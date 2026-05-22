

	; ***************************************************************
	; ***                                                         ***
	; ***  SOURCEFILE CONTAINING ALL STUFF NEEDED FOR MY EFFECTS  ***
	; ***                                                         ***
	; ***************************************************************


	; Assembled with PhxAss V4.36 (C)1991-1997 Frank Wille



	; New Stuff (6.4.98)
	;
	;
	;  * Added a background to the textured scene.
	;
	;  * Made the little pyramids rotate some more in the scene.
	;
	;  * Modified the shape of the 'N' in the scene to what Raven suggested.
	;
	;  * Added code to flash the screen between effects. You can change
	;    the colour of the flash using the 'BLANK_COLOUR' equate (below).
	;    Also fixed the annoying bug where the previous effect's display
	;    was shown on the next effect.
	;
	;  * Modified the 'CantStop.CNK' file to make the logo a bit more readable
	;    on darker screens.
	;
	;  That should be most of the major changes for now! ;)
	;



	; What's changed:
	;
	; Everything needed to assemble my effects is contained in this file,
	; except the binary files. All three effects share the same ChipRAM
	; for their planar display, but chew up a fair bit of FastRAM
	; (around 400K in total I think).
	;
	; 'Driver0' shows how to init and run all the effects together.
	;
	; Effects now run for a specified time, and then exit automatically.
	; Since I don't know how you do music synchronisation, I've done it
	; this way to at least give you some control over timing of the
	; effects.
	;
	;
	; Usage:
	;
	;  * Do a Jsr to 'LINE_INIT', 'BUMP_INIT', and 'SCENE_INIT' as part of
	;    your precalculation stuff.
	;
	;  * Call 'LINE_SHOW', 'BUMP_SHOW', and 'SCENE_SHOW' when you want the
	;    specific effect to be shown on screen. It will then run for the
	;    time specified below, and then return.
	;
	; The 'LINE_END', 'BUMP_END', and 'SCENE_END' did nothing, so they're
	; gone now! ;)
	;



	; ** THIS DEFINES THE LENGTH (IN FRAMES) FOR EACH EFFECT TO RUN) **

L_FRAMES	= 800		; 16 seconds
B_FRAMES	= 800
S_FRAMES	= 800


BLANK_COLOUR	= $888		; Colour that screen changes to between effects




	
	MACHINE	68020			; Gimme those all important opcodes ;)



	; ***************************************************************
	; ***                                                         ***
	; ***  DEMO EFFECTS LIBRARY: C2P, 3D ENGINE, GENERAL STUFF    ***
	; ***                                                         ***
	; ***************************************************************



	; ** This chunky-to-planar code is not mine! It was ripped from
	; ** an archive on Aminet, and to the best of my knowledge is
	; ** freely distributable. If this is not the case, then please
	; ** contact me, and it will be removed.

	; ** It has also been modified somewhat to allow different sized
	; ** C2P areas using the same piece of code.

	; ** Original archive was called 'FastC2P.LHA', and chunky routine
	; ** was called 'c2p_020.s'.


; Chunky2Planar algorithm. [writes pipelined a little]
;
; 	Cpu only solution
;	Optimised for 020+fastram
;	Aim for less than 90ms for 320x200x256 on 14MHz 020
;
;
; NOTE: uses hardcoded values for screen size
; 	assumes planes are allocated contiguously
;
; NOTE2:	Hacked a little bit to allow variable sized C2P coversion
;		Planar screensize remains at 320x200, but C2P can work
;		on any size (specified in d0)
;
; -------------------------------------------------------------------
;
; void __asm c2p_020(	register __d0 ULONG c2p_size,
;			register __a0 UBYTE *chunky,
;			register __a1 PLANEPTR raster );
;
; -------------------------------------------------------------------
;
; see c2p_020_test.c for example of usage


;	opt	o-,l+,d+
	
WIDTH		equ	320		; MUST be multiple of 32
HEIGHT		equ	200
plsiz		equ	(WIDTH/8)*HEIGHT


		cnop	0,4

_c2p_020

	movem.l	d2-d7/a2-a6,-(sp)

;	move.l	a0,a2
;	add.l	#plsiz*8,a2	;a2 = end of chunky buffer

	Move.l	d0,.c2psize
	Move.l	a0,a2
	Add.l	d0,a2		; a2 = end of chunky buffer


	
	;; Sweep thru the whole chunky data once,
	;; Performing 3 merge operations on it.
	
	move.l	#$00ff00ff,a3	; load byte merge mask
	move.l	#$0f0f0f0f,a4	; load nibble merge mask
	
.firstsweep
	movem.l (a0),d0-d7      ;8+4n   40      cycles
	move.l	d4,a6           ;a6 = CD
	move.w	d0,d4           ;d4 = CB
	swap	d4              ;d4 = BC
	move.w	d4,d0           ;d0 = AC
	move.w	a6,d4           ;d4 = BD
	move.l	d5,a6           ;a6 = CD
	move.w	d1,d5           ;d5 = CB
	swap	d5              ;d5 = BC
	move.w	d5,d1           ;d1 = AC
	move.w	a6,d5           ;d5 = BD
	move.l	d6,a6           ;a6 = CD
	move.w	d2,d6           ;d6 = CB
	swap	d6              ;d6 = BC
	move.w	d6,d2           ;d2 = AC
	move.w	a6,d6           ;d6 = BD
	move.l	d7,a6           ;a6 = CD
	move.w	d3,d7           ;d7 = CB
	swap	d7              ;d7 = BC
	move.w	d7,d3           ;d3 = AC
	move.w	a6,d7           ;d7 = BD
	move.l	d7,a6
	move.l	d6,a5
	move.l	a3,d6   ; d6 = 0x0x
	move.l	a3,d7   ; d7 = 0x0x
	and.l	d0,d6   ; d6 = 0b0r
	and.l	d2,d7   ; d7 = 0j0z
	eor.l	d6,d0   ; d0 = a0q0
	eor.l	d7,d2   ; d2 = i0y0
	lsl.l	#8,d6   ; d6 = b0r0
	lsr.l	#8,d2   ; d2 = 0i0y
	or.l	d2,d0           ; d0 = aiqy
	or.l	d7,d6           ; d2 = bjrz
	move.l	a3,d7   ; d7 = 0x0x
	move.l	a3,d2   ; d2 = 0x0x
	and.l	d1,d7   ; d7 = 0b0r
	and.l	d3,d2   ; d2 = 0j0z
	eor.l	d7,d1   ; d1 = a0q0
	eor.l	d2,d3   ; d3 = i0y0
	lsl.l	#8,d7   ; d7 = b0r0
	lsr.l	#8,d3   ; d3 = 0i0y
	or.l	d3,d1           ; d1 = aiqy
	or.l	d2,d7           ; d3 = bjrz

	move.l  a4,d2   ; d2 = 0x0x
	move.l  a4,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #4,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,(a0)+
	lsl.l	#4,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l	d2,(a0)+

	move.l  a4,d3   ; d3 = 0x0x
	move.l  a4,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #4,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l	d6,(a0)+
	lsl.l	#4,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l	d3,(a0)+

	; move.l	d0,(a0)+
	; move.l	d2,(a0)+
	; move.l	d6,(a0)+
	; move.l	d3,(a0)+
	move.l	a6,d7
	move.l  a5,d6
	move.l  a3,d0   ; d0 = 0x0x
	move.l  a3,d1   ; d1 = 0x0x
	and.l   d4,d0   ; d0 = 0b0r
	and.l   d6,d1   ; d1 = 0j0z
	eor.l   d0,d4   ; d4 = a0q0
	eor.l   d1,d6   ; d6 = i0y0
	lsl.l   #8,d0   ; d0 = b0r0
	lsr.l   #8,d6   ; d6 = 0i0y
	or.l    d6,d4           ; d4 = aiqy
	or.l    d1,d0           ; d6 = bjrz
	move.l  a3,d1   ; d1 = 0x0x
	move.l  a3,d6   ; d6 = 0x0x
	and.l   d5,d1   ; d1 = 0b0r
	and.l   d7,d6   ; d6 = 0j0z
	eor.l   d1,d5   ; d5 = a0q0
	eor.l   d6,d7   ; d7 = i0y0
	lsl.l   #8,d1   ; d1 = b0r0
	lsr.l   #8,d7   ; d7 = 0i0y
	or.l    d7,d5           ; d5 = aiqy
	or.l    d6,d1           ; d7 = bjrz
	move.l  a4,d6   ; d6 = 0x0x
	move.l  a4,d7   ; d7 = 0x0x
	and.l   d4,d6   ; d6 = 0b0r
	and.l   d5,d7   ; d7 = 0j0z
	eor.l   d6,d4   ; d4 = a0q0
	eor.l   d7,d5   ; d5 = i0y0
	lsr.l   #4,d5   ; d5 = 0i0y
	or.l    d5,d4           ; d4 = aiqy
	move.l  d4,(a0)+
	lsl.l   #4,d6   ; d6 = b0r0
	or.l    d7,d6           ; d5 = bjrz
	move.l  d6,(a0)+

	move.l  a4,d7   ; d7 = 0x0x
	move.l  a4,d5   ; d5 = 0x0x
	and.l   d0,d7   ; d7 = 0b0r
	and.l   d1,d5   ; d5 = 0j0z
	eor.l   d7,d0   ; d0 = a0q0
	eor.l   d5,d1   ; d1 = i0y0
	lsr.l   #4,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,(a0)+
	lsl.l   #4,d7   ; d7 = b0r0
	or.l    d5,d7           ; d1 = bjrz
	move.l  d7,(a0)+
	cmp.l   a0,a2           ;; 4c
	bne.w   .firstsweep      ;; 6c

;	sub.l   #plsiz*8,a0
	sub.l   .c2psize,a0
	move.l  #$33333333,a5
	move.l  #$55555555,a6
	lea     plsiz*4(a1),a1  ;a2 = plane4

.secondsweep
	move.l  (a0),d0
	move.l  8(a0),d1
	move.l  16(a0),d2
	move.l  24(a0),d3

	move.l  a5,d6   ; d6 = 0x0x
	move.l  a5,d7   ; d7 = 0x0x
	and.l   d0,d6   ; d6 = 0b0r
	and.l   d2,d7   ; d7 = 0j0z
	eor.l   d6,d0   ; d0 = a0q0
	eor.l   d7,d2   ; d2 = i0y0
	lsl.l   #2,d6   ; d6 = b0r0
	lsr.l   #2,d2   ; d2 = 0i0y
	or.l    d2,d0           ; d0 = aiqy
	or.l    d7,d6           ; d2 = bjrz
	move.l  a5,d7   ; d7 = 0x0x
	move.l  a5,d2   ; d2 = 0x0x
	and.l   d1,d7   ; d7 = 0b0r
	and.l   d3,d2   ; d2 = 0j0z
	eor.l   d7,d1   ; d1 = a0q0
	eor.l   d2,d3   ; d3 = i0y0
	lsl.l   #2,d7   ; d7 = b0r0
	lsr.l   #2,d3   ; d3 = 0i0y
	or.l    d3,d1           ; d1 = aiqy
	or.l    d2,d7           ; d3 = bjrz
	move.l  a6,d2   ; d2 = 0x0x
	move.l  a6,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #1,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,plsiz*3(a1)
	add.l   d2,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l  d2,plsiz*2(a1)

	move.l  a6,d3   ; d3 = 0x0x
	move.l  a6,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #1,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l  d6,plsiz*1(a1)
	add.l   d3,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l  d3,(a1)+
 
	move.l  4(a0),d0
	move.l  12(a0),d1
	move.l  20(a0),d2
	move.l  28(a0),d3

	move.l  a5,d6   ; d6 = 0x0x
	move.l  a5,d7   ; d7 = 0x0x
	and.l   d0,d6   ; d6 = 0b0r
	and.l   d2,d7   ; d7 = 0j0z
	eor.l   d6,d0   ; d0 = a0q0
	eor.l   d7,d2   ; d2 = i0y0
	lsl.l   #2,d6   ; d6 = b0r0
	lsr.l   #2,d2   ; d2 = 0i0y
	or.l    d2,d0           ; d0 = aiqy
	or.l    d7,d6           ; d2 = bjrz
	move.l  a5,d7   ; d7 = 0x0x
	move.l  a5,d2   ; d2 = 0x0x
	and.l   d1,d7   ; d7 = 0b0r
	and.l   d3,d2   ; d2 = 0j0z
	eor.l   d7,d1   ; d1 = a0q0
	eor.l   d2,d3   ; d3 = i0y0
	lsl.l   #2,d7   ; d7 = b0r0
	lsr.l   #2,d3   ; d3 = 0i0y
	or.l    d3,d1           ; d1 = aiqy
	or.l    d2,d7           ; d3 = bjrz
	move.l  a6,d2   ; d2 = 0x0x
	move.l  a6,d3   ; d3 = 0x0x
	and.l   d0,d2   ; d2 = 0b0r
	and.l   d1,d3   ; d3 = 0j0z
	eor.l   d2,d0   ; d0 = a0q0
	eor.l   d3,d1   ; d1 = i0y0
	lsr.l   #1,d1   ; d1 = 0i0y
	or.l    d1,d0           ; d0 = aiqy
	move.l  d0,-4-plsiz*1(a1)
	add.l   d2,d2
	or.l    d3,d2           ; d1 = bjrz
	move.l  d2,-4-plsiz*2(a1)

	move.l  a6,d3   ; d3 = 0x0x
	move.l  a6,d1   ; d1 = 0x0x
	and.l   d6,d3   ; d3 = 0b0r
	and.l   d7,d1   ; d1 = 0j0z
	eor.l   d3,d6   ; d6 = a0q0
	eor.l   d1,d7   ; d7 = i0y0
	lsr.l   #1,d7   ; d7 = 0i0y
	or.l    d7,d6           ; d6 = aiqy
	move.l  d6,-4-plsiz*3(a1)
	add.l   d3,d3
	or.l    d1,d3           ; d7 = bjrz
	move.l  d3,-4-plsiz*4(a1)
	add.w   #32,a0  ;;4c
	cmp.l   a0,a2   ;;4c
	bne.w   .secondsweep     ;;6c

	;300

.exit	movem.l	(sp)+,d2-d7/a2-a6
	rts

.c2psize	Dc.l	320*200






	; ----------------------------------------
	; --                                    --
	; --  All Macros for Demo Include File  --
	; --                                    --
	; ----------------------------------------




	; -------------
	; -- OFFSETS --
	; -------------


VPOSR	= $004
VHPOSR	= $006

JOY0DAT	= $00A
JOY1DAT	= $00C

COP1LCH	= $080
COP1LCL = $082
COPJMP1	= $088

DIWSTRT	= $08E
DIWSTOP	= $090
DDFSTRT	= $092
DDFSTOP	= $094

DMACON	= $096

BPL0PTH	= $0E0
BPL0PTL = $0E2
BPL1PTH	= $0E4
BPL1PTL = $0E6
BPL2PTH	= $0E8
BPL2PTL = $0EA
BPL3PTH	= $0EC
BPL3PTL = $0EE
BPL4PTH	= $0F0
BPL4PTL = $0F2
BPL5PTH	= $0F4
BPL5PTL = $0F6
BPL6PTH	= $0F8
BPL6PTL = $0FA
BPL7PTH	= $0FC
BPL7PTL = $0FE
BPLCON0	= $100
BPLCON1	= $102
BPLCON2	= $104
BPLCON3	= $106
BPL1MOD	= $108
BPL2MOD	= $10A
BPLCON4	= $10C

FMODE	= $1FC



	; ------------------------
	; -- GRAPHICS FUNCTIONS --
	; ------------------------

_WaitVBL	MACRO
	IFEQ	NARG-1
	  Move.w	d0,-(sp)
	  Move.w	#\1 - 1,d0
.\@	  Jsr	__WaitVBL
	  Dbra	d0,.\@
	  Move.w	(sp)+,d0
	ELSE
	  Jsr	__WaitVBL
	ENDC

	ENDM


__WaitVBL
	Move.l	d0,-(sp)
.lp	Move.l	$DFF004,d0
	Lsr.l	#8,d0			; Just Vertical
	And.w	#$01FF,d0
	Cmp.w	#$0010,d0		; Wait for line 16 (gives copper a
	Bne.s	.lp			;  chance to update!)
	Move.l	(sp)+,d0

__WaitLine
	Move.w	d0,-(sp)
	Move.b	$DFF006,d0
	Addq.b	#2,d0				; Waits at least 1 scanline (no more than 2)
.1	Cmp.b	$DFF006,d0
	Bge.s	.1
	Move.w	(sp)+,d0
	Rts




_LoadPalette24	MACRO
	Movem.l	d0-4/a0-1,-(sp)
	Lea	\1,a0
	Lea	\2,a1
	Move.w	#\3,d0
	Subq.w	#1,d0
	Jsr	__LoadPalette24
	Movem.l	(sp)+,d0-4/a0-1
	ENDM


ColBank	MACRO
	Ds.b	264*\1		; Space for x ColourBanks
	ENDM


_LoadCList	MACRO
	Move.l	#\1,$DFF080			; Our Copperlist
	Move.w	#$FFFF,$DFF088			; Copper Strobe - Activate CLIST #1
	ENDM


_LoadPlanes	MACRO
	Movem.l	d0-2/a0,-(sp)
	Move.l	\1,d0			; 1st Plane
	Lea	\2,a0			; CopperPlanePtr
	Move.w	#\3,d1			; Planes
	Move.l	#\4,d2			; Bitplane Modulo (gap between)
	Jsr	__LoadPlanes
	Movem.l	(sp)+,d0-2/a0
	ENDM


__LoadPlanes
	Subq.w	#1,d1
.1	Move.w	d0,6(a0)
	Swap	d0
	Move.w	d0,2(a0)
	Swap	d0
	Add.l	d2,d0
	Lea	8(a0),a0
	Dbra	d1,.1
	Rts



	; -----------------------
	; -- And Now Some Code --
	; -----------------------


	;
	;  PALETTE FUNCTIONS
	;


