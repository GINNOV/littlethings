*****************************************************************************
***                              SUBRTS.H                                 ***
***                                                                       ***
***    This file is part of the XCNT AmigaFlight® development package.    ***
***      It should be found in the AmigaFlight:Includes directory.        ***
***                                                                       ***
***                          ©XCNT, 1992-1994.                            ***
*****************************************************************************


*****************************************************************************
***    Values to write to the data direction register (of port A), to     ***
***   select which pins are being used for input and which for output.    ***
*****************************************************************************

APPS_ALL_IN	EQU	$00	All pins set to input.
APPS_MOTOR	EQU	$C0	Pins 6 & 7 output, pins 5-0 input.
APPS_HEATER	EQU	$20	Pin 5 output, all others input.

*****************************************************************************
***                       The main flight routines.                       ***
*****************************************************************************

		XREF	CLS
		XREF	CONHEX
		XREF	CRLF
		XREF	INADDR
		XREF	INCH
		XREF	INCHEX
		XREF	INKEY
		XREF	INSTHEX
		XREF	OUTCH
		XREF	OUTHEX
		XREF	OUT2HEX
		XREF	OUT4HEX
		XREF	OUT8HEX
		XREF	OUTSTR
		XREF	SPACE
		XREF	SPACES

*****************************************************************************
***               Applications board initialisation routine.              ***
*****************************************************************************

		XREF	APPS_INIT
		XREF	APPS_PORTA
		XREF	APPS_PORTB

*****************************************************************************
***           AmigaFlight hardware emulation routine (PRIVATE!).          ***
*****************************************************************************

		XREF	APPS_ROUTINE

*****************************************************************************
***                           Timer routines.                             ***
*****************************************************************************

		XREF	CHECK_TIMER
		XREF	START_TIMER
		XREF	STOP_TIMER

*****************************************************************************
***                        End of file SUBRTS.H.                          ***
*****************************************************************************
