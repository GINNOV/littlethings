		incdir "DANE:ASM/Include3.1/"
		include "libraries/gadtools.i"
		include "LVO3.0/gadtools_lib.i"
		include "exec/memory.i"
		include "LVO3.0/exec_lib.i"
;		include "exec/exec.i"
   		include "exec/types.i"
   		include "devices/timer.i"
		include "dos/dos.i"
		include "LVO3.0/dos_lib.i"
		include "dos/dostags.i"
		include "LVO3.0/intuition_lib.i"
		include "LVO3.0/asl_lib.i"
		include "libraries/asl.i"
		include "LVO3.0/locale_lib.i"
		include "libraries/locale.i"
		include "LVO3.0/graphics_lib.i"
numbernodes	equ	30
numbergadgets	equ	19
koniec_rekordu:	equ	$FF
spacja:		equ	$20
licznik:	equr	d0
wejscie:	equr	a0
wyjscie:	equr	a1
odleglosc:	equr	a2
;-------------------------

offsetSource	equ	0
offsetTo	equ	77
offsetDestin	equ	80
offsetOpt	equ	160
;--------------------------
;		RAZEM:  168B
offsetAsm	equ	168
prefsSize	equ	168+(80*numbernodes)+4;(4 na wszelki wypadek)
;--------------------------
;******* LOCALE ***********
ilewkatalogu	equ	9
str1txt		equ	1
str2txt:	equ	2
text:		equ	3
cyclerTxt:	equ	4
but1txt:	equ	5
but2txt:	equ	6
butAsstxt:	equ	7
butRemtxt:	equ	8
butReftxt:	equ	9

a4base:		rsreset
Pool:		rs.l	1
intbase:	rs.l	1
dosbase:	rs.l	1
Input:		rs.l	1
Output:		rs.l	1
localebase:	rs.l	1
locale:		rs.l	1
katalog:	rs.l	1
aslbase:	rs.l	1
aslRequest:	rs.l	1
gfxbase:	rs.l	1
gadbase:	rs.l	1
vi:		rs.l	1
screen:		rs.l	1
window:		rs.l	1
window1:	rs.l	1
WRPort:		rs.l	1
BRPort:		rs.l	1
mainUsrPrt:	rs.l	1
prefUsrPrt:	rs.l	1
signals:	rs.l	1
prefSignal:	rs.l	1
timerSignal:	rs.l	1
prefOpened:	rs.l	1
lock:		rs.l	1
filehdl:	rs.l	1
key:		rs.l	1
oldDir:		rs.l	1
dirLock:	rs.l	1
aslfh		rs.l	1
nody:		rs.l	1
tempNode:	rs.l	1
bufkom:		rs.l	1
offsetPtr:	rs.l	1
lista1:		rs.l	1
lista2:		rs.l	1
fh:		rs.l	1
emptyBuffer:	rs.b	80
pathBuffer:	rs.b	200
oldFile:	rs.l	1
glist:		rs.b	gg_SIZEOF
glist1:		rs.b	gg_SIZEOF
position:	rs.l	1
gadzet:		rs.l	1
LVptr:		rs.l	1
LV1ptr:		rs.l	1
nodeID:		rs.l	1
nodeShowID:	rs.l	1
cyclerPtr:	rs.l	1
string1ptr:	rs.l	1
string2ptr:	rs.l	1
ButSavePtr:	rs.l	1
ButShowPtr:	rs.l	1
ButRemovePtr:	rs.l	1
ButRefreshPtr:	rs.l	1
ButAssPtr:	rs.l	1
ButFromPtr:	rs.l	1
ButToPtr:	rs.l	1
ImgButPtr:	rs.l	1
LibStrPtr:	rs.l	1
selPPtr:	rs.l	1
selLPtr:	rs.l	1
selMPtr:	rs.l	1
selSPtr:	rs.l	1
TimerIOreq:     rs.b    IOSTD_SIZE
ProgramPort:    rs.b    MP_SIZE
TimerPort:      rs.b    MP_SIZE
time_buffer:    rs.l    12
test:		rs.l	1
godzina:        rs.l    1
minuty:         rs.l	1
sekundy:        rs.l	1
str1buffer:	rs.b	80
str2buffer:	rs.b	80
strOptbuffer:	rs.b	4
tempBuffer:	rs.b	80
prefsBuffer:	rs.b	prefsSize
infoBuffer	rs.b	36
base_SIZE:	rs.b	0

		cnop 0,8


		section kot,code_p
START:
		movem.l	d0-a6,-(sp)
		;------------------------------
		bra.w InitList1

************   Sets up port a2 and grabs a signal for it
* InitPort *
************
InitPort:
   clr.l LN_NAME(a2)
   clr.b LN_PRI(a2)
   move.b   #NT_MSGPORT,LN_TYPE(a2)
   clr.b MP_FLAGS(a2)

   moveq #-1,d0
   CALLEXEC AllocSignal
   cmp.l #$ffffffff,d0
   beq.s NoSignals
   move.b   d0,MP_SIGBIT(a2)

   sub.l a1,a1
   CALLEXEC FindTask

   move.l   d0,MP_SIGTASK(a2)
   lea   MP_MSGLIST(a2),a0
   move.l   a0,(a0)
   addq.l   #4,(a0)
   clr.l LH_TAIL(a0)
   move.l   a0,LH_TAILPRED(a0)

   move.l   a2,d0
   rts
NoSignals:
   moveq #0,d0
   rts


;---------------------------------------------------------------
SetTimer:
   lea   TimerIOreq(a4),a1
   move.w   #TR_ADDREQUEST,IO_COMMAND(a1)
   move.l   #1,IOTV_TIME+TV_SECS(a1)
   clr.l IOTV_TIME+TV_MICRO(a1)
   move.l   4.w,a6
   jmp   _LVOSendIO(a6)
;---------------------------------------------------------------

OpenMyTimer:
   lea   TimerPort(a4),a2      ;Set up port for IO request
   bsr.b InitPort
   tst.l d0
   beq.s NoTimePort

   lea   TimerIOreq(a4),a1
   move.b   #NT_MESSAGE,LN_TYPE(a1)    ;set up IO request structure
   move.l   a2,MN_REPLYPORT(a1)
   move.w   #IOSTD_SIZE,MN_LENGTH(a1)

   lea   TimerName,a0
   moveq #1,d0
   moveq #0,d1
   CALLEXEC OpenDevice
   tst.l d0
   bne.s NoTimerDevice

   lea   TimerPort(a4),a0   ;Get Timers signal
   moveq #0,d0
   move.b   $f(a0),d0
   moveq #1,d1
   asl.l d0,d1
   or.l  d1,signals(a4)
   move.l d1,timerSignal(a4)
   ;bsr.b SetTimer    ;Set timer to interrupt in 2 secs

   moveq #1,d0
NoTimePort:
   rts

NoTimerDevice:
   lea   TimerPort(a4),a0
   moveq #0,d0       ;free signal bit used by port
   move.b   MP_SIGBIT(a2),d0
   move.l   4.w,a6
   jmp   _LVOFreeSignal(a6)
;--------------------------
CloseMyTimer:
   lea   TimerIOreq(a4),a1  ;yes, so abort it
   CALLEXEC AbortIO

   lea   TimerIOreq(a4),a1  ;close timer.device
   CALLEXEC CloseDevice

   lea   TimerPort(a4),a0
   moveq #0,d0       ;free signal bit used by port
   move.b   MP_SIGBIT(a0),d0
   jmp   _LVOFreeSignal(a6)
	dc.b	'$VER: 1.0 10.05.1998 <Andrzej Krynski>',0
;--------------------------
		even
InitList1:
		move.l	#(MEMF_PUBLIC+MEMF_CLEAR),d0
		move.l	#((2*LH_SIZE)+(14*numbernodes)+base_SIZE+4096),d1
		move.l	#1024,d2
		move.l	4.w,a6
		jsr	_LVOCreatePool(a6)
		move.l	a0,d0
		beq.w	exit
		move.l	a0,-(sp)
		move.l	#base_SIZE,d0
		bsr.b	_AllocPooled
		tst.l	d0
		beq.w	delPool
		move.l	d0,a4
		move.l	#LH_SIZE,d0
		bsr.b	_AllocPooled
		tst.l	d0
		beq.w	delPool
		move.l	d0,lista1(a4)
		move.l	#LH_SIZE,d0
		bsr.b	_AllocPooled
		tst.l	d0
		beq.w	delPool
		move.l	d0,lista2(a4)
		move.l	#(14*numbernodes),d0
		bsr.b	_AllocPooled
		tst.l	d0
		beq.w	delPool
		move.l	d0,nody(a4)
		move.l	(sp)+,Pool(a4)
		bra.b 	E2
_AllocPooled:
		move.l	4.w,a6
		addq.l	#4,d0
		move.l	4(sp),a0
		move.l	d0,-(sp)
		jsr	_LVOAllocPooled(a6)
		move.l	(sp)+,d1
		tst.l	d0
		beq.b	fail
		move.l	d0,a0
		move.l	d1,(a0)+
		move.l	a0,d0
fail:		rts

;__________________________________________

;lh_head pokazuje pierwsze pole pierwszej nody okreôlajâce nastëpnâ
;(ln_succ [successor=next]) a lh_TailPred wskazuje na nodë ostatniâ
;drugie pole pierwszej nody (ln_pred [predecessor=previous]) wskazuje
;na listë (lh_head).
;pole ln_succ ostatniej nody ma wskazywaê lh_Tail, które w przypadku
;pojedyïczego sprzëûenia jest równe 0
;__________________________________________

E2:
		lea	LVtags,a1
		move.l	lista1(a4),LVlab(a1)
		move.l	lista2(a4),LV1lab(a1)
		move.l	lista1(a4),a0
		NEWLIST a0
		move.l	lista2(a4),a0
		NEWLIST a0
		move.l	nody(a4),a1
		moveq	#0,d3
		move.w	#LN_SIZE,d3
		lea	nodeNames,a2
		move.l	#numbernodes-1,d1
		move.l	#254,d2
initNode:
		move.b	d2,LN_TYPE(a1)
		move.l	(a2)+,LN_NAME(a1)
		move.l	lista1(a4),a0
		clr.l	d0
		ADDTAIL
		adda.l	d3,a1
		dbeq	d1,initNode

		lea	dosname,a1
		moveq	#39,d0
		move.l	4.w,a6
		jsr	-$228(a6)
		tst.l	d0
		beq.w	exit
		move.l	d0,dosbase(a4)

;LOCALIZE_______
		lea localename,a1
		moveq	#0,d0
		jsr	-$228(a6)
		move.l	d0,localebase(a4)
		move.l	d0,a6
		beq.w	exit
		suba.l	a0,a0	;lea polskitxt,a0 nie dziaîa ani z 'polski'
				;ani z 'polski.language'
		jsr	_LVOOpenLocale(a6)
		move.l	d0,locale(a4)
		beq.w	noLocale
		move.l	d0,a0
		lea	catalogName,a1
		lea	catalogTags,a2
		jsr	_LVOOpenCatalogA(a6)
		move.l	d0,katalog(a4)
		beq.b	nocatalog
		moveq.l	#0,d7
		lea	AppStrings,a3
.loop:
		move.l	katalog(a4),a0
		move.l	4(a3),a1		;default string
		move.l	(a3),d0			;string nr
		jsr	_LVOGetCatalogStr(a6)
		move.l	d0,4(a3)		;adres zamiennika z katalogu
		add.l	#1,d7
		add.l	#8,a3
		cmp.l	#ilewkatalogu,d7
		bne.b	.loop
		bra.b	noLocale
