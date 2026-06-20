		section	directory,code
		opt	o+,c-

		movem.l	d0/a0/a7,OldParams
		bsr.s	OpenDos
		bsr.s	GetOutPut
		bsr.s	GetLock

		bsr	Examine
		bsr	PrintNext

Error		bsr.s	Unlock
		bsr.s	CloseDos
		move.l	OldStack,sp
QuitFast	rts	
 
OpenDos		lea	DosName(pc),a1
		move.l	4.w,a6
		jsr	-408(a6)
		move.l	d0,DosBase
		beq.s	QuitFast
 		rts	
 
CloseDos	move.l	DosBase,a1
		move.l	4.w,a6
		jsr	-414(a6)
		rts	
 
GetOutPut	move.l	DosBase,a6
		jsr	-60(a6)
		move.l	d0,File
		beq.s	Error
 		rts	
 
GetLock		movem.l	OldParams,d0/a0
		add.l	d0,a0
		subq.l	#1,a0
		move.b	#0,(a0)
		moveq.l	#$FFFFFFFE,d2
		move.l	LockName,d1
		move.l	DosBase,a6
		jsr	-84(a6)
		move.l	d0,LockBase
		beq.s	Error
 		rts	
 
Unlock		move.l	DosBase,a6
		jsr	-90(a6)
		rts	
 
Examine		move.l	LockBase,d1
		move.l	#InfoBlk,d2
		move.l	DosBase,a6
		jsr	-102(a6)
		tst.l	Buf
		bmi	Error
	 
		lea	Dir.txt(pc),a1
		lea	Buffer,a0
		moveq.w	#4,d0
rloop		move.w	(a1)+,(a0)+
		dbra	d0,rloop
 
		lea	Buff,a1
gloop		move.b	(a1)+,(a0)+
		bne.s	gloop
 
		subq.l	#1,a0
		move.b	#47,(a0)+
		move.b	#10,(a0)+
		move.b	#13,(a0)+
		move.l	a0,OldBuf
		bsr	Write
		rts	
 
PrintNext	bsr	ExNext
		tst.l	d0
		beq	done
 
		lea	Buffer,a0
		bsr	getbuff
		move.b	#13,(a0)+
		move.b	#155,(a0)+
		move.b	#50,(a0)+
		move.b	#52,(a0)+
		move.b	#67,(a0)+
		move.l	Bufff,d0
		bne.s	nxt1
 
		bsr	PrtDir
		bra.s	nxt2
 
nxt1		bsr	getdecimal
nxt2		move.b	#13,(a0)+
		move.b	#155,(a0)+
		move.b	#51,(a0)+
		move.b	#56,(a0)+
		move.b	#67,(a0)+
		move.l	a0,OldBuf
		bsr.s	ExNext
		move.l	OldBuf,a0
		move.l	d0,-(sp)
		beq.s	nxt4
 
		bsr.s	getbuff
		move.b	#13,(a0)+
		move.b	#155,(a0)+
		move.b	#54,(a0)+
		move.b	#50,(a0)+
		move.b	#67,(a0)+
		move.l	Bufff,d0
		bne.s	nxt3
 		bsr.s	PrtDir
		bra.s	nxt4
 
nxt3		bsr.s	getdecimal
nxt4		move.b	#10,(a0)+
		move.b	#13,(a0)+
		move.l	a0,OldBuf
		bsr	Write
		tst.l	(sp)+
		bne	PrintNext
done		rts	
 
ExNext		move.l	LockBase,d1
		move.l	#InfoBlk,d2
		move.l	DosBase,a6
		jsr	-108(a6)
		rts	
 
getbuff		lea	Buff,a1
doit		move.b	(a1)+,(a0)+
		bne.s	doit
 		subq.l	#1,a0
		rts	
 
PrtDir		lea	Dir2.txt(pc),a1
		moveq.w	#10-1,d0
getspaces	move.b	(a1)+,(a0)+
		dbra	d0,getspaces
 		rts	
 
getdecimal	move.b	#32,d5
		lea	hextable(pc),a1
		move.w	#8,d4
ccloop		move.l	(a1)+,d1
		cmp.l	d1,d0
		bcs.s	get3
 
		move.w	#31,d3
		moveq.l	#0,d2
get1		asl.l	#1,d0
		roxl.l	#1,d2
		cmp.l	d1,d2
		bcs.s	get2
 
		sub.l	d1,d2
		addq.l	#1,d0
get2		dbra	d3,get1
	 
		add.b	#48,d0
		move.b	d0,(a0)+
		move.l	d2,d0
		move.b	#48,d5
		bra.s	get4
 
get3		move.b	d5,(a0)+
get4		dbra	d4,ccloop
 
		add.b	#48,d0
		move.b	d0,(a0)+
		rts	
 
Write		move.l	File,d1
		move.l	#Buffer,d2
		move.l	OldBuf,d3
		sub.l	#Buffer,d3
		move.l	DosBase,a6
		jsr	-48(a6)
		rts	

DosName		dc.b	'dos.library',0
		even
Dir.txt		dc.b	'DiskName: '
		even
Dir2.txt	dc.b	'     (dir)',0
		even
hextable	dc.l	1000000000
		dc.l	100000000
		dc.l	10000000
		dc.l	1000000
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		even

		section	nodiskspace,bss 

OldParams	ds.l	1
LockName	ds.l	1
OldStack	ds.l	1
DosBase		ds.l	1
File		ds.l	1
LockBase	ds.l	1
OldBuf		ds.l	1
InfoBlk		ds.l	1
Buf		ds.l	1
Buff		ds.l	29
Bufff		ds.l	34
Buffer		ds.l	50