__LoadPalette24
;	Move.l	#$01060020,d2		; The Longword for BPLCON3  ** BorderBlank ON  **
	Move.l	#$01060000,d2		;                           ** Borderblank OFF **

.1	Move.l	d2,000(a1)		; BPLCON3 HiColour Write
	Bchg	#09,d2			; Write Colour Low next time
	Move.l	d2,132(a1)		; BPLCON3 LoColour Write
	Bchg	#09,d2			; Write Colour Hi next time
	Move.w	#$0180,d3		; COL00
	Moveq	#31,d4

.2	Move.l	(a0)+,d1
	Ror.l	#4,d1
	Ror.w	#4,d1
	Ror.l	#4,d1
	Ror.w	#4,d1
	Ror.l	#4,d1
	Ror.w	#4,d1
	Ror.b	#4,d1
	Rol.w	#4,d1
	Swap	d1
	Ror.w	#4,d1

	Move.w	d3,136(a1)
	Move.w	d1,138(a1)		; Low word
	Swap	d1
	Move.w	d3,004(a1)
	Move.w	d1,006(a1)		; High word
	Add.l	#4,a1
	Addq.w	#2,d3			; Next Colour Palette Entry
	Dbra	d4,.2

	Lea	136(a1),a1		; Align for next row of 32 colours
	Add.w	#$2000,d2		; Next ColourBank In BPLCON3
	Dbra	d0,.1			; Next ColourBank

	Rts




	;
	; 3D LIBRARY VERSION 2.0 (16.12.97)
	;


	; OFFSETS:
	; --------

TD_POINTS	= $00		; UWORD		# Points - 1
TD_FACES	= $02		; UWORD		# Faces - 1
TD_PT_TABLE	= $04		; APTR		Original Point-List
TD_PT_BUFFER	= $08		; APTR		Rotated Point-List
TD_PT_PERSP	= $0C		; APTR		3d->2d Persp. Point-List
TD_XPOS		= $10		; WORD
TD_YPOS		= $12		; WORD
TD_ZPOS		= $14		; WORD
TD_XROT		= $16		; UWORD		$000 - $1FF
TD_YROT		= $18		; UWORD
TD_ZROT		= $1A		; UWORD
TD_LINESEGS	= $1C		; APTR		Pointer To Line Segments
TD_FACELIST	= $20		; APTR		Pointer To FaceList
TD_GORAUD	= $24		; APTR		Pointer to goraud table
TD_TEXELS	= $28		; APTR		Pointer to texel coord list
TD_DEPTHSORT	= $2C		; APTR		Pointer to depth-sort array



	; For Planar Polygons

TD_FACE_POINTS	= $00		; UWORD		# LineSegs in Face - 1
TD_FACE_COL0	= $02		; UBYTE		Colour Of Face (in filled-mode)
TD_FACE_COL1	= $03		; UBYTE		<unimplemented>
TD_FACE_PT1	= $04		; UWORD		\  Clockwise ordering of 3
TD_FACE_PT2	= $06		; UWORD		 > points in the plane (used 4
TD_FACE_PT3	= $08		; UWORD		/  back-surface elimination)
TD_FACE_LINE	= $0A		; UWORD		First LineSeg, Next Lineseg, ..


	; For Chunky GoraudShaded Polygons

TD_FACE_GS_PT1	= $00



	; For Chunky Texturemapped Polygons

TD_FACE_TM_TXR	= $00		; APTR		Base of the texture to use
TD_FACE_TM_PT1	= $04		; UWORD		First point in face
TD_FACE_TM_TX1	= $06		; UWORD		First texel lookup in face



	; DATA SECTION:
	; -------------

DEF_SCRW	= 320		; Default width
DEF_SCRH	= 256		; Default height

TD_ScrWidth	Dc.w	DEF_SCRW
TD_ScrHeight	Dc.w	DEF_SCRH
TD_Scr_MidX	Dc.w	DEF_SCRW/2
TD_Scr_MidY	Dc.w	DEF_SCRH/2
TD_ScrByteWidth	Dc.w	DEF_SCRW/8	; For Planar Displays

TD_ClipX1	Dc.w	0
TD_ClipY1	Dc.w	0
TD_ClipX2	Dc.w	DEF_SCRW-1
TD_ClipY2	Dc.w	DEF_SCRH-1

TD_TxrSize	Dc.w	0		; Textuer Size: 0 - 32x32, 1 - 64x64, 2 - 128x128, 3 - 256,256
TD_PixSize	Dc.w	0		; Resolution  : 0 - 1x1 (or 2x2), 1 - 1x2, 2 - 2x1

TD_maxmin	Dc.l	0
TD_edgebuffer	Ds.w	4*256		; Max ScreenHeight = 255
TD_txrbuffer	Ds.l	4*256








	;
	; CHANGE SCREEN + CLIP REGIONS V1.0 (17.12.97)
	;				- Adjust the internal parameters for
	;				   screen size and clip region
	;
	; DEPENDENCIES:	'TD_Main.i'



	; ---------------------
	; -- FUNCTION MACROS --
	; ---------------------

_TD_ChangeScreenSize	MACRO
	Movem.l	d0-3,-(sp)
	Move.w	#\1,d0
	Move.w	#\2,d1
	Jsr	TD_ChangeScreenSize
	Movem.l	(sp)+,d0-3
	ENDM

_TD_ChangeClipRegion	MACRO
	Movem.l	d0-3,-(sp)
	Move.w	#\1,d0
	Move.w	#\2,d1
	Move.w	#\3,d2
	Move.w	#\4,d3
	Jsr	TD_ChangeClipRegion
	Movem.l	(sp)+,d0-3
	ENDM

_TD_ChangeTxlSize	MACRO
	Move.w	#\1,TD_TxrSize
	ENDM

_TD_ChangePixSize	MACRO
	Move.w	#\1,TD_PixSize
	ENDM




	; -------------------
	; -- FUNCTION CODE --
	; -------------------


	;
	; TD_ChangeScreenSize
	;
	; PARAMETERS:	d0.w - ScreenWidth
	;		d1.w - ScreenHeight
	;
	; TRASHED REGS:	d0-d3
	;


TD_ChangeScreenSize
	Move.w	d0,TD_ScrWidth
	Move.w	d1,TD_ScrHeight
	Lsr.w	#1,d0
	Lsr.w	#1,d1
	Move.w	d0,TD_Scr_MidX
	Move.w	d1,TD_Scr_MidY
	Lsr.w	#2,d0				; now /8
	Move.w	d0,TD_ScrByteWidth
	Rts



	;
	; TD_ChangeClipRegion
	;
	; PARAMETERS:	d0-3 - x1,y1, x2,y2
	;
	; TRASHED REGS:	None
	;

TD_ChangeClipRegion
	Move.w	d0,TD_ClipX1
	Move.w	d1,TD_ClipY1
	Move.w	d2,TD_ClipX2
	Move.w	d3,TD_ClipY2
	Rts



	;
	; TD_ChangeTxlMask	- Change the texture size
	;
	; PARAMETERS:	d0.w	- New Texture Size
	;			- 0 - 32x32, 1 - 64x64, 2 - 128x128, 3 - 256x256
	; TRASHED REGS:	None
	;

TD_ChangeTxlSize
	Move.w	d0,TD_TxrSize
	Rts




	;
	; TD_ChangePixSize	- Change screen's pixel sizes
	;
	; PARAMETERS:	d0.w	- 0 = square pixels (1x1, 2x2), 1 = 1x2, 2 = 2x1
	;

TD_ChangePixSize
	Move.w	d0,TD_PixSize
	Rts







	;
	; ROTATE POINTS V1.0 (16.12.97)
	;			- Rotate a set of points about axes
	;			  in 3 dimensions
	;
	; PARAMETERS:	A0.l - Object Structure
	;
	; DEPENDENCIES:	TD_Sine.i
	;		TD_Main.i
	;
	; TRASHED REGS:	None
	;


	; MACRO DEFINITIONS:
	; ------------------

_TD_RotAbs	MACRO
		Lea	\1,a0
		Move.w	#\2,d0	
		Move.w	#\3,d1
		Move.w	#\4,d2
		Jsr	TD_RotAbs
		ENDM

_TD_RotRel	MACRO
		Lea	\1,a0
		Move.w	#\2,d0	
		Move.w	#\3,d1
		Move.w	#\4,d2
		Jsr	TD_RotRel
		ENDM

_TD_MovAbs	MACRO
		Lea	\1,a0
		Move.w	#\2,d0	
		Move.w	#\3,d1
		Move.w	#\4,d2
		Jsr	TD_MovAbs
		ENDM

_TD_MovRel	MACRO
		Lea	\1,a0
		Move.w	#\2,d0	
		Move.w	#\3,d1
		Move.w	#\4,d2
		Jsr	TD_MovRel
		ENDM


_TD_Rot		MACRO
		Lea	\1,a0
		Jsr	TD_Rot
		ENDM



	; CODE TO DO IT:
	; --------------

TD_RotRel
	Add.w	TD_XROT(a0),d0
	And.w	#$01FF,d0
	Move.w	d0,TD_XROT(a0)
	Add.w	TD_YROT(a0),d1
	And.w	#$01FF,d1
	Move.w	d1,TD_YROT(a0)
	Add.w	TD_ZROT(a0),d2
	And.w	#$01FF,d2
	Move.w	d2,TD_ZROT(a0)
	Rts

TD_RotAbs
	And.w	#$01FF,d0
	Move.w	d0,TD_XROT(a0)
	And.w	#$01FF,d1
	Move.w	d1,TD_YROT(a0)
	And.w	#$01FF,d2
	Move.w	d2,TD_ZROT(a0)
	Rts


TD_MovRel
	Add.w	d0,TD_XPOS(a0)
	Add.w	d1,TD_YPOS(a0)
	Add.w	d2,TD_ZPOS(a0)
	Rts

TD_MovAbs
	Move.w	d0,TD_XPOS(a0)
	Move.w	d1,TD_YPOS(a0)
	Move.w	d2,TD_ZPOS(a0)
	Rts




TD_Rot	Movem.l	d0-7/a1-4,-(sp)

	Lea	TD_Sine,a1		; Sine Table
	Lea	TD_Cosine,a2		; Cosine Tble

	Move.l	TD_PT_TABLE(a0),a3	; Source Point Table
	Move.l	TD_PT_BUFFER(a0),a4	; Dest Rotated Points

	Move.w	TD_POINTS(a0),d7	; # Points to rotate - 1

.rotlp					; ZXY Rotation
	;-- Z Rotation --

	Move.w	TD_ZROT(a0),d0
	Move.w	0(a2,d0.w*2),d1		; Cos(ZAngle)
	Move.w	0(a1,d0.w*2),d0		; Sin(ZAngle)

	Move.w	(a3)+,d2		; D2.w - X
	Asl.w	#4,d2
	Move.w	(a3)+,d3		; D3.w - Y
	Asl.w	#4,d3
	Move.w	d3,d5
	Move.w	d2,d4

	Muls	d1,d2			; D2.l - 4096.X.Cos(ZAngle)
	Muls	d0,d5			; D5.l - 4096.Y.Sin(ZAngle)

	Sub.l	d5,d2		; D2.l - 4096.X' = 4096.[X.Cos(ZA) - Y.Sin(ZA)]
	Asr.l	#8,d2		; D2.w - 256.X'

	Muls	d0,d4			; D4.l - 4096.X.Sin(ZAngle)
	Muls	d1,d3			; D3.l - 4096.Y.Cos(ZAngle)

	Add.l	d4,d3		; D3.l - 4096.Y' = 4096.[X.Sin(ZA) + Y.Cos(ZA)]
	Asr.l	#8,d3		; D3.w - 16.Y'

	;-- Y Rotation --

	Move.w	TD_YROT(a0),d0
	Move.w	0(a2,d0.w*2),d1		; Cos(YAngle)
	Move.w	0(a1,d0.w*2),d0		; Sin(YAngle)

	Move.w	(a3)+,d4
	Asl.w	#4,d4			; D4.w - 16.Z
	Move.w	d4,d6
	Move.w	d2,d5

	Muls	d1,d4			; D4.l - 4096.Z .Cos(YAngle)
	Muls	d0,d5			; D5.l - 4096.X'.Sin(YAngle)

	Sub.l	d5,d4		; D4.l - 4096.[Z.Cos(YA) - X'.Sin(YA)]
	Asr.l	#8,d4		; D4.w - 16.Z'

	Muls	d0,d6			; D6.l - 4096.Z .Sin(YAngle)
	Muls	d1,d2			; D2.l - 4096.X'.Cos(YAngle)

	Add.l	d6,d2		; D2.l - 4096.[Z.Sin(YA) + X'.Cos(YA)]
	Asr.l	#8,d2		; D2.w - 16.X''

	Move.w	d2,(a4)+		; X'' -> Rotated_Point-Buffer

	;-- X Rotation --

	Move.w	TD_XROT(a0),d0
	Move.w	0(a2,d0.w*2),d1
	Move.w	0(a1,d0.w*2),d0

	Move.w	d3,d2			; D3.w=D2.w - 16.Y'
	Move.w	d4,d5			; D4.w=d5.w - 16.Z'

	Muls	d1,d3			; D3.l - 4096.Y'.Cos(XAngle)
	Muls	d0,d5			; D5.l - 4096.Z'.Sin(XAngle)

	Sub.l	d5,d3		; D3.l - 4096.[Y'.Cos(XA) - Z'.Sin(XA)]
	Asr.l	#8,d3		; D3.w - 16.Y''

	Move.w	d3,(a4)+		; Y'' -> Rotated_Point-Buffer

	Muls	d0,d2			; D2.l - 4096.Y'.Sin(XAngle)
	Muls	d1,d4			; D4.l - 4096.Z'.Cos(XAngle)
		
	Add.l	d2,d4		; D3.l - 4096.[Y'.Sin(XA) + Z'.Cos(XA)]
	Asr.l	#8,d4		; D3.w - 16.Z''

	Asr.l	#4,d4
	Move.w	d4,(a4)+		; Z'' -> Rotated_Point-Buffer

	;-- Done Rotations --

	Dbra	d7,.rotlp			; And Loop It For All Points

	Movem.l	(sp)+,d0-7/a1-4


	; ----------------------------------
	; -- Calculate Perspective Points --	; ** Actually no perspective now ;) **
	; ----------------------------------

	Movem.l	d0-4/a0-2,-(sp)
	Move.w	TD_POINTS(a0),d3
	Move.l	TD_PT_PERSP(a0),a1
	Move.l	TD_PT_BUFFER(a0),a2
.1	Movem.w	(a2)+,d0-2

	Move.w	TD_XPOS(a0),d4
	Add.w	d4,d0
	Move.w	TD_YPOS(a0),d4
	Add.w	d4,d1

	Add.w	TD_Scr_MidX,d0		; Centre X Coord
	Move.w	d0,(a1)+
	Add.w	TD_Scr_MidY,d1		; Centre Y Coord
	Move.w	d1,(a1)+
.endl	Dbra	d3,.1

	Movem.l	(sp)+,d0-4/a0-2
	Rts					; -> RETURN <-



	;
	; ROTATE POINTS V1.0 (16.12.97)
	;			- Rotate a set of points about axes
	;			  in 3 dimensions
	;
	; PARAMETERS:	A0.l - Object Structure
	;
	; DEPENDENCIES:	TD_Sine.i
	;		TD_Main.i
	;
	; TRASHED REGS:	None
	;

_TD_Rot2	MACRO
		Lea	\1,a0
		Jsr	TD_Rot2
		ENDM



TD_Rot2	Movem.l	d0-7/a1-4,-(sp)

	Lea	TD_Sine,a1		; Sine Table
	Lea	TD_Cosine,a2		; Cosine Tble

	Move.l	TD_PT_TABLE(a0),a3	; Source Point Table
	Move.l	TD_PT_BUFFER(a0),a4	; Dest Rotated Points

	Move.w	TD_POINTS(a0),d7	; # Points to rotate - 1

.rotlp					; ZXY Rotation
	;-- Z Rotation --

	Move.w	TD_ZROT(a0),d0
	Move.w	0(a2,d0.w*2),d1		; Cos(ZAngle)
	Move.w	0(a1,d0.w*2),d0		; Sin(ZAngle)

	Move.w	(a3)+,d2		; D2.w - X
	Asl.w	#4,d2
	Move.w	(a3)+,d3		; D3.w - Y
	Asl.w	#4,d3
	Move.w	d3,d5
	Move.w	d2,d4

	Muls	d1,d2			; D2.l - 4096.X.Cos(ZAngle)
	Muls	d0,d5			; D5.l - 4096.Y.Sin(ZAngle)

	Sub.l	d5,d2		; D2.l - 4096.X' = 4096.[X.Cos(ZA) - Y.Sin(ZA)]
	Asr.l	#8,d2		; D2.w - 256.X'

	Muls	d0,d4			; D4.l - 4096.X.Sin(ZAngle)
	Muls	d1,d3			; D3.l - 4096.Y.Cos(ZAngle)

	Add.l	d4,d3		; D3.l - 4096.Y' = 4096.[X.Sin(ZA) + Y.Cos(ZA)]
	Asr.l	#8,d3		; D3.w - 16.Y'

	;-- Y Rotation --

	Move.w	TD_YROT(a0),d0
	Move.w	0(a2,d0.w*2),d1		; Cos(YAngle)
	Move.w	0(a1,d0.w*2),d0		; Sin(YAngle)

	Move.w	(a3)+,d4
	Asl.w	#4,d4			; D4.w - 16.Z
	Move.w	d4,d6
	Move.w	d2,d5

	Muls	d1,d4			; D4.l - 4096.Z .Cos(YAngle)
	Muls	d0,d5			; D5.l - 4096.X'.Sin(YAngle)

	Sub.l	d5,d4		; D4.l - 4096.[Z.Cos(YA) - X'.Sin(YA)]
	Asr.l	#8,d4		; D4.w - 16.Z'

	Muls	d0,d6			; D6.l - 4096.Z .Sin(YAngle)
	Muls	d1,d2			; D2.l - 4096.X'.Cos(YAngle)

	Add.l	d6,d2		; D2.l - 4096.[Z.Sin(YA) + X'.Cos(YA)]
	Asr.l	#8,d2		; D2.w - 16.X''

	Move.w	d2,(a4)+		; X'' -> Rotated_Point-Buffer

	;-- X Rotation --

	Move.w	TD_XROT(a0),d0
	Move.w	0(a2,d0.w*2),d1
	Move.w	0(a1,d0.w*2),d0

	Move.w	d3,d2			; D3.w=D2.w - 16.Y'
	Move.w	d4,d5			; D4.w=d5.w - 16.Z'

	Muls	d1,d3			; D3.l - 4096.Y'.Cos(XAngle)
	Muls	d0,d5			; D5.l - 4096.Z'.Sin(XAngle)

	Sub.l	d5,d3		; D3.l - 4096.[Y'.Cos(XA) - Z'.Sin(XA)]
	Asr.l	#8,d3		; D3.w - 16.Y''

	Move.w	d3,(a4)+		; Y'' -> Rotated_Point-Buffer

	Muls	d0,d2			; D2.l - 4096.Y'.Sin(XAngle)
	Muls	d1,d4			; D4.l - 4096.Z'.Cos(XAngle)
		
	Add.l	d2,d4		; D3.l - 4096.[Y'.Sin(XA) + Z'.Cos(XA)]
	Asr.l	#8,d4		; D3.w - 16.Z''

	Asr.l	#4,d4
	Move.w	d4,(a4)+		; Z'' -> Rotated_Point-Buffer

	;-- Done Rotations --

	Dbra	d7,.rotlp			; And Loop It For All Points

	Movem.l	(sp)+,d0-7/a1-4


	; ----------------------------------
	; -- Calculate Perspective Points --
	; ----------------------------------

	Movem.l	d0-4/a0-2,-(sp)
	Move.w	TD_POINTS(a0),d3
	Move.l	TD_PT_PERSP(a0),a1
	Move.l	TD_PT_BUFFER(a0),a2
.1	Movem.w	(a2)+,d0-2

	Move.w	TD_XPOS(a0),d4
	Asl.w	#4,d4
	Add.w	d4,d0
	Ext.l	d0
	Asl.l	#4,d0

	Move.w	TD_YPOS(a0),d4
	Asl.w	#4,d4
	Add.w	d4,d1
	Ext.l	d1
	Asl.l	#4,d1

	Add.w	TD_ZPOS(a0),d2
	Add.w	#256,d2				; Mystery Add Factor (!)
	Cmp.w	#50,d2				; Check for safe Z values
	Ble.s	.emerg				;  -> Close to Zero !!

	Divs	d2,d0
	Add.w	TD_Scr_MidX,d0		; Centre X Coord
	Move.w	d0,(a1)+
	Divs	d2,d1
	Add.w	TD_Scr_MidY,d1		; Centre Y Coord
	Move.w	d1,(a1)+
.endl	Dbra	d3,.1

	Movem.l	(sp)+,d0-4/a0-2
	Rts					; -> RETURN <-


.emerg	Move.w	#0,(a1)+			; Emergency Error (Close to DivZero)
	Move.w	#0,(a1)+
	Bra.s	.endl




	;
	; TD_InsertSort - Perform depth-sorting on an array
	;
	;
	; PARAMETERS:	d0.w - Number of elements to process
	;		a0.l - Array of values to sort
	;
	; NOTES:	The array contains (value.w, depth.w) pairs. Sorting is done
	;		on the 'depth' key, and is from largest depth to smallest.
	;		Depth is in the range -32768..32767
	;


TD_InsertSort

.3	Move.w	#$7FFF,d2			; d2.w - MaxVal
	Move.w	d0,d1				; Start Of Scan
.2	Cmp.w	2(a0,d1.w*4),d2
	Ble.s	.1
	Move.w	d1,d3				; New Min -> Save Position
	Move.l	0(a0,d1.w*4),d2			;         -> New Min Value
.1	Dbra	d1,.2
	Move.l	0(a0,d0.w*4),0(a0,d3.w*4)
	Move.l	d2,0(a0,d0.w*4)			; Put next smallest Z-val at END of array!
	Dbra	d0,.3
	Rts



	;
	; TEXTUREMAPPING CODE V1.2 (07.04.98)
	;
	;
	; NOTES:	This code is really very ugly. Hopefully I'll do a rewrite soon,
	;		but for now this is it!! Damn, I need some more sleep ;)
	;		As always, it's really badly optimised. Oh well, I tried... ;)
	;
	;		060 sore-points are noted. I can't see a neat way of getting around
	;		these yet, so they are staying. At least the 2 Divs.l per scanline
	;		were replaced by Divs (lose a bit of resolution, but works OK!!)
	;
	;		Finally tracked down the Z-sorting bug in both this and the goraud
	;		engine! :)  I feel better now!
	;
	; TO DO:	Hopefully fixed the weird bug where objects were not back-surface
	;		eliminated properly (it was a stupid mixup in which registers were
	;		used as aprameters for the TD_ChkNorm function).
	;
	;		Also found a bug in the TD_ChkNorm function itself. Had the wrong
	;		offsets for reading the points out of the face structure. Now fixed.
	;		Mystery back-surface problems gone forever!!! :)
	;
	;		Also, don't add all the bloody faces in to the sort. Even insertion
	;		sort is not incredibly fast for > 20 faces, so I should be back-surface
	;		eliminating _before_ inserting them into the array, eliminating ~1/2
	;		of the faces right there (= big speed increase!)
	;



	; --+---------------+--
	; --| TD_Ck_TmapObj |--
	; --+---------------+--

