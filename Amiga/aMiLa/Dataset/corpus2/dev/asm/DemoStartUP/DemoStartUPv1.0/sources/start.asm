;- [ 8bit START UP v1.0 ] -
; AGA/CGX/CGX Window/P61
; by Nemanja Bondzulic aka Cyborg/iNDUSTRY <cyborg@indus3.org>

;///XDEF
	xdef	_CPU
	xdef	_FPU
	xdef	_blit
	xdef	_CGX
        xdef	_WIN
	xdef	_screen
	xdef	_window
	xdef	_newpal
	xdef	_cls
	xdef	_gettime

	xdef	_DosBase
	xdef	_IntuitionBase
	xdef	_GfxBase
	xdef	_CyberGfxBase

	xdef	_thisTasksigf
	xdef	_thisTask

	xdef	_nfsc
;///
;///XREF
	xref	_C2P
	xref	_InitC2P
	xref	_InitPlayer
	xref	_StopPlayer
	xref	_P61_E8
	xref	_InitPreDEMO
	xref	_Main
	xref	_chunky
	xref    _AslCgxModeRequester
	xref	_displayid
	xref	_SoftIRQ
	xref	_StartSoftInt
	xref    _StopSoftInt
	xref	_si_micro
	xref	_si_secs
	xref	_si_func
;///
;///Includes
	include	"basemacros.i"

	incdir	include:

	include	devices/timer.i

	include exec/interrupts.i
	include	exec/lists.i
	include	exec/execbase.i
	include exec/types.i
	include	exec/exec.i
	include exec/libraries.i
	include exec/io.i
	include exec/memory.i
	include exec/ports.i

	include utility/tagitem.i

	include	intuition/intuition.i

	include dos/dostags.i

	include	hardware/blit.i
	include	hardware/custom.i
        include hardware/dmabits.i
	include	hardware/intbits.i
	include hardware/rawkeys.i

	include	LVO/graphics_lib.i
	include	LVO/dos_lib.i
	include LVO/exec_lib.i
	include	LVO/intuition_lib.i
	include	LVO/cybergraphics_lib.i
	include	LVO/asl_lib.i
	include	LVO/icon_lib.i

	include	libraries/asl.i
        include	libraries/dosextens.i

	include cybergraphx/cybergraphics.i

	include	graphics/view.i

	include	workbench/workbench.i
	include	workbench/startup.i
;///

	section asmstart,code

;///_asmstart
_asmstart
        movem.l	d0/a0,-(sp)

	sub.l	a1,a1
	callExe	FindTask
	move.l	d0,_thisTask

	move.l	d0,a4

	tst.l	pr_CLI(a4)
	bne.s   .fromCLI

	move.b	#TRUE,WB

	lea	pr_MsgPort(a4),a0
	callExe WaitPort
	lea	pr_MsgPort(a4),a0
	callExe GetMsg
	move.l	d0,returnMsg

.fromCLI
	movem.l	(sp)+,d0/a0

	;Set own priority to 1
	move.l	_thisTask,a1
	moveq	#1,d0
	callExe SetTaskPri

	bsr.s	determinePU

	;Open dos.library
	lea	DosName(pc),a1
	moveq	#39,d0
	callExe	OpenLibrary
	move.l	d0,_DosBase
	beq.w	.nodos

        ;Read arguments if started from CLI
        tst.b	WB
        bne.s	.skipreadargs
	move.l	#template,d1
        move.l	#argarray,d2
        moveq	#0,d3
        callDos	ReadArgs
	move.l	d0,rdargs

        lea	argarray,a0
	move.l	ARG_LIMITFPS(a0),a0
        tst.l	a0
        beq.s	.nolimitfps
	move.l	(a0),d0
        ble.s   .nolimitfps
        and.l	#$ff,d0
        move.l	d0,limitfps
.nolimitfps


        bra.s	.skiptooltypes
.skipreadargs

        ;Lock current directory
	move.l	returnMsg,a2
        move.l	sm_ArgList(a2),d0
        beq.s	.domain
	move.l	d0,a0
	move.l	wa_Lock(a0),d1
	callDos	DupLock
	move.l	d0,curdir
	move.l	d0,d1
	callDos	CurrentDir
.domain
        ;Get WB program name
	move.l	returnMsg,a0
	move.l	sm_ArgList(a0),a0
        move.l	wa_Name(a0),programname

        ;Open icon.library
	lea	IconName(pc),a1
	moveq	#36,d0
	callExe	OpenLibrary
	move.l	d0,_IconBase
	beq.w	.unlockdir

       	;Get icon
        move.l	programname,a0
        callIco	GetDiskObject
        move.l	d0,diskobject
        beq.s	.unlockdir

	;Find tooltypes
        lea	argarray,a2

        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_SCREENMODE,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypesm
        move.l	#TRUE,ARG_SCREENMODE(a2)
