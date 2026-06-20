
*	Examples of using Graphics library routines.

*	Coding, Mike Cross - January 1991


	incdir	include/
	include	graphics/graphics_lib.i
	include	intuition/intuition_lib.i
	include	exec/exec_lib.i
	
Ciaapra	equ	$bfe001

	movem.l  a0-a6/d0-d7,-(a7)		* Save all on stack
	move.l   a7,Stack
	
	lea     	_GfxName,a1
	CALLEXEC	OldOpenLibrary     
	move.l 	d0,_GfxBase
	beq	Q_Exit
	lea     	_IntName,a1
	CALLEXEC	OldOpenLibrary     
	move.l 	d0,_IntuitionBase
	beq	Q_Exit2
	
	lea	NewScreen,a0
	CALLINT	OpenScreen
	move.l	d0,_S_Handle
	
	move.l	d0,a0
	add.l	#44,a0
	move.l	a0,_ViewPort
	add.l	#40,a0
	move.l	a0,_RastPort
	
	move.l	_ViewPort,a0
	lea	Palette,a1
	move.w	#4,d0		* 4 colours in map
	CALLGRAF	LoadRGB4
	
	move.l	_RastPort,a1	* Applies to ALL calls
	
	lea	String,a0
	move.w	#End-String,d0
	CALLGRAF	TextLength	* D0 contains width in pixels
	
	movea.l	_S_Handle,a0
	move.w	12(a0),d1		* Get screen width
	sub.w	d0,d1
	ror.w	#1,d1
	move.w	d1,d0
	move.w	#60,d1
	CALLGRAF	Move
	
	move.w	#2,d0		* Use colour 2 (Yellow)
	CALLGRAF	SetAPen		* This is main text colour
	move.w	#3,d0		* Text background is colour 3
	CALLGRAF	SetBPen		* (Red)
	
	move.w	#4,d0		* This sets the text style
	move.w	#4,d1		* 4 = Italicised
	CALLGRAF	SetSoftStyle
	
	lea	String,a0
	move.w	#End-String,d0
	CALLGRAF	Text
	
	
Mouse	btst	#6,Ciaapra		
	bne.s	Mouse
	
	
	move.l	_S_Handle,a0
	CALLINT	CloseScreen
	
	move.l	_IntuitionBase,a1
	CALLEXEC	CloseLibrary
	
Q_Exit2	move.l	_GfxBase,a1
	CALLEXEC	CloseLibrary
	
Q_Exit	move.l  	Stack,a7
	movem.l 	(a7)+,A0-a6/d0-D7
	moveq.l	#0,d0
	rts
	
	
Stack		dc.l	0
_GfxBase		dc.l	0
_IntuitionBase	dc.l	0
_RastPort		dc.l	0
_ViewPort		dc.l	0
_S_Handle		dc.l	0

Palette		dc.w	$0000,$0fff,$0fd0,$0a00

	even

_IntName	dc.b	'intuition.library',0

	even

_GfxName	dc.b	'graphics.library',0

	even
	
NewScreen	dc.w	0,0,640,256
	dc.w	2
	dc.b	0,1
	dc.w	$8002
	dc.w	15
	dc.l	0
	dc.l	_Title
	dc.l	0,0
_Title	dc.b	'Graphics Library routines for ACC, by Mike Cross.',0

	even
	
String	dc.b	' This text is perfectly centered on the screen. '
End

	even
	







	
