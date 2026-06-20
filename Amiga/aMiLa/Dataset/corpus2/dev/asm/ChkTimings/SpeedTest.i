		*****************************************
		*					*
		*		SpeedTest.i		*
		*     $VER: SpeedTest 1.3 (9.10.97)	*
		*     © 1997 Didier "kakace" Levet	*
		*					*
		*****************************************


;#########################################################################
; This little tool can be used to get a very accurate result of execution
; timings for both 68040 and 68060. It should be usefull to help you to
; optimize your code, and to get full advantage of caches and pipelines.
;
; USE IT AT YOUR OWN RISK !!
;
; Support : kakace@aix.pacwan.net
;#########################################################################


*------------------------------------------------------------------------------

	INCDIR CD0:NDK_3.1/Includes&Libs/Include_i/

	INCLUDE	Exec/Devices.i
	INCLUDE	Exec/Macros.i
	INCLUDE	Exec/Ables.i
	INCLUDE	Hardware/DMABits.i
	INCLUDE	Hardware/Custom.i
	INCLUDE	Hardware/Cia.i
	INCLUDE	Devices/Timer.i

_LVOOpenLibrary             	EQU	-552
_LVOCloseLibrary            	EQU	-414
_LVOOpenDevice              	EQU	-444
_LVOCloseDevice             	EQU	-450
_LVOCreateIORequest         	EQU	-654
_LVODeleteIORequest         	EQU	-660
_LVOCreateMsgPort           	EQU	-666
_LVODeleteMsgPort           	EQU	-672
_LVOPermit                  	EQU	-138
_LVOCacheClearU             	EQU	-636
	
_LVOVPrintf                 	EQU	-954

_LVOReadEClock			EQU	-60

	_intena: EQU 	$DFF000+intena

	DMACONR: EQU	$DFF000+dmaconr
	DMACON:	 EQU	$DFF000+dmacon
	CIACNT:	 EQU	$BFE001+ciatblo


	__testloop:	SET	 0
	__060OverHead:	EQU	 5		;  5 cycles overhead for 060 MICROHERTZ test loop.
	__040OverHead:	EQU	11		; 11  cycles overhead for 040 MICROHERTZ test loop.


*========== Init macro.

STARTUP	MACRO
		movem.l	d0-d7/a0-a7,__regsbackup

		movea.l	4.w,a6
		move.l	a6,SYSBase

		move.l	ex_EClockFrequency(a6),EClockFreq

		lea	_DOSName,a1
		moveq	#37,d0
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,DOSBase
		beq.l	st_NoDOS

		jsr	_LVOCreateMsgPort(a6)
		move.l	d0,MsgPort
		beq.l	st_CloseDOS

		movea.l	d0,a0
		moveq	#IOTV_SIZE,d0
		jsr	_LVOCreateIORequest(a6)
		move.l	d0,TimeRequest
		beq.l	st_FreeMsgPort

		lea	_TimerName,a0
		moveq	#UNIT_MICROHZ,d0
		movea.l	TimeRequest,a1
		clr.l	d1
		jsr	_LVOOpenDevice(a6)
		tst.l	d0
		bne.l	st_FreeTimeRequest

		movem.l	__regsbackup,d0-d7/a0-a7	; Restore all registers.
	ENDM


*========== Exit Macro.

CLEANUP	MACRO
__cleanup
st_CloseDevice 	movem.l	d0-d7/a0-a7,__regsbackup
		movea.l	SYSBase(pc),a6
		movea.l	TimeRequest(pc),a1
		jsr	_LVOCloseDevice(a6)

st_FreeTimeRequest	
		movea.l	TimeRequest(pc),a0
		jsr	_LVODeleteIORequest(a6)

st_FreeMsgPort 	movea.l	MsgPort(pc),a0
		jsr	_LVODeleteMsgPort(a6)

st_CloseDOS	movea.l	DOSBase(pc),a1
		jsr	_LVOCloseLibrary(a6)

st_NoDOS	moveq	#0,d0
		movem.l	__regsbackup,d0-d7/a0-a7
		rts

; a0 = Pointer to function name
; d0 = Loop count.

	;------ Display the result (µs).

PrintResult_1	movea.l	d0,a1
		move.l	EClock(pc),d0
		sub.l	Result(pc),d0		; = ticks.
		bcc.s	.ok

		add.l	#65536,d0

.ok		move.l	EClockFreq(pc),d2

		mulu.l	#1000000,d1:d0
		divu.l	d2,d1:d0

		move.l	d0,d1
		move.l	a1,d2			; Loop count.
		move.l	a1,d4
		mulu.l	#MEGAHERTZ,d1
		divu.l	d2,d1			; # cycles.

   IFNE TEST_CPU=68060
		moveq	#__060OverHead,d3
   ENDC
   IFNE TEST_CPU=68040
		moveq	#__040OverHead,d3
   ENDC

		sub.l	d3,d1			; Substract overhead time.
		mulu.l	d4,d4:d3
		divu.l	#MEGAHERTZ,d4:d3
		sub.l	d3,d0			; Substract overhead time from loop timing.

		movea.l	DOSBase(pc),a6
		move.l	d1,-(sp)
		move.l	d0,-(sp)		; µs
		pea	(a1)
		pea	(a0)			; Function name
		move.l	sp,d2
		lea	info2(pc),a0
		move.l	a0,d1
		jsr	_LVOVPrintf(a6)
		movem.l	__regsbackup,d0-d7/a0-a7
		rts


	;------ Return the result (seconds).

