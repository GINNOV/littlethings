import React, { createContext, useState, useEffect, useContext } from 'react';

const SettingsContext = createContext();

export const useSettings = () => useContext(SettingsContext);

export const SettingsProvider = ({ children }) => {
  // Initialize state with a default value, NOT from localStorage.
  const [showTooltipSetting, setShowTooltipSetting] = useState(false);
  const [showItalianSetting, setShowItalianSetting] = useState(false);

  // Use useEffect to load the saved state from localStorage only on the client-side.
  useEffect(() => {
    const savedTooltip = localStorage.getItem('showTooltipSetting');
    if (savedTooltip !== null) {
      setShowTooltipSetting(JSON.parse(savedTooltip));
    }

    const savedItalian = localStorage.getItem('showItalianSetting');
    if (savedItalian !== null) {
      setShowItalianSetting(JSON.parse(savedItalian));
    }
  }, []); // The empty array [] ensures this runs only once after the component mounts in the browser.

  // Effects for SAVING state to localStorage.
  useEffect(() => {
    localStorage.setItem('showTooltipSetting', JSON.stringify(showTooltipSetting));
    if (!showTooltipSetting) {
      setShowItalianSetting(false);
    }
  }, [showTooltipSetting]);

  useEffect(() => {
    localStorage.setItem('showItalianSetting', JSON.stringify(showItalianSetting));
  }, [showItalianSetting]);

  const value = {
    showTooltipSetting,
    setShowTooltipSetting,
    showItalianSetting,
    setShowItalianSetting,
  };

  return (
    <SettingsContext.Provider value={value}>
      {children}
    </SettingsContext.Provider>
  );
};
