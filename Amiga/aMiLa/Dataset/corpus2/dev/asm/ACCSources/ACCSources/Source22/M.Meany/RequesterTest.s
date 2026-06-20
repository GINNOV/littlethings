
*****	Title		RequesterTest.s
*****	Function	Simple routine to test my file requester.
*****			
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	21 March 92
*****	This Revision	23 March 92
*****	Notes		I may get there yet!
*****			

		incdir		df2:
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i
		include		intuition/intuition_lib.i
		include		intuition/intuition.i
		include		graphics/graphics_lib.i
		include		graphics/gfx.i


Start		lea		FRQ,a0			requester structure
		bsr		FileRequest		display it
		tst.l		d0			all ok?
		bne.s		Finish			exit if not
		
		lea		Buffer,a1		a1->filename
		move.l		frq_Length(a0),d0	d0=file size

Finish		rts					exit


FRQ		dc.l		MyName		pointer to window name
		dc.l		0		custom screen pointer or NULL
		dc.l		Dir		pointer to directory
		dc.l		Buffer		pointer to dest buffer
		dc.w		10		X position
		dc.w		50		Y position
		dc.l		0		Selected files length

MyName		dc.b		'Select File To Load',0
		even
Buffer		ds.b		300
Dir		dc.b		'df2:include/exec',0
		even

****************************************************************************
*		File Requester by Mark Meany, March 92.			   *
****************************************************************************

*  A stand-alone filerequester subroutine. The following subroutine is self
* contained, opening it's own libraries and window as well as controlling
* it's own memory usage.

*  To call requester, pass address of frq structure ( defined below ) in
* register a0. One field in this structure MUST be initialised, the
* frq_Buffer field. This should contain a pointer to a buffer where the
* subroutine will write the name of the file selected. All other fields are
* optional. The buffer must be big enough to hold a maximum of 355 characters
* though I doubt this many will ever be required!

*  The frq structure then:

		rsreset
frq_Name	rs.l		1		pointer to window name
frq_Screen	rs.l		1		custom screen pointer or NULL
frq_Path	rs.l		1		pointer to directory
frq_Buffer	rs.l		1		pointer to dest buffer
frq_X		rs.w		1		X position
frq_Y		rs.w		1		Y position
frq_Length	rs.l		1		Selected files length
frq_SIZE	rs.b		0

*  The frq_X and frq_Y will be modified if the user moves the window, this
* will allow the routine to open the window in the same place next time it
* is called. NOTE, you must pass legal values in these fields as no range
* checking is done in this version!

*  If you intend to open the requester on a custom screen, pass a pointer to
* the screen ( as returned by OpenScreen() ) in the frq_Screen field.

*  If you wish to give the window a name, pass a pointer to it in the
* frq_Name field. The name must be NULL terminated.

*  A starting directory can be specified, pass a pointer to it in the
* frq_Path field. This string must also be NULL terminated.

*  On return, register d0 will contain one of the following values:
* d0=0		all ok. Selected file or directory exsists and has been
*		examined.
* d0=1		user selected cancel.
* d0=2		file selected, but could not lock it.
* d0=3		internal error, probably memory allocation.

*  The complete filename will be in your buffer, ready to use. Also, the
* frq_Length field will contain the size ( in bytes ) of the selected file,
* providing it could be locked.

*  The requester will accept a directory with no file being selected. This
* allows it to act as a directory selecter as well. If a valid directory is
* selected, frq_Length will contain a NULL ( 0 ).

*  This code is still under development and needs a lot of work. The basics
* are all there, but the window looks scruffy. I still have to add a few
* borders and proper scrolling routines as well as real-time updating while
* a directory is being read. Maybe next month will see a better version.

*  At this time the proportional gadget is non-functional.

*  This code is entirely PD. Use and abuse as you wish. M.Meany, March 92.

************************* STAGE 1 DEVELOPMENT ******************************


****************************************************************************
*			Macros						   *
****************************************************************************

***************	Macro's used by filerequester source

; register a6 is used to point to allocated variable block, so these macros
;ensure pointer is preserved during library calls.

mEXEC		macro
		move.l		a6,-(sp)		save var pointer
		move.l		$4,a6			sysbase
		jsr		_LVO\1(a6)		call function
		move.l		(sp)+,a6		restore var pointer
		endm

mDOS		macro
		move.l		a6,-(sp)		save var pointer
		move.l		_mDOSBase(a6),a6	lib base pointer
		jsr		_LVO\1(a6)		call function
		move.l		(sp)+,a6		restore var pointer
		endm

mINT		macro
		move.l		a6,-(sp)		save var pointer
		move.l		_mINTBase(a6),a6	lib base pointer
		jsr		_LVO\1(a6)		call function
		move.l		(sp)+,a6		restore var pointer
		endm

mGRAF		macro
		move.l		a6,-(sp)		save var pointer
		move.l		_mGFXBase(a6),a6	lib base pointer
		jsr		_LVO\1(a6)		call function
		move.l		(sp)+,a6		restore var pointer
		endm

;--------------
;--------------	Main file requester subroutine
;--------------

; Entry		a0->rqInfo structure ( defined below )

; Exit		UserBuffer will contain name of file selected.
;		d0 = return code:
;			0 => Valid file selected.
;			1 => Cancel selected.
;			2 => Selected file could not be Lock'ed.
;			3 => Internal error.

; Corrupt	d0

; Author	M.Meany, March 1992.

; Global register conventions:	a6->variables
;				d7=return error code ( see above )

FileRequest	movem.l		d1-d7/a0-a6,-(sp)	save registers
		moveq.l		#3,d7			initial error code
		move.l		a0,d6			save inputs

