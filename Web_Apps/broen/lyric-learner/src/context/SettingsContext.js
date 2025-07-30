import React, { createContext, useState, useEffect, useContext } from 'react';

const SettingsContext = createContext();

export const useSettings = () => useContext(SettingsContext);

export const SettingsProvider = ({ children }) => {
  // rationale: 'aiutino' state now manages the helper visibility.
  // 'none' = off, 'esempio' = show example, 'bilingue' = show example + italian.
  const [aiutino, setAiutino] = useState('none');
  // rationale: 'tutor' state manages the text-to-speech feature for examples.
  const [tutor, setTutor] = useState(false);

  // Load saved settings from localStorage on initial client-side render.
  useEffect(() => {
    const savedAiutino = localStorage.getItem('aiutino');
    if (savedAiutino !== null) {
      setAiutino(savedAiutino);
    }

    const savedTutor = localStorage.getItem('tutor');
    if (savedTutor !== null) {
      setTutor(JSON.parse(savedTutor));
    }
  }, []);

  // Save 'aiutino' setting to localStorage whenever it changes.
  useEffect(() => {
    localStorage.setItem('aiutino', aiutino);
  }, [aiutino]);

  // Save 'tutor' setting to localStorage whenever it changes.
  useEffect(() => {
    localStorage.setItem('tutor', JSON.stringify(tutor));
  }, [tutor]);

  // Deprecated states are kept for now to avoid breaking other components,
  // but they are now controlled by the new 'aiutino' state.
  const showTooltipSetting = aiutino !== 'none';
  const showItalianSetting = aiutino === 'bilingue';

  const value = {
    aiutino,
    setAiutino,
    tutor,
    setTutor,
    // Provide the derived legacy values for compatibility during refactoring.
    showTooltipSetting,
    showItalianSetting,
  };

  return (
    <SettingsContext.Provider value={value}>
      {children}
    </SettingsContext.Provider>
  );
};
