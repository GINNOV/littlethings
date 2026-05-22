*****************************************************************************

; Name			: IntroFramework.i
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Shared framework.
; Date last edited	: 24/05/2019

; CPU Required		: MC68000 or better
; ChipSet Required	: OCS or better
				
*****************************************************************************
*****************************************************************************

	SECTION	IntroFrameworkCode,CODE	;Code section in Public memory

*****************************************************************************

*****************************************************************************

*** Changeable Parameters For Display ***

*** Display Window ***

; Photon:
; Best practice is to start with DDF 38,d0 and DIW 2c81,2cc1 and modify these 
; symmetrically and always in whole 16px steps for compatibility.
; Note DDF start of less than 30 and you start to lose sprites.

DIW_V			=	$2c	;Hardware Vstart ($2c normal, $24 overscan)
DIW_H			=	$81	;Hardware Hstart ($81 normal, $71 overscan)
DIW_Width		=	320	;Pixels		 (multiple of 16, 320 normal, 352 overscan)
DIW_Height		=	256	;Lines		 (256 normal PAL, 272 overscan)

*** Data Fetch ***

MemoryFetchMode		=	0	;0,1 or 3 
; When FMode=0,1,3 DDF_Width must be a multiple of 16,32,64 respectively.
; NB. I can't get FMODE=2 to work - sorry.
; 0=OCS/ECS, 3=AA in practice
; Bitplane, copper and sprite data should be 64bit (CNOP 0,8) aligned so that it can work
; in ECS/AA modes.
; Bitplanes should be multiples of 64bits wide to take maximum advantage of bandwidth
; 320 or 384 pix width.

DDF_H			=	$81	;Hardware Hstart ($81 normal, $71 overscan)
DDF_Width		=	320	;Pixels		 (320 normal pal, 352 overscan)

*****************************************************************************

*** Non-changable parameters for display - Automatically calculated from above ***

DIW_Vstart		=	(DIW_V&$ff)<<8
DIW_Vstop		=	((DIW_V+DIW_Height)&$ff)<<8
DIW_Hstart		=	DIW_H&$ff
DIW_Hstop		=	(DIW_Hstart+DIW_Width)&$ff
DIW_Start		=	DIW_Vstart!DIW_Hstart
DIW_Stop		= 	DIW_Vstop!DIW_Hstop

	IFEQ	MemoryFetchMode
DDF_Increment		=	1
	ENDC
	IFNE	MemoryFetchMode
DDF_Increment		=	(MemoryFetchMode+1)&$fffe
	ENDC	

DDF_WordWidth		=	DDF_Width/16
DDF_Start		=	(DDF_H/2)-8
DDF_Stop		=	DDF_Start+((DDF_WordWidth-DDF_Increment)*8)

*****************************************************************************

KillSys:
	move.l	(_ExecBase).w,a6
	jsr	_Forbid(a6)		;no multitask

	sub.l	a4,a4			;default VBR at $0
	btst.b	#0,_AttnFlags+1(a6)	;68000 CPU?
	beq.s	.yes68k
	lea	.GetVBR(PC),a5		;else fetch vector base address to a4
	jsr	_Supervisor(a6)		;enter Supervisor mode and return VBR in a4
