***********************************************************************************
*
* SaveMemory Utility
* ------------------
*
* You specify CLI paramters for StartAddress,EndAddress and SaveFileName and this
* program will save the memory block out to a file. Note-: The Memory 
* Addresses you specify must be in HEX notation, not DECIMAL
*
***********************************************************************************
		section	savememory,code		; any public memory will do
		opt	o+,c-,a+		; optimise on,etc

SaveMem		cmp.b	#10,(a0)		; where no parameters given ???
		beq	ShowUsage		; if so,show usage text
 
		lea	filename(pc),a1
checkparams	move.b	(a0)+,d0		; read a char
		cmp.b	#' ',d0			; check for a space
		beq.s	Get1stParam		; if found,read 1st parameter
 
		move.b	d0,(a1)+		; read a new char into filename
		bra.s	checkparams		; loop until a space is found
 
Get1stParam	clr.b	(a1)
		lea	FirstAddr(pc),a1
readhex		move.b	(a0)+,d0		; read a char
		cmp.b	#'$',d0			; was it a Hex prefix ? 
		beq.s	readhex			; YEP,so read next char
 	
		move.b	d0,(a1)+		; read a new char into filename
		beq.s	Get2ndParam
 
		cmp.b	#' ',d0			; was it a space ??
		beq.s	Get2ndParam
 
		cmp.b	#10,d0			; was it a linefeed ??
		bne.s	readhex
 
Get2ndParam	lea	SecondAddr(pc),a1
readhex2	move.b	(a0)+,d0
		cmp.b	#'$',d0			; was it a Hex prefix ?
		beq.s	readhex2		; YEP,so read next char
 
		move.b	d0,(a1)+		; read a new char into filename
		beq.s	Para2
 
		cmp.b	#' ',d0			; was it a space
		beq.s	Para2
 
		cmp.b	#10,d0			; was it a linefeed
		bne.s	readhex2
 
Para2		lea	FirstAddr(pc),a0	; parameter START ADDRESS (ASCII HEX)
		bsr	Ascii2Hex		; convert ASCII HEX to HEX
		move.l	d0,StartAddr		; save start adddress

		lea	SecondAddr(pc),a0	; parameter END ADDRESS (ASCII HEX)
		bsr	Ascii2Hex		; convert ASCII HEX to HEX
		sub.l	StartAddr,d0		; sub start from end to get length
		move.l	d0,Length		; save length
		bmi.s	AddrErr			; Was EndAddr was larger than Start ?
 
		bsr	OpenDos			; open dos library

		move.l	#filename,d1		;
		move.l	StartAddr,d2
		move.l	Length,d3

		bsr	savefile		; save new file

		tst.l	d0			; did and error occur ???
		bne.s	AbortErr		;

 		bsr.s	GetOutPut		; get CLI output

		lea	FileOk(pc),a0		; print file saved Ok.
		bsr	PrintText

		lea	filename(pc),a0		; print filename
		bsr	PrintText

		lea	From(pc),a0		; print "from"
		bsr	PrintText

		move.l	StartAddr,d0		; hex number in d0
		bsr.s	Hex2Ascii		; convert hex no. to ASCII
						; and print to CLI

		lea	To(pc),a0		; print "TO" text to CLI
		bsr	PrintText

		move.l	StartAddr,d0		; hex number in d0
		add.l	Length,d0		; get end address
		bsr.s	Hex2Ascii		; convert hex no. to ASCII
						; and print to CLI

		lea	AsciiLfeed(pc),a0	; new line
		bsr	PrintText		; print text to CLI

		moveq.l	#0,d0			; no CLI return code
		rts				; exit
 
AddrErr		bsr.s	GetOutPut
		lea	AddressErr.txt(pc),a0
		bsr	PrintText

		moveq.l	#0,d0			; no CLI return code
		rts				; exit 
 
AbortErr	bsr.s	GetOutPut
		lea	Aborted.txt(pc),a0
		bsr	PrintText

		moveq.l	#0,d0			; no CLI return code
		rts				; exit 

 
ShowUsage	bsr.s	GetOutPut		; get CLI output
		lea	UsageText(pc),a0	; show USAGE text
		bsr	PrintText	

		moveq.l	#0,d0			; no CLI return code
		rts				; exit 

 
