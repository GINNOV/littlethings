
; Program to test integrity of acc.library

; Function	: To sort a text file into ascending alphabetical order.
; Program Size	: 1016 bytes.
; Author	: M.Meany.
; Date		: 10-10-91

; Enter the name of a text file as a parameter at the CLI. The file will be
;replaced by an alphabetically sorted version.

; WARNING: 	1/ Original file is replaced with sorted file.
;		2/ All characters converted to upper case.
;		3/ Takes bloody ages to sort large, disorganised files!


		incdir		sys:include/
		include		exec/exec.i
		include		exec/exec_lib.i
		include		libraries/dos_lib.i
		include		libraries/dosextens.i
		include		df1:project/lib_development/acc_lib.i

Start		move.b		#0,-1(a0,d0)	zero terminate filename!
		move.l		a0,filename	save pointer to filename

		lea		accname,a1	lib name
		moveq.l   	#0,d0		any version
		CALLEXEC	OpenLibrary	and open DOS
		move.l		d0,_AccBase	save lib pointer
		beq		.quit		quit if error

		lea		_DOSBase,a0	a0->lib base storage
		CALLACC		GetLibs		get lib pointers

		CALLDOS		Output		get handle of CLI window
		move.l		d0,STD_OUT	and save it

		move.l		filename,a0	a0->filename.
		tst.l		(a0)		filename specified?
		bne.s		.got_something	if so skip next bit

		lea		err_fname,a0	a0->error message
		move.l		STD_OUT,d0	d0=handle
		CALLACC		DOSPrint	display it
		bra		.error		and quit

.got_something	cmpi.b		#'?',(a0)	usage requested?
		bne.s		.got_file	if not skip next bit

		lea		usage,a0	a0->usage text
		move.l		STD_OUT,d0	d0=handle
		CALLACC		DOSPrint	display it
		bra		.error		and quit

.got_file	CALLACC		NewList		create a new list
		move.l		d0,d7		save header pointer
		beq		.error		quit if error

		move.l		filename,a0	a0->data filename
		move.l		d0,a1		a1->list header
		bsr		ReadFile	read in data
		move.l		d0,d5		save buffer size
		move.l		a0,a5		and address

		tst.l		d0		did we load ok?
		bne.s		.loaded		yep! so skip next bit

		lea		err_open,a0	a0->error message
		move.l		STD_OUT,d0	d0=handle
		CALLACC		DOSPrint	display it
		bra.s		.error1		and quit

.loaded		lea		text1,a0	a0->message
		move.l		STD_OUT,d0	d0=handle
		CALLACC		DOSPrint	display it

		move.l		d7,a0		a0->list header
		bsr		Bubble		sort the list

		move.l		d7,a0		a0->list header
		bsr.s		PrintList	save data

		lea		text2,a0	a0->message
		move.l		STD_OUT,d0	d0=handle
		CALLACC		DOSPrint	display it

.error1		move.l		d7,a0		a0->list header
		CALLACC		FreeList	and release mem

		move.l		d5,d0		get buffer size
		beq.s		.error		skip if no buffer
		move.l		a5,a1		a1->buffer
		CALLEXEC	FreeMem		free the buffer

.error		move.l		_AccBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close DOS

.quit		rts

*****************************************************************************

; Subroutine to print out all nodes in a list.

; Entry		a0->list header
; Exit		None
; Corrupted	d0,d1,a0,a1

PrintList	movem.l		d2/d4/d7/a4,-(sp)	save work registers
		move.l		a0,a4		copy header pointer

		move.l		filename,d1	filename
		move.l		#MODE_NEWFILE,d2 access mode
		CALLDOS		Open		open the file
		move.l		d0,d7		save handle
		beq.s		.error		quit if error

		move.l		(a4),d4		d4 = addr of next node

.loop		move.l		d4,a0		a0->node to print
		tst.l		(a0)		is this the tail?
		beq.s		.error1		yep! so quit loop

		move.l		(a0),d4		d4=addr of next node

		move.l		nd_Data(a0),a0	a0->ASCII text of node
		move.l		d7,d0		handle
		CALLACC		DOSPrint	print this nodes text

		lea		EOL,a0		a0->line feed
		move.l		d7,d0		handle
		CALLACC		DOSPrint	print a line feed.

		bra.s		.loop		loop back for next node

.error1		move.l		d7,d1		file handle
		CALLDOS		Close		and close it

.error		movem.l		(sp)+,d2/d4/d7/a4 restore registers
		rts				all done so quit

*****************************************************************************

; Reads in data from disc and adds it to list.

; Entry		a0->name of file to load
;		a1=list header
; Exit		d0=length of file or 0 if an error occured
;		a0->buffer allocated for file.
; Corrupt	d0,d1,a0,a1

ReadFile	movem.l		d5/d7/a3-a5,-(sp)	save registers
		move.l		a1,a3		save addr of list header
		move.l		a0,a5		save filename address

		moveq.l		#PUBLICMEM,d0	mem type to load into
		CALLACC		LoadFile	get size of file in bytes
		move.l		d0,d7		working copy of file len
		beq.s		.error		quit if not found
		move.l		a0,a4		buffer pointer

