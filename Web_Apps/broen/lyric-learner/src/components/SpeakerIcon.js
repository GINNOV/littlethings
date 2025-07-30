import React from 'react';

// rationale: Creating a dedicated component for the speaker icon makes it reusable
// and keeps the SVG markup out of the main WordComponent, improving readability.
const SpeakerIcon = ({ onClick, className }) => {
  const handleIconClick = (e) => {
    e.stopPropagation(); // Prevent the word's own click event from firing
    onClick();
  };

  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="currentColor"
      className={className}
      onClick={handleIconClick}
      role="button"
      aria-label="Pronounce example"
      tabIndex="0"
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          handleIconClick(e);
        }
      }}
    >
      <path d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25zM10.26 16.624a.75.75 0 01-.827-.03L6.12 14.25H4.5a.75.75 0 01-.75-.75v-3a.75.75 0 01.75-.75h1.62l3.313-2.344a.75.75 0 01.826-.03c.26.123.424.39.424.68v7.358c0 .29-.164.557-.424.68zM19.5 12a.75.75 0 01-.75.75h-3a.75.75 0 010-1.5h3a.75.75 0 01.75.75z" />
      <path d="M16.5 12a2.25 2.25 0 10-4.5 0 2.25 2.25 0 004.5 0z" fillOpacity="0.5" />
    </svg>
  );
};

export default SpeakerIcon;
