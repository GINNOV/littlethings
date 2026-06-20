
		******************************************
		* File-O-Fax utility for script file use *
		*		   by M.Meany, Sept 1992 *
		******************************************

* Any version Amiga :-)
* Maximum size of a data file is 65K since DBcc has been used.

		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i

; Open DOS library

Start		move.b		#0,-1(a0,d0)	NULL terminate parameters
		move.l		d0,argc
		move.l		a0,argv		I like C!
		
		lea		dosname,a1	library name
		moveq.l		#37,d0		v2.0 only!!!
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_DOSBase	save pointer
		beq		Error		exit if old version

; Now get handle of CLI con: for text printing

		CALLDOS		Output		get CLI handle
		move.l		d0,std_out	save it

; Check if user wants usage details

		move.l		argv,a0		a0->command tail
		cmp.b		#'?',(a0)	usage requested?
		bne.s		CheckDataFile	no, so skip this bit!
		
		lea		Usage,a0	addr of text
		bsr		DosMsg		print it
		bra		AllDone		and exit!

; Open magic file-o-fax file, should be in s: or current dir

CheckDataFile	move.l		#FileName,d1	->name
		move.l		d1,Name		save this pointer
		move.l		#MODE_OLDFILE,d2 non-destructive open
		CALLDOS		Open		attempt to open file
		move.l		d0,Handle	save handle
		bne.s		GotHndl		continue if file opened!

; Could not open file in s: directory, try current directory

		move.l		#FileName1,d1	->name
		move.l		d1,Name		save this pointer
		move.l		#MODE_OLDFILE,d2 still non-destructive
		CALLDOS		Open		attempt to open file
		move.l		d0,Handle	save handle
		bne.s		GotHndl		continue if file opened!

