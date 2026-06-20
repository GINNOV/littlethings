
; The subroutines in this file are intended for use in conjunction with the
;file SysMacros.i see the doc file for more information.

; Written for ACC by M.Meany, Feb 92. Use, abuse and expand as you will.

; This is version 1.0, compiled on Feb 13th 92.

;	Name		Date Written		Last Alteration

; OpenScrn		9th  Feb 92
; CloseScrn		9th  Feb 92
; OpenAWin		9th  Feb 92
; OpenSBWin		9th  Feb 92
; CloseWin		9th  Feb 92
; _WFM			12th Feb 92		15th Feb 92
; GetBitMap		9th  Feb 92
; FreeBitMap		9th  Feb 92
; FadeIn		11th Feb 92
; FadeOut		11th Feb 92


;--------------
;--------------	Open an Intuition Window
;--------------

; It is best to call this subroutine using the supplied OPENWIN macro.

* Function	Opens a window and sets a few variables up for it. Can open
;		a window on a custom screen if required. Will display an
;		IText list, Image list and Border if required as well as
;		setting a menu to the window. Easiest method of calling
;		this subroutine is with the above specified macro! See doc
;		file for information on macro usage.

;		Does not cater for shared port, assumes IDCMP are defined
;		in the NewWindow structure. If not, attach port on return
;		and set IDCMP using ModifyIDCMP().

* Entry		a0->block of 6 long words:	NewWindow struct addr
;						IText struct addr or NULL
;						Image struct addr or NULL
;						Border struct addr or NULL
;						MenuStrip struct addr or NULL
;						Screen struct addr or NULL

* Exit		d0=0 if an error occurs, else d0= addr of Window.

* Corrupt	d0,d1,d2,d5,d6,d7,a0,a1,a2,a4,a5,a6

* Author	M.Meany

OpenAWin	move.l		a0,a4			safe register

; Determine if window is opening on a custom screen, if so link them.

		moveq.l		#WBENCHSCREEN,d0	default screen type
		move.l		20(a0),d1		custom screen?
		beq.s		.NoScreen		skip if not
		moveq.l		#CUSTOMSCREEN,d0	set screen type

.NoScreen	move.l		(a4),a0			a0->NewWindow
		move.l		d1,nw_Screen(a0)	link win to scrn
		move.w		d0,nw_Type(a0)		set screen type

; now open the window

		CALLINT		OpenWindow		open it
		move.l		d0,d6			save Window ptr
		beq.s		.error			quit if no window
		
; get temp pointer to RastPort

		move.l		d0,a0			a0->Window
		move.l		wd_RPort(a0),a5	a5->RastPort

; if IText's requested, display them.

		move.l		4(a4),d0		get IText pointer
		beq.s		.DoImage		skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			IText
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		PrintIText		display it.

; if Image's requested, display them.

.DoImage	move.l		8(a4),d0		get Image pointer
		beq.s		.DoBorder		skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			Image
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		DrawImage		display it.

; if Border's requested, display them.

.DoBorder	move.l		12(a4),d0		get Border pointer
		beq.s		.DoMenu			skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			Border
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		DrawBorder		display it.

; if a menu is supplied, attach it.

.DoMenu		move.l		16(a4),d0		get Menu pointer
		beq.s		.Done			skip if NULL
		
		move.l		d6,a0			Window
		move.l		d0,a1			Menu
		CALLSYS		SetMenuStrip		attach menu

.Done		move.l		d6,d0			d0=Window pointer
.error		rts					and return

;--------------
;--------------	Close a window.
;--------------

; Not intended for windows sharing a message port for IDCMP.

* Entry		a0->Window

* Exit		None

* Corrupt	None

* Author	M.Meany

CloseWin	movem.l		d0-d2/a0-a4/a6,-(sp)	save

; close the window

		CALLINT		CloseWindow		close the window
		
		movem.l		(sp)+,d0-d2/a0-a4/a6	restore
		rts

;--------------
;-------------- Deal with User interaction
;--------------

; Not suitable at this stage for handaling shared ports or RAWKEY events

; The only way to quit this loop if for a routine called to set register
;d2=CLOSEWINDOW. A value may be passed from a service routine to the caller
;in register d7. This will be returned to caller in register d0.

; HANDLEIDCMP	Window,Subroutine

* Entry		a3->Users own idcmp handaler or NULL if none

* Exit		d0=return value

* Corrupt	d0

* Author	M.Meany

_WFM		movem.l		d1-d7/a0-a6,-(sp)	save

.Loop		move.l		window.up(a5),a0	a0-->user port
		CALLEXEC	WaitPort		wait for message
		move.l		window.up(a5),a0	a0-->window pointer
		CALLSYS		GetMsg			get messages
		tst.l		d0			bogus ?
		beq.s		.Loop			yes! then loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=key/menu details
		move.w		im_Qualifier(a1),d4 	d4=special key details
		move.l		im_IAddress(a1),_ThisObject  addr of object
		move.l		im_MouseX(a1),d5 	d5=MouseX,MouseY
		cmp.l		#RAWKEY,d2		keyboard input ?
		bne.s		.DoReply		if not then reply msg

		move.l		a3,d0			subroutine supplied?
		beq.s		.NoSub			skip if not		
		movem.l		d0/d1/d3-d6/a0-a6,-(sp)	save
		jsr		(a3)		jump to ServerRoutine
		movem.l		(sp)+,d0/d1/d3-d6/a0-a6	restore
.NoSub		CALLEXEC	ReplyMsg		answer os now
		bra		.CheckWindow		jump to end of loop

.DoReply	CALLEXEC	ReplyMsg		answer os

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0	gadget selected?
		beq.s		.DoUser			skip if not
		move.l		_ThisObject,a0		a0->Gadget struct
		move.l		gg_UserData(a0),a0	get ptr to subroutine
		cmpa.l		#0,a0			NULL?
		beq.s		.CheckWindow		skip if so
		movem.l		d0/d1/d3-d6/a0-a6,-(sp)	save
		jsr		(a0)			jump to subroutine
		movem.l		(sp)+,d0/d1/d3-d6/a0-a6	restore
		bra.s		.CheckWindow		and jump to loop end

.DoUser		move.l		a3,d0			subroutine supplied?
		beq		.CheckWindow		skip if not
		movem.l		d0/d1/d3-d6/a0-a6,-(sp)	save
		jsr		(a3)			do user routine
		movem.l		(sp)+,d0/d1/d3-d6/a0-a6	restore

.CheckWindow	cmp.l		#CLOSEWINDOW,d2 	 window closed ?
		bne		.Loop			 if not then jump
		
		move.l		d7,d0			get return value
		movem.l		(sp)+,d1-d7/a0-a6	restore
		rts

_ThisObject	dc.l		0

