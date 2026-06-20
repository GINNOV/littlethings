
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
;--------------	Open an Intuition Screen
;--------------

* Function	Opens a custom screen and will set palette if pointer to 
;		CMAP is supplied.

* Entry		a0->NewScreen
;		a1->ColourMap (word values, 1 for each colour used), or NULL.

* Exit		d0=0 if an error occurs, else d0= addr of Screen.

* Corrupt	d0

* Author	M.Meany

OpenScrn	movem.l		d1-d3/d7/a0-a4/a6,-(sp)	save

		move.w		ns_Depth(a0),d3		save screen depth
		move.l		a1,a4			save CMAP pointer
		
; open the screen

		CALLINT		OpenScreen		open it
		move.l		d0,d7			save Screen pointer
		beq.s		.Error			quit if error
		
; add some colour,

		move.l		a4,d0			get CMAP pointer
		beq.s		.Done			skip if none
		move.l		d0,a1			a1->CMAP
		move.l		d7,a0			a0->Screen
		lea		sc_ViewPort(a0),a0	a0->ViewPort
		moveq.l		#1,d0			init count
		asl.l		d3,d0			calc colours
		CALLGRAF	LoadRGB4		set colours
		
.Done		move.l		d7,d0			d0=Screen pointer

.Error		movem.l		(sp)+,d1-d3/d7/a0-a4/a6 restore
		rts


;--------------
;--------------	Closes an Intuition Screen
;--------------


* Function	Closes a custom screen.

* Entry		a0->Screen

* Exit		None

* Corrupt	None

* Author	M.Meany

CloseScrn	movem.l		d0-d2/a0-a2/a6,-(sp)	save

		CALLINT		CloseScreen		close it!
		
		movem.l		(sp)+,d0-d2/a0-a2/a6
		rts

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
;--------------	Open a SuperBitMap Intuition Window
;--------------

; It is best to call this subroutine using the supplied OPENSBWIN macro.

* Function	Opens a window and sets a few variables up for it. Can open
;		a window on a custom screen if required. Will display an
;		IText list, Image list and Border if required as well as
;		setting a menu to the window. Easiest method of calling
;		this subroutine is with the above specified macro! See doc
;		file for information on macro usage.

;		Does not cater for shared port, assumes IDCMP are defined
;		in the NewWindow structure. If not, attach port on return
;		and set IDCMP using ModifyIDCMP().

* Entry		a0->block of 7 long words:	*NewWindow struct addr
;						**BitMap structure
;						*IText struct addr or NULL
;						*Image struct addr or NULL
;						*Border struct addr or NULL
;						*MenuStrip struct addr or NULL
;						**Screen struct or NULL

* Exit		d0=0 if an error occurs, else d0= addr of Window.

* Corrupt	d0,d1,d2,d5,d6,d7,a0,a1,a2,a4,a5,a6

* Author	M.Meany

OpenSBWin	move.l		a0,a4			safe register

; Determine if window is opening on a custom screen, if so link them.

		moveq.l		#WBENCHSCREEN,d0	default screen type
		move.l		24(a0),d1		custom screen?
		beq.s		.NoScreen		skip if not
		moveq.l		#CUSTOMSCREEN,d0	set screen type

.NoScreen	move.l		(a4),a0			a0->NewWindow
		move.l		d1,nw_Screen(a0)	link win to scrn
		move.w		d0,nw_Type(a0)		set screen type

; attach the bitmap structure

		move.l		4(a4),nw_BitMap(a0)	fill in bitmap ptr

; now open the window

		CALLINT		OpenWindow		open it
		move.l		d0,d6			save Window ptr
		beq.s		.error			quit if no window
		
; get temp pointer to RastPort

		move.l		d0,a0			a0->Window
		move.l		wd_RPort(a0),a5	a5->RastPort

; if IText's requested, display them.

		move.l		8(a4),d0		get IText pointer
		beq.s		.DoImage		skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			IText
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		PrintIText		display it.

; if Image's requested, display them.

.DoImage	move.l		12(a4),d0		get Image pointer
		beq.s		.DoBorder		skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			Image
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		DrawImage		display it.

; if Border's requested, display them.

.DoBorder	move.l		16(a4),d0		get Border pointer
		beq.s		.DoMenu			skip if NULL
		
		move.l		a5,a0			RastPort
		move.l		d0,a1			Border
		moveq.l		#0,d0			X offset
		move.l		d0,d1			Y offset
		CALLSYS		DrawBorder		display it.

