;-------------- I'm using mark's subroutine for getting the length
;		of a file,whats the point of doing it again.
	
;-------------- Subroutine that returns the length of a file in bytes.

; Entry		a0 = address of file name

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	a0

; M.Meany, Feb 91


;---------- Save register values

FileLen	
	movem.l		d1-d4/a1-a4,-(sp)

;---------- Save address of filename and clear file length

	move.l		a0,RFfile_name
	move.l		#0,RFfile_len

;---------- Allocate some memory for the File Info block

	move.l		#fib_SIZEOF,d0
	move.l		#MEMF_PUBLIC,d1
	CALLEXEC	AllocMem
	move.l		d0,RFfile_info
	beq		.error1
		
;---------- Lock the file
		
	move.l		RFfile_name,d1
	move.l		#ACCESS_READ,d2
	CALLDOS		Lock
	move.l		d0,RFfile_lock
	beq		.error2

;---------- Use Examine to load the File Info block

	move.l		d0,d1
	move.l		RFfile_info,d2
	CALLDOS		Examine

;---------- Copy the length of the file into RFfile_len

	move.l		RFfile_info,a0
	move.l		fib_Size(a0),RFfile_len

;---------- Release the file

	move.l		RFfile_lock,d1
	CALLDOS		UnLock

;---------- Release allocated memory

.error2	move.l		RFfile_info,a1
	move.l		#fib_SIZEOF,d0
	CALLEXEC	FreeMem


;---------- All done so return

.error1	
	move.l		RFfile_len,d0
	movem.l		(sp)+,d1-d4/a1-a4
	rts

