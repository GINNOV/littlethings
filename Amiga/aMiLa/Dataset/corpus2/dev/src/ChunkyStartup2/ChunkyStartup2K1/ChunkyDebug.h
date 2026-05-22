#ifndef K_CHUNKYDEBUG_H
#define K_CHUNKYDEBUG_H
/*==========================================================*/
/*====                                                  ====*/
/*====                                                  ====*/
/*====      ChunkyDebug.h => ChunkyDebug.o handler      ====*/
/*====      krabob@online.fr 5/04/2001                  ====*/
/*====                                                  ====*/
/*====                                                  ====*/
/*==========================================================*/
/*
    short .o containing functions to
    help to debug under chunky screen.

    This .h was designed for vbcc (68k) that means
    the primitives use the __reg("d0") syntax to notify
    what argument use what register:
    This syntax is not the same for other compiler
    -> just change that to fit your compiler.

*/

/* Amiga-Standard Types */
#include    <exec/types.h>
/*==========================================================*/
/*====                                                  ====*/
/*==== Show Hexadecimal Integer value on chunky screen  ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  void    ShowInt(  __reg("d0") int value,
                          __reg("d1") int offset,
                          __reg("d2") int modulo,
                          __reg("a0") char *screen
                        );
/*
    Show Hexadecimal Integer value on chunky screen.
    the printing take a 64x8 pixelrectangle.

    value: the 32bit value to print in hexadecimal.
    offset: an offset to print anywhere on the chunky buffer.
    modulo: the bytes per line of the screen.
    screen : pointer to the screen buffer.

*/

#endif  /* K_CHUNKYDEBUG_H */

