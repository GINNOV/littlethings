*
*
*	TEXTMASTER: Version 1.10
*
*	©1991 BY NEIL JOHNSTON.
*
*	added loaded filename message, M.Meany 5.6.91

; Decided to do a re-vamp:
;1/ DOS Library not needed as you are using ARP, DELETED.
;2/ No need to open Intuition or Graphics libs as ARP does this, DELETED.
;3/ Added the text viewer subroutine I've written to display text before
;  and after processing. Two gadgets added to support this.
;  Hope you don't mind Neil, M.Meany, 11.6.91


	SECTION	TEXTMASTER,CODE

**********

	INCDIR	SYS:INCLUDE/
	INCLUDE	EXEC/EXEC_LIB.I
	INCLUDE	EXEC/EXEC.I
	INCLUDE	INTUITION/INTUITION_LIB.I
	INCLUDE	INTUITION/INTUITION.I
	INCLUDE	GRAPHICS/GRAPHICS_LIB.I
	INCLUDE	MISC/ARPBASE.I
	INCLUDE	MISC/POWERPACKER_LIB.I
	INCLUDE	MISC/PPBASE.I

	INCLUDE	MISC/EASYSTART.I	ENABLE WORKBENCH STARTUP

**********

CALLSYS	MACRO				BASIC CALLSYS MACRO
	JSR	_LVO\1(A6)
	ENDM

**********


		OPENARP				;use arp's own open macro
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

OPENLIBS

	LEA	PPname,A1
	MOVEQ.L	#0,D0
	MOVE.L	$4,A6
	CALLSYS	OpenLibrary
	MOVE.L	D0,Powerbase
	BNE	Main

**********

PPError
	Move.l	_ArpBase,a6

	CALLSYS	Output			Get output handle

	move.l	d0,d1
	move.l	#NoPPText,d2
	move.l	#NoPPTextLen,d3

	CALLSYS	Write

	bra	CloseLibs

**********

Main	LEA	MainWindow,A0
	MOVE.L	_IntuitionBase,A6
	CALLSYS	OpenWindow
	MOVE.L	D0,WinPtr		WINDOW OPEN?
	BEQ	FreeMemory		NO? QUIT...

	MOVE.L	D0,A0
	MOVE.L	wd_UserPort(A0),UserPort	SAVE USERPORT
	MOVE.L	wd_RPort(A0),RPort		SAVE RASTPORT

	move.l	RPort,a0
	lea	MessageBorder,a1
	moveq.l	#0,d0
	moveq.l	#0,d1

	move.l	_IntuitionBase,a6
	CALLSYS	DrawBorder		Draw message box's border

	lea	WelcomeText,a5		Print a nice 'Welcome' Message!
	bsr	PrintMessage

WaitForMsg
	MOVE.L	UserPort,A0

	MOVE.L	$4,A6
	CALLSYS	WaitPort

	MOVE.L	UserPort,A0
	CALLSYS	GetMsg

	MOVE.L	D0,A1
	MOVE.L	im_Class(A1),D2		SAVE MESSAGE CLASS
	MOVE.L	im_IAddress(A1),A2	SAVE GADGET ADDRESS

	CALLSYS	ReplyMsg

	CMP.L	#CLOSEWINDOW,D2
	BEQ.S	CloseWin		CLOSE WINDOW (& QUIT)

	CMP.L	#GADGETUP,D2
	BEQ.S	GadgetJump		GO TO GADGET JUMP ROUTINE

	BRA.S	WaitForMsg

**********

GadgetJump
	MOVE.L	gg_UserData(A2),A0
	CMPA.L	#0,A0			GADGET ASSIGNED?
	BEQ.S	WaitForMsg		IF NOT, DON'T JUMP TO $0!!!

	JMP	(A0)			JUMP TO GADGET ROUTINE

**********

CloseWin
	MOVE.L	WinPtr,A0
	MOVE.L	_IntuitionBase,A6
	CALLSYS	CloseWindow

**********

FreeMemory
	CMPI.B	#$FF,LoadFlag
	BNE.S	CloseLibs		DON'T FREE MEM, IF NOT ALLOCATED!
	MOVE.L	SourceBuffer,A1
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			FREE THE PP ALLOCATED MEM

	CMPI.B	#$FF,DestUsed
	BNE.S	ClosePP
	MOVE.L	DestBuffer,A1
	MOVE.L	DestLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			

**********
	
ClosePP
	MOVE.L	$4,A6
	MOVE.L	Powerbase,A1
	CALLSYS	CloseLibrary

CloseLibs
	MOVE.L	$4,A6
	MOVE.L	_ArpBase,A1
	CALLSYS	CloseLibrary

	MOVEQ.L	#0,D0			NO CLI ERROR MESSAGE

QEXIT	RTS				BYE!!!

**********

Prefix	MOVE.L	#0,D0
	LEA	Prefix_Gadget,A0
	MOVE.W	gg_Flags(A0),D0		GET GADGET FLAGS
	AND.W	#SELECTED,D0		GADGET SELECTED?
	BNE.S	Prefix_On

Prefix_Off
	MOVE.B	#$00,PreFlag		00 = NO PREFIX

	lea	PrefixOffText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

Prefix_On
	MOVE.B	#$FF,PreFlag		FF = YES PREFIX!

	lea	PrefixOnText,a5
	bsr	PrintMessage

	BRA	WaitForMsg


**********


Centre	MOVE.L	#0,D0
	LEA	Centre_Gadget,A0
	MOVE.W	gg_Flags(A0),D0		GET GADGET FLAGS
	AND.W	#SELECTED,D0		GADGET SELECTED?
	BNE.S	Centre_On

Centre_Off
	MOVE.B	#$00,CentFlag		00 = NO, CENTRE

	lea	CentreOffText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

Centre_On
	MOVE.B	#$FF,CentFlag		FF = YES, CENTRE

	lea	CentreOnText,a5
	bsr	PrintMessage

	BRA	WaitForMsg

**********

Load	LEA	ReqStruct,A0
	MOVE.L	_ArpBase,A6
	CALLSYS	FileRequest		STICK REQUESTER UP

	TST.L	D0
	BNE.S	.OK			USER SELECTED A FILE?

	BRA	WaitForMsg		QUIT IF NO NAME

.OK	LEA	PathBuffer,A0
	LEA	FullBuffer,A1

.Loop	MOVE.B	(A0)+,(A1)
	TST.B	(A1)			FOUND NULL TERMINATOR?
	BEQ.S	.Cont
	ADDA.L	#1,A1
	BRA	.Loop

.Cont	LEA	FullBuffer,A0
	LEA	FileBuffer,A1

	MOVE.L	_ArpBase,A6
	CALLSYS	TackOn			GET FULL PATHNAME

**********

ReadData
	CMPI.B	#$FF,LoadFlag		PREVIOUS FILE LOADED?
	BNE.S	.OK

	MOVE.L	SourceBuffer,A1		FREE OLD MEMORY:
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			FREE THE PP ALLOCATED MEM
	MOVE.B	#$00,LoadFlag		NO FILE LOADED

.OK	LEA	FullBuffer,A0		PATHNAME+FILENAME TO LOAD
	MOVE.L	#DECR_POINTER,D0	FLASH POINTER
	MOVE.L	#MEMF_PUBLIC,D1		ANY MEMORY
	LEA	SourceBuffer,A1		ADDRESS OF POINTER
	LEA	SourceLength,A2		ADDRESS OF POINTER
	MOVE.L	#0,A3			NOTHING SPECIAL!

	MOVE.L	Powerbase,A6
	CALLSYS	ppLoadData		READ FILE

	TST.L	D0
	BEQ.S	.OK2			NO LOADING PROBLEMS!

	lea	LoadErrText,a5
	bsr	PrintMessage		Tell 'em about the Loading problems!

	BRA	WaitForMsg