nocatalog:	move.l	#catalogerr,d2
		bsr.b	printfault
		bra.b	noLocale
printfault:	movem.l	d0/d1/a6,-(sp)
		move.l	dosbase(a4),a6
		jsr	_LVOIoErr(a6)
		jsr	_LVOPrintFault(a6)
		movem.l	(sp)+,d0/d1/a6
		rts
catalogerr:	dc.b	'Bîâd funkcji OpenCatalogA()',0
		cnop 0,4
noLocale:
		lea	AppStrings,a3
		lea	STRptrs,a2
		moveq.l	#ilewkatalogu,d0
.wstaw:	move.l	(a2)+,a1
		move.l	4(a3),(a1)
		adda.l	#8,a3
		subq.l	#1,d0
		bne.b	.wstaw

		move.l	#envName,d1
		move.l	#MODE_OLDFILE,d2
		move.l	dosbase(a4),a6
		jsr	-$1e(a6)	;Open prefs
		move.l	d0,fh(a4)
		bne.b	prefOK
		st	oldFile(a4)		
		move.l	#envName,d1
		move.l	#MODE_NEWFILE,d2
		move.l	dosbase(a4),a6
		jsr	-$1e(a6)	;Open
		move.l	d0,fh(a4)
		move.l	fh(a4),d1
		lea	prefsBuffer(a4),a0
		move.l	a0,d2
		move.l	#prefsSize,d3
		jsr	-$30(a6)	;Write
prefOK:
		move.l	fh(a4),d1
		jsr	-$24(a6)	;Close
		pea	TO
		pea	offsetTo
		bsr.w	WritePrefs
		adda.l	#8,sp

		lea	gadname,a1
		moveq	#0,d0
		move.l	4.w,a6
		jsr	-$228(a6)
		move.l	d0,gadbase(a4)
		move.l	d0,a5
		lea	gfxname,a1
		moveq	#0,d0
		jsr	-$228(a6)
		move.l	d0,gfxbase(a4)
		move.l	d0,myData
		lea	intname,a1
		move.l	#0,d0
		jsr	-$228(a6)
		move.l	d0,intbase(a4)
		lea	aslname,a1
		move.l	#0,d0
		jsr	-$228(a6)
		move.l	d0,aslbase(a4)
		move.l	d0,a6
		moveq	#0,d0	; = #ASL_FileRequest,d0
		lea	aslTags,a0
		jsr	_LVOAllocAslRequest(a6)
		move.l	d0,aslRequest(a4)


		move.l	intbase(a4),a6
		lea	screenName,a0
		jsr	-$1fe(a6)	;LockPubScreen=Workbench
		tst.l	d0
		bne.b	ced
		lea	0,a0
		jsr	-$1fe(a6)
ced:	
		lea	public,a1
		move.l	d0,4(a1)
		lea	public1,a0
		move.l	d0,4(a0)
		exg.l	a5,a6
		move.l	d0,a0
		move.l	d0,screen(a4)
		lea	0,a1
		jsr	-$7e(a6)	;GetVisualInfo
		move.l	d0,vi(a4)
		lea	ng_LVmain,a0
		move.l	#numbergadgets-1,d1
		lea	txtattr,a1	
getVI:
		move.l	a1,gng_TextAttr(a0)		
		move.l	d0,gng_VisualInfo(a0)
		adda.l	#gng_SIZEOF,a0
		dbeq	d1,getVI

		lea 	BoxTags,a0
		move.l	d0,4(a0)

		lea	glist(a4),a0
		jsr	-$72(a6)	;createContext
		;move.l	d0,context(a4) ;praktycznie niepotrzebne- nieuûywane
		
		tst.l	oldFile(a4)
		bne.b	createGad
		bsr.w	initBuffers
createGad:
		move.l	glist(a4),a0
		lea	gadTag,a3
		move.l	a0,4(a3)
		
		moveq	#STRING_KIND,d0
		lea	ng_LVstring,a1
		lea	0,a2
		jsr	-$1e(a6)	;creategadget
		move.l	d0,gadzet(a4)
		lea	entry,a0
		move.l	d0,4(a0)
		move.l	d0,a0
		moveq	#LISTVIEW_KIND,d0
		lea	ng_LVmain,a1
		lea	LVtags,a2
		jsr	-$1e(a6)	;creategadget
		move.l	d0,LVptr(a4)

		move.l	d0,a0
		lea	newCycler,a1
		lea	CyclerTags,a2
		move.l	#CYCLE_KIND,D0
		jsr	-$1e(a6)
		move.l	d0,cyclerPtr(a4)
		move.l	d0,a0
		lea	selP,a1
		lea	selTags,a2
		move.l	#CHECKBOX_KIND,D0
		jsr	-$1e(a6)
		move.l	d0,selPPtr(a4)
		move.l	d0,a0
		lea	imageP,a1
		move.l	a1,gg_GadgetRender(a0)
		lea	imagePs,a1
		move.l	a1,gg_SelectRender(a0)
		move.l	d0,a0
		lea	selL,a1
		lea	selTags,a2
		move.l	#CHECKBOX_KIND,D0
		jsr	-$1e(a6)
		move.l	d0,selLPtr(a4)
		move.l	d0,a0
		lea	imageL,a1
		move.l	a1,gg_GadgetRender(a0)
		lea	imageLs,a1
		move.l	a1,gg_SelectRender(a0)
		move.l	d0,a0
		lea	selM,a1
		lea	selTags,a2
		move.l	#CHECKBOX_KIND,D0
		jsr	-$1e(a6)
		move.l	d0,selMPtr(a4)
		move.l	d0,a0
		lea	imageM,a1
		move.l	a1,gg_GadgetRender(a0)
		lea	imageMs,a1
		move.l	a1,gg_SelectRender(a0)
		move.l	d0,a0
		lea	selS,a1
		lea	selTags,a2
		move.l	#CHECKBOX_KIND,D0
		jsr	-$1e(a6)
		move.l	d0,selSPtr(a4)
		move.l	d0,a0
		lea	imageS,a1
		move.l	a1,gg_GadgetRender(a0)
		lea	imageSs,a1
		move.l	a1,gg_SelectRender(a0)


		move.l	d0,a0
		lea	ng_string1,a1
		lea	string1tags,a2
		lea	str1buffer(a4),a3
		move.l	a3,12(a2)
		move.l	#STRING_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,string1ptr(a4)
		
		move.l	d0,a0
		lea	ng_string2,a1
		lea	string2tags,a2
		lea	str2buffer(a4),a3
		move.l	a3,12(a2)
		move.l	#STRING_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,string2ptr(a4)
		
		move.l	d0,a0
		lea	ButtonSave,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButSavePtr(a4)

		move.l	d0,a0
		lea	ButtonShow,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButShowPtr(a4)
		
		move.l	d0,a0
		lea	ButtonAssemble,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButAssPtr(a4)

		move.l	d0,a0
		lea	ButtonFrom,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButFromPtr(a4)

		move.l	d0,a0
		lea	ButtonTo,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButToPtr(a4)

		move.l	d0,a0
		lea	ImageButton,a1
		lea	0,a2
		move.l	#GENERIC_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ImgButPtr(a4)
		
		move.l	d0,a0
		move.w	#GTYP_BOOLGADGET,gg_GadgetType(a0)
		move.w	#GFLG_GADGIMAGE,gg_Flags(a0)
		move.w	#GACT_RELVERIFY,gg_Activation(a0)
		lea	imageFile,a1
		move.l	a1,gg_GadgetRender(a0)

		move.l	d0,a0
		lea	LibString,a1
		lea	0,a2
		move.l	#STRING_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,LibStrPtr(a4)

		move.l	intbase(a4),a6
		lea	0,a0
		lea	taglist,a1
		jsr	-$25e(a6)	;OpenWindowTagList
		move.l	d0,window(a4)
		bsr.w	initCycler
		
		move.l	d0,a0
		move.l	wd_RPort(a0),WRPort(a4)
		move.l	wd_BorderRPort(a0),BRPort(a4)
		move.l	wd_UserPort(a0),a1
		move.l	a1,mainUsrPrt(a4)
		moveq	#0,d0
		moveq	#1,d1
		move.b	$0f(a1),d0
		asl.l	d0,d1
		move.l	d1,signals(a4)
		bsr.w	drawBox
		bsr.w	drawImage
		suba.l	a1,a1
		move.l	gadbase(a4),a6
		jsr	-$54(a6)	;GT_RefreshWindow

		bsr.w   	OpenMyTimer
		tst.l	d0
		beq.b	noTimer

;---------------------------------------
		
loop:		bsr.w	SetTimer
noTimer:	move.l	signals(a4),d0
		move.l	4.w,a6
		jsr	-318(a6)
		move.l	prefSignal(a4),d1
		cmp.l	d0,d1
		beq.w	handlePrefWind
		move.l	timerSignal(a4),d1
		cmp.l	d0,d1
		beq.b	handleTimer
		move.l	mainUsrPrt(a4),a0
		move.l	gadbase(a4),a6
		jsr	-$48(a6)	;GT_GetMsg
		move.l	d0,a1
		beq.b		nomore
		move.l	$14(a1),d2	;class=IDCMP
		move.w	$18(a1),d3	;nr_wëzîa
		move.l	$1c(a1),a3	;IAddress=ActiveGadget
		;move.l	$20(a1),d5	;HW=mouseX LW=mouseY
		jsr	-$4e(a6)	;GTReplyMsg
		cmpi.b	#$40,d2
		beq.w	gadTicked
close:
		cmpi.l	#$200,d2
		beq.b	wyj		
nomore:		bra.b	loop
;-----------------------------------
handleTimer:
         lea   TimerPort(a4),a0   ;Check for timer interrupt
         CALLEXEC GetMsg
         tst.l d0
         beq.b	loop
         bsr.w   zegar
         bra.b	loop

;------------------------------------
delPool:
		move.l	(sp)+,a0
		move.l	4.w,a6
		jsr	_LVODeletePool(a6)
		bra.w	exit
wyj:
		tst.l	prefOpened(a4)
		bne.b	nomore
   	        jsr   CloseMyTimer
		move.l	intbase(a4),a6
		move.l	window(a4),a0
		jsr	-$48(a6)	;CloseWindow
		move.l	gadbase(a4),a6
		move.l	glist(a4),a0
		jsr	-$24(a6)	;GT_FreeGadgets
;zwolnij pamiëê alokowanâ na nody LV gadûetu !!!
		move.l	window1(a4),a2
		move.l	lista2(a4),a0
		move.l	LV1ptr(a4),a3
		bsr.w	FreeLVList
		move.l	gadbase(a4),a6
		move.l	glist1(a4),a0
		jsr	-$24(a6)	;GT_FreeGadgets		
		move.l	vi(a4),a0
		jsr	-$84(a6)	;freeVI?
		move.l	intbase(a4),a6
		move.l	screen(a4),a1
		suba.l	a0,a0
		jsr	-$204(a6)	;UnlockPubScreen
		move.l	a6,a1
		move.l	4.w,a6
		jsr	-$19e(a6)
		move.l	localebase(a4),a6
		move.l	katalog(a4),a0
		beq.b	nocat
		jsr	_LVOCloseCatalog(a6)
