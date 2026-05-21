*****************************************************************
*                                                               *
*		Modified Diskcopy				*
*                                                               *
* This version of Diskcopy was produced using the disassembler	*
* DSM, and has been modified to work with the Mac-2-Dos Laser	*
* ADOS driver, which requires that the Laser drive motor be 	*
* turned off so	that the other drive can be accessed.  This is 	*
* accomplished by forcing Diskcopy to read multiple cylinders 	*
* from the source drive, then writing to those cylinders to the *
* destination drive, as it does in a single-drive copy.  Be-	*
* cause of problems caused by the NOVERIFY option, that option 	*
* has been disabled, although the keyword IS recognized in the 	*
* command line.							*
*                                                               *
* George Chamberlain, February 12, 1990 			*
*								*
*****************************************************************

	INCLUDE	"MACROS.ASM"

MEMF_CHIP	EQU	$10002
MEMF_PUBLIC	EQU	$10001

	SECTION  segment0,CODE

Start:
	MOVE.L	d0,d2
	MOVE.L	a0,a2
	MOVE.L	4,A6
	MOVE.L	a6,SysBase
	SUB.L	a1,a1
	CALLSYS	FindTask
	MOVE.L	d0,a4
	MOVEQ	#0,d0
	LEA	DosLib.,a1
	CALLSYS	OpenLibrary
	TST.L	d0
	BEQ	Abort
	MOVE.L	d0,DosBase
	MOVE.L	#388,d0
	MOVE.L	#MEMF_PUBLIC,d1
	CALLSYS	AllocMem
	TST.L	d0
	BEQ	Abort1
	MOVE.L	d0,-(a7)
	MOVE.L	d0,a5			;ptr to local temp storage
	CLR.L	-(a7)
	MOVE.L	$ac(a4),d0		;from CLI?
	BEQ	FromWB			;no...from Workbench
FromCLI:
	LSL.L	#2,d0			;convert BPTR
	MOVE.L	d0,a0
	MOVE.L	16(a0),d0		;BSTR name of current command
	LSL.L	#2,d0			;convert to APTR
	LEA	132(a5),a1		;command buffer
	LEA	4(a5),a3
	MOVE.L	d0,a0			;point A0 to name of command
	MOVEQ	#0,d0
	MOVE.B	(a0)+,d0		;get length and bump ptr
	CLR.B	0(a0,d0.l)		;zap the last byte of string
	MOVE.L	a0,(a3)+		;store ptr to command name at offset 4
	MOVEQ	#1,d3			;first keyword
	LEA	0(a2,d2.l),a0		;point past end of command line
1$:	CMPI.B	#32,-(a0)		;get rid of ASCII control chars
	DBHI	d2,1$			;loop
	CLR.B	1(a0)			;terminate string

* isolate keywords and store ptr to them in an array

2$:	MOVE.B	(a2)+,d1		;get a byte from command line
	BEQ.S	8$			;end of string
	CMPI.B	#32,d1			;leading blank?
	BEQ.S	2$			;yes...ignore
	CMPI.B	#9,d1			;leading tab?
	BEQ.S	2$			;yes...ignore
	CMPI.W	#31,d3			;got 31 keywords?
	BEQ.S	8$			;yes...stop now
	MOVE.L	a1,(a3)+		;else store ptr to keyword in array
	ADDQ.W	#1,d3			;count chars in buffer
	CMPI.B	#'"',d1			;double quote?
	BEQ.S	5$			;yes
	MOVE.B	d1,(a1)+		;store first char
3$:	MOVE.B	(a2)+,d1		;get next char
	BEQ.S	8$			;end of string
	CMPI.B	#32,d1			;blank?
	BEQ.S	4$			;yes
	MOVE.B	d1,(a1)+		;else store keyword char
	BRA.S	3$			;loop

4$:	CLR.B	(a1)+			;terminate this keyword string
	BRA.S	2$			;loop for next keyword

5$:	MOVE.B	(a2)+,d1		;get next char of quoted string
	BEQ.S	8$			;end of string
	CMPI.B	#'"',d1			;trailing quote?
	BEQ.S	4$			;yes...terminate keyword string
	CMPI.B	#'*',d1			;console synonym?
	BNE.S	7$			;no
	MOVE.B	(a2)+,d1		;else get next char
	MOVE.B	d1,d2			;save it
	andi.b	#$DF,d2			;make it upper case
	CMPI.B	#'N',d2
	BNE.S	6$			;not *N
	MOVEQ	#10,d1			;else change to line feed
	BRA.S	7$

6$:	CMPI.B	#'E',d2
	BNE.S	7$			;not *E
	MOVEQ	#$1b,d1			;else convert to ESC
7$:	MOVE.B	d1,(a1)+		;store converted char
	BRA.S	5$

8$:	CLR.B	(a1)			;terminate last keyword
	CLR.L	(a3)			;terminate array of keyword ptrs
	PEA	4(a5)			;point to array of keywords
	MOVE.L	d3,-(a7)		;pass count of keywords
	MOVE.L	DosBase,A6
	CALLSYS	Input			;get input file handle
	MOVE.L	d0,StdIn
	CALLSYS	Output			;get output file handle
	MOVE.L	d0,StdOut
	MOVE.L	d0,StdErr
	MOVE.L	4,A6			;reload A6 with SysBase
	BRA	Common

FromWB:	BSR.S	GetWBMsg
	MOVE.L	d0,(a7)			;save ptr to Workbencg msg
	MOVE.L	d0,WBMsg
	MOVE.L	d0,-(a7)		;pass ptr to WB msg
	CLR.L	-(a7)			;count of keywords=0 if WB
	MOVE.L	DosBase,A6
	MOVE.L	d0,a2			;ptr to wb msg
	MOVE.L	36(a2),d0		;ptr to param list
	BEQ.S	1$			;no params
	MOVE.L	d0,a0
	MOVE.L	0(a0),d1		;get ptr to lock
	CALLSYS	CurrentDir		;make this the current dir
1$:	LEA	Nil.,a0
	MOVE.L	a0,d1			;open NIL:
	MOVE.L	#$3ed,d2		;open existing file
	CALLSYS	Open
	MOVE.L	d0,0(a5)		;bptr to NIL: file handle
	BNE.S	2$			;good open
	MOVEQ	#$14,d2			;bad open
	BRA	ExitToDos

2$:	MOVE.L	d0,StdIn		;use NIL: for standard I/O
	MOVE.L	d0,StdOut
	MOVE.L	d0,StdErr
	MOVE.L	d0,$9c(a4)		;pr_CIS
	MOVE.L	d0,$a0(a4)		;pr_COS
	LSL.L	#2,d0			;convert to APTR
	MOVE.L	d0,a0
	MOVE.L	8(a0),d0		;get port for PutMsg
	BEQ.S	Common			;none
	MOVE.L	d0,$a4(a4)		;save port in pr_ConsoleTask
Common:	BSR	MAIN			;do the copy now
	MOVEQ	#0,d2			;good return
	BRA.S	ExitToDos		;exit

GetWBMsg:
	LEA	$5c(a4),a0
	CALLSYS	WaitPort
	LEA	$5c(a4),a0
	CALLSYS	GetMsg
	RTS

Abort:
	MOVEM.L	d7/a5-a6,-(a7)
	MOVE.L	#$38007,d7
	MOVE.L	4,A6
	CALLSYS	Alert
	MOVEM.L	(a7)+,d7/a5-a6
	BRA.S	Abort2

Abort1:
	MOVE.L	DosBase,a1
	CALLSYS	CloseLibrary
	MOVEM.L	d7/a5-a6,-(a7)
	MOVE.L	#$10000,d7
	MOVE.L	4,A6
	CALLSYS	Alert
	MOVEM.L	(a7)+,d7/a5-a6
Abort2:
	TST.L	$ac(a4)			;from Workbench?
	BNE.S	1$			;no
	BSR.S	GetWBMsg
	MOVE.L	d0,a2
	BSR.S	SendReply
1$:	MOVEQ	#$14,d0
	RTS

SendReply:
	CALLSYS	Forbid
	MOVE.L	a2,a1
	CALLSYS	ReplyMsg
	RTS

ExitSR:
	MOVE.L	4(a7),d2
ExitToDos:
	MOVE.L	4,A6
	SUB.L	a1,a1
	CALLSYS	FindTask		;find own task
	MOVE.L	d0,a4			;save ptr
	MOVE.L	$b0(a4),a5		;ptr to return address
	suba.w	#12,a5			;allow for initial params
	MOVE.L	a5,a7			;reset stack ptr
	MOVE.L	(a7)+,a2		;WB msg
	MOVE.L	(a7)+,a5		;ptr to work area
	MOVE.L	0(a5),d1		;got NIL: handle?
	BEQ.S	1$			;no
	MOVE.L	DosBase,A6
	CALLSYS	Close			;yes...close it
1$:	MOVE.L	4,A6
	MOVE.L	DosBase,a1
	CALLSYS	CloseLibrary
	MOVE.L	a2,d0			;got a WB msg?
	BEQ.S	2$			;no
	BSR.S	SendReply		;else send reply
2$:	MOVE.L	a5,a1			;ptr to local work area
	MOVE.L	#388,d0			;size of work area
	CALLSYS	FreeMem			;release work area
	MOVE.L	d2,d0			;return code to D0
	RTS				;bail out

**************************************************************

MAIN:
	MOVEM.L	d2-d4/a2-a5,-(a7)
	MOVE.L	32(a7),d2		;count of keywords
	MOVE.L	36(a7),a2		;ptr to keyword array or WB msg
	MOVE.L	#DestIOB,a3		;dest iob ptr??
	MOVE.L	#CleanUp,d3
	MOVE.L	#ModeFlag,a4		;point to mode flag
	TST.L	d2			;any keywords?
	BEQ.S	1$			;no...from WB
	MOVE.L	(a2),d0			;get ptr to array of keywords
	BRA.S	2$

1$:	MOVEQ	#0,d0
2$:	MOVE.L	d0,KeyArrayPtr		;save ptr to aray of keywords
	CLR.L	-(a7)
	BSR	SetResult
	CLR.L	-(a7)			;any version
	PEA	IntLib.
	BSR	OpenLib
	MOVE.L	d0,IntuitionBase
	CLR.L	-(a7)			;any version
	PEA	GraphLib.
	BSR	OpenLib
	MOVE.L	d0,GraphicsBase
	MOVE.L	DosBase,a0
	CMPI.W	#33,20(a0)		;correct version?
	LEA	20(a7),a7
	BCS.S	3$			;no
	TST.L	GraphicsBase
	BEQ.S	3$			;no graphics library
	TST.L	IntuitionBase
	BNE.S	4$			;okay...

3$:	PEA	10			;else bail out...
	BSR	CleanUp
	ADDQ.L	#4,a7

4$:	CLR.L	-(a7)
	CLR.L	-(a7)
	BSR	CreatePort
	MOVE.L	d0,LocalPort
	ADDQ.L	#8,a7
	BEQ.S	5$			;can't create port
	PEA	$34
	MOVE.L	LocalPort,-(a7)
	BSR	CreateExtIO
	MOVE.L	d0,SrceIOB		;source iob ptr
	ADDQ.L	#8,a7
	BEQ.S	5$			;can't create IOB
	PEA	$34
	MOVE.L	LocalPort,-(a7)
	BSR	CreateExtIO
	MOVE.L	d0,(a3)
	ADDQ.L	#8,a7
	BEQ.S	5$			;can't create other IOB
	MOVE.L	#MEMF_CHIP,-(a7)
	PEA	512			;data buffer
	BSR	AllocateMemory
	MOVE.L	d0,BlockBufPtr
	ADDQ.L	#8,a7
	BNE.S	6$			;got data buffer

5$:	PEA	1			;error in setting up data structures
	BSR	SetResult
	PEA	10
	BSR	CleanUp
	ADDQ.L	#8,a7

6$:	MOVE.L	#MEMF_PUBLIC,-(a7)
	PEA	260			;size of file info buffer
	BSR	AllocateMemory
	MOVE.L	d0,FileInfoBuf
	ADDQ.L	#8,a7
	BEQ.S	7$
	MOVE.L	#MEMF_PUBLIC,-(a7)
	PEA	36			;size of infodata buffer
	BSR	AllocateMemory
	MOVE.L	d0,InfoBuffer
	ADDQ.L	#8,a7
	BNE.S	8$

7$:	PEA	1
	BSR	SetResult
	PEA	10
	BSR	CleanUp
	ADDQ.L	#8,a7

8$:	TST.L	KeyArrayPtr		;any keywords?
	BEQ	19$			;no...must be from WB
	MOVEQ	#2,d0
	MOVE.L	d0,a1
	CMPA.L	d2,a1
	BLE.S	9$			;got at least 2 keywords
	BSR	DispUsage		;else tell op how to do it

9$:	PEA	L246			;FROM
	MOVE.L	4(a2),-(a7)		;second keyword
	BSR	CompareStrings
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	10$			;didn't find it
	ADDQ.L	#4,a2			;else advance to next keyword
	SUBQ.L	#1,d2			;one less keywords

10$:	MOVE.L	d2,d4			;save keyword count
	BRA	15$


11$:	PEA	L247			;NAME
	MOVE.L	d4,d0
	ASL.L	#2,d0
	MOVE.L	d0,a5
	MOVE.L	0(a5,a2.l),-(a7)
	BSR	CompareStrings
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	12$			;didn't find it
	MOVE.L	d4,a1
	ADDQ.L	#1,a1
	MOVE.L	a1,d0
	ASL.L	#2,d0
	MOVE.L	d0,a1
	MOVE.L	0(a1,a2.l),NamePtr	;save ptr to name keyword
	SUBQ.L	#2,d2
	BRA.S	15$


12$:	PEA	L248			;MULTI
	MOVE.L	d4,d0
	ASL.L	#2,d0
	MOVE.L	d0,a5
	MOVE.L	0(a5,a2.l),-(a7)
	BSR	CompareStrings
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	13$			;didn't find it
	MOVE.B	#1,(a4)			;set mode=multi
	BRA.S	14$


13$:	PEA	L249			;NOVERIFY
	MOVE.L	d4,d0
	ASL.L	#2,d0
	MOVE.L	d0,a5
	MOVE.L	0(a5,a2.l),-(a7)
	BSR	CompareStrings
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	15$			;didn't find it
;;	CLR.W	VerifyFlg		;disable verification

14$:	SUBQ.L	#1,d2			;one less keyword

15$:	SUBQ.L	#1,d4
	MOVEQ	#4,d0
	MOVE.L	d0,a1
	CMPA.L	d4,a1
	BLE  	11$			;loop for more keywords
	MOVEQ	#4,d0
	MOVE.L	d0,a1
	CMPA.L	d2,a1
	BNE.S	16$
	PEA	L250			;TO
	MOVE.L	8(a2),-(a7)
	BSR	CompareStrings
	TST.L	d0
	ADDQ.L	#8,a7
	BNE.S	17$			;did find it

16$:	BSR	DispUsage		;must have "TO"

17$:	CLR.L	-(a7)
	MOVE.L	12(a2),-(a7)
	CLR.L	-(a7)
	MOVE.L	4(a2),-(a7)

18$:	BSR	CreateIOBs
	LEA	16(a7),a7
	BRA	27$

* Invoked from Workbench...no keywords

19$:	CLR.L	-(a7)
	PEA	L251			;icon.lib
	BSR	OpenLib
	MOVE.L	d0,IconBase
	ADDQ.L	#8,a7
	BNE.S	20$			;got the icon lib
	PEA	$40
	PEA	$12a
	CLR.L	-(a7)
	MOVE.L	#$8000,-(a7)
	PEA	L421
	PEA	L423
	PEA	L477
	CLR.L	-(a7)
	BSR	DispReq
	TST.L	d0
	LEA	32(a7),a7
	BNE.S	19$