.yes68k:
	move.l	a4,VBRPtr		;a4 is vbr

	lea	GfxName,a1		;open graphics.library
	jsr	_OldOpenLib(a6)		;open
	move.l	d0,a6
	move.l	a6,GfxBase		;Save adr	

	move.l	Gb_ActiView(a6),OldGfxView

	sub.l	a1,a1			;null view
	jsr	_LoadView(a6)		;reset display
	jsr	_WaitTOF(a6)		;let interlaced displays stop
	jsr	_WaitTOF(a6)		;required to avoid sprite garbage

	jsr	_OwnBlitter(a6)		;Take over blitter
	jsr	_WaitBlit(a6)		;and let it finish

	lea	CUSTOM,a5		;Base of HW regs

	move.w	DMACONR(a5),SysDmacon	;save sys stuff
	move.w	INTENAR(a5),SysIntena
	move.w	INTREQR(a5),SysIntreq
	move.w	ADKCONR(a5),SysAdkcon	

	move.l	_Level3Vector(a4),OldLevel3Vector	; Save old VBI

	bsr	WaitEOF_A5		;wait for end of frame to reduce risk of sprite data showing up
	move.w	#$7fff,d0		;clr sys stuff
	move.w	d0,INTENA(a5)
	move.w	d0,INTREQ(a5)
	move.w	d0,INTREQ(a5)		;twice for A4000 compat
	move.w	d0,DMACON(a5)
	move.w	d0,ADKCON(a5)

	sf	AA_Chipset		;AA chipset check
	cmpi.b	#$f8,LISAID+1(a5)	;$fc=ECS, $f8=AA
	bne.s	.notAA
	st	AA_Chipset
	move.w	#0,FMODE(a5)		;normal OCS/ECS Chip mem access (MOVE TO COPPERLIST)

.notAA:		
	move.l	#0,SPR0DATA(a5)		;clr stupid sprite rubbish
	move.b	#$7f,$bfed01		;bye bye Cia inters
	move.b	#$7f,$bfdd00

	rts


	; From call to Supervisor()
	; Get VBR in a4
.GetVBR		
	;movec   vbr,a4
	dc.w $4e7a,$c801		; movec vbr,a4 (if assembler not 680x0 aware)
	rte

*****************************************************************************

*****************************************************************************

RestoreSys:
	lea	CUSTOM,a5

	bsr	WaitBlit_A5
	bsr	WaitEOF_A5		;wait for last frame and blits to finish

	move.w	#$7fff,d0		;clr before setting
	move.w	d0,INTENA(a5)
	move.w	d0,INTREQ(a5)
	move.w	d0,INTREQ(a5)		;twice for A4000 compat
	move.w	d0,DMACON(a5)
	move.w	d0,ADKCON(a5)

	move.b	#$7f,$bfed01		;clr before setting
	move.b	#$7f,$bfdd00

	move.l	VBRPtr,a4
	move.l	OldLevel3Vector,_Level3Vector(a4)

	move.b	#$9b,$bfed01		;cia inters on
	move.b	#$9b,$bfdd00

	move.w	#$8000,d0		;Dma etc.. back on
	or.w	d0,SysAdkcon
	or.w	d0,SysDmacon		
	or.w	d0,SysIntreq
	or.w	d0,SysIntena
	move.w	SysAdkcon,ADKCON(a5)
	move.w	SysDmacon,DMACON(a5)
	move.w	SysIntreq,INTREQ(a5)
	move.w	SysIntreq,INTREQ(a5)	;twice for A4000 compat
	move.w	SysIntena,INTENA(a5)

	move.l	GfxBase,a6
	move.l	Gb_CopInit(a6),COP1LCH(a5)	;Old copper adr
	jsr	_DisownBlitter(a6)	;free the blitter

	move.l	OldGfxView,a1		;get old view
	jsr	_LoadView(a6)		;activate view

	move.l	a6,a1			;gfx base
	move.l	(_ExecBase).w,a6
	jsr	_CloseLib(a6)		;close

	jsr	_Permit(a6)		;multitask on

	rts

*****************************************************************************

WaitRasterExact_A5:
.lo:	move.l	VPOSR(a5),d1		;Wait for scanline. IN: A5=custom, d0=scanline, trashes d1
	lsr.l	#1,d1
	lsr.w	#7,d1
	cmp.w	d0,d1
	bne.s	.lo			;wait until it matches (eq)
	rts

*****************************************************************************

WaitEOFExact_A5:			;wait for end of frame, IN: a5=CUSTOM, trashes d0
.lo:	move.l	VPOSR(a5),d0
	lsr.l	#1,d0
	lsr.w	#7,d0
	cmpi.w	#300,d0			
	bne.s	.lo			;wait until it matches (eq)
	rts

*****************************************************************************

