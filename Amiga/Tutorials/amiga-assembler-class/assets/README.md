# Course assets

This folder collects the visual and binary material used by the book and the course.

- `images/` contains the 43 original book figures.
- `diagrams/` contains the editable SVG diagrams used by the reflowable EPUB.
- `iff/` contains Amiga-native image data, including the book's `TitleImage.iff`.
- `audio/` is reserved for WAV and 8SVX samples.
- `music/` is reserved for MIDI and MOD music files.

The preserved source repository currently includes no MIDI, WAV, 8SVX, MOD, or other
music/audio samples to copy. The empty media folders are intentional: the course's
modern asset-generation examples can place their outputs here without mixing them
with the original book figures.

The conversion utilities are in [`../tools`](../tools), including PNG-to-ILBM and
WAV-to-8SVX examples.
