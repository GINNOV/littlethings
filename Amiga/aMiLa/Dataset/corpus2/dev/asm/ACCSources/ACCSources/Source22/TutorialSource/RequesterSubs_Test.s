
*****	Title		GetVolList
*****	Function	A subroutine to build a list of available volumes.
*****			
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	15th March 92
*****	This Revision	
*****	Notes		Names must NOT be altered by applications, they are
*****			used to determine length of memory to release! May
*****			develop a better system later (extended node struct)

		include		start.i

Main		bsr		GetVolList
		move.l		d0,-(sp)
		bsr		Tester
		move.l		(sp)+,a0
		bsr		FreeVolList
		rts

;--------------
;--------------	Subroutine to test the GetVolList routine
;--------------

; Entry		d0=addr of header

Tester		move.l		d0,a1

.loop		TSTNODE		a1,a1			a1->next node
		beq		.done			exit if end
		move.l		LN_NAME(a1),a0		a0->node name
		bsr		PrintNL			print name
		bra		.loop			and loop back

.done		rts

;		opt		o+

;--------------
;--------------	Build a list of available volumes and assigns
;--------------

* Entry		None, though _DOSBase must be available and set correctly.

* Exit		d0=address of list header or NULL if error occurred

* Corrupt	d0

GetVolList	movem.l		d1-d7/a0-a6,-(sp)	save registers

; Allocate memory for list header and initialise it.

		moveq.l		#LH_SIZE,d0		size
		move.l		#MEMF_CLEAR,d1		type
		CALLEXEC	AllocMem		get memory
		tst.l		d0			ok?
		beq		.QuitFast		exit now if not!

		move.l		d0,a5			save in safe reg
		move.l		d0,a0			initialise header
		NEWLIST		a0

; Locate the start of the Device list.

		move.l		_DOSBase,a6
		move.l		dl_Root(a6),a0		a0->Root Node
		move.l		rn_Info(a0),d0		d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a0			a0->DosInfo
		move.l		di_DevInfo(a0),d0	d0=BPTR
		asl.l		#2,d0			convert
		move.l		d0,a4			a4->Device list

; Check entry is of required type, skip it if not.

.Loop		move.l		dl_Type(a4),d4		d4=Type
		cmp.l		#1,d4			min value
		blt		.Next			skip if lower
		cmp.l		#2,d4			max value
		bgt.s		.Next			skip if higher

; Allocate memory for node.

		moveq.l		#LN_SIZE,d0		size
		move.l		#MEMF_CLEAR,d1		type
		CALLEXEC	AllocMem		get memory
		tst.l		d0			ok?
		beq.s		.error			exit if not
		move.l		d0,a3			keep safe

; Allocate memory for copy of name.

		move.l		dl_Name(a4),d0		BPTR
		asl.l		#2,d0			convert
		move.l		d0,a2			a2->name (BSTR)
		moveq.l		#0,d0			clear
		move.b		(a2)+,d0		d0=name length
		addq.l		#1,d0			+1 for  NULL
		move.l		#MEMF_CLEAR,d1		type
		CALLEXEC	AllocMem		get memory
		move.l		d0,d7			keep safe
		bne.s		.GotAllMem		branch if allocated
		
		;error handler. If no mem for name, release node and quit!
		
		move.l		a3,a1			node address
		moveq.l		#LN_SIZE,d0		node size
		CALLEXEC	FreeMem			release it
		bra.s		.error			and exit

; Copy name into allocated memory.

.GotAllMem	move.l		a2,a0			source
		move.l		d7,a1			destination
		moveq.l		#0,d0			clear
		move.b		-1(a2),d0		size
		CALLEXEC	CopyMem			copy name

; Link name to node.

		move.l		d7,LN_NAME(a3)		store name pointer

; Copy entry type into priority field.

		move.l		dl_Type(a4),d0		Type
		move.b		d0,LN_PRI(a3)		into node struct

; Add node to end of list.

		move.l		a5,a0			header
		move.l		a3,a1			node
		ADDTAIL					add it!

; Step on to next entry

.Next		move.l		(a4),d0			step on
		beq.s		.error			exit if so
		asl.l		#2,d0			convert BPTR
		move.l		d0,a4
		bra		.Loop

; Address of header into d0.

.error		move.l		a5,d0			header

; All entries processed, so exit.

.QuitFast	movem.l		(sp)+,d1-d7/a0-a6	restore
		rts					exit

;--------------
;--------------	Free a list of available volumes and assigns
;--------------

* Entry		a0->list header

* Exit		none.

* Corrupt	none.

FreeVolList	movem.l		d0-d7/a0-a6,-(sp)	save

		move.l		a0,a4			a4->header
		move.l		a0,a3

; Get address of next node in list.

.NameLoop	TSTNODE		a3,a3			a3->next node
		beq.s		.NamesDone		branch if at tail

; Get address of nodes name.

		move.l		LN_NAME(a3),a0		a0->Name
		move.l		a0,a1			copy

; Determine length of name.

		moveq.l		#0,d0			length
.LenLoop	addq.l		#1,d0			bump counter
		tst.b		(a0)+			EOS?
		bne.s		.LenLoop		branch if not

; Release memory used for name and loop back.

		CALLEXEC	FreeMem			release it
		bra.s		.NameLoop		branch
		
; Remove next node from start of list.

.NamesDone	move.l		a4,a0			a0->list header
		CALLEXEC	RemHead			remove 1st node
		tst.l		d0			at tail?
		beq.s		.DoneNodes		branch if so.

; Release memory used for removed node.

		move.l		d0,a1			a1->mem
		moveq.l		#LN_SIZE,d0		size
		CALLEXEC	FreeMem			free it
		bra.s		.NamesDone		and loop

; Finally, release the header's memory.

.DoneNodes	move.l		a4,a1			a1->mem
		moveq.l		#LH_SIZE,d0		size
		CALLEXEC	FreeMem			free it

; All memory released, so exit.

.error		movem.l		(sp)+,d0-d7/a0-a6	restore
		rts


