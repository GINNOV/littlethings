*
*   FileRequest.asm     13-Jan-88  
*   		    	Copyright © 1988 by David Czaya  (PLink -Dave-)
*			
*   This is a relatively close translation of the C language demo
*   'FileRequest.c' in 'Transactor for the Amiga' magazine [Vol. 1/Issue 1].
*
*   Above noted C version is Copyright © 1987, Scott Ballantyne
*
*   The arp.library (vers. 31 or higher) MUST be present for
*   this program to function! 
*
*   This source and any resulting object and load files are public domain
*   material.
*
	incdir	'df0:include/'
	INCLUDE 'misc/arpbase.i'
	

_LVOOpenLibrary		EQU -$0228
_LVOCloseLibrary  	EQU -$019e

MAXPATH 	EQU	((FCHARS*10)+DSIZE+1)	; size of a pathname

AbsExecBase     EQU	$4
Version		EQU	31		; do NOT use V32.01 because of a
					; possible bug in FileRequest()
ArpLib		EQUR	d7


Print	MACRO
	lea	\1,a0			; string goes here
	lea	Args,a1			; args go here
	LINKDOS	Printf
	ENDM


Init:
        move.l	AbsExecBase,a6		
        lea	ArpName,a1      	; open the arp library
        moveq   #Version,d0             ; version number
        LINKDOS OpenLibrary
        move.l  d0,ArpLib
        beq     FailToOpenArp

	exg	ArpLib,a6

        move.l  Default,Directory	; default directory
	lea     FR,a0			
	clr.l	d0
	LINKDOS FileRequest		; open the file requester

Select	beq	SayCancel		; user pressed cancel
 	cmp.b	#0,Filename
 	beq	NoFile			; no file selected
 	move.l	#Filename,Args		
 	Print	FileStr			; print filename
 	bra	SayDir

NoFile	move.l	#'',Args		
 	Print	NoFileStr		; print 'no file selected'

SayDir	move.l	#Directory,Args		
 	Print	DirStr			; print directory
 	bra	Quit	

SayCancel:	
 	move.l	#'',Args
 	Print	CancelStr		; print 'pressed cancel'

Quit	exg	ArpLib,a6
	move.l	ArpLib,a1
	LINKDOS	CloseLibrary
	moveq	#0,d0
	rts 				; Exit the program

FailToOpenArp:
	move.l	#20,d0			; return code 20
	rts


	SECTION DATA
	CNOP  0,2
Default		dc.b	'DF0:',0
Greetings	dc.b	'Greetings! Click on stuff!',0

FileStr		dc.b	'Filename =  %s ',$0A,0
DirStr		dc.b	'Directory = %s ',$0A,0

CancelStr	dc.b	'User cancelled requester!',$0A,0
NoFileStr	dc.b	'No filename selected!',$0A,0

ArpName		ArpName

FR	dc.l	Greetings		;  hailing text
        dc.l	Filename            	;  filename array
        dc.l	Directory               ;  directory array
        dc.l	0                       ;  window, NULL = workbench
        dc.w	0                       ;  flags, not used in this release
        dc.l	0                       ;  wildfunc,  "		"
        dc.l	0			;  msgfunc,   "		"	


	SECTION BSS
	CNOP  0,2

Args		ds.l	1

Directory	ds.b	MAXPATH
Filename	ds.b	FCHARS+1	;  be careful to align properly
		ds.w	0		;  or stick at end!
 end

