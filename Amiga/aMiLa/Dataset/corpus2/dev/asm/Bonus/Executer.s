
;SafeExecuter0.1 from Safe archive. Full Source.

	section	firstcode,code
	
Starter:
	move.l	4.w,a6

	move.l	a6,_ExecBase

	sub.l	a1,a1		; zero
	jsr	-$126(a6)	; FindTask
	move.l	d0,a5
	move.l	$98(a5),_Lock	; pr_CurrentDir
	move.l	188(a5),_Home


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
	move.l	_ExecBase,a6


	lea.l	_Dosname(pc),a1	; nazwa
	moveq	#0,d0		; wersja
	jsr	-$228(a6)	; OpenLibrary
	move.l	d0,a6		; baza dosu
	move.l	a6,_DosBase

	move.l	_Lock,d1
	jsr	-$60(a6)	; DupLock
	move.l	d0,_Lock
	
	lea	Starter-4(pc),a1
	move.l	(a1),d3
	clr.l	(a1)
	move.l	d3,_SegList
	
	move.l	#Nazwa,d1	; nazwa
	moveq	#0,d2		; priorytet
	move.l	#4096,d4	; stos
	
	jsr	-$8a(a6)	; CreateProc

	moveq	#0,d0
	rts

	dc.b	"$VER: SafeExecuter 0.1 (29.11.99) by Zbigniew `Zeeball` Trzcionkowski",10,0

_DosName:	dc.b	"dos.library",0

	section	Main,code
	
	move.l	_Execbase(pc),a6
	sub.l	a1,a1		; zero
	jsr	-$126(a6)	; FindTask
	move.l	d0,a5

	bsr.b	Program

	move.l	_Execbase(pc),a6
	;jsr	-$84(a6)	; Forbid
	move.l	_DosBase(pc),a6
	move.l	_Lock(pc),d1
	jsr	-$5a(a6)	; UnLock

	;move.l	_SegList(pc),d1
	;jsr	-$9c(a6)	; UnLoadSeg

	;move.l	a6,a1
	;move.l	_Execbase(pc),a6
	;jsr	-$19e(a6)	; CloseLibrary

	moveq	#0,d0
	rts

Nazwa:	dc.b	"Safe-Executer!"
Counter:	dc.b	0,0	

_SegList:	ds.l	1
_Lock:		ds.l	1
_DosBase:	ds.l	1
_ExecBase:	ds.l	1
_Home:		ds.l	2

Program:
	move.l	_DosBase(pc),a6
	lea.l	SafeName(pc),a1
	move.l	a1,d1
	moveq	#0,d2
	moveq	#0,d3
	jsr	-$de(a6)	;Execute

	move.l	#50*10,d1
	jsr	-198(a6)	;Delay
	bra	Program

SafeName:
	dc.b	"Safe OWNOUT",0
