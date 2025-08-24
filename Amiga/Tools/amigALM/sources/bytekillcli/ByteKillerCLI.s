AllocMem	= -198
FreeMem		= -210

Open		= -30
Close		= -36
Read		= -42
Write		= -48
Output		= -60
Lock		= -84
UnLock		= -90
Examine		= -102

	cmp.b	#1,d0
	bne	NotNthg

	move.l	4.w,a6
	lea	DosName(pc),a1
	jsr	-408(a6)
	move.l	d0,a6
	jsr	Output(a6)
	move.l	d0,d1
	move.l	#Text,d2
	move.l	#TextEnd-Text,d3
	jsr	Write(a6)
	moveq	#0,d0
	rts

NotNthg	move.b	#"|",-1(a0,d0)
	move.l	a0,a2
	add.l	d0,a2
	move.l	a0,LoadNme
Chck1	cmp.b	#"|",(a0)+
	bne	Chck1
	move.b	#0,-1(a0)

	move.l	a0,SaveNme
Chck2	cmp.b	#"|",(a0)+
	bne	Chck2
	move.b	#0,-1(a0)

	move.l	a0,a1
CapsON	move.b	(a1)+,d0
	sub.b	#$61,d0
	cmp.b	#$19,d0
	bhi	NotChar
	sub.b	#$20,-1(a1)
NotChar	cmp.l	a1,a2
	bne	CapsON

	move.l	a0,Crnch25
Chck3	cmp.b	#"|",(a0)+
	bne	Chck3
	move.b	#0,-1(a0)

	move.b	(a0),DataExe
Chck4	cmp.b	#"|",(a0)+
	bne	Chck4

	cmp.b	#"E",DataExe
	bne	ChkNoMr

	move.l	a0,FLocate
Chck5	cmp.b	#"|",(a0)+
	bne	Chck5
	move.b	#0,-1(a0)

	move.l	a0,JmpInAt
Chck6	cmp.b	#"|",(a0)+
	bne	Chck6
	move.b	#0,-1(a0)

	moveq	#0,d1
	move.l	FLocate(pc),a0
	bsr	HexInLp
	move.l	d1,FLocate

	moveq	#0,d1
	move.l	JmpInAt(pc),a0
	bsr	HexInLp
	move.l	d1,JmpInAt

ChkNoMr	moveq	#0,d1
	move.l	Crnch25(pc),a0
	bsr	HexInLp
	cmp.l	#$1000,d1
	ble	OffstOK
	moveq	#-1,d0
	rts
OffstOK	bclr	#0,d1
	move.l	d1,Crnch25

LoadFle	move.l	4.w,a6
	lea	DosName(pc),a1
	jsr	-408(a6)
	move.l	d0,DosName
	move.l	d0,a6
	move.l	LoadNme(pc),d1
	moveq	#-2,d2
	jsr	Lock(a6)
	move.l	d0,d7
	bne.b	FlExsts
	moveq	#-1,d0
	rts

FlExsts	move.l	d0,d1
	move.l	#InfoBlk,d2
	jsr	Examine(a6)
	move.l	d7,d1
	jsr	UnLock(a6)
	lea	InfoBlk,a0
	move.l	124(a0),FleLgth

	move.l	4.w,a6
	move.l	124(a0),d0
	add.l	#128,d0
	move.l	#$10000,d1
	jsr	AllocMem(a6)
	move.l	d0,AllcMem
	bne.b	GotFlMm
	moveq	#-1,d0
	rts

GotFlMm	move.l	DosName(pc),a6
	move.l	LoadNme(pc),d1
	move.l	#1005,d2
	jsr	Open(a6)
	move.l	d0,d1
	bne.b	FleOpnd

	move.l	4.w,a6
	move.l	FleLgth(pc),d0
	add.l	#128,d0
	move.l	AllcMem(pc),a1
	jsr	FreeMem(a6)
	moveq	#-1,d0
	rts

