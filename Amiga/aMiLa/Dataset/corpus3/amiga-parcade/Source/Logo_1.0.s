*****************************************************************************

; Name			: Logo.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Simple logo/bitmap display.
; Date last edited	: 24/05/2019

; CPU Required		: MC68000 or better
; ChipSet Required	: OCS or better
				
*****************************************************************************

	INCDIR "SOURCES:Parcade/"
	IFND _CUSTOMMACROS_I
		INCLUDE "CustomMacros.i"
	ENDC

	IFND _INTROWRAPPER
	INCLUDE "IntroStandalone.i"
	ENDC

*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	LGO_Code,CODE	;Code section in Public memory

*****************************************************************************

*** Changeable Parameters For Display ***

*** Display Window ***

; Photon:
; Best practice is to start with DDF 38,d0 and DIW 2c81,2cc1 and modify these 
; symmetrically and always in whole 16px steps for compatibility.
; Note DDF start of less than 30 and you start to lose sprites.

LGO_DIW_V		=	$2c+13	;Hardware Vstart ($2c normal, $24 overscan)
LGO_DIW_H		=	$81	;Hardware Hstart ($81 normal, $71 overscan)
LGO_DIW_Width		=	320	;Pixels		 (multiple of 16, 320 normal, 352 overscan)
LGO_DIW_Height		=	229	;Lines		 (256 normal PAL, 272 overscan)

*** Data Fetch ***

LGO_MemoryFetchMode	=	0	;0,1 or 3 
; When FMode=0,1,3 DDF_Width must be a multiple of 16,32,64 respectively.
; NB. I can't get FMODE=2 to work - sorry.
; 0=OCS/ECS, 3=AA in practice
; Bitplane, copper and sprite data should be 64bit (CNOP 0,8) aligned so that it can work
; in ECS/AA modes.
; Bitplanes should be multiples of 64bits wide to take maximum advantage of bandwidth
; 320 or 384 pix which.

LGO_DDF_H		=	$81	;Hardware Hstart ($81 normal, $71 overscan)
LGO_DDF_Width		=	320	;Pixels		 (320 normal pal, 352 overscan)

*****************************************************************************

*** Non-changable parameters for display - Automatically calculated from above ***

LGO_DIW_Vstart		=	(LGO_DIW_V&$ff)<<8
LGO_DIW_Vstop		=	((LGO_DIW_V+LGO_DIW_Height)&$ff)<<8
LGO_DIW_Hstart		=	LGO_DIW_H&$ff
LGO_DIW_Hstop		=	(LGO_DIW_Hstart+LGO_DIW_Width)&$ff
LGO_DIW_Start		=	LGO_DIW_Vstart!LGO_DIW_Hstart
LGO_DIW_Stop		= 	LGO_DIW_Vstop!LGO_DIW_Hstop

	IFEQ	LGO_MemoryFetchMode
LGO_DDF_Increment	=	1
	ENDC
	IFNE	LGO_MemoryFetchMode
LGO_DDF_Increment	=	(LGO_MemoryFetchMode+1)&$fffe
	ENDC	

LGO_DDF_WordWidth		=	LGO_DDF_Width/16
LGO_DDF_Start			=	(LGO_DDF_H/2)-8
LGO_DDF_Stop			=	LGO_DDF_Start+((LGO_DDF_WordWidth-LGO_DDF_Increment)*8)

*****************************************************************************

*** Screen Definitions ***

;Antiriad logo
LGO_PIC1_Width		=	320	
LGO_PIC1_ByteWidth	=	LGO_PIC1_Width/8		;Bytes
LGO_PIC1_WordWidth	=	LGO_PIC1_ByteWidth/2	;Words
LGO_PIC1_Height		=	229	;Lines
LGO_PIC1_NumPlanes	=	5
LGO_PIC1_Size		=	LGO_PIC1_ByteWidth*LGO_PIC1_Height
LGO_PIC1_TotalSize	=	LGO_PIC1_Size*LGO_PIC1_NumPlanes


*****************************************************************************

*****************************************************************************
* Start the effect (usually used for setting up the copper)
* This is called each time the effect is started
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

	IFND _INTROWRAPPER
SubPartStart:	
	ENDC
LGO_Start:
	; Save parameters

	; Have we already done any one-time setup routines?
	tst.w	LGO_Initialised
	bne.s	.alreadyinit
	bsr.s	LGO_Init
.alreadyinit:
	; Init copper pointers
	bsr	LGO_InitCopper

	lea	CUSTOM,a5
	move.l 	#LGO_CL,COP1LCH(a5)	; Active NEXT frame
	jsr	WaitEOF_A5

	; Continue with main loop
	bsr	LGO_MainLoop

	; Restore copper for framework
	jsr	SetBaseCopperAndDma_A5

	rts

*****************************************************************************
* Called ONCE per routine, no matter how many times the routine is used
* Use for one-time setup
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

LGO_Init:
	move.w	#1,LGO_Initialised

	rts


*****************************************************************************
* Runs the effect.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		d0(0=Running, 1=Ending)
* TRASHED:	d0
*****************************************************************************

LGO_MainLoop:
	clr.w	LGO_Finished

	lea	CUSTOM,a5
.Mainloop1:
	BLIT_NASTY_OFF_A5			; Default is no blitter nasty

	;Logo fade in
	moveq	#0,d3			;initial step
.fadeinloop:
	moveq	#(1<<LGO_PIC1_NumPlanes)-1,d7
	lea	LGO_Palette_Logo,a0	;the final colors we want
	lea	LGO_CL_Screen_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.fadeincl:	
	moveq	#0,d0			;starting color is black
	move.w	(a0)+,d1		;final color
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.fadeincl

	moveq	#2,d0
	jsr	WaitVBI_X

	addq.w	#1,d3
	cmpi.w	#16,d3
	bne.s	.fadeinloop
	
	;pause
	move.w	#200,d0
	jsr	WaitVBI_X

	;Logo fade out
	moveq	#0,d3			;initial step
