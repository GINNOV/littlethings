TRUE	equ	-1
FALSE	equ	0

MUSIC	equ	TRUE	 ;turn music on/off


SCREEN_WIDTH	equ 320
SCREEN_HEIGHT	equ 256


ARG_SCREENMODE	equ	0*4
ARG_AGA		equ	1*4
ARG_WINDOW	equ	2*4
ARG_PUBSCREEN	equ	3*4
ARG_NOCHK	equ	4*4
ARG_LIMITFPS	equ	5*4
ARG_Count	equ	6

call	macro
	jsr	_LVO\1(a6)
	endm

callExe	macro
	move.l	$4.w,a6
	jsr	_LVO\1(a6)
	endm

callDos	macro
	move.l	_DosBase,a6
	jsr	_LVO\1(a6)
	endm

callGfx	macro
	move.l	_GfxBase,a6
	jsr	_LVO\1(a6)
	endm

callCgx	macro
	move.l	_CyberGfxBase,a6
	jsr	_LVO\1(a6)
	endm

callAsl	macro
	move.l	_AslBase,a6
	jsr	_LVO\1(a6)
	endm

	rept	0
callInt	macro
	move.l	_IntuitionBase,a6
	jsr	_LVO\1(a6)
	endm
	endr

callIco	macro
	move.l	_IconBase,a6
	jsr	_LVO\1(a6)
	endm



