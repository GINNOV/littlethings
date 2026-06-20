ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;WarpOS-DemoStartup
;Revdate: 28.3.03
;Ostyl of Mankind!

        INCDIR  INCLUDES:

	INCLUDE	EXEC/EXECBASE.i
        INCLUDE DOS/DOS.i
        INCLUDE LIBRARIES/DOSEXTENS.i
        INCLUDE	DOS/RDARGS.i
        INCLUDE	WORKBENCH/STARTUP.i
        INCLUDE	WORKBENCH/WORKBENCH.i
     
        INCLUDE POWERPC/POWERPC.i
        INCLUDE POWERPC/TASKSPPC.i
	INCLUDE	POWERPC/GRAPHICSPPC.i
	INCLUDE	GRAPHICS/MODEID.i

        INCLUDE MACROS/MACROS.i
        INCLUDE MACROS/POWERPC.i
        INCLUDE MISC/DEVPACMACROS.i

	XREF	Messg

	;---- LibsVer

EXEver  EQU     39
DOSver  EQU     39
ICOver	EQU	39
REQver	EQU	0
INTver	EQU	39
GADver	EQU	39
UTLver	EQU	39
GFXver  EQU     39
PPCver  EQU     15
DBPver	EQU	0	

	;---- Find MyTask
	
	Move.L  4.w,a6
        Sub.L   a1,a1
        Jsr     _LVOFindTask(a6)
        Move.L  d0,MyTask68k

	;---- Teste le type de démarage

        Move.L  MyTask68k(pc),a4
        Tst.L   pr_CLI(a4)
        Beq.B   WB

	Lea     Req(pc),a1
        Moveq   #REQver,d0
	Jsr	OpenLibrary
        Move.L  d0,_ReqBase
        Beq.B	Exit

	Lea	FromWB(pc),a0
	Jsr	Messg

Exit	Moveq   #0,d0
        Rts

	;---- WB message handler

WB      Move.L  4.w,a6
        Lea     pr_MsgPort(a4),a0       
        Jsr     _LVOWaitPort(a6)                

        Move.L  4.w,a6
        Lea     pr_MsgPort(a4),a0       
        Jsr     _LVOGetMsg(a6)
        Move.L  d0,WbMsg

	Bsr.B	Start

WBExit:	Move.L  4.w,a6
        Move.L  WbMsg(pc),a1
        Jsr     _LVOReplyMsg(a6)        
	Moveq   #0,d0
        Rts

	;----

	Dc.B	'WOS Demo-Startup coded by Ostyl of Mankind -',0
	Even

Start:	;---- Ouvre les libraries Dos, Req et Icon

	Lea     Dos(pc),a1
        Moveq   #DOSver,d0
	Jsr	OpenLibrary
        Move.L  d0,_DosBase
        Beq.W  	End

	Lea	Icon(pc),a1
	Moveq	#ICOver,d0
	Jsr	OpenLibrary
	Move.L	d0,_IconBase
        Beq.W	End

	Lea     Req(pc),a1
        Moveq   #REQver,d0
	Jsr	OpenLibrary
        Move.L  d0,_ReqBase
        Beq.W	End

	;---- ToolTypes
	
	Move.L	_DosBase(pc),a6
	Move.L	WbMsg(pc),a0
	Move.L	sm_ArgList(a0),a0
	Move.L	wa_Lock(a0),d1
	Jsr	_LVOCurrentDir(a6)

	Move.L	_IconBase(pc),a6
	Move.L	WbMsg(pc),a0
	Move.L	sm_ArgList(a0),a0
	Move.L	wa_Name(a0),a0
	Jsr	_LVOGetDiskObject(a6)
	Move.L	d0,MyDiskObject

	;---- Detection du FPU
             
	Move.L	_IconBase(pc),a6
	Move.L	MyDiskObject(pc),a0
	Move.L	do_ToolTypes(a0),a0
	Lea	FPUType(pc),a1
	Jsr	_LVOFindToolType(a6)
	Tst.L	d0
	Bne.B	OpenLibs

	Move.L	4.w,a6
	Move	AttnFlags(a6),d0
	Btst	#7,d0 			;68060
	Bne.B	OpenLibs
	Btst	#AFB_FPU40,d0
	Bne.B	OpenLibs

	Lea	NoFPU(pc),a0
	Jsr	Messg
	Bra.W	Leave

	;---- Ouvre les librairies

