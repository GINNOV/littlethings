
;RNDHandle structure

;rnd_Handle	rs.l		1
;rnd_Buffer	rs.l		1
;rnd_RecSize	rs.l		1
;rnd_Password	rs.l		1	Pointer to 8 bytes encryption code
;rnd_Fields	rs.l		1	field length table [NOT IMPLEMENTED]
;rnd_SIZE	rs.b		0

; RNDHandle = CreateRandom( filename, record size )
;    d0                        a0         d0

; RNDHandle = OpenRandom( filename, record size )
;    d0                      a0        d0

; CloseRandom( RNDHandle )
;		  a0

; error = LoadRecord( RNDHandle, record number )  (0 < record number < 65536)
;  d0                   a0           d0

; error = SaveRecord( RNDHandle, record number )
;  d0                   a0           d0

; RandPassword( RNDHandle, password )	[Password MUST be 8 bytes ]
;                  a0        a1

; RNDCrypt( RNDHandle )  **** Private ****
;              a0

; error = CountRecords( RNDHandle )	( error = -1 on failure )
;  d0			   a0

; error = WipeRecord( RNDHandle, record number )
;  d0                     a0         d0

; BOOL = ValidateRecord( RNDHandle, record number )
;  d0                       a0          d0

; BOOL = PurgeRecords( RNDHandle, filename )
;  d0                     a0         a1

; NextNum = SearchFRec( RNDHandle, Search Structure, record number )
;   d0                      a0           a1               d0

; NextNum = SearchBRec( RNDHandle, Search Structure, record number )
;   d0                      a0           a1               d0


*****************************************************************************
*			Random Access File Routines			    *
*****************************************************************************

; The following routines were developed to simplify the manipulation of
;Random Access Files. The structure shown below is used to control access
;to the file and you should familiarise yourself with it.

; To write a record to a file, all data must be copied into the files buffer,
;the address of which is located at rnd_Buffer in the handle structure.

; When loading a record, the data loaded will be found in the same buffer.

; Most routines have some level of error checking so test return values!

; M.Meany, 1993.

; Routines for handling random access files

		LIST
*** Random.i v1.00. © M.Meany, 1993 ***
		NOLIST

		rsreset
rnd_Handle	rs.l		1
rnd_Buffer	rs.l		1
rnd_RecSize	rs.l		1
rnd_Password	rs.l		1	Pointer to 8 bytes encryption code
;rnd_Fields	rs.l		1	pointer to field length table
rnd_SIZE	rs.b		0

CALLAGAIN	macro
		jsr		_LVO\1(a6)
		endm

*****************************************************************************
*			Create A Random Access File			    *
*****************************************************************************

; Entry		a0->filename
;		d0=record size

; Exit		d0=RNDHandle

; Corrupt	d0

CreateRandom	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			filename
		move.l		d0,d5			record size

; Create file

		move.l		a0,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,d1
		beq.s		.error
		CALLAGAIN	Close

; Open file as a Random Access file

		move.l		a5,a0			name
		move.l		d5,d0			record size
		bsr		OpenRandom		Open the file

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			Open a Random Access File			    *
*****************************************************************************

; Entry		a0->filename
;		d0=record size

; Exit		d0=Pointer to above declared Random Structure

; Corrupt	d0

OpenRandom	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a4
		move.l		d0,d4

; AllocMem for structure

		moveq.l		#rnd_SIZE,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l		d0
		beq.s		.Error
		move.l		d0,a5
		move.l		d4,rnd_RecSize(a5)
; AllocMem for a single record

		move.l		d4,d0
		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,rnd_Buffer(a5)
		beq.s		.Error1

; Open the file

		move.l		a4,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,(a5)
		beq.s		.Error2

; And exit

		move.l		a5,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

.Error2		move.l		rnd_Buffer(a5),a1
		move.l		rnd_RecSize(a5),d0
		CALLEXEC	FreeMem

.Error1		move.l		a5,a1
		moveq.l		#rnd_SIZE,d0
		CALLEXEC	FreeMem

.Error		moveq.l		#0,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			Close a Random Access File			    *
*****************************************************************************

; Entry		a0->handle

; Exit		none

; Corrupt	d0

CloseRandom	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5

; Close the file

		move.l		(a5),d1
		CALLDOS		Close

; Release record buffer

		move.l		rnd_Buffer(a5),a1
		move.l		rnd_RecSize(a5),d0
		CALLEXEC	FreeMem

; Release handle structure

		move.l		a5,a1
		moveq.l		#rnd_SIZE,d0
		CALLEXEC	FreeMem

; And exit

		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*		  Load A Record From A Random Access File		    *
