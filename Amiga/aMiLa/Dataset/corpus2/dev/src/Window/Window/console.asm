**********************************************
* console.asm
* 
* contents: code to spawn a new console task  
* From Tim King (more or less)
* (C) 1986 Commodore-Amiga
*
* (c) 1986 Commodore-Amiga, Inc.
* This file may be used in any manner, as long as this copyright notice
* remains intact.
* 		andy finkel
*		Commodore-Amiga
*
************************************
	include	"window.i"

	xdef	_NewConsole
	xdef	_CloseConsole
	xref	_DOSBase

* offset into device style DevList structure
* (the include file said the DevList structure
* needed some work !)
startup	equ	28

act_end		equ	1007

g_sendpkt	equ	48
g_loaddevice	equ	112
g_finddevice	equ	124

* task = NewConsole(Window)
* create a console task in an already opened window
* and return its handle
 
_NewConsole:
	procst	#0,d2/a2/a5
	move.l	#conname,d1	d1 = address of "CON" string
	lsr.l	#2,d1		arg1 = BCPL address of string
	callg	g_finddevice	get console device node
	move.l	d0,d1		send it in arg1
	lsl.l	#2,d0		d0 = address of node
	move.l	d0,a2		save it in a2
	move.l	#-1,startup(a2)	tell it not to create another window
	move.l	arg1(a6),d2	arg2 = window structure pointer
	callg	g_loaddevice
	clr.l	startup(a2)	zero startup- we're cool now
	return	d2/a2/a5

* CloseConsole( task )
* shutdown the console task
_CloseConsole:
	procst	#0,d2-d4
	move.l	arg1(a6),d2	d2 = destination task
	move.l	#act_end,d3	d3 = action
	callg	g_sendpkt	send the pkt off
	return	d2-d4

	cnop	0,4

conname	dc.b	3,'C','O','N'

	end

****************************
* end of file console.asm
****************************
