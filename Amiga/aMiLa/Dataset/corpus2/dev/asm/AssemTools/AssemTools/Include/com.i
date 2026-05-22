; Graphics and etc. MACRO SET
; fw 1988
; Metacomco Macro Assembler
; Needs 'jmplibs.i' included
; 
; NOTE: The "common registers" (d0-d1/a0-a1/a6-a7)
; should not be used as parameters for these macros
; to avoid confusion.

leftmouse	macro
		btst	#6,$bfe001
		endm

; Usage: leftmouse [<dummy>]
; Returns the zero flag as ONE if the left mouse button was
; pressed.
; <dummy> for compatibility with former versions.


rightmouse	macro
		btst	#10,$dff016
		endm

; Usage: rightmouse
; Returns the zero flag as ONE if the right mouse button was
; pressed.


use_text	macro
		push	d0-d1/a0-a2
		move.l	\1,a1
		move.w	\2,d0
		move.l	\4,a2
		move.w	\3,d1
		lib	Gfx,Move
		move.l	a2,a0
		moveq.l	#-1,d0
use_tx\@	addq.l	#1,d0
		tst.b	(a2)+
		bne	use_tx\@
		lib	Gfx,Text
		pull	d0-d1/a0-a2
		endm

; Usage: use_text <rport>,<xco>,<yco>,<*text>
; Calculates the length of the string *text
; (until a null byte) and outputs it to po-
; sition xco,yco using Move and Text-functions
; of the Graphics library.


alloc_mem	macro
		move.l	$4,a6
		move.l	\1,d0
		move.l	\2,d1
		jsr	_LVOAllocMem(a6)
		move.l	d0,\3
		endm

; Usage: alloc_mem <size>,<type>,<*mem>
; Allocates memory and returns the pointer.


use_setapen	macro
		move.l	\1,a1
		move.l	\2,d0
		lib	Gfx,SetAPen
		endm

use_setbpen	macro
		move.l	\1,a1
		move.l	\2,d0
		lib	Gfx,SetBPen
		endm

;Usage:	use_setapen <rport>,<pen>
;Sets the Bg-pen (setbpen) or the Fg-pen (setapen).


use_setmask	macro
		move.l	\1,a1
		move.b	\2,24(a1)
		endm

;Usage:	use_setmask <rport>,<mask>
;Sets the drawing mask for given rastport.


use_move	macro
		move.l	\1,a1
		move.l	\2,d0
		move.l	\3,d1
		lib	Gfx,Move
		endm

use_draw	macro
		move.l	\1,a1
		move.l	\2,d0
		move.l	\3,d1
		lib	Gfx,Draw
		endm

;Usage:	use_move <rport>,<xco>,<yco>
;	use_draw <rport>,<xco>,<yco>
;Moves the pixel cursor or draws a line.


use_hrect	macro
		move.l	\1,a1
		move.l	\2,d0
		move.l	\3,d1
		lib	Gfx,Move
		move.l	\2,d0
		move.l	\5,d1
		move.l	\1,a1
		lib	Gfx,Draw
		move.l	\4,d0
		move.l	\5,d1
		move.l	\1,a1
		lib	Gfx,Draw
		move.l	\4,d0
		move.l	\3,d1
		move.l	\1,a1
		lib	Gfx,Draw
		move.l	\2,d0
		move.l	\3,d1
		move.l	\1,a1
		lib	Gfx,Draw
		endm

;Usage:	use_hrect <rport>,<xco1>,<yco1>,<xco2>,<yco2>
;Draws a hollow rectangle using Move and Draw-routines


use_frect	macro
		move.l	\1,a1
		move.l	\4,d2
		move.l	\5,d3
		move.l	\2,d0
		move.l	\3,d1
		lib	Gfx,RectFill
		endm

;Usage:	use_frect <rport>,<xco1>,<yco1>,<xco2>,<yco2>
;Draws a filled rectangle using the RectFill-routine.
;NOTE: Any parameters should not be passed to this macro
;in the common registers or d2-d3 to avoid confusion.


set_led		macro
		push	d0
		move.l	\1,d0
		beq	\@s_led2
		bpl	\@s_led1
		bclr	#1,$bfe001
		bra	\@s_led0
\@s_led1	bset	#1,$bfe001
		bra	\@s_led0