.notooltypesm
        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_AGA,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypeaga
        move.l	#TRUE,ARG_AGA(a2)
.notooltypeaga
        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_WINDOW,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypewin
        move.l	#TRUE,ARG_WINDOW(a2)
.notooltypewin
        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_NOCHK,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypenochk
        move.l	#TRUE,ARG_NOCHK(a2)
.notooltypenochk
        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_LIMITFPS,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypelimitfps

	move.l	d0,d1
        move.l	#limitfps,d2
        callDos	StrToLong
.notooltypelimitfps
        move.l	diskobject,a0
        move.l	do_ToolTypes(a0),a0
        lea	TT_PUBSCREEN,a1
	callIco	FindToolType
        tst.l	d0
        beq.s	.notooltypepubscreen
        move.l	d0,ARG_PUBSCREEN(a2)
.notooltypepubscreen

.unlockdir
	;Unlock current directory
	move.l	curdir,d1
        beq.s	.wasnolock
	callDos	UnLock
.wasnolock
.skiptooltypes
        ;Open intuition.library
	lea	IntName(pc),a1
	moveq	#39,d0
	callExe	OpenLibrary
	move.l	d0,_IntuitionBase
	beq.w	.noint

	;Open graphics.library
	lea	GfxName(pc),a1
	moveq	#39,d0
	callExe	OpenLibrary
	move.l	d0,_GfxBase
	beq.w	.nogfx

	;Center screens
	move.l	#LORES_KEY,a0
	move.w	#OSCAN_TEXT,d0
	lea	rectangle,a1
	callInt	QueryOverscan
	tst.l	d0
	beq.s	.nooverscan

	lea	rectangle,a1
	moveq	#0,d0
	move.l	d0,d1
	move.w	ra_MaxX(a1),d0
	move.w	ra_MaxY(a1),d1
	sub.w	ra_MinX(a1),d0
	sub.w	#SCREEN_WIDTH-1,d0
	bmi.s	.nooverscan2
	lsr.w	#1,d0
	move.l	d0,cgxscrl
	move.l	d0,agascrl
.nooverscan2
	sub.w	ra_MinY(a1),d1
	sub.w	#SCREEN_HEIGHT-1,d1
	bmi.s	.nooverscan
	lsr.w	#1,d1
	move.l	d1,cgxscrt
	move.l	d1,agascrt
.nooverscan

        ;Test if AGA switch is used
        lea	argarray,a0
        tst.b	ARG_AGA(a0)
	beq.s	.noagaswitch
	;Force AGA
	bra.w   .nocgx
.noagaswitch
	
	;Open cybergraphics.library
	lea	CyberName(pc),a1
	move.l	#41,d0
	callExe	OpenLibrary
	move.l	d0,_CyberGfxBase
	beq.w	.nocgx


	;Test if WINDOW switch is used
	lea	argarray,a0
        tst.b	ARG_WINDOW(a0)
	beq.s	.cgx

        move.b  #TRUE,_WIN
        bra.s   .both


.cgx	;CGX!
	move.w	#TRUE,_CGX
        move.b	#FALSE,_WIN
	move.l	#SCREEN_HEIGHT*2,winh8

        ;Find best CGX mode
        lea	bestcmodeidtaglist(pc),a0
	callCgx	BestCModeIDTagList
	move.l	d0,cgxmode

        ;Test if SCREENMODE switch is used
        lea	argarray,a0
        tst.b	ARG_SCREENMODE(a0)
	bne.s	.modereq
	
        ;Check for SHIFT key
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	move.b	#$0,$bfec01
	move.b	#%10001000,$bfee01
	cmp.b	#KEY_LSHIFT,d0
	beq.s	.modereq
	cmp.b	#KEY_RSHIFT,d0
	beq.s	.modereq

	;Best CGX mode gotten?
	tst.l	cgxmode
	bne.s	.cgxmodefound
.modereq
	bsr.w	_AslCgxModeRequester
	move.l	_displayid,d0
	beq.w	.noscreen
	move.l	d0,cgxmode
	
.cgxmodefound
	;Check depth of this mode
	move.l	#CYBRIDATTR_DEPTH,d0
	move.l	cgxmode,d1
	callCgx	GetCyberIDAttr
	cmp.w	#8,d0
	bne.s	.modereq

	;Check pixel format of this mode
	move.l	#CYBRIDATTR_PIXFMT,d0
	move.l	cgxmode,d1
	callCgx	GetCyberIDAttr
	cmp.w	#PIXFMT_LUT8,d0
	bne.s	.modereq

	;Set backdrop window width
	move.l	#CYBRIDATTR_WIDTH,d0
	move.l	cgxmode,d1
	callCgx	GetCyberIDAttr
	move.l	d0,winwi

	;Set backdrop window and screen height
	move.l	#CYBRIDATTR_HEIGHT,d0
	move.l	cgxmode,d1
	callCgx	GetCyberIDAttr
	cmp.l	#SCREEN_HEIGHT,d0
	bge.s	.zh
	move.l	#SCREEN_HEIGHT,d0
