*****************************************************************************

; Name			: BigSineScroller.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Huge sine scroller.
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

	SECTION	SIN_Code,CODE	;Code section in Public memory

*****************************************************************************
*** Changeable Parameters For Display ***

*** Display Window ***

; Photon:
; Best practice is to start with DDF 38,d0 and DIW 2c81,2cc1 and modify these 
; symmetrically and always in whole 16px steps for compatibility.
; Note DDF start of less than 30 and you start to lose sprites.

SIN_DIW_V		=	$24	;Hardware Vstart ($2c normal, $24 overscan)
SIN_DIW_H		=	$71	;Hardware Hstart ($81 normal, $71 overscan)
SIN_DIW_Width		=	352	;Pixels		 (multiple of 16, 320 normal, 352 overscan)
SIN_DIW_Height		=	272	;Lines		 (256 normal PAL, 272 overscan)

*** Data Fetch ***

SIN_MemoryFetchMode	=	0	;0,1 or 3 
; When FMode=0,1,3 DDF_Width must be a multiple of 16,32,64 respectively.
; NB. I can't get FMODE=2 to work - sorry.
; 0=OCS/ECS, 3=AA in practice
; Bitplane, copper and sprite data should be 64bit (CNOP 0,8) aligned so that it can work
; in ECS/AA modes.
; Bitplanes should be multiples of 64bits wide to take maximum advantage of bandwidth
; 320 or 384 pix which.

SIN_DDF_H		=	$71	;Hardware Hstart ($81 normal, $71 overscan)
SIN_DDF_Width		=	352	;Pixels		 (320 normal pal, 352 overscan)

*****************************************************************************

*** Non-changable parameters for display - Automatically calculated from above ***

SIN_DIW_Vstart		=	(SIN_DIW_V&$ff)<<8
SIN_DIW_Vstop		=	((SIN_DIW_V+SIN_DIW_Height)&$ff)<<8
SIN_DIW_Hstart		=	SIN_DIW_H&$ff
SIN_DIW_Hstop		=	(SIN_DIW_Hstart+SIN_DIW_Width)&$ff
SIN_DIW_Start		=	SIN_DIW_Vstart!SIN_DIW_Hstart
SIN_DIW_Stop		= 	SIN_DIW_Vstop!SIN_DIW_Hstop

	IFEQ	SIN_MemoryFetchMode
SIN_DDF_Increment		=	1
	ENDC
	IFNE	SIN_MemoryFetchMode
SIN_DDF_Increment		=	(SIN_DDF_FetchMode+1)&$fffe
	ENDC	

SIN_DDF_WordWidth	=	SIN_DDF_Width/16
SIN_DDF_Start		=	(SIN_DDF_H/2)-8
SIN_DDF_Stop		=	SIN_DDF_Start+((SIN_DDF_WordWidth-SIN_DDF_Increment)*8)

*** Screen Definitions ***

;The memory sizes for screen area and back buffer - may be wider/taller than what we display
;For this routine we have an extra 
SIN_Screen_Width		=	352 	; Must be multiple of 16, ideally 64pix multiple for best AA perf
SIN_Screen_ByteWidth		=	SIN_Screen_Width/8	;Bytes
SIN_Screen_WordWidth		=	SIN_Screen_ByteWidth/2	;Words
SIN_Screen_Height		=	224+8	;8 lines overscan at top 
SIN_Screen_NumPlanes		=	1	; 1bpl/2 cols
SIN_Screen_Size			=	SIN_Screen_ByteWidth*SIN_Screen_Height
SIN_Screen_TotalSize		=	SIN_Screen_Size*SIN_Screen_NumPlanes

SIN_Reflection_DIW_H		=	268	;line to start the reflection

; The actual font details
SIN_Font_Height			=	8	; Real height with no extra pixels
SIN_Font_PixelWidth		=	61	; Pixel width, may be smaller. Used for spacing.
SIN_Font_HeightMultiplier	=	16	; final height will be (SIN_Font_Height-1) * SIN_Font_HeightMultiplier

SIN_Font_Bitmap_Width		=	320
SIN_Font_Bitmap_ByteWidth	=	SIN_Font_Bitmap_Width/8
SIN_Font_Bitmap_Height		=	224

; The font matrix picks out a word aligned block in the font sheet. Usually the fonts aren't
; perfectly aligned so we need to adjust the Y position (lines) to match exactly
; Also may need to offset the word boundary. For example 16x16 font uses a 32x32 matrix but
; the font is stored in the bottom right of each cell. So YOffsetPixels=16, and XOffsetBytes=2
SIN_Font_Bitmap_YOffsetPixels	=	0	
SIN_Font_Bitmap_XOffsetBytes	=	0

; The buffer that the scroller uses. After scrolling this is plotted onto the back buffer
; in a sine wave. It can be made a touch wider than the screen for smooth scrolling. New letters will be plotted
; At the right edge of this buffer minus SIN_Scroller_ExtraByteWidth
; NOTE: Min size is Screen Width. Add the font width in multiples of 16. We will add 64 for our
; large font (we are converting 8px wide font to 64 px wide)
SIN_Scroller_ExtraWidth		=	64
SIN_Scroller_ExtraByteWidth	= 	SIN_Scroller_ExtraWidth/8

SIN_Scroller_Width		=	SIN_Screen_Width+SIN_Scroller_ExtraWidth
SIN_Scroller_ByteWidth		=	SIN_Scroller_Width/8		;Bytes
SIN_Scroller_WordWidth		=	SIN_Scroller_ByteWidth/2	;Words
SIN_Scroller_Height		=	SIN_Font_Height
SIN_Scroller_NumPlanes		=	1
SIN_Scroller_Size		=	SIN_Scroller_ByteWidth*SIN_Scroller_Height
SIN_Scroller_TotalSize		=	SIN_Scroller_Size*SIN_Scroller_NumPlanes

