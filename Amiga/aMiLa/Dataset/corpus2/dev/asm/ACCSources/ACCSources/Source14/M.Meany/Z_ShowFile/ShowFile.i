
; This massive subroutine is infact a text file viewer. You may attach it
;to any program you wish providing the About window text is left unaltered.

;To display a text file:

;	ShowFile	( filename )
;			     d0

; 	d0 should contain the address of a NULL ( 0 ) terminated text
;	   string or 0. If d0=0 a clear window is displayed, the user
;	   may load a file of his chosing!

; ALL registers preserved on return.

; See Doc file for more info!

; Does not support crunched files!

; Requires the following libraries to be open and their base pointers
;stored at the label shown:

;	LIBRARY			BASE POINTER LABEL

;	arp.library		_ArpBase
;	intuition.library	_IntuitionBase
;	graphics.library	_GfxBase


; © M.Meany, June 1991

; The following files must be 'Included' :

;		include		"exec/exec_lib.i"
;		include		exec/memory.i
;		include		"intuition/intuition_lib.i"
;		include		"intuition/intuition.i"
;		include		graphics/graphics_lib.i
;		include		"source:include/arpbase.i"
		

ShowFile	movem.l		d0-d7/a0-a6,-(sp)
		move.l		d0,_initial_file
		bsr		_GoForIt
		movem.l		(sp)+,d0-d7/a0-a6
		rts
_GoForIt	bsr		_OpenAWindow	
		tst.l		d0		
		beq.s		.error1		
		bsr		_TailLoad	
		bsr		_WaitOnUser	
.error1		rts				
_OpenAWindow	move.l		#_Mvars_sizeof,d0
		CALLARP		DosAllocMem
		move.l		d0,d6
		beq		.error
		move.l		d0,a4
		moveq.l		#0,d0
		lea		_LoadFileStruct(a4),a0
		move.l		#_LoadText,(a0)+
		lea		_LoadFileData(a4),a1
		move.l		a1,(a0)+
		lea		_LoadDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		_LoadFileStruct(a4),a0
		lea		_LoadPathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		or.b		#FRF_DoColor,d0
		lea		_SaveFileStruct(a4),a0
		move.l		#_SaveText,(a0)+
		lea		_SaveFileData(a4),a1
		move.l		a1,(a0)+
		lea		_SaveDirData(a4),a1
		move.l		a1,(a0)+
		addq.l		#4,a0
		move.b		d0,(a0)
		lea		_SaveFileStruct(a4),a0
		lea		_SavePathName(a4),a1
		move.l		a1,fr_SIZEOF(a0)
		lea		_msg_text(a4),a0
		move.b		#1,it_FrontPen(a0)
		move.b		#RP_JAM2,it_DrawMode(a0)
		lea		_line_buf(a4),a1
		move.l		a1,it_IText(a0)
		lea		_MyWindow,a0
		CALLINT		OpenWindow
		move.l		d0,_window.ptr(a4)
		bne.s		.ok
		move.l		d6,a1
		CALLARP		DosFreeMem
		moveq.l		#0,d0
		bra		.error
.ok		move.l		d0,a0
		move.l		wd_RPort(a0),_window.rp(a4)
		move.l		d6,wd_UserData(a0)
		move.l		wd_UserPort(a0),_MyPort
		bsr		_win_sized
		move.l		_window.ptr(a4),a0
		lea		_winname,a1		
		lea		_scrn_Title,a2		
		CALLINT		SetWindowTitles
		moveq.l		#1,d0
		add.l		d0,_StillHere
.error		rts
_TailLoad	tst.l		_initial_file
		beq.s		.no_file
		lea		_LoadPathName(a4),a0
		move.l		_initial_file,a1
.loop		move.b		(a1)+,(a0)+
		cmpi.b		#$0,(a1)
		beq.s		.ok
		cmpi.b		#' ',(a1)
		beq.s		.ok
		bra		.loop
.ok		move.b		#0,(a0)
		bsr		_Entry1
.no_file	rts
_refresh_display	tst.l		_line_list(a4)
		beq		_referror
		move.l		_window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen
		move.l		_window.rp(a4),a1
		moveq.l		#4,d0
		moveq.l		#10,d1
		move.l		_scrn_width(a4),d2
		move.l		_scrn_height(a4),d3
		addq.l		#1,d3
		CALLGRAF	RectFill
		move.l		#10,_linenum(a4)	
		move.l		_top_line(a4),d4
		move.l		_lines_on_scrn(a4),d5
		subq.l		#1,d5
_plop		move.l		d4,d0
		bsr		_print_line
		addq.l		#1,d4
		dbra		d5,_plop
_referror	rts
_print_line	cmp.l		_num_lines(a4),d0
		bgt		.error
		subq.l		#1,d0
		asl.l		#2,d0		x4
		add.l		_line_list(a4),d0
		move.l		d0,a1
		move.l		(a1),a1
		lea		_line_buf(a4),a0
		bsr		_expand_text
		lea		_line_buf(a4),a0
		move.l		_chars_on_line(a4),d0
		move.b		#0,0(a0,d0)
		lea		_msg_text(a4),a1
		move.l		_window.rp(a4),a0
		moveq.l		#5,d0
		move.l		_linenum(a4),d1
		CALLINT		PrintIText
		move.l		_font.height(a4),d0
		add.l		d0,_linenum(a4)
