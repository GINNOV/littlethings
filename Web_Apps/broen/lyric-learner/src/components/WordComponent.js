// FILE: src/components/WordComponent.js
// This component handles the display and interaction for a single word.

import React from 'react';

const WordComponent = ({ wordData, activeLayer, songData, onWordClick, showTooltipSetting }) => {
  const { text, layer, example } = wordData;
  const layerInfo = songData.layers[layer] || {};
  const isHighlighted = activeLayer === 'all' || layer === activeLayer;

  const style = {
    opacity: isHighlighted ? 1 : 0.25,
    backgroundColor: isHighlighted && activeLayer !== 'all' ? layerInfo.color : 'transparent',
    color: isHighlighted && activeLayer !== 'all' ? layerInfo.textColor : 'inherit',
    fontWeight: isHighlighted && activeLayer !== 'all' ? '600' : '400',
  };
  
  const handleClick = (e) => {
    e.stopPropagation();
    onWordClick(text);
  };
  
  const handleKeyDown = (event) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      handleClick(event);
    }
  };

  // Add a class to the wrapper if tooltips are enabled
  const wrapperClassName = `word-wrapper ${showTooltipSetting ? 'tooltips-enabled' : ''}`;

  return (
    <div className={wrapperClassName}>
        <span
          className="word"
          style={style}
          onClick={handleClick}
          onKeyDown={handleKeyDown}
          tabIndex="0"
          role="button"
          aria-label={`${text}. Layer ${layer}: ${layerInfo.name}`}
        >
          {text}
        </span>
        <div className="word-tooltip">
            <strong>{layerInfo.name || 'N/A'}</strong><br/>
            <em>{example}</em>
        </div>
    </div>
  );
};

export default WordComponent;