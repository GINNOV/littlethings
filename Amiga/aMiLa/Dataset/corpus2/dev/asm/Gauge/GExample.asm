

;$VER: Usage of Gauge by Andry of PEGAS 0.1 (16.11.97)

;This example shows how to use the Gauge-code.
;GAF_SCREEN and GAF_SYSTEMFONT are not demonstrated but their usage
;is very similar.

;Enjoy.
;           Andry



		MACHINE	68020

		INCDIR	"INCLUDE:"
		INCLUDE "ram:Gauge.i"
		INCLUDE	"lvo/exec_lib.i"
		INCLUDE	"lvo/dos_lib.i"
		INCLUDE	"lvo/intuition_lib.i"
		INCLUDE	"lvo/reqtools_lib.i"
		INCLUDE	"intuition/intuition.i"
		INCLUDE	"libraries/reqtools.i"

		XREF	ga_OpenGauge,ga_RedrawGauge,ga_CloseGauge

IMAGEWIDTH	= 250
IMAGEHEIGHT	= 100

SHOWTEXT	MACRO
		lea	text_\1,a0
		bsr.w	ShowText
		ENDM

		SECTION	example,CODE

		jmp	_IconStart

_main		lea	(EB,pc),a0
		move.l	4.w,(a0)

	;OpenLibraries
		lea	IntuiName,a1
		moveq	#36,d0
		move.l	(EB,pc),a6
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,IntuiBase
		beq.w	NoIntuition

		lea	DosName,a1
		moveq	#0,d0
		move.l	(EB,pc),a6
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,DosBase
		beq.w	NoDos

		lea	ReqtoolsName,a1
		moveq	#0,d0
		move.l	(EB,pc),a6
		jsr	(_LVOOpenLibrary,a6)
		move.l	d0,ReqtoolsBase
		beq.w	NoReqtools

	;open some window
		move.l	IntuiBase,a6
		sub.l	a0,a0	;NewWindow
		lea	WinTags,a1
		jsr	(_LVOOpenWindowTagList,a6)
		move.l	d0,WindowPtr
		beq.w	NoWindow
	;now show the advertisment
		move.l	WindowPtr,a0
		moveq	#0,d0
		move.l	d0,d1
		move.b	(wd_BorderLeft,a0),d0
		move.b	(wd_BorderTop,a0),d1
		move.l	(wd_RPort,a0),a0
		lea	AdvertImage,a1
		move.l	IntuiBase,a6
		jsr	(_LVODrawImage,a6)

		SHOWTEXT start
	;init the GaugeParams structure
		lea	Params,a5
		move.w	#200,(gapa_WinPos,a5)	;x (MSW)
		move.w	#30,(gapa_WinPos+2,a5)	;y (LSW)
		move.l	WindowPtr,(gapa_ScrWinAdr,a5)
		move.l	#3,(gapa_Delay,a5)
		move.l	#AnotherTitle,(gapa_Title,a5)
		move.w	#300,(gapa_BarWidth,a5)