20$:	TST.L	IconBase
	BNE.S	21$			;got icon lib
	PEA	10			;else bail out
	BSR	CleanUp
	ADDQ.L	#4,a7

21$:	PEA	NewWindow		;window params
	BSR	OpenWin
	MOVE.L	d0,Window
	ADDQ.L	#4,a7
	BNE.S	22$			;got window
	PEA	10
	BSR	CleanUp
	ADDQ.L	#4,a7

22$:	PEA	L252			;diskcopy
	MOVEQ	#-1,d4
	MOVE.L	d4,-(a7)
	MOVE.L	Window,-(a7)
	BSR	SetTitles
	MOVE.L	28(a2),a1		;get number of args in WB msg
	MOVE.L	a1,d2
	LEA	12(a7),a7
	MOVEQ	#2,d0
	CMP.L	a1,d0
	BGT.S	26$			;1 or 0 args...error
	bge.s	23$			;2 args...source/dest same drive
	MOVEQ	#3,d0
	CMP.L	a1,d0
	BNE.S	26$			;not 2 or 3 args...error
	BRA.S	24$			;3 args...2 drives

* 2 wb args - source and dest the same

23$:	MOVE.L	36(a2),a0		;wb arglist ptr
	PEA	8(a0)			;source?
	MOVE.L	36(a2),a0
	MOVE.L	12(a0),-(a7)		;dest?
	BRA.S	25$

* 3 wb args, two-drive copy

24$:	MOVE.L	36(a2),a0
	PEA	16(a0)
	MOVE.L	36(a2),a0
	MOVE.L	20(a0),-(a7)

25$:	MOVE.L	36(a2),a0
	PEA	8(a0)
	MOVE.L	36(a2),a0
	MOVE.L	12(a0),-(a7)
	BRA	18$


26$:	BSR	DispUsage

27$:	MOVE.L	SrceDevList,a0
	MOVE.L	28(a0),d2		;BPTR filesystem startup msg
	ASL.L	#2,d2
	MOVE.L	d2,SrceFSSM		;APTR to srce filesystem startup msg
	MOVE.L	SrceFSSM,a0
	MOVE.L	8(a0),d2		;BPTR to environment table
	ASL.L	#2,d2
	MOVE.L	d2,SrceEnviron		;APTR to srce environment
	MOVE.L	SrceEnviron,a0
	MOVE.L	40(a0),a1		;high cylinder
	MOVE.L	SrceEnviron,a2
	SUB.L	36(a2),a1		;low cylinder
	ADDQ.L	#1,a1			;zero origin
	MOVE.L	a1,SrceCyls		;source size in cylinders
	MOVE.L	SrceEnviron,a0
	MOVE.L	12(a0),a1		;source surfaces
	MOVE.L	SrceEnviron,a2
	MOVE.L	20(a2),d0		;source blocks per track
	ASL.L	#8,d0
	ASL.L	#1,d0
	MOVE.L	a1,d1
	BSR	Multiply
	MOVE.L	d0,Buffersize		;buffer size=cylinder size
	MOVE.L	DestDevList,a0
	MOVE.L	28(a0),d2
	ASL.L	#2,d2
	MOVE.L	d2,DestFSSM		;dest filesystem startup msg
	MOVE.L	DestFSSM,a0
	MOVE.L	8(a0),d2
	ASL.L	#2,d2
	MOVE.L	d2,DestEnviron		;dest environment
	MOVE.L	DestEnviron,a0
	MOVE.L	40(a0),a1		;high cylinder
	MOVE.L	DestEnviron,a2
	SUB.L	36(a2),a1		;low cylinder
	ADDQ.L	#1,a1			;zero origin
	CMPA.L	SrceCyls,a1		;devices same size?
	BNE.S	28$			;oops...bad awful
	MOVE.L	DestEnviron,a0
	MOVE.L	12(a0),a1		;surfaces
	MOVE.L	DestEnviron,a2
	MOVE.L	20(a2),d0		;blocks per track
	ASL.L	#8,d0
	ASL.L	#1,d0
	MOVE.L	a1,d1
	BSR	Multiply
	MOVE.L	d0,a1
	CMPA.L	Buffersize,a1		;device cylinder size same?
	BEQ.S	29$			;yes

28$:	PEA	2			;devices not compatible
	PEA	$62
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7

29$:	MOVE.L	DestEnviron,a0
	MOVE.L	12(a0),a1		;surfaces
	MOVE.L	DestEnviron,a2
	MOVE.L	a1,d1
	MOVE.L	20(a2),d0		;blocks per track
	BSR	Multiply
	MOVE.L	d0,d1			;blocks per cylinder
	MOVE.L	SrceCyls,d0
	BSR	Multiply
	MOVE.L	d0,a1			;blocks per volume
	SUBQ.L	#1,a1			;last block number
	MOVE.L	DestEnviron,a0
	ADDA.L	24(a0),a1		;number of reserved blocks
	MOVE.L	a1,d2
	asr.l	#1,d2			;divide to get root block number
	MOVE.L	d2,RootBlkNbr		;calc block number of root block
	MOVE.L	#MEMF_CHIP,-(a7)
	MOVE.L	Buffersize,-(a7)	;size of buffer
	BSR	AllocateMemory
	MOVE.L	d0,DataBuffer		;data buffer
	TST.B	(a4)			;multi?
	ADDQ.L	#8,a7
	BEQ.S	30$			;no
	MOVE.W	#1,OneDrvFlg		;show one drive copy

30$:	BSR	AllocateBuffers
	MOVE.L	d0,CylsPerSwap		;this many per drive
;;	TST.W	OneDrvFlg
;;	BEQ.S	31$			;not one drive
	MOVE.L	SrceCyls,d0
	asr.l	#2,d0
	MOVE.L	d0,a1
	CMPA.L	CylsPerSwap,a1
	BGT.S	32$			;not enough buffers

31$:	TST.B	(a4)			;multi?
	BEQ	45$			;no

32$:	MOVEQ	#0,d2
	BRA.S	34$


33$:	MOVE.L	Buffersize,-(a7)	;cylinder buf size
	MOVE.L	d2,d0
	ASL.L	#2,d0
	MOVE.L	CylBufTblPtr,d1
	MOVE.L	d0,a2
	MOVE.L	0(a2,d1.l),-(a7)	;get entry from CylBufTbl
	BSR	FreeMemory
	MOVE.L	d2,d4
	ASL.L	#2,d4
	MOVE.L	d4,a1
	MOVE.L	CylBufTblPtr,d0
	CLR.L	0(a1,d0.l)		;clear entry in cylbuftbl
	ADDQ.L	#1,d2
	ADDQ.L	#8,a7

34$:	MOVE.L	d2,d1
	ASL.L	#2,d1
	MOVE.L	d1,a1
	MOVE.L	CylBufTblPtr,d0
	TST.L	0(a1,d0.l)		;end of list?
	BNE.S	33$			;no...loop for rest of cyl bufs
	MOVEQ	#0,d2
	MOVE.L	SrceCyls,d0
	BRA.S	36$

35$:	SUB.L	CylsPerSwap,d0
	ADDQ.L	#1,d2

36$:	TST.L	d0
	BGT.S	35$
	TST.B	(a4)			;multi-disk copy?
	BEQ.S	37$			;no
	PEA	L253			;not enough memory for multi
	PEA	TxtBuf1
	BSR	FormatTextString
	ADDQ.L	#8,a7
	BRA.S	39$


37$:	TST.L	KeyArrayPtr
	BEQ.S	38$
	PEA	L254			;close other tools
	BSR	OutputMsg
	ADDQ.L	#4,a7

38$:	MOVE.L	d2,-(a7)
	PEA	L255			;warning: this will take
	PEA	TxtBuf1
	BSR	FormatTextString
	LEA	12(a7),a7

39$:	PEA	L453
	PEA	TxtBuf1
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
	ADDQ.L	#8,a7
	BEQ.S	40$			;CTRL-C
	TST.B	(a4)			;multi?
	BEQ.S	41$			;no

40$:	PEA	10
	BSR	CleanUp
	ADDQ.L	#4,a7

41$:	BSR	AllocateBuffers
	MOVE.L	d0,CylsPerSwap
	MOVEQ	#0,d2
	MOVE.L	SrceCyls,d0
	BRA.S	43$


42$:	SUB.L	CylsPerSwap,d0
	ADDQ.L	#1,d2

43$:	TST.L	d0
	BGT.S	42$
	MOVE.L	d2,-(a7)
	PEA	L256			;diskcopy will now take
	PEA	TxtBuf1
	BSR	FormatTextString
	TST.L	KeyArrayPtr
	LEA	12(a7),a7
	BEQ.S	44$
	PEA	TxtBuf1
	PEA	L257			;
	BSR	OutputMsg
	ADDQ.L	#8,a7
	BRA.S	45$

44$:	PEA	TxtBuf1
	PEA	20
	BSR	L402
	PEA	15
	BSR	TimeDelay
	LEA	12(a7),a7

* Start the actual copy process here

45$:	MOVE.W	#2,RWMode		;CMD_READ
	MOVE.L	SrceIOB,ActiveIOB	;source iob
	CLR.L	CylinderCnt

46$:	CLR.L	-(a7)
	MOVE.L	SrceIOB,-(a7)		;source iob
	MOVE.L	SrceFSSM,a0
	MOVE.L	(a0),-(a7)
	MOVE.L	SrceFSSM,a0
	MOVE.L	4(a0),d0
	ASL.L	#2,d0
	ADDQ.L	#1,d0
	MOVE.L	d0,-(a7)
	BSR	OpenDev
	TST.L	d0
	LEA	16(a7),a7
	BNE.S	47$
	CLR.L	-(a7)
	MOVE.L	(a3),-(a7)
	MOVE.L	DestFSSM,a0
	MOVE.L	(a0),-(a7)
	MOVE.L	DestFSSM,a0
	MOVE.L	4(a0),d0
	ASL.L	#2,d0
	ADDQ.L	#1,d0
	MOVE.L	d0,-(a7)
	BSR	OpenDev
	TST.L	d0
	LEA	16(a7),a7
	BEQ.S	48$

47$:	PEA	2
	PEA	$60
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7

48$:	MOVE.L	SrceIOB,a0		;source iob
	LEA	$30(a0),a2		;point to change count
	MOVE.L	SrceEnviron,a0
	MOVE.L	36(a0),(a2)		;save source low cylinder in IOB
	MOVE.L	(a3),a0			;dest IOB
	LEA	$30(a0),a2		;point to change count
	MOVE.L	DestEnviron,a0
	MOVE.L	36(a0),(a2)		;save dest low cylinder in IOB
	MOVE.L	SrceEnviron,a0
	MOVE.L	40(a0),a1		;srce high cyl
	MOVE.L	SrceEnviron,a2
	SUB.L	36(a2),a1		;srce low cyl
	MOVE.L	a1,MaxCyls		;max cyls
	CLR.L	CylsCompleted		;clear completed count
	MOVE.L	SrceIOB,a0
	CLR.B	31(a0)			;srce IO error
	MOVE.L	(a3),a0
	CLR.B	31(a0)			;dest IO error
	MOVE.L	SrceIOB,a0
	MOVE.B	#7,8(a0)		;node type=replymsg
	MOVE.L	(a3),a0
	MOVE.B	#7,8(a0)		;ditto
	MOVE.L	SrceIOB,-(a7)
	BSR	MotorOff
	CMPI.B	#2,(a4)			;check for multi
	ADDQ.L	#4,a7
	bge.l	51$
	TST.W	OneDrvFlg
	BEQ.S	49$			;two drives
	MOVE.L	SrceNamePtr,-(a7)
	PEA	L258			;'( FROM disk ) in drive n'
	PEA	L332
	BSR	FormatTextString
	PEA	L332
	PEA	L334
	PEA	L259			;'Place n n'
	PEA	TrkStatusBuf
	BSR	FormatTextString
	PEA	L462
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	LEA	36(a7),a7
	BRA.S	50$


49$:	MOVE.L	DestNamePtr,-(a7)
	PEA	L260			;'( TO disk ) in drive n'
	PEA	L333
	BSR	FormatTextString
	MOVE.L	SrceNamePtr,-(a7)
	PEA	L261			;'( FROM disk ) in drive n
	PEA	L332
	BSR	FormatTextString
	PEA	L333
	PEA	L335
	PEA	L332
	PEA	L334
	PEA	L262			;'Place %s %s',10,'Place %s %s',0
	PEA	TrkStatusBuf
	BSR	FormatTextString
	PEA	L469
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	LEA	$38(a7),a7

50$:	TST.W	d0			;CTRL-C?
	BNE.S	51$			;no
	BSR	L200			;else bail out
	PEA	10
	BSR	CleanUp
	ADDQ.L	#4,a7

51$:	CMPI.B	#2,(a4)			;check mode
	bge.s	52$
	PEA	L263			;reading track
	BSR	DisplayTrackStatus
	MOVE.L	CylinderCnt,-(a7)
	MOVE.L	CylinderCnt,-(a7)
	MOVEQ	#0,d0
	MOVE.W	RWMode,d0
	MOVE.L	d0,-(a7)
	MOVE.L	SrceIOB,-(a7)
	BSR	ReadWriteCyl
	LEA	20(a7),a7
	BRA.S	53$

52$:	PEA	L264			;writing track
	BSR	DisplayTrackStatus
	BSR	CopyByGroups
	ADDQ.L	#4,a7

53$:	BRA	62$			;check for break


54$:	TST.L	KeyArrayPtr		;from CLI?
	BNE.S	55$			;yes
	MOVE.L	Window,a0
	MOVE.L	$56(a0),-(a7)
	BSR	GetAnyMsg
	MOVE.L	d0,L347
	ADDQ.L	#4,a7
	BEQ.S	55$
	MOVE.L	L347,a0
	MOVE.W	22(a0),L362
	MOVE.L	L347,-(a7)
	BSR	SendReply2
	CMPI.W	#$200,L362
	ADDQ.L	#4,a7
	BEQ	63$

55$:	MOVE.L	LocalPort,-(a7)		;clear pending msg
	BSR	GetAnyMsg
	MOVE.L	d0,L346			;save msg ptr
	ADDQ.L	#4,a7
	BEQ.S	56$			;no msg
	MOVE.L	L346,ActiveIOB		;else 
	BSR	CopyByGroups
	TST.L	d0			;op wants to quit?
	BNE	62$			;no...check for break
	BRA	63$			;else stop now

56$:	TST.L	KeyArrayPtr		;from CLI?
	BEQ.S	57$			;no
	MOVEQ	#0,d2
	BRA.S	58$

57$:	MOVEQ	#1,d2
	MOVE.L	Window,a0
	MOVE.L	$56(a0),a2
	MOVE.B	15(a2),d0
	ASL.L	d0,d2

58$:	MOVEQ	#1,d0
	MOVE.L	LocalPort,a0
	MOVE.B	15(a0),d1		;get port signal bit
	ASL.L	d1,d0
	or.l	d2,d0
	MOVE.L	d0,-(a7)
	BSR	WaitEvent		;wait for signal to be set
	CMPI.W	#999,RWMode		;verification pass?
	ADDQ.L	#4,a7
	BNE.S	60$			;no...proceed
	MOVE.L	CylinderCnt,-(a7)
	BSR	CompareData		;else perform data compare
	MOVE.W	d0,d0
	ADDQ.L	#4,a7
	BNE	62$			;no error...check for break
	PEA	1			;compare error
	PEA	$63

59$:	BSR	Error
	ADDQ.L	#8,a7
	BRA	63$

60$:	CMPI.W	#11,RWMode		;write mode?
	BNE.S	61$			;no, read or verify
	MOVE.L	(a3),a0
	TST.B	31(a0)
	BEQ	62$			;??...check for break
	MOVE.L	(a3),a0
	CMPI.B	#$1c,31(a0)
	BEQ	62$			;??...check for break
	TST.W	VerifyFlg		;verifying?
	BNE.S	62$			;yes...check for break
	PEA	1
	MOVE.L	(a3),a0
	MOVE.B	31(a0),d0
	EXT.W	d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	BRA.S	59$

