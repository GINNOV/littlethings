*****************************************************************************

; Name			: IntroStandalone.s
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Simulates frames so individual parts can be tested.
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

	SECTION	IntroStandAloneCode,CODE	;Code section in Public memory

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
	
	clr.w	Quit_Flag		;Don't quit just yet
	
.MainLoop1
	tst.w	Quit_Flag
	bne.w	.quit

	jsr	SubPartStart	

	;btst 	#6,$bfe001		;L.m.b. pressed?
	;bne.w 	.MainLoop1		;restart

.quit	rts				;exit

*****************************************************************************

	;Include framework functions and shared data
	INCLUDE "IntroFramework.i"
	INCLUDE "IntroSharedData.i"

*****************************************************************************
