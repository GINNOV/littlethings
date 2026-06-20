
; New version of words. © M.Meany, May 91.

; This version reads in the glossary from files of 5000 words.

		opt		o+,ow-

		incdir		sys:include/
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		misc/ppbase.i
		include		misc/powerpacker_lib.i
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		
;**************	CONSTANTS

ciaapra		equ		$bfe001
GLOS_SIZE	equ		5005		words in each sub glossary


;*****************************************

CALLSYS    	MACRO			;added CALLSYS macro - using CALLARP
		IFGT	NARG-1       	;CALLINT etc can slow code down and  
		FAIL	!!!         	;waste a lot of memory  S.M. 
		ENDC                 
		JSR	_LVO\1(A6)
		ENDM

CALLNICO	MACRO			;Simplifies calls to powerpacker
		move.l	_PPBase,a6	;library. M.M.
		jsr	_LVO\1(a6)
		ENDM

;******************************************


;** OPENARP moved to front as it will print a message on the CLI then **
;**   return to easystart if it can't find the ARP library ,we don't  **
;**                need to do any error checking of our own           **

start		OPENARP				;use arp's own open macro
		movem.l		(sp)+,d0/a0	;restore d0 and a0 as the
						;the macro leaves these on
						;the stack causing corrupt
						;stack

		move.l		a6,_ArpBase	;store arpbase
		
;--------------	the ARP library opens and uses the graphics and intuition 
;		libs and it is quite legal for us to get these bases for 
;		our own use

		move.l		IntuiBase(a6),_IntuitionBase
		move.l		GFXBase(a6),_GfxBase

;--------------	Open PowerPacker Library

		lea		PPName,a1	a1->library name
		moveq.l		#0,d0		any version
		CALLEXEC	OpenLibrary	and open it
		move.l		d0,_PPBase	save base pointer
		beq		Ende		quit if failure

;--------------	Libs now open and base pointers set, so get on with it!

		bsr		Init		get mem for vars
		tst.l		d0		all ok ?
		beq		quit_fast	finish if not

		bsr		init_list	initialise list struct

		bsr		GetLineMem	get mem for line list
		tst.l		d0		all ok ?
		beq		quit_fast	finish if not

		bsr		ReadGloss	read in all words
		tst.l		d0		all ok ?
		beq		quit_fast	finish if not

		bsr		GoForWord

		bsr		FreeGloss	free mem for glossaries

		bsr		clear_list	free mem tied in list

;--------------	Close PowerPacker library

quit_fast	move.l		_PPBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close it

;--------------	All done so close ARP and finish

Ende		move.l		_ArpBase,a1	a1->lib base
		CALLEXEC	CloseLibrary	and close ARP

		rts
*****************************************************************************
**************************** SUBROUTINES ************************************
*****************************************************************************

;--------------
;--------------	Subroutine to obtain memory for all variables
;--------------

; A block of memory is obtained for all variables used by the program. The
;address of this memory is then put into register a4 so a variable. All
;references to a variable are then made using an offset into this memory
;block.

;Exit		d0=0 implies memory not available
;		a4-> memory

Init		move.l		#Vars_SIZEOF,d0	d0=number of bytes
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 requirments
		CALLARP		ArpAllocMem	get the block
		move.l		d0,a4		a4->vars mem

;--------------	Initialise IntuiText structures

		lea		RDFbuf(a4),a0
		move.l		a0,KeyTextPtr
		move.l		a0,ListTextPtr

		rts

;--------------
;--------------	Subroutine to obtain memory for line list
;--------------

; Subroutine counts the number of sub-glossaries available and reserves
;a block of memory for later use to hold pointers for each line in each
;file.

;Exit	d0= 0 implies an error occured ie no glossaries or no memory
;	d7= number of glossaries available

GetLineMem	moveq.l		#0,d7		clear counter
		lea		glosname,a5	set pointer to glossary

;--------------	Count available sub glossaries

.loop		move.l		a5,d1		d1=addr of filename
		moveq.l		#ACCESS_READ,d2	d2=mode of access
		CALLARP		Lock		find file
		tst.l		d0		key found ?
		beq.s		.rt		if not we have finished

		addq.l		#1,d7		bump counter
		addq.b		#1,glos_ext	alter gloss extension

		move.l		d0,d1		d1=key 
		CALLSYS		UnLock		release file
		bra.s		.loop
.rt		cmp.l		#2,d7
		ble.s		.done
		subq.l		#1,d7
		bra		.rt

