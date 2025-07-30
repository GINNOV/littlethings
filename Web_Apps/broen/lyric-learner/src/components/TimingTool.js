import React, { useState, useEffect, useRef } from 'react';
import YouTube from 'react-youtube';

const TimingTool = ({ songId }) => {
  const [songData, setSongData] = useState(null);
  const [player, setPlayer] = useState(null);
  const [currentTime, setCurrentTime] = useState(0);
  const [message, setMessage] = useState('');
  const intervalRef = useRef();

  useEffect(() => {
    const fetchSongForTiming = async () => {
      if (!songId) return;
      setSongData(null);
      try {
        const res = await fetch(`/api/song/${songId}`);
        const data = await res.json();
        const sanitizedStanzas = data.stanzas.map(stanza => 
          stanza.map(word => ({
            ...word,
            startTime: Number(word.startTime) || 0,
            endTime: Number(word.endTime) || 0,
          }))
        );
        setSongData({ ...data, stanzas: sanitizedStanzas });
      } catch (error) {
        console.error("Failed to fetch song for timing tool", error);
      }
    };
    fetchSongForTiming();
  }, [songId]);

  useEffect(() => {
    if (player && typeof player.getCurrentTime === 'function') {
      intervalRef.current = setInterval(() => {
        const time = player.getCurrentTime();
        if (time !== undefined) {
          setCurrentTime(time);
        }
      }, 100);
    }
    return () => clearInterval(intervalRef.current);
  }, [player]);

  const updateWordTime = (stanzaIndex, wordIndex, type, value) => {
    const newStanzas = songData.stanzas.map((stanza, sIndex) => {
      if (sIndex !== stanzaIndex) return stanza;
      return stanza.map((word, wIndex) => {
        if (wIndex !== wordIndex) return word;
        return { ...word, [type]: value };
      });
    });
    setSongData(prev => ({ ...prev, stanzas: newStanzas }));
  };

  const handleSetTime = (stanzaIndex, wordIndex, type) => {
    if (!player || typeof player.getPlayerState !== 'function' || typeof player.getCurrentTime !== 'function') {
      setMessage("Player is not ready.");
      return;
    }

    const playerState = player.getPlayerState();
    if (playerState === -1) {
        setMessage("Please play the video at least once before setting time.");
        return;
    }

    const time = player.getCurrentTime();
    if (time === undefined || time === null) return;
    
    const newTime = parseFloat(time.toFixed(2));

    if (!isNaN(newTime)) {
      updateWordTime(stanzaIndex, wordIndex, type, newTime);
      setMessage('');
    } else {
      console.error("Could not get a valid time from the player.");
    }
  };

  const handleTimeInputChange = (stanzaIndex, wordIndex, type, event) => {
    const value = event.target.value;
    // rationale: Allow empty string in the state so the user can clear the input field.
    // The sanitization will happen in handleSaveTimings before sending to the API.
    updateWordTime(stanzaIndex, wordIndex, type, value === '' ? '' : parseFloat(value));
  };

  const handleSaveTimings = async () => {
    setMessage('Saving...');
    try {
      // rationale: This is the primary fix. Before sending the data, we ensure all timing values
      // are valid numbers. An empty string or other falsy value becomes 0.
      // This prevents sending invalid data that the database would reject.
      const sanitizedStanzas = songData.stanzas.map(stanza =>
        stanza.map(word => ({
          ...word,
          startTime: Number(word.startTime) || 0,
          endTime: Number(word.endTime) || 0,
        }))
      );

      const res = await fetch('/api/songs/update-timing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          songId: songId,
          stanzas: sanitizedStanzas // Use the sanitized data
        }),
      });

      if (!res.ok) {
        try {
            const errorData = await res.json();
            throw new Error(errorData.error || `HTTP error! status: ${res.status}`);
        } catch (jsonError) {
            throw new Error(`HTTP error! status: ${res.status}`);
        }
      }
      const data = await res.json();
      setMessage(data.message || 'Timings saved successfully!');
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    }
  };

  if (!songData) {
    return <p>Loading song data...</p>;
  }

  return (
    <div className="timing-tool">
      <h3>{songData.title}</h3>
      <div className="player-and-lyrics">
        <div className="timing-player">
          <YouTube
            videoId={songData.youtubeVideoId}
            opts={{ height: '200', width: '100%', playerVars: { controls: 1 } }}
            onReady={(e) => setPlayer(e.target)}
          />
          <p>Current Time: <strong>{currentTime.toFixed(2)}s</strong></p>
          <button onClick={handleSaveTimings} className="save-button">Save All Timings</button>
          {message && <p className="message">{message}</p>}
        </div>
        <div className="timing-lyrics">
          {songData.stanzas.map((stanza, stanzaIndex) =>
            stanza.map((word, wordIndex) => {
              const key = `${stanzaIndex}-${wordIndex}`;
              return (
                <div key={key} className="word-timing-row">
                  <span className="word-text">{word.text}</span>
                  <div className="time-inputs">
                    <input 
                      type="number" 
                      step="0.1" 
                      value={word.startTime} 
                      onChange={(e) => handleTimeInputChange(stanzaIndex, wordIndex, 'startTime', e)}
                    />
                    <input 
                      type="number" 
                      step="0.1" 
                      value={word.endTime} 
                      onChange={(e) => handleTimeInputChange(stanzaIndex, wordIndex, 'endTime', e)}
                    />
                  </div>
                  <div className="time-buttons">
                    <button onClick={() => handleSetTime(stanzaIndex, wordIndex, 'startTime')}>Set Start</button>
                    <button onClick={() => handleSetTime(stanzaIndex, wordIndex, 'endTime')}>Set End</button>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
};

export default TimingTool;
