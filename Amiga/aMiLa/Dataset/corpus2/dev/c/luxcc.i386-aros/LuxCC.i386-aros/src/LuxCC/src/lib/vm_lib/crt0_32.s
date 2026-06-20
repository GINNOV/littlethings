# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                        32-bit C Runtime Startup                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#
# Globals.
#
.bss
    .align 4
_vars:
stdin:
.global stdin
    .res 4
stdout:
.global stdout
    .res 4
stderr:
.global stderr
    .res 4
_argc:
    .res 4
_argv:
    .res 4
errno:
.global errno
    .res 4

#
# Entry point.
#
.text
    # let the VM set globals
    ldidw _vars;
    ldidw _getvars;
    call 4;
    pop;

    # call main/exit
    .extern main    # the user must define it!
    ldidw _argv;
    lddw;
    ldidw _argc;
    lddw;
    ldidw main;
    call 8;
    halt;

#
# Library routines.
#
_getvars:
    libcall 0;
    ret;
malloc:
.global malloc
    libcall 1;
    ret;
free:
.global free
    libcall 2;
    ret;
exit:
.global exit
    libcall 3;
    ret;
realloc:
.global realloc
    libcall 4;
    ret;
fputc:
.global fputc
    libcall 5;
    ret;
fgetc:
.global fgetc
    libcall 6;
    ret;
fread:
.global fread
    libcall 7;
    ret;
fwrite:
.global fwrite
    libcall 8;
    ret;
ferror:
.global ferror
    libcall 9;
    ret;
fopen:
.global fopen
    libcall 10;
    ret;
fclose:
.global fclose
    libcall 11;
    ret;
fseek:
.global fseek
    libcall 12;
    ret;
ftell:
.global ftell
    libcall 13;
    ret;
rewind:
.global rewind
    libcall 14;
    ret;
fgets:
.global fgets
    libcall 15;
    ret;
stat:
.global stat
    libcall 16;
    ret;
fileno:
.global fileno
    libcall 17;
    ret;
isatty:
.global isatty
    libcall 18;
    ret;
strtol:
.global strtol
    libcall 19;
    ret;
strtoul:
.global strtoul
    libcall 20;
    ret;
strtoll:
.global strtoll
    libcall 21;
    addsp 4;
    pushsp;
    ret;
strtoull:
.global strtoull
    libcall 22;
    addsp 4;
    pushsp;
    ret;
system:
.global system
    libcall 23;
    addsp 4;
    pushsp;
    ret;
remove:
.global remove
    libcall 24;
    addsp 4;
    pushsp;
    ret;
rename:
.global rename
    libcall 25;
    addsp 4;
    pushsp;
    ret;
fflush:
.global fflush
    libcall 26;
    addsp 4;
    pushsp;
    ret;
