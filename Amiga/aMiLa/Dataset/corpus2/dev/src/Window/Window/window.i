***********************************************************************
* window.i
* contents: useful macros/definitions from Tim King
* 9/15/86
*
* (c) 1986 Commodore-Amiga, Inc.
* This file may be used in any manner, as long as this copyright notice
* remains intact.
* 		andy finkel
*		Commodore-Amiga
*
***********************************************************************

procst  macro
        link    a6,\1
        movem.l \2,-(sp)
        sub.l   z,z
        endm

return  macro
        movem.l (sp)+,\1
        unlk    a6
        rts
        endm

callg   macro
        move.l  a6,-(sp)
        move.l  #\1,d0
        move.l  _DOSBase,a6
        jsr     -28(a6)
        move.l  (sp)+,a6
        endm
 
* Registers
Z       equr    a0
*P      equr    a1
*G      equr    a2
L       equr    a3
B       equr    a4
S       equr    a5
R       equr    a6

arg1    equ     8
arg2    equ     12
arg3    equ     16
arg4    equ     20

*****************************
* end of file window.i
*****************************
