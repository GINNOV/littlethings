# Amiga 68000 Assembly Course

This project is an educational course for programmers who know a modern language such as Swift or Python but are new to assembly language. The goal is to teach 68000 assembly and Amiga programming through practical examples, with the longer-term goal of building a game.

## Acknowledgements

The course builds on the work of Paul Overaa, author of *Total Amiga Assembler*, originally published by Bruce Smith Books in 1995.

The original book has been preserved and made available digitally by the [Amiga Source Code Preservation project](https://gitlab.com/amigasourcecodepreservation/total-amiga-assembler). Its source, examples, and web edition are the foundation for the EPUB and course work in this directory.

This project expands on that work with:

- A beginner-oriented learning path for Swift, Python, and other high-level-language programmers.
- A modern, reflowable EPUB edition.
- Explanations, exercises, and quizzes.
- A practical progression toward building an Amiga game.
- Modern emulator and cross-development guidance.
- Modern asset tools for generating ILBM images, 8SVX samples, and game data.

The original book and its digital preservation project remain the authoritative sources for the preserved text. This course is an independent educational expansion and is not affiliated with or endorsed by Paul Overaa or Bruce Smith Books.

## License and attribution

The preserved book is released under the [Creative Commons Attribution-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-sa/4.0/), as documented by the source project. Adaptations of the original material should retain the required attribution and follow the same license terms.

Original work:

- Paul Overaa, *Total Amiga Assembler*, 1995
- Bruce Smith Books
- [Amiga Source Code Preservation: Total Amiga Assembler](https://gitlab.com/amigasourcecodepreservation/total-amiga-assembler)

Course and EPUB work in this directory is an independent expansion built on that preserved material.

## Practical asset tools

The [`tools`](tools) directory contains small Python 3 reference converters:

- `png_to_ilbm.py` converts a modern image into a simple uncompressed OCS ILBM.
- `wav_to_8svx.py` converts PCM WAV audio into an IFF 8SVX sample.

The course explains how to use OpenMPT for classic four-channel Amiga MOD files, FFmpeg for audio preparation, and Python for project-owned level and game-data files.

## Project layout

- [`sample-code`](sample-code) contains the readable assembler, C, and supporting documentation used by the book, organized by chapter.
- [`assets`](assets) contains the original figures, editable EPUB diagrams, Amiga-native IFF data, and dedicated folders for audio and music samples.
- [`tools`](tools) contains modern converters for preparing assets for an Amiga build.

The preserved checkout remains under `tmp/upstream-total-amiga-assembler`. The organized folders above are working copies for the course and keep generated teaching material separate from the preserved source.