TD_Ck_TmapObj

	; A0.l - Object Structure
	; A1.l - Chunky Buffer

	Movem.l	d0/a2-3,-(sp)
	Move.w	TD_FACES(a0),d0		; # of faces to draw
	Move.l	TD_FACELIST(a0),a3	; Address of FaceList
.tmplp	Move.l	(a3)+,a2		; Address of face
	Movem.l	d0/a0-3,-(sp)
	Bsr.s	TD_ChkNorm			; Do we need to draw it?
	Bne.s	.skipdraw		;  NUP -> Skip the rest
	Bsr.s	TD_Mapper
.skipdraw
	Movem.l	(sp)+,d0/a0-3
	Dbra	d0,.tmplp

	Movem.l	(sp)+,d0/a2-3
	Rts





	; --+-------------------------+--
	; --| TD_Ck_DepthSort_TmapObj |--
	; --+-------------------------+--

TD_Ck_DepthSort_TmapObj

	; A0.l - Object Structure
	; A1.l - Chunky Buffer

	Movem.l	d0-7/a0-6,-(sp)


	;-- UPDATE DEPTHSORTARRAY --
	Move.l	a5,-(sp)
	Move.w	TD_FACES(a0),d0			; # Faces-1 to process
	Move.l	TD_FACELIST(a0),a3		; Ptr to faces
	Move.l	TD_DEPTHSORT(a0),a4		; Ptr to DS-Array
	Move.l	TD_PT_BUFFER(a0),a5		; Ptr to 3D Rotated Pts
.flp	Move.l	0(a3,d0.w*4),a2			; Current Face
	Lea	4(a2),a2
	Move.w	d0,(a4)+		; Face #
	;----------------------
	Moveq	#0,d2
	Move.w	d2,d3
.zlp	Move.w	(a2),d1				; Point Offset
	Blt.s	.zdone
	Addq.w	#1,d3
	Lea	4(a2),a2			; Next Point
	Mulu	#6,d1
	Add.w	4(a5,d1),d2			; Add to total
	Bra.s	.zlp
.zdone	Ext.l	d2
	Divs	d3,d2				; D2.w = Middle Z Coord
	;----------------------
	Move.w	d2,(a4)+		; Z Coord (minimum for face)
	Dbra	d0,.flp
	Move.l	(sp)+,a5


	;-- Depth-Sort the FaceList --
	Move.l	a0,-(sp)
	Move.w	TD_FACES(a0),d0			; # Faces-1 to process
	Move.l	TD_DEPTHSORT(a0),a0		; Ptr to DS-Array
	Bsr	TD_InsertSort			; d0.w - entries, a0.l - array base
	Move.l	(sp)+,a0


	;-- DRAW FACES --
	Move.w	TD_FACES(a0),d0		; # of faces to draw
	Move.l	TD_FACELIST(a0),a3	; Address of FaceList
	Move.l	TD_DEPTHSORT(a0),a4	; -> DepthSortArray
.tmplp	Move.w	(a4),d1			; Face #
	Lea	4(a4),a4		; Next Face# In List
	Move.l	(a3,d1.w*4),a2		; Address of face
	Movem.l	d0/a0-4,-(sp)
	Bsr.s	TD_ChkNorm			; Do we need to draw it?
	Bne.s	.skipdraw		;  NUP -> Skip the rest
	Bsr.s	TD_Mapper
.skipdraw
	Movem.l	(sp)+,d0/a0-4
	Dbra	d0,.tmplp


	Movem.l	(sp)+,d0-7/a0-6
	Rts







	; --+----------------------------+--
	; --| Check Face's Normal Vector |--
	; --+----------------------------+--

TD_ChkNorm

	; CHECK NORMAL OF A FACE V1.0 (16.01.97)
	;		- This version for tmapped polys
	;
	;
	; PARAMETERS:	a0.l	- Object Base Address
	;		a2.l	- Face Structure
	;
	; RETURNS:	d0.w	- 0 = Invisible, 1 = Visible
	;
	; NOTES:	Points order should be clockwise, or the values
	;		 returned will be opposite to what you expect!!
	;

	Movem.l	d1-5/a3,-(sp)

	Move.l	TD_PT_PERSP(a0),a3	; A3.l - 2D Points List
	Move.w	4(a2),d1
	Move.w	0(a3,d1.w*4),d0		; X1
	Move.w	2(a3,d1.w*4),d1		; Y1
	Move.w	8(a2),d3
	Move.w	0(a3,d3.w*4),d2		; X2
	Move.w	2(a3,d3.w*4),d3		; Y2
	Move.w	12(a2),d5
	Move.w	0(a3,d5.w*4),d4		; X3
	Move.w	2(a3,d5.w*4),d5		; Y3
	;-- NOW CHECK THE NORMAL --
	Sub.w	d0,d4		; d4.w = (x3-x1)
	Sub.w	d1,d3		; d3.w = (y2-y1)
	Sub.w	d0,d2		; d2.w = (x2-x1)
	Sub.w	d1,d5		; d5.w = (y3-y1)
	Muls	d4,d3		; (x3-x1)*(y2-y1)
	Muls	d2,d5		; (x2-x1)*(y3-y1)
	Sub.l	d5,d3		; c =  [(x3-x1)*(y2-y1)] - [(x2-x1)*(y3-y1)]
	Ble.s	.noset		; < 0 so can't be seen

.set	Movem.l	(sp)+,d1-5/a3
	Moveq	#1,d0
	Rts
.noset	Movem.l	(sp)+,d1-5/a3
	Moveq	#0,d0
	Rts





	; --+---------------------+--
	; --| Texturemap One Face |--
	; --+---------------------+--

TD_Mapper

	; A0.l - Object Structure
	; A1.l - Chunky Buffer
	; A2.l - Face Structure Pointer




	;-- Draw line to edge-buffer --

	Movem.l	d0-7/a0-6,-(sp)

	Lea	TD_FACE_TM_PT1(a2),a3		; Start of point/texel pairs
	Move.l	TD_PT_PERSP(a0),a4
	Move.l	TD_TEXELS(a0),a5

	Moveq	#0,d0
	Move.w	TD_ScrHeight,d0
	Subq.w	#1,d0
	Swap	d0				; d0.l = [ ScrHeight-1.w | 0.w ]
	Move.l	d0,TD_maxmin
;	Move.l	#(200<<16),TD_maxmin



.linelp	Move.w	(a3)+,d0		; pt_1
	Move.w	(a3)+,d1		; tx_1
	Move.w	0(a5,d1.w*4),d4		; u1
	Move.w	2(a5,d1.w*4),d5		; v1
	Move.w	2(a4,d0.w*4),d1		; y1
	Move.w	0(a4,d0.w*4),d0		; x1


	Move.w	0(a3),d2		; pt_2
	Bmi.s	.drawit			; GOT A '-1' (END)
	Move.w	2(a3),d3		; tx_2
	Move.w	0(a5,d3.w*4),d6		; u2
	Move.w	2(a5,d3.w*4),d7		; v2
	Move.w	2(a4,d2.w*4),d3		; y2
	Move.w	0(a4,d2.w*4),d2		; x2

	Bsr	.DrawLine		; Draw to edge buffer
	Bra.s	.linelp

	;-- Now draw it properly --

.drawit

	Lea	TD_edgebuffer,a3
	Move.l	TD_FACE_TM_TXR(a2),a4	; The texture map to use (64x64)
	Lea	TD_txrbuffer,a5


	Move.l	TD_maxmin,d0
	Move.w	d0,d1
	Swap	d0
	Sub.w	d0,d1
	Lea	0(a3,d0.w*4),a3		; A3.l - Start of edges coords
	Lsl.w	#4,d0
	Lea	0(a5,d0.w),a5		; A5.l - Start of tmap coords [left x.y | right x.y]
	Lsr.w	#4,d0
	Mulu	TD_ScrWidth,d0
	Lea	0(a1,d0.l),a1		; A1.l - Start of screen to draw
	Move.w	d1,d0			; D0.w - # of lines to draw

	Subq	#1,d0
	Bmi.s	.end			; DON'T DRAW IF NEGATIVE!!

	

	; -- Check For Texture Size --
	Move.w	TD_TxrSize,d7
	Bne.s	.3f
	Move.w	#$1F1F,d7		; 32x32 texture
	Bra.s	.drawlp
.3f	Cmp.w	#$01,d7
	Bne.s	.7f
	Move.w	#$3F3F,d7		; 64x64
	Bra.s	.drawlp
.7f	Cmp.w	#$02,d7
	Bne.s	.ff
	Move.w	#$7F7F,d7		; 128x128
	Bra.s	.drawlp
.ff	Move.w	#$FFFF,d7		; 256x256



	; --+-- SCANLINE LOOP --+--

.drawlp	Movem.w	(a3)+,d1-2		; d1.w - Start x pixel
	Sub.w	d1,d2			; d2.w - x delta
	Ble.s	.nodraw			;      - Was neg or zero, don't draw!!
	Movem.l	(a5)+,d3-6		; u1,v1, u2,v2 coords [24.8]
	Sub.l	d3,d5			; d5.l - u delta (total)
	Sub.l	d4,d6			; d6.l - v delta (total)

	Divs	d2,d5			; d5.l - [-.-.8.8] U delta
	Divs	d2,d6			; d6.l - [-.-.8.8] V Delta
	And.l	#$FFFF,d5		; * We lose some accuracy by not using Divs.l
	And.l	#$FFFF,d6		;   but 060 owners should thank me for it! ;)

	And.l	#$FFFF,d1
	Ror.l	#8,d3			; Now [8.-.-.8] as [frac.-.-.int]
	Ror.l	#8,d5			; Now [8.-.-.8] as [frac.-.-.int]
	Subq.w	#1,d2			; Compensate for Dbra's extra loop


	Movem.l	d0/d7/a1,-(sp)
	Lea	0(a1,d1.l),a1		; Add Start X to write offset

	Move.w	d7,d1			; d1.w - Texture Mask
	Moveq	#0,d7			; d7.l - Always Zero (used for Addx later!)
	Move.l	d7,d0			; d0.l - 0


	; --+-- INNER LOOP --+--

	; d0.w - * Texel Address Offset (calcuated)
	; d1.w -   Texture Mask
	; d2.w -   Loop Counter
	; d3.l -   U (x) [8.24]
	; d4.l -   V (y) [24.8]
	; d5.l -   U Delta [8.24]
	; d6.l -   V Delta [24.8]
	; d7.l -   0

	; a1.l - Chunky Buffer
	; a4.l - Texture Base


.inner	Move.w	d4,d0
	Add.l	d6,d4		;   V Delta Add
	Move.b	d3,d0
	Add.l	d5,d3		; \ U Delta Add
	Addx.l	d7,d3		; /
	And.w	d1,d0		; Mask the texture (may not be needed!!)
	Move.b	0(a4,d0.l),d0	; Texel
	Move.b	d0,(a1)+
	Dbra	d2,.inner
	;--+-- END INNER LOOP --+--

	Movem.l	(sp)+,d0/d7/a1
.nodraw	Add.w	TD_ScrWidth,a1
	Dbra	d0,.drawlp
	; --+-- END SCANLINE LOOP --+--

.end	Movem.l	(sp)+,d0-7/a0-6
	Rts




; --+---------------------+--
; --| Draw to Edge Buffer |--
; --+---------------------+--


.DrawLine

	; D0-3.w - x1,y1, x2,y2
	; D4-7.w - u1,v1, u2,v2

	Movem.l	a2-3,-(sp)


	Lea	TD_edgebuffer+2,a2
	Lea	TD_txrbuffer+8,a3


	; --+-- MaxMin Y --+--

	Move.l	d4,-(sp)
	Move.l	TD_maxmin,d4

	Swap	d4
	Cmp.w	d1,d4
	Ble.s	.nmin
	Move.w	d1,d4
.nmin	Swap	d4
	Cmp.w	d3,d4
	Bge.s	.nmax
	Move.w	d3,d4
