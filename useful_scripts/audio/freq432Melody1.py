import numpy as np
import sounddevice as sd

# Define parameters
sample_rate = 44100  # Hz
duration = 0.5  # seconds per note

# Notes tuned to 432 Hz reference
notes = {
    "C4": 256, "D4": 288, "E4": 324, "G4": 384, "A4": 432,
    "B4": 486, "C5": 512  # Higher octave C
}

# Define a melody sequence
melody = ["C4", "E4", "G4", "A4", "G4", "E4", "C4", "A4"]

# Function to generate a sine wave for a given frequency
def generate_wave(frequency, duration, sample_rate):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return 0.5 * np.sin(2 * np.pi * frequency * t)

# Play melody
for note in melody:
    waveform = generate_wave(notes[note], duration, sample_rate)
    sd.play(waveform, samplerate=sample_rate)
    sd.wait()