; Data is now in memory and file has been closed. Time to start processing
;the data! The following loop replaces line feeds with zero bytes and also
;converts lowercase to uppercase ( could have used UcaseMem() for the last
;bit, but what the hell! ).

		move.l		a4,a0		a0->buffer
		move.l		d7,d0		d0=buffer size
		subq.l		#1,d0		adjust for dbra

.procLoop1	move.b		(a0)+,d1	d1=next byte in buffer
		cmpi.b		#$0a,d1		is it a line feed
		bne.s		.not_LF		if not jump
		move.b		#0,-1(a0)	else replace with zero
		bra.s		.next		skip to end of loop

.not_LF		cmp.b		#'a',d1		is it lower case?
		blt.s		.next		if not skip to end of loop
		cmp.b		#'z',d1		is it lower case?
		bgt.s		.next		if not skip to end of loop
		sub.b		#'a'-'A',d1	convert byte to upper case
		move.b		d1,-1(a0)	and write back to buffer

.next		dbra		d0,.procLoop1	repeat 'till end of buffer

; Data is now processed. All we need do is locate each word and add it to
;the list. As explained in the tutorial, this code could have been merged
;into the above loop, but was left seperate for clarity.

		move.l		a4,a5		a5->buffer
		move.l		d7,d5		d5=buffer size
		subq.l		#1,d5		adjust for dbra

		move.l		a3,a0		a0->list header
		move.l		nd_Data(a0),a0	a0->last node
		CALLACC		AddNode		add to list
		tst.l		d0
		bne.s		.procLoop2	skip if node failed
		move.l		a5,nd_Data(a0)	save data pointer

.procLoop2	tst.b		(a5)+		is byte a zero?
		bne.s		.next1		if not skip to end of loop

; if a zero byte was found, we must check we are not at the end of the file
;as this would cause us to save a word that does not exsist. To check for
;the end of the file, test the loop counter. It will be zero when the last
;byte is being processed!

		tst.l		d5		end of file?
		beq.s		.next1		if so skipto end of loop

		move.l		a3,a0		a0->list header
		move.l		nd_Data(a0),a0	a0->last node
		CALLACC		AddNode		add to list
		tst.l		d0
		bne.s		.next1		skip if node failed
		move.l		a5,nd_Data(a0)	save data pointer

.next1		dbra		d5,.procLoop2	repeat 'till end of buffer

; All words are now added to the list! Time to finish.

		move.l		a4,a0		a0->buffer for return
		move.l		d7,d0		d0=buffer size for return

.error		movem.l		(sp)+,d5/d7/a3-a5	restore registers
		rts					and return

*****************************************************************************

; List Bubble Sort routine. Scans list exchanging two consecutive nodes if
;the data in the first node is alphabetically higher than the data in the
;second node. M.Meany, Sept 91.

; Entry		a0->list header
; Exit		none
; Corrupted	d0,d1,a0,a1

Bubble		movem.l		d7/a2-a4,-(sp)		save registers

		move.l		a0,a4			working copy

.next_scan	moveq.l		#0,d7			clear flag
		move.l		(a4),a2			a2->1st node
		tst.l		(a2)			end of list?
		beq.s		.error			if so quit!

.loop		move.l		(a2),a3			a3->next node
		tst.l		(a3)			end of list?
		beq.s		.error			if so quit!

		move.l		nd_Data(a2),a0		a0->1st word
		move.l		nd_Data(a3),a1		a1->2nd word
		CALLACC		StringCmp		and test order

		cmp.l		#2,d0			wrong order?
		bne.s		.next			if not skip to end

		move.l		nd_Data(a2),d0		get copy of pointer
		move.l		nd_Data(a3),nd_Data(a2)	swap pointers
		move.l		d0,nd_Data(a3)
		moveq.l		#1,d7			set flag

.next		move.l		a3,a2			step to next pair
		bra.s		.loop			and loop back

.error		tst.l		d7			flag set?
		bne.s		.next_scan		if so scan list again

		movem.l		(sp)+,d7/a2-a4		restore registers
		rts					and return

*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************

; Data section!

accname		dc.b		'df1:project/lib_development/acc.library',0
		even
_AccBase	dc.l		0
_DOSBase	ds.l		3	space for 3 lib pointers

STD_OUT		dc.l		0

filename	dc.l		0
		even
err_fname	dc.b		'You must specify a filename !',$0a,0
		even
err_open	dc.b		'Could not open specified file !',$0a
		dc.b		'Either file does not exsist or it is read protected.',$0a,0
		even
usage		dc.b		'Sort by M.Meany, Sept 1991.',$0a,$0a
		dc.b		'Usage:',$09,'Sort <filename>',$0a
		dc.b		'Where <filename> is the name of the file to sort.',$0a
		dc.b		'WARNING: The file will be replaced with the sorted copy.',$0a,$0a
		dc.b		'Run from the CLI only',$0a,0
		even
text1		dc.b		'..... Sorting file',$0a,0
		even
text2		dc.b		'..... Sort Complete.',$0a,0
		even
EOL		dc.b		$0a,0
*****************************************************************************



