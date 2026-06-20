*********************************************************
*							*
*		MacFloppy.device			*
*							*
*	mfio.asm - Mac drive io routines		*
*							*
*	Copyright (c) 1989 Central Coast Software	*
*							*
*********************************************************

	INCLUDE "vd0:MACROS.ASM"
	INCLUDE "mf.i"

	XDEF	DriveInstalled
	XDEF	DoubleSided
	XDEF	DriveReady
	XDEF	CheckProtection
	XDEF	Track0
	XDEF	MotorOnOff
	XDEF	StepHeads
	XDEF	ZapSpeedTable
	XDEF	ReadTrack,WriteTrack
	XDEF	BusyDrives,FreeDrives
	XDEF	SetTrkParams
	XDEF	EjectDisk
	XDEF	MotorChangeB,MotorChangeA
	XDEF	FreeTimer

	XREF	TimeDelay,WaitForSignal


Deselect	EQU	$78	;select bits for DF0-DF3
RPMconstant	EQU	120000	;RPM conversion constant
PulseWidth	EQU	750	;				;gec 2/12/90
;;PulseWidth	EQU	950	;depends upon speed control technique
TimeVal		EQU	716	;1 ms in timer B ticks

* CIA resource library offsets

AddICRVector	EQU	-6
RemICRVector	EQU	-12
AbleICR		EQU	-18
SetICR		EQU	-24

TBLO	EQU	$BFD600
TBHI	EQU	$BFD700
TBCR	EQU	$BFDF00
TBICRB	EQU	1
TBICRF	EQU	2
OneShot		EQU	$18		;TimerB mode=force load, one-shot
ContMode	EQU	$10		;TimerB mode=force load, continuous

* Ejects disk from Mac drive.

EjectDisk:
	PUSH	D2/A2
	BSR	BusyDrives
	LEA	CIAB,A2
;	MOVE.B	Select(A3),(A2)
	OR.B	#CA0!CA1,(A2)		;eject disk
	OR.B	#CA2,(A2)
	MOVE.B	LSTRB(A3),D2
	BSET	D2,(A2)			;LSTRB on
	MOVE.L  #500000,D0		;else wait 0.5 second
	BSR	TimeDelay
	BCLR	D2,(A2)			;lstrb off
	MOVE.B	Select(A3),(A2)
	BSR	FreeDrives
	POP	D2/A2
	RTS	

* Checks whether or not Mac drive is hooked up to interface.

DriveInstalled:
	PUSH	D2
	BSR	BusyDrives
	LEA	CIAB,A0
	LEA	CIAA,A1
;	MOVE.B	#$FF,(A0)		;deselect everyone
;	BTST	#5,(A1)			;RDY is active low, better be high
;	BEQ.S	8$			;something has pulled rdy low
;	MOVE.B	#Deselect,(A0)		;condition for selection
;	MOVE.B	Select(A3),(A0)		;select drive
	OR.B	#CA0!CA1!CA2!SEL,(A0)	;put drive into speed control mode
	MOVE.B	Select(A3),D0
	OR.B	#CA0!CA1!CA2,D0
	MOVE.B	D0,(A0)			;now ask if drive is installed
	BTST	#5,(A1)			;should go low now
	BNE.S	8$			;oops...no response to selection
	MOVE.B	LSTRB(A3),D2		;now simulate speed control
	BSET	D2,(A0)			;this will deselect a normal drive
	BTST	#5,(A1)			;is it still set?
	BNE.S	8$			;no...drive didn't remember...
	BSR	FreeDrives
	CLC
	BRA.S	9$
8$:	BSR	FreeDrives
	STC
9$:	POP	D2
	RTS

* Checks for double-sided drive.

DoubleSided:
	PUSH	D2
	BSR	BusyDrives
	OR.B	#CA1!CA2,CIAB		;SIDES - double sided?
	MOVE.B	CIAA,D2
	BSR	FreeDrives
	MOVE.L	D2,D0
	AND.W	#$20,D0
	BNE.S	9$			;double-sided
	STC
