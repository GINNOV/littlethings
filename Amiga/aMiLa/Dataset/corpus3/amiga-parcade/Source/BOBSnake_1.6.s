*****************************************************************************

; Name			: BobSnake.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: 8 colour bobs.
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

	SECTION	BOBSnake_Code,CODE	;Code section in Public memory

*****************************************************************************
*** Changeable Parameters For Display ***

*** Display Window ***

; Photon:
; Best practice is to start with DDF 38,d0 and DIW 2c81,2cc1 and modify these 
; symmetrically and always in whole 16px steps for compatibility.
; Note DDF start of less than 30 and you start to lose sprites.

BOB_DIW_V		=	$2c	;Hardware Vstart ($2c normal, $24 overscan)
BOB_DIW_H		=	$81	;Hardware Hstart ($81 normal, $71 overscan)
BOB_DIW_Width		=	320	;Pixels		 (multiple of 16, 320 normal, 352 overscan)
BOB_DIW_Height		=	256+8	;Lines		 (256 normal PAL, 272 overscan)

*** Data Fetch ***

BOB_MemoryFetchMode	=	0	;0,1 or 3 
; When FMode=0,1,3 DDF_Width must be a multiple of 16,32,64 respectively.
; NB. I can't get FMODE=2 to work - sorry.
; 0=OCS/ECS, 3=AA in practice
; Bitplane, copper and sprite data should be 64bit (CNOP 0,8) aligned so that it can work
; in ECS/AA modes.
; Bitplanes should be multiples of 64bits wide to take maximum advantage of bandwidth
; 320 or 384 pix which.

BOB_DDF_H		=	$81	;Hardware Hstart ($81 normal, $71 overscan)
BOB_DDF_Width		=	320	;Pixels		 (320 normal pal, 352 overscan)

*****************************************************************************

*** Non-changable parameters for display - Automatically calculated from above ***

BOB_DIW_Vstart		=	(BOB_DIW_V&$ff)<<8
BOB_DIW_Vstop		=	((BOB_DIW_V+BOB_DIW_Height)&$ff)<<8
BOB_DIW_Hstart		=	BOB_DIW_H&$ff
BOB_DIW_Hstop		=	(BOB_DIW_Hstart+BOB_DIW_Width)&$ff
BOB_DIW_Start		=	BOB_DIW_Vstart!BOB_DIW_Hstart
BOB_DIW_Stop		= 	BOB_DIW_Vstop!BOB_DIW_Hstop

	IFEQ	BOB_MemoryFetchMode
BOB_DDF_Increment		=	1
	ENDC
	IFNE	BOB_MemoryFetchMode
BOB_DDF_Increment		=	(BOB_DDF_FetchMode+1)&$fffe
	ENDC	

BOB_DDF_WordWidth	=	BOB_DDF_Width/16
BOB_DDF_Start		=	(BOB_DDF_H/2)-8
BOB_DDF_Stop		=	BOB_DDF_Start+((BOB_DDF_WordWidth-BOB_DDF_Increment)*8)

*** Screen Definitions ***

;The visible screen area and back buffer
BOBSnake_Screen_Width		=	320
BOBSnake_Screen_ByteWidth	=	BOBSnake_Screen_Width/8		;Bytes
BOBSnake_Screen_WordWidth	=	BOBSnake_Screen_ByteWidth/2	;Words

BOBSnake_Screen_Height		=	224				;Lines
BOBSnake_Screen_NumPlanes	=	3				;4bpl/16 cols
BOBSnake_Screen_Size		=	BOBSnake_Screen_ByteWidth*BOBSnake_Screen_Height
BOBSnake_Screen_TotalSize	=	BOBSnake_Screen_Size*BOBSnake_Screen_NumPlanes

