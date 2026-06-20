;
; ### Backup v 1.221 ###
;
; - Created 881109 by JM -
;
;
; Copyright © 1988, 1989 by Supervisor Software
;
;
; For backuping a harddisk.  Written because it's a good habit to make some
; backups of one's harddisks from time to time.
;
;
; NOTES:
;
; - Trackdisk seems to need CMD_UPDATE ALWAYS after a track write although
;   some would think that is only needed after writing just few sectors.
;
; - I'm planning to visit... THERE!
;
; - I ain't any longer ... because of the ... CRASH
;
; - 1.22 Life goes on...  Where's Miki?
;
;
; BUGS:
;
; - None, I hope (And I REALLY DO because if my hard disk fails I will
;   need this to restore it...)
;
;
; Edited:
;
; - 881109 by JM -> v0.001	- Already loads and prints Dir (hew-hew).
;		    v0.002	- Should handle subdirectories correctly.
;		    v0.003	- If error, now UnLock()s correctly.
; - 881110 by JM -> v0.004	- File copy PushAway written, uses only 1 disk
; - 881110 by JM -> v0.005	- File copy RdMain started, uses only 1 disk
; - 881111 by JM -> v0.010	- File copy RdMain ready, uses many disks
;				- PushAway uses many disks
; - 881112 by JM -> v0.020	- CMD_UPDATE added to WriteCyl().  Now seems
;				  to work correctly.
;				- BackupAll and SetArchive options added.
;				- CmdLine parsing written by TM.
;				- Check mode added.
; - 881112 by JM -> v0.15	- Finally a version that seems to work.
; - 881113 by JM -> v0.30	- Disk ids added.
;				- CMDLine parser re-written by TM.
; - 881113 by JM -> v0.34	- Retry option added to trackdisk routines.
; - 881113 by JM -> v0.36	- Trackdisk Format added.
; - 881113 by JM -> v0.37	- Bug fixed in retry().
; - 881113 by JM -> v0.38	- Sets/checks A-flags of directories, too.
; - 881113 by JM -> v0.40	- Now only affects Archive flag.  Other
;				  flags remain unchanged.
; - 881113 by JM -> v0.50	- Some cleaning still made.
;				- Now counts the cylinders formatted and
;				  prints the # if not zero.
;				- Now also asks for the first backup disk,
;				  so it doesn't have to be in drive when
;				  the program is first started.
; - 881113 by JM -> v0.60	- Disk # mismatch fixed.
; - 881114 by JM -> v0.70	- Now writes fib_Protect and fib_DateStamp
;				  onto disk, too.  During restore sets prot
;				  flags.
;				- Does not start trackdisk.device at the
;				  beginning before asking for the first disk.
; - 881121 by JM -> v0.75	- After the Earthquake:
;				  Now option ALL causes all files to be read
;				  from a backup.  If the option is not used,
;				  only the files that don't exist on HD will
;				  be read.
; - 881121 by JM -> v0.80	- Verify added to WriteCyl().
;				- Now WriteCyl() always formats the cylinders.
;				- Now WriteCyl() automatically retries three
;				  times before asking the User to select
;				  retry or cancel.
; - 881122 by JM -> v1.0	- Minor bug fixes.
;				- Now writes DateStamp onto disk and checks
;				  it when reading (must be same on all disks
;				  of a backup).
;				- Now prints the drive which is being used
;				  when asking for backup disks.
;				- Now doesn't try to write EOP onto disk if
;				  an error has occurred.
;				- Now doesn't calc lengths of files not
;				  copied from backup.
; - 881203 by JM -> v1.1	- Now ALL directories are ALWAYS searched for
;				  files without Archive flags set.  This is
;				  because the Archive flag of parentparent
;				  dir a is not cleared if a/b/file is changed.
;				  This must be a bug of AmigaDOS (this system
;				  is not sensible).
; - 890121 by JM -> v1.2	- If a read error during backupping is encoun-
;				  tered the user can select Abort to exit the
;				  program or Continue to continue backupping
;				  with the next file.
;				- .s's added to relative branch intructions.
; - 890122 by JM -> v1.21	- If Read() gets less than fib_Size bytes from
;				  the file the user is informed and the space
;				  is filled with $ff's.
; - 890312 by JM -> v1.22	- Short branches, A68k compatibility.
; - 890706 by JM -> v1.221	- Converted to use relative.i.  Untested.
;
;


		include	"dos.xref"
		include	"exec.xref"
		include "JMPLibs.i"
		include	"string.i"
		include	"numeric.i"
		include	"relative.i"

		include "exec/types.i"
		include "exec/nodes.i"
		include "exec/lists.i"
		include "exec/memory.i"
		include "exec/interrupts.i"
		include "exec/ports.i"
		include "exec/libraries.i"
		include "exec/io.i"
		include "exec/tasks.i"
		include "exec/execbase.i"
		include "exec/devices.i"
		include "devices/trackdisk.i"
		include	"dos.i"



*************************************************************************
*									*
* Stack allocation for WrMain():					*
*									*
*************************************************************************

		.var				alloc backwards
		dl	bufmem			start of temp buffer
		dl	lockptr			pointer to a lock
		dl	locknam			pointer to new name of lock
		dl	oldlock			pointer to original name of lock



CYL_SIZE	equ	512*11*2		bytes per cylinder
TEMPSTR		equ	256
PATHSTR		equ	256
NAMESTR		equ	256
TRACKBUF	equ	CYL_SIZE+TEMPSTR+NAMESTR+PATHSTR+256
VERBUF		equ	CYL_SIZE+256
WRMEM		equ	fib_SIZEOF+256

MAXUCYL		equ	79+1			highest + 1

LF		equ	10
CR		equ	13
CSI		equ	155

;DEBUG		equ	1



*************************************************************************
*									*
* Macro definitions:							*
*									*
*************************************************************************

strcpy		macro	*src,dst
strcpy\@	move.b	(\1)+,(\2)+
		bne	strcpy\@
		endm

strcmp		macro	*src,dst
		push	a0/a1/d0/d1
		ifnc	'\1','a0'
		move.l	\1,a0
		endc
		ifnc	'\2','a1'
		move.l	\2,a1
		endc
		bsr	StrCmp
		pull	a0/a1/d0/d1
		endm


dcbne		macro	hlong,llong,label
		cmp.l	\1,d1
		bne	\3
		cmp.l	\2,d0
		bne	\3
		endm


bug		macro
		ifd	DEBUG
		print	<\1>
		endc
		endm



*************************************************************************
*									*
* Program main entry:							*
*									*
*************************************************************************

