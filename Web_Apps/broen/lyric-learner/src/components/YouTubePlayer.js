// FILE: src/components/YouTubePlayer.js
// This component renders a fixed YouTube player bar with custom controls.

import React from 'react';
import YouTube from 'react-youtube';

const YouTubePlayer = ({ player, isPlaying, setIsPlaying, currentTime, setCurrentTime, duration, onPlayerReady, onPlayerStateChange }) => {
  const videoId = "9hG_h21A3eM"; // Official Audio for Mrs. Robinson

  const opts = {
    height: '0',
    width: '0',
    playerVars: {
      autoplay: 0,
      controls: 0,
    },
    // This is the crucial fix: It now dynamically uses the correct origin
    // for both localhost and your deployed Vercel site.
    origin: window.location.origin
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
        <YouTube key={videoId} videoId={videoId} opts={opts} onReady={onPlayerReady} onStateChange={onPlayerStateChange} />
      </div>
    </div>
  );
};

export default YouTubePlayer;