FleOpnd	move.l	d0,d7
	move.l	AllcMem(pc),d2
	add.l	#128,d2
	move.l	FleLgth(pc),d3
	jsr	Read(a6)
	move.l	d7,d1
	move.l	d0,d7
	jsr	Close(a6)
	tst.l	d7
	bpl.b	ReadOK

	move.l	4.w,a6
	move.l	FleLgth(pc),d0
	add.l	#128,d0
	move.l	AllcMem(pc),a1
	jsr	FreeMem(a6)
	moveq	#-1,d0
	rts

ReadOK	move.l	AllcMem,d0
	add.l	#128,d0
	move.l	d0,FileMem

	bsr	Crnch00
	bset	#1,$bfe001

	move.l	DosName(pc),a6
	move.l	SaveNme(pc),d1
	move.l	#1006,d2
	jsr	Open(a6)
	move.l	d0,d7

	cmp.b	#"E",DataExe
	bne	NotExe1
	move.l	PckLgth(pc),d0
	add.l	#12+188,d0
	move.l	d0,d1
	lsr.l	#2,d0
	and.l	#%11,d1
	beq	IsLong
	addq.l	#1,d0
IsLong	lea	FleHead(pc),a0
	move.l	d0,20(a0)
	move.l	d0,28(a0)
	move.l	FLocate(pc),42(a0)
	move.l	JmpInAt(pc),182(a0)

	move.l	d7,d1
	move.l	a0,d2
	move.l	#220,d3
	jsr	Write(a6)

NotExe1	move.l	d7,d1
	move.l	AllcMem(pc),d2
	move.l	PckLgth(pc),d3
	add.l	#12,d3
	jsr	Write(a6)

	cmp.b	#"E",DataExe
	bne	NotExe2
	move.l	d7,d1
	move.l	#HeadEnd,d2
	moveq	#4,d3
	jsr	Write(a6)

NotExe2	move.l	d7,d1
	jsr	Close(a6)

	move.l	4.w,a6
	move.l	FleLgth(pc),d0
	add.l	#128,d0
	move.l	AllcMem(pc),a1
	jsr	FreeMem(a6)
	moveq	#0,d0
	rts

;--------------------------------------;

Crnch00:move.l	FileMem(pc),a0
	move.l	a0,a1
	add.l	FleLgth(pc),a1
	move.l	AllcMem(pc),a2
	moveq	#0,d2
	move.l	d2,(a2)+
	move.l	FleLgth(pc),(a2)+
	move.l	d2,(a2)+
	move.w	d2,d1
	move.l	d2,d7
	moveq	#1,d2
Crnch01:bsr.s	Crnch03
	tst.b	d0
	beq.s	Crnch02
	addq.w	#1,d1
	cmp.w	#$108,d1
	bne.s	Crnch02
	bsr.l	Crnch18
Crnch02:cmp.l	a0,a1
	bgt.s	Crnch01
	bsr.l	Crnch18
	bsr.l	Crnch23
	move.l	a2,d0
	sub.l	AllcMem(pc),d0
	subq.l	#8,d0
	subq.l	#4,d0
	lea	PckLgth(pc),a3
	move.l	d0,(a3)
	move.l	AllcMem(pc),a3
	move.l	d7,8(a3)
	move.l	d0,(a3)
	rts

Crnch03:move.l	a0,a3
	add.l	Crnch25(pc),a3
	cmp.l	a1,a3
	ble.s	Crnch04
	move.l	a1,a3
Crnch04:moveq	#1,d5
	move.l	a0,a5
	addq.w	#1,a5
Crnch05:move.b	(a0),d3
	move.b	1(a0),d4
Crnch06:cmp.b	(a5)+,d3
	bne.s	Crnch07
	cmp.b	(a5),d4
	beq.s	Crnch08
Crnch07:cmp.l	a5,a3
	bgt.s	Crnch06
	bra.s	Crnch15

Crnch08:subq.w	#1,a5
	move.l	a0,a4
Crnch09:move.b	(a4)+,d3
	cmp.b	(a5)+,d3
	bne.s	Crnch10
	bchg	#1,$bfe001
	cmp.l	a5,a3
	bgt.s	Crnch09
