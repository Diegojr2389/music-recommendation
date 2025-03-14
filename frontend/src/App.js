import React, { useState } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [username, setUsername] = useState('');
  const [recommendations, setRecommendations] = useState([]);
  const [trendingSongs, setTrendingSongs] = useState([]);
  const [userPreferences, setUserPreferences] = useState([]);
  const [artistPopularity, setArtistPopularity] = useState([]);
  const [playlistEngagement, setPlaylistEngagement] = useState([]);
  const [searchResults, setSearchResults] = useState([]);
  const [searchMood, setSearchMood] = useState('');
  const [searchMinTempo, setSearchMinTempo] = useState('');
  const [searchMaxTempo, setSearchMaxTempo] = useState('');
  const [newSong, setNewSong] = useState({ Song_ID: '', Artist_ID: '', SongTitle: '', S_Duration: '', S_Genre: '', Mood: '', Tempo: '', S_ReleasedDate: '', Streams: '' });
  const [listeningTime, setListeningTime] = useState({ U_Name: '', Behavior_ID: '', AdditionalTime: '' });
  const [deleteSongId, setDeleteSongId] = useState('');
  const [deleteArtistId, setDeleteArtistId] = useState('');
  const [fetchMessage, setFetchMessage] = useState(''); // New state for fetch feedback

  // Fetch Last.fm Songs (New)
  const handleFetchLastFm = () => {
    axios.get('http://localhost:5000/fetch-lastfm')
      .then(response => {
        console.log('Fetch Result:', response.data);
        setFetchMessage(response.data.message);
      })
      .catch(error => {
        console.error('Error fetching Last.fm songs:', error);
        setFetchMessage('Error fetching songs: ' + error.message);
      });
  };

  // Fetch Recommendations
  const handleGetRecommendations = () => {
    console.log('Fetching recommendations for:', username);
    axios.get(`http://localhost:5000/recommend/${username}`)
      .then(response => {
        console.log('Recommendations:', response.data);
        setRecommendations(response.data);
      })
      .catch(error => console.error('Error fetching recommendations:', error));
  };

  // Fetch Trending Songs
  const handleGetTrendingSongs = () => {
    axios.get('http://localhost:5000/trending-songs')
      .then(response => {
        console.log('Trending Songs:', response.data);
        setTrendingSongs(response.data);
      })
      .catch(error => console.error('Error fetching trending songs:', error));
  };

  // Fetch Top User Preferences
  const handleGetUserPreferences = () => {
    axios.get(`http://localhost:5000/top-user-preferences/${username}`)
      .then(response => {
        console.log('User Preferences:', response.data);
        setUserPreferences(response.data);
      })
      .catch(error => console.error('Error fetching user preferences:', error));
  };

  // Fetch Artist Popularity
  const handleGetArtistPopularity = () => {
    axios.get('http://localhost:5000/artist-popularity')
      .then(response => {
        console.log('Artist Popularity:', response.data);
        setArtistPopularity(response.data);
      })
      .catch(error => console.error('Error fetching artist popularity:', error));
  };

  // Fetch Playlist Engagement
  const handleGetPlaylistEngagement = () => {
    axios.get(`http://localhost:5000/playlist-engagement/${username}`)
      .then(response => {
        console.log('Playlist Engagement:', response.data);
        setPlaylistEngagement(response.data);
      })
      .catch(error => console.error('Error fetching playlist engagement:', error));
  };

  // Search Songs by Mood and Tempo
  const handleSearchSongs = () => {
    axios.get('http://localhost:5000/search-songs', {
      params: { mood: searchMood, minTempo: searchMinTempo, maxTempo: searchMaxTempo }
    })
      .then(response => {
        console.log('Search Results:', response.data);
        setSearchResults(response.data);
      })
      .catch(error => console.error('Error searching songs:', error));
  };

  // Add a Song
  const handleAddSong = () => {
    axios.post('http://localhost:5000/songs', newSong)
      .then(response => {
        console.log('Song Added:', response.data);
        setNewSong({ Song_ID: '', Artist_ID: '', SongTitle: '', S_Duration: '', S_Genre: '', Mood: '', Tempo: '', S_ReleasedDate: '', Streams: '' });
      })
      .catch(error => console.error('Error adding song:', error));
  };

  // Delete a Song
  const handleDeleteSong = (songId, artistId) => {
    axios.delete(`http://localhost:5000/songs/${songId}/${artistId}`)
      .then(response => {
        console.log('Song Deleted:', response.data);
      })
      .catch(error => console.error('Error deleting song:', error));
  };

  // Update Listening Time
  const handleUpdateListeningTime = () => {
    axios.post('http://localhost:5000/update-listening-time', listeningTime)
      .then(response => {
        console.log('Listening Time Updated:', response.data);
        setListeningTime({ U_Name: '', Behavior_ID: '', AdditionalTime: '' });
      })
      .catch(error => console.error('Error updating listening time:', error));
  };

  return (
    <div className="App">
      <h1>Music Recommendation Platform</h1>

      {/* Username Input */}
      <div>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="Enter username"
        />
      </div>

      {/* Fetch Last.fm Songs (New) */}
      <div>
        <h2>Fetch Last.fm Songs</h2>
        <button onClick={handleFetchLastFm}>Fetch Last.fm Songs</button>
        <p>{fetchMessage || 'Click to fetch top tracks from Last.fm'}</p>
      </div>

      {/* Recommendations */}
      <div>
        <h2>Recommended Songs</h2>
        <button onClick={handleGetRecommendations}>Get Recommendations</button>
        <ul>
          {recommendations.length > 0 ? (
            recommendations.map((rec, index) => (
              <li key={index}>
                {rec.SongTitle} by {rec.A_Name}
                {rec.Source === 'LastFM' && (
                  <span style={{ color: 'blue', marginLeft: '10px' }}>(Powered by Last.fm)</span>
                )}
              </li>
            ))
          ) : (
            <li>No recommendations available</li>
          )}
        </ul>
      </div>

      {/* Trending Songs */}
      <div>
        <h2>Trending Songs</h2>
        <button onClick={handleGetTrendingSongs}>Get Trending Songs</button>
        <ul>
          {trendingSongs.length > 0 ? (
            trendingSongs.map((song, index) => (
              <li key={index}>
                {song.SongTitle} by {song.A_Name} (Streams: {song.Streams})
                {song.Source === 'LastFM' && (
                  <span style={{ color: 'blue', marginLeft: '10px' }}>(Powered by Last.fm)</span>
                )}
              </li>
            ))
          ) : (
            <li>No trending songs available</li>
          )}
        </ul>
      </div>

      {/* Top User Preferences */}
      <div>
        <h2>Top User Preferences</h2>
        <button onClick={handleGetUserPreferences}>Get User Preferences</button>
        <ul>
          {userPreferences.length > 0 ? (
            userPreferences.map((pref, index) => (
              <li key={index}>{pref.SongTitle} (LikedSongs: {pref.LikedSongs})</li>
            ))
          ) : (
            <li>No user preferences available</li>
          )}
        </ul>
      </div>

      {/* Artist Popularity */}
      <div>
        <h2>Artist Popularity</h2>
        <button onClick={handleGetArtistPopularity}>Get Artist Popularity</button>
        <ul>
          {artistPopularity.length > 0 ? (
            artistPopularity.map((artist, index) => (
              <li key={index}>{artist.A_Name} (Total Streams: {artist.TotalStreams})</li>
            ))
          ) : (
            <li>No artist popularity data available</li>
          )}
        </ul>
      </div>

      {/* Playlist Engagement */}
      <div>
        <h2>Playlist Engagement</h2>
        <button onClick={handleGetPlaylistEngagement}>Get Playlist Engagement</button>
        <ul>
          {playlistEngagement.length > 0 ? (
            playlistEngagement.map((playlist, index) => (
              <li key={index}>{playlist.PlaylistName} (Song Count: {playlist.SongCount})</li>
            ))
          ) : (
            <li>No playlist engagement data available</li>
          )}
        </ul>
      </div>

      {/* Search Songs by Mood and Tempo */}
      <div>
        <h2>Search Songs by Mood and Tempo</h2>
        <input
          type="text"
          value={searchMood}
          onChange={(e) => setSearchMood(e.target.value)}
          placeholder="Mood"
        />
        <input
          type="number"
          value={searchMinTempo}
          onChange={(e) => setSearchMinTempo(e.target.value)}
          placeholder="Min Tempo"
        />
        <input
          type="number"
          value={searchMaxTempo}
          onChange={(e) => setSearchMaxTempo(e.target.value)}
          placeholder="Max Tempo"
        />
        <button onClick={handleSearchSongs}>Search</button>
        <ul>
          {searchResults.length > 0 ? (
            searchResults.map((song, index) => (
              <li key={index}>{song.SongTitle} by {song.A_Name} (Duration: {song.S_Duration})</li>
            ))
          ) : (
            <li>No search results available</li>
          )}
        </ul>
      </div>

      {/* Add a Song */}
      <div>
        <h2>Add a Song</h2>
        <input
          type="text"
          value={newSong.Song_ID}
          onChange={(e) => setNewSong({ ...newSong, Song_ID: e.target.value })}
          placeholder="Song ID"
        />
        <input
          type="text"
          value={newSong.Artist_ID}
          onChange={(e) => setNewSong({ ...newSong, Artist_ID: e.target.value })}
          placeholder="Artist ID"
        />
        <input
          type="text"
          value={newSong.SongTitle}
          onChange={(e) => setNewSong({ ...newSong, SongTitle: e.target.value })}
          placeholder="Song Title"
        />
        <input
          type="number"
          value={newSong.S_Duration}
          onChange={(e) => setNewSong({ ...newSong, S_Duration: e.target.value })}
          placeholder="Duration"
        />
        <input
          type="text"
          value={newSong.S_Genre}
          onChange={(e) => setNewSong({ ...newSong, S_Genre: e.target.value })}
          placeholder="Genre"
        />
        <input
          type="text"
          value={newSong.Mood}
          onChange={(e) => setNewSong({ ...newSong, Mood: e.target.value })}
          placeholder="Mood"
        />
        <input
          type="number"
          value={newSong.Tempo}
          onChange={(e) => setNewSong({ ...newSong, Tempo: e.target.value })}
          placeholder="Tempo"
        />
        <input
          type="date"
          value={newSong.S_ReleasedDate}
          onChange={(e) => setNewSong({ ...newSong, S_ReleasedDate: e.target.value })}
          placeholder="Release Date"
        />
        <input
          type="number"
          value={newSong.Streams}
          onChange={(e) => setNewSong({ ...newSong, Streams: e.target.value })}
          placeholder="Streams"
        />
        <button onClick={handleAddSong}>Add Song</button>
      </div>

      {/* Delete a Song */}
      <div>
        <h2>Delete a Song</h2>
        <input
          type="text"
          value={deleteSongId}
          onChange={(e) => setDeleteSongId(e.target.value)}
          placeholder="Enter Song ID"
        />
        <input
          type="text"
          value={deleteArtistId}
          onChange={(e) => setDeleteArtistId(e.target.value)}
          placeholder="Enter Artist ID"
        />
        <button onClick={() => handleDeleteSong(deleteSongId, deleteArtistId)}>Delete Song</button>
      </div>

      {/* Update Listening Time */}
      <div>
        <h2>Update Listening Time</h2>
        <input
          type="text"
          value={listeningTime.U_Name}
          onChange={(e) => setListeningTime({ ...listeningTime, U_Name: e.target.value })}
          placeholder="Username"
        />
        <input
          type="text"
          value={listeningTime.Behavior_ID}
          onChange={(e) => setListeningTime({ ...listeningTime, Behavior_ID: e.target.value })}
          placeholder="Behavior ID"
        />
        <input
          type="number"
          value={listeningTime.AdditionalTime}
          onChange={(e) => setListeningTime({ ...listeningTime, AdditionalTime: e.target.value })}
          placeholder="Additional Time (minutes)"
        />
        <button onClick={handleUpdateListeningTime}>Update Listening Time</button>
      </div>
    </div>
  );
}

export default App;