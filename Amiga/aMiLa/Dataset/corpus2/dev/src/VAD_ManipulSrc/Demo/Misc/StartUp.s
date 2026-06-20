; Startup code by Noe

_LVOFindTask	=	-294
_LVOSetTaskPri	=	-300
_LVOOpenLibrary	=	-552
_LVOCloseLibrary	=	-414
_LVOAllocEntry	=	-222
_LVOFreeEntry	=	-228
_LVOAllocMem	=	-198
_LVOFreeMem	=	-210
_LVOAvailMem	=	-216

MEMF_PUBLIC	=	1
MEMF_CHIP	=	2
MEMF_CLEAR	=	$10000
MEMF_LARGES	=	$20000

_LVOLoadView	=	-222
_LVOWaitTOF	=	-270
_LVOOwnBlitter	=	-456
_LVODisownBlitter	=	-462

gb_ActiView	=	34
gb_copinit	=	38

CUSTOM		=	$dff000
NULL		=	0

;		INCLUDE	DEMO:Misc/Custom.i

StartUp		movea.l	4.w,a6
		suba.l	a1,a1
		jsr	_LVOFindTask(a6)

		movea.l	d0,a1
		moveq	#127,d0
		jsr	_LVOSetTaskPri(a6)

		movea.l	4.w,a6
		moveq	#0,d0
		lea.l	GfxName(pc),a1
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,_GfxBase
		beq.b	s_Fail

		movea.l	d0,a6
		move.l	gb_ActiView(a6),wbview

	IFEQ	DEBUG

		suba.l	a1,a1
		jsr	_LVOLoadView(a6)
		jsr	_LVOWaitTOF(a6)
		jsr	_LVOWaitTOF(a6)

	ENDC

		bsr.b	Code
		move.l	d0,d0temp

		movea.l	_GfxBase(pc),a6

		movea.l	wbview(pc),a1
		jsr	_LVOLoadView(a6)
		jsr	_LVOWaitTOF(a6)
		jsr	_LVOWaitTOF(a6)

		move.l	gb_copinit(a6),cop1lc+CUSTOM

		movea.l	4.w,a6
		move.l	_GfxBase(pc),a1
		jsr	_LVOCloseLibrary(a6)

		move.l	d0temp(pc),d0
		rts

s_Fail		moveq	#-1,d0
		rts

_GfxBase	DC.L	0
wbview		DC.L	0
d0temp		DC.L	0
GfxName		DC.B	"graphics.library",0
		CNOP	0,2

Code		; User code
