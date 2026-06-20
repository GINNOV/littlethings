;-------------------------------------------------------------------------------
*                                                                              *
* ProgressBar Demo program 'pbtest'                                            *
*                                                                              *
* Written 1995 by Daniel Weber                                                 *
*                                                                              *
*                                                                              *
* Last Revision   16.04.95                                                     *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:pbtest'

	opt	o+,q+,ow-,qw-,sw-
	verbose
	base	progbase

	filenote	'pbtest, ProgressBar.r Demo program'

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	include	'intuition/intuition.i'
	include	'dos/dos.i'
	include	libraries/gadtools.i


	incequ	'LVO.s'
	include	'basicmac.r'


;-------------------------------------------------------------------------------

version		equr	"0.10"
gea_progname	equr	"pbtest"

;-- startup control  --
cws_V36PLUSONLY	set	1			;only OS2.x or higher
;cws_DETACH	set	1			;detach from CLI
cws_CLIONLY	set	1			;for CLI usage only
cws_EASYLIB	set	1
;cws_PRI	equ	0			;set process priority to 0
;cws_FPU	set	1
;cws_STACKSIZE	equ	4096

;-- user definitions --
AbsExecBase	equ	4

INTUITION.LIB	equ	1
GRAPHICS.LIB	equ	1
DOS.LIB		equ	1
GADTOOLS.LIB	equ	1


maximum		equ	60			; max. value for ProgressBar
step		equ	5			; step width

;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even
;----------------------------
start:
clistartup:
wbstartup:
	lea	progbase(pc),a5
	bsr	OpenProgressWindow
	tst.l	ProgressWnd(a5)
	beq	.out

	lea	pbar(pc),a0
	move.l	ProgressWnd(a5),a1
	move.b	wd_BorderLeft(a1),d0
	ext.w	d0
	move.b	wd_BorderTop(a1),d1
	ext.w	d1
	add.w	d0,pgb_x(a0)
	add.w	d1,pgb_y(a0)
	CALL_	InitProgressBar
	beq	.err

	move.l	#maximum,pgb_max(a0)		; set to 60 seconds


	;
	; play around a bit
	;
	moveq	#10-1,d6
.loop	move.l	DosBase(pc),a6
	moveq	#4,d1
	jsr	_LVODelay(a6)
	lea	pbar(pc),a0
	move.l	#maximum,pgb_value(a0)
	CALL_	SetProgressBar
	moveq	#4,d1
	jsr	_LVODelay(a6)
	lea	pbar(pc),a0
	clr.l	pgb_value(a0)
	CALL_	ClearProgressBar
	dbra	d6,.loop

	;
	; fill & empty bar
	;
	moveq	#step,d7		; step value
	clr.l	pgb_value+pbar(a5)
	moveq	#1,d6
.loop2	moveq	#maximum/step,d5
.loop3	lea	pbar(pc),a0
	add.l	d7,pgb_value(a0)
	CALL_	UpdateProgressBar
	move.l	DosBase(pc),a6
	moveq	#1,d1			; 1/25 sec
	jsr	_LVODelay(a6)
	dbra	d5,.loop3
	lea	pbar(pc),a0
	clr.w	pgb_last(a0)
	clr.l	pgb_value(a0)
	CALL_	UpdateProgressBar
	dbra	d6,.loop2


	;
	; count seconds...
	;
	moveq	#step,d7			; step value
.wait:	move.l	DosBase(pc),a6
	moveq	#50,d1			; wait a second
	jsr	_LVODelay(a6)
	move.l	#SIGBREAKF_CTRL_C,d6	;CTRL-C pressed ?
	moveq	#0,d0
	move.l	d6,d1
	move.l	4.w,a6
	jsr	_LVOSetSignal(a6)	;set signal
	and.l	d6,d0			;-: break  0:no break
	bne.s	.err

	lea	pbar(pc),a0
	add.l	d7,pgb_value(a0)
	beq.s	0$
	cmp.l	#60,pgb_value(a0)
	blt.s	1$
0$:	neg.l	d7
1$:	CALL_	UpdateProgressBar
	bra	.wait


.err:	bsr	CloseProgressWindow
.out:	moveq	#0,d0
	bra	ReplyWBMsg



;-------------------------------------------------------------------------------
*
* various subroutines
*
;-------------------------------------------------------------------------------
			foreset
gsd_screenbuffer:	fo.b	52	;space for GetScreenData()
gsd_length:		foval		;length of structure

boxleft			EQU	4
boxtop			EQU	3
boxwidth		EQU	160
boxheight		EQU	10
boxborderleft		equ	2	; border sizes for
boxbordertop		equ	1	; adjusting...
defwinx			equ	16	; default window positions
defwiny			equ	16	;
defwinxy		equ	16	; default pos x=y=16