WaitRaster_A5:
.lo:	move.l	VPOSR(a5),d1		;Wait for scanline. IN: A5=custom, d0=scanline, trashes d1
	lsr.l	#1,d1
	lsr.w	#7,d1
	cmp.w	d0,d1
	blt.s	.lo			;wait until it matches (eq)
	rts

*****************************************************************************

WaitEOF_A5:			;wait for end of frame, IN: a5=CUSTOM, trashes d0
.lo:	move.l	VPOSR(a5),d0
	lsr.l	#1,d0
	lsr.w	#7,d0
	cmpi.w	#300,d0			;line 44+256 (i.e. 257th normal visible line)
	blt.s	.lo			;wait until it matches (eq)
	rts

*****************************************************************************

WaitBlit_A5:				;wait until blitter is finished, IN: A5=CUSTOM
	tst.w	DMACONR(a5)		;for compatibility with A1000
.loop:	btst.b	#6,DMACONR(a5)
	bne.s	.loop
	rts

;WaitRaster:
;		move.l	d0,-(sp)
;.wr:		move.l	VPOSR+CUSTOM,d0
;		andi.l	#$1ff00,d0
;		cmpi.l	#303<<8,d0
;		bne.s	.wr
;		move.l	(sp)+,d0
;		rts

;WaitRasterEnd:
;		move.l	d0,-(sp)
;.wr:		move.l	VPOSR+CUSTOM,d0
;		andi.l	#$1ff00,d0
;		cmpi.l	#303<<8,d0
;		beq.s	.wr
;		move.l	(sp)+,d0
;		rts

;VblankWait1:
;		move.l	d0,-(sp)
;.w1:		move.l	VPOSR+CUSTOM,d0
;		andi.l	#$0001ff00,d0
;		cmpi.l	#$00001000,d0		; Line 16
;		bne.s	.w1
;		move.l	(sp)+,d0
;		rts

;VblankWait2:
;.w2:		cmpi.b	#$ff,VHPOSR+CUSTOM	; Line 255
;		bne.s	.w2
;		rts

*****************************************************************************
* Clears a buffer using the CPU. Use in combination with the blitter for speed.
* Clears in groups of 64 bytes.
* IN:		a0 (buffer to clear), d7.l (byte size to clear)
* OUT:		
* TRASHED:	a0,a1,d0-d4/d6-d7
*****************************************************************************

CPUClearBuffer:
	add.l  d7,a0		; start at end for movem -(a0) addressing
	
	lea	.zeros(pc),a1		; quick way of loading 0s

	lsr.l   #2,d7			; divide by 4 for long words.
	move.l  d7,d6
	lsr.l   #4,d6			; # of 16 longword blocks 
	beq.s   .noblock		; branch if no none
	subq.l  #1,d6			; one less so dbra works
	movem.l (a1),d0-d4/a2-a4	; 8 registers = 32 bytes 
.zapblock 
	movem.l d0-d4/a2-a4,-(a0)	; 8 x 4 = 32 bytes
	movem.l d0-d4/a2-a4,-(a0)	; 8 x 4 again for 64 bytes
	dbf    d6,.zapblock		; loop ends when d7=-1
.noblock  
	andi.w   #$0f,d7		; how many long words left
	beq.s   .none
					; do any remainder
	subq.w  #1,d7			; 1 less so dbra works
	move.l  (a1),d0			; pattern in d0 if not there b4
.zap    
	move.l  d0,-(a0)		; set memory long word at a time
	dbf    d7,.zap
.none
	rts

.zeros	dc.l    0,0,0,0,0,0,0,0      	; 8x4 = 32bytes


*****************************************************************************
* Sets the base (blank screen) copper list and enables DMA (Blitter,Copper)
* Use after exiting a subpart to ensure blank screen.
* IN:
* OUT:
* TRASHED:	d0
*****************************************************************************

SetBaseCopperAndDma_A5:
	lea     CL,a0
	bra	SetCopperAndDma_A5
	;rts


*****************************************************************************
* Sets the copper list and enables DMA (Blitter,Copper)
* IN:		a0, aptr to new copperlist
* OUT:		
* TRASHED:	d0
*****************************************************************************