61$:;	TST.W	OneDrvFlg
;	BEQ.S	62$			;two drives...check for break
	MOVE.L	CylinderCnt,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	CylBufTblPtr,d0
	MOVE.L	0(a0,d0.l),-(a7)
	BSR	TypeOfMemory
	btst	#2,d0
	ADDQ.L	#4,a7
	BEQ.S	62$			;??...check for break
	MOVE.L	Buffersize,-(a7)
	MOVE.L	CylinderCnt,d0
	ASL.L	#2,d0
	MOVE.L	CylBufTblPtr,d1
	MOVE.L	d0,a2
	MOVE.L	0(a2,d1.l),-(a7)
	MOVE.L	DataBuffer,-(a7)
	BSR	CopyMemory
	LEA	12(a7),a7

62$:	BSR	CheckForBreak
	MOVE.W	d0,d0			;operator wants to break?
	BEQ	54$			;no...go on

* Come here when copy complete

63$:	TST.W	DoneFlag		;completed successfully?
	BEQ.S	64$			;no
	MOVE.L	(a3),-(a7)
	BSR	FixCopy			;else correct version and datestamp
	ADDQ.L	#4,a7

64$:	MOVE.L	DestIOB,-(a7)		;;dest iob
	BSR	MotorOff		;;
	BSR	L200
	TST.B	(a4)			;multi?
	BEQ.S	65$			;no...all done
	MOVE.L	(a3),a0			;yes...
	TST.B	31(a0)
	BNE.S	65$
	PEA	L266
	PEA	L265			;'Press return for another copy'
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
	ADDQ.L	#8,a7
	BEQ.S	65$			;CTRL-C...op wants to quit
	CLR.L	CylinderCnt		;else go again
	MOVE.B	#2,(a4)			;set mode
	CLR.W	DoneFlag
	CLR.B	L324
	MOVE.L	(a3),ActiveIOB
	MOVE.L	Buffersize,-(a7)
	MOVE.L	DataBuffer,-(a7)
	MOVE.L	CylBufTblPtr,a0
	MOVE.L	(a0),-(a7)
	BSR	CopyMemory
	TST.B	(a4)			;multi?
	LEA	12(a7),a7
	BNE	46$			;yes...do another

65$:	CLR.L	-(a7)			;exit...copying complete
	BSR	CleanUp
	ADDQ.L	#4,a7
	MOVEM.L	(a7)+,d2-d4/a2-a5
	RTS

********************************************************************

* Displays usage msg to operator if params not right.

DispUsage:
	TST.L	KeyArrayPtr
	BEQ.S	1$
	MOVE.L	KeyArrayPtr,-(a7)
	PEA	L267			;usage msg
	BSR	OutputMsg
	ADDQ.L	#8,a7
	BRA.S	2$

1$:	PEA	$48
	PEA	$157
	PEA	$200
	CLR.L	-(a7)
	PEA	L421
	CLR.L	-(a7)
	PEA	L440
	MOVE.L	Window,-(a7)
	BSR	DispReq
	LEA	32(a7),a7
2$:
	PEA	10
	BSR	CleanUp
	ADDQ.L	#4,a7
	RTS

* Called to shut down and clean up

CleanUp:
	MOVEM.L	d2-d5/a2-a4,-(a7)
	MOVE.L	32(a7),d2
	MOVE.L	36(a7),d3
	MOVE.L	#FreeMemory,a3
	MOVE.L	#CylBufTblPtr,a2
	MOVE.L	#L342,a4
	TST.W	SrceFlag
	BEQ.S	1$
	MOVE.L	SrceDevProc,-(a7)
	CLR.L	-(a7)
	BSR	InitIOB
	ADDQ.L	#8,a7
1$:	TST.W	DestFlag
	BEQ.S	2$
	MOVE.L	DestDevProc,-(a7)
	CLR.L	-(a7)
	BSR	InitIOB
	ADDQ.L	#8,a7
2$:	TST.L	SrceIOB			;source iob ptr
	BEQ.S	3$
	PEA	$34
	MOVE.L	SrceIOB,-(a7)
	BSR	DeleteExtIO
	ADDQ.L	#8,a7
3$:	TST.L	DestIOB			;dest iob ptr
	BEQ.S	4$
	PEA	$34
	MOVE.L	DestIOB,-(a7)		;dest iob
	BSR	DeleteExtIO
	ADDQ.L	#8,a7
4$:	TST.L	LocalPort			;
	BEQ.S	5$
	MOVE.L	LocalPort,-(a7)
	BSR	DeletePort
	ADDQ.L	#4,a7
5$:	TST.L	(a2)
	BEQ.S	8$
	MOVEQ	#0,d4
	BRA.S	7$

6$:	MOVE.L	Buffersize,-(a7)
	MOVE.L	d4,d5
	ASL.L	#2,d5
	MOVE.L	d5,a0
	MOVE.L	(a2),d0
	MOVE.L	0(a0,d0.l),-(a7)
	JSR	(a3)
	MOVE.L	d4,d5
	ASL.L	#2,d5
	MOVE.L	d5,a0
	MOVE.L	(a2),d0
	CLR.L	0(a0,d0.l)
	ADDQ.L	#1,d4
	ADDQ.L	#8,a7
7$:	MOVE.L	d4,d1
	ASL.L	#2,d1
	MOVE.L	d1,a0
	MOVE.L	(a2),d0
	TST.L	0(a0,d0.l)
	BNE.S	6$
	MOVE.L	SrceCyls,a0
	ADDQ.L	#1,a0
	MOVE.L	a0,d4
	ASL.L	#2,d4
	MOVE.L	d4,-(a7)
	MOVE.L	(a2),-(a7)
	JSR	(a3)
	ADDQ.L	#8,a7
8$:	TST.L	DataBuffer
	BEQ.S	9$
	MOVE.L	Buffersize,-(a7)
	MOVE.L	DataBuffer,-(a7)
	JSR	(a3)
	ADDQ.L	#8,a7
9$:	TST.L	BlockBufPtr
	BEQ.S	10$
	PEA	512
	MOVE.L	BlockBufPtr,-(a7)
	JSR	(a3)
	ADDQ.L	#8,a7
10$:	TST.L	InfoBuffer		;got infodata buffer?
	BEQ.S	11$			;no
	PEA	36			;size of infodata buffer
	MOVE.L	InfoBuffer,-(a7)	;ptr to infodata buffer
	JSR	(a3)
	ADDQ.L	#8,a7
11$:	TST.L	FileInfoBuf		;got a fileinfo buffer?
	BEQ.S	12$			;none
	PEA	260			;buffer size
	MOVE.L	FileInfoBuf,-(a7)	;ptr to FileInfo buffer
	JSR	(a3)
	ADDQ.L	#8,a7
12$:	TST.L	GraphicsBase
	BEQ.S	13$
	MOVE.L	GraphicsBase,-(a7)
	BSR	CloseLib
	ADDQ.L	#4,a7
13$	TST.L	IconBase
	BEQ.S	14$
	MOVE.L	IconBase,-(a7)
	BSR	CloseLib
	ADDQ.L	#4,a7
14$:	TST.W	DoneFlag		;diskcopy successful?
	BEQ.S	15$			;no
	MOVE.L	#L268,a0		;else diskcopy finished
	BRA.S	16$

15$:	MOVE.L	#L269,a0		;diskcopy abandoned
16$:	MOVE.L	a0,(a4)
	TST.L	KeyArrayPtr
	BEQ.S	17$
	TST.L	d2
	BNE.S	18$
	MOVE.L	(a4),-(a7)
	PEA	L270			;
	BSR	OutputMsg
	ADDQ.L	#8,a7
	BRA.S	18$

17$:	TST.L	Window
	BEQ.S	18$
	MOVE.L	(a4),-(a7)
	PEA	$3c
	BSR	L402
	PEA	150
	BSR	TimeDelay
	MOVE.L	Window,-(a7)
	BSR	CloseWin
	LEA	16(a7),a7
18$:	TST.L	IntuitionBase
	BEQ.S	19$
	MOVE.L	IntuitionBase,-(a7)
	BSR	CloseLib
	ADDQ.L	#4,a7
19$:	MOVE.L	d3,-(a7)
	BSR	SetResult
	MOVE.L	d2,-(a7)
	BSR	ExitSR
	ADDQ.L	#8,a7
	MOVEM.L	(a7)+,d2-d5/a2-a4
	RTS

* This code reads a group of cylinders from source, writes them to dest, and
* verifies the write.

CopyByGroups:
	MOVEM.L	d2-d3/a2-a4,-(a7)
	MOVEQ	#1,d3
	MOVE.L	#RWMode,a2		;point to block count
	MOVE.L	#CylinderCnt,a3
	MOVE.L	#ActiveIOB,a4
	MOVE.L	(a3),d0			;get cylinder count
	ADD.L	CylsCompleted,d0
	CMP.L	MaxCyls,d0
	SEQ	d0
	NEG.B	d0
	EXT.W	d0
	EXT.L	d0
	TST.L	(a3)			;cylinder count
	sge	d1
	NEG.B	d1
	EXT.W	d1
	EXT.L	d1
	and.l	d1,d0
	BEQ	4$
	CMPI.W	#11,(a2)		;write mode?
	BNE.S	1$			;no
	TST.W	VerifyFlg		;yes, verifying?
	BEQ.S	2$			;no
1$:	CMPI.W	#999,(a2)		;verification pass?
	BNE.S	4$			;no
2$:	MOVE.L	DestIOB,-(a7)		;yes...dest iob
	BSR	WaitInOut
	PEA	512			;512 bytes
	CLR.L	-(a7)			;offset=0
	MOVE.L	BlockBufPtr,-(a7)	;buffer address
	PEA	3			;CMD_WRITE
	MOVE.L	DestIOB,-(a7)		;dest iob
	BSR	LoadIOBlock		;load data into IOB
	MOVE.L	DestIOB,-(a7)		;dest iob
	BSR	DoInOut			;write block to disk
	TST.L	d0			;error?
	LEA	28(a7),a7
	BEQ.S	3$			;no
	PEA	1
	MOVE.L	DestIOB,a0		;dest iob
	MOVE.B	31(a0),d1
	EXT.W	d1
	EXT.L	d1
	MOVE.L	d1,-(a7)
	BSR	Error
	MOVEQ	#0,d0
	ADDQ.L	#8,a7
	BRA	35$

3$:	MOVE.W	#1,DoneFlag		;mark successful completion
	BRA	33$

4$:	MOVE.L	(a4),a0
	TST.B	31(a0)			;io_error?
	BNE	21$			;yes
	ADDQ.L	#1,(a3)			;else increment cyl count
	BRA	20$

5$:	MOVE.L	(a3),d0			;get cylinder count
	ASL.L	#2,d0
	MOVE.L	CylBufTblPtr,d2
	MOVE.L	d0,a1
	TST.L	0(a1,d2.l)
	BEQ	11$
	MOVE.L	(a3),d0			;cylinder count
	ADD.L	CylsCompleted,d0
	CMP.L	MaxCyls,d0
	bgt.l	11$
	CLR.B	L324
	CMPI.W	#11,(a2)		;write mode?
	BNE.S	6$			;no, read/verify
	MOVE.L	(a3),d0			;cylinder count
	ADD.L	CylsCompleted,d0
	BNE.S	6$
	PEA	512			;512 bytes
	MOVE.L	BlockBufPtr,-(a7)
	MOVE.L	CylBufTblPtr,a0
	MOVE.L	(a0),-(a7)
	BSR	MoveData
	MOVE.L	CylBufTblPtr,a0
	MOVE.L	(a0),a0
	MOVE.L	#'COPY',(a0)		;"COPY"
	LEA	12(a7),a7
6$:	CMPI.W	#999,(a2)		;verification pass?
	BNE.S	7$			;no
	PEA	L271			;verifying track
	BSR	DisplayTrackStatus
	PEA	999
	MOVE.L	(a3),d1			;cylinder count
	ADD.L	CylsCompleted,d1
	MOVE.L	d1,-(a7)
	PEA	2			;CMD_READ
	MOVE.L	(a4),-(a7)		;IOB
	BSR	ReadWriteCyl
	TST.L	d0
	LEA	20(a7),a7
	BNE.S	10$
	BRA	33$

7$:	CMPI.W	#11,(a2)		;write mode?
	BNE.S	8$			;no
	MOVE.L	#L272,a0		;writing track
	BRA.S	9$

8$:	MOVE.L	#L273,a0		;reading track
9$:	MOVE.L	a0,-(a7)
	BSR	DisplayTrackStatus
	MOVE.L	(a3),-(a7)		;cylinder count
	MOVE.L	(a3),d1			;cylinder count
	ADD.L	CylsCompleted,d1
	MOVE.L	d1,-(a7)
	MOVEQ	#0,d0
	MOVE.W	(a2),d0			;read/write command
	MOVE.L	d0,-(a7)		;command
	MOVE.L	(a4),-(a7)		;iob
	BSR	ReadWriteCyl
	TST.L	d0
	LEA	20(a7),a7
	BNE.S	10$			;no error
	BRA	33$			;else take error exit

10$:	CLR.W	d3
	BRA	20$

11$:	CMPI.W	#11,(a2)		;write mode?
	BEQ.S	12$			;yes
	CMPI.W	#999,(a2)		;verification pass?
	BNE	17$			;no
12$:	CMPI.B	#2,ModeFlag		;yes
	bge.l	17$
;;	TST.W	OneDrvFlg
;;	BEQ.S	14$			;two drives
	TST.W	VerifyFlg
	BEQ.S	13$			;no
	CMPI.W	#999,(a2)		;verification pass?
	BNE.S	14$			;no
13$:	MOVE.L	(a4),-(a7)
	BSR	UpdateDrive
	LEA	4(A7),A7		;;
	TST.W	OneDrvFlg		;;
	BEQ.S	14$			;;two drives
	MOVE.L	SrceNamePtr,-(a7)
	PEA	L274			;'( FROM disk) in drive %s'
	PEA	L332
	BSR	FormatTextString
	PEA	L332
	PEA	L334
	PEA	L275			;'Place %s %s'
	PEA	TrkStatusBuf
	BSR	FormatTextString
	PEA	L462
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
;;	LEA	40(a7),a7
	LEA	36(a7),a7		;;
	BNE.S	14$			;go on
	BRA	33$			;else bail out

14$:	TST.W	VerifyFlg
	BEQ.S	15$			;not verifying
	CMPI.W	#999,(a2)		;was this the verification pass?
	BNE.S	16$			;no...do it now
15$:	MOVE.L	(a3),d0			;cylinder count
	ADD.L	d0,CylsCompleted
	MOVE.L	SrceIOB,(a4)		;source iob
	MOVE.W	#2,(a2)			;set read mode
	BRA	19$

16$:	MOVE.W	#999,(a2)		;set verification pass flag
	BRA	19$

17$:;;	TST.W	OneDrvFlg
;;	BEQ.S	18$			;two drives
	MOVE.L	(a4),-(a7)
	BSR	UpdateDrive
	LEA	4(A7),A7		;;
	TST.W	OneDrvFlg		;;
	BEQ.S	18$			;;two drives
	MOVE.L	DestIOB,-(a7)		;dest iob
	BSR	MotorOff
	MOVE.L	DestNamePtr,-(a7)
	PEA	L276			;'(TO DISK) in drive %s'
	PEA	L332
	BSR	FormatTextString
	PEA	L332
	PEA	L335
	PEA	L277			;'Place %s %s'
	PEA	TrkStatusBuf
	BSR	FormatTextString
	PEA	L458
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
;;	LEA	44(a7),a7
	LEA	40(a7),a7		;;
	BNE.S	18$			;proceed
	BRA	33$			;op wants to quit

