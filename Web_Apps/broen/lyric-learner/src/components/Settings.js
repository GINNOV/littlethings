// FILE: src/components/Settings.js
// This component contains the settings controls for the application.

import React from 'react';

const Settings = ({ showTooltipSetting, setShowTooltipSetting, showItalianSetting, setShowItalianSetting }) => {
  const handleTooltipCheckboxChange = (e) => {
    setShowTooltipSetting(e.target.checked);
  };
  
  const handleItalianCheckboxChange = (e) => {
    setShowItalianSetting(e.target.checked);
  };

  return (
    <div className="settings-container">
      <label htmlFor="tooltip-toggle" className="setting-item">
        <input
          type="checkbox"
          id="tooltip-toggle"
          checked={showTooltipSetting}
          onChange={handleTooltipCheckboxChange}
        />
        Mostra esempio di uso
      </label>
      <label htmlFor="italian-toggle" className={`setting-item ${!showTooltipSetting ? 'disabled' : ''}`}>
        <input
          type="checkbox"
          id="italian-toggle"
          checked={showItalianSetting}
          onChange={handleItalianCheckboxChange}
          disabled={!showTooltipSetting}
        />
        Mostra italiano
      </label>
    </div>
  );
};

export default Settings;