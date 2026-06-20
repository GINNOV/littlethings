*****************************************************************************

; Name			: TextWall.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Logo, starfield and text messages.
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

	SECTION	TX1_Code,CODE	;Code section in Public memory

*****************************************************************************


*****************************************************************************

*** Screen Definitions ***

;The top logo
TX1_TopLogo_Width	=	320
TX1_TopLogo_ByteWidth	=	TX1_TopLogo_Width/8		;Bytes
TX1_TopLogo_WordWidth	=	TX1_TopLogo_ByteWidth/2	;Words
TX1_TopLogo_Height	=	70	;Lines
TX1_TopLogo_NumPlanes	=	4
TX1_TopLogo_Size	=	TX1_TopLogo_ByteWidth*TX1_TopLogo_Height
TX1_TopLogo_TotalSize	=	TX1_TopLogo_Size*TX1_TopLogo_NumPlanes

;The visible screen area and back buffer
TX1_SCR_Width		=	320
TX1_SCR_ByteWidth	=	TX1_SCR_Width/8		;Bytes
TX1_SCR_WordWidth	=	TX1_SCR_ByteWidth/2	;Words
TX1_SCR_Height		=	178	;Lines
TX1_SCR_PF1_NumPlanes	=	3	; 3bpl/8 cols
TX1_SCR_PF2_NumPlanes	=	2	; 2bpl/4 cols
TX1_SCR_Size		=	TX1_SCR_ByteWidth*TX1_SCR_Height
TX1_SCR_PF1_TotalSize	=	TX1_SCR_Size*TX1_SCR_PF1_NumPlanes
TX1_SCR_PF2_TotalSize	=	TX1_SCR_Size*TX1_SCR_PF2_NumPlanes

TX1_XOFFSET		=	TX1_SCR_Width/2
TX1_YOFFSET		=	TX1_SCR_Height/2
TX1_ZOFFSET		=	0

TX1_NUMSTARS 		= 	105
TX1_ZSTEP		=	3
TX1_ZSTART		=	768			;Z start position

TX1_CLIPMINX		=	0
TX1_CLIPMAXX		=	TX1_SCR_Width-1
TX1_CLIPMINY		=	0
TX1_CLIPMAXY		=	TX1_SCR_Height-1

; The actual font details
TX1_Font_Height			=	14	;Real height with no extra pixels
TX1_Font_ByteWidth		=	16/8	;16pixel font, 2bytes
TX1_Font_WordWidth		=	TX1_Font_ByteWidth/2
TX1_Font_BlitModulo_1Bpl	= 	TX1_SCR_ByteWidth-TX1_Font_ByteWidth	
TX1_Font_BlitModulo_nBplInt	= 	(TX1_SCR_ByteWidth-TX1_Font_ByteWidth)+((TX1_SCR_PF2_NumPlanes-1)*TX1_SCR_ByteWidth)

; The source font bitmap
TX1_Font_Bitmap_Width		=	320
TX1_Font_Bitmap_ByteWidth	=	TX1_Font_Bitmap_Width/8
TX1_Font_Bitmap_Height		=	224

TX1_Font_Mask_Max		=	7	;Mask values are 1-8 (1=fully visible,8=clear)

; The font matrix picks out a word aligned block in the font sheet. Usually the fonts aren't
; perfectly aligned so we need to adjust the Y position (lines) to match exactly
; Also may need to offset the word boundary. For example 16x16 font uses a 32x32 matrix but
; the font is stored in the bottom right of each cell. So YOffsetPixels=16, and XOffsetBytes=2
TX1_Font_Bitmap_YOffsetPixels	=	2	
TX1_Font_Bitmap_XOffsetBytes	=	2

; The number of blocks of text
TX1_Text_X_Blocks		= 	20
TX1_Text_Y_Blocks		= 	10

*****************************************************************************

*****************************************************************************
* Called ONCE per routine, no matter how many times the routine is used
* Use for one-time setups and pre calcs.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

TX1_Init:
	move.w	#1,TX1_Initialised

	; CReate random stars
	bsr	TX1_RandomizeStars

	rts

*****************************************************************************
* Start the effect (usually used for setting up the copper)
* This is called each time the effect is started
* IN:		a0(text message ptr),d0(pre pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************
	IFND _INTROWRAPPER
SubPartStart:	
	lea	TX1_Text1,a0		
	moveq	#0,d0			;pre pause
	ENDC

TX1_Start:
	; Save parameters and setup controller structure values
	lea	TX1_Controller_Info,a6
	move.l	a0,TX1_CTRL_TEXTPTR(a6)

	; First routine is the fade in
	move.w	#TX1_CTRL_STATE_FADEIN,TX1_CTRL_STATE(a6)
	move.w	#0,TX1_CTRL_PALETTE_STEP(a6)	;0-15
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)	;passed paramter frames to pause before fade

	; Have we already done any one-time setup routines?
	tst.w	TX1_Initialised
	bne.s	.alreadyinit
	bsr.s	TX1_Init
.alreadyinit:

	; Init copper pointers
	bsr	TX1_InitCopper
	; We always fade in so setup initial palettes to all black in the copperlist
	bsr	TX1_InitCopperPalette

	; Clear all screen buffers at EOF and swap copper list
	; Main routine has bitplanes off so safe to clear first
	lea	CUSTOM,a5
	bsr	TX1_Clear_ScreenBuffers_A5
	bsr	DrawAntiriadLogo

	WAITBLIT_A5
	jsr	WaitEOF_A5
	move.l 	#TX1_CL,COP1LCH(a5)	; Active NEXT frame

	bsr.s	TX1_MainLoop

	;restore framework CL
	jsr	SetBaseCopperAndDma_A5

	rts


*****************************************************************************
* Runs the effect.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		d0(0=Running, 1=Ending)
* TRASHED:	d0
*****************************************************************************

TX1_MainLoop:
	clr.w	TX1_Finished

	lea	CUSTOM,a5
.Mainloop1:
	BLIT_NASTY_OFF_A5			; Default is no blitter nasty

	TIMERON	$111

	bsr	TX1_Clear_WorkBuffer_A5
	bsr	TX1_Perspective
	TIMERON	$300
	WAITBLIT_A5
	TIMERON	$111
	bsr	TX1_PlotStars

	bsr	TX1_TextRoutine

	TIMEROFF

	jsr	WaitEOFExact_A5
	bsr	TX1_DoubleBufferSwap
	bsr	TX1_DoFades		;Have to do after EOF for smooth color transition
	
	tst.w	TX1_Finished		;Check if script ended
	bne	.fin
.Testmouse
	btst 	#10-8,POTGOR(a5)	;rmb quits section
	beq.s	.fin
	btst 	#6,$bfe001		;lmb quits all
	bne.s 	.Mainloop1
	move.w	#1,Quit_Flag
.fin	
	moveq	#1,d0		;Signal finished
	rts

*****************************************************************************

