; Another INFO Utility
; (c) 1994 MJSoft System Software, Martin Mares

	include	"ssmac.h"

	clistart

; DeviceInfo structure:
	rsreset
di_node	rs.l	2
di_name	rs.b	8	; Null-terminated
di_state	rs.l	1	; Disk state
di_blocks	rs.l	1	; Number of blocks
di_blused	rs.l	1	; Number of used blocks
di_blocksize	rs.l	1	; Bytes per block
di_disktype	rs.l	1	; FileSystem ID
di_errors	rs.l	1	; Number of soft errors
di_volname	rs.b	32	; Volume name
di_sizeof	rs.b	0

	dbuf	infodata,id_SIZEOF	; Must be _LONGWORD_ALIGNED_ !!!
	dbuf	devlist,12		; Original device list
	dbuf	dvclist,12		; Sorted device list

	geta	devlist,a0
	move.l	a0,LH_TAILPRED(a0)	; This NEWLIST macro requires
	move.l	a0,(a0)			; previously cleared memory
	addq.l	#LH_TAIL,(a0)

	geta	dvclist,a0
	move.l	a0,LH_TAILPRED(a0)
	move.l	a0,(a0)
	addq.l	#LH_TAIL,(a0)

; Scan devices

	moveq	#LDF_READ+LDF_DEVICES,d1
	call	dos,LockDosList
	move.l	d0,d1
scandl	moveq	#LDF_DEVICES,d2
	call	dos,NextDosEntry
	tst.l	d0
	beq.s	scande
	move.l	d0,a3

	moveq	#di_sizeof,d0
	call	ss,TrackAlloc
	move.l	d0,a2
	move.l	a2,a1
	geta	devlist,a0
	call	exec,AddTail

	move.l	dol_Name(a3),a0
	add.l	a0,a0
	add.l	a0,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	lea	di_name(a2),a1
	cmp.b	#6,d0
	bcs.s	1$
	moveq	#6,d0
1$	move.w	d0,d1
	subq.b	#1,d1
	bmi.s	4$
3$	move.b	(a0)+,(a1)+
	dbra	d1,3$
	move.b	#':',(a1)+

4$	move.l	a3,d1
	bra.s	scandl

scande	moveq	#LDF_READ+LDF_DEVICES,d1
	call	UnLockDosList

; Get info on each device

anadev	get.l	devlist,a2
	geta	infodata,a3
	get.l	sv_thistask,a0
	push	pr_WindowPtr(a0)
	moveq	#-1,d0
	move.l	d0,pr_WindowPtr(a0)
1$	move.l	(a2),d7
	beq	2$

	move.l	a2,d1
	addq.l	#di_name,d1
	moveq	#0,d6
	call	dos,IsFileSystem
	tst.l	d0
	beq.s	30$

	move.l	a2,d1
	addq.l	#di_name,d1
	moveq	#ACCESS_READ,d2
	call	dos,Lock
	move.l	d0,d6
	beq.s	40$
	move.l	d0,d1
	move.l	a3,d2
	call	Info
	move.l	d0,d5
	beq.s	40$

	lea	di_state(a2),a0
	lea	id_DiskState(a3),a1
	moveq	#4,d0
10$	move.l	(a1)+,(a0)+
	dbra	d0,10$
	move.l	(a3),(a0)+	; NumSoftErrors

	move.l	id_VolumeNode(a3),a1
	add.l	a1,a1
	add.l	a1,a1
	move.l	dol_Name(a1),a1
	add.l	a1,a1
	add.l	a1,a1
	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.w	#30,d0
	bcs.s	11$
	moveq	#30,d0
	bra.s	11$
12$	move.b	(a1)+,(a0)+
11$	dbra	d0,12$

	bra.s	31$

40$	call	IoErr
	move.l	d0,di_volname(a2)
	bra.s	31$

30$	move.l	a2,a1
	call	exec,Remove
31$	move.l	d6,d1
	beq.s	32$
	call	UnLock
32$	move.l	d7,a2
	bra	1$

