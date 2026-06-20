
; All the following subroutines expect to find required parameters on the
;stack. No registers are preserved! Putting the parameters onto the stack
;preserving registers and restoring the stack is left for the macros that
;invoke these routines.

; In some cases it is quite possible that the macro will generate more code
;than the subroutine itself, especialy for small subroutines. In these cases
;the macro should be removed at the end of development ( :-} ) and a suitable
;subroutine written to replace it.

		************************************
		*   String Handling Subroutines	   *
		************************************

*****************************************************************************

*****
*****	Calculate length of null terminated text string
*****

* stack		addr of string
*		return address

*# a0

		IFD		MMStrLen

MM_StrLen	move.l		4(sp),a0		get addr of string
		moveq.l		#-1,d0			clear counter

.loop		addq.l		#1,d0			bump counter
		tst.b		(a0)+			step through string
		bne.s		.loop			until end is reached
		
		rts

		ENDC

*****************************************************************************

*****
*****	Copy a NULL terminated string
*****

* stack		addr of dst string
*		addr of src string
*		return address

*# a0,a1

		IFD		MMStrCpy
		
MM_StrCpy	move.l		4(a7),a0		src addr
		move.l		8(a7),a1		dest addr

.loop		move.b		(a0)+,(a1)+		copy char
		bne.s		.loop			'till end of string
		
		rts

		ENDC

*****************************************************************************

*****
*****	Convert a string to UPPER case
*****

* stack		addr of string
*		return address

*# a0

		IFD		MMToUpper

MM_ToUpper	move.l		4(sp),a0		get addr of string
		tst.b		(a0)
		beq.s		.error

.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok

		cmp.b		#'z',-1(a0)
		bgt.s		.ok

		subi.b		#$20,-1(a0)

.ok		tst.b		(a0)
		bne.s		.loop

.error		rts

		ENDC

*****************************************************************************

*****
*****	Convert a string to lower case
*****

* stack		addr of string
*		return address

*# a0

		IFD		MMToLower

MM_ToLower	move.l		4(sp),a0		get addr of string
		tst.b		(a0)
		beq.s		.error

.loop		cmpi.b		#'A',(a0)+
		blt.s		.ok

		cmp.b		#'Z',-1(a0)
		bgt.s		.ok

		addi.b		#$20,-1(a0)

.ok		tst.b		(a0)
		bne.s		.loop

.error		rts

		ENDC
		
*****************************************************************************

*****
*****	Compare two strings
*****

* stack		addr of 2nd string
*		addr of 1st string
*		return address

* Exit		d0=  0  if words the same
;		d0= -ve if first word < second word
;		d0= +ve if first word > second word

*# d1-d2,a0-a2

		IFD		MMStrCmp

MM_StrCmp	move.l		4(sp),a0		addr of 1st string
		move.l		8(sp),a1		addr of 2nd string
		
		move.l		a0,a2
		moveq.l		#0,d0
		move.l		d0,d1

.len1		addq.l		#1,d0
		tst.b		(a2)+
		bne.s		.len1

		move.l		a1,a2
.len2		addq.l		#1,d1
		tst.b		(a2)+
		bne.s		.len2

		moveq.l		#0,d2
		cmp.l		d0,d1
		beq.s		.ok
		blt.s		.ok1
		moveq.l		#1,d2
		bra.s		.ok
.ok1		moveq.l		#2,d2
		move.l		d1,d0
.ok		subq.l		#2,d0
.loop		cmp.b		(a0)+,(a1)+
		dbne		d0,.loop
		bgt.s		.first
		blt.s		.second
		move.l		d2,d0
		bra.s		.done

.first		moveq.l		#-1,d0
		bra.s		.done

.second		moveq.l		#1,d0

.done		rts

		ENDC

*****************************************************************************

*****
*****	Preform 'C' type switch parsing on a given string
*****

* stack		addr of action table
*		addr of string
*		return address

*# ALL REGISTERS

; This function has been provided to allows 'C' type parsing of a string.
;Before calling CaseString, an ActionTable must be set up. An ActionTable
;must consist of long word values, two for each entry in the table.

; The first long word for each entry must be a pointer to a NULL terminated
;text string, the second long word must be a pointer to a subroutine to call
;if the string being parsed matches the string being pointed to.