Crnch10:move.l	a4,d3
	sub.l	a0,d3
	subq.l	#1,d3
	cmp.l	d3,d5
	bge.s	Crnch14
	move.l	a5,d4
	sub.l	a0,d4
	sub.l	d3,d4
	subq.w	#1,d4
	moveq	#4,d6
	cmp.l	d6,d3
	ble.s	Crnch12
	moveq	#6,d6
	cmp.l	#$101,d3
	blt.s	Crnch11
	move.w	#$100,d3
Crnch11:bra.s	Crnch13

Crnch12:move.w	d3,d6
	subq.w	#2,d6
	lsl.w	#1,d6
Crnch13:lea	Crnch28(pc),a6
	cmp.w	(a6,d6.w),d4
	bge.s	Crnch14
	move.l	d3,d5
	lea	Crnch26(pc),a4
	move.l	d4,(a4)
	move.b	d6,4(a4)
Crnch14:cmp.l	a5,a3
	bgt.s	Crnch05
Crnch15:moveq	#1,d0
	cmp.l	d0,d5
	beq.s	Crnch17
	bsr.s	Crnch18
	move.b	Crnch27(pc),d6
	move.l	Crnch26(pc),d3
	move.b	d3,$dff180
	move.w	8(a6,d6.w),d0
	bsr.s	Crnch21
	move.w	16(a6,d6.w),d0
	beq.s	Crnch16
	move.l	d5,d3
	subq.w	#1,d3
	bsr.s	Crnch21
Crnch16:move.w	24(a6,d6.w),d0
	move.w	32(a6,d6.w),d3
	bsr.s	Crnch21
	addq.w	#1,40(a6,d6.w)
	add.l	d5,a0
	move.b	#0,d0
	rts

Crnch17:move.b	(a0)+,d3
	moveq	#8,d0
	bsr.s	Crnch21
	moveq	#1,d0
	rts

Crnch18:tst.w	d1
	beq.s	Crnch19
	move.w	d1,d3
	moveq	#0,d1
	cmp.w	#9,d3
	bge.s	Crnch20
	subq.w	#1,d3
	moveq	#5,d0
	bra.s	Crnch21
Crnch19:rts

Crnch20:subq.w	#8,d3
	subq.w	#1,d3
	or.w	#$700,d3
	moveq	#11,d0
Crnch21:subq.w	#1,d0
Crnch22:lsr.l	#1,d3
	roxl.l	#1,d2
	bcs.s	Crnch24
	dbf	d0,Crnch22
	rts

Crnch23:moveq	#0,d0
Crnch24:move.l	d2,(a2)+
	eor.l	d2,d7
	moveq	#1,d2
	dbf	d0,Crnch22
	rts

;--------------------------------------;

HexInLp	tst.b	(a0)
	beq	HexInOK

	moveq	#0,d0
	move.b	(a0)+,d0
	sub.w	#"A",d0
	bcc	IsChar
	add.w	#7,d0
IsChar	add.w	#10,d0

	lsl.l	#4,d1
	or.b	d0,d1
	bra	HexInLp
HexInOK	rts

;--------------------------------------;

Crnch25:dc.l	0
Crnch26:dc.l	0
Crnch27:dc.b	0
	even
Crnch28:dc.w	$0100,$0200,$0400,$1000
	dc.w	$0008,$0009,$000a,$000c
	dc.w	$0000,$0000,$0000,$0008
	dc.w	$0002,$0003,$0003,$0003
	dc.w	$0001,$0004,$0005,$0006
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$0000,$0000

FleLgth:dc.l	0
PckLgth:dc.l	0
AllcMem:dc.l	0
FileMem:dc.l	0
LoadNme:dc.l	0
SaveNme:dc.l	0
Effcncy:dc.l	0
DataExe:dc.b	0
	even
FLocate:dc.l	0
JmpInAt:dc.l	0
DosName:dc.b	"dos.library",0

;--------------------------------------;

