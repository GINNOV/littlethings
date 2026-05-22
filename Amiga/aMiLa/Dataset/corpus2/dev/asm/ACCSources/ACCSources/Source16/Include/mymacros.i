
NULL		equ		0

TD_DF0		equ		NULL
TD_DF1		equ		1
TD_DF2		equ		2
TD_DF3		equ		3

TYPE		MACRO				* Needs dos open and an
		move.l		CliBase(a5),d1	* output handle called
		move.l		#\1,d2		* CliBase(a5)
		move.l		#\2,d3
		DOSCALL		Write
		ENDM

ZEROM		MACRO				* Zero multiple registers
		movem.l		Blanks(a5),\1	* Needs sufficient No. of
		ENDM				* blank long words

ZERO		MACRO				* Clear data register
		moveq.l		#NULL,\1
		ENDM
		
ZEROA		MACRO				* Clear address register
		suba.l		\1,\1
		ENDM
	
INTCALL		MACRO				
		move.l		_IntBase(a5),a6	* Go fast macros!
		jsr		_LVO\1(a6)
		ENDM	
	
GRAFCALL	MACRO				
		move.l	_GfxBase(a5),a6		
		jsr			_LVO\1(a6)
		ENDM

DOSCALL		MACRO				
		move.l		_DosBase(a5),a6		
		jsr		_LVO\1(a6)
		ENDM
	
CALLSYS		MACRO				* Now A6 is not corrupt
		move.l		a6,-(sp)	* when a library call
		movea.l		(_SysBase).w,a6	* is used
		jsr		_LVO\1(a6)
		move.l		(sp)+,a6
		ENDM

*	Multiply a data register (d0-d6) by 10.  A standard Mulu uses
*	74 processor cycles, this macro uses 44, (or 20 without the
*	stack access!)  Quite a saving.
*	Note : D7 cannot be used.  No register corruption

*	MULU10	d5	* Multiply contents of d5 by 10

MULU10		MACRO
		move.l		d7,-(sp)
		move.w		\1,d7
		add.w		\1,\1
		add.w		\1,\1
		add.w		d7,\1
		add.w		\1,\1
		move.l		(sp)+,d7
		ENDM

