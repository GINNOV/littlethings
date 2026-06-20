**************************************************************************
**************************************************************************
*		Routines to take and restore AmigaDos
**************************************************************************
**************************************************************************

TakeSys
	lea	GraphicsName(pc),a1		open the graphics library
	move.l	ExecBase,a6			to find the system copper
	clr.l	d0				so we can restore it!
	jsr	OpenLibrary(a6)
	move.l	d0,GraphicsBase

*	lea	DOSName(pc),a1			open the DOS library to allow
*	clr.l	d0				the loading of data before
*	jsr	OpenLibrary(a6)			killing the system ( OPT )
*	move.l	d0,DOSBase

	move.l	#MemNeeded,d0			allocate loadsa chipmem
	moveq.l	#2,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq	MemError			Oh Dear! no chipmem avail!!
	move.l	d0,(Variables+MemBase)		store memory start address
	move.l	#Hardware,a6			harware base address in a6
	move.w	intenar(a6),SystemInts		save system interupts
	move.w	dmaconr(a6),SystemDMA		and DMA settings
;	bsr	WaitDrive
	move.w	#$7fff,intena(a6)		kill interupts
.wait	btst.b	#0,vposr(a6)
	bne.s	.wait				wait for line 0
	tst.b	vhposr(a6)			before disabling
	bne.s	.wait				DMA else sprite corruption
	move.w	#$7fff,dmacon(a6)		kill all DMA
	move.b	#%01111111,IcrA			kill CIA-A interupts
	move.l	$68.w,Level2Vector		store sys interupt vectors
	move.l	$6c.w,Level3Vector
	bra	StartCode

WaitDrive
	move.w	#$fff,d1
.l2	move.w	#300,d0
.l1	move.w	d1,color+2(a6)
	dbf	d0,.l1
	dbf	d1,.l2
	rts

**************************************************************************

RestoreSys
	move.w	#$20,$1dc(a6)
	move.l	Level2Vector,$68.w
	move.l	Level3Vector,$6c.w
	move.l	GraphicsBase,a1	
	move.l	SystemCopper1(a1),Hardware+cop1lc	replace system
	move.l	SystemCopper2(a1),Hardware+cop2lc	copperlists
	move.w	SystemInts,d0				restore system
	or.w	#$c000,d0				interupts
	move.w	d0,intena(a6)
	move.w	SystemDMA,d0				and system DMA
	or.w	#$8100,d0
	move.w	d0,dmacon(a6)			finally CIA-A interupts
	move.w	#$000f,dmacon(a6)
	move.b	#%10011011,Icra			ie Keyboard,exec timing
	move.l	ExecBase,a6			get execbase in a6
	move.l	(Variables+MemBase),a1
	move.l	#MemNeeded,d0			free the chipmem we took
	jsr	FreeMem(a6)
Memerror
*	move.l	DOSBase,a1			finally close DOS lib
*	jsr	CloseLibrary(a6)
	move.l	GraphicsBase,a1			close grafix lib
	jsr	CloseLibrary(a6)
	clr.l	d0
	rts					back to where we came from
***************************************************************************

Level2Vector		dc.l	0	variable area used in
Level3Vector		dc.l	0	boshing system
SystemInts		dc.w	0
SystemDMA		dc.w	0
DOSBase			dc.l	0
GraphicsBase		dc.l	0
			Even
GraphicsName		dc.b	'graphics.library',0
			Even
DOSName			dc.b	'dos.library',0

****************************************************************************


