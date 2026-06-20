


* This program demonstrates use of Exec list & node structures
* to produce a sorted directory list. The routines can be lifted
* out to use within, for example, a DPaint-type file requester
* which was my original motivation for writing this code. After
* I wrote this, I discovered MinLists and MinNodes and other
* goodies, so if you wish to modify this, do so. Use the Exec
* DOC file on the CLUBINFO disc to get the requisite information.



		opt	d+



		include	source_1:include/my_exec.i
		include	source_1:include/my_dos.i


* Definition of my variable block. Note to all club members:
* my standard practice for programming is to define a variable
* block using RS defs and access it via A6. Because of this, I
* mutated the standard GenAm include files, particularly the
* function calling macros, to take account of this (mainly to
* save A6 before putting library bases there, then recover it
* after the call). Also I have my very own file for accessing
* the hardware.


		rsreset

dos_base		rs.l	1	;base for dos.library

con_ihandle	rs.l	1	;console input handle
con_ohandle	rs.l	1	;console output handle

dir_start	rs.l	1	;block of memory reserved for dir list
dir_size		rs.l	1	;size of reserved block

dir_dlist	rs.l	1	;pointer to list of subdir's
dir_flist	rs.l	1	;pointer to list of files

dir_info		rs.l	1	;reserved memory for dir strings
dir_infolen	rs.l	1	;memory block length

dir_count	rs.l	1	;no of entries found

dir_name		rs.l	1	;ptr to name of current dir
dir_lock		rs.l	1	;directory lock variable

vars_sizeof	rs.w	0


* main program begins here. My ancestry as a C programmer at
* university (AAAGGHH!) betrays itself here!


main		lea	vars(pc),a6

		lea	dos_name(pc),a1	;want dos library
		CALLEXEC	OldOpenLibrary	;Gimme her address
		move.l	d0,dos_base(a6)	;valid?
		beq	cock_up_1	;nope-exit gracefully

		move.l	#32768,d0
		move.l	d0,dir_size(a6)
		move.l	#MEMF_PUBLIC,d1	;gimme some memory
		CALLEXEC	AllocMem
		move.l	d0,dir_start(a6)
		beq	cock_up_2

		move.l	#260,d0
		move.l	d0,dir_infolen(a6)
		move.l	#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l	d0,dir_info(a6)
		beq	cock_up_3

* Now I want file handles for CLI console, input and output,
* so I can list my directory once I've created the sorted list

		CALLDOS	Output
		move.l	d0,con_ohandle(a6)
		beq.s	cock_up_4

		CALLDOS	Input
		move.l	d0,con_ihandle(a6)
		beq.s	cock_up_4

		bsr	get_dir_name	;does what it says

		lea	test_dir(pc),a0	;directory info
		move.l	a0,dir_name(a6)
		bsr	do_dir		;do sorted directory list

		lea	dirmsg(pc),a1		;tell user I'm
		move.l	con_ohandle(a6),d1	;listing subdirectories
		bsr	prints

		move.l	dir_dlist(a6),a0	;ptr to head of dirs list
		lea	showentry(pc),a5	;this function prints out entry
		bsr	traverse		;go do it!

		lea	filmsg(pc),a1		;tell user I'm
		move.l	con_ohandle(a6),d1	;listing files
		bsr	prints

		move.l	dir_flist(a6),a0	;ptr to head of files list
		lea	showentry(pc),a5	;this function prints out entry
		bsr	traverse		;go do it!

* This point should be reached only after the list traversals.
* If something went wrong, no dir lists will be printed out.
* Instead, the program will cease operations quietly.

cock_up_4	move.l	dir_info(a6),a1
		move.l	dir_infolen(a6),d0
		CALLEXEC	FreeMem

cock_up_3	move.l	dir_start(a6),a1
		move.l	dir_size(a6),d0
		CALLEXEC	FreeMem

cock_up_2	move.l	dos_base(a6),a1
		CALLEXEC	CloseLibrary

cock_up_1	moveq	#0,d0		;DOS return code:ALWAYS do this!
		rts


;do_dir(a6) a6 = ptr to main vars

;generate sorted directory list


do_dir		moveq	#0,d0
		move.l	d0,dir_count(a6)		;clear no of processed entries

		move.l	dir_name(a6),d1		;get lock for this dir
		move.l	#ACCESS_READ,d2
		CALLDOS	Lock
		move.l	d0,dir_lock(a6)
		beq	done_dir			;can't do it

		move.l	d0,d1
		move.l	dir_info(a6),d2
		CALLDOS	Examine			;get first entry (should be directory name)

		move.l	dir_start(a6),d7		;where text goes


