* SimpleAudio.i
*
* © 1998 Blasio Muscat
*

	incdir	"include:"

	IFND	exec_exec_lib.i
	include	exec/exec_lib.i
	ENDC

	IFND	exec_exec.i
	include	exec/exec.i
	ENDC

	IFND	exec_ports.i
	include	exec/ports.i
	ENDC

	IFND	exec_initializers.i
	include	exec/initializers.i
	ENDC

	IFND	exec_nodes.i
	include	exec/nodes.i
	ENDC

	IFND	exec_io.i
	include	exec/io.i
	ENDC

	IFND	devices_audio.i
	include	devices/audio.i
	ENDC



	Bra.w	End_SimpleAudio

UNSTOPPABLE  equ	127
EMERGENCIES  equ	 95
ATTENTION    equ	 85
SPEECH       equ	 75
INFORMATION  equ	 60
MUSIC        equ	  0
EFFECT       equ	-35
BACKGROUND   equ	-90
SILENCE      equ -128


NTSC_CLOCK    equ	3579545 * American Amigas - 60Hz
PAL_CLOCK     equ	3546895 * European Amigas - 50Hz 

CLOCK = PAL_CLOCK	; Change according to where you are located


; ********* Flags

LEFT1	EQU	$1
RIGHT1	EQU	$2
RIGHT2	EQU	$4
LEFT2	EQU	$8

PERIOD	EQU	$10
WAIT	EQU	$20



ALLOCAUDIO	MACRO	
	movem.l	d2-d7/a0-a6,-(a7)
	move.l	\1,d0			; Channel (L1/L2/R1/R2)
	move.l	\2,d1			; Pri	  (MUSIC/FX/EMERGENCY)
	jsr	AllocAudio
	movem.l	(a7)+,d2-d7/a0-a6
	ENDM

PLAY	MACRO
	movem.l	d1-d7/a0-a6,-(a7)
	move.l	\1,a0			; Pointer to Sample
	move.l	\2,d0			; Lenght of Sample
	move.l	\3,d1			; Frequency / Period
	move.l	\4,d2			; Volume
	move.l	\5,d3			; Channel + Period/Freq (Flags)
	move.l	\6,d4			; No of Times to Play
	jsr	Play
	movem.l	(a7)+,d1-d7/a0-a6
	ENDM

DEALLOCAUDIO	MACRO
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	DeAllocAudio
	movem.l	(a7)+,d0-d7/a0-a6
	ENDM




AllocAudio:
; d0 Channels
; d1 Priority

	lea	AuReq,a1
	move.b	d1,LN_PRI(a1)
	move.b	d0,AuChannels

	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,_AuReplyPort

	lea	AuReq,a1
	move.l	_AuReplyPort,MN_REPLYPORT(a1)

	clr.w	ioa_AllocKey(a1)
	move.l	#AuChannels,ioa_Data(a1)
	move.l	#1,ioa_Length(a1)

	move.l	#AuDevice,a0
	clr.l	d0
	clr.l	d1
	move.l	4.w,a6
	jsr	_LVOOpenDevice(a6)

	move.l	#AuReq,a1
	move.l	IO_UNIT(a1),AuUnit

; Returns 0 if OK or else an error code

	rts


Play:
; a0	pointer to sample
; d0	lenght of sample (will be turned into even if necessary)
; d1	Frequency or Period
; d2	Volume
; d3	Flags (Select Channel, Freq/Period, Wait/DONOTWAIT)
; d4	No of times to play

; This routine only accepts 1 Sample at a time.

	lea	AuReq,a1
	move.b	#ADIOF_PERVOL,IO_FLAGS(a1)
	move.l	a0,ioa_Data(a1)
	bclr.l	#0,d0		; if it is odd make it even
	move.l	d0,ioa_Length(a1)
	
	move.l	d3,d7	; Copy of Flags
	andi.l	#PERIOD,d7
	tst.l	d7
	bne	Period_Play

	move.l	#CLOCK,d6
	divs	d1,d6
	
	
	move.l	d6,d1
Period_Play	move.w	d1,ioa_Period(a1)
	move.w	d2,ioa_Volume(a1)
	
	tst.l	d4
	bne.s	Cont_Play
	moveq.l	#1,d4

Cont_Play	move.w	d4,ioa_Cycles(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)

	move.l	d3,d7
	andi.l	#$F,d7
	move.l	d7,IO_UNIT(a1)

	BEGINIO

	btst.l	#5,d3
	beq.s	Exit_Play

	move.l	4.w,a6
	lea	AuReq,a1
	jsr	_LVOWaitIO(a6)

Exit_Play:	
	rts	

	
DeAllocAudio:	lea	AuReq,a1
	move.l	AuUnit,IO_UNIT(a1)
	move.w	#ADCMD_FREE,IO_COMMAND(a1)
	move.l	4.w,a6
	jsr	_LVODoIO(a6)

DeAllocLoop:	move.l	_AuReplyPort,a0
	move.l	4.w,a6
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	bne.s	DeAllocLoop

	move.l	_AuReplyPort,a0
	move.l	4.w,a6
	jsr	_LVODeleteMsgPort(a6)

	move.l	#AuReq,a1
	move.l	4.w,a6
	jsr	_LVOCloseDevice(a6)

	rts

AuDevice	dc.b	'audio.device',0

AuReq	ds.l	ioa_SIZEOF

_AuReplyPort	dc.l	0

AuChannels	dc.b	0

AuUnit	dc.l	0


End_SimpleAudio
