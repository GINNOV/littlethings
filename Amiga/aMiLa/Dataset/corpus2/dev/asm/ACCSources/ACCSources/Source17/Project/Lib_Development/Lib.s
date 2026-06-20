
; The main body of routines for acc.library, a project started in Oct 91.

; © M.Meany, 1991.

; Subroutine list in order of occurence:

;					Function	Author

;					GetLibs		M.Meany
;					LoadFile	M.Meany
;					SaveFile	M.Meany
;					FileLen		M.Meany
;					FindStr		M.Meany
;					StringCmp	M.Meany
;					Ucase		M.Meany
;					Lcase		M.Meany
;					UcaseMem	M.Meany
;					LcaseMem	M.Meany
;					DOSPrint	M.Meany
;					GetDirList	M.Meany
;					FreeDirList	M.Meany
;					NewList		M.Meany
;					AddNode		M.Meany
;					DeleteNode	M.Meany
;					FreeList	M.Meany

		XREF		_DOSBase,_IntuitionBase,_GfxBase
		XDEF		GetLibs,LoadFile,SaveFile,FileLen
		XDEF		FindStr,StringCmp,Ucase,Lcase,UcaseMem
		XDEF		LcaseMem,DOSPrint,GetDirList,FreeDirList
		XDEF		NewList,AddNode,DeleteNode,FreeList

		incdir		sys:include/
		include		exec/exec_lib.i
		include		exec/memory.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i

		opt p+

MYEXEC		macro
		move.l		a6,-(sp)
		move.l		4.w,a6
		jsr		_LVO\1(a6)
		move.l		(sp)+,a6
		endm

MYDOS		macro
		move.l		a6,-(sp)
		move.l		_DOSBase,a6
		jsr		_LVO\1(a6)
		move.l		(sp)+,a6
		endm

****************

; Subroutine that copies library pointers into a block of mem ( 3 longs ).

; Entry		a0-> block of memory to store pointers in ( 3 long words ).

; Exit		dos, intuition and gfx lib base pointers stored in mem.

; Corrupted	None

GetLibs		move.l		_DOSBase,(a0)+
		move.l		_IntuitionBase,(a0)+
		move.l		_GfxBase,(a0)+
		lea		-12(a0),a0
		rts

****************

; Subroutine that loads a file into a block of memory.

; Entry		a0-> filename
;		d0=  type of memory ( either CHIPMEM, FASTMEM or PUBLICMEM )

; Exit		d0= length of buffer allocated
;		a0->buffer

; Corrupt	d0,a0

LoadFile	movem.l		d1/d5/d6/a4/a5,-(sp)

		move.l		d0,d1		save requirements
		move.l		a0,a4		save filename pointer

		bsr		FileLen		obtain thhe size of the file

		move.l		d0,d5		save file size
		beq.s		.error		quit if zero

;--------------	Filesize determined so allocate a buffer. NB d1= requirements.

		MYEXEC		AllocMem	get buffer
		move.l		d0,a5		save pointer
		tst.l		d0		all ok?
		bne.s		.cont		if so skip next bit

		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont		move.l		a4,d1		d1->filename
		move.l		#MODE_OLDFILE,d2 access mode
		MYDOS		Open		open the file
		move.l		d0,d6		save handle
		bne		.cont1		quit if error

		move.l		a5,a1		buffer
		move.l		d5,d1		length
		MYEXEC		FreeMem		and release it
		moveq.l		#0,d5		set error
		bra		.error		and quit

.cont1		move.l		d0,d1		handle
		move.l		a5,d2		buffer
		move.l		d5,d3		file length
		MYDOS		Read		and load the file

		move.l		d6,d1		handle
		MYDOS		Close		close the file

		move.l		a5,a0		a0->buffer
.error		move.l		d5,d0		d0=return value
		movem.l		(sp)+,d1/d5/d6/a4/a5
		rts

****************

; Routine to create a file and write data to it.

; Entry		a0->Filename
;		a1->Buffer
;		d0=buffer size ( number of bytes to write ).

; Exit		d0=0 if an error occurred, non zero if file created.