.OK2	lea	MMmsg,a5		;Print out file loaded message
	bsr	PrintMessage		;  << HAD TO DO SOMETHING >>

	move.l	SourceLength,d0		Number of bytes read
	cmp.l	#20000,d0
	bgt.s	.Error			File size too great

	MOVE.B	#$FF,LoadFlag		SO I KNOW A FILE WAS LOADED!
	MOVE.B	#$00,PrcessFlag		SO I KNOW IT HASN'T BEEN PROCESSED!

	BRA	WaitForMsg

.Error	MOVE.B	#$00,LoadFlag		SO I KNOW A FILE WASN'T LOADED!
	MOVE.B	#$00,PrcessFlag		HASN'T BEEN PROCESSED!

	MOVE.L	SourceBuffer,A1
	MOVE.L	SourceLength,D0
	MOVE.L	$4,A6
	CALLSYS	FreeMem			Free the memory
	
	lea	FileTooBigText,a5
	bsr	PrintMessage

	bra	WaitForMsg

**********

ProcessText
	CMPI.B	#$FF,LoadFlag		FILE LOADED YET?
	BEQ.S	.OK

	lea	NotLoadedText,a5	You 'aint loaded no text yet!
	bsr	PrintMessage

	BRA	WaitForMsg

.OK	cmp.b	#$ff,PrcessFlag		Text already processed?
	bne.s	.OK3

	lea	AlreadyProcessedText,a5
	bsr	PrintMessage

	bra	WaitForMsg
	
.OK3	move.l	#40000,d0		Alloc 'Bout 40K!
	MOVE.L	D0,DestLength
	MOVE.L	#MEMF_PUBLIC+MEMF_CLEAR,D1	CLEAR, PUBLIC MEMORY
	MOVE.L	$4,A6

	CALLSYS	AllocMem		GET DESTINATION MEMORY

	TST.L	D0
	BNE	.OK2			NO MEMORY = EXIT!

	lea	NoMemText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.OK2	move.b	#$ff,DestUsed		So We Can Deallocate it!
	MOVE.L	D0,DestBuffer		SAVE BUFFER ADDRESS

	move.b	#$00,NoProcessMsg

	MOVE.L	SourceBuffer,A0
	move.l	DestBuffer,A1

	moveq.l	#0,d1
	moveq.l	#0,d0
	lea	WidthBuffer,a2		My VERY basic ASCII->INT Routine:
	move.b	(a2)+,d1
	sub	#$30,d1
	mulu	#10,d1

	move.b	(a2),d0
	sub	#$30,d0
	add.l	d1,d0			d0 = Integer Screen width value
	move.w	d0,FullWidth

**********

FindLength
	move.b	#$00,OddFlag		'Odd number of Bytes on line' Flag!
	move.l	a0,a4			Save A0 (Line Start Address)
	moveq.l	#0,d1

GetLength
	cmpi.b	#$0a,(a0)		Return Char ($0a)
	beq.s	GotLength
	cmpi.b	#$00,(a0)		End of text yet?
	beq	Text_End
	addi.l	#1,d1			Line Length
	adda.l	#1,a0			Next Char
	bra.s	GetLength

GotLength
	move.l	d1,d2
	btst	#0,d1			Odd number of Bytes
	beq.s	.ok
	move.b	#$ff,OddFlag		Set OddFlag!

.ok	move.l	a4,a0			Restore A0
	moveq.l	#0,d0
	move.w	FullWidth,d0
	cmp.w	d0,d1			Is Line longer than screen width?
	blt.s	.ok2			No Problems!

	add.l	d1,a0			Problems! -- Sod that line then!
	adda.l	#1,a0			Bump a0 past Line's CR

	lea	LineClippedText,a5
	bsr	PrintMessage
	move.b	#$ff,NoProcessMsg

	bra	FindLength

.ok2	cmpi.l	#0,d1			Blank line? (Just CR)
	beq.s	BlankLine
	cmpi.b	#$ff,PreFlag
	bne	No_Prefix
	bra	Do_Prefix

**********

BlankLine
	adda.l	#1,a0			Bump A0 past offending CR
	cmpi.b	#$ff,PreFlag
	bne.s	.No

	cmpi.b	#$ff,CentFlag
	bne.s	.Exit			Just do nothing

	lea	DCtext,a2
	move.l	#DCtextLen-1,d7
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	move.b	(a2),$dff180		Supposed to make screen flicker->
	dbra	d7,.Loop		but it's a bit too quick!

	moveq.l	#0,d7
	move.w	FullWidth,d7
	subi.w	#1,d7			Correct D0 for DBRA loop
.Loop2	move.b	#$20,(a1)+		Print Space
	move.b	(a1),$dff180

	dbra	d7,.Loop2

	move.b	#"'",(a1)+		terminating "'"

.No	move.b	#$0a,(a1)+		CR
.Exit	bra	FindLength

**********

Do_Prefix
	lea	DCtext,a2
	move.l	#DCtextLen-1,d7
.Loop	move.b	(a2)+,(a1)+		Build "DC.B" Prefix
	move.b	(a2),$dff180
	dbra	d7,.Loop

No_Prefix
	move.l	d1,d2			d1 = Line's Length
	moveq.l	#0,d0

	cmpi.b	#$ff,PreFlag		Centre text if no prefix found
	bne.s	.OK

	cmpi.b	#$ff,CentFlag
	bne.s	DoText			Just do the text without pre-spaces

.OK	move.w	FullWidth,d0		Get screen's full width

	sub.l	d2,d0			Screen Width - Line Width
	and.l	#$fffffffe,d0		d1=even number (mask lsb)
	divu	#2,d0			Divide difference by 2

	subi.l	#1,d0			Correct D1 for DBRA Loop
	move.l	d0,d6			Save For Later!
	move.l	d0,d7
.Loop	move.b	#$20,(a1)+		Preceding Spaces
	move.b	(a1),$dff180
	dbra	d7,.Loop

DoText	move.l	d2,d7			Get Line Length
	sub.l	#1,d7			Correct D7 For DBRA Loop

.Loop2	cmpi.b	#"'",(a0)		GenAm takes ' to be '' in quotes
	bne.s	.Cont3

	cmpi.b	#$ff,PreFlag		Prfix requested?
	bne.s	.Cont3

	move.b	#"'",(a1)+		Double ['']s required 

.Cont3	move.b	(a0)+,(a1)+		Move byte from source to dest
	move.b	(a0),$dff180
	dbra	d7,.Loop2

	cmpi.b	#$ff,PreFlag
	bne.s	No_Prefix2

	cmpi.b	#$ff,CentFlag
	bne.s	.Cont			Just skip closing spaces

	move.l	d6,d7
.Loop3	move.b	#$20,(a1)+		Closing spaces
	move.b	(a1),$dff180
	dbra	d7,.Loop3

	cmpi.b	#$ff,CentFlag		Was a centre requested?
	beq.s	.Cont

	cmpi.b	#$ff,PreFlag		Was prefix requested?
	bne.s	.Cont

	move.b	#$20,(a1)+		Need another space!

.Cont	cmpi.b	#$ff,OddFlag
	bne.s	.Cont2
	move.b	#$20,(a1)+		Odd length lines require extra Byte!

.Cont2	move.b	#"'",(a1)+

No_Prefix2
	adda.l	#1,a0
	move.b	#$0a,(a1)+		Insert Return code

	move.l	SourceLength,d6
	move.l	a0,d5
	sub.l	SourceBuffer,d5
	cmp.l	d6,d5			End of Text?
	bge.s	Text_End		Branch if greater/equal

	bra	FindLength		Keep On Running.....

Text_End
	move.b	#$00,(a1)+		Null Terminator (just in case!)
	move.b	#$FF,PrcessFlag		So I know text has been processed

	cmp.b	#$ff,NoProcessMsg
	beq.s	.Cont

	lea	ProcessedText,a5
	bsr	PrintMessage

.Cont	bra	WaitForMsg

**********

Save	cmp.b	#$ff,PrcessFlag		Have we processed text?
	beq	.OK2		No? Don't try to save then!

	lea	NotLoadedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.OK2	lea	ReqStruct,A0
	move.l	_ArpBase,A6
	CALLSYS	FileRequest		STICK REQUESTER UP

	TST.L	D0
	BNE.S	.OK			USER SELECTED A FILE?

	BRA	WaitForMsg		QUIT IF NO NAME

