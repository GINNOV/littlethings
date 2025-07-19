// FILE: src/components/ProgressBar.js
// This component displays the user's learning progress.

import React from 'react';

const ProgressBar = ({ progress, stars }) => {
  const progressPercentage = (progress / 5) * 100;

  return (
    <div className="progress-container">
      <div className="stars-container">
        {Array.from({ length: stars }).map((_, index) => (
          <span key={index} className="star">⭐️</span>
        ))}
      </div>
      <div className="progress-bar-background">
        <div 
          className="progress-bar-foreground" 
          style={{ width: `${progressPercentage}%` }}
        ></div>
      </div>
    </div>
  );
};

export default ProgressBar;