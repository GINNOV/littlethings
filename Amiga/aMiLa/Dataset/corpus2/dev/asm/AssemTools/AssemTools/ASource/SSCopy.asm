;
; ### SSCopy v 1.11 ###
;
; - Created 880825 by JM -
;
;
; Copyright © 1988 by Supervisor Software
;
;
; With this program several files can be written onto disk track-by-track.
; Using RD mode the files can be read back to create a RAM-disk, for example.
;
; Syntax:
;
; SSCopy WR a: TO dfX: [-v]	copies all files in a: to dfX: using SSFormat
; SSCopy WR a  TO dfX: [-v]	copies all files specified in text file a
;				to dfX: using SSFormat
; SSCopy RD dfX: TO a: [-v]	copies all files from dfX: to a:
; SSCopy RD dfX: [-v]		copies all files from dfX: to current
;				directory, or, when 'WR a' was used, to
;				their original directories.
;				Option -v causes all copied filenames to be
;				output to stdout.
;
;
; Bugs: Command file MAY NEVER CONTAIN SPACES after file names.
;
;
; Edited:
;
; - 880826 by JM -> v0.05	- Create&Delete IO&Port written
;				- Finally works (well, reads cyls)
; - 880828 by JM -> v0.10	- Directory reading, file reading
; - 880828 by JM -> v0.15	- Copy to archive seems to work...
; - 880828 by JM -> v0.20	- Copy from archive written...
; - 880828 by JM -> v0.25	- Copy from archive seems to work...
;				- IDentifier string added
; - 880828 by JM -> v0.27	- Started working with cmdline params...
; - 880829 by JM -> v0.28	- Work continued...
; - 880829 by JM -> v0.29	- Work completed.  Operation seems to be
;				  quite reliable, but sometimes things
;				  don't work so well.  Maybe when file ends
;				  at cylinder boundary?
; - 880829 by JM -> v0.30	- By supplying a cmd file the user can
;				  select the files from different directories
;				  to be copied.  Subdirectories will not be
;				  processed, however.
;				- In rd mode destination directory no longer
;				  essential.  If not supplied, will use the
;				  current directory.
; - 880829 by JM -> v1.00	- Finally a working version.  Not fully tested
;				  but it seems to work.
;				- Some cleanup, Usage() improved (?).
; - 881123 by JM -> v1.10	- CMD_UPDATE added to WriteCyl() to ensure
;				  that all bytes are written on disk.
;				  That seemed to help in Backup.asm.
; - 890311 by JM -> v1.11	- Branches converted to short using Crunchy.
;
;


CYL_SIZE	equ	512*11*2		bytes per cylinder
TRACKBUF	equ	CYL_SIZE+1000		bytes for buffer

LF		equ	10
CR		equ	13

		include	"dos.xref"
		include	"exec.xref"
		include "JMPLibs.i"

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



Start		push	d2-d7/a2-a6		save regs
		move.l	d0,_CMDLen		len of cmd line
		move.l	a0,_CMDBuf		start addr of cmd line
		clr.b	-1(a0,d0.l)		add null
		openlib Dos,cleanup		open Dos library

		print	<'SSCopy v1.11 © JM 1988',LF>

		bsr	CreatePort
		bcs	cleanup
		ifd	DEBUG
		print	<'port created',10>
		endc

		bsr	CreateIO
		bcs	cleanup
		ifd	DEBUG
		print	<'ioreq created',10>
		endc

		bsr	Allocmem
		bcs	cleanup
		ifd	DEBUG
		print	<'mem reserved',10>
		endc

		bsr	ck_cmd			parse commands

		lea	TDname(pc),a0		device name
		move.l	unit(pc),d0		unit number
		move.l	ioreq(pc),a1		*IORequest
		moveq.l	#0,d1			flags (normally zero)
		lib	Exec,OpenDevice
		move.l	d0,TDOflag		flag: error opening TD.device
		beq.s	TDopened
		print	<'Can''t open trackdisk.device',LF>
		bra.s	cleanup

TDopened	bsr	OpenLock
		bcs.s	cleanup

		move.l	command(pc),d0
		beq.s	cleanup
		cmp.l	#'RD',d0
		beq.s	cmd_read
		cmp.l	#'WR',d0
		beq.s	cmd_write
		bra.s	cleanup

cmd_read	bsr	ReadFiles
		bra.s	done

cmd_write	bsr	WriteFiles

