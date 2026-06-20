
		LIST
*** Text.i v1.00, by M.Meany ***
		NOLIST



; Entry		a0->text string

; Exit		a0->terminating position in text string

;		note: if (a0)=0 then end of text was reached, otherwise a
;		      soft exit was reached, meaning that the routine should
;		      be called again, ie during the next vbl, with the addr
;		      returned.

; Corrupt	a0.

WriteText	movem.l		d0-d7/a1-a6,-(sp)

		tst.b		(a0)		valid string?
		beq		fnt_Done	no, exit!

		move.l		a0,a5		a5->next character
		move.l		_FontData,a4	a4->font gfx data

fnt_NextChar	move.l		_FontBpl,a3	a3->dest bit plane
		moveq.l		#0,d5		clear register
		move.b		(a5)+,d5	get next character
		cmp.b		#' ',d5		is it a control character?
		blt		fnt_Control	yep, go and check it!
		cmp.b		#'~',d5		is it out of range?
		bgt.s		fnt_NextChar	yep, ignore it!

; If we get this far it is a printable character, start by finding address
;of the font graphics.

		sub.b		#' ',d5		sub code for a space
		asl.w		#3,d5		x8
		add.l		a4,d5		add font start address
		move.l		d5,a2		a2->character gfx 	

; Now calculate bit plane offset

		moveq.l		#0,d4		clear work registers
		move.l		d4,d0
		move.w		_FontCurX,d4	get pixel offset
		asr.w		#3,d4		/8 for byte position
		move.w		_FontCurY,d0	get line number
		mulu		_BplW,d0	x bytes per line
		add.l		d0,d4		d4 = offset

; Finaly arrange a loop to copy character gfx into required bitplanes

		moveq.l		#1,d3		bit plane comparitor
		moveq.l		#0,d7
		move.l		d7,d1
		move.w		_BplD,d7	get number of bit planes
		sub.l		d3,d7		adjust for dbra counter
		bmi		fnt_CopyDone	exit if negative = error


		move.l		_FontMode,a0	get address of draw routine
		jsr		(a0)		and call it
		
; This character has been copied, update x,y positions. X is bumped by one
;character position, if past end of bit plane a line feed is done.

		move.w		_BplW,d1
		subq.l		#1,d1		max X position
		move.w		_FontCurX,d0
		addq.l		#8,d0
		asr.w		#3,d0		bump X
		cmp.w		d0,d1		out of range?
		bge.s		fnt_DoneXY	no, continue.

; End of line. Bump Y position and reset X to start of line.

		moveq.l		#0,d0		reset X
		move.w		_BplH,d1
		subq.l		#8,d1		max Y value
		move.w		_FontCurY,d2
		addq.w		#8,d2		bump Y
		cmp.w		d2,d1		out of range?
		blt.s		fnt_DoneXY	yes, don't bump
		move.w		d2,_FontCurY	else bump Y proper

; Save new X position and loop for next character

fnt_DoneXY	asl.w		#3,d0		back to pixel coords
		move.w		d0,_FontCurX	and save
fnt_CopyDone	tst.w		_FontToggle	in 1 char mode?
		bne.s		fnt_Done	yes! exit now
		bra		fnt_NextChar	no! print next character

;******** Here we start dealing with recognised control characters *********

; Check end of text

fnt_Control	moveq.l		#0,d0			clear work register

		cmp.b		#$00,d5			00 - terminate
		bne.s		fnt_Soft
		
fnt_Done	move.l		a5,a0
		movem.l		(sp)+,d0-d7/a1-a6
		rts

fnt_Soft	cmp.b		#01,d5			01 - Soft Exit
		beq.s		fnt_Done
		
		cmp.b		#02,d5			02 - Change Colour
		bne.s		fnt_ChangeXY
		move.b		(a5)+,d0
		move.w		d0,_FontColr
		bra		fnt_NextChar

fnt_ChangeXY	cmp.b		#03,d5			03 - New X,Y position
		bne.s		fnt_ChangeFont
		move.l		d0,d1
		move.b		(a5)+,d0		new X -- in bytes
		bmi.s		fnt_ChangeXY2		skip if negative

; make sure new X is in range before using it. If not set to zero

		cmp.w		_BplW,d0
		ble.s		fnt_ChangeXY1
		moveq.l		#0,d0

