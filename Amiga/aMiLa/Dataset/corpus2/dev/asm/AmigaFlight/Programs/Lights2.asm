*****************************************************************************
***                             LIGHTS1.ASM                               ***
***                                                                       ***
***    Author : Pete Cheetham, Andrew Duffy                               ***
***    Date   : November 1992, June 1994                                  ***
***    Desc.  : This program was written to demonstrate driving the 68000 ***
***             applications board.                                       ***
***             It counts repeatedly from 0 to 255, outputting the value  ***
***             each time to the LEDs and then delaying for 0.2 seconds   ***
***             before moving onto the next number.                       ***
***                                                                       ***
***                          ©XCNT, 1992-1994.                            ***
*****************************************************************************


*****************************************************************************
***                              Includes                                 ***
*****************************************************************************

		include	"subrts.h"	Included by default anyway

*****************************************************************************
***                              Constants                                ***
*****************************************************************************

FIFTHSEC	EQU	50000		Number of clock ticks in 0.2 seconds

*****************************************************************************
***                          Initialisation routine                       ***
*****************************************************************************

		move.b	#APPS_ALL_IN,d0	Initialise the applications board
		jsr	APPS_INIT	(port A all input)

		movea.l	#Instructs,a6	Print instructions
		jsr	OUTSTR

*****************************************************************************
***                              Main routine                             ***
*****************************************************************************

		move.l	#FIFTHSEC,d0	Initialise delay value
		move.b	#0,d1		Initialise LED value

Loop		move.b	d1,APPS_PORTB	Output it to the LEDs
		bsr	Delay		Wait a while
		add.b	#1,d1		Increment LED value.
		bra	Loop		Repeat forever

		rts			Exit (never gets here)

*****************************************************************************
***                             Delay routine                             ***
*** Waits for the value in bits 23-0 of d0 clock ticks to elapse before   ***
*** returning.                                                            ***
*****************************************************************************

Delay		jsr	START_TIMER	Initialise clock and start it going
Delay1		jsr	CHECK_TIMER	Has countdown timer reached zero ?
		beq	Delay1		No, go back and wait some more
		rts			Return from subroutine

*****************************************************************************
***                               Strings                                 ***
*****************************************************************************

Instructs	dc.b	"Lights2.asm",13,10,"===========",13,10,13,10
		dc.b	"Ensure that the LEDs are switched on.",13,10
		dc.b	"This program counts repeatedly from 0 to 255, outputting the value each time",13,10
		dc.b	"to the LEDs and then displaying for 0.2 seconds before moving onto the next",13,10
		dc.b	"number."13,10,0

*****************************************************************************
***                       End of file LIGHTS2.ASM.                        ***
*****************************************************************************
