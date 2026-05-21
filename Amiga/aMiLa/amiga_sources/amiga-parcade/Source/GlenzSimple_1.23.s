*****************************************************************************

; Name			: GlenzSimple.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Complex and simple vector routines.
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

	SECTION	VectorCode,CODE	;Code section in Public memory

*****************************************************************************

*** Changeable Parameters For Display ***

*** Display Window ***

; Photon:
; Best practice is to start with DDF 38,d0 and DIW 2c81,2cc1 and modify these 
; symmetrically and always in whole 16px steps for compatibility.
; Note DDF start of less than 30 and you start to lose sprites.

VEC_DIW_V		=	$2c	;Hardware Vstart ($2c normal, $24 overscan)
VEC_DIW_H		=	$81	;Hardware Hstart ($81 normal, $71 overscan)
VEC_DIW_Width		=	320	;Pixels		 (multiple of 16, 320 normal, 352 overscan)
VEC_DIW_Height		=	256+8	;Lines		 (256 normal PAL, 272 overscan)

*** Data Fetch ***

VEC_MemoryFetchMode	=	0	;0,1 or 3 
; When FMode=0,1,3 DDF_Width must be a multiple of 16,32,64 respectively.
; NB. I can't get FMODE=2 to work - sorry.
; 0=OCS/ECS, 3=AA in practice
; Bitplane, copper and sprite data should be 64bit (CNOP 0,8) aligned so that it can work
; in ECS/AA modes.
; Bitplanes should be multiples of 64bits wide to take maximum advantage of bandwidth
; 320 or 384 pix width.

VEC_DDF_H		=	$81+16+16+16	;Hardware Hstart ($81 normal, $71 overscan)
VEC_DDF_Width		=	224	;Pixels		 (320 normal pal, 352 overscan)

*****************************************************************************

*** Non-changable parameters for display - Automatically calculated from above ***

VEC_DIW_Vstart		=	(VEC_DIW_V&$ff)<<8
VEC_DIW_Vstop		=	((VEC_DIW_V+VEC_DIW_Height)&$ff)<<8
VEC_DIW_Hstart		=	VEC_DIW_H&$ff
VEC_DIW_Hstop		=	(VEC_DIW_Hstart+VEC_DIW_Width)&$ff
VEC_DIW_Start		=	VEC_DIW_Vstart!VEC_DIW_Hstart
VEC_DIW_Stop		= 	VEC_DIW_Vstop!VEC_DIW_Hstop

	IFEQ	VEC_MemoryFetchMode
VEC_DDF_Increment	=	1
	ENDC
	IFNE	VEC_MemoryFetchMode
VEC_DDF_Increment	=	(VEC_MemoryFetchMode+1)&$fffe
	ENDC	

VEC_DDF_WordWidth	=	VEC_DDF_Width/16
VEC_DDF_Start		=	(VEC_DDF_H/2)-8
VEC_DDF_Stop		=	VEC_DDF_Start+((VEC_DDF_WordWidth-VEC_DDF_Increment)*8)

*****************************************************************************

*** Screen Definitions ***

;The visible screen area and back buffer
VEC_SCR_WIDTH		=	224
VEC_SCR_BYTEWIDTH	=	VEC_SCR_WIDTH/8		;Bytes
VEC_SCR_WORDWIDTH	=	VEC_SCR_BYTEWIDTH/2	;Words
VEC_SCR_HEIGHT		=	224			;Lines (1 extra line to go into reflection)
VEC_SCR_NUMPLANES	=	3			;3bpl/16 cols
VEC_SCR_SIZE		=	VEC_SCR_BYTEWIDTH*VEC_SCR_HEIGHT
VEC_SCR_TOTALSIZE	=	VEC_SCR_SIZE*VEC_SCR_NUMPLANES

; Draw buffer is identical to screen but in 1bpl
VEC_DRAW_TOTALSIZE	=	VEC_SCR_SIZE*1

; Vertical scanline to start the reflection
VEC_DIW_V_REFLECTION	=	VEC_DIW_V+VEC_SCR_HEIGHT


VEC_HORIZ_SCROLL_NUMLINES = VEC_DIW_V_REFLECTION-VEC_DIW_V-1
VEC_HORIZ_SCROLL_REFL_NUMLINES = (VEC_DIW_V+VEC_DIW_Height)-VEC_DIW_V_REFLECTION

*****************************************************************************

VEC_XOFFSET		=	VEC_SCR_WIDTH/2
VEC_YOFFSET		=	VEC_SCR_HEIGHT/2
VEC_ZOFFSET		=	256

VEC_LINEDRAW3_CLIPMINX	=	0
VEC_LINEDRAW3_CLIPMAXX	=	VEC_SCR_WIDTH-1
VEC_LINEDRAW3_CLIPMINY	=	0
VEC_LINEDRAW3_CLIPMAXY	=	VEC_SCR_HEIGHT-1

VEC_CLIPPING		=	1	; Slighty quicker with no clipping
VEC_CLIPCHECK		=	1	; Will write 1 into VEC_ClipCheck_Flag if clipping occured
VEC_BETTER_Z_AVERAGE	=	1	; Use full z average with divs vs a dirty method :)

*****************************************************************************
* Start the effect (usually used for setting up the copper)
* This is called each time the effect is started
* IN:		a0(script ptr),d0(end pause)
* OUT:		
* TRASHED:	d0
*****************************************************************************

	IFND _INTROWRAPPER
SubPartStart:	
	lea	VEC_ControllerScript,a0
	ENDC
VEC_Start:
	; Save script ptr and reset everything to defaults
	bsr	VEC_ResetDefaults		;a0=script ptr

	; Have we already done any one-time setup routines?
	tst.w	VEC_Initialised
	bne.s	.alreadyinit
	bsr.s	VEC_Init
.alreadyinit:
	lea	CUSTOM,a5

	; Clear all screen buffers
	; Main routine has bitplanes off so safe to clear first without being seen
	bsr	VEC_Clear_ScreenBuffers_A5

	;load current palette (default) into work CL and swap so that it's immediately live
	bsr	VEC_InitCopper			;setup bpl ptrs and copperlists
	bsr	VEC_Do_Copper_Palette		;load palette into work copper (including reflection)

	WAITBLIT_A5
	jsr	WaitEOF_A5
	bsr	VEC_DoubleBufferSwap		;swap buffers and CopperLists made live
.fin
	; Continue with main loop
	bsr	VEC_MainLoop

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

VEC_Init:
	move.w	#1,VEC_Initialised

	; Multiply sine values by screen widths
	bsr	VEC_Calc_PreMult_ScreenHeight

	; Create stipple pattern
	bsr	VEC_Calc_Stipple

	; Convert sine table to BPLCON shifts
	jsr	VEC_Calc_HorizScroll_BPLCON

	rts


*****************************************************************************
* Called at the start of each routine run. Use to set everything to defaults
* to allow multiple reruns.
* IN:		a0, new script to run
* OUT:		
* TRASHED:	d0
*****************************************************************************

VEC_ResetDefaults:

	; Store script ptr and reset VEC_Controller_Info to sensible defaults
	lea	VEC_Controller_Info,a1
	move.l	a0,VEC_CTRL_SCRIPT_PTR(a1)

	; Reset frame timers to 1 frame as a sensible default
	moveq	#1,d0
	move.w	d0,VEC_CTRL_FRAMES_MIN(a1)

	;stop all time based effects
	moveq	#0,d0
	move.w	d0,VEC_CTRL_PAUSE_COUNTER(a1)
	move.w	d0,VEC_CTRL_PALETTE_ACTIVE(a1)
	move.w	d0,VEC_CTRL_ROT_CHANGE_ACTIVE(a1)
	move.w	d0,VEC_CTRL_FLASH_COUNT(a1)
	move.w	d0,VEC_CTRL_MOVE_ACTIVE(a1)

	; Load default palette
	lea	VEC_PAL_Default,a2
	moveq	#0,d0
	bsr	VEC_Controller_FX_Palette	;a1,a2,d0
	
	; Preload first object
	lea	VEC_Controller_Info,a1
	move.l	#Obj_Glenz24_Info,a2
	bsr	VEC_Controller_FX_Load		;a1/a2

	; Reset fill/clear buffers
	moveq	#0,d0
	move.l	d0,VEC_SCR_CLR_Details+VEC_SCR_CLR_SRCPTR
	move.l	d0,VEC_WORK_CLR_Details+VEC_SCR_CLR_SRCPTR

	;TODO: Clear horizsine

	rts


*****************************************************************************
* Runs the effect.
* IN:		a0(text message ptr),d0(end pause)
* OUT:		d0(0=Running, 1=Ending)
* TRASHED:	d0
*
* The order of the operations in this loop looks odd. It is to optimize
* cpu processing during large blits.
*
* Simple:
* Two large blits, one clear screen and one fill screen. Split CPU use up between
* these. Fill screen is the bigger wait so move CPU code there.
*
* Complex:
* One large blit for clear screen. Lots of small but unpredicable blits 
* for each face. Put most CPU in the clear screen and a small routine after
* the last face is blit cleared.
*
* CPU Usage, high to low:
* Rotate
* Perspective
* VEC_Calc_Face_Stats
* VEC_Calc_Visible_Faces
* VEC_Calc_Rotation_Matrix_For_Object
* VEC_Calc_Screen_Clr_Bounding
*
*****************************************************************************

VEC_MainLoop:
	clr.w	VEC_Finished

	lea	CUSTOM,a5

	; prerun all the calculations as the order of the loop is strange
	; see notes above.
	move.l	VEC_ObjectCurrent_Adr,a6
	bsr	VEC_Calc_Rotation_Matrix_For_Object
	bsr 	VEC_Rotate
	bsr	VEC_Perspective
	bsr	VEC_Calc_Screen_Clr_Bounding	;also screen clear
	bsr	VEC_Calc_Visible_Faces
	bsr	VEC_Calc_Face_Stats
	bsr	VEC_Sort_Faces	

	jsr	WaitEOF_A5			;so we enter the loop in the right way

.Mainloop1:
	TIMERON	$111

	BLIT_NASTY_OFF_A5			; Default is no blitter nasty

	;Check vector type, simple or complex.
	move.l	VEC_ObjectCurrent_Adr,a6
	tst.w	VEC_OBJ_COMPLEX(a6)
	beq.s	.simple

; ***
; Complex vectors. 
; ***
.complex:
	bsr	VEC_Clear_WorkBuffer_Bounded_Blitter_A5

	; Must do Calc stats/sort here as we may have switched from simple to complex
	; and simple will not have done these. Complex takes a perf hit because of this.
	move.l	VEC_ObjectCurrent_Adr,a6
	bsr	VEC_Calc_Face_Stats
	bsr	VEC_Sort_Faces

	bsr	VEC_Calc_Screen_Clr_Bounding	; Based on current rotated+pers pts

	; Check clearscreen blitter use
	;TIMERON	$600
	;BLIT_NASTY_ON_A5
	;WAITBLIT_A5
	;BLIT_NASTY_OFF_A5
	;TIMERON	$111

	bsr	VEC_DrawObject_Complex

	; Read new script lines and perform
	lea	VEC_Controller_Info,a1		;controller info
	move.l	VEC_ObjectCurrent_Adr,a0	;single object info (just object in this routine)
	bsr	VEC_Controller_ReadCommands	;Read new commands
	bsr	VEC_Controller_Perform		;Do any ongoing time-based effects and update angles

	; Must do rotate to calc visible faces here as may jump straight into simple vector
	move.l	VEC_ObjectCurrent_Adr,a6
	bsr	VEC_Calc_Rotation_Matrix_For_Object
	bsr 	VEC_Rotate
	bsr	VEC_Perspective
	bsr	VEC_Calc_Visible_Faces

	bra.s	.endofvector

; ***
; Simple
; ***
.simple:
	bsr	VEC_Clear_WorkBuffer_BlitterCPU_A5		; Clear whole screen + CPU clear
	
	;move.l	VEC_ObjectCurrent_Adr,a6
	
	bsr	VEC_Calc_Screen_Clr_Bounding	; Based on current rotated+pers pts, used for fills/clrs

	; Check clearscreen blitter use
	;TIMERON	$600
	;BLIT_NASTY_ON_A5
	;WAITBLIT_A5
	;BLIT_NASTY_OFF_A5
	;TIMERON	$111

	bsr	VEC_DrawObject			; Draw lines 
	bsr	VEC_Fill_Screen_Bounded		; Fill screen

	; Read new script lines and perform
	lea	VEC_Controller_Info,a1		;controller info
	move.l	VEC_ObjectCurrent_Adr,a0	;single object info (just object in this routine)
	bsr	VEC_Controller_ReadCommands	;Read new commands
	bsr	VEC_Controller_Perform		;Do any ongoing time-based effects and update angles

	TIMERON	$060
	move.l	VEC_ObjectCurrent_Adr,a6
	bsr	VEC_Calc_Rotation_Matrix_For_Object
	bsr 	VEC_Rotate
	bsr	VEC_Perspective
	bsr	VEC_Calc_Visible_Faces
	TIMERON $111

.endofvector:
	tst.w	VEC_Finished			;Check if script ended
	bne	.fin

	bsr	VEC_Do_Horiz_Scroll		;do horizontal sine effect
	bsr	VEC_Do_Copper_Palette		;load palette into copper (including reflection)

	lea	VEC_Controller_Info,a1		;controller info
	bsr	VEC_Controller_Perform_Flash	;Flash has to go last as it updates copper palette

	;Blitter nasty on while we finish off any blits
	TIMERON	$600
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5

	TIMEROFF

	; Swap screens and buffers for next frame
	; For a 1 frame vector we need to wait until NumLev3=1
	; For a 2 frame vector we need to wait until NumLev3=2
	; Then wait for EOF and then swap
	lea	VEC_Controller_Info,a0
	lea	NumLev3,a1
	move.w	VEC_CTRL_FRAMES_MIN(a0),d0	;what minimum frames are we targeting?
.vbiloop:
	cmp.w	(a1),d0
	bgt.s	.vbiloop			

	jsr	WaitEOFExact_A5			;Wait until last line of frame before vblank int
	move.w	(a1),d0				;current number of frames started so far

	moveq	#0,d0
	move.w	d0,(a1)				;have to clear NumLev3 manually as didn't use WaitVBI
	bsr	VEC_DoubleBufferSwap		;swap buffers and CopperLists


.Testmouse
	btst 	#10-8,POTGOR+CUSTOM	;rmb quits section
	beq.s	.fin
	btst 	#6,$bfe001		;lmb quits all
	bne.w 	.Mainloop1
	move.w	#1,Quit_Flag
.fin
	moveq	#1,d0		;Signal finished
	rts


*****************************************************************************

VEC_InitCopper:

	; Fill/clear details buffers	
	move.l	#VEC_SCR_CLR_Details,VEC_SCR_CLR_Details_Ptr	;Physical fill details adr
	move.l	#VEC_WORK_CLR_Details,VEC_WORK_CLR_Details_Ptr	;Logical fill details adr

	; Copper list buffers - copy screen list into 2nd buffer for doublebuffering
	lea	VEC_Screen_CL,a0
	lea	VEC_Work_CL,a1
	move.w	#(VEC_CL_SIZE/2)-1,d0	;size in words
.copy:
	move.w	(a0)+,(a1)+
	dbf	d0,.copy

	;Screen copper BPL pointers
	lea	VEC_Screen_CL,a0
	move.l	a0,VEC_Screen_CL_Ptr
	lea	VEC_Screen_CL_Bpl-VEC_Screen_CL(a0),a0	;copper bpl pointer block
	moveq	#VEC_SCR_NUMPLANES,d0
	move.l	#Screen_Buffer,d1	;in d1 for InitCopperBplPtrs
	move.l	d1,VEC_Screen_Ptr
	moveq 	#VEC_SCR_BYTEWIDTH,d2	;interleaved
	jsr	InitCopperBplPtrs	;a0=bpl ptr block, d0=numplanes, d1=scr buffer, d2=modulo

	;Work copper BPL pointers
	lea	VEC_Work_CL,a0
	move.l	a0,VEC_Work_CL_Ptr
	lea	VEC_Screen_CL_Bpl-VEC_Screen_CL(a0),a0	;copper bpl pointer block
	moveq	#VEC_SCR_NUMPLANES,d0
	move.l	#Work_Buffer,d1		;in d1 for InitCopperBplPtrs
	move.l	d1,VEC_Work_Ptr
	moveq 	#VEC_SCR_BYTEWIDTH,d2	;interleaved
	jsr	InitCopperBplPtrs	;a0=bpl ptr block, d0=numplanes, d1=scr buffer, d2=modulo

	rts


*****************************************************************************
* Swaps the copperlist, screen and clr/fill pointers and activates the CL
* for the next frame. 
* NOTE: Call before vblank so new copper takes effect next frame.
* IN:		
* OUT:		
* TRASHED:	d0-d1/a0
*****************************************************************************

VEC_DoubleBufferSwap:
	; Swap fill details
	lea	VEC_SCR_CLR_Details_Ptr,a0
	movem.l	(a0),d0/d1
	exg	d0,d1
	movem.l	d0/d1,(a0)

	; Swap screen buffer details
	lea	VEC_Screen_Ptr,a0
	movem.l	(a0),d0/d1
	exg	d0,d1
	movem.l	d0/d1,(a0)

	; Swap copper buffer details
	lea	VEC_Screen_CL_Ptr,a0
	movem.l	(a0),d0/d1
	exg	d0,d1
	movem.l	d0/d1,(a0)

	; and activate
	move.l 	d0,COP1LCH(a5)		; Active NEXT frame

	rts


*****************************************************************************
* Creates table of screen height * screenwidth bytes (non-interleaved) or
* screen height * (screenwidth bytes * num bitplanes) (interleaved)
* Use for one-time setup
* IN:		
* OUT:		
* TRASHED:	a0,d0,d1,d2,d7
*****************************************************************************

VEC_Calc_PreMult_ScreenHeight:

	;interleaved
	lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a0
	move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d1
	bsr.s	.calc

	;single bpl (face mask buffer) or 1 bpl
	lea	VEC_Mult_SCR_Height_ByteWidth,a0
	move.w	#VEC_SCR_BYTEWIDTH,d1
	
.calc	;d1 = byte width per line
	moveq	#0,d0
	move.w	#VEC_SCR_HEIGHT-1,d7
.loop
	move.w	d0,d2
	mulu	d1,d2
	move.w	d2,(a0)+
	addq.w	#1,d0
	dbf	d7,.loop

	rts