.zh
	add.l   d0,d0
	move.l  d0,cgxscrh
	move.l	d0,winh8
	
        ;Open CGX screen
	move.l	#0,a0
	lea	cgxscreentags(pc),a1
	callInt	OpenScreenTagList
	move.l	d0,_screen
	beq.w	.noscreen

	;Check if it is CGX bitmap
        move.l	_screen,a0
        move.l	(sc_RastPort+rp_BitMap)(a0),a0
        move.l	#CYBRMATTR_ISCYBERGFX,d0
	callCgx	GetCyberMapAttr
        tst.l	d0
        beq.w	.notcgxmap

	;Check if it is linear accesable
        move.l	_screen,a0
        move.l	(sc_RastPort+rp_BitMap)(a0),a0
        move.l	#CYBRMATTR_ISLINEARMEM,d0
	callCgx	GetCyberMapAttr
        tst.l	d0
        beq.s	.nolinearcgxmem

	;Get CGX bitmap info by locking
	move.l  _screen,a0
	move.l  (sc_RastPort+rp_BitMap)(a0),a0
	lea     cgxinfotaglist(pc),a1
	callCgx LockBitMapTagList
	move.l  d0,cgxbitmaplock
	beq.s   .nocgxlock

	;Unlock CGX bitmap
	move.l  cgxbitmaplock(pc),a0
	callCgx UnLockBitMap

	move.l  cgxbitmap_height,d0
	lsr.l	#1,d0

	move.w  d0,cgxh8
	move.w	d0,scrpart
	move.l  cgxbitmap_bytesperrow,d1
	mulu.l	d0,d1
	move.l	d1,cgxadd
	
        bra.s	.both

.nocgxlock
.nolinearcgxmem
	;Close screen
        tst.l	_screen
        beq.s	.noscreen
	move.l	_screen,a0
	callInt	CloseScreen



.nocgx  ;NO CGX! ONLY AGA!
	move.w	#FALSE,_CGX

	;Allocate CHIP Memory
	move.l	#SCREEN_WIDTH*SCREEN_HEIGHT,d0
	move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	callExe	AllocVec
	move.l	d0,bmp1pointer
	beq.s	.exitsequence

	move.l	#SCREEN_WIDTH*SCREEN_HEIGHT,d0
	move.l	#MEMF_CHIP|MEMF_CLEAR,d1
	callExe	AllocVec
	move.l	d0,bmp2pointer
	beq.s	.exitsequence

	lea	bm,a0
	move.l	bmp1pointer,d3
	lea	bm2,a1
	move.l	bmp2pointer,d4

	move.l	#SCREEN_WIDTH*SCREEN_HEIGHT/8,d0
	move.w	#8-1,d1
.setplanes
	move.l	d3,(a0)+
	add.l	d0,d3
	move.l	d4,(a1)+
	add.l	d0,d4
	dbf	d1,.setplanes

	;Open AGA screen.
	move.l	#0,a0
	lea.l	agascreentags(pc),a1
	callInt	OpenScreenTagList
	move.l	d0,_screen	
	beq.w	.nowindow

	;Put BitMap1 into _Screen->ViewPort.RasInfo
	move.l  _screen,a0
	move.l  sc_ViewPort+vp_RasInfo(a0),a1
	move.l  #BitMap1,ri_BitMap(a1)

        ;Initialize C2P routine
	jsr	_InitC2P


	;do for both AGA and CGX
.both
	;WINDOW mode?
        tst.b	_WIN
        beq.s	.bkwin

	;Yep...Lock public screen
        lea	argarray,a0
	move.l	ARG_PUBSCREEN(a0),a0
	move.l	a0,pubscr
        callInt	LockPubScreen
        move.l	d0,pubscrlock
        beq.s	.cgx	;can't lock pub screen, try cgx screen

        ;Check if pub screen has 8+ bits depth
       	move.l	pubscrlock,a0
        move.l	sc_RastPort+rp_BitMap(a0),a0
        move.l	#BMA_DEPTH,d1
        callGfx	GetBitMapAttr
	cmp.l	#8,d0
        ble.s	.nowindow
	
        move.l	pubscrlock,_screen

        ;Center window
        move.l	_screen,a0
        moveq	#0,d0
        move.l	d0,d1
        move.w	sc_Width(a0),d0
        sub.w	#SCREEN_WIDTH,d0
        lsr.w	#1,d0
        move.l	d0,wleft
        move.w	sc_Height(a0),d1
        sub.w	#SCREEN_HEIGHT,d1
        lsr.w	#1,d1
        move.l	d1,wtop

        ;Open window
	sub.l	a0,a0
        lea	windowtags(pc),a1
	callInt	OpenWindowTagList
	move.l	d0,_window
	beq.w	.nowindow


	;Unlock public screen
        move.l	pubscrlock,a1
        sub.l	a0,a0
        callInt	UnlockPubScreen
        move.l	#0,pubscrlock
	bra.s	.nnx


