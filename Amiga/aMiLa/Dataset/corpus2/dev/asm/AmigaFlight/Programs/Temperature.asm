*****************************************************************************
***                          TEMPERATURE.ASM                              ***
***                                                                       ***
***    Author : Andrew Duffy                                              ***
***    Date   : February 1993                                             ***
***    Desc.  : This program demonstrates how to read the value of the    ***
***             heater/potentiometer using a simple binary chop routine.  ***
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
***                         Main control routine                          ***
*****************************************************************************

Main		bsr.s	Get.Temperature	Call Get.Temperature routine
		bra.s	Main		Repeat forever

		rts			Exit (never gets here)

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

		move.b	#18,d0		Locate cursor to print
		move.b	#47,d1		out temperature value.
		bsr.s	Locate		Locate cursor
		move.w	Temperature,d0	Temperature between 0 and 255
		jsr	OUT2HEX		Output fan speed

		move.b	#15,d0		Locate cursor to print
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

Instructs	dc.b	"Temperature.asm",13,10,"===============",13,10,13,10
		dc.b	"Ensure that the ADC is switched on.",13,10
		dc.b	"Now select between the Heater and the Potentiometer using the",13,10
		dc.b	"Heater/Pot switch.  If you select the potentiometer then use",13,10
		dc.b	"the slider to adjust it''s value.",13,10
		dc.b	"(LEDs may be left ON or OFF but will slow down on slower machines)"
		dc.b	27,"[12;30fTemperature - (Percent)"
		dc.b	27,"[14;8f00%  -     -     -     -     - 50% -     -     -     -     - 100%"
		dc.b	27,"[18;32fActual Value :",0

*****************************************************************************
***                    End of file TEMPERATURE.ASM.                       ***
*****************************************************************************
