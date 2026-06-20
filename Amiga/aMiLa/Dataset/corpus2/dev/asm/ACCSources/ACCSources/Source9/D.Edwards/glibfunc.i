


* Graphics & Intuition functions include files to make life
* easier for lazy users. Calling synopsis for each function
* in function list below, full docs for each function where
* relevant. If the function is described as NON-MODIFIABLE
* then the function has been exhaustively tested and WORKS
* IN ALL CASES. Other functions can be modified by user at
* will if user's own special case usage demands it (or any
* bugs are discovered!)

* This file is PUBLIC DOMAIN. Use, modify, etc., to your
* heart's content.

* NEEDS THE FOLLOWING INCLUDE FILES LINKED INTO YOUR CODE:

* my_exec.i
* my_dos.i
* my_intuition.i
* my_graf.i


* BUG REPORTS, USER'S OWN UPDATES : SEND ALL BUG REPORTS, WITH
* ALL THE USUAL INFORMATION (WHAT YOU CALLED, WITH WHAT PARAMETERS
* ETC, PLUS RELEVANT SMALL PORTION OF YOUR SOURCE WHERE THE BUG
* OCCURRED) TO:


*		Dave Edwards
*		232 Hale Road
*		WIDNES
*		Cheshire
*		WA8 8QA


* Contact above address also for the include files mentioned above, which
* are also Public Domain. If you want updated copy, provide a small jiffy
* bag or stiff envelope with a 1st class stamp & your address for return.
* Files will be returned on the disc you send.



* Function List:


* rp = MakeOwnRastPort (BitMap)
* D0			A0

* KillOwnRastPort(rp)
*		A0

* MakeAllVPorts (View,ViewPort)
*		A0	A1

* BitMap = NewBitMap (width,height,depth)
*   D0		     D0	   D1	 D2

* DisposeBitMap (BitMap,width,height,depth)
*		A0	D0   D1	   D2


* InitWindow (Window) -> Viewport, Rastport, UserPort
*	       A0	D0	  D1	   D2

* OpenSW (NewScreen,NewWindow,BitMap) -> Screen, Window, Viewport,
*	    A0	     A1	     A2		A0    A1	      D0

*					RastPort, UserPort, Success
*					   D1	    D2	     D3

* CloseSW (Screen, Window)
*	    A0	   A1






* MakeOwnRastPort(a0) -> d0
* a0 = ptr to BitMap to attach to it
* if wanted, NULL if none available.

* Create a RastPort if possible.
* returns D0=NULL if failed,
* D0=ptr to RastPort if succeeded

* d0/d1/a1/a5 corrupt


MakeOwnRastPort	movem.l	a0/a5,-(sp)

		move.l	#rp_sizeof,d0		;create a
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1	;RastPort struct
		CALLEXEC	AllocMem
		move.l	d0,a5
		tst.l	d0			;get one?
		beq.s	MORP_done		;no, bye

		move.l	d0,a1			;make it a real
		CALLGRAF	InitRastPort		;RastPort

		move.l	(sp),d0			;got a BitMap?
		beq.s	MORP_ok			;no, don't link in

		move.l	d0,rp_BitMap(a5)	;else link in BitMap

MORP_ok		move.l	a5,d0		;pointer to RastPort

MORP_done	movem.l	(sp)+,a0/a5
		rts




* KillOwnRastPort(a0)
* a0 = ptr to RastPort to get rid of
* won't do it if RaspPort doesn't exist.

* d0/d1/a1/a5 corrupt


KillOwnRastPort	move.l	a0,d0		;check if RastPort exists
		beq.s	KORP_done	;it doesn't so exit

		move.l	d0,a1
		move.l	#rp_sizeof,d0
		CALLEXEC	FreeMem		;get rid of it.

KORP_done	rts



* MakeAllVPorts(a0,a1)
* a0 = pointer to View structure
* a1 = pointer to ViewPort structure

* If a ViewPort structure has others
* linked to it in a list, this function
* will perform a MakeVPort() on ALL of
* them, ensuring that ALL ViewPorts are
* properly created. Saves the hassle of
* doing it yourself.

* d0/a1 corrupt