.bkwin  ;Nope...backdrop window
	sub.l	a0,a0
	lea	bkwindowtags(pc),a1
	callInt	OpenWindowTagList
	move.l	d0,_window
	beq.w	.nowindow

.nnx
        ;Set nfsc if NOFRONTSCREENCHECK switch is used
.argts
	lea	argarray,a0
        move.b	ARG_NOCHK(a0),_nfsc

        ;Create timer
	callExe	CreateMsgPort
	move.l	d0,TimerMP
	beq.w	.nomp

	move.l	TimerMP,a0
	move.l	#IOTV_SIZE,d0
	callExe	CreateIORequest
	move.l	d0,TimerIO
	beq.s	.noio

	lea	TimerName,a0
	move.l	#UNIT_MICROHZ,d0	;UNIT_VBLANK,d0
	move.l	TimerIO,a1
	moveq.l	#0,d1
	callExe	OpenDevice
	tst.l	d0
	bne.s	.nodev

	;Allocate double buffering structure
	move.l	_screen,a0
	lea	sc_ViewPort(a0),a0
	callGfx	AllocDBufInfo
	move.l	d0,mydbi
	beq.s	.exitsequence

	;Create message ports for double buffering
	callExe	CreateMsgPort
	move.l	d0,safewrite
	beq.s	.exitsequence
        move.l	mydbi(pc),a0
	move.l	d0,(dbi_SafeMessage+MN_REPLYPORT)(a0)

	callExe	CreateMsgPort
	move.l	d0,safeswap
	beq.s	.exitsequence
	move.l	mydbi(pc),a0
	move.l	d0,(dbi_DispMessage+MN_REPLYPORT)(a0)

	;Allocate signal for first screen
	moveq	#-1,d0
	callExe	AllocSignal
        moveq	#0,d1
	bset	d0,d1
	move.l	d0,_thisTasksig
	move.l	d1,_thisTasksigf

	;Start interrupt
        move.l	limitfps,d0
        bgt.s	.validlimit
        move.l	#50,d0
.validlimit
	move.l	#1000000,d1
        divu.l	d0,d1
        move.l	d1,_si_micro
        move.l	#0,_si_secs
	lea	_SoftIRQ,a0
	move.l	a0,_si_func
	bsr	_StartSoftInt

	jsr     _InitPreDEMO
        jsr     _Main
	IFNE	MUSIC
        jsr     _StopPlayer
	ENDC

.exitsequence
	;Remove soft IRQ
	bsr	_StopSoftInt

	;Free signal
	move.l	_thisTasksig,d0
	cmp.l	#-1,d0
	beq.s	.wasnosignal
	callExe	FreeSignal
.wasnosignal

        ;Remove double buffering resources
.while2
	move.l  safeswap,a0
	tst.l	a0
	beq.s	.safe2swap

	tst.w	safe2swap
	bne.s	.safe2swap

	move.l  safeswap,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2swap
	moveq	#0,d0
	move.l	d0,d1
	move.l	safeswap,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait
	bra.s	.while2
.safe2swap
.while1
	move.l  safewrite,a0
	tst.l	a0
	beq.s	.safe2write

	tst.w	safe2write
	bne.s	.safe2write
	
        move.l  safewrite,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2write
	moveq	#0,d0
	move.l	d0,d1
	move.l	safewrite,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait
	bra.s	.while1
.safe2write
	move.l	safeswap,a0
	tst.l	a0
	beq.s	.noswapmsg
	callExe	DeleteMsgPort
.noswapmsg
	move.l	safewrite,a0
	tst.l	a0
	beq.s	.nowritemsg
	callExe	DeleteMsgPort
.nowritemsg
	move.l	mydbi,a1
	tst.l	a1
	beq.s	.nodbi
	callGfx	FreeDBufInfo
.nodbi

	;Remove timer
        move.l	TimerIO,a1
	tst.l	a1
	beq.s	.nodev
	callExe	CloseDevice
.nodev
	move.l	TimerIO,a0
	tst.l	a0
	beq.s	.noio
	callExe	DeleteIORequest
.noio
	move.l	TimerMP,a0
	tst.l	a0
	beq.s	.nomp
	callExe	DeleteMsgPort
.nomp

	;Close window
	tst.l	_window
	beq.s	.nowindow
	move.l	_window,a0
	callInt	CloseWindow