; allocate a memory block for vars

		move.l		#_mSIZE,d0		size
		move.l		#$10000,d1		MEMF_CLEAR
		mEXEC		AllocMem		get block
		tst.l		d0			all ok?
		beq		.BadError		quit if not
		move.l		d0,a6			save address

; Set up required variables

		move.l		d6,_mrqInfo(a6)		addr of info struct
		lea		_mWin(pc),a1		NewWindow
		move.l		d6,a0			a0->rqInfor struct
		move.l		frq_Name(a0),nw_Title(a1)
		move.w		frq_X(a0),nw_LeftEdge(a1)
		move.w		frq_Y(a0),nw_TopEdge(a1)
		tst.l		frq_Screen(a0)
		beq.s		.NoScreen
		move.l		frq_Screen(a0),nw_Screen(a1)
		move.w		#CUSTOMSCREEN,nw_Type(a1)
		
.NoScreen	lea		_mPath(a6),a1
		move.l		frq_Path(a0),a0
.copyloop	move.b		(a0)+,(a1)+
		bne.s		.copyloop
		
		move.l		#-1,_mPathEnd(a6)	delimit buffer

; Set buffer pointers in string gadgets

		lea		_mFileGadg(pc),a0	Gadget
		move.l		gg_SpecialInfo(a0),a0	StrinInfo
		lea		_mName(a6),a1		a1->buffer
		move.l		a1,(a0)			attach
		
		lea		_mDirGadg(pc),a0	Gadget
		move.l		gg_SpecialInfo(a0),a0	StrinInfo
		lea		_mPath(a6),a1		a1->buffer
		move.l		a1,(a0)			attach

; initialise list header

		lea		_mHeader(a6),a0
		NEWLIST		a0

; Open dos library

		lea		_mDOSstr(pc),a1		libname
		moveq.l		#0,d0			any version
		mEXEC		OpenLibrary		and open it
		move.l		d0,_mDOSBase(a6)	save
		beq		.Error1			quit if error

; Open intuition library

		lea		_mINTstr(pc),a1		libname
		moveq.l		#0,d0			any version
		mEXEC		OpenLibrary		and open it
		move.l		d0,_mINTBase(a6)	save
		beq		.Error2			quit if error

; Open graphics library

		lea		_mGFXstr(pc),a1		libname
		moveq.l		#0,d0			any version
		mEXEC		OpenLibrary		and open it
		move.l		d0,_mGFXBase(a6)	save
		beq		.Error3			quit if error

; Open requesters window

		lea		_mWin(pc),a0		a0->NewWindow
		mINT		OpenWindow		open it
		move.l		d0,_mwindow.ptr(a6)	save pointer
		beq		.Error4

; Get important pointers

		move.l		d0,a0			Window
		move.l		wd_UserPort(a0),_mwindow.up(a6) UserPort
		move.l		wd_RPort(a0),_mwindow.rp(a6)	RastPort

; Build initial list and display it

		lea		_mPath(a6),a0
		bsr		_mGetDirList
		bsr		_mFreshDisplay

; Do interaction

.mWait		move.l		_mwindow.up(a6),a0	a0-->user port
		mEXEC		WaitPort		wait for event
		move.l		_mwindow.up(a6),a0	a0-->user port
		mEXEC		GetMsg			get any messages
		tst.l		d0			was there a message ?
		beq.s		.mWait			if not loop back
		move.l		d0,a1			a1-->message
		move.l		im_Class(a1),d2		d2=IDCMP flags
		move.l		im_IAddress(a1),a5 	a5=addr of object
		move.l		im_Seconds(a1),d5	get a copy of
		move.l		im_Micros(a1),d6	the time stamp
		mEXEC		ReplyMsg		answer os

		; Deal with gadgets

		move.l		d2,d0
		and.l		#GADGETUP!GADGETDOWN,d0
		beq.s		.test_tick
		move.l		gg_UserData(a5),a0
		cmpa.l		#0,a0
		beq.s		.test_win
		jsr		(a0)

		; Deal with intuiticks

.test_tick	cmp.l		#INTUITICKS,d2		ticking
		bne.s		.test_win		skip if not
		move.l		_mGadgSub(a6),d0	get sub addr
		beq.s		.test_win		skip if none
		move.l		d0,a0			a0->subroutine
		jsr		(a0)

		; Check if operation complete, keep looping if not

.test_win	cmp.l		#CLOSEWINDOW,d2 	window closed ?
		bne.s		.mWait			if not then loop

; Time to see what we got! First, check for cancel.

		cmp.l		#1,d7			cancel?
		beq		.Error6			yep! so quit
		
		;not cancel, so build filename in users buffer
		
		move.l		_mrqInfo(a6),a4		a4->user struct
		lea		_mPath(a6),a0		source
		move.l		frq_Buffer(a4),a1	dest buffer
		bsr		_mStrCpy		copy path
		move.l		frq_Buffer(a4),a0	path
		lea		_mName(a6),a1		name of file
		bsr		_TagDirName		add name to path

		;now examine the file to determine it's length
		
			; Lock the file

		move.l		frq_Buffer(a4),d1	filename
		moveq.l		#ACCESS_READ,d2		access mode
		mDOS		Lock			get lock on dir
		move.l		d0,d6			save lock
		beq		.Error6			quit if no lock

			; Examine the file

		lea		_mPath(a6),a0		a0->fib buffer
		move.l		d6,d1			lock
		move.l		a0,d2			mem block for fib
		mDOS		Examine			get fib
		tst.l		d0			read ok?
		beq		.UnLock			quit if error

			; Copy file length into users buffer
		
		move.l		#0,d7			signal locked OK
		lea		_mPath(a6),a0		fib
		move.l		fib_Size(a0),frq_Length(a4) copy length
		
			;now unlock the file and continue to tidy up.
		