18$:	MOVE.L	DestIOB,(a4)		;dest iob ptr
	MOVE.W	#11,(a2)		;set write mode (format)
19$:	CLR.L	(a3)			;reset cylinder count
	CLR.B	L324
20$:	TST.W	d3			;done?
	BEQ	34$			;yes...good exit
	BRA	5$			;else loop

21$:	CMPI.B	#3,L324
	BNE	31$
	CMPI.W	#2,(a2)			;read mode?
	BNE	31$			;no
	TST.L	KeyArrayPtr		;from CLI?
	BEQ	27$			;no...WB
	PEA	L334
	PEA	L278			;cannot read drive?
	BSR	OutputMsg
	CLR.B	L363
	ADDQ.L	#8,a7
	BRA.S	23$

22$:	BSR	GetInputChar
	MOVE.B	d0,L363			;save char
23$:	PEA	30
	MOVE.L	StdIn,-(a7)
	BSR	WaitChar
	TST.L	d0
	ADDQ.L	#8,a7
	BNE.S	22$
	TST.B	L363
	BEQ.S	24$
	MOVE.B	#10,L363
	BEQ.S	25$
24$:	BSR	GetInputChar
	MOVE.B	d0,L363
	CMPI.B	#10,L363		;end of msg?
	BEQ.S	25$			;yes
	BSR	GetInputChar		;else get next
25$:	BSR	CheckForBreak		;op wants to break?
	MOVE.W	d0,d0
	BNE.S	26$			;yes
	MOVEQ	#0,d0
	MOVE.B	L363,d0
	MOVEQ	#$5f,d1
	and.l	d1,d0
	MOVEQ	#$43,d1
	CMP.L	d0,d1
	BEQ.S	28$
26$:	BRA	33$

27$:	PEA	L473
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
	ADDQ.L	#8,a7
	BNE.S	28$			;proceed
	BRA	33$			;op wants to quit

28$:	CLR.W	L325
	MOVEQ	#0,d3
	BRA.S	30$

29$:	MOVE.L	(a3),d0			;cylinder count
	ASL.L	#2,d0
	MOVE.L	CylBufTblPtr,d2
	MOVE.L	d0,a1
	MOVE.L	d3,d1
	ADDQ.L	#1,d3
	MOVE.L	0(a1,d2.l),d0
	MOVE.L	d1,a1
	CLR.B	0(a1,d0.l)
30$:	CMP.L	Buffersize,d3
	BLT.S	29$
	MOVE.L	(a4),-(a7)
	BSR	SendReply2
	MOVE.L	(a4),a0
	CLR.B	31(a0)
	SUBQ.L	#1,(a3)			;decrement cylinder count
	MOVEQ	#1,d0
	ADDQ.L	#4,a7
	BRA	35$

31$:	MOVE.L	(a4),a0
	CMPI.B	#$1c,31(a0)
	BNE.S	32$
	CLR.B	L324
	MOVE.L	(a4),-(a7)
	BSR	MotorOff
	PEA	L279
	PEA	TrkStatusBuf
	BSR	FormatTextString
	PEA	L426
	PEA	TrkStatusBuf
	BSR	OutputMsgWaitReturn
	PEA	L280			;writing track
	BSR	DisplayTrackStatus
	LEA	24(a7),a7
32$:	MOVE.L	(a3),-(a7)		;cylinder count
	MOVE.L	(a3),d1			;ditto
	ADD.L	CylsCompleted,d1
	MOVE.L	d1,-(a7)
	MOVEQ	#0,d0
	MOVE.W	(a2),d0			;read/write mode
	MOVE.L	d0,-(a7)		;command
	MOVE.L	(a4),-(a7)		;iob
	BSR	ReadWriteCyl
	TST.L	d0
	LEA	16(a7),a7
	BNE.S	34$
33$:	MOVEQ	#0,d0			;incomplete exit
	BRA.S	35$

34$:	MOVEQ	#1,d0
35$:	MOVEM.L	(a7)+,d2-d3/a2-a4
	RTS

* Come here on various error 

Error:
L156	MOVEM.L	d2/a2,-(a7)
	MOVE.B	15(a7),d2
	MOVE.L	16(a7),d0
	MOVE.L	#L342,a2
	MOVEQ	#2,d1
	CMP.L	d0,d1
	BLE.S	L159
	TST.L	d0
	BEQ.S	L157
	MOVE.L	#L281,a0		;error on dest disk
	BRA.S	L158

L157	MOVE.L	#L282,a0		;error on source disk
L158	MOVE.L	a0,(a2)
	BRA.S	L160

L159	MOVE.L	#L283,(a2)		;diskcopy error
L160	TST.L	KeyArrayPtr
	BEQ.S	L161
	MOVE.L	(a2),-(a7)
	PEA	L284
	BSR	OutputMsg
	BRA.S	L162

L161	MOVE.L	(a2),-(a7)
	PEA	30
	BSR	L402
L162	ADDQ.L	#8,a7
	CMPI.B	#$15,d2
	bcs.s	L163
	CMPI.B	#$1b,d2
	bhi.s	L163
	MOVE.L	#L285,(a2)
	BRA	L171

L163	MOVEQ	#0,d0
	MOVE.B	d2,d0
	CMPI.W	#29,d0
	BLT.S	L164
	BGT.S	L165
	BRA.S	L168

L164	CMPI.W	#1,d0
	BLT	L170
	BLE.S	L166
	CMPI.W	#28,d0
	BNE	L170
	BRA.S	L167

L165	CMPI.W	#30,d0
	BLT	L170
	BLE.S	L169
	CMPI.W	#$60,d0
	BLT.S	L170
	CMPI.W	#$63,d0
	BGT.S	L170
	subi.w	#$60,d0
	add.w	d0,d0
	MOVE.W	*+8(pc,d0.w),d0
	JMP	*+4(pc,d0.w)

	DC.W	$0008,$0018
	DC.W	$0038,$0040

* no refs
	MOVE.L	#L286,(A2)		;cannot open device
	BRA.S	L171

L166	MOVE.L	#L287,(a2)		;not enough memory
	BRA.S	L171

* no refs
	MOVE.L	#L288,(a2)		;cannot open amigados device
	BRA.S	L171

L167	MOVE.L	#L289,(a2)		;write protected
	BRA.S	L171

L168	MOVE.L	#L290,(a2)		;disk changed
	BRA.S	L171

L169	MOVE.L	#L291,(a2)		;seek error
	BRA.S	L171

* no refs
	MOVE.L	#L292,(a2)		;disk size error
	BRA.S	L171

* no refs
	MOVE.L	#L293,(a2)		;verify error
	BRA.S	L171

L170	MOVE.L	#L294,(a2)		;unspecified error
L171	TST.L	KeyArrayPtr
	BEQ.S	1$
	MOVE.L	(a2),-(a7)
	PEA	L295
	BSR	OutputMsg
	BRA.S	2$

1$:	MOVE.L	(a2),-(a7)
	PEA	40
	BSR	L402
2$:	ADDQ.L	#8,a7
	MOVEQ	#0,d0
	MOVE.B	d2,d0
	MOVE.L	d0,-(a7)
	BSR	SetResult
	MOVEQ	#0,d0
	ADDQ.L	#4,a7
	MOVEM.L	(a7)+,d2/a2
	RTS

***********************************************************
* Checks for break signal and processes the break, if found.
* If multi (mode=1) or mode=2 checks another signal bit...disk changed?

CheckForBreak:
L174	PEA	$3000
	CLR.L	-(a7)
	BSR	TestSignal		;break commanded?
	MOVE.L	d0,d1			;save old signal bits
	ANDI.L	#$1000,d0		;break?
	ADDQ.L	#8,a7
	BEQ.S	1$			;no
	TST.L	KeyArrayPtr		;from CLI?
	BEQ.S	1$			;no
	PEA	L296			;*** BREAK
	BSR	OutputMsg		;display break text
	MOVEQ	#1,d0			;show break commanded
	ADDQ.L	#4,a7
	BRA.S	3$			;exit

1$:	TST.B	ModeFlag		;multi?
	BEQ.S	2$			;no
	MOVE.L	d1,d0			;restore signal bits
	ANDI.L	#$2000,d0		;diskchange???
	BEQ.S	2$			;no
	MOVEQ	#1,d0			;else show break commanded
	BRA.S	3$			;exit

2$:	CLR.W	d0
3$:	EXT.L	d0
	RTS

************************************************************
* Output msg and wait for return to proceed.
* CTRL-D or CTRL-C will abort

OutputMsgWaitReturn:
L178	MOVE.L	4(a7),d0
	MOVE.L	8(a7),d1
	TST.L	KeyArrayPtr		;from CLI?
	BEQ.S	3$			;no
	MOVE.L	d0,-(a7)
	PEA	L297			;press RETURN to continue
	BSR	OutputMsg
	ADDQ.L	#8,a7
	BRA.S	2$

1$:	BSR	GetInputChar
2$:	PEA	30
	MOVE.L	StdIn,-(a7)
	BSR	WaitChar
	TST.L	d0
	ADDQ.L	#8,a7
	BNE.S	1$
	BSR	GetInputChar
	PEA	L298
	BSR	OutputMsg
	BSR	CheckForBreak
	MOVE.W	d0,d0			;0=no, 1=yes
	SEQ	d0
	NEG.B	d0
	EXT.W	d0
	EXT.L	d0
	ADDQ.L	#4,a7
	BRA.S	5$

3$:	PEA	$48
	PEA	$157
	PEA	$200
	CLR.L	-(a7)
	PEA	L421
	PEA	L423
	MOVE.L	d1,-(a7)
	MOVE.L	Window,-(a7)
	BSR	DispReq
	TST.L	d0
	LEA	32(a7),a7
	BNE.S	4$
	PEA	10
	BSR	CleanUp
	ADDQ.L	#4,a7
4$:	MOVEQ	#1,d0
5$:	EXT.L	d0
	RTS

********************************************************
* Check out devices and create IOBs for copy.

CreateIOBs:
	MOVEM.L	d2-d5/a2-a5,-(a7)
	MOVE.L	36(a7),d2		;dest keyword ptr
	MOVE.L	40(a7),a2
	MOVE.L	44(a7),d1		;source keyword ptr
	CLR.W	d4
	MOVE.L	#DestNamePtr,a3
	MOVE.L	#SrceDevProc,a4
	MOVE.L	#SrceDevList,d3
	MOVE.L	a2,d0
	BEQ.S	1$
	MOVE.L	(a2),d0
	BRA.S	2$

1$:	MOVEQ	#0,d0
2$:	MOVE.L	d0,d5
	TST.L	$30(a7)
	BEQ.S	3$
	MOVE.L	$30(a7),a0
	MOVE.L	(a0),d0
	BRA.S	4$

3$:	MOVEQ	#0,d0
4$:	MOVE.L	d0,d0
	BEQ.S	5$
	CMP.L	d5,d0
	BNE.S	5$
	MOVE.L	SrceNamePtr,-(a7)
	MOVE.L	(a3),-(a7)
	BSR	FormatTextString
	MOVE.L	(a3),d1
	MOVEQ	#1,d4
	ADDQ.L	#8,a7
5$:	MOVE.W	d4,d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	PEA	1			;srce/dest flag=dest
	MOVE.L	(a3),-(a7)
	PEA	L335	
	MOVE.L	$40(a7),-(a7)		;
	MOVE.L	d1,-(a7)		;dest keyword ptr
	BSR	GetDevInfo
	MOVE.L	d0,DestDevList			;dest device list entry
	MOVE.W	d4,d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	CLR.L	-(a7)			;srce/dest flag=source
	MOVE.L	SrceNamePtr,-(a7)
	PEA	L334
	MOVE.L	a2,-(a7)
	MOVE.L	d2,-(a7)		;srce keyword ptr
	BSR	GetDevInfo
	MOVE.L	d3,a5
	MOVE.L	d0,(a5)			;save ptr to srce device list
	TST.L	(a5)
	LEA	$30(a7),a7
	BEQ.S	6$
	TST.L	DestDevList
	BNE.S	9$
6$:	MOVE.L	d3,a0
	TST.L	(a0)
	BEQ.S	7$
	MOVEQ	#1,d0
	BRA.S	8$

7$:	MOVEQ	#0,d0
8$:	MOVE.L	d0,-(a7)
	PEA	$61
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7
9$:	MOVE.L	SrceNamePtr,-(a7)
	BSR	GetDevProc
	MOVE.L	d0,(a4)			;source dev proc
	ADDQ.L	#4,a7
	BEQ.S	10$
	MOVE.L	(a3),-(a7)
	BSR	GetDevProc
	MOVE.L	d0,DestDevProc		;dest dev proc
	ADDQ.L	#4,a7
	BNE.S	13$
10$:	TST.L	(a4)
	BEQ.S	11$
	MOVEQ	#1,d0
	BRA.S	12$

11$:	MOVEQ	#0,d0
12$:	MOVE.L	d0,-(a7)
	PEA	$61
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7
13$:	MOVE.L	(a4),d0			;source dev proc
	CMP.L	DestDevProc,d0		;same as dest dev proc?
	SEQ	d0
	NEG.B	d0
	EXT.W	d0
	EXT.L	d0
	MOVE.W	d0,OneDrvFlg		;1=single device
	MOVE.L	(a4),-(a7)		;source proc
	PEA	1
	BSR	InitIOB
	MOVE.W	d0,SrceFlag
	ADDQ.L	#8,a7
	BEQ.S	14$
	TST.W	OneDrvFlg		;single drive?
	BNE.S	15$			;yes, dont try to create other IOB
	MOVE.L	DestDevProc,-(a7)
	PEA	1
	BSR	InitIOB
	MOVE.W	d0,DestFlag
	ADDQ.L	#8,a7
	BNE.S	15$
14$:	PEA	2
	PEA	$61
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7
15$:	MOVEM.L	(a7)+,d2-d5/a2-a5
	RTS

***********************************

L200	MOVE.L	SrceIOB,-(a7)		;source iob ptr
	BSR	UpdateDrive
	MOVE.L	SrceIOB,-(a7)
	BSR	CloseDev
	MOVE.L	DestIOB,-(a7)		;dest iob ptr
	BSR	UpdateDrive
	MOVE.L	DestIOB,-(a7)
	BSR	CloseDev
	LEA	16(a7),a7
	RTS

***********************************

AllocateBuffers:
L201	BRA.S	L204

L202	TST.L	KeyArrayPtr
	BEQ.S	L203
	PEA	2
	PEA	1
	BSR	Error
	PEA	10
	BSR	CleanUp
	LEA	12(a7),a7
	BRA.S	L204

L203	PEA	L447
	PEA	L299
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
	ADDQ.L	#8,a7
	BNE.S	L204			;proceed
	PEA	1			;else bail out
	BSR	SetResult
	PEA	10
	BSR	CleanUp
	ADDQ.L	#8,a7
L204	BSR	AllocBuffers
	MOVE.B	d0,d0
	BEQ.S	L202
	EXT.W	d0
	EXT.L	d0
	RTS

******************************************
* Allocates cylinder buffer(s) for copy.
* Also allocates cylinder buffer table.

AllocBuffers:
L205	LINK	a6,#-8
	MOVEM.L	d2-d7/a2-a4,-(a7)
	MOVEQ	#1,d6
	MOVEQ	#0,d3
	MOVEQ	#0,d4
	CLR.L	-4(a6)			;return flag
	MOVE.L	#MEMF_CHIP,-8(a6)	;mem-type=chip
	MOVE.L	#CylBufTblPtr,a3
	MOVE.L	#SrceCyls,d5
	MOVE.L	#Buffersize,a4		;cylinder size in bytes
	MOVE.L	#MEMF_PUBLIC,-(a7)	;type of memory
	MOVE.L	d5,a2
	MOVE.L	(a2),a0			;number of cylinders on source
	ADDQ.L	#1,a0			;srcecyls plus 1
	MOVE.L	a0,d2
	ASL.L	#2,d2			;mult by 4
	MOVE.L	d2,-(a7)		;size to allocate
	BSR	AllocateMemory		;alloc buffer for cylinderbuf table
	MOVE.L	d0,(a3)			;store ptr to table of cylinder bufs 
	ADDQ.L	#8,a7
	BNE.S	1$			;got a buffer
	MOVEQ	#0,d0
	BRA	11$

