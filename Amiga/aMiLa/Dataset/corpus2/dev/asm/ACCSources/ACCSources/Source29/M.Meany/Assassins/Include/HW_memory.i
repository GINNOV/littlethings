
; Memory managment routines. M.Meany, Sept 1992.

; Require following files:	hardware.i
;				macros.i

		ifnd		mem_routines
mem_routines	set		1
		endc

		LIST
*** Memory.i v1.00, by M.Meany ***
		NOLIST


*****
*****	Get a block of memory
*****

; Entry		d0=size of block required
;		d1=requirements as per AllocMem() or see below

; Exit		d0=addr of block or 0 on error

; Corrupt	d0

GetMem		PUSH		d1-d2/a0/a1/a6

; Add size of mem header onto block and request it. Exit if not obtained.

		add.l		#ln_SIZEOF,d0		bump block size
		move.l		d0,d2			save a copy
		or.l		#CLEARMEM,d1		make sure block clear
		move.l		$4,a6			SysBase
		jsr		-$0c6(a6)		AllocMem()
		tst.l		d0			all ok ?
		beq.s		.done

; Add this block to the start of the list

		lea		_mem_list,a0		list
		move.l		d0,a1			node
		ADDHEAD					add node

		move.l		d2,ln_size(a1)		block size

; Correct address of memory block by stepping over node structure

		move.l		a1,d0
		add.l		#ln_SIZEOF,d0		correct address

; All done so return

.done		PULL		d1-d2/a0/a1/a6
		rts

*****
*****	Free a block of memory
*****

; Entry		d0=address of block to free

; Exit		d0=0 if all ok, else returns addr of block.

; Corrupt	d0

; Frees a block of memory allocated by a call to GetMem

FreMem		PUSH		d1-d2/a0/a1/a6
		move.l		d0,-(sp)		save block address

; Make sure some memory has been allocated

		lea		_mem_list,a0		a0->list head
		TSTLIST					is list empty?
		beq		.done			yes, exit!

; Remove the node from the list. Size of structure must first be subtracted
;from the address supplied.

		sub.l		#ln_SIZEOF,d0		correct addr
		move.l		d0,a0			a0->node
		REMOVE					remove it 

; Now release the memory

		move.l		d0,a1			a1->block
		move.l		ln_size(a1),d0		size of block
		move.l		$4,a6
		jsr		-$0d2(a6)		FreeMem()

; Clear return value to signal success

		clr.l		4(sp)
		
.done		move.l		(sp)+,d0
		PULL		d1-d2/a0/a1/a6
		rts

*****
*****	Free all memory allocated by program
*****

; Entry		None

; Exit		None

; Corrupt	None

FreeAllMem	PUSH		d0/d1/a0/a1/a6
		
.loop		lea		_mem_list,a0
		IFEMPTY		.done
		
		move.l		(a0),d0
		add.l		#ln_SIZEOF,d0
		bsr.s		FreMem
		bra.s		.loop

.done		PULL		d0/d1/a0/a1/a6
		rts

*****
*****	Required data is simply an empty list
*****

_mem_list	dc.l		.list_end
.list_end	dc.l		0
		dc.l		_mem_list
		