Start		push	d2-d7/a2-a6		save regs
		move.l	d0,_CMDLen		len of cmd line
		move.l	a0,_CMDBuf		start addr of cmd line
		clr.b	-1(a0,d0.l)		add null
		openlib Dos,cleanup		open Dos library

		print	<'Backup v1.221 © JM 1988,89',LF>


		bsr	CreatePort
		bcs	cleanup
		ifd	DEBUG
		bug	<'port created',10>
		endc

		bsr	CreateIO
		bcs	cleanup
		ifd	DEBUG
		bug	<'ioreq created',10>
		endc

		bsr	Allocmem
		bcs	cleanup
		ifd	DEBUG
		bug	<'mem reserved',10>
		endc

		bsr	parse			parse command line parameters
		bcs	cleanup
		bsr	printvalues


		lea	TDname(pc),a0		device name
		move.l	unit(pc),d0		unit number
		move.l	ioreq(pc),a1		*IORequest
		moveq.l	#0,d1			flags (normally zero)
		lib	Exec,OpenDevice
		move.l	d0,TDOflag		flag: error opening TD.device
		beq.s	TDopened
		print	<'Can''t open trackdisk.device',LF>
		bra.s	cleanup


TDopened	move.b	command(pc),d0
		cmp.b	#'w',d0
		beq.s	BUWrite
		cmp.b	#'r',d0
		beq.s	BURead
		cmp.b	#'c',d0
		beq.s	BUCheck
		bra.s	cleanup

BUWrite		clr.w	chkflag		make backup
		bsr	WriteBup
		bra.s	done

BURead		clr.w	chkflag		read backup
		bsr	ReadBup
		bra.s	done

BUCheck		move.w	#-1,chkflag	check backup
		bsr	ReadBup
		;bra	done




done		bsr	MotorOff

cleanup		move.l	TDOflag(pc),d0
		bne.s	clean01
		move.l	ioreq(pc),a1
		lib	Exec,CloseDevice

clean01		bsr	DeleteIO
		bsr	DeletePort
		bsr	Freemem

clean99		closlib	Dos
		pull	d2-d7/a2-a6
		rts




*************************************************************************
*									*
* Main subroutines etc.							*
*									*
*************************************************************************

printvalues	
		ifd	DEBUG
		print	<LF,LF,'Parameter dump:',LF>
		print	<'Path: "'>
		printa	pbuf(pc)
		print	<'"',LF,'Unit:'>
		move.l	unit(pc),d0
		bsr	print10
		print	<LF,'Cmd:'>
		printa	#command
		print	<LF,'chkflag,allflag,verbose,arcflag:'>
		moveq.l	#0,d0
		move.w	chkflag(pc),d0
		bsr	print10
		moveq.l	#0,d0
		move.w	allflag(pc),d0
		bsr	print10
		moveq.l	#0,d0
		move.w	verbose(pc),d0
		bsr	print10
		moveq.l	#0,d0
		move.w	arcflag(pc),d0
		bsr	print10
		print	<LF,LF>
		endc
		rts



CreatePort	push	d1-d3/a0-a3
		moveq.l	#-1,d0
		lib	Exec,AllocSignal
		move.l	d0,d2
		bmi.s	CreatePort_e
		move.b	d0,signalbit
		moveq.l	#MP_SIZE,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,msgport
		beq.s	CreatePort_e

		sub.l	a1,a1
		lib	Exec,FindTask
		move.l	d0,a0			my task

		move.l	msgport(pc),a1
		move.l	a0,MP_SIGTASK(a1)
		move.b	signalbit(pc),MP_SIGBIT(a1)
		move.b	#NT_MSGPORT,LN_TYPE(a1)
		move.b	#PA_SIGNAL,MP_FLAGS(a1)
		move.l	a1,d0
		lea	MP_MSGLIST(a1),a1
		NEWLIST	a1
		pull	d1-d3/a0-a3
		clrc
		rts

CreatePort_e	bsr.s	DeletePort
		pull	d1-d3/a0-a3
		setc
		rts


DeletePort	push	d0-d3/a0-a3
		moveq.l	#0,d0
		move.b	signalbit(pc),d0
		bmi.s	DeletePort1
		lib	Exec,FreeSignal
DeletePort1	move.l	msgport(pc),d0
		beq.s	DeletePort2
		move.l	d0,a1
		moveq.l	#MP_SIZE,d0
		lib	Exec,FreeMem
DeletePort2	move.b	#-1,signalbit
		clr.l	msgport
		pull	d0-d3/a0-a3
		rts



CreateIO	push	d1-d3/a0-a3
		moveq.l	#IOSTD_SIZE,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,ioreq
		beq.s	CreateIO_e
		move.l	d0,a0
		move.l	msgport(pc),MN_REPLYPORT(a0)
		move.b	#NT_MESSAGE,LN_TYPE(a0)
		move.w	#IOSTD_SIZE,MN_LENGTH(a0)
		pull	d1-d3/a0-a3
		clrc
		rts

CreateIO_e	pull	d1-d3/a0-a3
		setc
		rts

DeleteIO	push	d1-d3/a0-a3
		move.l	ioreq(pc),d0
		beq.s	DeleteIO1
		move.l	d0,a1
		moveq.l	#IOSTD_SIZE,d0
		lib	Exec,FreeMem
		clr.l	ioreq
DeleteIO1	pull	d1-d3/a0-a3
		rts



Allocmem	push	all
		move.l	#TRACKBUF,d0	alloc mem for trackbuf & other
		move.l	#MEMF_CHIP,d1	 buffers
		lib	Exec,AllocMem
		move.l	d0,trackbuf
		move.l	d0,trackpoi
		beq.s	Allocmem_e
		add.l	#CYL_SIZE,d0
		move.l	d0,trackend
		add.l	#128,d0
		move.l	d0,sbuf		for temp strings
		add.l	#TEMPSTR,d0
		move.l	d0,pbuf		for pathname
		add.l	#PATHSTR,d0
		move.l	d0,nbuf		for filename

		move.l	#VERBUF,d0	alloc mem for verify track buffer
		move.l	#MEMF_CHIP,d1
		lib	Exec,AllocMem
		move.l	d0,verbuf
		beq.s	Allocmem_e

		pull	all
		clrc
		rts

Allocmem_e	pull	all
		setc
		rts



Freemem		push	all
		move.l	trackbuf(pc),d0
		beq.s	Freemem1
		move.l	d0,a1
		move.l	#TRACKBUF,d0
		lib	Exec,FreeMem
		clr.l	trackbuf
Freemem1	move.l	verbuf(pc),d0
		beq.s	Freemem2
		move.l	d0,a1
		move.l	#VERBUF,d0
		lib	Exec,FreeMem
		clr.l	verbuf
Freemem2	pull	all
		rts




MotorOn		push	all
		move.l	ioreq(pc),a1
		move.l	#1,IO_LENGTH(a1)
		move.w	#TD_MOTOR,IO_COMMAND(a1)
		lib	Exec,DoIO
		pull	all
		rts

MotorOff	push	all
		move.l	ioreq(pc),a1
		move.l	#0,IO_LENGTH(a1)
		move.w	#TD_MOTOR,IO_COMMAND(a1)
		lib	Exec,DoIO
		pull	all
		rts


ReadCyl		push	all			cyl=d0
		move.l	ioreq(pc),a1
		mulu.w	#44,d0			multiply by 512*11*2
		asl.l	#8,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	#CYL_SIZE,IO_LENGTH(a1)	length = 1 cyl
		move.l	trackbuf(pc),IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		lib	Exec,DoIO
		tst.l	d0
		beq.s	ReadCyl_ok
		print	<'*** Trackdisk error #'>
		bsr	print10
		print	<LF>
		bra.s	ReadCyl_e
