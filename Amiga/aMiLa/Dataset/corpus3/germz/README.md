# GermZ

The 4-player versus game.

You take control of one of four GermZ species and your purpose of the game is to elliminate all other GermZ.

Includes a built-in map editor and the single-player campaign.

More info on the [game's website](https://lastminutecreations.itch.io/germz).

## Build instructions

This game builds either with [Bebbo's GCC](https://github.com/bebbo/amiga-gcc) or with compiler bundled with [Bartman's VSCode extension](https://github.com/BartmanAbyss/vscode-amiga-debug).

You need CMake and toolchain files from [AmigaPorts/AmigaCMakeCrossToolchains](https://github.com/AmigaPorts/AmigaCMakeCrossToolchains).
Be sure to have the compiler in your PATH or specify the path via the `-DCMAKE_C_COMPILER` parameter.

```sh
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=/path/to/m68k-toolchain-file.cmake -DM68K_CPU=68000
```

where `m68k-toolchain-file.cmake` is either `m68k-bartman.cmake` or `m68k-amigaos.cmake`.
On Windows, be sure to add `-G "MinGW Makefiles"` parameter.

## Original authors

- Luc3k: music, sound effects
- KaiN: code
- Softiron: graphics, levels

## License

Unless otherwise stated, the game's code is licensed under [Mozilla Public License 2.0](LICENSE).

The game's assets (placed in `res` directory) are licensed under [Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
