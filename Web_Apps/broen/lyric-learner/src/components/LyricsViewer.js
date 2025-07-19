// FILE: src/components/LyricsViewer.js
// This component displays the song title, artist, and all the stanzas.

import React from 'react';
import WordComponent from './WordComponent';

const LyricsViewer = ({ songData, activeLayer, onWordClick }) => {
  return (
    <div className="lyrics-container">
      <h2 className="poem-title">{songData.title}</h2>
      <p className="poem-author">by {songData.author}</p>
      {songData.stanzas.map((stanza, stanzaIndex) => (
        <div className="stanza" key={stanzaIndex}>
          {stanza.map((word, wordIndex) => (
            <WordComponent
              key={wordIndex}
              wordData={word}
              activeLayer={activeLayer}
              songData={songData}
              onWordClick={onWordClick}
            />
          ))}
        </div>
      ))}
    </div>
  );
};

export default LyricsViewer;
