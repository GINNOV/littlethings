; mc1005.s								; scrolltext read text from a textfile
; from disk1/brev10
; explanation on letter_10 p. 12
; from Mark Wrobel course letter 28	
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1005.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>font
; BEGIN>font
; END>
; SEKA>wo
; MODE>c		; chip-RAM
; FILENAME>scroll
; SEKA>

; start program from CLI
; >scroll text			  ; text is a file with a text inside, the text ends with a * (asterisk) !!!			

start:					  ; comments from Mark Wrobel		
	cmp.w	#1,d0         ; compare d0 (CLI argument lenght) with 1
	bgt	argok			  ; if d0 > 1 then go to argok (we ignore carriage return)

	rts                   ; return from subroutine (no arguments)

argok:					  ; arguments present
	lea.l	filename,a1   ; move filename address into a1

copyargloop:			  ; copy arguments to a1 (filename)
	move.b	(a0)+,(a1)+   ; move arguments that a0 points at, to what a1 points at, then post increment
	subq.w	#1,d0         ; subtract d0 (argument length) by 1
	cmp.w	#1,d0         ; compare d0 with 1 (have we reached the end?)
	bne	copyargloop		  ; if d0 > 1 go to copyargloop

	move.l	#50000,d0     ; move 50000 to d0 (number of bytes to allocate)
	bsr	allocdef		  ; branch to subroutine allocdef. d0 = allocdef(d0)

	cmp.l	#0,d0         ; compare d0 with 0 (check return value from allocdef)
	bne	memok			  ; if d0 != 0 then goto memok

	rts                   ; return from subroutine (memory error)

memok:					  ; memory ok
	lea.l	buffer,a1     ; move buffer address into a1
	move.l	d0,(a1)       ; move d0 (points to allocated memory) into address pointed to by a1 (buffer)

	lea.l	filename,a0   ; move filename address into a0
	move.l	d0,a1         ; move d0 (points to allcoated memory) into a1
	move.l	#50000,d0     ; move 50000 into d0

	bsr	readfile		  ; branch to subroutine readfile. d0 = readfile(a0,a1,d0)

	cmp.l	#0,d0         ; compare d0 with 0 (check return value from readfile)
	beq	freeup			  ; if d0 = 0 then goto freeup (no bytes were read)

	move.w	#$4000,$dff09a        

	or.b	#%10000000,$bfd100
	and.b	#%10000111,$bfd100

	move.w	#$01a0,$dff096

	move.w	#$1200,$dff100
	move.w	#0,$dff102
	move.w	#0,$dff104
	move.w	#2,$dff108
	move.w	#2,$dff10a
	move.w	#$2c71,$dff08e
	move.w	#$f4d1,$dff090
	move.w	#$38d1,$dff090
	move.w	#$0030,$dff092
	move.w	#$00d8,$dff094

	lea.l	screen,a1
	lea.l	bplcop,a2
	move.l	a1,d1
	swap	d1
	move.w	d1,2(a2)
	swap	d1
	move.w	d1,6(a2)

	lea.l	copper,a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

mainloop:
	move.l	$dff004,d0
	asr.l	#8,d0
	and.l	#$1ff,d0
	cmp.w	#300,d0
	bne	mainloop

	bsr	scroll

	btst	#6,$bfe001
	bne	mainloop

freeup:					   ; free memory
	move.l	#50000,d0      ; move 50000 into d0 (50000 bytes)
	lea.l	buffer,a0      ; move buffer address into a0
	move.l	(a0),a0        ; move value in a0 (points to allocated memory) into a0
	bsr	freemem			   ; branch to subroutine freemem. freemem(a1,d0)

	move.w	#$0080,$dff096

	move.l	$04,a6
	move.l	156(a6),a1
	move.l	38(a1),$dff080

	move.w	#$80a0,$dff096

	move.w	#$c000,$dff09a
	rts

scrollcnt:
	dc.w	$0000

charcnt:
	dc.w	$0000

