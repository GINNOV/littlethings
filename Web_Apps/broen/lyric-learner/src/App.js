import React, { useState, useEffect, useRef } from 'react';
import dynamic from 'next/dynamic';
import LyricsViewer from './components/LyricsViewer';
import LayerSelector from './components/LayerSelector';
import Settings from './components/Settings';
import ProgressBar from './components/ProgressBar';
import packageJson from '../package.json';
import SongSelector from './components/SongSelector';

const YouTubePlayer = dynamic(() => import('./components/YouTubePlayer'), {
  ssr: false,
});

export default function App() {
  const [voices, setVoices] = useState([]);
  const [songList, setSongList] = useState([]);
  const [selectedSongId, setSelectedSongId] = useState(1);
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
    if (typeof window !== 'undefined' && window.speechSynthesis) {
      const loadVoices = () => {
        setVoices(window.speechSynthesis.getVoices());
      };
      loadVoices();
      window.speechSynthesis.onvoiceschanged = loadVoices;
    }

    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (window.speechSynthesis) {
        window.speechSynthesis.onvoiceschanged = null;
      }
    };
  }, []);

  useEffect(() => {
    async function fetchSongList() {
      try {
        const response = await fetch('/api/songs');
        if (!response.ok) {
          throw new Error('Failed to fetch song list');
        }
        const data = await response.json();
        setSongList(data);
      } catch (e) {
        console.error("Failed to fetch song list:", e);
      }
    }
    fetchSongList();
  }, []);

  useEffect(() => {
    if (!selectedSongId) return;

    async function fetchSongData() {
      setSongData(null);
      setError(null);
      try {
        const response = await fetch(`/api/song/${selectedSongId}`);
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
  }, [selectedSongId]);

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
  };

  const handleWordClick = (wordText) => {
    if (window.navigator && window.navigator.vibrate) {
      window.navigator.vibrate(50);
    }
    if (!window.speechSynthesis) return;

    window.speechSynthesis.cancel();
    clearTimeout(lastWordClicked.timer);

    const utterance = new SpeechSynthesisUtterance(wordText);
    const englishVoice = voices.find(voice => voice.lang.startsWith('en-'));
    if (englishVoice) {
      utterance.voice = englishVoice;
    }

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

  // rationale: New handler for the Tutor feature TTS.
  const handleExampleSpeak = (exampleText) => {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel(); // Stop any other speech
    const utterance = new SpeechSynthesisUtterance(exampleText);
    const englishVoice = voices.find(voice => voice.lang.startsWith('en-'));
    if (englishVoice) {
      utterance.voice = englishVoice;
    }
    utterance.rate = 1.0; // Speak the example at a normal rate
    window.speechSynthesis.speak(utterance);
  };

  const handleInstructionsClick = () => {
    if (!window.speechSynthesis) return;
    
    const message = "Clicca sulle parole evidenziate per sentirne la pronuncia. Attiva 'Mostra esempio di uso' per vedere un esempio della parola in una frase.";
    const utterance = new SpeechSynthesisUtterance(message);
    
    const italianVoice = voices.find(voice => voice.lang.startsWith('it-'));
    if (italianVoice) {
      utterance.voice = italianVoice;
    }
    utterance.lang = 'it-IT';
    
    window.speechSynthesis.speak(utterance);
  };
  
  const handleSongChange = (songId) => {
    setSelectedSongId(songId);
    if (player && isPlaying) {
      player.stopVideo();
    }
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
          <SongSelector 
            songs={songList}
            selectedSongId={selectedSongId}
            onSongChange={handleSongChange}
          />
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
          onExampleSpeak={handleExampleSpeak} // Pass the new handler down
        />
      </main>

      <footer className="App-footer">
        <div>(C) Garage Innovation LLC - USA</div>
        <div className="version-info">
          v{appVersion} (build {buildNumber})
        </div>
      </footer>

      <YouTubePlayer
        videoId={songData.youtubeVideoId}
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
