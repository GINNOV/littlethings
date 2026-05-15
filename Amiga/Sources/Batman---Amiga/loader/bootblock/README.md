# BOOTBLOCK

This is the disassembled game boot block from disk 1.

It contains an MFM bootloader that loads the main game loader file 'BATMAN' into memory at $800

The loader stays resident in memory for the life of the game and is invoked by parts of the game calling into the jump table at the start of the loader, which then loads, depacks and executes the various game stages.

The Rob Northen copy protection has been decoded and disassembled also, I've added annotations, and tried to get a handle on how it works.  There may be misunderstandings in the annotations.