PrintResult_2	move.l	d0,a1
		move.l	Result+4(pc),d1
		move.l	EClock+4(pc),d0
		sub.l	d0,d1			; Elapsed time.
		bcc.s	.ok

		neg.l	d1

.ok		move.l	EClockFreq(pc),d3	; Frequency.

		divul.l	d3,d0:d1		; seconds.
		mulu.l	#2000,d0
		add.l	d3,d0			; Round the last digit
		lsr.l	#1,d0
		divul.l	d3,d2:d0		; 1/1000 s.

		movea.l	DOSBase(pc),a6		; DOSBase
		move.l	d0,-(sp)		; 1/1000 s.
		move.l	d1,-(sp)		; seconds.
		pea	(a1)			; # loops
		pea	(a0)			; Function name.
		move.l	sp,d2
		lea	info(pc),a0
		move.l	a0,d1
		jsr	_LVOVPrintf(a6)
		movem.l	__regsbackup,d0-d7/a0-a7
		rts

	CNOP 0,4

	SYSBase:	dc.l	0
	DOSBase:	dc.l	0
	MsgPort:	dc.l	0
	TimeRequest:	dc.l	0
	LoopCnt:	dc.l	0
	EClockFreq:	dc.l	0
	DMAReg:		dc.w	0

_DOSName   dc.b "dos.library",0
_TimerName dc.b "timer.device",0

	CNOP 0,8

__regsbackup	dcb.l	16

	EClock:	dc.l	0
		dc.l	0
	
	Result:	dc.l	0
		dc.l	0

	info:	dc.b	"%s (%ld loops) = %ld.%03ld s",$0A,$0D,0
	info2:	dc.b	"%s (%ld loops) = %ld µs  (%ld cycles)",$0A,$0D,0

	CNOP 0,8

	ENDM


*========== Loop start.

LOOP	MACRO
	nop				; Synchronize all CPU's units.
	__testloopaddr\<__testloop>:	SET	*

	swap	d0			; Ensure that the first instruction of the tested
	swap	d0			; code will not be dispatched.
	ENDM


*========== Init before each test loop.

BEGIN	MACRO				; LoopCnt,MICROHZ/S

	__testloop:	SET	__testloop+1
	__currloopcnt:	SET 0
	__microhz:	SET 0

	IFC	'MICROHZ','\1'
	  __microhz: SET 1
	ELSE
	 IFNE	\1
	  move.l #\1,LoopCnt		; Setup the loop counter.
	  __currloopcnt: SET \1
	 ENDC
	ENDC

	IFC	'MICROHZ','\2'
	  __microhz: SET 1
	ENDC

	movem.l	d0-d7/a0-a7,__regsbackup
	movea.l	SYSBase,a6

	jsr	_LVOCacheClearU(a6)	; Flush data in instruction caches.

	IFNE __microhz			; DISABLE
	  move.w DMACONR,d0
	  or.w   #DMAF_SETCLR,d0
	  move.w d0,DMAReg
	  move.w #$7FFF,DMACON		; Disable DMA (MICROHZ ON)
	  DISABLE
	ELSE
	  FORBID			; Disable taskswitching (MICROHZ OFF)
	ENDC

	IFNE __microhz
	  clr.l   EClock		; Precharge the data cache.
	  clr.l   Result
	  move.b  CIACNT,EClock+3
	  move.b  CIACNT+$100,EClock+2
	ELSE
	  movea.l TimeRequest,a0
	  movea.l IO_DEVICE(a0),a6	; Device lib base.
	  lea	  EClock,a0
	  jsr	  _LVOReadEClock(a6)
	ENDC

	movem.l	__regsbackup,d0-d7/a0-a7

	LOOP
	ENDM


*========== Loop end.

BEND	MACRO				; FuncName/A

	IFNE __currloopcnt
	  swap d0			; Ensure that the next instruction
	  swap d0			; will not be dispatched.

	  subq.l #1,LoopCnt
	  bne.l	 __testloopaddr\<__testloop>
	ENDC

	movem.l	d0-d7/a0-a7,__regsbackup

	IFNE __microhz
	  move.b  CIACNT,d0
	  move.b  CIACNT+$100,d1
	  lsl.w   #8,d1
	  move.b  d0,d1
	  addq.w  #2,d1			; 3 ticks spend while reading the CIA timer.
	  move.w  d1,Result+2
	ELSE
	  movea.l TimeRequest,a0
	  movea.l IO_DEVICE(a0),a6	; Device lib base.
	  lea	  Result,a0
	  jsr	  _LVOReadEClock(a6)
	ENDC

	movea.l	SYSBase,a6

	IFNE	__microhz
	  ENABLE
	  move.w DMAReg,DMACON
	ELSE
	  PERMIT
	ENDC

	lea	func_\@(pc),a0
	move.l	#__currloopcnt,d0

	IFNE __microhz
	  bra.l	PrintResult_1
	ELSE
	  bra.l	PrintResult_2
	ENDC

func_\@	dc.b	\1,0

	CNOP 0,8
	ENDM


*========== Read the counter just before entering the loop (MICROHZ mode only).

READCNT	MACRO				; Fetch actual counter.
	IFEQ __microhz
	 FAIL	ERROR : READCNT should be used in MICROHZ mode only !
	 MEXIT
	ENDC
	  move.b  CIACNT,EClock+3
	  move.b  CIACNT+$100,EClock+2

	  LOOP
	ENDM