.error		rts
_expand_text	movem.l		d0-d7/a0-a1,-(sp)
		moveq.l		#0,d6		
		moveq.l		#$09,d2		
		moveq.l		#$0a,d3		
		moveq.l		#' ',d4		
.next_char	move.b		(a1)+,d0	
		cmp.b		d3,d0		
		beq.s		.line_done	
		cmp.b		d2,d0		
		beq.s		.do_tab		
		move.b		d0,0(a0,d6)	
		addq.w		#1,d6		
		bra.s		.next_char	
.line_done	move.b		#0,0(a0,d6)	
		movem.l		(sp)+,d0-d7/a0-a1
		rts
.do_tab		move.l		d6,d1		
		asr.w		#3,d1		
		addq.w		#1,d1
		asl.w		#3,d1
		sub.w		d6,d1
		subq.w		#1,d1		
.next_spc	move.b		d4,0(a0,d6)	
		addq.w		#1,d6		
		dbra		d1,.next_spc	
		bra.s		.next_char
_WaitOnUser	move.l		_MyPort,a0	
		CALLEXEC	WaitPort	
		move.l		_MyPort,a0	
		jsr		_LVOGetMsg(a6)	
		tst.l		d0		
		beq		_WaitOnUser	
		move.l		d0,a1		
		move.l		im_Class(a1),d2	
		move.l		im_Code(a1),d3	
		move.l		im_Qualifier(a1),d4
		move.l		im_IDCMPWindow(a1),a5
		move.l		im_IAddress(a1),a3 
		jsr		_LVOReplyMsg(a6) 
		cmp.l		#CLOSEWINDOW,d2	 
		bne.s		.check_resize	 
		bsr		_win_closed
		bra		.test_complete
.check_resize	cmp.l		#NEWSIZE,d2	
		bne.s		.check_key
		bsr		_win_sized
		bra		.test_complete
.check_key	cmp.l		#RAWKEY,d2
		bne.s		.check_active
		bsr		_do_keys
		bra		.test_complete
.check_active	cmp.l		#ACTIVEWINDOW,d2
		bne.s		.check_gadg
		bsr		_win_activate
		bra		.test_complete
.check_gadg	cmp.l		#GADGETUP,d2
		bne.s		.test_complete
		move.l		gg_UserData(a3),a0
		jsr		(a0)
.test_complete	tst.l		_StillHere
		bne		_WaitOnUser
		rts
_win_sized	move.l		_window.ptr(a4),a0
		move.l		_window.rp(a4),a1
		moveq		#0,d1
		move.w		rp_TxWidth(a1),d1
		move.l		d1,_font.width(a4)
		move.w		rp_TxHeight(a1),d1		
		move.l		d1,_font.height(a4)
		moveq.l		#0,d0
		move.w		wd_Height(a0),d0
		sub.l		#12,d0
		move.l		d0,_scrn_height(a4)
		divu		d1,d0
		and.l		#$ffff,d0
		subq.l		#1,d0
		move.l		d0,_lines_on_scrn(a4)
		moveq		#0,d0
		move.w		wd_Width(a0),d0
		subq.w		#4,d0
		move.l		d0,_scrn_width(a4)
		divu		_font.width+2(a4),d0
		subq.w		#1,d0
		and.l		#$ffff,d0
		move.l		d0,_chars_on_line(a4)
		move.l		_window.rp(a4),a1
		moveq.l		#0,d0
		CALLGRAF	SetAPen
		move.l		_window.rp(a4),a1
		moveq.l		#4,d0
		move.l		_scrn_height(a4),d1
		move.l		_scrn_width(a4),d2
		sub.l		#12,d2
		move.l		d1,d3
		add.l		#10,d3
		CALLGRAF	RectFill
		bsr		_refresh_display
		rts
_do_keys	swap		d3
		cmpi.b		#$28,d3		
		bne.s		.is_S
		bsr		_Load
		bra		.ok
.is_S		cmpi.b		#$21,d3		
		bne.s		.is_G
		bsr		_Save
		bra		.ok
.is_G		cmpi.b		#$24,d3		
		bne.s		.is_Q
		bsr		_GotoLine
		bra		.ok
.is_Q		cmpi.b		#$10,d3		
		bne.s		.is_T
		bsr		_win_closed
		bra		.ok
.is_T		cmpi.b		#$14,d3		
		bne.s		.is_B
		bsr		_GoTop
		bra		.ok
.is_B		cmpi.b		#$35,d3		
		bne.s		.is_F
		bsr		_GoBot
		bra		.ok
.is_F		cmpi.b		#$23,d3		
		bne.s		.is_N
		bsr		_SearchString
		bra		.ok
.is_N		cmpi.b		#$36,d3		
		bne.s		.is_D
		bsr		_Next
		bra		.ok
.is_D		cmpi.b		#$22,d3		
		bne.s		.is_up
		bsr		_DumpFile
		bra		.ok
.is_up		cmpi.b		#$4d,d3		
		bne.s		.is_down
		and.l		#$30000,d4	
		bne.s		.is_pup
		bsr		_line_up
		bra		.ok
.is_pup		bsr		_page_up	
		bra		.ok
