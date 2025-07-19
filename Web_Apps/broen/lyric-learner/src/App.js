// FILE: src/App.js
// This is the main component that manages the application's state and brings all other components together.

import React, { useState, useEffect } from 'react';
import './App.css'; // Import the styles
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import Settings from './components/Settings'; // Import the new Settings component
import { songData } from './data/lyricsData'; // Import the song data

export default function App() {
  const [activeLayer, setActiveLayer] = useState(1);
  const [settings] = useState({ slowSpeed: 0.5 });
  const [ariaLiveMessage, setAriaLiveMessage] = useState('');
  const [lastWordClicked, setLastWordClicked] = useState({ word: null, timer: null });
  // Load the setting from localStorage, defaulting to false (off)
  const [showTooltipSetting, setShowTooltipSetting] = useState(() => {
    const saved = localStorage.getItem('showTooltipSetting');
    return saved !== null ? JSON.parse(saved) : false;
  });

  // Save the setting to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('showTooltipSetting', JSON.stringify(showTooltipSetting));
  }, [showTooltipSetting]);

  useEffect(() => {
    if (activeLayer === 'all') {
      setAriaLiveMessage('Showing all vocabulary layers.');
    } else {
      // Ensure songData.layers[activeLayer] exists before accessing name
      if (songData.layers[activeLayer]) {
        setAriaLiveMessage(`Now highlighting Layer ${activeLayer}: ${songData.layers[activeLayer].name}.`);
      }
    }
  }, [activeLayer]);

  const handleWordClick = (wordText) => {
    if (!window.speechSynthesis) {
      alert("Sorry, your browser doesn't support text-to-speech.");
      return;
    }
    
    window.speechSynthesis.cancel();
    clearTimeout(lastWordClicked.timer);

    const utterance = new SpeechSynthesisUtterance(wordText);
    
    if (lastWordClicked.word === wordText) {
      utterance.rate = 1.0;
      setLastWordClicked({ word: null, timer: null });
    } else {
      utterance.rate = settings.slowSpeed;
      const timer = setTimeout(() => setLastWordClicked({ word: null, timer: null }), 3000);
      setLastWordClicked({ word: wordText, timer });
    }
    
    window.speechSynthesis.speak(utterance);
  };
  
  const handleInstructionsClick = () => {
    if (!window.speechSynthesis) {
      alert("Sorry, your browser doesn't support text-to-speech.");
      return;
    }
    const message = "clicca sulle parole evidenziate per sentirne la pronuncia. Tieni il dito premuto piu' a lungo per vederne un esempio di uso di quella parola in una frase breve";
    const utterance = new SpeechSynthesisUtterance(message);
    utterance.lang = 'it-IT';
    window.speechSynthesis.speak(utterance);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Lyric Learner</h1>
        <h4>⭐️ bro edition ⭐️</h4>
        <p>Impariamo l'inglese interattivamente con la musica.</p>
        <button onClick={handleInstructionsClick} className="instructions-button">Instruzioni</button>
      </header>
      <main>
        <div className="top-controls">
          <LayerSelector
            layers={songData.layers}
            activeLayer={activeLayer}
            setActiveLayer={setActiveLayer}
          />
          <Settings
            showTooltipSetting={showTooltipSetting}
            setShowTooltipSetting={setShowTooltipSetting}
          />
        </div>
        <LyricsViewer
          songData={songData}
          activeLayer={activeLayer}
          onWordClick={handleWordClick}
          layers={songData.layers}
          showTooltipSetting={showTooltipSetting} // Pass the setting down
        />
      </main>
      <footer className="App-footer">
        (C) Garage Innovation LLC - USA
      </footer>
      <div className="sr-only" aria-live="polite" aria-atomic="true">
        {ariaLiveMessage}
      </div>
    </div>
  );
}