1$:;	TST.W	OneDrvFlg		;one drive?
;	BEQ.S	2$			;no
	MOVE.L	d5,a0			;yes...
	MOVE.L	(a0),d6			;srce cyls to d6 to 1
2$:	BRA.S	7$

3$:	MOVE.L	d3,d7
	ASL.L	#2,d7
	MOVE.L	d7,a0			;offset into cylbuftbl
	MOVE.L	(a3),d2			;cylbuftblptr
	MOVE.L	a0,a2
	MOVE.L	-8(a6),-(a7)		;memory type
	MOVE.L	(a4),-(a7)		;buffersize
	BSR	AllocateMemory		;allocate cyl buffer
	MOVE.L	d0,0(a2,d2.l)		;enter new cylbuf into cylbuftbl
	MOVE.L	d3,d7
	ASL.L	#2,d7
	MOVE.L	d7,a0
	MOVE.L	(a3),d0
	TST.L	0(a0,d0.l)		;test new entry
	ADDQ.L	#8,a7
	BNE.S	5$			;no error...got a buffer
	TST.L	d4			;no buffer...any already allocated?
	BEQ.S	4$			;no
	SUBQ.L	#1,d3
	MOVE.L	(a4),-(a7)		;size
	MOVE.L	d3,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	(a3),d0
	MOVE.L	0(a0,d0.l),-(a7)	;get ptr to allocated buffer
	BSR	FreeMemory		;release it
	SUBQ.L	#1,d4			;one less
	MOVE.L	d3,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	(a3),d0
	CLR.L	0(a0,d0.l)		;clear entry in tbl
	ADDQ.L	#8,a7
4$:	MOVE.L	d6,d3
	BRA.S	6$

5$:	ADDQ.L	#1,d4			;count of allocated bufs
6$:	ADDQ.L	#1,d3			;buffer count
	MOVE.L	#MEMF_PUBLIC,-8(a6)	;change memory type to public
7$:	CMP.L	d6,d3			;allocated enough cylinder bufs?
	BLT.S	3$			;no...loop
	TST.L	d4			;actually allocated any?
	BEQ.S	10$			;no
	MOVE.L	d5,a2			;yes...
	MOVE.L	(a2),a0			;srce cyls
	ADDA.L	d4,a0
	SUBQ.L	#1,a0
	MOVE.L	d4,d1
	MOVE.L	a0,d0
	BSR	DivideLong
	MOVE.L	(a2),a0
	ADDA.L	d0,a0
	SUBQ.L	#1,a0
	MOVE.L	d0,d1
	MOVE.L	a0,d0
	BSR	DivideLong
	MOVE.L	d0,-4(a6)		;set error flag
	MOVE.L	d4,d3
	SUBQ.L	#1,d3
	BRA.S	9$

8$:	MOVE.L	(a4),-(a7)
	MOVE.L	d3,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	(a3),d0
	MOVE.L	0(a0,d0.l),-(a7)
	BSR	FreeMemory
	MOVE.L	d3,a0
	SUBQ.L	#1,d3
	MOVE.L	a0,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	(a3),d0
	CLR.L	0(a0,d0.l)
	ADDQ.L	#8,a7
9$:	CMP.L	-4(a6),d3		;??
	BGT.S	8$
10$:	MOVE.L	-4(a6),d0		;return code
11$:	MOVEM.L	-44(a6),d2-d7/a2-a4
	UNLK	a6
	RTS

**********************************************

DisplayTrackStatus:
L217	MOVEM.L	d2/a2,-(a7)
	MOVE.L	12(a7),d1		;mode string ptr
	MOVE.L	#TrkStatusBuf,a2
	MOVE.L	MaxCyls,d0
	MOVE.L	CylinderCnt,d2
	ADD.L	CylsCompleted,d2
	SUB.L	d2,d0
	MOVE.L	d0,-(a7)		;"to go" count
	MOVE.L	ActiveIOB,a0
	LEA	$30(a0),a0
	MOVE.L	(a0),d2
	MOVE.L	CylinderCnt,d0
	ADD.L	CylsCompleted,d0
	ADD.L	d0,d2
	MOVE.L	d2,-(a7)		;"current track" count
	MOVE.L	d1,-(a7)		;mode string ptr
	PEA	L300			;basic track status msg
	PEA	(a2)			;it all goes into this buffer
	BSR	FormatTextString
	TST.L	KeyArrayPtr
	LEA	20(a7),a7
	BEQ.S	1$
	PEA	(a2)
	PEA	L301
	BSR	OutputMsg		;display format msg
	BRA.S	2$

1$:	PEA	(a2)
	PEA	20
	BSR	L402
2$:	ADDQ.L	#8,a7
	MOVEM.L	(a7)+,d2/a2
	RTS

***********************************************
* Compares data for verify step.

CompareData:
L220	MOVEM.L	d2-d3/a2-a3,-(a7)
	MOVE.W	22(a7),d1
	TST.W	VerifyFlg
	BEQ.S	5$			;no
	MOVEQ	#0,d0
	MOVE.W	d1,d0
	MOVE.L	d0,d2
	ASL.L	#2,d2
	MOVE.L	d2,a0
	MOVE.L	CylBufTblPtr,d0
	MOVE.L	0(a0,d0.l),a2
	MOVE.L	DataBuffer,a3
	TST.L	DataBuffer
	BNE.S	1$
	BRA.S	5$

1$:;	MOVEQ	#0,d2
;;	BRA.S	4$
	MOVE.L	Buffersize,D2			;;
	LSR.L	#2,D2				;;
	DECL	D2				;;

2$:;;	MOVE.L	(a3),d0
;;	CMP.L	(a2),d0
	MOVE.L	(A3)+,D0
	CMP.L	(A2)+,D0
	BEQ.S	3$
	CLR.W	d0
	BRA.S	6$

3$:;;	ADDQ.L	#1,d2
;;	ADDQ.L	#4,a2
;;	ADDQ.L	#4,a3
;;4$:	MOVEQ	#4,d1
;;	MOVE.L	Buffersize,d0
;;	BSR	DivideLong
;;	CMP.L	d0,d2
;;	BLT.S	2$
	DBF	D2,2$				;;
5$:	MOVEQ	#1,d0
6$:	EXT.L	d0
	MOVEM.L	(a7)+,d2-d3/a2-a3
	RTS

*****************************************
* Gets device information and sets device name buffer
* Returns ptr to device list entry or 0 in D0.

GetDevInfo:
L227	MOVEM.L	d2-d5/a2-a5,-(a7)
	MOVE.L	36(a7),a3
	MOVE.L	40(a7),a2
	MOVE.L	44(a7),d2
	MOVE.L	#CleanUp,a4
	MOVE.L	#InfoBuffer,d3
	MOVE.L	a2,d0
	BEQ.S	1$
	MOVE.L	(a2),d4
	BRA.S	2$

1$:	MOVEQ	#0,d4			;lock=0=current device
2$:	TST.W	$36(a7)			;srce/dest flag
	BEQ.S	3$			;process source disk
	MOVE.L	#L302,a0		;else process 'destination disk'
	BRA.S	4$

3$:	MOVE.L	#L303,a0		;'source disk'
4$:	MOVE.L	a0,d5
	TST.L	d4			;current device?
	BEQ	11$			;yes
	TST.B	(a3)			;else there must be some keywords
	BEQ.S	5$			;???
	PEA	10
	JSR	(a4)			;cleanup
	ADDQ.L	#4,a7
5$:	MOVE.L	d4,-(a7)		;pass lock
	BSR	ParDir			;get parent dir
	MOVE.L	d0,d0
	ADDQ.L	#4,a7
	BEQ.S	6$			;got parent
	MOVE.L	d0,-(a7)
	BSR	Unlock
	PEA	10
	JSR	(a4)			;cleanup
	ADDQ.L	#8,a7
6$:	BSR	InOutErr
	TST.L	d0
	BNE.S	7$
	MOVE.L	d3,a5			;ptr to InfoBuffer address
	MOVE.L	(a5),-(a7)		;pass InfoBuffer address
	MOVE.L	d4,-(a7)		;lock on drive
	BSR	DriveInfo		;get drive info
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	7$			;error
	MOVE.L	FileInfoBuf,-(a7)	;fileinfo buffer
	MOVE.L	d4,-(a7)		;pass lock
	BSR	Exam			;exam the root
	TST.L	d0
	ADDQ.L	#8,a7
	BNE.S	8$
7$:	MOVE.W	$36(a7),d0		;srce/dest flag (1=dest)
	EXT.L	d0
	MOVE.L	d0,-(a7)
	PEA	$61
	BSR	Error
	PEA	10
	JSR	(a4)			;cleanup
	LEA	12(a7),a7
8$:	MOVE.L	FileInfoBuf,a0		;fileinfo buffer
	PEA	8(a0)
	MOVE.L	d2,-(a7)
	BSR	FormatTextString
	TST.W	$3e(a7)
	ADDQ.L	#8,a7
	BEQ	10$
	TST.W	$3a(a7)
	BNE	10$
	MOVE.L	d3,a5			;ptr to infodata buffer
	MOVE.L	(a5),a0			;infodata buffer address
	MOVE.L	32(a0),d0		;get some BPTR
	ASL.L	#2,d0
	MOVE.L	d0,a1			;APTR
	TST.L	(a1)			;drive in use?
	BEQ.S	9$			;no
	PEA	L432
	PEA	L304			;another process has drive
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0			;ctrl-c?
	ADDQ.L	#8,a7
	BNE.S	9$			;no
	PEA	$ca			;else bail out
	BSR	SetResult
	PEA	10
	JSR	(a4)			;cleanup
	ADDQ.L	#8,a7
9$:	MOVE.L	d3,a5			;ptr to InfoData buffer
	MOVE.L	(a5),a0
	MOVEQ	#80,d0
	MOVE.L	d0,a1
	CMPA.L	8(a0),a1		;drive write protected?
	BNE.S	10$			;no
	PEA	L426
	PEA	L305			;destination disk is write protected
	BSR	OutputMsgWaitReturn
	MOVE.W	d0,d0
	ADDQ.L	#8,a7
	BNE.S	10$			;proceed
	PEA	1			;else bail out
	PEA	28
	BSR	Error
	PEA	10
	JSR	(a4)			;cleanup
	LEA	12(a7),a7
10$:	MOVE.L	d4,-(a7)		;device lock
	BSR	Unlock			;unlock it
	CLR.L	(a2)
	ADDQ.L	#4,a7
	BRA.S	12$

11$:	MOVE.L	a3,-(a7)		;ptr to keyword
	BSR	DeleteColon		;delete trailing colon in device name
	MOVE.L	d5,-(a7)
	MOVE.L	d2,-(a7)
	BSR	FormatTextString
	LEA	12(a7),a7
12$:	MOVE.L	d3,a2			;infodata buffer ptr
	MOVE.L	(a2),a0
	MOVE.L	28(a0),d2		;BPTR to volume node
	ASL.L	#2,d2
	MOVE.L	d2,a1			;point to volume node
	MOVE.L	8(a1),-(a7)		;ptr to handler task msg port (process)
	MOVE.L	a3,-(a7)		;keyword ptr
	MOVE.L	$38(a7),-(a7)		;device name buffer
	BSR	CheckDeviceList		;search device list and move name
	LEA	12(a7),a7
	MOVEM.L	(a7)+,d2-d5/a2-a5	;ptr to device list entry in D0
	RTS

*************************************** 

SetResult:
L240	MOVEM.L	d2-d3,-(a7)
	MOVE.L	12(a7),d2
	MOVEQ	#0,d3
	MOVEQ	#0,d1
1$:	MOVE.L	#L328,a0
	MOVEQ	#0,d0
	MOVE.B	0(a0,d1.l),d0
	CMP.L	d2,d0
	BNE.S	2$
	MOVE.L	#L329,a0
	MOVEQ	#0,d0
	MOVE.B	0(a0,d1.l),d0
	MOVE.L	d0,d3
	BRA.S	3$

2$:	ADDQ.L	#1,d1
	MOVEQ	#6,d0
	CMP.L	d1,d0
	BGT.S	1$
3$:	CLR.L	-(a7)
	BSR	FindAnyTask
	MOVE.L	d0,a0
	MOVE.L	d3,$94(a0)
	ADDQ.L	#4,a7
	MOVE.L	d2,d0
	MOVEM.L	(a7)+,d2-d3
	RTS

******************************************************
* Load data into IOB

LoadIOBlock:
L364	MOVE.L	a2,-(a7) 
	MOVE.L	8(a7),a2		;IOB ptr
	MOVE.W	14(a7),d0		;command code
	MOVE.L	16(a7),d1		;buffer ptr
	MOVE.W	d0,28(a2)		;IO_COMMAND
	MOVE.L	24(a7),36(a2)		;IO_LENGTH
	MOVE.L	d1,40(a2)		;IO_DATA=buffer
	CLR.B	31(a2)			;IO_ERROR
	CLR.B	30(a2)			;IO_FLAGS
	LEA	48(a2),a0		;point to IO_TDCOUNT
	MOVE.L	(a0),d1			;get disk change count??
	MOVE.L	Buffersize,d0
	BSR	Multiply
	ADD.L	20(a7),d0		;add IO_OFFSET 
	MOVE.L	d0,44(a2)		;update IO_OFFSET in IOB
	MOVEQ	#0,d0			;no error
	MOVE.L	(a7)+,a2
	RTS

****************************************************
* Turns drive motor off
* IOB in A2

MotorOff:
L365	MOVE.L	a2,-(a7)
	MOVE.L	8(a7),a2
	MOVE.L	a2,-(a7)
	BSR	ChkIO			;previous IO done?
	TST.L	d0
	ADDQ.L	#4,a7
	BNE.S	1$			;yes
	MOVE.L	a2,-(a7)
	BSR	WaitInOut		;else wait till done
	ADDQ.L	#4,a7
1$:	CLR.L	36(a2)			;set io_length=0
	MOVE.W	#9,28(a2)		;command=motor off
	MOVE.L	a2,-(a7)
	BSR	DoInOut			;now do this one
	MOVEQ	#0,d0
	ADDQ.L	#4,a7
	MOVE.L	(a7)+,a2
	RTS

***********************************
* Forces last write out of device buffer

UpdateDrive:
L367	MOVE.L	a2,-(a7)		;save current IOB
	MOVE.L	8(a7),a2		;get new IOB
	MOVE.L	a2,-(a7)
	BSR	ChkIO			;previous IO done?
	TST.L	d0
	ADDQ.L	#4,a7
	BNE.S	1$			;yes
	MOVE.L	a2,-(a7)
	BSR	WaitInOut		;else wait for completion
	ADDQ.L	#4,a7
1$:	MOVE.W	#4,28(a2)		;IO_COMMAND=update
	MOVE.L	a2,-(a7)
	BSR	DoInOut			;now do this one
	MOVE.W	#5,28(a2)		;IO_COMMAND=clear
	MOVE.L	a2,-(a7)
	BSR	DoInOut
	MOVE.L	a2,-(a7)
	BSR	MotorOff
	LEA	12(a7),a7
	MOVE.L	(a7)+,a2
	RTS

***************************************************
* Fixes version and datestamp on copy after copy completed.