fnt_ChangeXY1	asl.w		#3,d0			convert to pixel pos
		move.w		d0,_FontCurX		and set

fnt_ChangeXY2	move.b		(a5)+,d1		new Y
		bmi.s		fnt_ChangeXY4		skip if negative
		
; Make sure bew Y is in range before using it. If not set to zero

		move.w		_BplH,d0
		subq.w		#8,d0
		cmp.w		d0,d1
		ble.s		fnt_ChangeXY3
		moveq.l		#0,d1

fnt_ChangeXY3	move.w		d1,_FontCurY
fnt_ChangeXY4	bra		fnt_NextChar

fnt_ChangeFont	cmp.w		#04,d5			04 - Change Fonts
		bne.s		fnt_EOL
		
		move.b		(a5)+,d0
		cmpi.b		#8,d0
		bgt		fnt_NotControl
		subq.w		#1,d0			font number
		asl.w		#2,d0			x4
		add.l		#_Font1Ptr,d0
		move.l		d0,a0
		move.l		(a0),a4
		move.l		a4,_FontData
		bra		fnt_NextChar

fnt_EOL		cmp.b		#10,d5			10 - Line Feed
		bne.s		fnt_Justify

		move.w		d0,_FontCurX	reset X
		move.w		_BplH,d1
		subq.l		#8,d1		max Y value
		move.w		_FontCurY,d2
		addq.w		#8,d2		bump Y
		cmp.w		d2,d1		out of range?
		blt.s		fnt_EOL1	yes, don't bump
		move.w		d2,_FontCurY	else bump Y proper

fnt_EOL1	bra		fnt_NextChar

; To justify a line of text. Text must start at next character and terminates
;at next character $0a, $0, $03 byte.

fnt_Justify	cmp.b		#5,d5			05 - Centralise text
		bne		fnt_NewMode
		
		move.l		d0,d1
		move.l		a5,a0		working copy
		
fnt_JustLoop	move.b		(a0)+,d1	get next character
		beq		fnt_Just1	exit loop if end of text
		
		cmp.b		#3,d1		exit if new X,Y specified
		beq		fnt_Just1
		
		cmp.b		#$0a,d1		exit if line feed reached
		beq.s		fnt_Just1
		
		cmp.b		#' ',d1		dont count char if not ASCII
		blt.s		fnt_JustLoop
		cmp.b		#'~',d1
		bgt.s		fnt_JustLoop
		
		addq.w		#1,d0		bump counter
		bra.s		fnt_JustLoop	and loop

; End of text found

fnt_Just1	move.w		_BplW,d1	bytes per line
		sub.w		d0,d1		- length of text
		bmi.s		fnt_Just2	exit if it don't fit
		asr.w		#1,d1		/2 = pad bytes
		asl.w		#3,d1		x8 = pixel position
		move.w		d1,_FontCurX	set pen position

fnt_Just2	bra		fnt_NextChar

fnt_NewMode	cmp.b		#6,d5			06 - New Mode
		bne.s		fnt_Toggle
		
		lea		fnt_Mode1,a0	default to mode 0
		move.b		(a5)+,d0	get mode ( 0 or 1 )
		beq		fnt_IsM0
		subq.b		#1,d0
		bne.s		fnt_IsM0	if invalid mode default to 0
		lea		fnt_Mode2,a0	set mode 1
		

fnt_IsM0	move.l		a0,_FontMode	set new draw mode
		bra		fnt_NextChar

fnt_Toggle	cmp.b		#7,d5			07 - 1 char mode
		bne.s		fnt_StrMod
		move.w		#1,_FontToggle		toggle mode
		bra		fnt_NextChar

fnt_StrMod	cmp.b		#8,d5			08 - String Mode
		bne.s		fnt_NotControl
		move.w		#0,_FontToggle
		bra		fnt_NextChar

fnt_NotControl	bra		fnt_NextChar

;		*************************
;		* Straight Forward Copy *
;		*************************

; Copies a character into bitplanes wiping whatever was there to start with.

; Entry		a2->character gfx
;		a3->start of 1st bit plane

;		d1=0, always!
;		d3=bit plane comparitor
;		d4=offset into bit plane
;		d7=bit plane counter

