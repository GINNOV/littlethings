# Amiga 68k Cross-Development Docker Environment
# Provides gcc, vasm, and AmigaOS cross-compilation toolchains

FROM amigadev/crosstools:m68k-amigaos

WORKDIR /work

# Default command compiles C source file button_sound.c
CMD ["m68k-amigaos-gcc", "-O2", "button_sound.c", "-o", "button_sound", "-noixemul"]
