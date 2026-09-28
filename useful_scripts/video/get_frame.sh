#!/bin/zsh

# Check if correct number of arguments are provided
if [[ $# -ne 2 ]]; then
    osascript -e 'display notification "Usage: $0 <video_file> <frame_number>" with title "Error: Incorrect Usage"'
    exit 1
fi

video_file="$1"
frame_number="$2"
ffmpeg_path="/opt/homebrew/bin/ffmpeg"
output_file="${video_file%.*}_frame_${frame_number}.png"

# Function to display notification
show_notification() {
    osascript -e "display notification \"$1\" with title \"$2\""
}

# Check if input file exists
if [[ ! -f "$video_file" ]]; then
    show_notification "Input file does not exist: $video_file" "Error: Video Frame Extraction"
    exit 1
fi

# Check if ffmpeg exists
if [[ ! -f "$ffmpeg_path" ]]; then
    show_notification "FFmpeg not found at: $ffmpeg_path" "Error: Video Frame Extraction"
    exit 1
fi

# Extract frame
"$ffmpeg_path" -i "$video_file" -vf "select='eq(n,$frame_number)'" -vframes 1 "$output_file" 2>&1

# Check if extraction was successful
if [[ $? -eq 0 && -f "$output_file" ]]; then
    message="Success!\nSource: $video_file\nFrame: $frame_number\nOutput: $output_file"
    show_notification "$message" "Video Frame Extraction"
    echo "$output_file"
else
    error_message="Failed to extract frame $frame_number from $video_file"
    show_notification "$error_message" "Error: Video Frame Extraction"
    echo "$error_message" >&2
    exit 1
fi