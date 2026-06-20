

* DeadKeyConvert() function as promised
* synopsis:


* Count = DeadKeyConvert(msg,kbuf,ksize,kmap)

*  D0		  	  A0  A1   D0    A2

* msg	= pointer to IntuiMessage structure
* kbuf	= pointer to buffer to use
* ksize	= size of above keyboard buffer
* kmap	= pointer to a keymap structure, NULL if using default

* REQUIRES POINTER TO CONSOLE DEVICE IOREQUEST IN A6!!!

* Returns:

* D0 = -2 : Not a RAWKEY event
* D0 = -1 : Keyboard buffer too small-try with bigger buffer

* Otherwise, number of characters placed in the buffer.

* Needs following data structures defined via various include
* files:

* InputEvent structure inc. ie_sizeof

* KeyMap structure inc. km_sizeof

* IntuiMessage structure inc. im_sizeof

* d1/a3 corrupt

* This is the InputEvent structure, in case you haven't got it.
* Now you'll also need the TimeVector structure for tv_sizeof. See
* typed_inputevent.doc for more info.


		rsreset
ie_NextEvent	rs.l	1
ie_Class	rs.b	1
ie_SubClass	rs.b	1
ie_Code		rs.w	1
ie_Qualifier	rs.w	1
ie_EventAddress	rs.w	0
ie_X		rs.w	1
ie_Y		rs.w	1
ie_TimeStamp	rs.b	tv_sizeof
ie_sizeof	rs.w	0



DeadKeyConvert	move.l	im_Class(a0),d1		;get IDCMP event class
		cmp.l	#RAWKEY,d1		;RAWKEY event?
		bne.s	DCC_1

		lea	fakeinputevent(pc),a3	;get fake input event ptr

		moveq	#0,d1
		move.w	im_Code(a0),d1
		move.b	d1,ie_Code(a3)		;copy data across

		move.w	im_Qualifier(a0),d1
		move.w	d1,ie_Qualifier(a3)

		move.l	im_IAddress(a0),d1
		move.l	d1,ie_EventAddress(a3)

		move.l	a3,a0
		move.l	d0,d1

* Now registers set up for RawKeyConvert(). Do it!!!

		jsr	RawKeyConvert(a6)

* Now, D0 = -1 if buffer was too small, else contains no of
* chars converted.

		rts


DCC_1		moveq	#-2,d0
		rts

* This is the fake input event structure for DeadKeyConvert().

fakeinputevent	dc.l	NULL
		dc.b	IECLASS_RAWKEY
		dc.b	0
		dc.w	0
		dc.l	0
		dc.l	0,0