.nowindow

	;Unlock public screen
        move.l	pubscrlock,a1
        tst.l	a1
        beq.s	.nopubscrlock
        sub.l	a0,a0
        callInt	UnlockPubScreen
.nopubscrlock
.notcgxmap
	;Close screen
        tst.l	_screen
        beq.s	.noscreen
        tst.b	_WIN
        bne.s	.noscreen
	move.l	_screen,a0
	callInt	CloseScreen
.noscreen

	
        ;Deallocate CHIP memory
	move.l	bmp1pointer,a1
	tst.l	a1
	beq.s	.notmem1
	callExe	FreeVec
.notmem1
	move.l	bmp2pointer,a1
	tst.l	a1
	beq.s	.notmem2
	callExe	FreeVec
.notmem2
	
        ;Close cybergraphics.library
	tst.l	_CyberGfxBase
        beq.s	.wasnocyber
	move.l	_CyberGfxBase(pc),a1
	callExe	CloseLibrary
.wasnocyber
        ;Close graphics.library
	move.l	_GfxBase(pc),a1
	callExe	CloseLibrary
.nogfx
        ;Close intuition.library
	move.l	_IntuitionBase(pc),a1
	callExe	CloseLibrary
.noint
	;Free icon
        move.l	diskobject,a0
        tst.l	a0
        beq.s	.nodskobj
        callIco	FreeDiskObject
.nodskobj
        ;Close icon.library
	move.l	_IconBase(pc),a1
        tst.l	a1
        beq.s	.noicon
	callExe	CloseLibrary
.noicon

        ;Free arguments
        move.l	rdargs,d1
        beq.s	.noargs
        callDos	FreeArgs
.noargs
        ;Close dos.library
	move.l	_DosBase(pc),a1
	callExe	CloseLibrary
.nodos

	tst.l	returnMsg
	beq.s	exitToDOS
	callExe	Forbid
	move.l	returnMsg(pc),a1
	callExe	ReplyMsg
exitToDOS
	moveq	#0,d0
	rts
;///

;///Data
returnMsg	dc.l 	0
_thisTask	dc.l	0
_thisTasksig	dc.l	-1
_thisTasksigf	dc.l	0
curdir		dc.l	0

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DosBase	dc.l    0
_CyberGfxBase	dc.l	0
_IconBase	dc.l	0
TimerMP		dc.l	0
TimerIO		dc.l	0

TimerName	dc.b	"timer.device",0
IntName		dc.b	"intuition.library",0
GfxName		dc.b	"graphics.library",0
DosName		dc.b	"dos.library",0
CyberName	dc.b	"cybergraphics.library",0
IconName	dc.b	"icon.library",0
	even

bestcmodeidtaglist
        dc.l    CYBRBIDTG_Depth,8
	dc.l    CYBRBIDTG_NominalWidth,SCREEN_WIDTH
	dc.l	CYBRBIDTG_NominalHeight,SCREEN_HEIGHT
	dc.l	TAG_END

cgxinfotaglist
        dc.l    LBMI_WIDTH,cgxbitmap_width
        dc.l    LBMI_HEIGHT,cgxbitmap_height
        dc.l    LBMI_DEPTH,cgxbitmap_depth
        dc.l    LBMI_PIXFMT,cgxbitmap_pixfmt
	dc.l	LBMI_BYTESPERPIX,cgxbitmap_bytesperpix
	dc.l	LBMI_BYTESPERROW,cgxbitmap_bytesperrow
	dc.l	LBMI_BASEADDRESS,cgxbitmap_baseaddress
	dc.l	TAG_END

cgxbitmaplock	dc.l	0

cgxbitmap_width		dc.l	0
cgxbitmap_height	dc.l	0
cgxbitmap_depth		dc.l	0
cgxbitmap_pixfmt	dc.l	0
cgxbitmap_bytesperpix	dc.l	0
cgxbitmap_bytesperrow	dc.l	0
cgxbitmap_baseaddress	dc.l	0

cgxscreentags
	dc.l	SA_DisplayID
cgxmode	dc.l	0
	dc.l	SA_Left
cgxscrl	dc.l	0
	dc.l	SA_Top
cgxscrt	dc.l	0
	dc.l	SA_Width,SCREEN_WIDTH
	dc.l	SA_Height
cgxscrh dc.l	SCREEN_HEIGHT*2
	dc.l	SA_Depth,8
	dc.l	SA_Quiet,1
	dc.l	SA_Colors32,blackpal
	dc.l	SA_ShowTitle,0
	dc.l	SA_Draggable,0
	dc.l	TAG_END

agascreentags
	dc.l	SA_DisplayID,LORES_KEY
	dc.l	SA_Left
agascrl	dc.l	0
	dc.l	SA_Top
