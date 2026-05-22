		opt 		o+,ow-

		incdir		"df0:include/"
		include		"exec/exec_lib.i"
		include		"exec/exec.i"
		include		"exec/ports.i"
		include		"devices/console_lib.i"
		include		"devices/inputevent.i"
		include		"intuition/intuition_lib.i"
		include		"intuition/intuition.i"
		include		"libraries/dos.i"
		include		"libraries/dosextens.i"
		include		"graphics/gfx.i"
		include		"graphics/graphics_lib.i"
		include		"misc/arpbase.i"

; Include easystart to allow a Workbench startup.

		include		"misc/easystart.i"
		
ciaapra		equ		$bfe001
NULL		equ		0

;*****************************************

CALLSYS    MACRO		;added CALLSYS macro - using CALLARP
	IFGT	NARG-1       	;CALLINT etc can slow code down and  
	FAIL	!!!         	;waste a lot of memory  S.M. 
	ENDC                 
	JSR	_LVO\1(A6)
	ENDM
		
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

		move.l		IntuiBase(a6),_IntuitionBase

		move.l		GfxBase(a6),_GfxBase
		
		bsr		Initialise
	
		beq.s		.end
		
		bsr		read_dictionary
		
		bsr		find_words
		
.end		bsr		clean_up
		
		rts
		
;--------------
;-------------- Subroutines
;--------------

;-------------- Initialise data 

Initialise	move.l		#vars_SIZEOF,d0
		move.l		#MEMF_CLEAR!MEMF_PUBLIC,d1
		CALLARP		ArpAllocMem
		move.l		d0,a4
		beq.s		.error
		
		bsr		init_list

		lea		input_string(a4),a0
		move.l		a0,str_gadgSInfo
	
		moveq.l		#1,d0
		
.error		rts
		
;-------------- Read the dictionary from disc into a linked list

read_dictionary	lea		dictionary_name,a5
		bsr		load_file
		rts
		
;-------------- Get a string from the user and display all matches.

find_words	bsr		OpenWindow
		beq.s		.error
		bsr		WaitForMsg
.error		bsr		CloseWindow
		rts

;-------------- Clear the list and close libraries.

clean_up	bsr		clear_list

		move.l		_ArpBase,a1
		CALLEXEC	CloseLibrary
		
		rts

;--------------	Open the window and display text/gadget

OpenWindow	move.l		#CON_Name,d1
		move.l		#MODE_OLDFILE,d2
		CALLARP		Open
		move.l		d0,con_handle(a4)
		beq.s		.error
		
		move.l		d0,d1
		move.l		#my_text,d2
		move.l		#mytext_len,d3
		CALLSYS		Write

		lea		MatchWindow,a0
		CALLINT		OpenWindow
		move.l		d0,window.ptr(a4)
		beq.s		.error
		move.l		d0,a0
		move.l		wd_RPort(a0),window.rp(a4)
		move.l		wd_UserPort(a0),window.up(a4)
		
		move.l		window.rp(a4),a0
		lea		IText1,a1
		moveq.l		#0,d0
		move.l		d0,d1
		CALLINT		PrintIText
		
		lea		str_gadg,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLINT		ActivateGadget
		
		moveq.l		#1,d1
		
.error		rts

;-------------- Wait for user to take some action

WaitForMsg	move.l		window.up(a4),a0	a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.up(a4),a0	a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.w		im_Code(a1),d3	d3=key code or menu details
		move.w		im_Qualifier(a1),d4 d4=special key details
		move.l		im_IAddress(a1),d7
		CALLEXEC	ReplyMsg	answer os or it get angry
		cmp.l		#CLOSEWINDOW,d2	window closed ?
		bne.s		.check_gadg	if not check for gadget
		bra		.all_over	else quit
.check_gadg	cmp.l		#GADGETUP,d2	gadget_pressed ?
		bne.s		WaitForMsg

		move.l		window.ptr(a4),a0
		lea		str_gadg,a1
		CALLINT		RemoveGadget

; Convert input to upper case

		bsr		ucase

; Find and display all words that match pattern

		bsr		match_word
		
; Clear the string gadget buffer
		
		lea		input_string(a4),a0
		move.b		#0,(a0)+
		moveq.l		#19,d0
.loop		move.b		#' ',(a0)+
		dbra		d0,.loop

; Remove text from window

		move.l		window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen
		
		move.l		window.rp(a4),a1
		move.l		#139,d0
		moveq.l		#43,d1
		move.l		#139+268,d2
		moveq.l		#43+8,d3
		CALLGRAF	RectFill

; Restore gadget structure

		lea		cur_pos,a0
		move.l		#20,(a0)+
		move.l		#0,(a0)+
		move.w		#0,(a0)
		
; Re-activate the string gadget
		
		move.l		window.ptr(a4),a0
		lea		str_gadg,a1
		moveq.l		#-1,d0
		CALLINT		AddGadget

		lea		str_gadg,a0
		move.l		window.ptr(a4),a1
		move.l		#0,a2
		CALLINT		ActivateGadget
		
		bra		WaitForMsg
		