SetCopperAndDma_A5:
	bsr	WaitBlit_A5
	bsr	WaitEOF_A5

	move.l 	a0,COP1LCH(a5)
	;move.w 	#$87c0,DMACON(a5)	;Screen,Blitter,Copper,Blit nasty
	move.w 	#$83c0,DMACON(a5)	;Screen,Blitter,Copper,NOT Blit nasty

	rts


*****************************************************************************
* Pokes the bitplane pointers in the copperlist
* IN:		a0(CopperPtr to BPL1PTH),d1(ScreenPtr),d0(num bitplanes)
*		d2(modulo in bytes, screen_bytewidth for interleaved
*		screen_size for normal)
* OUT:		
* TRASHED:	d0,d1
*****************************************************************************

InitCopperBplPtrs:
	subq.w	#1,d0			;-1 for dbf
	ext.l	d2			;Make d2 safe for longword addition

.makecl
	swap	d1			;Swap high & low words
	move.w	d1,2(a0)		;High ptr
	swap	d1			;Swap high & low words
	move.w	d1,6(a0)		;Low ptr
	addq.l	#8,a0			;Next set of ptrs
	add.l	d2,d1			;Next bitplane
	dbf	d0,.makecl

	rts


*****************************************************************************
* Pokes the colors in the copperlist stored at the end of an image (normal RAW)
* IN:		a0(CopperPtr to COLOR00),a1(ImagePtr),d0(num colors),d1(image size)
* OUT:		
* TRASHED:	d0,a0,a1
*****************************************************************************

InitCopperColsFromRawImage:
	addq.l	#2,a0			;Skip COLOR00 entry
	subq.w	#1,d0			;-1 for dbf

	add.l	d1,a1			;Skip to the color map
	
.loop	move.w	(a1)+,(a0)
	addq.l	#4,a0			;Next copper instruction
	dbf	d0,.loop
	rts

*****************************************************************************
* Pokes the colors in the copperlist using a source palette (just list of dc.w color values)
* IN:		a0(CopperPtr to COLOR00),a1(palette),d0(num colors)
* OUT:		
* TRASHED:	d0,a0,a1
*****************************************************************************

InitCopperColsFromPalette:
	addq.l	#2,a0			;Skip COLOR00 entry
	subq.w	#1,d0			;-1 for dbf
	
.loop	move.w	(a1)+,(a0)
	addq.l	#4,a0			;Next copper instruction
	dbf	d0,.loop
	rts


*****************************************************************************
* VBI happens at line 0 and lasts for 25 lines on PAL
* If you need more processing time you can make the copper trigger the blank 
* after the last line instead. If double buffering this probably isn't needed.
*****************************************************************************
	
VBlankServer:				;Blank template VERTB interrupt
	SAVEREGS

	lea	CUSTOM,a5		;Set CUSTOM chip base adr
	btst	#5,INTREQR+1(a5)	;Is it a vblank interrupt? Could be a Copper/Blitter
	beq.s	.notvb
 
	IFNE	Music
	move.l	a5,a6			;Music routine wants it in a6
	jsr	P61_Music
	ENDC

	addq.w	#1,NumLev3		;Increase Vblank counter
	addq.w	#1,MasterFrameCounter	;Increase master frame counter
	lea	CUSTOM,a5		;Set CUSTOM chip base adr
	RESET_LEV3_A5			;Reset level 3

.notvb	LOADREGS		;restore
	rte

*****************************************************************************
* Waits for a vertical blank
* IN:		
* OUT:		
* TRASHED:	
*****************************************************************************

WaitVBI:
	clr.w	NumLev3
.loop	cmpi.w	#1,NumLev3
	bne.s	.loop
	clr.w	NumLev3
	rts

*****************************************************************************
* Waits for a vertical blank for a number of frames (to get constant 25fps for example)
* If the period has already been missed when it starts it will wait for the next vblank.
* IN:		d0(number of frames to wait, 1=50fps,2=25fps)	
* OUT:		
* TRASHED:	
*****************************************************************************