nocat:		move.l	locale(a4),a0
		beq.b	noloc
		jsr	_LVOCloseLocale(a6)
noloc:		move.l	a6,a1
		move.l	4.w,a6
		jsr	-$19e(a6)
		move.l	gadbase(a4),a1
		jsr	-$19e(a6)
		move.l	aslRequest(a4),d0
		beq.b	noAsl
		move.l	d0,a0
		move.l	aslbase(a4),a6
		jsr	_LVOFreeAslRequest(a6)
noAsl:		move.l	a6,a1
		move.l	4.w,a6
		jsr	-$19e(a6)
		move.l	dosbase(a4),a1
		jsr	-$19e(a6)
		move.l	gfxbase(a4),a1
		jsr	_LVOCloseLibrary(a6)
		move.l	Pool(a4),a0
		move.l	4.w,a6
		jsr	_LVODeletePool(a6)
exit:	
		movem.l	(sp)+,d0-a6
		moveq	#0,d0
		rts
		
;------------------------------------------------
;     PROCEDURA DO PROGRAMU >ZEGAR<



zegar:
	movem.l	d0-a6,-(sp)
         lea   time_buffer(a4),a0
         move.l   a0,d1
         move.l   a0,-(a7)
         move.l   dosbase(a4),a6
         jsr   -$c0(a6) ;_DateStamp

         move.l   (a7)+,a0
         move.l   4(a0),d0

         move.l   #60,d1
         divu  d1,d0

;         move.l   test(a4),d6
;         beq.b normalny
;         add.w #1,d0

normalny:
         move.w   d0,-(a7) ;godzina(hex)
;PAMIETAJ!Na stosie zapisywane jest  slowo!
;UWAGA SCHODY!
         swap  d0
         move.w   d0,-(a7) ;minuty(hex)
         move.l   8(a0),d0
         move.l   #50,d1
         divu  d1,d0
         move.w   d0,-(a7) ;sekundy(hex)
;stos wyglada teraz tak:
;  SP+  0 1  2 3  4 5  6 7  8 9  a b  c d  e f 10 11 ....
; (sp)= 0009 0018 0015 002f ccc8 .... .... .... ....->adresy wyzsze->
;       sek  min  godz |return  |


;konwersja parametrow czasu z postaci hexadecymalnej na kody ASCII

         lea   godzina,a0
         moveq #0,d4
         moveq #0,d0
         move.w   4(a7),d0
loop1:
         add.w #1,d4 ;licznik petli
         move.l   #$0a,d1
         divu  d1,d0
         move.w   d0,d1
         swap  d0
;---------------------------------------------------------------------------
         move.w   d0,d2
         add.w #$30,d1
         add.w #$30,d2
         move.l   #58,d5
         move.b   d1,(a0)+
         move.b   d2,(a0)+
         move.b   d5,(a0)+
         move.w   d2,-(a7)
;rozbudowanie stosu w gore powoduje, ze pozycja 4(sp) bedzie
;wskazywala wartosc minut w drugim przejsciu petli a wartosc sekund
;w przejsciu trzecim
         moveq #0,d0
         move.w   4(a7),d0
         cmp.w #3,d4
         bne.b loop1
         adda.w   #12,a7

;;wypisanie czasu
         lea   BRPort(a4),a1      ;kolor
	move.l	(a1),a1
         move.l   #1,d0
         move.l   gfxbase(a4),a6
         jsr   -342(a6)		;setApen
         lea   BRPort(a4),a1
         move.l	(a1),a1
         move.w   #190,d0	;x
         move.w   #8,d1		;y
         move.l   gfxbase(a4),a6
         jsr   -$f0(a6)		;move
         lea   BRPort(a4),a1      ;mode
         move.l	(a1),a1
         move.l   #1,d0
         jsr   -$162(a6)
        
         lea   BRPort(a4),a1
         move.l	(a1),a1
         move.l   #godzina,a0
         move.l   #8,d0
         move.l   gfxbase(a4),a6
         jsr   -$3c(a6) ;_Text

         lea   BRPort(a4),a1      ;kolor
         move.l	(a1),a1
         move.l   #1,d0
         move.l   gfxbase(a4),a6
         jsr   -$156(a6)
	movem.l	(sp)+,d0-a6
         rts

handlePrefWind:
		move.l	prefUsrPrt(a4),a0
		move.l	gadbase(a4),a6
		jsr	-$48(a6)	;GT_GetMsg
		move.l	d0,a1
		move.l	$14(a1),d2	;class=IDCMP
		move.l	$18(a1),d3	;nr_wëzîa
		move.l	$1c(a1),a3	;IAddress
		move.l	$2c(a1),d4	;IDCMPWindow
		jsr	-$4e(a6)	;GTReplyMsg
		cmpi.l	#$200,d2
		beq.b	closePrWin
		cmpi.l	#$40,d2
		beq.b	handleButton
		bra.w	loop
closePrWin:
		move.l	intbase(a4),a6
		move.l	window1(a4),a0
		jsr	-$48(a6)	;CloseWindow

		clr.l	prefOpened(a4)
;wlacz gadzet "pokaz preferencje"
		move.l	ButShowPtr(a4),a0
		move.l	window(a4),a1
		lea	0,a2
		lea	enable,a3
		move.l	gadbase(a4),a6
		jsr	-$2a(a6)	;GT_SetGadgetAttrs
		move.l	window(a4),a0
		lea	0,a1
		jsr	-$54(a6)
		bra.w	loop
handleButton:
		move.w	gg_GadgetID(a3),d0
		cmpi.w	#8,d0
		bne.b	.dalej
		move.l	d3,nodeShowID(a4)
.dalej		cmpi.w	#9,d0
		beq.w	killNode
		cmpi.w	#10,d0
		bne.b	.end
		bsr.w	RefreshLV1
		bsr.b	GT_Refresh
.end:		bra.w	loop
GT_Refresh:
		move.l	gadbase(a4),a6
		move.l	window1(a4),a0
		suba.l	a1,a1
		jsr	_LVOGT_RefreshWindow(a6)
		rts
;--------------------------------------
FreeLVList:
		movem.l	d0-a6,-(sp)
		move.l	a0,a1
		move.l	a1,a5
		IFEMPTY	a1,.done
		move.l	a3,a0
		bsr.b	RemoveLVLabels
		move.l	4.w,a6
.loop:		move.l	a5,a0
		jsr	-258(a6)	;RemHead
		tst.l	d0
		beq.b	.done
		move.l	d0,a0		;a0=node
		bsr.b	FreeLVNode
		bra.b	.loop
		
.done:		movem.l	(sp)+,d0-a6
		rts

RemoveLVLabels:
		move.l	GTLV_Labels,d1
		moveq	#-1,d0
		bra.w	SetGadgetTag

SetGadgetTag:
		movem.l	d0-a6,-(sp)
		move.l	a2,a1		;window
		suba.l	a2,a2
		move.l	#0,-(sp)
		move.l	d0,-(sp)
		move.l	d1,-(sp)
		move.l	sp,a3
		move.l	gadbase(a4),a6
		jsr	-42(a6)		;GT_SetGadgetAttrsA()
		lea	12(sp),sp
		movem.l	(sp)+,d0-a6
		rts
FreeLVNode:
		movem.l	d0-a6,-(sp)
		move.l	10(a0),a2	;LN_NAME
.loop:		tst.b	(a2)+
		bne.b	.loop
		move.l	a2,d0
		sub.l	a0,d0
		move.l	a0,a1
		move.l	4.w,a6
		jsr	-210(a6)	;FreeMem
		movem.l	(sp)+,d0-a6
		rts
killNode:
;1.	Pobraê adres podôwietlonego wëzîa listy
;2.	Ze struktury pod tym adresem pobraê offset rekordu preferencji
;	dla tego wëzîa.
;3.	Usunâê wëzeî z listy:
;	a)	zablokowaê listë: a0-gadûet, a2-okno ->bsr RemoveLVLabels
;	b)	usunâê wëzeî z listy
;	c)	zwolniê pamiëê usuwanej struktury: a0-Node->bsr FreeLVNode
;4.	Wyczyôciê rekord w pliku preferencji.
;5.	Przepisaê bufor.
;6.	Odblokowaê listë i odôwieûyê okno.
;w d4 mamy IDCMPWindow

		movem.l	d0-a6,-(sp)

		move.l	nodeShowID(a4),d3
		swap	d3
		and.l	#$f,d3
		move.l	d3,d0
		move.l	lista2(a4),a2
		IFEMPTY a2,.exit
.next:		SUCC a2,a2
		subq.w	#1,d0
		bpl.b	.next	
		move.l	a2,tempNode(a4)	;node addr.
		move.l	LN_SIZE(a2),offsetPtr(a4) ;wskaúnik na offset	
		move.l	window1(a4),a2
		move.l	LV1ptr(a4),a0
		bsr.w	RemoveLVLabels	;a0-gad,a2-wind
		move.l	tempNode(a4),a1
		move.l	a1,a3
		REMOVE
		move.l	a3,a0
		bsr.b	FreeLVNode
		;move.l	emptyBuffer(a4),-(sp)
		pea	emptyBuffer(a4)
		move.l	offsetPtr(a4),-(sp)
		bsr.w	WritePrefs
		adda.l	#8,sp
		bsr.w	clonePrefs
		move.l	LV1ptr(a4),a0
		move.l	d4,a2
		move.l	GTLV_Labels,d1
		move.l	lista2(a4),d0
		bsr.w	SetGadgetTag
		bsr.w	GT_Refresh
		
.exit:		movem.l	(sp)+,d0-a6
		bra.w	loop
;request:	dc.l	GTLV_Selected,selected
;		dc.l	TAG_END
;selected:	dc.l	0		
;--------------------------------------
drawImage:	
		movem.l	d0-a6,-(sp)
		move.l	WRPort(a4),a0
		lea	imageLogo,a1
		moveq.l	#6,d0
		moveq.l	#105,d1
		move.l	intbase(a4),a6
		jsr	_LVODrawImage(a6)
		movem.l	(sp)+,d0-a6
		rts
;--------------------------------------
drawBox:
		movem.l	d0-a6,-(sp)
		move.l	WRPort(a4),a0
		move.l	a0,-(sp)
		moveq	#2,d0
		moveq	#2,d1
		move.l	#((32*8)+16),d2
		move.l	#100,d3
		lea	BoxTags,a1
		move.l	gadbase(a4),a6
		jsr	-$78(a6)
		move.l	(sp),a0
		move.l	#((32*8)+18),d0
		moveq	#2,d1
		move.l	#174,d2
		move.l	#(38+12),d3
		lea	BoxTags,a1
		jsr	-$78(a6)
		move.l	(sp),a0
		move.l	#135,d0
		moveq	#105,d1
		move.l	#313,d2
		move.l	#35,d3
		lea	BoxTags,a1
		jsr	-$78(a6)
		move.l	(sp)+,a0
		move.l	#((32*8)+18),d0
		moveq	#42+12,d1
		move.l	#174,d2
		move.l	#60-12,d3
		lea	BoxTags,a1
		jsr	-$78(a6)
		movem.l	(sp)+,d0-a6
		rts