.OK	LEA	PathBuffer,A0
	LEA	FullBuffer,A1

.Loop	MOVE.B	(A0)+,(A1)		Copy Path to A Buffer
	TST.B	(A1)			Found NULL Terminator?
	BEQ.S	.Cont
	ADDA.L	#1,A1
	BRA	.Loop

.Cont	LEA	FullBuffer,A0
	LEA	FileBuffer,A1

	MOVE.L	_ArpBase,A6
	CALLSYS	TackOn			Get Full Pathname

**********

GetSaveLength
	moveq.l	#0,d0
	move.l	DestBuffer,a0
.Loop	tst.b	(a0)+			Null Terminator?
	beq.s	.Cont
	addi.l	#1,d0
	bra.s	.Loop

	bra	WaitForMsg

.Cont	move.l	d0,SaveLength
	move.l	#FullBuffer,d1
	move.l	#MODE_NEWFILE,d2

	move.l	_ArpBase,a6
	CALLSYS	Open			Open new file

	move.l	d0,SaveHD
	beq	WaitForMsg

	move.l	SaveHD,d1
	move.l	DestBuffer,d2
	move.l	SaveLength,d3

	CALLSYS	Write			Save our text!!!

	move.l	SaveHD,d1
	CALLSYS	Close			Close File

	lea	TextSavedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

**********

*	MESSAGE PRINTER -- ENTRY:
*					A5 = POINTER TO TEXT

*		           EXIT:
*					BUGGER ALL!!

**********

PrintMessage

	bsr	ClearMessage		Clear old Message

	lea	MessageStruct,a0
	move.l	a5,it_IText(a0)		Stick string's address in IT struct	

	move.l	_IntuitionBase,a6
	CALLSYS	IntuiTextLength		Get pixel width of string

	move.l	#408,d1			Window's Width
	sub.l	d0,d1			Get Excess space
	divu	#2,d1			And divide by 2

	move.l	d1,d0
	moveq.l	#0,d1
	move.l	RPort,a0
	lea	MessageStruct,a1	Address of Intuitext Structure

	CALLSYS	PrintIText		Print the Message!!!

	rts

**********

ClearMessage
	move.l	RPort,a1
	move.l	#0,d0
	move.l	_GfxBase,a6

	CALLSYS	SetAPen			Crnt pen = BG colour

	move.l	RPort,a0		Window's rastport

	move.l	#21,d0			\
	move.l	#159,d1			 \ Definition of 
	move.l	#387,d2			 / Message box
	move.l	#166,d3			/

	CALLSYS	RectFill		Blank out message area

	rts


**********

ShowTheProc
	cmp.b	#$ff,PrcessFlag		Have we processed text?
	beq	.OK			No? Don't try to display it then!

	lea	NotProcessedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.OK	moveq.l	#0,d0
	move.l	DestBuffer,a0
.Loop	tst.b	(a0)+			Null Terminator?
	beq.s	.Cont
	addi.l	#1,d0
	bra.s	.Loop

.Cont	move.l	DestBuffer,a0
	bsr	ShowMem
	bra	WaitForMsg

**********

ShowTheText
	tst.l	SourceLength		Have we processed text?
	bne.s	.Cont			No? Don't try to display it then!

	lea	NotLoadedText,a5
	bsr	PrintMessage

	bra	WaitForMsg

.Cont	move.l	SourceBuffer,a0
	move.l	SourceLength,d0
	bsr	ShowMem
	bra	WaitForMsg

**********
;To display a text file:

;	ShowMem		( buffer, bytes )
;			     a0     d0

; 	a0 Should contain the address of the buffer in which the text is
;	   loaded. The text should be in a continuous block of memory.

;	d0 Should hold the size of the buffer, ie how many characters are
;	   in the text.

; ALL registers preserved on return.
; See Doc file for more info!

; © M.Meany, June 1991


ShowMem	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,_initial_file
	move.l	d0,_initial_len
	bsr	_GoForIt
	movem.l	(sp)+,d0-d7/a0-a6
	rts
_GoForIt	bsr	_OpenAWindow
	tst.l	d0
	beq.s	.error1
	bsr	_TailLoad
	tst.l	d0	
	beq.s	.error1	
	bsr	_WaitOnUser
.error1	rts	
_OpenAWindow	move.l	#_Mvars_sizeof,d0
	CALLARP	DosAllocMem
	move.l	d0,d6
	beq	.error
	move.l	d0,a4
	lea	_msg_text(a4),a0
	move.b	#1,it_FrontPen(a0)
	move.b	#RP_JAM2,it_DrawMode(a0)
	lea	_line_buf(a4),a1
	move.l	a1,it_IText(a0)
	lea	_MyWindow,a0
	CALLINT	OpenWindow
	move.l	d0,_window.ptr(a4)
	bne.s	.ok
	move.l	d6,a1
	CALLARP	DosFreeMem
	moveq.l	#0,d0
	bra	.error
.ok	move.l	d0,a0
	move.l	wd_RPort(a0),_window.rp(a4)
	move.l	d6,wd_UserData(a0)
	move.l	wd_UserPort(a0),_MyPort
	bsr	_win_sized
	move.l	_window.ptr(a4),a0
	lea	_winname,a1
	lea	_scrn_Title,a2
	CALLINT	SetWindowTitles
	moveq.l	#1,d0
	add.l	d0,_StillHere
.error	rts
_TailLoad	moveq.l	#0,d0
	tst.l	_initial_len
	beq.s	.no_file
	move.l	_initial_file,_buffer(a4)
	move.l	_initial_len,_buf_len(a4)
	bsr	_Count_Lines
	move.l	_num_lines(a4),_DStream
	lea	_Tmpl,a0
	lea	_DStream,a1
	lea	_PutCH,a2
	lea	_winname,a3
	CALLEXEC RawDoFmt
	move.l	_window.ptr(a4),a0
	lea	_winname,a1
	lea	_scrn_Title,a2
	CALLINT	SetWindowTitles
	moveq.l	#1,d0
.no_file	rts
_PutCH	move.b	d0,(a3)+
	rts
_refresh_display	tst.l	_line_list(a4)
	beq	_referror
	move.l	_window.rp(a4),a1
	moveq.l	#0,d0
	CALLGRAF	SetAPen
	move.l	_window.rp(a4),a1
	moveq.l	#4,d0
	moveq.l	#10,d1
	move.l	_scrn_width(a4),d2
	move.l	_scrn_height(a4),d3
	addq.l	#1,d3
	CALLGRAF	RectFill
	move.l	#10,_linenum(a4)
	move.l	_top_line(a4),d4
	move.l	_lines_on_scrn(a4),d5
	subq.l	#1,d5
_plop	move.l	d4,d0
	bsr	_print_line
	addq.l	#1,d4
	dbra	d5,_plop
_referror	rts
_print_line	cmp.l	_num_lines(a4),d0
	bgt	.error
	subq.l	#1,d0
	asl.l	#2,d0	x4
	add.l	_line_list(a4),d0
	move.l	d0,a1
	move.l	(a1),a1
	lea	_line_buf(a4),a0
	bsr	_expand_text
	lea	_line_buf(a4),a0
	move.l	_chars_on_line(a4),d0
	move.b	#0,0(a0,d0)
	lea	_msg_text(a4),a1
	move.l	_window.rp(a4),a0
	moveq.l	#5,d0
	move.l	_linenum(a4),d1
	CALLINT	PrintIText
	move.l	_font.height(a4),d0
	add.l	d0,_linenum(a4)
.error	rts
_expand_text	movem.l	d0-d7/a0-a1,-(sp)
	moveq.l	#0,d6
	moveq.l	#$09,d2	
	moveq.l	#$0a,d3
	moveq.l	#' ',d4
.next_char	move.b	(a1)+,d0
	cmp.b	d3,d0
	beq.s	.line_done
	cmp.b	d2,d0
	beq.s	.do_tab
	move.b	d0,0(a0,d6)	
	addq.w	#1,d6	
	bra.s	.next_char	
