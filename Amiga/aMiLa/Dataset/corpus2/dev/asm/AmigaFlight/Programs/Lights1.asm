*****************************************************************************
***                             LIGHTS1.ASM                               ***
***                                                                       ***
***    Author : Pete Cheetham, Andrew Duffy                               ***
***    Date   : November 1992, June 1994                                  ***
***    Desc.  : This program was written to demonstrate driving the 68000 ***
***             applications board.                                       ***
***             It repeatedly reads the bit switches and echoes their     ***
***             values to the coloured LEDs, forever.                     ***
***                                                                       ***
***                          ©XCNT, 1992-1994.                            ***
*****************************************************************************


*****************************************************************************
***                              Includes                                 ***
*****************************************************************************

		include	"subrts.h"	Included by default anyway

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

Loop		move.b	APPS_PORTA,d0	Get the values of the bit switches
		move.b	d0,APPS_PORTB	Output them to the LEDs
		bra	Loop		Repeat forever

		rts			Exit (never gets here)

*****************************************************************************
***                               Strings                                 ***
*****************************************************************************

Instructs	dc.b	"Lights1.asm",13,10,"===========",13,10,13,10
		dc.b	"Ensure that the LEDs are switched on and the ADC is switched off.",13,10
		dc.b	"This program reads the values from the DIP switches and echoes their values",13,10
		dc.b	"to the coloured LEDs, forever...",13,10,0

*****************************************************************************
***                       End of file LIGHTS1.ASM.                        ***
*****************************************************************************