.fadeoutloop:
	moveq	#(1<<LGO_PIC1_NumPlanes)-1,d7
	lea	LGO_Palette_Logo,a0	;the start colors we want
	lea	LGO_CL_Screen_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.fadeoutcl:	
	move.w	(a0)+,d0		;starting color
	moveq	#0,d1			;final color is black
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.fadeoutcl

	moveq	#2,d0
	jsr	WaitVBI_X

	addq.w	#1,d3
	cmpi.w	#16,d3
	bne.s	.fadeoutloop



.fin
	moveq	#1,d0		;Signal finished
	rts


*****************************************************************************

LGO_InitCopper:
	;Copy logo colors (end of raw bitmap to our palette store)
	lea	LGO_Palette_Logo,a0
	lea	LGO_Pic1,a1
	add.l	#LGO_PIC1_TotalSize,a1			;Skip to the color map
	moveq	#(1<<LGO_PIC1_NumPlanes)-1,d0
.copyl:
	move.w	(a1)+,(a0)+
	dbf	d0,.copyl

	;Start with logo all black
	move.l	#LGO_CL_Screen_Cols,a0
	lea	LGO_Palette_AllBlack32,a1
	moveq	#(1<<LGO_PIC1_NumPlanes),d0
	jsr	InitCopperColsFromPalette		;trashes d0,a0,a1

	;bitplane pointers
	move.l 	#LGO_CL_Screen_Bpl,a0
	moveq	#LGO_PIC1_NumPlanes,d0
	move.l	#LGO_Pic1,d1
	move.w 	#LGO_PIC1_Size,d2	;non-interleaved
	jsr	InitCopperBplPtrs

	rts

*****************************************************************************

*****************************************************************************
*****************************************************************************

	SECTION	LGO_PublicData,DATA	;Public data section for variables
	
*****************************************************************************

*** Program Variables ***
LGO_Initialised:
	dc.w	0
LGO_Finished:
	dc.w	0

LGO_Palette_AllBlack32:
	dcb.w	32,0

LGO_Palette_Logo:
	dcb.w	(1<<LGO_PIC1_NumPlanes),0

*****************************************************************************


*****************************************************************************
*****************************************************************************

;	SECTION	LGO_PublicBSS,BSS	;Public blank memory

*****************************************************************************
*****************************************************************************

	SECTION	LGO_ChipData,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************

LGO_Pic1:
	INCBIN "gfx/Antiriad_Production_320x229x5.raw"

*** THE COPPERLISTS ***

; Copper horizontal blanking notes from Photon/Scoopex
; As established, positions $e7...$03 are not usable. If you're writing a simple 
; copperlist with no need for tight timing, positions $df and $07 are conventionally 
;used for the positions on either side of the horizontal blanking, and for 
; compatibility across chipsets use increments of 4 from these, resulting in 
;positions $db, $0b, and so on.

	CNOP 0,8	; 64 bit alignment for AA
LGO_CL:
	CMOVE	FMODE,LGO_MemoryFetchMode		;Chip Ram fetch mode (0=OCS)

	CWAIT	LGO_DIW_V-2,$7		;Time for altering Copperlist

	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,LGO_DIW_Start
	CMOVE 	DIWSTOP,LGO_DIW_Stop
	CMOVE 	DDFSTRT,LGO_DDF_Start
	CMOVE 	DDFSTOP,LGO_DDF_Stop
	CMOVE 	BPLCON0,$5200		;5bpl/8 cols
	CMOVE 	BPLCON1,$0000
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,0
	CMOVE 	BPL2MOD,0

LGO_CL_Screen_Bpl:			;Bitplane pointers
	CMOVE	BPL1PTH,$0
	CMOVE	BPL1PTL,$0
	CMOVE	BPL2PTH,$0
	CMOVE	BPL2PTL,$0
	CMOVE	BPL3PTH,$0
	CMOVE	BPL3PTL,$0
	CMOVE	BPL4PTH,$0
	CMOVE	BPL4PTL,$0
	CMOVE	BPL5PTH,$0
	CMOVE	BPL5PTL,$0

LGO_CL_Color00:
LGO_CL_Screen_Cols:
	CMOVE	COLOR00,$000
	CMOVE	COLOR01,$000
	CMOVE	COLOR02,$000
	CMOVE	COLOR03,$000
	CMOVE	COLOR04,$000
	CMOVE	COLOR05,$000
	CMOVE	COLOR06,$000
	CMOVE	COLOR07,$000
	CMOVE	COLOR08,$000
	CMOVE	COLOR09,$000
	CMOVE	COLOR10,$000
	CMOVE	COLOR11,$000
	CMOVE	COLOR12,$000
	CMOVE	COLOR13,$000
	CMOVE	COLOR14,$000
	CMOVE	COLOR15,$000
	CMOVE	COLOR16,$000
	CMOVE	COLOR17,$000
	CMOVE	COLOR18,$000
	CMOVE	COLOR19,$000
	CMOVE	COLOR20,$000
	CMOVE	COLOR21,$000
	CMOVE	COLOR22,$000
	CMOVE	COLOR23,$000
	CMOVE	COLOR24,$000
	CMOVE	COLOR25,$000
	CMOVE	COLOR26,$000
	CMOVE	COLOR27,$000
	CMOVE	COLOR28,$000
	CMOVE	COLOR29,$000
	CMOVE	COLOR30,$000
	CMOVE	COLOR31,$000

	COPPEREND

*****************************************************************************
