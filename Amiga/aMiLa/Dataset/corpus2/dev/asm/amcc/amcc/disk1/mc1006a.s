; mc1006a.s						; write on a disk
; from disk1/brev10
; explanation on letter_10 p. 15
; from Mark Wrobel course letter 30
	
; create standard floppy disk (empty) "diskname.adf"
; df0: insert "diskname.adf"

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1006a.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j	; after execution:
			; you can ckeck with a hex-editor the content of diskname.adf
			; the result on byte: 200: "This is a test"	

start:							; comments from Mark Wrobel	
	lea.l	buffer,a0			; move buffer address into a0
	move.l	#0,d0				; move 0 into d0 (diskStation = internal drive)
	move.l	#1,d1				; move 1 into d1 (block = block 1)			; the result on byte 200 of diskname.adf: "This is a test"	
	;move.l	#100,d1				; move 100 into d1 (block = block 100)		; original
	move.l	#1,d2				; move 1 into d2 (length = 1)
	move.l	#2,d3				; move 2 into d3 (mode = WRITE)
	bsr	sector
	move.l	#3,d3				; move 3 into d3 (mode = UPDATE)
	bsr	sector
	rts							; return from subroutine

sector:							; sector(a0,d0,d1,d2,d3)
	movem.l	d0-d7/a0-a6,-(a7)	; push register values onto the stack
	lsl.l	#8,d1				; left shift d1 8 bit. convert to offset in bytes
	add.l	d1,d1				; add d1 to d1. convert to offset in bytes
	lsl.l	#8,d2				; left shift d2 8 bit. convert to length in bytes
	add.l	d2,d2				; add d2 to d2. convert to length in bytes
	move.l	d1,-(a7)			; push d1 onto the stack (block)
	move.l	d2,-(a7)			; push d2 onto the stack (length)
	move.l	a0,-(a7)			; push a0 onto the stack (buffer)
	move.l	d0,-(a7)			; push d0 onto the stack (diskStation)
	move.l	$4,a6				; move base of exec.library into a6
	lea.l	ws_diskport,a2		; move ws_diskport address into a2
	moveq	#-1,d0				; move -1 into d0 (no preference for signal number)
	jsr	-330(a6)				; call AllocSignal. d0 = AllocSignal(d0)
	moveq	#-1,d1				; move -1 into d1
	move.b	d0,15(a2)			; move d0 (signal number) into address a2+15
	clr.b	14(a2)				; clear byte at address a2+14
	move.b	#4,8(a2)			; move 4 into address 8+a2
	move.b	#120,9(a2)			; move 120 into address 9+a2
	sub.l	a1,a1				; set a1 to 0 (find oneself)
	jsr	-294(a6)				; call FindTask. d0 = FindTask(a1)
	move.l	d0,16(a2)			; move task into address 16+a2
	lea.l	20(a2),a0			; move value in address 20+a2 into a0
	move.l	a0,(a0)				; move a0 into address a0
	addq.l	#4,(a0)				; add 4 to value in address a0
	clr.l	4(a0)				; clear long in address 4+a0
	move.l	a0,8(a0)			; move a0 into address 8+a0
	lea.l	ws_diskreq,a1		; move ws_diskreq address into a1 (IOStdReq)
	move.b	#$05,8(a1)			; move 5 into address 8+a1. NT_MESSAGE indicates message currently pending
	move.l	a2,14(a1)			; move a2 into address 14+a1. Pointer to MsgPort
	lea.l	ws_devicename,a0	; move ws_devicename address into a0 (devName)
	move.l	(a7)+,d0			; pop stack into register d0 (diskStation)
	clr.l	d1					; clear d1 (flags, 0 for opening)
	jsr	-444(a6)				; call OpenDevice. d0 = OpenDevice(a0,d0,a1,d1)
	move.l	(a7)+,40(a1)		; pop stack into address 40+a1 (buffer)
	andi.l	#3,d3				; preserve first 3 bits in d3. Map mode to command
	addq.w	#1,d3				; add 1 to d3. Map mode to command
	move.w	d3,28(a1)			; move d3 into address 28+a1. Set the command
	move.l	(a7)+,36(a1)		; pop stack into address 36+a1 (length)
	move.l	(a7)+,44(a1)		; pop stack into address 44+a1 (block)
	jsr	-456(a6)				; call DoIO. d0 = DoIO(a1)
	move.l	d0,d7				; move d0 (error) into d7
	move.l	#0,36(a1)			; move 0 into address 36+a1
	move.w	#$9,28(a1)			; move 9 into address 28+a1
	jsr	-456(a6)				; call DoIO. d0 = DoIO(a1)
	movem.l	(a7)+,d0-d7/a0-a6	; pop values from the stack into the registers
	rts							; return from subroutine
ws_diskport:
	blk.l	100,0
ws_diskreq:
	blk.l	15,0
ws_devicename:
	dc.b	"trackdisk.device",0,0

buffer:
	dc.b	"This is a test"
	;blk.b 512,0

	end
