
; Subroutines for list handaling. Should still be ok to make A68K resident.

; The list uses ARP DosAllocMem to request memory for each line. Each line
;has a simple node structure appended to its start. This consists of 9 bytes:

; node.next	addr of next line
; node.prev	addr of previous line
; node.len	length ( in bytes ) of this line.

; Obviously node.len restricts line length to 255 chars, 0 chars not allowed.
;This is not a serious restriction.

; This list method adds 9 bytes overhead to each line !

; M.Meany	21.12.90

;-------------- The node structure

		rsreset
node.next	rs.l		1
node.prev	rs.l		1
node.len	rs.b		1
node.data	rs.b		1

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
;		d0=  size of data in bytes

add_node	move.l		a0,a2
		move.l		d0,d2
		add.l		#9,d0		add room for node struct
		CALLARP		DosAllocMem
		move.l		d0,a1		a1->new node
		tst.l		d0
		beq.s		.fail
		
; Copy data into new node

		move.b		d2,node.len(a1)	length into structure
		subq.l		#1,d2		correct for dbra
		add.l		#node.data,d0
		move.l		d0,a0
.loop		move.b		(a2)+,(a0)+
		dbra		d2,.loop
		
; Get address of new nodes predesessor and sucessor

		move.l		node(a4),a0		a0->predecerror
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