9$:	POP	D2
	RTS

* Tests for diskette loaded in drive.

DriveReady:
	MOVE.B	Select(A3),CIAB
	OR.B	#SEL,CIAB		;CSTIN=disk in place
	MOVE.B	CIAA,D0
	AND.W	#$20,D0			;is there a disk?
	BEQ.S	9$			;yes
	STC				;else report error
9$:	RTS

* Checks for head over track 0.

Track0:	MOVE.B	Select(A3),CIAB
	OR.B	#SEL!CA1,CIAB		;TK0
	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	BEQ.S	9$			;at track 0
	STC				;else error
9$:	RTS

CheckProtection:
	MOVE.B	Select(A3),CIAB
	OR.B	#SEL!CA0,CIAB		;WRTPRT=write locked
	MOVE.B	CIAA,D0
	AND.W	#$20,D0
	BNE.S	9$			;write enabled
	STC				;else error
9$:	RTS

* Steps head to desired track.
* Desired track in D0.  Note: range 0-159

* Moves the heads one track in the direction indicated by Mac_StepDir flag.

StepHeads:
	PUSH	D2
	LEA	CIAB,A0			;first set direction of step
	MOVE.B	Select(A3),(A0)		;drive select, clear regs
	OR.B	#CA0!CA1,(A0)		;set direction
	MOVE.B	Select(A3),(A0)
	BTST	#Mac_StepDir,MacFlags(A3) ;step toward track 0?
	BEQ.S	1$			;no...toward spindle 
	OR.B	#CA2,(A0)		;toward track 0
1$:	MOVE.B	LSTRB(A3),D1
	BSET	D1,(A0)			;LSTRB
;	NOP
;	NOP
	MULU	D1,D0			;time delay
	BCLR	D1,(A0)			;clear LSTRB

	MOVE.B	Select(A3),(A0)		;reselect for actual step
	OR.B	#CA0!CA1,(A0)		;CA0!CA1
	MOVE.B	Select(A3),D0
	OR.B	#CA0,D0
	MOVE.B	D0,(A0)
	OR.B	#CA2,(A0)
	BSET	D1,(A0)			;LSTRB
;	NOP
;	NOP
;	NOP
;	NOP
	MULU	D1,D0			;time delay
	BCLR	D1,(A0)			;clear LSTRB
	MOVE.B	Select(A3),D0
	OR.B	#CA0!CA1,D0
	MOVE.B	D0,(A0)
	MOVE.B	Select(A3),D0
	OR.B	#CA0,D0
	MOVE.B	D0,(A0)
	BSET	D1,(A0)			;LSTRB
;	NOP
;	NOP
;	NOP
;	NOP
	MULU	D1,D0			;time delay
	BCLR	D1,(A0)
	MOVEQ	#10,D2			;max loop count
	BRA.S	5$
3$:	MOVE.B	CIAA,D0			;check status...
	AND.W	#$20,D0			;step complete?
	BNE.S	4$			;yes...all done
5$:	MOVE.L	#StepDelay,D0		;else wait for a bit
	BSR	TimeDelay
	DBF	D2,3$			;but don't get stuck here
4$:	POP	D2
	RTS

* New motor state in D0: 1=on, 0=off.  Returns prior state in D0.

MotorOnOff:
	PUSH	D2-D3
	MOVE.B	MacFlags(A3),D2		;preserve current motor state
	IFNZL	D0,1$			;commanded ON
	BCLR	#Mac_Motor,MacFlags(A3)	;MOTOR OFF NOW
	BEQ.S	9$			;was already off
	MOVE.B	#CA2,D3			;ELSE D3=CA2 FOR OFF
	BSR.S	MotorCmd		;issue the command for off
	BSR	FreeDrives		;and release the hardware
	BRA.S	9$

