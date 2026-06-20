
		rsreset
spr_X		rs.w		1	display X position ( 0<= x <= 320 )
spr_Y		rs.w		1	display Y position ( 0<= y <= 256 )
spr_Height	rs.w		1	Height of sprite
spr_Data	rs.l		1	pointer to CHIP mem data structure
spr_Size	rs.b		0	size of structure


		*********************************
		*  Build Sprite Control Words	*
		*********************************

; Entry		a0->Custom sprite structure

; Exit		d0= sprite position data control words

; Corrupt	d0

; A mere 70 bytes of code, ahhhh :-)

; NOTE: If using attached sprites, set attach bit after calling this routine
;and prior to writing the control word into the sprite structure.

SprPos		movem.l		d1-d4/a0-a3,-(sp)

		moveq.l		#0,d0			clear register
		move.l		d0,d1

; Get sprite Y start into d0 and Y stop into D2
		
		move.w		spr_Y(a0),d0
		move.w		d0,d2
		add.w		spr_Height(a0),d2	last line + 1

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

; All done so exit!
 
.done		movem.l		(sp)+,d1-d4/a0-a3
		rts