;--------------------------------------------------------------------
gadTicked:	move.l	d0,-(sp)
		move.w	gg_GadgetID(a3),d0
		cmpi.b	#1,d0
		beq.b	lvTouched
		cmpi.b	#2,d0
		beq.b	LVstring
		cmpi.b	#3,d0
		beq.w	cyclerTouched
		cmpi.b	#4,d0
		beq.w	sourceTouched
		cmpi.b	#5,d0
		beq.w	destinTouched
		cmpi.b	#6,d0
		beq.w	button1touched
		cmpi.b	#7,d0
		beq.w	button2touched
		cmpi.b	#11,d0
		beq.w	parseCommand
		cmpi.b	#12,d0
		beq.w	load
		cmpi.b	#13,d0
		beq.w	save
		move.l	(sp)+,d0
		bra.w	noTimer
reqData:	
		dc.l	-1
;---------------------------------------------------------------------
lvTouched:
		movem.l	d0-a6,-(sp)
		
		and.l	#$0000000f,d3
		move.l	d3,nodeID(a4)
		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
LVstring:
		movem.l	d0-a6,-(sp)
		moveq	#0,d0
		move.l	nodeID(a4),d0	;blokada zapisu preferencji nie
		bmi.b	keyboard	;wystepujacych w LV
		asl.l	#2,d0
		move.l	44(sp),a3
		move.l	$22(a3),a3
		move.l	(a3),a3
		move.l	a3,-(sp)
		lea	offsetASM0,a0
		move.l	(a0,d0.w),-(sp)
		bsr.w	WritePrefs
		adda.l	#8,sp
		neg.l	nodeID(a4)
keyboard:	movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;---------------
cyclerTouched:
		movem.l	d0-a6,-(sp)
		and.l	#$000f,d3
		cmpi.b	#13,d3
		bne.b	shift
		moveq	#0,d3
shift:
		asl.l	#2,d3
		lea	CyclerLabels,a0
		move.l	(a0,d3.w),-(sp)
		move.l	#offsetOpt,-(sp)
		bsr.w	WritePrefs
		adda.l	#8,sp
		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer

;---------------
sourceTouched:	
		movem.l	d0-a6,-(sp)
		move.l	$22(a3),a3	;str.Gadget_SpecialInfo
		move.l	(a3),a3		;str.SpecialInfo_Buffer
		
		move.l	a3,-(sp)
		move.l	#offsetSource,-(sp)
		bsr.w   WritePrefs
		adda.l	#8,sp
		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;---------------
destinTouched:
		movem.l	d0-a6,-(sp)
		move.l	$22(a3),a3	;str.Gadget_SpecialInfo
		move.l	(a3),a3		;str.SpecialInfo_Buffer
		
		move.l	a3,-(sp)
		move.l	#offsetDestin,-(sp)
		bsr.w   WritePrefs
		adda.l	#8,sp
		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;----------------------------------------------------------------------
* zmiana zawartoôci gadûetu odbywa sië nastëpujâco:
* - przepisz bufor asl-requestu lub bezpoôrednio fr_Drawer i rf_File
*   do bufora gadûetu
* - wskaû tagiem GTST_String nowy bufor
* - odôwieû okno
* wsio




load:
		movem.l	d0-a6,-(sp)
		
		lea	str1buffer(a4),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2
		move.l	dosbase(a4),a6
		jsr	_LVOOpen(a6)
		move.l	d0,aslfh(a4)
		beq.b	isDir
		move.l	d0,d1
		jsr	_LVOParentOfFH(a6)
		move.l	d0,-(sp)
		move.l	aslfh(a4),d1
		jsr	_LVOClose(a6)
		move.l	(sp)+,d1
		jsr	_LVOCurrentDir(a6)
		move.l	d0,oldDir(a4)
		bra.b	jes
isDir:
		lea	str1buffer(a4),a0
		move.l	a0,d1
		move.l	#SHARED_LOCK,d2
		jsr	_LVOLock(a6)
		move.l	d0,dirLock(a4)
		move.l	d0,d1
		jsr	_LVOCurrentDir(a6)
		move.l	d0,oldDir(a4)
		move.l	dirLock(a4),d1
		jsr	_LVOUnLock(a6)
jes:		
		lea	tempBuffer(a4),a0
		move.l	a0,d1
		jsr	_LVOGetCurrentDirName(a6)	
		lea	loadTags,a1
		move.l	d0,20(a1)
		lea	loadTxt,a2
		bsr.w	requestAsl
		beq.b	abortLoad

		lea	str1buffer(a4),a1
		move.l	a0,-(sp)
		lea	pathBuffer(a4),a0
		bsr.w	copyString
		move.l	(sp)+,d0
          	move.l 	#GTST_String,d1      ;TAG
          	move.l	window(a4),a2	;okno
          	move.l	string1ptr(a4),a0
		bsr.w	SetGadgetTag
          	
		lea	pathBuffer(a4),a0
		move.l	a0,-(sp)
		move.l	#offsetSource,-(sp)		
		bsr.w	WritePrefs
		adda.l	#8,sp
		
		bsr.w	clonePrefs
	
		move.l	window(a4),a0
		suba.l	a1,a1
		move.l	gadbase(a4),a6
		jsr	_LVOGT_RefreshWindow(a6)
				
abortLoad:	movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;----------------------------------------
save:
		movem.l	d0-a6,-(sp)
		lea	saveTags,a1
		lea	saveTxt,a2
		bsr.b	requestAsl
		beq.b	abortSave

		lea	str2buffer(a4),a1
		move.l	a0,-(sp)
		lea	pathBuffer(a4),a0
		bsr.w	copyString
		move.l	(sp)+,d0
          	move.l 	#GTST_String,d1      ;TAG
          	move.l	window(a4),a2	;okno
          	move.l	string2ptr(a4),a0
		bsr.w	SetGadgetTag
          	
		lea	pathBuffer(a4),a0
		move.l	a0,-(sp)
		move.l	#offsetDestin,-(sp)		
		bsr.w	WritePrefs
		adda.l	#8,sp
		
		bsr.w	clonePrefs
	
		move.l	window(a4),a0
		suba.l	a1,a1
		move.l	gadbase(a4),a6
		jsr	_LVOGT_RefreshWindow(a6)
		
abortSave:	movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;----------------------------------------
requestAsl:

*str1buffer zawiera ôcieûkë z preferencji a pathBuffer jest pusty,
*wiëc ASL ustawi current_dir na "" czyli PROGDIR:!
*Naleûaîo by dla wygody ustawiaê current_dir na ten z str1buffer;
*uniknie sië wtedy takûe przejmowania ôcieûki miëdzy load a save
*(skoro korzystam tylko z jednego bufora ||:-|)
		
		
		move.l	a2,4(a1)
		move.l	aslRequest(a4),a0
		move.l	aslbase(a4),a6
		jsr	_LVOAslRequest(a6)
		tst.l	d0
		beq.b	cancelled
		lea	pathBuffer(a4),a5
		move.l	aslRequest(a4),a0
		move.l	rf_Dir(a0),a1
		move.l	a5,a2
		moveq	#56,d0
.copy:		move.b	(a1)+,(a2)+
		dbeq	d0,.copy
		move.l	a5,d1
		move.l	rf_File(a0),d2
		move.l	#200,d3
		move.l	dosbase(a4),a6
		jsr	_LVOAddPart(a6)
		tst.l	d0
		beq.b	cancelled
		moveq	#-1,d0
		move.l	a5,a0
checksize:	addq.w	#1,d0
		tst.b	0(a0,d0.w)
		bne.b	checksize
		cmpi.w	#37,d0
		ble.b	sizeok
		sub.w	#37,d0
		add.w	d0,a0
sizeok:		st.b	d0
		rts
;----------------------------------------
cancelled:
		suba.l	a0,a0
		sf.b	d0
		rts
;----------------------------------------------------------------------
WritePrefs:
		move.l	#envName,d1
		move.l	#MODE_READWRITE,d2
		move.l	dosbase(a4),a6
		jsr	-$1e(a6)		;Open
		move.l	d0,fh(a4)
		move.l	d0,d1
		move.l	4(sp),d2
		move.l	#OFFSET_BEGINNING,d3
		jsr     -$42(a6)		;Seek
		moveq	#0,d3
		move.l	fh(a4),d1
		move.l	8(sp),d2
		moveq	#0,d3
		move.l	d2,a3
.loop:
		addq.w	#1,d3
		tst.b	(a3)+
		bne.b	.loop
		jsr  	-$30(a6)		;Write
		move.l	fh(a4),d1
		jsr		-$24(a6)		;Close
		rts

;......................................................................
initBuffers:
		movem.l	d0-a6,-(sp)
		bsr.w	clonePrefs
		lea	prefsBuffer(a4),a0
		lea	str1buffer(a4),a1
		move.l	a0,-(sp)
		add.l	#offsetSource,a0
		bsr.b	copyString
		move.l	(sp),a0
		lea	str2buffer(a4),a1
		add.l	#offsetDestin,a0
		bsr.b	copyString
		move.l	(sp),a0
		lea	strOptbuffer(a4),a1
		add.l	#offsetOpt,a0
		bsr.b	copyString

		move.l	(sp)+,a0
		movem.l	(sp)+,d0-a6
		rts
;--------------------------------------
copyString:
		tst.b	(a0)
		beq.b	raus
cop:		move.b	(a0)+,(a1)+
		bne.b	cop
		move.b	(a0),(a1)
raus:		rts

;---------------------------------------
komenda:	dc.b	'PhxAss',0
TO:		dc.b	'TO',0
		even
parseCommand:
		movem.l	d0-a6,-(sp)
		bsr.w	clonePrefs
		clr.l	licznik
		lea	prefsBuffer(a4),wejscie
		lea	bufor_komendy,a1
		move.l	a1,-(sp)
		move.l	#50,d0
		moveq.l	#0,d1
.loop:		move.l	d1,(a1)+
		subq.w  #1,d0
		bne.b	.loop
		move.l	(sp)+,wyjscie
		
		lea	offsety_rekordow,odleglosc
		move.l	wyjscie,-(sp)
		move.l	wejscie,-(sp)
		lea	komenda,a3
		moveq	#6,licznik
.petla		move.b	(a3)+,(wyjscie)+
		subq.b	#1,licznik
		bne.b	.petla
		move.b	#spacja,(wyjscie)+
petla:		clr.l	d1
		move.l	(odleglosc)+,d1
		add.l	(sp),d1
		cmp.l	wejscie,d1
		bne.b	zly_offset
		move.l	d1,wejscie
		cmpi.b	#0,(wejscie)
		beq.b	jest_zero
MalaPetla:	addq.w	#1,licznik
		move.b	(wejscie)+,(wyjscie)+
		beq.b	jest_zero
		bra.b	MalaPetla
jest_zero:	move.b	#spacja,-(wyjscie)
		add.l	#1,wyjscie
		cmpi.l	#2568,(odleglosc)
		beq.b	EOF
		bra.b	petla
zly_offset:	
		cmpi.l	#1768,(odleglosc)
		beq.b	EOF	
		add.l	#1,wejscie
		suba.l	#4,odleglosc
		bra.b	petla
EOF:		
		adda.l	#4,sp
		move.l	dosbase(a4),a6
		jsr	_LVOInput(a6)
		move.l	d0,Input(a4)
		jsr	_LVOOutput(a6)
		move.l	d0,Output(a4)
		move.l	(sp),d1		;bufor_komendy
		adda.l	#4,sp
		lea	SystemTags,a0
		move.l	a0,d2
		move.l	Input(a4),4(a0)
		move.l	Output(a4),12(a0)
		jsr	_LVOSystemTagList(a6)

		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
		rts

;---------------------------------------
AllocLVNode:

;------------------
; a0-ptr na tekst do wpisania w LV
; d0-rozmiar obszaru dodawanego do str. Node
; out: d0,a0 - node or 0


.start:	movem.l	d1-d7/a1-a6,-(sp)
	move.l	a0,a2
	move.l	d0,d7
	moveq	#14,d0			;LN_SIZEOF
	add.l	d7,d0			;+ desired number of bytes
.loop:	addq.l	#1,d0			;+ string size
	tst.b	(a0)+
	bne.b	.loop

	moveq	#1,d1			;even VMem allowed!
	swap	d1			;clear!
	move.l	4.w,a6
	jsr	-198(a6)		;AllocMem()
	tst.l	d0
	beq.s	.done

	move.l	d0,a0
	lea	14(a0,d7.l),a1
	move.l	a1,10(a0)
.loop2:	move.b	(a2)+,(a1)+		;copy string...
	bne.b	.loop2
	tst.l	d0

.done:	move.l	d0,a0
	movem.l	(sp)+,d1-d7/a1-a6
	rts
;---------------------------------------

initCycler:
		movem.l	d0-a6,-(sp)
		lea	strOptbuffer(a4),a0
		move.l	a0,a2
		lea	CyclerLabels,a3
		moveq.l	#-1,d0
nowy:		moveq.l	#5,d1
		move.l	(a3)+,a1
		move.l	a2,a0
		addq.l	#1,d0
porownaj:	subq	#1,d1
		cmpm.b	(a0)+,(a1)+
		beq.b	porownaj
		tst	d1
		beq.b	nowy
identyczne:	
		lea	CyclerRequest,a3
		move.l	d0,4(a3)
		move.l	cyclerPtr(a4),a0
		move.l	window(a4),a1
		suba.l	a2,a2
		move.l	gadbase(a4),a6
		jsr	-$2a(a6)	;GT_SetGadgetAttr
		
		movem.l	(sp)+,d0-a6
		rts
		
;----------------------------------------------------------------------
button1touched:	;zapis preferencji na dysk
		movem.l	d0-a6,-(sp)
		
;here check free store on your disk!
		move.l	#volName,d1
		move.l	#ACCESS_READ,d2
		move.l	dosbase(a4),a6
		jsr	-84(a6)		;Lock all volume
		move.l	d0,key(a4)
		beq.w	ex
		move.l	d0,d1
		lea	infoBuffer(a4),a0
		move.l	a0,d2
		jsr	-114(a6)	;Info
		move.l	key(a4),d1
		jsr	-90(a6)	;Unlock
		lea	infoBuffer(a4),a0
		moveq	#0,d0
		move.l	8(a0),d0
		cmpi.b	#82,d0
		beq.b	enabled
		bra.w	ex
enabled:	move.l	10(a0),d0	;total
		move.l	14(a0),d1	;used
		move.l	18(a0),d2	;block size
		sub.l	d1,d0		;=free
		move.l	d2,d1
		;d0=d0*d1
		movem.l	d1/d2/d3,-(sp)
		move.w	d1,d2
		mulu	d0,d2
		move.l	d1,d3
		swap	d3
		mulu	d0,d3
		swap	d3
		clr.w	d3
		add.l	d3,d2
		swap	d0
		mulu	d1,d0
		swap	d0
		clr.w	d0
		add.l	d2,d0
		movem.l	(sp)+,d1/d2/d3
		and.l	#$fffffff,d0
		subi.l	#1024+prefsSize,d0
		ble.b	ex
		bsr.b	clonePrefs
		move.l	#prefsName,d1
		move.l	#MODE_READWRITE,d2
		jsr	-$1e(a6)	;Open\Create disk prefs file
		move.l	d0,filehdl(a4)
		move.l	d0,d1
		jsr	-372(a6)
		move.l	d0,key(a4)
		move.l	filehdl(a4),d1	;to where
		lea	prefsBuffer(a4),a0	;from where
		move.l	a0,d2
		move.l	#prefsSize,d3	;how much bytes
		jsr	-$30(a6)	;Write
		move.l	filehdl(a4),d1
		jsr	-$24(a6)	;Close
		move.l	key(a4),d1
		jsr	-90(a6)
ex:		movem.l	(sp)+,d0-a6
		move.l	(sp)+,d0
		bra.w	noTimer
;--------------------------------------		
clonePrefs:	equ *

		move.l	#envName,d1
		move.l	#MODE_OLDFILE,d2
		move.l	dosbase(a4),a6
		jsr	-$1e(a6)	;Open temporary prefs
		move.l	d0,filehdl(a4)
		move.l	d0,d1
		jsr	-372(a6)
		move.l	d0,key(a4)
		move.l	filehdl(a4),d1
		lea	prefsBuffer(a4),a0
		move.l	a0,d2
		move.l	#prefsSize,d3
		jsr	-$2a(a6)	;Read prefs to buffer
		move.l	filehdl(a4),d1
		jsr	-$24(a6)	;Close temporary
		move.l	key(a4),d1
		jsr	-90(a6)

		rts
;---------------------------------------------------------------------
button2touched:	;okno ustawionych preferencji
		tst.l	prefOpened(a4)
		bne.w	otwarte
		movem.l	d0-a6,-(sp)
		lea	glist1(a4),a0
		move.l	gadbase(a4),a6
		jsr	-$72(a6)	;CreateContext
		move.l	glist1(a4),a0
		lea	win1tags,a3
		move.l	a0,4(a3)
		moveq	#LISTVIEW_KIND,d0
		lea	ng_LVshow,a1
		lea	LV1tags,a2
		jsr	-$1e(a6)	;creategadget
		move.l	d0,LV1ptr(a4)
		move.l	d0,a0
		lea	ButtonRemove,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButRemovePtr(a4)
		move.l	d0,a0
		lea	ButtonRefresh,a1
		lea	0,a2
		move.l	#BUTTON_KIND,d0
		jsr	-$1e(a6)
		move.l	d0,ButRefreshPtr(a4)
		lea	0,a0
		lea	win1tags,a1
		move.l	intbase(a4),a6
		jsr	-$25e(a6)	;OpenWindowTagList
		move.l	d0,window1(a4)
		move.l	d0,a0
		move.l	$56(a0),a1
		move.l	a1,prefUsrPrt(a4)
		moveq	#0,d0
		moveq	#1,d1
		move.b	$0f(a1),d0
		asl.l	d0,d1
		or.l	d1,signals(a4)
		move.l	d1,prefSignal(a4)
		move.l	#1,prefOpened(a4)
		bsr.b	RefreshLV1
;wylacz gadzet "pokaz preferencje"
		move.l	ButShowPtr(a4),a0
		move.l	window(a4),a1
		lea	0,a2
		lea	disable,a3
		move.l	gadbase(a4),a6
		jsr	-$2a(a6)	;GT_SetGadgetAttrs
		move.l	window1(a4),a0
		lea	0,a1
		jsr	-$54(a6)	

		movem.l	(sp)+,d0-a6
otwarte:	move.l	(sp)+,d0
		bra.w	loop
;--------------------------------------------
RefreshLV1:
		movem.l	d0-a6,-(sp)
;przed otworzeniem okna trzeba zaktualizowac liste LV gadzetu
.here:		equ *		
		jsr	(clonePrefs-.here)(pc)
		move.l	window1(a4),a2
		move.l	lista2(a4),a0
		move.l	LV1ptr(a4),a3
		bsr.w	FreeLVList
		lea	prefsBuffer(a4),a0
		move.l	a0,-(sp)
		lea	offsetASM0,a5
nextOffset:	move.l	(a5)+,d0
		bmi.b	offsetEnd
		move.l	(sp),a0
		adda.l	d0,a0
		tst.b	(a0)
		beq.b	nextOffset
		move.l	d0,d1
		moveq	#4,d0		;extra buffer to add after Node str.
		bsr.w	AllocLVNode
		move.l	lista2(a4),a0
		move.l	d0,a1
		move.l	d1,LN_SIZE(a1)
		clr.l	d0
		ADDTAIL
		bra.b	nextOffset		
offsetEnd:
		move.l	LV1ptr(a4),a0
		move.l	window1(a4),a1
		lea	0,a2
		lea	LV1tags,a3
		move.l	gadbase(a4),a6
		jsr	-$2a(a6)
		move.l	(sp)+,a0
		movem.l	(sp)+,d0-a6
		rts			
;......................................................................
BackfillHookCode:
		movem.l	d2-d7/a3-a6,-(sp)
		move.l	(a1)+,a0		;get the layer
		moveq.l	#0,d2
		move.w	ra_MinX(a1),d2
		moveq	#0,d3
		move.w	ra_MinY(a1),d3
		moveq	#0,d4
		move.w	ra_MaxX(a1),d4
		sub.l	d2,d4
		addq.l	#1,d4			;get x size
		moveq	#0,d5
		move.w	ra_MaxY(a1),d5
		sub.l	d3,d5
		addq.l	#1,d5			;get y size
		move.l	d2,d0			;x source
		move.l	d3,d1			;y source
		move.l	#$30,d6			;minterm
		moveq.l	#3,d7			;maska-jakby mapa o kolorze nr.
		move.l	rp_BitMap(a2),a1	;destination bitmap
		move.l	a1,a0			;source bitmap
		move.l	myData,a6
		jsr	_LVOBltBitMap(a6)
		movem.l	(sp)+,d2-d7/a3-a6
		rts

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		section dane,data_p
bufor_komendy:	blk.b	200,0
taglist:
gadTag:		
		dc.l	WA_Gadgets,0
		dc.l	WA_Left,180
		dc.l	WA_Top,95
		dc.l	WA_Width,460
		dc.l	WA_Height,156
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW+LISTVIEWIDCMP+CYCLEIDCMP+STRINGIDCMP
		dc.l	WA_Flags,WINDOWDRAG+WINDOWCLOSE+WINDOWDEPTH+GIMMEZEROZERO
		dc.l	WA_Title,wtyt
		dc.l	WA_ScreenTitle,styt
		dc.l	WA_Activate,1
		dc.l	WA_AutoAdjust,1
		dc.l	WA_BackFill,BackfillHookStr
		dc.l	WA_NoCareRefresh,1
public:	
		dc.l	WA_PubScreen,0
		dc.l	TAG_END

BackfillHookStr:
		ds.b	MLN_SIZE
		dc.l	BackfillHookCode
		dc.l	0
myData:		dc.l	0
win1tags:		
		dc.l	WA_Gadgets,0
		dc.l	WA_Left,1
		dc.l	WA_Top,95
		dc.l	WA_Width,180
		dc.l	WA_Height,156
		dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW+LISTVIEWIDCMP
		dc.l	WA_Flags,WINDOWDRAG+WINDOWCLOSE+WINDOWDEPTH+NOCAREREFRESH+GIMMEZEROZERO ;+WINDOWSIZING+SIZEBRIGHT
		dc.l	WA_Title,w1tyt
		dc.l	WA_Activate,0
		dc.l	WA_AutoAdjust,1
public1:	
		dc.l	WA_PubScreen,0
		dc.l	TAG_END

imageLogo:
		dc.w  0,0,127,49,8
		dc.l  imagedataLogo
		dc.b  -1,-1
		dc.l  0

imageFile:
  dc.w  0,0,13,13,8
  dc.l  imagedataFile
  dc.b  -1,-1
  dc.l  0
imageP:
  dc.w  0,0,12,12,8
  dc.l  imagedataP
  dc.b  -1,-1
  dc.l  0