; Corrupted	d0,a0

SaveFile	movem.l		d1-d5/a1-a4,-(sp)

		move.l		d0,d4		working copies
		move.l		a1,a4

		move.l		a0,d1		filename
		move.l		#MODE_NEWFILE,d2 access mode
		MYDOS		Open		and open file
		move.l		d0,d5		save handle
		beq		.error		quit if no file

		move.l		d0,d1		handle
		move.l		a4,d2		buffer
		move.l		d4,d3		size
		MYDOS		Write		write data to file

		move.l		d5,d1		handle
		MYDOS		Close		close file

.error		move.l		d5,d0		  set return code
		movem.l		(sp)+,d1-d5/a1-a4
		rts

****************

; Subroutine that returns the length of a file in bytes.

; Entry		a0-> filename

; Exit		d0 = length of file in bytes or 0 if any error occurred

; Corrupted	d0

; M.Meany, Feb 91

; Save register values

FileLen		movem.l		d1-d7/a0-a6,-(sp)

; Save address of filename and clear file length

		move.l		a0,a6
		move.l		#0,d5

; Allocate some memory for the File Info block

		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		MYEXEC		AllocMem
		move.l		d0,d6
		beq		.error1
		
; Lock the file
		
		move.l		a6,d1
		move.l		#ACCESS_READ,d2
		MYDOS		Lock
		move.l		d0,d7
		beq		.error2

; Use Examine to load the File Info block

		move.l		d0,d1
		move.l		d6,d2
		MYDOS		Examine

; Copy the length of the file into d5

		move.l		d6,a0
		move.l		fib_Size(a0),d5

; Release the file

		move.l		d7,d1
		MYDOS		UnLock

; Release allocated memory

.error2		move.l		d6,a1
		move.l		#fib_SIZEOF,d0
		MYEXEC		FreeMem

; All done so return

.error1		move.l		d5,d0
		movem.l		(sp)+,d1-d7/a0-a6
		rts

****************
	
;--------------	Compare two words.

; Compares two zero terminated text strings and returns a value in d0
;that specifies the priority of one relative to the other.

; Entry a0->start of first word
;	a1->start of second word

; Exit	d0=0 if words the same
;	d0=1 if first word < second word
;	d0=2 if first word > second word

; corrupted d0,d1,a0,a1

StringCmp	move.l		d2,-(sp)
		move.l		a2,-(sp)

		move.l		a0,a2
		moveq.l		#0,d0
		move.l		d0,d1

.len1		addq.l		#1,d0
		tst.b		(a2)+
		bne.s		.len1

		move.l		a1,a2
.len2		addq.l		#1,d1
		tst.b		(a2)+
		bne.s		.len2

		moveq.l		#0,d2
		cmp.l		d0,d1
		beq.s		.ok
		blt.s		.ok1
		moveq.l		#1,d2
		bra.s		.ok
.ok1		moveq.l		#2,d2
		move.l		d1,d0
.ok		subq.l		#2,d0
.loop		cmp.b		(a0)+,(a1)+
		dbne		d0,.loop
		bgt.s		.first
		blt.s		.second
		move.l		d2,d0
		bra.s		.done
		
.first		moveq.l		#1,d0
		bra.s		.done
		
.second		moveq.l		#2,d0

.done		move.l		(sp)+,a2
		move.l		(sp)+,d2
		rts

****************

; Subroutine to search a block of memory for a given string.
; M.Meany, April 91.

; Entry		a0 addr of string to search for
;		d0 length of string
;		a1 addr of memory block
;		d1 length of memory block

; Exit		d0 addr of first occurence of string, 0 if no match found

; Corrupted	d0

FindStr		movem.l		d1-d3/a0-a2,-(sp) save values
		moveq.l		#0,d3	clear flag, assume failure
		sub.l		d0,d1		set up counter
		subq.l		#1,d1		correct for dbra
		bmi.s		.FindError	quit if block < string

		move.b		(a0),d2		d2=1st char to match