.is_down	cmpi.b		#$4c,d3		
		bne.s		.is_about
		and.l		#$30000,d4	
		bne.s		.is_pdown
		bsr		_line_down
		bra		.ok
.is_pdown	bsr		_page_down	
		bra		.ok
.is_about	cmpi.b		#$5f,d3		
		bne.s		.ok
		bsr		_About
		bra.s		.ok
		nop
.ok		rts
_DumpFile	bsr		_PointerOn
		move.l		#_printername,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d5
		beq		.error
		move.l		d0,d1
		move.l		_buffer(a4),d2
		move.l		_buf_len(a4),d3
		jsr		_LVOWrite(a6)
		move.l		d5,d1
		jsr		_LVOClose(a6)
.error		bsr		_PointerOff
		rts
_GoTop		move.l		#1,_top_line(a4)
		bsr		_refresh_display
		rts
_GoBot		move.l		_max_top_line(a4),_top_line(a4)
		bsr		_refresh_display
		rts
_line_up	tst.l		_line_list(a4)
		beq		.error
		move.l		_top_line(a4),d0
		cmp.l		_max_top_line(a4),d0
		beq		.error
		addq.l		#1,d0
		move.l		d0,_top_line(a4)
		move.l		_window.rp(a4),a1
		moveq.l		#0,d0
		move.l		_font.height(a4),d1
		moveq.l		#5,d2
		moveq.l		#10,d3
		move.l		_scrn_width(a4),d4
		move.l		_font.height(a4),d5
		mulu		_lines_on_scrn+2(a4),d5
		add.l		#9,d5
		CALLGRAF	ScrollRaster
		move.l		_lines_on_scrn(a4),d0
		subq.l		#1,d0
		move.l		d0,d1
		mulu		_font.height+2(a4),d1
		add.l		#10,d1
		move.l		d1,_linenum(a4)
		add.l		_top_line(a4),d0
		bsr		_print_line
.error		rts
_line_down	tst.l		_line_list(a4)
		beq		.error
		move.l		_top_line(a4),d0
		subq.l		#1,d0
		beq		.error
		move.l		d0,_top_line(a4)
		move.l		_window.rp(a4),a1
		moveq.l		#0,d0
		move.l		_font.height(a4),d1
		neg.l		d1
		moveq.l		#5,d2
		moveq.l		#10,d3
		move.l		_scrn_width(a4),d4
		move.l		_font.height(a4),d5
		mulu		_lines_on_scrn+2(a4),d5
		add.l		#9,d5
		CALLGRAF	ScrollRaster
		move.l		#10,_linenum(a4)
		move.l		_top_line(a4),d0
		bsr		_print_line
.error		rts
_page_up	tst.l		_line_list(a4)
		beq		.error
		move.l		_top_line(a4),d0
		add.l		_lines_on_scrn(a4),d0
		subq.l		#1,d0
		cmp.l		_max_top_line(a4),d0
		ble.s		.ok
		move.l		_max_top_line(a4),d0
.ok		move.l		d0,_top_line(a4)
		bsr		_refresh_display
.error		rts
_page_down	tst.l		_line_list(a4)
		beq		.error
		move.l		_top_line(a4),d0
		sub.l		_lines_on_scrn(a4),d0
		addq.l		#1,d0
		cmp.l		#1,d0
		bge.s		.ok
		move.l		#1,d0
.ok		move.l		d0,_top_line(a4)
		bsr		_refresh_display
.error		rts
_Load		bsr		_PointerOn
		tst.l		_buffer(a4)
		beq.s		.ok
		move.l		_buffer(a4),a1
		move.l		_buf_len(a4),d0
		CALLEXEC	FreeMem
		move.l		#0,_buffer(a4)
.ok		bsr		_arpload
		beq		_load_error
_Entry1		move.l		_window.ptr(a4),a0
		lea		_LoadPathName(a4),a1
		lea		_scrn_Title,a2
		CALLINT		SetWindowTitles
		lea		_LoadPathName(a4),a0	
		bsr		_FileLen		
		move.l		d0,_buf_len(a4)		
		beq		_ld_mem_err		
		lea		_LoadPathName(a4),a0	
		move.l		a0,d1			
		move.l		#MODE_OLDFILE,d2	
		CALLARP		Open			
		move.l		d0,d7			
		beq		_ld_mem_err		
		move.l		_buf_len(a4),d0		
		move.l		#MEMF_PUBLIC!MEMF_CLEAR,d1
		CALLEXEC	AllocMem		
		move.l		d0,_buffer(a4)		
		bne.s		.read_file		
		move.l		d7,d1			
		CALLARP		Close			
		bra		_ld_mem_err		
.read_file	move.l		d7,d1			
		move.l		d0,d2			
		move.l		_buf_len(a4),d3		
		CALLARP		Read			
		move.l		d7,d1			
		CALLARP		Close			
		move.l		_line_list(a4),a1
		CALLARP		DosFreeMem
		moveq.l		#0,d0		
		move.l		d0,d1		
		moveq.l		#$0a,d2		
		move.l		_buf_len(a4),d3
		move.l		_buffer(a4),a0	
		movem.l		d1-d3/a0,-(sp)	
_lf_loop	cmp.b		(a0)+,d2	
		bne.s		.ok		
		addq.l		#1,d0		