agascrt	dc.l	0
	dc.l	SA_Width,SCREEN_WIDTH
	dc.l	SA_Height,SCREEN_HEIGHT
	dc.l	SA_Depth,8
	dc.l	SA_ShowTitle,FALSE
	dc.l	SA_BitMap,BitMap1
	dc.l	SA_Quiet,TRUE
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Colors32,blackpal
	dc.l	SA_Draggable,FALSE
	dc.l	TAG_END

BitMap1:
	dc.w    SCREEN_WIDTH/8,SCREEN_HEIGHT,8,0
bm	dcb.l	9

BitMap2:
	dc.w    SCREEN_WIDTH/8,SCREEN_HEIGHT,8,0
bm2	dcb.l	9

bmp1pointer	dc.l	0
bmp2pointer	dc.l	0

safeswap	dc.l	0
safewrite	dc.l	0

mydbi		dc.l	0

safe2swap	dc.w	1
safe2write	dc.w	1

rectangle	ds.b    ra_SIZEOF

	;Backdrop window
bkwindowtags
	dc.l	WA_Top,0
	dc.l	WA_Left,0
	dc.l	WA_Width
winwi	dc.l	SCREEN_WIDTH
	dc.l	WA_Height
winh8   dc.l    SCREEN_HEIGHT
	dc.l	WA_CustomScreen
_screen	dc.l	0
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_Backdrop,TRUE
	dc.l	WA_Borderless,TRUE
	dc.l	WA_Activate,TRUE
	dc.l	WA_Pointer,pointer
	dc.l	WA_RMBTrap,TRUE
	dc.l	WA_IDCMP,IDCMP_MOUSEBUTTONS
	dc.l	TAG_END

	;Window on WB screen
windowtags
	dc.l	WA_Top
wtop	dc.l	0
	dc.l	WA_Left
wleft	dc.l	0
	dc.l	WA_InnerWidth
	dc.l	SCREEN_WIDTH
	dc.l	WA_InnerHeight
	dc.l    SCREEN_HEIGHT
	dc.l	WA_NoCareRefresh,TRUE
	dc.l	WA_Borderless,FALSE
	dc.l	WA_Activate,TRUE
        dc.l	WA_DepthGadget,TRUE
        dc.l    WA_CloseGadget,TRUE
        dc.l	WA_DragBar,TRUE
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW
	dc.l	WA_RMBTrap,TRUE
        dc.l	WA_Title,wintitle
        dc.l	WA_PubScreenName
pubscr	dc.l	0
	dc.l	TAG_END

wintitle	
	dc.b	"Happy Go Fucked Up",0
	even

_window	dc.l	0

pubscrlock
	dc.l	0

blackpal
	dc.w	256,0
	dcb.l	256*3
	dc.w	0

pointer
	dc.l	nullpointer
	dcb.w	8

limitfps	dc.l	50	;DEFAULT LIMIT 50fps!

rdargs		dc.l	0
argarray	ds.l	ARG_Count+1
template
	dc.b	"SCREENMODE=SM/S,AGA/S,WINDOW=WIN/S,PUBSCREEN=PUB/K,NOFRONTSCREENCHECK=NOCHK/S,LIMITFPS/N",0
	even

programname	dc.l    0

diskobject	ds.b	do_SIZEOF

TT_SCREENMODE	dc.b	"SCREENMODE",0
TT_AGA		dc.b	"AGA",0
TT_WINDOW	dc.b	"WINDOW",0
TT_NOCHK	dc.b	"NOFRONTSCREENCHECK",0
TT_LIMITFPS	dc.b	"LIMITFPS",0
TT_PUBSCREEN	dc.b	"PUBSCREEN",0

WB	dc.b	0
_nfsc	dc.b    0
_WIN	dc.b	0
	even
_CPU	dc.l	0
_FPU	dc.l	0
_CGX	dc.w	0
;///

;///determinePU
determinePU
	;Determine CPU type
	move.l	$4.w,a6
	move.w	AttnFlags(a6),d0
	move.l	#68000,_CPU
	btst	#AFB_68010,d0
	beq.s	.cpu68010
	move.l	#68010,_CPU
.cpu68010
	btst	#AFB_68020,d0
	beq.s	.cpu68020
	move.l	#68020,_CPU
.cpu68020
	btst	#AFB_68030,d0
	beq.s	.cpu68030
	move.l	#68030,_CPU
.cpu68030
	btst	#AFB_68040,d0
	beq.s	.cpu68040
	move.l	#68040,_CPU
.cpu68040
	btst	#AFB_68060,d0
	beq.s	.cpu68060
	move.l	#68060,_CPU
.cpu68060
	;Determine FPU type
	move.l	#0,_FPU
	btst	#AFB_68881,d0
	beq.s	.fpu68881
	move.l	#68881,_FPU
.fpu68881
	btst	#AFB_68882,d0
	beq.s	.fpu68882
	move.l	#68882,_FPU
