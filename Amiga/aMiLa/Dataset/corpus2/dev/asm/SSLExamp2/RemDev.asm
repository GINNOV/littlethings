; Remove DOS Device
; (c) 1994 Martin Mares, MJSoft System Software

;DEBUG	set	1
_GlobVec	set	1
;GATHERTX	set	1
;TEXTRACT	set	1

	include	"ssmac.h"

	clistart

	dbuf	buffer,256
	get.l	device,a0
	geta	buffer,a1
	move.l	a1,d2
copyname	move.b	(a0)+,d0
	beq.s	namecopied
	cmp.b	#':',d0
	beq.s	namecopied
	move.b	d0,(a1)+
	bra.s	copyname

namecopied	move.l	a1,a4

	moveq	#LDF_DEVICES+LDF_READ,d1
	call	dos,LockDosList
	move.l	d0,d1
	moveq	#LDF_DEVICES,d3
	call	FindDosEntry
	move.l	d0,d3
	beq.s	nodev
	move.l	d0,a0
	move.l	dl_Task(a0),d4
nodev	moveq	#LDF_DEVICES+LDF_READ,d1
	call	UnLockDosList
	tst.l	d3
	bne.s	okay1
errr	err	<Device not found>

okay1	tst.l	d4
	beq.s	remnode
	move.b	#':',(a4)
	move.l	d2,d1
	moveq	#0,d2
	call	GetDeviceProc
	move.l	d0,d7
	beq.s	errr
	move.l	d0,a0
	move.l	(a0),d1
	moveq	#ACTION_DIE,d2
	call	DoPkt
	move.l	d0,d2
	call	IoErr
	move.l	d1,d3
	move.l	d7,d1
	call	FreeDeviceProc
	tst.l	d2
	beq.s	failed
	tst.l	d3
	beq.s	remnode
failed	tsv.l	force
	bne.s	remnode
	move.l	d3,d1
	call	SetIoErr
	dtl	<Cannot unload handler>,a0
	jump	ss,DosError

remnode	moveq	#LDF_DEVICES+LDF_WRITE,d1
	call	LockDosList
	move.l	d0,d1
	clr.b	(a4)
	geta	buffer,a0
	move.l	a0,d2
	moveq	#LDF_DEVICES,d3
	call	FindDosEntry
	move.l	d0,d3
	beq.s	okay3
	moveq	#0,d2
	move.l	d3,d1
	call	RemDosEntry
	move.l	d3,d1
	call	FreeDosEntry
okay3	moveq	#LDF_DEVICES+LDF_WRITE,d1
	call	UnLockDosList
	tst.l	d2
	errc.eq	<Device node cannot be removed>
	rts

	tags
	template <DEVICE/A,FORCE/S>
	dv.l	device
	dv.l	force
	finish
	end