.nmax
	Move.l	d4,TD_maxmin
	Move.l	(sp)+,d4

	; --+---------------+--

	Cmp.w	d1,d3
	Beq.s	.nodrw
	Bgt.s	.noswap

	Exg.w	d1,d3
	Exg.w	d0,d2
	Exg.w	d4,d6
	Exg.w	d5,d7

	Lea	-2(a2),a2		; Left column of each
	Lea	-8(a3),a3		;  of the edge buffers
.noswap

	;-- Y Delta --
	Sub.w	d1,d3			; D3.w - # of scanlines (Y)
	Ext.l	d1
	Lea	0(a2,d1.l*4),a2		; Start addr for x  possie  (2x word)
	Lsl.l	#4,d1
	Lea	0(a3,d1.l),a3		; Start addr for uv possies (4x long)

	Ext.l	d0
	Ext.l	d4
	Ext.l	d5

	Ext.l	d3


	;-- X Delta --
	Sub.w	d0,d2
	Ext.l	d2
	Lsl.l	#8,d2
	Divs.l	d3,d2			; d2.l - (24.8) x delta			** 060!! **

	Ror.l	#1,d2		; Gives better accuracy ( add 1/2 * delta to start value )
	Rol.l	#8,d0
	Add.l	d2,d0
	Ror.l	#8,d0
	Ror.l	#7,d2		; d2.l (8.24)  [dec|int]	(was #8,d2)


	;-- U Delta --
	Sub.w	d4,d6
	Ext.l	d6
	Lsl.l	#8,d4
	Lsl.l	#8,d6
	Divs.l	d3,d6			; d6.l - (24.8) u delta			** 060!! **

	Asr.l	#1,d6		; Gives better accuracy ( add 1/2 * delta to start value )
	Add.l	d6,d4
	Asl.l	#1,d6


	;-- V Delta --
	Sub.w	d5,d7
	Ext.l	d7
	Lsl.l	#8,d5
	Lsl.l	#8,d7
	Divs.l	d3,d7			; d7.l - (24.8) v delta			** 060!! **

	Asr.l	#1,d7
	Add.l	d7,d5
	Asl.l	#1,d7

	; ------------------------
	; -- Write To EdgeBufer --
	; ------------------------

	Moveq	#0,d1			; Clear it for Addx usage!

	Subq	#1,d3
	Beq.s	.lastadd

.lp	Move.w	d0,(a2)			; x pos (16.0)
	Move.l	d4,00(a3)		; u pos (24.8)
	Move.l	d5,04(a3)		; v pos (24.8)

	Add.l	d2,d0			; Add the x delta
	Addx.l	d1,d0
	Add.l	d6,d4			; Add u delta
	Add.l	d7,d5			; Add v delta


	Lea	04(a2),a2
	Lea	16(a3),a3
	Dbra	d3,.lp

.lastadd
	Asr.l	#1,d2
	Asr.l	#1,d6
	Asr.l	#1,d7

	Sub.l	d2,d0
	Subx.l	d1,d0
	Sub.l	d6,d4
	Sub.l	d7,d5

	Move.w	d0,(a2)
	Move.l	d4,00(a3)
	Move.l	d5,04(a3)


.nodrw	Movem.l	(sp)+,a2-3
	Rts






	;
	; SINE TABLE V1.0 (16.12.97)
	;			- 1024 Entries + cosine extra
	;			- Sin(Angle)*1024
	;
	; PARAMETERS:	None
	;
	; DEPENDENCIES: None
	;
	; TRASHED REGS:	None
	;

TD_Sine
	Dc.w	$0000,$0003,$0006,$0009,$000C,$000F,$0012,$0015
	Dc.w	$0019,$001C,$001F,$0022,$0025,$0028,$002B,$002E
	Dc.w	$0031,$0035,$0038,$003B,$003E,$0041,$0044,$0047
	Dc.w	$004A,$004D,$0050,$0053,$0056,$0059,$005C,$005F

	Dc.w	$0061,$0064,$0067,$006A,$006D,$0070,$0073,$0075
	Dc.w	$0078,$007B,$007E,$0080,$0083,$0086,$0088,$008B
	Dc.w	$008E,$0090,$0093,$0095,$0098,$009B,$009D,$009F
	Dc.w	$00A2,$00A4,$00A7,$00A9,$00AB,$00AE,$00B0,$00B2

	Dc.w	$00B5,$00B7,$00B9,$00BB,$00BD,$00BF,$00C1,$00C3
	Dc.w	$00C5,$00C7,$00C9,$00CB,$00CD,$00CF,$00D1,$00D3
	Dc.w	$00D4,$00D6,$00D8,$00D9,$00DB,$00DD,$00DE,$00E0
	Dc.w	$00E1,$00E3,$00E4,$00E6,$00E7,$00E8,$00EA,$00EB

	Dc.w	$00EC,$00ED,$00EE,$00EF,$00F1,$00F2,$00F3,$00F4
	Dc.w	$00F4,$00F5,$00F6,$00F7,$00F8,$00F9,$00F9,$00FA
	Dc.w	$00FB,$00FB,$00FC,$00FC,$00FD,$00FD,$00FE,$00FE
	Dc.w	$00FE,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF


TD_Cosine
	Dc.w	$0100,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF
	Dc.w	$00FE,$00FE,$00FE,$00FD,$00FD,$00FC,$00FC,$00FB
	Dc.w	$00FB,$00FA,$00F9,$00F9,$00F8,$00F7,$00F6,$00F5
	Dc.w	$00F4,$00F4,$00F3,$00F2,$00F1,$00EF,$00EE,$00ED

	Dc.w	$00EC,$00EB,$00EA,$00E8,$00E7,$00E6,$00E4,$00E3
	Dc.w	$00E1,$00E0,$00DE,$00DD,$00DB,$00D9,$00D8,$00D6
	Dc.w	$00D4,$00D3,$00D1,$00CF,$00CD,$00CB,$00C9,$00C7
	Dc.w	$00C5,$00C3,$00C1,$00BF,$00BD,$00BB,$00B9,$00B7

	Dc.w	$00B5,$00B2,$00B0,$00AE,$00AB,$00A9,$00A7,$00A4
	Dc.w	$00A2,$009F,$009D,$009B,$0098,$0095,$0093,$0090
	Dc.w	$008E,$008B,$0088,$0086,$0083,$0080,$007E,$007B
	Dc.w	$0078,$0075,$0073,$0070,$006D,$006A,$0067,$0064

	Dc.w	$0061,$005F,$005C,$0059,$0056,$0053,$0050,$004D
	Dc.w	$004A,$0047,$0044,$0041,$003E,$003B,$0038,$0035
	Dc.w	$0031,$002E,$002B,$0028,$0025,$0022,$001F,$001C
	Dc.w	$0019,$0015,$0012,$000F,$000C,$0009,$0006,$0003
	Dc.w	$0000,$FFFD,$FFFA,$FFF7,$FFF4,$FFF1,$FFEE,$FFEB


	Dc.w	$FFE7,$FFE4,$FFE1,$FFDE,$FFDB,$FFD8,$FFD5,$FFD2
	Dc.w	$FFCF,$FFCB,$FFC8,$FFC5,$FFC2,$FFBF,$FFBC,$FFB9
	Dc.w	$FFB6,$FFB3,$FFB0,$FFAD,$FFAA,$FFA7,$FFA4,$FFA1
	Dc.w	$FF9F,$FF9C,$FF99,$FF96,$FF93,$FF90,$FF8D,$FF8B

	Dc.w	$FF88,$FF85,$FF82,$FF80,$FF7D,$FF7A,$FF78,$FF75
	Dc.w	$FF72,$FF70,$FF6D,$FF6B,$FF68,$FF65,$FF63,$FF61
	Dc.w	$FF5E,$FF5C,$FF59,$FF57,$FF55,$FF52,$FF50,$FF4E
	Dc.w	$FF4B,$FF49,$FF47,$FF45,$FF43,$FF41,$FF3F,$FF3D

	Dc.w	$FF3B,$FF39,$FF37,$FF35,$FF33,$FF31,$FF2F,$FF2D
	Dc.w	$FF2C,$FF2A,$FF28,$FF27,$FF25,$FF23,$FF22,$FF20
	Dc.w	$FF1F,$FF1D,$FF1C,$FF1A,$FF19,$FF18,$FF16,$FF15
	Dc.w	$FF14,$FF13,$FF12,$FF11,$FF0F,$FF0E,$FF0D,$FF0C

	Dc.w	$FF0C,$FF0B,$FF0A,$FF09,$FF08,$FF07,$FF07,$FF06
	Dc.w	$FF05,$FF05,$FF04,$FF04,$FF03,$FF03,$FF02,$FF02
	Dc.w	$FF02,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01
	Dc.w	$FF00,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01


	Dc.w	$FF02,$FF02,$FF02,$FF03,$FF03,$FF04,$FF04,$FF05
	Dc.w	$FF05,$FF06,$FF07,$FF07,$FF08,$FF09,$FF0A,$FF0B
	Dc.w	$FF0C,$FF0C,$FF0D,$FF0E,$FF0F,$FF11,$FF12,$FF13
	Dc.w	$FF14,$FF15,$FF16,$FF18,$FF19,$FF1A,$FF1C,$FF1D

	Dc.w	$FF1F,$FF20,$FF22,$FF23,$FF25,$FF27,$FF28,$FF2A
	Dc.w	$FF2C,$FF2D,$FF2F,$FF31,$FF33,$FF35,$FF37,$FF39
	Dc.w	$FF3B,$FF3D,$FF3F,$FF41,$FF43,$FF45,$FF47,$FF49
	Dc.w	$FF4B,$FF4E,$FF50,$FF52,$FF55,$FF57,$FF59,$FF5C

	Dc.w	$FF5E,$FF61,$FF63,$FF65,$FF68,$FF6B,$FF6D,$FF70
	Dc.w	$FF72,$FF75,$FF78,$FF7A,$FF7D,$FF80,$FF82,$FF85
	Dc.w	$FF88,$FF8B,$FF8D,$FF90,$FF93,$FF96,$FF99,$FF9C
	Dc.w	$FF9F,$FFA1,$FFA4,$FFA7,$FFAA,$FFAD,$FFB0,$FFB3

	Dc.w	$FFB6,$FFB9,$FFBC,$FFBF,$FFC2,$FFC5,$FFC8,$FFCB
	Dc.w	$FFCF,$FFD2,$FFD5,$FFD8,$FFDB,$FFDE,$FFE1,$FFE4
	Dc.w	$FFE7,$FFEB,$FFEE,$FFF1,$FFF4,$FFF7,$FFFA,$FFFD



	Dc.w	$0000,$0003,$0006,$0009,$000C,$000F,$0012,$0015
	Dc.w	$0019,$001C,$001F,$0022,$0025,$0028,$002B,$002E
	Dc.w	$0031,$0035,$0038,$003B,$003E,$0041,$0044,$0047
	Dc.w	$004A,$004D,$0050,$0053,$0056,$0059,$005C,$005F

	Dc.w	$0061,$0064,$0067,$006A,$006D,$0070,$0073,$0075
	Dc.w	$0078,$007B,$007E,$0080,$0083,$0086,$0088,$008B
	Dc.w	$008E,$0090,$0093,$0095,$0098,$009B,$009D,$009F
	Dc.w	$00A2,$00A4,$00A7,$00A9,$00AB,$00AE,$00B0,$00B2

	Dc.w	$00B5,$00B7,$00B9,$00BB,$00BD,$00BF,$00C1,$00C3
	Dc.w	$00C5,$00C7,$00C9,$00CB,$00CD,$00CF,$00D1,$00D3
	Dc.w	$00D4,$00D6,$00D8,$00D9,$00DB,$00DD,$00DE,$00E0
	Dc.w	$00E1,$00E3,$00E4,$00E6,$00E7,$00E8,$00EA,$00EB

	Dc.w	$00EC,$00ED,$00EE,$00EF,$00F1,$00F2,$00F3,$00F4
	Dc.w	$00F4,$00F5,$00F6,$00F7,$00F8,$00F9,$00F9,$00FA
	Dc.w	$00FB,$00FB,$00FC,$00FC,$00FD,$00FD,$00FE,$00FE
	Dc.w	$00FE,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF




	;
	; LINE CLIPPING + DRAWING ROUTINE V1.1 (09.02.98)
	;			- Clips coordinates to within defined
	;			   boundaries and draws the line
	;
	; PARAMETERS:	D0-D3.w	- X1,Y1, X2,Y2 Coords
	;		A0.l	- Address of Line-Drawing Routine
	;		A1.l	- Bitplane Base Address
	;		A5.l	- $DFF000	** For Planar Lines
	;		A6.l	- GraphicsBase  ** For Planar Lines
	;
	; TRASHED REGS:	d0-3
	;
	; NOTES:	Not Publicly Accessible!!
 

TD_ClipNDraw

	Movem.l	d4-6,-(sp)
	Moveq	#0,d6

	;--------------------
	;-- Check Vertical --
	;--------------------

	Cmp.w	d1,d3
	Bge.s	.1
	Exg.w	d0,d2			; D1 < D3
	Exg.w	d1,d3
	Bchg	#0,d6

.1	Cmp.w	TD_ClipY1,d3
	Blt.s	.nodraw			; D3 < BottomClip -> No Draw
	Cmp.w	TD_ClipY2,d1
	Bgt.s	.nodraw			; D1 > TopClip -> No Draw

	;-- Check Top --
	Cmp.w	TD_ClipY1,d1
	Bge.s	.2			; Y1 OK

	;-- Clip Top --			; (dx/DX) = (dy/DY)
					; New x = X1 + (DX/DY)*dy
	Move.w	d0,d4
	Sub.w	d2,d4			; D4.w = DX
	Move.w	d1,d5
	Sub.w	TD_ClipY1,d5		; D5.w = dy
	Muls	d5,d4			; D4.l = DX.dy
	Move.w	d3,d5
	Sub.w	d1,d5			; D5.w = DY
	Divs	d5,d4			; D4.w = (DX/DY)*dy = dx
	Add.w	d4,d0			; New X Coord
	Move.w	TD_ClipY1,d1		; New Y Coord

	;-- Check Bottom --

.2	Cmp.w	TD_ClipY2,d3
	Ble.s	.3			; Y2 OK

	;-- Clip Bottom --		; New x1 = X1 + (DX/DY)*dy
	Move.w	d0,d4
	Sub.w	d2,d4			; D4.w = DY
	Move.w	d3,d5
	Sub.w	TD_ClipY2,d5
	Muls	d5,d4
	Move.w	d3,d5
	Sub.w	d1,d5
	Divs	d5,d4
	Add.w	d4,d2
	Move.w	TD_ClipY2,d3


	;----------------------
	;-- Check Horizontal --
	;----------------------

.3	Cmp.w	d0,d2
	Bge.s	.4
	Exg.w	d0,d2
	Exg.w	d1,d3
	Bchg	#0,d6

.4	Cmp.w	TD_ClipX1,d2
	Blt.s	.nodraw			; X2 < LeftClip -> No Draw
	Cmp.w	TD_ClipX2,d0
	Bgt.s	.nodraw			; X0 > RightClip -> NoDraw

	;-- Check Left --
	Cmp.w	TD_ClipX1,d0
	Bge.s	.5			; X1 OK

	;-- Clip Left --		; New Y1 = Y1 + (DY/DX)*dx
	Move.w	d1,d4
	Sub.w	d3,d4			; D4.w = DY
	Move.w	d0,d5
	Sub.w	TD_ClipX1,d5		; D5.w = dx
	Muls	d5,d4			; D4.l = DY.dx
	Move.w	d2,d5
	Sub.w	d0,d5			; D5.w = DX
	Divs	d5,d4
	Add.w	d4,d1			; D1 = New Y Coord
	Move.w	TD_ClipX1,d0		; D0 = New X coord
	
.5	;-- Check Right --
	Cmp.w	TD_ClipX2,d2
	Ble.s	.6			; X2 OK

	;-- Clip Right --
	Move.w	d1,d4
	Sub.w	d3,d4
	Move.w	d2,d5
	Sub.w	TD_ClipX2,d5
	Muls	d5,d4
	Move.w	d2,d5
	Sub.w	d0,d5
	Divs	d5,d4
	Add.w	d4,d3
	Move.w	TD_ClipX2,d2

	;-- Clipping Finished --
.6	Tst.w	d6
	Beq.s	.7
	Exg.w	d0,d2
	Exg.w	d1,d3
.7	Jsr	(a0)			; Go ahead and draw it!

.nodraw	Movem.l	(sp)+,d4-6
	Rts





ClearPlanes
	Lea	Planes,a0
	Move.w	#320*200*2/8-1,d0
.0	Clr.l	(a0)+
	Clr.l	(a0)+
	Dbra	d0,.0
	Rts




	; ***************************************************************
	; ***                                                         ***
	; ***  EFFECT #1: HIDDEN-LINE LOGO                            ***
	; ***                                                         ***
	; ***************************************************************


	;
	; Usage:
	;
	;   * Just call LINE_INIT as part of the precalculation phase
	;
	;   * Call LINE_SHOW to actually display the effect
	;
	;   * Call LINE_END preferably at the end of the demo
	;
	;   * Call LINE_VBL as part of your VBLANK interrupt code (assuming that
	;     you have a vblank interrupt going, otherwise just call it everytime
	;     in the main loop). I have added the VBlank interrupt setup code
	;     at the start of LINE_SHOW, and remove the interrupt after the effect
	;     is finished. You may want to replace this if you hack the INTENA
	;     registers directly!!
	;
	;
	; Notes:
	;
	;   * I've made some comments that I think deserve attention. They start with '** '
	;
	;   * A major space-waster is the sine-table found in 'TDLIB/TD_Sine.i'. It
	;     probably uses about 2.5K of RAM, but should crunch fairly well.
	;
	;   * DMA is assumed to be at least COPEN | BPLEN | DMAEN  ($8380)
	;


line_SCR_WIDTH	= 320
line_SCR_HEIGHT	= 100
line_SCR_WH	= line_SCR_WIDTH*line_SCR_HEIGHT

