;EXEC macros ; Simon Knipe ; v1.0

;	OPENLIB		open rom-resident library
;	SMARTOPENLIB	open rom-resident library, jump if failed
;	CLOSELIB	close rom-resident library
;	GETMEM		allocate amount of memory, jump if failed
;	GETMEMAREA	allocate specific memory area, jump if failed
;	RETURNMEM	return memory allocated previously

************************************************************** EXEC ***
;Purpose: open rom-resident library
;To call: OPENLIB LibraryName,LibraryBase

OPENLIB MACRO
	move.l	execbase,a6	get exec
	lea	\1,a1	name of library
	jsr	oldopenlibrary(a6)
	move.l	d0,\2	save adr of library
	ENDM
************************************************************** EXEC ***
;Purpose: open rom-resident library, with error jump if failed
;To call: SMARTOPENLIB LibraryName,LibraryBase,ErrorJumpAdr

SMARTOPENLIB MACRO
	move.l	execbase,a6	get exec
	lea	\1,a1	name of library
	jsr	oldopenlibrary(a6)
	move.l	d0,\2	save adr of library
	tst.l	d0	check if opened
	beq	\3
	ENDM
************************************************************** EXEC ***
;Purpose: close rom-resident library
;To call: CLOSELIB LibraryBase

CLOSELIB MACRO
	move.l	execbase,a6	get exec
	move.l	\1,a1	get adr of lib
	jsr	closelibrary(a6)
	ENDM
************************************************************** EXEC ***
;Purpose: allocate specified amount of memory, jump if failed
;To call: GETMEM BytesWanted,MemPointer,MemType,JumpIfErrorAdr

GETMEM MACRO
	move.l	\1,d0	number of bytes to get
	move.l	#\3,d1	type of memory, eg: MEMF_CHIP
	move.l	execbase,a6
	jsr	allocmem(a6)	exec function
	move.l	d0,\2	save adr of mem taken
	tst.l	d0
	beq	\4
	ENDM
************************************************************** EXEC ***
;Purpose: allocate specific location in memory, jump if failed
;To call: GETMEMAREA BytesWanted,StartAddress,ErrorJumpAdr

GETMEMAREA MACRO
	move.l	#\1,d0	bytes requested
	lea	\2,a1	start adr
	move.l	execbase,a6
	jsr	allocabs(a6)
	tst.l	d0
	beq	\3
	ENDM
************************************************************** EXEC ***
;Purpose: return memory allocated previously
;To call: RETURNMEM BytesTaken,MemPointer

RETURNMEM MACRO
	move.l	\1,d0	number of bytes to release
	move.l	\2,a1	adr of memory
	move.l	execbase,a6
	jsr	freemem(a6)	free it
	ENDM