*****************************************************************************
* Modifies the horiz scroll sine table into bplcon1 shift values.
* Use for one-time setup
* IN:		
* OUT:		
* TRASHED:	a0,d0,d1,d2
*****************************************************************************

VEC_Calc_HorizScroll_BPLCON:

	lea	VEC_HorizScroll_Table,a0
	move.w	#VEC_HORIZSCROLL_TABLE_NUMWORDS-1,d2
.loop
	move.w	(a0),d0
	move.w	d0,d1
	lsl.w	#4,d1
	or.w	d0,d1		;change 000f to 00ff
	move.w	d1,(a0)+
	dbf	d2,.loop

	rts	


*****************************************************************************
* Creates our stipple patterns. 
* Use for one-time setup
* IN:		
* OUT:		
* TRASHED:	a0,d0,d1,d2
*****************************************************************************

VEC_Calc_Stipple:

	lea	VEC_Stipple_1Bpl,a0
	move.w	#$5555,d0
	move.w	#$aaaa,d1

	move.w	#(VEC_SCR_HEIGHT/2)-1,d7
.lineloop
	moveq	#VEC_SCR_WORDWIDTH-1,d6
.wordloop1
	move.w	d0,(a0)+
	dbf	d6,.wordloop1
	
	moveq	#VEC_SCR_WORDWIDTH-1,d6
.wordloop2
	move.w	d1,(a0)+
	dbf	d6,.wordloop2

	dbf	d7,.lineloop

	rts


*****************************************************************************
* Clears the entire work buffer screen. Every frame.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0/a0
*****************************************************************************

VEC_Clear_WorkBuffer_BlitterCPU_A5:

; Tune this so that the very first WAITBLIT call AFTER this
; routine should take no time at all.
; CPU clear first as blitter busy filling previous frame
VECClear_BlitHeight = 135; 115
VECClear_CPUHeight = (VEC_SCR_HEIGHT-VECClear_BlitHeight)

	; Blitter
	move.l  VEC_Work_Ptr,a0		; memory to clear
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	move.l	#$01000000,BLTCON0(a5)
	move.l	a0,BLTDPTH(a5)
	move.w	#0,BLTDMOD(a5)
	move.w	#((VECClear_BlitHeight*VEC_SCR_NUMPLANES)*64)+VEC_SCR_WORDWIDTH,BLTSIZE(a5)
	; Max height = 1024, made wordwidth = 64
	BLIT_NASTY_OFF_A5


	; CPU
	; a0 = buffer to clear, we need to skip the part cleared by the blitter
	; d7 = size in bytes to clear
	move.l  VEC_Work_Ptr,a0		; memory to clear
	lea	VECClear_BlitHeight*VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES(a0),a0
	move.l	#VECClear_CPUHeight*VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d7
	jmp	CPUClearBuffer		;trashes all

	;rts


*****************************************************************************
* Clears entire front and back buffer. Done once at startup to ensure clean env.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	
*****************************************************************************

VEC_Clear_ScreenBuffers_A5:
	;smallest first so the final wait blit is more time for following CPU routines.
	WAITBLIT_A5
	move.l	#$01000000,BLTCON0(a5)
	move.w	#0,BLTDMOD(a5)
	move.l	#Scratch_Buffer,BLTDPTH(a5)
	move.w	#(VEC_SCR_HEIGHT*64)+VEC_SCR_WORDWIDTH,BLTSIZE(a5)

	WAITBLIT_A5
	move.l	#Screen_Buffer,BLTDPTH(a5)
	move.w	#((VEC_SCR_HEIGHT*VEC_SCR_NUMPLANES)*64)+VEC_SCR_WORDWIDTH,BLTSIZE(a5)

	WAITBLIT_A5
	move.l	#Work_Buffer,BLTDPTH(a5)
	move.w	#((VEC_SCR_HEIGHT*VEC_SCR_NUMPLANES)*64)+VEC_SCR_WORDWIDTH,BLTSIZE(a5)

	rts


*****************************************************************************
* Fills a bounded area of the screen.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0-d2/a0
*****************************************************************************

VEC_Fill_Screen_Bounded:
	; We only fill the box that we've drawn in.
	move.l	VEC_WORK_CLR_Details_Ptr,a0

	; Get start address of bottom right corner (fulls are in descending mode so match with clear)
	; If the value is 0 then no valid fill was done, so skip the clear as well - happens at
	; start of routine
	move.l	VEC_SCR_CLR_SRCPTR(a0),d0
	beq.s	.exit

	move.w	VEC_SCR_CLR_BLTSIZE(a0),d2	;completed BLTSIZE in d4
	move.w	VEC_SCR_CLR_BYTEMODULO(a0),d1

	lea 	BLTAPTH(a5),a0
	WAITBLIT_A5
	move.l	#$09f00012,BLTCON0(a5)	; Descending, exclusive fill mode
	move.w	d1,BLTAMOD(a5)
	move.w	d1,BLTDMOD(a5)
	move.l	d0,(a0)+	; BLTAPTH
	move.l	d0,(a0)+	; BLTDPTH
	move.w	d2,(a0)		; BLTSIZE
.exit:
	rts


*****************************************************************************
* Clears the work buffer screen. Only clears the bounded area that was drawn in.
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0-d2/a0
*****************************************************************************

VEC_Clear_WorkBuffer_Bounded_Blitter_A5:
	
	; We only fill the box that we've drawn in. 
	move.l	VEC_WORK_CLR_Details_Ptr,a0

	; Get start address of bottom right corner (fills are in descending mode so match with clear)
	; If the value is 0 then no valid fill was done, so skip the clear as well - happens at
	; start of routine
	move.l	VEC_SCR_CLR_SRCPTR(a0),d0
	beq.s	.exit

	move.w	VEC_SCR_CLR_BLTSIZE(a0),d2	;completed BLTSIZE in d4
	move.w	VEC_SCR_CLR_BYTEMODULO(a0),d1

	lea 	BLTDPTH(a5),a0
	WAITBLIT_A5
	move.l	#$01000002,BLTCON0(a5)	;desending to match fill routine calculations
	move.w	d1,BLTDMOD(a5)
	move.l	d0,(a0)+	; BLTDPTH
	move.w	d2,(a0)		; BLTSIZE
.exit:
	rts


*****************************************************************************
* Runs the controller script.
* Note the commands are read until a FX_PAUSE command is reached. So beware
* of hogging the CPU with too many commands at once.
* IN:		a1, VEC_Controller_Info
*		a0, CurrentObject 
* OUT:		
* TRASHED:	
*****************************************************************************

VEC_Controller_ReadCommands:

	;Time to get a new command from the script? Subtract each frame until 0
	move.w	VEC_CTRL_PAUSE_COUNTER(a1),d0
	bne	.pausing

	; Is flash active, don't read any new commands while active
	move.w	VEC_CTRL_FLASH_COUNT(a1),d0
	bne.s	.exit	

	; Get current script pointer
	move.l	VEC_CTRL_SCRIPT_PTR(a1),a6
.loop:
	move.w	(a6)+,d0

	cmpi.w	#VEC_FX_END_FLAG,d0		;End of script? Don't save pointer and exit
	;beq.s	.restartscript
	beq	.fin

	; subrouteins need to preserve a6
	cmpi.w	#VEC_FX_PAUSE_FLAG,d0
	beq.s	.fx_pause
	cmpi.w	#VEC_FX_FLASH_FLAG,d0
	beq.s	.fx_flash
	cmpi.w	#VEC_FX_LOAD_FLAG,d0
	beq	.fx_load
	cmpi.w	#VEC_FX_MORPH_FLAG,d0
	beq	.fx_morph
	cmpi.w	#VEC_FX_PALETTE_FLAG,d0
	beq	.fx_pallete
	cmp.w	#VEC_FX_CLONE_ROTATION_FLAG,d0
	beq	.fx_clone_rotation
	cmp.w	#VEC_FX_CHANGE_ROT_DELTA_FLAG,d0
	beq	.fx_change_rot_delta
	cmp.w	#VEC_FX_CHANGE_ROT_FLAG,d0
	beq	.fx_change_rot
	cmp.w	#VEC_FX_HORIZSINE_FLAG,d0
	beq	.fx_horizsine
	cmp.w	#VEC_FX_MOVE_FLAG,d0
	beq	.fx_move

.exit:
	rts

.fx_pause:
	move.w	(a6)+,d0
	move.w	d0,VEC_CTRL_PAUSE_COUNTER(a1)
	move.l	a6,VEC_CTRL_SCRIPT_PTR(a1)
	rts					;exit when starting pause

.fx_flash:
	move.w	#VEC_CTRL_FLASH_STARTCOUNT,VEC_CTRL_FLASH_COUNT(a1)	; start the flash process
	bra	.loop

.fx_load:
	move.l	(a6)+,a2		;New object
	bsr	VEC_Controller_FX_Load
	bra	.loop

.fx_morph:
	move.w	(a6)+,d0		;Speed
	move.l	(a6)+,a2		;New points
	bsr	VEC_Controller_FX_Morph
	bra	.loop

.fx_pallete:
	move.w	(a6)+,d0		;Speed
	move.l	(a6)+,a2		;New pallete
	bsr	VEC_Controller_FX_Palette	
	bra	.loop

.fx_clone_rotation:
	move.l	(a6)+,a2		;Object to clone from
	bsr	VEC_Controller_FX_Clone_Rotation
	bra	.loop

.fx_change_rot_delta:
	movem.w	(a6)+,d0-d2
	bsr	VEC_Controller_FX_Change_Rot_Delta
	bra	.loop

.fx_change_rot:
	movem.w	(a6)+,d0-d3		;x,y,z,speed
	bsr	VEC_Controller_FX_Change_Rot
	bra	.loop

.fx_horizsine:
	movem.w	(a6)+,d0-d1		;speed,step
	bsr	VEC_Controller_FX_HorizSine
	bra	.loop

.fx_move:
	movem.w	(a6)+,d0-d3		;x,y,z,speed
	bsr	VEC_Controller_FX_Move
	bra	.loop

.pausing:
	;use the expected frame count for the object as the speed to decrease
	;so that pause values roughly match
	sub.w	VEC_CTRL_FRAMES_MIN(a1),d0
	bpl.s	.pause_more
	moveq	#0,d0			;finish pausing
.pause_more:
	move.w	d0,VEC_CTRL_PAUSE_COUNTER(a1)
	rts

.fin:
	move.w	#1,VEC_Finished
	rts


*****************************************************************************
* Performs any time-based controller routines.
* IN:		a1, VEC_Controller_Info
*		a0, current object
* OUT:
* TRASHED:	d0-d7/a2-a6
*****************************************************************************

VEC_Controller_Perform:

; TODO: Change to bitflag

.morph:
	tst.w	VEC_OBJ_MORPH_ACTIVE(a0)
	beq.s	.pal
	bsr	VEC_Controller_FX_Morph_Perform
.pal:
	tst.w	VEC_CTRL_PALETTE_ACTIVE(a1)
	beq.s	.rot
	bsr	VEC_Controller_FX_Palette_Perform
.rot:
	tst.w	VEC_CTRL_ROT_CHANGE_ACTIVE(a1)
	beq.s	.move
	bsr	VEC_Controller_FX_Change_Rot_Perform
.move:
	tst.w	VEC_CTRL_MOVE_ACTIVE(a1)
	beq.s	.exit
	bsr	VEC_Controller_FX_Move_Perform

.exit:
	; Update current angles
	movem.w	VEC_OBJ_THETA_X(a0),d0-d5
	; current d0-d2, delta d3-d5

	; have to increase the rotation speed if not a one frame vector
	; so that 1 frame, 2 frame,3 frame vectors move at same apparent speed
	move.w	VEC_CTRL_FRAMES_MIN(a1),d7
	subq.w	#1,d7			; fix for dbf
	move.w	#VEC_SIN_TABLE_OFFSET_MASK,d6
.thetaloop
	add.w	d3,d0
	add.w	d4,d1
	add.w	d5,d2
	dbf	d7,.thetaloop

	and.w	d6,d0			;ensure in range
	and.w	d6,d1
	and.w	d6,d2
	movem.w d0-d2,VEC_OBJ_THETA_X(a0)	;save new values

	rts



*****************************************************************************
* Performs the flash routine
* IN:		a1, VEC_Controller_Info
* OUT:
* TRASHED:	d0/d1/a2/a3
*****************************************************************************

VEC_Controller_Perform_Flash:

; TODO: Change to bitflag

	move.w	VEC_CTRL_FLASH_COUNT(a1),d0
	beq.s	.exit			;no flash in progress
	;$555 - 5
	;$aaa - 4
	;$fff - 3
	;$aaa - 2
	;$555 - 1
	
	moveq	#5,d1
	cmp.w	d0,d1
	beq.s	.555
	moveq	#1,d1
	cmp.w	d0,d1
	beq.s	.555

	moveq	#4,d1
	cmp.w	d0,d1
	beq.s	.aaa
	moveq	#2,d1
	cmp.w	d0,d1
	beq.s	.aaa
.fff:
	move.w	#$fff,d1
	bra.s	.setcolor
.aaa:
	move.w	#$aaa,d1
	bra.s	.setcolor
.555:
	move.w	#$555,d1

.setcolor:
	subq.w	#1,d0			;decrease counter
	move.w	d0,VEC_CTRL_FLASH_COUNT(a1)

	; Change color 00 in the copperlist in normal/reflection parts
	move.l	VEC_Work_CL_Ptr,a2
	lea	VEC_CL_COL_OFFSET+2(a2),a3	;normal colors
	move.w	d1,(a3)
	lea	VEC_CL_COL_REFL_OFFSET+2(a2),a3	;reflection colors
	move.w	d1,(a3)
.exit:
	rts


*****************************************************************************
* Loads a new object.
* IN:		a1, Vector controller info
*		a2, new object info (Obj_Glenz24_Info for example)
* OUT:		a0, new curent object
* TRASHED:	d0-d2/d7/a3/a4
*****************************************************************************

VEC_Controller_FX_Load:

	; Test if new object has been initialised already, if so skip
	; the inintial face/pts copy and just change current pointer
	tst.w	VEC_OBJ_INITIALIZED(a2)
	bne.s	.changecurrent	

	; Points - ASSUMPTION: Points buffer must be large enough to hold!
	move.l	VEC_OBJ_PTS_PTR(a2),a3
	move.l 	VEC_OBJ_PTSINITIAL_PTR(a2),a4

	; Copy the initial points into the pts buffer
	move.w	(a4)+,d7	; num points-1 
	move.w	d7,(a3)+
.copypts
	movem.w	(a4)+,d0-d2
	movem.w	d0-d2,(a3)
	addq.l	#6,a3
	dbf	d7,.copypts

	; Mark as initialised
	move.w	#1,VEC_OBJ_INITIALIZED(a2)

.changecurrent:
	; Change current object
	move.l	a2,a0
	move.l	a0,VEC_ObjectCurrent_Adr

	;Update frame target based on object
	move.w VEC_OBJ_NUMFRAMES(a0),VEC_CTRL_FRAMES_MIN(a1)

	rts


*****************************************************************************
* Copies the rotation from one object to another.
* IN:		a1, vector controller info
*		a0, current object definition
*		a2, object definition to clone (Obj_Glenz24_Info for example)
* OUT:		
* TRASHED:	d0-d2/a2
*****************************************************************************

VEC_Controller_FX_Clone_Rotation:

	movem.w	VEC_OBJ_THETA_X(a2),d0-d2
	movem.w	d0-d2,VEC_OBJ_THETA_X(a0)

	movem.w	VEC_OBJ_THETA_DX(a2),d0-d2
	movem.w	d0-d2,VEC_OBJ_THETA_DX(a0)

	rts


*****************************************************************************
* Changes rot delta.
* IN:		a1, vector controller info
*		a0, current object
*		d0-d2, new x,y,z
* OUT:		
* TRASHED:	a0
*****************************************************************************

VEC_Controller_FX_Change_Rot_Delta:

	movem.w	d0-d2,VEC_OBJ_THETA_DX(a0)

	rts


*****************************************************************************
* Changes rot values. Will do over time is speed >0
* IN:		a1, vec controller info
*		a0, current object info
* 		d0-d3, new x,y,z, speed
* OUT:		
* TRASHED:	d0-d3
*****************************************************************************

VEC_Controller_FX_Change_Rot:
	tst.w	d3
	bne.s	.slow
	move.w	#0,VEC_CTRL_ROT_CHANGE_ACTIVE(a1)	;disable change
	movem.w	d0-d2,VEC_OBJ_THETA_X(a0)		;change rot
	rts

.slow:
	move.w	#1,VEC_CTRL_ROT_CHANGE_ACTIVE(a1)	;enable change
	movem.w	d0-d3,VEC_CTRL_ROT_CHANGE_X(a1)		;store params in controller info

	; If doing slow transform also have to zero rot delta
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

	movem.w	d0-d2,VEC_OBJ_THETA_DX(a0)

	rts


*****************************************************************************
* Performs rot change
* IN:		a1, VEC_Controller_Info
*		a0, current object info
* OUT:
* TRASHED:	d0-d7
*****************************************************************************

VEC_Controller_FX_Change_Rot_Perform:

	movem.w	VEC_CTRL_ROT_CHANGE_X(a1),d0-d2
	movem.w	VEC_OBJ_THETA_X(a0),d3-d5
	
	;TODO: fix this lame code, should be working out the best direction

	moveq   #0,d6			;flag

	move.w	VEC_CTRL_ROT_CHANGE_SPEED(a1),d7
.x	cmp.w	d3,d0
	beq.s	.y
	moveq	#1,d6			;set flag
	addq.w	#1,d3
	andi.w	#VEC_SIN_TABLE_OFFSET_MASK,d3
	dbf	d7,.x

	move.w	VEC_CTRL_ROT_CHANGE_SPEED(a1),d7
.y	cmp.w	d4,d1
	beq.s	.z
	moveq	#1,d6			;set flag
	addq.w	#1,d4
	andi.w	#VEC_SIN_TABLE_OFFSET_MASK,d4
	dbf	d7,.y

	move.w	VEC_CTRL_ROT_CHANGE_SPEED(a1),d7
.z	cmp.w	d5,d2
	beq.s	.q
	moveq	#1,d6			;set flag
	addq.w	#1,d5
	andi.w	#VEC_SIN_TABLE_OFFSET_MASK,d5
	dbf	d7,.z

.q
	tst.w	d6
	bne.s	.bye
	move.w	#0,VEC_CTRL_ROT_CHANGE_ACTIVE(a1)	;finished
