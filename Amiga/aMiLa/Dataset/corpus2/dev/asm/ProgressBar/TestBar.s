	Section	TestWindow,CODE
	Opt	!

	IncDir	Include:
	Include	mysystem.i

WindowX	Equ	25
WindowY	Equ	25
WindowWidth	Equ	160
WindowHeight	Equ	60

BarType	Equ	1	;0 is normal
			;1 is bevel

;-----------------------------------------------------------------------
Start:	Move.L	$4.w,_EXECBase

	Lea	(INTUILibrary,PC),A1
	Moveq	#0,D0
	CALL	OpenLibrary,EXEC
	Move.L	D0,_INTUIBase
	Beq	CloseDown

	Lea	(GRAPHLibrary,PC),A1
	Moveq	#0,D0
	CALL	OpenLibrary,EXEC
	Move.L	D0,_GRAPHBase
	Beq	CloseDown
	
	Lea	(TestWindow,PC),A0
	Sub.L	A1,A1
	CALL	OpenWindowTagList,INTUI
	Move.L	D0,_WindowHandle
	Beq	CloseDown

	Move.L	D0,A0		;window

	Moveq	#10,D0		;bar x
	Moveq	#10,D1		;bar y
	Move.L	#WindowWidth-30,D2	;bar width
	Move.L	#WindowHeight-40,D3	;bar height

	Bsr	BuildBar

;-----------------------------------------------------------------------
MainLoop:	Tst.B	D5
	Beq.S	CloseDown

	Bsr	UpdateBar

	Move.L	(_WindowHandle,PC),A3
	Move.L	(wd_UserPort,A3),A0
	CALL	WaitPort,EXEC

.MsgLoop	Move.L	(wd_UserPort,A3),A0
	CALL	GetMsg
	Tst.L	D0
	Beq.S	MainLoop

	Move.L	D0,A1
	Move.L	(im_Class,A1),D4	;class

	CALL	ReplyMsg

	Cmp.L	#CLOSEWINDOW,D4		;type of message
	Sne.B	D5
	Bra.S	.MsgLoop

;-----------------------------------------------------------------------
CloseDown:	Move.L	(_WindowHandle,PC),A0
	Cmp.L	#0,A0
	Beq.S	.NoWindow
	CALL	CloseWindow,INTUI
.NoWindow
	Move.L	(_GRAPHBase,PC),A1
	Cmp.L	#0,A1
	Beq.S	.NoGraph
	CALL	CloseLibrary,EXEC
.NoGraph
	Move.L	(_INTUIBase,PC),A1
	Cmp.L	#0,A1
	Beq.S	.NoIntui
	CALL	CloseLibrary,EXEC
.NoIntui
	Clr.L	D0
	Rts

;-----------------------------------------------------------------------
	IFD	BarType
	Include	BevelBar.s
	ELSE
	Include	NormalBar.s
	ENDC

;-----------------------------------------------------------------------
WindowTitle:	Dc.B	'Test Window',0
INTUILibrary:	INTUITIONNAME
GRAPHLibrary:	GRAPHICSNAME
	EVEN

TestWindow:	Dc.W	WindowX
	Dc.W	WindowY
	Dc.W	WindowWidth
	Dc.W	WindowHeight
	Dc.B	-1
	Dc.B	-1
	Dc.L	IDCMP_CLOSEWINDOW|IDCMP_MOUSEBUTTONS
	Dc.L	WFLG_CLOSEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_ACTIVATE|WFLG_RMBTRAP|WFLG_NOCAREREFRESH|WFLG_GIMMEZEROZERO
	Dc.L	0
	Dc.L	0
	Dc.L	WindowTitle
	Dc.L	0
	Dc.L	0
	Dc.W	0
	Dc.W	0
	Dc.W	0
	Dc.W	0
	Dc.W	WBENCHSCREEN

_EXECBase:	Dc.L	0
_INTUIBase:	Dc.L	0
_GRAPHBase:	Dc.L	0
_WindowHandle:	Dc.L	0