; The table must be terminated by a NULL string pointer. The subroutine
;pointer for this entry may be set to NULL, or it may point to a default
;subroutine that will be called if no match is found.

		IFD		MMCaseStr

MM_CaseStr	move.l		4(sp),a0		addr of string
		move.l		8(sp),a1		addr of action table
		
		move.l		a0,a4			safe working copies
		move.l		a1,a5

.CaseLoop	tst.l		(a5)			end of ActionTable ?
		beq.s		.Default		if so check default

		move.l		a4,a0			a0->parse string
		move.l		(a5)+,a1		next 'Case' string
		move.l		(a5)+,a3		subroutine if match

		STRCMP		a0,a1

		tst.l		d0			match found ?
		bne.s		.CaseLoop		loop if not

		jsr		(a3)			else call subroutine
		bra.s		.Done			and exit

.Default	tst.l		4(a5)			default subroutine?
		beq.s		.Done			exit if not

		move.l		4(a5),a3		else call it
		jsr		(a3)

.Done		rts

		ENDC

*****************************************************************************

*****
*****	Case sensitive String Search
*****

* stack		length of memory block
*		addr of memory block
*		length of string
*		addr of string
*		return address

*# d1-d3,a0-a2

		IFD		MMFindSame

MM_FindSame	move.l		4(sp),a0		addr of string
		move.l		8(sp),d0		length of string
		move.l		12(sp),a1		addr of memory
		move.l		16(sp),d1		length of memory
		
		moveq.l		#0,d3			assume failure
		sub.l		d0,d1			set up counter
		subq.l		#1,d1			correct for dbra
		bmi.s		.FindError		quit if block<string

		move.b		(a0),d2			d2=1st char to match
.Floop		cmp.b		(a1)+,d2		match 1st char ?
		dbeq		d1,.Floop		no+not end,loop back

		bne.s		.FindError		if no match+end quit

		bsr.s		.CompStr		else check rest 

		beq.s		.Floop			loop back if no match

.FindError	move.l		d3,d0			set d0 for return
		rts

.CompStr	movem.l		d0/a0-a2,-(sp)

		subq.l		#1,d0			correct for dbra
		move.l		a1,a2			save a copy
		subq.l		#1,a1			correct
.FFloop		cmp.b		(a0)+,(a1)+		compare str elements
		dbne		d0,.FFloop		while notend+notmatch

		bne.s		.ComprDone		no match so quit
		subq.l		#1,a2			correct this addr
		move.l		a2,d3			save addr of match

.ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		d3			set Z flag
		rts

		ENDC

*****************************************************************************

		************************************
		*     DOS Library Subroutines	   *
		************************************

*****************************************************************************

*****
*****	Subroutine to write NULL terminated string into an open file.
*****

* stack		file handle
*		addr of Null terminated text string
*		return address

*# d0-d3,a0,a1,a6

		IFD		MMPutStr

MM_PutStr	move.l		4(sp),a0	addr of string
		move.l		8(sp),d1	file handle
		beq		.error		exit if no handle	

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a0)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		4(sp),d2	d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		rts				and return

		ENDC

*****************************************************************************

*****
*****	Determines the length of a file.
*****

* stack		addr of filename
*		return address

*# d1-d4/a0/a1/a6

		IFD		MMFileLen

MM_FileLen	move.l		4(sp),d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,d4			handle
		beq		.error
		
		move.l		d4,d1
		move.l		#0,d2
		move.l		#1,d3			OFFSET_END
		CALLSYS		Seek
		
		move.l		d4,d1
		move.l		#0,d2
		move.l		#-1,d3			OFFSET_BEGINNING
		CALLSYS		Seek
		move.l		d0,d3			end of file
		
		move.l		d4,d1
		CALLSYS		Close

		move.l		d3,d0			file length
.error		rts
		
		ENDC

*****************************************************************************

*****
*****	Determines the length of a file.
*****

* determines length of an open file.

* stack		files handle
*		return address

*# d1-d4/a0/a1/a6

		IFD		MMOFileLen

MM_OFileLen	move.l		4(sp),d1
		move.l		#0,d2
		move.l		#1,d3			OFFSET_END
		CALLDOS		Seek
		
		move.l		4(sp),d1
		move.l		#0,d2
		move.l		#-1,d3			OFFSET_BEGINNING
		CALLSYS		Seek
		
		rts

		ENDC