.UnLock		move.l		d6,d1			lock
		mDOS		UnLock			free it
		
; Free memory tied up in list

.Error6		bsr		_mFreeList		release it

; close requester window

.Error5		move.l		_mwindow.ptr(a6),a0	a0->Window
		mINT		CloseWindow		close it

; close graphics library

.Error4		move.l		_mGFXBase(a6),a1	base pointer
		mEXEC		CloseLibrary


; close intuition library

.Error3		move.l		_mINTBase(a6),a1	base pointer
		mEXEC		CloseLibrary


; close dos library

.Error2		move.l		_mDOSBase(a6),a1	base pointer
		mEXEC		CloseLibrary
		
; free memory used for variables

.Error1		move.l		a6,a1			a1->mem
		move.l		#_mSIZE,d0		size
		mEXEC		FreeMem			release it

.BadError	move.l		d7,d0			set return value
		movem.l		(sp)+,d1-d7/a0-a6	retrieve registers
		rts

*--------------------------------------------------------------------------*

_mDOSstr	dc.b		'dos.library',0
		even
_mINTstr	dc.b		'intuition.library',0
		even
_mGFXstr	dc.b		'graphics.library',0
		even
		
****************************************************************************
*			Subroutines					   *
****************************************************************************

*--------------------------------------------------------------------------*
*			IDCMP HANDLERS					   *
*--------------------------------------------------------------------------*

;--------------
;--------------	Prop gadget not yet supported!
;--------------

_mDoProp	rts

;--------------
;--------------	User has clicked 'OK', so exit.
;--------------

_mDoOk		moveq.l		#2,d7			set return code
		move.l		#CLOSEWINDOW,d2		signal exit
		rts

;--------------
;--------------	User has typed in a filename, so exit.
;--------------

_mDoFile	moveq.l		#2,d7			set return code
		move.l		#CLOSEWINDOW,d2		signal exit
		rts

;--------------
;--------------	An entry has been selected, deal with it.
;--------------

_mDoSelect	cmp.l		#GADGETDOWN,d2		just selected?
		beq		.invalid		exit if so

; find node at top of window

		lea		_mHeader(a6),a0		Head node
		move.l		_mTopNode(a6),d0	get offset
		subq.l		#1,d0			correct for DBcc

.findpos	TSTNODE		a0,a0
		dbra		d0,.findpos

; find node in gadget selected

.there		moveq.l		#0,d1			clear
		move.w		gg_GadgetID(a5),d1	get offset
		subq.w		#1,d1			DBcc adjust
		beq.s		.got_node		skip if desired node
		subq.w		#1,d1
				
.loop		TSTNODE		a0,a0			step on
		beq		.invalid		exit if end of list
		dbra		d1,.loop		loop if not there

; deal with a file selection

.got_node	cmp.b		#3,LN_PRI(a0)		File ?
		bne.s		.tryVol			skip if not
		bsr		_mFileSel		service selection
		bra		.invalid		and exit

; deal with volume & assign selections

.tryVol		tst.b		LN_PRI(a0)		directory ?
		beq.s		.isDir			skip if so
		move.l		LN_NAME(a0),a0		source
		lea		_mPath(a6),a1		dest
		bsr		_mStrCpy		copy name

		lea		_mDirGadg,a0			Gadget
		move.l		_mwindow.ptr(a6),a1	Window
		suba.l		a2,a2			not requester
		moveq.l		#1,d0			1 gadget
		mINT		RefreshGList		redisplay

		bsr		_mFreeList		free current list
		bsr		_mGetDirList		build a new one
		bsr		_mFreshDisplay		and display it
		moveq.l		#0,d2			not quitting
		bra		.invalid		and exit

; deal with directory selection

.isDir		move.l		LN_NAME(a0),a1		dir to be appended
		lea		_mPath(a6),a0		path to append onto
		bsr		_TagDirName		append it
		
		lea		_mDirGadg,a0		Gadget
		move.l		_mwindow.ptr(a6),a1	Window
		suba.l		a2,a2			not requester
		moveq.l		#1,d0			1 gadget
		mINT		RefreshGList		redisplay

		bsr		_mFreeList		free current list
		bsr		_mGetDirList		build a new one
		bsr		_mFreshDisplay		and display it
		moveq.l		#0,d2			not quitting

; remove highlight from gadget and exit

.invalid	rts		


_mFileSel	move.l		a0,a3			safe!

		move.l		_mLastSel(a6),d0	addr of last name
		cmp.l		LN_NAME(a3),d0		same name?
		beq.s		.CheckDouble		go for it!			

; this is a new selection. Copy required details and exit!

		move.l		LN_NAME(a3),_mLastSel(a6) ptr to name
		move.l		d5,_mLastSec(a6)	save the time
		move.l		d6,_mLastMicro(a6)
		
		lea		_mName(a6),a1		dest
		move.l		LN_NAME(a3),a0		source
		bsr		_mStrCpy		copy it!

		lea		_mFileGadg,a0		Gadget
		move.l		_mwindow.ptr(a6),a1	Window
		suba.l		a2,a2			not requester
		moveq.l		#1,d0			1 gadget
		mINT		RefreshGList		redisplay

		bra.s		.done

; second time selected, see if double-clicked!

.CheckDouble	move.l		_mLastSec(a6),d0	last time stamp
		move.l		_mLastMicro(a6),d1
		move.l		d5,d2			this time stamp
		move.l		d6,d3
		mINT		DoubleClick
		tst.l		d0			?????
		bne.s		.isTrue			branch if accepted

; not within double-click range! Save current ticks and exit.

		move.l		d5,_mLastSec(a6)	save the time
		move.l		d6,_mLastMicro(a6)
		bra.s		.done

; must be a double click, accept the file.