GetOutPut	lea	DosName(pc),a1		; ptr to name of library to open
		moveq.l	#0,d0			; any version
		move.l	4.w,a6			; get execbase
		jsr	-$0228(a6)		; open dos library
		move.l	d0,DosBase		; save dosbase

		move.l	d0,a6			; dosbase in a6
		jsr	-$0036(a6)		; get input from cli
		move.l	d0,InPutBase		; save input base

		jsr	-$003C(a6)		; get output to cli
		move.l	d0,FileOutput		; save file base
		rts	
 
*************************************************************************************
*
* HEX longword to ASCII HEX (OUTPUT)
* ----------------------------------
*
*************************************************************************************

Hex2Ascii	lea	Space(pc),a0
		lea	Checker(pc),a1

		moveq.l	#6-1,d2

hexloop		move.b	d0,d1
		and.w	#15,d1
		move.b	(a1,d1.w),-(a0)
		lsr.l	#4,d0
		dbra	d2,hexloop
 
		lea	OutText(pc),a0
		bsr.s	PrintText
		rts	

*************************************************************************************
*
* ASCII HEX (INPUT) to HEX longword
* ---------------------------------
*
* Note-: Only converts lowercase hex, ie $3f will convert but $3F will not convert.
*
*************************************************************************************
 
Ascii2Hex	moveq.l	#0,d7
		moveq.l	#0,d0
ASCIIloop	move.b	(a0)+,d0
		cmp.b	#'0',d0
		blt.s	NotLegal
 	
		cmp.b	#'f',d0
		bgt.s	NotLegal
 
		bsr.s	HexNum
		lsl.l	#4,d7
		or.l	d0,d7
		bra.s	ASCIIloop
 
NotLegal	move.l	d7,d0
		rts	
 
HexNum		cmp.b	#'9',d0
		bgt.s	HexLet
 
		sub.b	#48,d0
		rts	
 
HexLet		sub.b	#87,d0
		rts	


*************************************************************************************
* Print text to CLI window
 
PrintText	moveq.l	#0,d3
Prt		tst.b	(a0,d3.l)
		beq.s	CallOut
 
		addq.l	#1,d3
		bra.s	Prt
 
CallOut		move.l	a0,d2
		move.l	FileOutput,d1
		move.l	DosBase,a6
		jsr	-$0030(a6)	; get output
		rts	

*************************************************************************************
* Open Dos library
 
OpenDos		lea	DosName(pc),a1
		moveq.l	#0,d0
		move.l	4.w,a6
		jsr	-$0228(a6)	; open dos library
		move.l	d0,DosBase
		rts	
 
*************************************************************************************
* Save out file from specifed memory paramters

savefile	movem.l	d2/d3,-(sp)
		move.l	#1006,d2
		move.l	DosBase(pc),a6
		jsr	-$001E(a6)	; open file
		movem.l	(sp)+,d2/d3
		tst.l	d0
		beq.s	WriteErr
 
		move.l	d0,FilePtr
		move.l	d0,d1
		move.l	FilePtr,d1
		jsr	-$0030(a6)	; write file
		tst.l	d0
		beq.s	WriteErr
 
		move.l	FilePtr,d1
		jsr	-$0024(a6)	; close file
		moveq.l	#0,d0
		rts	
 
WriteErr	moveq.l	#1,d0		; an error occured while trying to save file
		rts	

*************************************************************************************
*
* DATA SECTION
* ------------
*
*************************************************************************************

 
DosName		dc.b	'dos.library',0
filename	dcb.l	20,0
OutText		dc.b	' $000000'
Space		dc.b	' ',0
Checker		dc.b	'0123456789ABCDEF'
AddressErr.txt	dc.b	'Please check your addresses!',$a
		even
Aborted.txt	dc.b	'Error - Save aborted.',$a
		even
FileOk		dc.b	'O.K. Saved file ',0
From		dc.b	' from',0
To		dc.b	'to',0
AsciiLfeed	dc.b	$a
		even
UsageText	dc.b	12
		dc.b	$a
		dc.b	'  SAVEMEM                               ',$a,$a
		dc.b	'  Usage:  SAVEMEM  <filename>  <from>  <to>',$a,$a
		dc.b	'  The addresses must be entered in hex ($ optional)',$a,$a
		even

Length		ds.l	1
StartAddr	ds.l	1
DosBase		ds.l	1
FilePtr		ds.l	1
InPutBase	ds.l	1
FileOutput	ds.l	1
FirstAddr	dcb.l	8,0
SecondAddr	dcb.l	8,0


