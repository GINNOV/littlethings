

;$VER: Gauge.asm by Andry of PEGAS 0.1 (16.11.97)



;This piece of code opens a progress-indicator window,
; waits for informations from your code and displays it to user.



;ABOUT IT
;  The idea came from Olaf `Olsen' Barthel and his implementation of
;  a gauge, but his solution was not acceptable for me. Source in C,
;  too big compiled size (for a gauge at least), comunicating via message
;  ports (slower than just passing parameters in registers
;  and a gauge should not take too much CPU time...).
;  This is why I decided to make this code as it is.
;  (Still thanks for some tips Olaf..)

;  I tried to make it as simple as possible but still usable (you may think
;  that's because I'm too lazy. Well, you're right.. :-).
;  It was made for all coders (not hackers!) and all users of Amiga.

;REQUIREMENTS
;  Requires MC68020+ and system V36.
;  Tested on A1232/50MHz 4MB FAST KICK3.0
;         on A1260/100MHz 16MB FAST KICK 3.0
;         on A1260/100MHz 48MB FAST KICK3.1 CyberGraphX
;     and on A1200 KICK3.0


;COPYRIGHT
;  You may use it free and you may modify the source for your purposes.
;  When redistributing, all files must be kept unmodified and together.
;  Finally, you may give me credits :-)

;CONTACT
;  Comments and ideas send to:
;               s-mail: Andreas Bednarek, Tyrsova 4, 751 24, PREROV, CZECH REP.
;		        (tel: +420-641-68284)
;               e-mail: hanza@cbnet.cz (not PEGAS software mail, but you may
;                                       use it - try set subject to
;                                       Amiga/Nezhyba - name of my friend...)

;FILES IN ARCHIVE
;  - There are 7 files in the archive:
;        Advert.raw    200 * 150 * 8 colors raw brush
;        Gauge.asm     this file
;        Gauge.i       the include file
;        Gauge.o       the object file
;        GExample      example code
;        GExample.info icon
;        GExample.asm  source of the example code

;USAGE
;  The Gauge.o file gives you 3 external labels: ga_OpenGauge, ga_RedrawGauge
;  and ga_CloseGauge.

;  First call ga_OpenGauge() with desired parameters.
;  Then for every time you want to redraw the
;  progress-bar call ga_RedrawGauge().  At the end call
;  ga_CloseGauge().
;  ga_RedrawGauge() and ga_CloseGauge() may be called
;  either if ga_OpenGauge() failed, so you don't have to check
;  the result of ga_OpenGauge() and adapt your code;
;  the functions will just have no effect.
;  Read detail description of each function! (below)

;MORE ABOUT THE CODE
;  - Position dependent.

;  - All registers instead of a0-a1/d0-d1 are preserved after a function call.

;  - The ga_OpenGauge() function makes its window not active so if you have set
;    an alternate mouse-pointer it will not change.

;  - It allways depens on you how offen you call ga_RedrawGauge()
;    and how friendly will your program be to the user. If you call it
;    once per 10 seconds, the user has the posibbility to stop it once
;    per 10 seconds. Well...

;  - The compiled example is a little bit different due to the source code.
;    There are changes made just for more smoothness of the gauge bar.
;    (default 100% value is set to the same value as bar width.)

;IDEAS TO FUTURE  (may be never implemented)
;  - Display some text in the window.
;  - Use other mouse pointer.
;  - Use other font.

;  - More ideas, comments and bug reports are expected from you.


;BUGS	:-(
;  - When moving the gauge window, your task stops until done.

;  - The delay before open (GAF_SLEEPTIME) is specified by seconds.
;    So it's not very exact and a delay of 3 seconds may in real grow
;    up to 4 seconds. I hope to solve it soon (I think I'll use "timer.device").

;  - The visual representation may sometimes not exactly correspond to reality.
;    It's because I'm working with word-divisions to calculate the progress bar length.
;    If it happens to you, you have to shrink or expand the gauge width (GAF_WIDTH)
;    or set another value for 100%. In global, too big diference between these
;    two values may cause that problem.
;    (Try e.g.  65535 for 100% and 40 for bar width... or 3 for 100% and 500 for bar width...)
;    It didn't happen to me yet. For normal use suffice the default values.
;    If you want to know more about the problem, see ga_OpenGauge at place
;    where I'm calculating 1% (nearly at end of the function) and ga_RedrawGauge
;    at place where I "get new width of the bar".
;    If you have more elegant solution, just contact me.


;HISTORY
;    V0.1 (24.9.1997)  -  first public release



;More details about the functions:

	;----------------------------------------------------------------------
	;NAME	ga_OpenGauge
	;----------------------------------------------------------------------
	;FUNCTION
	;    Initializes and opens a progress bar window for you.

	;INPUT
	;    d0 - flags (LONG)

	;    Optional parameters (They are not necessary; see flags!):
	;    a0 - address of the screen/window where it should be opened on or
	;	  GaugeParams structure  (see GAF_STRUCTURE flag)
	;    a1 - ptr. to a string, which will be used for the STOP button
	;	  or NULL if default text shell be used.
	;    a2 - ptr. to a string, which will be in the gauge-window title
	;	  or NULL for default title.
	;    d1 - value, which represents 100% (WORD) (default is 100)
	;    d2 - initial delay (LONG) (see GAF_SLEEPTIME flag)
	;    d3 - progress bar width (WORD)
	;    d4 - WinLeft,WinTop (see GAF_NOCENTER flag)

	;RESULT
	;    d0 - success (BOOL) (checking not necessary...)

	;NOTE
	;    The way of passing the parameters is a bit unusual,
	;    but I wanted to make the usage as easy as possible. You just have to
	;    set d0 to zero and call ga_OpenGauge() for a usable gauge.
	;    Note that you can use also the GaugeParams structure!

	;SEE ALSO!!
	;    Gauge.i



	;----------------------------------------------------------------------
	;NAME	ga_RedrawGauge
	;----------------------------------------------------------------------
	;FUNCTION
	;    Redraws the gauge bar due to the number it gets from you.
	;    (See GAF_100VALUE flag). When GAF_ENABLESTOP flag is set, the result
	;    in d0 has to be checked for GA_STOP value which tells you if the user
	;    did or did not press the STOP button.

	;INPUT
	;    d0 - number to be represented (WORD)

	;RESULT
	;    None
	;      or if GAF_ENABLESTOP is set then check d0: GA_STOP if the user
	;      pressed the STOP button or NULL if not.

	;NOTE
	;    It may try to open the gauge window (see GAF_SLEEPTIME flag) and
	;    if it fails, you never realise it. The window will just not appear.
	;    This function may be called either if ga_OpenGauge() failed - it will
	;    have no effect.




	;----------------------------------------------------------------------
	;NAME	ga_CloseGauge
	;----------------------------------------------------------------------
	;FUNCTION
	;    closes the gauge window and frees all allocations

	;INPUT    none
	;RESULT   none

	;NOTE
	;    This function may be called either if ga_OpenGauge() failed - it will
	;    have no effect.





		XDEF	ga_OpenGauge,ga_CloseGauge,ga_RedrawGauge


		MACHINE	68020

		INCDIR	"INCLUDE:"
		INCLUDE	"Ram:Gauge.i"

		INCLUDE	"exec/types.i"
		INCLUDE	"exec/execbase.i"
		INCLUDE	"intuition/intuition.i"
		INCLUDE	"graphics/gfxbase.i"
		INCLUDE	"graphics/rastport.i"
		INCLUDE	"graphics/text.i"
		INCLUDE	"libraries/gadtools.i"
		INCLUDE	"lvo/exec_lib.i"
		INCLUDE	"lvo/graphics_lib.i"
		INCLUDE	"lvo/intuition_lib.i"
		INCLUDE	"lvo/gadtools_lib.i"




;Private constants
LEFTSPACE	= 5
RIGHTSPACE	= 5
TOPSPACE	= 3
BOTTOMSPACE	= 3
SPACEZERO	= 2
SPACE100	= 2
;offsets of the parameters on the stack
D0OFF	= 0
D1OFF	= 4
D2OFF	= 8
D3OFF	= 12
D4OFF	= 16
A0OFF	= 20
A1OFF	= 24
A2OFF	= 28

		SECTION gauge,CODE
;------------------------------------------------------------------------------
;Public functions
;------------------------------------------------------------------------------
ga_OpenGauge
		bsr.w	InitAllValues
		movem.l	d2-d7/a2-a6,-(sp)	;store regs.
		move.l	d0,-(sp)		;store flags
		andi.l	#GAF_STRUCTURE,d0	;use GaugeParams?
		beq.s	.nostruct
	;extract parameters
		move.l	(gapa_StopText,a0),a1
		move.l	(gapa_Title,a0),a2
		move.l	(gapa_Delay,a0),d2
		move.l	(gapa_WinPos,a0),d4
		move.w	(gapa_100Value,a0),d1
		move.w	(gapa_BarWidth,a0),d3
		move.l	(gapa_ScrWinAdr,a0),a0

.nostruct	move.l	(sp)+,d0
		movem.l	d0-d4/a0-a2,-(sp)	;store parameters
		lea	(EB,pc),a0
		move.l	4.w,(a0)
	;check processor
		move.l	(EB,pc),a6
		btst.b	#AFB_68020,(AttnFlags+1,a6)	;MC_68020?
		beq.s	.lowproc			;no
	;open libraries first
		move.l	(EB,pc),a6
		lea	GfxName,a1
		moveq	#0,d0
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,GraphBase
		beq.w	.nogfx

		lea	IntuiName,a1
		moveq	#36,d0
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,IntuiBase
		beq.w	.nointuition

		move.l	(sp),d0		;flags
		andi.l	#GAF_SLEEPTIME,d0
		beq.s	.nosleep
		move.l	IntuiBase,a0
		move.l	(D2OFF,sp),d0
		add.l	(ib_Seconds,a0),d0
		move.l	d0,SleepTime
.nosleep

		lea	GadtoolsName,a1
		moveq	#36,d0
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,GadtoolsBase
		beq.w	.nogadtools

	;get screen to open on
		move.l	(sp),d0		;flags
		move.l	(A0OFF,sp),a0	;possible window/screen pointer
		andi.l	#GAF_WINDOW,d0
		beq.s	.getscreen
		move.l	(wd_WScreen,a0),ScreenPtr
		move.l	(wd_WScreen,a0),wt_screen+4	;set WA_CustomScreen
		move.l	a0,ParentWin
		bra.s	.gs_ok
.getscreen	move.l	(sp),d0		;flags
		andi.l	#GAF_SCREEN,d0
		beq.s	.getwb
		move.l	a0,ScreenPtr
		move.l	a0,wt_screen+4	;set WA_CustomScreen
		bra.s	.gs_ok
.getwb		move.l	IntuiBase,a6
		sub.l	a0,a0	;WB or default public
		jsr	(_LVOLockPubScreen,a6)
		move.l	d0,ScreenPtr
		move.b	#1,UnlockScreen
		move.l	#TAG_IGNORE,wt_screen	;ignore WA_CustomScreen
.gs_ok

	;get font dimensions
	;len. of '  0%100%'
		move.l	IntuiBase,a6
		move.l	(sp),d0		;get flags
		andi.l	#GAF_SYSTEMFONT,d0	;use system default font?
		bne.s	.sysfont		;yes
		move.l	([ScreenPtr],sc_RastPort+rp_Font),d0
		bra.s	.fontok
.sysfont	move.l	([GraphBase],gb_DefaultFont),d0
.fontok
		move.l	d0,a0			;make TextAttr structure
		lea	FontAttrib,a1
		move.l	(LN_NAME,a0),(ta_Name,a1)
		move.w	(tf_YSize,a0),(ta_YSize,a1)

		lea	IText,a0		;set font to IntuiText
		move.l	#FontAttrib,(it_ITextFont,a0)

		move.l	#gt_zero,(it_IText,a0)
		jsr	(_LVOIntuiTextLength,a6)
		move.w	d0,ZeroLen
		lea	IText,a0
		move.l	#gt_hun,(it_IText,a0)
		jsr	(_LVOIntuiTextLength,a6)
		move.w	d0,HunLen
	;len. of STOP text
		move.l	(sp),d0
		andi.l	#GAF_ENABLESTOP,d0
		seq	NoStop
		beq.s	.nostop
		lea	IText,a0
		move.l	(A1OFF,sp),d0
		beq.s	.deftext
		move.l	d0,(it_IText,a0)
		move.l	d0,StopText
		bra.s	.stextok
.deftext	lea	defStopText,a1
		move.l	a1,(it_IText,a0)
		move.l	a1,StopText
.stextok	move.l	IntuiBase,a6
		lea	IText,a0
		jsr	(_LVOIntuiTextLength,a6)
		move.w	d0,StopLen
.nostop
	;now calculate position and dimensions of the bar and the bevelled box
		move.l	ScreenPtr,a0
		move.b	(sc_WBorTop,a0),d0	;get top offset
		add.b	(sc_BarHeight,a0),d0
		ext.w	d0
		addq.w	#TOPSPACE,d0
		move.w	d0,BevelTop
		addq.w	#1,d0
		move.w	d0,BarTop
		move.b	(sc_WBorLeft,a0),d0
		ext.w	d0
		addq.w	#LEFTSPACE,d0
		move.w	d0,posZero	;position of '  0%'
		add.w	ZeroLen,d0
		addq.w	#SPACEZERO,d0
		move.w	d0,BevelLeft
		addq.w	#2,d0
		move.w	d0,BarLeft
	;widths
		move.l	(sp),d0		;flags
		andi.l	#GAF_WIDTH,d0
		beq.s	.go100
		move.w	d3,BarWidth
.go100
		move.w	BarWidth,d0
		addq.w	#4,d0
		move.w	d0,BevelWidth
	;heights
		move.w	FontAttrib+ta_YSize,d0
		move.w	d0,FontY
		move.w	d0,BarHeight
		addq.w	#2,d0
		move.w	d0,BevelHeight
	;set '100%' text position
		move.w	BevelLeft,d0
		add.w	BevelWidth,d0
		addq.w	#SPACE100,d0
		move.w	d0,pos100
	;set window size
		add.w	HunLen,d0
		addq.w	#RIGHTSPACE,d0
		move.b	([ScreenPtr],sc_WBorRight),d1
		ext.w	d1
		sub.w	d1,d0
		move.w	d0,InnerWidth
		move.w	#TOPSPACE,d0
		add.w	BevelHeight,d0
		addi.w	#BOTTOMSPACE,d0
		tst.b	NoStop
		bne.s	.noplace		;add place for stop gadget?no
		add.w	FontY,d0
		addq.w	#4,d0		;bevel rectangle+additive gadget height
		addi.w	#BOTTOMSPACE,d0
.noplace	move.w	d0,InnerHeight

	;get visual info
		move.l	GadtoolsBase,a6
		move.l	ScreenPtr,a0
		sub.l	a1,a1
		jsr	(_LVOGetVisualInfoA,a6)
		move.l	d0,VisualInfo
		beq.w	.novi

	;Now create the STOP gadget
		tst.b	NoStop
		bne.s	.skipit

		lea	ngStop,a0	;NewGadget structure
		move.w	StopLen,d0
		addq.w	#8,d0
		cmp.w	InnerWidth,d0	;is the gadget larger than window?
		blo.s	.no
		move.w	d0,InnerWidth	;set new window width
.no		move.w	d0,(gng_Width,a0)

		move.w	InnerWidth,d1
		sub.w	d0,d1
		asr.w	#1,d1
		move.b	([ScreenPtr],sc_WBorLeft),d0
		ext.w	d0
		add.w	d1,d0
		move.w	d0,(gng_LeftEdge,a0)

		move.w	FontY,d0
		addq.w	#4,d0		;bevel rectangle+additive gadget height (2+2)
		move.w	d0,(gng_Height,a0)

		move.w	BevelTop,d0
		add.w	BevelHeight,d0
		addi.w	#BOTTOMSPACE,d0
		move.w	d0,(gng_TopEdge,a0)

		move.l	StopText,(gng_GadgetText,a0)
		move.l	#FontAttrib,(gng_TextAttr,a0)
		move.l	#PLACETEXT_IN,(gng_Flags,a0)
		move.l	VisualInfo,(gng_VisualInfo,a0)

		move.l	GadtoolsBase,a6
		lea	Glist,a0
		jsr	(_LVOCreateContext,a6)
		tst.l	d0
		beq.s	.nocontext

		move.l	d0,a0		;previous
		lea	ngStop,a1	;new
		move.l	#BUTTON_KIND,d0	;kind
		sub.l	a2,a2		;tags
		jsr	(_LVOCreateGadgetA,a6)
		tst.l	d0
		beq.s	.nogadget
		move.l	Glist,wt_gadget+4

.skipit

		move.l	(sp),d0		;flags
		andi.l	#GAF_WTITLE,d0	;use another title for the window?
		beq.s	.titleok	;no, use default title
		move.l	(A2OFF,sp),d0
		beq.s	.titleok	;use default
		move.l	d0,wt_title+4
.titleok
		move.l	(sp),d0		;flags
		andi.l	#GAF_100VALUE,d0 ;use another value to represent 100%?
		beq.s	.use100		;no
		move.w	(2+D1OFF,sp),Value100
.use100
		move.w	Value100,d0
		andi.l	#$ffff,d0
		asl.l	#7,d0
		divu.w	BarWidth,d0		;get 1%
		move.w	d0,Value100

		move.l	(sp),d0
		andi.l	#GAF_NOCENTER,d0
		beq.s	.cent
		move.w	(D4OFF,sp),WinX
		move.w	(D4OFF+2,sp),WinY
.cent
		move.l	(sp),d0		;flags
		bsr.w	OpenWindow	;OUT: d0 - success (BOOL)
		tst.l	d0
		beq.s	.nowindow

		lea	(8*4,sp),sp	;movem.l (sp)+,d0-d4/a0-a2 ;restore parameters
		movem.l	(sp)+,d2-d7/a2-a6	;restore regs.
		rts

.nowindow
.nogadget	move.l	GadtoolsBase,a6
		move.l	Glist,a0
		jsr	(_LVOFreeGadgets,a6)
.nocontext	move.l	VisualInfo,a0
		move.l	GadtoolsBase,a6
		jsr	(_LVOFreeVisualInfo,a6)
.novi		move.l	(EB,pc),a6
		move.l	GadtoolsBase,a1
		jsr	(_LVOCloseLibrary,a6)
.nogadtools	move.l	(EB,pc),a6
		move.l	IntuiBase,a1
		jsr	(_LVOCloseLibrary,a6)
.nointuition	move.l	(EB,pc),a6
		move.l	GraphBase,a1
		jsr	(_LVOCloseLibrary,a6)
.nogfx
.lowproc	lea	(8*4,sp),sp	;movem.l (sp)+,d0-d4/a0-a2 ;restore parameters
		movem.l	(sp)+,d2-d7/a2-a6
		st	OpeningFailed
		moveq	#0,d0
		rts

;------------------------------------------------------------------------------
ga_RedrawGauge	;IN: d0 - value to represent (WORD)
		movem.l	d2-d7/a2-a6,-(sp)
		move.w	d0,-(sp)

		tst.b	OpeningFailed
		bne.s	.nodraw

		move.l	SleepTime,d0
		beq.s	.redraw
		move.l	IntuiBase,a0
		move.l	(ib_Seconds,a0),d1
		cmp.l	d1,d0		;reached the time to open?
		bhs.s	.dontdrawyet	;not yet

.ga_ok		clr.l	SleepTime
		bsr.w	GetOpened
		bra.s	.redraw
.dontdrawyet	addq.l	#2,sp
		movem.l	(sp)+,d2-d7/a2-a6
		moveq	#0,d0
		rts

.redraw		move.l	WindowPtr,d0
		beq.s	.nodraw

		tst.b	NoStop	;shell I expect an IDCMP_GADGETUP?
		bne.s	.nomsg	;no

		move.l	d0,a2
		move.l	GadtoolsBase,a6
		move.l	(wd_UserPort,a2),a0
		jsr	(_LVOGT_GetIMsg,a6)
		tst.l	d0
		beq.s	.nomsg

		move.l	d0,a1
		move.l	(im_Class,a1),d2	;get message

		jsr	(_LVOGT_ReplyIMsg,a6)	;message in A1

	;**Handle message in d0
		cmpi.l	#IDCMP_GADGETUP,d2
		beq.s	.stopit

.nomsg
		move.l	WindowPtr,a5
		move.l	(wd_RPort,a5),a5
		move.l	GraphBase,a6
		move.l	a5,a1
		move.l	#3,d0
		jsr	(_LVOSetAPen,a6)
	;get new width of the bar
		move.w	(sp),d2
		andi.l	#$ffff,d2
		asl.l	#7,d2
		divu.w	Value100,d2
		move.w	BarOldX,d3	;old width of the bar
		sub.w	d3,d2
		beq.s	.same
		bmi.s	.same		;for faster performance
		addq.w	#1,d3
		subq.w	#1,d2
		move.w	d3,d4
		add.w	d2,d4
		bpl.s	.okl		;test bounds
		moveq	#0,d4
.okl		cmp.w	BarWidth,d4
		ble.s	.okr
		move.w	BarWidth,d4
.okr
		move.w	d4,BarOldX

		move.w	BarLeft,d2
		move.w	d3,d0
		subq.w	#1,d0
		add.w	d2,d0		;xmin
		move.w	BarTop,d1	;ymin
		add.w	d4,d2
		subq.w	#1,d2		;xmax
		move.w	d1,d3
		add.w	BarHeight,d3
		subq.w	#1,d3		;ymax
		move.l	a5,a1		;rp
		jsr	(_LVORectFill,a6)

.same		addq.l	#2,sp
		movem.l	(sp)+,d2-d7/a2-a6
		moveq	#0,d0
		rts

.nodraw		addq.l	#2,sp
		movem.l	(sp)+,d2-d7/a2-a6
		moveq	#0,d0
		rts

.stopit		addq.l	#2,sp
		movem.l	(sp)+,d2-d7/a2-a6
		move.l	#GA_STOP,d0
		rts
;------------------------------------------------------------------------------
ga_CloseGauge
		movem.l	d2-d7/a2-a6,-(sp)
		tst.b	OpeningFailed
		bne.s	.notopened
	;close window
		move.l	WindowPtr,d0	;may happen that this is zero... (see GAF_SLEEPTIME)
		beq.s	.nowin
		move.l	d0,a0
		move.l	IntuiBase,a6
		jsr	(_LVOCloseWindow,a6)
.nowin
		move.l	GadtoolsBase,a6
		move.l	Glist,a0
		jsr	(_LVOFreeGadgets,a6)

		move.l	VisualInfo,a0
		jsr	(_LVOFreeVisualInfo,a6)

		tst.b	UnlockScreen
		beq.s	.nounlock
		move.l	IntuiBase,a6
		sub.l	a0,a0	;name
		move.l	ScreenPtr,a1
		jsr	(_LVOUnlockPubScreen,a6)
.nounlock
	;close libraries
		move.l	(EB,pc),a6

		move.l	GadtoolsBase,a1
		jsr	(_LVOCloseLibrary,a6)

		move.l	GraphBase,a1
		jsr	(_LVOCloseLibrary,a6)

		move.l	IntuiBase,a1
		jsr	(_LVOCloseLibrary,a6)

.notopened
		st	OpeningFailed
		movem.l	(sp)+,d2-d7/a2-a6
		moveq	#0,d0
		rts

;------------------------------------------------------------------------------
;Private functions
;------------------------------------------------------------------------------
OpenWindow	;IN: d0 - flags
		;OUT:d0 - success (BOOL)
	;center the window

		move.l	ScreenPtr,a5

		move.l	d0,-(sp)
		andi.l	#GAF_NOCENTER,d0
		bne.s	.nocenter

		move.l	ParentWin,d0	;center on screen or within the window?
		beq.s	.onscreen
		move.l	d0,a0		;within the window

		move.w	(wd_Width,a0),d0
		asr.w	#1,d0
		add.w	(wd_LeftEdge,a0),d0
		move.w	d0,CenterPointX

		move.w	(wd_Height,a0),d0
		asr.w	#1,d0
		add.w	(wd_TopEdge,a0),d0
		move.w	d0,CenterPointY
		bra.s	.center

.onscreen
	;get center of the visible part of screen
	;get screen and window sizes
		move.l	(sc_ViewPort+vp_ColorMap,a5),a4
		move.l	(cm_vpe,a4),a4	;ViewPortExtra
	;Winx=(ScrWidth-WinWidth)/2
		move.w	(vpe_DisplayClip+ra_MaxX,a4),d1
		sub.w	(vpe_DisplayClip+ra_MinX,a4),d1
		move.w	(sc_Width,a5),d0
		cmp.w	d0,d1		;if screen width < display clip
		bls.s	.dc1
		move.w	d0,d1
.dc1		asr.w	#1,d1	;/2
		sub.w	(sc_ViewPort+vp_DxOffset,a5),d1	;offset
		move.w	d1,CenterPointX

	;WinY=(ScrHeight-WinHeight)/2
		move.w	(vpe_DisplayClip+ra_MaxY,a4),d1
		sub.w	(vpe_DisplayClip+ra_MinY,a4),d1
		move.w	(sc_Height,a5),d0
		cmp.w	d0,d1
		bls.s	.dc2
		move.w	d0,d1
.dc2		asr.w	#1,d1	;/2
		sub.w	(sc_ViewPort+vp_DyOffset,a5),d1
		move.w	d1,CenterPointY

.center		move.b	(sc_WBorLeft,a5),d1
		add.b	(sc_WBorRight,a5),d1
		ext.w	d1
		add.w	InnerWidth,d1
		asr.w	#1,d1		;/2
		sub.w	CenterPointX,d1
		neg.w	d1
		move.w	d1,WinX

		move.b	(sc_WBorTop,a5),d1
		add.b	(sc_WBorBottom,a5),d1
		add.b	(sc_BarHeight,a5),d1
		ext.w	d1
		add.w	InnerHeight,d1
		asr.w	#1,d1
		sub.w	CenterPointY,d1
		neg.w	d1
		move.w	d1,WinY
		bra.s	.nooffset

.nocenter	move.l	ParentWin,d0
		beq.s	.nooffset
		move.l	d0,a0
		move.w	(wd_LeftEdge,a0),d0
		add.w	d0,WinX
		move.w	(wd_TopEdge,a0),d0
		add.w	d0,WinY
.nooffset
	;set values to taglist
		move.w	WinX,wt_left+6
		move.w	WinY,wt_top+6
		move.w	InnerWidth,wt_width+6
		move.w	InnerHeight,wt_height+6

		tst.l	SleepTime
		bne.s	.dontopenyet
		bsr.w	GetOpened
		tst.l	d0
		beq.s	.nowindow
.dontopenyet
		addq.l	#4,sp
		moveq	#1,d0
		rts

.nowindow	addq.l	#4,sp
		moveq	#0,d0
		rts

;--------------------------------------------------------------------------
GetOpened	;IN: structures initialized by OpenWindow
		;OUT: d0 - success (BOOL)
		move.l	IntuiBase,a6
		sub.l	a0,a0
		lea	WindowTags,a1
		jsr	(_LVOOpenWindowTagList,a6)
		move.l	d0,WindowPtr
		beq.s	.nowindow

		move.l	IntuiBase,a6
		lea	IText,a1
		move.b	#1,(it_FrontPen,a1)
	;draw '  0%'
		move.l	#gt_zero,(it_IText,a1)
		move.w	posZero,d0
		ext.l	d0
		move.w	BarTop,d1
		ext.l	d1
		move.l	([WindowPtr],wd_RPort),a0
		jsr	(_LVOPrintIText,a6)

	;draw '100%'
		lea	IText,a1
		move.l	#gt_hun,(it_IText,a1)
		move.w	pos100,d0
		ext.l	d0
		move.w	BarTop,d1
		ext.l	d1
		move.l	([WindowPtr],wd_RPort),a0
		jsr	(_LVOPrintIText,a6)

		move.l	GadtoolsBase,a6
		move.l	([WindowPtr],wd_RPort),a0
		lea	BevelTags,a1
		move.w	BevelLeft,d0
		move.w	BevelTop,d1
		move.w	BevelWidth,d2
		move.w	BevelHeight,d3
		jsr	(_LVODrawBevelBoxA,a6)

		moveq	#1,d0
		rts
.nowindow	moveq	#0,d0
		rts
;--------------------------------------------------------------------------
InitAllValues	movem.l	d0-d7/a0-a6,-(sp)

		lea	ZeroesStart,a0
		lea	ZeroesEnd,a1
.loop		clr.b	(a0)+
		cmp.l	a0,a1
		bne.s	.loop

		clr.l	VisualInfo
		move.l	#DefaultTitle,wt_title+4
		move.l	#WA_CustomScreen,wt_screen
		clr.l	wt_screen+4
		clr.l	wt_gadget+4
		move.w	#100,Value100
		move.w	#128,BarWidth

		movem.l	(sp)+,d0-d7/a0-a6
		rts
;--------------------------------------------------------------------------
EB		dc.l	0	;ExecBase

		SECTION gaugedata,DATA
GfxName		dc.b	'graphics.library',0
IntuiName	dc.b	'intuition.library',0
GadtoolsName	dc.b	'gadtools.library',0
DefaultTitle	dc.b	'Processing...',0

gt_zero		dc.b	'0%',0
gt_hun		dc.b	'100%',0
defStopText	dc.b	'Stop',0

;section to be initialized by special values
		cnop	0,4
BevelTags	dc.l	GT_VisualInfo
VisualInfo	dc.l	0			;initialize to 0
		dc.l	GTBB_Recessed,1
		dc.l	TAG_DONE,0

WindowTags
wt_left		dc.l	WA_Left,0
wt_top		dc.l	WA_Top,0
wt_width	dc.l	WA_InnerWidth,0
wt_height	dc.l	WA_InnerHeight,0

wt_title	dc.l	WA_Title,0	;set to default title
wt_screen	dc.l	WA_CustomScreen,0
wt_gadget	dc.l	WA_Gadgets,0
		dc.l	WA_IDCMP,IDCMP_GADGETUP
		dc.l	WA_DragBar,1
		dc.l	WA_DepthGadget,1
		dc.l	WA_RMBTrap,1
		dc.l	WA_SmartRefresh,1
		dc.l	WA_AutoAdjust,1
		dc.l	TAG_DONE,0

		SECTION bssdata,BSS
ZeroesStart	;start of section to be zero
GraphBase	ds.l	1
IntuiBase	ds.l	1
GadtoolsBase	ds.l	1
SleepTime	ds.l	1
ZeroLen		ds.w	1	;len of gt_zero text
HunLen		ds.w	1	;
StopLen		ds.w	1	;

BarLeft		ds.w	1
BarTop		ds.w	1
BarHeight	ds.w	1
BarOldX		ds.w	1
BevelLeft	ds.w	1
BevelTop	ds.w	1
BevelWidth	ds.w	1
BevelHeight	ds.w	1
posZero		ds.w	1	;position of '  0%'
pos100		ds.w	1	;            '100%'
FontY		ds.w	1	;ysize of used font
CenterPointX	ds.w	1
CenterPointY	ds.w	1

InnerWidth	ds.w	1	;dimensions of the window
InnerHeight	ds.w	1	;
WinX		ds.w	1
WinY		ds.w	1

WindowPtr	ds.l	1	;pointer to the gauge-window
ScreenPtr	ds.l	1	;screen to open on
ParentWin	ds.l	1	;ptr. to a parent window
StopText	ds.l	1	;ptr. to a text used in STOP button
IText		ds.b	it_SIZEOF	;IntuiText structure
FontAttrib	ds.b	ta_SIZEOF	;TextAttr struct.

Glist		ds.l	1
ngStop		ds.b	gng_SIZEOF	;NewGadget structure
GadText		ds.b	it_SIZEOF

;some flags
UnlockScreen	ds.b	1	;if set then unlock the screen after closing window
NoStop		ds.b	1	;if set, no stop button is used
OpeningFailed	ds.b	1
ZeroesEnd	;end of section to be cleared while initializing

		even
Value100	ds.w	1	;the nominal value is 100
BarWidth	ds.w	1	;the nominal value is 128
