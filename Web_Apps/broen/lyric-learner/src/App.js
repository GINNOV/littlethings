// FILE: src/App.js
// This is the main component that manages the application's state and brings all other components together.

import React, { useState, useEffect } from 'react';
import './App.css'; // Import the styles
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import { songData } from './data/lyricsData'; // Import the song data

export default function App() {
  const [activeLayer, setActiveLayer] = useState('all');
  const [settings] = useState({ slowSpeed: 0.5 });
  const [ariaLiveMessage, setAriaLiveMessage] = useState('');
  const [lastWordClicked, setLastWordClicked] = useState({ word: null, timer: null });

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

  return (
    <div className="App">
      <header className="App-header">
        <h1>Lyric Learner</h1>
        <h4>⭐️ bro edition ⭐️</h4>
        <p>Impariamo l'inglese interattivamente con la musica.</p>
      </header>
      <main>
        <LayerSelector
          layers={songData.layers}
          activeLayer={activeLayer}
          setActiveLayer={setActiveLayer}
        />
        <LyricsViewer
          songData={songData}
          activeLayer={activeLayer}
          onWordClick={handleWordClick}
        />
      </main>
      <div className="sr-only" aria-live="polite" aria-atomic="true">
        {ariaLiveMessage}
      </div>
    </div>
  );
}