.bye
	;store changes
	movem.w	d3-d5,VEC_OBJ_THETA_X(a0)

	rts


*****************************************************************************
* Moves. Will do over time is speed >0
* IN:		a1, vec controller info
*		a0, current object info
* 		d0-d3, new x,y,z, speed
* OUT:		
* TRASHED:	d0-d3
*****************************************************************************

VEC_Controller_FX_Move:
	tst.w	d3
	bne.s	.slow
	move.w	d3,VEC_CTRL_MOVE_ACTIVE(a1)	;disable change, d3 is zero here
	movem.w	d0-d2,VEC_OBJ_POSX(a0)		;change pos
	rts

.slow:
	move.w	#1,VEC_CTRL_MOVE_ACTIVE(a1)	;enable change
	movem.w	d0-d3,VEC_CTRL_MOVE_X(a1)	;store params in controller info

	rts


*****************************************************************************
* Performs move change
* IN:		a1, VEC_Controller_Info
*		a0, current object info
* OUT:
* TRASHED:	d0-d6
*****************************************************************************

VEC_Controller_FX_Move_Perform:

	move.w	VEC_CTRL_MOVE_SPEED(a1),d2	;speed
	moveq	#0,d6				;flag

	move.w	VEC_CTRL_MOVE_X(a1),d1	;final value
	move.w	VEC_OBJ_POSX(a0),d0	;current value
	bsr.s	VEC_Move_Coord_Towards
	move.w	d0,VEC_OBJ_POSX(a0)	;save value
	cmp.w	d0,d1
	beq.s	.y
	moveq	#1,d6
.y:
	move.w	VEC_CTRL_MOVE_Y(a1),d1	;final value
	move.w	VEC_OBJ_POSY(a0),d0	;current value
	bsr.s	VEC_Move_Coord_Towards
	move.w	d0,VEC_OBJ_POSY(a0)	;save value
	cmp.w	d0,d1
	beq.s	.z
	moveq	#1,d6
.z:
	move.w	VEC_CTRL_MOVE_Z(a1),d1	;final value
	move.w	VEC_OBJ_POSZ(a0),d0	;current value
	bsr.s	VEC_Move_Coord_Towards
	move.w	d0,VEC_OBJ_POSZ(a0)	;save value
	cmp.w	d0,d1
	beq.s	.test_flag
	moveq	#1,d6

.test_flag:
	tst.w	d6
	bne.s	.exit			;test flag, if not zero not finished
	move.w	#0,VEC_CTRL_MOVE_ACTIVE(a1)	;finished
.exit:
	rts

*****************************************************************************
* Moves a coordinate towards a value at given speed.
* IN:		d0, current value
*		d1, target value
*		d2, speed
* OUT:		d0, new value
* TRASHED:	
*****************************************************************************

VEC_Move_Coord_Towards:
	cmp.w	d1,d0
	beq.s	.next			; already there
	bgt.s	.greater
.less:
	add.w	d2,d0			;add the speed
	cmp.w	d1,d0			;how about now?
	ble.s	.next			;still moving in right direction
.less_now_greater:
	move.w	d1,d0			;overshot, set value to final
	bra.s	.next

.greater:
	sub.w	d2,d0			;sub the speed
	cmp.w	d1,d0			;how about now?
	bge.s	.next			;still moving in right direction
.greater_now_less:
	move.w	d1,d0			;overshot, set value to final
.next
	rts

*****************************************************************************
* Changes the horizontal scroll effect
* IN:		a1, vec controller info
*		a0, current object info
* 		d0-d3, speed,step,speed,step
* OUT:		
* TRASHED:	d0-d4,a2
*****************************************************************************

VEC_Controller_FX_HorizSine:

	lea	VEC_HorizScroll_Variables,a2

	;2 because when we deactivate we use this as a count for coping
	;with doublebuffered copper
	move.w	#2,VEC_HORIZSCROLL_ACTIVE(a2)
	movem.w	d0-d1,VEC_HORIZSCROLL_SIN1_SPEED(a2)

	rts

*****************************************************************************
* Sets up the pallet change process.
* IN:		a1, vec controller info
*		a2, new pallete
*		d0, speed
* OUT:		
* TRASHED:	d0/a2/a3
*****************************************************************************

VEC_Controller_FX_Palette:
	; If speed is 0 just instastransform
	tst.w	d0
	bne.s	.palette

	move.w	d0,VEC_CTRL_PALETTE_ACTIVE(a1)	;disable change, d0 is zero here

	moveq	#((1<<VEC_SCR_NUMPLANES)*2)-1,d0	;8 cols * 2
	lea	VEC_Palette,a3
.loop:
	move.w	(a2)+,(a3)+
	dbf	d0,.loop

	rts

.palette:
	move.l	a2,VEC_CTRL_PALETTE_PTR(a1)	; supplied pallete now the master
	move.w	d0,VEC_CTRL_PALETTE_COUNTER(a1)	; Setup counter and speed
	move.w	d0,VEC_CTRL_PALETTE_SPEED(a1)
	
	moveq	#1,d0				; Initial step is 1 (we run 1-15)
	move.w	d0,VEC_CTRL_PALETTE_STEP(a1)
	move.w	d0,VEC_CTRL_PALETTE_ACTIVE(a1)	; Set pallete flag to 1

	
	moveq	#((1<<VEC_SCR_NUMPLANES)*2)-1,d0	; 8 cols * 2
	
	lea	VEC_Palette,a2			;current active colors
	lea	VEC_Palette_Src,a3		;store original active colors
.loop2:
	move.w	(a2)+,(a3)+
	dbf	d0,.loop2

	rts


*****************************************************************************
* Performs the pallete change.
* IN:		a1, VEC_Controller_Info
* OUT:
* TRASHED:	d0-d7/a2/a3/a4
*****************************************************************************

VEC_Controller_FX_Palette_Perform:

	;check counter
	move.w	VEC_CTRL_PALETTE_COUNTER(a1),d0
	beq.s	.pal
	subq.w	#1,d0
	move.w	d0,VEC_CTRL_PALETTE_COUNTER(a1)
	rts
.pal:
	;Reset counter for next time
	move.w	VEC_CTRL_PALETTE_SPEED(a1),VEC_CTRL_PALETTE_COUNTER(a1)

	lea	VEC_Palette_Src,a2		;starting colors
	move.l	VEC_CTRL_PALETTE_PTR(a1),a3	;final colors
	lea	VEC_Palette,a4			;active colors
	move.w	VEC_CTRL_PALETTE_STEP(a1),d3	;step
	move.w	d3,d0
	addq.w	#1,d0				;step+1 for next time
	move.w	d0,VEC_CTRL_PALETTE_STEP(a1)	;save step

	moveq	#((1<<VEC_SCR_NUMPLANES)*2)-1,d7	;8 colors and 8 reflection colors
.loop	move.w	(a2)+,d0		;starting color
	move.w	(a3)+,d1		;current color
	move.w	d3,d2			;step

	jsr	RGB12_Interpolate_Fast	;d0-d2. Needs RGB12_Interpolate_Fast_BuildTable done at startup.
	move.w	d0,(a4)+		;new active color
	dbf	d7,.loop

	;if step was 15 then we have finished
	cmp.w	#15,d3
	bne.s	.fin

	move.w	#0,VEC_CTRL_PALETTE_ACTIVE(a1)	;d7 will be zero here, finish routine
.fin:

	rts


*****************************************************************************
* Sets up the morph process.
* IN:		a1, vector_controller_info
*		a0, current object info
*		a2, new pts
*		d0, speed
* OUT:		
* TRASHED:	d0-d2/d7/a2/a3
*****************************************************************************

VEC_Controller_FX_Morph:
	; set new initial points which the morph will use
	move.l	a2,VEC_OBJ_PTSINITIAL_PTR(a0)

	; If speed is 0 just instastransform
	tst.w	d0
	bne.s	.morph

	clr.w	VEC_OBJ_MORPH_ACTIVE(a0)	;disable morph

	move.l	VEC_OBJ_PTS_PTR(a0),a3

	move.w	(a2)+,d7	; num points-1 
	move.w	d7,(a3)+
.copypts
	movem.w	(a2)+,d0-d2
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	dbf	d7,.copypts

	rts

.morph:
	; Setup counter 
	move.w	d0,VEC_OBJ_MORPH_COUNTER(a0)
	move.w	d0,VEC_OBJ_MORPH_SPEED(a0)

	; Set morph flag
	move.w	#1,VEC_OBJ_MORPH_ACTIVE(a0)

	rts


*****************************************************************************
* Performs the morph.
* IN:		a0, VEC_ObjectCurrent_Adr
* OUT:
* TRASHED:	a2,a3,d0-d7
*****************************************************************************

VEC_Controller_FX_Morph_Perform:
	;check counter
	move.w	VEC_OBJ_MORPH_COUNTER(a0),d0
	beq.s	.morph
	subq.w	#1,d0
	move.w	d0,VEC_OBJ_MORPH_COUNTER(a0)
	rts
.morph:
	;new counter for next time
	move.w	VEC_OBJ_MORPH_SPEED(a0),VEC_OBJ_MORPH_COUNTER(a0)

	move.l	VEC_OBJ_PTSINITIAL_PTR(a0),a2
	move.l	VEC_OBJ_PTS_PTR(a0),a3
	moveq	#0,d6	

	; ASSUMPTION: Num points in current and new buffers are the same.
	move.w	(a2)+,d7	; num points-1 
	addq.l	#2,a3		; skip num points
.morphpts:
	movem.w	(a2)+,d0-d2	;x,y,z
	movem.w	(a3),d3-d5	;x,y,z

	cmp	d0,d3
	beq.s	.xequal
	ble.s	.xless
	subq.w	#1,d3
	moveq	#1,d6		;flag
	bra.s	.xequal
.xless:		
	addq.w	#1,d3
	moveq	#1,d6		;flag
.xequal:
	cmp	d1,d4
	beq.s	.yequal
	ble.s	.yless
	subq.w	#1,d4
	moveq	#1,d6		;flag
	bra.s	.yequal
.yless:		
	addq.w	#1,d4
	moveq	#1,d6		;flag
.yequal:
	cmp	d2,d5
	beq.s	.zequal
	ble.s	.zless
	subq.w	#1,d5
	moveq	#1,d6		;flag
	bra.s	.zequal
.zless:		
	addq.w	#1,d5
	moveq	#1,d6		;flag
.zequal:

	; save pts
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	move.w	d5,(a3)+
	dbf	d7,.morphpts

	; Reset morph flag if no changes made
	tst.w	d6
	bne.s	.fin

	move.w	#0,VEC_OBJ_MORPH_ACTIVE(a0)

.fin:
	rts


*****************************************************************************
* Loads the current colors into the current copperlist
* IN:		a1, VEC_Controller_Info
* OUT:
* TRASHED:	d0-d7/a2/a3/a4
*****************************************************************************

VEC_Do_Copper_Palette:
	lea	VEC_Palette,a0
	move.l	VEC_Work_CL_Ptr,a1

	;Normal colors
	lea	VEC_CL_COL_OFFSET+2(a1),a2	
	moveq	#4,d0			;next color in CL

;	moveq	#(1<<VEC_SCR_NUMPLANES)-1,d1
;.loop:
	REPT	(1<<VEC_SCR_NUMPLANES)
	move.w	(a0)+,(a2)
	add.l	d0,a2			;next color
	ENDR
;	dbf	d1,.loop
	
	;Reflection colors
	lea	VEC_CL_COL_REFL_OFFSET+2(a1),a2	
	;moveq	#(1<<VEC_SCR_NUMPLANES)-1,d1
;.loop2:
	REPT	(1<<VEC_SCR_NUMPLANES)
	move.w	(a0)+,(a2)
	add.l	d0,a2			;next color
	ENDR
;	dbf	d1,.loop2
	
	rts


*****************************************************************************
* Does the sine based horizontal scroll effect
* IN:		A5(CUSTOM)
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

; Format of the horizontal scroll entries in copper:
;CWAIT x,x (4 bytes)
;CMOVE BPLCON1,x (4 bytes) we want byte 6 for the value

VEC_Do_Horiz_Scroll:
	lea	VEC_HorizScroll_Variables,a0

	; Active?
	tst.w	VEC_HORIZSCROLL_ACTIVE(a0)
	beq	.exit

	; Active, but do we need to shut it off? (speed and step = 0)
	movem.w	VEC_HORIZSCROLL_SIN1_SPEED(a0),d0/d1
	tst.w	d0
	bne.s	.active
	tst.w	d1
	bne.s	.active

; Shut it off
	moveq	#0,d0			;bplcon shift = 0, and flag = 0
	;Get work address of the horiz scroll part of the copper list
	move.l	VEC_Work_CL_Ptr,a1
	lea	VEC_CL_HORIZSCROLL_OFFSET+6(a1),a1
	move.w	#VEC_HORIZ_SCROLL_NUMLINES-1,d7
.offloop:
	move.w	d0,(a1)
	addq.l	#8,a1			;next BPLCON1 entry
	dbf	d7,.offloop

	;Get work address of reflection part of list
	move.l	VEC_Work_CL_Ptr,a1
	lea	VEC_CL_HORIZSCROLL_REFL_OFFSET+6(a1),a1
	move.w	#VEC_HORIZ_SCROLL_REFL_NUMLINES-1,d7
.offloop2:
	move.w	d0,(a1)
	addq.l	#8,a1			;next BPLCON1 entry
	dbf	d7,.offloop2

	;deactivate (need to do twice because of doublebuffered copper)
	subq.w	#1,VEC_HORIZSCROLL_ACTIVE(a0)
	rts


.active:
	;Get the speed (movement per frame) and adjust based on the object's num frames so that
	;effect runs at same speed for fast and slow vector objects
	move.l	VEC_ObjectCurrent_Adr,a1
	move.w	VEC_HORIZSCROLL_SIN1_SPEED(a0),d3
	move.w	VEC_Controller_Info+VEC_CTRL_FRAMES_MIN,d0
	subq.w	#2,d0
	bmi.s	.speedok
	move.w	d3,d4
.speedloop:
	add.w	d4,d3			;add original speed to ourself
	dbf	d0,.speedloop

.speedok:

	move.w	VEC_HORIZSCROLL_SIN1_OFFSET(a0),d4	;offset in words
	add.w	d3,d3				;speed to word offset
	add.w	d3,d4				;add speed to offset (movement per frame)
	and.w	#VEC_HORIZSCROLL_TABLE_OFFSET_MASK,d4	;keep in range
	move.w	d4,VEC_HORIZSCROLL_SIN1_OFFSET(a0)	;save for next frame
	move.w	VEC_HORIZSCROLL_SIN1_STEP(a0),d3	;step, movement per line
	add.w	d3,d3				;step to word offset

	;Get work address of the horiz scroll part of the copper list
	;for the work copper list
	;format is
	;CWAIT x,x (4 bytes)
	;CMOVE BPLCON1,x (4 bytes) we want byte 6 for the value
	move.l	VEC_Work_CL_Ptr,a1
	lea	VEC_CL_HORIZSCROLL_OFFSET+6(a1),a1

	;Sine table has been modified into bplcon shift values like 00ff
	lea	VEC_HorizScroll_Table,a0
	move.w	#VEC_HORIZSCROLL_TABLE_OFFSET_MASK,d2
	moveq	#8,d0

;	move.w	#VEC_HORIZ_SCROLL_NUMLINES-1,d7
;.loop:
	REPT	VEC_HORIZ_SCROLL_NUMLINES
	move.w	(a0,d4.w),(a1)
	add.l	d0,a1			;next BPLCON1 entry
	add.w	d3,d4			;increase by step value
	and.w	d2,d4			;ensure in range
	ENDR
;	dbf	d7,.loop


	; Relections
	subq.l	#8,a1			;a1 points to last bplcon value used

	;Get work address of the horiz scroll reflection part of the copper list
	;for the work copper list
	move.l	VEC_Work_CL_Ptr,a2
	lea	VEC_CL_HORIZSCROLL_REFL_OFFSET+6(a2),a2

	moveq	#8,d0
	moveq	#8*4,d1
;	move.w	#VEC_HORIZ_SCROLL_REFL_NUMLINES-1,d7
;.loop2:
	REPT	VEC_HORIZ_SCROLL_REFL_NUMLINES
	move.w	(a1),(a2)
	sub.l	d1,a1			;reflection skips 4 lines per 1 non-reflected line
	add.l	d0,a2
	ENDR
;	dbf	d7,.loop2

.exit:
	rts


*****************************************************************************
* Precreates rotation matrix for the given object.
* IN:		a6, current object info
* OUT:
* TRASHED:	d0-d7/a0-a3
*****************************************************************************

VEC_Calc_Rotation_Matrix_For_Object:
	; Get current angles
	movem.w	VEC_OBJ_THETA_X(a6),d0-d2
	lea	VEC_MatrixRotObject,a2		;adr of matrix
	jmp	VEC_Calc_Rotation_Matrix	;init matrix

	;rts


*****************************************************************************
* Creates a rotation matrix. General purpose routine for angles and a given matrix.
* IN:		d0-d2, x,y,z thetas
*		a2, Adr of rotation matrix
* OUT:
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

VEC_Calc_Rotation_Matrix:

	add.w	d0,d0			;double for access in words
	add.w	d1,d1
	add.w	d2,d2

	lea	VEC_SIN_Table,a0			;Sine
	lea	VEC_COS_Table,a1			;Cosine
	;lea	(VEC_SIN_TABLE_NUMWORDS/2)(a0),a1	;Cos
	
	move.w	(a0,d0.w),d7
	move.w	(a1,d0.w),d6
	move.w	(a0,d1.w),d5
	move.w	(a1,d1.w),d4
	move.w	(a0,d2.w),d3
	move.w	(a1,d2.w),d2

;all thetas have been taken care of - now init rot matrix

	;SinX = d7 , CosX = d6
	;SinY = d5 , CosY = d4
	;SinZ = d3 , CosZ = d2


; 3D composite rotation in ZYX order

; ( CosYCosZ		    -CosYSinZ		    SinY      )	 1
; ( SinXSinYCosZ+CosXSinZ   -SinXSinYSinZ+CosXCosZ  -SinXCosY )  2
; ( -CosXSinYCosZ+SinXSinZ  CosXSinYSinZ+SinXCosZ   CosXCosY  )  3
;             1                       2                 3

;rot11
	move.w	d4,d0			;cosY
	muls	d2,d0			;cosYcosZ
	add.l	d0,d0
	swap	d0			;*2 and swap = divide by 32768
	move.w	d0,(a2)+		;Rot11