1$:	BSET	#Mac_Motor,MacFlags(A3)	;motor on now
	BNE.S	9$			;was already on
	BSR	BusyDrives
	ZAP	D3			;D3=0 FOR ON
	BSR.S	MotorCmd		;issue the cmd
	MOVE.L  #500000,D0		;else wait 0.5 second for spin up
	BSR	TimeDelay
9$:	ZAP	D0
	BTST	#Mac_Motor,D2		;what was prior motor state?
	SNE	D0			;set D0 to prior state of motorflag
	POP	D2-D3
	RTS

MotorCmd:
	LEA	CIAB,A0
	MOVE.B	LSTRB(A3),D1
	MOVE.B	Select(A3),(A0)
	OR.B	#CA0!CA1,(A0)
	MOVE.B	Select(A3),D0
	OR.B	#CA1,D0
	MOVE.B	D0,(A0)			;CA1
	OR.B	D3,(A0)			;CA2 if OFF, 0 if ON
	BSET	D1,(A0)			;LSTRB on
;	NOP
;	NOP
	MULU	D1,D0			;time delay
	BCLR	D1,(A0)			;lstrb off
	OR.B	#CA0!CA1,(A0)
	RTS

* Buffer to read into in A0, byte count in D0.

ReadTrack:
	PUSH	D2-D3/A2/A4
	MOVE.L	A0,A2			;buffer to A2
	LEA     HdwRegsBase,A4		;hardware base reg to A1
	LSR.W   #1,D0			;divide to get word count
	ORI.W   #$8000,D0		;enable DMA with write not set
	MOVE.L  D0,D2			;word count to D2

	MOVE.W  #$4000,$24(A4)		;stop DMA
	MOVE.L  #1000,D0		;wait 1ms
	BSR	TimeDelay
	BSR	DriveReady		;disk loaded?
	ERROR	8$,L			;no
	MOVE.L  A2,$20(A4)		;set DMA address
	MOVE.W  #$1002,$9C(A4)		;clear pending disk comp ints
	IFZB	DiskType(A3),1$		;ADOS format...mfm, no sync
	MOVE.W	#$1500,$9E(A4)
	MOVE.W	#$8300,$9E(A4)		;GCR sync
	BRA.S	2$
1$:	MOVE.W  #$600,$9E(A4)		;clear wordsync and msbsync
	MOVE.W  #$9100,$9E(A4)		;enable mfm precomp and 500khz clock

2$:	MOVE.B	#OneShot,TimerMode	;force one-shot mode
	MOVE.L	#250000,D0		;250ms to reach proper speed
	BSR	SpeedControlOn		;check and enable speed control
	ERROR	8$			;its wrong...but I'm in a hurry
	MOVE.W  #$8002,$9A(A4)		;enable disk comp ints
	MOVE.B	Select(A3),D0
	OR.B	#CA2,D0			;read lower head
	BTST	#Mac_Side,MacFlags(A3)	;which head?
	BEQ.S	3$			;lower
	OR.B	#SEL,D0			;else force upper head
3$:	MOVE.B	D0,CIAB			;select head
	MOVE.W  D2,$24(A4)		;start the transfer
	MOVE.W  D2,$24(A4)
	BSR	WaitForSignal		;else wait for block completion signal
	BSR	SpeedControlOff
	MOVE.W  #2,$9A(A4)		;clear disk block int enable
	MOVE.W  #$4000,$24(A4)		;stop DMA
	ZAP	D2			;error=none
	BSR	DriveReady		;disk still loaded?
	NOERROR	9$			;yes

8$:	MOVEQ   #TDERR_DiskChanged,D2	;else error=no disk loaded

9$:	MOVE.L  D2,D0			;return error code
	POP	D2-D3/A2/A4
	RTS

* Buffer to write from in A0, byte count in D0.

