; mc1004.s		; execution from CLI: prints the arguments
; from disk1/brev10
; explanation on letter_10 p. 10
; from Mark Wrobel course letter 28
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1004.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>wo
; MODE>c						; c - chip-RAM
; FILENAME>mc1004o				; o for object - (w, wo) only for security

; start program from CLI
; >mc1004o hallo 	; with arguments
		
start:							; comments from Mark Wrobel	
	cmp.w	#1,d0				; compare 1 with d0 (argument length from CLI)
	ble	noarg					; if d0 <= 1, then goto noarg

	lea.l	argbuffer,a1		; move argbuffer address into a1
	move.l	d0,d7				; move d0 into d7

copyarg:						; copy argument
	move.b	(a0)+,(a1)+			; move value pointed to by a0 into argbuffer and post increment both
	subq.w	#1,d0				; subtract 1 from argument length
	cmp.w	#0,d0				; compare d0 with zero - we leave the last argument character since it's just a return
	bne	copyarg					; if d0 != 0 then goto copyarg

	bsr	opendos					; branch to subroutine opendos
	move.l	d7,d0				; move d7 into d0 (restore argument length)
	lea.l	argbuffer,a0		; move argbuffer address into a0
	bsr	writechar				; branch to subroutine writechar

	rts							; return from subroutine

noarg:							; handling that no arguments was entered in CLI
	rts							; return from subroutine

argbuffer:
	blk.b	80,0				; allocate 80 bytes to argbuffer

writechar:					   ; writechar subroutine. writechar(a0,d0)
	movem.l	d1-d7/a0-a6,-(a7)  ; push register values onto the stack
	move.l	a0,a5              ; move a0 (argbuffer) into a5
	move.l	d0,d5              ; move d0 (arg length) into d5
	lea.l	txt_dosbase,a0     ; move txt_dosbase address into a0 (contains base address of dos.library)
	move.l	(a0),a6            ; move base address of dos.library into a6
	jsr	-60(a6)				   ; call Output in dos.library. d0 = output()
	move.l	d0,d1              ; move d0 (filehandle) into d1
	move.l	a5,d2              ; move a5 (argbuffer) into d2
	move.l	d5,d3              ; mvoe d5 (arg length) into d3
	jsr	-48(a6)				   ; call Write in dos.library. d0 = Write(d1,d2,d3)
	movem.l	(a7)+,d1-d7/a0-a6  ; pop values from the stack into the registers
	rts                        ; return from subroutine

opendos:					   ; opendos subroutine. opendos()
	movem.l	d0-d7/a0-a6,-(a7)  ; push register values onto the stack
	clr.l	d0                 ; clear d0
	move.l	$4,a6              ; move base pointer of exec.library into a6
	lea.l	txt_dosname,a1     ; move pointer to library name into a1
	jsr	-408(a6)			   ; call OpenLibrary in the exec.library. d0 = OpenLibrary(a1,d0)
	lea.l	txt_dosbase,a5     ; move address of txt_dosbase into a5
	move.l	d0,(a5)            ; move dos.library base address into txt_dosbase
	movem.l	(a7)+,d0-d7/a0-a6  ; pop values from the stack into the registers
	rts                        ; return from subroutine

txt_dosname:
	dc.b	"dos.library",0    ; library name terminated by zero
	txt_dosbase:
	dc.l	$0                 ; allocation for holding the base address of dos.library

	end