.Floop		cmp.b		(a1)+,d2	match 1st char of string ?
		dbeq		d1,.Floop	no+not end, loop back

		bne.s		.FindError	if no match+end then quit

		bsr.s		.CompStr	else check rest of string

		beq.s		.Floop		loop back if no match

.FindError	movem.l		(sp)+,d1-d3/a0-a2 retrieve values
		move.l		d3,d0	set d0 for return
		rts

.CompStr	movem.l		d0/a0-a2,-(sp)

		subq.l		#1,d0		correct for dbra
		move.l		a1,a2		save a copy
		subq.l		#1,a1		correct as it was bumped
.FFloop		cmp.b		(a0)+,(a1)+	compare string elements
		dbne		d0,.FFloop	while not end + not match

		bne.s		.ComprDone	no match so quit
		subq.l		#1,a2		correct this addr
		move.l		a2,d3	save addr of match

.ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		d3	set Z flag as required
		rts

****************

;--------------	Converts text string to upper case.

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	a0

Ucase		movem.l		d1-d3,-(sp)
		tst.b		(a0)
		beq.s		.error

		move.b		#'a',d1
		move.b		#'z',d2
		moveq.l		#$20,d3
		
.loop		cmp.b		(a0)+,d1
		bgt.s		.ok
		
		cmp.b		-1(a0),d2
		blt.s		.ok
		
		sub.b		d3,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		movem.l		(sp)+,d1-d3
		rts

****************

;--------------	Converts text string to lower case.

;Entry		a0->start of null terminated text string

;Exit		a0->end of text string ( the zero byte ).

;corrupted	a0

Lcase		movem.l		d1-d3,-(sp)
		tst.b		(a0)
		beq.s		.error

		move.b		#'A',d1
		move.b		#'Z',d2
		moveq.l		#$20,d3
		
.loop		cmp.b		(a0)+,d1
		bgt.s		.ok
		
		cmp.b		-1(a0),d2
		blt.s		.ok
		
		add.b		d3,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		movem.l		(sp)+,d1-d3
		rts

****************

;--------------	Converts text in a buffer to upper case.

;Entry		a0->start of text buffer
;		d0=len of buffer

;Exit		none

;corrupted	a0,d0

UcaseMem	movem.l		d1-d3,-(sp)
		tst.l		d0
		beq.s		.error

		move.b		#'a',d1
		move.b		#'z',d2
		moveq.l		#$20,d3
		
.loop		cmp.b		(a0)+,d1
		bgt.s		.ok
		
		cmp.b		-1(a0),d2
		blt.s		.ok
		
		sub.b		d3,-1(a0)
		
.ok		subq.l		#1,d0
		bne.s		.loop
		
.error		movem.l		(sp)+,d1-d3
		rts

****************

;--------------	Converts text in a buffer to lower case.

;Entry		a0->start of text buffer
;		d0=len of buffer

;Exit		none

;corrupted	a0,d0

LcaseMem	movem.l		d1-d3,-(sp)
		tst.l		d0
		beq.s		.error

		move.b		#'A',d1
		move.b		#'Z',d2
		moveq.l		#$20,d3
		
.loop		cmp.b		(a0)+,d1
		bgt.s		.ok
		
		cmp.b		-1(a0),d2
		blt.s		.ok
		
		add.b		d3,-1(a0)
		
.ok		subq.l		#1,d0
		bne.s		.loop
		
.error		movem.l		(sp)+,d1-d3
		rts

****************

;--------------	Subroutine to display any message in an open file.

; Entry		a0 must hold address of 0 terminated message.
;		d0 should hold handle of open file to be written to.

; Exit		None
;Corrupted	d0,d1,a0,a1

DOSPrint	move.l		d3,-(sp)	save work registers
		move.l		d2,-(sp)

		move.l		d0,d1		get a working copy of handle
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

		tst.l		d1		d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		move.l		(sp)+,d2	restore registers
		move.l		(sp)+,d3
		rts				and return

***************

; Entry		a0-> name of directory to examine.

; Exit		d0-> list header of dir entries or 0 if error.

; Corrupt	a0,d0