; Not in current dir either, inform user of error and exit:-(

		lea		Err1,a0		error message
		bsr		DosMsg		print it
		bra		AllDone		and exit

; Read FileInfoBlock to determine files size

GotHndl		bsr		GetFib		read FileInfoBlock
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
		
		lea		Err2,a0		error message
		bsr		DosMsg		print it
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
		moveq.l		#10,d0		length of date string
CopyParam	move.b		(a0)+,(a1)+	copy into buffer
		dbra		d0,CopyParam	
		bra.s		GotDate		and continue
		
GetDate		move.l		#Date,d1	DateStamp structure
		CALLDOS		DateStamp	get the date

; Convert to a string

		lea		Date,a0		DateStamp structure
		lea		Today,a1	buffer for string
		bsr		TheDate		convert to English

; Now convert todays date into upper-case characters

GotDate		lea		Today,a0	the string
		bsr		ToUpper		conversion routine

; Now find entries in data buffer that match todays date

		move.l		FileBuff,a1	buffer
		move.l		d4,d1		it's size

SrchLoop	lea		Today,a0	search string
		moveq.l		#11,d0		it's length ( dd-mmm-yy )

		bsr		Search		check it out
		tst.l		d0		match found?
		beq.s		NearlyThere	no, so exit!

; Found an appointment, display it!

		move.l		d0,-(sp)	save these as we need them
		move.l		d1,-(sp)
		
		move.l		d0,a0		address of reminder
		bsr		DosMsg		print it
		
		lea		Lf,a0		line feed
		bsr		DosMsg		print it
		
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
		* Print a NULL terminated message in CLI window *
		*************************************************

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		tst.l		std_out		test for open console
		beq		.error		quit if not one

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		std_out,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts

		*************************************************
		* 		Read FileInfoBlock		*
		*************************************************

GetFib		move.l		Name,d1		filename
		moveq.l		#ACCESS_READ,d2	access mode
		CALLDOS		Lock		lock the file
		move.l		d0,d7		save lock
		beq.s		.done		exit on failure

		move.l		d0,d1		lock
		move.l		#fibBuff,d2	buffer for FileInfoBlock
		CALLDOS		Examine		fill buffer
		
		move.l		d7,d1		get lock
		CALLDOS		UnLock		and release file

.done		rts


		*****************************************
		*    Routine to convert DateStamp()	*
		*  into useable values. M.Meany, 1992.	*
		*****************************************

; This routine will convert the day count returned by DateStamp() into the
;date proper so it can be used! MM.

; Entry		a0->DateStamp structure (initialised by a call to DateStamp())
;		a1->buffer for date string ( at least 12 bytes )

; Exit		buffer will be filled with date string in form dd-mmm-yyyy,
;		string will be NULL terminated.

; Corrupt	None

TheDate		movem.l		d0-d4/a0-a4/a6,-(sp)

; We want todays date, but today has not elapsed yet! Bump day count to
;accomodate this.

		move.l		(a0),d0			get days since 1:1:78
		addq.l		#1,d0			bump days

; To calculate the year, continualy subtract the days in a year from the
;days elapsed since 01-Jan-78. If there are less days left than there are in
;a year, the year has been found. Leap years must be accounted for.

		move.l		#1978,d1		set year

.YearLoop	cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days
		
		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		cmp.l		#366,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#366,d0			dec days

		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		bra.s		.YearLoop

; When we get here, d7 will hold the correct year and d0 the number of days
;into the year ... getting closer:

.GotYear	move.w		d1,-(sp)		year onto stack

		lea		DaysInMonth(pc),a0	a0->days array
		move.w		#28,10(a0)		default not leap
		
		divu		#4,d1			year / 4
		swap		d1			get remainder
		tst.w		d1			is leap year?
		bne.s		.MonthLoop		no so skip
		move.w		#29,10(a0)		else feb=29 days

; When we get here, the DaysInMonth will have been set to account for leap
;years which have 29 days in february as opposed to 28 days in a normal year.


.MonthLoop	move.l		a0,d2			addr of month name
		addq.l		#4,a0			bump
		move.w		(a0)+,d1		get days in month

		cmp.w		d1,d0			found month yet?
		ble.s		.GotMonth		yes, exit loop!
		
		sub.w		d1,d0			no, dec days
		bra.s		.MonthLoop		and loop
		
.GotMonth	move.l		d2,-(sp)		addr onto stack
		move.w		d0,-(sp)		days onto stack

		lea		DS_template(pc),a0	C format string
		move.l		a1,a3			output buffer
		move.l		sp,a1			data stream
		lea		.PutC(pc),a2		subroutine
		CALLEXEC	RawDoFmt		build date

		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d0-d4/a0-a4/a6
		rts

; Subroutine called by RawDoFmt()

.PutC		move.b		d0,(a3)+		copy char
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

		dc.b		'$VER: File-O-Faxer v1.01'
		even


DaysInMonth	dc.b		'j','a','n',0
		dc.w		31
		dc.b		'f','e','b',0
		dc.w		28
		dc.b		'm','a','r',0
		dc.w		31
		dc.b		'a','p','r',0
		dc.w		30
		dc.b		'm','a','y',0
		dc.w		31
		dc.b		'j','u','n',0
		dc.w		30
		dc.b		'j','u','l',0
		dc.w		31
		dc.b		'a','u','g',0
		dc.w		31
		dc.b		's','e','p',0
		dc.w		30
		dc.b		'o','c','t',0
		dc.w		31
		dc.b		'n','o','v',0
		dc.w		30
		dc.b		'd','e','c',0
		dc.w		31

DS_template	dc.b		'%02d-%s-%04d',0
		even

		*********************************
		* Data storage area for utility *
		*********************************

		section		dat,BSS

fibBuff		ds.b		fib_SIZEOF	long word alligned!

_DOSBase	ds.l		1		library base

std_out		ds.l		1		CLI output parameter

argv		ds.l		1		cli parameter vector
argc		ds.l		1		and byte count

Name		ds.l		1		pointer to script filename

Handle		ds.l		1		file handle

FileBuff	ds.l		1		pointer to memory block

_MatchFlag	ds.l		1		used by search routine

Date		ds.b		12		integral DateStamp structure

Today		ds.b		20		loads of room for date