.ok		subq.l		#1,d3		
		bne.s		_lf_loop
		move.l		d0,_num_lines(a4)
		addq.l		#2,d0		
		asl.l		#2,d0		
		CALLARP		DosAllocMem	
		movem.l		(sp)+,d1-d3/a0	
		move.l		d0,_line_list(a4)
		beq.s		_ld_mem_err		
		move.l		d0,a1		
		move.l		a0,(a1)+	
_table_loop	cmp.b		(a0)+,d2	
		bne.s		.ok		
		move.l		a0,(a1)+	
.ok		subq.l		#1,d3		
		bne.s		_table_loop	
		move.l		#1,_top_line(a4)
		move.l		_lines_on_scrn(a4),d0
		move.l		_num_lines(a4),d1
		sub.l		d0,d1
		beq.s		.error
		bmi.s		.error
		bra		.ok1
.error		moveq.l		#1,d1
.ok1		move.l		d1,_max_top_line(a4)
		bsr		_refresh_display
		bra		_load_error
_ld_mem_err	move.l		#0,a0
		CALLINT		DisplayBeep
_load_error	bsr		_PointerOff
		moveq.l		#0,d0
		rts
_arpload	lea		_LoadFileStruct(a4),a0	
		CALLARP		FileRequest 		
		tst.l		d0			
		beq.s		_NoPath
		lea		_LoadFileStruct(a4),a0	
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		_NoPath
		bsr		_CreatePath		
		tst.b		_LoadPathName(a4)	
_NoPath		rts					
_FileLen	movem.l		d1-d4/a1-a4,-(sp)
		move.l		a0,_RFfile_name(a4)
		move.l		#0,_RFfile_len(a4)
		move.l		#fib_SIZEOF,d0
		move.l		#MEMF_PUBLIC,d1
		CALLEXEC	AllocMem
		move.l		d0,_RFfile_info(a4)
		beq		.error1
		move.l		_RFfile_name(a4),d1
		move.l		#ACCESS_READ,d2
		CALLARP		Lock
		move.l		d0,_RFfile_lock(a4)
		beq		.error2
		move.l		d0,d1
		move.l		_RFfile_info(a4),d2
		jsr		_LVOExamine(a6)
		move.l		_RFfile_info(a4),a0
		move.l		fib_Size(a0),_RFfile_len(a4)
		move.l		_RFfile_lock(a4),d1
		jsr		_LVOUnLock(a6)
.error2		move.l		_RFfile_info(a4),a1
		move.l		#fib_SIZEOF,d0
		CALLEXEC	FreeMem
.error1		move.l		_RFfile_len(a4),d0
		movem.l		(sp)+,d1-d4/a1-a4
		rts
_Save		bsr		_PointerOn
		tst.l		_buffer(a4)
		beq		_save_error
		bsr.s		_arpsave
		tst.b		_SavePathName(a4)
		beq.s		_save_error
		move.l		a4,d1
		add.l		#_SavePathName,d1
		move.l		#MODE_NEWFILE,d2
		CALLARP		Open
		move.l		d0,d7
		bne.s		.ok
		move.l		#0,a0
		CALLINT		DisplayBeep
		bra.s		_save_error
.ok		move.l		d0,d1
		move.l		_buffer(a4),d2
		move.l		_buf_len(a4),d3
		jsr		_LVOWrite(a6)
		move.l		d7,d1
		jsr		_LVOClose(a6)
_save_error	bsr		_PointerOff
		moveq.l		#0,d0
		rts
_arpsave	lea		_SaveFileStruct(a4),a0	
		CALLARP		FileRequest 		
		tst.l		d0			
		beq.s		_NoPath2		
		lea		_SaveFileStruct(a4),a0	
		move.l		fr_File(a0),a1
		tst.b		(a1)
		beq.s		_NoPath2
		bsr.s		_CreatePath		
_NoPath2	rts					
_CreatePath:	move.l		a2,-(sp)	
	move.l		a0,a2			
	move.l		fr_Dir(a2),a0		
	move.l		fr_SIZEOF(a2),a1	
	moveq		#DSIZE,d0		
	CALLEXEC	CopyMem			
	move.l		fr_SIZEOF(a2),a0	
	move.l		fr_File(a2),a1		
	CALLARP		TackOn			
	move.l		(sp)+,a2		
	rts					
_PointerOn	move.l		_window.ptr(a4),a0
		lea		_newptr,a1
		moveq.l		#16,d0
		move.l		d0,d1
		moveq.l		#0,d2
		move.l		d2,d3
		CALLINT		SetPointer
		rts
_PointerOff	move.l		_window.ptr(a4),a0
		CALLINT		ClearPointer
		rts
_win_activate	move.l		wd_UserData(a5),a4
		rts
_win_closed	move.l		wd_UserData(a5),a3
		move.l		_line_list(a3),a1
		CALLARP		DosFreeMem
		move.l		_buffer(a3),a1
		move.l		_buf_len(a3),d0
		beq.s		.ok
		CALLEXEC	FreeMem
.ok		move.l		a3,a1
		CALLARP		DosFreeMem
		move.l		a5,a0
		CALLINT		CloseWindow
		subq.l		#1,_StillHere
		rts
