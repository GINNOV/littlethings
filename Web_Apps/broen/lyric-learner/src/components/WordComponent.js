import React from 'react';
import { useSettings } from '../context/SettingsContext';
import SpeakerIcon from './SpeakerIcon'; // Import the new icon component

const WordComponent = ({ wordData, activeLayer, songData, onWordClick, isCurrentWord, onExampleSpeak }) => {
  // rationale: Destructuring the new context values, including the specific 'aiutino' state.
  const { showTooltipSetting, showItalianSetting, tutor, aiutino } = useSettings();
  const { text, layer, example, italian, pronunciation } = wordData;
  const isHighlighted = activeLayer === 'all' || layer === activeLayer;
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

  const handleSpeakerClick = () => {
    if (onExampleSpeak) {
      onExampleSpeak(example);
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
        {/* rationale: Conditionally render the tooltip content based on the 'aiutino' setting. */}
        {aiutino === 'pronuncia' ? (
          <>
            <strong>Pronuncia</strong><br />
            <span className="pronunciation-text">🇮🇹 {pronunciation}</span>
          </>
        ) : (
          <>
            <strong>Esempio d&apos;uso</strong><br />
            <em className="example-text">
              🇺🇸 {example}
              {tutor && <SpeakerIcon onClick={handleSpeakerClick} className="speaker-icon" />}
            </em>
            {showItalianSetting && italian && <><br /><i>🇮🇹 {italian}</i></>}
          </>
        )}
      </div>
    </div>
  );
};

export default WordComponent;
