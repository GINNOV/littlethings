* PERSONAL MACROS

callexec Macro                   Define a macro for calling library
 move.l $4,a6                routines, This keeps the source tidy
 jsr \1(a6)              and shorter  
 Endm

plane Macro 		     Define macro for placing pic into
 move.w d0,\1		     plane pointers. The \1 and \2 is 
 swap d0 		     where the macro passes the parameters to.
 move.w d0,\2 		     ie. move.w d0,\1 is assembled as
 swap d0		     move.w d0,pl1l in line 37.
 add.l #$\3,d0	    	     Add plane size, ready for next plane.
 Endm
 
mouse Macro
 btst #6,Ciaapra
 bne.s \1
 Endm

rmouse Macro
 btst #2,Ciaapra
 bne.s \1
 Endm

Call macro
	jsr \1(a6)
	endm

OpenDos macro
	lea DosName(pc),a1
	move.l \2,d0
	callexec OpenLibrary
	move.l d0,\1
	endm

OpenInt	macro
	lea IntName(pc),a1
	move.l \2,d0
	callexec OpenLibrary
	move.l d0,\1
	endm

OpenGraph macro
	lea GraphName(pc),a1
	move.l \2,d0
	callexec OpenLibrary
	move.l d0,\1
	endm

Close	macro
	move.l \1,a1
	callexec CloseLibrary
	endm

Base	macro
	move.l \1,a6
	endm

DosName	macro
Dosname	dc.b "dos.library",0
	even
	endm

IntName	macro
IntName	dc.b "intuition.library",0
	even
	endm

Graphname macro
Graphname dc.b "graphics.library",0
	even
	endm

DFontName macro
DFontName dc.b "diskfont.library",0
	even
	endm

OpenDFont macro
	lea DFontName(pc),a1
	move.l \2,d0
	callexec OpenLibrary
	move.l d0,\1
	endm