MakeAllVPorts	movem.l	a0/a1,-(sp)	;save View, ViewPort pointers

		move.l	a1,d0		;get 1st Viewport
		beq.s	MAVP_done	;if nonexistent, exit

		move.l	d0,a1
		CALLGRAF	MakeVPort	;this one

		movem.l	(sp)+,a0/a1	;recover View,ViewPort pointers

		move.l	vp_Next(a1),a1	;and get next ViewPort
		bra.s	MakeAllVPorts	;in list, & repeat action
		
MAVP_done	rts


* Workspace allocation defs for NewBitMap() etc


nbm_width	equ	-2
nbm_height	equ	-4
nbm_depth	equ	-6
nbm_pointer	equ	-10
nbm_ssize	equ	-14
nbm_space	equ	-18


* NewBitMap(d0,d1,d2) -> d0
* Allocate memory for, & initialise a BitMap
* structure. Also allocate all of the Raster
* bitplanes needed for it, & link them in.
* d0 = width in pixels
* d1 = height in pixels
* d2 = depth in pixels

* returns d0 = ptr to bitmap structure if allocated AND
* all Raster bitplanes obtained, else NULL

* d0-d2/d7/a0/a4 corrupt

* NON-MODIFIABLE.


NewBitMap	link	a5,#nbm_space	;reserve some workspace!

		move.w	d0,nbm_width(a5)
		move.w	d1,nbm_height(a5)
		move.w	d2,nbm_depth(a5)

		moveq	#bm_Planes,d0
		lsl.w	#2,d2
		add.w	d2,d0		;size of BitMap structure
		ext.l	d0
		move.l	d0,nbm_ssize(a5)	;keep it!

		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,nbm_pointer(a5)	;save pointer
		beq	NBM_done			;oops...

		move.l	d0,a0
		move.w	nbm_depth(a5),d0
		move.w	nbm_width(a5),d1
		move.w	nbm_height(a5),d2
		CALLGRAF	InitBitMap		;init BitMap struct

		move.w	nbm_depth(a5),d7		;no of bitplanes

		move.l	nbm_pointer(a5),a4
		lea	bm_Planes(a4),a4		;where Plane ptrs go

NBM_l1		move.w	nbm_width(a5),d0
		move.w	nbm_height(a5),d1
		CALLGRAF	AllocRaster		;get a Raster bitplane
		move.l	d0,(a4)+			;save pointer
		beq.s	NBM_b1			;cock up!

		subq.w	#1,d7			;done all bitplanes?
		bne.s	NBM_l1			;back if not

		move.l	nbm_pointer(a5),d0	;all's well-return ptr
		bra.s	NBM_done

* From here on, couldn't allocate a Raster bitplane. So deallocate
* those that exist, then deallocate the BitMap structure & return
* a zero pointer.

NBM_b1		move.l	nbm_pointer(a5),a0
		lea	bm_Planes(a0),a0
		move.l	a0,d7

NBM_l2		move.l	-(a4),d0		;this one WAS allocated?
		beq.s	NBM_b3		;no
		move.l	d0,a0		;else this is pointer
		move.w	nbm_width(a5),d0	;size across
		move.w	nbm_height(a5),d1	;and down
		CALLGRAF	FreeRaster	;get rid of it!

NBM_b3		cmp.l	a4,d7		;last one?
		bcs.s	NBM_l2		;no, go back

		move.l	nbm_ssize(a5),d0
		move.l	nbm_pointer(a5),a1	;now free up the
		CALLEXEC	FreeMem			;BitMap struct!

		moveq	#0,d0			;return NULL ptr

NBM_done		unlk	a5
		rts


* DisposeBitMap(a0,d0,d1,d2)
* Get rid of allocated BitMap structure and its
* associated Raster bitplanes.
* a0 = ptr to BitMap to dispose of
* d0 = width of planes to dispose of
* d1 = height of planes to dispose of
* d2 = no of planes to dispose of

* d0/a0/a4 corrupt

* NON-MODIFIABLE.


