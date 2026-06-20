; mc1007.s						; read and write character
; from disk1/brev10
; explanation on letter_10 p. 18
; from Mark Wrobel course letter 29	
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1007.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>wo
; MODE>c			
; FILENAME>mc1007o

; start program from CLI
; >mc1007o						; enter program without arguments
; how are you doing!			; now insert arguments
; Hallo, how are you doing!		; this is the result

start:							; comments from Mark Wrobel					
	bsr	opendos					; go to opendos() to open the DOS library

	moveq	#40,d0				; move 40 into d0
	lea.l	input,a0			; move input address into a0
	bsr	readchar				; go to subroutine d0 = readchar(a0, d0)

	addq.l	#7,d0				; add 7 to actual length read by readchar, where 7 is for "Hallo, "
	lea.l	output,a0			; put output address into a0
	bsr	writechar				; go to subroutine d0 = writechar(a0, d0)
	rts							; exit program

output:
	dc.b	"Hallo, "			; fill some bytes with characters

input:
	blk.b	40,0				; reserves 40 bytes for input
	even						; pseudo-op for Seka. Makes the current address
								;  even by sometimes inserting a fill byte


readchar:						; subroutine (d0=actualLength) = readchar(a0=input,d0=length)
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a5				; move a0 into a5 (input)
	move.l	d0,d5				; move d0 into d5 (length)
	lea.l	txt_dosbase,a0		; move txt_dosbase address into a0
	move.l	(a0),a6				; move base pointer to DOS library into a6
	jsr	-54(a6)					; call (d0=file) = Input() in DOS library
	move.l	d0,d1				; move d0 (file) into d1
	move.l	a5,d2				; move a5 (input) into d2
	move.l	d5,d3				; move d5 (length) into d3
	jsr	-42(a6)					; call (d0=actualLength) = Read(d1=file,d2=buffer,d3=length)
	movem.l	(a7)+,d1-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine

writechar:						; subroutine (d0=returnedLength) = writechar(a0=buffer, d0=length)
	movem.l	d1-d7/a0-a6,-(a7)	; push register values onto the stack
	move.l	a0,a5				; move a0 into a5 (buffer)
	move.l	d0,d5				; move d0 into d5 (length)
	lea.l	txt_dosbase,a0		; move txt_dosbase address into a0
	move.l	(a0),a6				; move base pointer to DOS library into a6
	jsr	-60(a6)					; call (d0=file) = Output()
	move.l	d0,d1				; move d0 (file) into d1
	move.l	a5,d2				; move a5 (buffer) into d2
	move.l	d5,d3				; move d5 (length) into d3
	jsr	-48(a6)					; call (d0=returnedLength) = Write(d1=file,d2=buffer,d3=length)
								; in DOS library
	movem.l	(a7)+,d1-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine

opendos:					    ; opens the dos library. opendos()
	movem.l	d0-d7/a0-a6,-(a7)   ; push register values onto the stack
	clr.l	d0
	move.l	$4,a6
	lea.l	txt_dosname,a1
	jsr	-408(a6)			    ; call exec.library method d0 = OpenLibrary(a1,d0)
	lea.l	txt_dosbase,a1
	move.l	d0,(a1)
	movem.l	(a7)+,d0-d7/a0-a6   ; pop values from the stack into the registers
	rts                         ; return from subroutine

txt_dosname:
	dc.b	"dos.library",0     ; library name terminated by zero
txt_dosbase:
	dc.l	$0                  ; allocation for holding the base address of dos.library
	
	end