_About		lea		_AboutWin,a0
		CALLINT		OpenWindow
		move.l		d0,d7
		beq		_NoAbout
		move.l		d0,a0
		move.l		wd_UserPort(a0),a3
		move.l		wd_RPort(a0),a5
		move.l		a5,a0		
		lea		_AboutIT,a1	
		moveq.l		#0,d0		
		move.l		d0,d1		
		jsr		_LVOPrintIText(a6)
_WaitAbout	move.l		a3,a0		
		CALLEXEC	WaitPort	
		move.l		a3,a0		
		jsr		_LVOGetMsg(a6)	
		tst.l		d0		
		beq.s		_WaitAbout	
		move.l		d0,a1		
		move.l		im_Class(a1),d2	
		CALLEXEC	ReplyMsg	
		cmp.l		#GADGETUP,d2	
		bne.s		_WaitAbout
		move.l		d7,a0
		CALLINT		CloseWindow
_NoAbout	rts
_AboutWin	dc.w	127,6
	dc.w	400,190
	dc.b	1,2
	dc.l	GADGETUP
	dc.l	WINDOWDRAG+WINDOWDEPTH+NOCAREREFRESH+ACTIVATE
	dc.l	_AboutGadg
	dc.l	0
	dc.l	_AboutWinName
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
_AboutWinName	dc.b	'More Subroutines © M.Meany 1991',0
	even
_AboutGadg	dc.l	0
	dc.w	282,145
	dc.w	93,36
	dc.w	0
	dc.w	RELVERIFY
	dc.w	BOOLGADGET
	dc.l	_Border1
	dc.l	0
	dc.l	_IText1
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
_Border1	dc.w	-2,-1
	dc.b	2,0,RP_JAM1
	dc.b	5
	dc.l	_BorderVectors1
	dc.l	0
_BorderVectors1	dc.w	0,0
	dc.w	96,0
	dc.w	96,37
	dc.w	0,37
	dc.w	0,0
_IText1	dc.b	2,0,RP_JAM2,0
	dc.w	25,7
	dc.l	0
	dc.l	_ITextText1
	dc.l	_IText2
_ITextText1	dc.b	'CLICK',0
	even
_IText2	dc.b	2,0,RP_JAM2,0
	dc.w	25,21
	dc.l	0
	dc.l	_ITextText2
	dc.l	0
_ITextText2	dc.b	'HERE !',0
	even
_AboutIT dc.b	1,0,RP_JAM2,0
	dc.w	13,16
	dc.l	0
	dc.l	_ITextText3
	dc.l	_IText4
_ITextText3	dc.b	'The subroutine used to  display this file  was',0
	even
_IText4	dc.b	1,0,RP_JAM2,0
	dc.w	13,25
	dc.l	0
	dc.l	_ITextText4
	dc.l	_IText5  
_ITextText4	dc.b	'written for the PD. Contact  Amiganuts  United',0
	even
_IText5	dc.b	1,0,RP_JAM2,0
	dc.w	14,34
	dc.l	0
	dc.l	_ITextText5
	dc.l	_IText6  
_ITextText5	dc.b	'and ask for ACC disc 14. Assembler source is',0
	even
_IText6	dc.b	1,0,RP_JAM2,0
	dc.w	14,44
	dc.l	0
	dc.l	_ITextText6
	dc.l	_IText7  
_ITextText6	dc.b	'on this disc. M.Meany, July 1991.',0
	even
_IText7	dc.b	3,0,RP_JAM2,0
	dc.w	101,53
	dc.l	0
	dc.l	_ITextText7
	dc.l	_IText8
_ITextText7	dc.b	'INSTRUCTION SUMMARY',0
	even
_IText8	dc.b	1,0,RP_JAM2,0
	dc.w	20,70
	dc.l	0
	dc.l	_ITextText8
	dc.l	_IText9
_ITextText8	dc.b	'L      Load a text file',0
	even
_IText9	dc.b	1,0,RP_JAM2,0
	dc.w	20,80
	dc.l	0
	dc.l	_ITextText9
	dc.l	_IText10
_ITextText9	dc.b	'S      Save text file',0
	even
_IText10	dc.b	1,0,RP_JAM2,0
	dc.w	20,90
	dc.l	0
	dc.l	_ITextText10
	dc.l	_IText11
_ITextText10	dc.b	'D      Dump file to printer',0
	even
_IText11	dc.b	1,0,RP_JAM2,0
	dc.w	20,100
	dc.l	0
	dc.l	_ITextText11
	dc.l	_IText12
_ITextText11	dc.b	'Q      Quit',0
	even
_IText12	dc.b	1,0,RP_JAM2,0
	dc.w	20,110
	dc.l	0
	dc.l	_ITextText12
	dc.l	_IText13
_ITextText12	dc.b	'CURSOR UP     Line up (+shift for page up)',0
	even
_IText13	dc.b	1,0,RP_JAM2,0
	dc.w	20,120
	dc.l	0
	dc.l	_ITextText13
	dc.l	_IText14
_ITextText13	dc.b	'CURSOR DOWN   Line down (+shift for page down)',0
	even
_IText14	dc.b	1,0,RP_JAM2,0
	dc.w	20,130
	dc.l	0
	dc.l	_ITextText14
	dc.l	_IText15
_ITextText14	dc.b	'T      Top of file',0
	even
_IText15	dc.b	1,0,RP_JAM2,0
	dc.w	20,140
	dc.l	0
	dc.l	_ITextText15
	dc.l	_IText16
