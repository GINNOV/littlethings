import librosa
import numpy as np
from moviepy.editor import *

# Step 1: Load audio and background image
audio_path = 'audio.mp3'  # Replace with your audio file path
bg_image_path = 'background.jpg'  # Replace with your background image path
fps = 24  # Frames per second

# Load audio and calculate duration
audio, sr = librosa.load(audio_path)
duration = len(audio) / sr

# Load and resize background image to 1080x1080
bg_image = ImageClip(bg_image_path).resize((1080, 1080)).set_duration(duration)

# Step 2: Generate long waveform image for Siri-like animation
def generate_waveform_image(audio, width=10000, height=200):
    max_amp = np.max(np.abs(audio))
    image = np.zeros((height, width, 3), dtype=np.uint8)
    for x in range(width):
        start = int(x * len(audio) / width)
        end = int((x + 1) * len(audio) / width)
        segment = audio[start:end]
        if len(segment) > 0:
            min_val = np.min(segment)
            max_val = np.max(segment)
            y_min = int(((min_val / max_amp) + 1) * (height / 2))
            y_max = int(((max_val / max_amp) + 1) * (height / 2))
            image[y_min:y_max, x] = [0, 0, 255]  # Blue waveform
    return image

long_waveform = generate_waveform_image(audio)
long_waveform_width = long_waveform.shape[1]

# Step 3: Compute RMS for VU meter
hop_length = int(sr / fps)
rms = librosa.feature.rms(y=audio, frame_length=2048, hop_length=hop_length)
max_rms = np.max(rms)

# Step 4: Define Siri-like waveform frame function
def make_siri_frame(t):
    center_pixel = (t / duration) * long_waveform_width
    start_x = int(center_pixel - 540)
    end_x = int(center_pixel + 540)
    if start_x < 0:
        start_x = 0
    if end_x > long_waveform_width:
        end_x = long_waveform_width
    crop = long_waveform[:, start_x:end_x]
    if crop.shape[1] < 1080:
        pad_width = 1080 - crop.shape[1]
        left_pad = pad_width // 2
        right_pad = pad_width - left_pad
        crop = np.pad(crop, ((0, 0), (left_pad, right_pad), (0, 0)), mode='constant')
    return crop

# Step 5: Define VU meter frame function
def make_vu_frame(t):
    idx = min(int(t * fps), rms.shape[1] - 1)
    rms_value = rms[0, idx]
    bar_width = int((rms_value / max_rms) * 540)  # Max width: 540 pixels
    bar = ColorClip(size=(bar_width, 50), color=(255, 0, 0))  # Red bar
    return bar.get_frame(0)

# Step 6: Define progress bar frame function
def make_progress_frame(t):
    remaining = (duration - t) / duration
    bar_width = int(200 * remaining)  # Max width: 200 pixels
    bar = ColorClip(size=(bar_width, 20), color=(0, 255, 0))  # Green bar
    return bar.get_frame(0)

# Step 7: Create video clips
siri_clip = VideoClip(make_siri_frame, duration=duration).set_position(('center', 440))
vu_clip = VideoClip(make_vu_frame, duration=duration).set_position(('center', 1000))
progress_clip = VideoClip(make_progress_frame, duration=duration).set_position((880, 10))

# Step 8: Composite all clips
final_clip = CompositeVideoClip([bg_image, siri_clip, vu_clip, progress_clip])

# Step 9: Set audio
final_clip = final_clip.set_audio(AudioFileClip(audio_path))

# Step 10: Render video
output_path = 'output.mp4'  # Replace with desired output path
final_clip.write_videofile(output_path, fps=fps)