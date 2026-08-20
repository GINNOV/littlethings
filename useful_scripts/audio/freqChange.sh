#!/bin/zsh

# Get the current user's username
username=$(whoami)

# Construct the path to the Downloads folder log file
download_path="/Users/$username/Downloads/log.txt"

# Log the input
echo "Input file: $1" >> "$download_path"

# Converts a wave file from the source to 44100 Hz 24-bit PCM

# Check if a file was passed as an argument
if [ $# -eq 0 ]; then
  echo "No file provided. Please provide a WAV file to convert." >> "$download_path"
  exit 1
fi

# Get the input file from the command line argument
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file" >> "$download_path"
  exit 1
fi

# Find ffmpeg binary dynamically or fallback to PATH
FFMPEG_BIN=$(command -v ffmpeg || echo "/opt/homebrew/bin/ffmpeg")

# Use ffmpeg to convert the file to 44.1 kHz and 24-bit
"$FFMPEG_BIN" -i "$input_file" -ar 44100 -sample_fmt s32 -acodec pcm_s24le "$output_file"

echo "Conversion complete: $output_file" >> "$download_path"