.all_over	rts

;--------------	Close the window

CloseWindow	move.l		window.ptr(a4),a0
		move.l		a0,d0
		beq.s		.error
		CALLINT		CloseWindow

		move.l		con_handle(a4),d1
		beq.s		.error
		CALLARP		Close

.error		rts
	
;--------------	Converts input string to upper case.

ucase		lea		input_string(a4),a0
	
		tst.b		(a0)
		beq.s		.error
		
.loop		cmpi.b		#'a',(a0)+
		blt.s		.ok
		
		cmp.b		#'z',-1(a0)
		bgt.s		.ok
		
		subi.b		#$20,-1(a0)
		
.ok		tst.b		(a0)
		bne.s		.loop
		
.error		rts

;--------------	Finds all words in dictionary that match users pattern
	
match_word	lea		input_string(a4),a0
		tst.b		(a0)
		beq		eexit

		move.l		#0,fflag(a4)
		
		move.l		a0,-(sp)
		move.l		con_handle(a4),d1
		move.l		#seperator,d2
		move.l		#sep_len,d3
		CALLARP		Write
		move.l		(sp)+,a0
		
		move.l		a0,a1
		moveq.l		#0,d0
.loop		addq.l		#1,d0
		cmpi.b		#0,(a1)+
		bne.s		.loop
		move.b		#$0a,-1(a1)
		move.b		#$0a,(a1)
		
		move.l		con_handle(a4),d1
		move.l		a0,d2
		move.l		d0,d3
		addq.l		#1,d3
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLSYS		Write
		
		move.l		(sp)+,a0
		move.l		(sp)+,d0

		swap		d0
		bsr		bubble
		lea		input_string(a4),a1
		moveq.l		#0,d2
		swap		d0
		move.b		d0,d2

		lea		start_list(a4),a0
		move.l		node.next(a0),a0
		
.check_next	movem.l		d2/a0-a1,-(sp)
		
		cmp.b		node.len(a0),d2
		blt		.dont_print
		
		adda.l		#node.data,a0
		move.l		d2,d0
		subq.l		#1,d0
		lea		pattern(a4),a2
.copy_loop	move.b		(a0)+,(a2)+
		dbra		d0,.copy_loop
		
		lea		pattern(a4),a0
		bsr		bubble
		
		lea		pattern(a4),a0
		bsr		can_make
		tst.l		d0
		bne.s		.dont_print
		bsr		print_match
.dont_print	movem.l		(sp)+,d2/a0-a1

		move.b		node.len(a0),d1
		addi.b		#node.data-1,d1
		move.b		#$0A,0(a0,d1)

		move.l		node.next(a0),a0
		tst.b		node.len(a0)
		bne.s		.check_next

		tst.l		fflag(a4)
		bne.s		eexit
		
		move.l		con_handle(a4),d1
		move.l		#sorry,d2
		move.l		#sorry_len,d3
		CALLARP		Write
		
eexit		rts
	
;--------------	Print a word that matches users pattern in console window

print_match	move.l		(sp)+,a2
		movem.l		(sp)+,d0/a0-a1
		movem.l		d0/a0-a1,-(sp)
		move.l		a2,-(sp)
		
		move.b		node.len(a0),d1
		move.l		d1,d0
		addi.b		#node.data-1,d1
		move.b		#$09,0(a0,d1)
		
		move.l		con_handle(a4),d1
		move.l		a0,d2
		add.l		#node.data,d2
		move.l		d0,d3
		CALLARP		Write
		
		move.l		#1,fflag(a4)
		
		rts

;--------------	Acending sort routine. Sorts a list of bytes.

; Entry		a0->start of null or $0A terminated list

; Exit

; Corrupted	a0,d0 bflag

bubble		move.l		#0,bflag(a4)

		tst.b		(a0)
		beq.s		.error

		move.l		a0,-(sp)

.loop		tst.b		1(a0)
		beq.s		.done
		cmpi.b		#$0a,1(a0)
		beq.s		.done
		
		move.b		(a0)+,d0
		cmp.b		(a0),d0
		ble.s		.ok
		move.l		#1,bflag(a4)
		move.b		(a0),-1(a0)
		move.b		d0,(a0)
		
.ok		bra		.loop

.done		move.l		(sp)+,a0
		tst.l		bflag(a4)
		bne.s		bubble
		
.error		rts

;--------------	Checks if current list entry can be formed from input.

can_make	moveq.l		#0,d0
.loop		move.b		(a0),d1
.next		cmp.b		(a1)+,d1
		beq.s		.got_char
		cmpi.b		#$0a,(a1)
		beq.s		.fail
		bra.s		.next
		
.got_char	addq.l		#1,a0
		cmpi.b		#$0a,(a0)
		bne.s		.loop
		rts
		
.fail		moveq.l		#1,d0
		rts

;--------------
;-------------- Include Other Required Files
;--------------

		include		workdisk:acc_source/list.s

		include		workdisk:m.meany/makewords/variables
		
		include		workdisk:m.meany/makewords/match_win.s
