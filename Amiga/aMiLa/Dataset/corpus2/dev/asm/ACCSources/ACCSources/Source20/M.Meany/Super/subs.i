
; Subroutines for Map Builder program. Jan 92.

; Subroutine to move portion of playfield visible in window. No bounds
;checking is done, this should happen prior to calling this routine.

;Entry		d0=dx		x scroll value
;		d1=dy		y scroll value

SlideBitMap	suba.l		a0,a0		dummy = 0
		move.l		window.lyr,a1	a1->Layer
		CALLLAYERS	ScrollLayer	scroll bitmap
		rts				and return

; Subroutine to set up proportional gadgets correctly after a window has been
;resized ( also called when window first opened ).
; Stolen from RKM manual Libraries and Devices!

; Corrupts loads of registers: d0-d7,a0-a2/a5

DoNewSize	moveq.l		#0,d7			clear work registers
		move.l		window.lyr,a5		a5->Layers structure

; Check if window can be filled horizontally, if not reposition playfield

		move.l		d7,d0			clear it
		move.w		lr_Scroll_X(a5),d0	d0=X offset
		move.w		window.ptr,a0		a0->Window struct
		add.w		wd_GZZWidth(a0),d0	d0=width+offset
		cmp.w		#WidthSuper,d0		will it all fit?
		blt.s		.ok1			if so skip next bit

		neg.w		d0
		add.w		#WidthSuper,d0		dx
		move.l		d7,d1			dy
		bsr		SlideBitMap		correct position
		
; Set up parameters of NewModifyProp for horizontal gadget
; first then the required pointers

.ok1		lea		LeftRightGadg,a0	a0->gadget structure
		move.l		window.ptr,a1		a1->window
		suba.l		a2,a2			not a requester

;flags		
		move.l		#AUTOKNOB!FREEHORIZ,d0	flags
;horizPot
		move.w		lr_Scroll_X(a5),d1	playfield X offset
		mulu		#$ffff,d1		x MAXVAL
		move.l		#WidthSuper,d2		playfield width
		sub.w		wd_GZZWidth(a1),d2	- window width
		divu		d2,d1			d1=d1/d2 : HorizPot
		and.l		#$ffff,d1		mask out remainder
;vertPot
		move.l		d7,d2			VertPot
;horizBody
		move.w		wd_GZZWidth(a1),d3	window width
		mulu		#$ffff,d3		x MAXVAL
		divu		#WidthSuper,d3		/ by playfield width
		and.l		#$ffff,d3		mask out remainder
;vertBpody
		move.l		#$ffff,d4		MAXVAL
;number of gadgets
		moveq.l		#1,d5			only one gadget
;now modify it!
		CALLINT		NewModifyProp		update it
		
; Now check if window can be filled vertically, if not reposition playfield

		move.l		d7,d1			clear it
		move.w		lr_Scroll_Y(a5),d1	d1=Y offset
		move.w		window.ptr,a0		a0->Window struct
		add.w		wd_GZZHeight(a0),d1	d1=height+offset
		cmp.w		#HeightSuper,d1		will it all fit?
		blt.s		.ok2			if so skip next bit

		neg.w		d1
		add.w		#HeightSuper,d1		dy
		move.l		d7,d0			dx
		bsr		SlideBitMap		correct position

; Now for the vertical gadget

; first the requiredd pointers		

.ok2		lea		UpDownGadg,a0		a0->gadget structure
		move.l		window.ptr,a1		a1->window
		suba.l		a2,a2			not a requester

;flags		
		move.l		#AUTOKNOB!FREEVERT,d0	flags
;horizPot
		moveq.l		#0,d1			NULL
;vertPot
		move.w		lr_Scroll_Y(a5),d2	playfield Y offset
		mulu		#$ffff,d2		x MAXVAL
		move.l		#HeightSuper,d3		height of playfield
		sub.w		wd_GZZHeight(a1),d3	- window height
		divu		d3,d2			d2=d2/d3
		and.l		#$ffff,d2		mask off remainder
;horizBody
		move.l		#$ffff,d3		MAXVAL
;vertBody
		move.l		d3,d4			MAXVAL
		mulu		wd_GZZHeight(a1),d4	wdHeight*MAXVAL
		divu		#HeightSuper,d4		/ playfield height
		and.l		#$ffff,d4		mask off remainder
;NumGad
		moveq.l		#1,d5			just one gadget
		
		CALLINT		NewModifyProp		and update it
		
		rts

; Subroutine that deals with proportional gadgets.

; If a prop gadget is active, PropGadgSub will hold addr of subroutine to
;call to deal with this gadget. All such subroutines must return a value in
;register d2:

;	d2=	     dy           dx
;		< HIGH WORD >< LOW WORD >

; This return is used to slide the playfield through the window when
;required ( ie. User is moving the slider ).

CheckPropGadg	move.l		PropGadgSub,d0		get addr of subroutine
		beq.s		.error			if not there quit
		
		move.l		d0,a0			a0->subroutine
		jsr		(a0)			call subroutine
		
		tst.l		d2			moved?
		beq.s		.error			if not then quit
		
		moveq.l		#0,d0			clear
		moveq.l		#0,d1			clear
		move.w		d2,d0			dx
		swap		d2
		move.w		d2,d1			dy
		bsr		SlideBitMap		reposition playfield
		
		moveq.l		#0,d2			don't quit
		
.error		rts					return

; Subroutine called by CheckPropGadg for UpDown gadget movements!

DoUpDown	move.l		window.ptr,a0		a0->window structure

		move.l		#HeightSuper,d0		pf height
		sub.w		wd_GZZHeight(a0),d0	- window height
		
		lea		UpDownGadg,a0		a5->Gadget structure
		move.l		gg_SpecialInfo(a0),a0	a0->PropInfo struct
		mulu		pi_VertPot(a0),d0	* fraction
		divu		#$ffff,d0		/ MAXVALUE
		
		move.l		window.lyr,a0		a0->Layers structure
		sub.w		lr_Scroll_Y(a0),d0	dy
		
		moveq.l		#0,d2			prepare return value
		move.w		d0,d2			copy dy
		swap		d2			into high word
		rts					and return

; Subroutine called by CheckPropGadg for LeftRight gadget movements!

DoLeftRight	move.l		window.ptr,a0		a0->window structure

		move.l		#WidthSuper,d0		pf width
		sub.w		wd_GZZWidth(a0),d0	- window width
		
		lea		LeftRightGadg,a0	a0->Gadget struct
		move.l		gg_SpecialInfo(a0),a0	a0->PropInfo struct
		mulu		pi_HorizPot(a0),d0	* fraction
		divu		#$ffff,d0		/ MAXVALUE
		
		move.l		window.lyr,a0		a0->Layers structure
		sub.w		lr_Scroll_X(a0),d0	dx
		
		moveq.l		#0,d2			prepare return value
		move.w		d0,d2			copy dx
		rts					and return

		