OpenLibs
	Lea     PowerPC(pc),a1
        Moveq   #PPCver,d0
	Bsr.W	OpenLibrary
        Move.L  d0,_PowerPCBase
	Beq.W   Leave

	Lea	Intuition(pc),a1
	Moveq	#INTver,d0
	Bsr.W	OpenLibrary
	Move.L	d0,_IntuiBase
        Beq.W   Leave

	Lea     Graphics(pc),a1
        Moveq   #GFXver,d0
	Bsr.W	OpenLibrary
        Move.L  d0,_GfxBase
        Beq.W   Leave

	Lea	GadTools(pc),a1
	Moveq	#GADver,d0
	Bsr.W	OpenLibrary
	Move.L	d0,_GadBase
        Beq.W   Leave

	Lea	Utility(pc),a1
	Moveq	#UTLver,d0
	Bsr.W	OpenLibrary
	Move.L	d0,_UtilBase
        Beq.W   Leave

	;---- StartupWindow
	
	XREF	StartWindow
		
	Move.L	_IconBase(pc),a6
	Move.L	MyDiskObject(pc),a0
	Move.L	do_ToolTypes(a0),a0
	Lea	WindowType(pc),a1
	Jsr	_LVOFindToolType(a6)
	Tst.L	d0
	Beq.B	NoWin

	Jsr	StartWindow

NoWin:	;---- Ouvre un écran

	XREF	OpenCkScreen

	Move.L	_IconBase(pc),a6
	Move.L	MyDiskObject(pc),a0
	Move.L	do_ToolTypes(a0),a0
	Lea	ScreenType(pc),a1
	Jsr	_LVOFindToolType(a6)
	Move.L	d0,ScreenValues
	Beq.W	Main

	;----

	Moveq	#3-1,d7
	Move.L	ScreenValues(pc),a4
	Lea	ScreenParam(pc),a5
Loop1:	Move.L	_DosBase(pc),a6
	Move.L	a4,d1
	Move.L	a5,d2
	Jsr	_LVOStrToLong(a6)
	Lea	1(a4,d0.W),a4
	Lea	4(a5),a5
	Dbf	d7,Loop1

	Moveq	#6-1,d7
	Lea	ResolValues(pc),a5
Loop2	Move.L	_IconBase(pc),a6
	Move.L	ScreenValues(pc),a0
	Move.L	a5,a1
	Jsr	_LVOMatchToolValue(a6)
	Lea	6(a5),a5
	Tst.L	d0
	Dbne	d7,Loop2

	Lea	MyScreen(pc),a0
	Lea	ScreenTags(pc),a1
	Lea	ResolKey(pc),a2
	Move.L	(a2,d7.W*4),4(a1)
	Lea	ScreenParam(pc),a2
	Move	2(a2),ns_Width(a0)
	Move	6(a2),ns_Height(a0)
	Move	10(a2),ns_Depth(a0)
	Jsr	OpenCkScreen
	Move.L	d0,_CkScreen
	Beq.B	Leave

	;---- Efface la souris

	XREF	ClearMouse

	Move.L	_IconBase(pc),a6
	Move.L	MyDiskObject(pc),a0
	Move.L	do_ToolTypes(a0),a0
	Lea	ClrMouseType(pc),a1
	Jsr	_LVOFindToolType(a6)
	Tst.L	d0
	Beq.B	Main

	Move.L	_CkScreen(pc),a0
	Jsr	ClearMouse

Main:	;---- Main()
	
	XREF	_Main
	Move.L	_CkScreen(pc),a1
	Jsr	_Main

	;---- Ferme l'écran

	XREF	CloseCkScreen