ReadCyl_ok	pull	all
		clrc
		rts

ReadCyl_e	pull	all
		move.l	d0,-(sp)
		bsr	retry
		bne.s	ReadCyl_ee
		move.l	(sp)+,d0
		bra	ReadCyl
ReadCyl_ee	move.l	(sp)+,d0
		setc
		rts



WriteCyl	push	all				cyl=d0
		move.l	d0,d7				save cyl#
WriteCyl_Retry	moveq.l	#2,d6				retry counter
WriteCyl_Rtr	move.l	ioreq(pc),a1
		move.l	d7,d0
		mulu.w	#44,d0				multiply by 512*11*2
		asl.l	#8,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	#CYL_SIZE,IO_LENGTH(a1)		length = 1 cyl
		move.l	trackbuf(pc),IO_DATA(a1)
		move.w	#TD_FORMAT,IO_COMMAND(a1)
		move.l	a1,a2
		lib	Exec,DoIO			write this cyl
		tst.l	d0
		bne.s	WriteCyl_e1			could not write it

		move.l	a2,a1
		move.w	#CMD_UPDATE,IO_COMMAND(a1)	try to update
		lib	Exec,DoIO
		tst.l	d0
		bne	WriteCyl_e2			could not update

		move.l	d7,d0				verify it
		bsr	VeriCyl
		bcs.s	WriteCyl_e3			verify error

		pull	all				OK, written ok
		clrc
		rts

WriteCyl_e1	cmp.w	#TDERR_WriteProt,d0
		bne.s	WriteCyl_e2
		print	<'*** Error: Disk write protected',LF>
		bra.s	WriteCyl_ask
WriteCyl_e3	print	<'*** Verify error -'>
WriteCyl_e2	print	<' Retrying...',LF>
		addq.l	#1,retrycnt
		dbf	d6,WriteCyl_Rtr		retry operation
WriteCyl_ask	bsr	retry
		beq	WriteCyl_Retry		user wants us to retry again
		pull	all
		setc				- no success
		rts




VeriCyl		push	all			cyl=d0
		move.l	verbuf(pc),a0		verify buffer
		move.l	ioreq(pc),a1
		mulu.w	#44,d0			multiply by 512*11*2
		asl.l	#8,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	#CYL_SIZE,IO_LENGTH(a1)	length = 1 cyl
		move.l	a0,IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		lib	Exec,DoIO
		tst.l	d0
		bne.s	VeriCyl_e	could not even read it
		move.l	verbuf(pc),a0
		move.l	trackbuf(pc),a1
		move.w	#(CYL_SIZE/4)-1,d0
VeriLoop	cmpm.l	(a0)+,(a1)+	compare each and every LONG
		dbne	d0,VeriLoop
		tst.w	d0
		bpl.s	VeriCyl_e	error in data
VeriCyl_ok	pull	all
		clrc
		rts

VeriCyl_e	pull	all
		setc
		rts






*************************************************************************
*									*
* This routine reads files back from backup disks			*
*									*
*************************************************************************

ReadBup		push	all
		moveq.l	#0,d0
		move.w	d0,cyl			start at cyl#0
		move.w	d0,dsk			start from disk #0
		move.l	d0,files
		move.l	d0,bytes
		move.l	d0,dirs
		moveq.l	#0,d7			filehandle*

		bsr	AskNextDisk

		move.l	trackbuf(pc),a4
		move.l	a4,trackpoi

		moveq.l	#1,d0
		bsr	ck_dsk			read in the first cylinder
		bcs	RdMain_e

*************************************************************************
*									*
* NOTE:									*
* If -a or ALL is not selected during restore operation, only those	*
* files that don't exist on hard disk will be copied from backup.  This	*
* is flagged by chkflag bit#0 which is set to 1 if the current file	*
* should not be copied.							*
*									*
*************************************************************************

RdMainLoop	bsr	ck_stop
		bne	RdMain_e
		andi.w	#-2,chkflag		reset special flag bit #0
		move.l	sbuf(pc),a0
		moveq.l	#16,d1
RdMainPath	bsr	istr			read path chunk name
		bcs	RdMain_e
		lea	TYPE_PATH(pc),a0
		move.l	sbuf(pc),a1
		strcmp	a0,a1
		bne	RdMainFile		path not found

		move.l	pbuf(pc),a0
		moveq.l	#96,d1
RdMain10	bsr	istr			get pathname
		bcs	RdMain_e

		move.w	verbose(pc),d0
		beq.s	RdMaVe1
		print	<'Path "'>
		printa	pbuf(pc)
		print	<'"',LF>

RdMaVe1		move.l	sbuf(pc),a0		check for EOP
		moveq.l	#16,d1
		bsr	istr
		lea	TYPE_EOP(pc),a0
		move.l	sbuf(pc),a1
		strcmp	a0,a1
		bne	RdMain_e2		path syntax error
		addq.l	#1,dirs
		move.w	chkflag(pc),d0		if check, don't CreDir()
		bne	RdMainLoop
		bsr	CreDir			create dir if necessary
		bra	RdMainLoop

RdMainFile	lea	TYPE_FILE(pc),a0
		move.l	sbuf(pc),a1
		strcmp	a0,a1
		bne	RdMainEnd	is it the end then?

		move.l	nbuf(pc),a0
		move.l	pbuf(pc),a1
		strcpy	a1,a0		copy path into name buffer
		subq.l	#1,a0
		moveq.l	#64,d1
		bsr	istr		input filename
		bcs	RdMain_e4	cannot get filename

		move.w	verbose(pc),d0
		beq.s	RdMaVe2
		print	<'File "'>
		printa	nbuf(pc)
		print	<'"',LF>

RdMaVe2		bsr	ilong		get length of file
		bcs	RdMain_e5
		move.l	d0,d6		save length

		bsr	ilong		get protection status
		bcs	RdMain_e5
		move.l	d0,d5		save it in d5

		lea	mydate(pc),a0
		bsr	ilong		get DateStamp
		bcs	RdMain_e5
		move.l	d0,(a0)+
		bsr	ilong
		bcs	RdMain_e5
		move.l	d0,(a0)+
		bsr	ilong
		bcs	RdMain_e5
		move.l	d0,(a0)

		move.w	chkflag(pc),d0	check if check mode
		beq.s	RdMainCkAll
		add.l	d6,bytes	add bytes in real check mode
		bra.s	RdMainCopy

RdMainCkAll	move.w	allflag(pc),d0	check if all files should be read
		bne.s	RdMainOpAlways	yes -> don't check if already exists

		move.l	nbuf(pc),d1	check if file already exists
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		move.l	d0,d1
		beq.s	RdMainOpAlways	it doesn't exist
		moveq.l	#1,d0
		move.w	d0,chkflag	prevent copying file
		lib	Dos,UnLock
		bra.s	RdMainCopy	don't open file!

RdMainOpAlways	move.l	nbuf(pc),d1
		move.l	#MODE_NEWFILE,d2
		lib	Dos,Open
		move.l	d0,d7
		beq	RdMain_e6