.done		tst.l		d7		check a glossary is here
		beq.s		.error		if not quit

		move.l		#GLOS_SIZE,d0	d0=num of lines in file
		mulu.w		#6,d0		x by bytes per line
		mulu.w		d7,d0		x by num of files

		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1  requirements
		CALLSYS		ArpAllocMem	get mem for line list
		move.l		d0,line_list(a4) save pointer to list

.error		move.b		#'A',glos_ext	reset glossary name
		rts				and return

;--------------
;--------------	Subroutine to read in all glossaries
;--------------

; All glossaries are read in and a line list is generated. Each glossary is
;loaded into its own area of memory, the line list is used to link all the
;individual blocks together. The address and length of each memory block is
;stored in a seperate table, created using ArpAllocMem.

;Entry		d7= number of available glossaries

;Exit		d0=0 implies an error has occurred and no words loaded

ReadGloss	move.l		d7,GlosCount(a4)	store value

		bsr		OpenIntro	display intro pic

;--------------	Get memory for table to store addr + len of glossaries

		move.l		d7,d0		d0=num of glossaries
		asl.l		#3,d0		x8, 2 long words each
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1 
		CALLARP		ArpAllocMem	get mem block
		move.l		d0,GlosMemTable(a4) store addr of table
		beq		.error		leave if error

		move.l		d0,a5		a5->table
		move.l		d7,d6		init counter in d6
		subq.l		#1,d6		correct for DBRA
		move.l		line_list(a4),d5 d5=addr of line list

;--------------	Read in next glossary

.outer		lea		glosname,a0	a0->filename
		moveq.l		#DECR_POINTER,d0 flag for flash pointer
		moveq.l		#0,d1
		lea		buffer(a4),a1	a1->store for buf address
		lea		buf_len(a4),a2	a2->store for buf length
		move.l		d1,a3
		CALLNICO	ppLoadData	read file
		tst.l		d0		all ok ?
		bne.s		.error	quit if error

;--------------	Save address in table and bump glossary name

		move.l		buffer(a4),(a5)+ save this blocks addr
		move.l		buf_len(a4),(a5)+ and len in table
		addq.b		#1,glos_ext

;--------------	Add lines in this file to line list

		move.l		buf_len(a4),d0	d0=len of file
		moveq.l		#0,d1		d1=line len counter
		moveq.l		#$0a,d2		d2=LINE FEED
		moveq.l		#1,d3		d3=1 ( for fast addittion )
		move.l		d1,d4		d4=0 ( fast clearing )

		move.l		buffer(a4),a0	a0->file
		move.l		d5,a1		a1->next entry in line-list
		
		move.l		a0,(a1)+	save addr of 1st line

.inner		add.l		d3,d1		bump line len counter
		cmp.b		(a0)+,d2	end of line ?
		bne.s		.not_end	nope, so branch
		move.b		d4,-1(a0)	NULL terminate all lines
		move.w		d1,(a1)+	save line length
		move.l		d4,d1		reset counter
		move.l		a0,(a1)+	save addr of next line
.not_end	dbra		d0,.inner	until end of file

		move.l		a1,d5		get ptr to list in d5
		subq.l		#4,d5		correct for last entry

		dbra		d6,.outer	loop for all glossaries

		move.l		line_list(a4),d0
		sub.l		d0,d5
		move.l		d5,d0
		moveq.l		#6,d1
		CALLARP		LDiv
		move.l		d0,NumWords(a4)

.error		bsr		CloseIntro	close intro window
		rts


;--------------
;--------------	Subroutine to open introduction window
;--------------

OpenIntro	lea		IntroWin,a0
		CALLINT		OpenWindow
		move.l		d0,intro.ptr(a4)
		beq.s		.error

		move.l		d0,a0
		move.l		wd_RPort(a0),a0
		lea		IntroImage,a1
		moveq.l		#4,d0
		moveq.l		#2,d1
		CALLINT		DrawImage

.error		rts

;--------------
;--------------	Subroutine to close introduction window
;--------------

CloseIntro	move.l		intro.ptr(a4),d0
		beq.s		.error

		move.l		d0,a0
		CALLINT		CloseWindow

.error		rts

;--------------
;--------------	Subroutine to release all glossary memory
;--------------

FreeGloss	move.l		GlosMemTable(a4),a3	a3->table
		move.l		GlosCount(a4),d7	d7=num of files
		subq.l		#1,d7			adjust for DBRA		

.loop		move.l		(a3)+,a1	a1->mem block
		move.l		(a3)+,d0	d0= length of block
		beq.s		.error		dont fuck up !
		CALLEXEC	FreeMem		and release it

.error		dbra		d7,.loop	for all files
		rts


		incdir		source:m.meany/words/
		include		subs_1.i
		include		subs_2.i
		include		subs_3.i
		include		about.i
		include		vars.i

