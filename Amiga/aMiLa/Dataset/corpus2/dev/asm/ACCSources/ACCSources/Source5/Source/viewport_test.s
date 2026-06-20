

* For Mark:this code is an attempt to solve your ViewPort problem.
* If it works, then when a line is drawn on the screen, it should
* appear in two different colours. If not, I'll have to look into
* the matter further.

* Right. I've tested it & got it to work. The test involves setting
* up 2 viewports with different colormaps. The top one has a black
* background, white for colour 1. The bottom one has a sick green
* background, and horrid pink for colour 1. The idea is to have them
* both 100 raster lines deep, and to position the top one at (0,0),
* the bottom one at (0,120) on a 256-line PAL screen.

* Having done that, I then draw a vertical line from (160,20) to
* (160,220). That part of the line falling into the top viewport
* should be white in colour, the part falling into the bottom viewport
* should be horrid pink (it's drawn in colour 1), assuming it works.

* Well, it does. The problem is this:as well as setting the variables
* RxOffset/RyOffset in the RasInfo structure, and the DWidth/DHeight
* variables in the ViewPort structure, you NEED to set DxOffset/DyOffset
* in the ViewPort structure also! The graphics library doesn't do it
* for you!

* And finally? Before calling MakeVPort, place the pointer to your first
* ViewPort in the View structure. This you must already have done to get
* the first viewport to be displayed, because until I did it, NONE of my
* viewports were displayed. To get BOTH displayed, I had to set by hand
* the DxOffset/DyOffset variables. Furthermore, after the LoadView() call,
* do a call to RemakeDisplay() to ensure that everything gets linked in
* properly by the system!

* Well, now that this code works, feel free to use it, chop it up, add to
* it or mutilate it in any way you want. No copyright involved, and I also
* urge you to pop it into the Tutorial section complete with these comments.

* P.S. This took 2 hrs 20 minutes to type in, 35 minutes to debug. Something
* of a record, I think.


		opt	d+


		include	Source5:include/my_exec.i
		include	Source5:include/my_dos.i
		include	Source5:include/my_intuition.i
		include	Source5:include/my_graf.i



* variables


		rsreset
dos_base		rs.l	1
int_base		rs.l	1
graf_base	rs.l	1

my_screen	rs.l	1
my_window	rs.l	1

my_bitmap	rs.l	1

bp_1		rs.l	1
bp_2		rs.l	1
bp_3		rs.l	1
bp_4		rs.l	1

my_viewport	rs.l	1
my_rastport	rs.l	1
my_userport	rs.l	1

my_vp1		rs.l	1
my_vp2		rs.l	1

my_ri1		rs.l	1
my_ri2		rs.l	1

int_view		rs.l	1

old_vp		rs.l	1

vars_sizeof	rs.w	0



main		move.l	#vars_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		tst.l	d0		;got space for my vars?
		beq	cock_up_1	;no-leave now
		move.l	d0,a6		;where my vars go!

		bsr	openlibs		;open libraries
		beq	cock_up_2	;can't do it-leave now

		bsr	initrasters	;init bitmap struct & rasters
		beq	cock_up_3	;can't do it-leave now

		bsr	opensw		;open Intuiton screen, window
		beq	cock_up_4

		CALLINT	ViewAddress
		move.l	d0,int_view(a6)	;get Intuition View address

		move.l	my_viewport(a6),a0
		lea	colourlist3(pc),a1
		moveq	#16,d0
		CALLGRAF	LoadRGB4


* here on is the viewport stuff


		bsr	setupvports

* Now link in custom viewports to Intuition view structure

		move.l	my_vp1(a6),a0
		move.l	int_view(a6),a1
		move.l	vw_ViewPort(a1),old_vp(a6)
		move.l	a0,vw_ViewPort(a1)

* Now do the MakeVPort() etc

		move.l	my_vp1(a6),a1
		move.l	int_view(a6),a0
		CALLGRAF	MakeVPort

		move.l	int_view(a6),a1
		CALLGRAF	MrgCop

		move.l	int_view(a6),a1
		CALLGRAF	LoadView

		CALLINT	RemakeDisplay

* Pop in two different Colormaps for the different ViewPorts to
* make sure that the code works!

		move.l	my_vp1(a6),a0
		lea	colourlist1(pc),a1
		moveq	#16,d0
		CALLGRAF	LoadRGB4

		move.l	my_vp2(a6),a0
		lea	colourlist2(pc),a1
		moveq	#16,d0
		CALLGRAF	LoadRGB4

* Wait for Mouse click

mousehang1	btst	#6,$BFE001	;wait for mouse button press
		bne.s	mousehang1

mousehang2	btst	#6,$BFE001
		beq.s	mousehang2

* Draw a line crossing BOTH ViewPorts to check if all's well

		move.l	my_rastport(a6),a1
		moveq	#1,d0
		CALLGRAF	SetAPen

		move.l	my_rastport(a6),a1
		move.w	#160,d0
		move.w	#20,d1
		CALLGRAF	Move

		move.l	my_rastport(a6),a1
		move.w	#160,d0
		move.w	#220,d1
		CALLGRAF	Draw

* Wait for Mouse click

mousehang3	btst	#6,$BFE001	;wait for mouse button press
		bne.s	mousehang3

mousehang4	btst	#6,$BFE001
		beq.s	mousehang4

* Make sure that the old window viewport is linked in before
* scratching the custom viewports!

		move.l	old_vp(a6),a0
		move.l	int_view(a6),a1
		move.l	a0,vw_ViewPort(a1)

		move.l	my_viewport(a6),a1
		move.l	int_view(a6),a0
		CALLGRAF	MakeVPort

		move.l	int_view(a6),a1
		CALLGRAF	MrgCop

		move.l	int_view(a6),a1
		CALLGRAF	LoadView

* Now kill off the old ViewPorts etc, return memory to Exec

		bsr	killvports


* now back to sanity...


cock_up_4	bsr	closesw		;close opened screen, window

cock_up_3	bsr	killrasters	;deallocate raster & bitmap memory

cock_up_2	bsr	closelibs	;close libraries

		move.l	a6,a1
		move.l	#vars_sizeof,d0
		CALLEXEC	FreeMem		;deallocate my vars!

cock_up_1	moveq	#0,d0		;signal that all's well
		rts

* openlibs(a6) -> d0
* a6 = ptr to my vars
* open all libraries
* d0=0 if any failed, -1 if all opened ok
* d0/a1 corrupt

openlibs		lea	dos_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary
		move.l	d0,dos_base(a6)
		beq.s	opened_libs

		lea	int_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary
		move.l	d0,int_base(a6)
		beq.s	opened_libs

		lea	graf_name(pc),a1
		moveq	#0,d0
		CALLEXEC	OpenLibrary
		move.l	d0,graf_base(a6)
		beq.s	opened_libs

		moveq	#-1,d0

opened_libs	rts

* closelibs(a6)
* a6 = ptr to my vars
* close any opened libraries
* d0/a1 corrupt

closelibs	move.l	graf_base(a6),d0
		beq.s	closelibs_2
		move.l	d0,a1
		CALLEXEC	CloseLibrary

closelibs_2	move.l	int_base(a6),d0
		beq.s	closelibs_1
		move.l	d0,a1
		CALLEXEC	CloseLibrary

closelibs_1	move.l	dos_base(a6),d0
		beq.s	closed_libs
		move.l	d0,a1
		CALLEXEC CloseLibrary

closed_libs	rts

* opensw(a6) -> d0
* a6 = ptr to my vars
* open Intuition screen & window
* d0=0 if any failed, -1 if ok
* d0/a0 corrupt

opensw		lea	newscreen(pc),a0
		move.l	my_bitmap(a6),28(a0)
		CALLINT	OpenScreen
		move.l	d0,my_screen(a6)
		beq.s	opened_sw

		lea	newwindow(pc),a0
		move.l	my_screen(a6),30(a0)
		move.l	my_bitmap(a6),34(a0)
		CALLINT	OpenWindow
		move.l	d0,my_window(a6)
		beq.s	opened_sw

		move.l	d0,a0
		bsr	initwindow
		move.l	d0,my_viewport(a6)
		move.l	d1,my_rastport(a6)
		move.l	d2,my_userport(a6)

		moveq	#-1,d0

opened_sw	rts

* closesw(a6)
* a6 = ptr to my vars
* close Intuition screen & window if opened
* d0/a0 corrupt

closesw		move.l	my_window(a6),d0
		beq.s	closesw_1
		move.l	d0,a0
		CALLINT	CloseWindow

closesw_1	move.l	my_screen(a6),d0
		beq.s	closed_sw
		move.l	d0,a0
		CALLINT	CloseScreen
	
closed_sw	rts

* initwindow(a0) -> d0-d2
* get viewport, rastport & userport addresses
* return:
* d0 = viewport addr
* d1 = rastport addr
* d2 = userport addr

initwindow	move.l	a0,-(sp)
		CALLINT	ViewPortAddress
		move.l	(sp)+,a0
		move.l	50(a0),d1
		move.l	86(a0),d2

		rts

* initrasters(a6) -> d0
* a6 = ptr to my vars
* initialise bitmap structure, then allocate rasters
* d0=0 if any failed, -1 if ok
* d0-d2/a0-a1 corrupt

initrasters	move.l	#bm_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,my_bitmap(a6)
		beq	initrast_done

		move.l	d0,a0
		move.w	#320,d1
		move.w	#256,d2
		moveq	#4,d0
		CALLGRAF	InitBitMap

		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	AllocRaster
		move.l	d0,bp_1(a6)
		beq.s	initrast_done

		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	AllocRaster
		move.l	d0,bp_2(a6)
		beq.s	initrast_done

		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	AllocRaster
		move.l	d0,bp_3(a6)
		beq.s	initrast_done

		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	AllocRaster
		move.l	d0,bp_4(a6)
		beq.s	initrast_done

		move.l	my_bitmap(a6),a0
		lea	bm_Planes(a0),a0
		lea	bp_1(a6),a1

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		moveq	#-1,d0

initrast_done	rts

* kilrasters(a6)
* deallocate rasters & bitmap structure if allocated
* d0-d1/a0-a1 corrupt

killrasters	move.l	bp_4(a6),d0
		beq.s	killrast_4
		move.l	d0,a0
		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	FreeRaster

killrast_4	move.l	bp_3(a6),d0
		beq.s	killrast_3
		move.l	d0,a0
		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	FreeRaster

killrast_3	move.l	bp_2(a6),d0
		beq.s	killrast_2
		move.l	d0,a0
		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	FreeRaster

killrast_2	move.l	bp_1(a6),d0
		beq.s	killrast_1
		move.l	d0,a0
		move.w	#320,d0
		move.w	#256,d1
		CALLGRAF	FreeRaster

killrast_1	move.l	my_bitmap(a6),d0
		beq.s	killed_rast
		move.l	d0,a1
		move.l	#bm_sizeof,d0
		CALLEXEC	FreeMem

killed_rast	rts

* setupvports(a6) -> d0
* a6 = ptr to my vars
* allocate memory for & construct viewports.
* d0=0 if any failed, -1 if ok
* d0-d1/a0-a1 corrupt

setupvports	move.l	#vp_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,my_vp1(a6)
		beq	setupvp_done

		move.l	#vp_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,my_vp2(a6)
		beq	setupvp_done

		move.l	#ri_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,my_ri1(a6)
		beq	setupvp_done

		move.l	#ri_sizeof,d0
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,my_ri2(a6)
		beq	setupvp_done

* initialise ViewPort structures with standard data

		move.l	my_vp1(a6),a0
		CALLGRAF InitVPort

		move.l	my_vp2(a6),a0
		CALLGRAF InitVPort

* initialise RasInfo structures, then link into ViewPort structures,
* link in BitMap structure to RasInfos, and get the ColorMaps.

		move.l	my_ri1(a6),a0
		move.l	my_vp1(a6),a1
		moveq	#0,d0

		move.w	d0,ri_RxOffset(a0)	;set RasInfo vars
		move.w	d0,ri_RyOffset(a0)
		move.l	my_bitmap(a6),ri_BitMap(a0)
		move.l	d0,ri_Next(a0)

		move.l	a0,vp_RasInfo(a1)		;set ViewPort vars
		move.w	#320,vp_DWidth(a1)
		move.w	#100,vp_DHeight(a1)
		move.w	d0,vp_DxOffset(a1)
		move.w	d0,vp_DyOffset(a1)

;		moveq	#16,d0
;		CALLGRAF	GetColorMap
;		move.l	d0,vp_ColorMap(a1)

		move.l	my_ri2(a6),a0
		move.l	my_vp2(a6),a1
		moveq	#0,d0

		move.w	d0,ri_RxOffset(a0)	;do the same here
		move.w	#120,ri_RyOffset(a0)
		move.l	my_bitmap(a6),ri_BitMap(a0)
		move.l	d0,ri_Next(a0)

		move.l	a0,vp_RasInfo(a1)		;and here
		move.w	#320,vp_DWidth(a1)
		move.w	#100,vp_DHeight(a1)
		move.w	d0,vp_DxOffset(a1)
		move.w	#120,vp_DyOffset(a1)

;		moveq	#16,d0
;		CALLGRAF	GetColorMap
;		move.l	d0,vp_ColorMap(a1)

* Now link two viewports together

		move.l	my_vp1(a6),a0
		move.l	my_vp2(a6),d0
		move.l	d0,vp_Next(a0)

		moveq	#-1,d0

setupvp_done	rts

* killvports(a6)
* a6 = ptr to my variables
* deallocate Viewports/Rasinfos etc.

killvports	move.l	my_ri2(a6),d0
		beq.s	killvp_3
		move.l	d0,a1
		move.l	#ri_sizeof,d0
		CALLEXEC	FreeMem

killvp_3		move.l	my_ri1(a6),d0
		beq.s	killvp_2
		move.l	d0,a1
		move.l	#ri_sizeof,d0
		CALLEXEC	FreeMem

killvp_2		move.l	my_vp2(a6),d0
		beq.s	killvp_1
		move.l	d0,a1
		move.l	#vp_sizeof,d0
		CALLEXEC	FreeMem

killvp_1		move.l	my_vp1(a6),d0
		beq.s	killed_vp
		move.l	d0,a1
		move.l	#vp_sizeof,d0
		CALLEXEC	FreeMem

killed_vp	rts


newscreen	dc.w	0,0
		dc.w	320,256
		dc.w	4
		dc.b	3,2
		dc.w	GENLOCK_VIDEO
		dc.w	CUSTOMSCREEN+CUSTOMBITMAP
		dc.l	0
		dc.l	newscreen_title
		dc.l	0
		dc.l	0	;insert bitmap ptr later


newwindow	dc.w	0,0
		dc.w	320,256
		dc.b	1,0
		dc.l	NULL	;no IDCMP
		dc.l	ACTIVATE+BACKDROP+BORDERLESS
		dc.l	NULL
		dc.l	NULL
		dc.l	NULL
		dc.l	NULL	;insert screen ptr later
		dc.l	NULL	;ditto for bitmap
		dc.w	10,10
		dc.w	320,256
		dc.w	CUSTOMSCREEN

colourlist1	dc.w	$000,$FFF,$048,$070
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000

colourlist2	dc.w	$3C3,$966,$000,$000
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000

colourlist3	dc.w	$FF0,$000,$06C,$262
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$000


newscreen_title	dc.b	"ViewPort Test",0

dos_name		dc.b	"dos.library",0

int_name		dc.b	"intuition.library",0

graf_name	dc.b	"graphics.library",0

		even


