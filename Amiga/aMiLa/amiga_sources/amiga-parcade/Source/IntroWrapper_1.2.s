
*****************************************************************************

; Name			: IntroWrapper.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: The main wrapper for the entire intro.
; Date last edited	: 24/05/2019

; CPU Required		: MC68000 or better
; ChipSet Required	: OCS or better
				
*****************************************************************************

RasterTest	=	0	;Timing bar
Music		=	1	;Play music
WBStartupCode	=	1	;Add startup code from icon (needs amigaos includes and won't compile in ASMOne)

*****************************************************************************

	INCDIR "SOURCES:Parcade/"

	IFNE WBStartupCode
		INCLUDE "exec/exec_lib.i"
		INCLUDE	"exec/exec.i"
		INCLUDE	"libraries/dosextens.i"
	ENDC

	IFND _CUSTOMMACROS_I
		INCLUDE "CustomMacros.i"
	ENDC
	
	SECTION	IntroWrapperCode,CODE	;Code section in Public memory

; Flag so that subparts can be tested standalone or as part of intro.
_INTROWRAPPER = 1

*****************************************************************************
*****************************************************************************
IntroIconStartup:
	IFNE WBStartupCode
	;This handles startup from an icon cleanly.
	movem.l	d0/a0,-(sp)

	sub.l	a1,a1
	move.l  4.w,a6
	jsr	_LVOFindTask(a6)

	move.l	d0,a4

	tst.l	pr_CLI(a4)	; was it called from CLI?
	bne.s   .fromCLI		; if so, skip out this bit...

	lea	pr_MsgPort(a4),a0
	move.l  4.w,a6
	jsr	_LVOWaitPort(A6)
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(A6)
	move.l	d0,.returnMsg

.fromCLI
	movem.l	(sp)+,d0/a0
	ENDC

	bsr.s	IntroStartup           	; Calls your code..
	
	IFNE WBStartupCode
	move.l	d0,-(sp)
	tst.l	.returnMsg		; Is there a message?
	beq.s	.exitToDOS		; if not, skip...

	move.l	4.w,a6
        jsr	_LVOForbid(a6)          ; note! No Permit needed!
	move.l	.returnMsg(pc),a1
	jsr	_LVOReplyMsg(a6)
.exitToDOS:
	move.l	(sp)+,d0		; exit code
	ENDC

	rts

.returnMsg:	dc.l	0

*****************************************************************************

	EVEN
IntroStartup:
	jsr	KillSys			;Kill system	
	bsr	IntroMain		;Run the intro
	jsr	RestoreSys		;Restore system
	clr.l 	d0			;Keep cli happy
	rts


*****************************************************************************

IntroMain:
		
;Setup music and VBI
	IFNE	Music
		move.l	VBRPtr,P61_VBR
		lea	MusicModule,a0
		moveq	#0,d0
		move.l	d0,a1
		move.l	d0,a2
		jsr	P61_Init
	ENDC	

	lea	CUSTOM,a5

	; Setup initial blank screen and turn DMA on
	jsr	SetBaseCopperAndDma_A5

	; RGB12 interpolation table
	jsr	RGB12_Interpolate_Fast_BuildTable

	; Install the music VBR
	move.l	VBRPtr,a4
	move.l	#VBlankServer,_Level3Vector(a4)

	ENABLE_LEV3_A5			;Enable Vblank interrupts	
	bsr	MainLoop		;Start program
	DISABLE_LEV3_A5			;Vblank interrupts off

	; Finish music
	IFNE	Music
	jsr	P61_End
	ENDC

	rts

*****************************************************************************

MainLoop:
	; Wait until frame to start
.startwait:
	clr.w	Quit_Flag		;Don't quit just yet
	
.MainLoop1
	tst.w	Quit_Flag
	bne.w	.quit
	
	move.l	ControllerScriptPtr,a6

	;Get a new command from the script
	move.w	(a6)+,d0
	cmpi.w	#FX_End,d0		;End of script? Restart
	beq.s	.restartscript
	
	cmpi.w	#FX_Pause,d0
	beq	.fx_pause
	cmpi.w	#FX_Vector,d0
	beq	.fx_vector
	cmpi.w	#FX_BOBSnake,d0
	beq.s	.fx_bobsnake
	cmpi.w	#FX_Flash,d0
	beq.s	.fx_flash
	cmpi.w	#FX_TextWall,d0
	beq	.fx_textwall
	cmpi.w	#FX_Sine,d0
	beq	.fx_sine
	cmpi.w	#FX_Logo,d0
	beq	.fx_logo

	; uknown?? error in script - restart
.restartscript
	move.l	#ControllerScript,ControllerScriptPtr
	bra	.tstmouse

.fx_pause:
	move.w	(a6)+,d0		;pause time
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	WaitVBI_X
	bra	.tstmouse

.fx_bobsnake:
	move.l	(a6)+,a0		;Routine pointer to pass as parameter
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	BOBSnake_Start
	bra	.tstmouse

.fx_flash:
	;move.w	(a6)+,d0		;Pause after text
	;move.l	(a6)+,a0		;Text message to pass as parameter
	move.l	a6,ControllerScriptPtr	;Store script ptr
	move.l	#CL_Color00,a4
	
	move.w	#$555,2(a4)
	jsr	WaitVBI
	move.w	#$aaa,2(a4)
	jsr	WaitVBI
	move.w	#$fff,2(a4)
	jsr	WaitVBI
	move.w	#$aaa,2(a4)
	jsr	WaitVBI
	move.w	#$555,2(a4)
	jsr	WaitVBI
	move.w	#$000,2(a4)

	bra.s	.tstmouse

.fx_vector:
	move.l	(a6)+,a0		;Text message to pass as parameter
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	VEC_Start
	bra.s	.tstmouse

.fx_textwall:
	move.w	(a6)+,d0		;Pause after text
	move.l	(a6)+,a0		;Text message to pass as parameter
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	TX1_Start
	bra	.tstmouse

.fx_sine:
	move.l	(a6)+,a0		;Text message to pass as parameter
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	SIN_Start
	bra	.tstmouse

.fx_logo:
	move.l	(a6)+,a0		;.l param
	move.l	a6,ControllerScriptPtr	;Store script ptr
	jsr	LGO_Start
	bra	.tstmouse

;---
.tstmouse
	btst 	#10-8,POTGOR+CUSTOM	;rmb quits section so stay here until it is released
	beq.s	.tstmouse		

	btst 	#6,$bfe001		;L.m.b. pressed?
	bne.w 	.MainLoop1

.quit	rts				;exit
			

*****************************************************************************
*****************************************************************************

	;Include framework functions and shared data
	INCLUDE "IntroFramework.i"
	INCLUDE "IntroSharedData.i"

*****************************************************************************

	;Include Demo Parts
	INCLUDE "Logo_1.0.s"
	INCLUDE "BobSnake_1.6.s"
	INCLUDE "BigSineScroller_1.4.s"
	INCLUDE "TextWall_1.6.s"
	INCLUDE "GlenzSimple_1.23.s"


*****************************************************************************
*****************************************************************************

	SECTION	AntPublicData2,DATA	;Public data section for variables
	
*****************************************************************************

*** Demo Sequencing ***
; Has to go last to have all the labels from the individual parts available

FX_End			= 	$ff
FX_None			=	$f0
FX_TitlePic		=	$f1
FX_Sine			=	$f2
FX_TextWall		=	$f3
;FX_TextDotWriter	=	$f4
FX_BOBSnake		=	$f5
FX_Vector		=	$f6
FX_Pause		=	$f7
FX_Flash		=	$f8
FX_Logo			=	$f9


ControllerScriptPtr:	dc.l	ControllerScript

ControllerScript:

;	dc.w	FX_Pause,100
;	dc.w	FX_VectorInc
;	dc.l	0

	dc.w	FX_Pause,100
	dc.w	FX_Logo
	dc.l	0

	dc.w	FX_TextWall,50
	dc.l	TX1_Text_Intro

	dc.w	FX_Sine
	dc.l	SIN_Text1

	dc.w	FX_TextWall,50
	dc.l	TX1_Text_Vectors
	dc.w	FX_Vector
	dc.l	VEC_ControllerScript

	dc.w	FX_TextWall,50
	dc.l	TX1_Text_BOBSnake
	dc.w	FX_BOBSnake
	dc.l	BOBSnake_Routine1

	dc.w	FX_TextWall,50
	dc.l	TX1_Text_VectorRepublic
	dc.w	FX_Vector
	dc.l	VEC_ControllerScript_VR

	dc.w	FX_TextWall,50
	dc.l	TX1_Text_Credits

ControllerScriptEnd:
	dc.w	FX_End