*****************************************************************************
; Load a record from a file. Assumes you have supplied a valid record number

; Entry		a0->Handle
;		d0=record number ( 1 to 65535 )

; Exit		d0=0 if operation failed

; Corrupt	d0

LoadRecord	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle

; Locate the record

		move.l		(a5),d1
		subq.l		#1,d0
		move.l		rnd_RecSize(a5),d2
		mulu		d0,d2
		moveq.l		#OFFSET_BEGINNING,d3
		CALLDOS		Seek
		cmp.l		#-1,d0
		bne.s		.SeekOk
		moveq.l		#0,d0
		bra.s		.Error

; Load the record

.SeekOk		move.l		(a5),d1			handle
		move.l		rnd_Buffer(a5),d2	buffer
		move.l		rnd_RecSize(a5),d3	size
		CALLAGAIN	Read			read record
		cmp.l		rnd_RecSize(a5),d0	read ok?
		beq.s		.ReadOk
		moveq.l		#0,d0			no, signal an error
		bra.s		.Error

; Decrypt data if necessary

.ReadOk		move.l		a5,a0			handle
		bsr		RNDCrypt		decrypt

; And exit

		moveq.l		#1,d0			no errors

.Error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*		   Save A Record To A Random Access File		    *
*****************************************************************************
; Save a record to a file

; Entry		a0->Handle
;		d0=record number

; Exit		d0=0 if operation failed

; Corrupt	d0

SaveRecord	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle

; Locate the record

		move.l		(a5),d1
		subq.l		#1,d0
		move.l		rnd_RecSize(a5),d2
		mulu		d0,d2
		moveq.l		#OFFSET_BEGINNING,d3
		CALLDOS		Seek
		cmp.l		#-1,d0
		bne.s		.SeekOk
		moveq.l		#0,d0
		bra.s		.Error

; Save the record

.SeekOk		move.l		a5,a0
		bsr		RNDCrypt
		move.l		(a5),d1			handle
		move.l		rnd_Buffer(a5),d2	buffer
		move.l		rnd_RecSize(a5),d3	size
		CALLAGAIN	Write			save record
		move.l		a5,a0
		bsr		RNDCrypt
		cmp.l		rnd_RecSize(a5),d0	save ok?
		beq.s		.WriteOk
		moveq.l		#0,d0			no, signal an error
		bra.s		.Error

; And exit

.WriteOk	moveq.l		#1,d0			no errors

.Error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			  Set Password For A File			    *
*****************************************************************************

; CALL THIS BEFORE PREFORMING ANY FILE I/O

;Entry		a0->RNDHandle
;		a1->Password  [ 8 bytes ]

RandPassword	move.l		a1,rnd_Password(a0)
		rts

*****************************************************************************
*		   Encrypt/Decrypt Data In Buffer			    *
*****************************************************************************

; Entry		a0->RNDHandle

; Exit		none

; Corrupt	none

RNDCrypt	movem.l		d0-d2/a0-a2,-(sp)

		tst.l		rnd_Password(a0)	Password supplied?
		beq.s		.done			no, leave it alone!

		move.l		rnd_RecSize(a0),d0	buffer size
		move.l		rnd_Password(a0),a1	Password
		move.l		rnd_Buffer(a0),a0	buffer

		subq.w		#1,d0
		move.l		a1,d2
		move.l		a1,a2
		addq.l		#8,d2

.loop		move.b		(a1)+,d1
		ror.b		#2,d1
		eor.b		d1,(a0)+
		cmp.l		a1,d2
		bne.s		.NoReset
		move.l		a2,a1

.NoReset	dbra		d0,.loop

.done		movem.l		(sp)+,d0-d2/a0-a2
		rts

*****************************************************************************
*		   Count Records In A Random Access File		    *
*****************************************************************************
; Count total number of records, in use and wiped, in a file

; Entry		a0->Handle

; Exit		d0=-1 if operation failed, else number of records (can=0!)

; Corrupt	d0

CountRecords	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5

; Move to start of file

		move.l		(a5),d1
		moveq.l		#0,d2
		moveq.l		#OFFSET_END,d3
		CALLDOS		Seek
		cmp.l		#-1,d0
		beq.s		.error
		
; Move to end of file

		move.l		(a5),d1
		moveq.l		#0,d2
		moveq.l		#OFFSET_BEGINNING,d3
		CALLDOS		Seek
		cmp.l		#-1,d0
		beq.s		.error

; Calculate number of records from size of file

		move.l		rnd_RecSize(a5),d1
		bne.s		.NoTrap			trap 'Divide By Zero'
		moveq.l		#-1,d0
		bra.s		.error

.NoTrap		divu		d1,d0
		and.l		#$ffff,d0		mask off remainder