;rot12
	move.w	d4,d0			;cosY
	neg.w	d0			;-CosY
	muls	d3,d0			;-cosYsinZ
	add.l	d0,d0
	swap	d0
	move.w	d0,(a2)+		;Rot12

;rot13
	move.w	d5,(a2)+		;Rot13   (SinY)

;rot21
	move.w	d7,d0			;sinX
	muls	d5,d0     		;sinXsinY	
	add.l	d0,d0
	swap	d0
	muls	d2,d0			;sinXsinYCosZ
	add.l	d0,d0
	swap	d0

	move.w	d6,d1			;cosX
	muls	d3,d1			;cosXSinZ
	add.l	d1,d1
	swap	d1

	add.w	d1,d0
	move.w	d0,(a2)+		;Rot21

;rot22
	move.w	d7,d0			;sinX
	neg.w	d0			;-sinX
	muls	d5,d0			;-sinXsinY
	add.l	d0,d0
	swap	d0
	muls	d3,d0			;-sinXsinYsinZ
	add.l	d0,d0
	swap	d0

	move.w	d6,d1			;cosX
	muls	d2,d1			;cosXCosZ
	add.l	d1,d1
	swap	d1

	add.w	d1,d0
	move.w	d0,(a2)+		;Rot22

;rot23
	move.w	d7,d0			;sinX
	neg.w	d0			;-sinX
	muls	d4,d0			;-sinXcosY
	add.l	d0,d0
	swap	d0
	move.w	d0,(a2)+		;Rot23

;rot31
	move.w	d6,d0			;cosX
	neg.w	d0			;-cosX
	muls	d5,d0			;-cosXsinY
	add.l	d0,d0
	swap	d0
	muls	d2,d0			;-cosXsinYcosZ
	add.l	d0,d0
	swap	d0

	move.w	d7,d1			;sinX
	muls	d3,d1			;sinXsinZ
	add.l	d1,d1
	swap	d1

	add.w	d1,d0
	move.w	d0,(a2)+		;Rot31

;rot32
	move.w	d6,d0			;cosX
	muls	d5,d0			;cosXsinY	
	add.l	d0,d0
	swap	d0
	muls	d3,d0			;cosXsinYsinZ
	add.l	d0,d0
	swap	d0

	move.w	d7,d1			;sinX
	muls	d2,d1			;sinXcosZ
	add.l	d1,d1
	swap	d1

	add.w	d1,d0
	move.w	d0,(a2)+		;Rot32

;rot33
	move.w	d6,d0			;cosX
	muls	d4,d0			;cosXcosY
	add.l	d0,d0
	swap	d0
	move.w	d0,(a2)+		;Rot33
	
;rotation matrix is done

	rts


*****************************************************************************
* Rotates an object.
* IN:		a6, current object info
* OUT:
* TRASHED:	d0-d7/a0-a4
*****************************************************************************

VEC_Rotate:
	movem.l	a5/a6,-(sp)		;save

	move.l	VEC_OBJ_PTS_PTR(a6),a0
	movem.w	VEC_OBJ_POSX(a6),a4-a6	;get object position

	lea	VEC_RotXYZpts,a1
	lea	VEC_MatrixRotObject,a2

	move.w	(a0)+,d7		;number of points
	move.w	d7,(a1)+

.rotloop
	movem.w	(a0)+,d0-d2

	move.l	a2,a3			;save a2

	move.w	d0,d4
	move.w	d1,d5
	move.w	d2,d6

	muls	(a3)+,d4		;rot11
	muls	(a3)+,d5		;rot12
	muls	(a3)+,d6		;rot13
	add.l	d4,d5
	add.l	d5,d6
	add.l	d6,d6			;*2 and swap = divide by 32768
	swap	d6			;d6=new x coord
	
	add.w	a4,d6			;add x pos
	move.w	d6,(a1)+


	move.w	d0,d4
	move.w	d1,d5
	move.w	d2,d6

	muls	(a3)+,d4		;rot21
	muls	(a3)+,d5		;rot22
	muls	(a3)+,d6		;rot23
	add.l	d4,d5
	add.l	d5,d6
	add.l	d6,d6
	swap	d6			;d6=new y coord

	add.w	a5,d6			;add y pos
	move.w	d6,(a1)+


	muls	(a3)+,d0		;rot31
	muls	(a3)+,d1		;rot32
	muls	(a3)+,d2		;rot33
	add.l	d0,d1
	add.l	d1,d2
	add.l	d2,d2
	swap	d2			;d2=new z coord

	add.w	a6,d2			;add z pos
	move.w	d2,(a1)+

	dbf	d7,.rotloop

	movem.l	(sp)+,a5/a6

	rts


*****************************************************************************
* Performs perspective.
* IN:
* OUT:
* TRASHED:	d0-d7/a0
*****************************************************************************

VEC_Perspective:
	;Get screen offsets
	moveq	#VEC_XOFFSET,d4
	moveq	#VEC_YOFFSET,d5
	move.w	#VEC_ZOFFSET,d6

	lea	VEC_RotXYZpts,a0	;rot pts 3d

	move.w	(a0)+,d7		;num pts-1
.persloop1:
	movem.w	(a0),d0-d2		;get x,y,z pts
	;ext.l	d0			;sign extend to a longword
	;ext.l	d1			;REMOVED: movem.w auto sign extends!

	asl.l	#8,d0			;*256
	asl.l	#8,d1			;*256
	add.w	d6,d2			;pers+z
	beq.s	.store			;trap div by zero
	divs	d2,d0			;new x & y values
	divs	d2,d1
.store:	
	add.w	d4,d0			;add x offset
	neg.w	d1			;flip y axis
	add.w	d5,d1			;add y axis
	
	movem.w	d0-d1,(a0)		;store x,y
	addq.l	#6,a0			;skip to next pts

	dbf	d7,.persloop1		;next pt

	rts



*****************************************************************************
* Performs rotate and perspective in the same routine for speed.
* IN:		a6, current object info
* OUT:
* TRASHED:	d0-d7/a0-a4
*****************************************************************************
; TODO: This is missing object position code.

VEC_RotateAndPerspective:
	; Add position offsets
	movem.w	VEC_OBJ_POSX(a6),d5-d6/a4
	neg.w	d6
	add.w	#VEC_XOFFSET,d5
	add.w	#VEC_YOFFSET,d6
	add.w	#VEC_ZOFFSET,a4

	move.l	VEC_OBJ_PTS_PTR(a6),a0
	lea	VEC_RotXYZpts,a1
	lea	VEC_MatrixRotObject,a3
	
	move.w	(a0)+,d7		;number of points-1
	move.w	d7,(a1)+
.loop:
	move.l	a3,a2			;Matrix 
; X
	movem.w	(a0),d0-d2		;x,y,z
	muls	(a2)+,d0		;VEC_MROT11
	muls	(a2)+,d1		;VEC_MROT12
	muls	(a2)+,d2		;VEC_MROT13
	add.l	d1,d0
	add.l	d2,d0
	add.l	d0,d0			;*2 and swap = divide by 32768
	swap	d0

; Y
	move.w	(a0),d3			;x
	movem.w	2(a0),d1-d2		;y,z
	muls	(a2)+,d3		;VEC_MROT21
	muls	(a2)+,d1		;VEC_MROT22
	muls	(a2)+,d2		;VEC_MROT23
	add.l	d3,d1
	add.l	d2,d1
	add.l	d1,d1
	swap	d1			;/32768

; Z 
	movem.w	(a0)+,d3-d4		;x,y
	move.w	(a0)+,d2		;z

	muls	(a2)+,d3		;VEC_MROT31
	muls	(a2)+,d4		;VEC_MROT32
	muls	(a2),d2			;VEC_MROT33
	add.l	d3,d2
	add.l	d4,d2
	add.l	d2,d2
	swap	d2			;/32768

;Perspective
	;d0,d1,d2 = x,y,z

	ext.l	d0
	ext.l	d1
	asl.l	#3,d0			;*256 - this should match the WORLDDATA_ZOFFSET value so that
	asl.l	#3,d1			;object coords equate roughly to screen coords
	add.w	a4,d2			;Add Z offset
	beq.s	.store
	divs	d2,d0	
	divs	d2,d1
.store:
	add.w	d5,d0			;add x offset
	neg.w	d1			;invert Y
	add.w	d6,d1			;add y offset

	movem.w	d0-d2,(a1)		;store x,y,z (note z not used usually for convex)
	addq.l	#6,a1

	dbf	d7,.loop
	rts



*****************************************************************************
* Calculates the bounding rectange of the rotated points. Points are expected to
* be in screen coordinates just prior to drawing.
* This uses the overall shape of an object so is used for clearing or filling
* the whole screen.
*
* IN:		
* OUT:
* TRASHED:	d0-d7/a0-a2
*****************************************************************************


VEC_Calc_Screen_Clr_Bounding:
	lea	VEC_RotXYZpts,a0		;rot pts 3d

	move.w	(a0)+,d7		;num pts-1

	movem.w	(a0),d0-d1		; First x and y
	addq.l	#6,a0			;skip to next x,y,z

	; First coords, use these as the initial clip/fill values
	move.w	d0,d3			;min x
	move.w	d1,d4			;min y
	move.w	d0,d5			;max x
	move.w	d1,d6			;max y
	bra.s	.skipinit
.loop
	movem.w	(a0),d0-d1		;get x and y
	addq.l	#6,a0			;skip to next x,y,z
.skipinit	
	cmp.w	d0,d3
	ble.s	.minx_nochange
	move.w	d0,d3			;new min x
.minx_nochange:
	cmp.w	d1,d4
	ble.s	.miny_nochange
	move.w	d1,d4			;new min y
.miny_nochange:
	cmp.w	d0,d5
	bge.s	.maxx_nochange
	move.w	d0,d5			;new max x
.maxx_nochange:
	cmp.w	d1,d6
	bge.s	.maxy_nochange
	move.w	d1,d6			;new max y
.maxy_nochange:

	dbf	d7,.loop		;next pt
	;d3=minx, d4=miny, d5=maxx, d6=maxy

; ensure not out of bounds for what we are clipping to
; Remember to check both minx/maxx against the clipping minx,maxx as object
; may be off the screen so both minx/maxx could be > clipmaxx
	moveq	#VEC_LINEDRAW3_CLIPMINX,d0
	moveq	#VEC_LINEDRAW3_CLIPMINY,d1

	cmp.w	d0,d3
	bge.s	.minxok
	move.w	d0,d3			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.minxok:
	cmp.w	d1,d4
	bge.s	.minyok
	move.w	d1,d4			;new miny
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.minyok:
	cmp.w	d0,d5
	bge.s	.maxxok
	move.w	d0,d5			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.maxxok:
	cmp.w	d1,d6
	bge.s	.maxyok
	move.w	d1,d6			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.maxyok:

	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d1

	cmp.w	d0,d3
	ble.s	.minxok2
	move.w	d0,d3			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.minxok2:
	cmp.w	d1,d4
	ble.s	.minyok2
	move.w	d1,d4			;new miny
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.minyok2:
	cmp.w	d0,d5
	ble.s	.maxxok2
	move.w	d0,d5			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.maxxok2:
	cmp.w	d1,d6
	ble.s	.maxyok2
	move.w	d1,d6			;new minx
	IFNE VEC_CLIPCHECK
		move.w	#1,VEC_ClipCheck_Flag
	ENDC
.maxyok2:

	; Store the new bounding box values
	move.w	d3,d0
	move.w	d4,d1
	move.w	d5,d2
	move.w	d6,d3


	; Draw bounding box for debugging
	;lea	VEC_LineDraw3_Variables,a1
	;move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d5	;interleaved
	;bsr	VEC_LineDraw3_BlitterSetup	;Set one-time values for line draw
	;move.l	VEC_WORK_CLR_Details_Ptr,a0
	;movem.w	(a0),d0-d3
	;move.l	VEC_Work_Ptr,a0
	;lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a2	; line draw needs in a2
	;bsr	VEC_LineDraw3_DrawFilled

; ***
; Now work out the blitter values for use in full screen fill/clear
; ***
	; We only fill the box that we've drawn in. Requires interleaved bitmaps
	move.l	VEC_WORK_CLR_Details_Ptr,a0
	lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a2
	
	moveq	#-16,d4
	and.w	d4,d0			;leftx on word boundary
	and.w	d4,d2			;rightx on boundary
	move.w	d2,d5			;don't trash max x 
	sub.w	d0,d5			;width in pixels (word aligned)
	lsr.w	#4,d5			;width in words
	addq.w	#1,d5			;width+1, 0 to 304 is 20 words not 19 as calculated
	move.w	d5,VEC_SCR_CLR_WORDWIDTH(a0)	;save for clear routine

	move.w	d3,d4			;don't trash max y
	sub.w	d1,d4			;height
	addq.w	#1,d4			;height+1,  255-0 = 255, but height should be 256

	;moveq	#VEC_SCR_NUMPLANES,d0
	;mulu.w	d0,d4			
	;height * num bpl for interleaved
	IFEQ	2-VEC_SCR_NUMPLANES
		add.w	d4,d4
	ENDC
	IFEQ	3-VEC_SCR_NUMPLANES
		move.w	d4,d0
		add.w	d4,d4
		add.w	d0,d4
	ENDC
	IFEQ	4-VEC_SCR_NUMPLANES
		add.w	d4,d4
		add.w	d4,d4
	ENDC
	IFEQ	5-VEC_SCR_NUMPLANES
		move.w	d4,d0
		add.w	d4,d4
		add.w	d4,d4
		add.w	d0,d4
	ENDC
	move.w	d4,VEC_SCR_CLR_LINEHEIGHT(a0)	;save for clear routine

	lsl.w	#6,d4			;*64 = height portion of BLTSIZE
	add.w	d5,d4			;Add word width, completed BLTSIZE in d4
	move.w	d4,VEC_SCR_CLR_BLTSIZE(a0)	;save for clear routine

	;d2 = max x in pixels (on word boundary)
	;d3 = max y
	;d4 = BLTSIZE
	;d5 = fill width in words

	add.w	d5,d5			;d5=width in bytes
	moveq	#VEC_SCR_BYTEWIDTH,d1	;screen width in bytes
	sub.w	d5,d1			;modulo
	move.w	d1,VEC_SCR_CLR_BYTEMODULO(a0)	;save for clear routine

	; our Blitter source has to be the last word on the last bitplane (desending mode)
	; For line 100
	; 100 * (ScreenByteWidth * NumBitplanes)
	; + (ScreenByteWidth * (NumBitplanes-1))
	; + rightx in bytes

	lsr.w	#3,d2			;rightx in bytes
	move.l	VEC_Work_Ptr,a1
	add.w	d3,d3			;access mult table in words
	add.w	(a2,d3.w),a1		;add to address

	lea 	VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES-1)(a1,d2.w),a1
	move.l	a1,VEC_SCR_CLR_SRCPTR(a0)	;save for clear routine

	rts

	IFNE VEC_CLIPCHECK
VEC_ClipCheck_Flag:
	dc.w 	0
	ENDC

*****************************************************************************
* Calculates the what faces are visible.
*
* IN:		a6, current object info
* OUT:
* TRASHED:	d0-d7/a1-a4
*****************************************************************************

;hidden line equation
;			(x2-x1)(y3-y2)-(y2-y1)(x3-x2)			    

VEC_Calc_Visible_Faces:
	move.l	VEC_OBJ_FACELIST_PTR(a6),a4

	move.w	(a4)+,d6		;num faces
	bmi.s	.byebye			;no faces?

	lea	VEC_RotXYZpts+2,a2	;miss numpts
	lea	VEC_Visible_Face_Buffer,a1
	lea	2(a1),a0		;skip number of faces

	moveq	#0,d7			;num face to be drawn
.hloop:	
	move.l	(a4)+,a3		;a3=adr of face data
	
	movem.w	VEC_FACE_CON_XY1(a3),d0-d1	;indexes for x1,y1,x2,y2
	move.w	VEC_FACE_CON_XY3(a3),d2	;x3,y3 (2nd coord )

	move.w	(a2,d1.w),d3		;x2
	sub.w	(a2,d0.w),d3		;(x2-x1)
	move.w	2(a2,d2.w),d4		;y3
	sub.w	2(a2,d1.w),d4		;(y3-y2)
	muls	d4,d3			;(x2-x1)(y3-y2)
	
	move.w	2(a2,d1.w),d4		;y2		
	sub.w	2(a2,d0.w),d4		;(y2-y1)
	move.w	(a2,d2.w),d5		;x3
	sub.w	(a2,d1.w),d5		;(x3-x2)
	muls	d5,d4			;(y2-y1)(x3-x2)
	
	sub.l	d4,d3
	ble.b	.backface		;back face

.frontface:
	moveq	#0,d0			;front face flag = 0
	bra.s	.store
.backface:
	; If backface check the backface paper col, if negative then cull it
	; otherwise add it to the draw list so it can be drawn with alt colors
	; Note: leave color00, can do interesting things when used in complex vectors
	move.b	VEC_FACE_PAPER_BACKFACE(a3),d0
	bmi.s	.cull
	moveq	#1,d0			;backface flag = 1
.store:
	move.l	a3,(a0)+		;store face adr in visble faces buffer
	move.w	d0,VEC_FACE_FLAG_BACKFACE(a3)		;store frontface flag
	addq.w	#1,d7			;inc num of faces
.cull:
	dbf	d6,.hloop	

	move.w	d7,(a1)			;store num faces at start of Visble_Face_Buffer

.byebye:
	rts



*****************************************************************************
* Calculates some stats on visible faces:
* - Average Z value (used to sort)
* - Min/Max screen coords (used to fill/clear)
*
* IN:		
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

VEC_Calc_Face_Stats:
	lea	VEC_Visible_Face_Buffer,a0
	lea	VEC_RotXYZpts+2,a1	;miss numpts 

	move.w	(a0)+,d5		;Number of visible faces 
	beq	.quit			;Quit if no faces visible
	subq.w	#1,d5			;-1 for dbf
.faceloop:
	swap	d5			;save face counter (d5 now is used for maxy)

	move.w	#32767,d2		;minx,y initial
	move.w	d2,d3
	move.w	#-32767,d4		;maxx,y initial
	move.w	d4,d5			
	moveq	#0,d6			;average z, initial

	move.l	(a0)+,a2		;face adr
	move.l	a2,a3			;save face address
	move.w	(a2),d7			;number of connections - 1
	lea	VEC_FACE_CON_XY1(a2),a2	;Go to connections
