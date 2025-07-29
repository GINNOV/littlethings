import React from 'react';
import WordComponent from './WordComponent';

const LyricsViewer = ({ songData, activeLayer, onWordClick, layers, activeWordIndex }) => {
  let wordCounter = -1;

  return (
    <div className="lyrics-container">
      <h2 className="poem-title">
        <a href={songData.youtubeLink} target="_blank" rel="noopener noreferrer">
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