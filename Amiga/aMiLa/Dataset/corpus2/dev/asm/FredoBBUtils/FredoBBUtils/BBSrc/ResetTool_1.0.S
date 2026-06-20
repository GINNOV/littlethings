;
;RESET-TOOL v1.0 by Frédo (fbas@club-internet.fr) '95-97
;
;PUBLIC DOMAIN - Do what you want with this thingy!
;
;Another resident monitor... UNFINISHED as I don't have the time!
;
;TODO:
;	- add de-installation routine
;	- Improve disassembly routines
;	- Implement assemble instruction
;	- Implement command history
;	- Improve the 'si' (System Info) command
;	- Improve/debug the '?' (Calculate) command
;	- Improve everything, fix the numerous bugs!
;	- and anything else you want...
;
;I WOULD BE HAPPY TO SEE IMPROVED VERSIONS OF THIS!!
;SO IF YOU DO IMPROVE IT OR USE IT, TELL ME.
;
;Assemble with PhxAss or AsmOne, Trash'mOne

	incdir	ASM:/Include/
	include equ.s
	include exec/types.i
	include exec/resident.i
	include exec/lists.i
	include exec/memory.i
	include exec/execbase.i

DBUG=1	;0 to disable debug mode

	IFEQ	DBUG

	STRUCTURE	InitGlobals,0
		APTR	ig_memlist
		APTR	ig_resdatastruct
		APTR	ig_resident
		APTR	ig_segment
		APTR	ig_nextseg
		APTR	ig_segsize
		LABEL	ig_size
StringSizeMax=20
	STRUCTURE	myresident,RT_SIZE
		APTR	mr_reslist
		APTR	mr_listend
		STRUCT	mr_name,StringSizeMax
		STRUCT	mr_idstring,StringSizeMax*2
		LABEL	mr_size

	BITDEF	MEM,RESET,MEMB_CHIP

VERSION=1
PRI=-55

;Install Reset-Tool into memory (as a resident module)
InitRes:
	moveq	#ig_size,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,a5
	move.l	a5,d0
	beq.w	Init_NoGlobalMem
	moveq	#mr_size,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR!MEMF_RESET,d1
	jsr	AllocMem(a6)
	move.l	d0,ig_resident(a5)
	beq.w	Init_NoResidentMem

	lea	InitRes-4(pc),a0
	lea	ResetSegStart(pc),a1
	move.l	(a0),ig_nextseg(a5)
	move.l	(a0),4(a1)
	clr.l	(a0)
	move.l	-4(a0),d0
	move.l	d0,ig_segsize(a5)
	move.l	#ResetSegStart-InitRes+8,d1
	sub.l	d1,d0
	move.l	d0,(a1)
	move.l	d1,-4(a0)

	lea	ResetSegStart+4(pc),a0
	move.l	a0,ig_segment(a5)
	moveq	#1,d0
	bsr.w	MakeMemList
	move.l	d0,ig_memlist(a5)
	beq.b	Init_NoMemEntry
	move.l	ig_resident(a5),ME_ADDR(a0)
	move.l	#mr_size,ME_LENGTH(a0)
	move.l	ig_resident(a5),a0
	move.l	ig_memlist(a5),a1
	move.l	ig_segment(a5),d0
	bsr.w	MakeReset
*** Message d'installation
	lea	dosname(pc),a1
	moveq	#0,d0
	move.l	4.w,a6
	jsr	OpenLibrary(a6)
	move.l	d0,d7
	beq.b	.nodos
	move.l	d7,a6
	jsr	Output(a6)
	move.l	d0,d6
	beq.b	.cldos
	lea	ResidentName(pc),a0
	bsr.b	prnt
	lea	Install.txt(pc),a0
	bsr.b	prnt
.cldos
	move.l	d7,a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)
.nodos
	bra.b	Init_Fin

* afficher un text-string (terminée par 0)
* a0: adr string
* d6: output handle
* d7: dosbase
prnt
	move.l	a0,d2
	moveq	#-1,d3
.lop	addq.l	#1,d3
	tst.b	(a0)+
	bne.b	.lop
	move.l	d6,d1
	move.l	d7,a6
	jmp	Write(a6)

Init_NoMemEntry:
	lea	InitRes-8(pc),a0
	move.l	ig_segsize(a5),(a0)
	move.l	ig_nextseg(a5),4(a0)
	move.l	ig_resident(a5),a1
	moveq	#mr_size,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
Init_NoResidentMem:
Init_Fin:
	moveq	#ig_size,d0
	move.l	a5,a1
	move.l	4.w,a6
	jsr	FreeMem(a6)
Init_NoGlobalMem:
	moveq	#0,d0
	rts

MakeMemList:
	movem.l a2-a3/d2-d4,-(sp)
	move.l	a0,a2
	move	d0,d2
	bsr.b	ScanSegMemList
	move	d0,d3
	add	d0,d2
	addq	#1,d2
	move	d2,d0
	mulu	#ME_SIZE,d0
	add.l	#ML_SIZE,d0
	move.l	d0,d4
	move.l	#MEMF_CLEAR!MEMF_PUBLIC!MEMF_RESET,d1
	jsr	AllocMem(a6)
	tst.l	d0
	beq.b	.end
	move.l	d0,a3
	move	d2,ML_NUMENTRIES(a3)
	lea	ML_ME(a3),a0
	move.l	d0,ME_ADDR(a0)
	move.l	d4,ME_LENGTH(a0)
	addq.l	#ME_SIZE,a0
	bra.b	.do
.loop
	lea	-4(a2),a1
	move.l	a1,ME_ADDR(a0)
	move.l	(a1),ME_LENGTH(a0)
	addq.l	#ME_SIZE,a0
	move.l	(a2),d0
	lsl.l	#2,d0
	move.l	d0,a2
.do
	dbf	d3,.loop
	move.l	a3,d0
.end
	movem.l (sp)+,a2-a3/d2-d4
	rts

ScanSegMemList:
	moveq	#1,d0
.loop	move.l	(a0),d1
	beq.b	.end
	lsl.l	#2,d1
	move.l	d1,a0
	addq	#1,d0
	bra.b	.loop
.end	rts

MakeReset:
	movem.l a2-a4,-(sp)
	move.l	a0,a2
	move.l	a1,a3
	addq.l	#4,d0
	move.l	d0,a4
	move.l	a2,a1

;save ptr to Resident structure
	move.l	a1,myresptr

	lea	Resident(pc),a0
	moveq	#RT_SIZE,d0
	jsr	CopyMem(a6)
	move.l	a2,RT_MATCHTAG(a2)
	move.l	a2,mr_reslist(a2)
	move.l	a4,RT_INIT(a2)
	lea	ResidentName(pc),a0
	lea	mr_name(a2),a1
	moveq	#StringSizeMax-1,d0
	jsr	CopyMem(a6)
	lea	ResidentIDString(pc),a0
	lea	mr_idstring(a2),a1
	moveq	#(StringSizeMax*2)-1,d0
	jsr	CopyMem(a6)

	lea	mr_name(a2),a0
	move.l	a0,RT_NAME(a2)
	lea	mr_idstring(a2),a0
	move.l	a0,RT_IDSTRING(a2)
;	clr.l	RT_IDSTRING(a2)
	lea	mr_size(a2),a0
	move.l	a0,RT_ENDSKIP(a2)
	move.l	KickTagPtr(a6),d0
	beq.b	.ResMod
	bset	#31,d0
.ResMod
	move.l	d0,mr_listend(a2)
	lea	mr_reslist(a2),a0
	move.l	a0,KickTagPtr(a6)
	move.l	KickMemPtr(a6),(a3)
	move.l	a3,KickMemPtr(a6)
	jsr	SumKickData(a6)
	move.l	d0,KickCheckSum(a6)
	movem.l (sp)+,a2-a4
	rts

*** Structure Resident
Resident:
	dc.w	RTC_MATCHWORD	;rt_MatchWord
	dc.l	0		;rt_MatchTag
	dc.l	0		;rt_EndSkip
	dc.b	RTF_COLDSTART	;rt_Flags
	dc.b	VERSION 	;rt_Version
	dc.b	NT_UNKNOWN	;rt_Type
	dc.b	PRI		;rt_Pri
	dc.l	0		;rt_Name
	dc.l	0		;rt_IDString
	dc.l	0		;rt_Init

residentlist:dc.l Resident,0

dosname:	dc.b 'dos.library',0
Install.txt:	dc.b ' ...installed!',$a,0
Rem.txt:	dc.b ' ...removed!',$a,0
ResidentName:	dc.b 'RESET-TOOL',0
ResidentNameLen=*-ResidentName
ResidentIDString:dc.b 'rt 1.0 (1.1.96) by Frédéric BASSALER',$a,0
	even
ResetSegStart:dc.l 0,0

	ENDC


ResetProg:

;here follows the resident part of the program

*************************************************
*		RESET-TOOL		V1.0	*
*-----------------------------------------------*
* Classe: Moniteur de mémoire			*
* Auteur: Frédéric Bassaler			*
* Date:   Commençé en Mai 1995			*
*-----------------------------------------------*
* Config: OS 1.3 ou supérieur			*
* (testé sous 1.3 et 2.04)			*
*************************************************

	include exec/ports.i
	include exec/interrupts.i
	include exec/tasks.i
;	include exec/execbase.i
	include graphics/text.i
	include graphics/gfx.i
	include graphics/rastport.i
	include intuition/intuition.i

	rsreset
mytask	rs.l	1
;oldsysstack rs.l 1
oldtrap rs.l	1
trapadr rs.l	1
savesp	rs.l	1
olddma	rs.w	1
oldirq	rs.w	1
oldint	rs.w	1
intbase rs.l	1
gfxbase rs.l	1
scrbase rs.l	1
winbase rs.l	1
rast	rs.l	1
x_pos	rs.w	1
y_pos	rs.w	1
x_max	rs.w	1
y_max	rs.w	1
x_rsize rs.w	1
y_rsize rs.w	1
x_org	rs.w	1
y_org	rs.w	1
combuf	rs.l	1
comlen	rs.w	1
maxcomlen rs.w	1
oldptr	rs.l	1
endadr	rs.l	1
lastdis rs.l	1
unit0	rs.l	1
unit1	rs.l	1
unit2	rs.l	1
unit3	rs.l	1
curunit rs.l	1
defunit rs.l	1
dflag	rs.b	1
ascflag rs.b	1
conport rs.b	34
conio	rs.b	48
keymap	rs.b	32
inputevent rs.b 22
trkbuf	rs.b	512*11*2
outbuf	rs.b	512*4
binbuf	rs.b	48
VARSIZE rs.w	0

* dimensions écran/fenètre
Width=640	;screen width
Height=-1	;screen height
Depth=2		;screen depth

;NEWKEYMAP=0

Main:
	btst	#6,$bfe001	;leftmousebutton during reboot to skip
	bne.s	.enter
	rts
* passer en mode superviseur
.superv move	#$2700,sr
	move	sr,srreg
	rte
.enter
	movem.l d0-a7,regs	;sauver registres
	movem.l d0-a6,-(sp)
	lea	.superv(pc),a5
	move.l	4.w,a6