; And exit
		
.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*		   Wipe A Record In A Random Access File		    *
*****************************************************************************
; Blank record in a file so it can be 'purged' at a later date

; Entry		a0->Handle
;		d0=record number

; Exit		d0=0 if operation failed

; Corrupt	d0

WipeRecord	movem.l		d1-d7/a0-a6,-(sp)

; Wipe the record buffer

		move.l		rnd_Buffer(a0),a1
		move.l		rnd_RecSize(a0),d1
		subq.l		#1,d1

.loop		move.b		#0,(a1)+
		dbra		d1,.loop

; Save empty buffer

		bsr		SaveRecord

; And exit!

		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			    Validate A Record				    *
*****************************************************************************
; Check a given record exsists and is not empty

; Entry		a0->Handle
;		d0=record number

; Exit		d0=0 if record is invalid

; Corrupt	d0

ValidateRecord	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle

; Load the record

		bsr		LoadRecord
		tst.l		d0
		beq.s		.error

; OR all bytes in record together, if result is zero then record is empty

		move.l		rnd_Buffer(a5),a0	a0->record
		move.l		rnd_RecSize(a5),d1	d1=size of record
		moveq.l		#0,d0			clear

.loop		subq.l		#1,d1			dec counter
		bmi.s		.error			exit when finished
		or.b		(a0)+,d0
		bra.s		.loop

; And exit

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*			Purge A Random Access File			    *
*****************************************************************************
; Remove all empty records from a Random Access File

; Entry		a0->Source Handle
;		a1->Dest file name

; Exit		d0=0 if operation failed

; Corrupt	d0

PurgeRecords	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			Source handle
		move.l		a1,a4			Dest filename

; Create destination file

		move.l		a1,d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,d1
		beq.s		.error
		CALLAGAIN	Close

; Open destination file as a Random Access file

		move.l		a4,a0			name
		move.l		rnd_RecSize(a5),d0	record size
		bsr		OpenRandom		Open the file
		tst.l		d0
		beq.s		.error
		move.l		d0,a4			Dest Handle
		move.l		rnd_Password(a5),rnd_Password(a4)

; Determine number of records in the file

		move.l		a5,a0			handle
		bsr		CountRecords
		move.l		d0,d7			counter
		beq.s		.error
		cmp.l		#-1,d0
		bne.s		.GotSome

	; Must free destination file prior to quitting

		move.l		a4,a0
		bsr		CloseRandom
		moveq.l		#0,d0
		bra.s		.error

; Initialise the Read and Write counters

.GotSome	moveq.l		#1,d5			Read Counter
		moveq.l		#1,d6			Write Counter

; Check if all records examined, exit when true

.loop		cmp.l		d7,d5			All done?
		bgt.s		.done

; Load next record

		move.l		a5,a0			handle
		move.l		d5,d0			record number
		bsr		ValidateRecord		Load & Validate
		tst.l		d0			Wiped?
		beq.s		.Next			yes, skip saving

; Is valid, so write it back

		move.l		rnd_Buffer(a5),a0
		move.l		rnd_Buffer(a4),a1
		move.l		rnd_RecSize(a4),d0
		CALLEXEC	CopyMem

		move.l		a4,a0			handle
		move.l		d6,d0			record number
		bsr		SaveRecord		save it

; Bump counters and loop

		addq.l		#1,d6			bump Write counter
.Next		addq.l		#1,d5			bump Read counter
		bra.s		.loop

.done		move.l		a4,a0
		bsr		CloseRandom

		moveq.l		#1,d0			no errors

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts

*****************************************************************************
*		    Search Forward A Random Access File			    *
*****************************************************************************
; Search a file for a record containing matching data

; Entry		a0->Handle
;		a1->Search Data
;		d0=start record

; Exit		d0=0 if no match found, else returns next start record number
;		   if match found, record will be loaded into buffer

; Corrupt	d0


SearchFRec	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle
		move.w		(a1)+,d5		search mode AND,OR
		move.l		a1,a4			search criterior
		move.l		d0,d7			current rec num

; Load the next record

.loop		move.l		a5,a0
		move.l		d7,d0
		bsr		LoadRecord
		tst.l		d0
		bne.s		.GotRec
		move.l		d0,d7
		bra.s		.Error

; Start servicing the search criterior

.GotRec		moveq.l		#0,d6			clear found flag
		movea.l		a4,a3			working copy
		
.Inner		tst.l		(a3)			end of search?
		beq.s		.Next			yep, check result!
		
		moveq.l		#0,d0			clear
		move.w		(a3)+,d0		offset
		move.w		(a3)+,d1		length
		subq.w		#1,d1			dbra adjust
		move.l		(a3)+,a0		match with
		move.l		rnd_Buffer(a5),a1	a1->buffer
		adda.l		d0,a1			a1->field
		