.fpu68882
	btst	#AFB_FPU40,d0
	beq.b	.fpu68040
	btst	#AFB_68040,d0
	beq.b	.fpu68040
	move.l	#68040,_FPU
.fpu68040
	rts
;///
;///_gettime
	cnop	0,4
_gettime
	;output:
	; D0 = current time [1/500 seconds]

        move.l	TimerIO,a1
	move.w	#TR_GETSYSTIME,IO_COMMAND(a1)

	move.l	TimerIO,a1
	callExe	DoIO

	move.l	TimerIO,a0
	move.l	(IO_SIZE+TV_SECS)(a0),d0	;seconds
	move.l	(IO_SIZE+TV_MICRO)(a0),d1	;micros

	mulu.l	#500,d0
	divu.l	#2000,d1

        add.l	d1,d0
	rts
;///
;///getscreen
	cnop	0,4
getscreen
	;output:
	; A1 = PlanePtr of Undisplayed BitMap
	; A2 = Undisplayed BitMap
	; A3 = _Screen->Viewport.RasInfo
	move.l	_screen(pc),a3
	move.l	sc_ViewPort+vp_RasInfo(a3),a3
	move.l	#BitMap1,a2
	add.l	#BitMap2,a2
	sub.l	ri_BitMap(a3),a2
	move.l	bm_Planes(a2),a1
	rts
;///
;///_blit
	cnop	0,4
_blit
	;A0 = chunky buffer

        tst.w	_WIN
        bne.s	windowblit
	tst.w	_CGX
	bne.s   cyberblit

agablit
	move.l	a0,a4
	;input:	A4 = Chunky buffer

	movem.l	d0-a6,-(sp)

        tst.b	_nfsc
        bne.s	.skipfrontscreenwait
	
        move.l	_thisTasksigf,d0
        callExe	Wait

.skipfrontscreenwait

        tst.w	safe2write
	bne.s	.safe2write
.while1
	move.l  safewrite,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2write

	move.l	safewrite,a0
	moveq	#0,d0
	move.l	d0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while1
.safe2write
	move.w	#TRUE,safe2write
	
	bsr.s	getscreen	 ;a1 - planeptr
	move.l	a4,a0
	jsr	_C2P

	bsr.s	setpalette

        tst.w	safe2swap
	bne.s	.safe2swap
.while2
	move.l  safeswap,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2swap

	moveq	#0,d1
	move.l	d1,d0
	move.l	safeswap,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while2
.safe2swap
	move.w	#TRUE,safe2swap
	
	bsr.s   getscreen
	move.l  a2,a1
	move.l  _screen(pc),a0
	lea	sc_ViewPort(a0),a0
	move.l	mydbi,a2
	callGfx	ChangeVPBitMap

	move.w	#FALSE,safe2swap
	move.w	#FALSE,safe2write

	movem.l	(sp)+,d0-a6
	rts


	cnop	0,4
cyberblit
        movem.l	d0-a6,-(sp)

	move.l	a0,a2
	;input:	A2 = Chunky buffer

        tst.b	_nfsc
        bne.s	.skipfrontscreenwait

	move.l	_thisTasksigf,d0
        callExe	Wait

.skipfrontscreenwait

        tst.w	safe2write
	bne.s	.safe2write
.while1
	move.l  safewrite,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2write

	move.l	safewrite,a0
	moveq	#0,d0
	move.l	d0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while1
.safe2write
	move.w	#TRUE,safe2write

	bsr.s   setpalette

        ;Get CGX bitmap info by locking
        move.l	_screen,a0
        move.l	(sc_RastPort+rp_BitMap)(a0),a0
	lea	cgxinfotaglist(pc),a1
	callCgx	LockBitMapTagList
        move.l	d0,cgxbitmaplock
        beq.w	.nolock

	move.l	cgxbitmap_bytesperrow(pc),d1
	sub.l	#SCREEN_WIDTH,d1
	move.l	cgxbitmap_baseaddress(pc),a1
	tst.l	a1
	beq.w	.unlock

	tst.w	scrpart
	beq.s	.next
	add.l	cgxadd,a1
.next
	move.w  #SCREEN_WIDTH*SCREEN_HEIGHT/4/80-1,d0
.copy
	rept    80
	move.l  (a2)+,(a1)+
	endr
	add.l   d1,a1
	dbf     d0,.copy
.unlock
        ;Unlock CGX bitmap
        move.l	cgxbitmaplock(pc),a0
	callCgx	UnLockBitMap
.nolock
	
        tst.w	safe2swap
	bne.s	.safe2swap
.while2
	move.l  safeswap,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2swap

	moveq	#0,d1
	move.l	d1,d0
	move.l	safeswap,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while2