;	jsr	Supervisor(a6)
* Mettre le bit BLIPRI de DMACON à 1
* pour que le blitter ait la priorité sur le CPU
* (gain de vitesse à l'affichage)
;	lea	$dff000,a0
;	move	2(a0),d0
;	or	#$87f0,d0
;	move	d0,$96(a0)
* allouer buffer pour variables globales
	move.l	#VARSIZE,d0
	move.l	#$10001,d1
;	 move.l  4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,a5
	move.l	a5,d0
	beq	quit
	lea	VARS(pc),a0
	move.l	d0,(a0)
	move.l	ThisTask(a6),mytask(a5)
* ouvrir trackdisk pour toutes les unités disponibles
	lea	unit0(a5),a4
	moveq	#3,d3
	moveq	#0,d4
.op
	move.l	d4,d0
	bsr	OpenUnit
	move.l	d0,(a4)+
	addq.l	#1,d4
	dbf	d3,.op

	move.l	unit0(a5),curunit(a5)	;unité courante par défaut = df0:
*** open libs
	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase(a5)
	beq	cltd
	lea	intname(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,intbase(a5)
	beq.w	cltd
*** Open main screen & window
	lea	New.Scr(pc),a0
	move.l	intbase(a5),a6
	jsr	OpenScreen(a6)
	move.l	d0,scrbase(a5)
	beq	cltd
	move.l	d0,a0
	lea	44(a0),a0
	lea	New.Pal(pc),a1
	moveq	#2^Depth,d0
	move.l	gfxbase(a5),a6
	jsr	LoadRGB4(a6)

	move.l	scrbase(a5),a1
	lea	New.Win(pc),a0
	move	sc_Width(a1),nw_Width(a0)
	move	sc_Height(a1),nw_Height(a0)
	move.l	a1,nw_Screen(a0)
	move.l	intbase(a5),a6
	jsr	OpenWindow(a6)
	move.l	d0,winbase(a5)
	beq	clscr
*** Open console
	move.l	d0,a0
	move.l	50(a0),rast(a5)	;window->rastport
	move.l	d0,d7
	lea	conport(a5),a1
	move.l	a1,-(sp)
	move.l	mytask(a5),$10(a1)
	move.l	4.w,a6
	jsr	AddPort(a6)

	lea	conio(a5),a1
	move.l	(sp)+,14(a1)
	move.l	d7,40(a1)
	move.l	#nw_SIZEOF,36(a1)
	moveq	#0,d0
	moveq	#0,d1
	lea	consolename(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0
	bne	clwin

;	bsr	SetMap		;set new keymap

*** installer handler trap
;	move.l	MyTask(a5),a1
;	move.l	tc_TrapCode(a1),oldtrap(a5)
;	lea	mytrap(pc),a0
;	move.l	a0,tc_TrapCode(a1)
;	clr.l	tc_TrapData(a1)

*** affiche main menu
printmenu:
	lea	main.txt(pc),a0
	bsr	print
;last guru
	move.l	4.w,a6
	lea	514(a6),a0
	tst.l	(a0)
	beq.s	.no_failure
	move.l	a0,a1
	lea	lastalert.txt(pc),a0
	bsr	printf
.no_failure
mainmenu:
	bsr	prompt
	lea	strbuf(pc),a0
	move.l	a0,combuf(a5)
	clr	comlen(a5)
	moveq	#(strbuflen>>2)-1,d0
.clr	clr.l	(a0)+
	dbf	d0,.clr
*** boucle principale: attente d'un ordre
mainloop:
	move.l	winbase(a5),a0
	bsr.w	WaitMsg
	cmp.l	#$400,d6
	bne.s	mainloop

	btst	#7,d4		;touche relachée?
	bne.s	mainloop
	move	d4,d0
	and	#$60,d0
	cmp	#$60,d0 	;shift, ctrl, etc..?
	beq.s	mainloop

	cmp.b	#$5f,d4 	;help
	beq.s	printmenu
	cmp.b	#$4f,d4 	;flèche Gauche
	beq.w	.cursorleft
	cmp.b	#$4e,d4 	;flèche Droit
	beq.w	.cursorright
	cmp.b	#$4c,d4 	;flèche Haut
	beq.s	.oldcommand

	bsr.w	ConvRawKey	;convertir code rawkey en ascii
	lea	string(pc),a0
	move.b	(a0),d0
	cmp.b	#$d,d0		;cr?
	beq.s	.getcommand
	cmp.b	#8,d0		;backspace?
	beq.w	.dobackspace
	cmp.b	#$1b,d0 	;esc?
	beq.w	cls

	move.l	combuf(a5),a0
	move.b	d0,(a0)+
	move.l	a0,combuf(a5)
	cmp	#strbuflen,comlen(a5)
	bge.s	mainloop
	addq	#1,comlen(a5)

	subq.l	#1,a0
	bsr.w	print		;afficher le caractère ascii
	bra.s	mainloop
.oldcommand
	lea	oldcommand.txt(pc),a0
	bsr	print
	lea	oldbuf(pc),a0
	move.l	a0,-(sp)
	lea	strbuf(pc),a1
	move.l	#strbuf,combuf(a5)
	clr	comlen(a5)
	move	#strbuflen-1,d0
.restore_from_oldbuf
	move.b	(a0)+,(a1)+
	beq.s	.restore_done
	addq.l	#1,combuf(a5)
	addq	#1,comlen(a5)
	dbf	d0,.restore_from_oldbuf
.restore_done
	move.l	(sp)+,a0
	bsr	print
	bra	mainloop
.getcommand
	lea	lf.txt(pc),a0
	bsr	print
* copier ligne de commande vers buffer de sauvegarde
	lea	strbuf(pc),a0
	move.l	a0,-(sp)
	tst.b	(a0)
	beq.s	.copy_done
	lea	oldbuf(pc),a1
	move	#strbuflen-1,d0
.copy_to_oldbuf
	move.b	(a0)+,(a1)+
	beq.s	.copy_done
	dbf	d0,.copy_to_oldbuf
.copy_done
	move.l	(sp)+,a0
	moveq	#0,d7
	move	comlen(a5),d7	;long. ligne de commande
	addq	#1,d7
	move.b	(a0),d0 	;linefeed seul?
	beq	mainmenu
	move	(a0),d1
	move.l	(a0),d2

* parse command
	cmp.b	#'<',d0
	beq	ReadBlocks
	cmp.b	#'>',d0
	beq	WriteBlocks
	cmp.b	#'[',d0
	beq	AllocMemory
	cmp.b	#']',d0
	beq	FreeMemory
	cmp.b	#'?',d0
	beq	Calculate

	cmp.l	#'KILL',d2
	beq	UnInstall
	cmp.l	#'fill',d2
	beq	FillMem
	cmp.l	#'find',d2
	beq	FindMem
	cmp.l	#'inst',d2
	beq	InstallDisk
	cmp	#'si',d1
	beq	SysInfo
	cmp	#'cl',d1
	beq	ClearMem
	cmp	#'du',d1
	beq	ChangeUnit
	cmp.b	#'x',d0
	beq.w	CloseAll
	cmp.b	#'m',d0
	beq	MemDump
	cmp.b	#'a',d0
	beq	AsciiDump
	cmp.b	#'c',d0
	beq	CopMem
	cmp.b	#'d',d0
	beq	Dis
	cmp.b	#'j',d0
	beq	Jump
	cmp.b	#'r',d0
	beq	ShowRegs
	cmp.b	#'e',d0
	beq	EditMem
	cmp.b	#'b',d0
	beq	BlockCheckSum
	cmp.b	#'l',d0
	beq	ListResModules

	lea	badcommand.txt(pc),a0
	bsr	print
	bra.w	mainmenu
.cursorleft
	cmp.l	#strbuf,combuf(a5)
	ble.s	.main
	subq.l	#1,combuf(a5)
	lea	cursorleft.txt(pc),a0
	bra.s	.pr
.cursorright
	lea	cursorright.txt(pc),a0
	bra.s	.pr
.dobackspace
	cmp.l	#strbuf,combuf(a5)
	ble.s	.main
	subq.l	#1,combuf(a5)
	move.l	combuf(a5),a0
	clr.b	(a0)
	subq	#1,comlen(a5)
	lea	backspace.txt(pc),a0
.pr	bsr	print
.main	bra	mainloop

*** fermer & libérer tout
CloseAll:
;	move.l	mytask(a5),a1
;	move.l	oldtrap(a5),tc_TrapCode(a1)
clcon
	lea	conio(a5),a1
	move.l	14(a1),-(sp)
	move.l	4.w,a6
	jsr	CloseDevice(a6)
	move.l	(sp)+,a1
	jsr	RemPort(a6)
clwin
	move.l	winbase(a5),d0
	beq.b	clscr
	move.l	d0,a0
	move.l	intbase(a5),a6
	jsr	CloseWindow(a6)
clscr
	move.l	scrbase(a5),d0
	beq.b	cltd
	move.l	d0,a0
	move.l	intbase(a5),a6
	jsr	CloseScreen(a6)
	move.l	intbase(a5),a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)
	move.l	gfxbase(a5),a1
	jsr	CloseLibrary(a6)
cltd
* fermer toutes les unités de disk
CloseDiskUnits:
	lea	unit0(a5),a4
	moveq	#3,d3
.clu	move.l	(a4),a0
	clr.l	(a4)+
	bsr	CloseUnit
	dbf	d3,.clu
* retourner en mode utilisateur
;	move.l	oldsysstack(a5),d0
;	move.l	4.w,a6
;	jsr	-156(a6)	;UserState()
freevars:
;	move.l	VARS(pc),a1
	move.l	a5,a1
	move.l	#VARSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
quit
	movem.l (sp)+,d0-a6
	rts
notrack
	move	#$f00,$dff180
	bra.b	quit

WaitMsg:
	move.l	a0,a4
	move.l	86(a0),a0
	move.l	a0,-(sp)
	move.l	4.w,a6
	jsr	WaitPort(a6)
	move.l	(sp)+,a0
	jsr	GetMsg(a6)
	move.l	a4,a0
	tst.l	d0
	beq.s	WaitMsg
	move.l	d0,a1
	move.l	a1,-(sp)
	jsr	ReplyMsg(a6)
	move.l	(sp)+,a1
	move.l	20(a1),d6	;ie_class
	move	24(a1),d4	;ie_code
	move	26(a1),d5	;ie_qualifier
	move.l	28(a1),d7	;ie_itemaddress
	rts

* Transformer le code rawkey en code ascii correspondant
ConvRawKey:
	move.l	a6,-(sp)
	lea	conio(a5),a6	;iorequest
	move.l	20(a6),a6	;device library
	lea	inputevent(a5),a0
	move.b	#1,4(a0)	;ieclass_rawkey
	move	d4,6(a0)	;code rawkey
	move	d5,8(a0)	;qualifier: 1=lshift 2=rshift 8=ctrl
	clr.l	(a0)		;nxt=0
	lea	string(pc),a1	;buffer destination
	moveq	#10,d1		;nbre d'octets
	suba.l	a2,a2
	jsr	-48(a6) 	;RawKeyConvert()
	move.l	(sp)+,a6
	rts
string	dcb.b	12,0
	even

*** rechercher le prochain espace
spc	cmp.b	#$20,(a0)+
	beq.s	spc
	subq.l	#1,a0
	rts

*** Calculer une expression (pas encore au point!)
Calculate:
	addq.l	#1,a0
	tst.b	(a0)
	bne.s	.spc
	moveq	#0,d0
	bra.s	.calc_done
.spc	bsr.s	spc

	bsr.s	Calc
.calc_done
	lea	.ascbuf(pc),a0
	move.l	a0,-(sp)
	move.l	d0,-(sp)	;résultat
	move.l	d0,-(sp)

	moveq	#3,d1
.cop	rol.l	#8,d0
	move.b	d0,(a0)+
	dbf	d1,.cop
	clr.b	(a0)

	lea	.ascbuf(pc),a0
	moveq	#4,d0
	bsr	Test

	move.l	sp,a1
	lea	.str(pc),a0
	bsr	printf

	move.l	(sp),d1
	bsr	Long2BinString
	bsr	print
	add	#12,sp
	lea	lf.txt(pc),a0
	bsr	print
.f
	bra	mainmenu
.badargs
	bsr	BadArgs
	bra.s	.f
.str	dc.b	'$%08lx %10.10ld "%s" %%',0
.ascbuf dcb.b	6,0
	even

*****************************************
*   Calculer une expression numérique	*
*---------------------------------------*
* Paramètres d'entrée:                  *
* a0: adr. de l'expression à calculer   *
*	(chaine ascii terminée par 0)	*
*---------------------------------------*
* En sortie:				*
* d0: contient le résultat		*
* d1: 0=ok, -1=erreur			*
*****************************************
Calc:
	move.l	a4,-(sp)
	lea	result(pc),a4
	clr.l	(a4)
* analyse des opérateurs
.loop
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.w	.fin		;0 de fin?
	cmp.b	#'"',d0
	beq.w	.ascii
	cmp.b	#'(',d0
	beq.s	.loop
	cmp.b	#')',d0
	beq.s	.loop
	cmp.b	#'[',d0
	beq.s	.loop
	cmp.b	#']',d0
	beq.s	.loop
	cmp.b	#'/',d0
	beq.w	.div
	cmp.b	#':',d0
	beq.w	.div
	cmp.b	#'*',d0
	beq.w	.mul
	cmp.b	#'-',d0
	beq.w	.moins
	cmp.b	#'+',d0
	beq.w	.plus
	cmp.b	#'^',d0
	beq.w	.power
	cmp.b	#'!',d0
	beq.w	.or
	cmp.b	#'|',d0
	beq.w	.or
	cmp.b	#'&',d0
	beq.w	.and
	cmp.b	#'~',d0
	beq.w	.not
	cmp.b	#'>',d0
	beq.w	.rot_right
	cmp.b	#'<',d0
	beq.w	.rot_left

.cv
	btst	#6,$bfe001
	beq.s	.fin

	subq.l	#1,a0
	bsr.w	Convert
	move.l	d1,(a4)
	bra.w	.loop
.ascii
	move.l	a0,a1
.ass	move.b	(a1)+,d0
	beq.w	CalcErr 	;pas de guillemet de fin?
	cmp.b	#'"',d0
	bne.s	.ass
	suba.l	a0,a1
	move.l	a1,d0
	subq	#1,d0
	lea	.asciibuf(pc),a1
	move.l	a1,-(sp)
.copasc move.b	(a0)+,(a1)+
	dbf	d0,.copasc
	move.l	(sp)+,a1
	move.l	(a1),(a4)
	bra.w	.loop
.fin
	move.l	(a4),d0
	move.l	(sp)+,a4
	moveq	#0,d1
	rts

.asciibuf dcb.b 8,0
	even
;.parenth
;	bra.w	.loop
.div
	bsr.w	Convert
	move.l	(a4),d0
	tst.l	d1
	beq.s	.zero
;	divs	d1,d0
;	ext.l	d0
	bsr.w	Div32
	move.l	d0,(a4)
.zero
	bra.w	.loop
.mul
	bsr.w	Convert
	move.l	(a4),d0
;	muls	d1,d0
	bsr.w	Mult32
	move.l	d0,(a4)
	bra.w	.loop
.moins
	bsr.w	Convert
	move.l	(a4),d0
	sub.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop
.plus
	bsr.w	Convert
	move.l	(a4),d0
	add.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop
.power
	bsr.w	Convert
	move.l	(a4),d0
	moveq	#1,d2
	tst.l	d1		;puissance = 0?
	beq.s	.pow_done
.pow
;	mulu	d0,d2
	movem.l d0-d1,-(sp)
	move.l	d2,d1
	bsr.b	Mult32
	move.l	d0,d2
	movem.l (sp)+,d0-d1
	subq	#1,d1
	bne.s	.pow
.pow_done
	move.l	d2,(a4)
	bra.w	.loop
.or
	bsr.w	Convert
	move.l	(a4),d0
	or.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop
.and
	bsr.w	Convert
	move.l	(a4),d0
	and.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop
* routine à mettre au point!
.not
	bsr.w	Convert
	move.l	(a4),d0
	moveq	#-1,d2
	sub.l	d1,d2
	eor.l	d2,d0
	move.l	d0,(a4)
	bra.w	.loop
.rot_left
	cmp.b	#'<',(a0)+
	bne.b	CalcErr
	bsr.w	Convert
	move.l	(a4),d0
	lsl.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop
.rot_right
	cmp.b	#'>',(a0)+
	bne.b	CalcErr
	bsr.w	Convert
	move.l	(a4),d0
	lsr.l	d1,d0
	move.l	d0,(a4)
	bra.w	.loop

CalcErr:
	move.l	(sp)+,a4
	moveq	#-1,d1
	rts

result: dc.l	0

* Multiplication sur 32 bits (signée ou non)
Mult32: ;d0=Mult32(factor1,factor2)(d0,d1)
	MOVEM.L D2/D3,-(A7)
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	SWAP	D2
	SWAP	D3
	MULU	D1,D2
	MULU	D0,D3
	MULU	D1,D0
	ADD	D3,D2
	SWAP	D2
	CLR	D2
	ADD.L	D2,D0
	MOVEM.L (A7)+,D2/D3
	RTS
* Division sur 32 bits (signée)
Div32:	;(quotien,remainder)(d0,d1)=DivMod32(dividend,divisor)(d0,d1)
LB_43EE TST.L	D0
	BPL.B	LB_4408
	NEG.L	D0
	TST.L	D1
	BPL.B	LB_4400
	NEG.L	D1
	BSR.B	UDiv32
	NEG.L	D1
	RTS
LB_4400 BSR.B	UDiv32
	NEG.L	D0
	NEG.L	D1
	RTS
LB_4408 TST.L	D1
	BPL.B	UDiv32
	NEG.L	D1
	BSR.B	UDiv32
	NEG.L	D0
	RTS

* Division sur 32 bits (non signée)
UDiv32: ;(dividend,divisor)(d0,d1)
	MOVE.L	D3,-(A7)
	CMP.L	#$0000FFFF,D1
	BHI.B	LB_4440
	MOVE.L	D1,D3
	SWAP	D0
	MOVE	D0,D3
	BEQ.B	LB_4430
	DIVU	D1,D3
	MOVE	D3,D0
LB_4430 SWAP	D0
	MOVE	D0,D3
	DIVU	D1,D3
	MOVE	D3,D0
	SWAP	D3
	MOVE	D3,D1
	MOVE.L	(A7)+,D3
	RTS
LB_4440 MOVE.L	D2,-(A7)
	MOVE.L	D1,D3
	MOVE.L	D0,D1
	CLR	D1
	SWAP	D1
	SWAP	D0
	CLR	D0
	MOVEQ	#$10,D2
LB_4450 ADD.L	D0,D0
	ADDX.L	D1,D1
	CMP.L	D1,D3
	BHI.B	LB_445C
	SUB.L	D3,D1
	ADDQ	#1,D0
LB_445C subq	#1,d2
	bne.s	LB_4450
	MOVEM.L (A7)+,D2/D3
	RTS

*** Changer d'unité de disk <UnitNumber (0-3)>
* si aucun argument, on affiche le n° du drive courant
ChangeUnit:
	addq.l	#2,a0
	tst.b	(a0)
	beq.w	.show_current
;sauter les espaces en début de chaine, s'il y'en a
	bsr	spc
.rdargs
	bsr	Convert

	tst.l	d1
	bmi.s	.badunit
	moveq	#3,d0
	cmp.l	d0,d1
	bhi.s	.badunit
	move.l	defunit(a5),-(sp)
	move.l	d1,defunit(a5)
	lsl.l	#2,d1
	move.l	unit0(a5,d1.w),d0
	beq.s	.bad_unit
	move.l	d0,curunit(a5)
	addq.l	#4,sp
.f
	bra	mainmenu
.show_current
	lea	currunit.txt(pc),a0
	lea	defunit(a5),a1
	bsr	printf
	bra.s	.f
.badargs
	bsr	BadArgs
	bra.s	.f
.bad_unit
	move.l	(sp)+,defunit(a5)
.badunit
	lea	badunit.txt(pc),a0
	bsr	print
	bra.s	.f

*** Jump <addr>
Jump:
;	clr.b	-1(a0,d7.w)
	addq.l	#1,a0
	move.b	(a0),d0
	beq.w	.badargs

	lea	.inst(pc),a4
	move	#$4ef9,(a4)	;instruction JMP
	lsl	#8,d0
	addq.l	#1,a0
	move.b	(a0)+,d0
	cmp	#'sr',d0        ;'JSR' ?
	beq.s	.jsr
	subq.l	#1,a0
	bra.s	.spc
.jsr	move	#$4eb9,(a4)	;instruction JSR
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

.rdargs
	bsr	Convert
;	tst.l	d0
;	bne.s	.badargs

* sauver l'état du système
	move.l	sp,savesp(a5)
	lea	$dff000,a0
	move	2(a0),olddma(a5)
	move	$1c(a0),oldirq(a5)
	or.l	#$84008000,olddma(a5)
	move.l	$6c.w,oldint(a5)

	lea	.adr(pc),a0
	move.l	d1,(a0)

;	movem.l regs(pc),d0-a7
.inst	dc.w	$4ef9
.adr	dc.l	0
* restituer système
.restore
	move	sr,srreg
;	movem.l d0-a7,regs
	move.l	VARS(pc),a5
	move.l	savesp(a5),sp
	lea	$dff000,a0
	move.l	oldint(a5),$6c.w
	move	#$7fff,$96(a0)
	move.l	gfxbase(a5),a6
	move.l	38(a6),$80(a0)
	clr	$88(a0)
	move	olddma(a5),$96(a0)
	move	oldirq(a5),$9a(a0)

	bra.s	ShowRegs

.f	bra	mainmenu
.badargs
	bsr	BadArgs
	bra.s	.f

*** Afficher registres
ShowRegs:
;	move.l	mytask(a5),a0
;	move.l	tc_TrapData(a0),d0
;	beq.s	.no_trap
;	move.l	oldtrap(a5),tc_TrapCode(a0)

.no_trap
	lea	regs.txt(pc),a0
	lea	regs(pc),a1
	movem.l d0-a6,-(sp)
	lea	.trap(pc),a5
	move.l	4.w,a6
	jsr	Supervisor(a6)
	move.l	a2,spreg
	movem.l (sp)+,d0-a6
	bsr	printf

.f	bra	mainmenu
.trap
	move.l	usp,a2
	rte
*** Infos Système
SysInfo:
	bsr	CursOff

	lea	trkbuf(a5),a0
	move.l	4.w,a6
	move	AttnFlags(a6),d0
	moveq	#4,d1
.cpu040
	btst	#3,d0
	bne.s	.cpudone
	subq	#1,d1
.cpu030
	btst	#2,d0
	bne.s	.cpudone
	subq	#1,d1
.cpu020
	btst	#1,d0
	bne.s	.cpudone
	subq	#1,d1
.cpu010
	btst	#0,d0
	bne.s	.cpudone
	subq	#1,d1
.cpudone
	move	d1,(a0)+

	move	AttnFlags(a6),d0
.fpu040 btst	#6,d0
	beq.s	.fpu882
	lea	fpu040.txt(pc),a1
	bra.s	.fpudone
.fpu882 btst	#5,d0
	beq.s	.fpu881
	lea	fpu882.txt(pc),a1
	bra.s	.fpudone
.fpu881 btst	#4,d0
	beq.s	.nofpu
	lea	fpu881.txt(pc),a1
	bra.s	.fpudone
.nofpu	lea	nofpu.txt(pc),a1
.fpudone
	move.l	a1,(a0)+

	move.l	$f8000c,(a0)+	;kickstart version
	move.l	20(a6),(a0)+	;exec version
	move.l	62(a6),(a0)+	;max loc mem
	move.l	78(a6),(a0)+	;max ext mem
	moveq	#0,d0
	move.b	530(a6),d0
	swap	d0
	move.b	531(a6),d0	;vblank/power
	move.l	d0,(a0)+
	lea	42(a6),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	546(a6),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	a0,a4
	moveq	#2!1,d1 	;chip
	jsr	AvailMem(a6)
	move.l	d0,(a4)+
	move.l	#$20000!2!1,d1	;largest chip
	jsr	AvailMem(a6)
	move.l	d0,(a4)+
	moveq	#4!1,d1 	;fast
	jsr	AvailMem(a6)
	move.l	d0,(a4)+
	move.l	#$20000!4!1,d1	;largest fast
	jsr	AvailMem(a6)
	move.l	d0,(a4)+
	moveq	#4&2&1,d1	;total
	jsr	AvailMem(a6)
	move.l	d0,(a4)+
	lea	Main(pc),a0	;prog start
	lea	End(pc),a1	;prog end
	move.l	a0,(a4)+
	move.l	a1,(a4)+
	suba.l	a0,a1		;prog size
	move	a1,(a4)+
	lea	sysinfo.txt(pc),a0
	lea	trkbuf(a5),a1
	bsr.w	printf
.f	bra	mainmenu

;Memory dump - 3 possibilités:
;  m<return> -> dump de n lignes
;  m[start] [end] -> dump de l'adresse start -> end
;  m[start] -> dump de l'adresse start -> mouseclick
NLIN=16
BYTES_PER_LINE=20
MemDump:
	clr.b	dflag(a5)
	addq.l	#1,a0
	tst.b	(a0)
	bne.b	.adr_entered
	move.l	oldptr(a5),a4
	moveq	#NLIN-1,d6	;nbre de lignes à afficher
	st	dflag(a5)
	bra.b	.no_end1
.adr_entered
	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	bsr	CursOff
	movem.l .adr(pc),d0/d1
	tst.l	d1
	beq.s	.no_end
	move.l	d0,a4
	move.l	d1,endadr(a5)
	sub.l	d0,d1
	cmp	#BYTES_PER_LINE,d1
	bcs.w	.f
	bra.b	.dmp
.no_end
	move.l	d0,a4		;start adr
.no_end1
	clr.l	endadr(a5)	;no end adr
.dmp
	lea	outbuf(a5),a0
.bcl
	move.l	a4,d0
	move.l	a4,a3
	bsr	HexConv0
	move.b	#':',(a0)+
	move.b	#$20,(a0)+

	moveq	#(BYTES_PER_LINE/4)-1,d7
.lop
	move.l	d7,-(sp)
	moveq	#3,d7
.lop1	move.b	(a4)+,d0
	bsr	HexConvByte
	dbf	d7,.lop1
	move.b	#$20,(a0)+
	move.l	(sp)+,d7
	dbf	d7,.lop
	move.b	#$20,(a0)+

	moveq	#BYTES_PER_LINE-1,d7
.cop	move.b	(a3)+,(a0)

	movem.l d1-d2,-(sp)
.t	move.b	nullchr(pc),d1	;caract. de remplacement
	move.b	(a0)+,d2
	bclr	#7,d2
	cmp.b	#$20,d2 	;caract. < à $20(=espace)?
	bcs.b	.no		;si oui remplacer
	move.b	d2,d1
	btst	#7,-1(a0)
	beq.b	.no
	bset	#7,d1
.no	move.b	d1,-1(a0)
	movem.l (sp)+,d1-d2

	dbf	d7,.cop
	move.b	#$a,(a0)+
	clr.b	(a0)

	btst	#6,$bfe001
	beq.b	.f

	tst.l	endadr(a5)
	beq.b	.no_end2
	cmp.l	endadr(a5),a4
	bhi.b	.f
.no_end2
	lea	outbuf(a5),a0
	bsr	print	;Line

	tst.b	dflag(a5)
	beq.w	.dmp
	dbf	d6,.dmp
.f
	move.l	a4,oldptr(a5)
	bra	mainmenu

.adr	dc.l	0,0

*** ASCII Dump [start] [end]
AsciiDump:
NCHR=70
	clr.b	dflag(a5)
	addq.l	#1,a0
	tst.b	(a0)
	bne.b	.adr_entered
	move.l	oldptr(a5),a4
	moveq	#NLIN-1,d6	;nbre de lignes à afficher
	st	dflag(a5)
	bra.b	.no_end1
.adr_entered
	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	bsr	CursOff
	movem.l .adr(pc),d0/d1
	tst.l	d1
	beq.s	.no_end
	move.l	d0,a4
	move.l	d1,endadr(a5)
	sub.l	d0,d1
	cmp	#NCHR,d1
	bcs.b	.f
	bra.b	.dmp
.no_end
	move.l	d0,a4		;start adr
.no_end1
	clr.l	endadr(a5)	;no end adr
.dmp
	moveq	#NCHR,d0
	move	d0,d1
	lea	trkbuf(a5),a1
	subq	#1,d1
.copmem
	move.b	(a4)+,(a1)+
	dbf	d1,.copmem

	lea	trkbuf(a5),a0
	bsr.w	Test
* construire le dump
	lea	(a0,d0.w),a1
	clr.b	(a1)
	move.l	a1,a2
	moveq	#0,d3
.bcl0	moveq	#NCHR-1,d1
	move.l	d3,d7
	add.l	a4,d7
	sub	#NCHR,d7
	bsr.w	Long2Hex
	move.b	#':',(a1)+
	move.b	#$20,(a1)+
.bcl
	move.b	(a0)+,(a1)+
	addq	#1,d3
	dbf	d1,.bcl
	move.b	#$a,(a1)+
	clr.b	(a1)

	btst	#6,$bfe001
	beq.s	.f

	tst.l	endadr(a5)
	beq.b	.no_end2
	cmp.l	endadr(a5),a4
	bhi.b	.f
.no_end2
	move.l	a2,a0
	bsr	print	;Line

	tst.b	dflag(a5)
	beq.b	.dmp
	dbf	d6,.dmp

.f
	move.l	a4,oldptr(a5)
	bra.w	mainmenu
.adr	dcb.l	2,0

;cls	lea	cls.txt(pc),a0
;	bra	print

*** Allouer de la mémoire
* Alloc   <size>	allouer size octets
* Alloc #<addr> <size>	allouer size octets à l'adresse <adr> (AllocAbs)
AllocMemory:
	addq.l	#1,a0
	tst.b	(a0)
	beq.s	.badargs
;	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
	bsr	spc

	cmp.b	#'#',(a0)+
	beq.s	.allocabs
	subq.l	#1,a0

	bsr	Convert
	tst.l	d0
	bne.s	.badargs
	move.l	d1,d4

	move.l	d1,d0
	moveq	#0,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	.failed
.alloc_ok
	move.l	d0,-(sp)
	move.l	d4,-(sp)
	move.l	sp,a1
	lea	alloc.txt(pc),a0
	bsr	printf
	addq.l	#8,sp

	bra.s	.f
.badargs
	bsr	BadArgs
.f	bra	mainmenu

.allocabs
	bsr	Convert
;	tst.l	d0
;	bne.s	.badargs
	move.l	d1,a4
.spc1	bsr	spc
	bsr	Convert
	tst.l	d0
	bne.s	.badargs
	move.l	d1,d0
	move.l	d1,d4
	move.l	a4,a1
	move.l	4.w,a6
	jsr	AllocAbs(a6)
	tst.l	d0
	bne.s	.alloc_ok
.failed
	lea	allocerr.txt(pc),a0
	bsr	print
	bra.s	.f

*** FreeMemory <addr> <bytesize>
FreeMemory:
	addq.l	#1,a0
	tst.b	(a0)
	beq.s	.badargs
;	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	movem.l .adr(pc),d0/a1
	exg	d0,a1
	move.l	4.w,a6
	jsr	FreeMem(a6)

	bra.s	.f
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.adr	dcb.l	2,0

*** Effacer une zone mémoire avec des zéros
* CL <start> <end>
ClearMem:
	addq.l	#2,a0
	tst.b	(a0)
	beq.s	.badargs
	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	movem.l .adr(pc),d0-d1	;StartAdr en d0, EndAdr en d1
	cmp.l	d0,d1		;vérifier que StartAdr < EndAdr
	bcs.s	.badargs

	lea	clrmem.txt(pc),a0
	lea	.adr(pc),a1
	bsr	printf
;effacer la zone mémoire
	movem.l .adr(pc),a0/a1
	suba.l	a0,a1
	move.l	a1,d0		;length
.clr	clr.b	(a0)+
	subq.l	#1,d0
	bne.s	.clr

	bra.s	.f
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.adr	dc.l	0,0

;Copier une zone mémoire vers une autre
;C <start> <end> <dest>
CopMem:
	addq.l	#1,a0
	tst.b	(a0)
	beq.s	.badargs
;	clr.b	(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#3-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	movem.l .adr(pc),d0/d1	;StartAdr en d0, EndAdr en d1
	cmp.l	d0,d1		;vérifier que StartAdr < EndAdr
	bcs.s	.badargs

	lea	copmem.txt(pc),a0
	lea	.adr(pc),a1
	bsr	printf
;copier la zone mémoire
	movem.l .adr(pc),a0/a1/a2
	suba.l	a0,a1
	move.l	a1,d0		;length
	move.l	a2,a1
	move.l	4.w,a6
	jsr	CopyMem(a6)

	bra.s	.f
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.adr	dc.l	0,0,0

*** FIND <start> <end> <data>
* rechercher une chaine ASCII ou HEX en mémoire
FindMem:
	addq.l	#4,a0
	tst.b	(a0)
	beq.w	.badargs
;	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.startadr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#'"',d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
.skip1	move.b	(a3)+,d0
	beq.s	.end1
	cmp.b	#'"',d0         ;ascii string
	beq.s	.end1
	cmp.b	#'$',d0         ;hex string
	bne.s	.skip1
.hex
	move.l	a3,a0
	bsr	StrLen
	lsr	#1,d0
	move.l	d0,d6
	move.l	d0,d7
	subq	#1,d7
	move.l	a3,a0
	lea	hexbuf(pc),a1
	move.l	a1,-(sp)
.hconv
	moveq	#2,d3
	bsr	HConv
	move.b	d1,(a1)+
	dbf	d7,.hconv
	clr.b	(a1)
	move.l	(sp)+,a0
	bra.s	.start
.end1
	move.l	a3,a0		;adr find-string
	bsr	StrLen
	move.l	d0,d6
	lea	strbuf(pc),a1
	move.l	a1,-(sp)
	subq	#1,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop
	clr.b	(a1)
	move.l	(sp)+,a0
.start
	lea	.stradr(pc),a1
	move.l	a0,(a1)

	move.l	.startadr(pc),a0 ;StartAdr, EndAdr
	move.l	.endadr(pc),a1
	suba.l	a0,a1		;vérifier que StartAdr < EndAdr
	bmi.s	.badargs
	move.l	a1,d7
.find
	move.l	.stradr(pc),a3
	move.l	.startadr(pc),a0
	move.l	d7,d0
.find_loop
	btst	#6,$bfe001	;press leftmousebutton to break
	beq.s	.f

	move.l	a3,a4
	move	d6,d1		;len find-string
	subq	#1,d1
.cmp
	subq.l	#1,d0
	bmi.s	.end_reached
	cmpm.b	(a0)+,(a4)+	;case insensitive search
	bne.s	.find_loop
	dbf	d1,.cmp
	bra.b	.found
.end_reached
	lea	lf.txt(pc),a0
	bsr	print
	bra.s	.f		;fin si pas trouvé
.found
	movem.l d0-a6,-(sp)
	sub.l	d6,a0
	move.l	a0,-(sp)
	move.l	sp,a1
	lea	.adr.txt(pc),a0
	bsr	printf
	addq.l	#4,sp
	movem.l (sp)+,d0-a6
	bra.s	.find_loop	;find next occurence
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.startadr	dc.l	0
.endadr		dc.l	0
.stradr dc.l	0
.adr.txt dc.b '$%08lx ',0
	even

*** FILL <start> <end> <data>
FillMem:
	addq.l	#4,a0
	tst.b	(a0)
	beq.w	.badargs
;	clr.b	-1(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.startadr(pc),a4
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#'"',d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
.skip1	move.b	(a3)+,d0
	beq.s	.end1
	cmp.b	#'"',d0         ;ascii string
	beq.s	.end1
	cmp.b	#'$',d0         ;hex string
	bne.s	.skip1
.hex
	move.l	a3,a0
	bsr	StrLen
	lsr	#1,d0
	move.l	d0,d6
	move.l	d0,d7
	subq	#1,d7
	move.l	a3,a0
	lea	hexbuf(pc),a1
	move.l	a1,-(sp)
.hconv
	moveq	#2,d3
	bsr	HConv
	move.b	d1,(a1)+
	dbf	d7,.hconv
	clr.b	(a1)
	move.l	(sp)+,a0
	bra.s	.start
.end1
	move.l	a3,a0		;string addr
	bsr	StrLen
	move.l	d0,d6
	lea	strbuf(pc),a1
	move.l	a1,-(sp)
	subq	#1,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop
	clr.b	(a1)
	move.l	(sp)+,a0
.start
	lea	.stradr(pc),a1
	move.l	a0,(a1)

	move.l	.startadr(pc),a0;StartAdr, EndAdr
	move.l	.endadr(pc),a1
	suba.l	a0,a1		;vérifier que StartAdr < EndAdr
	bmi.s	.badargs
	move.l	a1,d7

	move.l	.stradr(pc),a3
	move.l	.startadr(pc),a0
	move.l	d7,d0
.fill_lop
	btst	#6,$bfe001
	beq.s	.f

	move.l	a3,a4
	move.l	d6,d1		;strlen
	subq	#1,d1
.fill
	subq.l	#1,d0
	bmi.s	.end_reached
	move.b	(a4)+,(a0)+
	dbf	d1,.fill
	bra.s	.fill_lop
.end_reached
	bra.s	.f
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.startadr	dc.l	0
.endadr		dc.l	0
.stradr dc.l	0

*** EditMem <adr>
EditMem:
	addq.l	#1,a0
	tst.b	(a0)
	beq.w	.badargs
;	clr.b	(a0,d7.w)
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	lea	.adr(pc),a4
	bsr	Convert
	move.l	d1,(a4) 	;adr

.edit
	lea	adr.txt(pc),a0
	lea	.adr(pc),a1
	bsr	printf

	lea	editbuf(pc),a3
	clr	comlen(a5)
.wait
	move.l	winbase(a5),a0
	bsr.w	WaitMsg
	cmp.l	#$400,d6
	bne.s	.wait

	btst	#7,d4		;touche relachée?
	bne.s	.wait
	move	d4,d0
	and	#$60,d0
	cmp	#$60,d0 	;shift, ctrl, etc..?
	beq.s	.wait

	bsr.w	ConvRawKey	;convertir code rawkey en ascii

	lea	string(pc),a0
	move.b	(a0),d0
;	cmp.b	#$20,d0
;	beq.s	.space
	cmp.b	#$d,d0		;cr?
	beq.s	.return
	cmp.b	#8,d0		;backspace?
	beq.w	.dobackspace
	cmp.b	#$1b,d0 	;esc?
	beq.s	.esc

	move.b	d0,(a3)+
.space
	cmp	#editbuflen,comlen(a5)
	bge.s	.wait
	addq	#1,comlen(a5)
	bsr	print
	bra.s	.wait
.return
	clr.b	(a3)
	lea	lf.txt(pc),a0
	bsr	print
	move.l	.adr(pc),a4

	lea	editbuf(pc),a0
	cmp.b	#'"',(a0)       ;mode ascii?
	beq.s	.ascii
	bsr	StrLen
	tst.l	d0
	beq.s	.retry
	subq.l	#1,d0
	asr.l	#1,d0
	move.l	d0,d7
;	subq.l	#1,d7
;	tst.l	d7
	blt.s	.retry
.hconv
	cmp.b	#$20,(a0)+
	beq.s	.hconv
	subq.l	#1,a0
	moveq	#2,d3
	bsr	HConv
	move.b	d1,(a4)+
	dbf	d7,.hconv
.fin_ligne
	lea	.adr(pc),a0
	move.l	a4,(a0)
	bra	.edit
.ascii
	addq.l	#1,a0
	bsr	StrLen
	tst.l	d0
	beq.s	.retry		;len=0?
	subq	#1,d0
.copmem move.b	(a0)+,(a4)+
	dbf	d0,.copmem
	bra.s	.fin_ligne
.badargs
	bsr	BadArgs
.f	bra	mainmenu
.esc
	lea	.esc.txt(pc),a0
	bsr	print
	bra.s	.f
.retry
	lea	.retry.txt(pc),a0
	bsr	print
	bra	.edit
.dobackspace
	tst	comlen(a5)
	ble	.wait
	subq	#1,comlen(a5)
	cmp.b	#'"',(a3)
	beq.s	.do_bs
	subq.l	#1,a3		;adr-1
.do_bs	lea	backspace.txt(pc),a0
	bsr	print
	bra	.wait
.adr	dc.l	0

.retry.txt	dc.b $b
.esc.txt	dc.b $d,$9b,'K',$d,0
adr.txt 	dc.b '%08lx: ',0
	even
*** afficher la liste des modules résidents en mémoire
ListResModules:
	move.b	1(a0),d0
	cmp.b	#'l',d0
	beq	ListLibs
	cmp.b	#'d',d0
	beq	ListDevs
	cmp.b	#'r',d0
	beq	ListRes
	cmp.b	#'t',d0
	beq	ListTasks
	cmp.b	#'p',d0
	beq	ListPorts
	cmp.b	#'i',d0
	beq	ListInts
	cmp.b	#'m',d0
	beq.s	.resmod
	cmp.b	#'M',d0
	beq	ListMem
	bsr	BadArgs
	bra.s	.z
.resmod
	bsr	CursOff
	lea	resmods.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	ResModules(a6),a4
.c	move.l	(a4)+,d7
	beq.b	.z
	btst	#6,$bfe001
	beq.s	.z

	lea	-5*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.l	d7,(a2)+
	move.l	d7,a0
	move.b	RT_PRI(a0),d0
	ext	d0
	move	d0,(a2)+
	moveq	#0,d0
	move.b	RT_VERSION(a0),d0
	move	d0,(a2)+
	move.l	RT_NAME(a0),(a2)+
	lea	.noid.txt(pc),a3
	tst.l	RT_IDSTRING(a0)
	beq.s	.id_done
	move.l	RT_IDSTRING(a0),a3
.id_done
	move.l	a3,(a2)+
	lea	.res.txt(pc),a0
	bsr	printf
	lea	5*4(sp),sp
	bra.b	.c
.z
	bra	mainmenu
.res.txt dc.b '%08lx %-4.4d %-3.3d %-25.25s %s',0
.noid.txt dc.b $a,0
	even
* afficher liste des libraries
ListLibs:
	lea	reslibs.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	LibList(a6),a4
List_
	bsr	CursOff

.list	move.l	a4,d7
	beq.s	.z
	tst.l	(a4)
	beq.s	.z
	btst	#6,$bfe001
	beq.s	.z

	move.l	d7,a0
	lea	-4*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.l	d7,(a2)+
	move	LIB_OPENCNT(a0),(a2)+
	move	LIB_VERSION(a0),(a2)+
	move	LIB_REVISION(a0),(a2)+
	move.l	LN_NAME(a0),(a2)+
	lea	.txt(pc),a0
	bsr	printf
	lea	4*4(sp),sp

	move.l	(a4),a4 	;next libnode
	bra.s	.list
.z
	bra	mainmenu
.txt	dc.b	'%08lx %-3d %d.%d',9,'%s',$a,0
	even
* afficher liste des devices
ListDevs:
	lea	resdevs.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	DeviceList(a6),a4
	bra.s	List_
* afficher liste des resources
ListRes:
	lea	resres.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	ResourceList(a6),a4
	bra.w	List_
* afficher PortList
ListPorts:
	bsr	CursOff
	lea	port.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	PortList(a6),a4

.list	move.l	a4,d7
	beq.s	.z
	tst.l	(a4)
	beq.s	.z
	btst	#6,$bfe001
	beq.s	.z

	move.l	d7,a0
	lea	-6*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.l	d7,(a2)+
	move.l	LN_NAME(a0),d0
	bne.s	.put_name
	lea	.no_name(pc),a3
	move.l	a3,d0
.put_name
	move.l	d0,(a2)+

	lea	.flag_unkn(pc),a3
	move.b	MP_FLAGS(a0),d0
	cmp.b	#2,d0
	bne.s	.fl_softint
	lea	.flag_ignore(pc),a3
	bra.s	.fl_done
.fl_softint
	cmp.b	#1,d0
	bne.s	.fl_signal
	lea	.flag_softint(pc),a3
	bra.s	.fl_done
.fl_signal
	tst.b	d0
	bne.s	.fl_done
	lea	.flag_signal(pc),a3
.fl_done
	move.l	a3,(a2)+

	moveq	#0,d0
	move.b	MP_SIGBIT(a0),d0
	move	d0,(a2)+

	move.l	MP_SIGTASK(a0),a0
	move.l	LN_NAME(a0),d0
	bne.s	.put_tname
	lea	.no_name(pc),a0
	move.l	a0,d0
.put_tname
	move.l	d0,(a2)+
	lea	.txt(pc),a0
	bsr	printf
	lea	6*4(sp),sp

	move.l	(a4),a4 	;next libnode
	bra.s	.list
.z
	bra	mainmenu
.txt	dc.b	'%08lx %-20s %-8.8s %-6.6d %s',$a,0
.no_name	dc.b '-------',0
.flag_unkn	dc.b '???????',0
.flag_signal	dc.b 'Signal ',0
.flag_ignore	dc.b 'Ignore ',0
.flag_softint	dc.b 'SoftInt',0
	even
* afficher InterruptList
ListInts:
	bsr	CursOff
	lea	int.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	IntrList(a6),a4

.list	move.l	a4,d7
	beq.s	.z
	tst.l	(a4)
	beq.s	.z
	btst	#6,$bfe001
	beq.s	.z

	move.l	d7,a0
	lea	-6*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.l	d7,(a2)+
	move.l	IS_CODE(a0),(a2)+
	move.l	IS_DATA(a0),(a2)+
	move.b	LN_PRI(a0),d0
	ext	d0
	move	d0,(a2)+
	move.l	LN_NAME(a0),d0
	bne.s	.put_name
	lea	.no_name(pc),a3
	move.l	a3,d0
.put_name
	move.l	d0,(a2)+
	lea	.txt(pc),a0
	bsr	printf
	lea	6*4(sp),sp

	move.l	(a4),a4 	;next node
	tst.l	(a4)
	bne.s	.list
.z
	bra	mainmenu
.txt	dc.b	'%08lx %08lx %08lx %-4.4d %s',$a,0
.no_name dc.b '-------',0
	even
* afficher TaskList
ListTasks:
	bsr	CursOff
	lea	task.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	jsr	Forbid(a6)
	move.l	ThisTask(a6),a4
	bsr.s	.list
	move.l	TaskWait(a6),a4
	bsr.s	.list
	move.l	TaskReady(a6),a4
	bsr.s	.list
	jsr	Permit(a6)
	bra	mainmenu

.list	move.l	a4,d7
	beq	.z
	tst.l	(a4)
	beq	.z
	btst	#6,$bfe001
	beq.w	.z

	move.l	d7,a0
	lea	-5*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.l	d7,(a2)+
	moveq	#0,d0
	move.b	LN_TYPE(a0),d0
	lea	.state_unkn(pc),a3
	cmp.b	#NT_TASK,d0
	bne.s	.no_task
	lea	.type_task(pc),a3
	bra.s	.type_done
.no_task
	cmp.b	#NT_PROCESS,d0
	bne.s	.type_done
	lea	.type_proc(pc),a3
.type_done
	move.l	a3,(a2)+

	move.b	tc_State(a0),d0
	lea	.state_unkn(pc),a3
	cmp.b	#TS_WAIT,d0
	bne.s	.no_wait
	lea	.state_wait(pc),a3
	bra.s	.state_done
.no_wait
	cmp.b	#TS_READY,d0
	bne.s	.no_ready
	lea	.state_ready(pc),a3
	bra.s	.state_done
.no_ready
	cmp.b	#TS_RUN,d0
	bne.s	.no_run
	lea	.state_run(pc),a3
	bra.s	.state_done
.no_run
	cmp.b	#TS_ADDED,d0
	bne.s	.no_added
	lea	.state_added(pc),a3
	bra.s	.state_done
.no_added
	cmp.b	#TS_REMOVED,d0
	bne.s	.state_done
	lea	.state_removed(pc),a3
.state_done
	move.l	a3,(a2)+

	move.b	LN_PRI(a0),d0
	ext	d0
	move	d0,(a2)+

	move.l	LN_NAME(a0),(a2)+
	lea	.txt(pc),a0
	bsr	printf
	lea	5*4(sp),sp

	move.l	(a4),a4 	;next libnode
	move.l	(a4),d0
	bne.w	.list
.z
	rts
.txt	dc.b	'%08lx %-7.7s %-7.7s %-4.4d %s',$a,0
.type_proc	dc.b 'Process',0
.type_task	dc.b 'Task   ',0
.state_wait	dc.b 'Waiting',0
.state_ready	dc.b 'Ready  ',0
.state_run	dc.b 'Running',0
.state_added	dc.b 'Added  ',0
.state_removed	dc.b 'Removed',0
.state_unkn	dc.b '???????',0
	even

* Afficher execbase->MemList
ListMem:
	bsr	CursOff
	lea	mem.txt(pc),a0
	bsr	print
	move.l	4.w,a6
	move.l	MemList(a6),a4
.lop	tst.l	(a4)
	beq.s	.end
	lea	-8*4(sp),sp
	move.l	sp,a1
	move.l	a1,a2
	move.b	LN_TYPE(a4),d0
	ext	d0
	move	d0,(a2)+
	move	MH_ATTRIBUTES(a4),(a2)+
	move.l	MH_LOWER(a4),(a2)+
	move.l	MH_UPPER(a4),d0
	move.l	d0,(a2)+
	sub.l	MH_LOWER(a4),d0
;	divu	#1024,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	move	d0,(a2)+
	move.b	LN_PRI(a4),d0
	ext	d0
	move	d0,(a2)+
	move.l	LN_NAME(a4),(a2)+
	lea	.txt(pc),a0
	bsr	printf
	lea	8*4(sp),sp
	move.l	LN_SUCC(a4),d0
	move.l	d0,a4
	tst.l	d0
	bne.s	.lop
.end
	bra	mainmenu
.txt	dc.b '$%-8.8x $%-4.4x $%08lx $%08lx %-9.9d %-4.4d %s',$a,0
	even
*** Calculer le CheckSum d'un BLOCK (bb, bmap, root, udir, fileheader...)
* b  <addr>	root, udir, fileheader block
* bb <addr>	Bootblock
* bm <addr>	Bitmap block
BlockCheckSum:
	addq.l	#1,a0
	move.b	(a0)+,d0
	beq.s	.badargs
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	tst.b	1(a0)
	beq.s	.badargs
	cmp.b	#'b',d0         ;boot
	beq.s	.boot
	cmp.b	#'m',d0         ;bmap
	beq.s	.bmap

	bsr	Convert
	tst.l	d0
	bne.s	.badargs
	move.l	d1,a0		;<addr>
* calculer checksum (suivant le type de block)
	moveq	#8,d0		;blocktype: data
	cmp.l	(a0),d0
	beq.s	.data

	bsr.s	cs_root
.done
	move.l	d0,d7
	lea	checksum.txt(pc),a0
	movem.l d6-d7,-(sp)
	move.l	sp,a1
	bsr	printf
	addq.l	#8,sp
	bra.s	.f

.data
	bsr.w	cs_data
	bra.s	.done
.bmap
.spc2
	bsr	spc
	bsr	Convert
	tst.l	d0
	bne.s	.badargs
	move.l	d1,a0
	bsr.s	cs_bmap
	bra.s	.done
.boot
.spc3
	bsr	spc
	bsr	Convert
	tst.l	d0
	bne.s	.badargs
	move.l	d1,a0
	bsr.s	cs_boot
	bra.s	.done
.badargs
	bsr	BadArgs
.f	bra	mainmenu

* calc. Bootblock CheckSum
cs_boot:
	move.l	4(a0),d6
	clr.l	4(a0)
	move.l	a0,-(sp)
	moveq	#0,d0
	move	#$ff,d1
.bcl	add.l	(a0)+,d0
	bcc.s	.do
	addq.l	#1,d0
.do	dbf	d1,.bcl
	not.l	d0
	move.l	(sp)+,a0
	move.l	d0,4(a0)
	rts
* routine valable pour root, udir, list, file.
cs_root:
	move.l	20(a0),d6	;ancien checksum
	clr.l	20(a0)		;effacer ancien
	move.l	a0,-(sp)
	moveq	#$7f,d1 	;nbre de mots
	moveq	#0,d0
.bcl	add.l	(a0)+,d0
	dbf	d1,.bcl
	subq.l	#1,d0
	not.l	d0
	move.l	(sp)+,a0
	move.l	d0,20(a0)	;nveau csum
	rts
cs_bmap:
	move.l	(a0),d6 	;ancien checkum
	clr.l	(a0)		;effacer ancien
	move.l	a0,-(sp)
	moveq	#$7f,d1 	;nbre de mots
	moveq	#0,d0
.bcl	add.l	(a0)+,d0
	dbf	d1,.bcl
	not.l	d0
	addq.l	#1,d0
	move.l	(sp)+,a0
	move.l	d0,(a0) 	;nveau csum
	rts
cs_data
	move.l	20(a0),d6	;ancien checksum
	clr.l	20(a0)		;effacer ancien
	move.l	a0,-(sp)
	moveq	#$7f,d1 	;nbre de mots
	moveq	#0,d0
.bcl	add.l	(a0)+,d0
	dbf	d1,.bcl
	not.l	d0
	addq.l	#1,d0
	move.l	(sp)+,a0
	move.l	d0,20(a0)	;nveau csum
	rts

*** Install disk  [unité] [FFS]
InstallDisk:
	addq.l	#4,a0

	move.l	defunit(a5),d6	;unité par défaut
	moveq	#0,d7		;flag: 0=OFS, 1=FFS

	tst.b	(a0)
	beq.s	.no_opts
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	bsr	Convert
	tst.l	d1
	bmi.w	.badunit
	moveq	#3,d0
	cmp.l	d0,d1
	bhi.w	.badunit
	lsl.l	#2,d1
	move.l	d1,d6		;unit en d6

.spc1
	bsr	spc
	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	clr.b	d0
	and.l	#$dfdfdf00,d0
	cmp.l	#$46465300,d0	;'FFS' ?
	bne.s	.ofs
	moveq	#1,d7
.ofs

.no_opts
	lea	bootblock.data(pc),a0
	move.b	d7,3(a0)
	lea	trkbuf(a5),a1
	moveq	#bootblock.size-1,d0
.cop	move.b	(a0)+,(a1)+
	dbf	d0,.cop

	lea	trkbuf(a5),a0
	move.l	d6,-(sp)
	bsr	cs_boot 	;calculer checksum
	move.l	(sp)+,d6

	move.l	unit0(a5,d6.w),a1
	move.l	a1,d7
	beq.s	.badunit

	move	#3,28(a1)	;TD_WRITE
	move.l	a0,40(a1)	;io_data: adr
	clr.l	44(a1)		;io_offset
	move.l	#$400,36(a1)	;io_length
	move.l	4.w,a6
	jsr	DoIO(a6)
	tst.l	d0
	beq.s	.no_err
	lea	diskerr.txt(pc),a0
	bsr	print
.no_err
	move.l	d7,a1
	move	#4,28(a1)	;TD_UPDATE
	jsr	DoIO(a6)

	bsr	MotorOff
.f
	bra	mainmenu
.badargs
	bsr	BadArgs
	bra.s	.f
.badunit
	lea	badunit.txt(pc),a0
	bsr	print
	bra.s	.f


*** Read Diskblocks <adr> <offset> <length>
ReadBlocks:
	clr.b	-1(a0,d7.w)
	addq.l	#1,a0
	tst.b	(a0)
	beq.w	.badargs
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#4-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
* lire les blocks
	lea	readblk.txt(pc),a0
	lea	.adr(pc),a1
	move.l	defunit(a5),3*4(a1)
	bsr	printf

	move.l	curunit(a5),a1
	move.l	a1,d7

	move	#2,28(a1)	;TD_READ
	lea	.adr(pc),a0
	move.l	(a0),oldptr(a5) ;adresse pour le dump
	move.l	(a0)+,40(a1)	;io_data: adr
	move.l	(a0)+,d0	;<offset>
	moveq	#9,d1
	lsl.l	d1,d0
	move.l	d0,44(a1)	;io_offset
	move.l	(a0)+,d0	;<len>
	lsl.l	d1,d0
	move.l	d0,36(a1)	;io_length
	move.l	4.w,a6
	jsr	DoIO(a6)
	tst.l	d0
	beq.s	.no_err
	lea	diskerr.txt(pc),a0
	bsr	print
.no_err
	bsr	MotorOff
	bra.s	.nodev
.abort
	lea	abort.txt(pc),a0
	bsr	print
.nodev
	bra.s	.f
.badargs
	bsr.w	BadArgs
.f
	bra	mainmenu

.adr	dcb.l	5,0

*** Write Diskblocks <adr> <offset> <length>
WriteBlocks:
	clr.b	-1(a0,d7.w)
	addq.l	#1,a0
	tst.b	(a0)
	beq.w	.badargs
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	moveq	#4-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
* lire les blocks
	lea	readblk.txt(pc),a0
	lea	.adr(pc),a1
	move.l	defunit(a5),3*4(a1)
	bsr	printf

	move.l	curunit(a5),a1
	move.l	a1,d7

	move	#3,28(a1)	;TD_WRITE
	lea	.adr(pc),a0
	move.l	(a0)+,40(a1)	;io_data: adr
	move.l	(a0)+,d0	;<offset>
	moveq	#9,d1
	lsl.l	d1,d0
	move.l	d0,44(a1)	;io_offset
	move.l	(a0)+,d0	;<len>
	lsl.l	d1,d0
	move.l	d0,36(a1)	;io_length
	move.l	4.w,a6
	jsr	DoIO(a6)
	tst.l	d0
	beq.s	.no_err
	lea	diskerr.txt(pc),a0
	bsr	print
.no_err
	move.l	d7,a1
	move	#4,28(a1)	;TD_UPDATE
	jsr	DoIO(a6)

	bsr	MotorOff
	bra.s	.nodev
.abort
	lea	abort.txt(pc),a0
	bsr	print
.nodev
	bra.s	.f
.badargs
	bsr.w	BadArgs
.f
	bra	mainmenu

.adr	dcb.l	5,0


**** routines Trackdisk
*** Ouvrir une unité de disk
* <-- d0: n° unité (0,..,4)
* --> d0: Structure 'Unit', ou 0 si erreur
OpenUnit:
	move.l	d0,d7
* on alloue d'abord une structure 'custom': la structure 'Unit'
* qui regroupe l'IORequest et le MsgPort
	moveq	#34+56,d0
	move.l	#$10001,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,d6
	beq.b	.err
* initialiser MsgPort
	move.l	d6,a1
	lea	56(a1),a1	;ptr sur MsgPort
	move.l	a1,-(sp)
	move.l	mytask(a5),$10(a1)
	jsr	AddPort(a6)	;trackdisk message port
	tst.l	d0
	beq.b	.free
* ouvrir device
	move.l	d6,a1
	move.l	(sp)+,14(a1)	;msgport
	move.l	d7,d0		;unit #
	moveq	#1,d1		;flags: ALLOW_NON_3_5
	lea	trackname(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0		;0=no err
	bne.b	.remport
	move.l	d6,d0		;En retour: Unit (0=err)
	rts
.remport
	move.l	d6,a1
	lea	56(a1),a1
	jsr	RemPort(a6)
.free
	move.l	d6,a1
	moveq	#34+56,d0
	jsr	FreeMem(a6)
.err	moveq	#0,d0
	rts

* <-- a0: struct 'Unit' de l'unité à fermer
CloseUnit:
	move.l	a0,d6
	beq.b	.f
	move.l	a0,-(sp)
	move.l	14(a0),a1
	jsr	RemPort(a6)	;supprimer le port
	move.l	(sp)+,a1
	jsr	CloseDevice(a6)
	move.l	d6,a1
	moveq	#34+56,d0
	jmp	FreeMem(a6)	;libérer struct 'unit'
.f	rts

* éteindre le moteur du drive courant
MotorOff:
	movem.l d0-a6,-(sp)
	move.l	curunit(a5),a1
	move	#9,28(a1)
	clr.l	36(a1)
	move.l	4.w,a6
	jsr	DoIO(a6)
	movem.l (sp)+,d0-a6
	rts

BadArgs:
	move.l	a0,-(sp)
	lea	badargs.txt(pc),a0
	bsr	print
	move.l	(sp)+,a0
	rts


*** Désinstaller RESET-TOOL
UnInstall:
	lea	uninstall.txt(pc),a0
	bsr	print
	move.l	myresptr(pc),a0
	clr	(a0)		;clear RTC_MATCHWORD
				;so that I won't be recognized at next reboot
				;but the memory I use isn't freed though

*** Effectuer un reboot de la machine
reboot:
	IFEQ	DBUG

MAGIC_ROMEND	    EQU $01000000   ;End of Kickstart ROM
MAGIC_SIZEOFFSET    EQU -$14	    ;Offset from end of ROM to Kickstart size
	move.l	4.w,a6
	cmp	#36,LIB_VERSION(a6)
	blt.s	.old_exec
	jmp	ColdReboot(a6)     ;Let Exec do it...
* manually reset the Amiga
.old_exec
	lea	.GoAway(pc),a5	;address of code to execute
	jsr	Supervisor(a6)	;trap to code at (a5)...
	;NOTE: Control flow never returns to here
* MagicResetCode --- DO NOT CHANGE
	CNOP	0,4			;IMPORTANT! Longword align!
.GoAway	lea	MAGIC_ROMEND,a0 	;(end of ROM)
	sub.l	MAGIC_SIZEOFFSET(a0),a0	;(end of ROM)-(ROM size)=PC
	move.l	4(a0),a0		;Get Initial Program Counter
	subq.l	#2,a0			;now points to second RESET
	reset				;first RESET instruction
	jmp	(a0)			;CPU Prefetch executes this
	;NOTE: the RESET and JMP instructions must share a longword!

	ENDC
	bra	mainmenu

*** Desass [start] [end]
DIS_LINES=16
Dis:
;	clr.b	-1(a0,d7.w)
	addq.l	#1,a0
	tst.b	(a0)		;pas d'arguments?
	beq.s	.lastadr
;sauter les espaces en début de chaine, s'il y'en a
.spc	bsr	spc

	move.l	a0,a3
	lea	.adr(pc),a4
	clr.l	(a4)		;start addr=0
	clr.l	4(a4)		;end addr=0
	moveq	#2-1,d6
.rdargs
	move.l	a3,a0
	bsr	Convert
	move.l	d1,(a4)+
.skip	move.b	(a3)+,d0
	beq.s	.end
	cmp.b	#$20,d0
	bne.s	.skip
	dbf	d6,.rdargs
.end
	bsr	CursOff

	movem.l .adr(pc),d0-d1
	tst.l	d1		;pas d'addr de fin?
	beq.s	.dis		;alors on veut un certain nombre de lignes
	sub.l	d0,d1
	bmi.s	.badargs
.dis	move.l	.adr(pc),a0
	moveq	#DIS_LINES-1,d7
.bcl
	btst	#6,$bfe001
	beq.s	.f
	lea	strbuf(pc),a1
	bsr.s	Desass
	lea	strbuf(pc),a0
	bsr	print
	move.l	d0,a0

	move.l	.adr+4(pc),d1
	bne.s	.until_end
	dbf	d7,.bcl
	bra.s	.f
.until_end
	cmp.l	d0,d1
	bhi.s	.bcl

.f
	move.l	d0,lastdis(a5)	;sauver adresse
.f1	bra	mainmenu
.badargs
	bsr	BadArgs
	bra.s	.f1
.lastadr
	lea	.adr(pc),a4
	move.l	lastdis(a5),(a4)
	clr.l	4(a4)
	bra.s	.end

.adr	dc.l	0,0

*** Désassembleur MC68000
* rippé dans 'ROMCRACK' de SCA
* amélioré par Frédéric Bassaler
*
* cette routine désassemble une ligne de code
* paramètres d'entrée:
* a0: src
* a1: dest
* en sortie:
* d0: adresse instruction suivante
da_LF=$a
Desass:
	movem.l d2-d7/a2-a4,-(sp)
	move.l	a1,a3
	move.l	a0,d0
	bclr	#0,d0		;adresse paire
	move.l	d0,a4
	move.l	d0,-(sp)
	moveq	#7,d1
	bsr.w	ConvHex2	;convertir adr de désass.
	move.l	(sp)+,d0
	move.b	#':',(a3)+
	move.b	#9,(a3)+
	lea	passflag(pc),a0
	clr.b	(a0)
	move.l	a0,-(sp)
	bsr.b	desass_instruction
	move.l	(sp)+,a0
	tst.b	(a0)
	bne.s	.no_second_pass
	move.b	#9,(a3)+	;tab
	bsr.w	desass_instruction2
.no_second_pass
	move.b	#da_LF,(a3)+	;lf
	clr.b	(a3)
	move.l	a4,d0
	move.b	d7,d1
	movem.l (sp)+,d2-d7/a2-a4
	rts

;détermine l'instruction
desass_instruction:
	move	(a4)+,d5

;	move	d5,d0
;	moveq	#3,d1
;	bsr.w	ConvHex2	;hexdump de l'opcode
;	move.b	#9,(a3)+

	move	d5,d0
	and	#$f000,d0
	cmp	#$a000,d0
	beq.w	line_a
	cmp	#$f000,d0
	beq.w	line_f

	move.b	#$c0,d4
	and.b	d5,d4
	lea	instruction_table(pc),a0
	moveq	#0,d2
next_op:
	move	d5,d1
	and	(a0)+,d1
	cmp	(a0)+,d1
	beq.s	opcode_found
	addq	#1,d2
	addq	#2,a0
	bra.s	next_op
opcode_found:
	move	(a0),d6
	bclr	#14,d6
	sne	d7
	lea	instructions.txt(pc),a0
lop
	move.l	a3,a1
.lop0
	move.b	(a0)+,d0
	cmp.b	#'*',d0
	beq.s	opcode_inconnu
	cmp.b	#'+',d0
	beq.s	point
	move.b	d0,(a1)+
	cmp.b	#'Z',d0
	bcs.s	.lop0
	bclr	#5,-1(a1)
	bra.s	lop1

point	move.b	#'.',(a1)+

lop1	dbf	d2,lop
	move.l	a1,a3
	lea	-4(a3),a0
	cmp.b	#'@',(a0)
	beq.s	get_condition_code
	addq.l	#2,a0
	cmp.b	#'@',(a0)
	bne.s	get_instruction
get_condition_code:
	move	d5,d0
	lsr	#7,d0
	and	#30,d0
	lea	condition_codes.txt(pc,d0.w),a2
;	add	d0,a2
	move.b	(a2)+,(a0)+	;copier le code de condition
	move.b	(a2),(a0)
get_instruction:
	move	d5,d0
	and	#$f138,d0
	cmp	#$0108,d0	;type movep
	bne.w	no_movep
	or	#$0020,d5
	or.b	#$80,d4
	bra.w	lbc001a68
opcode_inconnu:
	move.l	a1,a3
	lea	dc.txt(pc),a0
	bsr.w	cop_str
	move	d5,d0
	bsr.s	sort_hex16
	move.b	#9,(a3)+
	move.b	#9,(a3)+
	move	d5,d0
	move.b	#';',(a3)+
	move.b	#'"',(a3)+
	bsr.s	sort_ascii
	move.b	#'"',(a3)+
	rts
sort_ascii:
	moveq	#1,d1
.put
	ror	#8,d0
	cmp.b	#$20,d0
	bcs.s	.null
	cmp.b	#$80,d0
	bcs.s	.put1
.null	moveq	#'.',d0
.put1	move.b	d0,(a3)+
	dbf	d1,.put
	rts
condition_codes.txt:dc.b 'T F HILSCCCSNEEQVCVSPLMIGELTGTLE'
	even
line_a:
	moveq	#'A',d1
line_:
	lea	line.txt(pc),a0
	bsr.w	cop_str
	move.b	d1,(a3)+
	move.b	#9,(a3)+
	move	d5,d0
	and	#$0fff,d0
	moveq	#0,d7
sort_hex16:
	bsr.w	ConvHex16
	lea	passflag(pc),a0
	st	(a0)
	rts
line_f:
	moveq	#'F',d1
	bra.s	line_
line.txt:dc.b 'LINE_',0
dc.txt: dc.b 'DC.W',9,0
passflag:dc.b	0
	even
no_movep:
	move	#$0200,d0
	and	d6,d0
	beq.s	lbc001a6e
lbc001a68
	sub.b	#$40,d4
	bra.s	lbc001a76

lbc001a6e
	moveq	#1,d0
	and	d6,d0
	beq.s	ret0
lbc001a76
	move.b	d4,d0
	move.b	#'L',(a3)
	cmp.b	#$80,d0
	beq.s	lbc001a94
	move.b	#'W',(a3)
	cmp.b	#$40,d0
	beq.s	lbc001a94
	move.b	#'B',(a3)
	move.b	#$c0,d0
lbc001a94
	or.b	d0,d6
	addq	#1,a3
ret0:	rts

;après avoir déterminé l'instruction,
;il faut la décoder
desass_instruction2:
	move	d5,d0
	and	#$fff8,d0
	cmp	#$4e70,d0	;nop, rte, rts...
	bne.s	des_ins
	rts
des_ins:
	lea	_usp.txt(pc),a0
	move	d5,d0
	and	#$fff0,d0
	cmp	#$4e60,d0	;move ax,usp
	bne.s	no_move_ax_usp
	move	d5,d0
	and	#$ffc7,d5
	moveq	#8,d1
	or	d1,d5
	and	d1,d0
	bne.s	move_sr_dx
move_dx_sr:
	move.l	a0,-(sp)
	bsr.w	lbc001baa
	move.b	#',',(a3)+
	move.l	(sp)+,a0
	bra.w	cop_str

move_sr_dx:
	bsr.w	cop_str
	bra.w	lbc001c34

no_move_ax_usp:
	cmp	#$4e40,d0	;instruction trap
	bne.s	no_trap
	move.b	#'#',(a3)+
	move	d5,d0
	and	#$0f,d0
	bra.w	ConvByte

no_trap:
	lea	_sr.txt(pc),a0
	and	#$ffc0,d0
	cmp	#$40c0,d0	;move sr,dx
	beq.s	move_sr_dx
	cmp	#$46c0,d0	;move dx,sr
	beq.s	move_dx_sr
	lea	_ccr.txt(pc),a0
	cmp	#$44c0,d0	;move dx,ccr
	beq.s	move_dx_sr
	move	d6,d0
	and	#$30,d0
	beq.s	lbc001b40
	cmp	#$10,d0
	beq.s	lbc001b40
	bsr.w	lbc001baa
	move.b	#',',(a3)+
	move	d6,d1
	moveq	#1,d0
	and	#$30,d1
	cmp	#$30,d1
	beq.s	lbc001b38
	moveq	#0,d0
lbc001b38
	bsr.w	lbc001e92
	bra.w	lbc001d32

lbc001b40
	move	d5,d0
	and	#$f0f8,d0
	cmp	#$50c8,d0	;dbxx dx,label
	bne.s	no_dbcc
	and	#7,d5
	or	#$15c0,d5
no_dbcc:
	move	d6,d0
	and	#$0400,d0
	beq.s	lbc001b64
	and	#$0e07,d5
	or	#$10d8,d5
lbc001b64
	move	d6,d0
	and	#$1000,d0
	beq.s	lbc001b80
	move	d5,d1
	and	#$0e07,d5
	or	#$1000,d5
	and	#8,d1
	beq.s	lbc001b80
	or	#$0120,d5
lbc001b80
	move	d5,d0
	and	#$c000,d0
	bne.s	lbc001baa
	move	d5,d0
	and	#$3000,d0
	beq.s	lbc001baa
	bsr.b	lbc001baa
	move.b	#',',(a3)+
	bsr.w	lbc001e92
	move	d5,d0
	and	#$01c0,d0
	lsr	#3,d0
	and	#$f000,d5
	or	d1,d5
	or	d0,d5
lbc001baa
	move	d5,d0
	and	#$ff00,d0
	cmp	#$0800,d0	;btst
	bne.s	no_btst
	move.b	#'#',(a3)+
	move	(a4)+,d1	;# de bit
	and	#31,d1		;ne peut dépasser 31 !
	bra.s	conv_byte

no_btst:
	move	d6,d0
	and	#$0100,d0
	beq.s	lbc001c1e
	move	d5,d0
	and	#$f020,d0
	cmp	#$e020,d0	;asr.b dx,dx
	bne.s	no_asr_dx_dx
	and	#$ffc7,d5
	bra.s	lbc001c2a

no_asr_dx_dx:
	cmp	#$e000,d0	;asr.b #n,dx
	bne.s	no_asr_n_dx
	and	#$ffc7,d5
no_asr_n_dx:
	and	#$f000,d0
	cmp	#$7000,d0	;moveq #n,dx
	bne.s	no_moveq
	move.b	#'#',(a3)+
	move.b	d5,d0
	ext	d0
	bpl.s	.posit		;nombre positif?
	move.b	#'-',(a3)+      ;si non, prend son opposé et affiche un -
	neg	d0
.posit	bra.w	ConvByte	;et convertit le nombre
no_moveq:
	move.b	#'#',(a3)+
	bsr.w	lbc001e92
	tst	d1
	bne.s	conv_byte
	moveq	#8,d1
conv_byte:
	move	d1,d0
	bsr.w	ConvByte
	bra.s	lbc001c34

lbc001c1e
	move	d6,d0
	and	#$0030,d0
	cmp	#$0010,d0
	bne.s	lbc001c38
lbc001c2a
	clr	d0
	bsr.w	lbc001e92
	bsr.w	lbc001d32
lbc001c34
	move.b	#',',(a3)+
lbc001c38
	move	d6,d0
	and	#4,d0
	beq.s	get_adr_mode
	move	d5,d0
	ext	d0
	bne.s	lbc001c4a
	move	(a4)+,d0
	subq	#2,d0
lbc001c4a
	ext.l	d0
	add.l	a4,d0
	bra.w	ConvHex32
;détermine le mode d'adressage de l'instruction
get_adr_mode:
	move	d6,d0
	and	#$0200,d0	;mode d(PC) ?
	beq.s	lbc001c7a
	move	d5,d0
	and	#$0400,d0	;mode d(PC,xn) ?
	beq.s	lbc001c72
;sinon, mode d'adressage immediat
	move	(a4)+,d0
	move	d0,-(sp)
	bsr.b	lbc001c7a
	move.b	#',',(a3)+
	move	(sp)+,d0
	bra.w	lbc001dfe

lbc001c72
	bsr.w	lbc001dfc
	move.b	#',',(a3)+
lbc001c7a
	move	d5,d0
	and	#$fff0,d0
	cmp	#$4e50,d0	;link.w ax,#n
	bne.s	no_link_ax_n
	btst	#3,d5
	bne.s	lbc001c9c
	bsr.b	lbc001c9c
	move.b	#',',(a3)+
	move.b	#'#',(a3)+
	move	(a4)+,d0
	bra.w	lbc001f2a

lbc001c9c
	and	#$ffc7,d5
	or	#8,d5
no_link_ax_n:
	move	d6,d0
	and	#2,d0
	beq.w	ret
	move	d6,d0
	and	#8,d0
	beq.s	lbc001cbe
	bsr.w	lbc001ec2
	move.b	#',',(a3)+
lbc001cbe
	move	d5,d0
	and	#$003f,d0
	move	d0,d1
	cmp	#$003a,d0
	bne.s	mode_ABSw
;mode d'adressage adr(PC)
	move	(a4)+,d0
	subq	#2,d0
	ext.l	d0
	add.l	a4,d0
	bsr.w	ConvHex32
	lea	pc.txt(pc),a0
	bra.w	cop_str

mode_ABSw:
	cmp	#$0038,d0
	bne.s	mode_ABSl
	move	(a4)+,d0
	bsr.w	ConvHex16
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
	rts

mode_ABSl:
	cmp	#$0039,d0
	bne.s	lbc001d0c
	move.l	(a4)+,d0
	bsr.w	ConvHex32
;	move.b	#'.',(a3)+
;	move.b	#'L',(a3)+
	rts

lbc001d0c
	cmp	#$003c,d0
	beq.w	lbc001ea6
	cmp	#$003b,d0
	beq.s	lbc001d26
	and	#$0038,d0
	cmp	#$0038,d0
	beq.w	lbc001e9e
lbc001d26
	move	D1,D0
	and	#$0038,D0
	and	#7,D1
	lsr.b	#3,d0
lbc001d32
	dbf	d0,lbc001d3e
lbc001d36
	move.b	#'D',(a3)+
	bra.w	put_digit

lbc001d3e
	dbf	d0,lbc001d5a
lbc001d42
	cmp.b	#7,d1
	bne.s	no_sp
	move.b	#'S',(a3)+
	move.b	#'P',(a3)+
	rts
no_sp:	move.b	#'A',(a3)+
	bra.w	put_digit

lbc001d5a
	dbf	d0,lbc001d6a
parenth:
	move.b	#'(',(a3)+
	bsr.b	lbc001d42
	move.b	#')',(a3)+
	rts

lbc001d6a
	dbf	d0,lbc001d76
	bsr.s	parenth
	move.b	#'+',(a3)+      ;mode (xx)+
	rts

lbc001d76
	dbf	d0,lbc001d80
	move.b	#'-',(a3)+      ;mode -(xx)
	bra.s	parenth

lbc001d80
	dbf	d0,lbc001d98
	move	(a4)+,d0
	btst	#$0f,d6
	bne.s	lbc001d92
	bsr.w	lbc001f2a
	bra.s	lbc001d96

lbc001d92
	bsr.w	ConvDec
lbc001d96
	bra.s	parenth

lbc001d98
	dbf	d0,lbc001de2
	move.b	1(a4),d0
	ext	d0
	beq.s	lbc001da8
	bsr.w	lbc001f2a
lbc001da8
	move.b	#'(',(a3)+
	bsr.b	lbc001d42
	move.b	#',',(a3)+
lbc001db2
	move.b	(a4),d1
	lsr.b	#4,d1
	and	#7,d1
	btst	#7,(a4)
	bmi.s	lbc001dc6
	bsr.w	lbc001d36
	bra.s	put_size

lbc001dc6
	bsr.w	lbc001d42
put_size:
	move.b	#'.',(a3)+
	moveq	#'W',d0
	move	(a4)+,d1
	btst	#11,d1
	beq.s	.put
	moveq	#'L',d0
.put	move.b	d0,(a3)+
	move.b	#')',(a3)+
	rts

lbc001de2
	move	(a4),d0
	ext	d0
	bsr.w	lbc001c4a
	move.b	#'(',(a3)+
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	move.b	#',',(a3)+
	bra.s	lbc001db2

lbc001dfc
	move	(a4)+,d0
;routine qui s'occupe des MOVEMs
lbc001dfe
	move	d5,d1
	and	#$0038,D1
	cmp	#$0020,D1
	bne.s	lbc001e16
	moveq	#15,d2
lop_revert:
	roxr	#1,d0
	roxl	#1,d1
	dbf	d2,lop_revert
	move	d1,d0
lbc001e16
	moveq	#0,d1
	clr.b	d2
	clr.b	d3
lbc001e1c
	btst	d1,d0
	bne.s	lbc001e24
	clr.b	d2
	bra.s	lbc001e52

lbc001e24
	addq.b	#1,d1
	tst.b	d2
	beq.s	lbc001e4c
	cmp.b	#8,d1
	beq.s	lbc001e4c
	cmp.b	#9,d1
	beq.s	lbc001e4c
	cmp.b	#$10,d1
	beq.s	lbc001e4c
	btst	d1,d0
	beq.s	lbc001e4c
	cmp.b	#'-',d2
	beq.s	lbc001e54
	moveq	#'-',d2
	move.b	d2,(a3)+
	bra.s	lbc001e54

lbc001e4c
	subq.b	#1,d1
	bsr.b	put_it
	st	d2
lbc001e52
	addq.b	#1,d1
lbc001e54
	cmp.b	#$10,d1
	blt.s	lbc001e1c
	rts

put_it:
	movem.l d0/d1,-(sp)
	tst.b	d3
	beq.s	.put_it
	cmp.b	#'-',d2
	beq.s	.put_it
	move.b	#'/',(a3)+
.put_it moveq	#'D',d0
	cmp.b	#8,d1
	blt.s	.put
	moveq	#'A',d0
.put	move.b	d0,(a3)+
	and.b	#7,d1
	bsr.s	put_digit
	st	d3
	movem.l (sp)+,d0/d1
	rts

put_digit:
	moveq	#'0',d0
	add.b	d1,d0		;on se met en ascii
	move.b	d0,(a3)+
	rts

lbc001e92
	move	d5,d1
	and	#$0e00,d1
	lsr	#8,d1
	lsr	#1,d1
	rts

lbc001e9e
	lea	illegalmode7.txt(pc),a0
	bra.s	cop_str
ret:	rts

lbc001ea6
	move	d6,d0
	and	#$0800,d0
	beq.s	lbc001ec2
	lea	_sr.txt(pc),a0
	move	d6,d0
	and	#$00c0,D0
	cmp	#$00c0,D0
	bne.s	cop_str
	addq.l	#3,a0
	bra.s	cop_str

lbc001ec2
	move.b	#'#',(a3)+
	move	d6,d0
	and	#$00c0,d0
	cmp	#$0080,d0
	bne.s	lbc001ed6
	move.l	(a4)+,d0
	bra.s	ConvHex32

lbc001ed6
	cmp	#$0040,d0
	bne.s	lbc001ee0
	move	(a4)+,d0
	bra.s	ConvHex16

lbc001ee0
	move	(a4)+,d0
	bra.s	ConvByte

cop_str:
	tst.b	(a0)
	beq.s	ret2
	move.b	(a0)+,(a3)+
	bra.s	cop_str
ret2:	rts

ConvDec:
	clr	-(sp)
	ext.l	d0
	bpl.s	div_lop
	move.b	#'-',(a3)+
	neg.l	d0
div_lop:
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move	d0,-(sp)
	clr	d0
	swap	d0
	tst	d0
	bne.s	div_lop
cop_lop:
	move	(sp)+,d0
	beq.s	ret3
	move.b	d0,(a3)+
	bra.s	cop_lop
ret3:	rts

ConvByte:
	cmp.b	#9,d0
	bhi.s	hex_byte
	add.b	#'0',d0
	move.b	d0,(a3)+
	rts
hex_byte:
	moveq	#1,d1
	bra.s	ConvHex

lbc001f2a
	movem.l d1/a0/a1,-(sp)
	tst	d0
	bpl.s	.positive
	neg	d0
	move.b	#'-',(a3)+
.positive
	bsr.b	ConvHex16
	movem.l (sp)+,d1/a0/a1
	rts

ConvHex16:
	moveq	#3,d1
	bra.s	ConvHex

ConvHex32:
	moveq	#7,d1
ConvHex:
	move.b	#'$',(a3)+
ConvHex2:
	move.l	d2,-(sp)
	clr	-(sp)
cv_lop: move.b	d0,d2
	lsr.l	#4,d0
	and	#$0f,d2
	move.b	chiffres_table(pc,d2.w),d2
	move	d2,-(sp)
	dbf	d1,cv_lop
putchr: move	(sp)+,d0
	beq.s	ret4
	move.b	d0,(a3)+
	bra.s	putchr
ret4:	move.l	(sp)+,d2
	rts
chiffres_table:dc.b '0123456789ABCDEF'
	even

*** Attendre un clic de souris
Clik:
	btst	#6,$bfe001
	bne.b	Clik
	rts

*** redéfinir le keymap
* ceci est nécessaire car l'Amiga a le clavier usa0 par défaut
SetMap:
	IFD	NEWKEYMAP
;	lea	conio(a5),a1
;	move	#9,28(a1)	;CD_ASKKEYMAP
;	moveq	#32,d0		;keymap_SIZEOF
;	move.l	d0,36(a1)	;io_length
;	lea	KeyMap(a5),a0
;	move.l	a0,40(a1)	;io_data
	move.l	4.w,a6
;	jsr	DoIO(a6)

	lea	conio(a5),a1
	move	#10,28(a1)	;CD_SETKEYMAP
	moveq	#32,d0		;keymap_SIZEOF
	move.l	d0,36(a1)	;io_length
	lea	KeyMapData(pc),a0
	add	#LN_SIZE+4,a0
	move.l	a0,40(a1)	;io_data
	jsr	DoIO(a6)
	ENDC
	rts

CursOff:
	move.l	a0,-(sp)
	lea	cursoff.txt(pc),a0
	bra.s	cu_
CursOn:
	move.l	a0,-(sp)
	lea	curson.txt(pc),a0
cu_	bsr.s	print
	move.l	(sp)+,a0
	rts

prompt:
	lea	prompt.txt(pc),a0
	bra.s	print
printf:
	bsr.s	DoFmt
*** Sortir un texte avec la console
* <-- a0: adr texte (terminé par 0)
print:
	movem.l d0-a6,-(sp)
	moveq	#-1,d3
pr	move.l	a0,d2
	lea	conio(a5),a1
	move	#3,28(a1)
	move.l	d2,40(a1)
	move.l	d3,36(a1)
	move.l	4.w,a6
	jsr	DoIO(a6)
	movem.l (sp)+,d0-a6
	rts
* idem mais avec un nbre de caractères donné
* <-- d0: len
print2
	movem.l d0-a6,-(sp)
	move.l	d0,d3
	bra.b	pr

*** Effacer l'écran
cls:	lea	cls.txt(pc),a0
	bsr.s	print
	bra	mainmenu

* Convertir avec RawDoFmt()
* <-- a0: format string
*	a1: adr des données à convertir
*	a3: adr buffer cible
DoFmt:
	movem.l d0-a6,-(sp)
	lea	.put(pc),a2
	lea	outbuf(a5),a3
	move.l	4.w,a6
	jsr	RawDoFmt(a6)
	movem.l (sp)+,d0-a6
	lea	outbuf(a5),a0
	rts
.put	move.b	d0,(a3)+
	rts

	IFD	CustomPrint
PrintLine:
	movem.l d0-a6,-(sp)
	move.l	a0,a4
	move.l	rast(a5),a3
	move.l	gfxbase(a5),a6

	move.l	conio+24(a5),a0
	movem	38(a0),d0-d7
	movem	d0-d7,x_pos(a5)
	move	54(a0),x_max(a5)
	move	56(a0),y_max(a5)

	mulu	y_rsize(a5),d1
	move	d1,-(sp)

	moveq	#1,d0
	move.l	a3,a1
	jsr	SetAPen(a6)

	move.l	conio+24(a5),a0
	addq	#1,40(a0)

	move	40(a0),d0
	move	44(a0),d1
	addq	#1,d1
	cmp	d1,d0
	ble.s	.t
	subq	#2,40(a0)

;	moveq	#7,d7
.scroll
	move.l	a3,a1
	moveq	#0,d0
	move	y_rsize(a5),d1
;	moveq	#1,d1
	movem	x_org(a5),d2-d3
	movem	x_max(a5),d4-d5
	jsr	ScrollRaster(a6)
;	jsr	WaitTOF(a6)
;	dbf	d7,.scroll
.t
	move.l	a3,a1
	moveq	#0,d0
	move	(sp)+,d1
	subq	#2,d1
	jsr	Move(a6)
	move.l	a4,a0
	bsr	StrLen
	move.l	a3,a1
	jsr	Text(a6)

.f	movem.l (sp)+,d0-a6
	rts
	ENDC

* Remplacer les codes ascii non-affichables par 'NullChar'
* <-- a0: adr buffer	d0: taille buf
Test:
	movem.l a0/d0-d2,-(sp)
	subq	#1,d0
.t	move.b	nullchr(pc),d1	;caract. de remplacement
	move.b	(a0)+,d2
	bclr	#7,d2
	cmp.b	#$20,d2 	;caract. < à $20(=espace)?
	bcs.b	.no		;si oui remplacer
	move.b	d2,d1
	btst	#7,-1(a0)
	beq.b	.no
	bset	#7,d1
.no	move.b	d1,-1(a0)
	dbf	d0,.t
	movem.l (sp)+,a0/d0-d2
	rts
nullchr dc.b	'·',0
	even

*** Hex --> HexString
* <-- d7: long, a1: outputstr
Long2Hex:
	movem.l d0-d2/a0,-(sp)
	moveq	#7,d2
.bcl	rol.l	#4,d7
	bsr.b	putc
	dbf	d2,.bcl
cf	movem.l (sp)+,d0-d2/a0
	rts
* <-- d7: word, a1: outputstr
Word2Hex:
	movem.l d0-d2/a0,-(sp)
	moveq	#3,d2
.bcl	rol	#4,d7
	bsr.b	putc
	dbf	d2,.bcl
	bra.b	cf
* <-- d7: byte, a1: outputstr
Byte2Hex:
	movem.l d0-d2/a0,-(sp)
	moveq	#1,d2
.bcl	rol.b	#4,d7
	bsr.b	putc
	dbf	d2,.bcl
	bra.b	cf
putc
	move	d7,d1
	and	#$f,d1
	move.b	table_conv(pc,d1.w),(a1)+
	rts
table_conv dc.b '0123456789ABCDEF'
	even

* Conversion Mot Long-->HexString
* <-- a0: buffer dest.	d0: mot long à convertir
HexConv:
	lea	hbuf(pc),a0
HexConv2:
	move.b	#'$',(a0)+
HexConv0:
	move.l	d0,d1
	moveq	#7,d3		;counter for the nibbles:8-1
.bcl	rol.l	#4,d1		;move upper nibble into lower
	move	d1,d2		;write in d2
	bsr.b	nib		;and convert it
	move.b	d2,(a0)+	;character in buffer
	dbf	d3,.bcl 	;repeat 8 times
	rts
HexConvWord:
	move	d0,d1
	moveq	#3,d3
.bcl	rol	#4,d1
	move	d1,d2
	bsr.b	nib
	move.b	d2,(a0)+
	dbf	d3,.bcl
	rts
HexConvByte:
	move	d0,d1
	moveq	#1,d3
.bcl	rol.b	#4,d1
	move	d1,d2
	bsr.b	nib
	move.b	d2,(a0)+
	dbf	d3,.bcl
	rts
nib
	and.b	#$0f,d2
	add.b	#$30,d2
	cmp.b	#$3a,d2
	bcs.b	.ok
	addq.b	#7,d2
.ok	rts

*** Longword to DecimalString
* <-- d0: nbre à convertir
DecConv:
	lea	hbuf(pc),a0
DecConv2:
	movem.l a1/a2,-(sp)
	move.l	a0,a2
	lea	tableconv(pc),a1
	tst.l	d0
	bne.b	.non_nul
	move.b	#$30,(a0)+
	clr.b	(a0)
	move.l	a2,a0
	bra.b	.convend
.non_nul
	bpl.b	.pos
	move.b	#'-',(a0)+              ;nbre négatif
	neg.l	d0
	bra.b	.go
.pos
	and.l	#$7fffffff,d0		;valeur positive max.
.go
	moveq	#8,d2
	bsr.b	.nib
	add.b	#$30,d0
	move.b	d0,(a0)+
	clr.b	(a0)
.convend
	movem.l (sp)+,a1/a2
.nozero cmp.b	#$30,(a0)+
	beq.b	.nozero
	subq.l	#1,a0
	move.l	a0,-(sp)
	moveq	#-1,d0		;strlen en d0
.strlen addq.l	#1,d0
	tst.b	(a0)+
	bne.b	.strlen
	move.l	(sp)+,a0
	rts
.nib
	moveq	#0,d3
	move.l	(a1)+,d1
.bcl	sub.l	d1,d0
	bcs.b	.neg
	addq.l	#1,d3
	bra.b	.bcl
.neg	add.l	d1,d0
	add.b	#$30,d3
	move.b	d3,(a0)+
	dbf	d2,.nib
	rts
tableconv:
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
hbuf	dcb.b	32,0
	even

* Conversion Décimal/Hex String --> mot long
* <-- a0: string adr
* --> d0: 0 si ok, -1 si erreur
* --> d1: mot long
Convert:
	cmp.b	#'$',(a0)+
	beq.s	Hex2Long
	cmp.b	#'%',-1(a0)
	beq.w	BinString2Long
	subq.l	#1,a0

	moveq	#10,d3
DConv:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	d4,-(sp)
	moveq	#0,d4
	cmp.b	#'-',(a0)       ;nbre négatif?
	bne.b	.dconv
	moveq	#-1,d4
	addq.l	#1,a0
.dconv	move.b	(a0)+,d2
	beq.s	.done
	cmp.b	#'0',d2
	bcs.b	.done
	cmp.b	#'9',d2
	bhi.b	.done
	add.l	d0,d0
	move.l	d0,d1
	asl.l	#2,d0
	add.l	d1,d0
	sub.b	#'0',d2
	add.l	d2,d0
	dbf	d3,.dconv
.done	move.l	d0,d1
	tst.l	d4
	beq.b	.pos
	neg.l	d1		;nbre négatif
.pos
	moveq	#0,d0		;code de retour: pas d'erreur
	bra.b	.f
.no	moveq	#-1,d0		;erreur
.f	move.l	(sp)+,d4
	subq.l	#1,a0
	rts

* Conversion HexString --> mot Long
* <-- a0: buffer HexString
* --> d0: 0 si ok, -1 si erreur
* --> d1: mot long
Hex2Long:
	moveq	#8,d3
HConv:
	moveq	#0,d0
	moveq	#0,d1
.hconv	move.b	(a0)+,d0
;	beq.s	.err
	cmp.b	#$20,d0
	bls.s	.err
	bsr.s	hval
	tst.l	d0
	bmi.s	.err
	add.l	d0,d1
	subq	#1,d3
	beq.s	.fin
	rol.l	#4,d1
	bra.s	.hconv
.fin	moveq	#0,d0
.f1
	rts
.err
	ror.l	#4,d1
	subq.l	#1,a0
	bra.s	.f1
hval:
	move.b	d0,d2
	and.b	#~$20,d2	;mettre en majusc.
	cmp.b	#'A',d2
	blt.b	.nb
	cmp.b	#'Z',d2
	bgt.b	.nb
	cmp.b	#'F',d2
	bgt.b	.nohex
	sub.b	#'A'-10,d2
	move.b	d2,d0
	rts
.nb
	sub.b	#'0',d0
	blt.b	.nohex
	cmp.b	#9,d0
	bgt.b	.nohex
	rts
.nohex	moveq	#-1,d0
	rts

* Conversion Mot Long -> BinString
* <-- a0: adr bin-string
* <-- d1: mot long
Long2BinString:
	lea	binbuf(a5),a0
	movem.l d1-d4/a0,-(sp)
	moveq	#3,d4
.bcl0	moveq	#7,d2
.bcl	add.l	d1,d1
	moveq	#24,d3
	addx.b	d3,d3
	move.b	d3,(a0)+
	dbf	d2,.bcl
	move.b	#'.',(a0)+
	dbf	d4,.bcl0
	clr.b	-1(a0)
	movem.l (sp)+,d1-d4/a0
	rts
* Conversion BinString -> Mot long
* <-- a0: adr bin-string
* <-- d1: mot long
BinString2Long:
	move.l	d2,-(sp)
	move.l	a0,-(sp)
	moveq	#-1,d0
.lop0	addq.l	#1,d0
	move.b	(a0)+,d2
	beq.s	.end
	cmp.b	#'0',d2
	beq.s	.lop0
	cmp.b	#'1',d2
	beq.s	.lop0
* ce n'est pas un caractère '1' ou '0' => erreur
	move.l	(sp)+,a0
	bra.s	.err
.end
	move.l	(sp)+,a0
	subq	#1,d0
	moveq	#0,d1
.lop	move.b	(a0)+,d2
	sub.b	#$30,d2
	bmi.s	.err
	cmp.b	#1,d2
	bhi.s	.err
	tst.b	d2
	beq.s	.clr
	bset	d0,d1
	bra.s	.do_lop
.clr	bclr	d0,d1
.do_lop subq	#1,d0
	bpl.s	.lop
.f	move.l	(sp)+,d2
	moveq	#0,d0
	rts
.err
	moveq	#0,d1
	bra.s	.f

* a0: src string
* a1: dest string
StrCpy:
	movem.l a0/a1,-(sp)
.copy	move.b	(a0)+,(a1)+
	bne.s	.copy
	movem.l (sp)+,a0/a1
	rts
* a0: string
StrLen:
	move.l	a0,-(sp)
	moveq	#-1,d0
.len	addq.l	#1,d0
	tst.b	(a0)+
	bne.s	.len
	move.l	(sp)+,a0
	rts

*** Handler Trap
MyTrap:
;	move.l	a0,-(sp)
;	move.l	4.w,a0
;	move.l	ThisTask(a0),a0
;	move.l	4(sp),tc_TrapData(a0)	;numéro de trap ds tc_TrapData
;	move.l	(sp)+,a0
;	addq.l	#4,sp
;	rte

*** DATA
VARS:	dc.l	0

New.Scr:
	dc.w	0,0,Width,Height
	dc.w	Depth
	dc.b	0,1
	dc.w	$8000
	dc.w	$4000!$10f
	dc.l	topaz8
	dc.l	0	;scrtitle
	dc.l	0,0
New.Win:
	dc.w	0,0,0,0
	dc.b	-1,-1
	dc.l	$10000!$8000!$400!$40!$10!8
	dc.l	$1000!$800
	dc.l	0	;gagdets
	dc.l	0
	dc.l	0	;scrtitle
	dc.l	0,0
	dc.w	0,0,0,0
	dc.w	$f

New.Pal:dc.w	$aa9,$000,$fff,$dec

topaz8: dc.l	topaz.name
	dc.w	8
	dc.b	0,0

illegalmode7.txt:
;	dc.b	'ILLEGALMODE7',0
;	dc.b	'BADMODE',0
	dc.b	'???????',0
_sr.txt:	dc.b	'SR',0
_ccr.txt:	dc.b	'CCR',0
_usp.txt:	dc.b	'USP',0
pc.txt: 	dc.b	'(PC)',0
	even
instruction_table:
 dc.w $ff00,$0000,$080b
 dc.w $f1b8,$0108,$0022
 dc.w $f1b8,$0188,$0012
 dc.w $f1c0,$0100,$0012
 dc.w $f1c0,$0140,$0012
 dc.w $f1c0,$0180,$0012
 dc.w $f1c0,$01c0,$0012
 dc.w $ff00,$0200,$080b
 dc.w $ff00,$0400,$000b
 dc.w $ff00,$0600,$000b
 dc.w $ffc0,$0800,2
 dc.w $ffc0,$0840,2
 dc.w $ffc0,$0880,2
 dc.w $ffc0,$08c0,2
 dc.w $ff00,$0a00,$080b
 dc.w $ff00,$0c00,$000b
 dc.w $f000,$1000,$00c2
 dc.w $f000,$2000,$0082
 dc.w $f000,$3000,$0042
 dc.w $ffc0,$40c0,2
 dc.w $ff00,$4000,3
 dc.w $f1c0,$4180,$0022
 dc.w $f1c0,$41c0,$0032
 dc.w $ff00,$4200,3
 dc.w $ffc0,$44c0,2
 dc.w $ff00,$4400,3
 dc.w $ffc0,$46c0,2
 dc.w $ff00,$4600,3
 dc.w $ffc0,$4800,2
 dc.w $fff8,$4840,2	;swap dx
 dc.w $fff8,$4880,$42	;ext.w dx
 dc.w $fff8,$48c0,$82	;ext.l dx
 dc.w $ffc0,$4840,2
 dc.w $ff80,$4880,$0202
 dc.w $ffff,$4afc,0	;illegal
 dc.w $ff00,$4a00,3
 dc.w $ffc0,$4ac0,2
 dc.w $ff80,$4c80,$0202
 dc.w $fff0,$4e40,0	;trap #n
 dc.w $fff8,$4e50,2	;link.w ax,#n
 dc.w $fff8,$4e58,2	;unlk ax
 dc.w $fff0,$4e60,2	;move.l ax,usp
 dc.w $ffff,$4e70,0	;reset
 dc.w $ffff,$4e71,0	;nop
 dc.w $ffff,$4e72,0	;stop
 dc.w $ffff,$4e73,$4000 ;rte
 dc.w $ffff,$4e75,$4000 ;rts
 dc.w $ffff,$4e76,0	;trapv
 dc.w $ffff,$4e77,$4000 ;rtr
 dc.w $ffc0,$4e80,$a002 ;jsr
 dc.w $ffc0,$4ec0,$c002 ;jmp
 dc.w $f0f8,$50c8,2
 dc.w $ffc0,$51c0,2
 dc.w $f0c0,$50c0,2
 dc.w $f100,$5000,$0103
 dc.w $f100,$5100,$0103
 dc.w $ff00,$6100,$2004
 dc.w $ffff,$6000,$4004 ;bra.w
 dc.w $ff00,$6000,$4004
 dc.w $f0ff,$6000,4
 dc.w $f000,$6000,4
 dc.w $f100,$7000,$0120
 dc.w $f1c0,$80c0,$0022
 dc.w $f1f0,$8100,$1002
 dc.w $f1c0,$81c0,$0022
 dc.w $f100,$8000,$0023
 dc.w $f100,$8100,$0013
 dc.w $f1c0,$90c0,$0072
 dc.w $f1c0,$91c0,$00b2
 dc.w $f130,$9100,$1003
 dc.w $f100,$9000,$0023
 dc.w $f100,$9100,$0013
 dc.w $f1c0,$b0c0,$0072
 dc.w $f1c0,$b1c0,$00b2
 dc.w $f100,$b000,$0023
 dc.w $f138,$b108,$0403
 dc.w $f100,$b100,$0013
 dc.w $f1f0,$c100,$1002
 dc.w $f1c0,$c0c0,$0022
 dc.w $f1f8,$c140,$0022
 dc.w $f1f8,$c148,$0032
 dc.w $f1f8,$c188,$0022
 dc.w $f1c0,$c1c0,$0022
 dc.w $f100,$c000,$0023
 dc.w $f100,$c100,$0013
 dc.w $f1c0,$d0c0,$0072
 dc.w $f1c0,$d1c0,$00b2
 dc.w $f130,$d100,$1003
 dc.w $f100,$d000,$0023
 dc.w $f100,$d100,$0013
 dc.w $ffc0,$e0c0,2
 dc.w $ffc0,$e1c0,2
 dc.w $ffc0,$e2c0,2
 dc.w $ffc0,$e3c0,2
 dc.w $ffc0,$e4c0,2
 dc.w $ffc0,$e5c0,2
 dc.w $ffc0,$e6c0,2
 dc.w $ffc0,$e7c0,2
 dc.w $f118,$e000,$0103
 dc.w $f118,$e100,$0103
 dc.w $f118,$e008,$0103
 dc.w $f118,$e108,$0103
 dc.w $f118,$e010,$0103
 dc.w $f118,$e110,$0103
 dc.w $f118,$e018,$0103
 dc.w $f118,$e118,$0103
 dc.w 0,0,0		;fin de la table
instructions.txt:
 dc.b 'ORI+MOVEP+MOVEP+BTStBCHgBCLrBSEtANDI+SUBI+ADDI+'
 dc.b 'BTStBCHgBCLrBSEtEORI+CMPI+'
 dc.b 'MOVE.bMOVE.lMOVE.wMOVeNEGX+CHkLEaCLR+MOVeNEG+MOVeNOT+'
 dc.b 'NBCdSWApEXT.wEXT.lPEaMOVEM+ILLEGAlTST+TAsMOVEM+TRApLINk'
 dc.b 'UNLkMOVeRESEtNOpSTOpRTeRTsTRAPvRTrJSrJMpDB@cSfS@c'
 dc.b 'ADDQ+SUBQ+BSrBRA.lBRA.sB@C.lB@C.sMOVEqDIVuSBCdDIVsOR+OR+'
 dc.b 'SUBA.wSUBA.lSUBX+SUB+SUB+CMPA.wCMPA.lCMP+CMPM+EOR+ABCdMULu'
 dc.b 'EXgEXgEXgMULsAND+AND+ADDA.wADDA.lADDX+ADD+ADD+ASrASlLSrLSl'
 dc.b 'ROXrROXlROrROlASR+ASL+LSR+LSL+ROXR+ROXL+ROR+ROL+*',0     ;UNKNOWn',0

topaz.name	dc.b 'topaz.font',0
gfxname 	dc.b 'graphics.library',0
intname 	dc.b 'intuition.library',0
trackname	dc.b 'trackdisk.device',0
consolename	dc.b 'console.device',0

*** messages
prompt.txt	dc.b '>',$9b,' p',0
cursoff.txt	dc.b $9b,'0 p',0
curson.txt	dc.b $9b,' p',0
cls.txt 	dc.b $c,0
lf.txt		dc.b $a,0
home.txt	dc.b $9b,'H',0
space.txt	dc.b ' ',0
backspace.txt	dc.b 8,' ',8,0
cursorleft.txt	dc.b $9b,'D',0
cursorright.txt dc.b $9b,'C',0
oldcommand.txt	dc.b $d,$9b,'C',0

main.txt
; dc.b $9b,'0x',$9b,'0y'
; dc.b $9b,'80u',$9b,'32t'
 dc.b $9b,'0 p',$9b,'20h'
 dc.b $9b,'m',$9b,'1;33m',$c
 DC.B '- RESET-TOOL V1.0 - ©1995-97 by Frédéric BASSALER -'
 dc.b $9b,'m',$a
 dc.b 'm [start] [end]         Memory Dump    | '
 dc.b 'a [start] [end]         Ascii Dump',$a
 dc.b 'd [start] [end]         Disassemble    | '
 dc.b 'e <start>               Edit Mem',$a
 dc.b 'c <start> <end> <dest>  Copy Mem       | '
 dc.b 'cl <start> <end>        Clear Mem',$a
 dc.b '< <addr> <offset> <len> Read Diskblocks| '
 dc.b '> <addr> <offset> <len> Write Diskblcks',$a
 dc.b '[ [#<addr>] <bytesize>  Alloc[Abs] Mem | '
 dc.b '] <addr> <bytesize>     Free Mem',$a
 dc.b 'r                       Show Registers | '
 dc.b 'du <UnitNumber (0-3)>   Change DiskUnit',$a
 dc.b 'j[sr] <addr>            JMP/JSR to Addr| '
 dc.b 'b <addr>                Calc.Blk ChkSum',$a
 dc.b 'bb <addr>               Calc.BootChkSum| '
 dc.b 'bm <addr>               Calc.BmapChkSum',$a
 dc.b 'lm                      List ResModules| '
 dc.b 'll                      List Libraries',$a
 dc.b 'ld                      List Devices   | '
 dc.b 'lr                      List Resources',$a
 dc.b 'lt                      List Tasks     | '
 dc.b 'lp                      List Ports',$a
 dc.b 'li                      List Interrupts| '
 dc.b 'lM                      List Memory',$a
 dc.b 'fill <start> <end> <data> Fill Memory  | '
 dc.b 'find <start> <end> <data> Find data',$a
 dc.b '<HELP>                  Type this page | '
 dc.b 'si                      System Info',$a
 dc.b '? <expr>                Calculate      | '
 dc.b 'x                       Exit program',$a
 dc.b 'inst [unit] [FFS]       Install Disk   | '
 dc.b 'KILL             Remove RT from memory!',$a
 dc.b $a,'Commands are case sensitive.',$a
 dc.b $a,$9b,' p',0

sysinfo.txt
 dc.b 'CPU: 680%1d0 - FPU: %s',$a
 dc.b 'KickStart version: %d.%d - Exec version: %d.%d',$a
 dc.b 'MaxLocMem: %08lx - MaxExtMem: %08lx',$a
 dc.b 'VBlank: %d Hz - PowerSupply: %d Hz',$a,$a
 dc.b 'Capture Vectors: Cold  : %08lx Cool  : %08lx Warm  : %08lx',$a
 dc.b ' Kick   Vectors: MemPtr: %08lx TagPtr: %08lx ChkSum: %08lx',$a,$a
 dc.b '       Available  Largest',$a
 dc.b 'Chip  %10.10ld  %10.10ld',$a
 dc.b 'Fast  %10.10ld  %10.10ld',$a
 dc.b 'Total %10.10ld',$a,$a
 dc.b 'Reset-Tool location: %lx-%lx (%d bytes)',$a
 DC.B 0
fpu881.txt dc.b '68881',0
fpu882.txt dc.b '68882',0
fpu040.txt dc.b '68040',0
nofpu.txt  dc.b 'None.',0

lastalert.txt	dc.b 'Last Alert: %08lx.%08lx',$a,0
badcommand.txt	dc.b '** Unknown command (or unimplemented!)',$a,0
abort.txt	dc.b '** Aborted!',$a,0
badargs.txt	dc.b '** Bad args!',$a,0
badunit.txt	dc.b '** Bad Drive Unit!',$a,0
alloc.txt	dc.b 'Allocated %ld bytes at %lx',$a,0
allocerr.txt	dc.b '** Failed to Alloc memory!',$a,0
diskerr.txt	dc.b '** Disk error!',$a,0
clrmem.txt	dc.b 'Clearing memory location %lx-%lx',$a,0
copmem.txt	dc.b 'Copying memory from %lx-%lx to %lx',$a,0
readblk.txt	dc.b 'Addr:%lx Offset:%ld Len:%ld Unit:%ld',$a,0
checksum.txt	dc.b 'CheckSum fixed. Old:%08lx New:%08lx',$a,0
currunit.txt	dc.b 'Current Disk Unit: %ld',$a,0
uninstall.txt	dc.b $9b,'1;33mTerminating...',$9b,'m',$a,0

resmods.txt
 dc.b 'Resident Modules in System:',$a
 dc.b 'Addr     Pri  Ver Name                      ID String',$a
 dc.b '-------- ---  --- ----                      ---------',$a,0
reslibs.txt
 dc.b 'Resident Libraries in System:',$a
 dc.b 'Addr     Cnt Ver        Name',$a
 dc.b '-------- --- --------   ----',$a,0
resdevs.txt
 dc.b 'Resident Devices in System:',$a
 dc.b 'Addr     Cnt Ver        Name',$a
 dc.b '-------- --- --------   ----',$a,0
resres.txt
 dc.b 'Resident Resources in System:',$a
 dc.b 'Addr     Cnt Ver        Name',$a
 dc.b '-------- --- --------   ----',$a,0
port.txt
 dc.b 'System Ports:',$a
 dc.b 'Addr     Name                 Flags    SigBit SigTask',$a
 dc.b '-------- ----                 -------- ------ -------',$a,0
task.txt
 dc.b 'System Tasks:',$a
 dc.b 'Addr     Type    State   Pri  Name',$a
 dc.b '-------- ------- ------- ---- ----',$a,0
int.txt
 dc.b 'System Interrupts:',$a
 dc.b 'Addr     Code     Data     Pri  Name',$a
 dc.b '-------- -------- -------- ---- ----',$a,0
mem.txt
 dc.b 'Memory List:',$a
 dc.b 'Node Type Attr  Lower     Upper     Size (kb) Pri  Name',$a
 dc.b '--------- ----- --------- --------- --------- ---- ----',$a,0

regs.txt
 dc.b 'D0: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx',$a
 dc.b 'A0: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx',$a
 dc.b 'USP=%08lx SR=%04x',$a
 dc.b 0
	even
regs	ds.l   16
spreg	dc.l	0
srreg	dc.w	0

myresptr dc.l	0

strbuf	ds.b 512
strbuflen=*-strbuf
	even
oldbuf	ds.b 512
	even
hexbuf	ds.b 512
	even
editbuf ds.b 69
editbuflen=*-editbuf

	even
*** Programme de boot Standard 2.0+
bootblock.data:
	dc.b	'DOS',0
	dc.l	0,$370		;chksum, rootblock
	lea	expansion.name(pc),a1
	moveq	#37,d0
	jsr	OpenLibrary(a6)
	tst.l	d0
	beq.b	.err
	move.l	d0,a1
	bset	#6,34(a1)
	jsr	CloseLibrary(a6)
.err	lea	dos.name(pc),a1
	jsr	-96(a6)
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.nodos	moveq	#-1,d0
	rts
dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0
bootblock.size=*-bootblock.data

KeymapData:
	IFD	NEWKEYMAP
	incdir	devs:Keymaps/
	incbin	f
	ENDC

End:

	END