FixCopy:
L369	LINK	a6,#-$40
	MOVEM.L	d2-d3/a2-a5,-(a7)
	MOVE.L	8(a6),a2
	MOVEQ	#0,d2
	MOVE.L	#L342,d3
	MOVE.L	CylBufTblPtr,a0
	MOVE.L	(a0),a3			;get buffer address
	MOVE.L	a2,-(a7)
	BSR	WaitInOut
	PEA	$200			;512 bytes
	CLR.L	-(a7)			;offset is 0 for boot block
	MOVE.L	a3,-(a7)		;buffer address
	PEA	2			;CMD_READ
	MOVE.L	a2,-(a7)		;IOB
	BSR	LoadIOBlock		;get ready to perform IO
	MOVE.L	a2,-(a7)
	BSR	DoInOut			;do it
	MOVE.L	(a3),d0			;get ADOS id from boot block
	MOVEQ	#$FFFFFFFC,d1
	and.l	d1,d0
	cmpi.l	#$444f5300,d0		;check for ADOS ID
	LEA	28(a7),a7		;fix stack
	BNE	7$			;not a dos disk
	MOVE.L	CylBufTblPtr,a0
	MOVE.L	(a0),a4
	MOVE.L	a4,-(a7)		;buffer address
	PEA	2			;CMD_READ
	MOVE.L	a2,-(a7)		;IOB
	BSR	ReadWriteRoot
	TST.L	d0
	LEA	12(a7),a7
	BNE.S	2$			;no error
1$:	PEA	1
	MOVE.B	31(a2),d0		;get IO_ERROR code
	EXT.W	d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	BSR	Error
	ADDQ.L	#8,a7
	BRA	8$

2$:	PEA	$1e4(a4)
	BSR	StampDate
	PEA	$1a4(a4)
	BSR	StampDate
	LEA	$1b0(a4),a3
	MOVE.L	d3,a5
	MOVE.L	NamePtr,(a5)
	ADDQ.L	#8,a7
	BNE.S	4$
	MOVEQ	#0,d0
	MOVE.B	(a3),d0
	MOVE.L	d0,-(a7)		;count
	PEA	-32(a6)
	PEA	1(a3)
	BSR	MoveData
	MOVEQ	#0,d0
	MOVE.B	(a3),d0
	CLR.B	-32(a6,d0.w)
	TST.L	KeyArrayPtr
	LEA	12(a7),a7
	BEQ.S	3$
	LEA	-32(a6),a0
	MOVE.L	d3,a1
	MOVE.L	a0,(a1)
	BRA.S	4$

3$:	PEA	-32(a6)
	PEA	-$40(a6)
	BSR	ChangeRevision
	LEA	-$40(a6),a0
	MOVE.L	d3,a5
	MOVE.L	a0,(a5)
	ADDQ.L	#8,a7
4$:	MOVE.L	d3,a5
	MOVE.L	(a5),-(a7)
	BSR	L396
	MOVE.B	d0,(a3)
	MOVEQ	#0,d0
	MOVE.B	(a3),d0
	MOVE.L	d0,-(a7)		;count
	PEA	1(a3)
	MOVE.L	(a5),-(a7)
	BSR	MoveData
	MOVE.W	L325,d0
	EXT.L	d0
	MOVE.L	d0,$138(a4)
	MOVE.L	a4,a0
	MOVEQ	#0,d0
	LEA	16(a7),a7
	BRA.S	6$

5$:	ADDQ.L	#1,d0
	ADD.L	(a0)+,d2
6$:	cmpi.l	#$80,d0
	BLT.S	5$
	MOVE.L	d2,d0
	SUB.L	d0,20(a4)
	MOVE.L	a4,-(a7)
	PEA	3			;CMD_WRITE
	MOVE.L	a2,-(a7)
	BSR	ReadWriteRoot		;write block to disk
	TST.L	d0
	LEA	12(a7),a7
	BNE.S	7$			;no error
	BRA	1$

7$:	MOVEQ	#1,d0
8$:	MOVEM.L	-$58(a6),d2-d3/a2-a5
	UNLK	a6
	RTS

***************************************************
* Read or write 512-byte root block

ReadWriteRoot:
L378	MOVEM.L	d2-d4,-(a7)
	MOVE.L	16(a7),d2		;iob
	MOVE.W	22(a7),d3		;command
	MOVE.L	24(a7),d4		;buffer
	MOVE.L	d2,-(a7)		;iob to stack
	BSR	WaitInOut		;wait for previous I/O to finish
	PEA	512			;block size to stack
	MOVE.L	RootBlkNbr,d0		;block number
	ASL.L	#8,d0			;mult by 512 to get offset
	ASL.L	#1,d0
	MOVE.L	d0,-(a7)		;offset to stack
	MOVE.L	d4,-(a7)		;buffer ptr to stack
	ZAP	D0
	MOVE.W	d3,d0			;command
	MOVE.L	d0,-(a7)		;command to stack
	MOVE.L	d2,-(a7)		;iob to stack
	BSR	LoadIOBlock		;load data into IOB
	MOVE.L	d2,-(a7)
	BSR	DoInOut			;perform IO
	TST.L	d0
	LEA	28(a7),a7		;clean up stack
	BEQ.S	8$			;no error
	MOVEQ	#0,d0			;bad return
	BRA.S	9$

8$:	MOVEQ	#1,d0			;good return
9$:	MOVEM.L	(a7)+,d2-d4
	RTS

*************************************************************
* Reads/writes one cylinder

ReadWriteCyl:
L381	MOVEM.L	d2-d5/a2-a5,-(a7)
	MOVE.L	36(a7),a2		;iob
	MOVE.W	42(a7),d2		;read/write command
	MOVE.L	44(a7),d3
	MOVE.L	#CylBufTblPtr,a3
	MOVE.L	#Buffersize,a4
	MOVE.L	DataBuffer,d4
	BSR	CheckForBreak		;op wants to quit?
	TST.L	d0
	BEQ.S	1$			;no
	MOVEQ	#0,d0			;else exit
	BRA	6$

1$:	CMPI.W	#999,50(a7)
	BEQ.S	3$
	MOVEQ	#0,d0
	MOVE.W	50(a7),d0
	MOVE.L	d0,d5
	ASL.L	#2,d5
	MOVE.L	d5,a0
	MOVE.L	(a3),d0
	MOVE.L	0(a0,d0.l),-(a7)
	BSR	TypeOfMemory
	btst	#1,d0
	ADDQ.L	#4,a7
	BEQ.S	2$
	MOVEQ	#0,d0
	MOVE.W	50(a7),d0
	MOVE.L	d0,d1
	ASL.L	#2,d1
	MOVE.L	d1,a0
	MOVE.L	(a3),d0
	MOVE.L	0(a0,d0.l),d4
	BRA.S	3$

2$:	MOVE.L	(a4),-(a7)		;byte count
	MOVE.L	DataBuffer,-(a7)	;source buffer
	MOVEQ	#0,d0
	MOVE.W	$3a(a7),d0
	ASL.L	#2,d0
	MOVE.L	(a3),d1
	MOVE.L	d0,a5
	MOVE.L	0(a5,d1.l),-(a7)	;dest buffer
	BSR	CopyMemory
	LEA	12(a7),a7
3$:	MOVE.L	a2,-(a7)
	BSR	ChkIO
	TST.L	d0
	ADDQ.L	#4,a7
	BNE.S	4$			;no IO ongoing
	MOVE.L	a2,-(a7)		;else wait
	BSR	WaitInOut
	ADDQ.L	#4,a7
4$:	CMPI.B	#3,L324
	BNE.S	5$
	CMPI.W	#11,d2			;write mode?
	SEQ	d0
	NEG.B	d0
	EXT.W	d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	MOVE.B	31(a2),d0
	EXT.W	d0
	EXT.L	d0
	MOVE.L	d0,-(a7)
	BSR	Error
	ADDQ.L	#8,a7
	BRA.S	6$

5$:	MOVE.L	(a4),-(a7)		;byte count
	MOVE.L	(a4),d1
	MOVE.L	d3,d0
	BSR	Multiply
	MOVE.L	d0,-(a7)		;offset
	MOVE.L	d4,-(a7)		;buffer address
	MOVEQ	#0,d0
	MOVE.W	d2,d0
	MOVE.L	d0,-(a7)		;command
	MOVE.L	a2,-(a7)		;IOB
	BSR	LoadIOBlock
	MOVE.L	a2,-(a7)		;IOB
	BSR	SendInOut		;perform operation
	addq.b	#1,L324
	MOVEQ	#1,d5
	MOVE.L	d5,d0
	LEA	24(a7),a7
6$:	MOVEM.L	(a7)+,d2-d5/a2-a5
	RTS

*********************************************************
* Scans ADOS device list looking for match, and moves name into
* device name buffer.  Returns ptr to device list entry in D0.

CheckDeviceList:
L388	MOVEM.L	d2-d4/a2-a3,-(a7)
	MOVE.L	24(a7),d3		;buffer for formatted device name
	MOVE.L	28(a7),a2		;ptr to keyword device name
	MOVE.L	32(a7),d2		;devproc
	CLR.W	d4			;clear flag
	MOVE.L	DosBase,a0
	MOVE.L	34(a0),a0		;dl_Root
	MOVE.L	24(a0),d1		;rn_Info
	ASL.L	#2,d1			;AFIX D1
	MOVE.L	d1,a0
	MOVE.L	4(a0),d0		;di_DevInfo, BPTR to device list
	BRA.S	6$

1$:	TST.L	4(a3)			;dn_Type
	BNE.S	5$			;not a device entry
	TST.B	(a2)			;is there a keyword?
	BEQ.S	2$			;no
	MOVE.L	40(a3),d0		;ptr to device name
	ASL.L	#2,d0			;AFIX
	ADDQ.L	#1,d0			;skip length
	MOVE.L	d0,-(a7)		;pass ptr to device name
	MOVE.L	a2,-(a7)		;pass keyword ptr
	BSR	CompareStrings		;names match?
	TST.L	d0
	ADDQ.L	#8,a7
	BEQ.S	4$			;no match
	BRA.S	3$			;

2$:	CMP.L	8(a3),d2		;proper handler process?
	BNE.S	4$			;no
3$:	MOVEQ	#1,d4			;else force match
4$:	TST.W	d4
	BEQ.S	5$			;no match...try next device
	MOVE.L	40(a3),d0		;match...ptr to device name
	ASL.L	#2,d0			;AFIX
	ADDQ.L	#1,d0			;skip length
	MOVE.L	d0,-(a7)		;pass ptr to device name
	PEA	L418
	MOVE.L	d3,-(a7)		;buffer where device name goes
	BSR	FormatTextString
	MOVE.L	a3,d0
	LEA	12(a7),a7
	BRA.S	7$

5$:	MOVE.L	(a3),d0			;get fwd link to next device
6$:	ASL.L	#2,d0			;AFIX bptr to next device in list
	MOVE.L	d0,a3			;A3 points to device entry
	MOVE.L	a3,d0
	BNE.S	1$			;not end of list...loop
	MOVEQ	#0,d0			;error...no match
7$:	MOVEM.L	(a7)+,d2-d4/a2-a3
	RTS

*****************************************************

L396	MOVE.L	4(a7),a0
	MOVE.L	a0,a1
	BRA.S	2$

1$:	ADDQ.L	#1,a1
2$:	TST.B	(a1)
	BNE.S	1$
	MOVE.L	a1,d0
	MOVE.L	a0,d1
	SUB.L	d1,d0
	RTS

*****************************************************
* Moves source to dest for count bytes.

MoveData:
L399	MOVE.L	4(a7),a0
	MOVE.L	8(a7),a1
	MOVE.L	12(a7),d0
	MOVEQ	#0,d1
	BRA.S	2$

1$:	MOVE.B	(a0)+,(a1)+
	ADDQ.L	#1,d1
2$:	CMP.L	d0,d1
	BLT.S	1$
	RTS

**********************************************************

L402	MOVEM.L	d2-d3/a2,-(a7)
	MOVE.L	16(a7),d3
	MOVE.L	20(a7),d2
	MOVE.L	#Window,a2
	PEA	1
	MOVE.L	(a2),a0
	MOVE.L	50(a0),-(a7)
	BSR	SetPen
	MOVE.L	d3,-(a7)
	PEA	20			;20 bytes
	MOVE.L	(a2),a0
	MOVE.L	50(a0),-(a7)
	BSR	MoveData2
	MOVE.L	d2,-(a7)
	BSR	L396(pc)
	ADDQ.L	#4,a7
	MOVE.L	d0,-(a7)
	MOVE.L	d2,-(a7)
	MOVE.L	(a2),a0
	MOVE.L	50(a0),-(a7)
	BSR	DispText
	LEA	32(a7),a7
	MOVEM.L	(a7)+,d2-d3/a2
	RTS

* Converts passed char to upper case, and returns in D0.

UpperCase:
	MOVE.B	7(a7),d0
	CMPI.B	#$61,d0			;less than 'a'?
	bcs.s	1$			;yes
	CMPI.B	#$7a,d0			;greater than 'z'?
	bhi.s	1$			;yes
	MOVEQ	#0,d1			;else make upper case
	MOVE.B	d0,d1
	MOVEQ	#-32,d0
	ADD.L	d0,d1
	BRA.S	2$

1$:	MOVEQ	#0,d1			;return char 'as is'
	MOVE.B	d0,d1
2$:	MOVE.L	d1,d0			;return adjusted char
	RTS

* Compares two strings.  

CompareStrings:
	MOVEM.L	d2/a2-a3,-(a7)
	MOVE.L	16(a7),a2		;source string
	MOVE.L	20(a7),a3		;comparison string
	BRA.S	3$

1$:	TST.B	(a2)			;any more source?
	BNE.S	2$			;yes
	MOVEQ	#1,d0			;else match
	BRA.S	4$

2$:	ADDQ.L	#1,a2			;advance string ptrs
	ADDQ.L	#1,a3
3$:	MOVEQ	#0,d0
	MOVE.B	(a3),d0			;get a char from one stg
	MOVE.L	d0,-(a7)
	BSR	UpperCase		;make it upper case
	MOVE.L	d0,d2			;save it
	MOVEQ	#0,d0
	MOVE.B	(a2),d0			;get char from other stg
	MOVE.L	d0,-(a7)
	BSR	UpperCase		;make it upper case
	CMP.L	d0,d2			;match?
	ADDQ.L	#8,a7
	BEQ.S	1$			;yes...loop
	MOVEQ	#0,d0			;bad return...no match
4$:	MOVEM.L	(a7)+,d2/a2-a3
	RTS

* Deletes trailing colon from a device name string

DeleteColon:
	MOVE.L	4(a7),a0
	TST.B	(a0)			;null string?
	BEQ.S	3$			;yes...return
	BRA.S	2$			;else process

1$:	ADDQ.L	#1,a0			;advance ptr
2$:	TST.B	1(a0)			;found last char?
	BNE.S	1$			;no...loop
	CMPI.B	#$3a,(a0)		;yes...is it ':'?
	BNE.S	3$			;no
	CLR.B	(a0)			;else zap the char
3$:	RTS

* no refs?

L415A:
	MOVE.L 4(A7),A0
	BRA.S   2$
1$:	ADDQ.L  #1,A0
2$:	CMPI.B  #$3A,(A0)
	BEQ.S   3$
	TST.B   (A0)
	BNE.S   1$
3$:	TST.B   (A0)
	BNE.S   4$
	MOVE.B  #$3A,(A0)
4$:	CMPI.B  #$3A,(A0)
	BNE.S   5$
	ADDQ.L  #1,A0
	CLR.B   (A0)
5$:	RTS

******************************************************
* Initialize IOB for device

InitIOB:
L415	MOVEM.L	d2-d4/a2,-(a7)
	MOVE.L	20(a7),d2
	MOVE.L	24(a7),d3
	PEA	1
	PEA	$44
	BSR	AllocateMemory
	MOVE.L	d0,a2
	MOVE.L	a2,d4
	ADDQ.L	#8,a7
	BNE.S	1$
	MOVEQ	#0,d0
	BRA.S	2$