done		bsr.s	MotorOff

cleanup		move.l	TDOflag(pc),d0
		bne.s	clean01
		move.l	ioreq(pc),a1
		lib	Exec,CloseDevice

clean01		bsr	DeleteIO
		bsr	DeletePort
		bsr	CloseLock
		bsr	Freemem

clean99		closlib	Dos

		pull	d2-d7/a2-a6
		rts


*
* Subroutines:
*

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
		move.l	#TRACKBUF,d0
		move.l	#MEMF_CHIP,d1
		lib	Exec,AllocMem
		move.l	d0,trackbuf
		beq.s	Allocmem_e
		add.l	#CYL_SIZE+128,d0
		move.l	d0,strbuf
		move.l	d0,strbufm
		add.l	#256,d0
		move.l	d0,subbuf

		move.l	#fib_SIZEOF,d0
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,fileinfo
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
Freemem1	move.l	fileinfo(pc),d0
		beq.s	Freemem2
		move.l	d0,a1
		move.l	#fib_SIZEOF,d0
		lib	Exec,FreeMem
Freemem2	move.l	filebuf(pc),d0
		beq.s	Freemem3
		move.l	d0,a1
		move.l	FILEBUF(pc),d0
		lib	Exec,FreeMem
Freemem3	

		pull	all
		rts



ReadCyl		push	all			cyl=d0, buffer=a0
		move.l	ioreq(pc),a1
		cmp.l	#80,d0
		bhs	WriteCyl_e1
		mulu.w	#44,d0			multiply by 512*11*2
		asl.l	#8,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	#CYL_SIZE,IO_LENGTH(a1)	length = 1 cyl
		move.l	a0,IO_DATA(a1)
		move.w	#CMD_READ,IO_COMMAND(a1)
		lib	Exec,DoIO
		tst.l	d0
		beq.s	ReadCyl_ok
		print	<'*** Trackdisk error '>
		clrc
		bsr	print10
		print	<LF>
		bra.s	ReadCyl_e
ReadCyl_ok	pull	all
		clrc
		rts

ReadCyl_e	pull	all
		setc
		rts



WriteCyl	push	all			cyl=d0, buffer=a0
		move.l	ioreq(pc),a1
		cmp.l	#80,d0
		bhs	WriteCyl_e1
		mulu.w	#44,d0			multiply by 512*11*2
		asl.l	#8,d0
		move.l	d0,IO_OFFSET(a1)
		move.l	#CYL_SIZE,IO_LENGTH(a1)	length = 1 cyl
		move.l	a0,IO_DATA(a1)
		move.w	#CMD_WRITE,IO_COMMAND(a1)
		move.l	a1,a2
		lib	Exec,DoIO
		tst.l	d0
		beq	WriteCyl_ok
		cmp.w	#TDERR_WriteProt,d0
		bne.s	WriteCyl.1
		print	<'*** Error: Disk write protected',LF>
		bra	WriteCyl_e
WriteCyl.1	print	<'*** Trackdisk error '>
		clrc
		bsr	print10
		print	<LF>
		bra.s	WriteCyl_e

WriteCyl_ok	move.l	a2,a1
		move.w	#CMD_UPDATE,IO_COMMAND(a1)	try to update
		lib	Exec,DoIO
		tst.l	d0
		bne.s	WriteCyl_e			could not update
		pull	all
		clrc
		rts

WriteCyl_e1	print	<'*** Illegal Track number',LF>

WriteCyl_e	pull	all
		setc
		rts


Write_wcyl	push	d0-d1/a0-a1
		move.l	trackbuf(pc),a0
		move.l	d7,d0
		bsr	WriteCyl
		bcs.s	Writewcyl_e
		addq.l	#1,d7
		move.l	trackbuf(pc),a4		start of buffer
		move.l	a4,a5
		add.l	#CYL_SIZE,a5		end of buffer
		clrc
Writewcyl_e	pull	d0-d1/a0-a1
		rts


Read_rcyl	push	d0-d1/a0-a1
		move.l	trackbuf(pc),a0
		move.l	d7,d0
		bsr	ReadCyl
		bcs.s	Readrcyl_e
		addq.l	#1,d7
		move.l	trackbuf(pc),a4		start of buffer
		move.l	a4,a5
		add.l	#CYL_SIZE,a5		end of buffer
		clrc
Readrcyl_e	pull	d0-d1/a0-a1
		rts



