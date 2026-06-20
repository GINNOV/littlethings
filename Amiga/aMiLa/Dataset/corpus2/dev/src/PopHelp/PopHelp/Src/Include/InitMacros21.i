; Set some memory based variables
; $VER: Include v1.00 / PH v2.58
; (C) Mika Lundell
;
; This source code is part of the PopHelp package.
; Freeware, use it as you like.

_InitVars	macro
		bset	#PointerPtr,CTRL_2(a5)
		bset	#AutoSize,CTRL_4(a5)
		addq.b	#1,VecCheck(a5)
		move.l	#64*1024,BufSize(a5)
		addq.b	#1,FPen(a5)
		addq.b	#2,BPen(a5)
		move.l	#64,SetBufSize(a5)
		move.l	#$36340000,BufSizeBuf(a5)	; '64',0,0
		move.l	#'DFx:',DriveID(a5)

		lea	_StringBuf1(a5),a0
		move.l	a0,StringBuf1(a5)
		lea	_StringBuf2(a5),a0
		move.l	a0,StringBuf2(a5)
		lea	_StringUnDoBuf(a5),a0
		move.l	a0,StringUnDoBuf(a5)
		lea	_TxtBuffer(a5),a0
		move.l	a0,TxtBuffer(a5)
		lea	_Buf1(a5),a0
		move.l	a0,Buf1(a5)
		move.l	a0,Err_pad(a5)
		lea	_JokerBuf(a5),a0
		move.l	a0,JokerBuf(a5)
		lea	_NoJokerPath(a5),a0
		move.l	a0,NoJokerPath(a5)
		lea	_DestBuf(a5),a0
		move.l	a0,DestBuf(a5)
		lea	_fastBuf(a5),a0
		move.l	a0,fastBuf(a5)
		lea	_FirstPathBuf(a5),a0
		move.l	a0,FirstPathBuf(a5)
		lea	_DWinTBuf(a5),a0
		move.l	a0,DWinTBuf(a5)
		lea	_FirstTitleBuf(a5),a0
		move.l	a0,FirstTitleBuf(a5)
		lea	_UseOnlyNowBuf(a5),a0
		move.l	a0,UseOnlyNowBuf(a5)

		lea	_FIB(a5),a0
		move.l	a0,FIB(a5)
		lea	_FIB2(a5),a0
		move.l	a0,FIB2(a5)
		lea	_DirFIB(a5),a0
		move.l	a0,DirFIB(a5)
		lea	_DirBufs(a5),a0
		move.l	a0,DirBufs(a5)
		lea	_FileBufs(a5),a0
		move.l	a0,FileBufs(a5)
		lea	_FirstDirBufs(a5),a0
		move.l	a0,FirstDirBufs(a5)
		lea	_FirstFileBufs(a5),a0
		move.l	a0,FirstFileBufs(a5)
		endm

_InitGfxVars	macro
		move.l	d0,a2
		lea	ChangedGfx(pc),a0
		move.l	a2,a1
		move.l	#MoveGfx_SIZE,d0
		jsr	CopyMemQuick(a6)

		lea	_gfx_ArrowPtr(a2),a0
		move.l	a0,ArrowPtr(a5)
		lea	_gfx_BusyPtr(a2),a0
		move.l	a0,BusyPtr(a5)
		lea	_gfx_DwnData(a2),a0
		move.l	a0,DwnData(a5)
		lea	_gfx_UpData(a2),a0
		move.l	a0,UpData(a5)
		lea	_gfx_PDwnData(a2),a0
		move.l	a0,PDwnData(a5)
		lea	_gfx_PUpData(a2),a0
		move.l	a0,PUpData(a5)
		lea	_gfx_BotData(a2),a0
		move.l	a0,BotData(a5)
		lea	_gfx_TopData(a2),a0
		move.l	a0,TopData(a5)
		lea	_gfx_OffPtr(a2),a0
		move.l	a0,OffPtr(a5)
		endm

_InitIntStuff	macro
		move.l	FirstGadget(a5),a0
		move.l	a0,StringGadget1(a5)
		move.l	gg_NextGadget(a0),a0
		move.l	a0,StringGadget2(a5)
		move.l	FirstIGadget(a5),DownArrow1(a5)
		move.l	FirstIGadget2(a5),DownArrow2(a5)
		moveq	#2,d0
		bsr	FindGadStruct_1
		move.l	a0,FirstDevGadget(a5)
		moveq	#6,d0
		bsr	FindGadStruct_1
		move.l	a0,FirstOptGadget(a5)

		lea	_nw_Struct(a5),a2
		addq.w	#1,nw_TopEdge(a2)
		move.l	#$0280000d,nw_Width(a2)		; 640, 13
		addq.b	#2,nw_DetailPen(a2)
		addq.b	#1,nw_BlockPen(a2)
		move.l	#IDCMP,nw_IDCMPFlags(a2)
		move.l	#WFLAGS,nw_Flags(a2)
		move.l	StringGadget1(a5),nw_FirstGadget(a2)
		move.l	#$02800008,nw_MinWidth(a2)	; 640, 8
		move.l	#$028000c8,nw_MaxWidth(a2)	; 640, 200
		addq.w	#WBENCHSCREEN,nw_Type(a2)
		endm

_InitIntStuff2	macro
		move.w	#199,nw_Height(a2)
		subq.b	#2,nw_DetailPen(a2)
		move.l	#IDCMP2,nw_IDCMPFlags(a2)
		move.l	DownArrow1(a5),nw_FirstGadget(a2)
		move.l	a2,BetaWindow(a5)

		lea	_ns_Struct(a5),a2
		move.w	#CUSTOMSCREEN!SCREENQUIET!SCREENBEHIND,ns_Type(a2)
		move.l	a2,ShowScr(a5)
		endm