1$:	LEA	20(a2),a0
	MOVE.L	a0,10(a2)
	MOVE.L	a2,20(a2)
	CLR.L	-(a7)
	BSR	FindAnyTask
	MOVE.L	d0,a0
	LEA	$5c(a0),a0		;point to own msg port
	MOVE.L	a0,d4			;to d4
	MOVE.L	a0,24(a2)
	MOVEQ	#31,d0
	MOVE.L	d0,28(a2)
	MOVE.L	d2,40(a2)
	PEA	(a2)
	MOVE.L	d3,-(a7)
	BSR	PutAnyMsg
	MOVE.L	d4,-(a7)
	BSR	WaitMsgPort		;check for msg waiting at port
	PEA	(a2)
	BSR	RemoveIt		;get rid of it
	MOVE.W	34(a2),d2
	PEA	$44
	MOVE.L	a2,-(a7)
	BSR	FreeMemory
	MOVE.W	d2,d0
	EXT.L	d0
	LEA	28(a7),a7
2$:	MOVEM.L	(a7)+,d2-d4/a2
	RTS

StampDate:
L479	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	MOVE.L	8(a7),d1
	CALLSYS	DateStamp
	MOVE.L	(a7)+,a6
	RTS

TimeDelay:
L480	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	MOVE.L	8(a7),d1
	CALLSYS	Delay
	MOVE.L	(a7)+,a6
	RTS

GetDevProc:
L481	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	MOVE.L	8(a7),d1
	CALLSYS	DeviceProc
	MOVE.L	(a7)+,a6
	RTS

Exam:
L482	MOVEM.L	d2/a6,-(a7)
	MOVE.L	DosBase,A6
	MOVEM.L	12(a7),d1-d2
	CALLSYS	Examine
	MOVEM.L	(a7)+,d2/a6
	RTS

DriveInfo:
L483	MOVEM.L	d2/a6,-(a7)
	MOVE.L	DosBase,A6
	MOVEM.L	12(a7),d1-d2
	CALLSYS	Info
	MOVEM.L	(a7)+,d2/a6
	RTS

InOutErr:
L484	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	CALLSYS	IoErr
	MOVE.L	(a7)+,a6
	RTS

ParDir:
L485	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	MOVE.L	8(a7),d1
	CALLSYS	ParentDir
	MOVE.L	(a7)+,a6
	RTS

ReadFile:
L486	MOVEM.L	d2-d3/a6,-(a7)
	MOVE.L	DosBase,A6
	MOVEM.L	16(a7),d1-d3
	CALLSYS	Read
	MOVEM.L	(a7)+,d2-d3/a6
	RTS

Unlock:
L487	MOVE.L	a6,-(a7)
	MOVE.L	DosBase,A6
	MOVE.L	8(a7),d1
	CALLSYS	UnLock
	MOVE.L	(a7)+,a6
	RTS

WaitChar:
L488	MOVEM.L	d2/a6,-(a7)
	MOVE.L	DosBase,A6
	MOVEM.L	12(a7),d1-d2
	CALLSYS	WaitForChar
	MOVEM.L	(a7)+,d2/a6
	RTS

WriteFile:
L489	MOVEM.L	d2-d3/a6,-(a7)
	MOVE.L	DosBase,A6
	MOVEM.L	16(a7),d1-d3
	CALLSYS	Write
	MOVEM.L	(a7)+,d2-d3/a6
	RTS

AddMsgPort:
L490	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	AddPort
	MOVE.L	(a7)+,a6
	RTS

AllocateMemory:
L491	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVEM.L	8(a7),d0-d1
	CALLSYS	AllocMem
	MOVE.L	(a7)+,a6
	RTS

AllocateSignal:
L492	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),d0
	CALLSYS	AllocSignal
	MOVE.L	(a7)+,a6
	RTS

ChkIO:
L493	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	CheckIO
	MOVE.L	(a7)+,a6
	RTS

CloseDev:
L494	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	CloseDevice
	MOVE.L	(a7)+,a6
	RTS

CloseLib:
L495	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	CloseLibrary
	MOVE.L	(a7)+,a6
	RTS

CopyMemory:
L496	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVEM.L	8(a7),a0-a1
	MOVE.L	16(a7),d0
	CALLSYS	CopyMem
	MOVE.L	(a7)+,a6
	RTS

DoInOut:
L497	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	DoIO
	MOVE.L	(a7)+,a6
	RTS

FindAnyTask:
L498	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	FindTask
	MOVE.L	(a7)+,a6
	RTS

FreeMemory:
L499	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	MOVE.L	12(a7),d0
	CALLSYS	FreeMem
	MOVE.L	(a7)+,a6
	RTS

FreeSig:
L500	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),d0
	CALLSYS	FreeSignal
	MOVE.L	(a7)+,a6
	RTS

GetAnyMsg:
L501	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a0
	CALLSYS	GetMsg
	MOVE.L	(a7)+,a6
	RTS

OpenDev:
L502	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a0
	MOVEM.L	12(a7),d0/a1
	MOVE.L	20(a7),d1
	CALLSYS	OpenDevice
	MOVE.L	(a7)+,a6
	RTS

OpenLib:
L503	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	MOVE.L	12(a7),d0
	CALLSYS	OpenLibrary
	MOVE.L	(a7)+,a6
	RTS

PutAnyMsg:
L504	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVEM.L	8(a7),a0-a1
	CALLSYS	PutMsg
	MOVE.L	(a7)+,a6
	RTS

RemovePort:
L505	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	RemPort
	MOVE.L	(a7)+,a6
	RTS

RemoveIt:
L506	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	Remove
	MOVE.L	(a7)+,a6
	RTS

SendReply2:
L507	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	ReplyMsg
	MOVE.L	(a7)+,a6
	RTS

SendInOut:
L508	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	SendIO
	MOVE.L	(a7)+,a6
	RTS

TestSignal:
L509	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVEM.L	8(a7),d0-d1
	CALLSYS	SetSignal
	MOVE.L	(a7)+,a6
	RTS

TypeOfMemory:
L510	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	TypeOfMem
	MOVE.L	(a7)+,a6
	RTS

WaitEvent:
L511	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),d0
	CALLSYS	Wait
	MOVE.L	(a7)+,a6
	RTS

WaitInOut:
L512	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a1
	CALLSYS	WaitIO
	MOVE.L	(a7)+,a6
	RTS

WaitMsgPort:
L513	MOVE.L	a6,-(a7)
	MOVE.L	SysBase,a6
	MOVE.L	8(a7),a0
	CALLSYS	WaitPort
	MOVE.L	(a7)+,a6
	RTS


MoveData2:
L514	MOVE.L	a6,-(a7)
	MOVE.L	GraphicsBase,a6
	MOVE.L	8(a7),a1
	MOVEM.L	12(a7),d0-d1
	CALLSYS	Move
	MOVE.L	(a7)+,a6
	RTS

SetPen:
L515	MOVE.L	a6,-(a7)
	MOVE.L	GraphicsBase,a6
	MOVE.L	8(a7),a1
	MOVE.L	12(a7),d0
	CALLSYS	SetAPen
	MOVE.L	(a7)+,a6
	RTS

DispText:
L516	MOVE.L	a6,-(a7)
	MOVE.L	GraphicsBase,a6
	MOVE.L	8(a7),a1
	MOVE.L	12(a7),a0
	MOVE.L	16(a7),d0
	CALLSYS	Text
	MOVE.L	(a7)+,a6
	RTS

ChangeRevision:
L517	MOVE.L	a6,-(a7)
	MOVE.L	IconBase,a6
	MOVEM.L	8(a7),a0-a1
	CALLSYS	BumpRevision
	MOVE.L	(a7)+,a6
	RTS

DispReq:
L518	MOVEM.L	d2-d3/a2-a3/a6,-(a7)
	MOVE.L	IntuitionBase,a6
	MOVEM.L	24(a7),a0-a3
	MOVEM.L	40(a7),d0-d3
	CALLSYS	AutoRequest
	MOVEM.L	(a7)+,d2-d3/a2-a3/a6
	RTS

CloseWin:
L519	MOVE.L	a6,-(a7)
	MOVE.L	IntuitionBase,a6
	MOVE.L	8(a7),a0
	CALLSYS	CloseWindow
	MOVE.L	(a7)+,a6
	RTS

OpenWin:
L520	MOVE.L	a6,-(a7)
	MOVE.L	IntuitionBase,a6
	MOVE.L	8(a7),a0
	CALLSYS	OpenWindow
	MOVE.L	(a7)+,a6
	RTS

SetTitles:
L521	MOVEM.L	a2/a6,-(a7)
	MOVE.L	IntuitionBase,a6
	MOVEM.L	12(a7),a0-a2
	CALLSYS	SetWindowTitles
	MOVEM.L	(a7)+,a2/a6
	RTS

OutputString:
L522	MOVEM.L	a2-a4/a6,-(a7)
	MOVE.L	20(a7),a4
	MOVE.L	24(a7),a0
	MOVE.L	28(a7),a1
	LEA	StoreChar,a2
	LEA	-$8c(a7),a7
	MOVE.L	a7,a3
	MOVE.L	4,a6
	CALLSYS	RawDoFmt
	MOVEQ	#-1,d0
1$:	TST.B	(a3)+
	dbeq	d0,1$
	NOT.L	d0
	BEQ.S	2$
	MOVE.L	d0,-(a7)
	PEA	4(a7)
	PEA	(a4)
	BSR	WriteFile
	LEA	12(a7),a7
2$:	LEA	$8c(a7),a7
	MOVEM.L	(a7)+,a2-a4/a6
	RTS

StoreChar:
L525	MOVE.B	D0,(A3)+
	RTS

Divide:
L526	cmpi.l	#$ffff,d2
	BGT.S	1$
	movea.w	d1,a1
	CLR.W	d1
	SWAP	d1
	DIVU	d2,d1
	MOVE.L	d1,d0
	SWAP	d1
	MOVE.W	a1,d0
	DIVU	d2,d0
	MOVE.W	d0,d1
	CLR.W	d0
	SWAP	d0
	RTS

1$:	MOVE.L	d1,d0
	CLR.W	d0
	SWAP	d0
	SWAP	d1
	CLR.W	d1
	MOVE.L	d2,a1
	MOVEQ	#$f,d2
2$:	ADD.L	d1,d1
	ADDX.L	d0,d0
	CMPA.L	d0,a1
	BGT.S	3$
	SUB.L	a1,d0
	ADDQ.W	#1,d1
3$:	DBF	d2,2$
	RTS

Multiply:
L530	MOVE.L	d2,-(a7)
	MOVE.L	d0,d2
	MULU	d1,d2
	MOVE.L	d2,a0
	MOVE.L	d0,d2
	SWAP	d2
	MULU	d1,d2
	SWAP	d1
	MULU	d1,d0
	ADD.L	d2,d0
	SWAP	d0
	CLR.W	d0
	ADDA.L	d0,a0
	MOVE.L	a0,d0
	MOVE.L	(a7)+,d2
	RTS

* no refs
	MOVE.L	D2,-(A7)
	MOVE.L	D1,D2
	MOVE.L	D0,D1
	BSR.S	Divide
	MOVE.L	(a7)+,d2
	RTS

* no refs
	MOVE.L	D2,-(A7)
	MOVE.L	D1,D2
	MOVE.L	D0,D1
	BSR.S	Divide
	MOVE.L	d1,d0
	MOVE.L	(a7)+,d2
	RTS

* no refs
	MOVE.L	D2,-(A7)
	MOVE.L	D1,D2
	BGE.S	1$
	NEG.L	D2
1$:	MOVE.L	D0,D1
	MOVEQ	#0,D0
	TST.L	D1
	BGE.S	2$
	NEG.L	D1
	NOT.L	D0
2$:	MOVE.L	D0,A0
	BSR	Divide
	MOVE.W	a0,d2
	BEQ.S	3$
	NEG.L	d0
3$:	MOVE.L	(a7)+,d2
	RTS

****************************************************************

DivideLong:
L532	MOVE.L	d2,-(a7)
	MOVE.L	d0,a0
	MOVEQ	#0,d0
	MOVE.L	d1,d2
	bge.s	1$
	NEG.L	d2
	NOT.L	d0
1$:	MOVE.L	a0,d1
	bge.s	2$
	NEG.L	d1
	NOT.L	d0
2$:	MOVE.L	d0,a0
	BSR	Divide
	MOVE.L	a0,d2
	BEQ.S	3$
	NEG.L	d1
3$:	MOVE.L	d1,d0
	MOVE.L	(a7)+,d2
	RTS

FormatTextString:
L536	MOVEM.L	a2-a4/a6,-(a7)
	MOVE.L	20(a7),a3
	MOVE.L	24(a7),a0
	LEA	28(a7),a1
	LEA	StoreChar2,a2
	MOVE.L	4,a6
	CALLSYS	RawDoFmt
	MOVEM.L	(a7)+,a2-a4/a6
	RTS

StoreChar2:
	MOVE.B	D0,(A3)+
	RTS

* Returns input char in d0 or -1

GetInputChar:
L538	LINK	a6,#-4
	PEA	1
	PEA	-4(a6)
	MOVE.L	StdIn,-(a7)
	BSR	ReadFile
	MOVEQ	#1,d1
	CMP.L	d0,d1
	LEA	12(a7),a7
	BEQ.S	1$
	MOVEQ	#-1,d0
	BRA.S	2$

1$:	MOVE.B	-4(a6),d0
	EXT.W	d0
	EXT.L	d0
2$:	UNLK	a6
	RTS

OutputMsg:
L541	MOVE.L	4(a7),d0
	PEA	8(a7)
	MOVE.L	d0,-(a7)
	MOVE.L	StdOut,-(a7)
	BSR	OutputString
	LEA	12(a7),a7
	RTS

******************************************

NewList:
L542	MOVE.L	4(a7),a0
	MOVE.L	a0,(a0)
	ADDQ.L	#4,(a0)
	CLR.L	4(a0)
	MOVE.L	a0,8(a0)
	RTS

*******************************************

CreatePort:
L543	MOVEM.L	d2-d5/a2,-(a7)
	MOVE.L	24(a7),d3
	MOVE.B	31(a7),d2
	MOVEQ	#-1,d5
	MOVE.L	d5,-(a7)
	BSR	AllocateSignal
	MOVE.B	d0,d1
	MOVEQ	#0,d0
	MOVE.B	d1,d0
	MOVE.L	d0,d4
	MOVEQ	#-1,d1
	CMP.L	d0,d1
	ADDQ.L	#4,a7
	BNE.S	1$
	MOVEQ	#0,d0
	BRA.S	5$

1$:	MOVE.L	#MEMF_PUBLIC,-(a7)
	PEA	34
	BSR	AllocateMemory
	MOVE.L	d0,a2
	MOVE.L	a2,d5
	ADDQ.L	#8,a7
	BNE.S	2$
	MOVE.L	d4,-(a7)
	BSR	FreeSig
	MOVEQ	#0,d0
	ADDQ.L	#4,a7
	BRA.S	5$

2$:	MOVE.L	d3,10(a2)
	MOVE.B	d2,9(a2)
	MOVE.B	#4,8(a2)
	CLR.B	14(a2)
	MOVE.B	d4,15(a2)
	CLR.L	-(a7)
	BSR	FindAnyTask
	MOVE.L	d0,16(a2)
	TST.L	d3
	ADDQ.L	#4,a7
	BEQ.S	3$
	MOVE.L	a2,-(a7)
	BSR	AddMsgPort
	BRA.S	4$

3$:	PEA	20(a2)
	BSR	NewList
4$:	ADDQ.L	#4,a7
	MOVE.L	a2,d0
5$:	MOVEM.L	(a7)+,d2-d5/a2
	RTS

***********************************************

DeletePort:
L549	MOVE.L	a2,-(a7)
	MOVE.L	8(a7),a2
	TST.L	10(a2)
	BEQ.S	1$
	MOVE.L	a2,-(a7)
	BSR	RemovePort
	ADDQ.L	#4,a7
