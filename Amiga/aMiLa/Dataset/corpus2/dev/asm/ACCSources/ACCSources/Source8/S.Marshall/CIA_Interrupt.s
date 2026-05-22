************************************************************************
*
*	    Simple Demonstration of setting up a CIA interrupt
*	This demo sets up a 50Hz interrupt (same speed as VBlank)
*	     so it can be used with little modification for
*	music playroutines etc. The advantage of this routine is
*	that there is no difference in speed between NTSC and PAL
*	machines (as opposed to 20% difference with VBlank or Copper
*	interrupts.This routine makes the slight adjustment needed
*	to compensate for the slight difference in CPU speed between
*	NTSC and PAL machines.
*	This Demo simply toggles the power LED 50 times per second.
*	The reason for this is that the code is very simple and 
*	doesn't confuse matters, making it easy to see the interrupt
*	code itself.
*
*		This program Compiles with Devpac V2
*
*			By Steve Marshall
*
************************************************************************

	INCDIR	"sys:Include/"
	INCLUDE	exec/exec_lib.i
	INCLUDE	resources/cia.i
	INCLUDE	hardware/cia.i
	INCLUDE	misc/easystart.i


	LIBINIT	LIB_BASE		;lib offsets for CIA resource
	LIBDEF	CIA_ADDICRVECTOR	;as not defined in recources/cia.i :-)
	LIBDEF	CIA_REMICRVECTOR	;I think these are correct anyway the 
	LIBDEF	CIA_ABLEICR		;two used in this program are.Does 
	LIBDEF	CIA_SETICR		;Commodore think we are telepathic ?
	
PALTIME		EQU	14187		;sets interrupt timer to 50Hz
NTSCTIME	EQU	14318

***************************************************************************

CALLSYS    MACRO
	IFGT	NARG-1         
	FAIL	!!!           
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM

***************************************************************************

	lea		InterruptVector(pc),a0	;set a0 to interrupt vector
	bsr.s		InitCIA			;set it running
	tst.l		d0			;check for errors
	beq.s		loop			;branch if no error
	move.l		#5,errorMsg		;set error to WARN
	bra.s		_exit2			;branch if error

loop:
	moveq		#0,d0			;no newsignals
	moveq		#0,d1			;no mask
	CALLEXEC	SetSignal		;check signals
	btst		#12,d0			;check for control C
	bne.s		_exit			;branch if Ctrl C
	btst		#6,$bfe001		;check for left mouseclick
	bne.s		loop 			;branch if not left mouse	
	
_exit
	lea		InterruptVector(pc),a0	;set interrupt to stop
	bsr		CIAOff			;and stop it
	clr.l		errorMsg		;no errors so clear error msg
_exit2
	bclr  		#1,$bfe001  		;**** LED on ****	
	rts					;EXIT program



InitCIA:
	move.l		a0,-(sp)		;save a0
	lea		CIAname(pc),a1		;get cia resource name 
	CALLEXEC	OpenResource		;open resource
	move.l		d0,CIAbase		;store resource base
	beq		CIA_Error		;branch if open failed
	
	moveq		#0,d0			;any lib version
  	lea		Grafname(pc),a1		;graphics lib name
  	CALLSYS		OpenLibrary		;open it
  	move.l		d0,d6			;store lib base
  	beq.s		.Pal			;default to pal if no graf lib
  	
  	move.l		d0,a1			;graphics lib base in a0
	move.w		206(a1),d1		;get Display flags
	btst		#2,d1			;does DisplayFlags = PAL
	beq.s		.Ntsc 			;branch if not PAL
.Pal
	move.w		#PALTIME,d7		;set PAL time delay
	bra.s		Timeset			;branch always
.Ntsc
	move.w		#NTSCTIME,d7		;set NTSC time delay

Timeset	
	lea		$bfd000,a5		;get peripheral data reg a
	move.l		CIAbase(pc),a6		;get cia base
	move.l		(sp),a1			;get Interrupt vector
	moveq		#1,d0			;set ICRBit (timer B)
	jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
	move.l		d0,CIAFlag		;store return value
	bne.s		TryTimerA		;branch to try timer A
	
	move.b		d7,ciatblo(a5)		;set timer B low
	lsr.w		#8,d7			;shift left for high byte
	move.b		d7,ciatbhi(a5)		;set timer B high
	bset		#0,ciacrb(a5)		;start timer (continuous)
	bra.s		CIA_End			;branch to finish
	
TryTimerA:
	move.l		(sp),a1			;get Interrupt vector
	moveq		#0,d0			;set ICRBit (timer A)
	jsr		CIA_ADDICRVECTOR(a6)	;add interrupt
	tst.l		d0			;check for error
	bne.s		CIA_Error		;branch if error
  	
	move.b		d7,ciatalo(a5)		;set timer A low
	lsr.w		#8,d7			;shift left for hight byte
	move.b		d7,ciatahi(a5)		;set timer B high
	bset		#0,ciacra(a5)		;start timer A

CIA_End:
	tst.l		d6			;check for Gfx lib
	beq.s		NoGfxLib		;branch if no lib
	move.l		d6,a1			;_GfxBase in a1
  	CALLEXEC 	CloseLibrary		;close graphics

NoGfxLib	
	moveq		#0,d0			;flag no error
	addq.l		#4,sp			;pop a0 from stack
	rts					;quit
	
CIAOff:
	move.l		a0,-(sp)		;save a0
	lea		$bfd000,a5		;get peripheral data reg a
	tst.l		CIAFlag			;check for timer B
	bne.s		TimerA			;branch if not timer B
	
	bclr		#0,ciacrb(a5)		;stop timer B
	moveq		#1,d0			;set ICRBit (timer B)
	bra.s		RemInt			;branch to remove
TimerA
	bclr		#0,ciacra(a5)		;stop timer A
	moveq		#0,d0			;set ICRBit (timer A)
	
RemInt
	move.l		CIAbase(pc),a6		;get CIA base
	move.l		(sp),a1			;get interrup to remove
	jsr		CIA_REMICRVECTOR(a6)	;and remove it

CIA_Error:
	moveq		#-1,d0			;flag error
	addq.l		#4,sp			;pop a0 from stack
	rts					;quit

Interrupt_handler:
	movem.l		d2-d7/a2-a6,-(a7)	;save regs
	bsr.s		Interrupt_code		;run our code
	
	movem.l		(a7)+,d2-d7/a2-a6	;restore regs
	moveq		#0,d0			;allow other interrupts to run
	rts	
	
;------	you can add your own interrupt driven code here or point the
;	Interrupt_handler bsr to your own code

Interrupt_code:
	bchg		#1,$bfe001		;toggle LED
	rts	
	
********** variables and structures ********
;------	Interrupt structure	
InterruptVector:
		dc.l	0	;LN_SUCC
		dc.l	0	;LN_PRED
		dc.b	0	;LN_TYPE
		dc.b	127	;LN_PRI
		dc.l	0	;LN_NAME
		dc.l	0	;is_Data
		dc.l	Interrupt_handler	;address of routine to call

errorMsg:	dc.l	0

CIAFlag:	dc.l	0		

CIAbase:	dc.l	0	

CIAname:
	CIABNAME
	
Grafname:
	dc.b	'graphics.library',0
	EVEN