WaitVBI_X:
	cmp.w	NumLev3,d0
	ble.s	WaitVBI
	;rts

.loop:	cmp.w	NumLev3,d0
	bgt.s	.loop
	clr.w	NumLev3
	rts

	
*****************************************************************************
* Clears front and back buffer (max size)
* IN:		A5(Custom)
* OUT:		
* TRASHED:	a0,a1,d0-d4/d6-d7
*****************************************************************************

Clear_AllScreenBuffers_A5:
	;Clear with CPU to avoid hassle of clearing 5*256*40 in OCS BLTSIZE
	; a0 = buffer to clear
	; d7 = size in bytes to clear
	lea	Screen_Buffer,a0
	move.l	#Screen_TotalSize,d7
	jsr	CPUClearBuffer	

	lea	Work_Buffer,a0
	move.l	#Screen_TotalSize,d7
	jsr	CPUClearBuffer	

	rts


*****************************************************************************

; Additional routines
	INCLUDE "RGB12_Interpolate.i"

*****************************************************************************

*** System stuff ***
		
SysDmacon	dc.w	0		;System DMA
SysAdkcon	dc.w	0		;System Disk & Sound
SysIntena	dc.w	0		;System Interrupt Control
SysIntreq	dc.w	0		;System Interrupt Request

AA_Chipset	dc.b	0		;-1=AA, 0=ECS/OCS
	EVEN

VBRPtr		dc.l	0		;VBR pointer
OldLevel3Vector	dc.l	0		;Old VBI

GfxBase		dc.l	0		;Address of Gfx Library
OldGfxView	dc.l	0		;Address of Old Viewport
GfxName		dc.b	"graphics.library",0
	EVEN

*** Intro Variables ***

Quit_Flag		dc.w	0		;1=Quit

NumLev3:		dc.w	0		;Number of VBlank interrupts since last check
MasterFrameCounter:	dc.w	0		;NUmber of VBlank interrupts since startup (demo timing)

*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	IntroFrameworkChipData,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************
	
*** THE COPPERLISTS ***

; Copper horizontal blanking notes from Photon/Scoopex
; As established, positions $e7...$03 are not usable. If you're writing a simple 
; copperlist with no need for tight timing, positions $df and $07 are conventionally 
;used for the positions on either side of the horizontal blanking, and for 
; compatibility across chipsets use increments of 4 from these, resulting in 
;positions $db, $0b, and so on.
	CNOP 0,8	; 64 bit alignment for AA
CL:
	CMOVE	FMODE,MemoryFetchMode	;Chip Ram fetch mode (0=OCS)
	
	CWAIT	DIW_V-2,$7		;Time for altering Copperlist
	
	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,DIW_Start
	CMOVE 	DIWSTOP,DIW_Stop
	CMOVE 	DDFSTRT,DDF_Start
	CMOVE 	DDFSTOP,DDF_Stop
	CMOVE 	BPLCON0,$0200		;Bitplanes off
	CMOVE 	BPLCON1,$0000
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,0
	CMOVE 	BPL2MOD,0

CL_Sprites:			        ;Blank Sprite pointers
	CMOVE	SPR0PTH,$0
	CMOVE	SPR0PTL,$0
	CMOVE	SPR1PTH,$0
	CMOVE	SPR1PTL,$0
	CMOVE	SPR2PTH,$0
	CMOVE	SPR2PTL,$0
	CMOVE	SPR3PTH,$0
	CMOVE	SPR3PTL,$0
	CMOVE	SPR4PTH,$0
	CMOVE	SPR4PTL,$0
	CMOVE	SPR5PTH,$0
	CMOVE	SPR5PTL,$0
	CMOVE	SPR6PTH,$0
	CMOVE	SPR6PTL,$0
       	CMOVE	SPR7PTH,$0
	CMOVE	SPR7PTL,$0
 
CL_Color00:
CL_Screen_Cols:
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ELSE
		CMOVE	COLOR01,$000		; If testing then just use color01 twice
	ENDC

	COPPEREND


*****************************************************************************
*****************************************************************************
