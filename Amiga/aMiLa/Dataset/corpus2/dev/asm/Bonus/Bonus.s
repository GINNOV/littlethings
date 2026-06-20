
; System advert coded by Zeeball/Apathy!

; Finished at 15.12.1999

; I hope everybody will be able to understand this source.
; If not then try to ask at:
; error@alpha.net.pl with subject:`To Zeeball`

; Uses ptreplay.library! Module not included!
;----------------------------------------------

	section	Starter,code
	
Starter:
	move.l	4.w,Execbase
	move.l	ExecBase,a6

	cmp.w	#36,$14(a6)
	bmi.b	TooBad

	sub.l	a1,a1		; zero
	jsr	-$126(a6)	; FindTask
	move.l	d0,a5
	move.l	$98(a5),Lock	; pr_CurrentDir
	
	tst.l	$ac(a5)		; Test, czy z WB...
	bne.b	Z_CLI		; Nie, to skok...
Z_WB:
	lea.l	$5c(a5),a0	; MsgPort
	jsr	-$180(a6)	; WaitPort
	lea.l	$5c(a5),a0	; MsgPort
	jsr	-$174(a6)	; GetMsg
	
	movem.l	d0/a6,-(sp)	; na stos!
 	
	bsr.b	Z_CLI

	movem.l	(sp)+,a1/a6	; ze stosu...
	
	jsr	-$84(a6)	; Forbid
 	
	jsr	-$17a(a6)	; ReplyMsg
TooBad:	moveq	#0,d0		; OK!
	rts			; wypad...
	
Z_CLI:

	lea.l	Dosname,a1	; nazwa
	moveq	#0,d0		; wersja
	jsr	-$228(a6)	; OpenLibrary
	move.l	d0,a6		; baza dosu
	move.l	a6,DosBase

	move.l	Lock,d1
	jsr	-$60(a6)	; DupLock
	move.l	d0,Lock
	
	lea	Starter-4(pc),a1
	move.l	(a1),d3
	clr.l	(a1)
	move.l	d3,SegList
	
	move.l	#Nazwa,d1	; nazwa
	moveq	#127,d2		; priorytet
	move.l	#4096,d4	; stos
	
	jsr	-$8a(a6)	; CreateProc
	
	moveq	#0,d0
	rts

	section	Main,code

	move.l	4.w,a6
	lea.l	Pt(pc),a1
	jsr	-408(a6)
	tst.l	d0
	beq	.x
	move.l	d0,a6
	lea.l	Module,a0
	jsr	-$72(a6)
	move.l	d0,a0
	move.l	a0,-(sp)
	jsr	-$2a(a6)
	move.l	a6,-(sp)

.x
	bsr.b	Program


	move.l	(sp)+,a6
	move.l	(sp)+,a0
	tst.l	a6
	beq	.y
	jsr	-$30(a6)
	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)
.y:
	move.l	Execbase(pc),a6
	jsr	-$84(a6)	; Forbid
	move.l	DosBase(pc),a6
	move.l	Lock(pc),d1
	jsr	-$5a(a6)	; UnLock

	move.l	SegList(pc),d1
	jsr	-$9c(a6)	; UnLoadSeg

	move.l	a6,a1
	move.l	Execbase(pc),a6
	jsr	-$19e(a6)	; CloseLibrary

	moveq	#0,d0
	rts

	
Program:


xsiz	=	620
ysiz	=	200


	lea.l	ExecBase(pc),a4
	move.l	4.w,(a4)
	move.l	(a4)+,a6
	
	lea.l	IntuiName(pc),a1	; nazwa
	moveq	#0,d0		; wersja
	jsr	-552(a6)	; OpenLibrary
	move.l	d0,(a4)+	; baza dosu

	lea.l	GraphName(pc),a1; nazwa
	moveq	#0,d0		; wersja
	jsr	-552(a6)	; OpenLibrary
	move.l	d0,(a4)+	; baza dosu


	move.l	IntuiBase(pc),a6	; intuitionbase...
	lea.l	Screen(pc),a2

	sub.l	a0,a0
	jsr	-$1fe(a6)	;LockPubScreen

	move.l	d0,a0
	move.l	d0,(a2)
	jsr	-252(a6)	;ScreentoFront

	move.l	Screen(pc),a0
	move.w	$c(a0),d0
	sub.w	#xsiz,d0
	asr.w	d0
	lea.l	NewWindow(pc),a0
	move.w	d0,(a0)	
	move.l	IntuiBase(pc),a6	; baza intuitionu
	jsr	-204(a6)		; OpenWindow
	move.l	d0,WindowBase

	move.l	GraphBase(pc),a6
	move.l	d0,a1
	move.l	50(a1),a1
	lea.l	rp(pc),a0
	move.l	a1,(a0)
	
	moveq	#1,d0
	jsr	-342(a6)		;SetAPen

	lea	FontDef(PC),a0
	lea	TopazName(PC),a1
	jsr	-$48(a6)	;OpenFont
	
	move.l	rp(pc),a1
	move.l	d0,a0
	lea.l	FontBase(pc),a2
	move.l	d0,(a2)
	jsr	-66(a6)		;SetFont



	lea.l	WindowName(pc),a2
	lea.l	-1,a1
	move.l	WindowBase(pc),a0
	
	move.l	IntuiBase(pc),a6
	jsr	-276(a6)		;SetWindowTitles


	jsr	MakeSlave


