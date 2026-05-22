*****************************************************************************
***                           CONSTRING.ASM                               ***
***                                                                       ***
***    Author : Andrew Duffy                                              ***
***    Date   : November 1992                                             ***
***    Desc.  : This program reads in a string from the keyboard          ***
***             (terminated by the character 'Term') and outputs it in    ***
***             the opposite case.                                        ***
***                                                                       ***
***                          ©XCNT, 1992-1994.                            ***
*****************************************************************************


*****************************************************************************
***                              Includes                                 ***
*****************************************************************************

		include	"subrts.h"	Included by default anyway

*****************************************************************************
***                        Termination character                          ***
*****************************************************************************

Term		EQU	13

*****************************************************************************
***                         Main control routine                          ***
*****************************************************************************

Main		jsr	Messages	Print initial messages
		jsr	GetString	Read string from keyboard
		jsr	ConString	Convert string and output
		rts			Exit

*****************************************************************************
***                          Messages routine                             ***
*****************************************************************************

Messages	movea.l	#Instructs,a6	Print text and other messages
		jsr	OUTSTR		Call OUTSTR routine
		rts			Return to Main

*****************************************************************************
***                         GetString routine                             ***
*****************************************************************************

GetString	movea.l	#Data,a0	Storage address
_GetString2	jsr	INCH		Call INCH routine
		jsr	OUTCH		Call OUTCH routine
		cmp.b	#8,d0		Compare with Delete character
		beq	Delete
		move.b	d0,(a0)+
		cmp.b	#Term,d0	Compare with Carriage Return
		bne.s	_GetString2
		jsr	CRLF		Call CRLF routine
		rts			Return to Main

*****************************************************************************
***                         ConString routine                             ***
*****************************************************************************

ConString	movea.l	#Data,a0	Restore Storage address
_ConString2	move.b	(a0)+,d0
		jsr	Convert.Case
		jsr	OUTCH		Call OUTCH routine
		cmp.b	#Term,d0	Check for a carriage return
		bne	_ConString2
		rts			Return to main menu
      
*****************************************************************************
***                        Convert.Case routine                           ***
*** This routine will convert the case of alphabet characters only in d0, ***
*** returning either a converted character or the original in d0.         ***
*****************************************************************************

Convert.Case	cmp.b	#'A',d0		Check if character is => A ...
		bge	_Con.Case1	... go through to second filter
		rts

_Con.Case1	cmp.b	#'Z',d0		Check if character is <= Z ...
		ble	_Con.Case3	... must be capital so convert

		cmp.b	#'a',d0		Check if character is => a ...
		bge	_Con.Case2	... go through to a third filter
		rts

_Con.Case2	cmp.b	#'z',d0		Check if character if <= z ...
		ble	_Con.Case3	... must be lower so convert
		rts

_Con.Case3	eor	#$20,d0		Convert character
		rts

*****************************************************************************
***                            Delete routine                             ***
*** The delete key was pressed, delete last character on screen and       ***
*** decrease address.                                                     ***
*****************************************************************************

Delete		jsr	SPACE		Call SPACE routine
		move.b	#8,d0		Put ASCII delete in d0
		jsr	OUTCH		Call OUTCH routine
		move.b	#' ',-(a0)
		bra	_GetString2	Continue getting the string

*****************************************************************************
***                               Strings                                 ***
*****************************************************************************

Instructs	dc.b	"ConString.asm",13,10,"=============",13,10,13,10
		dc.b	"Type in a string of text to be converted to the opposite case.",13,10
		dc.b	"Press <RETURN> when finished :",13,10,13,10,0
		even

*****************************************************************************
***                             Storage Area                              ***
*****************************************************************************

Data		ds.b	200

*****************************************************************************
***                      End of file CONSTRING.ASM.                       ***
*****************************************************************************
