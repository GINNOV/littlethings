
; rawHandle = tecLoadFile(*filename, memtype)
;    d0                      a0        d1
tecLoadFile:
	movem.l	d1-d7/a0-a1,-(a7)	; save registers
	move.l	d1,d5				; save requested memory type
	
	; open the file for reading
	move.l	a0,d1				      
    move.l  #MODE_OLDFILE,d2
	move.l  BASELIB_DOS,a6 
    jsr     _LVOOpen(a6)        ; handle[d0] = LVOOpenFile(filename[d1],mode[d2])
	tst.l	d0				
	beq	.open_error
	move.l	d0,d4				; save the file handle for later use.
	
	; allocate ram based	
	move.l	#4096,d0			; get file length
	move.l	d5,d1				
    move.l  LIBRARY_BASE,a6
    jsr     _LVOAllocMem(a6)
	tst.l	d0
	bmi.s	.alloc_error
	move.l	d0,d5				; save the allocated buffer origin into d5
	
	move.l	d4,d1				; get file handle for seek 
	move.l	#0,d2				; to 0 byte offset
	move.l	#OFFSET_BEGINNING,d3		; return to start of file
	move.l  BASELIB_DOS,a6 
	jsr	_LVOSeek(a6)			
	
	; read the entire file	
	move.l	d4,d1				; get file handle for seek 
	move.l	d5,d2				; buffer to read into
	move.l	#$ffffff,d3			; read entire file
    jsr     _LVORead(a6)        ; bytes[d0] = LVORead(handle[d1],buffer[d2],size[d3]) 	
	tst.l	d0
	bmi.s	.read_error
	move.l	d0,d3
	
	; close the file
	move.l	d4,d1				; result = LVOClose(handle[d1])      
    jsr     _LVOClose(a6)        
	
	movem.l (a7)+,a0-a1
	move.l	d6,d0				; return number of bytes read.
	bra	.exit					; all done.
	        	
.open_error:
	moveq	#ERROR_HANDLE_FILE_OPEN,d0
	bra.s	.exit
.header_error:
	moveq	#ERROR_HANDLE_HEADER_NOT_FOUND,d0
	bra.s	.exit
.alloc_error:
	moveq	#ERROR_HANDLE_ALLOCATE_FAIL,d0
	bra.s	.exit
.read_error:
	moveq	#ERROR_HANDLE_FILE_READ,d0
	bra.s	.exit
.exit:	
	movem.l	(a7)+,d1-d7/a0-a1
	rts