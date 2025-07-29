import React, { useState, useEffect } from 'react';
import dynamic from 'next/dynamic';
import Link from 'next/link'; // Import the Link component

// Dynamically import the TimingTool to ensure it only loads on the client
const TimingTool = dynamic(() => import('../src/components/TimingTool'), {
  ssr: false,
});

export default function AdminPage() {
  const [songs, setSongs] = useState([]);
  const [selectedSongId, setSelectedSongId] = useState('');
  const [newSong, setNewSong] = useState({ title: '', author: '', youtubeVideoId: '', lyrics: '' });
  const [message, setMessage] = useState('');

  // Fetch the list of songs when the component mounts
  useEffect(() => {
    fetchSongs();
  }, []);

  const fetchSongs = async () => {
    try {
      const res = await fetch('/api/songs');
      const data = await res.json();
      setSongs(data);
    } catch (error) {
      setMessage('Error fetching songs.');
      console.error(error);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewSong(prev => ({ ...prev, [name]: value }));
  };

  const handleAddSong = async (e) => {
    e.preventDefault();
    if (!newSong.lyrics.trim()) {
        setMessage('Lyrics cannot be empty.');
        return;
    }
    setMessage('Adding song...');
    try {
      const res = await fetch('/api/songs/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newSong),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to add song.');
      }
      setMessage(`Song "${data.title}" added successfully!`);
      setNewSong({ title: '', author: '', youtubeVideoId: '', lyrics: '' }); // Reset form
      fetchSongs(); // Refresh the song list
    } catch (error) {
      setMessage(error.message);
      console.error(error);
    }
  };

  return (
    <div className="admin-container">
      <header className="admin-header">
        <h1>Lyric Learner Admin</h1>
        {/* FIX: Replaced <a> with <Link> for client-side navigation */}
        <Link href="/" className="back-link">
          ← Back to App
        </Link>
      </header>
      
      <div className="admin-section">
        <h2>Add New Song</h2>
        <form onSubmit={handleAddSong} className="add-song-form">
          <input
            type="text"
            name="title"
            placeholder="Song Title"
            value={newSong.title}
            onChange={handleInputChange}
            required
          />
          <input
            type="text"
            name="author"
            placeholder="Artist / Author"
            value={newSong.author}
            onChange={handleInputChange}
            required
          />
          <input
            type="text"
            name="youtubeVideoId"
            placeholder="YouTube Video ID (e.g., a_v-4p84odw)"
            value={newSong.youtubeVideoId}
            onChange={handleInputChange}
            required
          />
          <textarea
            name="lyrics"
            placeholder="Paste lyrics here. One stanza per line."
            value={newSong.lyrics}
            onChange={handleInputChange}
            required
            rows="10"
          ></textarea>
          <button type="submit">Add Song</button>
        </form>
        {message && <p className="message">{message}</p>}
      </div>

      <div className="admin-section">
        <h2>Manage Word Timings</h2>
        <select 
          value={selectedSongId} 
          onChange={(e) => setSelectedSongId(e.target.value)}
          className="song-select"
        >
          <option value="">-- Select a Song to Manage --</option>
          {songs.map(song => (
            <option key={song.id} value={song.id}>{song.title}</option>
          ))}
        </select>
        
        {/* The TimingTool will only appear if a song is selected */}
        {selectedSongId && <TimingTool songId={selectedSongId} />}
      </div>
    </div>
  );
}