TX1_InitCopper:
;Init. physical & logical screen addresses
	lea	Screen_Buffer,a0
	move.l	a0,TX1_PF1_Screen_Ptr		;Physical screen adr
	lea	TX1_SCR_PF1_TotalSize(a0),a0
	move.l	a0,TX1_PF2_Screen_Ptr		;Physical screen adr

	lea	Work_Buffer,a1
	move.l	a1,TX1_PF1_Work_Ptr		;Logical screen adr
	lea	TX1_SCR_PF1_TotalSize(a1),a1
	move.l	a1,TX1_PF2_Work_Ptr		;Logical screen adr

        ; Just run double buffer swap to update the copper bitmap pointers
	bsr	TX1_DoubleBufferSwap

;Top logo
	move.l 	#TX1_CL_TopLogo_Bpl,a0
	moveq	#TX1_TopLogo_NumPlanes,d0
	move.l	#TX1_TopLogo,d1
	move.w 	#TX1_TopLogo_Size,d2	;non-interleaved
	jsr	InitCopperBplPtrs

;Antiriad logo
	move.l 	#TX1_CL_AntLogo_Bpl,a0
	moveq	#AntLogo_NumPlanes,d0
	move.l	#AntLogo_Buffer,d1
	move.w 	#AntLogo_Size,d2	;non-interleaved
	jsr	InitCopperBplPtrs

	rts


*****************************************************************************

TX1_InitCopperPalette:
	;Copy logo colors (end of raw bitmap to our palette store)
	lea	TX1_Palette_Logo,a0
	lea	TX1_TopLogo,a1
	add.l	#TX1_TopLogo_TotalSize,a1			;Skip to the color map
	moveq	#16-1,d0
.copyl:
	move.w	(a1)+,(a0)+
	dbf	d0,.copyl

	;Start with logo all black
	move.l	#TX1_CL_TopLogo_Cols,a0
	lea	TX1_Palette_AllBlack16,a1
	moveq	#16,d0
	jsr	InitCopperColsFromPalette

	;Start with stars all black
	move.l	#TX1_CL_PF1_Cols,a0
	lea	TX1_Palette_AllBlack16,a1
	moveq	#(1<<TX1_SCR_PF1_NumPlanes)-1,d0	;-1 as no color 0 in CL
	jsr	InitCopperColsFromPalette

	;Start with bars all black
	moveq	#0,d0
	move.w	d0,TX1_CL_TopBar_Col+2		;skip cmove
	move.w	d0,TX1_CL_BottomBar_Col+2	;skip cmove
	move.w	d0,TX1_CL_AntLogo_Col+2		;skip cmove

	rts


*****************************************************************************
* Swaps the screens
* IN:		
* OUT:		
* TRASHED:	d0-d1/a0
*****************************************************************************

TX1_DoubleBufferSwap:

	;playfield 1
	lea	TX1_PF1_Screen_Ptr,a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)

	lea 	TX1_CL_PF1_Bpl,a0		;Adr of copper pointers
	moveq	#TX1_SCR_PF1_NumPlanes-1,d1	;Number of bitplanes
.pf1loop
	swap	d0			;Swap high & low words
	move.w	d0,2(a0)		;High ptr
	swap	d0			;Swap high & low words
	move.w	d0,6(a0)		;Low ptr
	addq.l	#8,a0			;Next set of ptrs
	addi.l	#TX1_SCR_ByteWidth,d0	;Next bitplane (interleaved)

	dbf	d1,.pf1loop		

	;playfield 2
	lea	TX1_PF2_Screen_Ptr,a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)

	lea 	TX1_CL_PF2_Bpl,a0		;Adr of copper pointers
	moveq	#TX1_SCR_PF2_NumPlanes-1,d1	;Number of bitplanes
.pf2loop
	swap	d0			;Swap high & low words
	move.w	d0,2(a0)		;High ptr
	swap	d0			;Swap high & low words
	move.w	d0,6(a0)		;Low ptr
	addq.l	#8,a0			;Next set of ptrs
	addi.l	#TX1_SCR_ByteWidth,d0	;Next bitplane (interleaved)

	dbf	d1,.pf2loop		


	rts

*****************************************************************************
* Clears the work buffer screen. Every frame.
* IN:		A5(Custom)
* OUT:		
* TRASHED:	d0
*****************************************************************************

TX1_Clear_WorkBuffer_A5:

	; Clear stars screen
	move.l	TX1_PF1_Work_Ptr,d0
	WAITBLIT_A5
	move.l	#$01000000,BLTCON0(a5)
	move.l	d0,BLTDPTH(a5)
	move.w	#0,BLTDMOD(a5)
	move.w	#TX1_SCR_Height*64+(TX1_SCR_WordWidth*TX1_SCR_PF1_NumPlanes),BLTSIZE(a5)

	rts

*****************************************************************************
* Clears front and back buffer. Done at startup to clear everything.
* IN:		A5(Custom)
* OUT:		
* TRASHED:	
*****************************************************************************

TX1_Clear_ScreenBuffers_A5:

	;Clear with CPU to avoid hassle of clearing 5*256*40 in OCS BLTSIZE
	; a0 = buffer to clear
	; d7 = size in bytes to clear
	lea	Screen_Buffer,a0
	move.l	#TX1_SCR_PF1_TotalSize+TX1_SCR_PF2_TotalSize,d7
	jsr	CPUClearBuffer	

	lea	Work_Buffer,a0
	move.l	#TX1_SCR_PF1_TotalSize+TX1_SCR_PF2_TotalSize,d7
	jsr	CPUClearBuffer	

	lea	AntLogo_Buffer,a0
	move.l	#AntLogo_TotalSize,d7
	jsr	CPUClearBuffer	

	rts


*****************************************************************************
* Draws Antiriad logo
* IN:		A0(Screen address)
* OUT:		
* TRASHED:	d0
*****************************************************************************

DrawAntiriadLogo:
	lea	AntLogo_Buffer+34,a0
	move.l #$0064ffbc,(a0)
	move.w #$e670,4(a0)
	
	add.l  #(AntLogo_NumPlanes*AntLogo_ByteWidth),a0
	move.l #$00969122,(a0)
	move.w #$4948,4(a0)
	
	add.l  #(AntLogo_NumPlanes*AntLogo_ByteWidth),a0
	move.l #$00f5913c,(a0)
	move.w #$4F48,4(a0)
	
	add.l  #(AntLogo_NumPlanes*AntLogo_ByteWidth),a0
	move.l #$009493a2,(a0)
	move.w #$e930,4(a0)

	rts


*****************************************************************************
* Does some precalcs for perspective to change two divs into 2 muls.
* IN:		
* OUT:		
* TRASHED:	d0
*****************************************************************************

TX1_RndW:
	bsr.s	TX1_RndB
	rol.w	#8,d0
TX1_RndB:
	move.b	$dff007,d0		;Hpos
	move.b	$bfd800,d1		;event counter
	eor.b	d1,d0
	rts