*****************************************************************************

*****************************************************************************
* Called ONCE per routine, no matter how many times the routine is used
* Use for one-time setup
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	
*****************************************************************************

SIN_Init:
	move.w	#1,SIN_Initialised

	; Multiple sine values by screen widths
	bsr	SIN_PreMult_SineForScreen

	; Convert font bitmap to xor'ed version for vertical fill
	lea	SineFont3,a0	
	move.w	#SIN_Font_Bitmap_ByteWidth,d0
	move.w	#SIN_Font_Bitmap_Height,d1
	bsr	SIN_BitmapToVFill

	rts

*****************************************************************************
* Start the effect (usually used for setting up the copper)
* This is called each time the effect is started
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

	IFND _INTROWRAPPER
SubPartStart:	
	lea	SIN_Text1,a0
	ENDC

SIN_Start:
	; Save parameters
	move.l	a0,SIN_TextPtr

	; Have we already done any one-time setup routines?
	tst.w	SIN_Initialised
	bne.s	.alreadyinit
	bsr.s	SIN_Init
.alreadyinit:
	lea	CUSTOM,a5

	;Clear all the buffers we will use
	bsr	SIN_Clear_All_Buffers_A5

	; Reset sines to default and initialise other sine variables
	bsr.s	SIN_Init_Sine_Params

	; Init copper pointers
	bsr	SIN_InitCopper

	; At EOF and swap copper list
	; Main routine has bitplanes off so safe to clear first
	WAITBLIT_A5
	jsr	WaitEOF_A5
	move.l 	#SIN_CL,COP1LCH(a5)	; Active NEXT frame

.fin
	; Continue with main loop
	bra	SIN_MainLoop
	rts


*****************************************************************************
* Resets sine values to defaults.
* IN:		
* OUT:		
* TRASHED:	
*****************************************************************************

SIN_Init_Sine_Params:
	movem.l	d0/a0,-(sp)

	lea	SIN_Sine_Params,a0

	moveq	#0,d0
	move.w	d0,SIN_LastLetterFrameCount(a0)
	move.w	d0,SIN_StopScroll(a0)
	bsr.s	SIN_Reset_Sine_Params
	
	movem.l	(sp)+,d0/a0
	rts

SIN_Reset_Sine_Params:
	movem.l	d0/a0,-(sp)

	lea	SIN_Sine_Params,a0

	moveq	#0,d0
	move.w	d0,SIN_Sine1_Offset(a0)
	move.w	d0,SIN_Sine2_Offset(a0)
	move.w	#-4,SIN_Sine1_Speed(a0)	;motion per frame
	move.w	#3,SIN_Sine1_Step(a0)	;motion per pixel
	move.w	d0,SIN_Sine2_Speed(a0)
	move.w	d0,SIN_Sine2_Step(a0)

	move.w	#3,SIN_Speed(a0)

	movem.l	(sp)+,d0/a0
	rts


*****************************************************************************
* Converts a bitmap into something that can be used for blitter vertical filling.
* Thanks Dan Scott for the code.
* IN:		a0, pointer to bitmap
*		d0, bitmap width in bytes
*		d1, bitmap height in lines
* OUT:		
* TRASHED:	d0-d4/d6/d7/a0
*****************************************************************************

SIN_BitmapToVFill:
		move.w	d0,d6
		subq	#1,d6
.XLoop	
		moveq	#0,d2
		move.w	d1,d7
		subq	#1,d7
		moveq	#0,d4
.YLoop	
		move.b	(a0,d2.w),d3
		eor.b	d3,d4
		move.b	d4,(a0,d2.w)
		move.b	d3,d4
		add.w	d0,d2
		dbra	d7,.YLoop
		addq.w	#1,a0
		dbra	d6,.XLoop
		
		rts


*****************************************************************************
* Runs the effect.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		d0(0=Running, 1=Ending)
* TRASHED:	d0
*****************************************************************************

SIN_MainLoop:
	clr.w	SIN_Finished

	lea	CUSTOM,a5
.Mainloop1:
	BLIT_NASTY_OFF_A5			; Default is no blitter nasty

	TIMERON	$111

	; Full screen clear+CPU
	bsr	SIN_Clear_WorkBuffer_A5

	; Plot new letters if needed, and scroll hidden scroll
	bsr	SIN_PrintAndScroll
	tst.w	SIN_Finished
	bne.s	.fin

	; Now blit the scroll buffer to the screen following the generated sine wave
	bsr	SIN_CopyScrollToSine

	; Now vertical fill
	bsr	SIN_VerticalFill

	; Turn blitter nasty on for final blitter ops
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5

	TIMEROFF


	; Wait for overscan EOF and Double buffer
	move.w	#SIN_DIW_V+SIN_DIW_Height,d0
 	jsr	WaitRaster_A5
	bsr	SIN_DoubleBufferSwap
	
.Testmouse
	btst 	#10-8,POTGOR(a5)	;rmb quits section
	beq.s	.fin
	btst 	#6,$bfe001		;lmb quits all
	bne.s 	.Mainloop1
	move.w	#1,Quit_Flag
.fin	
	; Restore copper for main routine
	lea	CUSTOM,a5
	jsr	SetBaseCopperAndDma_A5

	moveq	#1,d0		;Signal finished
	rts

*****************************************************************************

SIN_InitCopper:
;Init. physical & logical screen addresses
	move.l	#Screen_Buffer,d1
	move.l	d1,SIN_Screen_Ptr		;Physical screen adr
	move.l	#Work_Buffer,SIN_Work_Ptr	;Logical screen adr

	;move.l 	#SIN_CL_Screen_Bpl,a0
	;moveq	#SIN_Screen_NumPlanes,d0
	;move.w 	#SIN_Screen_Size,d2	;non-interleaved
	;jsr	InitCopperBplPtrs
	; Just run double buffer swap to update the copper bitmap pointers
	bsr.s SIN_DoubleBufferSwap

	rts

