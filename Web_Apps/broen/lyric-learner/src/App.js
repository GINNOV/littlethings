import React, { useState, useEffect, useRef } from 'react';
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import Settings from './components/Settings';
import YouTubePlayer from './components/YoutubePlayer';
import ProgressBar from './components/ProgressBar';

export default function App() {
  const [songData, setSongData] = useState(null);
  const [error, setError] = useState(null);
  const allWords = useRef([]);
  const [activeLayer, setActiveLayer] = useState(1);
  const [settings] = useState({ slowSpeed: 0.5 });
  const [lastWordClicked, setLastWordClicked] = useState({ word: null, timer: null });
  const [progress, setProgress] = useState(0);
  const [stars, setStars] = useState(0);
  const [player, setPlayer] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [activeWordIndex, setActiveWordIndex] = useState(-1);
  const intervalRef = useRef();
  const [isScrolled, setIsScrolled] = useState(false);

  // Effect to handle scroll events for the shrinking header
  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  // Effect to fetch song data from the API
  useEffect(() => {
    async function fetchSongData() {
      try {
        // Fetching song with ID=1 by default.
        const response = await fetch('/api/song/1');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        setSongData(data);
        allWords.current = data.stanzas.flat();
      } catch (e) {
        console.error("Failed to fetch song data:", e);
        setError("Could not load the song. Please try again later.");
      }
    }
    fetchSongData();
  }, []);

  // Effect for gamification logic
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
        currentStreak++;
      } else if (diffDays > 1) {
        currentStreak = 1;
      }
      localStorage.setItem('lastVisit', today);
      localStorage.setItem('streak', currentStreak.toString());

      if (currentStreak > 0 && currentStreak % 5 === 0) {
        const newStars = currentStreak / 5;
        setStars(newStars);
        localStorage.setItem('stars', newStars.toString());
        const message = "Bravo, l'unico modo per imparare è farlo ogni giorno. Continua così!";
        const utterance = new SpeechSynthesisUtterance(message);
        utterance.lang = 'it-IT';
        window.speechSynthesis.speak(utterance);
      }
    }
    setStars(parseInt(localStorage.getItem('stars') || '0'));
    setProgress(currentStreak % 5);
  }, []);

  // Effect to track YouTube player time
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
    setIsPlaying(event.data === 1);
  };

  const handleWordClick = (wordText) => {
    if (window.navigator && window.navigator.vibrate) {
      window.navigator.vibrate(50);
    }
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

  if (error) {
    return <div className="App"><header className="App-header"><h1>Error</h1><p>{error}</p></header></div>;
  }
  if (!songData) {
    return <div className="App"><header className="App-header"><h1>Lyric Learner</h1><p>Loading song...</p></header></div>;
  }

  return (
    <div className="App">
      <header className={`App-header ${isScrolled ? 'scrolled' : ''}`}>
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
          <Settings />
          <ProgressBar progress={progress} stars={stars} />
        </div>
        <LyricsViewer
          songData={songData}
          activeLayer={activeLayer}
          onWordClick={handleWordClick}
          layers={songData.layers}
          activeWordIndex={activeWordIndex}
        />
      </main>

      <footer className="App-footer">
        <div>(C) Garage Innovation LLC - USA</div>
        {/* Using a simple version string instead of importing package.json */}
        <div className="version-info">v0.1.0 (build 1)</div>
      </footer>

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
    </div>
  );
}