GetDirList	movem.l		d1-d7/a1-a6,-(sp)

		move.l		a0,a4		save pointer to dir name

		move.l		#fib_SIZEOF,d0	size
		moveq.l		#MEMF_PUBLIC,d1	type
		CALLEXEC	AllocMem	and get mem block
		move.l		d0,d5		save pointer
		beq		.error		quit if no mem

		bsr		NewList		create a list for entries
		move.l		d0,d6		save list pointer
		beq		.error2		quit if no memory

		move.l		a4,d1		directory name
		moveq.l		#ACCESS_READ,d2 access mode ( read only )
		CALLDOS		Lock		and get a lock on directory
		move.l		d0,d7		save lock for later
		beq		.error1		quit if no lock

		move.l		d0,d1		lock
		move.l		d5,d2		mem block for fib
		CALLDOS		Examine		get fib
		tst.l		d0		read ok?
		beq.s		.error1		quit if error

		move.l		d6,a0		a0->list header
		bsr		AddNode		and add a node
		tst.l		d0		save node pointer
		bne.s		.error1		quit if error

.loop		move.l		a0,a3		save node pointer

		moveq.l		#110,d0		size of name
		moveq.l		#MEMF_PUBLIC,d1	type of mem
		CALLEXEC	AllocMem	get mem for nodes data
		move.l		d0,a1		save pointer
		move.l		d0,a2		twice
		tst.l		d0		mem allocated?
		beq.s		.error1		quit if error

		move.l		d5,a0		a0->fib
		lea		fib_DirEntryType(a0),a0	a0->entry type

		move.b		#'D',(a1)+	default to a dir entry
		tst.l		(a0)		if +ve then a directory
		bpl.s		.is_dir		if directory, skip next
		move.b		#'F',-1(a1)	save file descriptor

.is_dir		move.l		d5,a0		a0->fib
		lea		fib_FileName(a0),a0 a0->the entries name
.loop1		move.b		(a0)+,(a1)+	copy char
		bne.s		.loop1		until all name copied

		move.l		a2,nd_Data(a3)	attach data to node

		move.l		d7,d1		lock
		move.l		d5,d2		fib
		CALLDOS		ExNext		get info on next entry
		tst.l		d0		all ok?
		beq.s		.error1		if not quit

		move.l		d6,a0		a0->list header
		move.l		nd_Data(a0),a0	a0->last list entry
		bsr		AddNode		and add a node
		tst.l		d0		error?
		bne		.error1		quit if error
		bra.s		.loop		go back and copy data

.error1		move.l		d7,d1		d1=file lock
		CALLDOS		UnLock		and release it

.error2		move.l		d5,a1		a1->block
		move.l		#fib_SIZEOF,d0	d0=block size
		CALLEXEC	FreeMem		and release memory

		move.l		d6,d0		d0=addr of list header

.error		movem.l		(sp)+,d1-d7/a1-a6
		rts

***************

; Free memory tied up in a directory list

; Entry		a0->list header

; Exit		none

; Corrupt	d0,a0

FreeDirList	movem.l		d1-d7/a1-a6,-(sp)

		move.l		a0,a4
		move.l		a0,a5

.loop		move.l		nd_Succ(a5),a5
		tst.l		nd_Succ(a5)	end of list?
		beq.s		.done		if so skip next bit

		tst.l		nd_Data(a5)	valid data block ?
		beq.s		.loop		if not skip this entry
		move.l		nd_Data(a5),a1	a1->entry block
		moveq.l		#110,d0		d0=block size
		CALLEXEC	FreeMem		and release it
		bra.s		.loop		loop back for next entry

.done		move.l		a4,a0		a0->list header
		bsr		FreeList	and free the list

.error		movem.l		(sp)+,d1-d7/a1-a6
		rts

***************


; Node structure

		rsreset
nd_Succ		rs.l		1	pointer to next node
nd_Pred		rs.l		1	pointer to previous node
nd_Data		rs.l		1	pointer to nodes data
nd_SIZEOF	rs.l		0	size of node structure


*****************************************************************************

; Create an empty list

