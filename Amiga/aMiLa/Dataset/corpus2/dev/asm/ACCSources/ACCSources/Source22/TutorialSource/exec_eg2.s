
*****	Title		exec_eg2.s
*****	Function	Demonstrates application of system supported lists.
*****			
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	14 Feb 92
*****	This Revision	
*****	Notes		Shows use of Commodore supplied macro's and 
*****			exec.library functions supporting list handaling.
*****			All macros are defined in 'exec/lists.i'.

		include		start.i		startup module

; node structure for our list!

		rsreset
acc_Node	rs.b		LN_SIZE
acc_Phone	rs.l		1
acc_SizeOf	rs.b		0

; the main program.

Main		lea		MyHeader,a4	a4->list header

; Initialise an empty list.

		move.l		a4,a0		a0->head node
		NEWLIST		a0		initialise header
		
; Now add first three nodes to end of list.

		move.l		a4,a0		header
		lea		node1,a1	node
		ADDTAIL				add to end of list
		
		move.l		a4,a0		header
		lea		node2,a1	node
		ADDTAIL				add to end of list

		move.l		a4,a0		header
		lea		node3,a1	node
		ADDTAIL				add to end of list

; Add next three nodes to the start of the list.

		move.l		a4,a0		header
		lea		node4,a1	node
		ADDHEAD				add to start of list

		move.l		a4,a0		header
		lea		node5,a1	node
		ADDHEAD				add to start of list

		move.l		a4,a0		header
		lea		node6,a1	node
		ADDHEAD				add to start of list

; List is now complete, find a node by name and display details.

		move.l		a4,a0		header
		lea		name4,a1	name to find
		CALLEXEC	FindName	find the node
		tst.l		d0		exsists?
		beq.s		.loop		skip if not
		
		move.l		d0,a5		save node pointer
		move.l		LN_NAME(a5),a0	a0->node name
		bsr		PrintNL		print name
		
		move.l		acc_Phone(a5),a0 a0->phone number
		bsr		PrintNL		print number
		
; Display all entry details, a4 still points to list header.

.loop		TSTNODE		a4,a4			a4->next node
		beq		.done			exit if end
		move.l		LN_NAME(a4),a0		a0->node name
		bsr		PrintNL			print name
		move.l		acc_Phone(a4),a0	a0->node phone number
		bsr		PrintNL			print it
		bra.s		.loop			and loop back

.done		lea		MyHeader,a4		reset pointer

; remove a node from the list.

		lea		node4,a1		a1->node
		REMOVE					remove it

; display all entries again to verify above node removed.

.loop1		TSTNODE		a4,a4			a4->next node
		beq		.done1			exit if end
		move.l		LN_NAME(a4),a0		a0->node name
		bsr		PrintNL			print name
		move.l		acc_Phone(a4),a0	a0->node phone number
		bsr		PrintNL			print it
		bra.s		.loop1			and loop back

; all done so exit.

.done1		rts

;--------------	Data section.

MyHeader	ds.b		LH_SIZE

node1		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name1		LN_NAME
		dc.l		phone1		acc_Phone

node2		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name2		LN_NAME
		dc.l		phone2		acc_Phone

node3		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name3		LN_NAME
		dc.l		phone3		acc_Phone

node4		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name4		LN_NAME
		dc.l		phone4		acc_Phone

node5		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name5		LN_NAME
		dc.l		phone5		acc_Phone

node6		dc.l		0		LN_SUCC
		dc.l		0		LN_PRED
		dc.b		NT_UNKNOWN	LN_TYPE
		dc.b		0		LN_PRI
		dc.l		name6		LN_NAME
		dc.l		phone6		acc_Phone

name1		dc.b		'Mark',0
		even
name2		dc.b		'John',0
		even
name3		dc.b		'Dave',0
		even
name4		dc.b		'Blaine',0
		even
name5		dc.b		'Mike',0
		even
name6		dc.b		'Karl',0
		even

phone1		dc.b		'None',0
		even
phone2		dc.b		'657582',0
		even
phone3		dc.b		'983746',0
		even
phone4		dc.b		'876537',0
		even
phone5		dc.b		'654875',0
		even
phone6		dc.b		'543296',0
		even