.line_done	move.b	#0,0(a0,d6)	
	movem.l	(sp)+,d0-d7/a0-a1
	rts
.do_tab	move.l	d6,d1	
	asr.w	#3,d1	
	addq.w	#1,d1
	asl.w	#3,d1
	sub.w	d6,d1
	subq.w	#1,d1	
.next_spc	move.b	d4,0(a0,d6)	
	addq.w	#1,d6	
	dbra	d1,.next_spc	
	bra.s	.next_char
_WaitOnUser	move.l	_MyPort,a0	
	CALLEXEC	WaitPort	
	move.l	_MyPort,a0	
	jsr	_LVOGetMsg(a6)	
	tst.l	d0	
	beq	_WaitOnUser	
	move.l	d0,a1	
	move.l	im_Class(a1),d2	
	move.l	im_Code(a1),d3	
	move.l	im_Qualifier(a1),d4
	move.l	im_IDCMPWindow(a1),a5
	move.l	im_IAddress(a1),a3 
	jsr	_LVOReplyMsg(a6)
	cmp.l	#CLOSEWINDOW,d2	
	bne.s	.check_resize	
	bsr	_win_closed
	bra	.test_complete
.check_resize	cmp.l	#NEWSIZE,d2	
	bne.s	.check_key
	bsr	_win_sized
	bra	.test_complete
.check_key	cmp.l	#RAWKEY,d2
	bne.s	.check_active
	bsr	_do_keys
	bra	.test_complete
.check_active	cmp.l	#ACTIVEWINDOW,d2
	bne.s	.check_gadg
	bsr	_win_activate
	bra	.test_complete
.check_gadg	cmp.l	#GADGETUP,d2
	bne.s	.test_complete
	move.l	gg_UserData(a3),a0
	jsr	(a0)
.test_complete	tst.l	_StillHere
	bne	_WaitOnUser
	rts
_win_sized	move.l	_window.ptr(a4),a0
	move.l	_window.rp(a4),a1
	moveq	#0,d1
	move.w	rp_TxWidth(a1),d1
	move.l	d1,_font.width(a4)
	move.w	rp_TxHeight(a1),d1	
	move.l	d1,_font.height(a4)
	moveq.l	#0,d0
	move.w	wd_Height(a0),d0
	sub.l	#12,d0
	move.l	d0,_scrn_height(a4)
	divu	d1,d0
	and.l	#$ffff,d0
	subq.l	#1,d0
	move.l	d0,_lines_on_scrn(a4)
	moveq	#0,d0
	move.w	wd_Width(a0),d0
	subq.w	#4,d0
	move.l	d0,_scrn_width(a4)
	divu	_font.width+2(a4),d0
	subq.w	#1,d0
	and.l	#$ffff,d0
	move.l	d0,_chars_on_line(a4)
	move.l	_window.rp(a4),a1
	moveq.l	#0,d0
	CALLGRAF	SetAPen
	move.l	_window.rp(a4),a1
	moveq.l	#4,d0
	move.l	_scrn_height(a4),d1
	move.l	_scrn_width(a4),d2
	sub.l	#12,d2
	move.l	d1,d3
	add.l	#10,d3
	CALLGRAF	RectFill
	bsr	_refresh_display
	rts
_do_keys	swap	d3
	cmpi.b	#$24,d3	
	bne.s	.is_Q
	bsr	_GotoLine
	bra	.ok
.is_Q	cmpi.b	#$10,d3	
	bne.s	.is_T
	bsr	_win_closed
	bra	.ok
.is_T	cmpi.b	#$14,d3	
	bne.s	.is_B
	bsr	_GoTop
	bra	.ok
.is_B	cmpi.b	#$35,d3	
	bne.s	.is_F
	bsr	_GoBot
	bra	.ok
.is_F	cmpi.b	#$23,d3	
	bne.s	.is_N
	bsr	_SearchString
	bra	.ok
.is_N	cmpi.b	#$36,d3	
	bne.s	.is_D
	bsr	_Next
	bra	.ok
.is_D	cmpi.b	#$22,d3	
	bne.s	.is_up
	bsr	_DumpFile
	bra	.ok
.is_up	cmpi.b	#$4d,d3	
	bne.s	.is_down
	and.l	#$30000,d4	
	bne.s	.is_pup
	bsr	_line_up
	bra	.ok
.is_pup	bsr	_page_up	
	bra	.ok
.is_down	cmpi.b	#$4c,d3	
	bne.s	.is_about
	and.l	#$30000,d4	
	bne.s	.is_pdown
	bsr	_line_down
	bra	.ok
.is_pdown	bsr	_page_down	
	bra	.ok
.is_about	cmpi.b	#$5f,d3	
	bne.s	.ok
	bsr	_About
	bra.s	.ok
	nop
.ok	rts
_DumpFile	bsr	_PointerOn
	move.l	#_printername,d1
	move.l	#MODE_NEWFILE,d2
	CALLARP	Open
	move.l	d0,d5
	beq	.error
	move.l	d0,d1
	move.l	_buffer(a4),d2
	move.l	_buf_len(a4),d3
	jsr	_LVOWrite(a6)
	move.l	d5,d1
	jsr	_LVOClose(a6)
.error	bsr	_PointerOff
	rts
_GoTop	move.l	#1,_top_line(a4)
	bsr	_refresh_display
	rts
_GoBot	move.l	_max_top_line(a4),_top_line(a4)
	bsr	_refresh_display
	rts
_line_up	tst.l	_line_list(a4)
	beq	.error
	move.l	_top_line(a4),d0
	cmp.l	_max_top_line(a4),d0
	beq	.error
	addq.l	#1,d0
	move.l	d0,_top_line(a4)
	move.l	_window.rp(a4),a1
	moveq.l	#0,d0
	move.l	_font.height(a4),d1
	moveq.l	#5,d2
	moveq.l	#10,d3
	move.l	_scrn_width(a4),d4
	move.l	_font.height(a4),d5
	mulu	_lines_on_scrn+2(a4),d5
	add.l	#9,d5
	CALLGRAF	ScrollRaster
	move.l	_lines_on_scrn(a4),d0
	subq.l	#1,d0
	move.l	d0,d1
	mulu	_font.height+2(a4),d1
	add.l	#10,d1
	move.l	d1,_linenum(a4)
	add.l	_top_line(a4),d0
	bsr	_print_line
.error	rts
_line_down	tst.l	_line_list(a4)
	beq	.error
	move.l	_top_line(a4),d0
	subq.l	#1,d0
	beq	.error
	move.l	d0,_top_line(a4)
	move.l	_window.rp(a4),a1
	moveq.l	#0,d0
	move.l	_font.height(a4),d1
	neg.l	d1
	moveq.l	#5,d2
	moveq.l	#10,d3
	move.l	_scrn_width(a4),d4
	move.l	_font.height(a4),d5
	mulu	_lines_on_scrn+2(a4),d5
	add.l	#9,d5
	CALLGRAF	ScrollRaster
	move.l	#10,_linenum(a4)
	move.l	_top_line(a4),d0
	bsr	_print_line
.error	rts
_page_up	tst.l	_line_list(a4)
	beq	.error
	move.l	_top_line(a4),d0
	add.l	_lines_on_scrn(a4),d0
	subq.l	#1,d0
	cmp.l	_max_top_line(a4),d0
	ble.s	.ok
	move.l	_max_top_line(a4),d0
.ok	move.l	d0,_top_line(a4)
	bsr	_refresh_display
.error	rts
_page_down	tst.l	_line_list(a4)
	beq	.error
	move.l	_top_line(a4),d0
	sub.l	_lines_on_scrn(a4),d0
	addq.l	#1,d0
	cmp.l	#1,d0
	bge.s	.ok
	move.l	#1,d0
.ok	move.l	d0,_top_line(a4)
	bsr	_refresh_display
.error	rts
_Count_Lines	moveq.l	#0,d0	
	move.l	d0,d1	
	moveq.l	#$0a,d2	
	move.l	_buf_len(a4),d3	
	move.l	_buffer(a4),a0	
	movem.l	d1-d3/a0,-(sp)	