.coordloop
	move.w	(a2),d0			;coord index *6

	IFNE VEC_BETTER_Z_AVERAGE
		move.w	4(a1,d0.w),d1	;get z
		ext.l	d1		;extend so we can add to d6.l properly
		add.l	d1,d6
	ELSE
		add.w	4(a1,d0.w),d6	;add to z
		asr.w	#1,d6		;dirty average
	ENDC

	movem.w	(a1,d0.w),d0-d1		;x1,y1

	;update min/max
	cmp.w	d0,d2
	ble.s	.minx_nochange
	move.w	d0,d2			;new min x
.minx_nochange:
	cmp.w	d1,d3
	ble.s	.miny_nochange
	move.w	d1,d3			;new min y
.miny_nochange:
	cmp.w	d0,d4
	bge.s	.maxx_nochange
	move.w	d0,d4			;new max x
.maxx_nochange:
	cmp.w	d1,d5
	bge.s	.maxy_nochange
	move.w	d1,d5			;new max y
.maxy_nochange:	

	; Only read the first pair of coords on each line as we assume the poly
	; is a complete loop. Skip 4 bytes each loop to do this.
	; dc.w (0 index x1,y1),(2 index x2,y2)
	; dc.w (4 index x2,y2),(6 index x3,y3)
	addq.l	#4,a2

	dbf	d7,.coordloop

	IFNE VEC_BETTER_Z_AVERAGE
		move.w	(a3),d7		;number of coords - 1
		addq.w	#1,d7		;number of coords
		divs	d7,d6		;get average. TODO: make z postive and change to divu
	ENDC
	move.w	d6,VEC_FACE_AVG_Z(a3)	;store average z

	;have to ensure that the min/max is within clipping bounds
	; Remember to check both minx/maxx against the clipping minx,maxx as object
	; may be off the screen so both minx/maxx could be > clipmaxx
	moveq	#VEC_LINEDRAW3_CLIPMINX,d0
	moveq	#VEC_LINEDRAW3_CLIPMINY,d1

	cmp.w	d0,d2
	bge.s	.minxok
	move.w	d0,d2			;new minx
.minxok:
	cmp.w	d1,d3
	bge.s	.minyok
	move.w	d1,d3			;new miny
.minyok:
	cmp.w	d0,d4
	bge.s	.maxxok
	move.w	d0,d4			;new minx
.maxxok:
	cmp.w	d1,d5
	bge.s	.maxyok
	move.w	d1,d5			;new minx
.maxyok:

	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d1

	cmp.w	d0,d2
	ble.s	.minxok2
	move.w	d0,d2			;new minx
.minxok2:
	cmp.w	d1,d3
	ble.s	.minyok2
	move.w	d1,d3			;new miny
.minyok2:
	cmp.w	d0,d4
	ble.s	.maxxok2
	move.w	d0,d4			;new minx
.maxxok2:
	cmp.w	d1,d5
	ble.s	.maxyok2
	move.w	d1,d5			;new minx
.maxyok2:

	;store min/max x,y
	movem.w	d2-d5,VEC_FACE_MINX(a3)	;store min/max x,y

	swap	d5			;restore face counter
	dbf	d5,.faceloop
.quit:
	rts



*****************************************************************************
* Sorts the visible face list based on previously calculated average z.
*
* IN:		
* OUT:		
* TRASHED:	d0-d7/a0-a2
*****************************************************************************

VEC_Sort_Faces:
	lea	VEC_Visible_Face_Buffer,a0
	move.w	(a0)+,d7		;Number of visible faces (not n-1)
	moveq	#1,d3
	cmp.w	d3,d7
	ble.s	.quit			;quit if 1 or less

;loop count each iteration is (n-gap), then -1 for dbf.
;have to start initial gap at n/2+1
	move.w	d7,d5

;d3 = 1
;d5 = gap
;d6 = counter
;d7 = original n

	move.l	a0,a4			;save initial position
.sloop	
	; reduce gap, unless it's already 1
	lsr.w	d3,d5			;gap / 2
	cmp.w	d3,d5			;is gap 1?
	beq.s	.finalsort		;move to final sorting process

	move.w	d7,d6			;copy of n
	sub.w	d5,d6			;n-gap
	sub.w	d3,d6			;fix for dbf - 1

	move.l	a4,a0			;restore postion to start
	move.w	d5,d4			;copy of gap
	add.w	d4,d4			;gap * 4
	add.w	d4,d4			;=long offset
	lea	(a0,d4.w),a1		;a1 is ptr to gap entries
.sl2	
	move.l	(a0),a2			;face 1
	move.l	(a1),a3			;face 2

	move.w	VEC_FACE_AVG_Z(a2),d0
	cmp.w	VEC_FACE_AVG_Z(a3),d0	;compare average z
	bge.s	.noswap			;don't swap 

	move.l	a3,(a0)			;swap face addresses
	move.l	a2,(a1)
.noswap	
	addq.l	#4,a0			;inc table position by 1 
	addq.l	#4,a1			;inc table position by 1 
		
	dbf	d6,.sl2
	bra.s	.sloop			;back to start and decrease gap if we need to

; In shellsort you have to repeat gap=1 until no more swaps

.finalsort:
	sub.w	d5,d7			;n-gap
	sub.w	d3,d7			;fix for dbf, will use this value each loop now until sorted
.sloop3
	moveq	#0,d4			;swap flag
	move.w	d7,d6			;restore counter
	move.l	a4,a0			;restore postion to start
	lea	4(a0),a1		;a1 is ptr to gap entries 1 long away
.sl3	
	move.l	(a0),a2			;face 1
	move.l	(a1),a3			;face 2

	move.w	VEC_FACE_AVG_Z(a2),d0
	cmp.w	VEC_FACE_AVG_Z(a3),d0	;compare average z
	bge.s	.noswap2		;don't swap 
	
	moveq	#1,d4			;flag swap
	move.l	a3,(a0)			;swap face addresses
	move.l	a2,(a1)
.noswap2
	addq.l	#4,a0			;inc table position by 1 
	addq.l	#4,a1			;inc table position by 1 
		
	dbf	d6,.sl3

	tst.w	d4
	bne.s	.sloop3			;loop if any swaps
.quit:	
	rts

*****************************************************************************

VEC_DrawObject:
	lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a1	; line draw needs in a1
	lea	VEC_Visible_Face_Buffer,a4
	lea	VEC_RotXYZpts+2,a6	;miss numpts

	move.w	(a4)+,d7		;num faces
	beq.s	.bye			;no faces to draw
	subq.w	#1,d7			;correct counter for dbf
	move.l	VEC_Work_Ptr,a2		;adr of screen

	;Setup line draw blit registers that don't change
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.l	#-1,BLTAFWM(a5)		;mask
	move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,BLTCMOD(a5)	;modulo interleaved
	move.l	#-$8000,BLTBDAT(a5)
	; --------

.faceloop:	
	swap	d7			;save face counter

	move.l	(a4)+,a3		;a3=adr of face data
	move.w	VEC_FACE_FLAG_BACKFACE(a3),d0		;VISIBLE_FACE_BACKFACE flag (0 = normal, 1 = backface)
	add.w	d0,d0			;offset to VEC_FACE_PAPER or VEC_FACE_PAPER_BACKFACE

	move.w	(a3)+,d7		;num lines to draw
	;a3 = VEC_FACE_PAPER
	moveq	#0,d5			;clear d5
	move.b	(a3,d0.w),d5		;paper.b , ink.b (of front or back face)
	move.w  d5,VEC_LineDraw3_nBpl_Color	;save color for linedraw routine
				
	add.l	#(VEC_FACE_CON_XY1-VEC_FACE_PAPER),a3	;Skip to Connections
.lineloop:
	move.l	a2,a0			;restore screen ptr
	movem.w	(a3)+,d1/d3		;indexes
	movem.w	(a6,d1.w),d0-d1		;x1,y1
	movem.w	(a6,d3.w),d2-d3		;x2,y2
	bsr	Vector_LineDraw3_nBpl_ClipAndDrawFilled	; trashes d0-d6/a0

	dbf	d7,.lineloop		;more lines

	swap	d7			;restore face counter
	dbf	d7,.faceloop		;next face

.bye	rts				;byebye



*****************************************************************************

VEC_DrawObject_Complex:
	lea	VEC_Mult_SCR_Height_ByteWidth,a1	; line draw needs in a1 (non interleaved)
	
	lea	VEC_Visible_Face_Buffer,a4
	lea	VEC_RotXYZpts+2,a6	;miss numpts

	move.w	(a4)+,d7		;num faces
	beq.s	.bye			;no faces to draw
	subq.w	#1,d7			;correct counter for dbf
.faceloop:	
	lea	Scratch_Buffer,a2	;adr of screen
	swap	d7			;save face counter

	move.l	(a4),a3			;a3=adr of face data

	move.w	(a3),d7			;num lines to draw-1
	lea	VEC_FACE_CON_XY1(a3),a3	;skip to connections
.lineloop:
	movem.w	(a3)+,d1/d3		;indexes
	movem.w	(a6,d1.w),d0-d1		;x1,y1
	movem.w	(a6,d3.w),d2-d3		;x2,y2
	move.l	a2,a0			;restore screen ptr
	bsr	Vector_LineDraw3_1Bpl_ClipAndDrawFilled	; trashes d0-d6/a0

	dbf	d7,.lineloop		;more lines

	move.l	(a4)+,a0		;a3=adr of face data for fill face function
	movem.l	d7/a1/a4/a6,-(sp)
	bsr.s	VEC_Fill_Face_And_Copy
	movem.l	(sp)+,d7/a1/a4/a6

	swap	d7			;restore face counter
	dbf	d7,.faceloop		;next face

.bye	rts				;byebye


*****************************************************************************
* Fills the poly in in the scratch buffer and blits it to the screen buffer
*
* IN:		a5(CUSTOM)
*		a0, face adr
*		a1, premult table screenheight * bytewidth (scratch, non interleaved)
* OUT:		
* TRASHED:	d0-d6/a0 (linedraw on its own is d0-d4)
*****************************************************************************

VEC_Fill_Face_And_Copy:
	;Variables area, too many things to track in registers
	lea	VEC_BlitFace_Vars,a6

	; Work out the modulos,adr, and blitsizes for the bounding box for this face
	movem.w	VEC_FACE_MINX(a0),d0-d3	;get min/max x,y
	
	moveq	#-16,d4
	and.w	d4,d0			;leftx on word boundary
	and.w	d4,d2			;rightx on boundary
	move.w	d2,d5			;don't trash max x 
	sub.w	d0,d5			;width in pixels (word aligned)
	lsr.w	#4,d5			;width in words
	addq.w	#1,d5			;width+1, 0 to 304 is 20 words not 19 as calculated
	move.w	d3,d4			;don't trash max y
	sub.w	d1,d4			;height
	addq.w	#1,d4			;height+1,  255-0 = 255, but height should be 256
	lsl.w	#6,d4			;*64 = height portion of BLTSIZE
	add.w	d5,d4			;Add word width, completed BLTSIZE in d4

	move.w	d4,VEC_BLITFACE_VARS_BLTSIZE(a6)	;Save bltsize

;d2 = max x in pixels (on word boundary)
;d3 = max y
;d4 = BLTSIZE
;d5 = fill width in words

	add.w	d5,d5			;d5=width in bytes
	moveq	#VEC_SCR_BYTEWIDTH,d1	;screen width in bytes
	sub.w	d5,d1			;modulo into 1bpl scratch buffer
	move.w	d1,VEC_BLITFACE_VARS_MOD_1BPL(a6)	;modulo
	add.w	#VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES-1),d1
	move.w	d1,VEC_BLITFACE_VARS_MOD_NBPL(a6)	;3 bpl modulo

; our Blitter source has to be the last word on the last bitplane (desending mode)
; For line 100
; 100 * (ScreenByteWidth * NumBitplanes)
; + (ScreenByteWidth * (NumBitplanes-1))
; + rightx in bytes

	lsr.w	#3,d2			;rightx in bytes
	move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d0
	add.w	d3,d3			;access mult tables in words

	move.l	#Scratch_Buffer,a3	;Drawscreen address
	lea	VEC_Mult_SCR_Height_ByteWidth,a1
	move.w	(a1,d3.w),d1		;y * screen width
	add.w	d2,d1			;add rightx in bytes
	add.w 	d1,a3			;add  (safe to use add.w)
	move.l	a3,VEC_BLITFACE_VARS_DRAWPTR(a6)	;save
	
	move.l	#VEC_Stipple_1Bpl,a2		;1bpl stipple pattern (screen sized)
	add.w 	d1,a2			;add  (safe to use add.w)
	move.l	a2,VEC_BLITFACE_VARS_STIPPLEPTR(a6)	;save

	move.l	VEC_Work_Ptr,a4		;Screen address
	lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a1
	add.w	(a1,d3.w),a4		;mult by height, add to address
	add.w 	d2,a4			;add rightx in bytes (safe to use add.w)
	move.l	a4,VEC_BLITFACE_VARS_SCRPTR(a6)	;save


	move.w	VEC_BLITFACE_VARS_MOD_1BPL(a6),d0
	move.l	VEC_BLITFACE_VARS_DRAWPTR(a6),a3
	move.w	VEC_BLITFACE_VARS_BLTSIZE(a6),d2

; Unchanged throughout
; a2= stipple ptr
; a3= draw ptr
; d2= bltsize

; ***
; Fill 1bpl face in draw buffer
; ***
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.l	#$09f0000a,BLTCON0(a5)	;copy and fill
	move.w	d0,BLTAMOD(a5)		;source of face
	move.w	d0,BLTDMOD(a5)		;destination
	move.l	a3,BLTAPTH(a5)		;source of face
	move.l	a3,BLTDPTH(a5)		;desination
	move.w	d2,BLTSIZE(a5)		;bltsize


; ***
; Copy filled face to screen buffer
; ***
	; get the color in d3
	moveq	#0,d3				;clear d3
	moveq	#0,d4				;clear d4
	move.w	VEC_FACE_FLAG_BACKFACE(a0),d0	;VISIBLE_FACE_BACKFACE flag (0 = normal, 1 = backface)
	add.w	d0,d0				;offset to VEC_FACE_PAPER or VEC_FACE_PAPER_BACKFACE
	move.b	VEC_FACE_PAPER(a0,d0.w),d3	;paper.b , ink.b (of front or back face)
	move.b	VEC_FACE_INK(a0,d0.w),d4	;paper.b , ink.b (of front or back face)
	move.w	d3,VEC_BLITFACE_VARS_PAPERCOL(a6)		;save color
	move.w	d4,VEC_BLITFACE_VARS_INKCOL(a6)			;save color

	move.w	VEC_BLITFACE_VARS_MOD_1BPL(a6),d0
	move.w	VEC_BLITFACE_VARS_MOD_NBPL(a6),d1
	;move.l	VEC_BLITFACE_VARS_STIPPLEPTR(a6),a2
	;move.l	VEC_BLITFACE_VARS_DRAWPTR(a6),a3
	;move.l	VEC_BLITFACE_VARS_SCRPTR(a6),a4
	move.w	VEC_BLITFACE_VARS_BLTSIZE(a6),d2
	moveq	#VEC_SCR_NUMPLANES-1,d7

	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.w	#$0002,BLTCON1(a5)	;desending mode, no fill
	movem.w	d0-d1,BLTCMOD(a5)	;BTLCMOD (stipple), BLTBMOD (screen)
	movem.w	d0-d1,BLTAMOD(a5)	;BLTAMOD (face buffer), BLTDMOD (screen)
	;note all future blits have the same BLTCON1/MODs so can leave alone.
	;Exception is the final 1bpl draw screen clear.

.colorloopcopy
	move.w	#$0dfc,d0		;solid fill, ABD
	btst    #0,d3			;paper
	bne.s	.colorloopblit

	btst	#0,d4			;ink
	beq.s	.nextbplcopy
	move.w	#$0fac,d0		;stipple fill, ABCD
.colorloopblit:
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.w	d0,BLTCON0(a5)		;minterm
	movem.l	a2/a4,BLTCPTH(a5)	;BLTCPTH (stipple), BLTBPTH (screen)
	movem.l	a3/a4,BLTAPTH(a5)	;BLTAPTH (face), BLTDPTH (screen)
	move.w	d2,BLTSIZE(a5)		;bltsize	
.nextbplcopy:
	lea     VEC_SCR_BYTEWIDTH(a4),a4	;next bitplane (interleaved)
	lsr.w   d3			;check next bit 
	lsr.w   d4			;check next bit 
	dbf	d7,.colorloopcopy	;any colors left?

; ***
; clear undrawn bitplanes in the screen
; ***

;bltcon0.w = $0d0c  for clear where face is
;bltcon0.w = $0f4c  for clear where face AND stipple are

;	PlaneX	StPlaneX	Action to be taken
;       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;	-1	-1		Don't clear the bitplane
;	-1	 0		Stipple clear the bitplane
; 	 0	-1		Don't clear the bitplane
;	 0	 0		Totally clear the bitplane
;       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	move.w	VEC_BLITFACE_VARS_PAPERCOL(a6),d3
	move.w	VEC_BLITFACE_VARS_INKCOL(a6),d4
	;move.l	VEC_BLITFACE_VARS_STIPPLEPTR(a6),a2
	;move.l	VEC_BLITFACE_VARS_DRAWPTR(a6),a3
	move.l	VEC_BLITFACE_VARS_SCRPTR(a6),a4
	;move.w	VEC_BLITFACE_VARS_BLTSIZE(a6),d2
	moveq	#VEC_SCR_NUMPLANES-1,d7	; have to use a counter this time

.colorloopclr
	btst	#0,d4			;ink
	bne.s	.nextbplclr

	move.w	#$0d0c,d0		;minterm, ABD
	btst	#0,d3			;paper
	beq.s	.clrloopblit

	move.w	#$0f4c,d0		;minterm, ABCD
.clrloopblit:
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	move.w	d0,BLTCON0(a5)		;minterm
	movem.l	a2/a4,BLTCPTH(a5)	;BLTCPTH (stipple), BLTBPTH (screen)
	movem.l	a3/a4,BLTAPTH(a5)	;BLTAPTH (face), BLTDPTH (screen)
	move.w	d2,BLTSIZE(a5)		;bltsize	
.nextbplclr:
	lea     VEC_SCR_BYTEWIDTH(a4),a4	;next bitplane (interleaved)
	lsr.w   d3				;check next bit 
	lsr.w   d4				;check next bit 
	dbf	d7,.colorloopclr