SPHERE_POINTS	= 512				; ** Change this to alter sphere density **



	; ********************************************************
	; **                                                    **
	; **  LINE_INIT - Call as part of precalculation phase  **
	; **                                                    **
	; ********************************************************

	section	'Code1',CODE


LINE_INIT
	; --+----------------------+--
	; --| PRECALCULATION STUFF |--
	; --+----------------------+--

	; -- Precalc Radial Points Of Sphere-Object --
	Lea	pnts,a0
	Lea	TD_Sine,a1
	Move.w	#SPHERE_POINTS-1,d3
	Moveq	#0,d0
	Move.w	d0,d1
	Move.w	d0,d2

	Move.l	d0,d4
	Move.l	d0,d5
	Move.l	d0,d6

.lp	Move.w	d0,(a0)+
	Move.w	d1,(a0)+
	Move.w	d2,(a0)+

	Add.w	#256-43,d4
	Add.w	#512+27,d5
	Add.w	#256+512+87,d6

	And.w	#$01FF,d4
	And.w	#$01FF,d5
	And.w	#$01FF,d6

	Move.w	0(a1,d4.w*2),d0		; +/- 1024
	Move.w	0(a1,d5.w*2),d1
	Move.w	0(a1,d6.w*2),d2
	Asr.w	#2,d0			; +/- 256
	Asr.w	#2,d1
	Asr.w	#2,d2

	Dbra	d3,.lp


	; -- Precalc Edge-Draw Table --
	Lea	lines,a0
	Moveq	#1,d1
	Move.w	#SPHERE_POINTS-2,d0
.edt	Move.l	d1,(a0)+
	Addq.w	#1,d1
	Dbra	d0,.edt
	Move.l	#-1,(a0)+

	Rts





	; ********************************************************
	; **                                                    **
	; **  LINE_SHOW - Call this to display the effect       **
	; **                                                    **
	; ********************************************************

LINE_SHOW

	; -- ADD VBLANK INTERRUPT --
	Moveq	#5,d0
	Lea	line_ints,a1
	Move.l	4.w,a6
	Jsr	-168(a6)		; _LVOAddIntServer


	_LoadPalette24	Palette,CLIST_Palette,2
	_LoadPlanes	line_scr_p,CLIST_Planes,8,40*200
	_WaitVBL
	_LoadCList	CLIST
	Lea	$DFF000,a5

	_TD_ChangeScreenSize	line_SCR_WIDTH, line_SCR_HEIGHT
	_TD_ChangeClipRegion	1,1, line_SCR_WIDTH-2,line_SCR_HEIGHT-2



	; ---------------
	; -- MAIN LOOP --
	; ---------------

.lp	; -- DRAW LOGO TO SCREEN --
	Lea	Chunky,a0
	Lea	Logo,a1
	Move.w	#line_SCR_WH/8-1,d0
.logo	Move.l	(a1)+,(a0)+
	Move.l	(a1)+,(a0)+
	Dbra	d0,.logo


	; -- DRAW THE GLOWING SPHERE --
	Move.w	Sphere_x,d0
	Move.w	Sphere_y,d1
	Moveq	#0,d2
	Lea	Sphere,a0
	Jsr	TD_MovAbs

	_TD_Rot		Sphere

	Lea	Sphere,a0
	Lea	Chunky,a1
	Bsr	DrawWire



	; -----------------------------
	; -- LensFlares! yeahhhhh!!! --
	; -----------------------------


	Move.w	Sphere_x,d2
	Move.w	Sphere_y,d3
	Neg.w	d2
	Neg.w	d3
	Lsl.w	#2,d2
	Lsl.w	#2,d3

	; -- First LensFlare --
	Move.w	d2,d0
	Move.w	d3,d1
	Add.w	#line_SCR_WIDTH/2,d0
	Add.w	#line_SCR_HEIGHT/2,d1
	Lea	Flare3,a0
	Lea	Chunky,a1
	Bsr	DrawBob32

	; -- Second LensFlare --
	Asr.w	#1,d2
	Asr.w	#1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Add.w	#line_SCR_WIDTH/2,d0
	Add.w	#line_SCR_HEIGHT/2,d1
	Lea	Flare5,a0
	Lea	Chunky,a1
	Bsr	DrawBob32

	; -- Third LensFlare --
	Asr.w	#1,d2
	Asr.w	#1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Add.w	#line_SCR_WIDTH/2,d0
	Add.w	#line_SCR_HEIGHT/2,d1
	Lea	Flare1,a0
	Lea	Chunky,a1
	Bsr	DrawBob32

	; -- Fourth LensFlare --
	Asr.w	#1,d2
	Asr.w	#1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Add.w	#line_SCR_WIDTH/2,d0
	Add.w	#line_SCR_HEIGHT/2,d1
	Lea	Flare4,a0
	Lea	Chunky,a1
	Bsr	DrawBob32

	; -- Fifth LensFlare --
	Asr.w	#1,d2
	Asr.w	#1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Add.w	#line_SCR_WIDTH/2,d0
	Add.w	#line_SCR_HEIGHT/2,d1
	Lea	Flare2,a0
	Lea	Chunky,a1
	Bsr	DrawBob32





	; -- BLUR THE SCREEN --
	Jsr	Smooth


	; -- C2P STUFF --
	Lea	Chunky,a0			; Chunky Buffer
	Move.l	line_scr_l,a1			; Planar Buffer
	Move.l	#line_SCR_WH,d0			; Size of C2P
	Jsr	_c2p_020


	; -- DOUBLEBUFFER --
	_WaitVBL
	_LoadPlanes	line_scr_l, CLIST_Planes, 8, 40*200
	Move.l	line_scr_l,d0
	Move.l	line_scr_p,line_scr_l
	Move.l	d0,line_scr_p



	; -- EXIT CHECK	--
	Cmp.w	#L_FRAMES,l_Timer		; Will exit after L_FRAMES refreshes
	Bge.s	.end				;  has occurred

	; -- LEFT MOUSE BUTTON PRESSED? --
	Btst	#6,$BFE001			; ** Just change this to whatever you use
	Bne.s	.lp				;    to check for end-of-effect (check a
						;    VBL-updated counter, or something like
						;    that)
	; ------------------
	; -- END MAINLOOP --
	; ------------------



.end	; -- CLEAR DISPLAY --
	_LoadCLIST	CLIST_EMPTY
	_WaitVBL
	Jsr	ClearPlanes

	; -- REMOVE VBLANK INTERRUPT --
	Moveq	#5,d0
	Lea	line_ints,a1
	Move.l	4.w,a6
	Jsr	-174(a6)		; _LVORemIntServer


	Rts




	; ********************************************************
	; **                                                    **
	; **  LINE_VBL - The Vertical-Blank Interrupt Code      **
	; **                                                    **
	; ********************************************************

LINE_VBL
	Movem.l	d2-7/a2-6,-(sp)

	; -- Update the Sphere's coordinates --

	_TD_RotRel	Sphere, 1,0,1	; Perform 'logical' rotation on sphere
					; (3d rotation not actually performed here)
	Move.w	line_angx,d0
	Move.w	line_angy,d1
	Addq.w	#1,d0
	Addq.w	#3,d1
	And.w	#$03FF,d0
	And.w	#$03FF,d1
	Move.w	d0,line_angx
	Move.w	d1,line_angy

	Lsr.w	#1,d0
	Lsr.w	#1,d1
	Lea	TD_Sine,a0		; Sine Table
	Lea	TD_Cosine,a1		; Cosine Table
	Move.w	0(a0,d0.w*2),d0
	Move.w	0(a1,d1.w*2),d1
	Asr.w	#1,d0
	Asr.w	#5,d1
	Move.w	d0,Sphere_x
	Move.w	d1,Sphere_y


	; -- ** TIMER ** --
	Add.w	#1,l_Timer

	Movem.l	(sp)+,d2-7/a2-6
	Moveq	#0,d0			; Required for VBlank interrupts thru OS!!

	Rts






	; *****************************
	; **                         **
	; **  S U B R O U T I N E S  **
	; **                         **
	; *****************************


	; ---------------
	; -- Smoothing --
	; ---------------

	; ** Limited to 64 colour chunky bitmaps (byte overflows otherwise!) **


Smooth	Movem.l	d0-7/a0-3,-(sp)

	; -- Vertical Blur Phase --
	Lea	Chunky,a0			; Pre  Y
	Lea	line_SCR_WIDTH(a0),a1		;      Y
	Lea	line_SCR_WIDTH(a1),a2		; Post Y
	Lea	line_SCR_WH(a1),a3		; Dest


	Move.l	#(line_SCR_WIDTH/4)*(line_SCR_HEIGHT-2)-1,d7
.vlp	Move.l	(a0)+,d0
	Move.l	(a1)+,d1
	Move.l	(a2)+,d2
	Lsl.l	#1,d1
	Add.l	d0,d2
	Add.l	d2,d1
	Lsr.l	#2,d1
	And.l	#$3F3F3F3F,d1
	Move.l	d1,(a3)+
	Dbra	d7,.vlp


	; -- Horizontal Blur Phase --
	Lea	Chunky+line_SCR_WIDTH+line_SCR_WH,a0		; Src  Y
	Lea	Chunky+line_SCR_WIDTH,a1			; Dest Y

	Move.l	#(line_SCR_WIDTH*(line_SCR_HEIGHT-2)/2)-1,d7
.hlp	Move.l	(a0),d0
	Move.l	d0,d1
	Move.l	d0,d2
	Lsl.l	#8,d1
	Lsr.l	#8,d2
	Lsl.l	#1,d0
	Add.l	d1,d2
	Add.l	d0,d2
	Lsr.l	#8,d2
	Lsr.l	#2,d2
	And.w	#$3F3F,d2
	Lea	2(a0),a0
	Move.w	d2,(a1)+
	Dbra	d7,.hlp

	Movem.l	(sp)+,d0-d7/a0-3
	Rts





	; --+----------------------------------+--
	; --|  SIMPLE CHUNKY-BOB DRAW ROUTINE  |--
	; --+----------------------------------+--

