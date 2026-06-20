
; Sprite Example 3:	Using Sprite Macros

		incdir		Source:M.Meany/Include/hardware/
		include		hardware.i
		include		HW_Macros.i
		include		HW_Start.i
		include		HW_Sprites.i

; Stuff bitplane pointers into Copper list using a macro

Main		COPBPL		CopPlanes,bitplane,(320/8)*256,1

; Call routine that sets all sprite pointers to a blank sprite

		lea		SprtBase,a0
		bsr		SpritesOff

; Position sprite

		lea		Sprite1,a0
		bsr		SetSprPos

; Set sprite pointer 0 in copper list. Not that by omitting 3rd parameter,
;macro will assume SprtBase!

Break		SPRITEON	#0,#Sprite1		Turn sprite on

; Enable bitplane, Copper and sprite DMA.

		move.w		#SETIT!DMAEN!COPEN!BPLEN!SPREN,DMACON(a5)

; Now strobe the Copper list.

		move.l		#CopperList,COP1LCH(a5)	address of list
		move.w		#0,COPJMP1(a5)		strobe Copper

; Wait for user to press the left mouse button

mouse		btst		#6,CIAAPRA
		bne.s		mouse

; And exit.

		rts

;		***************************
;		*    Blank All Sprites	  *
;		***************************

; Entry		a0->SprBase for relevant Copper list

SpritesOff	move.l		#BlankSprite,d0		blank sprite
		moveq.l		#7,d1			sprite counter

_sprLoop	swap		d0			get high part of addr
		move.w		d0,2(a0)		into Copper list
		swap		d0			get low part of addr
		move.w		d0,6(a0)		into Copper list
		addq.l		#8,a0			bump Copper list ptr
		dbra		d1,_sprLoop
		
		rts


;		***************************
;		*	   Data    	  *
;		***************************

Sprite1		dc.w		201		X
		dc.w		96		Y
		dc.w		20		height
		dc.l		sprite1Data	address of data

;		***************************
;		*     CHIP Memory Data    *
;		***************************

		section		copper,data_c

CopperList	CMOVE		COLOR00,$0000		Black background

SprtBase	CMOVE		SPR0PTH,0		Sprite defs
		CMOVE		SPR0PTL,0
		CMOVE		SPR1PTH,0
		CMOVE		SPR1PTL,0
		CMOVE		SPR2PTH,0
		CMOVE		SPR2PTL,0
		CMOVE		SPR3PTH,0
		CMOVE		SPR3PTL,0
		CMOVE		SPR4PTH,0
		CMOVE		SPR4PTL,0
		CMOVE		SPR5PTH,0
		CMOVE		SPR5PTL,0
		CMOVE		SPR6PTH,0
		CMOVE		SPR6PTL,0
		CMOVE		SPR7PTH,0
		CMOVE		SPR7PTL,0
		
		CMOVE		DIWSTRT,$2c81		PAL -- 256 lines
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038		LoRes
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPL1MOD,$0000		No modulos
		CMOVE		BPL2MOD,$0000
		CMOVE		BPLCON0,$1200		1 bitplane & colour
		CMOVE		BPLCON1,$0000		No scrolling
		CMOVE		BPLCON2,$0000		Ignore priority

CopPlanes	CMOVE		BPL1PTH,0		Bit plane pointer
		CMOVE		BPL1PTL,0

		CMOVE		COLOR00,$0000		black background
		CMOVE		COLOR01,$0fff		white foreground
		CMOVE		COLOR16,$0000		black
		CMOVE		COLOR17,$0fff		white
		CMOVE		COLOR18,$000d		blue
		CMOVE		COLOR19,$0e00		red
		
		CEND					end of list

bitplane	ds.b		40*256		40 bytes wide by 256 lines

BlankSprite	dc.w		0,0		non-exsistent sprite!

; Sprite Data for 4 colour sprite, width=16, height=20

sprite1Data	dc.w		0 		1st control word
		dc.w		0 		2nd control word
	
		dc.w		$0000,$0180	Line 1
		dc.w		$0000,$0FF0	Line 2
		dc.w		$0000,$1FF8	Line 3
		dc.w		$0000,$3FFC	Line 4
		dc.w		$0000,$FFFF	Line 5
		dc.w		$0000,$F81F	Line 6
		dc.w		$0240,$3E7C	Line 7
		dc.w		$0000,$3FFC	Line 8
		dc.w		$0000,$7FFE	Line 9
		dc.w		$07E0,$FFFF	Line 10
		dc.w		$1FF8,$FFFF	Line 11
		dc.w		$3E7C,$FE7F	Line 12
		dc.w		$399C,$799E	Line 13
		dc.w		$3C3C,$3C3C	Line 14
		dc.w		$0FF0,$0FF0	Line 15
		dc.w		$07E0,$07E0	Line 16
		dc.w		$07E0,$07E0	Line 17
		dc.w		$03C0,$03C0	Line 18
		dc.w		$03C0,$03C0	Line 19
		dc.w		$0000,$0000	Line 20

		dc.l		0		next sprite pointer


;		end

		