WriteTrack:
	PUSH	D2-D3/A2/A4
	MOVE.L	A0,A2			;buffer to A2
	LEA     HdwRegsBase,A4		;hardware base reg
	LSR.W   #1,D0			;divide byte count
	ORI.W   #$C000,D0		;or in DMA and write bits
	MOVE.L  D0,D2			;byte count to D2

	MOVE.W  #$4000,$DFF024		;turn off DMA
	MOVE.L  #1000,D0
	BSR	TimeDelay		;wait 1ms

	BSR	DriveReady		;disk loaded?
	ERROR	7$,L			;no
	BSR	CheckProtection		;write protected?
	ERROR	8$,L			;yes
	MOVE.L  A2,$20(A4)		;set DMA address
	MOVE.W  #$1002,$9C(A4)		;clear pending disk comp ints
	IFZB	DiskType(A3),1$		;ADOS format...mfm, no sync
	MOVE.W	#$7500,$9E(A4)		;
	MOVE.W	#$8100,$9E(A4)		;500khz clock
	BRA.S	2$
1$:	MOVE.W  #$600,$9E(A4)		;clear wordsync and msbsync
	MOVE.W  #$9100,$9E(A4)		;enable mfm precomp and 500khz clock

2$:	MOVE.W  #$6000,$9E(A4)		;clear precomp bits
	MOVE.W  CurTrk(A3),D0		;get the track for this write
	MOVE.W  #$8000,D1		;set initial precomp param
	CMP.W   #80,D0			;is range for precomp 0?
	BLS.S   3$			;yes
	MOVE.W  #$A000,D1		;else switch to precomp 1
3$:	MOVE.W  D1,$9E(A4)		;issue proper precomp command
	BSET    #5,mf_Flags(A6)		;else show write on-going
	MOVE.B	#OneShot,TimerMode	;force one-shot mode
	MOVE.L	#500000,D0
	BSR	SpeedControlOn		;check and enable speed control
	ERROR	7$			;its wrong...but I'm in a hurry
	MOVE.W  #$8002,$9A(A4)		;enable disk comp ints
	MOVE.B	Select(A3),D0
	OR.B	#CA2,D0			;read lower head
	BTST	#Mac_Side,MacFlags(A3)	;which head?
	BEQ.S	4$			;lower
	OR.B	#SEL,D0			;else force upper head
4$:	MOVE.B	D0,CIAB			;select head
	MOVE.W  D2,$24(A4)		;start the transfer
	MOVE.W  D2,$24(A4)
	BSR	WaitForSignal		;else wait for block completion signal
	BSR	SpeedControlOff
	MOVE.W  #2,$9A(A4)		;clear disk block int enable bit
	MOVE.W  #$4000,$24(A4)		;stop DMA
	MOVE.L  #2000,D0		;wait 2ms - is this really necessary?
	BSR	TimeDelay
	BCLR    #5,mf_Flags(A6)		;clear 'write ongoing' bit
	ZAP	D2			;else good completion
	BSR	DriveReady		;disk still loaded?
	NOERROR	9$			;yes

7$:	MOVEQ   #TDERR_DiskChanged,D2	;else error=no disk loaded
	BRA	9$

8$:	MOVEQ   #TDERR_WriteProt,D2	;disk write protected

9$:	MOVE.L  D2,D0			;completion code to D0
	POP	D2-D3/A2/A4
	RTS

* CiaB timer B is used to toggle the motor speed bit.  The timer is allocated
* at device open, and the interrupt set up later when the drive is determined
* to be a speed-control drive.  Time values are selected from the unit table
* for the disk band in use, and the timer produces an variable duty cycle to 
* control the drive speed for that band.  The timer runs in one-shot mode, 
* with the ISR loading the next time value from the unit table.