LUPP:
	move.l	WindowBase(pc),a0
	move.l	86(a0),a0
	move.l	4.w,a6
	jsr	-384(a6)		; wait for your move

	move.l	WindowBase(pc),a0
	move.l	86(a0),a0
	jsr	-372(a6)
	tst.l	d0
	beq.b	LUPP

	move.l	d0,a1
	move.l	20(a1),d2
	move.l	28(a1),a2
	
	jsr	-378(a6)

	clr.l	rp


.loop:
	move.l	DosBase(pc),a6
	moveq	#50,d1
	jsr	-198(a6)	; Delay

	tst.l	sign
	beq.b	.loop


	move.l	GraphBase(pc),a6

	move.l	FontBase(pc),a1
	jsr	-78(a6)			;CloseFont

	move.l	WindowBase(pc),a0
	move.l	IntuiBase(pc),a6	; baza intitiona
	jsr	-72(a6)			; CloseWindow

	sub.l	a0,a0
	move.l	Screen(pc),a1
	jsr	-$204(a6)		;UnlockPubScreen


	lea.l	ExecBase(pc),a4
	move.l	(a4)+,a6
	
	move.l	(a4)+,a1
	jsr	-414(a6)	;CloseLibrary

	move.l	(a4)+,a1
	jsr	-414(a6)	;CloseLibrary
	
	moveq	#0,d0
	rts


WindowName:	dc.b	"Made by Zeeball and Coma of Apathy in 1999!",0
Nazwa:		dc.b	"Advert(main)",0
Nazwa2:		dc.b	"Advert(slave)",0
DosName:	dc.b	"dos.library",0	
TopazName:	dc.b	"topaz.font",0
IntuiName:	dc.b	"intuition.library",0
GraphName:	dc.b	"graphics.library",0
pt:		dc.b	"ptreplay.library",0
FontDef:			; spec def for topaz9
	dc.l	TopazName
	dc.w	9
	dc.b	0
	dc.b	0
	dc.w	9
	
NewWindow
	dc.w	0
	dc.w	9
	dc.w	xsiz
	dc.w	ysiz
	dc.w	1
	dc.l	32+$00000200
	dc.l	1024+8+$1000+4
	dc.l	Klawisz
	dc.l	0
	dc.l	0
ScreenBase:	dc.l	0
	dc.l	0
	dc.w	40
	dc.w	40
	dc.w	xsiz
	dc.w	ysiz
	dc.w	1



X_GAD=0
Y_GAD=10
X_SIZE=xsiz
Y_SIZE=ysiz-10
	cnop	0,4
Klawisz:
	dc.l	0
	dc.w	X_GAD
	dc.w	Y_GAD
	dc.w	X_SIZE
	dc.w	Y_SIZE
	dc.w	2
	dc.w	3
	dc.w	1
	dc.l	0
	dc.l	0
	ds.l	3
	dc.w	7		;identyfier
	dc.l	0

SegList:	ds.l	1
Lock:		ds.l	1
DosBase:	ds.l	1
ExecBase:	ds.l	1
IntuiBase:	ds.l	1
GraphBase:	ds.l	1
WindowBase:	ds.l	1
Screen:		ds.l	1
rp:		ds.l	1
FontBase:	ds.l	1

	section	Maker,code
Starter2:

MakeSlave:
	moveq	#0,d0
	
	move.l	DosBase,a6
	lea	Starter2-4(pc),a1
	move.l	(a1),d3
	
	move.l	#Nazwa2,d1	; nazwa
	moveq	#127,d2		; priorytet
	move.l	#4096,d4	; stos
	
	jmp	-$8a(a6)	; CreateProc
	

	section	Slave,code

