#!/bin/bash

BAUD=19200

stty $BAUD -F pty_gdbsim
echo -n + > pty_gdbsim
/opt/m68k-elf.haarer/bin/m68k-elf-gdb ../amiga_cppVsC_build/amibench -ex "target remote pty_gdbsim" -b $BAUD

#/opt/m68k-elf.haarer/bin/m68k-elf-gdb ../Amiga_SnailGame_build/srcGame/main.elf --eval-command="target remote localhost:1234"
