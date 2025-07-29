import React, { useState, useEffect, useRef } from 'react';
import dynamic from 'next/dynamic';
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import Settings from './components/Settings';
import ProgressBar from './components/ProgressBar';
import packageJson from '../package.json';

// --- NEW: Dynamically import the YouTubePlayer with SSR disabled ---
const YouTubePlayer = dynamic(() => import('./components/YouTubePlayer'), {
  ssr: false, 
});

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

  const appVersion = packageJson.version;
  const buildNumber = (new Date().getTime() % 1000).toString().padStart(3, '0');

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  useEffect(() => {
    async function fetchSongData() {
      try {
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

  useEffect(() => {
    // Gamification Logic
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
    setIsPlaying(event.data === 1);
  };

  const handlePlayerError = (event) => {
    console.error("YouTube Player Error:", event.data);
    console.error("Error codes:", {
      2: "Invalid video ID",
      5: "HTML5 player error",
      100: "Video not found or private",
      101: "Embedding not allowed by video owner",
      150: "Embedding not allowed by video owner (this is often the same as 101)"
    });
  };

  const handleWordClick = (wordText) => {
    // word click logic
  };

  const handleInstructionsClick = () => {
    // instructions logic
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
        <p>Impariamo l&apos;inglese interattivamente con la musica.</p>
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
        <div className="version-info">
          v{appVersion} (build {buildNumber})
        </div>
      </footer>

      {/* The dynamic import handles client-side rendering automatically */}
      <YouTubePlayer
        player={player}
        isPlaying={isPlaying}
        setIsPlaying={setIsPlaying}
        currentTime={currentTime}
        setCurrentTime={setCurrentTime}
        duration={duration}
        onPlayerReady={handlePlayerReady}
        onPlayerStateChange={handlePlayerStateChange}
        onPlayerError={handlePlayerError}
      />
    </div>
  );
}
