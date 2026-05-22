; mc1003.s			; writefile - after execution there is a file "Testfil" in your folder
; from disk1/brev10
; explanation on letter_10 p. 09
; from Mark Wrobel course letter 27
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1003.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j			
			
start:							; comments from Mark Wrobel	
	move.l	#24,d0				; move 24 into d0 (length)
	lea.l	filename,a0			; move filename address into a0
	lea.l	buffer,a1			; move buffer address into a1

	bsr	writefile				; branch to subroutine writefile

	cmp.l	#0,d0				; compare d0 with zero
	bne	error					; if d0 is zero goto error

	rts							; return from subroutine

	error:						; writefile error handling
	rts							; return from subroutine

filename:
	dc.b	"Testfil",0			; filename terminated by zero

buffer:
	dc.b	"Hallo, dette er en test!"  ; contents of the buffer


writefile:						; writefile subroutine
	movem.l	d1-d7/a0-a6,-(a7)   ; push register values onto the stack
	move.l	a0,a4               ; move a0 into a4 (filename)
	move.l	a1,a5               ; move a1 into a2 (buffer)
	move.l	d0,d5               ; move d0 into d5 (length)
	move.l	$4,a6               ; move base pointer of exec.library into a6
	lea.l	w_dosname,a1        ; move pointer to library name into a1
	jsr	-408(a6)				; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	move.l	d0,a6               ; move base pointer to dos.library into a6
	move.l	#1006,d2            ; move 1006 into d2 (accessMode = MODE_NEWFILE)
	move.l	a4,d1               ; move a4 into d1 (name of filename to open)
	jsr	-30(a6)					; call Open in dos.library. d0 = Open(d1,d2)
	cmp.l	#0,d0               ; compare value of d0 with zero
	beq	w_error				    ; if d0 is zero goto w_error
	move.l	d0,d1               ; move d0 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7
	move.l	a5,d2               ; move a5 into d2 (buffer)
	move.l	d5,d3               ; move d5 into d3 (length)
	jsr	-48(a6)					; call Write in dos.library. d0 = Write(d1,d2,d3)
	move.l	d7,d1               ; move d7 into d1 (filehandle)
	move.l	d0,d7               ; move d0 into d7 (actualLength from Write)
	jsr	-36(a6)					; call Close in dos.library. d0 = Close(d1)
	move.l	d7,d0               ; move d7 into d0 (actualLength)
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
w_error:						; write error handling
	clr.l	d0                  ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine
w_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero

	end
	
