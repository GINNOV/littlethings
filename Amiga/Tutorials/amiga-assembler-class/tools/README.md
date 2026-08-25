# Modern asset tools

These small Python 3 tools generate deliberately simple Amiga assets for the course.

Install the image dependency once:

```sh
python3 -m pip install Pillow
```

Generate an OCS-compatible ILBM from a modern image:

```sh
python3 tools/png_to_ilbm.py assets/player.png build/player.ilbm --colors 16
```

Prepare a sound effect with FFmpeg, then wrap it as an Amiga 8SVX sample:

```sh
ffmpeg -i assets/laser.wav -ar 11025 -ac 1 -c:a pcm_u8 build/laser.wav
python3 tools/wav_to_8svx.py build/laser.wav build/laser.8svx
```

The generated files are intentionally uncompressed. That makes the `FORM`, `BMHD`,
`CMAP`, `BODY`, and `VHDR` chunks easy to inspect from assembly. Compression and
production asset packing can be added after the loader works.
