# Parcade (Amiga A500 Demo Source)

## What is it?

This is the 68000 assembler source code for the ["Parcade"](https://www.pouet.net/prod.php?which=81350) Amiga intro.

Code & Music: Antiriad (Jonathan Bennett / jon@autoitscript.com)

## Requirements

Amiga 500 OCS chipset with 512KB RAM or better. 
(you'll need more ram to compile)

Tested with Devpac 3.18 and ASMOne 1.20.

You will need to edit all the INCDIR directives to suit.
Or assign SOURCES: and place in a folder called:
SOURCES:Parcade

To assemble entire intro assemble IntroWrapper_1.2.asm

To assemble a single part for testing, assemble one of these:
- BigSineScroller_1.4.s 
- BOBSnake_1.6.s
- GlenzSimple_1.23.s  (complex and glenz vectors)
- TextWall_1.6.s (text messages between parts)