RdMainCopy	bsr	ck_stop
		bne	RdMain_e

		move.l	d7,d1		file
		move.l	a4,d2		buffer
		move.l	d6,d3		length needed
		move.l	trackend(pc),d4
		sub.l	a4,d4		max length that can be got now
		cmp.l	d3,d4
		bhs.s	RdMainCopy0	OK, we can get all we need
		move.l	d4,d3		sorry, we can get only d4 bytes!

RdMainCopy0	move.w	chkflag(pc),d0	if check mode, don't write anything!
		beq.s	RdMainCopy0Wr
		move.l	d3,d0
		bra.s	RdMainCopy0NWr
RdMainCopy0Wr	lib	Dos,Write
		add.l	d0,bytes	these bytes actually read
		cmp.l	d0,d3
		bne	RdMain_e7
RdMainCopy0NWr	add.l	d0,a4
		sub.l	d0,d6		sub from total length
		cmp.l	trackend(pc),a4
		blo.s	RdMainCopy1
		bsr	RCyl
		bcs	RdMain_e
RdMainCopy1	tst.l	d6		still bytes left for this file?
		bne	RdMainCopy	do all blocks

		move.l	d7,d1
		beq.s	RdMainNoClose
		lib	Dos,Close
RdMainNoClose	moveq.l	#0,d7

		move.l	sbuf(pc),a0
		moveq.l	#16,d1
		bsr	istr
		bcs	RdMain_e8
		move.l	sbuf(pc),a0
		lea	TYPE_EOF(pc),a1
		strcmp	a0,a1
		bne	RdMain_e9		no EOF found
		addq.l	#1,files

		move.w	chkflag(pc),d0		check -> goto loop
		bne	RdMainLoop

		move.l	nbuf(pc),d1		name
		move.l	d5,d2			flags
		move.w	arcflag(pc),d0		no set arc -> do not set it!
		beq.s	RdMainDNS
		bset	#FIBB_ARCHIVE,d2
RdMainDNS	lib	Dos,SetProtection

		bra	RdMainLoop


RdMainEnd	lea	TYPE_END(pc),a0
		move.l	sbuf(pc),a1
		strcmp	a0,a1		not path, end, nor file
		bne	RdMain_e3	 - what is it then?

		print	<LF,'End of Backup found.',LF,'All done.',LF>

		bsr	PrintStat

RdMain_x	clrc
		pull	all
		rts

RdMain_e1	print	<'*** Path not found',LF>
		bra	RdMain_e
RdMain_e2	print	<'*** End of path not found',LF>
		bra	RdMain_e
RdMain_e3	print	<'*** Unknown Chunk',LF>
		bra	RdMain_e
RdMain_e4	print	<'*** Cannot get filename',LF>
		bra	RdMain_e
RdMain_e5	print	<'*** Cannot get file parameters',LF>
		bra	RdMain_e
RdMain_e6	print	<'*** Cannot create file',LF>
		bra	RdMain_e
RdMain_e7	print	<'*** Error writing file',LF>
		bra.s	RdMain_e
RdMain_e8	print	<'*** Cannot read EOF',LF>
		bra.s	RdMain_e
RdMain_e9	print	<'*** No EOF found',LF>

RdMain_e	move.l	d7,d1
		beq.s	RdMain_ee
		lib	Dos,Close
		moveq.l	#0,d7
RdMain_ee	setc
		pull	all
		rts



*************************************************************************
*									*
* This routine creates the backup (this is the main entry).		*
*									*
*************************************************************************

WriteBup	lea	ctime(pc),a0		obtain current time
		move.l	a0,d1
		lib	Dos,DateStamp

		moveq.l	#0,d0
		move.w	d0,cyl			start at cyl #0
		move.w	d0,dsk			start from disk #0
		move.l	d0,retrycnt		no retries done yet
		addq.l	#1,d0
		move.l	d0,dirs			already in first dir

		bsr	AskNextDisk

		bsr	WID			write disk ID

		move.l	pbuf(pc),a1
		tst.b	(a1)
		beq.s	WrMp_ok			if path=NULL, no slash needed!
WrMp1		tst.b	(a1)+
		bne.s	WrMp1
		move.b	-2(a1),d0
		cmp.b	#':',d0
		beq.s	WrMp_ok
		cmp.b	#'/',d0
		beq.s	WrMp_ok
		move.b	#'/',-1(a1)		add slash if needed
		clr.b	(a1)

WrMp_ok		move.l	pbuf(pc),a1
		bsr	PushPath

		move.l	pbuf(pc),d1		main lock name ###
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		tst.l	d0
		bne.s	WrMLock_ok
		print	<'*** Cannot get Main lock ***',LF>
		setc
		rts

WrMLock_ok	move.l	pbuf(pc),a0		lock path; d0=lockptr ###
		bsr.s	WrMain
		bcs.s	WrMain_rror

		bsr	PushEnd			don't try this if already error

WrMain_rror	move.l	d0,d1
		lib	Dos,UnLock

		bsr	PrintStat

		clrc
		rts



*************************************************************************
*									*
* This routine creates the backup (this is the re-entrant subroutine)	*
*									*
*************************************************************************

WrMain		.begin			alloc mem for temp usage
		push	a0-a3/a5/d0-d7

		move.l	d0,lockptr(a4)		save lock
		move.l	a0,oldlock(a4)		pathname of old lock

		moveq.l	#0,d5			files
		moveq.l	#0,d6			dirs
		moveq.l	#0,d7			bytes in files

		move.l	#WRMEM,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,bufmem(a4)
		beq	WrMain_e

		add.l	#fib_SIZEOF,d0
		move.l	d0,locknam(a4)		space for lock dir pathname

		move.l	oldlock(a4),a0		backup name path
		move.l	locknam(a4),a1
		strcpy	a0,a1			get a copy of lock name
		subq.l	#1,a1
		move.l	a1,oldlock(a4)		now points to end of oldlock

		move.l	lockptr(a4),d1
		move.l	bufmem(a4),d2		space for fib
		lib	Dos,Examine
		tst.l	d0
		beq	WrMain_e1		can't Examine()

		move.l	bufmem(a4),a5		fib
		tst.l	fib_DirEntryType(a5)	a dir?
		bmi	WrMain_e2		this is a file!

WrMainNextFile	bsr	ck_stop			*Handle files in this loop
		bne	WrMain_e		stopped?
		move.l	lockptr(a4),d1
		move.l	a5,d2
		lib	Dos,ExNext
		tst.l	d0
		beq.s	WrMain_Dir		no_more_entries maybe

		tst.l	fib_DirEntryType(a5)	a dir?
		bpl.s	WrMainNextFile		yes, skip it

		lea	fib_FileName(a5),a0
		move.l	oldlock(a4),a1
		strcpy	a0,a1

		move.w	allflag(pc),d0		check if all files must be
		bne.s	WrMainAlw		 copied (or only those with
		move.l	fib_Protection(a5),d0	 archive=0)
		btst	#FIBB_ARCHIVE,d0
		bne.s	WrMainNThis		

