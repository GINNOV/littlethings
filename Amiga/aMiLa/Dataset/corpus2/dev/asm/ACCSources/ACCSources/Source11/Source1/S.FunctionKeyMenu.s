; Function Key menu for demo comps etc.
; The Knipe, 4 Mar 91.
*****************************************************************************
		SECTION main_program,CODE
*****************************************************************************
 include source:include/SK_LoadMacros.i

start		move.b		$bfec01,d0	get the value
		not.b		d0		and manipulate it
		ror.b		d0		to get rawkey code

f1		cmp.b		#$50,d0		rawkey f1
		beq.s		do
f2		cmp.b		#$51,d0		rawkey f2
		beq.s		do
f3		cmp.b		#$52,d0		rawkey f3
		beq.s		do
f4		cmp.b		#$53,d0		rawkey f4
		beq.s		do
f5		cmp.b		#$54,d0		rawkey f5
		beq.s		do
f6		cmp.b		#$55,d0		rawkey f6
		beq.s		do
f7		cmp.b		#$56,d0		rawkey f7
		beq.s		do
f8		cmp.b		#$57,d0		rawkey f8
		beq.s		do
f9		cmp.b		#$58,d0		rawkey f9
		beq.s		do
f10		cmp.b		#$59,d0		rawkey f10
		beq.s		do
nothing		bra.s		start

do		sub.b		#15,d0		correct for ascii letter
		move.b		d0,exstring	insert byte in execute name
		SMARTOPENLIB dosname,dosbase,nodos
		RUNPROG exstring,#0,#0		execute prog A-J
		CLOSELIB dosbase
nodos		rts
*****************************************************************************
dosbase		dc.l		0
dosname		dc.b		"dos.library",0
exstring	dc.b		"A",10		name of program A-J for F1-10

