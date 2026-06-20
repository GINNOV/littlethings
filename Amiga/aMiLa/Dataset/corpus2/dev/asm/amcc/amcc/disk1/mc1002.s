; mc1002.s			; readfile - after execution insert SEKA>qbuffer
; from disk1/brev10
; explanation on letter_10 p. 07
; from Mark Wrobel course letter 27
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1002.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j			
			
start:							; comments from Mark Wrobel	
	move.l	#24,d0				; move 24 into d0 (length)
	lea.l	filename,a0			; move address of filename into a0
	lea.l	buffer,a1			; move address of buffer into a1

	bsr	readfile				; branch to subroutine readfile

	cmp.l	#0,d0				; check if value of d0 is zero
	beq	error					; if d0 is zero then goto error

	rts							; return from subroutine

error:
	rts							; return from subroutine

filename:
	dc.b	"Testfil",0			; the filename terminated by a zero

buffer:
	blk.b	50,0				; allocate 50 bytes of buffer


readfile:
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a4               ; move a0 into a4
	move.l	a1,a5               ; move a1 into a5
	move.l	d0,d5               ; move d0 into d5
	move.l	$4,a6               ; move base pointer of exec.library into a6
	lea.l	r_dosname,a1        ; move pointer to library name into a1
	jsr	-408(a6)			    ; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	move.l	d0,a6               ; move base pointer to dos.library into a6
	move.l	#1005,d2            ; move 1005 into d2 (accessMode = MODE_OLDFILE)
	move.l	a4,d1               ; move a4 into d1 (name of filename to open)
	jsr	-30(a6)				    ; call Open in dos.library. d0 = Open(d1,d2)
	cmp.l	#0,d0               ; compare value of d0 with zero
	beq	r_error				    ; if d0 is zero goto r_error
	move.l	d0,d1               ; move d0 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7
	move.l	a5,d2               ; move a5 into d2 (buffer)
	move.l	d5,d3               ; move d5 into d3 (length)
	jsr	-42(a6)				    ; call Read in dos.library. d0 = Read(d1,d2,d3)
	move.l	d7,d1               ; move d7 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7 (number of bytes read)
	jsr	-36(a6)				    ; call Close in dos.library. d0 = Close(d1)
	move.l	d7,d0               ; move d7 into d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
r_error:					    ; handle read error
	clr.l	d0                  ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
r_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero

	end