Leave:	Move.L	_CkScreen(pc),a0
	Jsr	CloseCkScreen

	;---- Libére le DiskObject

	Move.L	_IconBase(pc),a6
	Move.L	MyDiskObject(pc),a0
	Jsr	_LVOFreeDiskObject(a6)

End:	Rts

	;---- Custom OpenLibray

	; a1 = libname
	; d0 = libver 

OpenLibrary
	Movem.L	d0/a1,-(sp)
	Move.L	4.w,a6
	Lea	LibList(a6),a0
	Jsr	_LVOFindName(a6)
	Tst.L	d0
	Beq.B	OpenLib
	Movem.L	(sp)+,d1/d2
	Move.L	d0,a6
	Cmp	LIB_VERSION(a6),d1
	Ble.B	Done
	Moveq	#0,d0
	Bra.B	Done
OpenLib	Movem.L	(sp)+,d0/a1
	Jsr	_LVOOpenLibrary(a6)
Done	Tst.L	d0
	Beq.B	LibErr
	Rts

LibErr:	Lea	LibErrTxt(pc),a0
	Jsr	Messg
	Moveq	#0,d0
	Rts

;---- TASK ---------------------------------------------

		XDEF    MyTask68k
		XDEF    MyTaskPPC
        
MyTask68k       Ds.L    1
MyTaskPPC       Ds.L    1       
WbMsg           Ds.L    1

FindTaskPPC_PP  Ds.B    PP_SIZE

		EVEN

;---- LIBRARIES ----------------------------------------

        	XDEF    _DosBase
		XDEF	_ReqBase
        	XDEF	_IntuiBase
        	XDEF	_GadBase
		XDEF	_UtilBase
		XDEF    _GfxBase
		XDEF    _PowerPCBase
	        
Dos             Dc.B    'dos.library',0
Req		Dc.B    'reqtools.library',0
Icon            Dc.B    'icon.library',0
Intuition	Dc.B	'intuition.library',0
GadTools	Dc.B	'gadtools.library',0
Utility		Dc.B	'utility.library',0
Graphics        Dc.B    'graphics.library',0
PowerPC         Dc.B    'powerpc.library',0

                EVEN

_DosBase        Ds.L    1
_ReqBase	Ds.L	1
_IconBase	Ds.L	1
_IntuiBase	Ds.L	1
_GadBase	Ds.L	1
_UtilBase	Ds.L	1
_GfxBase        Ds.L    1
_PowerPCBase    Ds.L    1
		
_CkScreen	Dc.L	0

MyScreen	Ds.B	ns_SIZEOF	
		EVEN

ScreenTags	Dc.L	SA_DisplayID
Tag_ModeId	Ds.L	1
		Dc.L	TAG_DONE

;---- MESSAGES ----------------------------------------

FromWB		Dc.B	"Launch from WB icon !",0
		EVEN
LibErrTxt	Dc.B	"Unable to open library",0
		EVEN
NoFPU		Dc.B	"This program requires",10
		Dc.B	" a math coprocessor",0
		EVEN

;---- TOOLTYPES ----------------------------------------

ArgsPTR		Ds.L	1

ScreenType:	Dc.B	'SCREEN',0
WindowType:	Dc.B	'CREDITS',0
ClrMouseType:	Dc.B	'MOUSEHIDE',0
FPUType:	Dc.B	'NOFPU',0
ResolValues:	Dc.B	'LORES',0,'HIRES',0,'SHRES',0
		Dc.B	'LOHAM',0,'HIHAM',0,'SHHAM',0

		Even

ResolKey	Dc.L	SUPER_KEY!HAM_KEY,HIRES_KEY!HAM_KEY,LORES_KEY!HAM_KEY
		Dc.L	SUPER_KEY,HIRES_KEY,LORES_KEY
ScreenValues:	Ds.L	1

MyDiskObject	Ds.L	1
ScreenParam	Ds.L	3
ChunkyParam	Ds.L	2