.isTrue		moveq.l		#2,d7			set return code
		move.l		#CLOSEWINDOW,d2		signal exit
		rts

.done		rts		

;--------------
;--------------	Cancel gadget
;--------------

_mDoCancel	move.l		#CLOSEWINDOW,d2		signal exit
		moveq.l		#1,d7			set return value
		rts

;--------------
;--------------	Dir path string entry gadget
;--------------

_mDoDir		movem.l		d0-d7/a0-a6,-(sp)

		bsr		_mFreeList
		lea		_mPath(a6),a0
		bsr		_mGetDirList
		bsr		_mFreshDisplay

		movem.l		(sp)+,d0-d7/a0-a6
		rts

;--------------
;--------------	Disk gadget
;--------------

_mDoDisk	movem.l		d0-d7/a0-a6,-(sp)

; refresh the string gadget to confirm action taken

		move.l		#0,_mPath(a6)
		lea		_mDirGadg,a0
		move.l		_mwindow.ptr(a6),a1
		suba.l		a2,a2
		moveq.l		#1,d0
		mINT		RefreshGList

		bsr		_mFreeList
		bsr		_mGetVolList
		bsr		_mFreshDisplay

		movem.l		(sp)+,d0-d7/a0-a6
		rts

;--------------
;--------------	Parent gadget
;--------------

_mDoParent	movem.l		d0-d7/a0-a6,-(sp)

		bsr		_mFreeList
		lea		_mPath(a6),a0
		bsr		_UpLevel

; refresh the string gadget to confirm action taken

		lea		_mDirGadg,a0
		move.l		_mwindow.ptr(a6),a1
		suba.l		a2,a2
		moveq.l		#1,d0
		mINT		RefreshGList

		bsr		_mGetDirList
		bsr		_mFreshDisplay

		movem.l		(sp)+,d0-d7/a0-a6
		rts

;--------------
;--------------	Scroll down gadget
;--------------

_mDoDown	cmp.l		#GADGETUP,d2		determine action
		bne.s		.activate		jump if just pressed
		move.l		#0,_mGadgSub(a6)	clear pointer
		bra.s		.done
.activate	move.l		#_mGoDown,_mGadgSub(a6) set pointer
.done		rts

_mGoDown	move.l		_mTopNode(a6),d0
		cmp.l		_mMaxTopNode(a6),d0
		bge.s		.done
		addq.l		#1,_mTopNode(a6)
		bsr		_mFreshDisplay
.done		rts

;--------------
;--------------	Scroll up gadget
;--------------

_mDoUp		cmp.l		#GADGETUP,d2		determine action
		bne.s		.activate		jump if just pressed
		move.l		#0,_mGadgSub(a6)	clear pointer
		bra.s		.done
.activate	move.l		#_mGoUp,_mGadgSub(a6)	set pointer
.done		rts

_mGoUp		cmp.l		#1,_mTopNode(a6)
		ble.s		.done
		subq.l		#1,_mTopNode(a6)
		bsr		_mFreshDisplay
.done		rts


*--------------------------------------------------------------------------*
*		LIST BUILDING - FREEING ROUTINES			   *
*--------------------------------------------------------------------------*

;--------------
;--------------	Count valid entries in a list
;--------------

; Entry		ao->list header
; Exit		d0=number of entries
;		a0->list tail
; corrupt	d0,a0

_mSumList		moveq.l		#0,d0			init counter
		
.loop		move.l		LN_SUCC(a0),a0		move to next entry
		tst.l		LN_SUCC(a0)		end of list?
		beq.s		.done			if so quit
		addq.l		#1,d0			bump counter
		bra.s		.loop			and loop

; Calculate max value of node sitting at top of window. Numbering starts from
;1, so a value of 0 will signal an empty list error.

.done		move.l		d0,_mListLen(a6)	save size
		move.l		#1,_mTopNode(a6)	save init value
		move.l		d0,_mMaxTopNode(a6)	save max value

		beq.s		.error			quit if 0		
		sub.l		#7,d0			find max value
		bmi.s		.error			ignore negatives
		beq.s		.error			and zero
		move.l		d0,_mMaxTopNode(a6)	save max value

.error		rts

;--------------
;--------------	Build list of names of all entries in a directory
;--------------

; nd_Data contains entry name
; nd_Data1 contains entry type: 0=File, 1=Directory.

; Entry		none

; Exit		d0=number of entries in list ( hence directory )

; Corrupt	a0,d0

_mGetDirList	movem.l		d1-d7/a1-a6,-(sp)

; Get address of list header

		lea		_mHeader(a6),a5		head node

; Lock the directory

		lea		_mPath(a6),a0
		move.l		a0,d1			DIR name
		moveq.l		#ACCESS_READ,d2		access mode
		mDOS		Lock			get lock on dir
		move.l		d0,d6			save lock
		beq		.error1			quit if no lock

; Get memory for file info block

		move.l		#fib_SIZEOF,d0		size
		move.l		#MEMF_CLEAR,d1		type
		mEXEC		AllocMem		and get mem block
		tst.l		d0			did we get it?
		beq		.error2			quit if not
		move.l		d0,a4

; Examine the directory.

		move.l		d6,d1			lock
		move.l		a4,d2			mem block for fib
		mDOS		Examine			get fib
		tst.l		d0			read ok?
		beq		.Done			quit if error

; Examine next entry. Exit loop if last one has been done.

.NextEntry	move.l		d6,d1			lock
		move.l		a4,d2			fib
		mDOS		ExNext			get next entry
		tst.l		d0			all ok?
		beq		.Done			if not quit

; Allocate memory for node.

		moveq.l		#LN_SIZE,d0		size
		move.l		#MEMF_CLEAR,d1		type
		mEXEC		AllocMem		get memory
		tst.l		d0			ok?
		beq.s		.Done			exit if not
		move.l		d0,a3			keep safe