;--------------------------------------------


	lea.l	Text1(pc),a0
	move.l	#20,x_tx
	move.l	#30,y_tx
	bsr.w	Eff

	lea.l	Text2(pc),a0
	move.l	#20,x_tx
	move.l	#50,y_tx
	bsr.w	Eff

	lea.l	Text3(pc),a0
	move.l	#20,x_tx
	move.l	#60,y_tx
	bsr.w	Eff

	lea.l	Text4(pc),a0
	move.l	#20,x_tx
	move.l	#70,y_tx
	bsr.w	Eff

	lea.l	Text5(pc),a0
	move.l	#20,x_tx
	move.l	#80,y_tx
	bsr.w	Eff

	lea.l	Text6(pc),a0
	move.l	#20,x_tx
	move.l	#90,y_tx
	bsr.w	Eff

	lea.l	Text7(pc),a0
	move.l	#20,x_tx
	move.l	#100,y_tx
	bsr.w	Eff

	lea.l	Text8(pc),a0
	move.l	#20,x_tx
	move.l	#120,y_tx
	bsr.w	Eff

	lea.l	Text9(pc),a0
	move.l	#20,x_tx
	move.l	#130,y_tx
	bsr.w	Eff

	lea.l	Text10(pc),a0
	move.l	#20,x_tx
	move.l	#150,y_tx
	bsr.w	Eff



;--------------------------------------------
	move.l	#-1,sign
	rts
Eff:
;	a0	-	text


	lea.l	Usefull(pc),a1
	move.b	#" ",d0
	moveq	#EndUsefull-Usefull-4,d1
.clir:
	move.b	d0,(a1)+
	dbra	d1,.clir


	move.l	a0,a5
	moveq	#-1,d3
.loop:
	addq.l	#1,d3
	tst.b	(a0)+
	bne.b	.loop


	lea.l	Usefull(pc),a4
	
	move.l	d3,d5
	subq.l	#1,d5
.letter:

	cmp.b	#" ",(a5)
	beq.b	.skip
	
	lea.l	Frames(pc),a3
	
	moveq	#13,d6

.anim:
	move.l	(a3)+,(a4)

	bsr.b	PrintText
	
	dbra	d6,.anim

.skip
	move.b	(a5)+,(a4)+
	
	bsr.b	PrintText

	dbra	d5,.letter
	
	moveq	#50,d0
	moveq	#50,d1
	lea.l	GraphName,a4
	moveq	#10,d4
	
	bra.w	PrintText

PrintText:
	movem.l	d0-a6,-(sp)

	move.l	x_tx(pc),d0
	move.l	y_tx(pc),d1
	move.l	GraphBase,a6
	move.l	rp,a1
	tst.l	rp
	beq.b	.no
	jsr	-240(a6)		; Move
	move.l	rp,a1
	lea.l	Usefull(pc),a0
	moveq	#EndUsefull-usefull-4,d0
	jsr	-60(a6)			; Text

	btst	#2,$dff016
	beq	.turbo
	jsr	-270(a6)
	jsr	-270(a6)
.turbo

.no:
	movem.l	(sp)+,d0-a6
	rts
Frames:
f5:	dc.b	"  | "
f6:	dc.b	"  \ "
f7:	dc.b	" -  "
f8:	dc.b	" /  "
f9:	dc.b	" |  "
f10:	dc.b	" \  "
f13:	dc.b	"-   "
f14:	dc.b	"/   "
f15:	dc.b	"|   "
f16:	dc.b	"\   "
f17:	dc.b	"-   "
f18:	dc.b	".   "
f19:	dc.b	"o   "
f20:	dc.b	"O   "



Text1:	dc.b	"MERRY CHRISTMASS AND A HAPPY NEW YEAR 2000!",0
Text2:	dc.b	"Greets and thanks from Zbigniew `Zeeball` Trzcionkowski",0
Text3:	dc.b	"fly to: Jan Andersen, Error and Siumot of BlaBla,",0
Text4:	dc.b	"Strife, Rebel, Punisher, Roover and rest of Apathy!",0
Text5:	dc.b	"Time to say sorry for releasing short and lame intros.",0
Text6:	dc.b	"This activity will be stopped soon because I`m working",0
Text7:	dc.b	"very hard on my exellent antivirus software!",0
Text8:	dc.b	"Santa Claus is coming to the town!",0
Text9:	dc.b	"Enjoy the sources included in this archive!",0
Text10:	dc.b	"See You soon and have fun!",0
Text11:


Cop1:
	dc.b	"Code"
	dc.b	" by "
	dc.b	"Zeeb"
	dc.b	"all!"

	cnop	0,4
	
x_tx:		ds.l	1
y_tx:		ds.l	1
sign:		ds.l	1
Usefull:
	ds.l	30/2
EndUsefull:


	section	data,data_c
Module:
	incbin	dh1:sources/mod.1