; ***
; Clear face in draw buffer
; ***
.cleardraw:
	move.w	VEC_BLITFACE_VARS_MOD_1BPL(a6),d0
	;move.l	VEC_BLITFACE_VARS_DRAWPTR(a6),a3
	;move.w	VEC_BLITFACE_VARS_BLTSIZE(a6),d2

	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	
	move.w	#$0100,BLTCON0(a5)	;clear
	move.w	d0,BLTDMOD(a5)
	move.l	a3,BLTDPTH(a5)
	move.w	d2,BLTSIZE(a5)
.exit:
	rts


*****************************************************************************
* LineDraw3 For filled vectors. Best when only drawing a line once.
* Single bitplanes / inconvex etc. 
* Coords are not saved as assumes that the next line will be different anyway.
*****************************************************************************

*****************************************************************************
* Original clipping coded by Prophet/Goldfire (Thomas Szirtes), 
* Bug fixed by Antiriad/Goldfire (Jonathan Bennett)
* Note: the left side isn't fill clipped. So use 0, or ensure you align
* The left side to the region being filled (word aligned minx essentially)
* This may draw a new vertical line at maxx to ensure filling works.
*
* IN:		a5(CUSTOM)
*		a0, screen address
*		a1, premult table screenheight * bytewidth
*		d0-d3, x,y,x2,y2 of the line to draw
* OUT:		
* TRASHED:	d0-d6/a0 (linedraw on its own is d0-d4)
*****************************************************************************

Vector_LineDraw3_nBpl_ClipAndDrawFilled:
	IFNE VEC_CLIPPING

	cmp	d1,d3
	bgt.s	.ClipTop		;and always draw top to Bottom, y2>y1
	beq	.NoDrawLine
	exg	d1,d3
	exg	d0,d2
.ClipTop
	move.w	#VEC_LINEDRAW3_CLIPMINY,d4
	cmp	d4,d1
	bgt.b	.ClipBottom
	cmp	d4,d3
	bgt.s	.miss1			
	bra	.NoDrawLine		;Clip it all

.miss1	Sub	d1,d4			;Miny-Y1
	Move	d2,d5
	Sub	d0,d5			;x2-x1		
	Move	d3,d6
	Sub	d1,d6			;y2-y1
	Muls	d5,d4			;(y2-x1)*(miny-y1)
	Divs	d6,d4			;/(y2-y1)
	Add	d4,d0			;add to d0
	move.w	#VEC_LINEDRAW3_CLIPMINY,d1	;Clip d1

.ClipBottom
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d4
	Cmp	d3,d4
	Bgt.s	.ClipRight
	Cmp	d1,d4
	Bgt.s	.miss2			
	bra	.NoDrawLine		;clip it all

.miss2	Sub	d3,d4			;MaxY-y2
	Move	d2,d5
	Sub	d0,d5			;x2-x1
	Move	d3,d6
	Sub	d1,d6			;y2-y1
	Muls	d5,d4			;(x2-x1)*(maxy-y2)
	Divs	d6,d4			;/(y2-y1)
	Add	d4,d2			;add 
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d3
.ClipRight
; X1<X2 
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d4		;d4=Maxx
	Cmp	d0,d2			;If X2<X1
	Beq.s	.CheckRStr		;Stop Division by 0
	Blt.s	.XCSwap			;Then do reverse Calc
	Cmp	d2,d4			;If x2<Maxx
	Bgt	.ClipLeft		;Don't Clip
	Cmp	d0,d4			;if x1>Maxx
	Ble.s	.ClipRightWhole		;Clipwholeline
	Sub	d2,d4			;(Maxx-x2)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x2
	Divs	d5,d4			;and divide by delta x
	Move	d3,d5			;copy y2
	Add	d4,d5			;add d4 to y2
	
	Movem	d0-d1/d5,-(sp)		;Drawing two lines, save
	move.l	a0,-(sp)
	Move	d5,d1
	Cmp	d1,d3
	Beq.s	.skip1
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Move	d2,d0
	bsr	.DrawLine		;LINE DRAW CALL. Trashes d0-d4/a0
.skip1	
	move.l	(sp)+,a0
	Movem	(sp)+,d0-d1/d3		;Note d5 restored into d3 intentionally

	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Bra.b	.ClipLeft
.CheckRStr
	Cmp	d0,d4			;if x1>Maxx
	Blt.s	.ClipRightWhole		;Clipwholeline
	Bra.s	.ClipLeft
.XCSwap
; X2<X1 
	Cmp	d0,d4			;if x1<d4
	Bgt.s	.ClipLeft		;don't clip
	Cmp	d2,d4			;if x2>Maxx
	Blt.s	.ClipRightWhole		;Clipwholeline
	Sub	d0,d4			;(Maxx-x1)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y1
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x1
	Divs	d5,d4			;and divide by delta x
	Move	d1,d5			;copy y2
	Add	d4,d5			;add d4 to y1

	Movem	d2-d3,-(sp)		;Have to draw two lines
	move.l	a0,-(sp)
	Move	d5,d3
	Cmp	d1,d3
	Beq.s	.skip2
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	move	d0,d2
	bsr.s	.DrawLine		;LINE DRAW CALL. Trashes d0-d4/a0
.skip2	
	move.l	(sp)+,a0
	Movem	(sp)+,d2-d3

	move.w	d5,d1
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	Bra.s	.ClipLeft
.ClipRightWhole	
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Move	d2,d0
	bra.b	.DrawLine
	
.ClipLeft
; X1>X2 Left Boundary Clip
	move.w	#VEC_LINEDRAW3_CLIPMINX,d4		;d4=Minx
	Cmp	d0,d2			;If X2<X1
	Beq.b	.CheckLStr		;Stop Division by 0
	Bgt.b	.XmCSwap		;Then do reverse Calc
	Cmp	d2,d4			;If x2>minx
	Blt.b	.DrawLine		;Don't Clip
	Cmp	d0,d4			;if x1<minx
	;Bgt.b	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Sub	d2,d4			;(Minx-x2)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x1
	Divs	d5,d4			;and divide by delta x
	Add	d4,d3			;add d4 to y1
	move.w	#VEC_LINEDRAW3_CLIPMINX,d2		;New x2 = Minx
	Bra.b	.DrawLine
.CheckLStr
	Cmp	d0,d4			;if x1>Minx
	;Bgt.s	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Bra.s	.DrawLine
;.ClipWholeLeft
	; Not implmented on left for speed
;	bra.s	.NoDrawLine
.XmCSwap
; X2>X1 Left Boundary Clip
	Cmp	d0,d4			;if x1<d4
	Blt.s	.DrawLine		;don't clip
	Cmp	d2,d4			;if x2>Minx
	;Bgt.s	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Sub	d0,d4			;(Minx-x1)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*minx-x1
	Divs	d5,d4			;and divide by delta x
	Add	d4,d1			;add d4 to y1
	move.w	#VEC_LINEDRAW3_CLIPMINX,d0		;New x1 = Minx

;.DrawLine	
;	bra	VEC_LineDraw3_DrawFilled	* CALL LINE DRAW
;.NoDrawLine
;	rts
	; ****
	; Fall through to line draw
	; ****

	ENDC	;VEC_CLIPPING

*****************************************************************************
* Calcs and draws a line in one go.
* IN:		a5(CUSTOM)
*		a0, screen address
*		a1, premult table screenheight * bytewidth ( or interleaved)
*			premult table must match the modulo
*		d0-d3, x,y,x2,y2 of the line to draw
* OUT:		
* TRASHED:	d0-d4/a0
*****************************************************************************

.DrawLine:
;VEC_LineDraw3_nBpl_DrawFilled:
	; Can't skip this check even if clipper did it, it may add new lines
	; where y1=y2
	sub.w	d1,d3			;cmp y1,y2 by subtraction = dy, saves a sub later
	bgt.s	.line1			;and always draw top to Bottom
	beq	.NoDrawLine			;When drawing filled lines, y1 can't equal y2 
	exg	d0,d2			;swap x1,x2	
	neg.w	d3			;swap y1,y2
	sub.w	d3,d1			;have to do a calc because of the sub above
.line1:
	move.w	d1,d4			;copy y1
	;mulu	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d4	;y * screen byte width (d4 result = .l)
	;add.l	d4,a0			;add to screen adr
	add.w	d4,d4			;access offset in words
	add.w	(a1,d4.w),a0		;mult lookup and add to screen address

	move.w	d0,d4			;copy x1
	lsr.w	#3,d4			;convert to bytes
	add.w	d4,a0			;top of d4 may be garbage. use add.w which safely extends 
					;when adding to adr registers
	moveq	#0,d4
	sub.w	d0,d2
	bpl.s	.line2
	moveq	#1,d4
	neg.w	d2
.line2:	
	move.w	d3,d1
	add.w	d1,d1
	cmp.w	d2,d1
	dbhi	d3,.line3
.line3:	
	move	d3,d1
	sub.w	d2,d1
	bpl.s	.line4
	exg	d2,d3
.line4:	
	addx.w	d4,d4
	add.w	d2,d2
	move	d2,d1
	sub.w	d3,d2
	addx.w	d4,d4

	;andi.w	#15,d0
	;ror.w	#4,d0
	;ori.w	#$A4A,d0		;inverted line!
	add.w	d0,d0			;access minterms in words
	andi.w	#$1e,d0			;keep in range
	move.w	.minterms(pc,d0.w),d0
	
	ext.l	d0			;ensure no garbage in top word (assume d0 +ve)
	swap	d0			;min term in upper word
	move.b	.octfilled(pc,d4.w),d0	;d0.l is now BLTCON0/1

	move.w	d2,d4
	sub.w	d3,d4			;d4 = BLTCMOD
	lsl.w	#6,d3
	addq.w	#2,d3			;d3 BLTSIZE

	swap	d1			;d1 Hiword = BLTBMOD
	move.w	d4,d1			;d1 Loword = BLTAMOD

	;get color in d4
	move.w  .color(pc),d4
.colorloop
	btst    #0,d4
	beq.s   .nextbpl

	;TIMERON	$f00
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	;TIMERON $111

	move.l	d0,BLTCON0(a5)		;BLTCON0 and BLTCON1
	;movem.w	d1/d4,BLTBMOD(a5)	;BLTBMOD/BLTAMOD
	move.l	d1,BLTBMOD(a5)		;BLTBMOD/BLTAMOD

	; NOTE: These three lines can be moved out if drawing loads of lines at once
	;move.l	#-1,BLTAFWM(a5)		;mask
	;move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,BLTCMOD(a5)	;modulo interleaved
	;move.l	#-$8000,BLTBDAT(a5)
	; --------

	move.l	a0,BLTCPTH(a5)
	move.w	d2,BLTAPTL(a5)		
	move.l	a0,BLTDPTH(a5)
	move.w	d3,BLTSIZE(a5)
.nextbpl:
	lea     VEC_SCR_BYTEWIDTH(a0),a0	;next bitplane
	lsr.w   d4				;check next bit 
	bne.s   .colorloop			;any colors left?
.NoDrawLine:	
	rts

	EVEN
.octfilled:
	dc.b	$03,$43,$13,$53,$0b,$4b,$17,$57	;Oct Filled 
.octsolid:
;	dc.b	$03-2,$43-2,$13-2,$53-2,$0b-2,$4b-2,$17-2,$57-2   ;Oct Solid each term -2 for solid lines! 
.minterms:
	dc.w	$0a4a,$1a4a,$2a4a,$3a4a,$4a4a,$5a4a,$6a4a
	dc.w	$7a4a,$8a4a,$9a4a,$aa4a,$ba4a,$ca4a,$da4a
	dc.w	$ea4a,$fa4a

.color:
VEC_LineDraw3_nBpl_Color:
	dc.w    0       ; color

*****************************************************************************

*****************************************************************************
* Original clipping coded by Prophet/Goldfire (Thomas Szirtes), 
* Bug fixed by Antiriad/Goldfire (Jonathan Bennett)
* Note: the left side isn't fill clipped. So use 0, or ensure you align
* The left side to the region being filled (word aligned minx essentially)
* This may draw a new vertical line at maxx to ensure filling works.
*
* IN:		a5(CUSTOM)
*		a0, screen address
*		a1, premult table screenheight * bytewidth
*		d0-d3, x,y,x2,y2 of the line to draw
* OUT:		
* TRASHED:	d0-d6/a0 (linedraw on its own is d0-d4)
*****************************************************************************

Vector_LineDraw3_1Bpl_ClipAndDrawFilled:
	IFNE VEC_CLIPPING

	cmp	d1,d3
	bgt.s	.ClipTop		;and always draw top to Bottom, y2>y1
	beq	.NoDrawLine
	exg	d1,d3
	exg	d0,d2
.ClipTop
	move.w	#VEC_LINEDRAW3_CLIPMINY,d4
	cmp	d4,d1
	bgt.b	.ClipBottom
	cmp	d4,d3
	bgt.s	.miss1			
	bra	.NoDrawLine		;Clip it all

.miss1	Sub	d1,d4			;Miny-Y1
	Move	d2,d5
	Sub	d0,d5			;x2-x1		
	Move	d3,d6
	Sub	d1,d6			;y2-y1
	Muls	d5,d4			;(y2-x1)*(miny-y1)
	Divs	d6,d4			;/(y2-y1)
	Add	d4,d0			;add to d0
	move.w	#VEC_LINEDRAW3_CLIPMINY,d1	;Clip d1

.ClipBottom
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d4
	Cmp	d3,d4
	Bgt.s	.ClipRight
	Cmp	d1,d4
	Bgt.s	.miss2			
	bra	.NoDrawLine		;clip it all

.miss2	Sub	d3,d4			;MaxY-y2
	Move	d2,d5
	Sub	d0,d5			;x2-x1
	Move	d3,d6
	Sub	d1,d6			;y2-y1
	Muls	d5,d4			;(x2-x1)*(maxy-y2)
	Divs	d6,d4			;/(y2-y1)
	Add	d4,d2			;add 
	move.w	#VEC_LINEDRAW3_CLIPMAXY,d3
.ClipRight
; X1<X2 
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d4		;d4=Maxx
	Cmp	d0,d2			;If X2<X1
	Beq.s	.CheckRStr		;Stop Division by 0
	Blt.s	.XCSwap			;Then do reverse Calc
	Cmp	d2,d4			;If x2<Maxx
	Bgt	.ClipLeft		;Don't Clip
	Cmp	d0,d4			;if x1>Maxx
	Ble.s	.ClipRightWhole		;Clipwholeline
	Sub	d2,d4			;(Maxx-x2)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x2
	Divs	d5,d4			;and divide by delta x
	Move	d3,d5			;copy y2
	Add	d4,d5			;add d4 to y2
	
	Movem	d0-d1/d5,-(sp)		;Drawing two lines, save
	move.l	a0,-(sp)
	Move	d5,d1
	Cmp	d1,d3
	Beq.s	.skip1
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Move	d2,d0
	bsr	.DrawLine		;LINE DRAW CALL. Trashes d0-d4/a0
.skip1	
	move.l	(sp)+,a0
	Movem	(sp)+,d0-d1/d3		;Note d5 restored into d3 intentionally

	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Bra.b	.ClipLeft
.CheckRStr
	Cmp	d0,d4			;if x1>Maxx
	Blt.s	.ClipRightWhole		;Clipwholeline
	Bra.s	.ClipLeft
.XCSwap
; X2<X1 
	Cmp	d0,d4			;if x1<d4
	Bgt.s	.ClipLeft		;don't clip
	Cmp	d2,d4			;if x2>Maxx
	Blt.s	.ClipRightWhole		;Clipwholeline
	Sub	d0,d4			;(Maxx-x1)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y1
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x1
	Divs	d5,d4			;and divide by delta x
	Move	d1,d5			;copy y2
	Add	d4,d5			;add d4 to y1

	Movem	d2-d3,-(sp)		;Have to draw two lines
	move.l	a0,-(sp)
	Move	d5,d3
	Cmp	d1,d3
	Beq.s	.skip2
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	move	d0,d2
	bsr.s	.DrawLine		;LINE DRAW CALL. Trashes d0-d4/a0
.skip2	
	move.l	(sp)+,a0
	Movem	(sp)+,d2-d3

	move.w	d5,d1
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d0
	Bra.s	.ClipLeft
.ClipRightWhole	
	move.w	#VEC_LINEDRAW3_CLIPMAXX,d2
	Move	d2,d0
	bra.b	.DrawLine
	
.ClipLeft
; X1>X2 Left Boundary Clip
	move.w	#VEC_LINEDRAW3_CLIPMINX,d4		;d4=Minx
	Cmp	d0,d2			;If X2<X1
	Beq.b	.CheckLStr		;Stop Division by 0
	Bgt.b	.XmCSwap		;Then do reverse Calc
	Cmp	d2,d4			;If x2>minx
	Blt.b	.DrawLine		;Don't Clip
	Cmp	d0,d4			;if x1<minx
	;Bgt.b	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Sub	d2,d4			;(Minx-x2)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*maxx-x1
	Divs	d5,d4			;and divide by delta x
	Add	d4,d3			;add d4 to y1
	move.w	#VEC_LINEDRAW3_CLIPMINX,d2		;New x2 = Minx
	Bra.b	.DrawLine
.CheckLStr
	Cmp	d0,d4			;if x1>Minx
	;Bgt.s	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Bra.s	.DrawLine
;.ClipWholeLeft
	; Not implmented on left for speed
;	bra.s	.NoDrawLine
.XmCSwap
; X2>X1 Left Boundary Clip
	Cmp	d0,d4			;if x1<d4
	Blt.s	.DrawLine		;don't clip
	Cmp	d2,d4			;if x2>Minx
	;Bgt.s	.ClipWholeLeft		;Clipwholeline
	Bgt	.NoDrawLine		;Clipwholeline
	Sub	d0,d4			;(Minx-x1)
	Move	d2,d5			;Copy X2
	Sub	d0,d5			;d5 = delta x
	Move	d3,d6			;Copy y2
	Sub	d1,d6			;d6 = delta y
	Muls	d6,d4			;deltay*minx-x1
	Divs	d5,d4			;and divide by delta x
	Add	d4,d1			;add d4 to y1
	move.w	#VEC_LINEDRAW3_CLIPMINX,d0		;New x1 = Minx

;.DrawLine	
;	bra	VEC_LineDraw3_DrawFilled	* CALL LINE DRAW
;.NoDrawLine
;	rts
	; ****
	; Fall through to line draw
	; ****

	ENDC	;VEC_CLIPPING

