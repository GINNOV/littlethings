
;Classic startup with detaching of CLI.

;                                           
	printt	"**> Starter! <**"

	section	Antywirus,code	;FileShield v1.0 header
	pea	Starter
	rts
	rts

	section	Starter,code	;Real begin
	
Starter:
	move.l	4.w,Execbase
	move.l	ExecBase,a6
	
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
 	
	bsr	Z_CLI

	movem.l	(sp)+,a1/a6	; ze stosu...
	
	jsr	-$84(a6)	; Forbid
 	
	jsr	-$17a(a6)	; ReplyMsg
	moveq	#0,d0		; OK!
	rts			; wypad...
	
Z_CLI:

	lea.l	_Dosname(pc),a1	; nazwa
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
	moveq	#0,d2		; priorytet
	move.l	#4096,d4	; stos
	
	jsr	-$8a(a6)	; CreateProc

	moveq	#0,d0
	rts

_DosName:	dc.b	"dos.library",0

	section	Main,code

	bsr	Program

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

	

SegList:	dc.b	"ZbL!"
Lock:		ds.l	1
DosBase:	ds.l	1
ExecBase:	ds.l	1