*
* Main file transfer routines:
*

WriteFiles	push	d1-d7/a0-a5
		moveq.l	#0,d7			track#
		move.l	trackbuf(pc),a4		start of buffer
		move.l	a4,a5
		add.l	#CYL_SIZE,a5		end of buffer

		lea	DiskID(pc),a0
		bsr	Strout			write disk ID

Write_next	bsr	OpenFile
		bcs	WriteFiles_e		exit if error
		bvs.s	WriteNoMore		exit if no more files
		move.l	d0,d6			file handle
Write_cont	bsr	ck_stop
		bne	WriteFiles_e
		move.l	d6,d1			file
		move.l	a4,d2			buffer
		move.l	a5,d3
		sub.l	a4,d3			length
		lib	Dos,Read
		add.l	d0,a4
		cmp.l	a5,a4			buffer full?
		bhs.s	Write_write		if it is, write it out!
		move.l	d6,d1
		lib	Dos,Close
		moveq.l	#0,d6
		bra	Write_next		process next file

WriteNoMore	print	<'All files copied.',LF>
		moveq.l	#0,d0
		bsr	Chrout
		bsr	Chrout
		bsr	Chrout
		bsr	Chrout			NULLs indicate: no more files!
		cmp.l	trackbuf(pc),a4		all done
		beq.s	WriteFiles_x
		bsr	Write_wcyl		write last cyl
		bcc.s	WriteFiles_x
		bra.s	WriteFiles_e

Write_write	bsr	Write_wcyl		write one cylinder
		bcc	Write_cont
		bra.s	WriteFiles_e

WriteFiles_x	move.l	d7,d0
		bsr	print10
		print	<' cylinders used.',LF>
		pull	d1-d7/a0-a5
		clrc
		rts

WriteFiles_e	move.l	d6,d1
		beq.s	WriteFiles_e1
		lib	Dos,Close
WriteFiles_e1	pull	d1-d7/a0-a5
		setc
		rts



ReadFiles	push	d1-d7/a0-a5
		moveq.l	#0,d7			cyl#
		bsr	Read_rcyl
		bcs	ReadFiles_e1
		bsr	ck_ID
		bcs	ReadFiles_e1		ID not correct
ReadFiles_lp	bsr	ck_stop
		bne	ReadFiles_e1
		move.l	strbufm(pc),a0		directory added before
		bsr	Strget			get file name
		bcs	ReadFiles_e2
		beq	ReadFiles_ok		all done!

		move.w	verbose(pc),d0
		beq.s	ReadFiles_v1
		print	<'Extracting '>
		printa	strbuf(pc)
		print	<'...',LF>

ReadFiles_v1	move.l	strbuf(pc),d1		name
		move.l	#MODE_NEWFILE,d2	mode
		lib	Dos,Open
		move.l	d0,d6			handle
		beq	ReadFiles_e3		could not open file
		moveq.l	#3,d1
		lea	bcd_10(pc),a0
ReadFiles_len	bsr	Chrget
		bcs	ReadFiles_e2
		move.b	d0,(a0)+
		dbf	d1,ReadFiles_len
		move.l	-4(a0),d5		file length
ReadFiles_cont	bsr	ck_stop
		bne	ReadFiles_e1		stopped
		move.l	a5,d0
		sub.l	a4,d0			d0 = bytes left in buffer
		cmp.l	d5,d0
		blo.s	ReadFiles_more		file longer than buffer
		move.l	d6,d1			file
		move.l	a4,d2			buffer
		move.l	d5,d3			bytes
		lib	Dos,Write
		cmp.l	d0,d3
		bne	ReadFiles_e4		write error

		add.l	d0,a4			add bytes written to bufptr

		move.l	d6,d1
		lib	Dos,Close
		moveq.l	#0,d6
		bra	ReadFiles_lp

ReadFiles_more	move.l	d6,d1			file
		move.l	a4,d2			buffer
		move.l	d0,d3			bytes
		lib	Dos,Write		write rest of buffer
		cmp.l	d0,d3
		bne	ReadFiles_e4		write error
		sub.l	d3,d5			subtract written bytes
		bsr	Read_rcyl		read next cylinder
		bcc	ReadFiles_cont		continue writing
		bra.s	ReadFiles_e1

ReadFiles_ok	move.w	verbose(pc),d0
		beq.s	ReadFiles_v2
		move.l	d7,d0
		bsr	print10
		print	<' cylinders used.',LF>