_ITextText15	dc.b	'B      Bottom of file',0
	even
_IText16	dc.b	1,0,RP_JAM2,0
	dc.w	20,150
	dc.l	0
	dc.l	_ITextText16
	dc.l	_IText17
_ITextText16	dc.b	'F      Search for string',0
	even
_IText17	dc.b	1,0,RP_JAM2,0
	dc.w	20,160
	dc.l	0
	dc.l	_ITextText17
	dc.l	_IText18
_ITextText17	dc.b	'N      Find next occurence',0
	even
_IText18	dc.b	1,0,RP_JAM2,0
	dc.w	20,170
	dc.l	0
	dc.l	_ITextText18
	dc.l	_IText19
_ITextText18	dc.b	'P      Find previous occurence',0
	even
_IText19	dc.b	1,0,RP_JAM2,0
	dc.w	19,180
	dc.l	0
	dc.l	_ITextText19
	dc.l	_IText20
_ITextText19	dc.b	'G      Goto line number xxxx',0
	even
_IText20	dc.b	1,0,RP_JAM2,0
	dc.w	20,60
	dc.l	0
	dc.l	_ITextText20
	dc.l	0
_ITextText20	dc.b	'HELP   This page',0
	even
_GotoLine	move.l		#0,_LineBuffer
		lea		_line_window,a0	
		CALLINT		OpenWindow	
		move.l		d0,_line.ptr	
		lea		_LineWinText,a1	
		move.l		_line.ptr,a0	
		move.l		wd_RPort(a0),a0	
		moveq.l		#0,d0		
		moveq		#0,d1		
		jsr		_LVOPrintIText(a6)
		lea		_LineGadg,a0
		move.l		_line.ptr,a1
		move.l		#0,a2
		jsr		_LVOActivateGadget(a6)
_WaitForLine	move.l		_line.ptr,a0	
		move.l		wd_UserPort(a0),a0
		CALLEXEC	WaitPort	
		move.l		_line.ptr,a0	
		move.l		wd_UserPort(a0),a0
		jsr		_LVOGetMsg(A6)	
		tst.l		d0		
		beq.s		_WaitForLine	
		move.l		d0,a1		
		move.l		im_Class(a1),d2	
		move.l		im_IAddress(a1),a5
		jsr		_LVOReplyMsg(a6) 
		cmp.l		#GADGETUP,d2
		bne.s		_WaitForLine
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		move.l		_line.ptr,a0	
		CALLINT		CloseWindow	
		cmp.l		_max_top_line(a4),d7
		ble.s		.ok
		move.l		_max_top_line(a4),d7
.ok		move.l		d7,_top_line(a4)
		bsr		_refresh_display
		rts
_GotLineNum	lea		_LineGadgInfo,a5
		move.l		si_LongInt(a5),d7
		bpl.s		_ok
_NoLineNum	move.l		_top_line(a4),d7
_ok		rts
_line.ptr	dc.l		0
_line_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,2		
		dc.l		GADGETUP
		dc.l		ACTIVATE		
		dc.l		_LineGadg
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		
_LineGadg	dc.l		_LineOKGadg		
		dc.w		120,22		
		dc.w		44,8
		dc.w		0		
		dc.w		RELVERIFY+LONGINT+GADGIMMEDIATE
		dc.w		STRGADGET		
		dc.l		0
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		_LineGadgInfo		
		dc.w		0		
		dc.l		_GotLineNum
_LineGadgInfo	dc.l		_LineBuffer
		dc.l		0		
		dc.w		0		
		dc.w		5		
		dc.w		0		
		dc.w		0,0,0,0,0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
_LineBuffer	dc.b		0,0,0,0,0
		even
_LineOKGadg	dc.l		_LineCancelGadg		
		dc.w		33,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		_LineOKBorder
		dc.l		0		
		dc.l		_LineOKStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		_GotLineNum		
_LineOKBorder	dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		_LineOKVectors
		dc.l		0		
_LineOKVectors	dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0
_LineOKStruct	dc.b		1,0,RP_JAM2,0		
		dc.w		24,3		
		dc.l		0		
		dc.l		_LineOKText	
		dc.l		0		
_LineOKText	dc.b		'OK',0
		even
_LineCancelGadg	dc.l		0		
		dc.w		180,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		_LineCancelBorder
		dc.l		0		
		dc.l		_LineCancelStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		_NoLineNum
_LineCancelBorder dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		_LineCancelVectors
		dc.l		0		
_LineCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0
_LineCancelStruct dc.b		1,0,RP_JAM2,0		
		dc.w		8,3		
		dc.l		0		
		dc.l		_LineCancelText
		dc.l		0		
_LineCancelText	dc.b		'CANCEL',0
		even
_LineWinText	dc.b		1,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		_LineWinTextStr	
		dc.l		0		
_LineWinTextStr	dc.b		'GO TO LINE :',0
		even
_SearchString	lea		_SearchBuffer(a4),a0	
		move.l		a0,_SearchGadgInfo	
		lea		_search_window,a0	
		CALLINT		OpenWindow	
		move.l		d0,_search.ptr	
		lea		_SearchWinText,a1
		move.l		_search.ptr,a0	
		move.l		wd_RPort(a0),a0	
		moveq.l		#0,d0		
		moveq		#0,d1		
		jsr		_LVOPrintIText(a6)
		lea		_SearchGadg,a0
		move.l		_search.ptr,a1
		move.l		#0,a2
		jsr		_LVOActivateGadget(a6)