;here construct unsorted list of text entries from disk directory,
;and prefix with 0/1 byte for file/dir type entry


do_dir_l1	move.l	dir_lock(a6),d1
		move.l	dir_info(a6),d2
		CALLDOS	ExNext			;get all file entries
		tst.l	d0
		beq.s	do_dir_b1		;no more entries

		move.l	d7,a0		;get start of text area
		move.l	dir_info(a6),a1	;fileinfoblock
		
		move.l	4(a1),d0		;entry type (-=file,+=dir)
		rol.l	#1,d0		;get sign bit
		and.b	#1,d0		;in bit 0
		eor.b	#1,d0		;and invert
		move.b	d0,(a0)+		;0=file, 1=dir
		beq.s	do_dir_noprefix

		lea	dir_prefix(pc),a3

do_dir_pl1	move.b	(a3)+,(a0)+	;
		bne.s	do_dir_pl1
		subq.l	#1,a0
		
do_dir_noprefix	addq.l	#8,a1		;point to filename

do_dir_l2	move.b	(a1)+,(a0)+
		bne.s	do_dir_l2	;copy filename across

		addq.l	#1,dir_count(a6)	;update number of entries
		move.l	a0,d7		;save current text ptr

		bra.s	do_dir_l1	;and do all of them

do_dir_b1	nop			;do an IoErr() here?