ReadFiles_v2	clrc
		pull	d1-d7/a0-a5
		rts

ReadFiles_e1	move.l	d6,d1
		beq.s	ReadFiles_e1a
		lib	Dos,Close
ReadFiles_e1a	setc
		pull	d1-d7/a0-a5
		rts

ReadFiles_e2	print	<'*** Can''t obtain file name/length',LF>
		bra	ReadFiles_e1
ReadFiles_e3	print	<'*** Can''t open file for writing',LF>
		bra	ReadFiles_e1
ReadFiles_e4	print	<'*** Error writing file',LF>
		bra	ReadFiles_e1


OpenFile	push	d1-d3/a0-a3
		move.l	filebuf(pc),d0
		bne	OpenCMD			files in command file!
OpenFile_dir	move.l	mylock(pc),d1
		move.l	fileinfo(pc),d2
		lib	Dos,ExNext
		tst.l	d0
		beq	OpenFile_ok
		move.l	d2,a2
		move.l	fib_DirEntryType(a2),d0
		bmi.s	OpenFile_ndir
		bsr	OpenFileSkipDir		print msg: skipping a dir
		bra	OpenFile_dir

OpenFile_ndir	move.l	fileinfo(pc),a2
		move.w	verbose(pc),d0
		beq.s	OpenFile_v1
		print	<'Copying '>
OpenFile_v1	lea	fib_FileName(a2),a0
		move.l	strbufm(pc),a1
OpenFile_name	move.b	(a0)+,(a1)+
		bne	OpenFile_name

		move.w	verbose(pc),d0
		beq.s	OpenFile_v2
		printa	strbuf(pc)
		print	<'...',LF>
OpenFile_v2	move.l	strbufm(pc),a0

* Return here from OpenCMD after Lock, Examine, Unlock

OpenFile_Op	bsr	Strout			write filename
		bcs.s	OpenFile_e1
		lea	fib_Size(a2),a2
		moveq.l	#3,d1
OpenFile_lp	move.b	(a2)+,d0		write length (4 bytes)
		bsr	Chrout
		bcs.s	OpenFile_e1
		dbf	d1,OpenFile_lp

		move.l	strbuf(pc),d1		path+name
		move.l	#MODE_OLDFILE,d2
		lib	Dos,Open
		move.l	d0,d2			handle
		beq.s	OpenFile_e2

		move.l	d2,d0			handle
		clrc
		clrv
OpenFile_x	pull	d1-d3/a0-a3
		rts

OpenFile_ok	setv				no more files
		clrc				no error, however
		bra	OpenFile_x

OpenFile_e1	print	<'*** Can''t output filename/length',LF>
		bra.s	OpenFile_e
OpenFile_e2	print	<'*** Can''t open file "'>
		printa	strbuf(pc)
		print	<'"',LF>
OpenFile_e	setc
		bra	OpenFile_x


OpenCMD		move.l	cmdpoi(pc),a0
		move.l	strbuf(pc),a1
OpenCMD_nxl	move.b	(a0)+,d0
		beq	OpenFile_ok		no more files!
		cmp.b	#LF,d0
		beq	OpenCMD_nxl		next line!
		cmp.b	#CR,d0
		beq	OpenCMD_nxl		next line!

OpenCMD_cpy	move.b	d0,(a1)+
		move.b	(a0)+,d0
		beq.s	OpenCMD_nok		name ok
		cmp.b	#LF,d0
		beq.s	OpenCMD_nok
		cmp.b	#CR,d0
		bne	OpenCMD_cpy		copy more...

OpenCMD_nok	clr.b	(a1)			add null
		move.l	a0,cmdpoi

OpenCMDLock	move.l	strbuf(pc),d1		path
		moveq.l	#ACCESS_READ,d2		mode
		lib	Dos,Lock
		move.l	d0,mylock
		beq	OpenFile_e2		Lock failed
		move.l	d0,d1
		move.l	fileinfo(pc),d2
		lib	Dos,Examine
		tst.l	d0
		beq	OpenFile_e2		Examine failed

		bsr	CloseLock		no longer needed, I hope

		move.l	d2,a2			fileinfoblock
		move.l	fib_DirEntryType(a2),d0	dir/file?
		bmi.s	OpenCMDnd		dir -> get next name!
		bsr.s	OpenFileSkipDir		print msg: skipping a dir
		bra	OpenCMD

