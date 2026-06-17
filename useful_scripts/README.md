# Useful Scripts

Small, quick scripts used by blog posts, media workflows, and file cleanup experiments. Review a script before running it against important files.

## Scripts

| Script | Purpose | Notes |
| --- | --- | --- |
| `FindMyRPi.sh` | Finds a Raspberry Pi on the local network when you do not know its IP address. | Requires local network access. |
| `spoofOutput.sh` | Reuses the output of a previous command and filters it before running another command. | Read before use; behavior depends on the command pipeline. |
| `cropper.sh` | Crops a video with `ffmpeg`. | Details: `cropper.md`. |
| `get_frame.sh` | Extracts a specific frame from a video. | Details: `get_frame.md`. |
| `organize_files.sh` | Organizes large dumps of ROMs, PDFs, or similar files into browseable folders. | Details: `organize_files.md`. |
| `wavtoMP4.sh` | Converts WAV audio to MP4 and can be paired with a macOS Shortcut. | Requires media conversion tools. |
| `freqChange.sh` | Converts source audio to 44.1 kHz PCM. | Requires media conversion tools. |
| `mp3toWav.sh` | Converts MP3 audio to WAV. | Requires media conversion tools. |

```bash
brew install ffmpeg
```
