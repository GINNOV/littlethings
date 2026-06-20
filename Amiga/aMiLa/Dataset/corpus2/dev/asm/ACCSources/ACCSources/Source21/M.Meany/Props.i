
;--------------
;--------------	Set the slider in a prop gadget to specified position
;--------------

* Entry		a0->Proportional gadget structure
;		a1->Window structure
;		d0=value to set (word)
;		d1=range (high word) and start value (low word)

* Exit		None

* Corrupt	None

* Author	M.Meany

SetPropVal	movem.l		d0-d1/a0-a2,-(sp)	save

		move.l		gg_SpecialInfo(a0),a2	a2->PropInfo struct
		sub.w		d1,d0			correct value
		bpl.s		.InRange		skip if in range
		moveq.l		#0,d0			else set to 0
.InRange	mulu		#$ffff,d0		x numerator
		swap		d1			d1=range
		divu		d1,d0			div by denominator
		move.w		d0,pi_HorizPot(a2)	set pot value
		suba.l		a2,a2			not a requester
		moveq.l		#1,d0			1 gadget to rethink
		CALLINT		RefreshGList		display it
		
		movem.l		(sp)+,d0-d1/a0-a2	restore
		rts

;--------------
;--------------	Get the value represented by a prop gadget
;--------------

* Function	Examines a prop gadget and returns the value it represents.

* Entry		a0->Gadget
;		d1=Start,Range of value represented

* Exit		d0=value represented

* Corrupted	d0,d1,a0

* Author	M.Meany


GetPropVal	move.l		gg_SpecialInfo(a0),a0	a0->PropInfo struct
		moveq.l		#0,d0			clear
		move.w		pi_HorizPot(a0),d0	get setting
		mulu		d1,d0			calc actual
		divu		#-1,d0			div by max value
		and.l		#$ffff,d0		mask off remainder
		
		move.w		#0,d1			clear range
		swap		d1			get start value
		add.l		d1,d0			add start to value
		
		rts

