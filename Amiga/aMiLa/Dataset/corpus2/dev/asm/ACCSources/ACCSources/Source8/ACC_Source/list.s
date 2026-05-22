
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

;-------------- Adds a blank line to list.

empty_line	moveq.l		#1,d0
		lea		e_line_data,a0
		bsr		add_node
		add.l		#1,num_lines(a4)
		rts
		
e_line_data	dc.b		$0A
		even
		
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

;-------------- Load File

;		Reads in a file and adds it to cuttent list
;		The number of lines is stored in num_lines.
;		Node points to 1st entry in list.
;Entry		a5--> file name
		
load_file	move.l		#1000,d0
		CALLARP		DosAllocMem
		move.l		d0,read_buf(a4)
		beq		mem1_error
		
		move.l		#256,d0
		CALLSYS		DosAllocMem
		move.l		d0,copy_buf(a4)
		beq		mem2_error
		
		move.l		a5,d1
		move.l		#MODE_OLDFILE,d2
		CALLSYS		Open
		move.l		d0,filehd(a4)
		beq		no_file
		move.l		copy_buf(a4),a3
		moveq.l		#0,d4
		move.l		d4,d7
		
loop		move.l		filehd(a4),d1
		move.l		read_buf(a4),d2
		move.l		#1000,d3
		CALLSYS		Read
		move.l		d0,d6
		beq.s		all_done
		
		move.l		read_buf(a4),a5
		subq.l		#1,d6
loop1		move.b		(a5)+,d0
.break_line	move.b		d0,(a3)+
		addq.l		#1,d4
		cmp.b		#$0A,d0
		bne.s		.ok
		bsr		empty_buf
.ok		cmp.b		#254,d4
		bne.s		.ok1
		moveq.l		#$0A,d0
		bra.s		.break_line
		
.ok1		dbra		d6,loop1
		bra		loop
		
empty_buf	movem.l		d0-d6/a0-a7,-(sp)
		move.l		copy_buf(a4),a0
		move.l		d4,d0
		bsr		add_node
		movem.l		(sp)+,d0-d6/a0-a7
		moveq.l		#0,d4
		move.l		copy_buf(a4),a3
		addq.l		#1,d7
		rts

all_done	move.l		d7,num_lines(a4)
		move.l		filehd(a4),d1
		CALLSYS		Close
		
		lea		start_list(a4),a0
		move.l		node.next(a0),node(a4)
		
no_file		move.l		copy_buf(a4),a1
		CALLSYS		DosFreeMem
		
mem2_error	move.l		read_buf(a4),a1
		CALLSYS		DosFreeMem

mem1_error	rts

		
;-------------- Subroutine to save list 

;Entry		d7 must hold output file handle
;		node must hold address of 1st line to save.

save_list	move.l		node(a4),a5
		move.l		node.prev(a5),a5
.loop		move.l		node.next(a5),a5
		moveq.l		#0,d3
		move.b		node.len(a5),d3
		beq.s		.done
		move.l		a5,d2
		add.l		#node.data,d2
		move.l		d7,d1
		CALLARP		Write
		bra		.loop
.done		rts





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