*****************************************************************************
* Swaps the screens
* IN:		
* OUT:		
* TRASHED:	d0-d1/a0
*****************************************************************************

SIN_DoubleBufferSwap:
	move.l	SIN_Work_Ptr,d0		;Get logical adr
	move.l	SIN_Screen_Ptr,SIN_Work_Ptr	;Swap logical & physical
	move.l	d0,SIN_Screen_Ptr		;Save physical

;	move.l 	#SIN_CL_Screen_Bpl,a0		;Adr of copper pointers
;	moveq.l	#SIN_Screen_NumPlanes-1,d1	;Number of bitplanes
;.loop
;	swap	d0			;Swap high & low words
;	move.w	d0,2(a0)		;High ptr
;	swap	d0			;Swap high & low words
;	move.w	d0,6(a0)		;Low ptr
;	addq.l	#8,a0			;Next set of ptrs
;	addi.l	#SIN_Screen_Size,d0	;Next bitplane (non-interleaved)

;	dbf	d1,.loop		

	; 2nd bitplane is offset SIN_Screen_ShadowHeight lines for a cheap shadow
	lea	SIN_CL_Screen_Bpl,a0		;Adr of copper pointers
	moveq.l	#2-1,d1			;Number of bitplanes - 1 bpl really, 2nd is shadow
.loop
	swap	d0			;Swap high & low words
	move.w	d0,2(a0)		;High ptr
	swap	d0			;Swap high & low words
	move.w	d0,6(a0)		;Low ptr
	addq.l	#8,a0			;Next set of ptrs
	
	; Don't add anything to d0. We use the same address for shadow bitplane

	dbf	d1,.loop		


	rts

*****************************************************************************
* Clears the work buffer screen. Done every frame.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0-d7,a0-a4
*****************************************************************************

SIN_Clear_WorkBuffer_A5:

; Tune this so that the very first WAITBLIT call AFTER this
* routine should take no time at all.
SSClear_BlitHeight = 150;140
SSClear_CPUHeight = (SIN_Screen_Height-SSClear_BlitHeight)

	move.l  SIN_Work_Ptr,a0		; memory to clear

	; Blitter

	;BLIT_NASTY_ON_A5
	WAITBLIT_A5
	;BLIT_NASTY_OFF_A5
	move.l	#$01000000,BLTCON0(a5)
	move.w	#0,BLTDMOD(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	#SSClear_BlitHeight*64+(SIN_Screen_WordWidth*SIN_Screen_NumPlanes),BLTSIZE(a5)

	; CPU

	; a0 = buffer to clear, we need to skip the part cleared by the blitter
	; d7 = size in bytes to clear
	lea	SSClear_BlitHeight*SIN_Screen_ByteWidth*SIN_Screen_NumPlanes(a0),a0
	move.l	#SSClear_CPUHeight*SIN_Screen_ByteWidth*SIN_Screen_NumPlanes,d7
	jmp	CPUClearBuffer

	;rts

*****************************************************************************
* Clear ALL the buffers we will use. Done once at startup.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0
*****************************************************************************

SIN_Clear_All_Buffers_A5:
	
	WAITBLIT_A5
	move.l	#$01000000,BLTCON0(a5)
	move.w	#0,BLTDMOD(a5)
	move.l	#Scratch_Buffer,BLTDPTH(a5)
	move.w	#SIN_Scroller_Height*64+(SIN_Scroller_WordWidth),BLTSIZE(a5)

	WAITBLIT_A5
	move.l	#Screen_Buffer,BLTDPTH(a5)
	move.w	#SIN_Screen_Height*64+(SIN_Screen_WordWidth*SIN_Screen_NumPlanes),BLTSIZE(a5)

	WAITBLIT_A5
	move.l	#Work_Buffer,BLTDPTH(a5)
	move.w	#SIN_Screen_Height*64+(SIN_Screen_WordWidth*SIN_Screen_NumPlanes),BLTSIZE(a5)

	rts



*****************************************************************************
* Premultiplies the sine values by the screen width so we can skip some mults.
* IN:	
* OUT:		
* TRASHED:	
*****************************************************************************

SIN_PreMult_SineForScreen:	
	lea	SIN_Sine,a1

	move.w #SIN_Sine_NumEntries-1,d7
.loop:
	move.w	(a1),d0
	muls.w 	#SIN_Screen_ByteWidth,d0	; Values are positive and negative
	
	; truncate (assume no overflow and store)
	move.w 	d0,(a1)+

	dbf	d7,.loop
	rts



*****************************************************************************
* Copies the scroller from the scroll buffer and plots in a sine wave.
* Tried various blitter nasty tweaks. But running with blitter nasty off is
* a few cycles quicker in this case becuase of the CPU code run outside each
* blit. Also tried precalculating all the sines up front each frame but not
* faster.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	
*****************************************************************************

;a0 - Sine points ptr (premult by screen width in bytes)
;a1 - temp for writing blit registers quickly
;a2 - BLTAFWM(a5) speed up blitter loading
;a3 - Work_adr
;a4 - scroller buffer (source)
;a5 - custom
;a6 - Screen buffer (Destination)
;d0 - BLTSIZE
;d1 - blit loop count / #6 for blitwait (swap every 16 pixels)
;d2 - ROT mask
;d3 - Sine1 and Sine2 step in hi and lo words (offset into sine table)
;d4 - $0400 - blitter nasty off flag
;d5 - Sine offset mask (duplicated in hi and lo words)
;d6 - Sine1 and Sine2 Offset in hi/lo words (offsets into sine table)
;d7 - $8400 - blitter nasty on flag

