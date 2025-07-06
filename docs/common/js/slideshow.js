document.addEventListener('DOMContentLoaded', () => {
  const slideshowContainer = document.querySelector('.slideshow-container');
  
  if (slideshowContainer && slideshowContainer.dataset.source) {
    initSlideshow(slideshowContainer.dataset.source);
  }
});

function initSlideshow(folderPath) {
  let slides = [];
  let currentSlideIndex = 0;
  let slideInterval;

  const slideImage = document.getElementById('slideImage');
  const slideDescription = document.getElementById('slideDescription');
  const prevButton = document.getElementById('prevBtn');
  const nextButton = document.getElementById('nextBtn');
  const playPauseBtn = document.getElementById('playPauseBtn');

  if (!slideImage || !slideDescription || !prevButton || !nextButton || !playPauseBtn) {
    console.error('Slideshow is missing required elements. Check for IDs: slideImage, slideDescription, prevBtn, nextBtn, playPauseBtn.');
    return;
  }
  
  fetch(`${folderPath}/slides.json`)
    .then(response => {
      if (!response.ok) throw new Error(`Failed to load slideshow data from ${folderPath}/slides.json`);
      return response.json();
    })
    .then(data => {
      slides = data;
      if (slides && slides.length > 0) {
        showSlide(0);
        playSlideshow();
        
        // Clone and replace buttons to remove any old event listeners
        const cleanPrev = prevButton.cloneNode(true);
        const cleanNext = nextButton.cloneNode(true);
        const cleanPlayPause = playPauseBtn.cloneNode(true);
        
        prevButton.parentNode.replaceChild(cleanPrev, prevButton);
        nextButton.parentNode.replaceChild(cleanNext, nextButton);
        playPauseBtn.parentNode.replaceChild(cleanPlayPause, playPauseBtn);

        // Add fresh event listeners
        cleanPrev.addEventListener('click', handlePrev);
        cleanNext.addEventListener('click', handleNext);
        cleanPlayPause.addEventListener('click', handlePlayPause);

      } else {
        displayError('No slides found in the manifest file.');
      }
    })
    .catch(error => {
      console.error('Slideshow initialization failed:', error);
      displayError(error.message);
    });

  function displayError(message) {
    slideDescription.textContent = message;
    slideImage.src = 'https://placehold.co/800x450/0F172A/FF8800?text=Error';
    slideImage.alt = message;
  }

  function showSlide(index) {
    if (index >= slides.length) currentSlideIndex = 0;
    else if (index < 0) currentSlideIndex = slides.length - 1;
    else currentSlideIndex = index;

    const slide = slides[currentSlideIndex];
    slideImage.src = `${folderPath}/${slide.image}`;
    slideImage.alt = slide.description;
    slideImage.onerror = function() {
      this.src = 'https://placehold.co/800x450/0F172A/FF8800?text=Image+Not+Found';
      slideDescription.textContent = `Error: Could not load image at path: ${this.src}`;
    };
    slideDescription.textContent = slide.description;
  }

  function nextSlide() { showSlide(currentSlideIndex + 1); }
  function prevSlide() { showSlide(currentSlideIndex - 1); }

  function playSlideshow() {
    const freshPlayPauseBtn = document.getElementById('playPauseBtn');
    clearInterval(slideInterval);
    slideInterval = setInterval(nextSlide, 5000);
    freshPlayPauseBtn.innerHTML = '<i class="fas fa-pause"></i><span>Pause</span>';
  }

  function pauseSlideshow() {
    const freshPlayPauseBtn = document.getElementById('playPauseBtn');
    clearInterval(slideInterval);
    slideInterval = null;
    freshPlayPauseBtn.innerHTML = '<i class="fas fa-play"></i><span>Play</span>';
  }

  function handleNext() {
    nextSlide();
    if (slideInterval) playSlideshow();
  }

  function handlePrev() {
    prevSlide();
    if (slideInterval) playSlideshow();
  }
  
  function handlePlayPause() {
    if (slideInterval) {
      pauseSlideshow();
    } else {
      playSlideshow();
    }
  }
}