TX1_Random:				;A simple mathematical generator. d0=seed
	rol.w	d0,d0
	eor.w	#18565,d0
	rts				;returns next RND number/seed in d0

TX1_PRNG:    
	movem.l   TX1_PRNG_State(pc),d0-d1

	move.l	d0,d2
	lsl.l	#2,d0
	eor.l	d2,d0           ; T = A^(A<<2)

	move.l	d1,d2
	lsr.l	#3,d2
	eor.l	d1,d2           ; B^(B>>3)

	eor.l	d0,d2           ; B^(B>>3)^T
	lsr.l	#7,d0
	eor.l	d0,d2           ; B^(B>>3)^T^(T>>7)

	movem.l   d1-d2,TX1_PRNG_State
	rts                        ; return random number in D2

TX1_PRNG_State:
	;dc.l      2                ; initialize once to non zero
	dc.l $9876fedc
	dc.l $abcd1234


TX1_RandomizeStars:				;initialize x,y,z coordinate values
	lea	TX1_XYZpts,a1
	move.w	#TX1_NUMSTARS-1,d7
.l1:
	bsr	TX1_PRNG
	ext.l	d2			;-32768 to 32768
	divs	#32767/(TX1_SCR_Width/2),d2
	move.w 	d2,(a1)+		

	bsr	TX1_PRNG
	ext.l	d2			;-32768 to 32768
	divs	#32767/(TX1_SCR_Height/2),d2
	move.w 	d2,(a1)+		

	bsr	TX1_PRNG
	ext.l	d2			;-32768 to 32768		
	divs	#32767/(TX1_ZSTART/2),d2	;-ZSTART/2 to +ZSTART/2
	add.w	#TX1_ZSTART/2,d2	;0-ZSTART
	move.w 	d2,(a1)+		

	dbf d7,.l1	
	rts

TX1_Perspective:
	;Get screen offsets
	move.w	#TX1_XOFFSET,d4
	move.w	#TX1_YOFFSET,d5

	lea	TX1_XYZpts,a0		;rot pts 3d
	lea	TX1_PersXYpts,a1	;screen x,y and color

	move.w	#TX1_NUMSTARS-1,d7	;num pts-1
.persloop1:
	movem.w	(a0)+,d0-d2		;get x,y,z pts
	;ext.l	d0			;sign extend to a longword
	;ext.l	d1			;REMOVED: movem.w auto sign extends!
	
	subq.w	#TX1_ZSTEP,d2
	bpl.s	.zok	
	add.w	#TX1_ZSTART,d2
.zok:
	move.w	d2,-2(a0)		;store new z
	
	asl.l	#8,d0			;*256
	asl.l	#8,d1			;*256

	tst.w	d2
	beq.s	.store			;trap div by zero
	divs	d2,d0			;new x & y values
	divs	d2,d1
.store:	
	add.w	d4,d0			;add x offset
	add.w	d5,d1			;add y offset
	
	move.w	d0,(a1)+		;store x,y
	move.w	d1,(a1)+

	ext.l	d2
	divu	#(TX1_ZSTART/((1<<TX1_SCR_PF1_NumPlanes)-1)),d2
	addq.w	#1,d2			;1-7
	move.w	d2,(a1)+

	dbf	d7,.persloop1
	rts


*****************************************************************************
* Draws the stars on screen.
* IN:
* OUT:
* TRASHED:	d0-d7/a0
*****************************************************************************

TX1_PlotStars:
	move.l	TX1_PF1_Work_Ptr,a4
	move.l	#TX1_SCR_ByteWidth,a6	;interleaved
	lea	TX1_PersXYpts,a0
	lea	TX1_XYZpts+4,a1		;first z pt
	lea	TX1_Mult_Height_PF1_NumPlanes,a2
	move.w	#TX1_NUMSTARS-1,d7
.loop:
	movem.w	(a0)+,d0-d1/d4	;x,y,col

	;if clipping then reset z
	cmpi.w	#TX1_SCR_Width-1,d0
	bge	.resetz	
	tst.w	d0
	bmi	.resetz	
	cmpi.w	#TX1_SCR_Height-1,d1
	bge	.resetz	
	tst.w	d1
	bmi	.resetz	

;yes drawit
	move.l	a4,a3

	add.w	d1,d1
	add.w	(a2,d1.w),a3		;y val * numplanes + screen
	
	move.w	d0,d3
	not.w	d3			;convert to bset value
	asr.w	#3,d0
	add.w	d0,a3			;final screen ptr

.pl1:	btst	#0,d4
	beq.s	.pl2
	bset.b	d3,(a3)
.pl2:	
	add.l	a6,a3
	btst	#1,d4
	beq.s	.pl3
	bset.b	d3,(a3)
.pl3:	
	add.l	a6,a3
	btst	#2,d4
	beq.s	.pl4
	bset.b	d3,(a3)
.pl4:
	
	addq.l	#6,a1
	dbf	d7,.loop
	rts

.resetz:	
	move.w	#TX1_ZSTART,(a1)
	addq.l	#6,a1
	dbf	d7,.loop
	rts


*****************************************************************************
* Runs the fade routine, Call outside the visible area.
* IN:		a5, custom
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

TX1_DoFades:

	lea	TX1_Controller_Info,a6
	
	move.w	TX1_CTRL_STATE(a6),d0

	cmpi.w	#TX1_CTRL_STATE_FADEIN,d0
	beq	TX1_Ctrl_FadeIn

	cmpi.w	#TX1_CTRL_STATE_FADEOUT,d0
	beq	TX1_Ctrl_FadeOut

	rts

*****************************************************************************
* Runs the text routine
* IN:		a5, custom
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

TX1_TextRoutine:

	lea	TX1_Controller_Info,a6
	
	move.w	TX1_CTRL_STATE(a6),d0

	cmpi.w	#TX1_CTRL_STATE_QUIT,d0
	bne.s	.notquit

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.doquit
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts
.doquit:
	move.w	#1,TX1_Finished
	rts

.notquit:
	cmpi.w	#TX1_CTRL_STATE_PREPAUSE,d0
	beq	TX1_Ctrl_PrePause

	cmpi.w	#TX1_CTRL_STATE_TEXTDRAW,d0
	beq	TX1_DrawText

	cmpi.w	#TX1_CTRL_STATE_PAUSE,d0
	beq	TX1_Ctrl_Pause

	cmpi.w	#TX1_CTRL_STATE_TEXTCLEAR,d0
	beq	TX1_ClearText

	cmpi.w	#TX1_CTRL_STATE_POSTPAUSE,d0
	beq	TX1_Ctrl_PostPause

	rts


*****************************************************************************
* Runs the fade in
* IN:		a5, custom
*		a6, TX1_Controller_Info
* OUT:		
* TRASHED:	d0-d3/d7/a0-a1
*****************************************************************************

TX1_Ctrl_FadeIn:

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.dofade
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts

.dofade:
	move.w	#TX1_CTRL_FADE_SPEED,TX1_CTRL_FRAMECOUNTER(a6)	;reset counter if we need it
	move.w	TX1_CTRL_PALETTE_STEP(a6),d3	;get current step

	;Logo fade
	moveq	#(1<<TX1_TopLogo_NumPlanes)-1,d7
	lea	TX1_Palette_Logo,a0		;the final colors we want
	lea	TX1_CL_TopLogo_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.logoloop	
	moveq	#0,d0			;starting color is black
	move.w	(a0)+,d1		;final color
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.logoloop

	;Stars fade
	moveq	#(1<<TX1_SCR_PF1_NumPlanes)-2,d7	;-2 as no color 0 in CL and -1 for dbf
	lea	TX1_Palette_Stars,a0		;the final colors we want
	lea	TX1_CL_PF1_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.starloop	
	moveq	#0,d0			;starting color is black
	move.w	(a0)+,d1		;final color
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.starloop

	;bars
	moveq	#0,d0			;starting color is black
	move.w	#TX1_BAR_COLOR,d1	;final bar color
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,TX1_CL_TopBar_Col+2		;skip cmove
	move.w	d0,TX1_CL_BottomBar_Col+2	;skip cmove
	move.w	d0,TX1_CL_AntLogo_Col+2		;skip cmove

	; Increase step
	addq.w	#1,d3			;increase step
	move.w	d3,TX1_CTRL_PALETTE_STEP(a6)
	cmpi.w	#16,d3			;Was this the final step?
	blt.s	.exit			;Keep fading
	
	;Finished fading, setup next stage
	move.w	#TX1_CTRL_STATE_PREPAUSE,TX1_CTRL_STATE(a6)
	move.w	#TX1_CTRL_STATE_PREPAUSE_START,TX1_CTRL_FRAMECOUNTER(a6)
.exit:
	rts


*****************************************************************************
* Runs the fade out
* IN:		a5, custom
*		a6, TX1_Controller_Info
* OUT:		
* TRASHED:	d0-d3/d7/a0-a1
*****************************************************************************

TX1_Ctrl_FadeOut:

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.dofade
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts

.dofade:
	move.w	#TX1_CTRL_FADE_SPEED,TX1_CTRL_FRAMECOUNTER(a6)	;reset counter if we need it
	move.w	TX1_CTRL_PALETTE_STEP(a6),d3	;get current step

	;Logo fade
	moveq	#(1<<TX1_TopLogo_NumPlanes)-1,d7
	lea	TX1_Palette_Logo,a0		;the final colors we want
	lea	TX1_CL_TopLogo_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.logoloop	
	move.w	(a0)+,d0		;starting color
	moveq	#0,d1			;final color is black
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.logoloop

	;Stars fade
	moveq	#(1<<TX1_SCR_PF1_NumPlanes)-2,d7	;-2 as no color 0 in CL and -1 for dbf
	lea	TX1_Palette_Stars,a0		;the final colors we want
	lea	TX1_CL_PF1_Cols+2,a1	;the colors in the CL, skipping the CMOVE instruction
.starloop	
	move.w	(a0)+,d0		;starting color
	moveq	#0,d1			;final color is black
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a1)			;new color in the cl
	addq.l	#4,a1			;skip to next color value
	dbf	d7,.starloop

	;bars
	move.w	#TX1_BAR_COLOR,d0	;starting bar color
	moveq	#0,d1			;final color is black
	move.w	d3,d2			;step
	jsr	RGB12_Interpolate_Fast	;trashes d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,TX1_CL_TopBar_Col+2		;skip cmove
	move.w	d0,TX1_CL_BottomBar_Col+2	;skip cmove
	move.w	d0,TX1_CL_AntLogo_Col+2		;skip cmove

	; Increase step
	addq.w	#1,d3			;increase step
	move.w	d3,TX1_CTRL_PALETTE_STEP(a6)
	cmpi.w	#16,d3			;Was this the final step?
	blt.s	.exit			;Keep fading
	
	;Finished fading, setup next stage
	move.w	#TX1_CTRL_STATE_QUIT,TX1_CTRL_STATE(a6)
	move.w	#TX1_CTRL_STATE_POSTPAUSE_START,TX1_CTRL_FRAMECOUNTER(a6)
.exit:
	rts


*****************************************************************************
* The pause before text is drawn
* IN:		a5, custom
*		a6, TX1_Controller_Info
* OUT:		
* TRASHED:	d0/a0-a1
*****************************************************************************

TX1_Ctrl_PrePause:

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.finishpause
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts

.finishpause:
	;Next state is drawing text
	move.w	#TX1_CTRL_STATE_TEXTDRAW,TX1_CTRL_STATE(a6)

	;Setup the pattern
	move.w	#(TX1_Text_X_Blocks*TX1_Text_Y_Blocks)-1,d0
	lea	TX1_Text_Pattern1,a0
	lea	TX1_Text_Pattern_Current,a1
.loop:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop

	rts


*****************************************************************************
* The pause after text is drawn
* IN:		a5, custom
*		a6, TX1_Controller_Info
* OUT:		
* TRASHED:	d0/a0-a1
*****************************************************************************

TX1_Ctrl_Pause:

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.finishpause
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts

.finishpause:
	;Next state is clearing text
	move.w	#TX1_CTRL_STATE_TEXTCLEAR,TX1_CTRL_STATE(a6)

	;Setup the pattern
	move.w	#(TX1_Text_X_Blocks*TX1_Text_Y_Blocks)-1,d0
	lea	TX1_Text_Pattern2,a0
	lea	TX1_Text_Pattern_Current,a1
.loop:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop

	rts


*****************************************************************************
* The pause after text is cleared. We either fade and end. Or another page of text.
* IN:		a5, custom
*		a6, TX1_Controller_Info
* OUT:		
* TRASHED:	d0/a0-a1
*****************************************************************************

TX1_Ctrl_PostPause:

	move.w	TX1_CTRL_FRAMECOUNTER(a6),d0
	beq.s	.finishpause
	subq.w	#1,d0
	move.w	d0,TX1_CTRL_FRAMECOUNTER(a6)
	rts

.finishpause:
	;Next state is either more text or fade out
	move.l	TX1_CTRL_TEXTPTR(a6),a0
	add.l	#(TX1_Text_X_Blocks*TX1_Text_Y_Blocks),a0	;each block is a byte

	tst.b	(a0)			; zero denotes end, otherwise another page
	beq.s	.fadeout

	;Another page, store new text ptr and update pattern
	move.l	a0,TX1_CTRL_TEXTPTR(a6)
	move.w	#TX1_CTRL_STATE_TEXTDRAW,TX1_CTRL_STATE(a6)
	move.w	#(TX1_Text_X_Blocks*TX1_Text_Y_Blocks)-1,d0
	lea	TX1_Text_Pattern1,a0
	lea	TX1_Text_Pattern_Current,a1