AllocTimerB:
;	BTST	#Mac_TimerB,MacFlags(A3) ;already own Timer B?
;	BNE.S	2$			;yes
	MOVEQ	#TBICRB,D0		;Timer B interrupt bit
	LEA	SpeedIntB(A3),A1	;ptr to interrupt structure
	MOVE.L	A6,-(A7)
	MOVE.L	mf_CiaBBase(A6),A6
	JSR	AddICRVector(A6)
	IFNZL	D0,8$
	AND.B	#$F6,TBCR		;disable the timer
	MOVEQ	#TBICRF,D0
	JSR	AbleICR(A6)
	BSET	#Mac_TimerB,MacFlags(A3) ;we own timer B now
	BRA.S	9$
8$:	STC
9$:	MOVE.L	(A7)+,A6
	RTS

* Releases Timer B interrupt vector on program termination.

FreeTimer:
	BCLR	#Mac_TimerB,MacFlags(A3)	;don't own timer now
	BEQ.S	1$			;never did!
	MOVEQ	#TBICRB,D0		;Timer B interrupt bit
	LEA	SpeedIntB(A3),A1	;ptr to interrupt structure
	MOVE.L	A6,-(A7)
	MOVE.L	mf_CiaBBase(A6),A6
	JSR	RemICRVector(A6)
	MOVE.L	(A7)+,A6
1$:	RTS

* Checks type of drive and turns on speed control interrupts, if needed.
* Also waits for drive to get to right speed.  Delay value in D0 (shorter
* for read, since speed tolerance is much greater for reading.)

SpeedControlOn:
	LEA	CIAB,A0
	MOVE.B	Select(A3),(A0)
	OR.B	#CA0!CA1!SEL,(A0)
	BTST	#Mac_Speed,MacFlags(A3)	;speed control?
	BNE.S	1$			;yes...do it
	RTS				;else get out now
1$:	PUSH	D0/D2/A6		;save timeout value
	BSR	AllocTimerB		;get the timer
	NOERROR	2$			;got it
	POP	D0/D2/A6
	RTS
2$:	LEA	CIAB,A0
	MOVE.B	Select(A3),D0		;prepare to enable speed control
	MOVE.B	LSTRB(A3),D2
	MOVE.B	D0,(A0)
	OR.B	#CA0!CA1!CA2!SEL,(A0)	;enable speed control
	MOVE.B	D0,(A0)
	BSET	D2,(A0)			;keep speed low
	OR.B	#CA0!CA1!SEL,(A0)
	MOVE.L	mf_CiaBBase(A6),A6
	AND.B	#$C0,TBCR		;clear run and mode bits
	MOVEQ	#TBICRF,D0		;clear any pending Timer B int
	JSR	AbleICR(A6)
	MOVE.W	OnDuty(A3),D0
;	MOVE.W	D0,LastCount
	MOVE.B	D0,TBLO
	LSR.W	#8,D0
	MOVE.B	D0,TBHI
	MOVE.B	#$80!TBICRF,D0
	JSR	AbleICR(A6)
	Disable
	MOVE.B	TimerMode,D0
	OR.B	D0,TBCR			;one-shot, force load
	OR.B	#1,TBCR			;start the timer
	BCLR	D2,(A0)
	Enable
9$:	POP	D0/D2/A6
	IFZL	D0,10$
	BSR	TimeDelay		;wait for drive to reach speed
	CLC
10$:	RTS

* Checks type of drive and turns off speed control interrupts, if needed.

SpeedControlOff:
	BTST	#Mac_Speed,MacFlags(A3)	;speed control?
	BEQ.S	1$			;no
	Disable				;stop the clock
	AND.B	#$C0,TBCR		;else stop the timer
	MOVEQ	#TBICRF,D0		;clear any pending Timer B int
	MOVE.L	A6,-(A7)
	MOVE.L	mf_CiaBBase(A6),A6
	JSR	AbleICR(A6)
	MOVE.L	(A7)+,A6
	LEA	CIAB,A0
	MOVE.B	Select(A3),D0		;force select to 0
	MOVE.B	D0,(A0)
	OR.B	#CA0!CA1!CA2!SEL,(A0)	;disable speed control
	MOVE.B	D0,(A0)
	OR.B	#SEL,(A0)		;leave in disk installed
	MOVE.B	LSTRB(A3),D0
	BSET	D0,(A0)			;leave in slow mode
	Enable
	BSR	FreeTimer