*****************************************************************************

*****
***** Subroutine that loads a file into a block of memory.
*****

* stack		memory type (( defaults to NULL ))
*		addr of filename
*		return address

* Exit		d0= length of buffer allocated or NULL on error
*		a0->buffer

*# d1-d7/a1/a6

		IFD		MMLoadFile

MM_LoadFile	move.l		8(sp),d1		requirements
		move.l		4(sp),a0		filename
		
		FILELEN		a0			determine length

		move.l		d0,d5			save file size
		beq.s		.error			quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		CALLEXEC	AllocMem		get buffer
		move.l		d0,d7			save pointer
		tst.l		d0			all ok?
		bne.s		.cont			if so skip next bit

		moveq.l		#0,d5			set error
		bra		.error			and quit

.cont		move.l		4(sp),d1		d1->filename
		move.l		#MODE_OLDFILE,d2	 access mode
		CALLDOS		Open			open the file
		move.l		d0,d6			save handle
		bne		.cont1			quit if error

		move.l		d7,a1			buffer
		move.l		d5,d1			length
		CALLEXEC	FreeMem			and release it
		moveq.l		#0,d5			set error
		bra		.error			and quit

.cont1		move.l		d0,d1			handle
		move.l		d7,d2			buffer
		move.l		d5,d3			file length
		CALLDOS		Read			and load the file

		move.l		d6,d1			handle
		CALLSYS		Close			close the file

		move.l		d7,a0			a0->buffer
.error		move.l		d5,d0			d0=return value
		rts

		ENDC

*****************************************************************************

		************************************
		*  Intuition Library Subroutines   *
		************************************

*****************************************************************************

*****
*****	Open an Intuition Screen
*****

; Opens a custom screen and will set palette if pointer to CMAP is supplied.

* stack		*CMAP ( 1 word per colour ) or NULL
*		*NewScreen
*		return address

* Exit		d0=0 if an error occurs, else d0= addr of Screen.

*# d1-d3/d7/a0-a4/a6

		IFD		MMOpenScrn

MM_OpenScrn	move.l		4(sp),a0		a0->NewScreen
		move.w		ns_Depth(a0),d3		save screen depth

; open the screen

		CALLINT		OpenScreen		open it
		move.l		d0,d7			save Screen pointer
		beq.s		.Error			quit if error

; add some colour,

		tst.l		8(sp)			got CMAP pointer?
		beq.s		.Done			skip if not
		move.l		8(sp),a1		a1->CMAP
		move.l		d7,a0			a0->Screen
		lea		sc_ViewPort(a0),a0	a0->ViewPort
		moveq.l		#1,d0			init count
		asl.l		d3,d0			calc colours
		CALLGRAF	LoadRGB4		set colours

.Done		move.l		d7,d0			d0=Screen pointer

.Error		rts

		ENDC

*****************************************************************************

*****
*****	Close an Intuition Screen
*****

* stack		*Screen
*		return address

*# d0-d2/a0-a2/a6

		IFD		MMCloseScrn

MM_CloseScrn	move.l		4(sp),a0		a0->Screen

		CALLINT		CloseScreen		close it!

		rts

		ENDC

*****************************************************************************

*****
*****	Open an Intuition Window with objects 
*****

; Opens a window and sets a few variables up for it. Can open a window on a
;custom screen if required. Will display an IText list, Image list and Border
;if required as well as	setting a menu to the window. Easiest method of
;calling this subroutine is with the specified macro! See doc file for
;information on macro usage.

; Does not cater for shared port, assumes IDCMP are defined in the NewWindow
;structure. If not, attach port on return and set IDCMP using ModifyIDCMP().

* stack		*Screen or NULL
*		*MenuStrip or NULL
*		*Border or NULL
*		*Image or NULL
*		*IText or NULL
*		*NewWindow
*		return address

* Exit		d0=0 if an error occurs, else d0= addr of Window.

*# d1-d2/d5-d7/a0-a2/a4-a6

		IFD		MMOpenAWin

MM_OpenAWin	lea		4(sp),a4		safe register