_WaitForSearch	move.l		_search.ptr,a0	
		move.l		wd_UserPort(a0),a0
		CALLEXEC	WaitPort	
		move.l		_search.ptr,a0	
		move.l		wd_UserPort(a0),a0
		jsr		_LVOGetMsg(a6)	
		tst.l		d0		
		beq.s		_WaitForSearch	
		move.l		d0,a1		
		move.l		im_Class(a1),d2	
		move.l		im_IAddress(a1),a5
		jsr		_LVOReplyMsg(a6) 
		cmp.l		#GADGETUP,d2
		bne.s		_WaitForSearch
		move.l		gg_UserData(a5),a5
		jsr		(a5)
		move.l		_search.ptr,a0	
		CALLINT		CloseWindow	
		bsr		_refresh_display
		rts
_GotSearchNum	lea		_SearchBuffer(a4),a0
		move.l		a0,a1
		moveq.l		#-1,d0
		moveq.l		#0,d1
.loop		addq.l		#1,d0
		cmp.b		(a1)+,d1
		bne.s		.loop
		tst.l		d0
		beq		.error
		move.l		_buffer(a4),a1
		move.l		_buf_len(a4),d1
		bsr		_Find
		beq		.error
		move.l		_line_list(a4),a0
		moveq.l		#0,d1
.loop1		addq.l		#1,d1
		cmp.l		(a0)+,d0
		bge.s		.loop1
		subq.l		#1,d1
		cmp.l		_max_top_line(a4),d1
		ble.s		.okk
		move.l		_max_top_line(a4),d1
.okk		move.l		d1,_top_line(a4)
.error		rts
_NoSearchNum	rts
_Next		move.l		_top_line(a4),d0
		addq.l		#1,d0
		cmp.l		_max_top_line(a4),d0
		bge.s		.error
		move.l		_line_list(a4),a0
		subq.l		#1,d0
		asl.l		#2,d0
		move.l		0(a0,d0),d0
		move.l		d0,a1
		move.l		_buf_len(a4),d1
		add.l		_buffer(a4),d1
		sub.l		d0,d1
		lea		_SearchBuffer(a4),a0
		move.l		a0,a2
		moveq.l		#-1,d0
		moveq.l		#0,d2
.loop		addq.l		#1,d0
		cmp.b		(a2)+,d2
		bne.s		.loop
		tst.l		d0
		beq		.error
		bsr		_Find
		beq		.error
		move.l		_line_list(a4),a0
		moveq.l		#0,d1
.loop1		addq.l		#1,d1
		cmp.l		(a0)+,d0
		bge.s		.loop1
		subq.l		#1,d1
		cmp.l		_max_top_line(a4),d1
		ble.s		.okk
		move.l		_max_top_line(a4),d1
.okk		move.l		d1,_top_line(a4)
		bsr		_refresh_display
.error		rts
_Find		movem.l		d1-d2/a0-a2,-(sp)
		move.l		#0,_MatchFlag	
		sub.l		d0,d1		
		subq.l		#1,d1		
		bmi.s		_FindError	
		move.b		(a0),d2		
_Floop		cmp.b		(a1)+,d2	
		dbeq		d1,_Floop	
		bne.s		_FindError	
		bsr.s		_CompStr	
		beq.s		_Floop		
_FindError	movem.l		(sp)+,d1-d2/a0-a2
		move.l		_MatchFlag,d0	
		rts
_CompStr	movem.l		d0/a0-a2,-(sp)
		subq.l		#1,d0		
		move.l		a1,a2		
		subq.l		#1,a1		
_FFloop		cmp.b		(a0)+,(a1)+	
		dbne		d0,_FFloop	
		bne.s		_ComprDone	
		subq.l		#1,a2		
		move.l		a2,_MatchFlag	
_ComprDone	movem.l		(sp)+,d0/a0-a2
		tst.l		_MatchFlag	
		rts
_MatchFlag	dc.l		0
_search.ptr	dc.l		0
_search_window	dc.w		150,90	
		dc.w		279,67		
		dc.b		0,2		
		dc.l		GADGETUP
		dc.l		ACTIVATE		
		dc.l		_SearchGadg
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.w		5,5		
		dc.w		640,200		
		dc.w		WBENCHSCREEN		
_SearchGadg	dc.l		_SearchOKGadg		
		dc.w		110,22		
		dc.w		164,8
		dc.w		0		
		dc.w		RELVERIFY+GADGIMMEDIATE
		dc.w		STRGADGET		
		dc.l		0
		dc.l		0		
		dc.l		0		
		dc.l		0		
		dc.l		_SearchGadgInfo		
		dc.w		0		
		dc.l		_GotSearchNum
_SearchGadgInfo	dc.l		0		
		dc.l		0
		dc.w		0		
		dc.w		40
		dc.w		0		
		dc.w		0,0,0,0,0		
		dc.l		0		
		dc.l		0		
		dc.l		0		
_SearchOKGadg	dc.l		_SearchCancelGadg		
		dc.w		33,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		_SearchOKBorder
		dc.l		0		
		dc.l		_SearchOKStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		_GotSearchNum		
