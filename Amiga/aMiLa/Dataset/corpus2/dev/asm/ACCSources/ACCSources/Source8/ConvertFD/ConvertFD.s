; Program to convert .fd files into include files for use with a68k.

; Copyright © M.Meany 1990

; Assemble with Devpac 2

		incdir		df0:include/
		include		exec/exec_lib.i
		include		exec/exec.i
		include		libraries/dos_lib.i
		include		libraries/dos.i
		include		libraries/dosextens.i
		include		intuition/intuition.i
		include		intuition/intuition_lib.i
		include		misc/easystart.i

; Open the DOS library

start		lea		dosname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		no_dos

; Open Intuition Library

		lea		intname,a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_IntuitionBase
		beq		no_intuition
		
; Open window and wait for a gadget to be selected

		lea		MainWindow,a0	a0-->window structure
		CALLINT		OpenWindow	open this window
		move.l		d0,window.ptr	save its pointer
		beq		no_window
		lea		WindowText,a1	a1-->text structure
		move.l		window.ptr,a0	a0-->window
		move.l		50(a0),a0	
		moveq.l		#0,d0		x position of text
		move.l		#0,d1		y position of text
		CALLINT		PrintIText	print the help message
WaitForMsg	move.l		window.ptr,a0	a0-->window
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		window.ptr,a0	a0-->window pointer
		move.l		wd_UserPort(a0),a0  a0-->user port
		CALLEXEC	GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq		WaitForMsg	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		move.l		im_IAddress(a1),a5 a5=addr of structure
		CALLEXEC	ReplyMsg	answer o/s or it gets angry
		cmp.l		#GADGETUP,d2	was a gadget selected
		bne.s		WaitForMsg	if not loop back
		move.l		gg_UserData(a5),a5  else a5-->subroutine
		jsr		(a5)		call subroutine

; Close window

		move.l		window.ptr,a0
		CALLINT		CloseWindow

; Close Intuition library
		
no_window	move.l		_IntuitionBase,a1
		CALLEXEC	CloseLibrary

; Close DOS library

no_intuition	move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
; And finish
		
no_dos		rts
		
; Subroutine to deal with Extras 1.2 Gadget selection
		
; Change screen and window titles

E1.2		lea		title1,a1
		lea		WindowName,a2
		move.l		window.ptr,a0
		CALLINT		SetWindowTitles

; Initialise list pointers for 1.2 files

		move.l		#fd1.2_files,fd_files
		move.l		#inc_files1.2,inc_files

; Call conversion subroutine and finish

		bsr		ConvertFD
		moveq.l		#1,d0
		rts

; Subroutine to deal with Extras 1.3 gadget selection

; Change screen and window titles

E1.3		lea		title2,a1
		lea		WindowName,a2
		move.l		window.ptr,a0
		CALLINT		SetWindowTitles

; Initialise list pointers for 1.3 files

		move.l		#fd1.3_files,fd_files
		move.l		#inc_files1.3,inc_files

; Call conversion subroutine and finish

		bsr		ConvertFD
		moveq.l		#1,d0
		rts

; Subroutine to deal with CANCEL gadget selection

Cancel		moveq.l		#0,d0
		rts

; Main conversion subroutine.

; Get some memory for input buffer 

ConvertFD	move.l		#5000,d0
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,i_buffer
		beq		quit

; Get some memory for output buffer

		move.l		#10000,d0
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		move.l		d0,o_buffer
		beq		no_mem2

; Move list pointers into address registers

		move.l		fd_files,a4
		move.l		inc_files,a5
		
; Adjust these for loop
		
		sub.l		#4,a4
		sub.l		#4,a5		
		moveq.l		#4,d7

; Load and convert each file in the list

		moveq.l		#17,d5		loop counter
exp_loop	add.l		d7,a4
		add.l		d7,a5
		move.l		(a4),d0
bp1		bsr		convert
		tst.l		d0
		beq.s		error_outINC
		
; Get target filename from list and save converted file.
		
		move.l		d0,d6
		move.l		(a5),d1
		move.l		#MODE_NEWFILE,d2
		CALLDOS		Open
		move.l		d0,out_handle
		beq.s		error_outINC
		move.l		d0,d1
		move.l		o_buffer,d2
		move.l		d6,d3
		CALLDOS		Write
		move.l		out_handle,d1
		CALLDOS		Close
		