1$:	RTS

* Timer B motor change interrupt service routines.
* Watch out--these are "for real" ISRs.
* On entrance, A1=unit table, A6=SysBase.
* Can only use normal scratch regs here...

* This ISR is used only during the initial speed calculations following
* a disk change.  For this test, TimerB runs continuously, reloading the 
* previous value.  The idea is to measure average interrupt latency, so
* that the tick count for normal speed control can be adjusted.

MotorChangeA:
	INCL	COUNT
	MOVE.B	TBHI,D1
	LSL.W	#8,D1
	MOVE.B	TBLO,D1
	MOVE.W	#TimeVal,D0		;this is actual count
	SUB.W	D1,D0			;calc latency
	BMI.S	3$			;negative latency...don't use it
;	ADD.W	Latency,D0
;	LSR.W	#1,D0			;divide for simple average
	EXT.L	D0
	ADD.L	D0,Latency
3$:	RTS

* This is the normal speed control ISR.  Here TimerB runs in one-shot mode,
* and the tick count reloaded depends upon the desired rotational speed.
* The timer restarts automatically when the high byte is loaded.

MotorChangeB:
	MOVE.B	LSTRB(A1),D1
	BCHG	D1,CIAB			;reverse the state of the motor
	BNE.S	1$
	MOVE.B	OffDuty+1(A1),TBLO
	MOVE.B	OffDuty(A1),TBHI
;;	OR.B	#$10,TBCR		;force load
	RTS
1$:	MOVE.B	OnDuty+1(A1),TBLO
	MOVE.B	OnDuty(A1),TBHI
;;	OR.B	#$10,TBCR		;force load
	RTS

* Sets speed control duty cycle counts and track read lengths based
* on track number and disk format (ADOS/Mac).
* Also checks drive for speed control and measures drive speed.  Returns
* D0<>0 if drive needs speed control and timer B not available.

SetTrkParams:
	BTST	#Mac_Speed,MacFlags(A3)	;speed control?
	BEQ.S	3$			;no
	IFNZW	MacTable(A3),3$		;don't need to measure drive speed
	BSR	MeasureSpeed
;	IFZL	D0,3$			;good return
;	DispErr	Timer.			;oops...timer B not available
;	MOVEQ	#-1,D0			;show error
;	BRA	9$
3$:	ZAP	D0
	MOVE.W	CurTrk(A3),D0		;Mac params based on track
	LSR.W	#5,D0			;calc band (track is doubled)
	MOVE.L	D0,D1
	LSL.L	#2,D1			;index band table by 4 (2 words)
	LEA	MacTable(A3),A0
	LEA	MacLengthTable,A1	;index length table by long
	ADD.L	D1,A0
	ADD.L	D1,A1
2$:	MOVE.W	OnCount(A0),OnDuty(A3)	;get proper duty cycle
	MOVE.W	OffCount(A0),OffDuty(A3)
	MOVE.L	(A1)+,ReadLength(A3)
9$:	RTS

* Measures speed of Mac drive and stores speed params in MacTable.
* Returns D0<>0 if speed control needed but timer B is not available.

MeasureSpeed:
	PUSH	D2-D7
	BSET	#Mac_Speed,MacFlags(A3)	;assume local speed control
	MOVE.W	#TimeVal,D0		;0.5 ms in TimerB ticks
	MOVE.W	D0,OnDuty(A3)
	MOVE.W	D0,OffDuty(A3)
	LEA	MotorChangeA,A0		;set up interrupt vector
	MOVE.L	A0,SpeedIntB+IS_CODE(A3)
	MOVE.B	#ContMode,TimerMode	;continuous mode for latency check
	ZAP	D0
	BSR	SpeedControlOn		;enable speed control
	NOERROR	3$			;got timer
	DispErr	Timer.			;else let op know about trouble
	BRA	4$			;this will result in read error
