LIBRARY_BASE equ $4

	bra START
	
	include 'exec/types.i'
	include 'exec/exec.i'
	include 'exec/exec_lib.i'		; include these because we use the exec lib
	include 'libraries/dos.i'
	include 'libraries/dos_lib.i'	; include these because we use the dos lib
	
	include 'fileloader.i'			; loader constants
	include 'fileloader.asm'		; add in loader functions

START:
	; load dos.library and store handle in BASELIB_DOS
	move.l LIBRARY_BASE,a6
	lea LIBRARY_DOS,a1
	move.l #0,d0
	jsr _LVOOpenLibrary(a6)
	tst.l d0
	beq .error
	move.l d0,BASELIB_DOS
	
	; read file
	lea FILENAME,a0
	move.l #0,d0
	move.l #MEMF_CHIP,d1
	bsr tecLoadFile
	tst.l d0
	bmi .error
	nop
	
.error:
	; todo some useful error handling
	move.l #-1,d0
	bra .rts
	
.exit:
	move.l #0,d0

.rts:
	rts

FILENAME:
	dc.b "dh1:test.txt",0
	even

BASELIB_DOS:
	dc.l 0

LIBRARY_DOS:
	dc.b "dos.library",0
	even