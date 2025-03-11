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

// Fetch and store Last.fm top tracks
app.get('/fetch-lastfm', async (req, res) => {
  try {
    const response = await axios.get(`${LASTFM_BASE_URL}`, {
      params: {
        method: 'chart.getTopTracks',
        api_key: LASTFM_API_KEY,
        format: 'json',
        limit: 10
      }
    });
    const tracks = response.data.tracks.track;
    for (const track of tracks) {
      const songId = `lfm${track.mbid || track.url.split('/').pop()}`; // Unique ID
      const artistId = `lfm${track.artist.mbid || track.artist.url.split('/').pop()}`;
      await pool.query(
        'INSERT IGNORE INTO ARTIST (Artist_ID, A_Name, A_DOB, DebutDate, Nationality, A_Genre, Released_Albums) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [artistId, track.artist.name, '1970-01-01', '2000-01-01', 'Unknown', 'Unknown', 1]
      );
      await pool.query(
        'INSERT IGNORE INTO SONG (Song_ID, Artist_ID, SongTitle, S_Duration, S_Genre, Mood, Tempo, S_ReleasedDate, Streams) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [songId, artistId, track.name, track.duration || 180, 'Unknown', 'Unknown', 120, '2023-01-01', track.playcount || 0]
      );
    }
    res.json({ message: 'Last.fm data fetched and stored' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//Get all songs
app.get('/songs', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM SONG');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//Add a song
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

//Delete a song
app.delete('/songs/:Song_ID/:Artist_ID', async (req, res) => {
  const { Song_ID, Artist_ID } = req.params;
  try {
    await pool.query('DELETE FROM SONG WHERE Song_ID = ? AND Artist_ID = ?', [Song_ID, Artist_ID]);
    res.json({ message: 'Song deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//Trending Songs (Top 5 by Streams)
app.get('/trending-songs', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT S.SongTitle, S.Streams, A.A_Name FROM SONG S JOIN ARTIST A ON S.Artist_ID = A.Artist_ID ORDER BY S.Streams DESC LIMIT 5'
    );
    res.json(rows);
  } catch (err) {
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

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));