_lf_loop	cmp.b	(a0)+,d2	
	bne.s	.ok	
	addq.l	#1,d0	
.ok	subq.l	#1,d3	
	bne.s	_lf_loop
	move.l	d0,_num_lines(a4)
	addq.l	#2,d0	
	asl.l	#2,d0	
	CALLARP	DosAllocMem	
	movem.l	(sp)+,d1-d3/a0	
	move.l	d0,_line_list(a4)
	beq.s	_ld_mem_err	
	move.l	d0,a1	
	move.l	a0,(a1)+	
_table_loop	cmp.b	(a0)+,d2	
	bne.s	.ok	
	move.l	a0,(a1)+	
.ok	subq.l	#1,d3	
	bne.s	_table_loop	
	move.l	#1,_top_line(a4)	
	move.l	_lines_on_scrn(a4),d0
	move.l	_num_lines(a4),d1
	sub.l	d0,d1
	beq.s	.error
	bmi.s	.error
	bra	.ok1
.error	moveq.l	#1,d1
.ok1	move.l	d1,_max_top_line(a4)
	bsr	_refresh_display
	bra	_load_error
_ld_mem_err	move.l	#0,a0
	CALLINT	DisplayBeep
_load_error	bsr	_PointerOff
	moveq.l	#0,d0
	rts
_PointerOn	move.l	_window.ptr(a4),a0
	lea	_newptr,a1
	moveq.l	#16,d0
	move.l	d0,d1
	moveq.l	#0,d2
	move.l	d2,d3
	CALLINT	SetPointer
	rts
_PointerOff	move.l	_window.ptr(a4),a0
	CALLINT	ClearPointer
	rts
_win_activate	move.l	wd_UserData(a5),a4
	rts
_win_closed	move.l	wd_UserData(a5),a3	
	move.l	_line_list(a3),a1
	CALLARP	DosFreeMem
.ok	move.l	a3,a1
	CALLARP	DosFreeMem
	move.l	a5,a0
	CALLINT	CloseWindow
	subq.l	#1,_StillHere
	rts
_About	lea	_AboutWin,a0
	CALLINT	OpenWindow
	move.l	d0,d7
	beq	_NoAbout
	move.l	d0,a0
	move.l	wd_UserPort(a0),a3
	move.l	wd_RPort(a0),a5
	move.l	a5,a0	
	lea	_AboutIT,a1	
	moveq.l	#0,d0	
	move.l	d0,d1	
	jsr	_LVOPrintIText(a6)
_WaitAbout	move.l	a3,a0	
	CALLEXEC	WaitPort	
	move.l	a3,a0	
	jsr	_LVOGetMsg(a6)	
	tst.l	d0	
	beq.s	_WaitAbout	
	move.l	d0,a1	
	move.l	im_Class(a1),d2	
	CALLEXEC	ReplyMsg	
	cmp.l	#GADGETUP,d2	
	bne.s	_WaitAbout
	move.l	d7,a0
	CALLINT	CloseWindow
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
_AboutWinName	dc.b	'ShowMem Subroutine © M.Meany 1991',0
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
_AboutIT	dc.b	1,0,RP_JAM2,0
	dc.w	13,16
	dc.l	0
	dc.l	_ITextText3
	dc.l	_IText4
_ITextText3	dc.b	'The subroutines used to display this text are ',0
	even
_IText4:
	dc.b	1,0,RP_JAM2,0
	dc.w	13,25
	dc.l	0
	dc.l	_ITextText4
	dc.l	_IText5
_ITextText4:
	dc.b	'Public Domain. They were written by M.Meany.  ',0
	even
_IText5:
	dc.b	1,0,RP_JAM2,0
	dc.w	14,34
	dc.l	0
	dc.l	_ITextText5
	dc.l	_IText6
_ITextText5:
	dc.b	'Assembly source and instructions available  ',0
	even
_IText6:
	dc.b	1,0,RP_JAM2,0
	dc.w	14,44
	dc.l	0
	dc.l	_ITextText6
	dc.l	_IText7
_ITextText6:
	dc.b	'on ACC disc 13. Contact Amiganuts United.',0
	even
_IText7:
	dc.b	1,0,RP_JAM2,0
	dc.w	14,54
	dc.l	0
	dc.l	_ITextText7
	dc.l	_IText10
_ITextText7:
	dc.b	'Phone (O7O3) 78568O for more information.',0
	even
_IText10:
	dc.b	3,0,RP_JAM2,0
	dc.w	101,64
	dc.l	0
	dc.l	_ITextText10
	dc.l	_IText9
_ITextText10:
	dc.b	'INSTRUCTION SUMMARY ',0
	even
_IText9
	dc.b	1,0,RP_JAM2,0
	dc.w	20,180
	dc.l	0
	dc.l	_ITextText9
	dc.l	_IText11
_ITextText9
	dc.b	'Q      Quit',0
	even
_IText11:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,150
	dc.l	0
	dc.l	_ITextText11
	dc.l	_IText12
_ITextText11:
	dc.b	'P      Find previous occurence',0
	even
_IText12:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,90
	dc.l	0
	dc.l	_ITextText12
	dc.l	_IText13
_ITextText12:
	dc.b	'CURSOR UP     Line up (+shift for page up)',0
	even
_IText13:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,100
	dc.l	0
	dc.l	_ITextText13
	dc.l	_IText14
_ITextText13:
	dc.b	'CURSOR DOWN   Line down (+shift for page down)',0
	even
_IText14:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,110
	dc.l	0
	dc.l	_ITextText14
	dc.l	_IText15
_ITextText14:
	dc.b	'T      Top of file',0
	even
_IText15:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,120
	dc.l	0
	dc.l	_ITextText15
	dc.l	_IText16
_ITextText15:
	dc.b	'B      Bottom of file',0
	even
_IText16:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,130
	dc.l	0
	dc.l	_ITextText16
	dc.l	_IText17
_ITextText16:
	dc.b	'F      Search for string',0
	even
_IText17:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,140
	dc.l	0
	dc.l	_ITextText17
	dc.l	_IText18
_ITextText17:
	dc.b	'N      Find next occurence',0
	even
_IText18:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,170
	dc.l	0
	dc.l	_ITextText18
	dc.l	_IText19
_ITextText18:
	dc.b	'D      Dump file to printer',0
	even
_IText19:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,160
	dc.l	0
	dc.l	_ITextText19
	dc.l	_IText20
_ITextText19:
	dc.b	'G      Goto line number xxxx',0
	even
_IText20:
	dc.b	1,0,RP_JAM2,0
	dc.w	20,80
	dc.l	0
	dc.l	_ITextText20
	dc.l	0
_ITextText20:
	dc.b	'HELP   This page',0
	even
_GotoLine	move.l	#0,_LineBuffer
	lea	_line_window,a0	
	CALLINT	OpenWindow	
	move.l	d0,_line.ptr	
	lea	_LineWinText,a1	
	move.l	_line.ptr,a0	
	move.l	wd_RPort(a0),a0	
	moveq.l	#0,d0	
	moveq	#0,d1	
	jsr	_LVOPrintIText(a6)
	lea	_LineGadg,a0
	move.l	_line.ptr,a1
	move.l	#0,a2
	jsr	_LVOActivateGadget(a6)
_WaitForLine	move.l	_line.ptr,a0	
	move.l	wd_UserPort(a0),a0
	CALLEXEC	WaitPort	
	move.l	_line.ptr,a0	
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(A6)	
	tst.l	d0	
	beq.s	_WaitForLine	
	move.l	d0,a1	
	move.l	im_Class(a1),d2	
	move.l	im_IAddress(a1),a5
	jsr	_LVOReplyMsg(a6) 
	cmp.l	#GADGETUP,d2
	bne.s	_WaitForLine
	move.l	gg_UserData(a5),a5
	jsr	(a5)
	move.l	_line.ptr,a0	
	CALLINT	CloseWindow	
	cmp.l	_max_top_line(a4),d7
	ble.s	.ok
	move.l	_max_top_line(a4),d7
