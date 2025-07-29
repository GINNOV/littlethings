import React from 'react';

const SongSelector = ({ songs, selectedSongId, onSongChange }) => {
  if (!songs || songs.length === 0) {
    return <p>Loading songs...</p>;
  }

  return (
    <div className="selector-wrapper">
      <label htmlFor="song-select">Choose a song:</label>
      <select 
        id="song-select" 
        value={selectedSongId} 
        onChange={(e) => onSongChange(e.target.value)}
      >
        {songs.map((song) => (
          <option key={song.id} value={song.id}>
            {song.title}
          </option>
        ))}
      </select>
    </div>
  );
};

export default SongSelector;