; Determine if window is opening on a custom screen, if so link them.

		moveq.l		#WBENCHSCREEN,d0	default screen type
		move.l		20(a4),d1		custom screen?
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
		move.l		wd_RPort(a0),a5		a5->RastPort

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

		ENDC

*****************************************************************************

*****
*****	Close an Intuition Window
*****

; Not intended for windows sharing a message port for IDCMP.

* stack		*Window
*		return address

*# d0-d2/a0-a4/a6
		IFD		MMCloseWin

MM_CloseWin	move.l		4(sp),a0		a0->Window

		CALLINT		CloseWindow		close the window

		rts

		ENDC

*****************************************************************************

*****
*****	Deal with user interaction
*****

; Not suitable at this stage for handaling shared ports.

; The only way to quit this loop if for a routine called to set register
;d2=CLOSEWINDOW. A value may be passed from a service routine to the caller
;in register d7. This will be returned to caller in register d0.

* stack		LONG for last item
*		LONG for menuptr
*		*wd_UserPort -- starts as *Window
*		*UserRoutine or NULL
*		return address

* Exit		d0=return value

*# d1-d7/a0-a6
		IFD		MMWFM

MM_WFM		move.l		8(sp),a0		*Window
		move.l		wd_MenuStrip(a0),12(sp)	*MenuStrip
		move.l		wd_UserPort(a0),a0	*UserPort
		move.l		a0,8(sp)		replace it

.Loop		move.l		8(sp),a0		UserPort
		CALLEXEC	WaitPort		wait for message
		move.l		8(sp),a0		UserPort
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

		move.l		4(sp),d0		subroutine supplied?
		beq.s		.NoSub			skip if not
		move.l		a1,-(sp)		save *Message
		move.l		d0,a3
		jsr		(a3)			call UserRoutine
		move.l		(sp)+,a1		restore
.NoSub		CALLEXEC	ReplyMsg		answer os now
		bra		.CheckWindow		jump to end of loop

.DoReply	CALLSYS		ReplyMsg		answer os

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0	gadget selected?
		beq.s		.CheckMenu		skip if not
		move.l		gg_UserData(a5),a0	get ptr to subroutine
		cmpa.l		#0,a0			NULL?
		beq.s		.CheckWindow		skip if so
		jsr		(a0)			jump to subroutine
		bra.s		.CheckWindow		and jump to loop end

.CheckMenu	cmp.l		#MENUPICK,d2		menu selection made ?
		bne.s		.DoUser			skip if not

		bsr		.DoMenu			jump to menu handler
		bra.s		.CheckWindow

.DoUser		move.l		4(sp),d0		UserRoutine
		beq		.CheckWindow		skip if not
		move.l		d0,a3
		jsr		(a3)			call UserRoutine

.CheckWindow	cmp.l		#CLOSEWINDOW,d2 	 window closed ?
		bne		.Loop			 if not then jump

		move.l		d7,d0			get return value
		rts

; Subroutine to deal with multiple menu selections.

.DoMenu		tst.l		16(sp)
		beq.s		.NoSelection
		move.l		d3,d0

.MenuLoop	move.l		16(sp),a0
		CALLINT		ItemAddress
		tst.l		d0
		beq.s		.NoSelection
		move.l		d0,a0
		move.w		mi_NextSelect(a0),20(sp)
		move.l		mi_SIZEOF(a0),a0
		jsr		(a0)
		move.w		20(sp),d0
		bra.s		.MenuLoop

.NoSelection	rts

		ENDC

*****************************************************************************

*****
*****	Allocate and initialise a BitMap structure
*****

; Supplies an initialised BitMap structure. Memory for all bitplanes is also
;allocated.

* stack		depth
*		height
*		width
*		return address

* Exit		d0=addr of structure or 0 if error

*# d1-d7/a0-a3/a6

		IFD		MMGetBitMap

MM_GetBitMap	move.l		#bm_SIZEOF,d0		mem size
		move.l		#MEMF_CLEAR,d1		requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,d4			save address
		beq		.Error			quit if error

; Now intialise the BitMap structure

		move.l		d0,a0			a0->BitMap structure
		move.l		12(sp),d0		SuperBitmap depth
		move.l		4(sp),d1		SuperBitmap width
		move.l		8(sp),d2		SuperBitmap height
		CALLGRAF	InitBitMap		initialise the structure