.ok	move.l	d7,_top_line(a4)
	bsr	_refresh_display
	rts
_GotLineNum	lea	_LineGadgInfo,a5
	move.l	si_LongInt(a5),d7
	bpl.s	_ok
_NoLineNum	move.l	_top_line(a4),d7
_ok	rts
_line.ptr	dc.l	0
_line_window	dc.w	150,90	
	dc.w	279,67	
	dc.b	0,2	
	dc.l	GADGETUP
	dc.l	ACTIVATE	
	dc.l	_LineGadg
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.w	5,5	
	dc.w	640,200	
	dc.w	WBENCHSCREEN	
_LineGadg	dc.l	_LineOKGadg	
	dc.w	120,22	
	dc.w	44,8
	dc.w	0	
	dc.w	RELVERIFY+LONGINT+GADGIMMEDIATE
	dc.w	STRGADGET	
	dc.l	0
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.l	_LineGadgInfo	
	dc.w	0	
	dc.l	_GotLineNum
_LineGadgInfo	dc.l	_LineBuffer
	dc.l	0	
	dc.w	0	
	dc.w	5	
	dc.w	0	
	dc.w	0,0,0,0,0	
	dc.l	0	
	dc.l	0	
	dc.l	0	
_LineBuffer	dc.b	0,0,0,0,0
	even
_LineOKGadg	dc.l	_LineCancelGadg	
	dc.w	33,49	
	dc.w	64,12	
	dc.w	0	
	dc.w	RELVERIFY	
	dc.w	BOOLGADGET	
	dc.l	_LineOKBorder
	dc.l	0	
	dc.l	_LineOKStruct
	dc.l	0	
	dc.l	0	
	dc.w	0	
	dc.l	_GotLineNum	
_LineOKBorder	dc.w	-2,-1	
	dc.b	2,0,RP_JAM1	
	dc.b	5	
	dc.l	_LineOKVectors
	dc.l	0	
_LineOKVectors	dc.w	0,0
	dc.w	67,0
	dc.w	67,13
	dc.w	0,13
	dc.w	0,0
_LineOKStruct	dc.b	1,0,RP_JAM2,0	
	dc.w	24,3	
	dc.l	0	
	dc.l	_LineOKText	
	dc.l	0	
_LineOKText	dc.b	'OK',0
	even
_LineCancelGadg	dc.l	0	
	dc.w	180,49	
	dc.w	64,12	
	dc.w	0	
	dc.w	RELVERIFY	
	dc.w	BOOLGADGET	
	dc.l	_LineCancelBorder
	dc.l	0	
	dc.l	_LineCancelStruct
	dc.l	0	
	dc.l	0	
	dc.w	0	
	dc.l	_NoLineNum
_LineCancelBorder dc.w	-2,-1	
	dc.b	2,0,RP_JAM1	
	dc.b	5	
	dc.l	_LineCancelVectors
	dc.l	0	
_LineCancelVectors dc.w	0,0
	dc.w	67,0
	dc.w	67,13
	dc.w	0,13
	dc.w	0,0
_LineCancelStruct dc.b	1,0,RP_JAM2,0	
	dc.w	8,3	
	dc.l	0	
	dc.l	_LineCancelText
	dc.l	0	
_LineCancelText	dc.b	'CANCEL',0
	even
_LineWinText	dc.b	1,0,RP_JAM2,0	
	dc.w	15,23	
	dc.l	0	
	dc.l	_LineWinTextStr	
	dc.l	0	
_LineWinTextStr	dc.b	'GO TO LINE :',0
	even
_SearchString	lea	_SearchBuffer(a4),a0	
	move.l	a0,_SearchGadgInfo	
	lea	_search_window,a0	
	CALLINT	OpenWindow	
	move.l	d0,_search.ptr	
	lea	_SearchWinText,a1
	move.l	_search.ptr,a0	
	move.l	wd_RPort(a0),a0	
	moveq.l	#0,d0	
	moveq	#0,d1	
	jsr	_LVOPrintIText(a6)
	lea	_SearchGadg,a0
	move.l	_search.ptr,a1
	move.l	#0,a2
	jsr	_LVOActivateGadget(a6)
_WaitForSearch	move.l	_search.ptr,a0	
	move.l	wd_UserPort(a0),a0
	CALLEXEC	WaitPort	
	move.l	_search.ptr,a0	
	move.l	wd_UserPort(a0),a0
	jsr	_LVOGetMsg(a6)	
	tst.l	d0	
	beq.s	_WaitForSearch	
	move.l	d0,a1	
	move.l	im_Class(a1),d2	
	move.l	im_IAddress(a1),a5
	jsr	_LVOReplyMsg(a6) 
	cmp.l	#GADGETUP,d2
	bne.s	_WaitForSearch
	move.l	gg_UserData(a5),a5
	jsr	(a5)
	move.l	_search.ptr,a0	
	CALLINT	CloseWindow	
	bsr	_refresh_display
	rts
_GotSearchNum	lea	_SearchBuffer(a4),a0
	move.l	a0,a1
	moveq.l	#-1,d0
	moveq.l	#0,d1
.loop	addq.l	#1,d0
	cmp.b	(a1)+,d1
	bne.s	.loop
	tst.l	d0
	beq	.error
	move.l	_buffer(a4),a1
	move.l	_buf_len(a4),d1
	bsr	_Find
	beq	.error
	move.l	_line_list(a4),a0
	moveq.l	#0,d1
.loop1	addq.l	#1,d1
	cmp.l	(a0)+,d0
	bge.s	.loop1
	subq.l	#1,d1
	cmp.l	_max_top_line(a4),d1
	ble.s	.okk
	move.l	_max_top_line(a4),d1
.okk	move.l	d1,_top_line(a4)
.error	rts
_NoSearchNum	rts
_Next	move.l	_top_line(a4),d0
	addq.l	#1,d0
	cmp.l	_max_top_line(a4),d0
	bge.s	.error
	move.l	_line_list(a4),a0
	subq.l	#1,d0
	asl.l	#2,d0
	move.l	0(a0,d0),d0
	move.l	d0,a1
	move.l	_buf_len(a4),d1
	add.l	_buffer(a4),d1
	sub.l	d0,d1
	lea	_SearchBuffer(a4),a0
	move.l	a0,a2
	moveq.l	#-1,d0
	moveq.l	#0,d2
.loop	addq.l	#1,d0
	cmp.b	(a2)+,d2
	bne.s	.loop
	tst.l	d0
	beq	.error
	bsr	_Find
	beq	.error
	move.l	_line_list(a4),a0
	moveq.l	#0,d1
.loop1	addq.l	#1,d1
	cmp.l	(a0)+,d0
	bge.s	.loop1
	subq.l	#1,d1
	cmp.l	_max_top_line(a4),d1
	ble.s	.okk
	move.l	_max_top_line(a4),d1
.okk	move.l	d1,_top_line(a4)
	bsr	_refresh_display
.error	rts
_Find	movem.l	d1-d2/a0-a2,-(sp)
	move.l	#0,_MatchFlag	
	sub.l	d0,d1	
	subq.l	#1,d1	
	bmi.s	_FindError	
	move.b	(a0),d2	
_Floop	cmp.b	(a1)+,d2	
	dbeq	d1,_Floop	
	bne.s	_FindError	
	bsr.s	_CompStr	
	beq.s	_Floop	
_FindError	movem.l	(sp)+,d1-d2/a0-a2
	move.l	_MatchFlag,d0	
	rts
_CompStr	movem.l	d0/a0-a2,-(sp)
	subq.l	#1,d0	
	move.l	a1,a2	
	subq.l	#1,a1	
_FFloop	cmp.b	(a0)+,(a1)+	
	dbne	d0,_FFloop	
	bne.s	_ComprDone	
	subq.l	#1,a2	
	move.l	a2,_MatchFlag	
_ComprDone	movem.l	(sp)+,d0/a0-a2
	tst.l	_MatchFlag	
	rts
