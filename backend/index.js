const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
};

const pool = mysql.createPool(dbConfig);

const LASTFM_API_KEY = process.env.LASTFM_API_KEY;
const LASTFM_BASE_URL = 'http://ws.audioscrobbler.com/2.0/';

// Test DB connection
app.get('/test-db', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT 1 + 1 AS result');
    res.json({ message: 'Database connected', result: rows[0].result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Fetch and store Last.fm top tracks (Updated to Prevent Duplicates)
app.get('/fetch-lastfm', async (req, res) => {
  try {
    console.log('Fetching Last.fm top tracks...');
    const response = await axios.get(`${LASTFM_BASE_URL}`, {
      params: { method: 'chart.getTopTracks', api_key: LASTFM_API_KEY, format: 'json', limit: 51 }
    });
    const tracks = response.data.tracks.track;

    // Get highest existing lfm IDs for songs
    const [maxSong] = await pool.query(
      "SELECT Song_ID FROM SONG WHERE Song_ID LIKE 'lfm%' ORDER BY CAST(SUBSTRING(Song_ID, 4) AS UNSIGNED) DESC LIMIT 1"
    );
    let songCounter = maxSong.length ? parseInt(maxSong[0].Song_ID.replace('lfm', '')) + 1 : 1;

    // Get highest existing lfm IDs for artists, start from 1001 to avoid overlap with Song_ID
    const [maxArtist] = await pool.query(
      "SELECT Artist_ID FROM ARTIST WHERE Artist_ID LIKE 'lfm%' ORDER BY CAST(SUBSTRING(Artist_ID, 4) AS UNSIGNED) DESC LIMIT 1"
    );
    let artistCounter = maxArtist.length ? Math.max(parseInt(maxArtist[0].Artist_ID.replace('lfm', '')) + 1, 1001) : 1001;

    // Map to track artistName -> Artist_ID
    const artistMap = {};

    let inserted = 0;
    let updated = 0;

    for (const track of tracks) {
      // Check if artist already has an Artist_ID in the map or database
      const artistName = track.artist.name;
      let artistId;
      if (artistMap[artistName]) {
        artistId = artistMap[artistName];
        console.log(`Reusing Artist_ID for ${artistName}: ${artistId}`);
      } else {
        const [existingArtist] = await pool.query(
          'SELECT Artist_ID, A_Genre, DebutDate FROM ARTIST WHERE A_Name = ?',
          [artistName]
        );
        console.log(`Artist lookup for ${artistName}:`, existingArtist);
        if (existingArtist.length) {
          artistId = existingArtist[0].Artist_ID;
          artistMap[artistName] = artistId;
          console.log(`Artist ${artistName} found in DB, using Artist_ID: ${artistId}, artistCounter: ${artistCounter}`);
        } else {
          artistId = `lfm${artistCounter++}`;
          artistMap[artistName] = artistId;
          console.log(`Creating new Artist_ID for ${artistName}: ${artistId}, artistCounter: ${artistCounter}`);
          try {
            // Fetch artist info for debut date
            const artistInfoResponse = await axios.get(`${LASTFM_BASE_URL}`, {
              params: { method: 'artist.getInfo', artist: artistName, api_key: LASTFM_API_KEY, format: 'json' }
            });
            const artistInfo = artistInfoResponse.data.artist || {};
            const debutYear = artistInfo.bio && artistInfo.bio.content ? artistInfo.bio.content.match(/\d{4}/)?.[0] : '2000';
            await pool.query(
              'INSERT INTO ARTIST (Artist_ID, A_Name, A_DOB, DebutDate, Nationality, A_Genre, Released_Albums) VALUES (?, ?, ?, ?, ?, ?, ?)',
              [artistId, artistName, '1970-01-01', `${debutYear}-01-01`, 'Unknown', 'Unknown', 1]
            );
            console.log(`Inserted artist: ${artistName} (${artistId}), DebutDate: ${debutYear}-01-01`);
            // Verify artist was inserted
            const [verifyArtist] = await pool.query(
              'SELECT Artist_ID FROM ARTIST WHERE Artist_ID = ?',
              [artistId]
            );
            if (!verifyArtist.length) {
              console.error(`Artist ${artistId} (${artistName}) not found after insertion`);
              continue;
            }
          } catch (artistErr) {
            console.error(`Failed to insert artist ${artistName}:`, artistErr.message);
            continue; // Skip this song if artist insertion fails
          }
        }
      }

      // Double-check artist exists before proceeding
      const [artistCheck] = await pool.query(
        'SELECT Artist_ID FROM ARTIST WHERE Artist_ID = ?',
        [artistId]
      );
      if (!artistCheck.length) {
        console.error(`Artist ${artistId} (${artistName}) not found in ARTIST table, attempting reinsertion`);
        try {
          const artistInfoResponse = await axios.get(`${LASTFM_BASE_URL}`, {
            params: { method: 'artist.getInfo', artist: artistName, api_key: LASTFM_API_KEY, format: 'json' }
          });
          const artistInfo = artistInfoResponse.data.artist || {};
          const debutYear = artistInfo.bio && artistInfo.bio.content ? artistInfo.bio.content.match(/\d{4}/)?.[0] : '2000';
          await pool.query(
            'INSERT INTO ARTIST (Artist_ID, A_Name, A_DOB, DebutDate, Nationality, A_Genre, Released_Albums) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [artistId, artistName, '1970-01-01', `${debutYear}-01-01`, 'Unknown', 'Unknown', 1]
          );
          console.log(`Reinserted artist: ${artistName} (${artistId})`);
        } catch (reinsertErr) {
          console.error(`Failed to reinsert artist ${artistName}:`, reinsertErr.message);
          continue;
        }
      }

      // Check if song exists by SongTitle and Artist_ID (to prevent duplicates)
      const [existingSong] = await pool.query(
        'SELECT Song_ID, Streams, S_ReleasedDate FROM SONG WHERE SongTitle = ? AND Artist_ID = ?',
        [track.name, artistId]
      );

      // Generate Song_ID only if inserting a new song
      let songId;
      if (!existingSong.length) {
        songId = `lfm${songCounter++}`;
      } else {
        songId = existingSong[0].Song_ID;
      }

      // Fetch track info
      const infoResponse = await axios.get(`${LASTFM_BASE_URL}`, {
        params: { method: 'track.getInfo', artist: track.artist.name, track: track.name, api_key: LASTFM_API_KEY, format: 'json' }
      });
      const trackInfo = infoResponse.data.track || {};
      let duration = trackInfo.duration ? Math.round(trackInfo.duration / 1000) : track.duration ? parseInt(track.duration) : 180;
      if (duration < 60 || duration > 600) duration = 180;
      const streams = parseInt(trackInfo.playcount || track.playcount || 100000, 10);

      // Get release date
      let releaseDate = '2025-01-01';
      let tagYear = null;
      // Fetch track tags
      let tags = [];
      const tagResponse = await axios.get(`${LASTFM_BASE_URL}`, {
        params: { method: 'track.getTopTags', artist: track.artist.name, track: track.name, api_key: LASTFM_API_KEY, format: 'json' }
      });
      tags = tagResponse.data.toptags?.tag || [];
      console.log(`Track tags for ${track.name}:`, tags.map(t => t.name));

      // Extract year from track tags
      for (const tag of tags) {
        const tagName = tag.name;
        if (/^\d{4}$/.test(tagName)) {
          const year = parseInt(tagName);
          if (year >= 1900 && year <= 2025) {
            tagYear = year;
            console.log(`Found tag year for ${track.name}: ${tagYear}`);
            break;
          }
        }
      }

      // If no tag year, fetch artist tags to look for a year
      if (!tagYear) {
        const artistTagResponse = await axios.get(`${LASTFM_BASE_URL}`, {
          params: { method: 'artist.getTopTags', artist: track.artist.name, api_key: LASTFM_API_KEY, format: 'json' }
        });
        const artistTags = artistTagResponse.data.toptags?.tag || [];
        console.log(`Artist tags for ${track.artist.name}:`, artistTags.map(t => t.name));
        for (const tag of artistTags) {
          const tagName = tag.name;
          if (/^\d{4}$/.test(tagName)) {
            const year = parseInt(tagName);
            if (year >= 1900 && year <= 2025) {
              tagYear = year;
              console.log(`Found tag year in artist tags for ${track.name}: ${tagYear}`);
              break;
            }
          }
        }
      }

      // Try album.releasedate
      if (trackInfo.album && trackInfo.album.releasedate) {
        const dateStr = trackInfo.album.releasedate.trim();
        console.log(`Raw album release date for ${track.name}: ${dateStr}`);
        const match = dateStr.match(/(\d{1,2}\s\w{3}\s\d{4})/);
        if (match) {
          const parsedDate = new Date(match[0]);
          if (!isNaN(parsedDate) && parsedDate.getFullYear() >= 1900 && parsedDate.getFullYear() <= 2025) {
            releaseDate = parsedDate.toISOString().split('T')[0];
          }
        }
      }

      // Try wiki.published
      if (releaseDate === '2025-01-01' && trackInfo.wiki && trackInfo.wiki.published) {
        const dateStr = trackInfo.wiki.published.trim();
        console.log(`Raw wiki published date for ${track.name}: ${dateStr}`);
        const match = dateStr.match(/(\d{1,2}\s\w{3}\s\d{4})/);
        if (match) {
          const parsedDate = new Date(match[0]);
          if (!isNaN(parsedDate) && parsedDate.getFullYear() >= 1900 && parsedDate.getFullYear() <= 2025) {
            // Use wiki.published only if it matches the tag year or if no tag year exists
            if (!tagYear || parsedDate.getFullYear() === tagYear) {
              releaseDate = parsedDate.toISOString().split('T')[0];
            }
          }
        }
      }

      // Use tag year if available
      if (tagYear && releaseDate === '2025-01-01') {
        releaseDate = `${tagYear}-01-01`;
        console.log(`Using tag year for ${track.name}: ${releaseDate}`);
      }

      // Fallback: If wiki.published is in the future and no tag year, default to 2024
      const parsedReleaseDate = new Date(releaseDate);
      const currentDate = new Date('2025-03-14'); // Current date as of the prompt
      if (parsedReleaseDate > currentDate && !tagYear) {
        releaseDate = '2024-01-01';
        console.log(`Wiki date for ${track.name} is in the future, defaulting to 2024-01-01`);
      }

      // Map genre
      let genre = 'Unknown';
      for (const tag of tags) {
        const tagName = tag.name.toLowerCase();
        if (tagToGenreMap[tagName]) {
          genre = tagToGenreMap[tagName];
          break;
        }
      }

      // Update artist genre
      if (genre !== 'Unknown') {
        await pool.query(
          'UPDATE ARTIST SET A_Genre = ? WHERE Artist_ID = ? AND (A_Genre = "Unknown" OR A_Genre IS NULL)',
          [genre, artistId]
        );
      } else {
        const artistTagResponse = await axios.get(`${LASTFM_BASE_URL}`, {
          params: { method: 'artist.getTopTags', artist: track.artist.name, api_key: LASTFM_API_KEY, format: 'json' }
        });
        const artistTags = artistTagResponse.data.toptags?.tag || [];
        for (const tag of artistTags) {
          const tagName = tag.name.toLowerCase();
          if (tagToGenreMap[tagName]) {
            genre = tagToGenreMap[tagName];
            await pool.query(
              'UPDATE ARTIST SET A_Genre = ? WHERE Artist_ID = ? AND (A_Genre = "Unknown" OR A_Genre IS NULL)',
              [genre, artistId]
            );
            break;
          }
        }
      }

      // Map mood
      let mood = tags.reduce((acc, tag) => acc || moodMap[tag.name.toLowerCase()], null) || genreToMoodMap[genre] || 'Unknown';

      // Map tempo
      const tempo = genreTempoMap[genre] || 120;

      // Insert or update song
      if (existingSong.length) {
        await pool.query(
          'UPDATE SONG SET Streams = ?, S_Duration = ?, S_Genre = ?, Mood = ?, Tempo = ?, S_ReleasedDate = ? WHERE Song_ID = ? AND Artist_ID = ?',
          [streams, duration, genre, mood, tempo, releaseDate, existingSong[0].Song_ID, artistId]
        );
        console.log(`Updated song: ${track.name} (${existingSong[0].Song_ID}), Artist_ID: ${artistId}, Streams: ${streams}, Genre: ${genre}, Mood: ${mood}, Tempo: ${tempo}, ReleaseDate: ${releaseDate}`);
        updated++;
      } else {
        await pool.query(
          'INSERT INTO SONG (Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [songId, artistId, track.name, duration, genre, mood, tempo, releaseDate, streams]
        );
        console.log(`Inserted song: ${track.name} (${songId}), Artist_ID: ${artistId}, Streams: ${streams}, Genre: ${genre}, Mood: ${mood}, Tempo: ${tempo}, ReleaseDate: ${releaseDate}`);
        inserted++;
      }
    }

    console.log('Final artistMap:', artistMap);
    res.json({ message: `Last.fm data processed: ${inserted} inserted, ${updated} updated` });
  } catch (err) {
    console.error('Error in /fetch-lastfm:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// CRUD: Get all songs
app.get('/songs', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM SONG');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CRUD: Add a song
app.post('/songs', async (req, res) => {
  const { Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams } = req.body;
  try {
    await pool.query(
      'INSERT INTO SONG (Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams]
    );
    res.status(201).json({ message: 'Song added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CRUD: Delete a song
app.delete('/songs/:Song_ID/:Artist_ID', async (req, res) => {
  const { Song_ID, Artist_ID } = req.params;
  try {
    await pool.query('DELETE FROM SONG WHERE Song_ID = ? AND Artist_ID = ?', [Song_ID, Artist_ID]);
    res.json({ message: 'Song deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Complex Query: Trending Songs
app.get('/trending-songs', async (req, res) => {
  try {
    console.log('Fetching trending songs...');
    const [existingSongs] = await pool.query(`
      SELECT S.SongTitle, S.Streams, A.A_Name, S.Song_ID
      FROM SONG S
      JOIN ARTIST A ON S.Artist_ID = A.Artist_ID
      WHERE S.Streams > 0
      ORDER BY S.Streams DESC
      LIMIT 5
    `);
    const enrichedSongs = existingSongs.map(song => ({
      SongTitle: song.SongTitle,
      Streams: song.Streams,
      A_Name: song.A_Name,
      Source: song.Song_ID.startsWith('lfm') ? 'LastFM' : 'Manual'
    }));
    res.json(enrichedSongs);
  } catch (err) {
    console.error('Error in /trending-songs:', err);
    res.status(500).json({ error: err.message });
  }
});

// Additional Queries
app.get('/top-user-preferences/:U_Name', async (req, res) => {
  const { U_Name } = req.params;
  try {
    const [rows] = await pool.query(
      'SELECT S.SongTitle, UB.LikedSongs FROM USER_BEHAVIOR UB JOIN LISTEN L ON UB.U_Name = L.U_Name JOIN SONG S ON L.Song_ID = S.Song_ID AND L.Artist_ID = S.Artist_ID WHERE UB.U_Name = ? ORDER BY UB.LikedSongs DESC LIMIT 3',
      [U_Name]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/artist-popularity', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT A.A_Name, SUM(S.Streams) AS TotalStreams FROM ARTIST A JOIN SONG S ON A.Artist_ID = S.Artist_ID GROUP BY A.A_Name ORDER BY TotalStreams DESC LIMIT 5'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/playlist-engagement/:U_Name', async (req, res) => {
  const { U_Name } = req.params;
  try {
    const [rows] = await pool.query(
      'SELECT P.PlaylistName, COUNT(PS.Song_ID) AS SongCount FROM PLAYLIST P JOIN PLAYLIST_SONG PS ON P.PlaylistName = PS.PlaylistName AND P.U_Name = PS.U_Name WHERE P.U_Name = ? GROUP BY P.PlaylistName ORDER BY SongCount DESC LIMIT 3',
      [U_Name]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/search-songs', async (req, res) => {
  const { mood, minTempo, maxTempo } = req.query;
  try {
    const [rows] = await pool.query(
      'SELECT S.SongTitle, A.A_Name, S.S_Duration FROM SONG S JOIN ARTIST A ON S.Artist_ID = A.Artist_ID JOIN SONG_ALBUM SA ON S.Song_ID = SA.Song_ID AND S.Artist_ID = SA.Artist_ID JOIN ALBUM AL ON SA.AlbumName = AL.AlbumName AND SA.Artist_ID = AL.Artist_ID WHERE S.Mood = ? AND S.Tempo BETWEEN ? AND ?',
      [mood, minTempo, maxTempo]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/update-listening-time', async (req, res) => {
  const { U_Name, Behavior_ID, AdditionalTime } = req.body;
  try {
    await pool.query(
      'UPDATE USER_BEHAVIOR SET TotalListeningTime = TotalListeningTime + ? WHERE U_Name = ? AND Behavior_ID = ?',
      [AdditionalTime, U_Name, Behavior_ID]
    );
    res.json({ message: 'Listening time updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/recommend/:U_Name', async (req, res) => {
  const { U_Name } = req.params;
  try {
    const [user] = await pool.query('SELECT PreferredGenre FROM USER WHERE U_Name = ?', [U_Name]);
    if (!user.length) return res.status(404).json({ error: 'User not found' });
    const preferredGenre = user[0].PreferredGenre;

    // Step 1: Get preferred genre recommendations
    const [genreSongs] = await pool.query(
      `SELECT S.Song_ID, S.Artist_ID, S.SongTitle, A.A_Name
       FROM SONG S
       JOIN ARTIST A ON S.Artist_ID = A.Artist_ID
       WHERE S.S_Genre = ? AND S.Song_ID NOT IN (SELECT Song_ID FROM LISTEN WHERE U_Name = ?)
       ORDER BY S.Streams DESC
       LIMIT 5`,
      [preferredGenre, U_Name]
    );

    let recommendations = genreSongs;

    // Step 2: If fewer than 3, add popular unlistened songs from other genres
    if (recommendations.length < 5) {
      const [additionalSongs] = await pool.query(
        `SELECT S.Song_ID, S.Artist_ID, S.SongTitle, A.A_Name
         FROM SONG S
         JOIN ARTIST A ON S.Artist_ID = A.Artist_ID
         WHERE S.Song_ID NOT IN (SELECT Song_ID FROM LISTEN WHERE U_Name = ?)
         AND S.Song_ID NOT IN (?)
         ORDER BY S.Streams DESC
         LIMIT ?`,
        [U_Name, recommendations.map(s => s.Song_ID).join(','), 5 - recommendations.length]
      );
      recommendations.push(...additionalSongs);
    }

    // Ensure exactly 3 recommendations (pad with random unlistened songs if needed)
    if (recommendations.length < 5) {
      const [randomSongs] = await pool.query(
        `SELECT S.Song_ID, S.Artist_ID, S.SongTitle, A.A_Name
         FROM SONG S
         JOIN ARTIST A ON S.Artist_ID = A.Artist_ID
         WHERE S.Song_ID NOT IN (SELECT Song_ID FROM LISTEN WHERE U_Name = ?)
         AND S.Song_ID NOT IN (?)
         ORDER BY RAND()
         LIMIT ?`,
        [U_Name, recommendations.map(s => s.Song_ID).join(','), 5 - recommendations.length]
      );
      recommendations.push(...randomSongs);
    }

    res.json(recommendations.map(song => ({ ...song, Source: song.Song_ID.startsWith('song') ? 'Manual' : 'LastFM' })));
  } catch (err) {
    console.error('Error in /recommend:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Mappings (unchanged)
const tagToGenreMap = {
  'rock': 'Rock', 'pop': 'Pop', 'hip hop': 'Hip-Hop', 'r&b': 'R&B', 'alternative': 'Alternative',
  'electronic': 'Electronic', 'folk': 'Folk', 'jazz': 'Jazz', 'classical': 'Classical', 'country': 'Country',
  'indie': 'Alternative', 'dance': 'Electronic', 'synthpop': 'Pop', 'indie pop': 'Pop', 'indie rock': 'Alternative',
  'hip-hop': 'Hip-Hop', 'rap': 'Hip-Hop', 'soul': 'Soul', 'funk': 'Pop', 'disco': 'Pop', 'house': 'Electronic',
  'techno': 'Electronic', 'trance': 'Electronic', 'punk': 'Rock', 'metal': 'Rock', 'blues': 'Rock',
  'reggae': 'Pop', 'ska': 'Pop', 'latin': 'Pop', 'k-pop': 'Pop', 'j-pop': 'Pop'
};
const moodMap = {
  'happy': 'Happy', 'sad': 'Sad', 'energetic': 'Energetic', 'calm': 'Calm', 'upbeat': 'Upbeat', 'chill': 'Relaxing',
  'melancholic': 'Sad', 'melancholy': 'Sad', 'relaxing': 'Relaxing', 'dreamy': 'Relaxing', 'angry': 'Energetic',
  'romantic': 'Romantic', 'uplifting': 'Happy', 'dark': 'Sad', 'mellow': 'Relaxing', 'introspective': 'Sad'
};
const genreToMoodMap = {
  'Rock': 'Energetic', 'Pop': 'Happy', 'Hip-Hop': 'Energetic', 'R&B': 'Romantic', 'Alternative': 'Sad',
  'Electronic': 'Energetic', 'Folk': 'Relaxed', 'Jazz': 'Relaxed', 'Classical': 'Relaxed', 'Country': 'Happy',
  'Soul': 'Romantic'
};
const genreTempoMap = {
  'Rock': 120, 'Pop': 115, 'Hip-Hop': 90, 'R&B': 85, 'Alternative': 110, 'Soul': 80, 'Jazz': 70,
  'Classical': 60, 'Country': 100, 'Electronic': 128
};

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));