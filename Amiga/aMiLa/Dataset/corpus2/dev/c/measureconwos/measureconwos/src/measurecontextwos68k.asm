** MeasureContextWOS
** by Álmos Rajnai (Rachy/BiøHazard)
** on 21.11.1999
**
**  mailto: racs@fs2.bdtf.hu
**
** measurecontextwos68k.asm
** This part is the 68K core code.
** Done in assembly, for less fuss around the main cycle.
**
** See .build file for compiling!


	INCDIR	include:

	INCLUDE	exec/exec_lib.i
	INCLUDE	powerpc/powerpc.i

	XREF	_PowerPCBase
	XDEF	_timer68k

; *** D0 - number of switching

_timer68k:

.loop
	movem.l	d0,-(sp)

	RUNPOWERPC _timerppc

	movem.l	(sp)+,d0
	dbf	d0,.loop

	rts

