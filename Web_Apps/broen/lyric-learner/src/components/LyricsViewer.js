// FILE: src/components/LyricsViewer.js
// This component displays the song title, artist, and all the stanzas.

import React from 'react';
import WordComponent from './WordComponent';

const LyricsViewer = ({ songData, activeLayer, onWordClick, layers, showTooltipSetting, showItalianSetting, activeWordIndex }) => {
  let wordCounter = -1;
  const youtubeLink = "https://www.youtube.com/watch?v=9C1BCAgu2I8&list=RD9C1BCAgu2I8&start_radio=1"; // Your provided link

  return (
    <div className="lyrics-container">
      <h2 className="poem-title">
        <a href={youtubeLink} target="_blank" rel="noopener noreferrer">
            {songData.title}
        </a>
      </h2>
      <p className="poem-author">by {songData.author}</p>
      {songData.stanzas.map((stanza, stanzaIndex) => (
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
                showTooltipSetting={showTooltipSetting}
                showItalianSetting={showItalianSetting}
                isCurrentWord={isCurrentWord}
              />
            );
          })}
        </div>
      ))}
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