DrawBob32

	; Draws a chunky-mode bob (32x32pix) to chunky screen
	;
	; Parameters:	a0.l - Bob Base Address
	;		a1.l - Chunky Screen
	;		d0.w - X Position
	; 		d1.w - Y Position
	;
	; Notes: Clipping not fully implemented (won't trash mem tho!)
	;

	Movem.l	d0-4/a0-1,-(sp)

	Sub.w	#16,d0			; Make Them Centered
	Sub.w	#16,d1

	; -- CLIPPING --
	Tst.w	d0
	Blt.s	.nodr
	Tst.w	d1
	Blt.s	.nodr

	Cmp.w	#line_SCR_WIDTH-1-32,d0
	Bgt.s	.nodr
	Cmp.w	#line_SCR_HEIGHT-1-32,d1
	Bgt.s	.nodr

	; -- It's safe to draw now ;) --
	Mulu	#line_SCR_WIDTH,d1
	Lea	0(a1,d0.w),a1
	Lea	0(a1,d1.l),a1

	Moveq	#32-1,d0		;  Y Loop Counter
.0	Movem.l	(a0)+,d1-4
	Add.l	d1,(a1)+
	Add.l	d2,(a1)+
	Add.l	d3,(a1)+
	Add.l	d4,(a1)+

	Movem.l	(a0)+,d1-4
	Add.l	d1,(a1)+
	Add.l	d2,(a1)+
	Add.l	d3,(a1)+
	Add.l	d4,(a1)+

	Lea	line_SCR_WIDTH-32(a1),a1
	Dbra	d0,.0

.nodr	Movem.l	(sp)+,d0-4/a0-1
	Rts





	; --+----------------------------------+--
	; --|  SPECIAL WIREFRAME DRAW ROUTINE  |--
	; --+----------------------------------+--
	;
	;
	; PARAMETERS:	A0.l - Object Structure Base
	;		A1.l - Chunky Base Address
	;


DrawWire
	Movem.l	d0-5/a0-2,-(sp)
	Move.l	TD_PT_PERSP(a0),a2	; A2.l = Rotated -> 2D Point-List
	Move.l	TD_LINESEGS(a0),a0	; A0.l = LineSegs List
	Move.w	(a0)+,d4
	Move.w	(a0)+,d5		; Point Pair Read-Ahead
.1	Move.w	0(a2,d4.w*4),d0		; X1
	Move.w	2(a2,d4.w*4),d1		; Y1
	Move.w	0(a2,d5.w*4),d2		; X2
	Move.w	2(a2,d5.w*4),d3		; Y2
	; -- Draw Line --
	Move.l	a0,-(sp)
	Lea	DrawLine,a0		; Pointer to line-drawing code
	Jsr	TD_ClipNDraw		; Perform Edge-Clipping / Draw
	Move.l	(sp)+,a0
	; -- Next Point-Pair
	Move.w	(a0)+,d4
	Move.w	(a0)+,d5
	Bge.s	.1			; Not at end of line_seg-list (-1)
	Movem.l	(sp)+,d0-5/a0-2
	Rts





	; --+-----------------------------+--
	; --|  SPECIAL LINE-DRAW ROUTINE  |--
	; --+-----------------------------+--
	;
	;
	; PARAMETERS:	d0-3.w	- X1,Y1, X2,Y2
	;		a1.l	- Chunky Buffer
	;


DrawLine
	Movem.l	d0-7/a1-3,-(sp)

	Lea	.lkup1,a2
	Lea	Logo,a3

	Move.w	d2,d4
	Move.w	d3,d5
	Sub.w	d0,d4		; dx
	Bge.s	.nn1
	Neg.w	d4		; |dx|
.nn1	Sub.w	d1,d5		; dy
	Bge.s	.nn2
	Neg.w	d5		; |dy|
.nn2	Cmp.w	d4,d5
	Bgt.s	.ymaj		; |dy| > |dx| ?

	; -- X Major:  dx > dy --
	;
	; d4.w - number of X iterations
	;
	Moveq	#1,d7		; d7.w -  x delta (per loop)
	Move.l	#line_SCR_WIDTH,d6	; d6.w -  y delta (when add overflow)

	Sub.w	d0,d2
	Beq.s	.nodraw		; Don't Div 0!!
	Bge.s	.xn1
	Neg.l	d7		; d7.w -  -1.l
.xn1	Sub.w	d1,d3		; d3.w -  y delta
	Bge.s	.xn2
	Neg.l	d6		; d6.w -  -line_SCR_WIDTH.w
.xn2	Mulu	#line_SCR_WIDTH,d1
	Add.l	d1,a1
	Add.l	d1,a3
	Add.w	d0,a1		; a1.l -  start point
	Add.w	d0,a3

	Ext.l	d3
	Asl.l	#8,d3		; d3.l - [24.8] fixed point Y delta
	Divs	d4,d3
	Ext.l	d3		; (get rid of remainder part!!)
	Ror.l	#8,d3		; d3.l - [8.24] - [fract.int]

	Subq.w	#1,d4
	Moveq	#0,d5
	Move.l	d5,d0
	Move.l	d5,d1





.xlp	; -- Test Logo Point --
	Tst.b	(a3)
	Beq.s	.xlp2		; -> Start drawing the line
	;Bne.s	.xlp2		;    as soon as we get a (non) zero colour, start drawing line

	; -- Add Y Delta --	; but only upon x-flag carry!!
	Add.l	d3,d5
	Addx.l	d1,d5
	Tst.w	d5
	Beq.s	.nya
	Clr.w	d5
	Add.l	d6,a1		; Next/Prev vertical line
	Add.l	d6,a3
.nya	; -- Add X Delta --
	Add.l	d7,a1		; x delta ( +/- 1)
	Add.l	d7,a3
	Dbra	d4,.xlp

	Movem.l	(sp)+,d0-7/a1-3
	Rts




.xlp2	; -- Plot Pixel (additive intensity) --
	Move.b	(a1),d0
	Move.b	0(a2,d0.l),(a1)
	; -- Add Y Delta --	; but only upon x-flag carry!!
	Add.l	d3,d5
	Addx.l	d1,d5
	Tst.w	d5
	Beq.s	.noyadd
	Clr.w	d5
	Add.l	d6,a1		; Next/Prev vertical line
.noyadd	; -- Add X Delta --
	Add.l	d7,a1		; x delta ( +/- 1)
	Dbra	d4,.xlp2

.nodraw	Movem.l	(sp)+,d0-7/a1-3
	Rts






.ymaj	; -- Y Major:  dy > dx --
	;
	; d5.w - number of Y iterations
	;



	Moveq	#1,d7		; d7.w -  x delta (when add overflows)
	Move.l	#line_SCR_WIDTH,d6	; d6.w -  y delta (per loop)

	Sub.w	d1,d3
	Beq.s	.nodraw		; Don't Div 0!!
	Bge.s	.yn1
	Neg.l	d6		; d7.w -  -1.l
.yn1	Sub.w	d0,d2		; d2.w -  y delta
	Bge.s	.yn2
	Neg.l	d7		; d6.w -  -line_SCR_WIDTH.w
.yn2	Mulu	#line_SCR_WIDTH,d1
	Add.l	d1,a1
	Add.l	d1,a3
	Add.w	d0,a1		; a1.l -  start point
	Add.w	d0,a3


	Ext.l	d2
	Asl.l	#8,d2		; d2.l - [24.8] fixed point X delta
	Divs	d5,d2
	Ext.l	d2		; (get rid of remainder part!!)
	Ror.l	#8,d2		; d2.l - [8.24] - [fract.int]

	Subq.w	#1,d5
	Moveq	#0,d4
	Move.l	d4,d0
	Move.l	d4,d1




.ylp	; -- Test Logo Point --
	Tst.b	(a3)
	Beq.s	.ylp2		; -> Start drawing the line
	;Bne.s	.ylp2		;    as soon as we get a (non) zero colour, start drawing line

	; -- Add X Delta (carry) --
	Add.l	d2,d4
	Addx.l	d1,d4
	Tst.w	d4
	Beq.s	.nxa
	Clr.w	d4
	Add.l	d7,a1		; x delta ( +/- 1 )
	Add.l	d7,a3
.nxa	; -- Add Y Delta --
	Add.l	d6,a1		; y delta ( +/- line_SCR_WIDTH )
	Add.l	d6,a3
	Dbra	d5,.ylp

	Movem.l	(sp)+,d0-7/a1-3
	Rts



.ylp2	; -- Plot Pixel (additive intensity) --
	Move.b	(a1),d0
	Move.b	0(a2,d0.l),(a1)
	; -- Add X Delta --	; but only upon x-flag carry!!
	Add.l	d2,d4
	Addx.l	d1,d4
	Tst.w	d4
	Beq.s	.noxadd
	Clr.w	d4
	Add.l	d7,a1		; x delta ( +/- 1 )
.noxadd	; -- Add Y Delta --
	Add.l	d6,a1		; y delta ( +/- line_SCR_WIDTH )
	Dbra	d5,.ylp2



	Movem.l	(sp)+,d0-7/a1-3
	Rts





.lkup1	Dc.b	02,03,04,05,06,07,08,09,10,11,12,13,14,15
	Dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	Dc.b	31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31




	; --+---------------------------------------------------------------+--


	section	'DataMain',DATA


line_scr_l	Dc.l	Planes
line_scr_p	Dc.l	Planes+320*200

line_angx	Dc.w	0
line_angy	Dc.w	0

Sphere_x	Dc.w	0
Sphere_y	Dc.w	0

l_Timer	Dc.w	0


		; ** The Interrupt Structure **

line_ints	Dc.l	0,0			; PREV, NEXT
		Dc.b	2,0			; TYPE, PRIORITY
		Dc.l	line_intname		; NAME
		Dc.l	0,LINE_VBL		; DATA, CODE
line_intname	Dc.b	'Cruddy VBlank Interrupt',0
		cnop	0,4




Sphere		Dc.w	SPHERE_POINTS - 1, 0
		Dc.l	pnts, ptrot, ptpersp
		Dc.w	0,0,0, 0,0,0			; X,Y,Z, rX,rY,rZ
		Dc.l	lines
		Dc.l	0,0,0

		; -- 24-bit Palette, 64 colours --
Palette		dc.l	$00000000,$00020705,$00050e0a,$0007150f
		dc.l	$00091c14,$000c2319,$000e291e,$00103023
		dc.l	$00123728,$00153e2d,$00174532,$00205036
		dc.l	$002a5a3b,$0033653f,$003c6f43,$00457a47
		dc.l	$004f844c,$00588f50,$00619954,$006aa458
		dc.l	$0074ae5d,$007db961,$0086c365,$008fcc68
		dc.l	$0095d56b,$009cde6d,$00ade485,$00bde99e
		dc.l	$00ceefb6,$00def4ce,$00effae7,$00ffffff

		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff
		dc.l	$00ffffff,$00ffffff,$00ffffff,$00ffffff



		; -- The Logo Used For Ray Projection --
Logo		incbin	'Nuance.CNK'
		;incbin	'CantStop.CNK'		; ** 320x100x8 (chunky-mode graphic)


		; -- The 3 Different Lens-Flare 'bobs' --
Flare1		incbin	'Flare1.CNK'
Flare2		incbin	'Flare2.CNK'
Flare3		incbin	'Flare3.CNK'
Flare4		incbin	'Flare4.CNK'
Flare5		incbin	'Flare5.CNK'


	section	'planes',BSS_C
Planes		Ds.b	320*200*2		; MUST remain at this size always!! (C2P)


	section	'Data',BSS
pnts		Ds.w	3*SPHERE_POINTS
lines		Ds.w	2*(SPHERE_POINTS+1)	; '-1.l' terminated list of lines to draw
ptrot		Ds.w	3*SPHERE_POINTS
ptpersp		Ds.w	2*SPHERE_POINTS
Chunky		Ds.b	line_SCR_WH*2		; ** This is the chunky buffer **




	; --+------------+--
	; --| CopperList |--
	; --+------------+--

	section	'clist',DATA_C

CLIST
CLIST_Planes	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
		Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
		Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
		Dc.w	BPL6PTH,0,BPL6PTL,0,BPL7PTH,0,BPL7PTL,0

		Dc.w	BPLCON0,$0211,BPLCON1,0,BPLCON2,0
		Dc.w	DIWSTRT,$7A81,DIWSTOP,$2CC1,DDFSTRT,$38,DDFSTOP,$D0
		Dc.w	BPL1MOD,-8,BPL2MOD,-8

		Dc.w	FMODE,$0003


CLIST_Palette	ColBank	2			; 64 Colours

		Dc.w	$DE07,$FFFE,BPLCON0,$0201
		Dc.w	$FFFF,$FFFE


	; -- The empty copperlist used between effects --

CLIST_EMPTY	Dc.w	BPLCON0,$0200,BPLCON3,$0000,$180,BLANK_COLOUR
		Dc.w	$FFFF,$FFFE





	; ***************************************************************
	; ***                                                         ***
	; ***  EFFECT #2: BUMPMAPPED WIREFRAME                        ***
	; ***                                                         ***
	; ***************************************************************

	section	'code2',CODE


	; USAGE:
	;
	; * Call 'BUMP_INIT' as part of precalculation phase
	;
	; * Call 'BUMP_SHOW' to display the effect
	;
	; * Call 'BUMP_END' at the end of the demo
	;


bump_SCR_WIDTH	= 320
bump_SCR_HEIGHT	= 150
bump_SCR_WH	= bump_SCR_WIDTH*bump_SCR_HEIGHT

LS_WIDTH	= 512					; lightsource size
LS_HEIGHT	= bump_SCR_HEIGHT+64			;     "         "
LS_WH		= LS_WIDTH*LS_HEIGHT
LS_COLOURS	= 64
LS_MAGIC	= 600
LS_NOISE	= 7
LS_CX		= LS_WIDTH/2
LS_CY		= LS_HEIGHT/2

b_INTENS	= 42					; 'depth' of line drawing (0:63)




	; *********************************************
	; ***                                       ***
	; ***  BUMP_INIT - Call as part of precalc  ***
	; ***                                       ***
	; *********************************************

BUMP_INIT

	; --+------------------+--
	; --| PRECALC LIGHTMAP |--
	; --+------------------+--

	Lea	b_LightSource,a0
	Move.w	#LS_CX,d4
	Move.w	#LS_CY,d5
	Move.w	#LS_HEIGHT-1,d0		; d0.w - Y Count
.ylp	Move.w	#LS_WIDTH-1,d1		; d1.w - X Count
.xlp	Move.w	d1,d3
	Move.w	d0,d2
	Sub.w	d4,d3			; ( CX - x )
	Sub.w	d5,d2			; ( CY - y )
	Muls	d3,d3			; (CX-x)^2
	Muls	d2,d2			; (CY-y)^2
	Add.l	d3,d2			; (CX-X)^2 + (CY-y)^2	= r²
	Lsr.l	#1,d2			; Make light bigger!!	(was 2)

	Add.l	#LS_MAGIC,d2
	Move.l	#LS_MAGIC*LS_COLOURS-1,d3
	Divu.l	d2,d3
	Move.b	d3,(a0)+		; ~ 1/r²

	Dbra	d1,.xlp
	Dbra	d0,.ylp


Random	Lea	b_LightSource,a0

	Move.w	#LS_HEIGHT-1,d7		; d0.w - Y Count
.ylp	Move.w	#LS_WIDTH-1,d6		; d1.w - X Count
.xlp	Move.b	(a0),d2
	And.w	#$00FF,d2
	Moveq	#LS_NOISE,d0
	Bsr	Rnd
	Sub.w	#LS_NOISE/2,d1
	Add.w	d1,d2
	Bge.s	.nomi
	Moveq	#0,d2
.nomi	Cmp.w	#LS_COLOURS-1,d2
	Ble.s	.nopl
	Move.w	#LS_COLOURS-1,d2
.nopl	Move.b	d2,(a0)+
	Dbra	d6,.xlp
	Dbra	d7,.ylp


Smooth2	Move.w	#LS_WIDTH,d0
	Move.w	#LS_HEIGHT,d1
	Lea	b_LightSource,a0
	Lea	b_LightSource,a1
	Bsr	b_Smooth



	; --+-------------------------+--
	; --| CREATE BUMPY BACKGROUND |--
	; --+-------------------------+--

	Lea	b_Background,a0
	Move.w	#bump_SCR_WH-1,d7
.bumplp	Move.w	#37,d0
	Bsr	Rnd
	Move.b	d1,(a0)+
	Dbra	d7,.bumplp

	Move.w	#bump_SCR_WIDTH,d0
	Move.w	#bump_SCR_HEIGHT,d1
	Lea	b_Background,a0
	Lea	b_Background,a1
	Bsr	b_Smooth			; Smooth it
	Bsr	b_Smooth			; (twice!)  ;)


	; --+-----------------+--
	; --| Init Copperlist |--
	; --+-----------------+--

	_LoadPalette24	b_Palette, bump_CLIST_pal, 2		; Init Palette
	_LoadPlanes	b_Plane_P, bump_CLIST, 8, 40*200	; Init Bitplanes


	Rts




	; *********************************************
	; ***                                       ***
	; ***  BUMP_SHOW - Call to display effect   ***
	; ***                                       ***
	; *********************************************

BUMP_SHOW

	_TD_ChangeScreenSize	bump_SCR_WIDTH, bump_SCR_HEIGHT
	_TD_ChangeClipRegion	2,2, bump_SCR_WIDTH-3,bump_SCR_HEIGHT-3
	_TD_MovAbs		b_Object,0,0,200

	; --+-------------------+--
	; --| Add VBL Interrupt |--
	; --+-------------------+--

	Moveq	#5,d0
	Lea	b_VBLStruct,a1
	Move.l	4.w,a6
	Jsr	-168(a6)		; _LVOAddIntServer


	; --+-----------------+--
	; --| Show Copperlist |--
	; --+-----------------+--

	_WaitVBL

	Move.l	#bump_CLIST,$DFF080		; COP1LCH
	Move.w	#$FFF,$DFF088			; COPJMP1



	; --+-------------+--
	; --| Show Effect |--
	; --+-------------+--




.lp
	; -- Clear Chunky Buffer --
	Move.w	#bump_SCR_WH/8-1,d0
	Lea	b_Chunky,a0
.l1	Clr.l	(a0)+
	Clr.l	(a0)+
	Dbra	d0,.l1


	; -- Object Morph/Moving --
	Lea	TD_Sine,a0
	Move.w	b_ObjMorph,d0
	Move.w	0(a0,d0.w*2),d0
	Asr.w	#1,d0
	Add.w	#128,d0			; Range 0:255
	Moveq	#b_POINTS,d1
	Lea	pnts1,a0
	Lea	pnts2,a1
	Lea	b_pnts,a2
	Bsr	b_Morph

	Lea	TD_Sine,a0
	Move.w	b_ObjXA,d0
	Move.w	b_ObjYA,d1
	Move.w	b_ObjZA,d2
	Move.w	0(a0,d0.w*2),d0
	Move.w	0(a0,d1.w*2),d1
	Move.w	0(a0,d2.w*2),d2
	Asr.w	#1,d0
	Asr.w	#2,d1
;	Asr.w	#1,d2
	Add.w	#300,d2
	Lea	b_Object,a0
	Jsr	TD_MovAbs


	; -- Draw 3D Object --
	_TD_Rot2	b_Object

	Lea	b_Object,a0
	Lea	b_Chunky,a1
	Bsr	b_DrawWire


	; -- Smoothing --
	Move.w	#bump_SCR_WIDTH,d0
	Move.w	#bump_SCR_HEIGHT,d1
	Lea	b_Chunky,a0
	Lea	b_Chunky+bump_SCR_WH,a1
	Bsr	b_Smooth


	; -- BumpMapping --
	Bsr	b_BumpMap


	; -- Do C2P --
	Lea	b_Chunky+bump_SCR_WH,a0		; cnky
	Move.l	b_Plane_L,a1			; plnr
	Move.l	#bump_SCR_WH,d0			; sizeof c2p conversion
	Jsr	_c2p_020


	; -- DoubleBuffer --
	_LoadPlanes	b_Plane_L, bump_CLIST, 8, 40*200	; Init Bitplanes
	Move.l	b_Plane_P,d0
	Move.l	b_Plane_L,b_Plane_P
	Move.l	d0,b_Plane_L
	_WaitVBL


	; -- EXIT YET? --
	Cmp.w	#B_FRAMES,b_Timer
	Bge.s	.end

	; -- Test Exit Condition --
	Btst	#6,$BFE001			; ** Change this to your Exit test
	Bne.s	.lp


	; ------------------
	; -- END MAINLOOP --
	; ------------------


.end	; -- CLEAR DISPLAY --
	_LoadCLIST	CLIST_EMPTY
	_WaitVBL
	Jsr	ClearPlanes

	; -- Remove VBL Interrupt --
	Moveq	#5,d0
	Lea	b_VBLStruct,a1
	Move.l	4.w,a6
	Jsr	-174(a6)		; _LVORemIntServer


	Rts




	; ********************************
	; ***                          ***
	; ***  S U B R O U T I N E S   ***
	; ***                          ***
	; ********************************



b_BumpMap

	Movem.l	d0-7/a0-3,-(sp)


	; --------------------------
	; -- BUMPY BACKGROUND ADD --
	; --------------------------
	Lea	b_Background+bump_SCR_WIDTH,a0
	Lea	b_Chunky+bump_SCR_WIDTH,a1
	Move.w	#(bump_SCR_WIDTH*(bump_SCR_HEIGHT-2)/8)-1,d0
.bglp	Move.l	(a0)+,d1
	Move.l	(a0)+,d2
	Add.l	d1,(a1)+
	Add.l	d2,(a1)+
	Dbra	d0,.bglp
	; --------------------------



	Lea	b_Chunky+bump_SCR_WH,a0				; The bumpmap buffer (end)
	Lea	b_LightSource+((LS_CY+(bump_SCR_HEIGHT/2))*LS_WIDTH)+416,a1	; The light texture
	Lea	b_Chunky+bump_SCR_WH*2,a2			; Chunky Buffer (end)

	; ----------------------
	; -- LIGHTSOURCE MOVE --
	; ----------------------
	Move.w	b_XAng,d0
	Move.w	b_YAng,d1
	Lea	TD_Sine,a3
	Move.w	0(a3,d0.w*2),d0
	Move.w	0(a3,d1.w*2),d1
	Asr.w	#1,d0			; X coord (±128)
	Asr.w	#4,d1			; Y coord (±32)
	Ext.l	d1
	Lsl.l	#8,d1
	Lsl.l	#1,d1
	Add.l	d1,a1
	Add.w	d0,a1
	; -----------------------





	; -----------
	; -- LOOPS --
	; -----------

	Move.w	#bump_SCR_HEIGHT-2,d7
.lpy	Moveq	#0,d1
	Move.w	#bump_SCR_WIDTH-1,d6
.lpx	;-- UP/DOWN SHADE CALC. --
	Move.b	d1,d2	
	Sub.b	-bump_SCR_WIDTH(a0),d2
	Lsl.w	#8,d2
	;-- LEFT/RIGHT SHADE CALC. --
	Move.b	d1,d2
	Move.b	-(a0),d1
	Sub.b	d1,d2
	Lsl.w	#1,d2
	;-- WRITE TO CHUNKY --
	Move.b	0(a1,d2.w),-(a2)
	Lea	-1(a1),a1
	Dbra	d6,.lpx			; X Loop
	Lea	-192(a1),a1			; 320-512 [ MODULO ]
	Dbra	d7,.lpy			; Y Loop
	; -----------



	Movem.l	(sp)+,d0-7/a0-3
	Rts





	; --+-----------------------+--
	; --| UPDATE POLYGON COORDS |--
	; --+-----------------------+--

	; d0.w (0:255)	- Weighting of points 0 = obj1, 255 = obj2
	; d1.w		- Points to morph
	; a0.l		- Obj1 PointsList
	; a1.l		- Obj2 PointsList
	; a2.l		- PtsBuffer

b_Morph	Movem.l	d1-3/a0-2,-(sp)

	Mulu	#3,d1
	Subq	#1,d1	; d1.w - # iterations

.mlp	Move.w	(a0)+,d2
	Move.w	(a1)+,d3
	Sub.w	d2,d3
	Muls	d0,d3
	Asr.l	#8,d3
	Add.w	d2,d3
	Move.w	d3,(a2)+
	Dbra	d1,.mlp

	Movem.l	(sp)+,d1-3/a0-2

	Rts







b_DrawWire				; A0.l - Object Base, A1.l - Chunky Buffer

	Movem.l	d0-5/a0-2,-(sp)

	Move.l	TD_PT_PERSP(a0),a2	; A2.l = Rotated -> 2D Point-List
	Move.l	TD_LINESEGS(a0),a0	; A0.l = LineSegs List

	Move.w	(a0)+,d4
	Move.w	(a0)+,d5		; Point Pair Read-Ahead

.1	Move.w	0(a2,d4.w*4),d0		; X1
	Move.w	2(a2,d4.w*4),d1		; Y1
	Move.w	0(a2,d5.w*4),d2		; X2
	Move.w	2(a2,d5.w*4),d3		; Y2
	; -- Draw Line --
	Move.l	a0,-(sp)
	Lea	b_DrawLine,a0
	Jsr	TD_ClipNDraw		; Perform Edge-Clipping / Draw
	Move.l	(sp)+,a0
	; -- Next Point-Pair
	Move.w	(a0)+,d4
	Move.w	(a0)+,d5
	Bge.s	.1			; Not at end of line_seg-list (-1)

	Movem.l	(sp)+,d0-5/a0-2
	Rts