WrMainAlw	move.l	a5,a0			fib*
		move.l	locknam(a4),a1		path/file
		bsr	PushAway
		bcs	WrMain_e		if error or stopped
		addq.l	#1,d5			one more file!
		add.l	fib_Size(a5),d7		more bytes...

WrMainNThis	move.l	oldlock(a4),a0
		clr.b	(a0)			remove filename

		bra	WrMainNextFile		handle all files on this level


WrMain_Dir	move.l	lockptr(a4),d1		Start at beginning for Dirs
		move.l	bufmem(a4),d2		space for fib
		lib	Dos,Examine
		tst.l	d0
		beq	WrMain_e1		can't Examine()

WrMainNextDir	bsr	ck_stop			*Handle directories in this loop
		bne	WrMain_e		stopped?
		move.l	lockptr(a4),d1
		move.l	a5,d2
		lib	Dos,ExNext
		tst.l	d0
		beq	WrMain_x		no_more_entries maybe

		tst.l	fib_DirEntryType(a5)	a file?
		bmi.s	WrMainNextDir		yes, skip it

		addq.l	#1,d6			one more dir!

		lea	fib_FileName(a5),a0	start of path extension
		move.l	oldlock(a4),a1		end of previous path

		strcpy	a0,a1			add a new name
		subq.l	#1,a1
		move.b	-1(a1),d0		If ends with / or : no slash
		cmp.b	#'/',d0			 must be added!
		beq.s	WrMain_NoLPath
		cmp.b	#':',d0
		beq.s	WrMain_NoLPath
		move.b	#'/',(a1)+		add a slash!
		clr.b	(a1)			...and a NULL

WrMain_NoLPath	move.w	allflag(pc),d0		check if all dirs must be
;		bne	WrMainAlDir		 copied (or only those with
;		move.l	fib_Protection(a5),d0	 archive=0)
;		btst	#FIBB_ARCHIVE,d0
;		bne	WrMainNextDir

*************************************************************************
*									*
* NOTE:  There seems to be a bug in AmigaDOS 1.2:			*
*	 When a file A in dir B is changed, the Archive flags of both	*
*	 the file and the dir B are reset.  That's perfectly well.	*
*	 But if the dir B was located in dir C, the Archive flag of dir	*
*	 C was NOT reset!!!  So we need to search through all direct-	*
*	 ories ALTHOUGH their A-flags have been set.			*
*	 Maybe that'll change on 1.3.					*
*									*
*************************************************************************


WrMainAlDir	move.l	locknam(a4),a1
		bsr	PushPath		write new path name
		bcs	WrMain_e

		move.l	locknam(a4),d1
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		tst.l	d0
		beq	WrMain_e3		can't Lock()
		move.l	locknam(a4),a0
		bsr	WrMain
		bcs.s	WrMain__e
		move.l	d0,d1
		lib	Dos,UnLock

		move.w	arcflag(pc),d0		need A-flag?
		beq	WrMainNextDir		no -> jump

		move.l	locknam(a4),a0
		move.l	sbuf(pc),a1
		strcpy	a0,a1			copy dir name
		cmp.b	#'/',-2(a1)
		bne.s	1$
		clr.b	-2(a1)			remove '/'
1$		move.l	sbuf(pc),d1
		move.l	fib_Protection(a5),d2
		bset	#FIBB_ARCHIVE,d2	set A-flag, others unchanged
		lib	Dos,SetProtection	set flag: archived
		bra	WrMainNextDir

WrMain__e	move.l	d0,d1			Remember to UnLock() also if
		lib	Dos,UnLock		 an error occurred!
		bra	WrMain_e



WrMain_e1	print	<'*** Cannot Examine()',LF>
		bra.s	WrMain_e
WrMain_e2	print	<'*** This is a file!',LF>
		bra.s	WrMain_e
WrMain_e3	print	<'*** Cannot Lock()',LF>

WrMain_e	bsr	addstat			adds # of files, dirs and bytes
		move.l	bufmem(a4),d0
		beq.s	WrMain_ee1
		move.l	d0,a1
		move.l	#WRMEM,d0
		lib	Exec,FreeMem
WrMain_ee1	pull	a0-a3/a5/d0-d7
		.end
		setc
		rts


WrMain_x	bsr	addstat
		move.l	bufmem(a4),d0
		beq.s	WrMain_x1
		move.l	d0,a1
		move.l	#WRMEM,d0
		lib	Exec,FreeMem
WrMain_x1	pull	a0-a3/a5/d0-d7
		.end
		clrc
		rts



*************************************************************************
*									*
* This routine copies a given file onto disk.				*
*									*
*************************************************************************

PushAway	push	all
		move.l	a0,a5			fib*
		move.l	a1,a3			path/name*
		moveq.l	#0,d7
		move.l	trackpoi(pc),a4
		lea	TYPE_FILE(pc),a0	data type: FILE
		bsr	ostr
		bcs	PushAw_e

		lea	fib_FileName(a5),a0	write name
		bsr	ostr
		bcs	PushAw_e

		move.l	fib_Size(a5),d0		size of file
		move.l	d0,d6
		bsr	olong			output it
		bcs	PushAw_e

		move.l	fib_Protection(a5),d0	protection of file
		bsr	olong			output it
		bcs	PushAw_e

		move.l	fib_DateStamp(a5),d0	creation date of file
		bsr	olong			output it
		bcs	PushAw_e
		move.l	fib_DateStamp+4(a5),d0	creation date of file
		bsr	olong			output it
		bcs	PushAw_e
		move.l	fib_DateStamp+8(a5),d0	creation date of file
		bsr	olong			output it
		bcs	PushAw_e

		move.w	verbose(pc),d0
		beq.s	PushVe1
		print	<'Copying "'>
		printa	a3

PushVe1		move.l	a3,d1
		move.l	#MODE_OLDFILE,d2
		lib	Dos,Open
		move.l	d0,d7			file handle
		beq	PushAw_e1		not found

		move.w	verbose(pc),d0
		beq.s	PushAw1
		print	<'"',LF>

PushAw1		bsr	ck_stop
		bne	PushAw_e
		move.l	d7,d1			file
		move.l	a4,d2			buffer
		move.l	trackend(pc),d3		length
		sub.l	d2,d3
		lib	Dos,Read
		tst.l	d0
		bls.s	PushAw2			end-of-file or error
		add.l	d0,a4
		sub.l	d0,d6			sub from total length
		cmp.l	trackend(pc),a4
		blo.s	PushAw3			track buffer not yet full
		bsr	WCyl
		bcc.s	PushAw1			next block of file
		bra	PushAw_e

PushAw2		bmi.s	PushAw_e2		read error
PushAw3		tst.l	d6
		bne.s	PushAw_e2		should be more bytes!
PushReco	lea	TYPE_EOF(pc),a0
		bsr	ostr			end of file!
		move.l	d7,d1
		lib	Dos,Close
		moveq.l	#0,d7

		move.w	arcflag(pc),d0		need to set A-flag?
		beq.s	PushNSet		no -> jump
		move.l	a3,d1
		move.l	fib_Protection(a5),d2
		bset	#FIBB_ARCHIVE,d2	set A-flag, others unchanged
		lib	Dos,SetProtection	set flag: archived