1$:	MOVE.B	#-1,8(a2)
	MOVEQ	#-1,d0
	MOVE.L	d0,20(a2)
	MOVEQ	#0,d0
	MOVE.B	15(a2),d0
	MOVE.L	d0,-(a7)
	BSR	FreeSig
	PEA	34
	MOVE.L	a2,-(a7)
	BSR	FreeMemory
	LEA	12(a7),a7
	MOVE.L	(a7)+,a2
	RTS

*********************************************

CreateExtIO:
L551	MOVEM.L	d2-d4,-(a7)
	MOVE.L	16(a7),d2
	MOVE.L	20(a7),d3
	TST.L	d2
	BNE.S	2$
1$:	MOVEQ	#0,d0
	BRA.S	4$

2$:	MOVE.L	#MEMF_PUBLIC,-(a7)
	MOVE.L	d3,-(a7)
	BSR	AllocateMemory
	MOVE.L	d0,a0
	MOVE.L	a0,d4
	ADDQ.L	#8,a7
	BNE.S	3$
	BRA.S	1$

3$:	MOVE.B	#5,8(a0)
	MOVE.W	d3,18(a0)
	MOVE.L	d2,14(a0)
	MOVE.L	a0,d0
4$:	MOVEM.L	(a7)+,d2-d4
	RTS

************************************************

DeleteExtIO:
L556	MOVE.L	4(a7),a0
	MOVE.L	a0,d0
	BNE.S	1$
	BRA.S	2$

1$:	MOVE.B	#-1,8(a0)
	MOVEQ	#-1,d0
	MOVE.L	d0,20(a0)
	MOVEQ	#-1,d0
	MOVE.L	d0,24(a0)
	MOVEQ	#0,d0
	MOVE.W	18(a0),d0
	MOVE.L	d0,-(a7)
	MOVE.L	a0,-(a7)
	BSR	FreeMemory
	ADDQ.L	#8,a7
2$:	RTS

	SECTION	segment1,DATA
seg1
SysBase	dc.l	0
DosBase	dc.l	0
WBMsg	dc.l	0
StdIn	dc.l	0
StdOut	dc.l	0
StdErr	dc.l	0
	dc.b	$22,$00,$0c,$41,$00,$00
	dc.b	$00

DosLib.	dc.b	'dos.library',0
Nil.	dc.b	'NIL:',0

IntLib.		dc.b	'intuition.library',0
GraphLib.	dc.b	'graphics.library',0,0
L246		dc.b	'FROM',0,0
L247		dc.b	'NAME',0,0
L248		dc.b	'MULTI',0
L249		dc.b	'NOVERIFY',0,0
L250		dc.b	'TO',0,0
L251		dc.b	'icon.library',0,0
L252		dc.b	'DiskCopy',0,0
L253		dc.b	'Not enough memory for MULTI',10,0,0
L254		dc.b	10,'Close other tools to increase memory for diskcopy.'
		dc.b	10,0,0
L255		dc.b	'Warning: This will take %ld swaps.',0,0
L256		dc.b	'Diskcopy will now take %ld swaps.',0
L257		dc.b	10,'%s',10,0,0
L258		dc.b	'( FROM disk ) in drive %s',0
L259		dc.b	'Place %s %s',0
L260		dc.b	'( TO disk ) in drive %s',0
L261		dc.b	'( FROM disk ) in drive %s',0
L262		dc.b	'Place %s %s',10,'Place %s %s',0
L263		dc.b	'read',0,0
L264		dc.b	'writ',0,0
L265		dc.b	'Press return for another copy, Control-D to exit',10,0
L266		dc.b	0,0
L267		dc.b	'Usage: %s [FROM] <disk> TO <disk> [NOVERIFY] [MULTI] '
		dc.b	'[NAME <name>]',10,0
L268		dc.b	'DiskCopy Finished           ',0,0
L269		dc.b	'DiskCopy Abandoned          ',0,0
L270		dc.b	10,'%s',10,0,0
L271		dc.b	'ver',39,0,0
L272		dc.b	'writ',0,0
L273		dc.b	'read',0,0
L274		dc.b	'( FROM disk ) in drive %s',0
L275		dc.b	'Place %s %s',0
L276		dc.b	'( TO disk ) in drive %s',0
L277		dc.b	'Place %s %s',0
L278		dc.b	10,'Cannot read %s',10
		dc.b	'Press C to continue or RETURN to abandon ',0
L279		dc.b	'Destination disk is write protected',0
L280		dc.b	'writ',0,0
L281		dc.b	'Error on DESTINATION disk',0
L282		dc.b	'Error on SOURCE disk',0,0
L283		dc.b	'Diskcopy Error      ',0,0
L284		dc.b	10,'%s',10,0,0
L285		dc.b	'Bad sector          ',0,0
L286		dc.b	'Cannot open device  ',0,0
L287		dc.b	'Not enough memory   ',0,0
L288		dc.b	'Cannot open AmigaDOS device ',0,0
L289		dc.b	'Write protected     ',0,0
L290		dc.b	'Disk changed (no disk)',0,0
L291		dc.b	'Seek error          ',0,0
L292		dc.b	'Disk size error     ',0,0
L293		dc.b	'Verify error        ',0,0
L294		dc.b	'Unspecified error   ',0,0
L295		dc.b	'%s',10,0
L296		dc.b	10,'*** BREAK',10,'DiskCopy canceled.  '
		dc.b	'Remember to insert original disk.',10,0
L297		dc.b	'%s',10,'Press RETURN to continue ',0,0
L298		dc.b	13,27,'[K',13,0
L299		dc.b	0,0
L300		dc.b	'%sing %ld, %ld to go  ',0,0
L301		dc.b	$9b,'0 p %s',13,$9b,' p',13,0,0
L302		dc.b	'DESTINATION disk',0,0
L303		dc.b	'SOURCE disk',0
L304		dc.w	0
L305		dc.w	0
NewWindow	dc.l	0
		dc.b	$01,$58,$00,$4e,$ff,$01
		dc.b	$00,$00,$00,$40,$00,$00
		dc.b	$10,$06
		dcb.b	8,$00
		dc.l	L307
		dcb.b	9,$00
		dc.b	$25,$00,$07,$03,$e8,$03
		dc.b	$e8,$00,$01
L307		dc.b	'DiskCopy 1.3.2a',$00
;;		dcb.b	1,$00

IntuitionBase	dc.l	0
GraphicsBase	dc.l	0
IconBase	dc.l	0
CylBufTblPtr	dc.l	0		;ptr to table of cylinder buf ptrs
FileInfoBuf	dc.l	0
InfoBuffer	dc.l	0		;for device infodata
DataBuffer	dc.l	0		;main data buffer ptr
Window		dc.l	0		;ptr to window

CylsPerSwap	dc.l	1		;cyls to process before changing drvs
SrceNamePtr	dc.l	SrceNameBuf
DestNamePtr	dc.l	DestNameBuf
NamePtr		dc.l	0		;ptr to name keyword string
SrceFlag	dc.w	0		;1=got source IOB
DestFlag	dc.w	0		;1=got dest IOB
OneDrvFlg	dc.w	0		;1=one drive, 0=two drives
DoneFlag	dc.w	0		;1=successfull diskcopy
L324		dc.w	0
L325		dc.w	1
ModeFlag	dc.w	0
VerifyFlg	dc.w	1		;1=verify, 0=don't
L328		dc.b	$00,$01,$1c,$1d,$1e,$60
		dc.b	$ca,$00
L329		dc.b	$00,$67,$d6,$e2,$da,$ca
TrkStatusBuf	dcb.b	80,$00
TxtBuf1		dcb.b	40,$00
L332		dcb.b	36,$00
L333		dcb.b	36,$00
L334		dcb.b	36,$00
L335		dcb.b	36,$00
SrceNameBuf	dcb.b	40,$00
DestNameBuf	dcb.b	40,$00
SrceCyls	dc.l	0		;source disk size in cylinders
RootBlkNbr	dc.l	0		;root dir block number
Buffersize	dc.l	0		;size of main data buffer
BlockBufPtr	dc.l	0		;ptr to 512-byte buffer
L342		dcb.b	24,$00
SrceIOB		dc.l	0		;source iob ptr
DestIOB		dc.l	0		;dest iob ptr
ActiveIOB	dc.l	0		;active IOB for read/write
L346		dc.l	0
L347		dc.l	0
LocalPort	dc.l	0		;local msg port
CylinderCnt	dc.l	0		;count of cyls in this group
CylsCompleted	dc.l	0		;count of cyls completed
MaxCyls		dc.l	0		;max number of cylinders to process
KeyArrayPtr	dc.l	0
SrceDevProc	dc.l	0
DestDevProc	dc.l	0
SrceFSSM	dc.l	0		;APTR to filesystem startup msg
DestFSSM	dc.l	0		;APTR to filesystem startup msg
SrceDevList	dc.l	0
DestDevList	dc.l	0
SrceEnviron	dc.l	0		;source drive "environment" ptr
DestEnviron	dc.l	0,0		;dest drive "environment" ptr
RWMode		dc.w	0		;mode flag 2=read, 11=write, 999=ver
L362		dc.w	0
L363		dc.w	0		;input char buffer

L418	dc.b	'%s:',0
L419	dc.l	L420
	dc.b	$00,$08,$00,$01
L420	dc.b	'topaz.font',0,0
L421	dc.b	$03,$01,$00,$00,$00,$06
	dc.b	$00,$03
	dc.l	L419
	dc.l	L422
	dc.b	$00,$00,$00,$00
L422	dc.b	'Cancel',0,0
L423	dc.b	$03,$01,$00,$00,$00,$06
	dc.b	$00,$03
	dc.l	L419
	dc.l	L424
	dc.b	$00,$00,$00,$00
L424	dc.b	'Continue',0,0
L425	dc.b	$00,$01,$00,$00,$00,$3c
	dc.b	$00,$09
	dc.l	L419
	dc.l	L427
	dc.b	$00,$00,$00,$00
L426	dc.b	$00,$01,$00,$00,$00,$44
	dc.b	$00,$13
	dc.l	L419
	dc.l	L428
	dc.l	L425
L427	dc.b	'The destination disk',0,0
L428	dc.b	'is Write Protected',0,0
L429	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$06
	dc.l	L419
	dc.l	L433
	dc.b	$00,$00,$00,$00
L430	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$0e
	dc.l	L419
	dc.l	L434
	dc.l	L429
L431	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$16
	dc.l	L419
	dc.l	L435
	dc.l	L430
L432	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$1e
	dc.l	L419
	dc.l	L436
	dc.l	L431
L433	dc.b	'Another process has destination',0
L434	dc.b	'disk open.',0,0
L435	dc.b	'Do you really want me',0
L436	dc.b	'to write all over it?',0
L437	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$06
	dc.l	L419
	dc.l	L441
	dc.b	$00,$00,$00,$00
L438	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$0e
	dc.l	L419
	dc.l	L442
	dc.l	L437
L439	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$16
	dc.l	L419
	dc.l	L443
	dc.l	L438
L440	dc.b	$00,$01,$00,$00,$00,$0f
	dc.b	$00,$1e
	dc.l	L419
	dc.l	L444
	dc.l	L439
L441	dc.b	'To duplicate a disk',0
L442	dc.b	'Select its icon and choose',0,0
L443	dc.b	'Duplicate from the',0,0
L444	dc.b	'Workbench menu',0,0
L445	dc.b	$00,$01,$00,$00,$00,$16
	dc.b	$00,$09
	dc.l	L419
	dc.l	L448
	dc.b	$00,$00,$00,$00
L446	dc.b	$00,$01,$00,$00,$00,$0a
	dc.b	$00,$13
	dc.l	L419
	dc.l	L449
	dc.l	L445
L447	dc.b	$00,$01,$00,$00,$00,$46
	dc.b	$00,$1d
	dc.l	L450
	dc.l	L446
	dc.b	$00,$00,$00,$00
L448	dc.b	'Not enough memory to DiskCopy.',0,0
L449	dc.b	'To copy the disk, close other tools,',0,0
L450	dc.b	'then select Continue.',0
L451	dc.b	$00,$01,$00,$00,$00,$16
	dc.b	$00,$09
	dc.l	L419
	dc.l	TxtBuf1
	dc.b	$00,$00,$00,$00
L452	dc.b	$00,$01,$00,$00,$00,$16
	dc.b	$00,$13
	dc.l	L419
	dc.l	L454
	dc.l	L451
L453	dc.b	$00,$01,$00,$00,$00,$16
	dc.b	$00,$1d
	dc.l	L419
	dc.l	L455
	dc.l	L452
L454	dc.b	'You need fewer disk SWAPs when',0,0
L455	dc.b	'all other tools are closed',0,0
L456	dc.b	$00,$01,$00,$00,$00,$0c
	dc.b	$00,$0a
	dc.l	L419
	dc.l	L459
	dc.b	$00,$00,$00,$00
L457	dc.b	$00,$01,$00,$00,$00,$36
	dc.b	$00,$0a
	dc.l	L419
	dc.l	L335
	dc.l	L456
L458	dc.b	$00,$01,$00,$00,$00,$14
	dc.b	$00,$14
	dc.l	L419
	dc.l	L332
	dc.l	L457
L459	dc.b	$50,$75,$74,$00
L460	dc.b	$02,$01,$00,$00,$00,$0c
	dc.b	$00,$0a
	dc.l	L419
	dc.l	L463
	dc.b	$00,$00,$00,$00
L461	dc.b	$02,$01,$00,$00,$00,$36
	dc.b	$00,$0a
	dc.l	L419
	dc.l	L334
	dc.l	L460
L462	dc.b	$02,$01,$00,$00,$00,$14
	dc.b	$00,$14
	dc.l	L419
	dc.l	L332
	dc.l	L461
L463	dc.b	$50,$75,$74,$00
L464	dc.b	$02,$01,$00,$00,$00,$0c
	dc.b	$00,$06
	dc.l	L419
	dc.l	L470
	dc.b	$00,$00,$00,$00
L465	dc.b	$02,$01,$00,$00,$00,$36
	dc.b	$00,$06
	dc.l	L419
	dc.l	L334
	dc.l	L464
L466	dc.b	$02,$01,$00,$00,$00,$14
	dc.b	$00,$0e
	dc.l	L419
	dc.l	L332
	dc.l	L465
L467	dc.b	$02,$01,$00,$00,$00,$0c
	dc.b	$00,$16
	dc.l	L419
	dc.l	L471
	dc.l	L466
L468	dc.b	$02,$01,$00,$00,$00,$36
	dc.b	$00,$16
	dc.l	L419
	dc.l	L335
	dc.l	L467
L469	dc.b	$02,$01,$00,$00,$00,$14
	dc.b	$00,$1e
	dc.l	L419
	dc.l	L333
	dc.l	L468
L470	dc.b	$50,$75,$74,$00
L471	dc.b	$50,$75,$74,$00
L472	dc.b	$02,$01,$00,$00,$00,$0c
	dc.b	$00,$14
	dc.l	L419
	dc.l	L334
	dc.b	$00,$00,$00,$00
L473	dc.b	$02,$01,$00,$00,$00,$0c
	dc.b	$00,$0a
	dc.l	L419
	dc.l	L474
	dc.l	L472
L474	dc.b	'Cannot read',0
L475	dc.b	$00,$01,$00,$00,$00,$0a
	dc.b	$00,$10,$00,$00,$00,$00
	dc.l	L476
	dc.b	$00,$00,$00,$00
L476	dc.b	'Failed to open icon.library',0
L477	dc.b	$00,$01,$00,$00,$00,$0a
	dc.b	$00,$06,$00,$00,$00,$00
	dc.l	L478
	dc.l	L475
L478	dc.b	'Diskcopy:',0
	dc.b	$00,$00

	END

