import React, { useState, useEffect } from 'react';
import YouTube from 'react-youtube';

const YouTubePlayer = ({ player, isPlaying, setIsPlaying, currentTime, setCurrentTime, duration, onPlayerReady, onPlayerStateChange }) => {
  // --- FIX: State to ensure this component only renders on the client ---
  const [isClient, setIsClient] = useState(false);

  // This effect runs once after the component mounts, setting isClient to true.
  useEffect(() => {
    setIsClient(true);
  }, []);

  const videoId = "Q_c4gZkI-FQ"; // A karaoke version that allows embedding

  const opts = {
    height: '0',
    width: '0',
    playerVars: {
      autoplay: 0,
      controls: 0,
      // This will now be safely set only on the client
      origin: typeof window !== 'undefined' ? window.location.origin : '',
    },
  };

  const handlePlayPause = () => {
    if (!player) return;
    if (isPlaying) {
      player.pauseVideo();
    } else {
      player.playVideo();
    }
  };

  const handleScrubberChange = (e) => {
    if (!player) return;
    const newTime = parseFloat(e.target.value);
    setCurrentTime(newTime);
    player.seekTo(newTime, true);
  };

  const formatTime = (time) => {
    if (isNaN(time) || time === 0) return "0:00";
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60).toString().padStart(2, '0');
    return `${minutes}:${seconds}`;
  };

  return (
    <div className="youtube-player-container">
      <button onClick={handlePlayPause} className="play-pause-button">
        {isPlaying ? '❚❚' : '►'}
      </button>
      <span className="time-display">{formatTime(currentTime)}</span>
      <input
        type="range"
        className="scrubber"
        min="0"
        max={duration || 0}
        value={currentTime || 0}
        onChange={handleScrubberChange}
      />
      <span className="time-display">{formatTime(duration)}</span>
      <div className="youtube-embed">
        {/* --- FIX: Conditionally render the YouTube component only on the client --- */}
        {isClient && (
          <YouTube
            key={videoId}
            videoId={videoId}
            opts={opts}
            onReady={onPlayerReady}
            onStateChange={onPlayerStateChange}
            onError={(e) => console.error("YouTube Player Error:", e.data)}
          />
        )}
      </div>
    </div>
  );
};

export default YouTubePlayer;