PushNSet	move.l	a4,trackpoi
		pull	all
		clrc
		rts

PushAw_e2	move.l	d7,d1		read error. must fill the spc with $ff's
		beq.s	PushAw_e21
		lib	Dos,Close
		moveq.l	#0,d7
PushAw_e21	print	<'*** Error reading file.  Press A ',60,'return',62,LF>
		print	<'    to abort or ',60,'return',62,' to continue. '>
		bsr	getret
		cmp.b	#'A',d0
		beq	PushAw_eq
		cmp.b	#'a',d0
		beq	PushAw_eq
		tst.l	d6
		beq	PushReco
PushDummy	moveq.l	#-1,d0			write dummy bytes
		bsr	ochr
		bcs	PushAw_e
		subq.l	#1,d6
		bne.s	PushDummy
		bra	PushReco

PushAw_e1	move.w	verbose(pc),d0
		beq.s	PushVe2
		print	<'" *** not found',LF>
		bra.s	PushAw_eq
PushVe2		print	<'*** Internal Error: File not Found',LF>
PushAw_eq	move.l	a4,trackpoi
PushAw_e	move.l	d7,d1
		beq.s	PushAw_ee
		lib	Dos,Close
		moveq.l	#0,d7
PushAw_ee	pull	all
		setc
		rts




*************************************************************************
*									*
* Miscellaneous subroutines.						*
*									*
*************************************************************************

PushPath	push	all			writes path onto disk
		move.l	trackpoi(pc),a4
		move.l	a1,a3			pathname*
		lea	TYPE_PATH(pc),a0
		bsr	ostr
		bcs.s	PushPa_e
		move.l	a3,a0
		bsr	ostr
		bcs.s	PushPa_e
		lea	TYPE_EOP(pc),a0
		bsr	ostr
		bcs.s	PushPa_e
		move.l	a4,trackpoi
		pull	all
		rts
PushPa_e	move.l	a4,trackpoi
		pull	all
		setc
		rts


PushEnd		push	all			writes endmark onto disk
		move.l	trackpoi(pc),a4
		lea	TYPE_END(pc),a0
		bsr	ostr
		bcs.s	PushEnd_e
		cmp.l	trackbuf(pc),a4
		beq.s	PushEnd_ok
		bsr	WCyl
		move.l	a4,trackpoi
PushEnd_ok	clrc
		pull	all
		rts
PushEnd_e	move.l	a4,trackpoi
		pull	all
		setc
		rts



CreDir		push	all		creates a directory if needed
		move.l	pbuf(pc),a0
		move.l	sbuf(pc),a1
		strcpy	a0,a1		copy of new path		
		cmp.b	#'/',-2(a1)
		bne.s	CreDir1
		clr.b	-2(a1)
CreDir1		move.l	sbuf(pc),d1
		moveq.l	#ACCESS_READ,d2
		lib	Dos,Lock
		move.l	d0,d7		lock*
		bne.s	CreDir2		it already exists!

		move.l	sbuf(pc),d1
		lib	Dos,CreateDir
		move.l	d0,d7
		beq.s	CreDir_e

		move.w	verbose(pc),d0
		beq.s	CreDir2
		print	<'# Directory created...',LF>

CreDir2		move.l	d7,d1
		beq.s	CreDir3
		lib	Dos,UnLock
CreDir3		pull	all
		rts
CreDir_e	print	<'*** Cannot create directory "'>
		printa	sbuf(pc)
		print	<'"',LF>
		bra	CreDir3



ostr		move.b	(a0)+,d0
		bsr.s	ochr
		bcs.s	ostr_e
		bne.s	ostr
ostr_e		rts


ochr		push	a0-a1/d0-d1
		move.b	d0,(a4)+
		cmp.l	trackend(pc),a4
		blo.s	ochr_ok
		bsr.s	WCyl
		bcs.s	ochr_e
ochr_ok		pull	a0-a1/d0-d1
		tst.b	d0
		clrc
		rts
ochr_e		pull	a0-a1/d0-d1
		tst.b	d0
		setc
		rts


olong		push	d0-d1
		move.l	d0,d1
		rol.l	#8,d1
		move.b	d1,d0
		bsr.s	ochr		MSB
		bcs.s	olong_e
		rol.l	#8,d1
		move.b	d1,d0
		bsr.s	ochr		2. MSB
		bcs.s	olong_e
		rol.l	#8,d1
		move.b	d1,d0
		bsr.s	ochr		3. MSB
		bcs.s	olong_e
		rol.l	#8,d1
		move.b	d1,d0
		bsr.s	ochr		LSB
olong_e		pull	d0-d1
		rts



WCyl		push	a0-a1/d0-d1
		move.l	trackbuf(pc),a0
		lea	cyl(pc),a1
		move.l	a0,a4
		moveq.l	#0,d0
		move.w	(a1),d0
		bsr	WriteCyl
		bcs.s	WCyl_e
		addq.w	#1,(a1)
		cmp.w	#MAXUCYL,(a1)
		blo.s	WCyl_ok
		clr.w	(a1)
		bsr	AskNextDisk
		print	<'### Thanks... continuing',LF,LF>
		bsr	WID		write ID
		bcs.s	WCyl_e
WCyl_ok		clrc
		pull	a0-a1/d0-d1
		rts
WCyl_e		pull	a0-a1/d0-d1
		setc
		rts


RCyl		push	a0-a1/d0-d1
		lea	cyl(pc),a1
		cmp.w	#MAXUCYL,(a1)
		blo.s	RCyl_1
		clr.w	(a1)
		bsr.s	AskNextDisk
		move.l	trackbuf(pc),a4
		moveq.l	#0,d0
		move.w	dsk(pc),d0
		bsr	ck_dsk
		bcs.s	RCyl_e
		print	<'### Thanks... continuing',LF,LF>
		bra.s	RCyl_ok
RCyl_1		move.l	trackbuf(pc),a0
		move.l	a0,a4
		moveq.l	#0,d0
		move.w	(a1),d0
		bsr	ReadCyl
		bcs.s	RCyl_e
		addq.w	#1,(a1)
RCyl_ok		clrc
		pull	a0-a1/d0-d1
		rts
RCyl_e		pull	a0-a1/d0-d1
		setc
		rts



AskNextDisk	push	all
		bsr	MotorOff
		addq.w	#1,dsk
		print	<LF,'### Please insert backup disk #'>
		moveq.l	#0,d0
		move.w	dsk(pc),d0
		bsr	print10
		print	<' into drive DF'>
		move.l	unit(pc),d0
		bsr	print10
		print	<': and hit RETURN:'>
		bsr	getret
		bsr	MotorOn
		pull	all
		rts



ck_dsk		push	a0/a1/d0-d7
		move.l	d0,d7			dsk number