;centered in screen (stop)
		SHOWTEXT centerinscreen
		move.l	#GAF_ENABLESTOP!GAF_STRUCTURE,d0
		move.l	a5,a0		;structure GaugeParams
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge		;also closes the gauge
;centered in window
		SHOWTEXT centerinwindow
		move.l	#GAF_ENABLESTOP!GAF_WINDOW!GAF_STRUCTURE,d0
		move.l	a5,a0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;not centered (but relative to screen's left/top edge)
		SHOWTEXT absscreen
		move.l	#GAF_ENABLESTOP!GAF_NOCENTER!GAF_STRUCTURE,d0
		move.l	a5,a0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;not centered (but relative to window's left/top edgr)
		SHOWTEXT abswindow
		move.l	#GAF_ENABLESTOP!GAF_NOCENTER!GAF_WINDOW!GAF_STRUCTURE,d0
		move.l	a5,a0
		move.w	#60,(gapa_WinPos,a0)	;x (MSW)
		move.w	#60,(gapa_WinPos+2,a0)	;y (LSW)
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;sleeptime
		SHOWTEXT sleeptime
		move.l	#GAF_ENABLESTOP!GAF_WINDOW!GAF_SLEEPTIME!GAF_STRUCTURE,d0
		move.l	a5,a0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;just a basic gauge (all parameters are ignored)
		SHOWTEXT basic
		moveq	#0,d0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge	;faster that the others (no stop button)
;other label
		SHOWTEXT wintitle
		move.l	#GAF_ENABLESTOP!GAF_WTITLE!GAF_STRUCTURE,d0
		move.l	a5,a0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;other stoptext
		SHOWTEXT stoptext
		move.l	#GAF_ENABLESTOP!GAF_WTITLE!GAF_STRUCTURE,d0
		move.l	a5,a0
		move.l	#AnotherStop,(gapa_StopText,a0)	;set new text for stop gadget
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge
;bar width
		cmpi.l	#GA_STOP,d0
		bne.s	.norm
		SHOWTEXT patience
.norm		SHOWTEXT barwidth
		clr.l	(gapa_StopText,a5)	;turn the gadget back to default text
		move.l	#GAF_ENABLESTOP!GAF_WIDTH!GAF_STRUCTURE,d0
		move.l	a5,a0
		jsr	ga_OpenGauge
		bsr.w	ProcessGauge


		SHOWTEXT end

		move.l	IntuiBase,a6
		move.l	WindowPtr,a0
		jsr	(_LVOCloseWindow,a6)

NoWindow	move.l	(EB,pc),a6
		move.l	ReqtoolsBase,a1
		jsr	(_LVOCloseLibrary,a6)

NoReqtools	move.l	(EB,pc),a6
		move.l	DosBase,a1
		jsr	(_LVOCloseLibrary,a6)

NoDos		move.l	(EB,pc),a6
		move.l	IntuiBase,a1
		jsr	(_LVOCloseLibrary,a6)
NoIntuition
		rts


;--------------------------------------------------------------------
ProcessGauge	move.l	DosBase,a6
		moveq	#0,d2

.loop		addq.w	#1,d2
		cmpi.w	#101,d2
		beq.s	.ok
		move.l	d2,d0
		jsr	ga_RedrawGauge
		cmpi.l	#GA_STOP,d0
		beq.s	.stopped

		moveq	#2,d1
		jsr	(_LVODelay,a6)
		bra.s	.loop

.ok		jsr	ga_CloseGauge
		moveq	#0,d0		;ok
		rts
.stopped	jsr	ga_CloseGauge
		move.l	#GA_STOP,d0	;stopped
		rts
;-----------------------------------------------------------------------
ShowText	;opens an reqtools requester with informations about
		;the next gauge
		;IN: a0-ptr to the text

		move.l	ReqtoolsBase,a6
		move.l	a0,a1
		lea	reqtButton,a2
		sub.l	a3,a3
		sub.l	a4,a4
		lea	reqtTags,a0
		jsr	(_LVOrtEZRequestA,a6)
		rts

_IconStart	movem.l	d0/a0,-(sp)	;command line
		sub.l	a1,a1		;find myself
		move.l	4.w,a6
		jsr	(_LVOFindTask,a6)
		movea.l	d0,a2
		tst.l	($ac,a2)	;from WB?    (pr_CLI = $AC)
		bne.s	.From_CLI	;no
	;from WorkBench
		lea	($5c,a2),a2	;pr_MsgPort
		move.l	a2,a0
		jsr	(_LVOWaitPort,a6)
		move.l	a2,a0
		jsr	(_LVOGetMsg,a6)
		lea	(WBmessage,PC),a0
		move.l	d0,(a0)
		movem.l	(sp)+,d0/a0
		bra.s	.CoWB_run
.From_CLI	movem.l	(sp)+,d0/a0	;d0 = length of command line including LF
					;a0 - ptr. to 1. char of command line (Ucase<>Lcase)

.CoWB_run	jsr	_main

		move.l	d0,-(sp)	;returncode
	;return to CLI or WB ?
		tst.l	(WBmessage,pc)	;68020+ instruction
		beq.s	.To_CLI
		move.l	4.w,a6
		jsr	(_LVOForbid,a6)
		move.l	(WBmessage,pc),a1
		jsr	(_LVOReplyMsg,a6)
.To_CLI		move.l	(sp)+,d0	;returncode
		rts

WBmessage	dc.l	0
EB	dc.l	0	;ExecBase

		SECTION exampleData,DATA
IntuiBase	dc.l	0
DosBase		dc.l	0
ReqtoolsBase	dc.l	0
IntuiName	dc.b	'intuition.library',0
DosName		dc.b	'dos.library',0
ReqtoolsName	dc.b	'reqtools.library',0

AnotherTitle	dc.b	'Andry is the best!',0
AnotherStop	dc.b	'Stop this shit!!!',0
WinTitle	dc.b	'Gauge presentation',0

		cnop	0,4
reqtTags	dc.l	RTEZ_Flags,EZREQF_CENTERTEXT
		dc.l	TAG_DONE,0

WindowPtr	dc.l	0
WinTags		dc.l	WA_Left,50
		dc.l	WA_Top,50
		dc.l	WA_InnerWidth,IMAGEWIDTH
		dc.l	WA_InnerHeight,IMAGEHEIGHT
		dc.l	WA_Activate,1
		dc.l	WA_SmartRefresh,1
		dc.l	WA_CloseGadget,1
		dc.l	WA_DepthGadget,1
		dc.l	WA_DragBar,1
		dc.l	WA_Title,WinTitle
		dc.l	WA_BusyPointer,1
		dc.l	WA_PointerDelay,1
		dc.l	TAG_DONE,0

AdvertImage	dc.w	0,0	;left,top
		dc.w	IMAGEWIDTH,IMAGEHEIGHT,3	;w,h,depth
		dc.l	AdvertRaw	;ImageData
		dc.b	%111,0		;PlanePick,PlaneOnOff
		dc.l	0		;NextImage

Params		dcb.b	gapa_SIZEOF,0

reqtButton	dc.b	'Continue',0

text_start		dc.b	'This is a presentation of some features which are',10
			dc.b	'implemented in the Gauge-code by Andry of PEGAS.',10
			dc.b	'Watch it...',0
text_centerinscreen	dc.b	'The first gauge will be just centered',10
			dc.b	'within the VISIBLE bounds of screen.',10
			dc.b	'It will also become a STOP gadget.',0
text_centerinwindow	dc.b	'The next gauge will be centered within bounds',10
			dc.b	'of the opened window.',0
text_absscreen		dc.b	'You can also specify absolute position of the',10
			dc.b	'gauge window. The next will appear at position',10
			dc.b	'Left = 200  and  Top = 30  relative to Left/Top',10
			dc.b	'corner of the SCREEN.',0
text_abswindow		dc.b	'Let',39,'s open at position (60,60) relative to',10
			dc.b	'Left/Top corner of the WINDOW.',0
text_basic		dc.b	'Here comes a gauge which is the simplest you can use.',10
			dc.b	'No STOP gadget, also other features are not used.',10
			dc.b	'This type of gauge you can create with TWO instructions',10
			dc.b	'in your code.',0
text_wintitle		dc.b	'If you want, you can set another title to the gauge window.',10
			dc.b	'Let',39,'s see ...',0
text_stoptext		dc.b	'Of course you are able to set another text',10
			dc.b	'for the STOP gadget.',0
text_patience		dc.b	'Unfortunally, you have to watch it until the end.',10
			dc.b	'But don',39,'t worry, we are almost there.',0
text_barwidth		dc.b	'Another width of the gauge bar may be specified.',0
text_sleeptime		dc.b	'If you don',39,'t want the gauge appear if the operation',10
			dc.b	'takes only few time (e.g. on a 68060 would it just',10
			dc.b	'disturb  :-), you can specify a time period for which',10
			dc.b	'the gauge stays hidden.',10
			dc.b	'The next will appear after about 3 seconds.',0
text_end		dc.b	'So there were some examples. There are more features',10
			dc.b	'and new will come if I see some reactions.',10
			dc.b	'Whatever, it was made for YOU - CODER!',10,10
			dc.b	'So send me suggestions, bug reports or whatever you want',10
			dc.b	'(except bombs, acids ... well if you had some ACID...).',10,10
			dc.b	'CONTACT: Andreas Bednarek, Tyrsova 4, 751 24, PREROV, CZECH REP.',10
			dc.b	' e-mail: kozubv@vtx.cz   (available until March 1998)',0

		SECTION image,DATA_C
AdvertRaw	INCBIN	"ram:Advert.raw"