; if a menu is supplied, attach it.

.DoMenu		move.l		20(a4),d0		get Menu pointer
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

* Entry		a4->Window.UserPort
;		a3->Users own idcmp handaler or NULL if none
;		_menuptr must hold address of menu attached (macro does this)

* Exit		d0=return value

* Corrupt	d0

* Author	M.Meany

_WFM		movem.l		d1-d7/a0-a6,-(sp)	save

.Loop		move.l		a4,a0			a0-->user port
		CALLEXEC	WaitPort		wait for message
		move.l		a4,a0			a0-->window pointer
		CALLSYS		GetMsg			get messages
		tst.l		d0			bogus ?
		beq.s		.Loop			yes! then loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.w		im_Code(a1),d3		d3=key/menu details
		move.w		im_Qualifier(a1),d4 	d4=special key details
		move.l		im_IAddress(a1),a5	a5->addr of object
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
		beq.s		.CheckMenu		skip if not
		move.l		gg_UserData(a5),a0	get ptr to subroutine
		cmpa.l		#0,a0			NULL?
		beq.s		.CheckWindow		skip if so
		movem.l		d0/d1/d3-d6/a0-a6,-(sp)	save
		jsr		(a0)			jump to subroutine
		movem.l		(sp)+,d0/d1/d3-d6/a0-a6	restore
		bra.s		.CheckWindow		and jump to loop end

.CheckMenu	cmp.l		#MENUPICK,d2		menu selection made ?
		bne.s		.DoUser			skip if not

		movem.l		d0/d1/d3-d6/a0-a6,-(sp)	save
		bsr		.DoMenu			jump to menu handler
		movem.l		(sp)+,d0/d1/d3-d6/a0-a6	restore
		bra.s		.CheckWindow

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

; Subroutine to deal with multiple menu selections.

.DoMenu		tst.l		_menuptr
		beq.s		.NoSelection
		move.l		d3,d0

.MenuLoop	move.l		_menuptr,a0
		CALLINT		ItemAddress
		tst.l		d0
		beq.s		.NoSelection
		move.l		d0,a0
		move.w		mi_NextSelect(a0),_LastItem
		move.l		mi_SIZEOF(a0),a0
		jsr		(a0)
		move.w		_LastItem,d0
		bra.s		.MenuLoop
		
.NoSelection	rts		

_menuptr	dc.l		0
_LastItem	dc.l		0


;--------------
;--------------	Allocate and initialise a BitMap structure
;--------------

* Function	Supplies an initialised BitMap structure.

* Entry		d0=width
;		d1=height
;		d2=depth

* Exit		d0=addr of structure or 0 if error

* Corrupt	d0

* Author	M.Meany

GetBitMap	movem.l		d1-d7/a0-a3/a6,-(sp)

		move.l		d0,d5			backup copies
		move.l		d1,d6
		move.l		d2,d7

		move.l		#bm_SIZEOF,d0		mem size
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,d4			save address
		beq		.Error			quit if error

; Now intialise the BitMap structure

		move.l		d0,a0			a0->BitMap structure
		move.l		d7,d0			SuperBitmap depth
		move.l		d5,d1			SuperBitmap width
		move.l		d6,d2			SuperBitmap height
		CALLGRAF	InitBitMap		initialise the structure

