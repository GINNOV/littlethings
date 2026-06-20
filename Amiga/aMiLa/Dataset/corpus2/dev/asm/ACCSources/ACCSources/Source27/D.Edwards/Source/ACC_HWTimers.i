

* ACC Hardware Timer Management Include File
* Version 1.0 By Dave Edwards
* This source is Public Domain and FreeWare!



* NOTES ABOUT TIMERS!

* CIA-A Timer A can't be used as a free timer, because it's used to
* synchronise the keyboard! DON'T alter CIA-A control registers
* UNLESS you know what you're doing!



* Using the timer code:

* VERY IMPORTANT:FIRST SAVE THE CURRENT STATE OF THE CIA-B CONTROL
* REGISTERS BEFORE CALLING THIS CODE, AND RESTORE THEM AFTERWARDS!



* To find out how many E clock pulses elapses during a given piece
* of code:do the following:


* 1) MOVEQ #-1,D0 followed by BSR SetTimer

* 2) BSR TimerOn to start the timer

* 3) Code to be timed follows immediately

* 4) At end of code, do BSR TimerOff

* 5) Then do BSR CompTime. D0 contains elapsed time in
*	terms of E clock pulses. Multiply by 10 to
*	obtain the number of machine cycles elapsed.




* TimerOn()
* Turns on CIA-B timer, using timers A & B as a 32-bit timer.

* CIA control register states after calling are:

* CRB	:	ALARM=OFF (0)
*		INMODE=Timer A (10)
*		LOAD=Force Load (1)
*		RUNMODE=Continuous (0)
*		OUTMODE=Pulse (0)
*		START=ON (1)

* CRA	:	INMODE=Processor E Clock (0)
*		RUNMODE=Continuous (0)
*		LOAD=Force Load (1)
*		OUTMODE=Pulse (0)
*		START=ON (1)

* d0 corrupt


TimerOn		move.b	CIABCRB,d0	;get current control
		and.b	#%10000010,d0	;leave unused bits alone
		or.b	#%01010001,d0	;TB reacts to TA, continous
		move.b	d0,CIABCRB	;set it up
		
		move.b	CIABCRA,d0	;get current control
		and.b	#%11000111,d0	;TA counts 02 pulses
		or.b	#%0001,d0	;TA on, no PB6, continuous
		move.b	d0,CIABCRA	;set it up
		rts


* TimerOff()
* Turns off CIA-B timer. Stops both timers A and B

* Only affects START bits of control registers

* d0 corrupt

TimerOff	move.b	CIABCRA,d0
		and.b	#%01111110,d0	;stop TA
		move.b	d0,CIABCRA

		move.b	CIABCRB,d0
		and.b	#$FE,d0		;stop TB
		move.b	d0,CIABCRB
		rts


* SetTimer(d0,d1)
* d0 = timer start value

* Initialise CIA-B timers

* d0 corrupt


SetTimer	swap	d0		;get timer B (high word)
		move.b	d0,CIABTBLO	;load low byte first
		lsr.w	#8,d0
		move.b	d0,CIABTBHI	;high byte transfers latch
		swap	d0		;now timer A (low word)
		move.b	d0,CIABTALO	;load low byte first
		lsr.w	#8,d0
		move.b	d0,CIABTAHI	;high byte transfers latch
		rts


* CompTime() -> d0
* recover CIA-B timer value after a TimerOff() call,
* then perform subtraction to work out true timer
* elapsed value in terms of E clock. Elapsed time
* in terms of cycles is 10 * E clock time.

* Don't call before calling TimerOff() or the result
* will be wrong!

* Returns elapsed E clock time in d0.

* no other registers corrupt


CompTime	move.l	d1,-(sp)	;save so we can use it
		moveq	#-1,d0

		move.b	CIABTBHI,d1	;note:swap for high word
		lsl.w	#8,d1		;of timer plus lsl.w for
		move.b	CIABTBLO,d1	;each individual timer
		swap	d1		;faster than three lsl.l's
		move.b	CIABTAHI,d1	;and more elegant!
		lsl.w	#8,d1
		move.b	CIABTALO,d1

		sub.l	d1,d0		;compute elapsed time
		move.l	(sp)+,d1	;recover scratched reg
		rts