fnt_Mode1	move.l		a2,a0		a0->character gfx

		move.w		d3,d0		get comparitor
		and.w		_FontColr,d0	this plane needed ?
		bne.s		fnt_CopyGfx	yep, get on with it
		lea		_FontBlank,a0	nope, wipe the plane

fnt_CopyGfx	move.w		_BplW,d1	bit plane width
		move.l		a3,a1
		add.l		d4,a1		a1->bit plane address
		
		move.b		(a0)+,(a1)	copy line 1
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 2
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 3
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 4
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 5
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 6
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 7
		add.l		d1,a1
		move.b		(a0)+,(a1)	copy line 8

fnt_CopyNext	asl.w		#1,d3		move comparitor bit
		move.w		_BplSize,d0
		adda.l		d0,a3		bump to next bit plane
		dbra		d7,fnt_Mode1	for all bit planes
		rts

;		************************
;		* Non-Destructive Copy *
;		************************

; Or's a character into bitplanes.

; Entry		a2->character gfx
;		a3->start of 1st bit plane
;		d1=0, always!
;		d3=bit plane comparitor
;		d4=offset into bit plane
;		d7=bit plane counter

fnt_Mode2	move.l		a3,a1		a1->1st bit plane
		add.l		d4,a1	
		move.l		d7,d1		counter

; First etch a mask into every plane

fnt_DoMask	move.l		a2,a0
		moveq.l		#0,d2
		move.w		_BplW,d2	plane width

		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer
		move.b		(a0)+,d0
		not.b		d0
		and.b		(a1),d0
		move.b		d0,(a1)
		add.l		d2,a1		bump line pointer

		asl.w		#3,d2		x8
		sub.l		d2,a1		correct
		move.w		_BplSize,d2
		add.l		d2,a1		bump plane pointer
		dbra		d1,fnt_DoMask
		
; Now or the gfx into required planes

fnt_OrChar	move.l		a2,a0		a0->character gfx

		move.w		d3,d0		get comparitor
		and.w		_FontColr,d0	this plane needed ?
		beq.s		fnt_OrNext	nope, skip this plane

fnt_OrGfx	move.w		_BplW,d1	bit plane width
		move.l		a3,a1
		add.l		d4,a1		a1->bit plane address
		
		move.b		(a0)+,d0	copy line 1
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 2
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 3
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 4
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 5
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 6
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 7
		or.b		(a1),d0
		move.b		d0,(a1)
		add.l		d1,a1
		move.b		(a0)+,d0	copy line 8
		or.b		(a1),d0
		move.b		d0,(a1)

		

fnt_OrNext	asl.w		#1,d3		move comparitor bit
		move.w		_BplSize,d0
		adda.l		d0,a3		bump to next bit plane
		dbra		d7,fnt_OrChar	for all bit planes
		rts

;****************** Variables Used By The Font Routines *********************

_Font1Ptr	dc.l		_Font1		font gfx data pointers
_Font2Ptr	dc.l		_Font1
_Font3Ptr	dc.l		_Font1
_Font4Ptr	dc.l		_Font1
_Font5Ptr	dc.l		_Font1
_Font6Ptr	dc.l		_Font1
_Font7Ptr	dc.l		_Font1
_Font8Ptr	dc.l		_Font1
_FontData	dc.l		_Font1		current font gfx data address
_FontBpl	dc.l		0		bit plane start address
_FontColr	dc.w		3		colour to use
_FontCurX	dc.w		0		currnt pixel position
_FontCurY	dc.w		0		current line number
_FontMode	dc.l		fnt_Mode1	text drawing mode
_FontToggle	dc.w		0		set for 1 char per call
_BplW		dc.w		40		bit plane width in bytes
_BplH		dc.w		256		bit plane height in lines
_BplD		dc.w		4		display depth
_BplSize	dc.w		40*256		bit plane byte size
_FontBlank	dc.b		0,0,0,0,0,0,0,0	used to wipe a plane