_MatchFlag	dc.l	0
_search.ptr	dc.l	0
_search_window	dc.w	150,90	
	dc.w	279,67	
	dc.b	0,2	
	dc.l	GADGETUP
	dc.l	ACTIVATE	
	dc.l	_SearchGadg
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.w	5,5	
	dc.w	640,200	
	dc.w	WBENCHSCREEN	
_SearchGadg	dc.l	_SearchOKGadg	
	dc.w	110,22	
	dc.w	164,8
	dc.w	0	
	dc.w	RELVERIFY+GADGIMMEDIATE
	dc.w	STRGADGET	
	dc.l	0
	dc.l	0	
	dc.l	0	
	dc.l	0	
	dc.l	_SearchGadgInfo	
	dc.w	0	
	dc.l	_GotSearchNum
_SearchGadgInfo	dc.l	0	
	dc.l	0
	dc.w	0	
	dc.w	40
	dc.w	0	
	dc.w	0,0,0,0,0	
	dc.l	0	
	dc.l	0	
	dc.l	0	
_SearchOKGadg	dc.l	_SearchCancelGadg	
	dc.w	33,49	
	dc.w	64,12	
	dc.w	0	
	dc.w	RELVERIFY	
	dc.w	BOOLGADGET	
	dc.l	_SearchOKBorder
	dc.l	0	
	dc.l	_SearchOKStruct
	dc.l	0	
	dc.l	0	
	dc.w	0	
	dc.l	_GotSearchNum	
_SearchOKBorder	dc.w	-2,-1	
	dc.b	2,0,RP_JAM1	
	dc.b	5	
	dc.l	_SearchOKVectors
	dc.l	0	
_SearchOKVectors dc.w	0,0
	dc.w	67,0
	dc.w	67,13
	dc.w	0,13
	dc.w	0,0
_SearchOKStruct	dc.b	1,0,RP_JAM2,0	
	dc.w	24,3	
	dc.l	0	
	dc.l	_SearchOKText	
	dc.l	0	
_SearchOKText	dc.b	'OK',0
	even
_SearchCancelGadg	dc.l	0	
	dc.w	180,49	
	dc.w	64,12	
	dc.w	0	
	dc.w	RELVERIFY	
	dc.w	BOOLGADGET	
	dc.l	_SearchCancelBorder
	dc.l	0	
	dc.l	_SearchCancelStruct
	dc.l	0	
	dc.l	0	
	dc.w	0	
	dc.l	_NoSearchNum
_SearchCancelBorder dc.w	-2,-1	
	dc.b	2,0,RP_JAM1	
	dc.b	5	
	dc.l	_SearchCancelVectors
	dc.l	0	
_SearchCancelVectors dc.w	0,0
	dc.w	67,0
	dc.w	67,13
	dc.w	0,13
	dc.w	0,0
_SearchCancelStruct dc.b	1,0,RP_JAM2,0	
	dc.w	8,3	
	dc.l	0	
	dc.l	_SearchCancelText
	dc.l	0	
_SearchCancelText	dc.b	'CANCEL',0
	even
_SearchWinText	dc.b	1,0,RP_JAM2,0	
	dc.w	15,23	
	dc.l	0	
	dc.l	_SearchWinTextStr	
	dc.l	0	
_SearchWinTextStr	dc.b	'STRING  :',0
	even
_MyWindow	dc.w	0,10
	dc.w	640,189
	dc.b	0,1
	dc.l	CLOSEWINDOW!NEWSIZE!ACTIVEWINDOW!RAWKEY
	dc.l	WINDOWSIZING+WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE
	dc.l	0
	dc.l	0
	dc.l	_winname
	dc.l	0
	dc.l	0
	dc.w	50,50
	dc.w	640,256
	dc.w	WBENCHSCREEN
_winname	dc.b	'Viewing Text ',0
	ds.b	50
	even
_Tmpl	dc.b	'Viewing Text       ( %ld lines ) ',0
	even
_DStream dc.l	0
_scrn_Title	dc.b	'                Press HELP for instructions. ',0
	even
_printername	dc.b	'prt:',0
	even

	rsreset
_window.ptr	rs.l	1
_window.rp	rs.l	1
_buffer	rs.l	1
_buf_len	rs.l	1
_line_list	rs.l	1
_num_lines	rs.l	1
_top_line	rs.l	1
_lines_on_scrn	rs.l	1
_linenum	rs.l	1
_max_top_line	rs.l	1
_chars_on_line	rs.l	1
_scrn_width	rs.l	1
_scrn_height	rs.l	1
_font.width	rs.l	1
_font.height	rs.l	1
_RFfile_name	rs.l	1
_RFfile_lock	rs.l	1
_RFfile_info	rs.l	1
_RFfile_len	rs.l	1
_line_buf	rs.l	100
_SearchBuffer	rs.b	42
_msg_text	rs.l	it_SIZEOF
_Mvars_sizeof	rs.l	0

	section	vars,BSS
_initial_file	ds.l	1
_initial_len	ds.l	1
_about.ptr	ds.l	1
_AboutFlag	ds.l	1
_GotoFlag	ds.l	1
_MyPort	ds.l	1
_StillHere	ds.l	1

	section	pointer,data_c
_newptr	dc.w	$0000,$0000
	dc.w	$0000,$7ffe
	dc.w	$3ffc,$4002
	dc.w	$3ffc,$5ff6
	dc.w	$0018,$7fee
	dc.w	$0030,$7fde
	dc.w	$0060,$7fbe
	dc.w	$00c0,$7f7e
	dc.w	$0180,$7efe
	dc.w	$0300,$7dfe
	dc.w	$0600,$7bfe
	dc.w	$0c00,$77fe
	dc.w	$1ffc,$6ffa
	dc.w	$3ffc,$4002
	dc.w	$0000,$7ffe
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000


**********
**********

Intname	DC.B	'intuition.library',0
	EVEN

Dosname	DC.B	'dos.library',0
	EVEN

Gfxname	DC.B	'graphics.library',0
	EVEN

PPname	DC.B	'powerpacker.library',0
	EVEN

ARPname	DC.B	'arp.library',0
	EVEN

_IntuitionBase	DC.L	0
_ArpBase	DC.L	0
_GfxBase	DC.L	0
Powerbase	DC.L	0		'PPBASE' ALREADY DEFINED!

WinPtr		DC.L	0
UserPort	DC.L	0
RPort		DC.L	0
SaveHD		DC.L	0
SaveLength	DC.L	0

SourceBuffer	DC.L	0
SourceLength	DC.L	0
DestBuffer	DC.L	0
DestLength	DC.L	0
FullWidth	DC.W	0

PreFlag		DC.B	0
CentFlag	DC.B	0
LoadFlag	DC.B	0
PrcessFlag	DC.B	0
DestUsed	DC.B	0
OddFlag		DC.B	0
NoProcessMsg	DC.B	0
		EVEN

MMmsg		dc.b	'Loaded..'
FullBuffer	DS.B	80

DCtext		DC.B	"	DC.B	'"
DCtextLen	EQU	*-DCtext
		EVEN

**********	STRUCTURES!!!

MainWindow
	DC.W	116,30			X/Y ORIGIN
	DC.W	408,175			WIDTH/HEIGHT
	DC.B	0,1			PEN COLOURS
	DC.L	CLOSEWINDOW+GADGETUP	IDCMP FLAGS
	DC.L	WINDOWDRAG+WINDOWDEPTH+WINDOWCLOSE+ACTIVATE	WINDOW FLAGS
	DC.L	Load_Gadget		START OF GADGET LIST
	DC.L	0			CHECKMARK
	DC.L	WindowName		PONTER TO NAME
	DC.L	0,0			CUSTOM SCREEN/BITMAP
	DC.W	0,0			MIN WIDTH/HEIGHT
	DC.W	0,0			MAX WIDTH/HEIGHT
	DC.W	WBENCHSCREEN		SCREENTYPE

WindowName
	DC.B	'TEXTMASTER V1.10  ©1991 BY NEIL JOHNSTON',0
	EVEN

**********

Load_Gadget
	DC.L	Save_Gadget		NEXT GADGET
	DC.W	20,15			X/Y ORIGIN
	DC.W	172,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Load_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Load			USER DATA