.loop:
	move.b	(a0)+,(a1)+
	dbf	d0,.loop
	rts

.fadeout:
	move.w	#TX1_CTRL_STATE_FADEOUT,TX1_CTRL_STATE(a6)
	move.w	#0,TX1_CTRL_PALETTE_STEP(a6)	;0-15
	move.w	#TX1_CTRL_FADE_SPEED,TX1_CTRL_FRAMECOUNTER(a6)

	rts


*****************************************************************************
* DrawText. 
* IN:		a5, custom
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

TX1_DrawText:
	; We only want to update mask values every 2nd frame so that we have a 
	; consistant image for double buffering
	lea	TX1_Controller_Info+TX1_CTRL_FRAMECOUNTER,a0
	moveq	#0,d5			;default amount to subtract from mask
	tst.w	(a0)
	bne.s	.draw

	move.w	#2,(a0)			;reset frame counter
	moveq	#1,d5			;subtract 1 from mask
.draw:
	subq.w	#1,(a0)

	;Setup blitter values that don't change 
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	;move.l	#$0fca0000,BLTCON0(a5)		
	move.l	#$0dc00000,BLTCON0(a5)		
	move.l	#-1,BLTAFWM(a5)
	move.w	#0,BLTAMOD(a5)				
	move.w	#TX1_Font_BlitModulo_1Bpl,BLTBMOD(a5)
	move.w	#TX1_Font_BlitModulo_nBplInt,BLTDMOD(a5)


	move.l	TX1_PF2_Work_Ptr,a0
	move.l	TX1_Controller_Info+TX1_CTRL_TEXTPTR,a1
	lea	TX1_Text_Pattern_Current,a2

	moveq	#0,d4			;all masks 0 flag

	moveq	#8,d1			;y pos
	moveq	#TX1_Text_Y_Blocks-1,d7
.yloop:
	moveq	#0,d0			;x pos
	moveq	#TX1_Text_X_Blocks-1,d6
.xloop:
	moveq	#0,d2			;zero top of word
	move.b	(a1)+,d2		;get letter to print

	moveq	#0,d3			;zero top of word
	move.b	(a2),d3			;get mask and check if in drawing range
	beq.s	.nodraw

	moveq	#1,d4			;still reducing masks

	sub.b	d5,d3			;reduce mask and store
	move.b	d3,(a2)

	cmpi.b	#TX1_Font_Mask_Max,d3	;check if in drawing range
	bgt.s	.nodraw

	movem.l	d0-d1/a0-a2,-(sp)
	bsr	TX1_PrintLetter		;draw the letter, trashes d0-d3,a0-a2
	movem.l	(sp)+,d0-d1/a0-a2

.nodraw:
	addq.l	#1,a2			;next mask
	addi.w	#16,d0			;next x value
	dbf	d6,.xloop
	
	addi.w	#16,d1			;next y value
	dbf	d7,.yloop

	; Have we finished?
	tst.w	d4
	bne.s	.exit

	; Next state is pausing
	lea	TX1_Controller_Info,a0
	move.w	#TX1_CTRL_STATE_PAUSE,TX1_CTRL_STATE(a0)
	move.w	#TX1_CTRL_STATE_PAUSE_START,TX1_CTRL_FRAMECOUNTER(a0)
.exit:
	rts


*****************************************************************************
* ClearText. 
* IN:		a5, custom
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

TX1_ClearText:
	; We only want to update mask values every 2nd frame so that we have a 
	; consistant image for double buffering
	lea	TX1_Controller_Info+TX1_CTRL_FRAMECOUNTER,a0
	moveq	#0,d5			;default amount to subtract from mask
	tst.w	(a0)
	bne.s	.draw

	move.w	#2,(a0)			;reset frame counter
	moveq	#1,d5			;subtract 1 from mask
.draw:
	subq.w	#1,(a0)

	move.l	TX1_PF2_Work_Ptr,a0
	lea	TX1_Text_Pattern_Current,a2

	moveq	#0,d4			;all masks 0 flag

	moveq	#8,d1			;y pos
	moveq	#TX1_Text_Y_Blocks-1,d7
.yloop:
	moveq	#0,d0			;x pos
	moveq	#TX1_Text_X_Blocks-1,d6
.xloop:
	moveq	#0,d3			;zero top of word
	move.b	(a2),d3			;get mask and check if in drawing range
	beq.s	.nodraw

	moveq	#1,d4			;still reducing masks

	sub.b	d5,d3			;reduce mask and store
	move.b	d3,(a2)

	cmpi.b	#1,d3			;check if in drawing range (start drawing when mask = 1)
	bgt.s	.nodraw

	movem.l	d0-d1/a0,-(sp)
	bsr	TX1_ClearLetter		;draw the letter, trashes d0-d3,a0-a2
	movem.l	(sp)+,d0-d1/a0

.nodraw:
	addq.l	#1,a2			;next mask
	addi.w	#16,d0			;next x value
	dbf	d6,.xloop
	
	addi.w	#16,d1			;next y value
	dbf	d7,.yloop

	; Have we finished?
	tst.w	d4
	bne.s	.exit

	; Next state is pausing
	lea	TX1_Controller_Info,a0
	move.w	#TX1_CTRL_STATE_POSTPAUSE,TX1_CTRL_STATE(a0)
	move.w	#TX1_CTRL_STATE_POSTPAUSE_START,TX1_CTRL_FRAMECOUNTER(a0)
.exit:
	rts


*****************************************************************************
* Print letter
* IN:		a0, screen ptr
*		d0.w, x (pixels)
*		d1.w, y (lines)
*		d2.w, ascii value of letter
*		d3.w, mask type 0, no draw, 1=fully draw - 7=slight draw
* OUT:		
* TRASHED:	d0-d3/a0-a2
*****************************************************************************

;A=mask
;B=font
;D=screen
; We don't need to fetch the screen for or'ing as we obilterate the 16x16 block
; each blit. So just D=1 when mask+font is 1

; A B C   D
; 0 0 0   0
; 0 0 1   0
; 0 1 0   0
; 0 1 1   0
; 1 0 0   0
; 1 0 1   0
; 1 1 0   1
; 1 1 1   1
;
; ABD = $d
;  LF = $c0


