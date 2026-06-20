
* This is my standard Intuition.Library header file.
* It has been ripped off from the Genam one &
* altered to suit my prejudices. If you don't like
* it, then tough shit.

* Library offsets from int_base(A6)

OpenIntuition	equ	-30
Intuition	equ	-36
AddGadget	equ	-42
ClearDMRequest	equ	-48
ClearMenuStrip	equ	-54
ClearPointer	equ	-60
CloseScreen	equ	-66
CloseWindow	equ	-72
CloseWorkBench	equ	-78
CurrentTime	equ	-84
DisplayAlert	equ	-90
DisplayBeep	equ	-96
DoubleClick	equ	-102
DrawBorder	equ	-108
DrawImage	equ	-114
EndRequest	equ	-120
GetDefPrefs	equ	-126
GetPrefs		equ	-132
InitRequester	equ	-138
ItemAddress	equ	-144
ModifyIDCMP	equ	-150
ModifyProp	equ	-156
MoveScreen	equ	-162
MoveWindow	equ	-168
OffGadget	equ	-174
OffMenu		equ	-180
OnGadget		equ	-186
OnMenu		equ	-192
OpenScreen	equ	-198
OpenWindow	equ	-204
OpenWorkBench	equ	-210
PrintIText	equ	-216
RefreshGadgets	equ	-222
RemoveGadget	equ	-228
ReportMouse	equ	-234
Request		equ	-240
ScreenToBack	equ	-246
ScreenToFront	equ	-252
SetDMRequest	equ	-258
SetMenuStrip	equ	-264
SetPointer	equ	-270
SetWindowTitles	equ	-276
ShowTitle	equ	-282
SizeWindow	equ	-288
ViewAddress	equ	-294
ViewPortAddress	equ	-300
WindowToBack	equ	-306
WindowToFront	equ	-312
WindowLimits	equ	-318
SetPrefs		equ	-324
IntuiTextLength	equ	-330
WBenchToBack	equ	-336
WBenchToFront	equ	-342
AutoRequest	equ	-348
BeginRefresh	equ	-354
BuildSysRequest	equ	-360
EndRefresh	equ	-366
FreeSysRequest	equ	-372
MakeScreen	equ	-378
RemakeDisplay	equ	-384
RethinkDisplay	equ	-390
AllocRemember	equ	-396
AlohaWorkbench	equ	-402
FreeRemember	equ	-408
LockIBase	equ	-414
UnlockIBase	equ	-420

* new 1.2 routines

GetScreenData	equ	-426
RefreshGList	equ	-432
AddGList		equ	-438
RemoveGList	equ	-444
ActivateWindow	equ	-450

RefreshWindowFrame	equ	-456

ActivateGadget	equ	-462
NewModifyProp	equ	-468

* INTUITION DEFINITIONS

* Screen Definitions

SCREENTYPE	equ	$000F
WBENCHSCREEN	equ	$0001
CUSTOMSCREEN	equ	$000F
SHOWTITLE	equ	$0010
BEEPING		equ	$0020
CUSTOMBITMAP	equ	$0040
SCREENBEHIND	equ	$0080	1.2
SCREENQUIET	equ	$0100	1.2

STDSCREENHEIGHT	equ	-1	1.2

* Screen view modes flags

V_PFBA		EQU	$40	;don't yet know about this
V_DUALPF		EQU	$400	;divide screen into border char area
V_HIRES		EQU	$8000	;turn on 640x400 mode
V_LACE		EQU	4	;turn on interlace mode
V_HAM		EQU	$800	;turn on hold & modify
V_SPRITES	EQU	$4000	;allow sprites to be used
GENLOCK_VIDEO	EQU	2	;not sure about these yet
GENLOCK_AUDIO	EQU	$100
VP_HIDE		EQU	$2000


FILENAME_SIZE	equ	30

POINTERSIZE	equ	(1+16+1)*2

TOPAZ_EIGHTY	equ	8  
TOPAZ_SIXTY	equ	9


LACEWB		equ	$01



WBENCHOPEN	equ	$0001
WBENCHCLOSE	equ	$0002

* IDCMP Flags For Windows

SIZEVERIFY	equ	$00000001
NEWSIZE		equ	$00000002
REFRESHWINDOW	equ	$00000004
MOUSEBUTTONS	equ	$00000008
MOUSEMOVE	equ	$00000010
GADGETDOWN	equ	$00000020
GADGETUP		equ	$00000040
REQSET		equ	$00000080
MENUPICK		equ	$00000100
CLOSEWINDOW	equ	$00000200
RAWKEY		equ	$00000400
REQVERIFY	equ	$00000800
REQCLEAR		equ	$00001000
MENUVERIFY	equ	$00002000
NEWPREFS		equ	$00004000
DISKINSERTED	equ	$00008000
DISKREMOVED	equ	$00010000
WBENCHMESSAGE	equ	$00020000
ACTIVEWINDOW	equ	$00040000
INACTIVEWINDOW	equ	$00080000
DELTAMOVE	equ	$00100000
VANILLAKEY	equ	$00200000
INTUITICKS	equ	$00400000

