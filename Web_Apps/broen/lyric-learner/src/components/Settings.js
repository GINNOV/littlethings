// FILE: src/components/Settings.js
import React from 'react';
import { useSettings } from '../context/SettingsContext';

const Settings = () => {
  const {
    showTooltipSetting,
    setShowTooltipSetting,
    showItalianSetting,
    setShowItalianSetting
  } = useSettings();

  const handleTooltipCheckboxChange = (e) => {
    setShowTooltipSetting(e.target.checked);
  };

  const handleItalianCheckboxChange = (e) => {
    setShowItalianSetting(e.target.checked);
  };

  return (
    <div className="settings-container">
      <div className="setting-item">
        <span>Mostra esempio di uso</span>
        <div>
          <input
            type="checkbox"
            id="tooltip-toggle"
            checked={showTooltipSetting}
            onChange={handleTooltipCheckboxChange}
          />
          <label htmlFor="tooltip-toggle">Toggle</label>
        </div>
      </div>

      <div className={`setting-item ${!showTooltipSetting ? 'disabled' : ''}`}>
        <span>Mostra italiano</span>
        <div>
          <input
            type="checkbox"
            id="italian-toggle"
            checked={showItalianSetting}
            onChange={handleItalianCheckboxChange}
            disabled={!showTooltipSetting}
          />
          <label htmlFor="italian-toggle">Toggle</label>
        </div>
      </div>
    </div>
  );
};
export default Settings;
