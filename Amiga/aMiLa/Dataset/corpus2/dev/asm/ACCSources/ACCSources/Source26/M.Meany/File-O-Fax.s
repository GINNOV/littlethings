
		******************************************
		* File-O-Fax utility for script file use *
		*		   by M.Meany, July 1992 *
		******************************************

* For v2.0 and above only!
* Maximum size of a data file is 65K since DBcc has been used.

		incdir		sys:include2.0/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		dos/dos_lib.i
		include		dos/dosextens.i
		include		dos/datetime.i

; Open DOS library

Start		move.b		#0,-1(a0,d0)	NULL terminate parameters
		move.l		d0,argc
		move.l		a0,argv		I like C!
		
		lea		dosname,a1	library name
		moveq.l		#37,d0		v2.0 only!!!
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save pointer
		beq		Error		exit if old version

; Check if user wants usage details

		move.l		argv,a0		a0->command tail
		cmp.b		#'?',(a0)	usage requested?
		bne.s		CheckDataFile	no, so skip this bit!
		
		move.l		#Usage,d1	addr of text
		CALLDOS		PutStr		print it
		bra		AllDone		and exit!

; Open magic file-o-fax file, should be in s: or current dir

CheckDataFile	move.l		#FileName,d1	->name
		move.l		#MODE_OLDFILE,d2 non-destructive open
		CALLDOS		Open		attempt to open file
		move.l		d0,Handle	save handle
		bne.s		GotHndl		continue if file opened!

; Could not open file in s: directory, try current directory

		move.l		#FileName1,d1	->name
		move.l		#MODE_OLDFILE,d2 still non-destructive
		CALLDOS		Open		attempt to open file
		move.l		d0,Handle	save handle
		bne.s		GotHndl		continue if file opened!