LONELYMESSAGE	equ	$80000000

* Window Type Flags

WINDOWSIZING	equ	$0001
WINDOWDRAG	equ	$0002
WINDOWDEPTH	equ 	$0004
WINDOWCLOSE	equ	$0008

SIZEBRIGHT	equ	$0010
SIZEBBOTTOM	equ	$0020

REFRESHBITS	equ	$00C0
SMART_REFRESH	equ	$0000
SIMPLE_REFRESH	equ	$0040
SUPER_BITMAP	equ	$0080
OTHER_REFRESH	equ	$00C0

BACKDROP		equ	$0100
REPORTMOUSE	equ	$0200
GIMMEZEROZERO	equ	$0400
BORDERLESS	equ	$0800
ACTIVATE		equ	$1000
WINDOWACTIVE	equ	$2000
INREQUEST	equ	$4000
MENUSTATE	equ	$8000

RMBTRAP		equ	$00010000
NOCAREREFRESH	equ	$00020000

WINDOWREFRESH	equ	$01000000
WBENCHWINDOW	equ 	$02000000
WINDOWTICKED	equ	$04000000

SUPER_UNUSED	equ	$FCFC0000



* Menu flags


NOMENU		equ	$001F
NOITEM		equ	$003F
NOSUB		equ	$001F
MENUNULL		equ	$FFFF

MENUENABLED	equ	$0001

MIDRAWN		equ	$0100

* Menu Activation Flags

CHECKIT		equ	$0001
ITEMTEXT		equ	$0002
COMMSEQ		equ	$0004
MENUTOGGLE	equ	$0008
ITEMENABLED	equ	$0010

HIGHFLAGS	equ	$00C0
HIGHIMAGE	equ	$0000
HIGHCOMP		equ	$0040
HIGHBOX		equ	$0080
HIGHNONE		equ	$00C0

CHECKED		equ	$0100


ISDRAWN		equ	$1000
HIGHITEM		equ	$2000
MENUTOGGLED	equ	$4000

* Text Modes for Intuition Text Structure

RP_JAM1		equ	0
RP_JAM2		equ	1
RP_COMPLEMENT	equ	2
RP_INVERSID		equ	4

*Requester Stuff


POINTREL		equ	$0001
PREDRAWN		equ	$0002
NOISYREQ		equ	$0004	1.2

REQOFFWINDOW	equ	$1000
REQACTIVE	equ	$2000
SYSREQUEST	equ	$4000
DEFERREFRESH	equ	$8000


* GADGET DEFINITIONS

* Gadget Property Flags

GADGHIGHBITS	equ	$0003
GADGHCOMP	equ 	$0000
GADGHBOX		equ	$0001
GADGHIMAGE	equ	$0002
GADGHNONE	equ	$0003
GADGIMAGE	equ	$0004 
GRELBOTTOM	equ	$0008
GRELRIGHT	equ	$0010
GRELWIDTH	equ	$0020
GRELHEIGHT	equ 	$0040
SELECTED		equ	$0080
GADGDISABLED	equ	$0100

* Gadget Activation Flags

RELVERIFY	equ	$0001
GADGIMMEDIATE	equ	$0002
ENDGADGET	equ	$0004
FOLLOWMOUSE	equ	$0008
RIGHTBORDER	equ	$0010
LEFTBORDER	equ	$0020
TOPBORDER	equ	$0040
BOTTOMBORDER	equ	$0080
TOGGLESELECT	equ	$0100
STRINGCENTER	equ	$0200
STRINGRIGHT	equ	$0400
LONGINT		equ	$0800
ALTKEYMAP	equ	$1000

* Gadget Type Flags

GADGETTYPE	equ	$FC00
SYSGADGET	equ	$8000
SCRGADGET	equ	$4000
GZZGADGET	equ	$2000
REQGADGET	equ	$1000

SIZING		equ 	$0010
WDRAGGING	equ	$0020
SDRAGGING	equ	$0030
WUPFRONT		equ	$0040
SUPFRONT		equ	$0050
WDOWNBACK	equ	$0060
SDOWNBACK	equ	$0070
CLOSE		equ	$0080

BOOLGADGET	equ	$0001
GADGET0002	equ	$0002
PROPGADGET	equ	$0003
STRGADGET	equ	$0004

BOOLMASK		equ	1

* PropInfo structure for proportional gadget