; Do OR blit
BlitSine	MACRO
	move.l	a3,a6				;scr adr
	swap	d6				;sine1 offset to loword
	add.w 	(a0,d6.w),a6		        ;add sine 1 (premult)
	swap	d6				;sine2 offset to loword
	add.w	(a0,d6.w),a6		        ;add sine 2 (premult)
	add.l	d3,d6				;Increase sine1/sine2 offsets and mask to 0-2047 (1024 sine entries, in words)
	and.l	d5,d6				;And with SIN_Sine_Offset_Mask (two offsets anded at once)

	lea	BLTBPTH(a5),a1			;for quick blitter loading

	move.w	d7,DMACON(a5)			;Blitter nasty on
.bwt\@	btst.b	d1,DMACONR(a5)			;Blitwait
	bne.s	.bwt\@
	move.w	d4,DMACON(a5)			;Blitter nasty off

	; write blt registers as fast as possible
	move.w	d2,(a2)				;BLTAFWM($44)
	move.l	a6,(a1)+			;BLTBPTH - $4c
	move.l	a4,(a1)+			;BLTAPTH - $50
	move.l	a6,(a1)+			;BLTDPTH - $54
	move.w	d0,(a1)				;BLTSIZE - $58

	ror.w 	#1,d2				;rot mask
	ENDM

SIN_CopyScrollToSine:
	lea	CUSTOM,a5
	;lea	DMACONR(a5),a2			; Optimize blitwaits a little
	lea	BLTAFWM(a5),a2

	;Get sine speed and steps
	lea	SIN_Sine,a0
	lea	SIN_Sine_Params,a1

	move.w	#SIN_Sine_Offset_Mask,d5	;Used to keep the offset in range

	; Sine 1
	move.w	SIN_Sine1_Offset(a1),d6		;Offset in words
	move.w	SIN_Sine1_Speed(a1),d3		;Get speed (movement per frame)
	add.w	d3,d3				;Offset in words
	add.w	d3,d6
	and.w	d5,d6				;Ensure in range
	move.w	d6,SIN_Sine1_Offset(a1)		;Save for next frame
	move.w	SIN_Sine1_Step(a1),d3		;Get step (movement per pixel)
	add.w	d3,d3				;Offset in words

	; Sine 1
	move.w	SIN_Sine2_Offset(a1),d7		;Offset in words
	move.w	SIN_Sine2_Speed(a1),d4		;Get speed (movement per frame)
	add.w	d4,d4				;Offset in words
	add.w	d4,d7
	and.w	d5,d7				;Ensure in range
	move.w	d7,SIN_Sine2_Offset(a1)		;Save for next frame
	move.w	SIN_Sine2_Step(a1),d4		;Get step (movement per pixel)
	add.w	d4,d4				;Offset in words

	; Our starting source buffer and screen address. Add the padding.
	; Padding will copied every 16th blit
	lea 	Scratch_Buffer,a4
	move.l	SIN_Work_Ptr,a3			;scr adr
	
	; Put the sine table offsets in d6 in the high and low words to free up a data register
	swap	d6					
	move.w	d7,d6				; d6 contains offsets sine1 (hiword) and sine2 (loword)

	; Put the sine offset mask in the high word of d5 as well so we can AND 2 things at once
	move.w	d5,d1				; Sine offset mask
	swap	d5
	move.w	d1,d5				; Same mask now in high and low words

	; Put the sine steps in the high and lo words of d3
	swap	d3
	move.w	d4,d3				; d3 contains table steps sine1 (hiword) and sine2 (loword)

	; Setup registers we will use each frame to speed things
	move.w 	#$8000,d2			;start mask 1000000000000000
	move.w 	#(SIN_Font_Height)*64+1,d0	;BLTSIZE
	move.w	#$8400,d7			;Blitter nasty on 
	move.w	#$0400,d4			;Blitter nasty off
	moveq	#6,d1				;Speed up blitwait test

	lea	BLTBMOD(a5),a1			;Speed up blitter loading, after wait

	; Prior to this routine a full width scroll would be occuring. So temp turn
	; on blitter nasty here to speed it. Saves a whole 2 raster lines...
	TIMERON $660
	move.w	d7,DMACON(a5)			;Blitter nasty on
.bwait:	btst.b	d1,DMACONR(a5)			;Blitwait
	bne.s	.bwait
	move.w	d4,DMACON(a5)			;Blitter nasty off
	TIMERON $111

	move.l	#$0dfc0000,BLTCON0(a5)		; BLTCON0+1	
	move.w	#$ffff,BLTALWM(a5)		; Doesn't change
	move.w	#(SIN_Screen_ByteWidth*SIN_Font_HeightMultiplier)-2,(a1)+	; Screen buffer mod, BLTBMOD($62)
	move.w	#SIN_Scroller_ByteWidth-2,(a1)+	; Scroller buffer mod, BLTAMOD($64)
	move.w	#(SIN_Screen_ByteWidth*SIN_Font_HeightMultiplier)-2,(a1)	; Screen buffer mod, BLTDMOD($66)

	; Do NOT chnage this to moveq, hiword contains #6 for speeding up blitwaits
	swap	d1
	move.w	#SIN_Screen_WordWidth-1,d1	;number of loops to cover screen in 16pixel blocks
.blitloop:
	swap	d1				;Change counter to blitwait #6

	REPT 16
	BlitSine				; Rest of the blits
	ENDR

	addq.l 	#2,a3				;add to dest address
	addq.l 	#2,a4				;add to source address
	
	swap	d1				;Change blitwait #6 to loop counter
	dbf	d1,.blitloop


	rts	