OpenCMDnd	move.l	fileinfo(pc),a2
		move.w	verbose(pc),d0
		beq.s	OpenCMD_v1
		print	<'Copying '>
		printa	strbuf(pc)
		print	<'...',LF>

OpenCMD_v1	move.l	strbuf(pc),a0
		bra	OpenFile_Op

OpenFileSkipDir	push	a0
		move.w	verbose(pc),d0
		beq.s	OpenFileSkipDx
		print	<'Skipping directory "'>
		lea	fib_FileName(a2),a0
		printa	a0
		print	<'"',LF>

OpenFileSkipDx	pull	a0
		rts



OpenLock	move.l	strbuf(pc),d1		path
		moveq.l	#ACCESS_READ,d2		mode
		lib	Dos,Lock
		move.l	d0,mylock
		beq.s	OpenLock_e1
		move.l	d0,d1
		move.l	fileinfo(pc),d2
		lib	Dos,Examine
		tst.l	d0
		beq.s	OpenLock_e1

		move.l	d2,a2			fileinfoblock
		move.l	fib_DirEntryType(a2),d0	dir/file?
		bpl.s	OpenLock_dir

* Now: WR mode, source is not a dir but a FILE.
* We must read in the command file which contains files to be
* written onto §§ format.

		bsr.s	ReadCMD
		bcs.s	OpenLock_e
		bsr.s	CloseLock		it won't be needed any longer

OpenLock_dir	clrc
		rts

OpenLock_e1	print	<'*** Can''t open source',LF>
OpenLock_e	bsr.s	CloseLock
		setc
		rts

CloseLock	move.l	mylock(pc),d1
		beq.s	CloseLock_n
		lib	Dos,UnLock
		clr.l	mylock
CloseLock_n	rts



ReadCMD		push	all
		moveq.l	#0,d6
		move.l	fileinfo(pc),a2
		move.l	strbuf(pc),d1		name
		move.l	#MODE_OLDFILE,d2	mode
		lib	Dos,Open
		move.l	d0,d6			handle
		beq.s	ReadCMD_e1		can't open

		move.l	fib_Size(a2),d0		size
		addq.l	#8,d0
		move.l	d0,FILEBUF
		move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
		lib	Exec,AllocMem
		move.l	d0,filebuf
		beq.s	ReadCMD_e2		no mem
		move.l	d0,cmdpoi		'textpointer'

		move.l	d6,d1			file
		move.l	d0,d2			buffer
		move.l	fib_Size(a2),d3		length
		lib	Dos,Read
		cmp.l	d0,d3
		bne	ReadCMD_e3		can't read

		move.l	d6,d1
		lib	Dos,Close
		clrc
ReadCMD_x	pull	all
		rts

ReadCMD_e1	print	<'*** Can''t open command file',LF>
		bra	ReadCMD_e
ReadCMD_e2	print	<'*** Can''t allocate memory for command file',LF>
		bra.s	ReadCMD_e
ReadCMD_e3	print	<'*** Error reading command file',LF>
ReadCMD_e	move.l	d6,d1
		beq.s	ReadCMD_e_1
		lib	Dos,Close
ReadCMD_e_1	setc
		bra	ReadCMD_x



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


Chrout		push	d0-d3/a0-a3		writes a char into trackbuf
		cmp.l	a5,a4
		blo.s	Chrout1
		bsr	Write_wcyl
		bcs.s	Chrout2
Chrout1		move.b	d0,(a4)+
		clrc
Chrout2		pull	d0-d3/a0-a3
		rts

Strout		push	d0/a0		copy a string at (a0) into trackbuf
Strout1		move.b	(a0)+,d0
		bsr	Chrout
		bcs.s	Strout_e
		tst.b	d0
		bne	Strout1
		clrc
Strout_e	pull	d0/a0
		rts


Chrget		cmp.l	a5,a4		gets a single byte from trackbuf
		blo.s	Chrget1
		bsr	Read_rcyl
		bcs.s	Chrget_e
Chrget1		move.b	(a4)+,d0
		clrc
		rts
Chrget_e	rts


Strget		push	d0/a0-a1	gets a null-term. string from trackbuf
		move.l	a0,a1		 to (a0)
Strget_lp	bsr	Chrget
		bcs.s	Strget_e
		move.b	d0,(a0)+
		bne	Strget_lp
		tst.b	(a1)
		clrc