; Until end of list
		
error_outINC	dbra		d5,exp_loop
		
; Free output buffer memory
		
		move.l		o_buffer,a1
		move.l		#10000,d0
		CALLEXEC	FreeMem

; Free input buffer memory and finish

no_mem2		move.l		i_buffer,a1
		move.l		#5000,d0
		CALLEXEC	FreeMem
quit		rts

; Subroutine to read in .fd file and convert it

; Read .fd file into input buffer

convert		movem.l		d1-d7/a0-a7,-(sp)
		move.l		d0,d1
		move.l		#MODE_OLDFILE,d2
		CALLDOS		Open
		move.l		d0,handle_in
		beq.s		error_inFD
		move.l		d0,d1
		move.l		i_buffer,d2
		move.l		#5000,d3
		CALLDOS		Read
		move.l		d0,d7
		beq.s		error_inFD
		move.l		handle_in,d1
		CALLDOS		Close
		move.l		i_buffer,a5
		move.l		o_buffer,a4

; Call subroutine to replace all # symbols in input buffer with ;

		bsr		replace_hash
		
; Determine library bias ( starting offset value )
		
bp2		bsr		find_bias

; Add offsets to all lines not starting with ; or *

		moveq.l		#0,d6
		lea		offset,a3
		bsr		do_conversion

; Length of converted file into d0 and finish

		move.l		a4,d0
		sub.l		o_buffer,d0
error_inFD	movem.l		(sp)+,d1-d7/a0-a7
		rts
		
handle_in	dc.l		0