; Allocate memory for copy of name.

		lea		fib_FileName(a4),a0	a0->name
		bsr		_mStrLen		determine length
		addq.l		#1,d0			correct for NULL
		move.l		d0,d5			name length
		move.l		#MEMF_CLEAR,d1		type
		mEXEC		AllocMem		get memory
		move.l		d0,d4			keep safe
		bne.s		.GotAllMem		branch if allocated
		
		;error handler. If no mem for name, release node and quit!
		
		move.l		a3,a1			node address
		moveq.l		#LN_SIZE,d0		node size
		mEXEC		FreeMem			release it
		bra.s		.Done			and exit

; Copy name into allocated memory.

.GotAllMem	lea		fib_FileName(a4),a0	source
		move.l		d4,a1			destination
		move.l		d5,d0			clear
		mEXEC		CopyMem			copy name

; Link name to node.

		move.l		d4,LN_NAME(a3)		store name pointer

; Copy entry type into priority field.

		move.b		#0,LN_PRI(a3)		default to FILE
		tst.l		fib_DirEntryType(a4)	examine entry
		bpl.s		.AddIt			skip if is a file
		move.b		#3,LN_PRI(a3)		set as DIR

; Add node to list.

.AddIt		move.l		a5,a0			header
		move.l		a3,a1			node
		mEXEC		Enqueue			add it!

; Step on to next entry

		bra		.NextEntry		and loop back

; Release the file info block memory

.Done		move.l		a4,a1			a1->mem block
		move.l		#fib_SIZEOF,d0		size of block
		mEXEC		FreeMem			and release it

; Unlock the directory

.error2		move.l		d6,d1			d1=file lock
		mDOS		UnLock			and release it

; Calculate number of entries in the list

.error1		move.l		a5,a0			list header
		bsr		_mSumList		count entries

		move.l		d0,_mListLen(a6)	save count

; SumList returns the number of entries in the list in register d0

		movem.l		(sp)+,d1-d7/a1-a6
		rts

;--------------
;--------------	Build a list of available volumes and assigns
;--------------

* Entry		None, though _DOSBase must be available and set correctly.

* Exit		d0=address of list header or NULL if error occurred

* Corrupt	d0

* Author	M.Meany

_mGetVolList	movem.l		d1-d7/a0-a6,-(sp)	save registers

; Allocate memory for list header and initialise it.

		lea		_mHeader(a6),a5		save in safe reg

; Locate the start of the Device list.

		move.l		_mDOSBase(a6),a4
		move.l		dl_Root(a4),a0		a0->Root Node
		move.l		rn_Info(a0),d0		d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a0			a0->DosInfo
		move.l		di_DevInfo(a0),d0	d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a4			a4->Device list

; Check entry is of required type, skip it if not.

.Loop		move.l		dl_Type(a4),d4		d4=Type
		cmp.l		#1,d4			min value
		blt		.Next			skip if lower
		cmp.l		#2,d4			max value
		bgt		.Next			skip if higher

; Allocate memory for node.

		moveq.l		#LN_SIZE,d0		size
		move.l		#MEMF_CLEAR,d1		type
		mEXEC		AllocMem		get memory
		tst.l		d0			ok?
		beq		.error			exit if not
		move.l		d0,a3			keep safe

; Allocate memory for copy of name.

		move.l		dl_Name(a4),d0		BPTR
		asl.l		#2,d0			convert
		move.l		d0,a2			a2->name (BSTR)
		moveq.l		#0,d0			clear
		move.b		(a2)+,d0		d0=name length
		addq.l		#2,d0			+2 for ':',0
		move.l		#MEMF_CLEAR,d1		type
		mEXEC		AllocMem		get memory
		move.l		d0,d7			keep safe
		bne.s		.GotAllMem		branch if allocated
		
		;error handler. If no mem for name, release node and quit!
		
		move.l		a3,a1			node address
		moveq.l		#LN_SIZE,d0		node size
		mEXEC		FreeMem			release it
		bra.s		.error			and exit

; Copy name into allocated memory.

.GotAllMem	move.l		a2,a0			source
		move.l		d7,a1			destination
		moveq.l		#0,d0			clear
		move.b		-1(a2),d0		size
		move.b		#':',0(a1,d0)
		mEXEC		CopyMem			copy name

; Link name to node.

		move.l		d7,LN_NAME(a3)		store name pointer

; Copy entry type into priority field.

		move.l		dl_Type(a4),d0		Type
		move.b		d0,LN_PRI(a3)		into node struct

; Add node to list.

		move.l		a5,a0			header
		move.l		a3,a1			node
		mEXEC		Enqueue			add it!

; Step on to next entry

.Next		move.l		(a4),d0			step on
		beq.s		.error			exit if so
		asl.l		#2,d0			convert BPTR
		move.l		d0,a4
		bra		.Loop

; Address of header into d0.

.error		move.l		a5,d0			header

; All entries processed, so exit.

.QuitFast	movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					exit



;--------------
;--------------	Free a list 
;--------------

* Entry		none

* Exit		none.

* Corrupt	none.

* Author	M.Meany

_mFreeList	movem.l		d0-d7/a0-a6,-(sp)	save

		lea		_mHeader(a6),a0
		move.l		a0,a4			a4->header
		move.l		a0,a3

; Get address of next node in list.

.NameLoop	TSTNODE		a3,a3			a3->next node
		beq.s		.NamesDone		branch if at tail

; Get address of nodes name.

		move.l		LN_NAME(a3),a0		a0->Name
		move.l		a0,a1			copy

; Determine length of name.

		moveq.l		#0,d0			length
