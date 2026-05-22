
; Sprite structure

spr_X		equ		0
spr_Y		equ		2
spr_H		equ		4
spr_Data	equ		6
spr_Anim	equ		10
spr_Frame	equ		14
spr_Timer	equ		16

; Animation structure

sanim_Timer	equ		0
sanim_Count	equ		2
sanim_Frame1	equ		4

; Macro for turning a sprite channel on

SPRITEON	macro		num,SprtStruct {,SprtBase}

		move.l		\1,d0
		asl.w		#3,d0			x8
		move.l		\2,a0
		move.l		spr_Data(a0),d1

		IFNC		'','\3'
		move.l		\3,a0
		ENDC

		IFC		'','\3'
		lea		SprtBase,a0
		ENDC

		move.w		d1,6(a0)
		swap		d1
		move.w		d1,2(a0)
		
		endm

		*********************************
		*  Build Sprite Control Words	*
		*********************************

; Entry		a0->Custom sprite structure

; Exit		d0= sprite position data control words

; Corrupt	d0

; A mere 70 bytes of code, ahhhh :-)

; NOTE: If using attached sprites, set attach bit after calling this routine
;and prior to writing the control word into the sprite structure.

SetSprPos	movem.l		d1-d4/a0-a3,-(sp)

		moveq.l		#0,d0			clear register
		move.l		d0,d1

; Get sprite Y start into d0 and Y stop into D2
		
		move.w		spr_Y(a0),d0
		move.w		d0,d2
		add.w		spr_H(a0),d2		last line + 1

; Get lowest 8 bits of Y start into high byte of d0.w

		asl.w		#8,d0

; Obtain highest 8 bits of X start and combine with Y start

		move.w		spr_X(a0),d1
		asr.w		#1,d1
		or.b		d1,d0

; d0 now contains 1st control word, move into highest word

		swap		d0

; Get lowest 8 bits of Y stop into highest byte of d1.w

		move.w		d2,d1
		rol.w		#8,d1

; Now to set lowest 3 bits of d1!

		asl.b		#1,d1			set bit 1 to L8
		cmp.w		#255,spr_Y(a0)		Y > 255 ?
		ble.s		.NoE8			nope, skip!
		bset		#2,d1			yep, set bit!

.NoE8		move.w		spr_X(a0),d0
		and.w		#1,d0
		beq.s		.NoH0
		bset		#0,d1

; Combine low word of d1 ( the odd bits ) with d0 ( Y start, X start )

.NoH0		move.w		d1,d0

; Get current control words, mask out all but attach bit, combine with new
;control words and write back to sprite.

		move.l		spr_Data(a0),a0		a0->sprite struct
		move.l		(a0),d1
		and.w		$0080,d1
		or.w		d1,d0
		move.l		d0,(a0)

; All done so exit!
 
		movem.l		(sp)+,d1-d4/a0-a3
		rts

