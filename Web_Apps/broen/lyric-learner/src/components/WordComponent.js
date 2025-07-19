// FILE: src/components/WordComponent.js
// This component handles the display and interaction for a single word.

import React from 'react';

const WordComponent = ({ wordData, activeLayer, songData, onWordClick, showTooltipSetting, showItalianSetting, isCurrentWord }) => {
  const { text, layer, example, italian } = wordData;
  const isHighlighted = activeLayer === 'all' || layer === activeLayer;

  // Tooltip should only be enabled if the setting is on AND the word belongs to the active layer.
  const canShowTooltip = showTooltipSetting && isHighlighted;

  const style = {
    opacity: isHighlighted ? 1 : 0.25,
    backgroundColor: isHighlighted && activeLayer !== 'all' ? songData.layers[layer]?.color : 'transparent',
    color: isHighlighted && activeLayer !== 'all' ? songData.layers[layer]?.textColor : 'inherit',
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

  const wrapperClassName = `word-wrapper ${canShowTooltip ? 'tooltips-enabled' : ''}`;
  const wordClassName = `word ${isCurrentWord ? 'current-word' : ''}`;

  return (
    <div className={wrapperClassName}>
        <span
          className={wordClassName}
          style={style}
          onClick={handleClick}
          onKeyDown={handleKeyDown}
          tabIndex="0"
          role="button"
          aria-label={`${text}. Layer ${layer}`}
        >
          {text}
        </span>
        <div className="word-tooltip">
            <strong>Esempio d'uso</strong><br/>
            <em>🇺🇸 {example}</em>
            {showItalianSetting && italian && <><br/><i>🇮🇹 {italian}</i></>}
        </div>
    </div>
  );
};

export default WordComponent;