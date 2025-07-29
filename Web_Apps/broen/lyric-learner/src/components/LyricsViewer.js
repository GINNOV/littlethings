import React from 'react';
import WordComponent from './WordComponent';

const LyricsViewer = ({ songData, activeLayer, onWordClick, layers, activeWordIndex }) => {
  let wordCounter = -1;

  // --- DIAGNOSTIC LOG ---
  // This will show us the exact data being received by this component in the browser console.
  //console.log("LyricsViewer received songData:", songData);

  // Check if stanzas exist and have content
  const hasLyrics = songData && songData.stanzas && songData.stanzas.length > 0 && songData.stanzas.some(stanza => stanza.length > 0);

  return (
    <div className="lyrics-container">
      <h2 className="poem-title">
        <a href={songData.youtubeLink} target="_blank" rel="noopener noreferrer">
          {songData.title}
        </a>
      </h2>
      <p className="poem-author">by {songData.author}</p>
      
      {/* --- FIX: Conditional rendering for lyrics --- */}
      {hasLyrics ? (
        songData.stanzas.map((stanza, stanzaIndex) => (
          <div className="stanza" key={stanzaIndex}>
            {stanza.map((word, wordIndex) => {
              wordCounter++;
              const isCurrentWord = wordCounter === activeWordIndex;
              return (
                <WordComponent
                  key={wordIndex}
                  wordData={word}
                  activeLayer={activeLayer}
                  songData={songData}
                  onWordClick={onWordClick}
                  isCurrentWord={isCurrentWord}
                />
              );
            })}
          </div>
        ))
      ) : (
        <p className="no-lyrics-message">Lyrics for this song are not available yet.</p>
      )}

      <div className="legend">
        {Object.entries(layers).map(([layerNum, layerData]) => (
          <div key={layerNum} className="legend-item">
            <span className="legend-color-box" style={{ backgroundColor: layerData.color, border: `1px solid ${layerData.textColor}` }}></span>
            {layerData.name}
          </div>
        ))}
      </div>
    </div>
  );
};

export default LyricsViewer;