b_DrawLine				; D0-4.w - x1,y1, x2,y2, A1.l - Chunky Buffer

	Movem.l	d0-7/a1,-(sp)

	Move.w	d2,d4
	Move.w	d3,d5
	Sub.w	d0,d4		; dx
	Bge.s	.nn1
	Neg.w	d4		; |dx|
.nn1	Sub.w	d1,d5		; dy
	Bge.s	.nn2
	Neg.w	d5		; |dy|
.nn2	Cmp.w	d4,d5
	Bgt.s	.ymaj		; |dy| > |dx| ?



	; -- X Major:  dx > dy --
	;
	; d4.w - number of X iterations
	;

	Moveq	#1,d7			; d7.w -  x delta (per loop)
	Move.l	#bump_SCR_WIDTH,d6	; d6.w -  y delta (when add overflow)

	Sub.w	d0,d2
	Beq.s	.nodraw		; Don't Div 0!!
	Bge.s	.xn1
	Neg.l	d7		; d7.w -  -1.l
.xn1	Sub.w	d1,d3		; d3.w -  y delta
	Bge.s	.xn2
	Neg.l	d6		; d6.w -  -line_SCR_WIDTH.w
.xn2	Mulu	#bump_SCR_WIDTH,d1
	Add.l	d1,a1
	Add.l	d1,a3
	Add.w	d0,a1		; a1.l -  start point
	Add.w	d0,a3

	Ext.l	d3
	Asl.l	#8,d3		; d3.l - [24.8] fixed point Y delta
	Divs	d4,d3
	Ext.l	d3		; (get rid of remainder part!!)
	Ror.l	#8,d3		; d3.l - [8.24] - [fract.int]

	Subq.w	#1,d4
	Moveq	#0,d5
	Move.l	d5,d0
	Move.l	d5,d1

.xlp	; -- Plot Point --
	Move.b	#b_INTENS,(a1)

	; -- Add Y Delta --	; but only upon x-flag carry!!
	Add.l	d3,d5
	Addx.l	d1,d5
	Tst.w	d5
	Beq.s	.nya
	Clr.w	d5
	Add.l	d6,a1		; Next/Prev vertical line
.nya	; -- Add X Delta --
	Add.l	d7,a1		; x delta ( +/- 1)
	Add.l	d7,a3
	Dbra	d4,.xlp

.nodraw	Movem.l	(sp)+,d0-7/a1
	Rts



.ymaj	; -- Y Major:  dy > dx --
	;
	; d5.w - number of Y iterations
	;

	Moveq	#1,d7			; d7.w -  x delta (when add overflows)
	Move.l	#bump_SCR_WIDTH,d6	; d6.w -  y delta (per loop)

	Sub.w	d1,d3
	Beq.s	.nodraw		; Don't Div 0!!
	Bge.s	.yn1
	Neg.l	d6		; d7.w -  -1.l
.yn1	Sub.w	d0,d2		; d2.w -  y delta
	Bge.s	.yn2
	Neg.l	d7		; d6.w -  -line_SCR_WIDTH.w
.yn2	Mulu	#bump_SCR_WIDTH,d1
	Add.l	d1,a1
	Add.l	d1,a3
	Add.w	d0,a1		; a1.l -  start point
	Add.w	d0,a3


	Ext.l	d2
	Asl.l	#8,d2		; d2.l - [24.8] fixed point X delta
	Divs	d5,d2
	Ext.l	d2		; (get rid of remainder part!!)
	Ror.l	#8,d2		; d2.l - [8.24] - [fract.int]

	Subq.w	#1,d5
	Moveq	#0,d4
	Move.l	d4,d0
	Move.l	d4,d1

.ylp	; -- Plot Point --
	Move.b	#b_INTENS,(a1)

	; -- Add X Delta (carry) --
	Add.l	d2,d4
	Addx.l	d1,d4
	Tst.w	d4
	Beq.s	.nxa
	Clr.w	d4
	Add.l	d7,a1		; x delta ( +/- 1 )
.nxa	; -- Add Y Delta --
	Add.l	d6,a1		; y delta ( +/- line_SCR_WIDTH )
	Add.l	d6,a3
	Dbra	d5,.ylp

	Movem.l	(sp)+,d0-7/a1
	Rts






	; --+--------------------------------+--
	; --| General-Purpose Smoothing Code |--
	; --+--------------------------------+--

	; A0.l	- Source Buffer
	; A1.l	- Temp Buffer (Same size as source)
	; D0.w	- Screen Width
	; D1.w	- Screen Height


b_Smooth	; ** Limited to 64 colour chunky bitmaps (byte overflows otherwise!) **


	Movem.l	d0-7/a0-3,-(sp)



	; -- Vertical Blur Phase --

	Movem.l	d0-1/a0-1,-(sp)

	Move.l	a1,a3
	Move.l	a0,a1
	Add.w	d0,a1				;      Y
	Add.w	d0,a3				; Dest Y
	Lea	0(a1,d0.w),a2			; Post Y

	Move.w	d1,d7
	Subq.w	#2,d7
	Mulu	d0,d7
	Lsr.l	#2,d7
	Subq.l	#1,d7
	Swap	d7			; bump_SCR_WIDTH*(bump_SCR_HEIGHT-2)/4 - 1

.vlo	Swap	d7
.vli	Move.l	(a0)+,d0
	Move.l	(a1)+,d1
	Move.l	(a2)+,d2
	Lsl.l	#1,d1
	Add.l	d0,d2
	Add.l	d2,d1
	Lsr.l	#2,d1
	And.l	#$3F3F3F3F,d1
	Move.l	d1,(a3)+
	Dbra	d7,.vli
	Swap	d7
	Dbra	d7,.vlo

	Movem.l	(sp)+,d0-1/a0-1



	; -- Horizontal Blur Phase --

	Add.w	d0,a0
	Add.w	d0,a1

	Move.w	d1,d7
	Subq.w	#2,d7
	Mulu	d0,d7
	Lsr.l	#1,d7
	Subq.l	#1,d7		; (bump_SCR_WIDTH*(bump_SCR_HEIGHT-2)/2) - 1
	Swap	d7

.hlo	Swap	d7
.hli	Move.l	(a1),d0
	Move.l	d0,d1
	Move.l	d0,d2
	Lsl.l	#8,d1
	Lsr.l	#8,d2
	Lsl.l	#1,d0
	Add.l	d1,d2
	Add.l	d0,d2
	Lsr.l	#8,d2
	Lsr.l	#2,d2
	And.w	#$3F3F,d2
	Lea	2(a1),a1
	Move.w	d2,(a0)+
	Dbra	d7,.hli
	Swap	d7
	Dbra	d7,.hlo


	Movem.l	(sp)+,d0-d7/a0-3
	Rts





	;***********************************
	;***   Random Number Generator   ***
	;***   Borrowed Form Bullfrog!   ***
	;***********************************

	; D0 - Range (0 - x)
	; D1 - Returns Number (Long Word, But Only Grab Word!)

Rnd	Move.w	.seed(pc),d1
	Mulu	#9377,d1
	Add.w	#9439,d1
	Move.w	d1,.seed		; Store Value For Seed Next Time
	And.l	#$7FFF,d1		; Make Sure Positive Word

	Divu	d0,d1
	Swap	d1			; Make Remainder Low Word

	Rts

.seed	Dc.w	13			; Random Seed







	; ************************
	; ***                  ***
	; ***  Interrupt Code  ***
	; ***                  ***
	; ************************


b_VBLCode				; This should be executed every frame (50-60Hz)
	Movem.l	d2-7/a2-6,-(sp)


	; -- Rotate Object --
	_TD_RotRel	b_Object, 1,1,0		; X,Y,Z Rotation

	; -- Move Lightsource --
	Move.l	b_XAng,d0
	Add.l	#$00020003,d0
	And.l	#$01FF01FF,d0
	Move.l	d0,b_XAng


	; -- Morph Value Update
	Move.w	b_ObjMorph,d0
	Add.w	#3,d0
	And.w	#$01FF,d0
	Move.w	d0,b_ObjMorph

	; -- Move Object --
	Move.l	b_ObjXA,d0
	Move.w	b_ObjZA,d1
	Add.l	#$00010002,d0
	Add.w	#$0004,d1
	And.l	#$01FF01FF,d0
	And.w	#$01FF,d1
	Move.l	d0,b_ObjXA
	Move.w	d1,b_ObjZA

	; -- ** TIMER ** --
	Add.w	#1,b_Timer

	Movem.l	(sp)+,d2-7/a2-6
	Moveq	#0,d0
	Rts







	; *********************************
	; ***                           ***
	; ***  D A T A   S E C T I O N  ***
	; ***                           ***
	; *********************************


b_Plane_L	Dc.l	Planes			; Logical Buffer
b_Plane_P	Dc.l	Planes+320*200		; Physical Buffer

b_XAng		Dc.w	0
b_YAng		Dc.w	0

b_ObjXA		Dc.w	0
b_ObjYA		Dc.w	0
b_ObjZA		Dc.w	0
b_ObjMorph	Dc.w	0

b_Timer		Dc.w	0

b_Palette	dc.l	$00000028,$0008052f,$00100936,$00180e3c
		dc.l	$00201243,$0028174a,$00301b51,$00382058
		dc.l	$003f245e,$00472965,$004f2d6c,$00573273
		dc.l	$005f367a,$00673b80,$006f3f87,$00754485
		dc.l	$007a4982,$00804e80,$0086537d,$008b587b
		dc.l	$00915d78,$00976276,$009c6773,$00a26c71
		dc.l	$00a77572,$00ad7f73,$00b28875,$00b79176
		dc.l	$00bd9b77,$00c2a478,$00c7ad79,$00ccb67b
		dc.l	$00d2c07c,$00d7c97d,$00d8cb81,$00dacd86
		dc.l	$00dbce8a,$00dcd08e,$00ded293,$00dfd497
		dc.l	$00e0d69b,$00e2d7a0,$00e3d9a4,$00e4dba8
		dc.l	$00e6ddad,$00e7dfb1,$00e8e0b5,$00eae2ba
		dc.l	$00ebe4be,$00ece6c2,$00eee8c7,$00efe9cb
		dc.l	$00f0ebcf,$00f2edd4,$00f3efd8,$00f4f1dc
		dc.l	$00f6f2e1,$00f7f4e5,$00f8f6e9,$00faf8ee
		dc.l	$00fbfaf2,$00fcfbf6,$00fefdfb,$00ffffff


b_POINTS	= 12
b_FACES		= 0

b_Object	Dc.w	b_POINTS - 1,  b_FACES - 1
		Dc.l	b_pnts, b_ptrot, b_ptpersp
		Dc.w	0,0,0, 0,0,0
		Dc.l	.lineseg
		Dc.l	0,0,0,0


.lineseg	Dc.w	$0000,$0003,$0003,$0002,$0002,$0001,$0001,$0000,$0004,$0005
		Dc.w	$0004,$0007,$0007,$0006,$0006,$0005,$0004,$0003,$0000,$0007
		Dc.w	$0002,$0005,$0006,$0001,$0000,$0008,$0008,$0003,$0001,$0009
		Dc.w	$0009,$0002,$0000,$000A,$000A,$0001,$0002,$000B,$000B,$0003
		Dc.w	$0007,$0008,$0008,$0004,$0004,$000B,$000B,$0005,$0005,$0009
		Dc.w	$0009,$0006,$0006,$000A,$000A,$0007
		Dc.w	-1,-1

pnts1		Dc.w	$FFD8,$0028,$0014, $0028,$0028,$0014, $0028,$FFD8,$0014
		Dc.w	$FFD8,$FFD8,$0014, $FFD8,$FFD8,$FFEC, $0028,$FFD8,$FFEC
		Dc.w	$0028,$0028,$FFEC, $FFD8,$0028,$FFEC, $FF88,$0000,$0000
		Dc.w	$0078,$0000,$0000, $0000,$0078,$0000, $0000,$FF88,$0000

pnts2		Dc.w	$FFB0,$0050,$0014, $0050,$0050,$0014, $0050,$FFB0,$0014
		Dc.w	$FFB0,$FFB0,$0014, $FFB0,$FFB0,$FFEC, $0050,$FFB0,$FFEC
		Dc.w	$0050,$0050,$FFEC, $FFB0,$0050,$FFEC, $FFD8,$0000,$0000
		Dc.w	$0028,$0000,$0000, $0000,$0028,$0000, $0000,$FFD8,$0000



b_VBLStruct	Dc.l	0,0
		Dc.b	2,0
		Dc.l	b_VBLName
		Dc.l	0,b_VBLCode
b_VBLName	Dc.b	'BumpMap Effect VBL Interrupt',$00
		even



	section	'FastRAM',BSS

b_Chunky	Ds.b	bump_SCR_WH*2
b_LightSource	Ds.b	LS_WIDTH*LS_HEIGHT
b_Background	Ds.b	bump_SCR_WH		; 'bumpy' background

b_pnts		Ds.w	3*b_POINTS
b_ptrot		Ds.w	3*b_POINTS
b_ptpersp	Ds.w	2*b_POINTS



	section	'CopperList',DATA_C

bump_CLIST	Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
		Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
		Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
		Dc.w	BPL6PTH,0,BPL6PTL,0,BPL7PTH,0,BPL7PTL,0

		Dc.w	BPLCON0,$0210,BPLCON1,0,BPLCON2,0,BPLCON3,0
		Dc.w	DIWSTRT,$6181,DIWSTOP,$2CC1,DDFSTRT,$38,DDFSTOP,$A0
		Dc.w	BPL1MOD,0,BPL2MOD,0,FMODE,$0003

bump_CLIST_pal	ColBank	2				; 64 colours

		Dc.w	$F707,$FFFE,BPLCON0,$0200
		Dc.w	$FFFF,$FFFE






	; ***************************************************************
	; ***                                                         ***
	; ***  EFFECT #3: TEXTURED SCENE                              ***
	; ***                                                         ***
	; ***************************************************************


	; Usual stuff applies here:
	;
	; * Call SCENE_INIT as part of precalc
	;
	; * Call SCENE_SHOW to display the effect
	;
	; * Call SCENE_END after demo is finished (may not even need to call this ;))




	section	'Code3',CODE


scene_SCR_WIDTH		= 320
scene_SCR_HEIGHT	= 200
scene_SCR_WH		= scene_SCR_WIDTH*scene_SCR_HEIGHT




	; ********************
	; ***              ***
	; ***  SCENE_INIT  ***
	; ***              ***
	; ********************

SCENE_INIT

	; -- Precalculate Textures --


	; -- TEXTURE #1 --
	Lea	s_temp64,a0
	Move.w	#64*64-1,d7
.lp1	Moveq	#13,d0
	Jsr	Rnd
	Add.b	#16,d0
	Move.b	d1,(a0)+
	Dbra	d7,.lp1

	Lea	s_temp64,a0
	Move.l	a0,a1
	Moveq	#64,d0
	Move.w	d0,d1
	Jsr	b_Smooth
	Jsr	b_Smooth
	Lea	s_txr1,a1
	Bsr	s_Copy

	; -- TEXTURE #2 --
	Lea	s_temp64,a0
	Move.w	#64*64-1,d7
.lp2	Add.b	#4,(a0)+
	Dbra	d7,.lp2
	Lea	s_txr1+64,a1
	Bsr	s_Copy

	; -- TEXTURE #3 --
	Lea	s_temp64,a0
	Move.w	#64*64-1,d0
.lp3	Move.b	(a0),d1
	Add.b	#32+8,d1
	Move.b	d1,(a0)+
	Dbra	d0,.lp3

	Lea	s_txr1+128,a1
	Bsr	s_Copy

	; -- TEXTURE #4 --
	Lea	s_temp64,a0
	Move.w	#64*64-1,d7
.lp4	Sub.b	#8,(a0)+
	Dbra	d7,.lp4
	Lea	s_txr1+128+64,a1
	Bsr	s_Copy


	; -- BACKGROUND TEXTURE --
	Lea	s_Background,a0
	Move.w	#scene_SCR_WH-1,d7
.lp5	Move.w	#9,d0
	Jsr	Rnd
	Move.b	d1,(a0)+
	Dbra	d7,.lp5

	Lea	s_Background,a0
	Move.l	a0,a1
	Move.w	#scene_SCR_WIDTH,d0
	Move.w	#scene_SCR_HEIGHT,d1
	Jsr	b_Smooth

	Lea	s_Background,a0
	Move.l	a0,a1
	Move.w	#scene_SCR_WIDTH,d0
	Move.w	#scene_SCR_HEIGHT,d1
	Jsr	b_Smooth

	Lea	s_Background,a0
	Move.w	#scene_SCR_WH/8-1,d7
.lp6	Or.l	#$40404040,(a0)+
	Or.l	#$40404040,(a0)+
	Dbra	d7,.lp6



	; -- Setup CopperList
	_LoadPalette24	s_Palette, s_CLIST_Pal, 4
	_LoadPlanes	s_PlaneL, s_CLIST, 8, 40*200


	Rts



s_Copy	Lea	s_temp64,a0		; Fill in a1 as needed
	Moveq	#63,d0
.1	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Lea	256-64(a1),a1
	Dbra	d0,.1
	Rts




	; ********************
	; ***              ***
	; ***  SCENE_SHOW  ***
	; ***              ***
	; ********************

SCENE_SHOW

	; -- ADD VBL INTERRUPT --
	Moveq	#5,d0
	Lea	s_VBL_IntS,a1
	Move.l	4.w,a6
	Jsr	-168(a6)		; _LVOAddIntServer


	; -- OTHER INIT STUFF --
	_WaitVBL
	_LoadCList	s_CLIST


	_TD_ChangeScreenSize	scene_SCR_WIDTH, scene_SCR_HEIGHT
	_TD_ChangeClipRegion	1,1, scene_SCR_WIDTH-2,scene_SCR_HEIGHT-2
	_TD_ChangeTxlSize	1		; 64x64 textures


.lp	; -- Clear Screen --
	Move.w	#scene_SCR_WH/8-1,d0
	Sub.w	#scene_SCR_WIDTH/8,d0
	Lea	s_Background+scene_SCR_WIDTH,a0
	Lea	s_Chunky+scene_SCR_WIDTH,a1		; Workaround for weird bug!!
