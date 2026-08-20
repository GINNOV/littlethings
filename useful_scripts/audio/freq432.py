import numpy as np
import sounddevice as sd

# Define parameters
frequency = 432  # Hz
duration = 5  # seconds
sample_rate = 44100  # Hz (CD quality)

# Generate a sine wave
t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
waveform = 0.5 * np.sin(2 * np.pi * frequency * t)  # 0.5 amplitude to prevent clipping

# Play the sound
sd.play(waveform, samplerate=sample_rate)
sd.wait()  # Wait until sound finishes playing