imagePs:
  dc.w  0,0,12,12,8
  dc.l  imagedataPs
  dc.b  -1,-1
  dc.l  0
imageL:
  dc.w  0,0,12,12,8
  dc.l  imagedataL
  dc.b  -1,-1
  dc.l  0
imageLs:
  dc.w  0,0,12,12,8
  dc.l  imagedataLs
  dc.b  -1,-1
  dc.l  0
imageM:
  dc.w  0,0,12,12,8
  dc.l  imagedataM
  dc.b  -1,-1
  dc.l  0
imageMs:
  dc.w  0,0,12,12,8
  dc.l  imagedataMs
  dc.b  -1,-1
  dc.l  0
imageS:
  dc.w  0,0,12,12,8
  dc.l  imagedataS
  dc.b  -1,-1
  dc.l  0
imageSs:
  dc.w  0,0,12,12,8
  dc.l  imagedataSs
  dc.b  -1,-1
  dc.l  0

LVtags:
		dc.l	GTLV_Labels
LVlab:		equ	*-LVtags
		dc.l	0		
entry:
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_END
LV1tags:
		dc.l	GTLV_Labels
LV1lab:		equ	*-LVtags
		dc.l	-1
		dc.l	GTLV_ShowSelected,0
		dc.l	TAG_END		
CyclerTags:
		dc.l	GTCY_Labels,CyclerLabels
		dc.l	TAG_END
CyclerRequest:	
		dc.l	GTCY_Active,0
		dc.l	TAG_END		
string1tags:
		dc.l	GA_Immediate,1
		dc.l	GTST_String,0
		dc.l	STRINGA_ReplaceMode,1
		dc.l	GTST_MaxChars,80
		dc.l	STRINGA_Justification,STRINGLEFT
		dc.l	TAG_END
string2tags:
		dc.l	GA_Immediate,1
		dc.l	GTST_String,0
		dc.l	STRINGA_ReplaceMode,1
		dc.l	GTST_MaxChars,80
		dc.l	STRINGA_Justification,STRINGLEFT
		dc.l	TAG_END
requestTag:
		dc.l 	GTLV_Selected,nodeID
		dc.l	TAG_END

BoxTags:
		dc.l	GT_VisualInfo,0
		dc.l	GTBB_FrameType,BBFT_RIDGE 
		dc.l	GTBB_Recessed,1
		dc.l	TAG_END
disable:
		dc.l	GA_Disabled,1
		dc.l	TAG_END
enable:
		dc.l	GA_Disabled,0
		dc.l	TAG_END		
SystemTags:
		dc.l	SYS_Input,0
		dc.l	SYS_Output,0
		dc.l	TAG_END
aslTags:
		dc.l	ASL_Height,200
		dc.l	ASL_Width,340
		dc.l	TAG_DONE
loadTags:
		dc.l	ASL_Hail,0
		dc.l	ASL_FuncFlags,FILF_PATGAD
		dc.l	ASLFR_InitialDrawer,0
		dc.l	TAG_DONE
saveTags:
		dc.l	ASL_Hail,0
		dc.l	ASL_FuncFlags,FILF_SAVE+FILF_PATGAD
		dc.l	TAG_DONE

selTags:	dc.l	GTCB_Scaled,1
		dc.l	TAG_END

catalogTags:
		;dc.l	OC_Language,0
		dc.l	OC_BuiltInLanguage,englishtxt
		dc.l	TAG_END
offsety_rekordow:
		dc.l	offsetSource,offsetTo,offsetDestin,offsetOpt
offsetASM0:
		dc.l	168,248,328,408,488,568,668,728,808,888
		dc.l	968,1048,1128,1208,1288,1368,1448,1528,1608,1688
		dc.l	1768,1848,1928,2008,2088,2168,2248,2328,2408,2488
		dc.l	2568,-1


ng_LVmain:
		dc.w	11,20
		dc.w	32*8,50
STR_text:	dc.l	0
		dc.l	0
		dc.w	1
		dc.l	$24
		dc.l    0
		dc.l	0
		
ng_LVstring:
		dc.w	11,80
		dc.w	32*8,12
		dc.l	0
		dc.l	0
		dc.w	2
		dc.l	1
		dc.l    0
		dc.l	0
newCycler:
		dc.w	285,20
		dc.w	19*8,16
STR_cyclerTxt:	dc.l	0
		dc.l	0
		dc.w	3
		dc.l	$24
		dc.l	0
		dc.l	0
ng_string1:
		dc.w	44+8,74
		dc.w	27*8,12
		dc.l	0	;str1txt
		dc.l	0
		dc.w	4
		dc.l	0	;$21
		dc.l	0
		dc.l	0
ng_string2:
		dc.w	44+8,(74+12)
		dc.w	27*8,12
		dc.l	0	;str2txt
		dc.l	0
		dc.w	5
		dc.l	0	;$21
		dc.l	0
		dc.l	0
ButtonSave:
		dc.w	285,48+10
		dc.w	19*8,12
STR_but1txt:	dc.l	0
		dc.l	0
		dc.w	6
		dc.l	PLACETEXT_IN+NG_HIGHLABEL
		dc.l	0
		dc.l	0
ButtonShow:
		dc.w	285,48+14+10
		dc.w	19*8,12
STR_but2txt:	dc.l	0
		dc.l	0
		dc.w	7
		dc.l	PLACETEXT_IN+NG_HIGHLABEL
		dc.l	0
		dc.l	0
ng_LVshow:
		dc.w	1,1
		dc.w	180-10,90
		dc.l	0
		dc.l	0
		dc.w	8
		dc.l	0
		dc.l    0
		dc.l	0
ButtonRemove:
		dc.w	1,86
		dc.w	86,12
STR_butRemtxt:	dc.l	0
		dc.l	0
		dc.w	9
		dc.l	PLACETEXT_IN
		dc.l	0
		dc.l	0
ButtonRefresh:
		dc.w	87,86
		dc.w	84,12
STR_butReftxt:	dc.l	0
		dc.l	0
		dc.w	10
		dc.l	PLACETEXT_IN
		dc.l	0
		dc.l	0				
ButtonAssemble:
		dc.w	285,48+14+14+10
		dc.w	19*8,12
STR_butAsstxt:	dc.l	0
		dc.l	0
		dc.w	11
		dc.l	PLACETEXT_IN
		dc.l	0
		dc.l	0
ButtonFrom:
		dc.w	6,74
		dc.w	(6*8)-2,12
STR_str1txt:	dc.l	0
		dc.l	0
		dc.w	12
		dc.l	PLACETEXT_IN
		dc.l	0
		dc.l	0
ButtonTo:
		dc.w	6,74+12
		dc.w	(6*8)-2,12
STR_str2txt:	dc.l	0
		dc.l	0
		dc.w	13
		dc.l	PLACETEXT_IN
		dc.l	0
		dc.l	0
ImageButton:
		dc.w	190,110
		dc.w	13,13
		dc.l	0
		dc.l	0
		dc.w	14
		dc.l	0
		dc.l	0
		dc.l	0
LibString:
		dc.w	205,110
		dc.w	20*8,12
		dc.l	LibTxt
		dc.l	0
		dc.w	15
		dc.l	PLACETEXT_LEFT
		dc.l	0
		dc.l	0
selP:
		dc.w	285,20+17
		dc.w	12,12
		dc.l	0
		dc.l	0
		dc.w	16
		dc.l	$24
		dc.l	0
		dc.l	0

selL:
		dc.w	285+14,20+17
		dc.w	12,12
		dc.l	0
		dc.l	0
		dc.w	17
		dc.l	$24
		dc.l	0
		dc.l	0

selM:
		dc.w	285+14+14,20+17
		dc.w	12,12
		dc.l	0
		dc.l	0
		dc.w	16
		dc.l	$24
		dc.l	0
		dc.l	0

selS:
		dc.w	285+14+14+14,20+17
		dc.w	12,12
		dc.l	0
		dc.l	0
		dc.w	16
		dc.l	$24
		dc.l	0
		dc.l	0



nodeNames:
		dc.l	node0name
		dc.l	node1name
		dc.l	node2name
		dc.l	node3name
		dc.l	node4name
		dc.l	node5name
		dc.l	node6name
		dc.l	node7name
		dc.l	node8name
		dc.l	node9name
		dc.l	node10name
		dc.l	node11name
		dc.l	node12name
		dc.l	node13name
		dc.l	node14name
		dc.l	node15name
		dc.l	node16name
		dc.l	node17name
		dc.l	node18name
		dc.l	node19name
		dc.l	node20name
		dc.l	node21name
		dc.l	node22name
		dc.l	node23name
		dc.l	node24name
		dc.l	node25name
		dc.l	node26name
		dc.l	node27name
		dc.l	node28name
		dc.l	node29name

CyclerLabels:	dc.l	cl1
		dc.l	cl2
		dc.l	cl3
		dc.l	cl4
		dc.l	cl5
		dc.l	cl6
		dc.l	cl7
		dc.l	cl8
		dc.l	cl9
		dc.l	cl10
		dc.l	cl11
		dc.l	cl12
		dc.l	cl13
		dc.l	0
;--------------------- LOCALE -------------------------
AppStrings:
	dc.l	str1txt,	str1txt_STR
	dc.l	str2txt,	str2txt_STR
	dc.l	text,		text_STR
	dc.l	cyclerTxt,	cyclerTxt_STR
	dc.l	but1txt,	but1txt_STR
	dc.l	but2txt,	but2txt_STR
	dc.l	butAsstxt,	butAsstxt_STR
	dc.l	butRemtxt,	butRemtxt_STR
	dc.l	butReftxt,	butReftxt_STR
STRptrs:
	dc.l	STR_str1txt
	dc.l	STR_str2txt
	dc.l	STR_text
	dc.l	STR_cyclerTxt
	dc.l	STR_but1txt
	dc.l	STR_but2txt
	dc.l	STR_butAsstxt
	dc.l	STR_butRemtxt
	dc.l	STR_butReftxt
;------------------------------------------------------

cl1:		dc.b	'OPT 0',0
cl2:		dc.b	'OPT *',0
cl3:		dc.b	'OPT !',0
cl4:		dc.b	'OPT N',0
cl5:		dc.b	'OPT R',0
cl6:		dc.b	'OPT Q',0
cl7:		dc.b	'OPT B',0
cl8:		dc.b	'OPT T',0
cl9:		dc.b	'OPT L',0
cl10:		dc.b	'OPT P',0
cl11:		dc.b	'OPT S',0
cl12:		dc.b	'OPT M',0
cl13:		dc.b	'OPT I',0
wtyt:		dc.b	'GUI4PhxAss',0
w1tyt:		dc.b	'Prefs',0
styt:		dc.b	'Gui4PhxAss v1.0 by Andrzej Krynski <www.polbox.com/t/tichy/>',0
intname:	dc.b	'intuition.library',0
gadname:	dc.b	'gadtools.library',0
dosname:	dc.b	'dos.library',0
gfxname:	dc.b	'graphics.library',0
aslname:	dc.b	'asl.library',0
localename:	dc.b	'locale.library',0

LibTxt:		dc.b	'Lib.:  ',0
str1txt_STR:	dc.b	'FROM:',0
str2txt_STR:	dc.b	'  TO:',0
text_STR:	dc.b	'ASSEMBLE with ...',0
cyclerTxt_STR:	dc.b	'OPTIMIZE with ...',0
but1txt_STR:	dc.b	' SAVE PREFS ',0
but2txt_STR:	dc.b	' SHOW PREFS ',0
butAsstxt_STR:	dc.b	'ASSEMBLE',0
butRemtxt_STR:	dc.b	' REMOVE ',0
butReftxt_STR:	dc.b	'REFRESH',0