TX1_PrintLetter:
	;if mask is zero don't draw it
	;if mask is greater than TX1_Font_Mask_Max, don't draw it
	tst.w	d3
	beq	.exit
	cmpi.w	#TX1_Font_Mask_Max,d3
	bgt.s	.exit

	subq.w	#1,d3			;1-7 -> 0-6 for offset
	lea	TX1_Font_Bitmap_Mask,a2	;mask
	mulu	#TX1_Font_ByteWidth*TX1_Font_Height,d3
	add.l	d3,a2

	mulu	#TX1_SCR_ByteWidth*TX1_SCR_PF2_NumPlanes,d1	;get y byte offset
	add.l	d1,a0			;add to screen adr
	lsr.w	#3,d0			;pixels > bytes
	add.w	d0,a0			;a0=final screen address for 1st bpl

	subi.w	#30,d2							
	lea	TX1_IceFont_Matrix,a1	;font position look up table
	add.w	d2,d2			;access in words
	move.w	(a1,d2.w),d1
	add.w	#TX1_Font_Bitmap_YOffsetPixels*TX1_Font_Bitmap_ByteWidth,d1
	lea	TX1_IceFont+TX1_Font_Bitmap_XOffsetBytes,a1
	add.w	d1,a1			;a1=final address in font bitmap

	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