DisposeBitMap	link	a5,#nbm_space

		move.w	d0,nbm_width(a5)
		move.w	d1,nbm_height(a5)
		move.w	d2,nbm_depth(a5)

		move.l	a0,d0		;check if it exists
		beq.s	DBM_done		;no it doesn't!

		move.l	a0,nbm_pointer(a5)	;save BitMap ptr
		lea	bm_Planes(a0),a4		;ptr to Plane ptrs!

		move.w	d2,d7			;counter
		lsl.w	#2,d2
		add.w	#bm_Planes,d2
		ext.l	d2
		move.l	d2,nbm_ssize(a5)		;size of struct also

DBM_l1		move.l	(a4)+,d0			;get plane pointer
		beq.s	DBM_b1			;doesn't exist
		move.l	d0,a0
		move.w	nbm_width(a5),d0
		move.w	nbm_height(a5),d1
		CALLGRAF	FreeRaster		;get rid of raster

DBM_b1		subq.w	#1,d7			;done?
		bne.s	DBM_l1			;back if not

		move.l	nbm_pointer(a5),a1
		move.l	nbm_ssize(a5),d0
		CALLEXEC	FreeMem			;get rid of BitMap

DBM_done		unlk	a5
		rts


* InitWindow(a0) -> d0-d2
* a0 = pointer to Window structure
* return parameters are:
* d0 = ViewPort pointer
* d1 = RastPort pointer
* d2 = User Port pointer

* NON-MODIFIABLE.


InitWindow	move.l	a0,-(sp)
		CALLINT	ViewPortAddress
		move.l	(sp)+,a0
		move.l	RastPort(a0),d1
		move.l	UserPort(a0),d2
		rts


* Workspace defs for OpenSW() etc


sw_screen	equ	-4
sw_window	equ	-8
sw_bitmap	equ	-12
sw_space		equ	-16


* OpenSW(a0,a1,a2) -> d0-d3,a0,a1
* Open Intuition screen and principal window
* a0 = pointer to NewScreen structure
* a1 = pointer to NewWindow structure
* a2 = pointer to custom BitMap structure if present,
* NULL if not (MUST be non-NULL for CUSTOMBITMAP Screen!)

* returns:
* a0 = pointer to Screen handle
* a1 = pointer to Window handle
* d0 = pointer to Window ViewPort
* d1 = pointer to Window RastPort
* d2 = pointer to Window User Port
* d3 = success/failure

* NON-MODIFIABLE.


OpenSW		link	a5,#sw_space

		move.l	a0,sw_screen(a5)		;save input
		move.l	a1,sw_window(a5)		;parameters
		move.l	a2,sw_bitmap(a5)

		move.l	a2,d0			;got a bitmap?
		beq.s	OSW_2			;no

		move.l	d0,28(a0)		;set up bitmap ptr!

OSW_2		CALLINT	OpenScreen
		move.l	d0,sw_screen(a5)		;save Screen handle
		beq.s	OSW_1			;ain't got one!

		move.l	sw_bitmap(a5),d0		;get bitmap ptr

OSW_3		move.l	sw_screen(a5),d1		;get custom screen ptr
		move.l	sw_window(a5),a0
		move.l	d0,34(a0)		;set up BitMap
		move.l	d1,30(a0)		;and screen ptr
		CALLINT	OpenWindow
		move.l	d0,sw_window(a5)		;save Window handle
		beq.s	OSW_1			;oops...

		move.l	d0,a0
		bsr.s	InitWindow		;get important
		moveq	#TRUE,d3			;parameters
		bra.s	OSW_done			;& signal success

OSW_1		moveq	#FALSE,d3		;signal failure
		move.l	d3,d0		;and clear all of
		move.l	d3,d1		;the RastPort pointers
		move.l	d3,d2		;etc.

OSW_done		move.l	sw_screen(a5),a0
		move.l	sw_window(a5),a1

		unlk	a5
		rts


* CloseSW(a0,a1)
* a0 = pointer to Screen
* a1 = pointer to Window
* closes screen/window opened by OpenSW()

* NON-MODIFIABLE.


CloseSW		move.l	a0,-(sp)		;save screen ptr
		move.l	a1,d0		;Window exists?
		beq.s	CSW_1		;no

		move.l	d0,a0
		CALLINT	CloseWindow	;else close it

CSW_1		move.l	(sp)+,d0		;get screen ptr back
		beq.s	CSW_2		;woops, wasn't opened!
		move.l	d0,a0
		CALLINT	CloseScreen	;close the screen
CSW_2		rts