.cllp	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Dbra	d0,.cllp

	; -- Draw Scene --
	Bsr	s_DrawScene


	; -- C2P --
	Lea	s_Chunky,a0
	Move.l	s_PlaneL,a1
	Move.l	#scene_SCR_WH,d0
	Jsr	_c2p_020


	; -- DoubleBuffer --
	_WaitVBL
	_LoadPlanes	s_PlaneL, s_CLIST, 8, 40*200
	Move.l	s_PlaneL,d0
	Move.l	s_PlaneP,s_PlaneL
	Move.l	d0,s_PlaneP


	; -- END OF EFFECT? --
	Cmp.w	#S_FRAMES,s_Timer
	Bge.s	.end

	; -- EXIT? --
	Btst	#6,$BFE001
	Bne.s	.lp



	; ------------------
	; -- END MAINLOOP --
	; ------------------



.end	; -- CLEAR DISPLAY --
	;_LoadCLIST	CLIST_EMPTY
	;_WaitVBL
	Jsr	ClearPlanes

	; -- REMOVE VBL INTERRUPT --
	Moveq	#5,d0
	Lea	s_VBL_IntS,a1
	Move.l	4.w,a6
	Jsr	-174(a6)			; _LVORemIntServer


	Rts




	; ********************************
	; ***                          ***
	; ***  S U B R O U T I N E S   ***
	; ***                          ***
	; ********************************


s_DrawScene

	; -- ROTATE STAR SHAPE --

	_TD_Rot2	s_Star


	; -- FILL DEPTH-SORT ARRAY --
	Lea	s_Star_ptr,a0
	Lea	s_Star_dsarr,a1
	Moveq	#5-1,d0
	Moveq	#0,d1
.dsl	Move.w	4(a0),d2		; Z Coord
	Move.w	d1,(a1)+		; Point Number
	Move.w	d2,(a1)+
	Lea	6(a0),a0
	Addq.w	#1,d1
	Dbra	d0,.dsl

	; -- DEPTH-SORT COORDS --
	Lea	s_Star_dsarr,a0
	Moveq	#5-1,d0
	Jsr	TD_InsertSort

	; -- DRAW OBJECTS --
	Lea	s_Star_dsarr,a0
	Lea	s_Objects,a1
	Lea	s_Star_ptr,a2		; Star's rotated coords


	Moveq	#4,d7
.lp	Move.w	(a0),d4			; Object Number
	Lea	4(a0),a0		; (next object)

	Movem.l	a0-1,-(sp)
	Move.l	0(a1,d4.w*4),a0		; The Object
	Mulu	#6,d4
	Move.w	0(a2,d4.w),d0		; X Pos
	Move.w	2(a2,d4.w),d1		; Y Pos
	Move.w	4(a2,d4.w),d2		; Z Pos
	Add.w	#350,d2		; Mystery Add Factor ;)
	Jsr	TD_MovAbs		; Move this object to correct spot
	Jsr	TD_Rot2			; And rotate its points
	Lea	s_Chunky,a1
	Jsr	TD_Ck_DepthSort_TmapObj	; And Draw it
	Movem.l	(sp)+,a0-1

	Dbra	d7,.lp

	Rts




	; ***************************************
	; ***                                 ***
	; ***  V B L A N K   I N T   C O D E  ***
	; ***                                 ***
	; ***************************************


s_VBL_IntCode
	Movem.l	d2-7/a2-6,-(sp)


	Lea	TD_Sine,a0

	Move.w	s_S_xyz,d0
	Move.w	s_S_xyz+2,d1
	Move.w	s_S_xyz+4,d2

	Addq.w	#2,d0
	Addq.w	#1,d1
	Addq.w	#3,d2

	And.w	#$01FF,d0
	And.w	#$01FF,d1
	And.w	#$01FF,d2

	Move.w	d0,s_S_xyz
	Move.w	d1,s_S_xyz+2
	Move.w	d2,s_S_xyz+4

	Move.w	0(a0,d0.w*2),d0
	Asr.w	#3,d0



	Moveq.w	#0,d2

	Lea	s_Star,a0		; The Star
	Jsr	TD_RotAbs


	Move.w	s_S_xyz+4,d2

	And.w	#$01FF,d1
	Lea	s_S_obj1,a0		; Tri 1
	Jsr	TD_RotAbs
	Add.w	#128,d1
	And.w	#$01FF,d1
	Lea	s_S_obj2,a0		; Tri2
	Jsr	TD_RotAbs
	Add.w	#128,d1
	And.w	#$01FF,d1
	Lea	s_S_obj3,a0		; Tri 3
	Jsr	TD_RotAbs
	Add.w	#128,d1
	And.w	#$01FF,d1
	Lea	s_S_obj4,a0		; Tri 4
	Jsr	TD_RotAbs


	Moveq.w	#0,d2

	Neg.w	d1
	And.w	#$01FF,d1
	Lea	s_N_obj,a0		; N obj
	Jsr	TD_RotAbs


	; -- ** TIMER ** --
	Add.w	#1,s_Timer

	Movem.l	(sp)+,d2-7/a2-6
	Moveq	#0,d0
	Rts




	; *********************************
	; ***                           ***
	; ***  D A T A   S E C T I O N  ***
	; ***                           ***
	; *********************************


s_PlaneL	Dc.l	Planes
s_PlaneP	Dc.l	Planes+320*200

s_Timer		Dc.w	0

s_N_xyz		Dc.w	0,0,0
s_S_xyz		Dc.w	0,0,0


s_Palette

		dc.l	$00000000,$00061117,$000c1a22,$0013232c
		dc.l	$00192c37,$00203541,$00263e4c,$002d4756
		dc.l	$00335061,$0039586c,$00406176,$00466a81
		dc.l	$004d738b,$00537c96,$005a85a0,$00608eab
		dc.l	$006894b0,$00709ab6,$0077a0bb,$007fa6c0
		dc.l	$0087acc5,$008fb2cb,$0097b8d0,$009fbed5
		dc.l	$00a6c4da,$00aecae0,$00b6d0e5,$00bed6ea
		dc.l	$00c6dcef,$00cde2f5,$00d5e8fa,$00ddeeff

		dc.l	$00000000,$00080807,$0011100e,$00191815
		dc.l	$0022201c,$002a2823,$00332f2a,$003b3731
		dc.l	$00443f38,$004c473f,$00554f46,$005d574c
		dc.l	$00655f53,$006e675a,$00766f61,$007f7768
		dc.l	$00877f6f,$00908676,$00988e7d,$00a19684
		dc.l	$00a99e8b,$00b2a692,$00baae99,$00c2b7a4
		dc.l	$00c9c0b0,$00d1c9bb,$00d9d2c6,$00e0dbd2
		dc.l	$00e8e4dd,$00f0ede8,$00f7f6f4,$00ffffff

		dc.l	$00110b1c,$00161021,$001c1626,$00211b2b
		dc.l	$00262030,$002b2635,$00312b3a,$0036303f
		dc.l	$003b3643,$00403b48,$0046404d,$004b4652
		dc.l	$00504b57,$0055505c,$005b5661,$00605b66
		dc.l	$00ff0000,$00ee0000,$00dd0000,$00cc0000
		dc.l	$00bb0000,$00aa0000,$00990000,$00880000
		dc.l	$00770000,$00660000,$00550000,$00440000
		dc.l	$00330000,$00220000,$00110000,$00000000
		dc.l	$0000ff00,$0000ee00,$0000dd00,$0000cc00
		dc.l	$0000bb00,$0000aa00,$00009900,$00008800
		dc.l	$00007700,$00006600,$00005500,$00004400
		dc.l	$00003300,$00002200,$00001100,$00000000
		dc.l	$000000ff,$000000ee,$000000dd,$000000cc
		dc.l	$000000bb,$000000aa,$00000099,$00000088
		dc.l	$00000077,$00000066,$00000055,$00000044
		dc.l	$00000033,$00000022,$00000011,$00000000



s_VBL_IntS	Dc.l	0,0
		Dc.b	2,0
		Dc.l	s_VBL_IntN
		Dc.l	0,s_VBL_IntCode
s_VBL_IntN	Dc.b	'Krusty VBlank Int #3',0
		CNOP	0,4


	; ------------------------
	; -- OBJECT DEFINITIONS --
	; ------------------------

s_Objects	Dc.l	s_N_obj,s_S_obj1,s_S_obj2,s_S_obj3,s_S_obj4

s_N_POINTS	= 20
s_N_FACES	= 16

s_N_obj		Dc.w	s_N_POINTS-1, s_N_FACES-1
		Dc.l	.pts,s_ptr,s_ptp
		Dc.w	0,0,0, 0,0,0
		Dc.l	0		; lineseg
		Dc.l	.facel		; facelist
		Dc.l	0		; goraud list
		Dc.l	.txlst		; texel coord list
		Dc.l	s_dsarr		; depth-sort array

.facel	Dc.l	.f0,.f1,.f2,.f3,.f4,.f5,.f6,.f7
	Dc.l	.f8,.f9,.fa,.fb,.fc,.fd,.fe,.ff

	; -- FRONT FACE --
.f0	Dc.l	s_txr1+128
	Dc.w	0,0, 9,1, 3,7, 2,8, 1,9, 0,0, -1
.f1	Dc.l	s_txr1+128
	Dc.w	9,1, 8,2, 4,6, 3,7, 9,1, -1
.f2	Dc.l	s_txr1+128
	Dc.w	7,3, 6,4, 5,5, 4,6, 8,2, 7,3, -1

	; -- BACK FACE --
.f3	Dc.l	s_txr1+128
	Dc.w	10,0, 11,9, 12,8, 13,7, 19,1, 10,0, -1
.f4	Dc.l	s_txr1+128
	Dc.w	19,1, 13,7, 14,6, 18,2, 19,1, -1
.f5	Dc.l	s_txr1+128
	Dc.w	16,4, 17,3, 18,2, 14,6, 15,5, 16,4, -1


	; -- SURROUNDING FACES --
.f6	Dc.l	s_txr1+64+128
	Dc.w	10,0, 19,1, 9,1, 0,0, 10,0, -1
.f7	Dc.l	s_txr1+64+128
	Dc.w	19,1, 18,2, 8,2, 9,1, 19,1, -1
.f8	Dc.l	s_txr1+64+128
	Dc.w	17,3, 7,3, 8,2, 18,2, 17,3, -1
.f9	Dc.l	s_txr1+64+128
	Dc.w	17,3,16,4, 6,4, 7,3, 17,3, -1
.fa	Dc.l	s_txr1+64+128
	Dc.w	6,4, 16,4, 15,5, 5,5, 6,4, -1
.fb	Dc.l	s_txr1+64+128
	Dc.w	4,6, 5,5, 15,5, 14,6, 4,6, -1
.fc	Dc.l	s_txr1+64+128
	Dc.w	4,6, 14,6, 13,7, 3,7, 4,6, -1
.fd	Dc.l	s_txr1+64+128
	Dc.w	3,7, 13,7, 12,8, 2,8, 3,7, -1
.fe	Dc.l	s_txr1+64+128
	Dc.w	1,9, 2,8, 12,8, 11,9, 1,9, -1
.ff	Dc.l	s_txr1+64+128
	Dc.w	10,0, 0,0, 1,9, 11,9, 10,0, -1

.txlst	Dc.w	00,01, 19,01, 46,35, 46,01, 63,01
	Dc.w	63,62, 46,62, 19,29, 19,62, 00,62

.pts	Dc.w	$0078,$FFB0,$0014,$0096,$0096,$0014,$001E,$006E,$0014,$003C
	Dc.w	$FFEC,$0014,$FFEC,$0050,$0014,$FF9C,$0064,$0014,$FF74,$FF6A
	Dc.w	$0014,$FFE2,$FF9C,$0014,$FFD8,$000A,$0014,$0031,$FF93,$0013
	Dc.w	$0078,$FFB0,$FFEC,$0096,$0096,$FFEC,$001E,$006E,$FFEC,$003C
	Dc.w	$FFEC,$FFEC,$FFEC,$0050,$FFEC,$FF9C,$0064,$FFEC,$FF74,$FF6A
	Dc.w	$FFEC,$FFE2,$FF9C,$FFEC,$FFD8,$000A,$FFEC,$0031,$FF93,$FFED

	;Dc.w	$006D,$FF93,$0013,$006D,$006D,$0014,$0031,$006D,$0014,$0031
	;Dc.w	$FFF7,$0013,$FFCF,$006D,$0013,$FF93,$006D,$0013,$FF93,$FF93
	;Dc.w	$0013,$FFCF,$FF93,$0013,$FFCF,$0009,$0013,$0031,$FF93,$0013
	;Dc.w	$006D,$FF93,$FFED,$006D,$006D,$FFED,$0031,$006D,$FFED,$0031
	;Dc.w	$FFF7,$FFED,$FFCF,$006D,$FFED,$FF93,$006D,$FFED,$FF93,$FF93
	;Dc.w	$FFEC,$FFCF,$FF93,$FFEC,$FFCF,$0009,$FFED,$0031,$FF93,$FFED



s_S_POINTS	= 5
s_S_FACES	= 5


s_S_obj1
	Dc.w	s_S_POINTS-1, s_S_FACES-1
	Dc.l	s_pts,s_S_ptrot,s_S_ptpersp
	Dc.w	0,0,0, 0,0,0
	Dc.l	0
	Dc.l	s_facel
	Dc.l	0
	Dc.l	s_txlst
	Dc.l	s_S_dsarr

s_S_obj2
	Dc.w	s_S_POINTS-1, s_S_FACES-1
	Dc.l	s_pts,s_S_ptrot,s_S_ptpersp
	Dc.w	0,0,0, 0,128,0
	Dc.l	0
	Dc.l	s_facel
	Dc.l	0
	Dc.l	s_txlst
	Dc.l	s_S_dsarr

s_S_obj3
	Dc.w	s_S_POINTS-1, s_S_FACES-1
	Dc.l	s_pts,s_S_ptrot,s_S_ptpersp
	Dc.w	0,0,0, 0,256,0
	Dc.l	0
	Dc.l	s_facel
	Dc.l	0
	Dc.l	s_txlst
	Dc.l	s_S_dsarr

s_S_obj4
	Dc.w	s_S_POINTS-1, s_S_FACES-1
	Dc.l	s_pts,s_S_ptrot,s_S_ptpersp
	Dc.w	0,0,0, 0,384,0
	Dc.l	0
	Dc.l	s_facel
	Dc.l	0
	Dc.l	s_txlst
	Dc.l	s_S_dsarr



s_pts	Dc.w	$0014,$FFEC,$0000, $0014,$0014,$0000, $FFEC,$0014,$0000
	Dc.w	$FFEC,$FFEC,$0000, $0000,$0000,$0028

s_facel	Dc.l	.f0,.f1,.f2,.f3,.f4

.f0	Dc.l	s_txr1
	Dc.w	0,0, 1,1, 2,2, 3,3, 0,0, -1
.f1	Dc.l	s_txr1
	Dc.w	4,4, 0,0, 3,3, 4,4, -1
.f2	Dc.l	s_txr1+64
	Dc.w	4,4, 3,3, 2,2, 4,4, -1
.f3	Dc.l	s_txr1
	Dc.w	4,4, 2,2, 1,1, 4,4, -1
.f4	Dc.l	s_txr1+64
	Dc.w	4,4, 1,1, 0,0, 4,4, -1

s_txlst	Dc.w	0,1, 63,1, 63,62, 0,62, 31,31




	; -- This just gives a 4-point star definition --
	; -- for the surrounding pyramids and 'N'      --

s_Star	Dc.w	4,0
	Dc.l	s_S_pts, s_Star_ptr, s_Star_ptp
	Dc.w	0,0,0, 0,0,0
	Dc.l	0
	Dc.l	0
	Dc.l	0
	Dc.l	0
	Dc.l	0

s_S_pts	Dc.w	0,0,0, 0,0,20, 20,0,0, 0,0,-20, -20,0,0






	section	'Fast',BSS

s_Chunky	Ds.b	scene_SCR_WH

s_Background	Ds.b	scene_SCR_WH

s_ptr		Ds.w	3*s_N_POINTS
s_ptp		Ds.w	2*s_N_POINTS
s_dsarr		Ds.w	2*s_N_FACES

s_S_ptrot	Ds.w	3*s_S_POINTS
s_S_ptpersp	Ds.w	2*s_S_POINTS
s_S_dsarr	Ds.w	2*s_S_FACES

s_Star_ptr	Ds.w	3*5
s_Star_ptp	Ds.w	2*5
s_Star_dsarr	Ds.w	2*5

s_temp64	Ds.b	64*64			; Temp space for txr calc
s_txr1		Ds.b	256*64			; The actual textures (4)




	; *****************************
	; ***                       ***
	; ***  C o p p e r L i s t  ***
	; ***                       ***
	; *****************************

	section	'CLIST',DATA_C

s_CLIST		Dc.w	BPL0PTH,0,BPL0PTL,0,BPL1PTH,0,BPL1PTL,0
		Dc.w	BPL2PTH,0,BPL2PTL,0,BPL3PTH,0,BPL3PTL,0
		Dc.w	BPL4PTH,0,BPL4PTL,0,BPL5PTH,0,BPL5PTL,0
		Dc.w	BPL6PTH,0,BPL6PTL,0,BPL7PTH,0,BPL7PTL,0

		Dc.w	BPLCON0,$0210,BPLCON1,0,BPLCON2,0,FMODE,$0003
		Dc.w	DIWSTRT,$4881,DIWSTOP,$10C1,DDFSTRT,$38,DDFSTOP,$A0
		Dc.w	BPL1MOD,0,BPL2MOD,0

s_CLIST_Pal	ColBank	4			; 128 colours

		Dc.w	$FFFF,$FFFE