; Allocate memory for the bitplanes. I`ve opted for segmented playfields to
;allow the user more chance of getting the memory required. Trying to
;allocate one huge chunk may fail!

		move.l		12(sp),d7		depth
		subq.l		#1,d7			loop counter, dbr adjusted
		move.l		d4,a3			a3->BitMap structure
		moveq.l		#0,d3			clear register
		move.w		bm_BytesPerRow(a3),d3	d3=bitplane byte width
		mulu.w		bm_Rows(a3),d3	 	d3=RastetSize

		lea		bm_Planes(a3),a3 	a3->1st bitplane ptr
.allocplaneloop	move.l		d3,d0		 	size of memory
		move.l		#MEMF_CHIP!MEMF_CLEAR,d1 requirements
		CALLEXEC	AllocMem		get some memory
		move.l		d0,(a3)+		addr-> BitMap struct
		beq		.Error			quit if error

		dbra		d7,.allocplaneloop	for all bitplanes

.Error		move.l		d4,d0			addr of struct
		rts

		ENDC

*****************************************************************************

*****
*****	Free a BitMap structure and all it's bitplanes.
*****

* stack		*BitMap
*		return address

* Exit		None

*# d0-d7/a0-a6
; First release bitplane pointers

		IFD		MMFreeBitMap

MM_FreeBitMap	move.l		4(sp),d6		d6->BitMap structure (safe)
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
		CALLSYS		FreeMem			and release it

.Error		rts

		ENDC

*****************************************************************************

*****
*****	Fade a Screen from Black to specified palette.
*****

***** WARNING : ONLY USE ON SCREENS WITH DEPTH <= 5 *****

; Attempt at a colour fade-in for a screen. When screen is first opened,
;set palette to all black for fade to work correctly!

* stack		32 words for temp colour map
		*Palette
*		*Screen
*		return address

*# d0-d7/a0-a6 

		IFD		MMFadeIn

MM_FadeIn	move.l		4(sp),a0		*Screen

; Initialise some variables

		move.l		8(sp),a5		*Palette
		lea		sc_ViewPort(a0),a4	a4->ViewPort

; Calculate the number of colours to fade

		moveq.l		#1,d7			init colour count
		moveq.l		#0,d1			clear
		lea		sc_BitMap(a0),a1	a1->BitMap
		move.b		bm_Depth(a1),d1		d1=screen depth
		asl.l		d1,d7			calc num of colours

; Clear temporary colour store

		lea		12(sp),a0		a0->temporary CMAP
		move.l		d7,d0			colour count
		subq.l		#1,d0			adjust for dbra
		moveq.l		#0,d1			set to BLACK ($0000)
.ClearCMapLoop	move.w		d1,(a0)+		clear next colour
		dbra		d0,.ClearCMapLoop	all colours

; Initialise the main fade loop counters

		moveq.l		#15,d6			max RGB value

.NextFade	lea		12(sp),a3		a3->temporary CMAP
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
		CALLSYS		WaitTOF			twice for effect

		move.l		a4,a0			ViewPort
		lea		12(sp),a1		CMAP
		move.l		d7,d0			num colours
		CALLSYS		LoadRGB4		and fade in

; See if fade completed. Loop back if not!

		dbra		d6,.NextFade		'till fade complete

; Fade complete! Reset registers and return to application.

		rts					and exit

		ENDC

*****************************************************************************

*****
*****	Fade a Screen to Black
*****

* stack		32 words for temp colours
*		*Screen
*		return address

*# d0-d7/a0-a6

		IFD		MMFadeOut

MM_FadeOut	move.l		4(sp),a0		Screen

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
		lea		8(sp),a3		a3->temporary CMAP
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

.NextFade	lea		8(sp),a5		a3->temporary CMAP
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
		CALLSYS		WaitTOF			twice for effect

		move.l		a4,a0			ViewPort
		lea		8(sp),a1		CMAP
		move.l		d7,d0			num colours
		CALLSYS		LoadRGB4		and fade in

; See if fade completed. Loop back if not!

		dbra		d6,.NextFade		'till fade complete

; Fade complete! Reset registers and return to application.

		rts					and exit

		ENDC

*****************************************************************************

*****
*****
*****