*****************************************************************************
* Scrolls the hidden buffer at the correct speed
* IN:	
* OUT:		
* TRASHED:	d0-d3/a0-a1
*****************************************************************************

SIN_Scroll:
	lea	SIN_Sine_Params,a1

	; destination is the last word of the scrollbuffer (as we are in descending mode for left scrolling)
	; Add our by our padding height (so we drawing the letter in the center of the buffer)
	move.l 	#Scratch_Buffer+((SIN_Font_Height*SIN_Scroller_ByteWidth)-2),a0	; Assumes 1bpl

	; Shift speed (max $f)
	move.l	#$09f00002,d2			;bltcon0

	moveq	#0,d0
	move.w	SIN_Speed(a1),d0
	andi.w	#$f,d0				;keep in range of single blitter shift
	add.w	d0,SIN_LastLetterFrameCount(a1)	;Keep track of how much scrolling since last letter written
	move.w	d0,d3				;save shift speed
	ror.l	#4,d0				;move it to the last nibble
	or.l	d0,d2				;Or it with bltcon0

;To prevent data that is scrolled out of the left reappearing on the right we have to mask the LAST word 
;By the same amount that we are shifting. Last mask is applied BEFORE the shift occurs so only zeros
;get shifted back into the right
;shift 1, mask $7fff
;shift 2, mask $3fff
	moveq	#-1,d0				; $ffffffff for FWM/LWM
	lsr.w	d3,d0				; add x number of zeroed bits to LOW word (LWM)

	lea	BLTAPTH(a5),a1
	moveq	#0,d1

	; This will be the first blit of the frame
	TIMERON	$600
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5	
	TIMERON $111

	move.l	d2,BLTCON0(A5)			;4 pixels,use A & D,LF=copy
	move.l	d0,BLTAFWM(A5)			;FWM, LWM
	move.l	d1,BLTAMOD(A5)			;No modulo in A and D
	move.l	a0,(a1)+			;BLTAPTH
	move.l	a0,(a1)+			;BLTDPTH
	move.w	#SIN_Font_Height*64+(SIN_Scroller_WordWidth),(a1)	;BLTSIZE

	rts


*****************************************************************************
* Prints letters and scrolls the hidden scroller buffer.
* IN:	
* OUT:		
* TRASHED:	
*****************************************************************************

SIN_PrintAndScroll:

;Read in new letters and process
	lea	SIN_Sine_Params,a1
	; Are we pausing?
	cmpi.w #0,SIN_StopScroll(a1)
	beq.s .ReadInput
	subq.w #1,SIN_StopScroll(a1)
	rts

.ReadInput:
	cmpi.w	#(SIN_Font_PixelWidth),SIN_LastLetterFrameCount(a1)	;Draw one ?
	ble	.Scroll			;Not ready to read more data
	clr.w	SIN_LastLetterFrameCount(a1)
	move.l	SIN_TextPtr,a0
.read_next
	moveq	#0,d0			; clear top of d0
	move.b	(a0)+,d0
	bne.s	.CharOK				;Skip if not
	move.w	#1,SIN_Finished	;End of message
	rts

.CharOK:
	cmpi.b	#SIN_FX_Pause,d0
	beq.s	.pause_command
	cmpi.b	#SIN_FX_Speed,d0
	beq.s	.speed
	cmpi.b	#SIN_FX_Sine1_Speed,d0
	beq.s	.sine1_speed
	cmpi.b	#SIN_FX_Sine1_Step,d0
	beq.s	.sine1_step
	cmpi.b	#SIN_FX_Sine2_Speed,d0
	beq.s	.sine2_speed
	cmpi.b	#SIN_FX_Sine2_Step,d0
	beq.s	.sine2_step
	cmpi.b	#SIN_FX_Sine_Reset,d0
	beq.s	.sine_reset

	; Must be a normal letter
.DrawLetter
	move.l	a0,SIN_TextPtr		;Save pointer
	bsr.s	SIN_BlitLetter		;New letter
.Scroll:
	; Do the scroll of the hidden buffer
	bra 	SIN_Scroll

.speed:	
	move.b	(a0)+,d0
	move.w	d0,SIN_Speed(a1)
	bra.s	.read_next
.sine1_speed:	
	move.b	(a0)+,d0
	ext.w	d0				;cope with -ve
	move.w	d0,SIN_Sine1_Speed(a1)
	bra.s	.read_next
.sine1_step:	
	move.b	(a0)+,d0
	ext.w	d0				;cope with -ve
	move.w	d0,SIN_Sine1_Step(a1)
	bra.s	.read_next
.sine2_speed:	
	move.b	(a0)+,d0
	ext.w	d0				;cope with -ve
	move.w	d0,SIN_Sine2_Speed(a1)
	bra.s	.read_next
.sine2_step:	
	move.b	(a0)+,d0
	ext.w	d0				;cope with -ve
	move.w	d0,SIN_Sine2_Step(a1)
	bra.s	.read_next
.sine_reset:	
	bsr	SIN_Reset_Sine_Params
	bra.s	.read_next

.pause_command	
	move.b	(a0)+,d0
	
	;mulu.w	#10,d0
	lsl.w	#3,d0	;*8 is close enough

	move.w	d0,SIN_StopScroll(a1)
	move.l	a0,SIN_TextPtr
	rts


*****************************************************************************
* Blits a given letter to the scroll buffer
* IN:		d0 - ASCII value of letter to print
* OUT:		
* TRASHED:	d0/a0
*****************************************************************************