; Subroutine to find first ( on each line

do_conversion	move.l		#'(',d3
		moveq.l		#$0a,d2
		subq.l		#1,d7
char_loop	move.b		(a5)+,d4
		cmp.b		d4,d2
		bne.s		not_CR
		moveq.l		#0,d6	
		bra		not_brace
not_CR		cmp.b		d4,d3
		bne.s		not_brace
		bsr		got_brace
not_brace	move.b		d4,(a4)+
		dbra		d7,char_loop
		rts

; Subroutine that inserts equ -$xxxx before 1st ( on a line

got_brace	not.l		d6
		beq.s		dont_equate
		
; Call subroutine to convert counter value into ASCII string ( offset )
		
		bsr		hex_con
		moveq.l		#11,d0
		movea.l		a3,a0
.loop		move.b		(a0)+,(a4)+
		dbra		d0,.loop
dont_equate	rts

; Replace all # symbols with ; symbols so these lines will be ignored by the
;assembler.

replace_hash	move.l		a5,a0
		move.l		d7,d0
		subq.l		#1,d0
		move.l		#'#',d1
repl_loop	cmp.b		(a0)+,d1
		bne.s		not_hash
		move.b		#';',-1(a0)
not_hash	dbra		d0,repl_loop
		rts
		
; Finds the starting offset for this file and stores it in d7.

; Entry		a5 must hold start address of input buffer.

; Exit		d5 will hold starting offset.

; Corrupt	a0


find_bias	movem.l		d1-d2/a1-a3,-(sp)
		move.l		a5,a0
		lea		string,a1
		move.l		#2,d1		length  of string-2
		move.b		(a1)+,d5
.loop		cmp.b		(a0)+,d5
		bne.s		.loop
		move.l		a0,a2		copy buffer pointer
		move.l		a1,a3		copy string pointer
		move.l		d1,d2		copy counter
.loop1		cmp.b		(a2)+,(a3)+
		dbne		d2,.loop1
		bne.s		.loop
		adda.l		#4,a0
		moveq.l		#0,d5
		move.b		(a0)+,d5
		sub.w		#'0',d5
		mulu.w		#10,d5
		add.b		(a0),d5
		sub.w		#'0',d5
		movem.l		(sp)+,d1-d2/a1-a3
		rts

string		dc.b	'bias',0
		even

; routine to convert a word into a 4 byte ASCII string for printing
; CORRUPTED d0,d1,a0

hex_con		move.l		d5,d1		get offset
		lea		hex,a0		addr to write string
		move.w		d1,d0		get copy of word
		lsr.w		#8,d0		move MSB into LSB
		swap		d1		store word safely
		jsr		hexconvert	convert MSB
		swap		d1		retrieve word
		move.w		d1,d0		copy into d0
		jsr		hexconvert	convert LSB
		addq.l		#6,d5		bump offset
		rts				finished so return

; routine to convert a byte to a 2 byte ASCII string for printing
; ENTRY d0=byte  a0->address to store string

hexconvert 	move.b		d0,d1
		andi.b		#$f0,d0		mask off 1st nibble
		lsr.b		#4,d0		correct nibble position
		jsr		h_convert		convert to ASCII
		move.b		d1,d0		get copy of byte
		andi.b		#$0f,d0		mask off 2nd nibble
		jsr		h_convert		convert to ASCII
		rts				leave

h_convert		cmpi.b		#$0a,d0		is nibble a letter
		blt.s		add1		if not branch
		addi.b		#$07,d0		add letter offset
add1		addi.b		#$30,d0		add numeric offset
		move.b		d0,(a0)+	store value
		rts				return

offset		dc.b		$09,'equ',$09,'-$'
hex		dc.b		'    ',$09
		even

*****************************************************************************

; General variables

i_buffer	dc.l		0
o_buffer	dc.l		0
out_handle	dc.l		0
fd_files	dc.l		0
inc_files	dc.l		0
window.ptr	dc.l		0

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

intname		dc.b	'intuition.library',0
		even
_IntuitionBase	dc.l	0

title1		dc.b	'Converting 1.2 Files ----- Please Wait.',0
		even
title2		dc.b	'Converting 1.3 Files ----- Please Wait.',0
		even

; The filename lists

fd1.2_files	dc.l		fd1.2_1
		dc.l		fd1.2_2
		dc.l		fd1.2_3
		dc.l		fd1.2_4
		dc.l		fd1.2_5
		dc.l		fd1.2_6
		dc.l		fd1.2_7
		dc.l		fd1.2_8
		dc.l		fd1.2_9
		dc.l		fd1.2_10
		dc.l		fd1.2_11
		dc.l		fd1.2_12
		dc.l		fd1.2_13
		dc.l		fd1.2_14
		dc.l		fd1.2_15
		dc.l		fd1.2_16
		dc.l		fd1.2_17
		dc.l		fd1.2_18

fd1.3_files	dc.l		fd1.3_1
		dc.l		fd1.3_2
		dc.l		fd1.3_3
		dc.l		fd1.3_4
		dc.l		fd1.3_5
		dc.l		fd1.3_6
		dc.l		fd1.3_7
		dc.l		fd1.3_8
		dc.l		fd1.3_9
		dc.l		fd1.3_10
		dc.l		fd1.3_11
		dc.l		fd1.3_12
		dc.l		fd1.3_13
		dc.l		fd1.3_14
		dc.l		fd1.3_15
		dc.l		fd1.3_16
		dc.l		fd1.3_17
		dc.l		fd1.3_18
		
inc_files1.2	dc.l		inc1
inc_files1.3	dc.l		inc2
		dc.l		inc3
		dc.l		inc4
		dc.l		inc5
		dc.l		inc6
		dc.l		inc7
		dc.l		inc8
		dc.l		inc9
		dc.l		inc10
		dc.l		inc11
		dc.l		inc12
		dc.l		inc13
		dc.l		inc14
		dc.l		inc15
		dc.l		inc16
		dc.l		inc17
		dc.l		inc18
		dc.l		inc19

fd1.2_1		dc.b		'extras:fd1.2/cstrings_lib.fd',0
		even
fd1.2_2		dc.b		'extras:fd1.2/console_lib.fd',0
		even
fd1.2_3		dc.b		'extras:fd1.2/diskfont_lib.fd',0
		even
fd1.2_4		dc.b		'extras:fd1.2/dos_lib.fd',0
		even
fd1.2_5		dc.b		'extras:fd1.2/exec_lib.fd',0
		even
fd1.2_6		dc.b		'extras:fd1.2/expansion_lib.fd',0
		even
fd1.2_7		dc.b		'extras:fd1.2/graphics_lib.fd',0
		even
fd1.2_8		dc.b		'extras:fd1.2/icon_lib.fd',0
		even
fd1.2_9		dc.b		'extras:fd1.2/intuition_lib.fd',0
		even
fd1.2_10	dc.b		'extras:fd1.2/layers_lib.fd',0
		even
fd1.2_11	dc.b		'extras:fd1.2/mathffp_lib.fd',0
		even
fd1.2_12	dc.b		'extras:fd1.2/mathieeedoubbas_lib.fd',0
		even
fd1.2_13	dc.b		'extras:fd1.2/mathieeedoubtrans_lib.fd',0
		even
fd1.2_14	dc.b		'extras:fd1.2/mathtrans_lib.fd',0
		even
fd1.2_15	dc.b		'extras:fd1.2/potgo_lib.fd',0
		even
fd1.2_16	dc.b		'extras:fd1.2/clist_lib.fd',0
		even
fd1.2_17	dc.b		'extras:fd1.2/timer_lib.fd',0
		even
fd1.2_18	dc.b		'extras:fd1.2/translator_lib.fd',0
		even

		
fd1.3_1		dc.b		'extras:fd1.3/console_lib.fd',0
		even
fd1.3_2		dc.b		'extras:fd1.3/diskfont_lib.fd',0
		even
fd1.3_3		dc.b		'extras:fd1.3/dos_lib.fd',0
		even
fd1.3_4		dc.b		'extras:fd1.3/exec_lib.fd',0
		even
fd1.3_5		dc.b		'extras:fd1.3/expansion_lib.fd',0
		even
fd1.3_6		dc.b		'extras:fd1.3/graphics_lib.fd',0
		even
fd1.3_7		dc.b		'extras:fd1.3/icon_lib.fd',0
		even
fd1.3_8		dc.b		'extras:fd1.3/intuition_lib.fd',0
		even
fd1.3_9		dc.b		'extras:fd1.3/layers_lib.fd',0
		even
fd1.3_10	dc.b		'extras:fd1.3/mathffp_lib.fd',0
		even
fd1.3_11	dc.b		'extras:fd1.3/mathieeedoubbas_lib.fd',0
		even
fd1.3_12	dc.b		'extras:fd1.3/mathieeedoubtrans_lib.fd',0
		even
fd1.3_13	dc.b		'extras:fd1.3/mathtrans_lib.fd',0
		even
fd1.3_14	dc.b		'extras:fd1.3/potgo_lib.fd',0
		even
fd1.3_15	dc.b		'extras:fd1.3/clist_lib.fd',0
		even
fd1.3_16	dc.b		'extras:fd1.3/timer_lib.fd',0
		even
fd1.3_17	dc.b		'extras:fd1.3/translator_lib.fd',0
		even
fd1.3_18	dc.b		'extras:fd1.3/romboot_lib.fd',0
		even
		
		
inc1		dc.b		'Workdisk:include/cstrings_lib.i',0
		even
inc2		dc.b		'Workdisk:include/console_lib.i',0
		even
inc3		dc.b		'Workdisk:include/diskfont_lib.i',0
		even
inc4		dc.b		'Workdisk:include/dos_lib.i',0
		even
inc5		dc.b		'Workdisk:include/exec_lib.i',0
		even
inc6		dc.b		'Workdisk:include/expansion_lib.i',0
		even
inc7		dc.b		'Workdisk:include/graphics_lib.i',0
		even
inc8		dc.b		'Workdisk:include/icon_lib.i',0
		even
inc9		dc.b		'Workdisk:include/intuition_lib.i',0
		even
inc10		dc.b		'Workdisk:include/layers_lib.i',0
		even
inc11		dc.b		'Workdisk:include/mathffp_lib.i',0
		even
inc12		dc.b		'Workdisk:include/mathieeedoubbas_lib.i',0
		even
inc13		dc.b		'Workdisk:include/mathieeedoubtrans_lib.i',0
		even
inc14		dc.b		'Workdisk:include/mathtrans_lib.i',0
		even
inc15		dc.b		'Workdisk:include/potgo_lib.i',0
		even
inc16		dc.b		'Workdisk:include/clist_lib.i',0
		even
inc17		dc.b		'Workdisk:include/timer_lib.i',0
		even
inc18		dc.b		'Workdisk:include/translator_lib.i',0
		even
inc19		dc.b		'Workdisk:include/romboot_lib.i',0
		even

; Intuition structure defenitions ( Window, Gadgets and Text ).

MainWindow	dc.w		0,67		
		dc.w		640,120		
		dc.b		0,1		
		dc.l		GADGETUP
		dc.l		WINDOWDEPTH+NOCAREREFRESH+ACTIVATE
		dc.l		Gadg1.2		
		dc.l		0		
		dc.l		WindowName
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		

WindowName	dc.b		'ConvertFD © M.Meany 1990',0
		even

Gadg1.2		dc.l		Gadg1.3		
		dc.w		430,51		
		dc.w		95,16		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		Border1		
		dc.l		0		
		dc.l		IText1		
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		E1.2		

Border1		dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		BorderVectors1		
		dc.l		0		

BorderVectors1	dc.w		0,0
		dc.w		98,0
		dc.w		98,17
		dc.w		0,17
		dc.w		0,0

IText1		dc.b		1,0,RP_JAM2,0		
		dc.w		5,4		
		dc.l		0		
		dc.l		ITextText1		
		dc.l		0		

ITextText1	dc.b		'Extras 1.2',0
		even

Gadg1.3		dc.l		GadgCancel		
		dc.w		431,72		
		dc.w		95,16		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		Border2		
		dc.l		0		
		dc.l		IText2		
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		E1.3		

Border2		dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		BorderVectors2		
		dc.l		0		

BorderVectors2	dc.w		0,0
		dc.w		98,0
		dc.w		98,17
		dc.w		0,17
		dc.w		0,0

IText2		dc.b		1,0,RP_JAM2,0		
		dc.w		6,4		
		dc.l		0		
		dc.l		ITextText2		
		dc.l		0		

ITextText2	dc.b		'Extras 1.3',0
		even

GadgCancel	dc.l		0		
		dc.w		432,93		
		dc.w		95,16		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		Border3		
		dc.l		0		
		dc.l		IText3		
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		Cancel		

Border3		dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		BorderVectors3		
		dc.l		0		

BorderVectors3	dc.w		0,0
		dc.w		98,0
		dc.w		98,17
		dc.w		0,17
		dc.w		0,0

IText3		dc.b		1,0,RP_JAM2,0		
		dc.w		22,4		
		dc.l		0		
		dc.l		ITextText3		
		dc.l		0		

ITextText3	dc.b		'CANCEL',0
		even
		
WindowText	dc.b		2,0,RP_JAM2,0		
		dc.w		12,14		
		dc.l		0		
		dc.l		ITextText4		
		dc.l		IText5		

ITextText4	dc.b		'This program was written in Assembly Language. Source available on request.'
		even

IText5		dc.b		2,0,RP_JAM2,0		
		dc.w		13,25		
		dc.l		0		
		dc.l		ITextText5		
		dc.l		IText6		

ITextText5	dc.b		"You will need a disc handy labelled 'Workdisk:' and on it must exsist a",0
		even

IText6		dc.b		2,0,RP_JAM2,0		
		dc.w		13,36		
		dc.l		0		
		dc.l		ITextText6		
		dc.l		IText7		

ITextText6	dc.b		"directory called 'Include'. For full instructions see the doc file.",0
		even

IText7		dc.b		2,0,RP_JAM2,0		
		dc.w		15,47		
		dc.l		0		
		dc.l		ITextText7		
		dc.l		IText8		

ITextText7	dc.b		'Finally my address :',0
		even

IText8		dc.b		3,0,RP_JAM2,0		
		dc.w		198,58		
		dc.l		0		
		dc.l		ITextText8		
		dc.l		IText9		

ITextText8	dc.b		'1 Cromwell Road,',0
		even

IText9		dc.b		3,0,RP_JAM2,0		
		dc.w		198,68		
		dc.l		0		
		dc.l		ITextText9		
		dc.l		IText10		

ITextText9	dc.b		'Southampton,',0
		even

IText10		dc.b		3,0,RP_JAM2,0		
		dc.w		199,78		
		dc.l		0		
		dc.l		ITextText10		
		dc.l		IText11		

ITextText10	dc.b		"Hant's.",0
		even

IText11		dc.b		3,0,RP_JAM2,0		
		dc.w		199,88		
		dc.l		0		
		dc.l		ITextText11		
		dc.l		IText12		

ITextText11	dc.b		'SO1 2JH',0
		even

IText12		dc.b		3,0,RP_JAM2,0		
		dc.w		199,48		
		dc.l		0		
		dc.l		ITextText12		
		dc.l		0		

ITextText12	dc.b		'M.Meany',0
		even

		
