
; A program to decrunch PowerPacker text files from a directory on DF0: to
;a directory on DF1:. This program utalises both powerpacker.library and
;arp.library, both should be in the libs directory of the sys: disc.

; © M.Meany, Jan 1991.

; Written to make decrunch scripts easier to compile and update.

; Many thanks to the writers of arp.library and to Nico Francois, writer of
;PowerPacker and powerpacker.library.

; Full powerpacker.library and arp.library doc's available from me at:

;		1 Cromwell Road,
;		Southampton,
;		Hant's.
;		SO1 2JH


		incdir		"sys:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		incdir		source9:include/
		include		powerpacker_lib.i
		include		ppbase.i
		include		"arpbase.i"

ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM

CALLNICO	macro
		move.l		_PPBase,a6
		jsr		_LVO\1(a6)
		endm

*****************************************************************************

; The main routine that opens and closes things
;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt stack
		move.l		a6,_ArpBase	;store arpbase

;--------------	Save directory name supplied from CLI

		move.b		#0,-1(a0,d0)
		move.l		a0,a5			store dir pointer

;--------------	Check CLI parameters

		cmpi.l		#'df0:',(a0)
		beq.s		goforit
		bsr		usage
		bra		error_NOMEM
	
;--------------	Assign memory for variables

goforit		move.l		#vars_SIZEOF,d0
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLARP		ArpAllocMem
		move.l		d0,a4
		tst.l		d0
		beq		error_NOMEM

		move.l		a5,dirname(a4)		save dir pointer

;--------------	Initialise list for file names

		bsr		init_list

;--------------	Assign some memory for file info block

		move.l		#fib_SIZEOF,d0
		CALLSYS		DosAllocMem
		move.l		d0,info_buffer(a4)
		beq		error_NOINFOBUF
		
;-------------- Lock required directory

		move.l		dirname(a4),d1
		move.l		#-2,d2
		CALLSYS		Lock
		move.l		d0,dir_key(a4)
		beq		error_NOKEY
		
;--------------	Get file info block for this directory.

		move.l		d0,d1		d1=directory key
		move.l		info_buffer(a4),d2	d2=addr of memory for fib
		CALLSYS		Examine		get fib
		tst.l		d0
		beq		error_CANTEXAM
		
;--------------	Extract all entries in directory.

examine_loop	move.l		dir_key(a4),d1
		move.l		info_buffer(a4),d2
		CALLSYS		ExNext
		tst.l		d0
		beq.s		got_list
		
;--------------	If this entry is a file add it to list

		move.l		info_buffer(a4),a0
		
		tst.l		fib_DirEntryType(a0)
		bpl.s		examine_loop
		
		move.l		dirname(a4),a0
		lea		filename(a4),a1
		
.next		tst.b		(a0)
		beq.s		.ok
		move.b		(a0)+,(a1)+
		bra.s		.next
		
.ok		move.b		#'/',(a1)+
		move.l		info_buffer(a4),a0
		adda.l		#8,a0
		
.next1		tst.b		(a0)
		beq.s		.ok1
		move.b		(a0)+,(a1)+
		bra.s		.next1
		
.ok1		move.b		#0,(a1)+
		move.l		a1,d0
		lea		filename(a4),a0
		sub.l		a0,d0
		
		bsr		add_node
		
		bra		examine_loop		

;--------------	Create directory on df1:

got_list	move.l		dirname(a4),a0
		move.b		#'1',2(a0)
		move.l		a0,d1
		CALLARP		CreateDir
		move.l		d0,d1
		beq		error_CANTEXAM
		CALLSYS		UnLock
		
;--------------	Decrunch the files

		lea		ppname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_PPBase
		beq.s		error_CANTEXAM

		lea		start_list(a4),a5

decrunch_loop	move.l		node.next(a5),a5
		tst.l		node.next(a5)
		beq		.all_done
		
		move.l		a5,a0
		add.l		#node.data,a0

		bsr		do_pp

.no_file	bra		decrunch_loop

.all_done	move.l		_PPBase,a1
		CALLEXEC	CloseLibrary
		
;--------------	Unlock the directory

error_CANTEXAM	move.l		dir_key(a4),d1
		CALLARP		UnLock
		
;--------------	Free fib buffer memory

error_NOKEY	move.l		info_buffer(a4),a1
		CALLSYS		DosFreeMem
		
;--------------	Free the list used to store file names

error_NOINFOBUF	bsr		clear_list
		
;--------------	Close ARP library

error_NOMEM	move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		
;--------------	Finish

		rts
		
		
***************	Subroutines

;--------------	Decrunch file to memory

do_pp		moveq.l		#DECR_POINTER,d0
		moveq.l		#0,d1
		lea		buffer(a4),a1
		lea		length(a4),a2
		move.l		d1,a3
		CALLNICO	ppLoadData
		tst.l		d0
		bne.s		.failed
		
		move.l		a5,a0
		add.l		#node.data,a0
		move.b		#'1',2(a0)

		move.l		a0,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d1
		move.l		d0,d5
		beq		.cant_open
		
		move.l		buffer(a4),d2
		move.l		length(a4),d3
		CALLSYS		Write
		
		move.l		d5,d1
		CALLSYS		Close
		
.cant_open	move.l		buffer(a4),a1
		move.l		length(a4),d0
		CALLEXEC	FreeMem
		
.failed		rts
		
;--------------	Display usage instructions

usage		CALLARP		Output
		move.l	 	d0,d1
		
		move.l		#usage_text,d2
		move.l		#usage_len,d3
		CALLARP		Write
		
		rts
		
;--------------	Program Data Area

		include		source9:m.meany/decrunch/list.s
		include		source9:m.meany/decrunch/variables
