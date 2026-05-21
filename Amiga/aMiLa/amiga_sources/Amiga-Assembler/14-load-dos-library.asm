LIBRARY_BASE equ $4

	bra START
	
	include 'exec/types.i'
	include 'exec/exec.i'
	include 'exec/exec_lib.i'
	include 'libraries/dos.i'
	include 'libraries/dos_lib.i'

START:
	; load dos.library and store handle in BASELIB_DOS
	move.l LIBRARY_BASE,a6
	lea LIBRARY_DOS,a1
	move.l #0,d0
	jsr _LVOOpenLibrary(a6)
	tst.l d0
	beq .error
	move.l d0,BASELIB_DOS
	nop
	
.error:
	; todo some useful error handling

BASELIB_DOS:
	dc.l 0

LIBRARY_DOS:
	dc.b "dos.library",0
	even