.LenLoop	addq.l		#1,d0			bump counter
		tst.b		(a0)+			EOS?
		bne.s		.LenLoop		branch if not

; Release memory used for name and loop back.

		mEXEC		FreeMem			release it
		bra.s		.NameLoop		branch
		
; Remove next node from start of list.

.NamesDone	move.l		a4,a0			a0->list header
		mEXEC		RemHead			remove 1st node
		tst.l		d0			at tail?
		beq.s		.error			branch if so.

; Release memory used for removed node.

		move.l		d0,a1			a1->mem
		moveq.l		#LN_SIZE,d0		size
		mEXEC		FreeMem			free it
		bra.s		.NamesDone		and loop

; All memory released, so exit.

.error		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts

*--------------------------------------------------------------------------*
*		STRING MANIPULATION & PRINTING ROUTINES			   *
*--------------------------------------------------------------------------*

;--------------
;--------------	Calculate the length of a null terminated string
;--------------	

; Counts all characters in a NULL terminated byte sequence, NOT including the
;terminating NULL.

* Entry		a0->string

* Exit		d0=length

* Corrupted	d0

* Author	M.Meany

_mStrLen	move.l		a0,-(sp)
		moveq.l		#0,d0
		
.loop		tst.b		(a0)+
		beq.s		.done
		addq.l		#1,d0
		bra.s		.loop
		
.done		move.l		(sp)+,a0
		rts

;--------------
;--------------	Copy a null terminated text string
;--------------

; Copies all bytes in a NULL terminated byte sequence. Copies the terminating
;NULL as well.

* Entry		a0->string
; 		a1->dest buffer

* Exit		None

* Corrupted	None

* Author	M.Meany

_mStrCpy	move.l		a0,-(sp)
		move.l		a1,-(sp)
		
.loop		move.b		(a0)+,(a1)+	copy char
		bne.s		.loop		and loop

		move.l		(sp)+,a1
		move.l		(sp)+,a0
		
		rts

;--------------	
;--------------	Compare two strings
;--------------

; Compares two NULL terminated text strings and returns a value in d0
;that specifies the priority of one relative to the other.

* Entry 	a0->start of first word
;		a1->start of second word

* Exit		d0=0 if words the same
;		d0=1 if first word < second word
;		d0=2 if first word > second word

* Corrupted 	d0

* Author	M.Meany

_mStringCmp	movem.l		d1-d2/a0-a2,-(sp)

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
		
.first		moveq.l		#1,d0
		bra.s		.done
		
.second		moveq.l		#2,d0

.done		movem.l		(sp)+,d1-d2/a0-a2
		rts

;--------------
;--------------	Display 8 lines of list in window
;--------------

; Entry		none

; Exit		none

; Corrupt	none

_mFreshDisplay	movem.l		d0-d7/a0-a6,-(sp)

; First, clear the display box

		move.l		_mwindow.rp(a6),a1	RastPort
		moveq.l		#0,d0			pen colour
		mGRAF		SetAPen			and set it
		
		move.l		_mwindow.rp(a6),a1	RastPort
		moveq.l		#10,d0			xMin
		moveq.l		#12,d1			yMin
		move.l		#260,d2			xMax
		moveq.l		#83,d3			yMax
		mGRAF		RectFill		clear it

; Now print 8 lines from node

		lea		_mHeader(a6),a5		Head node
		move.l		_mTopNode(a6),d0	get offset
		subq.l		#1,d0			correct for DBcc
		beq.s		.there
		subq.l		#1,d0
		
.findpos	TSTNODE		a5,a5
		dbra		d0,.findpos

.there		moveq.l		#12,d6			Y offset
		moveq.l		#7,d5			loop counter			

.loop		TSTNODE		a5,a5			addr of next node
		beq		.Done			exit if Tail
		
		move.l		_mwindow.rp(a6),a0	RastPort
		lea		_mFileText(pc),a1	IntuiText
		cmp.b		#3,LN_PRI(a5)		is it a file?
		beq.s		.got_type		skip if so

		lea		_mVolText(pc),a1	IntuiText
		cmp.b		#2,LN_PRI(a5)		is it a disk
		beq.s		.got_type		skip if so

		lea		_mAsnText(pc),a1	IntuiText
		cmp.b		#1,LN_PRI(a5)		is it an assign
		beq.s		.got_type		skip if so

		lea		_mDirText(pc),a1	IntuiText

.got_type	move.l		LN_NAME(a5),it_IText(a1) set text pointer
		moveq.l		#10,d0			X offset
		move.l		d6,d1			Y offset
		mINT		PrintIText		print entry
		
		add.w		#8,d6			bump Y offset
		dbra		d5,.loop		for all lines

.Done		movem.l		(sp)+,d0-d7/a0-a6
		rts

;--------------
;--------------	Move path up 1 level towards root directory.
;--------------

; Entry		a0->path, must be NULL terminated.

; Exit		path updated

; Corrupt	None

; Author	M.Meany

* Note, will not go up a level if:
*				   1/ Directory is a disk.
*				   2/ Name is empty.
*
* Basically, inserts a NULL byte at a position that will cause the path to
*be same or one directory level nearer to root.

_UpLevel	move.l		a0,-(sp)		save

		move.l		a0,-(sp)		and again!

.loop1		tst.b		(a0)+			end of string?
		beq		.done			if so exit loop!
		
; not end of string, see if a ':' delimiter

		cmp.b		#':',(a0)		disk identifier?
		bne.s		.check_dir		skip if not!
		move.l		a0,(sp)			else save address
		addq.l		#1,(sp)			bump past delimeter
		bra.s		.loop1			and loop back

; not a disk delimiter, see if a '/' delimiter.

