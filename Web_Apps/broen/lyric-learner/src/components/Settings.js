// FILE: src/components/Settings.js
// This component contains the settings controls for the application.

import React from 'react';

const Settings = ({ showTooltipSetting, setShowTooltipSetting }) => {
  const handleCheckboxChange = (e) => {
    setShowTooltipSetting(e.target.checked);
  };

  return (
    <div className="settings-container">
      <label htmlFor="tooltip-toggle">
        <input
          type="checkbox"
          id="tooltip-toggle"
          checked={showTooltipSetting}
          onChange={handleCheckboxChange}
        />
        Mostra esempio di uso
      </label>
    </div>
  );
};

export default Settings;