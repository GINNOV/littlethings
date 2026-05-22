# Assemble for Amiga

Assemble is a fast m68k assembler for the Amiga line of computers, written
in assembly, supporting 68000, 68010, 68020, 68030, 68040, CPU32,
68851, 68881-2. The syntax is normally 100% compatible with Devpac.

This repository consists of my backup files. The latest
changes date back from 1995.

Assemble for the Atari ST/TT computers was commercialized by [Brainstorm](http://www.brainstorm.fr/Kits/ASSEMBLEATARI.html.fr) in the 90's.

The Amiga port did not have an IDE and was not released publicly.
There is no documentation available.

Authors: Alexandre Lemaresquier, Raphaël Lemoine, Daniel Vérité.

## Build process

Assemble uses itself (`asm`) to assemble, but the executable is
missing from the backups. Object files are present though, so hopefully
creating the `asm` executable should be doable by running a link step.
Otherwise, Devpac should be suitable to build from source.

The Makefile uses `slink` as the linker.
