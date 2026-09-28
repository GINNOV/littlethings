#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "🔴 Error: Invalid number of arguments."
    echo "Usage: $0 input_file output_file crop_width crop_height x_offset y_offset"
    echo
    echo "Example: $0 input.mp4 output.mp4 640 360 100 100"
    echo
    echo "Parameters:"
    echo "  input_file   - The video file you want to crop"
    echo "  output_file  - The name of the output cropped video file"
    echo "  crop_width   - The width of the cropping area"
    echo "  crop_height  - The height of the cropping area"
    echo "  x_offset     - The x-axis offset to start cropping from (pixels)"
    echo "  y_offset     - The y-axis offset to start cropping from (pixels)"
    exit 1
fi

# Parameters
input_file=$1
output_file=$2
crop_width=$3
crop_height=$4
x_offset=$5
y_offset=$6

# Use ffmpeg to crop the video
ffmpeg -i "$input_file" -vf "crop=$crop_width:$crop_height:$x_offset:$y_offset" -c:a copy "$output_file"

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "🟢 Video cropped successfully and saved to $output_file"
else
    echo "🔴 Error: Failed to crop the video."
fi