// FILE: src/App.js
// This is the main component that manages the application's state and brings all other components together.

import React, { useState, useEffect, useRef } from 'react';
import './App.css'; // Import the styles
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import Settings from './components/Settings';
import YouTubePlayer from './components/YouTubePlayer';
import ProgressBar from './components/ProgressBar';
import { songData } from './data/lyricsData';
import packageJson from '../package.json'; // Import package.json

export default function App() {
  const [activeLayer, setActiveLayer] = useState(1);
  const [settings] = useState({ slowSpeed: 0.5 });
  const [lastWordClicked, setLastWordClicked] = useState({ word: null, timer: null });
  
  const [showTooltipSetting, setShowTooltipSetting] = useState(() => {
    const saved = localStorage.getItem('showTooltipSetting');
    return saved !== null ? JSON.parse(saved) : false;
  });

  const [showItalianSetting, setShowItalianSetting] = useState(() => {
    const saved = localStorage.getItem('showItalianSetting');
    return saved !== null ? JSON.parse(saved) : false;
  });

  // Gamification State
  const [progress, setProgress] = useState(0);
  const [stars, setStars] = useState(0);

  // YouTube Player State
  const [player, setPlayer] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [activeWordIndex, setActiveWordIndex] = useState(-1);
  const allWords = useRef(songData.stanzas.flat());
  const intervalRef = useRef();
  
  // App Version
  const appVersion = packageJson.version;
  // This will generate a new 3-digit number for every build.
  const buildNumber = (new Date().getTime() % 1000).toString().padStart(3, '0');


  useEffect(() => {
    localStorage.setItem('showTooltipSetting', JSON.stringify(showTooltipSetting));
    if (!showTooltipSetting) {
      setShowItalianSetting(false);
    }
  }, [showTooltipSetting]);
  
  useEffect(() => {
    localStorage.setItem('showItalianSetting', JSON.stringify(showItalianSetting));
  }, [showItalianSetting]);

  // Gamification Logic
  useEffect(() => {
    const today = new Date().toDateString();
    const lastVisit = localStorage.getItem('lastVisit');
    let currentStreak = parseInt(localStorage.getItem('streak') || '0');

    if (lastVisit !== today) {
      const lastVisitDate = new Date(lastVisit);
      const todayDate = new Date(today);
      const diffTime = todayDate - lastVisitDate;
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        currentStreak++; // Increment streak
      } else if (diffDays > 1) {
        currentStreak = 1; // Reset streak
      }
      
      localStorage.setItem('lastVisit', today);
      localStorage.setItem('streak', currentStreak.toString());

      if (currentStreak > 0 && currentStreak % 5 === 0) {
        const newStars = currentStreak / 5;
        setStars(newStars);
        localStorage.setItem('stars', newStars.toString());
        // Play celebratory message
        const message = "Bravo, l'unico modo per imparare è farlo ogni giorno. Continua così!";
        const utterance = new SpeechSynthesisUtterance(message);
        utterance.lang = 'it-IT';
        window.speechSynthesis.speak(utterance);
      }
    }
    
    setStars(parseInt(localStorage.getItem('stars') || '0'));
    setProgress(currentStreak % 5);

  }, []);

  useEffect(() => {
    if (isPlaying && player) {
      intervalRef.current = setInterval(() => {
        const time = player.getCurrentTime();
        if (time !== undefined) {
          setCurrentTime(time);
          const wordIndex = allWords.current.findIndex(w => w && w.startTime <= time && w.endTime >= time);
          setActiveWordIndex(wordIndex);
        }
      }, 100);
    } else {
      clearInterval(intervalRef.current);
    }
    return () => clearInterval(intervalRef.current);
  }, [isPlaying, player]);

  const handlePlayerReady = (event) => {
    setPlayer(event.target);
    setDuration(event.target.getDuration());
  };

  const handlePlayerStateChange = (event) => {
    setIsPlaying(event.data === 1); // 1 === PLAYING
  };

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
    const message = "Clicca sulle parole evidenziate per sentirne la pronuncia. Attiva 'Mostra esempio di uso' per vedere un esempio della parola in una frase.";
    const utterance = new SpeechSynthesisUtterance(message);
    utterance.lang = 'it-IT';
    window.speechSynthesis.speak(utterance);
  };

  return (
    <div className="App">
      <YouTubePlayer
        player={player}
        isPlaying={isPlaying}
        setIsPlaying={setIsPlaying}
        currentTime={currentTime}
        setCurrentTime={setCurrentTime}
        duration={duration}
        onPlayerReady={handlePlayerReady}
        onPlayerStateChange={handlePlayerStateChange}
      />
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
            showItalianSetting={showItalianSetting}
            setShowItalianSetting={setShowItalianSetting}
          />
          <ProgressBar progress={progress} stars={stars} />
        </div>
        <LyricsViewer
          songData={songData}
          activeLayer={activeLayer}
          onWordClick={handleWordClick}
          layers={songData.layers}
          showTooltipSetting={showTooltipSetting}
          showItalianSetting={showItalianSetting}
          activeWordIndex={activeWordIndex}
        />
      </main>
      <footer className="App-footer">
        <div>(C) Garage Innovation LLC - USA</div>
        <div className="version-info">{appVersion} (build {buildNumber})</div>
      </footer>
    </div>
  );
}