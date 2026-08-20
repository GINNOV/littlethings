#!/bin/bash

# Check if input parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 inputfile.mp3"
  exit 1
fi

# Input and output files
input_file="$1"
output_file="${input_file%.*}.wav"

# Function for macOS desktop notifications
show_notification() {
  local message="$1"
  local title="$2"
  osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
}

# Convert MP3 to WAV using ffmpeg
/opt/homebrew/bin/ffmpeg -i "$input_file" "$output_file"
status=$?

# Check if conversion was successful
if [[ $status -eq 0 && -f "$output_file" ]]; then
    message="Conversion successful!\nSource: $input_file\nOutput: $output_file"
    show_notification "$message" "Audio Converted"
    echo "Conversion successful: $output_file"
else
    error_message="Failed to convert audio file: $input_file"
    show_notification "$error_message" "Error: Audio Conversion"
    echo "$error_message" >&2
    exit 1
fi