Load_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	172,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Load_Image_Data		POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Save_Gadget
	DC.L	Prefix_Gadget		NEXT GADGET
	DC.W	220,15			X/Y ORIGIN
	DC.W	166,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Save_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Save			USER DATA

Save_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	166,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Save_Image_Data		POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Prefix_Gadget
	DC.L	Process_Gadget		NEXT GADGET
	DC.W	113,46			X/Y ORIGIN
	DC.W	180,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY+TOGGLESELECT	ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Prefix_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Prefix			USER DATA

Prefix_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	180,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Prefix_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Process_Gadget
	DC.L	Centre_Gadget		NEXT GADGET
	DC.W	92,108			X/Y ORIGIN
	DC.W	221,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Process_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	ProcessText		USER DATA

Process_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	221,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Process_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Centre_Gadget
	DC.L	Width_Gadget		NEXT GADGET
	DC.W	95,77			X/Y ORIGIN
	DC.W	215,26			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY+TOGGLESELECT	ACTIVATION FLAGS
	DC.W	BOOLGADGET		GADGET TYPES
	DC.L	Centre_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	0			SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	Centre			USER DATA

Centre_Image
	DC.W	0,0			X/Y ORIGIN
	DC.W	215,26			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Centre_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

**********

Width_Gadget
	DC.L	ViewTextGadg		NEXT GADGET
	DC.W	354,142			X/Y ORIGIN
	DC.W	24,8			WIDTH/HEIGHT
	DC.W	GADGIMAGE		FLAGS
	DC.W	RELVERIFY		ACTIVATION FLAGS
	DC.W	STRGADGET		GADGET TYPES
	DC.L	Width_Image		IMAGE POINTER
	DC.L	0			NO ALTERNATE IMAGE
	DC.L	0			POINTER TO INTUITEXT STRUCTURE
	DC.L	0			MUTUAL EXCLUDE
	DC.L	Width_Info		SPECIAL INFO
	DC.W	0			GADGET ID
	DC.L	0			USER DATA

Width_Image
	DC.W	-166,-3			X/Y ORIGIN
	DC.W	194,13			WIDTH/HEIGHT
	DC.W	1			DEPTH
	DC.L	Width_Image_Data	POINTER TO IMAGE DATA
	DC.B	1,0			PLANEPICK/PLANEONOFF
	DC.L	0			NEXT IMAGE

Width_Info
	DC.L	WidthBuffer		POINTER TO BUFFER
	DC.L	0			UNDO BUFFER
	DC.W	0			CHARACTER POSITION IN BUFFER
	DC.W	3			MAX NO CHARS+1 (TERMINATING NULL)
	DC.W	0			FIRST CHARACTER POSITION
	DC.W	0			UNDO POS
	DC.W	0			NUM CHARS IN BUFFER
	DC.W	0			NO OF CHARS DISPLAYED
	DC.W	0			CONTAINER LEFT OFFSET
	DC.W	0			CONTAINER TOP OFFSET
	DC.L	RPort			GADGET'S RASTPORT
	DC.L	0			LONGINT
	DC.L	0			ALTERNATIVE KEYMAP

WidthBuffer
	DC.B	'80',0
	EVEN

**********

ViewTextGadg	dc.l		ViewProcGadg
		dc.w		9,140
		dc.w		83,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		ShowTheText
.Border		dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0
.Vectors	dc.w		0,0
		dc.w		86,0
		dc.w		86,12
		dc.w		0,12
		dc.w		0,0
.IText		dc.b		1,0,RP_JAM2,0
		dc.w		5,2
		dc.l		0
		dc.l		.Text
		dc.l		0
.Text		dc.b		'View Text',0
		even
ViewProcGadg	dc.l		0
		dc.w		100,140
		dc.w		83,11
		dc.w		0
		dc.w		RELVERIFY
		dc.w		BOOLGADGET
		dc.l		.Border
		dc.l		0
		dc.l		.IText
		dc.l		0
		dc.l		0
		dc.w		0
		dc.l		ShowTheProc
.Border		dc.w		-2,-1
		dc.b		1,0,RP_JAM1
		dc.b		5
		dc.l		.Vectors
		dc.l		0
.Vectors	dc.w		0,0
		dc.w		86,0
		dc.w		86,12
		dc.w		0,12
		dc.w		0,0
.IText		dc.b		1,0,RP_JAM2,0
		dc.w		5,2
		dc.l		0
		dc.l		.Text
		dc.l		0
.Text		dc.b		'View Proc',0
		even



**********

ReqStruct
	DC.L	ReqText			REQUESTER TEXT
	DC.L	FileBuffer		FILENAME BUFFER
	DC.L	PathBuffer		PATHNAME BUFFER
	DC.L	0			WINDOW (0=WB)
	DC.B	0			NO SPECIAL FUNCTIONS
	DC.B	0			RESERVED 1
	DC.L	0			FUNCTION
	DC.L	0			RESERVED 2

ReqText
	DC.B	'TEXTMASTER V1.10',0
	EVEN

FileBuffer
	DS.B	40			SPACE FOR FILENAME

PathBuffer
	DS.B	60			SPACE FOR PATHNAME

**********

MessageStruct
	DC.B	1,0			FRONTPEN+BACKPEN
	DC.B	RP_JAM2,0		MODE+FILLBYTE
	DC.W	0			LEFTEDGE
	DC.W	160			TOPEDGE
	DC.L	0			DEFAULT FONT
	DC.L	0			STRING POINTER
	DC.L	0			NEXT TEXT

**********

MessageBorder
	DC.W	20			LEFTEDGE
	DC.W	158			TOPEDGE
	DC.B	1,0			FRONTPEN+BACKPEN
	DC.B	RP_JAM1,5		DRAWMODE+COUNT
	DC.L	BorderVectors		XY VECTORS
	DC.L	0			NO OTHER BORDER

**********

BorderVectors
	DC.W	0,0
	DC.W	368,0
	DC.W	368,11
	DC.W	0,11
	DC.W	0,0

**********				Messages!!!

WelcomeText
	DC.B	'Welcome To Textmaster V1.10',0

LoadErrText
	DC.B	'Could Not Load File!',0

NotLoadedText
	DC.B	'You Haven''t Loaded A File Yet!',0

NoMemText
	DC.B	'Out Of Memory!',0

ProcessedText
	DC.B	'Your Text Has Been Processed.',0

NotProcessedText
	DC.B	'You haven''t Any Processed Text Yet!',0
	even

TextSavedText
	DC.B	'Your Text Has Been Saved.',0

LineClippedText
	DC.B	'Warning: A Line Has Been Clipped!',0

PrefixOnText
	DC.B	'Prefix Now On.',0

PrefixOffText
	DC.B	'Prefix Now Off.',0

CentreOnText
	DC.B	'Centre "DC.B" Text Now On.',0

CentreOffText
	DC.B	'Centre "DC.B" Text Now Off.',0

AlreadyProcessedText
	DC.B	'You''ve Already Processed The Text!',0

FileTooBigText
	DC.B	'Sorry! That File Is Bigger Than 20K!',0

**********

NoARPText	DC.B	'This Program Requires The ARP Library',10
NoARPTextLen	EQU	*-NoARPText
		EVEN

NoPPText	DC.B	'This Program Requires The PowerPacker Library',10
NoPPTextLen	EQU	*-NoPPText
		EVEN

**********

	SECTION	IMAGEDATA,DATA_C

**********

Load_Image_Data

	INCBIN	source:bitmaps/TM.LOAD.RAW

**********

Save_Image_Data

	INCBIN	source:bitmaps/TM.SAVE.RAW

**********

Process_Image_Data

	INCBIN	source:bitmaps/TM.PROCESS.RAW

**********

Prefix_Image_Data

	INCBIN	source:bitmaps/TM.PREFIX.RAW

**********

Width_Image_Data

	INCBIN	source:bitmaps/TM.WIDTH.RAW

**********

Centre_Image_Data

	INCBIN	source:bitmaps/TM.CENTRE.RAW

**********
