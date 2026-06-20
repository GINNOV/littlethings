		*****************************************
		*					*
		*		SpeedTest.s		*
		*     $VER: SpeedTest 1.3 (9.10.97)	*
		*     © 1997 Didier "kakace" Levet	*
		*					*
		*****************************************

	include speedtest.i
	OUTPUT RAM:SpeedTest

;#########################################################################
; This little tool can be used to get a very accurate result of execution
; timings for both 68040 and 68060. It should be usefull to help you to
; optimize your code, and to get full advantage of caches and pipelines.
;
; USE IT AT YOUR OWN RISK !!
;
; Support : kakace@aix.pacwan.net
;#########################################################################

; User setup.

	MACHINE MC68040

	TEST_CPU:	EQU	68060		;( or 68040).
	MEGAHERTZ:	EQU	50

	LOOPCNT:	EQU	5000


*======================================================================

	STARTUP			; Preserve ALL registers.

;--------------------------------------------
; Insert your init code here.
; You can use SYSBase and DOSBase to fetch libraries base address.
; You can trash ALL registers.
;--------------------------------------------

	* Call your test loop(s) from here. All registers are preserved
	* so you can use their values in your test loop.

	bsr	Test_1
	bsr	Test_2

;--------------------------------------
; Cleanup and exit.
; Since CLEANUP macro includes a RTS, you may prefer to use "bsr __cleanup"
; instead (and place the CLEANUP macro elsewhere).
;--------------------------------------

	CLEANUP			; Preserve ALL registers.

*======================================================================

Test_1
	;------------------------------------------------------------------------------
	; Test start.
	;  BEGIN  LoopCnt,MICROHZ/S
	;
	; LoopCnt : Loop counter.
	; MICROHZ : Use it when you want to get a more accurate timing. (Results are
	;	    given in µs and cycles). YOUR TEST LOOP MUST NOT BE LONGER THAN
	;	    ABOUT 90 ms OR YOU MAY CRASH YOUR MACHINE !
	;------------------------------------------------------------------------------

	BEGIN	LOOPCNT,MICROHZ	; Preserve ALL registers.
	
	; Init code.

	** Insert your loop's init code here when it is required.

	lea	src,a0
	move.l	(a0),d0		; Fill the data cache line.

	; You can replace LOOP by READCNT to ignore your init code execution time. 
	; (only when using MICROHZ test mode).

	;LOOP
	READCNT

	** Insert your test code here.

	move16	(a0),dest

	;---------------------------
	; Loop end.
	;  BEND  "FuncName"
	;---------------------------

	BEND	<"MOVE16 (cache hit)">		; Preserve ALL registers.


Test_2
	BEGIN LOOPCNT,MICROHZ
	
	lea	src,a0
	
	READCNT

	move16	(a0),dest

	BEND	<"MOVE16 (cache miss)">


	CNOP 0,8

src	dcb.l	16
dest	dcb.l	16
