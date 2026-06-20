; Needs libs.i to assemble.
*******************************************************
; AllocMem subprogram
; SK 5th Sep 1990

allocatemem:	move.l	#50000,d0	number of bytes to reserve
	move.l	execbase,a6	Execbase
	jsr	allocmem(a6)	get that mem
	move.l	d0,buffer	save base address of memory!
	rts
*******************************************************
; DeAllocMem subprogram
; SK 5th Sep 1990

deallocatemem:	move.l	#50000,d0	number to be released
	move.l	buffer,a1	start address from AllocMem
	move.l	execbase,a6	Execbase
	jsr	freemem(a6)	release mem
	rts		thats it!
******************************************************