_Font1		dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;" "
		dc.b	$18,$3C,$18,$18,$00,$18,$00,$00	;"!"
		dc.b	$36,$36,$6C,$00,$00,$00,$00,$00	;"""
		dc.b	$6C,$FE,$6C,$6C,$FE,$6C,$00,$00	;"#"
		dc.b	$10,$78,$D0,$7C,$16,$FC,$00,$00	;"$"
		dc.b	$C6,$CC,$18,$30,$66,$C6,$00,$00	;"%"
		dc.b	$38,$6C,$38,$6E,$6C,$3A,$00,$00	;"&"
		dc.b	$18,$18,$30,$00,$00,$00,$00,$00	;"'"
		dc.b	$1C,$30,$30,$30,$30,$1C,$00,$00	;"("
		dc.b	$38,$0C,$0C,$0C,$0C,$38,$00,$00	;")"
		dc.b	$00,$6C,$38,$FE,$38,$6C,$00,$00	;"*"
		dc.b	$00,$18,$18,$7E,$18,$18,$00,$00	;"+"
		dc.b	$00,$00,$00,$00,$18,$18,$30,$00	;","
		dc.b	$00,$00,$00,$7E,$00,$00,$00,$00	;"-"
		dc.b	$00,$00,$00,$00,$18,$18,$00,$00	;"."
		dc.b	$06,$0C,$18,$30,$60,$C0,$00,$00	;"/"
		dc.b	$3C,$66,$6E,$76,$66,$3C,$00,$00	;"0"
		dc.b	$18,$18,$38,$18,$18,$3C,$00,$00	;"1"
		dc.b	$3C,$06,$3C,$60,$62,$7E,$00,$00	;"2"
		dc.b	$7E,$4C,$18,$0C,$46,$7C,$00,$00	;"3"
		dc.b	$1C,$3C,$6C,$CC,$FE,$0C,$00,$00	;"4"
		dc.b	$7C,$60,$7C,$06,$4C,$78,$00,$00	;"5"
		dc.b	$3C,$60,$7C,$66,$66,$3C,$00,$00	;"6"
		dc.b	$7E,$46,$0C,$18,$30,$30,$00,$00	;"7"
		dc.b	$3C,$66,$3C,$66,$66,$3C,$00,$00	;"8"
		dc.b	$3C,$66,$66,$3E,$06,$0C,$18,$00	;"9"
		dc.b	$00,$18,$18,$00,$18,$18,$00,$00	;":"
		dc.b	$00,$18,$18,$00,$18,$18,$30,$00	;";"
		dc.b	$0C,$18,$30,$30,$18,$0C,$00,$00	;"<"
		dc.b	$00,$00,$7E,$00,$7E,$00,$00,$00	;"="
		dc.b	$30,$18,$0C,$0C,$18,$30,$00,$00	;">"
		dc.b	$7C,$46,$0C,$38,$00,$18,$00,$00	;"?"
		dc.b	$7C,$C6,$C6,$DE,$C0,$7E,$00,$00	;"@"
		dc.b	$3C,$66,$66,$7E,$66,$66,$00,$00	;"A"
		dc.b	$FC,$66,$7C,$66,$66,$FC,$00,$00	;"B"
		dc.b	$3C,$66,$60,$60,$66,$3C,$00,$00	;"C"
		dc.b	$F8,$6C,$66,$66,$66,$FC,$00,$00	;"D"
		dc.b	$FC,$64,$70,$60,$62,$FE,$00,$00	;"E"
		dc.b	$FE,$62,$78,$60,$60,$F0,$00,$00	;"F"
		dc.b	$7C,$C4,$C0,$CF,$C6,$7E,$00,$00	;"G"
		dc.b	$E7,$66,$7E,$66,$66,$E7,$00,$00	;"H"
		dc.b	$7E,$18,$18,$18,$18,$7E,$00,$00	;"I"
		dc.b	$3E,$26,$06,$06,$46,$7C,$00,$00	;"J"
		dc.b	$E6,$6C,$78,$78,$6C,$E6,$03,$00	;"K"
		dc.b	$F0,$60,$60,$60,$62,$FE,$00,$00	;"L"
		dc.b	$C6,$EE,$FE,$D6,$C6,$C6,$00,$00	;"M"
		dc.b	$E7,$76,$7E,$6E,$66,$E7,$00,$00	;"N"
		dc.b	$3C,$66,$66,$66,$66,$3C,$00,$00	;"O"
		dc.b	$F8,$6C,$66,$7C,$60,$F0,$00,$00	;"P"
		dc.b	$3C,$66,$66,$6E,$6C,$36,$00,$00	;"Q"
		dc.b	$F8,$6C,$66,$7E,$6C,$E6,$03,$00	;"R"
		dc.b	$3E,$60,$3C,$06,$86,$FC,$00,$00	;"S"
		dc.b	$FF,$5A,$18,$18,$18,$3C,$00,$00	;"T"
		dc.b	$66,$66,$66,$66,$66,$3C,$00,$00	;"U"
		dc.b	$66,$66,$66,$3C,$3C,$18,$00,$00	;"V"
		dc.b	$C6,$C6,$D6,$FE,$EE,$C6,$00,$00	;"W"
		dc.b	$E7,$66,$3C,$3C,$66,$E7,$00,$00	;"X"
		dc.b	$E7,$66,$3C,$18,$18,$3C,$00,$00	;"Y"
		dc.b	$FE,$8C,$18,$30,$62,$FE,$00,$00	;"Z"
		dc.b	$3C,$30,$30,$30,$30,$3C,$00,$00	;"["
		dc.b	$C0,$60,$30,$18,$0C,$06,$00,$00	;"\"
		dc.b	$3C,$0C,$0C,$0C,$0C,$3C,$00,$00	;"]"
		dc.b	$10,$38,$6C,$00,$00,$00,$00,$00	;"^"
		dc.b	$00,$00,$00,$00,$00,$00,$FE,$00	;"_"
		dc.b	$30,$30,$18,$00,$00,$00,$00,$00	;"`"
		dc.b	$00,$1C,$06,$3E,$66,$3F,$00,$00	;"a"
		dc.b	$E0,$60,$6C,$76,$66,$FC,$00,$00	;"b"
		dc.b	$00,$3C,$66,$60,$66,$3C,$00,$00	;"c"
		dc.b	$0E,$06,$36,$6E,$66,$3F,$00,$00	;"d"
		dc.b	$00,$3C,$66,$7C,$60,$3E,$00,$00	;"e"
		dc.b	$1C,$34,$30,$78,$30,$78,$00,$00	;"f"
		dc.b	$00,$37,$6E,$66,$3E,$06,$0C,$00	;"g"
		dc.b	$E0,$60,$6C,$76,$66,$E6,$00,$00	;"h"
		dc.b	$18,$00,$38,$18,$18,$18,$0C,$00	;"i"
		dc.b	$18,$00,$38,$18,$18,$30,$60,$00	;"j"
		dc.b	$E0,$64,$6C,$78,$6C,$E6,$00,$00	;"k"
		dc.b	$70,$60,$60,$60,$64,$3C,$00,$00	;"l"
		dc.b	$00,$CC,$FE,$D6,$C6,$C6,$00,$00	;"m"
		dc.b	$00,$6C,$76,$66,$66,$66,$00,$00	;"n"
		dc.b	$00,$3C,$66,$66,$66,$3C,$00,$00	;"o"
		dc.b	$00,$EC,$76,$66,$7C,$60,$C0,$00	;"p"
		dc.b	$00,$3F,$66,$6E,$36,$06,$03,$00	;"q"
		dc.b	$00,$76,$3A,$30,$30,$78,$00,$00	;"r"
		dc.b	$00,$3C,$60,$3C,$06,$FC,$00,$00	;"s"
		dc.b	$10,$30,$78,$30,$34,$1C,$00,$00	;"t"
		dc.b	$00,$66,$66,$66,$66,$3C,$00,$00	;"u"
		dc.b	$00,$66,$66,$3C,$3C,$18,$00,$00	;"v"
		dc.b	$00,$C6,$C6,$D6,$FE,$EC,$00,$00	;"w"
		dc.b	$00,$EE,$6C,$38,$6C,$EE,$00,$00	;"x"
		dc.b	$00,$EE,$6C,$38,$10,$38,$00,$00	;"y"
		dc.b	$00,$7C,$18,$30,$64,$FC,$00,$00	;"z"
		dc.b	$0E,$18,$30,$18,$18,$0E,$00,$00	;"{"
		dc.b	$18,$18,$18,$18,$18,$18,$00,$00	;"|"
		dc.b	$70,$18,$0C,$18,$18,$70,$00,$00	;"}"
		dc.b	$7C,$C6,$6C,$BA,$FE,$92,$38,$00	;"~"
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;""
	