SIN_BlitLetter:
	subi.b	#30,d0				;Get letter in font range
	move.l	#SinusFont3_Matrix,a1 
	add.w	d0,d0				;access in words

	lea	SineFont3,a0
	add.w	(a1,d0.w),a0			;Source byte offset in font bitmap 1st bitplane
	
	; Add offsets as font bitmap doesn't exactly match the matrix
	IFNE SIN_Font_Bitmap_YOffsetPixels
		IFNE SIN_Font_Bitmap_XOffsetBytes
			addi.l	#(SIN_Font_Bitmap_YOffsetPixels*SIN_Font_Bitmap_ByteWidth)+SIN_Font_Bitmap_XOffsetBytes,d0
		ENDC
	ENDC

	; Destination is scroller buffer extreme right edge, minus font width
	; Add our by our padding height (so we drawing the letter in the center of the buffer)
	move.l	#Scratch_Buffer+(SIN_Scroller_ByteWidth-SIN_Scroller_ExtraByteWidth),a1	
	
	; CPU BLIT
	; We are taking 8 pixels wide and change to 64 pixels
	moveq	#SIN_Font_Bitmap_ByteWidth,d5	
	moveq	#SIN_Scroller_ByteWidth-8,d6	;we are auto advancing dest by 2 longs per loop
	moveq	#SIN_Font_Height-1,d7	;8 lines high

	moveq	#$f,d4
 	moveq   #$f<<2,d3
.loop:
	moveq	#0,d1		;ensure bottom word is clear at start
	move.b	(a0),d1		;Get the byte of the source font
	move.w	d1,d0		;save

	lsr.w	#2,d0		;top nibble, access in longs
        and.w   d3,d0
	move.l	.lut(pc,d0.w),(a1)+	;save long

	and.w	d4,d1		;d1 is bottom nibble of orginal
	add.w	d1,d1
	add.w	d1,d1		;access in longs
	move.l	.lut(pc,d1.w),(a1)+	;save long

	add.w	d5,a0		;next line src
	add.w	d6,a1		;next line dest
	dbf	d7,.loop

	rts

.lut:
	dc.l	$00000000	;0
	dc.l	$000000ff	;1
	dc.l	$0000ff00	;2
	dc.l	$0000ffff	;3
	dc.l	$00ff0000	;4
	dc.l	$00ff00ff	;5
	dc.l	$00ffff00	;6
	dc.l	$00ffffff	;7
	dc.l	$ff000000	;8
	dc.l	$ff0000ff	;9
	dc.l	$ff00ff00	;10
	dc.l	$ff00ffff	;11
	dc.l	$ffff0000	;12
	dc.l	$ffff00ff	;13
	dc.l	$ffffff00	;14
	dc.l	$ffffffff	;15


*****************************************************************************
* Does a blitter vertical fill on the screen.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0
*****************************************************************************

SIN_VerticalFill:

; A XOR B
; A B C  D  ABD=$d, LF = $3C
; 0 0 x  0
; 0 0 x  0
; 0 1 x  1
; 0 1 x  1
; 1 0 x  1
; 1 0 x  1
; 1 1 x  0
; 1 1 x  0

	move.l	SIN_Work_Ptr,a1			;B PTR is first line
	lea	SIN_Screen_ByteWidth(a1),a0	;A and D PTR is the next line
	moveq	#-1,d0				;FWM/LWM = $ffffffff
	move.w	#(SIN_Screen_Height-1)*64+(SIN_Screen_WordWidth*SIN_Screen_NumPlanes),d1

	WAITBLIT_A5
	move.l	#$0d3c0000,BLTCON0(a5)		;BLTCON0/1
	move.l	d0,BLTAFWM(a5)
	move.w	#0,BLTBMOD(a5)
	move.w	#0,BLTAMOD(a5)
	move.w	#0,BLTDMOD(a5)
	move.l	a1,BLTBPTH(a5)
	move.l	a0,BLTAPTH(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	d1,BLTSIZE(a5)

	rts


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	SIN_Data1,DATA	;Public data section for variables
	
*****************************************************************************

SIN_FX_Pause		=	1
SIN_FX_Speed		=	2	;0-255
SIN_FX_Sine1_Speed	=	3	;-128 to 127
SIN_FX_Sine1_Step	=	4
SIN_FX_Sine2_Speed	=	5
SIN_FX_Sine2_Step	=	6
SIN_FX_Sine_Reset	=	7	; Reset sines to 0


*** Program Variables ***
SIN_Initialised:
	dc.w	0

SIN_TextPtr:
	dc.l	0
SIN_Finished:
	dc.w	0

; Screen buffer pointers
SIN_Screen_Ptr:		ds.l	1
SIN_Work_Ptr:		ds.l	1


; 20 chars width maxc
	EVEN
SIN_Text1:
	;dc.b	SIN_FX_Sine_Reset
	;dc.b	SIN_FX_Sine1_Speed,0,SIN_FX_Sine1_Step,0	; No sine - centered
	;dc.b	SIN_FX_Sine2_Speed,0,SIN_FX_Sine2_Step,0	; No sine!
	;dc.b	SIN_FX_Speed,1

	dc.b	SIN_FX_Sine_Reset
	dc.b	SIN_FX_Speed,5
	dc.b	SIN_FX_Sine1_Speed,-7,SIN_FX_Sine1_Step,2	; Elastic
	dc.b	SIN_FX_Sine2_Speed,14,SIN_FX_Sine2_Step,2	; 
	dc.b	"    OMFG... A MONSTER SINE SCROLLER!      "

	dc.b	SIN_FX_Sine_Reset
	dc.b	SIN_FX_Speed,5
	dc.b	SIN_FX_Sine1_Speed,-1,SIN_FX_Sine1_Step,4	; modulated
	dc.b	SIN_FX_Sine2_Speed,-2,SIN_FX_Sine2_Step,1
	dc.b	"MY BEST BACK IN THE DAY WAS 25 PIXELS HIGH :)      "

	dc.b	SIN_FX_Sine_Reset
	dc.b	SIN_FX_Speed,5
	dc.b	SIN_FX_Sine1_Speed,-7,SIN_FX_Sine1_Step,2	; Elastic
	dc.b	SIN_FX_Sine2_Speed,14,SIN_FX_Sine2_Step,2	; 
	dc.b	"CHEERS TO DAN AND ROSS @EAB FOR THE HELP!      "



	; Most severe sine for clr screen testing
	dc.b	SIN_FX_Sine_Reset
	dc.b	SIN_FX_Speed,5
	dc.b	SIN_FX_Sine1_Speed,-9,SIN_FX_Sine1_Step,8	; No sine - centered
	dc.b	SIN_FX_Sine2_Speed,-4,SIN_FX_Sine2_Step,16	; No sine!
	dc.b	"---===OOO===---        "

	dc.b	0
	EVEN



; For speed the Y range (taking account of padding) is not checked and the two sine waves used must
; be created so that the maximum top/bottom Y values do not cause the sine scroller blit (plus padding)
; to exceed the screen area.
; This routine:
; 224+8 pixels high. Allow 113 high font. = 119 = Amplitde of 59;
; allow addition of 2 waves = amplitude 29

SIN_Sine_NumEntries = 1024	; Must be power of 2
SIN_Sine_Offset_Mask = ((SIN_Sine_NumEntries*2)-2)	; Byte offset access into the table, forced to be even 
; Our table goes from 0 to 72 (amplitude 36)
SIN_Sine_YOffset = 36

; Sine values
SIN_Sine:
	INCLUDE "bin/sine_0-59_1024_words.i"


SIN_Speed			= 0
SIN_Sine1_Offset 		= 2
SIN_Sine2_Offset 		= 4
SIN_Sine1_Speed 		= 6
SIN_Sine1_Step 			= 8
SIN_Sine2_Speed 		= 10
SIN_Sine2_Step 			= 12
SIN_LastLetterFrameCount	= 14
SIN_StopScroll			= 16

SIN_Sine_Params:
	dc.w	1	;Speed
	dc.w	0	;SIN_Sine1_Offset
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0	;SIN_Sine2_Step
	dc.w	0	;SIN_LastLetterFrameCount
	dc.w	0	;SIN_StopScroll

SinusFont3_Matrix:
	DC.W 0		
	DC.W 4		
	DC.W 8			;SPACE
	dc.W 12			;!
	dc.W 16			;"
	dc.W 20			;#
	dc.W 24			;$
	dc.W 28			;%
	dc.W 32			;&
	dc.W 36			;'
	dc.W (32*40)+0		;(
	dc.W (32*40)+4		;)
	dc.W (32*40)+8		;*
	dc.W (32*40)+12		;+
	dc.W (32*40)+16		;,
	dc.W (32*40)+20		;-
	dc.W (32*40)+24		;.	
	dc.W (32*40)+28		;/
	dc.W (32*40)+32		;0
	dc.W (32*40)+36		;1
	
	DC.W (64*40)+0		;2
	dc.W (64*40)+4		;3
	dc.W (64*40)+8		;4
	dc.W (64*40)+12		;5
	dc.W (64*40)+16		;6
	dc.W (64*40)+20		;7
	dc.W (64*40)+24		;8
	dc.W (64*40)+28		;9
	dc.W (64*40)+32		;:
	dc.W (64*40)+36		;;
	
	DC.W (96*40)+0		;<
	dc.W (96*40)+4		;=
	dc.W (96*40)+8		;>
	dc.W (96*40)+12		;?
	dc.W (96*40)+16		;@
	dc.W (96*40)+20		;a
	dc.W (96*40)+24		;b
	dc.W (96*40)+28		;c
	dc.W (96*40)+32		;d
	dc.W (96*40)+36		;e
	
	
	DC.W (128*40)+0		;f
	dc.W (128*40)+4		;g
	dc.W (128*40)+8		;h
	dc.W (128*40)+12	;i
	dc.W (128*40)+16	;j
	dc.W (128*40)+20	;k
	dc.W (128*40)+24	;l
	dc.W (128*40)+28	;m
	dc.W (128*40)+32	;n
	dc.W (128*40)+36	;o
	
	DC.W (160*40)+0		;p
	dc.W (160*40)+4		;q
	dc.W (160*40)+8		;r
	dc.W (160*40)+12	;s
	dc.W (160*40)+16	;t
	dc.W (160*40)+20	;u
	dc.W (160*40)+24	;v
	dc.W (160*40)+28	;w
	dc.W (160*40)+32	;x
	dc.W (160*40)+36	;y
	
	dc.W (192*40)+0 	;z
	EVEN


*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	SIN_PublicBSS,BSS	; Public blank data

*****************************************************************************




*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	SIN_ChipData1,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************

*** THE COPPERLISTS ***

; Copper horizontal blanking notes from Photon/Scoopex
; As established, positions $e7...$03 are not usable. If you're writing a simple 
; copperlist with no need for tight timing, positions $df and $07 are conventionally 
;used for the positions on either side of the horizontal blanking, and for 
; compatibility across chipsets use increments of 4 from these, resulting in 
;positions $db, $0b, and so on.

	CNOP 0,8	; 64 bit alignment for AA
SIN_CL:
	CMOVE	FMODE,SIN_MemoryFetchMode		;Chip Ram fetch mode (0=OCS)
	
	CWAIT	SIN_DIW_V-2,$7		;Time for altering Copperlist
	
	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,SIN_DIW_Start
	CMOVE 	DIWSTOP,SIN_DIW_Stop
	CMOVE 	DDFSTRT,SIN_DDF_Start
	CMOVE 	DDFSTOP,SIN_DDF_Stop
	CMOVE 	BPLCON0,$1600		;Initially 1 bitplane,
	CMOVE 	BPLCON1,$0020		;scrolling is 2pixels to the right on even bitmaps (shadow)
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,0
	CMOVE 	BPL2MOD,0

SIN_CL_Screen_Bpl:			;Bitplane pointers
	CMOVE	BPL1PTH,$0		;Main bitmap
	CMOVE	BPL1PTL,$0
	CMOVE	BPL2PTH,$0		;Shadow/offset bitmap
	CMOVE	BPL2PTL,$0

SIN_CL_Screen_Cols:
	IFEQ	RasterTest
	CMOVE	COLOR00,$001
	ENDC
	CMOVE	COLOR09,$ddd		; Initial Shadow colour


a set SIN_DIW_V
b set 4
	CWAIT a,$7
	DC.W COLOR01,$0F55

	CWAIT	a+2,$7
	CMOVE 	BPLCON0,$2600		;2bpl, dual playfield, start shadow

a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0F65
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0F75


a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0F85
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0F95
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FA5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FB5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FC5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FD5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FE5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0FF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0EF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0DF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0CF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0BF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$0AF5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$09F5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$08F5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$07F5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$06F5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05F5
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05F6
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05F7
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05F8
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05F9
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FA

a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FB
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FC
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FD
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FE
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05FF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05EF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05DF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05CF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05BF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$05AF
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$059F


a set a+b
	CWAIT a,$7
	DC.W COLOR01,$058F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$057F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$056F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$055F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$065F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$075F
a set a+b
	CWAIT a,$7
	DC.W COLOR01,$085F


	IFEQ RasterTest

;start of background colour chnages
a set 210
	CWAIT a,$7
	DC.W COLOR00,$001
	DC.W COLOR01,$95F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$002
a set a+2
	CWAIT a,$7
	DC.W COLOR00,$003
	DC.W COLOR01,$A5F
a set a+2
	CWAIT a,$7
	DC.W COLOR00,$004

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$005
	DC.W COLOR01,$B5F
	
a set a+2
	CWAIT a,$7
	DC.W COLOR00,$006

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$007
	DC.W COLOR01,$C5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$008

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$009
	DC.W COLOR01,$D5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00A

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00B
	DC.W COLOR01,$E5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00C

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00D
	DC.W COLOR01,$F5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00E

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$00F
	DC.W COLOR01,$E5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$01F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$02F
	DC.W COLOR01,$D5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$03F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$04F
	DC.W COLOR01,$C5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$05F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$06F
	DC.W COLOR01,$B5F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$07F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$08F
	DC.W COLOR01,$A5F

	ENDC			; Raster Test
	; ---
	CWAIT 255,$E1		; >255 needs this line
	; ---
	IFEQ RasterTest

a set 0
	CWAIT a,$7
	DC.W COLOR00,$09F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$0AF
	DC.W COLOR01,$95F
a set a+2
	CWAIT a,$7
	DC.W COLOR00,$0BF

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$0CF
	DC.W COLOR01,$85F

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$0DF

a set a+2
	CWAIT a,$7
	DC.W COLOR00,$0EF
	DC.W COLOR01,$75F
	
a set a+1
	CWAIT a,$7
	DC.W COLOR00,$0FF


	ENDC

	; ---
	; Middle - Horizon line 268, have to set the modulo on the line BEFORE as it it only takes
	; effect at the end of the line
	; ---

a set SIN_Reflection_DIW_H-1
	CWAIT a,$7
	CMOVE 	BPL1MOD,-(4*SIN_Screen_ByteWidth)
	CMOVE 	BPL2MOD,-(4*SIN_Screen_ByteWidth)


a set SIN_Reflection_DIW_H
	CWAIT a,$7

	IFEQ RasterTest

	DC.W COLOR00,$0cc
a set a+1
	CWAIT a,$7
	DC.W COLOR00,$0bc

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$0ac
	DC.W COLOR01,$75F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$09c
	DC.W COLOR01,$85F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$08c
	DC.W COLOR01,$95F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$07c
	DC.W COLOR01,$A5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$06c
	DC.W COLOR01,$B5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$05c
	DC.W COLOR01,$C5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$04c
	DC.W COLOR01,$D5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$03c
	DC.W COLOR01,$E5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$02c
	DC.W COLOR01,$F5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$01c
	DC.W COLOR01,$E5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$00c
	DC.W COLOR01,$D5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$00b
	DC.W COLOR01,$C5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$00a
	DC.W COLOR01,$B5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$009
	DC.W COLOR01,$A5F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$008
	DC.W COLOR01,$95F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$007
	DC.W COLOR01,$085F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$006
	DC.W COLOR01,$075F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$005
	DC.W COLOR01,$065F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$004
	DC.W COLOR01,$055F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$003
	DC.W COLOR01,$056F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$002
	DC.W COLOR01,$057F

a set a+1
	CWAIT a,$7
	DC.W COLOR00,$001
	DC.W COLOR01,$058F

a set a+1
	CWAIT a,$7
	DC.W COLOR01,$059F

a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05AF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05BF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05CF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05DF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05EF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FF
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FE
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FD
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FC
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FB
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05FA
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05F9
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05F8
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05F7
a set a+1
	CWAIT a,$7
	DC.W COLOR01,$05F6


	ENDC


	COPPEREND

*****************************************************************************

	CNOP 0,8	; 64 bit alignment for AA
SineFont3:
	;INCBIN "gfx/PLAINFONT.RAW"
	INCBIN "gfx/Antiriad2_8px_320x224.raw"
					
*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	SIN_ChipBss1,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************

;This is where the scroll is created normally, then you blit from this buffer
;to the main screen in 1pix masks
; USING Scratch_Buffer
;sinus_scrollbuffer:
;	ds.b 	SIN_Font_Height*(SIN_Screen_ByteWidth+4)
;	EVEN

*****************************************************************************