Strget_e	pull	d0/a0-a1
		rts


ck_ID		move.l	subbuf(pc),a0	read ID string from buffer
		bsr	Strget
		lea	DiskID(pc),a1	comparison
ck_ID1		move.b	(a0)+,d0
		beq.s	ck_ID2
		cmp.b	(a1)+,d0
		beq	ck_ID1		go on...
ck_ID3		print	<'*** Not a Fast Disk',LF>
		setc
		rts
ck_ID2		tst.b	(a1)
		bne	ck_ID3
		clrc			IDs equal
		rts



print10		push	all		if carry clear, leading zeroes blanked
		bcs.s	conv_10_0
		moveq.l	#' ',d2
		bra.s	conv_10_spc
conv_10_0	moveq.l	#'0',d2
conv_10_spc	lea	bcd_10+6(pc),a0
		lea	res_10+6(pc),a1
		moveq.l	#0,d1			clear result first
		move.l	d1,-6(a0)
		move.l	d1,-2(a0)
		move.l	d1,-6(a1)
		move.l	d1,-2(a1)
		move.b	#1,-1(a0)		seed value
conv_10_main	lsr.l	#1,d0
		bcc.s	conv_10_next
		move.l	a0,a2
		move.l	a1,a3
		clrx
		abcd	-(a2),-(a3)		add seed value to result
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		tst.l	d0
conv_10_next	beq.s	conv_10_asc
		move.l	a0,a2			multiply seed value by 2
		move.l	a0,a3
		clrx
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		abcd	-(a2),-(a3)
		bra	conv_10_main
conv_10_asc	lea	res_10(pc),a0		convert to ascii
		lea	buf_10(pc),a1
		move.l	a1,a5
		moveq.l	#5,d1
conv_10_al	move.b	(a0)+,d3
		move.b	d3,d0
		lsr.b	#4,d0
		beq.s	conv_10_al1
		moveq.l	#'0',d2
conv_10_al1	or.b	d2,d0
		move.b	d0,(a1)+
		and.b	#15,d3
		beq.s	conv_10_al2
		moveq.l	#'0',d2
conv_10_al2	or.b	d2,d3
		move.b	d3,(a1)+
		dbf	d1,conv_10_al
		or.b	#'0',d3
		move.b	d3,-1(a1)
		clr.b	(a1)
		printa	a5
		pull	all
		rts



ck_cmd		move.l	_CMDBuf(pc),a0
		bsr	getcmd
		move.l	d1,command
		cmp.l	#'RD',d1	READ option
		bne	ck_c1
		bsr	getcmd
		moveq.l	#0,d2
		cmp.l	#'DF0:',d1
		beq.s	RD_1
		addq.l	#1,d2		incr drive number
		cmp.l	#'DF1:',d1
		bne.s	RD_e1
RD_1		move.l	d2,unit
		move.l	a0,a1		backup
		bsr	getcmd
		cmp.l	#'TO',d1
		bne.s	RD_2		no destination given
		move.l	strbuf(pc),a1
		bsr	strcpy		copy dest. directory name
		bsr	ck_opt		check for options
		bra	ck_cmd_ok
RD_2		move.l	a1,a0		get old txtptr
		move.l	strbuf(pc),a1	reset path name
		move.l	a1,strbufm
		clr.b	(a1)		add null
		bsr	ck_opt		check options
		bra	ck_cmd_ok

RD_e1		print	<'*** Illegal source drive specifier',LF>
		bra	ck_cmd_e

ck_c1		cmp.l	#'WR',d1	WRITE option
		bne	ck_c2
		move.l	strbuf(pc),a1
		bsr	strcpy		get source dir
		bsr	getcmd
		cmp.l	#'TO',d1
		bne.s	ck_c2
		bsr	getcmd
		moveq.l	#0,d2
		cmp.l	#'DF0:',d1
		beq.s	WR_1
		addq.l	#1,d2
		cmp.l	#'DF1:',d1
		bne.s	WR_e1
WR_1		move.l	d2,unit
		bsr	ck_opt		check for options
		bra.s	ck_cmd_ok

WR_e1		print	<'*** Illegal destination drive specifier',LF>
		bra.s	ck_cmd_e

ck_c2		lea	USAGE(pc),a0
		printa	a0
ck_cmd_e	clr.l	command
ck_cmd_ok	rts