; Entry		None
; Exit		d0=addr of list header or zero if no memory available
; Corrupted	d0,d1,a0,a1

NewList		moveq.l		#nd_SIZEOF,d0		size of node
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 type of mem
		CALLEXEC	AllocMem		and get a block
		move.l		d0,d1			save pointer
		beq.s		.error			quit if error

		move.l		d0,a0			a0->header
		move.l		d0,8(a0)		head pointer
		addq.l		#4,d0			addr of tail
		move.l		d0,(a0)			tail pointer
		move.l		a0,d0			d0=addr of header

.error		rts

*****************************************************************************

; Add node to list

; Entry		a0->node to insert after.

; Exit		d0 is non zero if an error occurred.
;		   Specific error codes: d0=1 if no memory for node structure
;		   d0=2 if attempting to write node after the Tail

; Corrupt	d0,d1,a0,a1

AddNode		move.l		a0,-(sp)	save node pointer

		tst.l		(a0)	end of list?
		bne.s		.do_it		if not skip next bit
		move.l		(sp)+,a0
		moveq.l		#2,d0		set error code ( 2=Tail )
		bra.s		.error		and leave

.do_it		moveq.l		#nd_SIZEOF,d0	size of block
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1	type of mem
		CALLEXEC	AllocMem	get block
		move.l		d0,d1		save pointer
		bne.s		.ok		branch if mem obtained

		move.l		(sp)+,a0
		moveq.l		#1,d0		set error code ( 1=no mem )
		bra.s		.error		and leave

.ok		move.l		d0,a1		a1->new nodes structure

		move.l		(sp)+,a0	a0->list header
		move.l		a0,nd_Pred(a1)	new node has head as pred

		move.l		(a0),nd_Succ(a1) new node succ=heads old succ

		move.l		a1,(a0)		head points to new node

		move.l		nd_Succ(a1),a0	a0->heads old successor
		move.l		a1,nd_Pred(a0)	heads old succ has node as pred

		move.l		a1,a0		a0->this node
		moveq.l		#0,d0		no errors

.error		rts

*****************************************************************************

; Delete a node from a list.

; Note, this routine only releases the memory occupied by the nodes
;structure, not by the nodes data!

; Entry		a0->node to delete
; Exit		none, but node will not be released if it is the Head or Tail
; Corrupted	d0,d1,a0.a1

DeleteNode	movem.l		d2-d4/a2-a4,-(sp)	save registers

		move.l		nd_Succ(a0),d3	get pointer to successor
		beq		.error		quit if this is lists Tail

		move.l		nd_Pred(a0),d4	get pointer to predecessor
		beq		.error		quit if this is lists Head

		move.l		a0,a1		a1->node
		move.l		#nd_SIZEOF,d0	d0=structure size
		CALLEXEC	FreeMem		and release memory

		move.l		d3,a0		a0->old successor
		move.l		d4,a1		a1->old predecessor

		move.l		d3,nd_Succ(a1)	link succ to pred
		move.l		d4,nd_Pred(a0)

.error		movem.l		(sp)+,d2-d4/a2-a4	restore registers
		rts

*****************************************************************************

; Release all memory used by a list

; Entry		a0->list header
; Exit		none
; Corrupted	d0,d1,a0,a1

FreeList	move.l		a4,-(sp)	save registers
		move.l		d4,-(sp)

		move.l		a0,a4		get copy of header ptr

		move.l		nd_Succ(a4),d4	d4 = addr of next node

.loop		move.l		d4,a1		a1->node to release
		tst.l		(a1)		is this the tail?
		beq.s		.done_nodes	yep! so quit loop

		move.l		nd_Succ(a1),d4	d4=addr of next node

		move.l		#nd_SIZEOF,d0	d0=size of mem to free
		CALLEXEC	FreeMem		and release this node

		bra.s		.loop		loop back for next node

.done_nodes	move.l		a4,a1		a1->list header
		move.l		#nd_SIZEOF,d0	size of mem to free
		CALLEXEC	FreeMem		and release it

		move.l		(sp)+,d4	restore registers
		move.l		(sp)+,a4
		rts				all done so return