3$:	LEA	CIAB,A0
	MOVE.B	LSTRB(A3),D2		;LSTRB
	BSET	D2,(A0)			;set slowest speed
	BSR	WaitaBit		;wait for drive to slow down
	BSR	MeasureRPM		;measure 1 rev at lowest speed
	MOVE.L	D0,D3			;save slowest rev ticks
	BCLR	D2,CIAB			;set fastest rpm
	BSR	WaitaBit		;wait for drive to speed up
	BSR	MeasureRPM		;measure 1 rev at fastest speed
	MOVE.L	D0,D4			;save fastest rev ticks
	BSR	SpeedControlOff		;turn off speed control for now
	LEA	MotorChangeB,A0
	MOVE.L	A0,SpeedIntB+IS_CODE(A3)
	MOVE.L	#RPMconstant,D0		;converts MS to RPM
	MOVE.L	D0,D1
	EXG	D0,D4
	DIVU	D0,D4			;calc high speed rpm
	EXG	D1,D3
	DIVU	D1,D3			;calc low speed rpm
	MOVE.W	D4,D0
	SUB.W	D3,D0			;check for difference in speeds
	AND.W	#$FFF8,D0		;ignore minor speed difference
	BNE.S	1$			;drive is responding to speed control
4$:	BCLR	#Mac_Speed,MacFlags(A3)	;else drive sets its own speed
	BRA.S	9$
1$:	LEA	RPMTable,A1		;table of desired band rpms
	LEA	MacTable(A3),A0		;point to MAC speed table
	MOVEQ	#4,D7			;5 mac bands
	SUB.W	D3,D4			;High rpm - Low rpm
	MOVE.W	#PulseWidth,D6		;depends on speed control technique
	MOVE.L	Latency,D2
	MOVE.L	COUNT,D0
	DIVU	D0,D2			;calc average latency
2$:	MOVE.W	(A1)+,D0		;desired rpm for this band
	SUB.W	D3,D0			;(desired rpm) - (drive low rpm)
	MULU	D6,D0			;multiply by full pulse width
	DIVU	D4,D0			;get ON count
	MOVE.W	D0,D1
	SUB.W	D2,D1			;adjust for latency
	MOVE.W	D1,(A0)+		;store it
	NEG.W	D0			;OFF count=(pulse width)-ON count
	ADD.W	D6,D0
	MOVE.W	D0,D1
	SUB.W	D2,D1			;adjust for latency
	MOVE.W	D1,(A0)+		;store OFF count
	DBF	D7,2$			;loop for all bands
9$:	POP	D2-D7
	RTS

* Measures number of TimerB ticks in two revolutions of the disk.
* Timer is set for 1.0 ms ticks.  Drive generates 60 pulses per
* revolution.  Returns count of ticks in D0.
* Extensive changes made 2/13/90

MeasureRPM:
	PUSH	D2-D3
	LINKSYS	Forbid,mf_SysBase(A6)
	LEA	CIAA,A0
	MOVE.W	#239,D1		;2 rev = 120 pulses = 240 transitions
	MOVEQ	#$20,D2
	MOVE.B	(A0),D0
	AND.W	D2,D0		;get initial drive pulse state 
	MOVE.B	D0,D3		;save initial state
1$:	MOVE.B	(A0),D0
	AND.W	D2,D0
	CMP.B	D0,D3		;state change?
	BEQ.S	1$		;no...loop till initial state changes
	CLR.L	COUNT		;yes...clear tick count
	CLR.L	Latency