2$	get.l	sv_thistask,a0
	pop	pr_WindowPtr(a0)

; Sort the devices by name

sortit	get.l	devlist,a2
	move.l	a2,d7
	move.l	(a2),d0
	beq.s	dumpit
	move.l	d0,a2
sort1	move.l	(a2),d6
	beq.s	sort2
	move.l	a2,a0
	move.l	d7,a1
	addq.l	#di_name,a0
	addq.l	#di_name,a1
	call	utility,Stricmp
	tst.l	d0
	bpl.s	1$
	move.l	a2,d7
1$	move.l	d6,a2
	bra.s	sort1

sort2	move.l	d7,a1
	call	exec,Remove
	move.l	d7,a1
	geta	dvclist,a0
	call	AddTail
	bra.s	sortit

; Display the devices

dumpit	lea	head(pc),a0
	call	ss,PutsNL
	get.l	dvclist,a2
dump1	move.l	(a2),d7
	beq	memstat

	lea	di_name(a2),a3
	moveq	#0,d2
	moveq	#7,d3
dumpname	move.b	(a3)+,d2
	beq.s	1$
	bsr	putc
	dbra	d3,dumpname
1$	addq.w	#1,d3
2$	moveq	#32,d2
	bsr	putc
	dbra	d3,2$

	tst.w	di_volname(a2)
	beq	novolume

	move.l	di_blocks(a2),d0
	bsr	putsize
	move.l	di_blocks(a2),d0
	sub.l	di_blused(a2),d0
	push	d0
	bsr	putsize
	pop	d0
	move.l	di_blocks(a2),d2
	bsr	putperc

	move.l	di_state(a2),d0
	moveq	#80,d1
	sub.l	d1,d0
	moveq	#3,d1
	cmp.l	d1,d0
	bcs.s	10$
	moveq	#4,d0
10$	lsl.l	#2,d0
	lea	dit(pc),a0
	add.l	d0,a0
	call	ss,Puts
	bsr	putsp

	lea	many(pc),a0
	move.l	di_errors(a2),d0
	cmp.l	#1000,d0
	bcc.s	20$
	lea	form1(pc),a0
20$	push	d0
	move.l	sp,a1
	call	ss,Printf
	addq.l	#4,sp
	bsr	put2sp

	move.l	di_disktype(a2),d0
	move.l	d0,d1
	sub.l	#'DOS'*256,d1
	moveq	#6,d2
	cmp.l	d2,d1
	bcs.s	30$
	moveq	#6,d1
	cmp.l	#'MSD'*256,d0
	beq.s	30$
	moveq	#7,d1
	cmp.l	#'MDD'*256,d0
	beq.s	30$
	moveq	#8,d1
30$	lsl.l	#2,d1
	lea	fstab(pc),a0
	add.l	d1,a0
	clr.l	-(sp)
	move.l	(a0)+,-(sp)
	move.l	sp,a0
	call	ss,Puts
	addq.l	#8,sp

	bsr	put2sp
	move.l	di_blocksize(a2),d0
	bsr	putsize2
	lea	di_volname(a2),a0
	call	ss,PutsNL

dumpnext	move.l	d7,a2
	bra	dump1

novolume	move.l	di_volname(a2),d0
	lea	nodisk(pc),a0
	cmp.l	#ERROR_NO_DISK,d0
	beq.s	1$
	lea	nodos(pc),a0
	cmp.l	#ERROR_NOT_A_DOS_DISK,d0
	beq.s	1$
	lea	qem(pc),a0
1$	call	ss,PutsNL
	bra.s	dumpnext

; After all, inform the user about available memory

	dv.l	chipram
	dv.l	fastram
	dv.l	slowram

	dv.l	chiplar
	dv.l	fastlar
	dv.l	slowlar

	dv.l	chiptot
	dv.l	fasttot
	dv.l	slowtot

	dv.l	chipis
	dv.l	fastis
	dv.l	expis

memstat	call	exec,Forbid
	move.l	MemList(a6),a3
