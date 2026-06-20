*****************************************************************************
***                              DEMO.ASM                                 ***
***                                                                       ***
***    Author : Andrew Duffy                                              ***
***    Date   : June 1994                                                 ***
***    Desc.  : This program is a combination of Control.asm to control   ***
***             the heater/fan and Temperature.asm to show the responses  ***
***             of the heater temperature.                                ***
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

Main		bsr	Get.Temperature
		jsr	INKEY
		beq.s	Main
		jsr	INCH
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
		movea.l	#End,a6		Print exit text
		jsr	OUTSTR
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
***                        Get.Temperature routine                        ***
*****************************************************************************

Get.Temperature	movem.l	d0-d2,-(a7)	Save all used registers
		move.l	#127,d0		Set up d0 with starting value
		move.l	#128,d1		Set up d1 to half of start value
.Chop		lsr.b	#1,d1		Divide half value by half again
		move.b	d0,APPS_PORTB	Send try value
		move.b	APPS_PORTA,d2
		btst	#3,d2		Check if value was higher or lower
		bne.s	.Higher		If value was higher
.Lower		sub.b	d1,d0		Subtract half value from main value
		cmp.b	#1,d1		Check if all values have been done
		beq.s	.Done
		bra.s	.Chop		Try next value
.Higher		add.b	d1,d0		Add half value to main value
		cmp.b	#1,d1		Check if all values have been done
		beq.s	.Done
		bra.s	.Chop		Try next value

.Done		move.b	d0,APPS_PORTB	(This ensures an acurate reading
		move.b	APPS_PORTA,d1	of the heater with single byte
		btst	#3,d1		differences rather than 2 bytes)
		beq.s	.Done2		Value is correct
		add.b	#1,d0		Value incorrect, subtract 1 from it
.Done2		move.w	d0,Temperature	Save Temperature

*****************************************************************************
***                  Temperature found - now draw graph                   ***
*****************************************************************************

		move.b	#21,d0		Locate cursor to print
		move.b	#47,d1		out temperature value.
		bsr.s	Locate		Locate cursor
		move.w	Temperature,d0	Temperature between 0 and 255
		jsr	OUT2HEX		Output fan speed

		move.b	#18,d0		Locate cursor to print
		move.b	#8,d1		out fan bar graph.
		bsr.s	Locate		Locate cursor
		moveq	#0,d1		Clear d1
		move.w	Temperature,d1	Temperature between 0 and 255
		lsr.b	#2,d1		Divide by four
		move.b	#'*',d0
		bsr.s	Chars		Output characters
		movem.l	(a7)+,d0-d2	Unstack registers
		rts

*****************************************************************************
***                          Locate routine                               ***
*** Locates the cursor at d0 down, d1 across.                             ***
*****************************************************************************

Locate		movem.l	d0-d3/a0/a6,-(a7)  Save all used registers
		moveq	#0,d3
		movea.l	#Locate_Seq+2,a0   ANSI locate sequence - Down
		move.b	d0,d3
		bsr.s	.Locate_1	   Convert value to text value
		movea.l	#Locate_Seq+5,a0   ANSI locate sequence - Across
		move.b	d1,d3
		bsr.s	.Locate_1	   Convert value to text value
		movea.l	#Locate_Seq,a6     Output escape sequence
		jsr	OUTSTR
		movem.l	(a7)+,d0-d3/a0/a6  Unstack registers
		rts

.Locate_1	divu	#10,d3		   Convert tens first
		bsr	.Locate_1.2
.Locate_1.2	add	#$30,d3		   Then units
		move.b	d3,(a0)+
		move.w	#0,d3
		swap	d3
		rts

*****************************************************************************
***                            Chars routine                              ***
*** Prints d1 number of d0.b characters                                   ***
*****************************************************************************

Chars		movem.l	d0-d1/a6,-(a7)	Save all used registers
.Chars_1	cmpi.b	#0,d1		Check if all characters done
		beq.s	.Chars_1.2
		jsr    	OUTCH		Output 1 character
		subi.b 	#1,d1		Decrement number to do
		bra.s	.Chars_1	Repeat
.Chars_1.2	movea.l	#EraseToEnd,a6	Output clear to end string
		jsr	OUTSTR
 		movem.l	(a7)+,d0-d1/a6	Unstack registers
		rts				

*****************************************************************************
***                             Variables                                 ***
*****************************************************************************

Temperature	ds.w	1

*****************************************************************************
***                              Strings                                  ***
*****************************************************************************

EraseToEnd	dc.b	27,'[K',0
		even

Locate_Seq	dc.b	27,'[  ;  f',0	   ANSI sequence
		even			   Re-align code

Instructs	dc.b	"Demo.asm",13,10,"========",13,10,13,10
		dc.b	"Ensure that the ADC, Motor, and Heater are all switched on.",13,10
		dc.b	"Select Heater on the Heater/Pot switch, then watch the temperature as you",13,10
		dc.b	"play with the heater and fan actions.",13,10,13,10
		dc.b	"Keys : F to make motor go forwards, B to make motor go backwards, S to stop.",13,10
		dc.b	"       1 to turn heater on, 2 to turn heater off.",13,10
		dc.b	"       Full stop to quit.",13,10,13,10
		dc.b	"Motor Status  : Stopped",13,10
		dc.b	"Heater Status : Off",13,10
		dc.b	27,"[15;30fTemperature - (Percent)"
		dc.b	27,"[17;8f00%  -     -     -     -     - 50% -     -     -     -     - 100%"
		dc.b	27,"[21;32fActual Value :",0
		even
Forwards	dc.b	27,"[12;17fGoing fowards  ",13,10,0
		even
Backwards	dc.b	27,"[12;17fGoing backwards",13,10,0
		even
Stopped		dc.b	27,"[12;17fStopped        ",13,10,0
		even
On		dc.b	27,"[13;17fOn ",13,10,0
		even
Off		dc.b	27,"[13;17fOff",13,10,0
		even
End		dc.b	27,"[23;1fProgram ended normally.",0

*****************************************************************************
***                        End of file DEMO.ASM.                          ***
*****************************************************************************
