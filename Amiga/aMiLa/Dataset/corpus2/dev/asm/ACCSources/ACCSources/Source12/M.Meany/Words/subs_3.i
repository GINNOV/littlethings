
; Subroutines for list handaling.

; The list uses ARP DosAllocMem to request memory for each line. Each line
;has a simple node structure appended to its start. This consists of 9 bytes:

; node.next	addr of next line
; node.prev	addr of previous line
; node.data	where long word address of data is stored

; Butchered	7.5.91 for application in Words v2.0, M.Meany.

;-------------- The node structure

		rsreset
node.next	rs.l		1
node.prev	rs.l		1
node.data	rs.l		1
node.SIZEOF	rs.b		0

;-------------- Initialise the list

init_list	lea		start_list(a4),a0
		lea		end_list(a4),a1
		move.l		a0,node.prev(a1)
		move.l		a1,node.next(a0)
		move.l		a0,node(a4)
		move.l		#0,num_lines(a4)
		rts

;-------------- Add a node to the list

;Entry		a0-> points to data for this node

add_node	move.l		a0,a2
		moveq.l		#node.SIZEOF,d0 size of block to allocate
		CALLARP		DosAllocMem
		move.l		d0,a1		a1->new node
		tst.l		d0
		beq.s		.fail
		
; Copy data into new node

		move.l		a2,node.data(a1)		

; Get address of new nodes predesessor and sucessor

		move.l		node(a4),a0	a0->predecerror
		move.l		node.next(a0),a2 a2->sucessor
		
; Insert these address into the new nodes structure

		move.l		a0,node.prev(a1)
		move.l		a2,node.next(a1)
		
; Correct predecessor to point to new node

		move.l		a1,node.next(a0)

; Correct sucessor to point to new node

		move.l		a1,node.prev(a2)
		
; make new node the current node

		move.l		a1,node(a4)
		addq.l		#1,num_lines(a4)
		
.fail		rts

;-------------- Delete current node from list.

; Will not delete 1st or last node.
; Current nodes sucessor becomes current node unless this is the last node.
;In this case the predesessor becomes current node.

del_node	move.l		node(a4),a1
		tst.l		node.next(a1)
		beq.s		.fail
		tst.l		node.prev(a1)
		beq.s		.fail
		
; Get pointers to sucessor and predecessor

		move.l		node.prev(a1),a0
		move.l		node.next(a1),a2
		
; Make predecessor point to sucessor

		move.l		a2,node.next(a0)
		
; Make sucessor point to predecessor

		move.l		a0,node.prev(a2)
		
; Make sucessor the current node

		move.l		a2,node(a4)
		
; If sucessor is end of list then make predecessor the current node

		tst.l		node.next(a2)
		bne.s		.ok
		move.l		a0,node(a4)
		subq.l		#1,num_lines(a4)
		
; Release memory for this node and finish

.ok		CALLARP		DosFreeMem
		
.fail		rts

;-------------- Clear the list and free all memory. Calls init_list

clear_list	lea		start_list(a4),a1
		move.l		node.next(a1),a1
.loop		move.l		node.next(a1),d2
		beq.s		.done
		CALLARP		DosFreeMem
		move.l		d2,a1
		bra.s		.loop
.done		bsr		init_list
		rts
		
;--------------	Compare two text strings.

; Assumes each word is followed by some terminating byte that is ignored.
; Terminating byte should be counted in the strings length.

; Entry a0->start of first word
;	a1->start of second word
;	d0= length of first word
;	d1= length of second word

; Exit	d0=0 if words the same
;	d0=1 if first word < second word
;	d0=2 if first word > second word

; corrupted d0,d1,a0,a1

compare_words	move.l		d2,-(sp)
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

.done		move.l		(sp)+,d2
		rts