.check_dir	cmp.b		#'/',(a0)		dir identifier?
		bne.s		.loop1			loop back if not
		move.l		a0,(sp)			else save address
		bra.s		.loop1			and loop back

; end of string located, insert NULL at last found delimiter!

.done		move.l		(sp)+,a0		get delimiters addr
		move.b		#0,(a0)			insert a NULL

; all done, so restore a0 and return.

		move.l		(sp)+,a0		restore
		rts					and exit

;--------------
;--------------	Tag a directory name onto a path.
;--------------

; Entry		a0->path, must be NULL terminated.
;		a1->directory name to tag onto path, also NULL terminated.

; Exit		path updated

; Corrupt	None

; Author	M.Meany

* Will not tag directory on if path buffer cannot hold all it's chars. Path 
*buffer is assumed to be terminated by a $ff byte.

_TagDirName	move.l		d0,-(sp)
		move.l		a0,-(sp)		save
		move.l		a1,-(sp)

; locate end of pathname

.loop1		tst.b		(a0)+			end of path?
		bne.s		.loop1			keep goin if not
		subq.l		#1,a0			step back 1 char
		
		move.l		a0,-(sp)		save this address

; if path is not a volume name or empty, append a '/' delimiter

		move.l		8(sp),d0		d0=addr of path
		cmp.l		a0,d0			start of path?
		beq.s		.loop2			skip if so
		cmp.b		#':',-1(a0)		path is a volume?
		beq.s		.loop2			skip if so
		move.b		#'/',(a0)+		append delimeter

; see if room in buffer for another character

.loop2		cmp.b		#$ff,(a0)		end of buffer?
		beq		.error			if so exit cleanly!

; there is room, so copy next character

		move.b		(a1)+,(a0)+		copy one more char
		bne.s		.loop2			and loop for next

; string copied. Restore stack and registers then return.

		move.l		(sp)+,a1		restore stack
		move.l		(sp)+,a1		restore registers
		move.l		(sp)+,a0
		move.l		(sp)+,d0
		rts					exit

; end of path buffer reached. Restore old path and exit gracefully.

.error		move.l		(sp)+,a0		end of old pathname
		move.b		#0,(a0)			NULL terminate
		move.l		(sp)+,a1		restore registers
		move.l		(sp)+,a0
		move.l		(sp)+,d0
		rts					and exit
		
****************************************************************************
*		INTUITION DEFENITIONS					   *
****************************************************************************
_mWin
	dc.w	11,50
	dc.w	300,136
	dc.b	0,1
	dc.l	MOUSEBUTTONS+GADGETDOWN+GADGETUP+CLOSEWINDOW+INTUITICKS
	dc.l	WINDOWDRAG+WINDOWCLOSE+ACTIVATE+RMBTRAP+NOCAREREFRESH
	dc.l	_mFileGadg
	dc.l	0
	dc.l	.Name
	dc.l	0
	dc.l	0
	dc.w	300,136
	dc.w	300,136
	dc.w	WBENCHSCREEN
.Name
	dc.b	'Select File ',0
	even


_mFileGadg:
	dc.l	_mDirGadg
	dc.w	60,104
	dc.w	232,10
	dc.w	0
	dc.w	RELVERIFY
	dc.w	STRGADGET
	dc.l	_mBorder3
	dc.l	0
	dc.l	IText1
	dc.l	0
	dc.l	.SInfo
	dc.w	0
	dc.l	_mDoFile

.SInfo
	dc.l	0		pointer to filenamee buffer
	dc.l	0
	dc.w	0
	dc.w	99
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0

IText1:
	dc.b	1,0,RP_JAM2,0
	dc.w	-49,0
	dc.l	0
	dc.l	ITextText1
	dc.l	0
ITextText1:
	dc.b	'File',0
	even

_mDirGadg:
	dc.l	_mPropGadg
	dc.w	60,91
	dc.w	232,10
	dc.w	0
	dc.w	RELVERIFY
	dc.w	STRGADGET
	dc.l	_mBorder3
	dc.l	0
	dc.l	IText2
	dc.l	0
	dc.l	_mDirGadgSInfo
	dc.w	0
	dc.l	_mDoDir
_mDirGadgSInfo:
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	255
	dc.w	0
	dc.w	0,0,0,0,0
	dc.l	0
	dc.l	0
	dc.l	0
IText2:
	dc.b	1,0,RP_JAM2,0
	dc.w	-49,0
	dc.l	0
	dc.l	ITextText2
	dc.l	0
ITextText2:
	dc.b	'Dir',0
	even

_mPropGadg:
	dc.l	_mCancelGadg
	dc.w	278,15
	dc.w	11,47
	dc.w	0
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	PROPGADGET
	dc.l	Image1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	_mPropGadgSInfo
	dc.w	0
	dc.l	_mDoProp
_mPropGadgSInfo:
	dc.w	AUTOKNOB+FREEVERT+PROPBORDERLESS
	dc.w	0,1336
	dc.w	1,1310
	dc.w	0,0,0,0,0,0
Image1:
	dc.w	0,0
	dc.w	11,4
	dc.w	0
	dc.l	0
	dc.b	$0000,$0000
	dc.l	0

_mCancelGadg
	dc.l	_mOkGadg
	dc.w	15,116
	dc.w	56,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	_mBorder1
	dc.l	0
	dc.l	IText3
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoCancel
IText3:
	dc.b	1,0,RP_JAM1,0
	dc.w	3,3
	dc.l	0
	dc.l	ITextText3
	dc.l	0
ITextText3:
	dc.b	'CANCEL',0
	even
_mOkGadg:
	dc.l	_mDiskGadg
	dc.w	225,116
	dc.w	56,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	_mBorder1
	dc.l	0
	dc.l	IText4
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoOk
IText4:
	dc.b	1,0,RP_JAM1,0
	dc.w	17,3
	dc.l	0
	dc.l	ITextText4
	dc.l	0