.checkloop	cmp.b		(a0)+,(a1)+
		dbne		d1,.checkloop
		
		bne.s		.NotSame
		
		moveq.l		#1,d6			signal found
		bra.s		.Inner

.NotSame	tst.w		d5			in OR mode?
		beq.s		.Inner			yes, ignore failure
		moveq.l		#0,d6			else set failure
		
.Next		tst.w		d6			match found?
		bne.s		.Found			yes, exit loop
		addq.l		#1,d7			else bump counter
		bra.s		.loop

.Found		move.l		d7,d0			return record number
		addq.l		#1,d0			of next record
		
.Error		movem.l		(sp)+,d1-d7/a0-a6
		rts

		dc.b		'These routines © M.Meany, 1993'
		dc.b		'Permission required for commercial use.'
		even
		
*****************************************************************************
*		   Search Backwards A Random Access File		    *
*****************************************************************************
; Search a file for a record containing matching data

; Entry		a0->Handle
;		a1->Search Data
;		d0=start record

; Exit		d0=0 if no match found, else returns next start record
;		   if match found, record will be loaded into buffer

; Corrupt	d0

SearchBRec	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle
		move.w		(a1)+,d5		search mode AND,OR
		move.l		a1,a4			search criterior
		move.l		d0,d7			current rec num

; Load the next record

.loop		move.l		a5,a0
		move.l		d7,d0
		bsr		LoadRecord
		tst.l		d0
		bne.s		.GotRec
		move.l		d0,d7
		bra.s		.Error

; Start servicing the search criterior

.GotRec		moveq.l		#0,d6			clear found flag
		movea.l		a4,a3			working copy
		
.Inner		tst.l		(a3)			end of search?
		beq.s		.Next			yep, check result!
		
		moveq.l		#0,d0			clear
		move.w		(a3)+,d0		offset
		move.w		(a3)+,d1		length
		subq.w		#1,d1			dbra adjust
		move.l		(a3)+,a0		match with
		move.l		rnd_Buffer(a5),a1	a1->buffer
		adda.l		d0,a1			a1->field
		
.checkloop	cmp.b		(a0)+,(a1)+
		dbne		d1,.checkloop
		
		bne.s		.NotSame
		
		moveq.l		#1,d6			signal found
		bra.s		.Inner

.NotSame	tst.w		d5			in OR mode?
		beq.s		.Inner			yes, ignore failure
		moveq.l		#0,d6			else set failure
		
.Next		tst.w		d6			match found?
		bne.s		.Found			yes, exit loop
		subq.l		#1,d7			else bump counter
		bne.s		.loop
		moveq.l		#0,d0
		bra.s		.Error

.Found		move.l		d7,d0			return record number
		addq.l		#1,d0			of next record
		
.Error		movem.l		(sp)+,d1-d7/a0-a6
		rts

; Text search routines. Use same data structure, but match pointer points to
;a NULL terminated string. A case insensitive, 'IN' string, search is done
;for each supplied string in it's relevant field. NOTE: This routine
;capitalises the supplied strings to simplify the search algorithm.

SearchFText	rts

SearchBText	rts

;Build a sorted index file for a field. Sorted as Alpha increasing. VERY
;memory intensive and non too fast either. All fields are loaded into a
;continuous block of memory!

; Entry		a0->RNDHandle
;		a1->Index filename to create
;		d0=field offset
;		d1=field width

; Exit		d0=success

; Corrupt	d0

RNDBuildIndex	movem.l		d1-d7/a0-a6,-(sp)

		move.l		a0,a5			handle
		move.l		a1,d7			filename
		move.l		rnd_Buffer(a5),a3
		mulu		rnd_RecSize(a5),d0	offset
		add.l		d0,a3			a3->field
		move.l		d1,d5			field width

; Allocate memory for all the fields

		move.l		a5,a0
		bsr		CountRecords
		mulu		d5,d0			size of mem required
		beq.s		.error

		move.l		#MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l		d0
		beq.s		.error

		move.l		d0,a4			a4->file buffer

; Step through records extracting the required field. Use a binary search to
;locate position at which to insert it. Shift all other entries down to
;accommodate new entry. Copy entry into buffer. ALL ENTRIES IN INDEX FILE
;WILL BE CAPITALISED TO SPEED THINGS UP!

.error		movem.l		(sp)+,d1-d7/a0-a6
		rts




; Search Data	mode ( 0=OR mode, 1=AND mode )
;		field offset, length, match pointer
;		field offset, length, match pointer
;		0,0