AUTOKNOB		equ	$0001
FREEHORIZ	equ 	$0002
FREEVERT		equ	$0004
PROPBORDERLESS	equ	$0008
KNOBHIT		equ	$0100


KNOBHMIN		equ	6
KNOBVMIN		equ	4
MAXBODY		equ	$FFFF
MAXPOT		equ	$FFFF


MENUHOT		equ	$0001
MENUCANCEL	equ	$0002
MENUWAITING	equ	$0003
OKOK		equ	MENUHOT			1.2
OKABORT		equ	$0004			1.2
OKCANCEL		equ	MENUCANCEL	1.2

* Not yet sure what these are for but I'm sure they're
* relevant to Intuition

AUTOFRONTPEN	equ	0
AUTOBACKPEN	equ	1
AUTODRAWMODE	equ	RP_JAM2
AUTOLEFTEDGE	equ	6
AUTOTOPEDGE	equ	3
AUTOITEXTFONT	equ	0
AUTONEXTTEXT	equ	0


CURSORUP		EQU	$4C
CURSORLEFT	EQU	$4F
CURSORRIGHT	EQU	$4E
CURSORDOWN	EQU	$4D
KEYCODE_Q	EQU	$10
KEYCODE_X	EQU	$32
KEYCODE_N	EQU	$36
KEYCODE_M	EQU	$37

* some structure definitions

* RastPort structure

		rsreset
rp_Layer		rs.l	1
rp_BitMap	rs.l	1
rp_AreaPtrn	rs.l	1
rp_TmpRas	rs.l	1
rp_AreaInfo	rs.l	1
rp_GelsInfo	rs.l	1
rp_Mask		rs.b	1
rp_FgPen		rs.b	1
rp_BgPen		rs.b	1
rp_AOLPen	rs.b	1
rp_DrawMode	rs.b	1
rp_AreaPtSz	rs.b	1
rp_Dummy		rs.b	1
rp_LinPatCnt	rs.b	1
rp_Flags		rs.w	1
rp_LinePtrn	rs.w	1
rp_cp_x		rs.w	1
rp_cp_y		rs.w	1
rp_Minterms	rs.b	8
rp_PenWidth	rs.w	1
rp_PenHeight	rs.w	1
rp_Font		rs.l	1
rp_AlgoStyle	rs.b	1
rp_TxFlags	rs.b	1
rp_TxHeight	rs.w	1
rp_TxWidth	rs.w	1
rp_TxBaseLine	rs.w	1
rp_TxSpacing	rs.w	1
rp_RP_User	rs.l	1
rp_wordreserved	rs.b	14	;Not V1.2!!!
rp_longreserved	rs.l	1
rp_reserved	rs.b	8

rp_sizeof	rs.w	0

* Intuition View structure

		rsreset
vw_ViewPort	rs.l	1
vw_LOFCprlist	rs.l	1
vw_SHFCprlist	rs.l	1
vw_DyOffset	rs.w	1
vw_DxOffset	rs.w	1
vw_Modes		rs.w	1
vw_sizeof	rs.w	0

* Intuition ViewPort structure

		rsreset
vp_Next		rs.l	1
vp_ColorMap	rs.l	1
vp_DspIns	rs.l	1
vp_SprIns	rs.l	1
vp_ClrIns	rs.l	1
vp_UCopIns	rs.l	1
vp_DWidth	rs.w	1
vp_DHeight	rs.w	1
vp_DxOffset	rs.w	1
vp_DyOffset	rs.w	1
vp_Modes		rs.w	1
vp_reserved	rs.w	1
vp_RasInfo	rs.l	1
vp_sizeof	rs.w	0

* RasInfo structure

		rsreset
ri_Next		rs.l	1
ri_BitMap	rs.l	1
ri_RxOffset	rs.w	1
ri_RyOffset	rs.w	1
ri_sizeof	rs.w	0


* intuition message structure


		rsreset
im_execmessage	rs.b	mn_sizeof
im_class		rs.l	1
im_code		rs.w	1
im_qualifier	rs.w	1
im_iaddress	rs.l	1
im_mousex	rs.w	1
im_mousey	rs.w	1
im_seconds	rs.w	1
im_micros	rs.w	1
im_IDCMPwindow	rs.l	1
im_speciallink	rs.l	1
im_sizeof	rs.w	0


;Intuition Remember structure


		rsreset
rm_NextRemember	rs.l	1
rm_RememberSize	rs.l	1
rm_Memory	rs.l	1
rm_sizeof	rs.w	0



* my macro for calling an INTUITION.LIBRARY function


CALLINT		macro	name	;call an INTUITION library function

		move.l	a6,-(sp)
		move.l	int_base(a6),a6
		jsr	\1(a6)
		move.l	(sp)+,a6

		endm