;now, longword align pointer to list structures at start
;(only for safety's sake), then set up the list header
;structures.


do_dir_b2	move.l	d7,d0
		and.b	#3,d0		;ensure LONGWORD aligned!
		beq.s	do_dir_b3	;here, it is-go on
		addq.l	#1,d7		;else re-align
		bra.s	do_dir_b2	;and check again

do_dir_b3	move.l	d7,a0
		move.l	a0,dir_dlist(a6)	;here is where dirs list starts

		lea	lh_tail(a0),a2	;initialise empty list
		move.l	a2,lh_head(a0)
		clr.l	(a2)
		move.l	a0,lh_tailpred(a0)
		clr.b	lh_type(a0)
		move.b	#$FF,lh_pad(a0)	;signals DIRS list

		lea	lh_sizeof(a0),a0
		move.l	a0,dir_flist(a6)	;here is where files lists starts

		lea	lh_tail(a0),a2	;initialise empty list
		move.l	a2,lh_head(a0)
		clr.l	(a2)
		move.l	a0,lh_tailpred(a0)
		clr.b	lh_type(a0)
		move.b	#$FE,lh_pad(a0)	;signals FILES list

		move.l	dir_start(a6),a4	;point to texts
		move.l	dir_count(a6),d7	;no. of entries found

		lea	lh_sizeof(a0),a1	;a1 points to potential node


;here perform sorted list construction


do_dir_l3	clr.b	ln_type(a1)	;my node type=0
		clr.b	ln_pri(a1)	;priority doesn't matter
		move.b	(a4)+,d0		;point to text
		move.l	a4,ln_name(a1)	;enter text pointer

do_dir_l4	tst.b	(a4)+		;skip to end of string
		bne.s	do_dir_l4	;& then to next string

		move.l	dir_flist(a6),a0	;files list
		tst.b	d0		;type=file?
		beq.s	do_dir_b4	;yes
		move.l	dir_dlist(a6),a0	;else dirs list


;here check if list empty. If so, just put text straight in.
;if nonempty list, find where to put it (sort at input)


do_dir_b4	move.l	a0,d6		;preserve list head ptr
		move.l	a1,d5		;preserve node pointer
		move.l	lh_head(a0),a2	;check list pointer
		tst.l	(a2)		;empty list?
		bne.s	do_dir_b5	;no so sort input


;here blast text straight into whatever list is selected


do_dir_b6	CALLEXEC	AddTail		;put node in list

do_dir_b7	move.l	d5,a1		;recover node pointer
		lea	ln_sizeof(a1),a1	;next node
		move.l	d6,a0		;which list?

		subq.l	#1,d7		;finished all of them?
		bne.s	do_dir_l3	;continue scan if not

done_dir		rts			;finito!!!


;here sort at input. a0/d6 = list head ptr, a1/d5 = new node ptr


do_dir_b5	move.l	lh_head(a0),a2	;pointer to 1st node in list
		move.l	ln_name(a1),a3	;new node text

do_dir_b8	move.l	a2,d4		;save pointer to current node in list
		beq.s	do_dir_b6	;end of list-handle separately
		move.l	ln_name(a2),a2	;get its text pointer
		bsr	cmpstr		;compare strings
		bls.s	do_dir_b9	;can go ahead and insert


;here new node text > current node text, so check successor


		move.l	d4,a2
		move.l	ln_succ(a2),a2	;get successor in list
		bra.s	do_dir_b8	;and resume scan


;here new node text < current node text, so insert into list


do_dir_b9	move.l	d4,a2		;pointer to current node
		move.l	ln_pred(a2),a2	;correct predecessor!
		CALLEXEC	Insert		;insert new node before current
		bra.s	do_dir_b7	;and back for more


;cmpstr(a2,a3) -> CCR
;a2,a3 = ptrs to strings to compare
;returns result in ZC flags

;convention	: a2 points to SOURCE string
;		: a3 points to DESTINATION string

;CCR gives result of DESTINATION compare SOURCE
;in the same way as Bcc instructions, just to keep
;things logically consistent.


cmpstr		movem.l	a2/a3,-(sp)	;save string ptrs
cmpstr_1		move.b	(a3),d0
		move.b	(a2),d1
		and.b	#%11011111,d0	;make both chars
		and.b	#%11011111,d1	;upper case for comparison
		cmp.b	d1,d0		;chars equal?
		bne.s	cmpstr_2		;no
		tst.b	(a2)		;end of string?
		beq.s	cmpstr_2		;yes, done
		addq.l	#1,a2		;point to next char
		addq.l	#1,a3		;in each string
		bra.s	cmpstr_1		;and continue scan
cmpstr_2		movem.l	(sp)+,a2/a3	;recover string ptrs
		rts			;CCR contains result
		


;traverse(a0,a5) a0 = ptr to list header structure
;a5 = ptr to a function to execute when a node is found
;if a5 = NULL, no function executed (hence this routine
;becomes a very time-consuming NOP function)

;this allows lists to be traversed & then a function of the
;user's choice to be performed upon that node if required.
;A bit of knowledge about EXEC lists does, however, come in
;very handy...


traverse		move.l	(a0),d0		;check pointer
		beq	traverse_done	;finished!
		move.l	d0,a0		;point to node

		move.l	a0,-(sp)		;save pointer

		move.l	a5,d0		;function exists?
		beq.s	dont_doit	;no, so don't do it!
		jsr	(a5)		;execute required function
dont_doit	move.l	(sp)+,a0		;get current pointer back
		bra.s	traverse		;and continue

traverse_done	rts


;prints(a1,d1) a1 = ptr to string to print
;d1 = output file/device handle

prints		bsr	getlen
		move.l	d7,d3		;length of string to write
		move.l	a1,d2		;ptr to string
		CALLDOS	Write
		rts


;showentry(a0,a6) a6 = ptr to main vars
;a0 =ptr to node entry
;displays entry name on console


showentry	move.l	ln_name(a0),a1
		move.l	con_ohandle(a6),d1
		bsr	prints

		lea	crlf(pc),a1
		move.l	con_ohandle(a6),d1
		bsr	prints

		rts


;getlen(a1) -> d7
;a1 = ptr to string
;returns length of string for printing in d7


getlen		move.l	a1,-(sp)
		moveq	#0,d7

getlen_l1	tst.b	(a1)+
		beq.s	getlen_b1
		addq.l	#1,d7
		bra.s	getlen_l1

getlen_b1	move.l	(sp)+,a1
		rts

get_dir_name	lea	imsg(pc),a1
		move.l	con_ohandle(a6),d1
		bsr	prints
		lea	test_dir(pc),a0
		move.l	a0,d2
		move.l	con_ihandle(a6),d1
		move.l	#128,d3
		CALLDOS	Read
		lea	test_dir(pc),a0
get_dname_1	cmp.b	#" ",(a0)
		bcs.s	get_dname_2
		addq.l	#1,a0
		bra.s	get_dname_1
get_dname_2	clr.b	(a0)
		rts


* where my variable block goes


vars		ds.b	vars_sizeof
		even


* constant strings


dos_name		dc.b	"dos.library",0

crlf		dc.b	13,10,0

dirmsg		dc.b	"Directories :",13,10,10,0

filmsg		dc.b	"Files :",13,10,10,0

imsg		dc.b	13,10,"Enter Required Directory : ",0

dir_prefix	dc.b	"[DIR] ",0

test_dir		ds.b	128