_SearchOKBorder	dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		_SearchOKVectors
		dc.l		0		
_SearchOKVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0
_SearchOKStruct	dc.b		1,0,RP_JAM2,0		
		dc.w		24,3		
		dc.l		0		
		dc.l		_SearchOKText	
		dc.l		0		
_SearchOKText	dc.b		'OK',0
		even
_SearchCancelGadg	dc.l		0		
		dc.w		180,49		
		dc.w		64,12		
		dc.w		0		
		dc.w		RELVERIFY		
		dc.w		BOOLGADGET		
		dc.l		_SearchCancelBorder
		dc.l		0		
		dc.l		_SearchCancelStruct
		dc.l		0		
		dc.l		0		
		dc.w		0		
		dc.l		_NoSearchNum
_SearchCancelBorder dc.w		-2,-1		
		dc.b		2,0,RP_JAM1		
		dc.b		5		
		dc.l		_SearchCancelVectors
		dc.l		0		
_SearchCancelVectors dc.w		0,0
		dc.w		67,0
		dc.w		67,13
		dc.w		0,13
		dc.w		0,0
_SearchCancelStruct dc.b		1,0,RP_JAM2,0		
		dc.w		8,3		
		dc.l		0		
		dc.l		_SearchCancelText
		dc.l		0		
_SearchCancelText	dc.b		'CANCEL',0
		even
_SearchWinText	dc.b		1,0,RP_JAM2,0		
		dc.w		15,23		
		dc.l		0		
		dc.l		_SearchWinTextStr	
		dc.l		0		
_SearchWinTextStr	dc.b		'STRING  :',0
		even
_MyWindow	dc.w		0,10
		dc.w		640,189
		dc.b		0,1
		dc.l		CLOSEWINDOW!NEWSIZE!ACTIVEWINDOW!RAWKEY
		dc.l		WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE
		dc.l		0
		dc.l		0
		dc.l		_winname
		dc.l		0
		dc.l		0
		dc.w		50,50
		dc.w		640,256
		dc.w		WBENCHSCREEN
_winname	dc.b		'No File Loaded',0
		even
_LoadText	dc.b		'Load File ',0
		even
_SaveText	dc.b		'Save File ',0
		even
_scrn_Title	dc.b		'More Subroutine © M.Meany 1991. Press HELP for instructions. ',0
		even
_printername	dc.b		'prt:',0
		even
		rsreset
_window.ptr	rs.l		1	pointer to windows struct
_window.rp	rs.l		1	pointer to windows rastport
_buffer		rs.l		1	address of text file in memory
_buf_len	rs.l		1	length of text file
_line_list	rs.l		1	pointer to line table
_num_lines	rs.l		1	num of lines in file
_top_line	rs.l		1	line number of top line on screen
_lines_on_scrn	rs.l		1	max num of lines that can be printed
_linenum	rs.l		1	line number of print position
_max_top_line	rs.l		1	max value of top_line
_chars_on_line	rs.l		1	char width of a screen line
_scrn_width	rs.l		1	pixel width of screen line
_scrn_height	rs.l		1	pixel height of screen
_font.width	rs.l		1	width of font in use
_font.height	rs.l		1	height of font in use
_RFfile_name	rs.l		1
_RFfile_lock	rs.l		1
_RFfile_info	rs.l		1
_RFfile_len	rs.l		1
_line_buf	rs.l		100	buffer for expanded text
_SearchBuffer	rs.b		42	buffer for search string
_msg_text	rs.l	it_SIZEOF	space for IntuiText structure
_LoadFileStruct	rs.b	fr_SIZEOF+4	space for load filerequest struct
_SaveFileStruct	rs.b	fr_SIZEOF+4	space for save filerequest struct
_LoadFileData	rs.b	FCHARS+2	;reserve space for filename buffer
_LoadDirData	rs.b	DSIZE+1		;reserve space for path buffer
_SaveFileData	rs.b	FCHARS+2	;reserve space for filename buffer
_SaveDirData	rs.b	DSIZE+1		;reserve space for path buffer
_LoadPathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer
_SavePathName	rs.b	DSIZE+FCHARS+3	;reserve space for full pathname name buffer
_Mvars_sizeof	rs.l		0
		section	vars,BSS
_initial_file	ds.l		1
_CMD_len	ds.l		1
_about.ptr	ds.l		1
_AboutFlag	ds.l		1
_GotoFlag	ds.l		1
_MyPort		ds.l		1
_StillHere	ds.l		1
	section		pointer,data_c
_newptr	dc.w		$0000,$0000
	dc.w		$0000,$7ffe
	dc.w		$3ffc,$4002
	dc.w		$3ffc,$5ff6
	dc.w		$0018,$7fee
	dc.w		$0030,$7fde
	dc.w		$0060,$7fbe
	dc.w		$00c0,$7f7e
	dc.w		$0180,$7efe
	dc.w		$0300,$7dfe
	dc.w		$0600,$7bfe
	dc.w		$0c00,$77fe
	dc.w		$1ffc,$6ffa
	dc.w		$3ffc,$4002
	dc.w		$0000,$7ffe
	dc.w		$0000,$0000
	dc.w		$0000,$0000
	dc.w		$0000,$0000

; To all who have bothered to read this far, I would like to express my
;thanks to Steve Marshall for helping me tame my Amiga.
