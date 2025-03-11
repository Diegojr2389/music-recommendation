import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [songs, setSongs] = useState([]);
  const [newSong, setNewSong] = useState({
    Song_ID: '', Artist_ID: '', SongTitle: '', S_Duration: '', S_Genre: '', Mood: '', Tempo: '', S_ReleasedDate: '', Streams: ''
  });
  const [trendingSongs, setTrendingSongs] = useState([]);
  const [userPreferences, setUserPreferences] = useState([]);
  const [artistPopularity, setArtistPopularity] = useState([]);
  const [playlistEngagement, setPlaylistEngagement] = useState([]);
  const [username, setUsername] = useState('user1');

  useEffect(() => {
    axios.get('http://localhost:5000/songs')
      .then(response => setSongs(response.data))
      .catch(error => console.error(error));
  }, []);

  const handleAddSong = () => {
    axios.post('http://localhost:5000/songs', newSong)
      .then(() => {
        setSongs([...songs, newSong]);
        setNewSong({ Song_ID: '', Artist_ID: '', SongTitle: '', S_Duration: '', S_Genre: '', Mood: '', Tempo: '', S_ReleasedDate: '', Streams: '' });
      })
      .catch(error => console.error(error));
  };

  const handleDeleteSong = (Song_ID, Artist_ID) => {
    axios.delete(`http://localhost:5000/songs/${Song_ID}/${Artist_ID}`)
      .then(() => setSongs(songs.filter(song => song.Song_ID !== Song_ID || song.Artist_ID !== Artist_ID)))
      .catch(error => console.error(error));
  };

  const handleGetTrendingSongs = () => {
    axios.get('http://localhost:5000/trending-songs')
      .then(response => setTrendingSongs(response.data))
      .catch(error => console.error(error));
  };

  const handleGetUserPreferences = () => {
    axios.get(`http://localhost:5000/top-user-preferences/${username}`)
      .then(response => setUserPreferences(response.data))
      .catch(error => console.error(error));
  };

  const handleGetArtistPopularity = () => {
    axios.get('http://localhost:5000/artist-popularity')
      .then(response => setArtistPopularity(response.data))
      .catch(error => console.error(error));
  };

  const handleGetPlaylistEngagement = () => {
    axios.get(`http://localhost:5000/playlist-engagement/${username}`)
      .then(response => setPlaylistEngagement(response.data))
      .catch(error => console.error(error));
  };

  return (
    <div className="App">
      <h1>Music Recommendation Platform</h1>

      <h2>Songs</h2>
      <ul>
        {songs.map(song => (
          <li key={`${song.Song_ID}-${song.Artist_ID}`}>
            {song.SongTitle} - Streams: {song.Streams}
            <button onClick={() => handleDeleteSong(song.Song_ID, song.Artist_ID)}>Delete</button>
          </li>
        ))}
      </ul>

      <h2>Add Song</h2>
      <input placeholder="Song ID" value={newSong.Song_ID} onChange={e => setNewSong({ ...newSong, Song_ID: e.target.value })} />
      <input placeholder="Artist ID" value={newSong.Artist_ID} onChange={e => setNewSong({ ...newSong, Artist_ID: e.target.value })} />
      <input placeholder="Title" value={newSong.SongTitle} onChange={e => setNewSong({ ...newSong, SongTitle: e.target.value })} />
      <input placeholder="Duration (sec)" value={newSong.S_Duration} onChange={e => setNewSong({ ...newSong, S_Duration: e.target.value })} />
      <input placeholder="Genre" value={newSong.S_Genre} onChange={e => setNewSong({ ...newSong, S_Genre: e.target.value })} />
      <input placeholder="Mood" value={newSong.Mood} onChange={e => setNewSong({ ...newSong, Mood: e.target.value })} />
      <input placeholder="Tempo" value={newSong.Tempo} onChange={e => setNewSong({ ...newSong, Tempo: e.target.value })} />
      <input placeholder="Release Date (YYYY-MM-DD)" value={newSong.S_ReleasedDate} onChange={e => setNewSong({ ...newSong, S_ReleasedDate: e.target.value })} />
      <input placeholder="Streams" value={newSong.Streams} onChange={e => setNewSong({ ...newSong, Streams: e.target.value })} />
      <button onClick={handleAddSong}>Add Song</button>

      <h2>Queries</h2>
      <div>
        <h3>Trending Songs</h3>
        <button onClick={handleGetTrendingSongs}>Get Trending Songs</button>
        <ul>
          {trendingSongs.map((song, index) => (
            <li key={index}>{song.SongTitle} by {song.A_Name} - Streams: {song.Streams}</li>
          ))}
        </ul>
      </div>
      <div>
        <h3>Top User Preferences</h3>
        <input placeholder="Username" value={username} onChange={e => setUsername(e.target.value)} />
        <button onClick={handleGetUserPreferences}>Get Preferences</button>
        <ul>
          {userPreferences.map((song, index) => (
            <li key={index}>{song.SongTitle} - Likes: {song.LikedSongs}</li>
          ))}
        </ul>
      </div>
      <div>
        <h3>Artist Popularity</h3>
        <button onClick={handleGetArtistPopularity}>Get Popular Artists</button>
        <ul>
          {artistPopularity.map((artist, index) => (
            <li key={index}>{artist.A_Name} - Total Streams: {artist.TotalStreams}</li>
          ))}
        </ul>
      </div>
      <div>
        <h3>Playlist Engagement</h3>
        <input placeholder="Username" value={username} onChange={e => setUsername(e.target.value)} />
        <button onClick={handleGetPlaylistEngagement}>Get Engagement</button>
        <ul>
          {playlistEngagement.map((playlist, index) => (
            <li key={index}>{playlist.PlaylistName} - Songs: {playlist.SongCount}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