Text	dc.b	10
	dc.b	" ",$9b,"1;33mByteKiller CLI",$9b,"0m by Robster",10
	dc.b	" -------------------------",10
	dc.b	" Based on ByteKiller 3.0b by SECTION 9",10,10,10
	dc.b	" ",$9b,"1;33mUSAGE:",$9b,"0m LoadName|SaveName|Offset|Type|Locate|JumpIn|",10,10
	dc.b	" Load Name: File To Be Crunched",10
	dc.b	" Save Name: Name Of File To Save As",10
	dc.b	"    Offset: Efficiency Of Cruncher in HEX, Offsets must be under 1000",10
	dc.b	"      Type: e For Executable, d For Data",10,10
	dc.b	" IF YOU HAVE SELECTED ""e""",10
	dc.b	"    Locate: The Executable Will Decrunch To This Address",10
	dc.b	"    JumpIn: The Address To Jump To After Decrunching",10,10
	dc.b	" A ""|"" MUST Seperate Each Detail",10,10
	dc.b	" eg.  ByteKillerCLI DH1:Intro|DH1:Intro.dat|1000|d",10
	dc.b	" eg.  ByteKillerCLI DH1:Intro|DH1:Intro.exe|5e8|e|70000|70020",10,10
TextEnd	even

;--------------------------------------;

FleHead	dc.l	1011,0,1,0,0,0
	dc.l	1001,0
DeCr00:	movem.l	d0-a6,-(a7)
	lea	DeCrDt(pc),a0
	lea	0,a1
	lea	$dff180,a6
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	add.l	d0,a0
	move.l	(a0),d0
	move.l	a1,a2
	add.l	d1,a2
	moveq	#3,d5
	moveq	#2,d6
	moveq	#$10,d7
DeCr01:	lsr.l	#1,d0
	bne.b	DeCr02
	bsr.b	DeCr14
DeCr02:	bcs.b	DeCr09
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.b	DeCr03
	bsr.b	DeCr14
DeCr03:	bcs.b	DeCr11
	moveq	#3,d1
	moveq	#0,d4
DeCr04:	bsr.b	DeCr15
	move.w	d2,d3
	add.w	d4,d3
DeCr05:	moveq	#7,d1
DeCr06:	lsr.l	#1,d0
	bne.b	DeCr07
	bsr.b	DeCr14
DeCr07:	roxl.l	#1,d2
	dbf	d1,DeCr06
	move.b	d2,-(a2)
	dbf	d3,DeCr05
	bra.b	DeCr13
DeCr08:	moveq	#8,d1
	moveq	#8,d4
	bra.b	DeCr04
DeCr09:	moveq	#2,d1
	bsr.b	DeCr15
	cmp.b	d6,d2
	blt.b	DeCr10
	cmp.b	d5,d2
	beq.b	DeCr08
	moveq	#8,d1
	bsr.b	DeCr15
	move.w	d2,d3
	moveq	#$c,d1
	bra.b	DeCr11
DeCr10:	moveq	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
	move.b	d3,(a6)
DeCr11:	bsr.b	DeCr15
DeCr12:	subq.w	#1,a2
	move.b	0(a2,d2.w),(a2)
	dbf	d3,DeCr12
DeCr13:	cmpa.l	a2,a1
	blt.b	DeCr01
	movem.l	(a7)+,d0-a6
	jmp	0
	moveq	#-1,d0
	rts
DeCr14:	move.l	-(a0),d0
	move.w	d7,ccr
	roxr.l	#1,d0
	rts	
DeCr15:	subq.w	#1,d1
	moveq	#0,d2
DeCr16:	lsr.l	#1,d0
	bne.b	DeCr17
	move.l	-(a0),d0
	move.w	d7,ccr
	roxr.l	#1,d0
DeCr17:	roxl.l	#1,d2
	dbf	d1,DeCr16
	rts	
DeCrDt:
HeadEnd:dc.l	1010

;--------------------------------------;

	SECTION	"Stuff",DATA
InfoBlk	dcb.b	260,0