BOBSnake_BOB_Height		=	16
BOBSnake_BOB_Width		=	32	;16x16 bob needs to be 16 pixels wider to allow for shifting
BOBSnake_BOB_ByteWidth		=	BOBSnake_BOB_Width/8
BOBSnake_BOB_WordWidth		=	BOBSnake_BOB_ByteWidth/2
BOBSnake_BOB_NumPlanes		=	3
BOBSnake_BOB_Size		=	BOBSnake_BOB_ByteWidth*BOBSnake_BOB_Height
BOBSnake_BOB_TotalSize		=	BOBSnake_BOB_Size*BOBSnake_BOB_NumPlanes

BOBSnake_NumBOBs		=	77; 80	; Make a multiple of 2 for prettiest

*****************************************************************************

*****************************************************************************
* Called ONCE per routine, no matter how many times the routine is used
* Use for one-time setup
* IN:		a0(text message ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

BOBSnake_Init:
	move.w	#1,BOBSnake_Initialised

	; Multiple sine values by screen widths
	bsr	BOBSnake_PreMult_SineForScreen

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
	lea	BOBSnake_Routine1,a0
	ENDC

BOBSnake_Start:
	; Save parameters
	move.l	a0,BOBSnake_RoutinePtr

	; Have we already done any one-time setup routines?
	tst.w	BOBSnake_Initialised
	bne.s	.alreadyinit
	bsr.s	BOBSnake_Init
.alreadyinit:
	lea	CUSTOM,a5

	;Clear sine scroller print buffer and init some variables
	move.w	#0,BOBSnake_Sine1_X_Offset
	move.w	#0,BOBSnake_Sine2_X_Offset

	move.w	#0,BOBSnake_Sine1_Y_Offset
	move.w	#0,BOBSnake_Sine2_Y_Offset

	clr.w	BOBSnake_TimeToFinish	;num frames to show

	; Init copper pointers
	bsr	BOBSnake_InitCopper

	; Clear all screen buffers at EOF and swap copper list
	; Main routine has bitplanes off so safe to clear first
	lea	CUSTOM,a5
	bsr	BOBSnake_Clear_ScreenBuffers_A5
	WAITBLIT_A5
	jsr	WaitEOF_A5
	move.l 	#BOBSnake_CL,COP1LCH(a5)	; Active NEXT frame

.fin
	; Continue with main loop
	bra	BOBSnake_MainLoop
	rts

*****************************************************************************
* Runs the effect.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		d0(0=Running, 1=Ending)
* TRASHED:	d0
*****************************************************************************

BOBSnake_MainLoop:

	lea	CUSTOM,a5
.Mainloop1:
	BLIT_NASTY_OFF_A5			; Default is no blitter nasty

	TIMERON	$111

	; Check if it's time to read more routine in
	tst.w	BOBSnake_TimeToFinish
	bne.s	.start

	; Read in routine
	move.l	BOBSnake_RoutinePtr,a0
	cmpi.w	#$ffff,(a0)
	beq	.fin

	move.w	(a0)+,BOBSnake_Sine1_X_Speed	;motion per frame
	move.w	(a0)+,BOBSnake_Sine1_X_Step	;motion per bob
	move.w	(a0)+,BOBSnake_Sine2_X_Speed
	move.w	(a0)+,BOBSnake_Sine2_X_Step

	move.w	(a0)+,BOBSnake_Sine1_Y_Speed	;motion per frame
	move.w	(a0)+,BOBSnake_Sine1_Y_Step	;motion per bob
	move.w	(a0)+,BOBSnake_Sine2_Y_Speed
	move.w	(a0)+,BOBSnake_Sine2_Y_Step

	move.w	(a0)+,BOBSnake_TimeToFinish	;num frames to show

	move.l	a0,BOBSnake_RoutinePtr

	move.w	#0,BOBSnake_Sine1_X_Offset	; reset
	move.w	#0,BOBSnake_Sine2_X_Offset
	move.w	#0,BOBSnake_Sine1_Y_Offset
	move.w	#0,BOBSnake_Sine2_Y_Offset

.start:
	subq.w	#1,BOBSnake_TimeToFinish

	bsr	BOBSnake_Clear_WorkBuffer_A5	;clear screen
	bsr	BOBSnake_PlotBOB		;plot bobs during blitter clr
	bsr	BOBSnake_DrawBOB		;loop and draw bobs

	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	TIMEROFF

	jsr	WaitEOF_A5
	bsr	BOBSnake_DoubleBufferSwap
	
.Testmouse
	btst 	#10-8,POTGOR+CUSTOM	;rmb quits section
	beq.s	.fin
	btst 	#6,$bfe001		;lmg quits all
	bne 	.Mainloop1
	move.w	#1,Quit_Flag
.fin

	; Restore copper for main routine
	lea	CUSTOM,a5
	jsr	SetBaseCopperAndDma_A5

	moveq	#1,d0		;Signal finished
	rts

*****************************************************************************

BOBSnake_InitCopper:
;Init. physical & logical screen addresses
	move.l	#Screen_Buffer,d1
	move.l	d1,BOB_Screen_Ptr		;Physical screen adr
	move.l	#Work_Buffer,BOB_Work_Ptr	;Logical screen adr

	move.l 	#BOBSnake_CL_Screen_Bpl,a0
	moveq	#BOBSnake_Screen_NumPlanes,d0
	move.w 	#BOBSnake_Screen_ByteWidth,d2	;interleaved
	jsr	InitCopperBplPtrs

	move.l	#BOBSnake_CL_Screen_Cols,a0
	move.l	#BOBSnake_BOB,a1
	move.w	#1<<BOBSnake_BOB_NumPlanes,d0
	move.l	#BOBSnake_BOB_TotalSize,d1
	jsr	InitCopperColsFromRawImage

	; set color 00
	move.w	#$001,BOBSnake_CL_Screen_Cols+2

	rts

*****************************************************************************
* Swaps the screens
* IN:		
* OUT:		
* TRASHED:	d0-d1/a0
*****************************************************************************

BOBSnake_DoubleBufferSwap:
	move.l	BOB_Work_Ptr,d0		;Get logical adr
	move.l	BOB_Screen_Ptr,BOB_Work_Ptr	;Swap logical & physical
	move.l	d0,BOB_Screen_Ptr		;Save physical

	move.l 	#BOBSnake_CL_Screen_Bpl,a0		;Adr of copper pointers
				
	moveq.l	#BOBSnake_Screen_NumPlanes-1,d1	;Number of bitplanes
.loop
	swap	d0			;Swap high & low words
	move.w	d0,2(a0)		;High ptr
	swap	d0			;Swap high & low words
	move.w	d0,6(a0)		;Low ptr
	addq.l	#8,a0			;Next set of ptrs
	addi.l	#BOBSnake_Screen_ByteWidth,d0	;Next bitplane (interleaved)

	dbf	d1,.loop		

	rts

*****************************************************************************
* Clears the work buffer screen. Every frame.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0
*****************************************************************************

BOBSnake_Clear_WorkBuffer_A5:

; Tune this so that the very first WAITBLIT call AFTER this
* routine should take no time at all.
BOBClear_BlitHeight = 143; 147
BOBClear_CPUHeight = (BOBSnake_Screen_Height-BOBClear_BlitHeight)

	move.l  BOB_Work_Ptr,a0		; memory to clear

	; Blitter

	;BLIT_NASTY_ON_A5
	WAITBLIT_A5
	;BLIT_NASTY_OFF_A5
	move.l	#$01000000,BLTCON0(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	#0,BLTDMOD(a5)
	move.w	#((BOBClear_BlitHeight*BOBSnake_Screen_NumPlanes)*64)+BOBSnake_Screen_WordWidth,BLTSIZE(a5)
	; Max height = 1024, made wordwidth = 64

	; CPU

	; a0 = buffer to clear, we need to skip the part cleared by the blitter
	; d7 = size in bytes to clear
	lea	BOBClear_BlitHeight*BOBSnake_Screen_ByteWidth*BOBSnake_Screen_NumPlanes(a0),a0
	move.l	#BOBClear_CPUHeight*BOBSnake_Screen_ByteWidth*BOBSnake_Screen_NumPlanes,d7
	jmp	CPUClearBuffer

	;rts

*****************************************************************************
* Clears front and back buffer. Done once at startup.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	
*****************************************************************************

BOBSnake_Clear_ScreenBuffers_A5:
	WAITBLIT_A5
	move.l	#$01000000,BLTCON0(a5)
	move.w	#0,BLTDMOD(a5)
	move.l	#Screen_Buffer,BLTDPTH(a5)
	move.w	#((BOBSnake_Screen_Height*BOBSnake_Screen_NumPlanes)*64)+BOBSnake_Screen_WordWidth,BLTSIZE(a5)
	WAITBLIT_A5
	;move.l	#$01000000,BLTCON0(a5)
	;move.w	#0,BLTDMOD(a5)
	move.l	#Work_Buffer,BLTDPTH(a5)
	move.w	#((BOBSnake_Screen_Height*BOBSnake_Screen_NumPlanes)*64)+BOBSnake_Screen_WordWidth,BLTSIZE(a5)

	rts

*****************************************************************************
* Takes the Y sine list and premultiples the values by the screen width
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	
*****************************************************************************

BOBSnake_PreMult_SineForScreen:	

	lea	BOBSnake_Sine_Y,a1
	move.w	#BOBSnake_Sine_NumEntries-1,d7
.loop:
	move.w	(a1),d0
	mulu.w 	#BOBSnake_Screen_ByteWidth*BOBSnake_Screen_NumPlanes,d0
	move.w 	d0,(a1)+
	dbf	d7,.loop

	rts

*****************************************************************************
* Creates the bob draw list. CPU routine to be used during blit/screen clear
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	
*****************************************************************************

BOBSnake_PlotBOB:
	;Get sine speed and steps
	lea	BOBSnake_Sine_X,a0
	lea	BOBSnake_DrawList_X,a2			;X coords

	move.w	#BOBSnake_Sine_Offset_Mask,d5	;Used to keep the offset in range

	; Sine 1
	move.w	BOBSnake_Sine1_X_Offset,d6		;Offset in words
	move.w	BOBSnake_Sine1_X_Speed,d3		;Get speed (movement per frame)
	add.w	d3,d3					;Offset in words
	add.w	d3,d6
	and.w	d5,d6					;Ensure in range
	move.w	d6,BOBSnake_Sine1_X_Offset		;Save for next frame
	move.w	BOBSnake_Sine1_X_Step,d3		;Get step (movement per pixel)
	add.w	d3,d3					;Offset in words

	; Sine 2
	move.w	BOBSnake_Sine2_X_Offset,d7		;Offset in words
	move.w	BOBSnake_Sine2_X_Speed,d4		;Get speed (movement per frame)
	add.w	d4,d4					;Offset in words
	add.w	d4,d7
	and.w	d5,d7					;Ensure in range
	move.w	d7,BOBSnake_Sine2_X_Offset		;Save for next frame
	move.w	BOBSnake_Sine2_X_Step,d4		;Get step (movement per pixel)
	add.w	d4,d4					;Offset in words

	REPT BOBSnake_NumBOBs
	;move.w	#BOBSnake_NumBOBs-1,d0
;.loopx
	move.w 	(a0,d6.w),d1		;sine 1
	add.w	(a0,d7.w),d1		;add sine 2

	move.w	d1,(a2)+
	;addq.l	#4,a2			; Next set of coords

	add.w	d3,d6			;Increase offsets and mask to 0-2047 (1024 sine entries, in words)
	add.w	d4,d7
	and.w	d5,d6
	and.w	d5,d7

	;dbf	d0,.loopx
	ENDR

	;Get sine speed and steps
	lea	BOBSnake_Sine_Y,a0			;This list has the Y premultiplied by Screen_ByteWidth*NumPlanes
	lea	BOBSnake_DrawList_Y,a2			; Y coords

	;move.w	#BOBSnake_Sine_Offset_Mask,d5		;Used to keep the offset in range

	; Sine 1
	move.w	BOBSnake_Sine1_Y_Offset,d6		;Offset in words
	move.w	BOBSnake_Sine1_Y_Speed,d3		;Get speed (movement per frame)
	add.w	d3,d3					;Offset in words
	add.w	d3,d6
	and.w	d5,d6					;Ensure in range
	move.w	d6,BOBSnake_Sine1_Y_Offset		;Save for next frame
	move.w	BOBSnake_Sine1_Y_Step,d3		;Get step (movement per pixel)
	add.w	d3,d3					;Offset in words

	; Sine 2
	move.w	BOBSnake_Sine2_Y_Offset,d7		;Offset in words
	move.w	BOBSnake_Sine2_Y_Speed,d4		;Get speed (movement per frame)
	add.w	d4,d4					;Offset in words
	add.w	d4,d7
	and.w	d5,d7					;Ensure in range
	move.w	d7,BOBSnake_Sine2_Y_Offset		;Save for next frame
	move.w	BOBSnake_Sine2_Y_Step,d4		;Get step (movement per pixel)
	add.w	d4,d4					;Offset in words

	REPT BOBSnake_NumBOBs
	;move.w	#BOBSnake_NumBOBs-1,d0
;.loopy
	move.w 	(a0,d6.w),d1		;sine 1
	add.w	(a0,d7.w),d1		;add sine 2

	move.w	d1,(a2)+
	;addq.l	#4,a2			; Next set of coords

	add.w	d3,d6		;Increase offsets and mask to 0-2047 (1024 sine entries, in words)
	add.w	d4,d7
	and.w	d5,d6
	and.w	d5,d7

	;dbf	d0,.loopy
	ENDR


	rts

*****************************************************************************

BOBSnake_DrawBOB:
	lea	BOBSnake_DrawList_X,a0	; x and y*screen_bytewidth values
	lea	BOBSnake_DrawList_Y,a1	; x and y*screen_bytewidth values
	move.l	BOB_Work_Ptr,a6
	move.w 	#(BOBSnake_BOB_Height*BOBSnake_BOB_NumPlanes)*64+BOBSnake_BOB_WordWidth,d5	;BLTSIZE
	move.l	#BOBSnake_BOB_Mask,a4
	move.l	#BOBSnake_BOB,a3

	lea	BLTCPTH(a5),a2
	move.w	#$0fca,d2
	moveq	#BOBSnake_NumBOBs-1,d7

	; Tune clear screen routine so this time is almost 0
	TIMERON $00f
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	TIMERON $111

	move.w	#0,BLTAMOD(a5)		
	move.w	#0,BLTBMOD(a5)
	move.l	#-1,BLTAFWM(a5)	
	move.w	#BOBSnake_Screen_ByteWidth-BOBSnake_BOB_ByteWidth,BLTCMOD(a5)	; interleaved
	move.w	#BOBSnake_Screen_ByteWidth-BOBSnake_BOB_ByteWidth,BLTDMOD(a5)
	move.l	a6,-(sp)
.loop
	;movem.w	(a0)+,d0-d1	;x in pixels, y is premult by screen width
	move.w	(a0)+,d0	;x in pixels
	move.w	(a1)+,d1	;y is premult by screen width

	;lea	BLTCON0(a5),a4
	;move.l	a1,a6		;destination address copy
	move.l	(sp),a6
	ext.l	d0		;ensure top word clear
	ror.l	#4,d0		;hiword of d0 contains shift in highest nibble
	add.w	d0,d0		;loword d0 contains byte offset into screen 
	add.w	d0,d1		;add byte offset to y address
	add.w	d1,a6		;add y address to screen address
	swap	d0		;d0 word now contains shift value
	move.w	d0,d1		;shift value for bltcon1
	or.w	d2,d0		;add minterm

	move.l	a6,d3		;copy for optimizing movem

	; There is quite a lot of blit waiting...so move as much as possible before the wait
	;TIMERON $f00
	BLIT_NASTY_ON_A5	;no more memory access so blitnasty on
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	;TIMERON $111


	; Write the values as fast as possible
	; A = mask, B = BOB, C = Screen (for masking), D = Screen result
	;move.w	d0,BLTCON0(a5)		;BLTCON0
	;move.w	d1,BLTCON1(a5)		;BLTCON1
	;move.l	d3,(a2)+		;BLTCPTH ($48)
	;move.l	a3,(a2)+		;BLTBPTH ($4c)
	;move.l	a4,(a2)+		;BLTAPTH ($50)
	;move.l	a6,(a2)+		;BLTDPTH ($54)
	;move.w	d5,(a2)			;BLTSIZE ($58)	
	movem.w	d0/d1,BLTCON0(a5)
	movem.l	d3/a3/a4/a6,(a2)
	move.w	d5,BLTSIZE(a5)

	dbf	d7,.loop

	move.l	(sp)+,a1		;tidy stack

	rts


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	BOBSnake_Data1,DATA	;Public data section for variables
	
*****************************************************************************

BOBSnake_FX_Pause		=	1
BOBSnake_FX_Speed		=	2	;0-255
BOBSnake_FX_Sine1_Speed		=	3	;-128 to 127
BOBSnake_FX_Sine1_Step		=	4
BOBSnake_FX_Sine2_Speed		=	5
BOBSnake_FX_Sine2_Step		=	6


*** Program Variables ***

; Screen buffer pointers
BOB_Screen_Ptr:		ds.l	1
BOB_Work_Ptr:		ds.l	1

BOBSnake_Initialised:
	dc.w	0

BOBSnake_RoutinePtr:
	dc.l	BOBSnake_Routine1

BOBSnake_TimeToFinish:
	dc.w	0

BOBSnake_Sine_NumEntries = 1024	; Must be power of 2
BOBSnake_Sine_Offset_Mask = ((BOBSnake_Sine_NumEntries*2)-2)	; Byte offset access into the table, forced to be even 

;16 is 16px wide so 0-303
;amplitude is 303/2 = 151
;we have 2 sines that can be added together so need to half again = 75
BOBSnake_Sine_X:
	INCLUDE "bin/sine_0-151_1024_words.i"
	dc.w $ffff,$ffff

; Screen is 224 pix high. 
; Bobs are 16 px high so valid Y values are 0-207
; amplitude = 207/2 = 103
; we have 2 sines that can be added together so need to half again = 51
; ASMOne Sine table creator:
; Amount 1024 words
; Amplitude 51
; Y offset 51
BOBSnake_Sine_Y:
	INCLUDE "bin/sine_0-103_1024_words.i"
	dc.w $ffff,$ffff

BOBSnake_Sine1_X_Offset:
	dc.w	0
BOBSnake_Sine2_X_Offset:
	dc.w	0
BOBSnake_Sine1_X_Speed
	dc.w	0
BOBSnake_Sine1_X_Step
	dc.w	0
BOBSnake_Sine2_X_Speed
	dc.w	0
BOBSnake_Sine2_X_Step
	dc.w	0

BOBSnake_Sine1_Y_Offset:
	dc.w	0
BOBSnake_Sine2_Y_Offset:
	dc.w	0
BOBSnake_Sine1_Y_Speed
	dc.w	0
BOBSnake_Sine1_Y_Step
	dc.w	0
BOBSnake_Sine2_Y_Speed
	dc.w	0
BOBSnake_Sine2_Y_Step
	dc.w	0

; list contains x,y values
; X in pixels
; Y in Y*Screen_ByteWidth (for speed)
BOBSnake_DrawList_X:
	REPT	BOBSnake_NumBOBs
	dc.w	0,0
	ENDR
BOBSnake_DrawList_Y:
	REPT	BOBSnake_NumBOBs
	dc.w	0,0
	ENDR

; X speed1,step1,speed2,step2
; Y speed1,step1,speed2,step2
; Timer (number of frames to show)
; step 14 for 77 bobs gives a complete circle
	EVEN
BOBSnake_Routine1:
	;dc.w	-2,14,-4,14	; 
	;dc.w	-4,14,-4,14
	;dc.w	300
	;dc.w	$ffff	;End

	dc.w	5,32,-3,16	; slow
	dc.w	7,16,14,64
	dc.w	300
;	dc.w	5,32,-3,16	; slow
;	dc.w	7,16,14,64
;	dc.w	300

;	dc.w	-7,14,-10,14	; circle
;	dc.w	-14,14,-10,14
;	dc.w	300

	dc.w	4,14,4,14	; infinity
	dc.w	7,28,10,14
	dc.w	300

	dc.w	5,16,6,48	; Calm snake
	dc.w	14,48,8,64
	dc.w	400




	dc.w	3,14,3,14	; Nice halo
	dc.w	14,14,14,14
	dc.w	300
	dc.w	$ffff	;End


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	BOBSnake_ChipData1,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************

*** THE COPPERLISTS ***
	CNOP 0,8	; 64 bit alignment for AA
BOBSnake_CL:
	CMOVE	FMODE,BOB_MemoryFetchMode	;Chip Ram fetch mode (0=OCS)
	
	IFEQ RasterTest
	DC.W COLOR00,$001
	ENDC			; Raster Test

	CWAIT	BOB_DIW_V-2,$7		;Time for altering Copperlist
	
	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,BOB_DIW_Start
	CMOVE 	DIWSTOP,BOB_DIW_Stop
	CMOVE 	DDFSTRT,BOB_DDF_Start
	CMOVE 	DDFSTOP,BOB_DDF_Stop
	CMOVE 	BPLCON0,$3200		;3bpl, 8 cols
	CMOVE 	BPLCON1,$0000
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,BOBSnake_Screen_ByteWidth*(BOBSnake_Screen_NumPlanes-1)	;interleaved mode
	CMOVE 	BPL2MOD,BOBSnake_Screen_ByteWidth*(BOBSnake_Screen_NumPlanes-1)

BOBSnake_CL_Screen_Bpl:			;Bitplane pointers
	CMOVE	BPL1PTH,$0
	CMOVE	BPL1PTL,$0
	CMOVE	BPL2PTH,$0
	CMOVE	BPL2PTL,$0
	CMOVE	BPL3PTH,$0
	CMOVE	BPL3PTL,$0

BOBSnake_CL_Screen_Cols:
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ELSE
		CMOVE	COLOR01,$000		; If testing then just use color01 twice
	ENDC
	CMOVE	COLOR01,$00f
	CMOVE	COLOR02,$21f
	CMOVE	COLOR03,$aaf
	CMOVE	COLOR04,$00f
	CMOVE	COLOR05,$21f
	CMOVE	COLOR06,$aaf
	CMOVE	COLOR07,$00f

	; ---
	; Middle - Horizon, start the reflection a little later
	; ---

	CWAIT	255,$E1			;Wait for line > 255
	CWAIT	267,$7			;For reflection at 268 need set the new modulo the prev line

	IFEQ RasterTest
	DC.W COLOR00,$003
	ENDC			; Raster Test

	CMOVE 	BPL1MOD,(-4*(BOBSnake_Screen_ByteWidth*BOBSnake_Screen_NumPlanes))-BOBSnake_Screen_ByteWidth	;interleaved mode
	CMOVE 	BPL2MOD,(-4*(BOBSnake_Screen_ByteWidth*BOBSnake_Screen_NumPlanes))-BOBSnake_Screen_ByteWidth	;interleaved mode




	COPPEREND

*****************************************************************************

;	EVEN
BOBSnake_BOB:
	INCBIN "gfx/ball4_32x16x3_inter.raw"
BOBSnake_BOB_Mask:
	INCBIN "gfx/ball4_32x16x3_mask_inter.raw"
					
*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	BOBSnake_ChipBss1,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************


*****************************************************************************