OpenProgressWindow:
	movem.l	d1-d4/a0-a4/a6,-(sp)
	lea	progbase(pc),a5
	clr.l	ProgressWnd(a5)
	move.l	IntBase(pc),a6
	sub.l	a0,a0
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,PubScreenLock(a5)

	link	a3,#gsd_length		;get correct title y size
	lea	gsd_screenbuffer(a3),a0
	moveq	#48,d0
	moveq	#1,d1
	sub.l	a1,a1
	jsr	-426(a6)		;getscreendata()
	lea	gsd_screenbuffer(a3),a0
	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3
	move.b	sc_WBorLeft(a0),d2
	move.b	sc_WBorTop(a0),d0
	move.l	sc_Font(a0),a0		;ptr on TextAttr
	move.w	ta_YSize(a0),d3		;y font size
	unlk	a3
	subq.w	#8,d3
	ext.l	d3
	add.l	d3,ProgressH+4(a5)
	move.l	d3,ydiff(a5)
	move.l	IntBase(pc),a6
	suba.l	a0,a0
	lea.l	ProgressWindowTags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,ProgressWnd(a5)
	bne.s	.ok

	moveq	#defwinxy,d0
	move.l	d0,ProgressL+4(a5)
	move.l	d0,ProgressT+4(a5)
	suba.l	a0,a0
	lea.l	ProgressWindowTags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,ProgressWnd(a5)
	beq.s	.error

.ok	move.l	GadToolsBase(pc),a6
	move.l	ProgressWnd(pc),a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)

	move.l	PubScreenLock(pc),a0
	lea	TD(pc),a1
	jsr	_LVOGetVisualInfoA(a6)
	move.l	d0,VisualInfo(a5)

	bsr	ProgressRender

.done:	move.l	PubScreenLock(pc),d0
	beq.s	9$
	move.l	d0,a1
	sub.l	a0,a0
	move.l	IntBase(pc),a6
	jsr	_LVOUnlockPubScreen(a6)
9$:	movem.l	(sp)+,d1-d4/a0-a4/a6
	rts
.error:	moveq	#4,d0
	bra.s	.done



CloseProgressWindow:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	lea	progbase(pc),a5
	move.l	IntBase(pc),a6
	move.l	ProgressWnd(pc),d0
	beq.s	1$
	move.l	d0,a0
	jsr	_LVOCloseWindow(a6)
	clr.l	ProgressWnd(a5)
1$:	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts


;---------------------------------------
ProgressRender:
	movem.l	d0-d5/a0-a2/a6,-(sp)
	move.l	ProgressWnd(pc),d0
	beq	.done
	move.l	d0,a0

	move.l	VisualInfo(pc),d0
	move.l	d0,NR+4(a5)
	move.l	d0,IR+4(a5)

	move.b	wd_BorderLeft(a0),d0
	ext.w	d0
	move.b	wd_BorderTop(a0),d1
	ext.w	d1
	addq.w	#boxleft,d0		; left
	addq.w	#boxtop,d1		; top
	move.w	#boxwidth,d2		; width
	moveq	#boxheight,d3		; height
	move.l	ProgressWnd(pc),a0
	move.l	wd_RPort(a0),a0
	lea	IR(pc),a1
	move.l	GadToolsBase(pc),a6
	jsr	_LVODrawBevelBoxA(a6)
.done:	movem.l	(sp)+,d0-d5/a0-a2/a6
	rts


;-------------------------------------------------
NR:	DC.L	GT_VisualInfo,$00000000,TAG_DONE
IR:	DC.L	GT_VisualInfo,$00000000,GTBB_Recessed,1
TD:	DC.L	TAG_DONE

ProgressWindowTags:
ProgressL:
	DC.L	WA_Left,defwinx
ProgressT:
	DC.L	WA_Top,defwiny
ProgressW:
	DC.L	WA_Width,176
ProgressH:
	DC.L	WA_Height,19+10
	DC.L	WA_IDCMP,IDCMP_CLOSEWINDOW!IDCMP_REFRESHWINDOW
	DC.L	WA_Flags,WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_SMART_REFRESH
	DC.L	WA_Title,ProgressWTitle
	DC.L	TAG_DONE

ProgressWTitle:
	dc.b	'PBTest (CTRL-C to quit)...',0
	EVEN



VisualInfo:	dc.l	0
PubScreenLock:	dc.l	0
ProgressWnd:	dc.l	0
ydiff:		dc.l	0



;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r
	include	progressbars.r


;-------------------------------------------------------------------------------
*
* data area
*
;-------------------------------------------------------------------------------


bar1_x		EQU	boxleft+boxborderleft
bar1_y		EQU	boxtop+boxbordertop
bar1_width	EQU	boxwidth-2*boxborderleft
bar1_height	EQU	boxheight-2*boxbordertop

pbar:	ProgressStruct_	bar1,maximum

	end