ck_dsk0		moveq.l	#0,d0
		move.l	trackbuf(pc),a0
		move.l	a0,a4
		bsr	ReadCyl
		bcs	ck_dsk_e
		move.l	sbuf(pc),a0
		move.l	#TEMPSTR-2,d1
		bsr	istr
		move.l	sbuf(pc),a0
		lea	DSKID(pc),a1
		strcmp	a0,a1
		beq.s	ck_dsk1			id ok.
		bsr	MotorOff
		print	<'*** Disk id mismatch - not a backup disk',LF>
		bra	ck_dsk_q

ck_dsk1		bsr	ilong			disk#
		cmp.l	d0,d7
		beq.s	ck_dsk2
		bsr	MotorOff
		print	<'*** Wrong backup disk number',LF>
		bra.s	ck_dsk_q

ck_dsk2		lea	ctime(pc),a0		addr of DateStamp
		tst.l	(a0)
		bpl.s	ck_dsk3			-> check if same date/time
		bsr	ck_dsk9
		bcs.s	ck_dsk_e
		move.l	d1,(a0)+		read DateStamp from first disk
		move.l	d2,(a0)+
		move.l	d3,(a0)+
		bra.s	ck_dsk_ok

ck_dsk3		bsr	ck_dsk9			compare DateStamps
		cmp.l	(a0)+,d1
		bne.s	ck_dsk_ed
		cmp.l	(a0)+,d2
		bne.s	ck_dsk_ed
		cmp.l	(a0)+,d3
		bne.s	ck_dsk_ed

ck_dsk_ok	move.w	#1,cyl
		clrc
		pull	a0/a1/d0-d7
		rts

ck_dsk_ed	bsr	MotorOff
		print	<'*** Wrong date of backup on disk',LF>

ck_dsk_q	bsr	retry
		bne.s	ck_dsk_e
		bsr	MotorOn
		bra	ck_dsk0

ck_dsk_e	move.w	#1,cyl			error: this disk won't do!
		setc
		pull	a0/a1/d0-d7
		rts

ck_dsk9		bsr	ilong		read date when backup was created
		bcs.s	ck_dsk9e
		move.l	d0,d1
		bsr	ilong
		bcs.s	ck_dsk9e
		move.l	d0,d2
		bsr	ilong
		bcs.s	ck_dsk9e
		move.l	d0,d3
ck_dsk9e	rts





WID		push	a0/a1/d0-d7
		move.l	trackbuf(pc),a4
		lea	DSKID(pc),a0		write disk id
		bsr	ostr
		bcs.s	WID_e
		moveq.l	#0,d0
		move.w	dsk(pc),d0		write disk number
		bsr	olong
		bcs.s	WID_e

		lea	ctime(pc),a0		write backup time
		move.l	(a0)+,d0
		bsr	olong
		bcs.s	WID_e
		move.l	(a0)+,d0
		bsr	olong
		bcs.s	WID_e
		move.l	(a0)+,d0
		bsr	olong
		bcs.s	WID_e

		move.l	a4,trackpoi
		pull	a0/a1/d0-d7
		rts
WID_e		pull	a0/a1/d0-d7
		rts


retry		print	<' - press R ',60,'return',62,' to retry: '>
		bsr.s	getret
		print	<LF>
		cmp.b	#'r',d0
		beq.s	retry_1
		cmp.b	#'R',d0
retry_1		rts


getret		push	a0/a1/d1-d3		waits for a RETURN
		lib	Dos,Input
		move.l	d0,d1
		lea	temp(pc),a0
		clr.l	(a0)
		move.l	a0,d2
		moveq.l	#4,d3
		lib	Dos,Read
		move.b	temp(pc),d0
		pull	a0/a1/d1-d3
		rts


ichr		push	a0-a1/d1		gets a char from TD to d0
		move.b	(a4)+,d0
		cmp.l	trackend(pc),a4
		blo.s	ichr_ok
		bsr	RCyl
		bcs.s	ichr_e
ichr_ok		pull	a0-a1/d1
		tst.b	d0
		clrc
		rts
ichr_e		pull	a0-a1/d1
		tst.b	d0
		setc
		rts


istr		bsr.s	ichr		input a string @a0, maxlen d1
		bcs.s	istr_e
		move.b	d0,(a0)+
		dbeq	d1,istr
		clrc
istr_e		rts


ilong		push	d1-d2/a0	input a long value into d0
		lea	temp(pc),a0
		bsr	ichr
		bcs.s	ilong_e
		move.b	d0,(a0)+	get MSB
		bsr	ichr
		bcs.s	ilong_e
		move.b	d0,(a0)+	2. MSB
		bsr	ichr
		bcs.s	ilong_e
		move.b	d0,(a0)+	3. MSB
		bsr	ichr
		bcs.s	ilong_e
		move.b	d0,(a0)+	LSB
		move.l	-4(a0),d0
		pull	d1-d2/a0
		clrc
		rts
ilong_e		pull	d1-d2/a0
		setc
		rts



addstat		add.l	d5,files		add information to statistics
		add.l	d6,dirs
		add.l	d7,bytes
		rts


PrintStat	print	<LF,LF,' Processing Status:',LF>
		print	<'====================',LF,LF,'# of files:       '>
		move.l	files(pc),d0
		bsr	print10

		print	<LF,'# of directories: '>
		move.l	dirs(pc),d0
		bsr	print10

		print	<LF,'# of bytes:       '>
		move.l	bytes(pc),d0
		bsr	print10

		move.l	retrycnt(pc),d0
		beq.s	PrintStat1
		print	<LF,'NOTE: Number of retries during write: '>
		bsr	print10
PrintStat1	print	<LF,LF>
		rts




StrCmp		moveq.l	#0,d0		compare strings at (a0) and (a1)
		moveq.l	#0,d1
StrCmp1		move.b	(a0)+,d0	cmp str(a0),str(a1)
		beq.s	eofs1
		move.b	(a1)+,d1
		beq.s	eofs2
		cmp.w	d0,d1
		beq.s	StrCmp1
StrEqu		rts
eofs1		tst.b	(a1)+
		beq.s	StrEqu
		moveq.l	#1,d0
		rts
eofs2		moveq.l	#-1,d0
		rts






ck_stop		push	d0-d1/a0-a1		checks if CTRL_C pressed
		moveq.l	#0,d0
		moveq.l	#0,d1
		lib	Exec,SetSignal
		btst	#SIGBREAKB_CTRL_C,d0
		beq.s	ck_nostop
		moveq.l	#0,d0
		moveq.l	#0,d1
		bset	#SIGBREAKB_CTRL_C,d1
		lib	Exec,SetSignal
		print	<'*** User break',LF>
		moveq.l	#1,d0			NE: STOP!!!
		pull	d0-d1/a0-a1
		rts
ck_nostop	moveq.l	#0,d0			EQ: no stop
		pull	d0-d1/a0-a1
		rts




print10		push	all
		lea	bcd_10(pc),a0
		numlib	put10
		lea	bcd_10(pc),a0
		printa	a0
		pull	all
		rts


*************************************************************************
*									*
* Command line parser written by TM.  New version.  Seems to work.	*
*									*
*************************************************************************