node0name:	dc.b	'LIST <name>',0
node1name:	dc.b	'EQU <name>',0
node2name:	dc.b	'I=INCPATH <path1[,path2,...]>',0
node3name:	dc.b	'H=HEADINC <name1[,name2,...]>',0
node4name:	dc.b	'PAGE=<n>',0
node5name:	dc.b	'ERRORS=<max errors>',0
node6name:	dc.b	'RC=ERRCODE=<n>',0
node7name:	dc.b	'SD=SMALLDATA <basReg>[,<sec>]',0
node8name:	dc.b	'SC=SMALLCODE',0
node9name:	dc.b	'LARGE',0
node10name:	dc.b	'VERBOSE',0
node11name:	dc.b	'DS=SYMDEBUG',0
node12name:	dc.b	'DL=LINEDEBUG',0
node13name:	dc.b	'A=ALIGN',0
node14name:	dc.b	'C=CASE',0
node15name:	dc.b	'XREFS',0
node16name:	dc.b	'Q=QUIET',0
node17name:	dc.b	'NOWARN',0
node18name:	dc.b	'SET <symbol[=value]>',0
node19name:	dc.b	'NOEXE',0
node20name:	dc.b	'MACHINE=<cpu>',0
node21name:	dc.b	'FPU=<fpuID>',0
node22name:	dc.b	'PMMU',0
node23name:	dc.b	'BUFSIZE=<size>',0
node24name:	dc.b	'GH=GLOBHASHTAB=<size>',0
node25name:	dc.b	'LH=LOCHASHTAB=<size>',0
node26name:	dc.b	'MH=MNEMOHASHTAM=<size>',0
node27name:	dc.b	'SHOWOPT',0
node28name:	dc.b	'PRI=<-10...+10>',0
node29name:	dc.b	'EXE',0

screenName:	dc.b	'CygnusEdScreen1',0
envName:	dc.b	'RAM:ENV/PhxAss/GUI4PhxAss.prefs',0
prefsName:	dc.b	'SYS:Prefs/Env-Archive/PhxAss/GUI4PhxAss.prefs',0
volName:	dc.b	'SYS:',0
freeMessage:	dc.b	'Na dysku jest %lu bajtow wolnej przestrzeni',0
outputName:	dc.b	'CON:10/10/300/100/GUI4PhxAss/CLOSE',0
loadTxt:	dc.b	'Load source',0
saveTxt:	dc.b	'Save executable/object',0
catalogName:	dc.b	'PhxGUI.catalog',0
englishtxt:	dc.b	'english',0
TimerName:	dc.b  'timer.device',0

		even
txtattr:	dc.l	fontname
		dc.w	8
		dc.b	2
		dc.b	0
fontname:	dc.b	'topaz.font',0


		section obrazek,data_c
; VR2:GFX/ts.asm ---Output data from Iconian 3--- Contact crandall@msen.com for hints, errors, or flames!
imagedataLogo:
; Plane
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$81FE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$7EFE
  dc.w  $FFC0,$0000,$C007,$FF01,$FFFF,$FFFF,$FFFF,$04FE
  dc.w  $FFBF,$FFFE,$BFFF,$FFFF,$FFFF,$FFFF,$FFFF,$5AFE
  dc.w  $FF50,$0000,$C007,$FE01,$FFFF,$FFFF,$FFFF,$46FE
  dc.w  $FFBE,$FFFF,$1FFF,$FE3F,$FFFF,$FFFF,$FFFF,$5AFE
  dc.w  $FFFE,$A002,$9FFF,$FE7F,$FFFF,$FFFF,$FFFF,$5EFE
  dc.w  $FFFD,$FFFB,$3FFF,$FE7E,$7FFF,$FFFF,$FFFF,$81FE
  dc.w  $FFFD,$0006,$3FFF,$FC7F,$FFFF,$FE3F,$FF7F,$FFFE
  dc.w  $FFFB,$BFFC,$7FFF,$FCFC,$7CFF,$3D1F,$9CC7,$FFFE
  dc.w  $FFFA,$801C,$0060,$0C0C,$7BFF,$F01F,$FB81,$FFFE
  dc.w  $FFF7,$FFDF,$FFFF,$B9FC,$18FF,$331F,$B839,$FFFE
  dc.w  $FFF4,$003C,$0040,$4C0B,$F9FE,$639F,$B34D,$FFFE
  dc.w  $FFF7,$FFFF,$F8AF,$19F9,$F1CE,$479E,$0EBD,$FFFE
  dc.w  $FFEE,$00FF,$FC8E,$B1F1,$F3CE,$4F1F,$5E61,$FFFE
  dc.w  $FFEA,$01FF,$F11F,$33F3,$F38C,$0F3F,$3D41,$FFFE
  dc.w  $FFDD,$FFFF,$E91C,$63F3,$F39C,$8F3E,$7C87,$FFFE
  dc.w  $FFD3,$FF80,$0202,$67E7,$FF4C,$9E3C,$7E3F,$FFFE
  dc.w  $FFBB,$FFFF,$F7FC,$E7E6,$7E8C,$DC3E,$FE7F,$FFFE
  dc.w  $FFA7,$FFC0,$0600,$C7F0,$EF24,$D13E,$FC7D,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$CFE8,$7661,$CD0C,$FC21,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$8FF0,$F87D,$E7FC,$FE03,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$8FFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