*****************************************************************************
* Calcs and draws a line in one go.
* IN:		a5(CUSTOM)
*		a0, screen address
*		a1, premult table screenheight * bytewidth ( or interleaved)
*			premult table must match the modulo
*		d0-d3, x,y,x2,y2 of the line to draw
* OUT:		
* TRASHED:	d0-d4/a0
*****************************************************************************

.DrawLine:
;VEC_LineDraw3_1Bpl_DrawFilled:
	; Can't skip this check even if clipper did it, it may add new lines
	; where y1=y2
	sub.w	d1,d3			;cmp y1,y2 by subtraction = dy, saves a sub later
	bgt.s	.line1			;and always draw top to Bottom
	beq	.NoDrawLine			;When drawing filled lines, y1 can't equal y2 
	exg	d0,d2			;swap x1,x2	
	neg.w	d3			;swap y1,y2
	sub.w	d3,d1			;have to do a calc because of the sub above
.line1:
	move.w	d1,d4			;copy y1
	;mulu	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d4	;y * screen byte width (d4 result = .l)
	;add.l	d4,a0			;add to screen adr
	add.w	d4,d4			;access offset in words
	add.w	(a1,d4.w),a0		;mult lookup and add to screen address

	move.w	d0,d4			;copy x1
	lsr.w	#3,d4			;convert to bytes
	add.w	d4,a0			;top of d4 may be garbage. use add.w which safely extends 
					;when adding to adr registers
	moveq	#0,d4
	sub.w	d0,d2
	bpl.s	.line2
	moveq	#1,d4
	neg.w	d2
.line2:	
	move.w	d3,d1
	add.w	d1,d1
	cmp.w	d2,d1
	dbhi	d3,.line3
.line3:	
	move	d3,d1
	sub.w	d2,d1
	bpl.s	.line4
	exg	d2,d3
.line4:	
	addx.w	d4,d4
	add.w	d2,d2
	move	d2,d1
	sub.w	d3,d2
	addx.w	d4,d4

	;andi.w	#15,d0
	;ror.w	#4,d0
	;ori.w	#$A4A,d0		;inverted line!
	add.w	d0,d0			;access minterms in words
	andi.w	#$1e,d0			;keep in range
	move.w	.minterms(pc,d0.w),d0
	
	ext.l	d0			;ensure no garbage in top word (assume d0 +ve)
	swap	d0			;min term in upper word
	move.b	.octfilled(pc,d4.w),d0	;d0.l is now BLTCON0/1

	move.w	d2,d4
	sub.w	d3,d4			;d4 = BLTCMOD
	lsl.w	#6,d3
	addq.w	#2,d3			;d3 BLTSIZE

	swap	d1			;d1 Hiword = BLTBMOD
	move.w	d4,d1			;d1 Loword = BLTAMOD

	;TIMERON	$f00
	BLIT_NASTY_ON_A5
	WAITBLIT_A5
	BLIT_NASTY_OFF_A5
	;TIMERON $111

	move.l	d0,BLTCON0(a5)		;BLTCON0 and BLTCON1
	;movem.w	d1/d4,BLTBMOD(a5)	;BLTBMOD/BLTAMOD
	move.l	d1,BLTBMOD(a5)		;BLTBMOD/BLTAMOD

	; NOTE: These three lines can be moved out if drawing loads of lines at once
	; But with complex vectors we are drawling 3/4 lines, then filling, so leave it here.
	move.l	#-1,BLTAFWM(a5)		;mask
	move.w	#VEC_SCR_BYTEWIDTH,BLTCMOD(a5)	;modulo interleaved
	move.l	#-$8000,BLTBDAT(a5)
	; --------

	move.l	a0,BLTCPTH(a5)
	move.w	d2,BLTAPTL(a5)		
	move.l	a0,BLTDPTH(a5)
	move.w	d3,BLTSIZE(a5)

.NoDrawLine:	
	rts

	EVEN
.octfilled:
	dc.b	$03,$43,$13,$53,$0b,$4b,$17,$57	;Oct Filled 
.octsolid:
;	dc.b	$03-2,$43-2,$13-2,$53-2,$0b-2,$4b-2,$17-2,$57-2   ;Oct Solid each term -2 for solid lines! 
.minterms:
	dc.w	$0a4a,$1a4a,$2a4a,$3a4a,$4a4a,$5a4a,$6a4a
	dc.w	$7a4a,$8a4a,$9a4a,$aa4a,$ba4a,$ca4a,$da4a
	dc.w	$ea4a,$fa4a

*****************************************************************************

;Vector_LineDrawTest:
;	lea	VEC_LineDraw3_Variables,a1
;	lea	VEC_Mult_SCR_Height_ByteWidth_NumPlanes,a2
;	moveq	#0,d0
;	moveq	#0,d1
;	move.w	#VEC_SCR_WIDTH-1,d2
;	move.w	#VEC_SCR_HEIGHT-1,d3
;	move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d5	;interleaved
;	bsr	VEC_LineDraw3_BlitterSetup	;Set one-time values for line draw

;	move.w	#160,d7
;.loop
;	move.l	VEC_Work_Ptr,a0		;adr of screen
;	moveq	#0,d0
;	moveq	#0,d1
;	move.w	#VEC_SCR_WIDTH/6-1,d2
;	move.w	#VEC_SCR_HEIGHT/6-1,d3
;	move.w	#VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES,d5	;interleaved
	
;	bsr	VEC_LineDraw3_DrawFilled
;	dbf	d7,.loop

;	rts




*****************************************************************************

*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	VectorPublicData,DATA	;Public data section for variables
	
*****************************************************************************

VEC_MAX_PTS	= 64	
VEC_MAX_FACES	= 48


; Note the table is in words from -32768 to 32767
; After multiplying
; add.l d0,d0
; swap d0
; = /32768
VEC_SIN_TABLE_NUMWORDS = 1024
VEC_SIN_TABLE_OFFSET_MASK = VEC_SIN_TABLE_NUMWORDS-1
	EVEN
VEC_SIN_Table:
	dc.w	$0000,$00c9,$0192,$025b,$0324,$03ed,$04b6,$057f,$0648,$0711,$07d9,$08a2,$096a,$0a33,$0afb,$0bc4
	dc.w	$0c8c,$0d54,$0e1c,$0ee3,$0fab,$1072,$113a,$1201,$12c8,$138f,$1455,$151c,$15e2,$16a8,$176e,$1833
	dc.w	$18f9,$19be,$1a82,$1b47,$1c0b,$1ccf,$1d93,$1e57,$1f1a,$1fdd,$209f,$2161,$2223,$22e5,$23a6,$2467
	dc.w	$2528,$25e8,$26a8,$2767,$2826,$28e5,$29a3,$2a61,$2b1f,$2bdc,$2c99,$2d55,$2e11,$2ecc,$2f87,$3041
	dc.w	$30fb,$31b5,$326e,$3326,$33df,$3496,$354d,$3604,$36ba,$376f,$3824,$38d9,$398c,$3a40,$3af2,$3ba5
	dc.w	$3c56,$3d07,$3db8,$3e68,$3f17,$3fc5,$4073,$4121,$41ce,$427a,$4325,$43d0,$447a,$4524,$45cd,$4675
	dc.w	$471c,$47c3,$4869,$490f,$49b4,$4a58,$4afb,$4b9d,$4c3f,$4ce0,$4d81,$4e20,$4ebf,$4f5d,$4ffb,$5097
	dc.w	$5133,$51ce,$5268,$5302,$539b,$5432,$54c9,$5560,$55f5,$568a,$571d,$57b0,$5842,$58d3,$5964,$59f3
	dc.w	$5a82,$5b10,$5b9c,$5c28,$5cb3,$5d3e,$5dc7,$5e4f,$5ed7,$5f5d,$5fe3,$6068,$60eb,$616e,$61f0,$6271
	dc.w	$62f1,$6370,$63ee,$646c,$64e8,$6563,$65dd,$6656,$66cf,$6746,$67bc,$6832,$68a6,$6919,$698b,$69fd
	dc.w	$6a6d,$6adc,$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61,$6dc9,$6e30,$6e96,$6efb,$6f5e,$6fc1,$7022,$7083
	dc.w	$70e2,$7140,$719d,$71f9,$7254,$72ae,$7307,$735f,$73b5,$740a,$745f,$74b2,$7504,$7555,$75a5,$75f3
	dc.w	$7641,$768d,$76d8,$7722,$776b,$77b3,$77fa,$783f,$7884,$78c7,$7909,$794a,$7989,$79c8,$7a05,$7a41
	dc.w	$7a7c,$7ab6,$7aee,$7b26,$7b5c,$7b91,$7bc5,$7bf8,$7c29,$7c59,$7c88,$7cb6,$7ce3,$7d0e,$7d39,$7d62
	dc.w	$7d89,$7db0,$7dd5,$7dfa,$7e1d,$7e3e,$7e5f,$7e7e,$7e9c,$7eb9,$7ed5,$7eef,$7f09,$7f21,$7f37,$7f4d
	dc.w	$7f61,$7f74,$7f86,$7f97,$7fa6,$7fb4,$7fc1,$7fcd,$7fd8,$7fe1,$7fe9,$7ff0,$7ff5,$7ff9,$7ffd,$7ffe

VEC_COS_Table:
	dc.w	$7fff,$7ffe,$7ffd,$7ff9,$7ff5,$7ff0,$7fe9,$7fe1,$7fd8,$7fcd,$7fc1,$7fb4,$7fa6,$7f97,$7f86,$7f74
	dc.w	$7f61,$7f4d,$7f37,$7f21,$7f09,$7eef,$7ed5,$7eb9,$7e9c,$7e7e,$7e5f,$7e3e,$7e1d,$7dfa,$7dd5,$7db0
	dc.w	$7d89,$7d62,$7d39,$7d0e,$7ce3,$7cb6,$7c88,$7c59,$7c29,$7bf8,$7bc5,$7b91,$7b5c,$7b26,$7aee,$7ab6
	dc.w	$7a7c,$7a41,$7a05,$79c8,$7989,$794a,$7909,$78c7,$7884,$783f,$77fa,$77b3,$776b,$7722,$76d8,$768d
	dc.w	$7641,$75f3,$75a5,$7555,$7504,$74b2,$745f,$740a,$73b5,$735f,$7307,$72ae,$7254,$71f9,$719d,$7140
	dc.w	$70e2,$7083,$7022,$6fc1,$6f5e,$6efb,$6e96,$6e30,$6dc9,$6d61,$6cf8,$6c8e,$6c23,$6bb7,$6b4a,$6adc
	dc.w	$6a6d,$69fd,$698b,$6919,$68a6,$6832,$67bc,$6746,$66cf,$6656,$65dd,$6563,$64e8,$646c,$63ee,$6370
	dc.w	$62f1,$6271,$61f0,$616e,$60eb,$6068,$5fe3,$5f5d,$5ed7,$5e4f,$5dc7,$5d3e,$5cb3,$5c28,$5b9c,$5b10
	dc.w	$5a82,$59f3,$5964,$58d3,$5842,$57b0,$571d,$568a,$55f5,$5560,$54c9,$5432,$539b,$5302,$5268,$51ce
	dc.w	$5133,$5097,$4ffb,$4f5d,$4ebf,$4e20,$4d81,$4ce0,$4c3f,$4b9d,$4afb,$4a58,$49b4,$490f,$4869,$47c3
	dc.w	$471c,$4675,$45cd,$4524,$447a,$43d0,$4325,$427a,$41ce,$4121,$4073,$3fc5,$3f17,$3e68,$3db8,$3d07
	dc.w	$3c56,$3ba5,$3af2,$3a40,$398c,$38d9,$3824,$376f,$36ba,$3604,$354d,$3496,$33df,$3326,$326e,$31b5
	dc.w	$30fb,$3041,$2f87,$2ecc,$2e11,$2d55,$2c99,$2bdc,$2b1f,$2a61,$29a3,$28e5,$2826,$2767,$26a8,$25e8
	dc.w	$2528,$2467,$23a6,$22e5,$2223,$2161,$209f,$1fdd,$1f1a,$1e57,$1d93,$1ccf,$1c0b,$1b47,$1a82,$19be
	dc.w	$18f9,$1833,$176e,$16a8,$15e2,$151c,$1455,$138f,$12c8,$1201,$113a,$1072,$0fab,$0ee3,$0e1c,$0d54
	dc.w	$0c8c,$0bc4,$0afb,$0a33,$096a,$08a2,$07d9,$0711,$0648,$057f,$04b6,$03ed,$0324,$025b,$0192,$00c9
	dc.w	$0000,$ff37,$fe6e,$fda5,$fcdc,$fc13,$fb4a,$fa81,$f9b8,$f8ef,$f827,$f75e,$f696,$f5cd,$f505,$f43c
	dc.w	$f374,$f2ac,$f1e4,$f11d,$f055,$ef8e,$eec6,$edff,$ed38,$ec71,$ebab,$eae4,$ea1e,$e958,$e892,$e7cd
	dc.w	$e707,$e642,$e57e,$e4b9,$e3f5,$e331,$e26d,$e1a9,$e0e6,$e023,$df61,$de9f,$dddd,$dd1b,$dc5a,$db99
	dc.w	$dad8,$da18,$d958,$d899,$d7da,$d71b,$d65d,$d59f,$d4e1,$d424,$d367,$d2ab,$d1ef,$d134,$d079,$cfbf
	dc.w	$cf05,$ce4b,$cd92,$ccda,$cc21,$cb6a,$cab3,$c9fc,$c946,$c891,$c7dc,$c727,$c674,$c5c0,$c50e,$c45b
	dc.w	$c3aa,$c2f9,$c248,$c198,$c0e9,$c03b,$bf8d,$bedf,$be32,$bd86,$bcdb,$bc30,$bb86,$badc,$ba33,$b98b
	dc.w	$b8e4,$b83d,$b797,$b6f1,$b64c,$b5a8,$b505,$b463,$b3c1,$b320,$b27f,$b1e0,$b141,$b0a3,$b005,$af69
	dc.w	$aecd,$ae32,$ad98,$acfe,$ac65,$abce,$ab37,$aaa0,$aa0b,$a976,$a8e3,$a850,$a7be,$a72d,$a69c,$a60d
	dc.w	$a57e,$a4f0,$a464,$a3d8,$a34d,$a2c2,$a239,$a1b1,$a129,$a0a3,$a01d,$9f98,$9f15,$9e92,$9e10,$9d8f
	dc.w	$9d0f,$9c90,$9c12,$9b94,$9b18,$9a9d,$9a23,$99aa,$9931,$98ba,$9844,$97ce,$975a,$96e7,$9675,$9603
	dc.w	$9593,$9524,$94b6,$9449,$93dd,$9372,$9308,$929f,$9237,$91d0,$916a,$9105,$90a2,$903f,$8fde,$8f7d
	dc.w	$8f1e,$8ec0,$8e63,$8e07,$8dac,$8d52,$8cf9,$8ca1,$8c4b,$8bf6,$8ba1,$8b4e,$8afc,$8aab,$8a5b,$8a0d
	dc.w	$89bf,$8973,$8928,$88de,$8895,$884d,$8806,$87c1,$877c,$8739,$86f7,$86b6,$8677,$8638,$85fb,$85bf
	dc.w	$8584,$854a,$8512,$84da,$84a4,$846f,$843b,$8408,$83d7,$83a7,$8378,$834a,$831d,$82f2,$82c7,$829e
	dc.w	$8277,$8250,$822b,$8206,$81e3,$81c2,$81a1,$8182,$8164,$8147,$812b,$8111,$80f7,$80df,$80c9,$80b3
	dc.w	$809f,$808c,$807a,$8069,$805a,$804c,$803f,$8033,$8028,$801f,$8017,$8010,$800b,$8007,$8003,$8002
	dc.w	$8001,$8002,$8003,$8007,$800b,$8010,$8017,$801f,$8028,$8033,$803f,$804c,$805a,$8069,$807a,$808c
	dc.w	$809f,$80b3,$80c9,$80df,$80f7,$8111,$812b,$8147,$8164,$8182,$81a1,$81c2,$81e3,$8206,$822b,$8250
	dc.w	$8277,$829e,$82c7,$82f2,$831d,$834a,$8378,$83a7,$83d7,$8408,$843b,$846f,$84a4,$84da,$8512,$854a
	dc.w	$8584,$85bf,$85fb,$8638,$8677,$86b6,$86f7,$8739,$877c,$87c1,$8806,$884d,$8895,$88de,$8928,$8973
	dc.w	$89bf,$8a0d,$8a5b,$8aab,$8afc,$8b4e,$8ba1,$8bf6,$8c4b,$8ca1,$8cf9,$8d52,$8dac,$8e07,$8e63,$8ec0
	dc.w	$8f1e,$8f7d,$8fde,$903f,$90a2,$9105,$916a,$91d0,$9237,$929f,$9308,$9372,$93dd,$9449,$94b6,$9524
	dc.w	$9593,$9603,$9675,$96e7,$975a,$97ce,$9844,$98ba,$9931,$99aa,$9a23,$9a9d,$9b18,$9b94,$9c12,$9c90
	dc.w	$9d0f,$9d8f,$9e10,$9e92,$9f15,$9f98,$a01d,$a0a3,$a129,$a1b1,$a239,$a2c2,$a34d,$a3d8,$a464,$a4f0
	dc.w	$a57e,$a60d,$a69c,$a72d,$a7be,$a850,$a8e3,$a976,$aa0b,$aaa0,$ab37,$abce,$ac65,$acfe,$ad98,$ae32
	dc.w	$aecd,$af69,$b005,$b0a3,$b141,$b1e0,$b27f,$b320,$b3c1,$b463,$b505,$b5a8,$b64c,$b6f1,$b797,$b83d
	dc.w	$b8e4,$b98b,$ba33,$badc,$bb86,$bc30,$bcdb,$bd86,$be32,$bedf,$bf8d,$c03b,$c0e9,$c198,$c248,$c2f9
	dc.w	$c3aa,$c45b,$c50e,$c5c0,$c674,$c727,$c7dc,$c891,$c946,$c9fc,$cab3,$cb6a,$cc21,$ccda,$cd92,$ce4b
	dc.w	$cf05,$cfbf,$d079,$d134,$d1ef,$d2ab,$d367,$d424,$d4e1,$d59f,$d65d,$d71b,$d7da,$d899,$d958,$da18
	dc.w	$dad8,$db99,$dc5a,$dd1b,$dddd,$de9f,$df61,$e023,$e0e6,$e1a9,$e26d,$e331,$e3f5,$e4b9,$e57e,$e642
	dc.w	$e707,$e7cd,$e892,$e958,$ea1e,$eae4,$ebab,$ec71,$ed38,$edff,$eec6,$ef8e,$f055,$f11d,$f1e4,$f2ac
	dc.w	$f374,$f43c,$f505,$f5cd,$f696,$f75e,$f827,$f8ef,$f9b8,$fa81,$fb4a,$fc13,$fcdc,$fda5,$fe6e,$ff37
	dc.w	$0000,$00c9,$0192,$025b,$0324,$03ed,$04b6,$057f,$0648,$0711,$07d9,$08a2,$096a,$0a33,$0afb,$0bc4
	dc.w	$0c8c,$0d54,$0e1c,$0ee3,$0fab,$1072,$113a,$1201,$12c8,$138f,$1455,$151c,$15e2,$16a8,$176e,$1833
	dc.w	$18f9,$19be,$1a82,$1b47,$1c0b,$1ccf,$1d93,$1e57,$1f1a,$1fdd,$209f,$2161,$2223,$22e5,$23a6,$2467
	dc.w	$2528,$25e8,$26a8,$2767,$2826,$28e5,$29a3,$2a61,$2b1f,$2bdc,$2c99,$2d55,$2e11,$2ecc,$2f87,$3041
	dc.w	$30fb,$31b5,$326e,$3326,$33df,$3496,$354d,$3604,$36ba,$376f,$3824,$38d9,$398c,$3a40,$3af2,$3ba5
	dc.w	$3c56,$3d07,$3db8,$3e68,$3f17,$3fc5,$4073,$4121,$41ce,$427a,$4325,$43d0,$447a,$4524,$45cd,$4675
	dc.w	$471c,$47c3,$4869,$490f,$49b4,$4a58,$4afb,$4b9d,$4c3f,$4ce0,$4d81,$4e20,$4ebf,$4f5d,$4ffb,$5097
	dc.w	$5133,$51ce,$5268,$5302,$539b,$5432,$54c9,$5560,$55f5,$568a,$571d,$57b0,$5842,$58d3,$5964,$59f3
	dc.w	$5a82,$5b10,$5b9c,$5c28,$5cb3,$5d3e,$5dc7,$5e4f,$5ed7,$5f5d,$5fe3,$6068,$60eb,$616e,$61f0,$6271
	dc.w	$62f1,$6370,$63ee,$646c,$64e8,$6563,$65dd,$6656,$66cf,$6746,$67bc,$6832,$68a6,$6919,$698b,$69fd
	dc.w	$6a6d,$6adc,$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61,$6dc9,$6e30,$6e96,$6efb,$6f5e,$6fc1,$7022,$7083
	dc.w	$70e2,$7140,$719d,$71f9,$7254,$72ae,$7307,$735f,$73b5,$740a,$745f,$74b2,$7504,$7555,$75a5,$75f3
	dc.w	$7641,$768d,$76d8,$7722,$776b,$77b3,$77fa,$783f,$7884,$78c7,$7909,$794a,$7989,$79c8,$7a05,$7a41
	dc.w	$7a7c,$7ab6,$7aee,$7b26,$7b5c,$7b91,$7bc5,$7bf8,$7c29,$7c59,$7c88,$7cb6,$7ce3,$7d0e,$7d39,$7d62
	dc.w	$7d89,$7db0,$7dd5,$7dfa,$7e1d,$7e3e,$7e5f,$7e7e,$7e9c,$7eb9,$7ed5,$7eef,$7f09,$7f21,$7f37,$7f4d
	dc.w	$7f61,$7f74,$7f86,$7f97,$7fa6,$7fb4,$7fc1,$7fcd,$7fd8,$7fe1,$7fe9,$7ff0,$7ff5,$7ff9,$7ffd,$7ffe