parse		push	all
		move.l	_CMDBuf(pc),a0
		cmp.b	#'?',(a0)
		beq	parseINFO
		cmp.b	#'!',(a0)
		beq	parseFURINFO
		strlib	skipblk
		tst.b	(a0)
		beq.s	parseMORPAR
		move.l	a0,a2
		strlib	getiwordu
		cmp.w	#'R',d0
		beq.s	parseR
		dcbne	#'RES',#'TORE',parse1
parseR		move.b	#'r',command
		bra	parse0
parseMORPAR	print	<'*** More parameters expected',10>
		bra.s	parserr
parseCMDEXP	print	<'*** COMMAND must be of R[ESTORE] B[ACKUP] C[HECK]',10>
parserr		setc
		pull	all
		rts
parse1		cmp.w	#'B',d0
		beq.s	parseW
		dcbne	#'BA',#'CKUP',parse2
parseW		move.b	#'w',command
		bra.s	parse_1
parse2		cmp.w	#'C',d0
		beq.s	parseC
		dcbne	#'C',#'HECK',parseCMDEXP
parseC		move.b	#'c',command
		bra.s	parse0
parse_1		strlib	skipblk
		tst.b	(a0)
		beq	parseMORPAR
		move.l	pbuf(pc),a1
		strlib	blkcpy
parse0		strlib	skipblk
		tst.b	(a0)
		beq	parseMORPAR
		move.b	(a0)+,d0
		strlib	ucase
		cmp.b	#'D',d0
		bne.s	parseUNITIL
		move.b	(a0)+,d0
		strlib	ucase
		cmp.b	#'F',d0
		bne.s	parseUNITIL
		move.b	(a0)+,d0
		cmp.b	#'0',d0
		blo.s	parseUNITIL
		cmp.b	#'3',d0
		bhi.s	parseUNITIL
		and.l	#15,d0
		move.l	d0,unit
		cmp.b	#':',(a0)+
		beq.s	parse3
parseUNITIL	print	<'*** UNIT must be of DF0: DF1: DF2: DF3:',10>
		bra	parserr
parse3		strlib	skipblk
		move.l	a0,a2
		tst.b	(a0)
		beq	parsend
		strlib	getiwordu
parse4		cmp.b	#'-',(a2)
		bne.s	parse5
		move.l	a2,a0
		addq.l	#1,a0
		move.b	(a0)+,d0
		strlib	ucase
		cmp.b	#'A',d0
		bne.s	parseo1
parseA		move.w	#1,allflag
		bra	parse3
parseo1		cmp.b	#'S',d0
		bne.s	parseo2
parseS		move.w	#1,arcflag
		bra	parse3
parseo2		cmp.b	#'V',d0
		bne.s	parseo3
parseV		move.w	#1,verbose
		bra	parse3
parseo3		print	<'*** OPTION must be of -A -S -V',10>
		bra	parserr
parse5		cmp.w	#'A',d0
		beq	parseA
		cmp.w	#'S',d0
		beq	parseS
		cmp.w	#'V',d0
		beq	parseV
		cmp.l	#'ALL',d0
		beq	parseA
		dcbne	#'SE',#'TARC',parse6
		bra	parseS
parse6		dcbne	#'VER',#'BOSE',parseSYNERR
		bra	parseV
parseSYNERR	print	<'*** Syntax error',10>
		bra	parserr
parseINFO	lea	USAGE(pc),a0
parseFINFO	printa	a0
		bra	parserr
parseFURINFO	lea	KNOWLEDGE(pc),a0
		bra	parseFINFO
parsend		pull	all
		clrc
		rts


*************************************************************************
*									*
* Some libraries by TM.							*
*									*
*************************************************************************

		strlib
		numlib



*************************************************************************
*									*
* Variables, strings, other storage					*
*									*
*************************************************************************

bcd_10		ds.l	4		buffers for bin -> ASCII conversion

_CMDLen		dc.l	0		The famous ones
_CMDBuf		dc.l	0
TDOflag		dc.l	1		error flag: trackdisk.device opened
msgport		dc.l	0		ptr to MsgPort struct
signalbit	dc.l	-1		signalbit number
ioreq		dc.l	0		ptr to IORequest

cyl		dc.w	0		current cyl#
dsk		dc.w	0		current disk#
files		dc.l	0		# of files
dirs		dc.l	0		# of directories
bytes		dc.l	0		# of bytes in files
retrycnt	dc.l	0		# of retries during WriteCyl()
trackbuf	dc.l	0		ptr to cylinder buffer
trackpoi	dc.l	0		pointer for track buffer
trackend	dc.l	0		end of trackbuf
verbuf		dc.l	0		ptr to verify buffer
temp		dc.l	0,0		temporary storage for long integers
sbuf		dc.l	0		pointer to string buffer used by RdMain()
pbuf		dc.l	0		pointer to pathname (used by RdMain)
nbuf		dc.l	0		pointer to filename (used by RdMain)
unit		dc.l	0		drive# for trackdisk.device
command		dc.w	0		command (r/w/c)
verbose		dc.w	0		flag: print verbose msgs
arcflag		dc.w	0		flag: 1 -> set archive flags
allflag		dc.w	0		flag: 1 -> backup all files
chkflag		dc.w	0		flag: -1 -> just check if backup is ok.
mydate		dc.l	0,0,0		DateStamp from backup
ctime		dc.l	-1,-1,-1	DateStamp when backup was made

TDname		TD_NAME			device name

TYPE_FILE	dc.b	'File',0
TYPE_EOF	dc.b	'EoF',0
TYPE_PATH	dc.b	'Path',0
TYPE_EOP	dc.b	'EoP',0
TYPE_END	dc.b	'EndOfBackup',0


KNOWLEDGE
	dc.b	'*** Hard Disk Backup ***',LF,LF
	dc.b	'© Supervisor Software 1988, 1989',LF
	dc.b	'Written by Jukka Marin 890312',LF
	dc.b	'Use Backup ? for help',LF,0

DSKID	dc.b	'HDBP  ',167,167,'  © Supervisor Software 1988  '
	dc.b	'Written by JM 8811xx',LF,LF,0

USAGE	dc.b	'Usage:  Backup B[ACKUP]  <srcpath> <drive> [-opt]',LF
	dc.b	'        Backup R[ESTORE] <drive> [-opt]',LF
	dc.b	'        Backup C[HECK]   <drive> [-opt]',LF,LF
	dc.b	'where',LF
	dc.b	' - BACKUP  copies files from hard disk to disk',LF
	dc.b	' - RESTORE copies files from disk back to hard disk',LF
	dc.b	' - CHECK   checks if the files on disks are ok.',LF
	dc.b	' - opt is any combination of:',LF
	dc.b	'   [-]A[LL]     causes all files to be copied from HD',LF
	dc.b	'                regardless of the archive-flag',LF
	dc.b	'                OR all files to be read from backup',LF
	dc.b	'                without checking if they already exist',LF
	dc.b	'   [-]S[ETARC]  causes the archive flag of files copied',LF
	dc.b	'                to be set',LF
	dc.b	'   [-]V[ERBOSE] causes verbose listing of files processed',LF,LF
	dc.b	'Note: When backuping a hard disk, all subdirectories of the',LF
	dc.b	'      given path will also be copied.',LF,0,0

		libnames		libraries & pointers

		end

