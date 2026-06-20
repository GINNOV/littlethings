* AddDosNode.asm 
*
* Interface code for AddDosNode() ... 
* 19-SEP-86 - Phillip Lindsay - (C) Commodore 1986 
*  You may freely distribute this source and use it for Amiga Development -
*  as long as the Copyright notice is left intact.
*
* This is for AZTEC people who don't have a library that supports new functions
*

_LVOAddDosNode	EQU	-150

	XREF	_ExpansionBase

        XDEF    _AddDosNode 	
       

_AddDosNode:

	move.l 	a6,-(sp)
        move.l  _ExpansionBase,a6
        movem.l 8(sp),d0-d1/a0
        jsr	_LVOAddDosNode(a6)	
        move.l (sp)+,a6
        rts
        
        END

* EOF
