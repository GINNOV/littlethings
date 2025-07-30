import React from 'react';
import { useSettings } from '../context/SettingsContext';

const Settings = () => {
  const {
    aiutino,
    setAiutino,
    tutor,
    setTutor
  } = useSettings();

  const handleAiutinoChange = (e) => {
    setAiutino(e.target.value);
  };

  const handleTutorChange = (e) => {
    setTutor(e.target.checked);
  };

  return (
    <div className="settings-container">
      <div className="setting-group">
        <span className="setting-label">Aiutino:</span>
        <div className="radio-group">
          <label>
            <input
              type="radio"
              name="aiutino"
              value="esempio"
              checked={aiutino === 'esempio'}
              onChange={handleAiutinoChange}
            />
            🇺🇸 Mostra esempio
          </label>
          <label>
            <input
              type="radio"
              name="aiutino"
              value="bilingue"
              checked={aiutino === 'bilingue'}
              onChange={handleAiutinoChange}
            />
            🇺🇸 + 🇮🇹 bilingue
          </label>
        </div>
      </div>

      <div className="setting-group">
        <span className="setting-label">Tutor:</span>
        <div className="checkbox-group">
          <label>
            <input
              type="checkbox"
              id="tutor-toggle"
              checked={tutor}
              onChange={handleTutorChange}
              // The tutor is only useful if an example is shown.
              disabled={aiutino === 'none'}
            />
            Pronuncia l'aiutino
          </label>
        </div>
      </div>
    </div>
  );
};
export default Settings;