strcpy		move.b	(a0),d0		check if any name
		cmp.b	#' ',d0
		bne.s	strcpy_1
		addq.l	#1,a0
		bra	strcpy		skip spaces

strcpy_1	bls.s	strcpy1		no dir
strcpy0		move.b	(a0)+,d0	copy directory name
		cmp.b	#' ',d0
		bls.s	strcpy_x
		move.b	d0,(a1)+
		bra	strcpy0
strcpy_x	cmp.b	#':',-1(a1)
		beq.s	strcpy1
		cmp.b	#'/',-1(a1)
		beq.s	strcpy1
		move.b	#'/',(a1)+	add / if needed
strcpy1		move.l	a1,strbufm
		clr.b	(a1)		add null for Lock()
		rts


getcmd		bsr.s	getc		skip spaces & tabs
		cmp.b	#' ',d0
		beq	getcmd
		cmp.b	#9,d0
		beq	getcmd
		moveq.l	#0,d1		get & process options
		subq.l	#1,a0
		bsr.s	getc		1st char
		bls.s	get_cmd_c
		move.b	d0,d1
		bsr.s	getc		2nd char
		bls.s	get_cmd_c
		lsl.l	#8,d1
		move.b	d0,d1
		bsr.s	getc		3rd char
		bls.s	get_cmd_c
		lsl.l	#8,d1
		move.b	d0,d1
		bsr.s	getc		4th char
		bls.s	get_cmd_c
		lsl.l	#8,d1
		move.b	d0,d1
get_cmd_c	rts


getc		move.b	(a0)+,d0
		bne.s	getc2
		subq.l	#1,a0		don't eat nulls!
getc2		cmp.b	#'a',d0
		blo.s	getc1
		cmp.b	#'z',d0
		bhi.s	getc1
		sub.b	#' ',d0
getc1		cmp.b	#' ',d0
		rts


ck_opt		bsr	getc		check options
		beq	ck_opt
		tst.b	d0
		beq.s	ck_opt_ok	no more options
		cmp.b	#'-',d0
		bne.s	ck_opt_e1	options must start with a '-'
		bsr	getc
		cmp.b	#'V',d0		verbose?
		bne.s	ck_opt1
		move.w	#1,verbose
		bra	ck_opt
ck_opt1		

ck_opt_e1	print	<'*** Illegal option - options ignored',LF>
ck_opt_ok	rts




bcd_10		ds.l	2		buffers for bin -> ASCII conversion
res_10		ds.l	2
buf_10		ds.l	4

_CMDLen		dc.l	0		The famous ones
_CMDBuf		dc.l	0
TDOflag		dc.l	1		error flag: trackdisk.device opened
msgport		dc.l	0		ptr to MsgPort struct
signalbit	dc.l	-1		signalbit number
ioreq		dc.l	0		ptr to IORequest
trackbuf	dc.l	0		ptr to cylinder buffer
mylock		dc.l	0		ptr to lock
fileinfo	dc.l	0		ptr to fileinfo struct
strbuf		dc.l	0		bufferptr for filename buffer
strbufm		dc.l	0		bufferptr, directory name before this addr
subbuf		dc.l	0		another buffer for filenames
verbose		dc.w	0		flag: print verbose msgs
unit		dc.l	0		drive# for trackdisk.device
command		dc.l	0		command
wrmode		dc.w	0		flag: file list in a file
filebuf		dc.l	0		buffer for command file
FILEBUF		dc.l	0		size of prev. buffer
cmdpoi		dc.l	0		text pointer for CMDFile reading

TDname		TD_NAME			device name

DiskID		dc.b	167,167,'  © Supervisor Software 1988  '
		dc.b	'Written by Jukka Marin 198808xx',0
USAGE		dc.b	'Usage:  SSCopy RD|WR scr TO dest [-opt]',LF
		dc.b	' where',LF
		dc.b	' RD converts files from SSFormat back to normal',LF
		dc.b	' WR makes a SSFormat collection of files',LF
		dc.b	' src is the source path',LF
		dc.b	' dest is the destination path',LF
		dc.b	' -opt may be -v for verbose listing of files',LF,LF
		dc.b	'Examples:',LF
		dc.b	'SSCopy WR c: to df1:  copies all files in c: to df1:',LF
		dc.b	'SSCopy RD df1: to a:  copies all files in df1: to a:',LF
		dc.b	'Note: Subdirectories will not be copied.',LF,0,0

		libnames		libraries & pointers

		end

