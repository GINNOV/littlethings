;	snmaopt	p-
	lea	(DT),a4
	tst.l	(128,SP,D7.L)
	move.l	(lab,a0.w*2),d0
	move.l	(lab,a0.w*2),(lab,a0.w*2)
	move.l	(lab,a0.w*2),(lab,a0,a0.w*2)
	move.l	($100000,a0.w*8),($100000,a0,a0*4)
	move.l	(lab,pc,a0.w*2),(lab,a0.w*2)
	move.l	d0,(lab,a0.w*2)
	move.l	(lab,zpc,d0.w),a0
	move.l	([lab]),d0
	move.l	d0,([lab])
	movea.l	([lab-DT,A4],8),A5
	move.l	a5,([lab-DT,A4],8)
	move.l	([lab],a0,2),(lab,a0,a0)
	tst.l	([$12345678.l,a4],a1,$4321.w)
	move.l	([$100000,a0,a0],$200000),([$100000,a0,a0],$800000)
	btst	d1,([lab],a0,2)
	btst	d1,([lab,a0],2)
	btst	d1,([lab,a0],a0,2)
	btst	d1,(lab,zpc,d0.w)
	pmove.w	mmusr,(1,a0,d0)
	pmove.q	crp,(a1)
	bfffo	([lab,d0.w],20){0:2},d0
	lea	(lab,a0,a0),a1
	lsl	d5

;some modes with OD as a label (ReSource hates these ;)

	move.l	([lab,d0],lab2),d0
	move.l	([lab,pc,d0],lab2),d0
	move.l	d0,([lab,d0],lab2)
	move.l	d0,([d0.l],lab2)
	move.l	([lab,a0,a0],lab2),([lab,a0,a0],lab2)
	move.l	([lab,a0.w],lab2),([lab,a0,a0],lab2)
	move.l	([lab,pc,a0.w],lab2),([lab,a0,a0],lab2)
	btst	d1,([lab],a0,lab2)
	btst	d1,([lab,a0],lab2)
	btst	d1,([lab,a0],a0,lab2)
	bfffo	([lab,d0.w],lab2){0:2},d0

;	section	a,data

DT	nop
lab	dc.b	'txt	''%s'''
lab2	dc.b	"MM's"	

mm	set	1
lab3	moveq	#mm+ss,d0
mm	set	2
	moveq	#mm+ss,d0

ss=1

;	end

* 68060 only stuff

	movec	pcr,d0
	movec	buscr,a0
	movec	sp,pcr
	movec	d7,buscr
	plpar	(a4)
	plpaw	(sp)
	lpstop	#4

	end

* these should be flagged off in 060 only mode

	mc68060		;forces 'pure' 060 mode

	ptestr	(a0)
	ptestw	(a4)
.m	ftrapeq
	fdbne	d0,.m
	fsoge	d0
	cas2	d0:d1,d2:d3,(a0):(a1)
	chk2	(a0),d0
	cmp2	(a0),d0
	movep	d0,(12,a0)
	fmovem	d0,-(sp)
	fmovem	(sp)+,d4
	mulu.l	d0,d0:d1
	divu.l	d0,d0:d1