.safe2swap
	move.w	#TRUE,safe2swap

	move.l  _screen(pc),a0
	move.l	a0,a3
	move.l  (sc_ViewPort+vp_RasInfo)(a3),a3
	move.w  scrpart,ri_RyOffset(a3)
	lea     sc_ViewPort(a0),a0
	callGfx ScrollVPort

	move.l	_screen(pc),a0
	move.l	a0,a1
	lea	sc_ViewPort(a0),a0
	move.l	(sc_RastPort+rp_BitMap)(a1),a1
	move.l	mydbi,a2
	callGfx	ChangeVPBitMap

	move.w	#FALSE,safe2swap
	move.w	#FALSE,safe2write

	tst.w	scrpart
	beq.s	.xc
	clr.w   scrpart
	bra.s	.nxc
.xc
	move.w  cgxh8,scrpart
.nxc
	movem.l	(sp)+,d0-a6
	rts

scrpart	dc.w    0
cgxadd	dc.l	SCREEN_WIDTH*SCREEN_HEIGHT
cgxh8   dc.w	SCREEN_HEIGHT


	cnop	0,4
windowblit
        movem.l	d0-a6,-(sp)

	move.l	a0,a2
	;input:	A2 = Chunky buffer

        tst.b	_nfsc
        bne.s	.skipfrontscreenwait

	move.l	_thisTasksigf,d0
        callExe	Wait

.skipfrontscreenwait


        tst.w	safe2write
	bne.s	.safe2write
.while1
	move.l  safewrite,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2write

	move.l	safewrite,a0
	moveq	#0,d0
	move.l	d0,d1
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while1
.safe2write
	move.w	#TRUE,safe2write


	bsr.s	setpalette

        move.l	a2,a0   		;srcRect
        move.w	#0,d0			;srcX
        move.w	d0,d1			;srcY
        move.w	d0,d3
        move.w	d0,d4
        move.l	#SCREEN_WIDTH,d2        ;srcMod
        move.l	_window,a2
        move.l	wd_RPort(a2),a1  	;RastPort
        move.b	wd_BorderLeft(a2),d3	;destX
	move.b	wd_BorderTop(a2),d4	;destY
        move.w	#SCREEN_WIDTH,d5   	;width
        move.w	#SCREEN_HEIGHT,d6	;height
        move.l	#CTABFMT_XRGB8,d7
        lea	winpal,a2
        callCgx	WriteLUTPixelArray


        tst.w	safe2swap
	bne.s	.safe2swap
.while2
	move.l  safeswap,a0
	callExe	GetMsg
	tst.l	d0
	bne.s   .safe2swap

	moveq	#0,d1
	move.l	d1,d0
	move.l	safeswap,a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	callExe	Wait

	bra.s	.while2
.safe2swap
	move.w	#TRUE,safe2swap

	move.l	_screen(pc),a0
	move.l	a0,a1
	lea	sc_ViewPort(a0),a0
	move.l	(sc_RastPort+rp_BitMap)(a1),a1
	move.l	mydbi,a2
	callGfx	ChangeVPBitMap

	move.w	#FALSE,safe2swap
	move.w	#FALSE,safe2write

        movem.l	(sp)+,d0-a6

	rts

;///
;///setpalette
	cnop	0,4
setpalette
	;Set palette address to _newpal
	;Palette format is RRGGBB
	movem.l	d0-d2/a0-a2/a6,-(sp)
	
        move.l	_newpal(pc),a0
	tst.l	a0
	beq.s	.out

        tst.b	_WIN
        beq.s	.notwin

        move.w	#256-1,d0
	lea	winpal+1,a1
.wl	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)
        addq.w	#2,a1
	dbf	d0,.wl

        bra.s	.out
.notwin
        lea	.data(pc),a1
	lea	4(a1),a2
	move.w	#256-1,d2
.loop:	move.b	(a0)+,(a2)
	addq.l	#4,a2
	move.b	(a0)+,(a2)
	addq.l	#4,a2
	move.b	(a0)+,(a2)
	addq.l	#4,a2
	dbf	d2,.loop

	move.l	_screen,a0
	lea	sc_ViewPort(a0),a0
	callGfx	LoadRGB32
.out
	move.l	#0,_newpal
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts
.data:
	dc.w	256,0   
	dcb.l	256*3
	dc.l	0

winpal
	dcb.l	256

_newpal	dc.l	0

;///
;///_cls
	cnop	0,4
_cls
	;Clear SCREEN_WIDTH x SCREEN_HEIGHT area
	moveq	#0,d1
	lea	_chunky,a0
	move.l	#SCREEN_WIDTH*SCREEN_HEIGHT/4/16-1,d0
.l1
	rept	16
	move.l	d1,(a0)+
	endr
	dbf	d0,.l1
	rts
;///

;///Pointer Data
	section killdabastard, data_c
	cnop	0,8
nullpointer
	dcb.w	20
;///