2$:	MOVE.B	(A0),D0		;wait for state change
	AND.W	D2,D0
	CMP.B	D0,D3		;state change?
	BEQ.S	2$		;no change...loop
	MOVE.B	D0,D3		;found a change...save new state
	DBF	D1,2$		;count the change and loop
	MOVE.L	COUNT,D0	;return tick count
	LINKSYS	Permit,mf_SysBase(A6)
	POP	D2-D3
	RTS

WaitaBit:
;;	MOVE.L	#300000,D0	;wait for drive to reach proper speed
	MOVE.L	#600000,D0	;wait for drive to reach proper speed
	BSR	TimeDelay
	RTS

* Called on disk change to clear the Mac speed table.  This forces the
* speed of the drive to be remeasured with the new diskette.

ZapSpeedTable:
	LEA	MacTable(A3),A0
	MOVEQ	#9,D1		;5 Mac bands, 2 words each
	ZAP	D0
1$:	MOVE.W	D0,(A0)+
	DBF	D1,1$
	RTS

* This routine requests exclusive use of the disk hardware, and waits
* until we can have it.

BusyDrives:
;	BSET	#Mac_Busy,MacFlags(A3)	;already own hardware?
;	BNE.S	9$			;yes...dont try again
	PUSH	A2/A4
	IFNZB	BusyCount,9$
	MOVE.L	A6,A2
	MOVE.L	mf_SysBase(A2),A4
	MOVE.L	mf_DRBase(A2),A6
1$:	LEA     PrivateMsg(A3),A1	;utility msg
	JSR	DR_GETUNIT(A6)		;try to seize the hardware
	IFNZL	D0,3$			;got the unit
	EXG     A4,A6			;else wait till we get it
2$:	MOVE.L  #$400,D0		;signal bits for wait
	CALLSYS	Wait
	LEA     PrivatePort(A3),A0	;get msg at private port
	CALLSYS	GetMsg
	IFZL	D0,2$			;no msg...loop
	EXG     A4,A6
	BRA.S   1$

* If we get here, we have private use of the disk controller 

3$:	EXG     A2,A6
	LEA	CIAB,A0
	MOVE.B	#Deselect,(A0)		;deselect all drives, condition for select
	MOVE.B  Select(A3),(A0)		;select Mac drive with no other bits
9$:	INCB	BusyCount
	POP	A2/A4
	RTS

* This routine releases our exclusive hold on the disk hardware. 

FreeDrives:
;	BCLR	#Mac_Busy,MacFlags(A3)	;still own hardware?
;	BEQ.S	9$			;no...dont need to release
	IFZB	BusyCount,9$
	DECB	BusyCount
	BNE.S	9$
	LEA	CIAB,A0
	MOVE.B	Select(A3),(A0)
	OR.B	#CA0!CA1!CA2!SEL,(A0)	;force motor control
	MOVE.B	LSTRB(A3),D0
	BSET	D0,(A0)			;this deselects all
	MOVE.B	#$FF,(A0)
	MOVE.L  A6,-(A7)
	MOVE.L	mf_DRBase(A6),A6
	JSR	DR_GIVEUNIT(A6)
	MOVE.L	(A7)+,A6
9$:	BCLR	#Mac_Motor,MacFlags(A3)	;assume motor goes off on deselect
	RTS

* Mac table of read/write byte counts by band
* read length=768*secs+TrackGap, write length=768*secs+TrackGap

*		read,write
MacLengthTable
	DC.L	10872,10872		;9984
	DC.L	10104,10104		;9216
	DC.L	09336,09336		;8448
	DC.L	08568,08568		;7680
	DC.L	07800,07800		;6912

* Table of desired track rpm by band.  Last entry is for ADOS.
* This data measured from a Mac drive.

RPMTable
	DC.W	394,433,476,522,590

Timer.	TEXTZ	<'Timer B already in use.'>

COUNT		DC.L	0		;0.5 ms tick counter
Latency		DC.L	0		;int latency in timerB ticks
BusyCount	DC.B	0		;hardware usage count
TimerMode	DC.B	0		;TimerB mode

	END