;BPLCON1 scroll values
VEC_HORIZSCROLL_TABLE_NUMWORDS = 256
;VEC_HORIZSCROLL_TABLE_OFFSET_MASK = VEC_HORIZSCROLL_TABLE_NUMWORDS-1
VEC_HORIZSCROLL_TABLE_OFFSET_MASK = ((VEC_HORIZSCROLL_TABLE_NUMWORDS*2)-2)	; Byte offset access into the table, forced to be even 

	EVEN
VEC_HorizScroll_Table:
	INCLUDE "bin/Sine_0_6_256_words.i"
	EVEN

	RSRESET
VEC_HORIZSCROLL_ACTIVE:		rs.w	1
VEC_HORIZSCROLL_SIN1_OFFSET:	rs.w	1
VEC_HORIZSCROLL_SIN1_SPEED:	rs.w	1
VEC_HORIZSCROLL_SIN1_STEP:	rs.w	1
VEC_HORIZSCROLL_SIZE		rs.w	0

VEC_HorizScroll_Variables:
	ds.b	VEC_HORIZSCROLL_SIZE


; Master palette poked into the copperlist each frame
VEC_Palette:		dc.w	$0,$0,$0,$0,$0,$0,$0,$0
			dc.w	$0,$0,$0,$0,$0,$0,$0,$0

; This holds the source palette used during transitions in VEC_FX_PALETTE. The
; source value is interpolated from this value to the destination value + step size.
VEC_Palette_Src:
			dc.w	$0,$0,$0,$0,$0,$0,$0,$0
			dc.w	$0,$0,$0,$0,$0,$0,$0,$0

*****************************************************************************

*** Program Variables ***
VEC_Initialised:
	dc.w	0
VEC_Finished:
	dc.w	0

; Screen buffer pointers
VEC_Screen_Ptr:			dc.l	0
VEC_Work_Ptr:			dc.l	0

; Copper list pointers
VEC_Screen_CL_Ptr:		dc.l	0
VEC_Work_CL_Ptr:		dc.l	0

; Details of the overall full screenscreen fills and clears - we keep a bounding
; box of the screen area used to optimize fills and clears
VEC_SCR_CLR_Details_Ptr:	dc.l 	0
VEC_WORK_CLR_Details_Ptr:	dc.l 	0

	RSRESET
VEC_SCR_CLR_LINEHEIGHT:		rs.w	1
VEC_SCR_CLR_WORDWIDTH:		rs.w	1
VEC_SCR_CLR_BYTEMODULO:		rs.w	1
VEC_SCR_CLR_SRCPTR:		rs.l	1	;if 0 then do not use
VEC_SCR_CLR_BLTSIZE:		rs.w	1
VEC_SCR_CLR_SIZE:		rs.w	0

	EVEN
VEC_SCR_CLR_Details:
	dc.w	0	;height in lines to clear
	dc.w	0	;width in words to clear
	dc.w	0	;modulo for next line
	dc.l	0	;screen ptr for bottom right src (descending) INIT AS 0
	dc.w	0	;bltsize

VEC_WORK_CLR_Details:
	dc.w	0	;height in lines to clear
	dc.w	0	;width in words to clear
	dc.w	0	;modulo for next line
	dc.l	0	;screen ptr for bottom right src (descending) INIT AS 0
	dc.w	0	;bltsize
	EVEN

; Variables used in Blit/Copy face
	RSRESET
VEC_BLITFACE_VARS_DRAWPTR:	rs.l 1
VEC_BLITFACE_VARS_SCRPTR:	rs.l 1
VEC_BLITFACE_VARS_STIPPLEPTR:	rs.l 1
VEC_BLITFACE_VARS_MOD_1BPL:	rs.w 1
VEC_BLITFACE_VARS_MOD_NBPL:	rs.w 1
VEC_BLITFACE_VARS_BLTSIZE:	rs.w 1
VEC_BLITFACE_VARS_PAPERCOL:	rs.w 1
VEC_BLITFACE_VARS_INKCOL:	rs.w 1
VEC_BLITFACE_VARS_SIZE:		rs.w 0

VEC_BlitFace_Vars:
	ds.b VEC_BLITFACE_VARS_SIZE

;Current object
VEC_ObjectCurrent_Adr:	dc.l 	0		; Object info (pos,rotation,etc)


*****************************************************************************

VEC_OBJ_INFO = 0

VEC_OBJ_INITIALIZED = 0

VEC_OBJ_POSX = 2
VEC_OBJ_POSY = 4
VEC_OBJ_POSZ = 6

VEC_OBJ_THETA = 8
VEC_OBJ_THETA_X = 8
VEC_OBJ_THETA_Y = 10
VEC_OBJ_THETA_Z = 12
VEC_OBJ_THETA_DX = 14
VEC_OBJ_THETA_DY = 16
VEC_OBJ_THETA_DZ = 18
VEC_OBJ_COMPLEX = 20
VEC_OBJ_NUMFRAMES = 22
VEC_OBJ_PTS_PTR = 24
VEC_OBJ_PTSINITIAL_PTR = 28
VEC_OBJ_FACELIST_PTR = 32
VEC_OBJ_MORPH_ACTIVE = 36
VEC_OBJ_MORPH_COUNTER = 38
VEC_OBJ_MORPH_SPEED = 40

;Obj_Glenz24_Info:
;	dc.w	0			; initialised (happens on first load)
;	dc.w	0,0,0			; pos, x,y,z
;	dc.w	0,0,0			; current rotation, x,y,z
;	dc.w	1,2,3			; Rotation step, x,y,z
;	dc.w	0			; Complex 1/0
;	dc.w	1			; Num frames max
;	dc.l	Obj_Glenz24_PtsBuffer	; Pts ptr (in use/buffer)
;	dc.l	Obj_Glenz24_Pts		; Initial points ptr
;	dc.l	Obj_Glenz24_Facelist	; Facelist ptr
;	dc.w	0,0,0			; Morph active flag, counter, speed

*****************************************************************************

VEC_FACE_NUMLINES = 0
VEC_FACE_PAPER = 2
VEC_FACE_INK = 3
VEC_FACE_PAPER_BACKFACE = 4
VEC_FACE_INK_BACKFACE = 5
VEC_FACE_FLAG_BACKFACE = 6
VEC_FACE_MINX = 8
VEC_FACE_MINY = 10
VEC_FACE_MAXX = 12
VEC_FACE_MAXY = 14
VEC_FACE_AVG_Z = 16
VEC_FACE_CON_XY1 = 18
VEC_FACE_CON_XY3 = 24

;connect pt 2 to pt 2, *6 is the byte offset in the Rotated pts struct.
VEC_CON		MACRO
		dc.w	\1*6,\2*6
		ENDM

VEC_FACE	MACRO			;define face pts,col
		dc.w	\1		;number of lines
		dc.b	\2,\3		;paper, ink (visible)
		dc.b	\4,\5		;paper, ink (backface), paper=-1 to just cull
		dc.w	0		;0/1 - is currently a backface after hidden line calc
		dc.w	0,0,0,0		;minx,y,maxx,y
		dc.w	0		;current average z for this face
		ENDM

; Note: Fastest colors are 1,2,4, then 3,5,6, then 7
; Also features stipple colours, that is, when you
; define a face 2 colours are entered first the
; PAPER & then the INK!
; n.b. if a stipple with col00 is needed then
; make sure that the PAPER is set to 0 and not
; the INK as it is slightly faster this way!

*****************************************************************************


*****************************************************************************

; Objects
	INCLUDE "Obj_C_Cube12.i"
	INCLUDE "Obj_C_Cube24.i"
	INCLUDE "Obj_Cube24.i"
	INCLUDE "Obj_Glenz24.i"
	INCLUDE "Obj_C_VectorRepublic_Simple.i"

*****************************************************************************

*** Demo Sequencing ***
; Has to go last to have all the labels from the individual parts available

	; The actual demo sequences
	INCLUDE "VEC_ControllerScript.i"


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	VectorPublicBSS,BSS	;Public blank memory

; Screen height mult by screen bytewidth and number of bitplanes (interleaved)
VEC_Mult_SCR_Height_ByteWidth_NumPlanes:
	ds.w	VEC_SCR_HEIGHT

; Screen height mult by screen bytewidth (non-interleaved or single bitplane draw buffer)
VEC_Mult_SCR_Height_ByteWidth:
	ds.w	VEC_SCR_HEIGHT

*****************************************************************************

;Rotation stuff for matrix

;Object rotation

VEC_MROT11 = 0
VEC_MROT12 = 2
VEC_MROT13 = 4
VEC_MROT21 = 6
VEC_MROT22 = 8
VEC_MROT23 = 10
VEC_MROT31 = 12
VEC_MROT32 = 14
VEC_MROT33 = 16

VEC_MatrixRotObject:
	ds.w	1			;0
	ds.w	1			;2
	ds.w	1			;4

	ds.w	1			;6
	ds.w	1			;8
	ds.w	1			;10

	ds.w	1			;12
	ds.w	1			;14
	ds.w	1			;16


VEC_RotXYZpts:
	ds.w	VEC_MAX_PTS*3			;rotated 128 pts 3d

; Visible face buffer is a list of pointer to face data structures.
; Room for 64 faces
VEC_Visible_Face_Buffer:
	ds.w	1		; num faces
	ds.l	VEC_MAX_FACES	; face ptr.l



*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	VectorChipData,DATA_C	;Chip Data Section for gfx/music

*****************************************************************************

*** THE COPPERLISTS ***

; Copper horizontal blanking notes from Photon/Scoopex
; As established, positions $e7...$03 are not usable. If you're writing a simple 
; copperlist with no need for tight timing, positions $df and $07 are conventionally 
;used for the positions on either side of the horizontal blanking, and for 
; compatibility across chipsets use increments of 4 from these, resulting in 
;positions $db, $0b, and so on.


	CNOP 0,8	; 64 bit alignment for AA
VEC_Screen_CL:
	CMOVE	FMODE,VEC_MemoryFetchMode		;Chip Ram fetch mode (0=OCS)

VEC_Screen_CL_Color00:
VEC_Screen_CL_Cols:
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ELSE
		CMOVE	COLOR01,$000		; If testing then just use color01 twice
	ENDC
	CMOVE	COLOR01,$000
	CMOVE	COLOR02,$000
	CMOVE	COLOR03,$000
	CMOVE	COLOR04,$000
	CMOVE	COLOR05,$000
	CMOVE	COLOR06,$000
	CMOVE	COLOR07,$000

	CWAIT	VEC_DIW_V-2,$7		;Time for altering Copperlist
	CMOVE	BEAMCON0,$0020		;Pal mode ( $0000=NTSC )
	CMOVE 	DIWSTRT,VEC_DIW_Start
	CMOVE 	DIWSTOP,VEC_DIW_Stop
	CMOVE 	DDFSTRT,VEC_DDF_Start
	CMOVE 	DDFSTOP,VEC_DDF_Stop
	CMOVE 	BPLCON0,$3200		;3bpl/8 cols
	CMOVE 	BPLCON1,$0000
	CMOVE	BPLCON2,$0000
	CMOVE	BPLCON3,$0c00		;AGA compat, dual playfield related
	CMOVE	BPLCON4,$0011
	CMOVE 	BPL1MOD,VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES-1)	;interleaved mode
	CMOVE 	BPL2MOD,VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES-1)

VEC_Screen_CL_Bpl:			;Bitplane pointers
	CMOVE	BPL1PTH,$0
	CMOVE	BPL1PTL,$0
	CMOVE	BPL2PTH,$0
	CMOVE	BPL2PTL,$0
	CMOVE	BPL3PTH,$0
	CMOVE	BPL3PTL,$0

VEC_Screen_CL_HorizScoll:
a set VEC_DIW_V-1
	REPT VEC_HORIZ_SCROLL_NUMLINES
	CWAIT	a&$ff,$e1
	CMOVE	BPLCON1,$0000
a set a+1
	ENDR

	; Reflection at 224+$2c = 268
	;IFGT	VEC_DIW_V_REFLECTION-255
	;	CWAIT	255,$e1
	;	CWAIT	VEC_DIW_V_REFLECTION&$ff,$e1
	;ELSE
	;	CWAIT	VEC_DIW_V_REFLECTION&$ff,$e1
	;ENDC
;a set VEC_DIW_V_REFLECTION-1
;	CWAIT	a&$ff,$e1
	; 4 lines = 1 reflected line
	CMOVE	BPL1MOD,(-(VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES+1)))-(3*VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES)
	CMOVE	BPL2MOD,(-(VEC_SCR_BYTEWIDTH*(VEC_SCR_NUMPLANES+1)))-(3*VEC_SCR_BYTEWIDTH*VEC_SCR_NUMPLANES)

VEC_Screen_CL_Refl_Cols:
	IFEQ	RasterTest
		CMOVE	COLOR00,$000
	ELSE
		CMOVE	COLOR01,$000		; If testing then just use color01 twice
	ENDC
	CMOVE	COLOR01,$000
	CMOVE	COLOR02,$000
	CMOVE	COLOR03,$000
	CMOVE	COLOR04,$000
	CMOVE	COLOR05,$000
	CMOVE	COLOR06,$000
	CMOVE	COLOR07,$000

VEC_Screen_CL_HorizScoll_Refl:	
	REPT VEC_HORIZ_SCROLL_REFL_NUMLINES
	CWAIT	a&$ff,$e1
	CMOVE	BPLCON1,$0000	
a set a+1
	ENDR

	COPPEREND
VEC_Screen_CL_End:

VEC_CL_BPL_OFFSET = (VEC_Screen_CL_Bpl-VEC_Screen_CL)
VEC_CL_COL_OFFSET = (VEC_Screen_CL_Cols-VEC_Screen_CL)
VEC_CL_COL_REFL_OFFSET = (VEC_Screen_CL_Refl_Cols-VEC_Screen_CL)
VEC_CL_HORIZSCROLL_OFFSET = (VEC_Screen_CL_HorizScoll-VEC_Screen_CL)
VEC_CL_HORIZSCROLL_REFL_OFFSET = (VEC_Screen_CL_HorizScoll_Refl-VEC_Screen_CL)
VEC_CL_SIZE = VEC_Screen_CL_End-VEC_Screen_CL

*****************************************************************************

; 2nd copy of copper list for double buffering

	CNOP 0,8	; 64 bit alignment for AA
VEC_Work_CL:
	ds.b	VEC_CL_SIZE

					
*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	VectorChipBss,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************

; The stipple pattern is 1bpl same size as screen
VEC_Stipple_1Bpl:
	ds.b	VEC_SCR_SIZE

; Can't nest REPT in devpac so have to precalc at startup
;	REPT	(VEC_SCR_HEIGHT/2)
;		REPT	VEC_SCR_WORDWIDTH
;			dc.w $5555
;		ENDR
;		REPT	VEC_SCR_WORDWIDTH
;			dc.w $aaaa
;		ENDR
;	ENDR

*****************************************************************************