1$	move.l	(a3),d7
	beq.s	2$
	move.l	MH_LOWER(a3),d2
	move.l	MH_UPPER(a3),d3
	move.w	MH_ATTRIBUTES(a3),d0
	geta	chipram,a0
	btst	#MEMB_CHIP,d0
	bne.s	3$
	addq.l	#4,a0
	cmp.l	#$c00000,d2
	bcs.s	3$
	cmp.l	#$dc0000,d2
	bcc.s	3$
	addq.l	#4,a0
3$	sub.l	d2,d3
	add.l	d3,(chiptot-chipram)(a0)
	move.l	MH_FREE(a3),d0
	add.l	d0,(a0)
	moveq	#0,d0
	move.l	MH_FIRST(a3),d1
	beq.s	4$
5$	move.l	d1,a1
	move.l	(a1)+,d1
	cmp.l	(a1),d0
	bcc.s	6$
	move.l	(a1),d0
6$	tst.l	d1
	bne.s	5$

4$	cmp.l	(chiplar-chipram)(a0),d0
	bcs.s	41$
	move.l	d0,(chiplar-chipram)(a0)
41$	st	(chipis-chipram)(a0)
	move.l	d7,a3
	bra.s	1$

2$	call	exec,Permit

memdump	moveq	#10,d2
	bsr	putc
	geta	chipram,a2
	lea	chip(pc),a3
	moveq	#2,d7
showmem	tst.l	(chipis-chipram)(a2)
	beq.s	1$
	push	(chiptot-chipram)(a2)
	push	(chiplar-chipram)(a2)
	push	(a2)
	push	a3
	lea	ramt(pc),a0
	move.l	sp,a1
	call	ss,Printf
	lea	16(sp),sp
1$	addq.l	#4,a2
	addq.l	#5,a3
	dbra	d7,showmem

	rts

; Some useful routines ...

putsize	move.l	di_blocksize(a2),d1
	call	utility,UMult32
putsize2	moveq	#'B',d2
	bsr.s	putsize3
	moveq	#'K',d2
	bsr.s	putsize3
	moveq	#'M',d2
	bsr.s	putsize3
	moveq	#'G',d2
	subq.l	#4,sp
putsize3	move.l	#1024,d1
	cmp.l	d1,d0
	bcs.s	putsize4
	add.l	#512,d0
	jump	utility,UDivMod32

putsize4	lea	form1(pc),a0
putsize5	push	d0
	move.l	sp,a1
	call	ss,Printf
	bsr.s	putc
	addq.l	#8,sp

put2sp	bsr	putsp
putsp	moveq	#32,d2
putc	get.l	stdout,d1
	jump	dos,FPutC

putperc	moveq	#100,d1
	call	utility,UMult32
	move.l	d2,d1
	lsr.l	#1,d2
	add.l	d2,d0
	tst.l	d1
	beq.s	putperz
	call	UDivMod32
putperz1	lea	form2(pc),a0
	moveq	#'%',d2
	bsr.s	putsize5	; Return address will be discarded

putperz	moveq	#0,d0
	bra.s	putperz1

; Strings and tables

fstab	dc.b	'OFS FFS OFSIFFSIOFSCFFSCMSD MSDD'
qem	dc.b	'??? ',0		; Must follow fstab !
head	dc.b	'Device    Size   Free  Free  Stat Err  Type  Block  '
	dc.b	'Volume',0
form1	dc.b	'%4ld',0
form2	dc.b	'%3ld',0
dit	dc.b	'R/O',0,'VAL',0,'R/W',0
many	dc.b	'MANY',0
nodisk	dc.b	'No disk present',0
nodos	dc.b	'Not a dos disk',0
chip	dc.b	'Chip',0
fast	dc.b	'Fast',0
c0	dc.b	'Slow',0
ramt	dc.b	'%s RAM: %ld (%ld) of %ld',10,0
	dc.b	'$VER: Inf 1.1 (5.4.94) by Martin Mares',0
	even

	tags
	finish
	end