;	move.l	#$0dc00000,BLTCON0(a5)		
;	move.l	#-1,BLTAFWM(a5)
;	move.w	#0,BLTAMOD(a5)				
;	move.w	#TX1_Font_BlitModulo_1Bpl,BLTBMOD(a5)
;	move.w	#TX1_Font_BlitModulo_nBplInt,BLTDMOD(a5)
	
	;move.l	a1,BLTBPTH(a5)		
	;move.l	a2,BLTAPTH(a5)		
	movem.l	a1-a2,BLTBPTH(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	#TX1_Font_Height*64+TX1_Font_WordWidth,BLTSIZE(a5)

.exit:
	rts



*****************************************************************************
* Clear letter
* IN:		a0, screen ptr
*		d0.w, x (pixels)
*		d1.w, y (lines)
*		d2.w, ascii value of letter
*		d3.w, mask type 0, no draw, 1=fully draw - 7=slight draw
* OUT:		
* TRASHED:	d0-d1/a0
*****************************************************************************

TX1_ClearLetter:
	mulu	#TX1_SCR_ByteWidth*TX1_SCR_PF2_NumPlanes,d1	;get y byte offset
	add.l	d1,a0			;add to screen adr
	lsr.w	#3,d0			;pixels > bytes
	add.w	d0,a0			;a0=final screen address for 1st bpl

	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.l	#$01000000,BLTCON0(a5)		
	move.w	#TX1_Font_BlitModulo_nBplInt,BLTDMOD(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	#TX1_Font_Height*64+TX1_Font_WordWidth,BLTSIZE(a5)

	rts

*****************************************************************************


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	TX1_Data1,DATA	;Public data section for variables
	
*****************************************************************************

*** Program Variables ***
TX1_Initialised:
	dc.w	0
TX1_Finished:
	dc.w	0

; Screen buffer pointers
TX1_PF1_Screen_Ptr:		dc.l	0
TX1_PF1_Work_Ptr:		dc.l	0

TX1_PF2_Screen_Ptr:		dc.l	0
TX1_PF2_Work_Ptr:		dc.l	0

TX1_Mult_Height_PF1_NumPlanes:
a set 0
	REPT TX1_SCR_Height
	dc.w	a*TX1_SCR_ByteWidth*TX1_SCR_PF1_NumPlanes
a set a+1
	ENDR

	RSRESET
TX1_CTRL_STATE:			rs.w 1		;Routine state
TX1_CTRL_FRAMECOUNTER:		rs.w 1		;Frame counter, set to a value and decrement
TX1_CTRL_TEXTPTR:		rs.l 1		;The text page/pages to show
TX1_CTRL_PALETTE_STEP:		rs.w 1		;The palette step 1-15 
TX1_CTRL_SIZE:			rs.w 0

	EVEN
TX1_Controller_Info:
	dcb.b	TX1_CTRL_SIZE,0			;Zeroed
	EVEN

TX1_CTRL_STATE_FADEIN		= 0
TX1_CTRL_STATE_FADEOUT		= 1
TX1_CTRL_STATE_PREPAUSE		= 2
TX1_CTRL_STATE_TEXTDRAW		= 3
TX1_CTRL_STATE_PAUSE		= 4
TX1_CTRL_STATE_TEXTCLEAR	= 5
TX1_CTRL_STATE_POSTPAUSE	= 6
TX1_CTRL_STATE_QUIT		= 7


TX1_CTRL_STATE_PREPAUSE_START	= 100
TX1_CTRL_STATE_PAUSE_START	= 300
TX1_CTRL_STATE_POSTPAUSE_START	= 50
TX1_CTRL_FADE_SPEED		= 2

; 20 chars width,10 high
TX1_Text_Pattern_Current:
	dcb.b	TX1_Text_X_Blocks*TX1_Text_Y_Blocks,0

TX1_Text_Pattern1:
a set 2
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+12	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+12	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+12	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+12	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+12	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+12	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+12	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+12	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+12
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+12	


TX1_Text_Pattern2:
a set 2
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+2	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+2
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+2	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+2	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+2	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+2	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+2	
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+2	
	dc.b	a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9,a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a
a set a+2
	dc.b	a+9,a+8,a+7,a+6,a+5,a+4,a+3,a+2,a+1,a,a,a+1,a+2,a+3,a+4,a+5,a+6,a+7,a+8,a+9
a set a+2	


	EVEN
TX1_Text1:
	DC.B	"SCREEN 1            "
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"

	DC.B	"SCREEN 2            "
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"
	DC.B	"12345678901234567890"

	DC.B	0,0			; END

	EVEN
TX1_Text_Intro:
	DC.B	"WELCOME TO MY RETRO "
	DC.B	"LAMETRO OF SHOCKING "
	DC.B	" COPPER REFLECTION  "
	DC.B	"      ABUSE :)      "
	DC.B	"                    "
	DC.B	" JUST A QUICK INTRO "
	DC.B	" TO SEE IF I COULD  "
	DC.B	"CODE SOMETHING AGAIN"
	DC.B	"IN 2019 AFTER A BOUT"
	DC.B	"    OF NOSTALGIA!   "

	DC.B	"  ALSO I WANTED TO  "
	DC.B	"   FINALLY CODE A   "
	DC.B	" COUPLE OF EFFECTS  "
	DC.B	"THAT I LOVED FROM MY"
	DC.B	" FAVE DEMOS OF OLD. "
	DC.B	"                    "
	DC.B	"I WAS TOO STUPID AT "
	DC.B	"  THE TIME TO WORK  "
	DC.B	"THEM OUT BUT NOW WE "
	DC.B	"HAVE RETRO FORUMS :)"

	DC.B	0,0			; END

	EVEN
TX1_Text_Vectors
	DC.B	" FINALLY WORKED OUT "
	DC.B	"  GLENZ VECTORS 25  "
	DC.B	" YEARS TOO LATE :(  "
	DC.B	"                    "
	DC.B	"   LETS SEE IF WE   "
	DC.B	"CAN GO FROM COMPLEX "
	DC.B	"VECTORS RUNNING IN  "
	DC.B	"2 FRAMES TO A GLENZ "
	DC.B	" VECTOR IN 1 FRAME  "
	DC.B	"   WITH NO CUTS :)  "
	DC.B	0,0			; END

	EVEN
TX1_Text_VectorRepublic:
	DC.B	"   HERE IS A LOGO   "
	DC.B	"    FOR CHRIS AT    "
	DC.B	"                    "
	DC.B	"  VECTOR  REPUBLIC  "
	DC.B	"                    "
	DC.B	" GOOD LUCK WITH THE "
	DC.B	"  NEW VECTREX GAME  "
	DC.B	"      --------      "
	DC.B	"      FRONTIER      "
	DC.B	"      --------      "
	DC.B	0,0			; END

	EVEN
TX1_Text_BOBSnake:
	DC.B	" THIS WAS THE FIRST "
	DC.B	" EFFECT I DID WHILE "
	DC.B	"RELEARNING ASSEMBLER"
	DC.B	"                    "
	DC.B	" SOME 8 COLOUR BOBS "
	DC.B	"                    "
	DC.B	"SUPER LAME EVEN FOR "
	DC.B	" 1989 BUT THEY ARE  "
	DC.B	"   STAYING IN ON    "
	DC.B	"     PRINCIPLE!     "

	DC.B	0,0			; END

	EVEN
TX1_Text_Credits:
	DC.B	"      CREDITS       "
	DC.B	"                    "
	DC.B	"   CODE AND MUSIC   "
	DC.B	"      ANTIRIAD      "
	DC.B	"                    "
	DC.B	"                    "
	DC.B	" GRAPHICS ALL FROM  "
	DC.B	"  VARIOUS INTERNET  "
	DC.B	"   LOGO AND MEME    "
	DC.B	"  GENERATORS :) :)  "

	DC.B	"GREETINGS AND THANKS"
	DC.B	"                    "
	DC.B	"CHRIS, HUGO AND LUIS"
	DC.B	"                    "
	DC.B	" THE CODERS AT EAB! " 
	DC.B	"                    "
	DC.B	"PHOTON/SCOOPEX FOR  "
	DC.B	"HIS YOUTUBE TUTORIAL"
	DC.B	"WHICH HELPED ME READ"
	DC.B	"MY OLD ASM SOURCES! "

	DC.B	0,0			; END

	EVEN

*****************************************************************************

TX1_Palette_AllBlack16:
	dcb.w	16,0

TX1_Palette_Logo:
	dcb.w	(1<<TX1_TopLogo_NumPlanes),0

TX1_Palette_Stars:	;7 colors, skipping col00
	dc.w	$fff,$ccc,$aaa,$888,$666,$444,$222

TX1_BAR_COLOR = $ddd

*****************************************************************************

	EVEN
TX1_IceFont_Matrix:
	dc.w 0		
	dc.w 4		
	dc.w 8			;SPACE
	dc.W 12			;!
	dc.W 16			;"
	dc.W 20			;#
	dc.W 24			;$
	dc.W 28			;%
	dc.W 32			;&
	dc.W 36			;'
	dc.W (16*40)+0		;(
	dc.W (16*40)+4		;)
	dc.W (16*40)+8		;*
	dc.W (16*40)+12		;+
	dc.W (16*40)+16		;,
	dc.W (16*40)+20		;-
	dc.W (16*40)+24		;.	
	dc.W (16*40)+28		;/
	dc.W (16*40)+32		;0
	dc.W (16*40)+36		;1
	
	DC.W (32*40)+0		;2
	dc.W (32*40)+4		;3
	dc.W (32*40)+8		;4
	dc.W (32*40)+12		;5
	dc.W (32*40)+16		;6
	dc.W (32*40)+20		;7
	dc.W (32*40)+24		;8
	dc.W (32*40)+28		;9
	dc.W (32*40)+32		;:
	dc.W (32*40)+36		;;
	
	DC.W (48*40)+0		;<
	dc.W (48*40)+4		;=
	dc.W (48*40)+8		;>
	dc.W (48*40)+12		;?
	dc.W (48*40)+16		;@
	dc.W (48*40)+20		;A
	dc.W (48*40)+24		;B
	dc.W (48*40)+28		;C
	dc.W (48*40)+32		;D
	dc.W (48*40)+36		;E
	
	DC.W (64*40)+0		;F
	dc.W (64*40)+4		;G
	dc.W (64*40)+8		;H
	dc.W (64*40)+12		;I
	dc.W (64*40)+16		;J
	dc.W (64*40)+20		;K
	dc.W (64*40)+24		;L
	dc.W (64*40)+28		;M
	dc.W (64*40)+32		;N
	dc.W (64*40)+36		;O

	DC.W (80*40)+0		;P
	dc.W (80*40)+4		;Q
	dc.W (80*40)+8		;R
	dc.W (80*40)+12		;S
	dc.W (80*40)+16		;T
	dc.W (80*40)+20		;U
	dc.W (80*40)+24		;V
	dc.W (80*40)+28		;W
	dc.W (80*40)+32		;X
	dc.W (80*40)+36		;Y
	
	dc.W (96*40)+0 		;Z
	EVEN

*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	TX1_PublicBSS,BSS	;Public blank memory


TX1_XYZpts:
	ds.w	TX1_NUMSTARS*3	;x,y,z
	
TX1_PersXYpts:
	ds.w	TX1_NUMSTARS*3	;x,y,color


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	TX1_ChipData1,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************

*** THE COPPERLISTS ***
	CNOP 0,8	; 64 bit alignment for AA
TX1_CL:
	CMOVE	FMODE,MemoryFetchMode		;Chip Ram fetch mode (0=OCS)
	
	CWAIT	DIW_V-2,$7		;Time for altering Copperlist
	
	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,DIW_Start
	CMOVE 	DIWSTOP,DIW_Stop
	CMOVE 	DDFSTRT,DDF_Start
	CMOVE 	DDFSTOP,DDF_Stop
	CMOVE 	BPLCON0,$4200		;LOGO - 4bpl/16 cols
	CMOVE 	BPLCON1,$0000
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,0
	CMOVE 	BPL2MOD,0

TX1_CL_TopLogo_Bpl:
	CMOVE	BPL1PTH,$0
	CMOVE	BPL1PTL,$0
	CMOVE	BPL2PTH,$0
	CMOVE	BPL2PTL,$0
	CMOVE	BPL3PTH,$0
	CMOVE	BPL3PTL,$0
	CMOVE	BPL4PTH,$0
	CMOVE	BPL4PTL,$0

	CWAIT	DIW_V,$7			;Color00 used in logo, so have to change colors at last minute
TX1_CL_TopLogo_Cols:
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ELSE
		CMOVE	COLOR01,$000		; If testing then just use color01 twice
	ENDC
	CMOVE	COLOR01,$f00
	CMOVE	COLOR02,$f00
	CMOVE	COLOR03,$f00
	CMOVE	COLOR04,$f00
	CMOVE	COLOR05,$f00
	CMOVE	COLOR06,$f00
	CMOVE	COLOR07,$f00
	CMOVE	COLOR08,$f00
	CMOVE	COLOR09,$f00
	CMOVE	COLOR10,$f00
	CMOVE	COLOR11,$f00
	CMOVE	COLOR12,$f00
	CMOVE	COLOR13,$f00
	CMOVE	COLOR14,$f00
	CMOVE	COLOR15,$f00


	CWAIT	DIW_V+TX1_TopLogo_Height,$7
	CMOVE	BPLCON0,$0200			; Screen off

TX1_CL_TopBar_Col:
	IFEQ	RasterTest
		CMOVE	COLOR00,$EEE	; Top border bar
	ELSE
		CMOVE	COLOR01,$000	; If testing then just use color01
	ENDC

TX1_CL_PF1_Bpl:			;Bitplane pointers playfield 1
	CMOVE	BPL1PTH,$0
	CMOVE	BPL1PTL,$0
	CMOVE	BPL3PTH,$0
	CMOVE	BPL3PTL,$0
	CMOVE	BPL5PTH,$0
	CMOVE	BPL5PTL,$0

TX1_CL_PF2_Bpl:			;Bitplane pointers playfield 2
	CMOVE	BPL2PTH,$0
	CMOVE	BPL2PTL,$0
	CMOVE	BPL4PTH,$0
	CMOVE	BPL4PTL,$0

TX1_CL_PF1_Cols:			;PF1 (stars) is 8 colours
	CMOVE	COLOR01,$fff		;No color 00, beware
	CMOVE	COLOR02,$ccc
	CMOVE	COLOR03,$aaa
	CMOVE	COLOR04,$888
	CMOVE	COLOR05,$666
	CMOVE	COLOR06,$444
	CMOVE	COLOR07,$222

TX1_CL_PF2_Cols:			;PF2 (text) is 4 colours
	CMOVE	COLOR08,$000
	CMOVE	COLOR09,$fff		;col1
	;CMOVE	COLOR10,$f00		;col2
	;CMOVE	COLOR11,$f00		;col3

	CWAIT	DIW_V+TX1_TopLogo_Height+2,$7		; After top bar
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ENDC

	CMOVE 	BPLCON0,$5600		;dual playfield 3bpl + 2bpl
	CMOVE	BPLCON2,$0040		;PF2 has priority (text in front of stars)
	CMOVE 	BPL1MOD,TX1_SCR_ByteWidth*(TX1_SCR_PF1_NumPlanes-1)	;interleaved mode
	CMOVE 	BPL2MOD,TX1_SCR_ByteWidth*(TX1_SCR_PF2_NumPlanes-1)

; Start text color gradient
	IFEQ RasterTest
	CWAIT 114,$7
	DC.W COLOR09,$fff
	CWAIT 120,$7
	DC.W COLOR09,$fee
	CWAIT 125,$7
	DC.W COLOR09,$fdd
	CWAIT 130,$7
	DC.W COLOR09,$fcc
	CWAIT 135,$7
	DC.W COLOR09,$fdd
	CWAIT 140,$7
	DC.W COLOR09,$fee
	CWAIT 145,$7
	DC.W COLOR09,$fff
	CWAIT 150,$7
	DC.W COLOR09,$eef
	CWAIT 155,$7
	DC.W COLOR09,$ddf
	CWAIT 160,$7
	DC.W COLOR09,$ccf
	CWAIT 165,$7
	DC.W COLOR09,$ddf
	CWAIT 170,$7
	DC.W COLOR09,$eef
	CWAIT 175,$7
	DC.W COLOR09,$fff
	CWAIT 180,$7
	DC.W COLOR09,$efe
	CWAIT 185,$7
	DC.W COLOR09,$dfd
	CWAIT 190,$7
	DC.W COLOR09,$cfc
	CWAIT 195,$7
	DC.W COLOR09,$dfd
	CWAIT 200,$7
	DC.W COLOR09,$efe
	CWAIT 205,$7
	DC.W COLOR09,$fff
	CWAIT 210,$7
	DC.W COLOR09,$eef
	CWAIT 215,$7
	DC.W COLOR09,$fff
	CWAIT 220,$7
	DC.W COLOR09,$fee
	CWAIT 225,$7
	DC.W COLOR09,$fdd
	CWAIT 230,$7
	DC.W COLOR09,$fcc
	CWAIT 235,$7
	DC.W COLOR09,$fdd
	CWAIT 240,$7
	DC.W COLOR09,$fee
	CWAIT 245,$7
	DC.W COLOR09,$fff
	ENDC


	CWAIT	255,$E1			;Wait for line > 255
	CWAIT	37,$7			;292	
	CMOVE	BPLCON0,$0200 		;Screen off

TX1_CL_BottomBar_Col:
	IFEQ	RasterTest
		CMOVE	COLOR00,$EEE	; Bottom border bar
	ELSE
		CMOVE	COLOR01,$000	; If testing then just use color01
	ENDC

	CWAIT	39,$7

	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ENDC

TX1_CL_AntLogo_Col:
	CMOVE	COLOR01,$FFF		;White for antiriad logo
	
	CWAIT	40,$7
	CMOVE	BPLCON0,$1200
	CMOVE	BPLCON2,$0000
	CMOVE 	BPL1MOD,$0		;1 bitplane normal mode
	CMOVE 	BPL2MOD,$0
TX1_CL_AntLogo_Bpl:
	CMOVE	BPL1PTH,$0		
	CMOVE	BPL1PTL,$0

	;CWAIT	31+4,$7
	;CMOVE	BPLCON0,$0200		;All off

	COPPEREND

*****************************************************************************
;Masks for 12x14 font, right aligned (so 4 blank pixels on the left)
;have two fully draw masks (1 and 2) to make it easier for doublebuffering
;mask 0 is no draw (for speed)
	EVEN
TX1_Font_Bitmap_Mask:
;1
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
	dc.w	%0000111111111111
;2
	dc.w	%0000000000000000
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000011111111110
	dc.w	%0000000000000000
;3
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000001111111100
	dc.w	%0000000000000000
	dc.w	%0000000000000000

;4
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000111111000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

;5
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000011110000
	dc.w	%0000000011110000
	dc.w	%0000000011110000
	dc.w	%0000000011110000
	dc.w	%0000000011110000
	dc.w	%0000000011110000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

;6
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000001100000
	dc.w	%0000000001100000
	dc.w	%0000000001100000
	dc.w	%0000000001100000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

;7
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

*****************************************************************************
;Logo
	CNOP 0,8	; 64 bit alignment for AA
TX1_TopLogo:
	INCBIN "gfx/parcade_logo2_320x70x4.raw"

	CNOP 0,8	; 64 bit alignment for AA
TX1_IceFont:
	INCBIN "gfx/icefont_320x112.raw"
					
*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	TX1_ChipBss1,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************

;Screen1	ds.b	Screen_TotalSize
;Work1	ds.b	Screen_TotalSize

*****************************************************************************