; Not in current dir either, inform user of error and exit:-(

		move.l		#Err1,d1	error message
		CALLDOS		PutStr		display it
		bra		AllDone		and exit

; Read FileInfoBlock to determine files size

GotHndl		move.l		d0,d1		handle
		move.l		#fibBuff,d2	file info buffer
		CALLDOS		ExamineFH	get FileInfoBlock
		lea		fibBuff,a0	a0->block
		move.l		fib_Size(a0),d4	d4=size of file in bytes

; Allocate a buffer to read file into

		move.l		d4,d0		size of required buffer
		move.l		#MEMF_CLEAR,d1	we need an empty buffer
		CALLEXEC	AllocMem	attempt to get some memory
		move.l		d0,FileBuff	save pointer
		bne.s		GotMem		continue if memory available

; No memory available so tell user, close the file and exit

		move.l		Handle,d1	files handle
		CALLDOS		Close		close it
		
		move.l		#Err2,d1	error message
		CALLDOS		PutStr		print it
		bra		AllDone		and exit.

; Read file into buffer allocated

GotMem		move.l		Handle,d1	files handle
		move.l		d0,d2		buffer
		move.l		d4,d3		buffer size
		CALLDOS		Read		read in the data

; Finished with file, so close it

		move.l		Handle,d1
		CALLDOS		Close		close data file

; Scan loaded data and convert line-feeds into NULL bytes. No DBcc on purpose

		move.l		FileBuff,a0	buffer
		move.l		d4,d0		buffer size
		moveq.l		#0,d1		NULL
		moveq.l		#$0a,d2		line feed

Loop		cmp.b		(a0)+,d2	is it a line feed?
		bne.s		NotLF		no, so skip it
		move.b		d1,-1(a0)	else replace it
NotLF		subq.l		#1,d0		dec counter
		bne.s		Loop		loop while non zero		

; If there was a CLI parameter, copy it to Today else get date stamp

		move.l		argv,a0		a0->cli tail
		tst.b		(a0)		any args?
		beq.s		GetDate		no, get todays date
		
		lea		Today,a1	a1->buffer
		moveq.l		#8,d0		length of date string
CopyParam	move.b		(a0)+,(a1)+	copy into buffer
		dbra		d0,CopyParam	
		bra.s		GotDate		and continue
		
GetDate		move.l		#Date,d1	DateStamp structure
		CALLDOS		DateStamp	get the date

; Convert to a string

		move.l		#Date,d1	DateTime structure
		CALLDOS		DateToStr	convert to English

; Now convert todays date into upper-case characters

GotDate		lea		Today,a0	the string
		bsr		ToUpper		conversion routine

; Now find entries in data buffer that match todays date

		move.l		FileBuff,a1	buffer
		move.l		d4,d1		it's size

SrchLoop	lea		Today,a0	search string
		moveq.l		#9,d0		it's length ( dd-mmm-yy )

		bsr		Search		check it out
		tst.l		d0		match found?
		beq.s		NearlyThere	no, so exit!

; Found an appointment, display it!

		move.l		d0,-(sp)	save these as we need them
		move.l		d1,-(sp)
		
		move.l		d0,d1		address of reminder
		CALLDOS		PutStr		print it
		
		move.l		#Lf,d1		line feed
		CALLDOS		PutStr		print it
		
		move.l		(sp)+,d1	length
		move.l		(sp)+,a1	address
		addq.l		#1,a1
		subq.l		#1,d1
		bra.s		SrchLoop	and loop back for more
		
; Free allocated buffer

NearlyThere	lea		fibBuff,a0	a0->file info block
		move.l		fib_Size(a0),d0	size of buffer
		move.l		FileBuff,a1	addr of buffer
		CALLEXEC	FreeMem		and release it

; Close DOS

AllDone		move.l		_DOSBase,a1	lib base pointer
		CALLEXEC	CloseLibrary	and close the library

; All done so return

		moveq.l		#0,d0		no script errors
Error		rts

		*************************************
		* Convert text string to upper case *
		*************************************

* Entry		a0->start of null terminated text string

* Exit		a0->end of text string ( the zero byte ).

* Corrupted	a0

* Author	M.Meany

ToUpper		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		rts

		******************************************
		* Case Insensetive string search routine *
		*		   by M.Meany, ???? 1991 *
		******************************************

; Entry		a0 addr of string to search for --- preconverted to UCASE
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found
;		d1 bytes still to be searched if match is found. This makes
;		   coding 'Find Next' and 'Find Prev' much easier.

; Corrupted	d0,d1

Search		movem.l		d2/a0-a2,-(sp)	save values
		move.l		#0,_MatchFlag	clear flag, assume failure
		sub.l		d0,d1		set up counter
		subq.l		#1,d1		correct for dbra
		bmi.s		.FindError	quit if block < string

		move.b		(a0),d2		d2=1st char to match
		move.b		d2,d3		make a copy
		add.b		#'a'-'A',d3	in lowercase
.Floop		cmp.b		(a1)+,d2	match 1st char of string ?
		beq.s		.Floopend
		cmp.b		-1(a1),d3	with upper or lower
.Floopend	dbeq		d1,.Floop	no+not end, loop back

		bne.s		.FindError	if no match+end then quit

		bsr.s		.CompStr	else check rest of string

		beq.s		.Floop		loop back if no match

.FindError	movem.l		(sp)+,d2/a0-a2  retrieve values
		move.l		_MatchFlag,d0	set d0 for return
		rts

.CompStr	movem.l		d0-d1/a0-a2,-(sp)

		subq.l		#1,d0		correct for dbra
		move.l		a1,a2		save a copy
		subq.l		#1,a1		correct as it was bumped
.FFloop		move.b		(a1)+,d1
		cmp.b		#'a',d1
		blt.s		.fok
		cmp.b		#'z',d1
		bgt.s		.fok
		sub.b		#('a'-'A'),d1
.fok		cmp.b		(a0)+,d1	compare string elements
		dbne		d0,.FFloop	while not end + not match

		bne.s		.ComprDone	no match so quit
		subq.l		#1,a2		correct this addr
		move.l		a2,_MatchFlag	save addr of match

.ComprDone	movem.l		(sp)+,d0-d1/a0-a2
		tst.l		_MatchFlag	set Z flag as required
		rts

		*************************************************
		* Text strings & variables used by this utility *
		*************************************************

dosname		DOSNAME

Usage		dc.b		'File-O-Faxer © M.Meany, 1992.',$0a
		dc.b		'Will check an appointment file S:Fax to'
		dc.b		' see what you should be doing today!',$0a
		dc.b		'Usage: File-O-Faxer <date>'
Lf		dc.b		$0a,0
		even

FileName	dc.b		's:fax',0
		even
FileName1	dc.b		'fax',0
		even

Err1		dc.b		$0a,"File-O-Faxer "
		dc.b		"Could not locate data file 'Fax'.",$0a
		dc.b		"This should be in the current directory"
		dc.b		" or s:.",$0a
		dc.b		0
		even

Err2		dc.b		$0a,"File-O-Faxer low memory warning.",$0a
		dc.b		"Aborting !",$0a
		dc.b		0
		even

		dc.b		'$VER: File-O-Faxer v1.00'
		even

Date		ds.b		12		integral DateStamp structure
		dc.b		FORMAT_DOS	string type
		dc.b		0		no substitution!
		dc.l		Day		->day name string
		dc.l		Today		->the date string
		dc.l		Time		->time string

		*********************************
		* Data storage area for utility *
		*********************************

		section		dat,BSS

fibBuff		ds.b		fib_SIZEOF	long word alligned!

_DOSBase	ds.l		1		library base

argv		ds.l		1		cli parameter vector
argc		ds.l		1		and byte count

Handle		ds.l		1		file handle

FileBuff	ds.l		1		pointer to memory block

_MatchFlag	ds.l		1		used by search routine

Day		ds.b		20		loads of room for day

Today		ds.b		20		loads of room for date

Time		ds.b		20		loads of room for time