scroll:
	lea.l	scrollcnt,a1
	cmp.w	#8,(a1)
	bne	nochar

	clr.w	(a1)

	lea.l	charcnt,a1
	move.w	(a1),d1
	addq.w	#1,(a1)

	lea.l	buffer,a2     ; move buffer address into a2
	move.l	(a2),a2       ; move value in a2 (points to allocated memory) into a2
	clr.l	d2
	move.b	(a2,d1.w),d2

	cmp.b	#42,d2
	bne	notend

	clr.w	(a1)
	move.b	#32,d2

notend:
	lea.l	convtab,a1
	move.b	(a1,d2.b),d2
	asl.w	#1,d2

	lea.l	font,a1
	add.l	d2,a1

	lea.l	screen,a2
	add.l	#6944,a2

	moveq	#19,d0

putcharloop:
	move.w	(a1),(a2)
	add.l	#64,a1
	add.l	#46,a2
	dbra	d0,putcharloop

nochar:
	btst	#6,$dff002
	bne	nochar

	lea.l	screen,a1
	add.l	#7820,a1

	move.l	a1,$dff050
	move.l	a1,$dff054
	move.w	#0,$dff064
	move.w	#0,$dff066
	move.l	#$ffffffff,$dff044
	move.w	#$29f0,$dff040
	move.w	#$0002,$dff042
	move.w	#$0517,$dff058   ; changed from #$0523 to #$0517 by me (I suspect an error)

	lea.l	scrollcnt,a1
	addq.w	#1,(a1)

	rts

readfile:				     ; the readfile subroutine (described elsewhere)
	movem.l	d1-d7/a0-a6,-(a7)
	move.l	a0,a4
	move.l	a1,a5
	move.l	d0,d5
	move.l	$4,a6
	lea.l	r_dosname,a1
	jsr	-408(a6)
	move.l	d0,a6
	move.l	#1005,d2
	move.l	a4,d1
	jsr	-30(a6)
	cmp.l	#0,d0
	beq	r_error
	move.l	d0,d1
	move.l	d0,d7
	move.l	a5,d2
	move.l	d5,d3
	jsr	-42(a6)
	move.l	d7,d1
	move.l	d0,d7
	jsr	-36(a6)
	move.l	d7,d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts

r_error:						  ; handle readfile error
	clr.l	d0                    ; clear d0
	movem.l	(a7)+,d1-d7/a0-a6     ; pop values from the stack into the registers
	rts                           ; return from subroutine
r_dosname:
	dc.b	"dos.library",0       ; library name terminated by zero

allocdef:						  ; the allocdef subroutine (described elsewhere)
	movem.l	d1-d7/a0-a6,-(a7)
	moveq	#1,d1
	swap	d1
	move.l	$4,a6
	jsr	-198(a6)
	movem.l	(a7)+,d1-d7/a0-a6
	rts

freemem:                          ; the freemem subroutine (described elsewhere)
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	a0,a1
	move.l	$4,a6
	jsr	-210(a6)
	movem.l	(a7)+,d0-d7/a0-a6
	rts

copper:
	dc.w	$2c01,$fffe
	dc.w	$0100,$1200

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$0180,$0000
	dc.w	$0182,$0ff0

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe

screen:
	blk.l	$b80,0

font:
	blk.l	$140,0

convtab:
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1f ;" "
	dc.b	$00
	dc.b	$00
	dc.b	$1b ;Ø
	dc.b	$1c ;Å
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1d ;,
	dc.b	$00 ;-
	dc.b	$1e ;.
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$00
	dc.b	$1a ;Æ
	dc.b	$00 ;A
	dc.b	$01 ;B
	dc.b	$02 ;C
	dc.b	$03 ;...
	dc.b	$04
	dc.b	$05
	dc.b	$06
	dc.b	$07
	dc.b	$08
	dc.b	$09
	dc.b	$0a
	dc.b	$0b
	dc.b	$0c
	dc.b	$0d
	dc.b	$0e
	dc.b	$0f
	dc.b	$10
	dc.b	$11
	dc.b	$12
	dc.b	$13
	dc.b	$14
	dc.b	$15
	dc.b	$16 ;....
	dc.b	$17 ;X
	dc.b	$18 ;Y
	dc.b	$19 ;Z
	dc.b	$00
	dc.b	$00
	dc.b	$00

buffer:
	dc.l	0      ; holds the pointer to the allocated buffer (holds contents of file)

filename:
	blk.b	50,0   ; the filename
	
	end