ITextText4:
	dc.b	'OK',0
	even
_mDiskGadg:
	dc.l	_mParentGadg
	dc.w	85,116
	dc.w	56,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	_mBorder1
	dc.l	0
	dc.l	IText5
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoDisk
IText5:
	dc.b	1,0,RP_JAM1,0
	dc.w	7,3
	dc.l	0
	dc.l	ITextText5
	dc.l	0
ITextText5:
	dc.b	'DISKS',0
	even

_mParentGadg
	dc.l	_MUpGadg
	dc.w	155,116
	dc.w	56,13
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	_mBorder1
	dc.l	0
	dc.l	IText6
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoParent
IText6:
	dc.b	1,0,RP_JAM1,0
	dc.w	3,3
	dc.l	0
	dc.l	ITextText6
	dc.l	0
ITextText6:
	dc.b	'PARENT',0
	even
_MUpGadg:
	dc.l	_mDownGadg
	dc.w	277,64
	dc.w	15,10
	dc.w	0
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	_mBorder2
	dc.l	0
	dc.l	IText7
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoUp
IText7:
	dc.b	1,0,RP_JAM1,0
	dc.w	3,2
	dc.l	0
	dc.l	ITextText7
	dc.l	0
ITextText7:
	dc.b	'U',0
	even
_mDownGadg:
	dc.l	_Sel1Gadg
	dc.w	277,76
	dc.w	15,10
	dc.w	0
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	_mBorder2
	dc.l	0
	dc.l	IText8
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	_mDoDown
IText8:
	dc.b	1,0,RP_JAM1,0
	dc.w	3,2
	dc.l	0
	dc.l	ITextText8
	dc.l	0
ITextText8:
	dc.b	'D',0
	even
_Sel1Gadg:
	dc.l	_mSel2Gadg
	dc.w	10,12
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	1
	dc.l	_mDoSelect

_mSel2Gadg
	dc.l	_mSel3Gadg
	dc.w	10,20
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	2
	dc.l	_mDoSelect

_mSel3Gadg
	dc.l	_mSel4Gadg
	dc.w	10,28
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	3
	dc.l	_mDoSelect

_mSel4Gadg:
	dc.l	_mSel5Gadg
	dc.w	10,36
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	4
	dc.l	_mDoSelect

_mSel5Gadg:
	dc.l	_mSel6Gadg
	dc.w	10,44
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	5
	dc.l	_mDoSelect

_mSel6Gadg:
	dc.l	_mSel7Gadg
	dc.w	10,52
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	6
	dc.l	_mDoSelect

_mSel7Gadg:
	dc.l	_mSel8Gadg
	dc.w	10,60
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	7
	dc.l	_mDoSelect

_mSel8Gadg:
	dc.l	0
	dc.w	10,68
	dc.w	250,8
	dc.w	0
	dc.w	GADGIMMEDIATE+RELVERIFY
	dc.w	BOOLGADGET
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	8
	dc.l	_mDoSelect

_mBorder1
	dc.w	-1,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	58,0
	dc.w	58,15
	dc.w	0,15
	dc.w	0,0

_mBorder2
	dc.w	-1,-1
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	17,0
	dc.w	17,12
	dc.w	0,12
	dc.w	0,0

_mBorder3
	dc.w	-2,-2
	dc.b	1,0,RP_JAM1
	dc.b	5
	dc.l	.Vectors
	dc.l	0

.Vectors
	dc.w	0,0
	dc.w	234,0
	dc.w	234,11
	dc.w	0,11
	dc.w	0,0

_mFileText
	dc.b	1,0,RP_JAM2,0
	dc.w	0,0
	dc.l	0
	dc.l	0
	dc.l	0

_mDirText
	dc.b	1,0,RP_JAM2,0
	dc.w	48,0
	dc.l	0
	dc.l	0
	dc.l	.IText

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	0,0
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'<DIR> ',0
	even

_mAsnText
	dc.b	1,0,RP_JAM2,0
	dc.w	48,0
	dc.l	0
	dc.l	0
	dc.l	.IText

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	0,0
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'<ASN> ',0
	even

_mVolText
	dc.b	1,0,RP_JAM2,0
	dc.w	48,0
	dc.l	0
	dc.l	0
	dc.l	.IText

.IText
	dc.b	3,0,RP_JAM2,0
	dc.w	0,0
	dc.l	0
	dc.l	.Text
	dc.l	0
.Text
	dc.b	'<VOL> ',0
	even


****************************************************************************
*			Data Block					   *
****************************************************************************

		rsreset
		
; First in the block we have the list header used by all routines. This is a
;dual purpose header, used for the volume list as well as the directory list.

_mHeader	rs.l		LH_SIZE			list header

_mListLen	rs.l		1			num entries in list

_mTopNode	rs.l		1
_mMaxTopNode	rs.l		1

_mLastSel	rs.l		1
_mLastSec	rs.l		1
_mLastMicro	rs.l		1

; the buffer for the file path

_mPath		rs.b		256			100 byte path buffer
_mPathEnd	rs.l		1			set = $ffffffff

; the buffer for the filename

_mName		rs.b		100			100 byte name buffer

; somewhere to store address of supplied rqInfo structure

_mrqInfo	rs.l		1

; window pointers

_mwindow.ptr	rs.l		1
_mwindow.up	rs.l		1
_mwindow.rp	rs.l		1

_mGadgSub	rs.l		1

; Lib base pointers

_mDOSBase	rs.l		1
_mINTBase	rs.l		1
_mGFXBase	rs.l		1

; size of variable block

_mSIZE		rs.b		0			size of var block