; Plane
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFE,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFDF,$FFFF,$C007,$FF01,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFF0,$0000,$C007,$FF01,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$DFFF,$FF3F,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$DFFB,$9FFF,$FE7F,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$C003,$BFFF,$FE7F,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$C006,$3FFF,$FE7E,$7FFF,$FD7F,$FFFF,$FFFE
  dc.w  $FFFF,$FFFE,$7FFF,$FEFE,$7FFF,$FC3F,$FFFB,$FFFE
  dc.w  $FFFF,$7FDF,$FFFF,$FDFE,$7CFF,$383F,$9C81,$FFFE
  dc.w  $FFFF,$003C,$0160,$4C0F,$FCFF,$3B1F,$3084,$FFFE
  dc.w  $FFFE,$003C,$0360,$080C,$19FF,$739F,$2108,$FFFE
  dc.w  $FFFC,$FFFF,$F8CF,$99F9,$F9FE,$479F,$4638,$FFFE
  dc.w  $FFFD,$FFFF,$F8CF,$33F9,$FBEE,$6FBE,$0E70,$FFFE
  dc.w  $FFF8,$01FF,$F99E,$33FB,$F3EE,$CF3E,$1C01,$FFFE
  dc.w  $FFFB,$FFFF,$FB9E,$77F3,$F3EE,$9F3E,$7C0F,$FFFE
  dc.w  $FFFF,$FFFF,$FBFC,$67FF,$E784,$CE3E,$7C7F,$FFFE
  dc.w  $FFE7,$FFC0,$0600,$E7FF,$E306,$CCFC,$7C7F,$FFFE
  dc.w  $FFEF,$FFC0,$0600,$CFEF,$6020,$CCFC,$7CFB,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$CFE6,$7060,$C1FC,$FCF3,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$CFF0,$F871,$E304,$FE03,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$9FFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
  dc.w  $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFE
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0060,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $00C0,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0040,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$7E00
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$8100
  dc.w  $001F,$FFFE,$3FF8,$007E,$0000,$0000,$0000,$FB00
  dc.w  $0020,$0000,$0000,$0000,$0000,$0000,$0000,$A500
  dc.w  $0070,$0000,$4000,$0000,$0000,$0000,$0000,$B900
  dc.w  $0001,$2000,$0000,$0000,$0000,$0000,$0000,$A500
  dc.w  $0001,$5FF8,$8000,$0000,$0000,$0000,$0000,$A100
  dc.w  $0002,$4001,$0000,$0000,$8000,$0000,$0000,$7E00
  dc.w  $0002,$8000,$0000,$0000,$0000,$0140,$0080,$0000
  dc.w  $0004,$8002,$0000,$0000,$0300,$C020,$6338,$0000
  dc.w  $0005,$7FC3,$FF9F,$F1F0,$0000,$0020,$0400,$0000
  dc.w  $0009,$0000,$0100,$4403,$E000,$0000,$0084,$0000
  dc.w  $000A,$0000,$0220,$0000,$0000,$0000,$0000,$0000
  dc.w  $0008,$0000,$0040,$8000,$0030,$0001,$4000,$0000
  dc.w  $0015,$FF00,$0001,$0200,$0020,$00A0,$0010,$0000
  dc.w  $0010,$0000,$0080,$0000,$0060,$8000,$0000,$0000
  dc.w  $0020,$0000,$1A02,$1400,$0060,$1000,$0000,$0000
  dc.w  $002C,$007F,$F9FC,$0008,$0080,$0002,$0000,$0000
  dc.w  $0044,$0040,$0000,$0019,$8102,$00C0,$0000,$0000
  dc.w  $0048,$0040,$0000,$080F,$0000,$0CC0,$0000,$0000
  dc.w  $0000,$0000,$0000,$0006,$0000,$00F0,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$1000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$7E00
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$8100
  dc.w  $003F,$FFFF,$3FF8,$00FE,$0000,$0000,$0000,$FB00
  dc.w  $005F,$FFFF,$7FF8,$00FE,$0000,$0000,$0000,$A500
  dc.w  $00AF,$FFFF,$3FF8,$01FE,$0000,$0000,$0000,$B900
  dc.w  $0041,$C000,$E000,$01C0,$0000,$0000,$0000,$A500
  dc.w  $0001,$FFFD,$6000,$0180,$0000,$0000,$0000,$A100
  dc.w  $0003,$BFFC,$C000,$0181,$8000,$0000,$0000,$7E00
  dc.w  $0003,$FFF9,$C000,$0381,$8000,$03C0,$0080,$0000
  dc.w  $0007,$4003,$8000,$0303,$8300,$C3E0,$633C,$0000
  dc.w  $0007,$FFE3,$FF9F,$F3F3,$8700,$CFE0,$677E,$0000
  dc.w  $000E,$FFE3,$FE9F,$F7F3,$E700,$CCE0,$CFFF,$0000
  dc.w  $000F,$FFC3,$FFBF,$F7F7,$E601,$9C60,$DEF7,$0000
  dc.w  $000F,$0000,$0770,$E606,$0E31,$B861,$F9C7,$0000
  dc.w  $001B,$FF00,$0771,$CE0E,$0C31,$B0E1,$F19F,$0000
  dc.w  $001F,$FE00,$0EE1,$CC0C,$0C73,$F0C1,$E3FE,$0000
  dc.w  $003E,$0000,$16E3,$9C0C,$0C73,$70C1,$83F8,$0000
  dc.w  $003C,$007F,$FDFF,$9818,$18FB,$71C3,$83C0,$0000
  dc.w  $007C,$003F,$F9FF,$1819,$9DFB,$33C3,$8380,$0000
  dc.w  $0078,$003F,$F9FF,$381F,$9FDF,$3FC3,$8386,$0000
  dc.w  $0000,$0000,$0000,$301F,$8F9F,$3EF3,$03DE,$0000
  dc.w  $0000,$0000,$0000,$700F,$078E,$1CFB,$01FC,$0000
  dc.w  $0000,$0000,$0000,$7000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$7E00
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$8100
  dc.w  $003F,$FFFF,$3FF8,$00FE,$0000,$0000,$0000,$FB00
  dc.w  $003F,$FFFF,$7FF8,$00FE,$0000,$0000,$0000,$A500
  dc.w  $000F,$FFFF,$3FF8,$01FE,$0000,$0000,$0000,$B900
  dc.w  $0001,$C000,$E000,$01C0,$0000,$0000,$0000,$A500
  dc.w  $0001,$FFFD,$6000,$0180,$0000,$0000,$0000,$A100
  dc.w  $0003,$BFFC,$C000,$0181,$8000,$0000,$0000,$7E00
  dc.w  $0003,$FFF9,$C000,$0381,$8000,$03C0,$0080,$0000
  dc.w  $0007,$4003,$8000,$0303,$8300,$C3E0,$633C,$0000
  dc.w  $0007,$FFE3,$FF9F,$F3F3,$8700,$CFE0,$677E,$0000
  dc.w  $000E,$FFE3,$FE9F,$F7F3,$E700,$CCE0,$CFFF,$0000
  dc.w  $000F,$FFC3,$FFBF,$F7F7,$E601,$9C60,$DEF7,$0000
  dc.w  $000F,$0000,$0770,$E606,$0E31,$B861,$F9C7,$0000
  dc.w  $001B,$FF00,$0771,$CE0E,$0C31,$B0E1,$F19F,$0000
  dc.w  $001F,$FE00,$0EE1,$CC0C,$0C73,$F0C1,$E3FE,$0000
  dc.w  $003E,$0000,$16E3,$9C0C,$0C73,$70C1,$83F8,$0000
  dc.w  $003C,$007F,$FDFF,$9818,$18FB,$71C3,$83C0,$0000
  dc.w  $007C,$003F,$F9FF,$1819,$9DFB,$33C3,$8380,$0000
  dc.w  $0078,$003F,$F9FF,$381F,$9FDF,$3FC3,$8386,$0000
  dc.w  $0000,$0000,$0000,$301F,$8F9F,$3EF3,$03DE,$0000
  dc.w  $0000,$0000,$0000,$700F,$078E,$1CFB,$01FC,$0000
  dc.w  $0000,$0000,$0000,$7000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$7E00
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$8100
  dc.w  $001F,$FFFF,$3FF8,$007E,$0000,$0000,$0000,$FB00
  dc.w  $0060,$0000,$3FF8,$00FE,$0000,$0000,$0000,$A500
  dc.w  $00AF,$FFFF,$3FF8,$00FE,$0000,$0000,$0000,$B900
  dc.w  $0041,$0000,$2000,$00C0,$0000,$0000,$0000,$A500
  dc.w  $0001,$7FFC,$6000,$0180,$0000,$0000,$0000,$A100
  dc.w  $0002,$3FFC,$4000,$0180,$8000,$0000,$0000,$7E00
  dc.w  $0002,$BFF9,$C000,$0181,$8000,$03C0,$0080,$0000
  dc.w  $0004,$0003,$8000,$0101,$8300,$C3E0,$633C,$0000
  dc.w  $0005,$FFE3,$FF9F,$F3F1,$8300,$C7E0,$677E,$0000
  dc.w  $0008,$FFC3,$FE9F,$F7F3,$E300,$C4E0,$CFFF,$0000
  dc.w  $000B,$FFC3,$FEBF,$F7F3,$E600,$8C60,$DEF7,$0000
  dc.w  $000B,$0000,$0770,$E606,$0631,$B861,$F9C7,$0000
  dc.w  $0013,$FF00,$0731,$CE06,$0431,$90E1,$F19F,$0000
  dc.w  $0017,$FE00,$06E1,$CC04,$0C71,$B0C1,$E3FE,$0000
  dc.w  $0024,$0000,$1663,$9C0C,$0C71,$70C1,$83F0,$0000
  dc.w  $002C,$007F,$FDFF,$9808,$18FB,$31C3,$8380,$0000
  dc.w  $005C,$003F,$F9FF,$1819,$9DFB,$33C3,$8380,$0000
  dc.w  $0058,$003F,$F9FF,$381F,$9FDF,$3FC3,$8304,$0000
  dc.w  $0000,$0000,$0000,$301F,$8F9F,$3EF3,$030C,$0000
  dc.w  $0000,$0000,$0000,$300F,$078E,$1CFB,$01FC,$0000
  dc.w  $0000,$0000,$0000,$7000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0001,$0000,$0080,$0000,$0000,$0000,$4200
  dc.w  $005F,$FFFF,$7FF8,$00FE,$0000,$0000,$0000,$0000
  dc.w  $00CF,$FFFF,$3FF8,$01FE,$0000,$0000,$0000,$0000
  dc.w  $0040,$C000,$E000,$01C0,$0000,$0000,$0000,$0000
  dc.w  $0000,$A005,$6000,$0180,$0000,$0000,$0000,$2000
  dc.w  $0001,$BFFC,$C000,$0181,$0000,$0000,$0000,$0000
  dc.w  $0001,$7FF9,$C000,$0381,$8000,$0280,$0080,$0000
  dc.w  $0003,$4001,$8000,$0303,$8000,$03C0,$0004,$0000
  dc.w  $0002,$8020,$0000,$0203,$8700,$CFC0,$637E,$0000
  dc.w  $0006,$FFE3,$FE9F,$B3F0,$0700,$CCE0,$CF7B,$0000
  dc.w  $0005,$FFC3,$FD9F,$F7F7,$E601,$9C60,$DEF7,$0000
  dc.w  $0007,$0000,$0730,$6606,$0E01,$B860,$B9C7,$0000
  dc.w  $000A,$0000,$0770,$CC0E,$0C11,$B041,$F18F,$0000
  dc.w  $000F,$FE00,$0E61,$CC0C,$0C13,$F0C1,$E3FE,$0000
  dc.w  $001E,$0000,$04E1,$880C,$0C13,$60C1,$83F8,$0000
  dc.w  $0010,$0000,$0403,$9810,$187B,$71C1,$83C0,$0000
  dc.w  $0038,$003F,$F9FF,$1800,$1CF9,$3303,$8380,$0000
  dc.w  $0030,$003F,$F9FF,$3010,$9FDF,$3303,$8386,$0000
  dc.w  $0000,$0000,$0000,$3019,$8F9F,$3E03,$03DE,$0000
  dc.w  $0000,$0000,$0000,$700F,$078E,$1CFB,$01FC,$0000
  dc.w  $0000,$0000,$0000,$6000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
imagedataFile:
; Plane
  dc.w  $0000,$7FF8,$7FF8,$7BF8,$71F8,$60F8,$4078,$4038
  dc.w  $7FF8,$7FF8,$7FF8,$7FF8,$FFF8
; Plane
  dc.w  $FFF8,$8000,$8000,$8400,$8800,$9000,$A000,$8000
  dc.w  $8000,$8000,$8000,$8000,$0000
; Plane
  dc.w  $0000,$7FF0,$7FF0,$7BF0,$77F0,$6FF0,$5FF0,$7FF0
  dc.w  $7FF0,$7FF0,$7FF0,$7FF0,$0000
; Plane
  dc.w  $0000,$0000,$7FF0,$79F0,$76F0,$6F70,$5FB0,$4030
  dc.w  $0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$7FF0,$79F0,$76F0,$6F70,$5FB0,$4030
  dc.w  $0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$7FF0,$7FF0,$7FF0,$7FF0,$7FF0,$4030
  dc.w  $0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$7FF0,$7FF0,$7FF0,$7FF0,$7FF0,$4030
  dc.w  $0000,$0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$7FF0,$7FF0,$7FF0,$7FF0,$7FF0,$4030
  dc.w  $0000,$0000,$0000,$0000,$0000
imagedataP:
; Plane
  dc.w  $FFF0,$8010,$9F10,$9990,$9990,$9F10,$9810,$9810
  dc.w  $9810,$8010,$8010,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FE0,$7FE0,$7FE0,$0000
; Plane
  dc.w  $FFF0,$8000,$9F00,$9980,$9980,$9F00,$9800,$9800
  dc.w  $9800,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$1F00,$1980,$1980,$1F00,$1800,$1800
  dc.w  $1800,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000

imagedataPs:
; Plane
  dc.w  $FFF0,$8010,$9F10,$9990,$9990,$9F10,$9810,$9810
  dc.w  $9830,$8070,$81F0,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FC0,$7F80,$7E00,$0000
; Plane
  dc.w  $FFF0,$8000,$8000,$8000,$8000,$8000,$8000,$8000
  dc.w  $8000,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000

imagedataL:
; Plane
  dc.w  $FFF0,$8010,$9810,$9810,$9810,$9810,$9810,$9810
  dc.w  $9F90,$8010,$8010,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FE0,$7FE0,$7FE0,$0000
; Plane
  dc.w  $FFF0,$8000,$9800,$9800,$9800,$9800,$9800,$9800
  dc.w  $9F80,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$1800,$1800,$1800,$1800,$1800,$1800
  dc.w  $1F80,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000

imagedataLs:
; Plane
  dc.w  $FFF0,$8010,$9810,$9810,$9810,$9810,$9810,$9810
  dc.w  $9FB0,$8070,$81F0,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FC0,$7F80,$7E00,$0000
; Plane
  dc.w  $FFF0,$8000,$8000,$8000,$8000,$8000,$8000,$8000
  dc.w  $8000,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
imagedataM:
; Plane
  dc.w  $FFF0,$8010,$B190,$BB90,$BF90,$B590,$B190,$B190
  dc.w  $B190,$8010,$8010,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FE0,$7FE0,$7FE0,$0000
; Plane
  dc.w  $FFF0,$8000,$B180,$BB80,$BF80,$B580,$B180,$B180
  dc.w  $B180,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$3180,$3B80,$3F80,$3580,$3180,$3180
  dc.w  $3180,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000

imagedataMs:
; Plane
  dc.w  $FFF0,$8010,$B190,$BB90,$BF90,$B590,$B190,$B190
  dc.w  $B1B0,$8070,$81F0,$FFF0
; Plane
  dc.w  $0000,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0,$7FE0
  dc.w  $7FC0,$7F80,$7E00,$0000
; Plane
  dc.w  $FFF0,$8000,$8000,$8000,$8000,$8000,$8000,$8000
  dc.w  $8000,$8000,$8000,$8000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
imagedataS:
; Plane
  dc.w  $FFF0,$8010,$8F10,$9990,$9C10,$8F10,$8390,$9990
  dc.w  $8F10,$8010,$8010,$FFF0
; Plane
  dc.w  $FFF0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0
  dc.w  $FFE0,$FFE0,$FFE0,$8000
; Plane
  dc.w  $0000,$0000,$0F00,$1980,$1C00,$0F00,$0380,$1980
  dc.w  $0F00,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0F00,$1980,$1C00,$0F00,$0380,$1980
  dc.w  $0F00,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000

imagedataSs:
; Plane
  dc.w  $FFF0,$8010,$8F10,$9990,$9C10,$8F10,$8390,$9990
  dc.w  $8F30,$8070,$81F0,$FFF0
; Plane
  dc.w  $FFF0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0,$FFE0
  dc.w  $FFC0,$FF80,$FE00,$8000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0000,$0000,$0000,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
; Plane
  dc.w  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  dc.w  $0020,$0060,$01E0,$0000
