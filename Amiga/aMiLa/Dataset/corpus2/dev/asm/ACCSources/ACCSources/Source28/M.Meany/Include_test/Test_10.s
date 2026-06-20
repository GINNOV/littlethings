
; Display Example 1. -- A Single Bitplane, Low Resolution, Display --

		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i
		include		Marks/Hardware/HW_Text.i

Main		FONTSCREEN	#bitplane
		lea		TestText,a0
		bsr		WriteText

; First, 'poke' address of bit plane into Copper list

		moveq.l		#4-1,d1			num planes - 1		
		move.l		#bitplane,d0		d0=addr of bitplane
		lea		CopPlanes,a0		a0->into Copper list

bpl_loop	move.w		d0,6(a0)		low word of address
		swap		d0
		move.w		d0,2(a0)		high word of address
		swap		d0
		add.l		#40*256,d0		addr of next plane
		addq.l		#8,a0			next pointer in list
		dbra		d1,bpl_loop

; d0 now holds address of colour data that follows bit plane data. Copy
; this into the Copper list

		move.l		d0,a0			a0->colour data
		moveq.l		#16-1,d0		num colours - 1
		lea		CopColours,a1		a1->into Copper list
colr_loop	move.w		(a0)+,2(a1)		copy colour
		addq.l		#4,a1			next register
		dbra		d0,colr_loop

; Enable bitplane and Copper DMA.

		move.w		#SETIT!DMAEN!COPEN!BPLEN,DMACON(a5)

; Now strobe the Copper list.

		move.l		#MyCopper,COP1LCH(a5)	address of list
		move.w		#0,COPJMP1(a5)		strobe Copper

; Wait for user to press the left mouse button

mouse		btst		#6,CIAAPRA
		bne.s		mouse

; And exit.

		rts


Font2		include		Source:M.Meany/Gfx/font8_2.i

TestText	dc.b		FFONT,1			font 1
		dc.b		FPOS,10,0		at ( 10,0 )
		dc.b		FCOLOUR,1		colour 1
		dc.b		FCENTER			centralise
		dc.b		'Hello World!'
		dc.b		FFONT,2			font 2
		dc.b		FPOS,10,10		at ( 10,10 )
		dc.b		FCOLOUR,5		colour 5
		dc.b		FCENTER			centralise
		dc.b		'Mark Here.',$0a,$0a
		dc.b		FCOLOUR,12
		dc.b		FCENTER			centralise
		dc.b		'Just trying out the font routines.',$0a
		dc.b		FCOLOUR,11
		dc.b		FMODE,BLEND		OR draw mode
		dc.b		FCENTER			centralise
		dc.b		"Hope they all work OK. If not it's",$0a
		dc.b		FCOLOUR,8
		dc.b		FMODE,SPLAT		AND draw mode
		dc.b		FCENTER			centralise
		dc.b		'a (*&^*^%)('
		
		dc.b		FEND			end of text
		
		even

;		***************************
;		*     CHIP Memory Data    *
;		***************************

		section		meme,DATA_C

;section		data custom,chip

MyCopper	CMOVE		DIWSTRT,$2c81		PAL -- 256 lines
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038		LoRes
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPL1MOD,$0000		No modulos
		CMOVE		BPL2MOD,$0000
		CMOVE		BPLCON0,$4200		4 bitplane & colour
		CMOVE		BPLCON1,$0000		No scrolling
		CMOVE		BPLCON2,$0000		Ignore priority

CopPlanes	CMOVE		BPL1PTH,0		Bit plane pointer
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0

CopColours	CMOVE		COLOR00,$0000		The colours will be
		CMOVE		COLOR01,$0000		filled in by the
		CMOVE		COLOR02,$0000		program!
		CMOVE		COLOR03,$0000
		CMOVE		COLOR04,$0000
		CMOVE		COLOR05,$0000
		CMOVE		COLOR06,$0000
		CMOVE		COLOR07,$0000
		CMOVE		COLOR08,$0000
		CMOVE		COLOR09,$0000
		CMOVE		COLOR10,$0000
		CMOVE		COLOR11,$0000
		CMOVE		COLOR12,$0000
		CMOVE		COLOR13,$0000
		CMOVE		COLOR14,$0000
		CMOVE		COLOR15,$0000

		CMOVE		COLOR00,$0000		black background
		CMOVE		COLOR01,$0fff		white foreground

		CEND					end of list

bitplane	dcb.b		40*256*4,$aa	40 bytes wide by 256 lines

; Below is a simple colour table, hand written.

		dc.w		$000,$d00,$f90,$ff0,$8e0,$0b1,$0bb,$bf0
		dc.w		$6fe,$61f,$91f,$f1f,$fac,$c80,$ccc,$fff

		end

		
