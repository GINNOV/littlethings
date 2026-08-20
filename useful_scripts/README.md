# Useful Scripts

A collection of utility scripts for network discovery, file organization, command output spoofing, audio processing, and video manipulation.

## Table of Contents

- [General Requirements & Prerequisites](#general-requirements--prerequisites)
- [Network & Shell Utilities](#network--shell-utilities)
  - [`FindMyRPi.sh`](#findmyrpish)
  - [`spoofOutput.sh`](#spoofoutputsh)
  - [`generate_vhs_for_shell.tape`](#generate_vhs_for_shelltape)
- [File Organization](#file-organization)
  - [`organize_files.sh`](#organize_filessh)
- [Video Utilities](#video-utilities)
  - [`cropper.sh`](#croppersh)
  - [`get_frame.sh`](#get_framesh)
- [Audio Utilities](#audio-utilities)
  - [`mp3toWav.sh`](#mp3towavsh)
  - [`audio/freqChange.sh`](#audiofreqchangesh)
  - [`audio/wavtoMP4.sh`](#audiowavtomp4sh)
  - [`audio/freq432.py`](#audiofreq432py)
  - [`audio/freq432Melody1.py`](#audiofreq432melody1py)
- [Safety Notes](#safety-notes)

---

## General Requirements & Prerequisites

Most video/audio scripts rely on `ffmpeg`. On macOS, you can install it using Homebrew:

```bash
brew install ffmpeg
```

Some scripts rely on additional tools such as `nmap` or `parallel`:

```bash
brew install nmap parallel
```

---

## Network & Shell Utilities

### `FindMyRPi.sh`

Scans your local subnet (/24) or IPv6 network to discover Raspberry Pi devices when the IP address is unknown.

- **Requirements / Dependencies**:
  - `nmap` (installed via package manager or from [nmap.org](https://nmap.org))
  - `ifconfig`, `awk`, `grep`
  - `sudo` privileges for running `nmap`
- **Usage**:
  ```bash
  # IPv4 Scan (default)
  ./FindMyRPi.sh

  # IPv6 Scan
  ./FindMyRPi.sh -6
  ```
- **Configuration**:
  - Edit line 16 to set your active network interface (default: `i="en0"`).

---

### `spoofOutput.sh`

Demonstrates capturing output from a command (`ls .`), searching for specific strings via `grep`, and conditionally executing shell commands based on match results.

- **Requirements / Dependencies**:
  - Bash (`/bin/bash`)
  - Standard Unix commands (`grep`, `ls`)
- **Usage**:
  ```bash
  ./spoofOutput.sh
  ```

---

### `generate_vhs_for_shell.tape`

Configuration script for [VHS](https://github.com/charmbracelet/vhs) by Charm to render terminal GIFs/videos of shell commands.

- **Requirements / Dependencies**:
  - `vhs` (`brew install vhs`)
  - `ffmpeg` & `ttyd` (installed automatically with VHS)
- **Usage**:
  ```bash
  vhs generate_vhs_for_shell.tape
  ```

---

## File Organization

### `organize_files.sh`

Organizes files in a target directory into alphabetical subfolders (`A/` through `Z/`) and a `non_alphabetic/` subfolder for files starting with numbers or symbols.

- **Requirements / Dependencies**:
  - Zsh shell (`/bin/zsh`)
  - `rsync` (used during `--organize` mode)
  - `parallel` (GNU Parallel, required if passing `--parallel N`)
- **Usage**:
  ```bash
  ./organize_files.sh [--organize] [--root /path/to/directory] [--parallel N]
  ```
- **Options**:
  - `--organize`: Executes the file move (default mode is preview-only).
  - `--root DIR`: Target directory (default: `/Volumes/ME/Amiga/BS1/`).
  - `--parallel N`: Uses `N` parallel jobs.
  - `--help`: Displays help message.
- **Examples**:
  ```bash
  # Preview file organization (dry-run)
  ./organize_files.sh --root /path/to/my/files

  # Organize files in-place
  ./organize_files.sh --organize --root /path/to/my/files

  # Organize using 4 parallel jobs
  ./organize_files.sh --organize --root /path/to/my/files --parallel 4
  ```

---

## Video Utilities

### `cropper.sh`

Crops a video file to specified width, height, and offset coordinates using `ffmpeg` while retaining the original audio stream.

- **Requirements / Dependencies**:
  - `ffmpeg`
- **Usage**:
  ```bash
  ./cropper.sh input_file output_file crop_width crop_height x_offset y_offset
  ```
- **Example**:
  ```bash
  ./cropper.sh input.mp4 output.mp4 640 360 100 50
  ```
  *(Crops a 640x360 region starting 100px from left and 50px from top).*

---

### `get_frame.sh`

Extracts a specific frame number from a video file using FFmpeg and sends macOS desktop notifications upon completion.

- **Requirements / Dependencies**:
  - macOS
  - Zsh shell (`#!/bin/zsh`)
  - FFmpeg (expected path: `/opt/homebrew/bin/ffmpeg`)
  - AppleScript (built into macOS for desktop notifications)
- **Usage**:
  ```bash
  ./get_frame.sh <video_file> <frame_number>
  ```
- **Example**:
  ```bash
  ./get_frame.sh sample.mp4 150
  ```
- **Output**: Saves `<video_file>_frame_<frame_number>.png` in the source directory.

---

## Audio Utilities

### `mp3toWav.sh`

Converts an MP3 audio file to WAV format using FFmpeg and triggers a macOS desktop notification.

- **Requirements / Dependencies**:
  - macOS
  - Bash (`/bin/bash`)
  - FFmpeg (expected path: `/opt/homebrew/bin/ffmpeg`)
- **Usage**:
  ```bash
  ./mp3toWav.sh inputfile.mp3
  ```
- **Output**: Generates `inputfile.wav` in the same directory as the source.

---

### `audio/freqChange.sh`

Converts an audio file into a 44.1 kHz, 24-bit PCM WAV file and logs input/output actions to `~/Downloads/log.txt`.

- **Requirements / Dependencies**:
  - Zsh shell (`/bin/zsh`)
  - FFmpeg (expected path: `/opt/homebrew/bin/ffmpeg`)
- **Usage**:
  ```bash
  ./audio/freqChange.sh input_file.wav
  ```
- **Output**: Generates `input_file_44k_24b.wav`.

---

### `audio/wavtoMP4.sh`

Converts a WAV audio file into an audio-only MP4 file using AAC encoding and triggers a macOS text-to-speech audio status notification (`say`).

- **Requirements / Dependencies**:
  - macOS (`say` command for TTS notification)
  - Bash (`/bin/bash`)
  - FFmpeg (expected path: `/opt/homebrew/bin/ffmpeg`)
- **Usage**:
  ```bash
  ./audio/wavtoMP4.sh inputfile.wav
  ```
- **Output**: Generates `inputfile.mp4`.

---

### `audio/freq432.py`

Generates and plays a 5-second sine wave at 432 Hz reference frequency.

- **Requirements / Dependencies**:
  - Python 3
  - Python packages: `numpy`, `sounddevice` (`pip install numpy sounddevice`)
  - Audio output device / PortAudio driver installed
- **Usage**:
  ```bash
  python3 audio/freq432.py
  ```

---

### `audio/freq432Melody1.py`

Generates and plays an 8-note melody tuned to a 432 Hz reference tuning scale (C4 through C5).

- **Requirements / Dependencies**:
  - Python 3
  - Python packages: `numpy`, `sounddevice` (`pip install numpy sounddevice`)
  - Audio output device / PortAudio driver installed
- **Usage**:
  ```bash
  python3 audio/freq432Melody1.py
  ```

---

## Safety Notes

1. Always test file manipulation scripts (such as `organize_files.sh`) on copy directories or in dry-run mode before targeting important files.
2. Quote file paths when working with filenames that contain spaces.
3. Ensure executable permissions are granted on scripts before execution: `chmod +x script_name.sh`.