; Allocate memory for the bitplanes. I`ve opted for segmented playfields to
;allow the user more chance of getting the memory required. Trying to
;allocate one huge chunk may fail!

		subq.l		#1,d7			loop counter, dbr adjusted
		move.l		d4,a3			a3->BitMap structure
		moveq.l		#0,d3			clear register
		move.w		bm_BytesPerRow(a3),d3	d3=bitplane byte width
		mulu.w		bm_Rows(a3),d3	 	d3=RastetSize

		lea		bm_Planes(a3),a3 	a3->1st bitplane ptr
.allocplaneloop	move.l		d3,d0		 	size of memory
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,(a3)+		save addr in BitMap struct
		beq		.Error			quit if error

		dbra		d7,.allocplaneloop	for all bitplanes

.Error		move.l		d4,d0			addr of struct
		movem.l		(sp)+,d1-d7/a0-a3/a6
		rts

;--------------
;--------------	Free all memory allocated to a BitMap structure
;--------------

* Entry		a0->BitMap struct

* Exit		None

* Corrupt	None

* Author	M.Meany

; First release bitplane pointers

FreeBitMap	movem.l		d0-d7/a0-a6,-(sp)	save
		move.l		a0,d6			d6->BitMap structure (safe)
		beq		.Error			quit if not allocated

		move.l		d6,a5			a5->BitMap structure
		lea		bm_Planes(a5),a3 	a3->1st bitplane
		moveq.l		#0,d7			clear
		move.b		bm_Depth(a5),d7		loop counter
		subq.w		#1,d7 			dbra adjusted

		moveq.l		#0,d5			clear register
		move.w		bm_BytesPerRow(a5),d5	d5=bitplane byte width
		mulu.w		bm_Rows(a5),d5	 	d5=RastetSize

.planeloop	moveq.l		#0,d0			clear register
		move.w		d5,d0			bytesize
		move.l		(a3)+,d1		d1->memoryBlock
		beq.s		.nextplane		skip if not allocated
		move.l		d1,a1			a1->memoryBlock
		CALLEXEC	FreeMem			and release it
.nextplane	dbra		d7,.planeloop		for all bitplanes

; Now release bitmap structure

		move.l		#bm_SIZEOF,d0		bytesize
		move.l		d6,a1			memoryBlock
		CALLEXEC	FreeMem			and release it

.Error		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts
		

; These two routines occupy a measly 416 bytes, that includes a 64 bytes
;buffer used to hold temporary colour information.

;--------------
;--------------	Fade from black an Intuition Screen
;--------------

; Attempt at a colour fade-in for a screen. When screen is first opened,
;set palette to all black for fade to work correctly!

* Entry		a0->Screen
;		a1->Palette

* Exit		None

* Corrupt	None

* Author	M.Meany

FadeIn		movem.l		d0-d7/a0-a6,-(sp)	save

; Initialise some variables

		move.l		a1,a5			a5->palette
		lea		sc_ViewPort(a0),a4	a4->ViewPort

; Calculate the number of colours to fade

		moveq.l		#1,d7			init colour count
		moveq.l		#0,d1			clear
		lea		sc_BitMap(a0),a1	a1->BitMap
		move.b		bm_Depth(a1),d1		d1=screen depth
		asl.l		d1,d7			calc num of colours
		
; Clear temporary colour store

		lea		_TempCmap,a0		a0->temporary CMAP
		move.l		d7,d0			colour count
		subq.l		#1,d0			adjust for dbra
		moveq.l		#0,d1			set to BLACK ($0000)
.ClearCMapLoop	move.w		d1,(a0)+		clear next colour
		dbra		d0,.ClearCMapLoop	all colours

; Initialise the main fade loop counters

		moveq.l		#15,d6			max RGB value

.NextFade	lea		_TempCmap,a3		a3->temporary CMAP
		move.l		a5,a6			a6->palette
		move.l		d7,d5			colour count
		subq.l		#1,d5			adjust for dbra

.NextEntry	move.w		(a3)+,d4		get part faded colour
		move.w		(a6)+,d3		get it's target value
		
; If colours are same there's no need to fade any further, so skip fade

		cmp.w		d3,d4			colour faded?
		beq.s		.ColourDone		skip if so

; Check the red components, bump temp value if not same

		move.w		d4,d0			d0=fading colour
		move.w		d3,d1			d1=dest colour
		and.w		#$0F00,d0		mask out green & blue
		and.w		#$0F00,d1		on both values
		cmp.w		d0,d1			Reds the same?
		beq.s		.CheckGreen		skip if so
		add.w		#$0100,d4		else bump red comp

; Check the green components, bump temp value if not same

.CheckGreen	move.w		d4,d0			d0=fading colour
		move.w		d3,d1			d1=dest colour
		and.w		#$00F0,d0		mask out red & blue
		and.w		#$00F0,d1		on both values
		cmp.w		d0,d1			greens the same?
		beq.s		.CheckBlue		skip if so
		add.w		#$0010,d4		else bump green comp

; Check the blue components, bump temp value if not same

.CheckBlue	move.w		d4,d0			d0=fading colour
		move.w		d3,d1			d1=dest colour
		and.w		#$000F,d0		mask out red & green
		and.w		#$000F,d1		on both values
		cmp.w		d0,d1			blues the same?
		beq.s		.ColourDone		skip if so
		addq.w		#$0001,d4		else bump blue comp

; Temp value is now one stage closer to it's dest colour, save it!

.ColourDone	move.w		d4,-2(a3)		put into temp CMAP

; We need to fade all colours in the display, so loop until all done

		dbra		d5,.NextEntry		for all colours

; Another stage of the fade is now complete. Effect it!

		CALLGRAF	WaitTOF			pause to VBlank
		CALLGRAF	WaitTOF			twice for effect
		
		move.l		a4,a0			ViewPort
		lea		_TempCmap,a1		CMAP
		move.l		d7,d0			num colours
		CALLGRAF	LoadRGB4		and fade in

; See if fade completed. Loop back if not!

		dbra		d6,.NextFade		'till fade complete

; Fade complete! Reset registers and return to application.

		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts					and exit

;--------------
;--------------	Fade to black an Intuition Screen
;--------------

; Attempt at a fade-out routine.

* Entry		a0->Screen

* Exit		None

* Corrupt	None

* Author	M.Meany

FadeOut		movem.l		d0-d7/a0-a6,-(sp)	save

; Initialise some variables

		lea		sc_ViewPort(a0),a4	a4->ViewPort
		move.l		vp_ColorMap(a4),a5	a5->ColourMap struct

; Calculate the number of colours to fade

		moveq.l		#1,d7			init colour count
		moveq.l		#0,d1			clear
		lea		sc_BitMap(a0),a1	a1->BitMap
		move.b		bm_Depth(a1),d1		d1=screen depth
		asl.l		d1,d7			calc num of colours
		
; Stuff current colours into temporary colour store ( reverse order ).

		move.l		d7,d5			d5=num colours
		subq.l		#1,d5			adjust for dbra
		lea		_TempCmap,a3		a3->temporary CMAP
		move.l		d7,d0			d0=num of entries
		asl.w		#1,d0			x2 since word vals
		adda.l		d0,a3			a3-> end of CMAP+2
		moveq.l		#0,d0			clear
		
.StuffColours	move.l		a5,a0			a0->ColorMap
		move.w		d5,d0			d0=entry
		CALLGRAF	GetRGB4			get colour value
		move.w		d0,-(a3)		put into temp CMAP
		dbra		d5,.StuffColours	for all colours

; Initialise the main fade loop counters

		moveq.l		#15,d6			max RGB value

.NextFade	lea		_TempCmap,a5		a3->temporary CMAP
		move.l		d7,d5			colour count
		subq.l		#1,d5			adjust for dbra

.NextEntry	move.w		(a5)+,d4		get part faded colour
		
; If colours is $0000 ( ie. Black ) no need to fade it!

		beq.s		.ColourDone		skip if so

; Check the red component, bump temp value if not $0000

		move.w		d4,d0			d0=fading colour
		and.w		#$0F00,d0		mask out green & blue
		beq.s		.CheckGreen		skip if already 0
		sub.w		#$0100,d4		else bump red comp

; Check the green component, bump temp value if not $0000

.CheckGreen	move.w		d4,d0			d0=fading colour
		and.w		#$00F0,d0		mask out red & blue
		beq.s		.CheckBlue		skip if already 0
		sub.w		#$0010,d4		else bump green comp

; Check the blue component, bump temp value if not $0000

.CheckBlue	move.w		d4,d0			d0=fading colour
		and.w		#$000F,d0		mask out red & green
		beq.s		.ColourDone		skip if already 0
		subq.w		#$0001,d4		else bump blue comp

; Temp value is now one stage closer to it's dest colour, save it!

.ColourDone	move.w		d4,-2(a5)		put into temp CMAP

; We need to fade all colours in the display, so loop until all done

		dbra		d5,.NextEntry		for all colours

; Another stage of the fade is now complete. Effect it!

		CALLGRAF	WaitTOF			pause to VBlank
		CALLGRAF	WaitTOF			twice for effect
		
		move.l		a4,a0			ViewPort
		lea		_TempCmap,a1		CMAP
		move.l		d7,d0			num colours
		CALLGRAF	LoadRGB4		and fade in

; See if fade completed. Loop back if not!

		dbra		d6,.NextFade		'till fade complete

; Fade complete! Reset registers and return to application.

		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts					and exit

;--------------
;--------------	Temporary buffer used by fade routines


_TempCmap	ds.w		32			for max 32 colours