\@s_led2	bchg	#1,$bfe001
\@s_led0	pull	d0
		endm

;Usage:	set_led	<state>
;Sets the power indicator state. On a positive <state> the
;indicator will be turned off (A500) or dimmed (A1000/A2000).
;On a negative <state> the indicator will be brightened back.
;On a zero <state> the led will be toggled on and off.


use_line	macro
		move.l	\1,a1
		move.l	\2,d0
		move.l	\3,d1
		lib	Gfx,Move
		move.l	\1,a1
		move.l	\4,d0
		move.l	\5,d1
		lib	Gfx,Draw
		endm

;Usage:	use_line <rport>,<x1>,<y1>,<x2>,<y2>
;Draws a straight line between points (x1,y1)
;and (x2,y2) using the routines DRAW and MOVE
;of the Gfx-library.


use_setdrmd	macro
		move.l	\1,a1
		move.l	\2,d0
		lib	Gfx,SetDrMd
		endm

;Usage:	use_setdrmd <rport>,<mode>
;Sets the drawing mode using the SetDrMd-routine.


drmd_jam1	equ	0
drmd_jam2	equ	1
drmd_complement	equ	2
drmd_inversvid	equ	4

memf_public	equ	1
memf_chip	equ	2
memf_fast	equ	4
memf_clear	equ	1<<16
memf_largest	equ	1<<17

style_bold	equ	2
style_italic	equ	4
style_underline	equ	1

customscreen	equ	15


use_setrast	macro
		move.l	\1,a1
		move.l	\2,d0
		lib	Gfx,SetRast
		endm

;Usage:	use_setrast <rport>,<color>
;Used to fill the whole rastport with any color.


use_scrollraster macro
		move.l	\1,a1
		move.l	\2,d2
		move.l	\3,d3
		move.l	\4,d4
		move.l	\5,d5
		move.l	\6,d0
		move.l	\7,d1
		lib	Gfx,ScrollRaster
		endm

;Usage:	use_scrollraster <rport>,<x1>,<y1>,<x2>,
;	<y2>,<xd>,<yd>
;Scrolls a rectangular area of the rastport.
;Direction is specified by dx and dy. Negative
;value means down or right, positive up or left.


use_clearvert	macro
		move.l	\1,a1
		move.l	4(a1),a1
		move.l	(8+4*\2)(a1),a1
		add.l	#\3*\5,a1
		move.l	#\4*\5,d0
		moveq.l	#0,d1
		lib	Gfx,BltClear
		endm

;Usage:	use_clearvert <rport>,<plane#>,<ymin>,<ysiz>,<bytesperrow>
;Used to clear a vertical region of a rastport.
;plane# is the number of plane to be cleared, 
;ymin and ysiz are the utmost pixel line and number of pixel
;lines of the area to be cleared,
;bytesperrow is the number of bytes per a horizontal row
;The values plane#, ymin, ysiz and bpr must be entered as
;immediate values, but WITHOUT the hash (#) sign.


use_loadrgb4	macro
		move.l	\1,a0
		move.l	\2,a1
		move.l	\3,d0
		lib	Gfx,LoadRGB4
		endm

;Usage:	use_loadrgb4 <vport>,<colmap>,<count>
;Loads palette for given viewport. See the
;Amiga Rom Kernel Refernce Manual: Libraries
;and Devices for further details.


rassize		macro
\1		set	\3*(((\2+15)/16)*2)
		endm

;Usage:	rassize <label>,<xsiz>,<ysiz>
;SETs the value of the label as the size of a raster
;of size (xsiz,ysiz) in words.


use_allocraster	macro
		move.l	\1,d0
		move.l	\2,d1
		lib	Gfx,AllocRaster
		move.l	d0,\3
		ifnc	'\4',''
		beq	\4
		endc
		endm

;Usage:	use_allocraster <wid>,<heig>,<dest>[,<cleanup>]
;Allocates a raster of size <wid>,<heig>. Pointer to
;the raster is written to the <dest>. If an error occurs,
;the program flow will be transferred to <cleanup>.


use_freeraster	macro
		move.l	\1,d0
		move.l	\2,d1
		move.l	\3,a0
		lib	Gfx,FreeRaster
		endm

;Usage:	use_freeraster <wid>,<heig>,<pointer>
;Frees the raster allocated by the use_allocraster.
;Use the same parameters as in the use_allocraster.

