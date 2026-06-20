*****************************************************************************
***                            CONTROL.ASM                                ***
***                                                                       ***
***    Author : Andrew Duffy                                              ***
***    Date   : January 1993                                              ***
***    Desc.  : This program demonstrates how to control the motor and    ***
***             heater using APPS_PORTA.                                  ***
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

		move.b	#APPS_MOTOR+APPS_HEATER,d0  Initialise the applications board
		jsr	APPS_INIT	(using motor and heater)

		move.b	#0,APPS_PORTA	Turn everything off

		movea.l	#Instructs,a6	Print instructions
		jsr	OUTSTR

*****************************************************************************
***                         Main control routine                          ***
*****************************************************************************

Main		jsr	INCH
		bclr	#5,d0		Convert to upper case
		cmp.b	#'F',d0
		beq	Mot_For
		cmp.b	#'B',d0
		beq	Mot_Bac
		cmp.b	#'S',d0
		beq	Mot_Sto
		bset	#5,d0		Convert back to normal case
		cmp.b	#'1',d0
		beq	Heat_On
		cmp.b	#'2',d0
		beq	Heat_Off
		cmp.b	#'.',d0		Was full stop pressed ?
		bne	Main		If not then loop again

*****************************************************************************
***                         Turn everything off                           ***
*****************************************************************************

		move.b	#0,APPS_PORTA	Turn everything off
		rts			Exit

*****************************************************************************
***                        Motor forward routine                          ***
*****************************************************************************

Mot_For		bclr	#6,APPS_PORTA	Clear bit 6 of Port A
		bset	#7,APPS_PORTA	Set bit 7 of Port A
		movea.l	#Forwards,a6	Output forward message
		jsr	OUTSTR
		bra	Main		Continue at main

*****************************************************************************
***                        Motor backward routine                         ***
*****************************************************************************

Mot_Bac		bclr	#7,APPS_PORTA	Clear bit 7 of Port A
		bset	#6,APPS_PORTA	Set bit 6 of Port A
		movea.l	#Backwards,a6	Output backward message
		jsr	OUTSTR
		bra	Main		Continue at main

*****************************************************************************
***                        Motor stopped routine                          ***
*****************************************************************************

Mot_Sto		bclr	#7,APPS_PORTA	Clear bit 7 of Port A
		bclr	#6,APPS_PORTA	Clear bit 6 of Port A
		movea.l	#Stopped,a6	Output stopped message
		jsr	OUTSTR
		bra	Main		Continue at main

*****************************************************************************
***                          Heater on routine                            ***
*****************************************************************************

Heat_On		bset	#5,APPS_PORTA	Set bit 5 of Port A
		movea.l	#On,a6		Output on message
		jsr	OUTSTR
		bra	Main		Continue at main

*****************************************************************************
***                         Heater off routine                            ***
*****************************************************************************

Heat_Off	bclr	#5,APPS_PORTA	Clear bi 5 of Port A
		movea.l	#Off,a6		Output off message
		jsr	OUTSTR
		bra	Main		Continue at main

*****************************************************************************
***                              Strings                                  ***
*****************************************************************************

Instructs	dc.b	"Control.asm",13,10,"===========",13,10,13,10
		dc.b	"Ensure that the Motor and Heater are switched on.",13,10
		dc.b	"Press F to make motor go forwards, B to make motor go backwards, S to stop.",13,10
		dc.b	"Press 1 to turn heater on, 2 to turn heater off.",13,10
		dc.b	"Press full stop to quit.",13,10,13,10
		dc.b	"Motor Status  : Stopped",13,10
		dc.b	"Heater Status : Off",13,10,0
		even
Forwards	dc.b	27,"[9;17fGoing fowards  ",13,10,0
		even
Backwards	dc.b	27,"[9;17fGoing backwards",13,10,0
		even
Stopped		dc.b	27,"[9;17fStopped        ",13,10,0
		even
On		dc.b	27,"[10;17fOn ",13,10,0
		even
Off		dc.b	27,"[10;17fOff",13,10,0

*****************************************************************************
***                      End of file CONTROL.ASM.                         ***
*****************************************************************************
