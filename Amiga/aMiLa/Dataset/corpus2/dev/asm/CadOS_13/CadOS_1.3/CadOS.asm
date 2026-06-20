 ; CadOS - CSG AGA Demo Operating System 1.3 release 1
; see the 100k of docs for more info!
; $VER: cados.asm 1.3 (22.1.97)

	IFND	__CADOS
__CADOS	set	1

; any other assembler-specific settings gp here
	IFD _PHXASS_
	machine 68020
	ENDC

	include	"CadOS.i"

START_OF_ALL_MY_WORRIES
	lea	.run(pc),a2
	cmp.w	#1,(a2)			; if we are resident, don't run two
	beq.s	.norun			; copies at once!
	move.w	#1,(a2)
	getbase	exec
	lea	sysbase(pc),a1
	move.l	a6,(a1)
	cmp.w	#36,20(a6)		; ensure 2.0
	bge	.begin
.norun	moveq	#100,d0
	rts

.intnam	dc.b	"intuition.library",0
.gfxnam	dc.b	"graphics.library",0
.dosnam	dc.b	"dos.library",0
.keynam	dc.b	"keymap.library",0
	cnop	0,4
	IFND	NO_MESSAGES
.errtab	dc.w	.err0-.errtab,.err1-.errtab,.err2-.errtab,.err3-.errtab
	dc.w	.err4-.errtab,.err5-.errtab,.err6-.errtab,.err7-.errtab
	dc.w	.err8-.errtab,.err9-.errtab,.erra-.errtab,.errb-.errtab
	dc.w	.errc-.errtab,.errd-.errtab,.erre-.errtab,.errf-.errtab
.err0	dc.b	"Bus error",0
.err1	dc.b	"Address error",0
.err2	dc.b	"Illegal instruction",0
.err3	dc.b	"Divide by zero",0
.err4	dc.b	"CHK: Out of bounds",0
.err5	dc.b	"Untrapped TRAPV",0
.err6	dc.b	"Privillege violation",0
.err7	dc.b	"Untrapped TRACE",0
.err8	dc.b	"Untrapped $Axxx",0
.err9	dc.b	"Untrapped $Fxxx",0
.erra	dc.b	"Format error",0
.errb	dc.b	"Uninitialized vector",0
.errc	dc.b	"Unknown error !!!",0
.errd	dc.b	"Untrapped TRAP",0
.erre	dc.b	"Illegal exit of program",0
.errf	dc.b	"'Undefined Error' error",0
.body	dc.b	"Sorry, this demo requires %s.",0
.body2	dc.b	"This program will take over your machine.",10,10
	dc.b	"- Multitasking will be suspended.",10
	dc.b	"- Background processing will be halted.",10
	dc.b	"- The screen will be taken over",10
	dc.b	"- Serial/network data will be ignored.",10,10
	dc.b	"Everything WILL be restored fully after the",10
	dc.b	"program finishes. Are you sure you want to ",10
	dc.b	"run this?",0
.body3	dc.b	"The program caused an error, and was aborted.",10
	dc.b	"For safety, you are advised to reboot soon.",10,10
	dc.b	"Error #%d: %s at $%lx",0
.resp	dc.b	"Quit",0
.resp2	dc.b	"OK|Quit",0
.resp3	dc.b	"Change to PAL|Quit",0
.thing1	dc.b	"a 68020 processor or better",0
.thing2	dc.b	"the AGA chipset",0
.thing3	dc.b	"a PAL display",0
	cnop	0,4
	ENDC
.stack	dc.l	0
.stack2	dc.l	0
.run	dc.w	0
	IFND	NO_REQUESTERS
.reqjmp	dc.l	0
.ezjmp	dc.l	0
.chscr	dc.w	0
	ENDC
.out	dc.w	0
.cop	dc.l	0
.begin	lea	arg_ptr(pc),a1
	move.l	a0,(a1)
	lea	arg_len(pc),a1
	move.w	d0,(a1)
	cmp.l	#0,a0
	beq.s	.noargs
	move.b	#0,-1(a0,d0.w)
.noargs
	lea	_retpc(pc),a0		; set up a few standard variables
	lea	.quit(pc),a1		; so we can be resident
	move.l	a1,(a0)
	IFND	NO_VBLSERVER
	lea	_jmpadr(pc),a0
	lea	__lev3x(pc),a1
	move.l	a1,(a0)
	ENDC
	moveq	#0,d0
	lea	.out(pc),a0
	move.w	d0,(a0)
	lea	_1sttm(pc),a0
	move.w	d0,(a0)
	lea	_dmaena(pc),a0
	move.w	d0,(a0)
	lea	_intena(pc),a0
	move.w	d0,(a0)
	lea	_intsta(pc),a0
	move.w	d0,(a0)
	lea	_fail(pc),a0
	move.w	d0,(a0)
	lea	_errnum(pc),a0
	move.w	#15,(a0)
	lea	_scrn(pc),a0
	move.w	d0,(a0)
	lea	_iecode(pc),a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	IFND	NO_REQUESTERS
	lea	.chscr(pc),a0
	move.w	d0,(a0)
	ENDC
	IFND	NO_FILESYSTEM
	lea	_file(pc),a0
	move.w	d0,(a0)
	lea	_chint(pc),a0
	move.w	d0,(a0)
	ENDC
	IFND	NO_VBLSERVER
	lea	__timer(pc),a0
	move.l	d0,(a0)
	ENDC
	lea	_bplcon0(pc),a0
	move.w	#%1100000001,(a0)+	; bplcon0=COLOR!GAUD!ECSENA
	move.l	#%1000000000,(a0)+	; bplcon1=0 bplcon2=KILLEHB
	move.l	d0,(a0)+		; bplcon3=0 bplcon4=0
	bsr	_FlushCache

	sub.l	a1,a1			; check for a workbench message.
	jsr	_LVOFindTask(a6)	; either save the msg, or save 0
	move.l	d0,a4
	moveq	#0,d0
	tst.l	172(a4)
	bne.s	.nomsg
	lea	92(a4),a0
	jsr	_LVOWaitPort(a6)
	lea	92(a4),a0
	jsr	_LVOGetMsg(a6)
.nomsg	move.l	d0,-(sp)

	lea	.intnam(pc),a1		; open intuition
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	lea	intbase(pc),a0
	move.l	d0,(a0)
	tst.l	d0
	beq	.noint
	lea	.gfxnam(pc),a1		; open graphics
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	lea	gfxbase(pc),a0
	move.l	d0,(a0)
	tst.l	d0
	beq	.nogfx
	lea	.dosnam(pc),a1		; open dos
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	lea	dosbase(pc),a0
	move.l	d0,(a0)
	tst.l	d0
	beq	.nodos
	lea	.keynam(pc),a1		; open keymap library
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	lea	keybase(pc),a0
	move.l	d0,(a0)
	tst.l	d0
	beq	.nokey
	move.l	d0,a6
	jsr	_LVOAskKeyMapDefault(a6)
	lea	keymap(pc),a0
	move.l	d0,(a0)

	getbasepc sys
	move.w	296(a6),d0		; check for 020+
	btst	#AFB_68020,d0
	bne.s	.is020
	moveq	#1,d0
	bsr	.requestme		; no 020? Complain
	bra	.failtest

.is020	lea	_custom+lisaid,a0	; hardware check for AGA
	move.w	(a0),d0
	moveq	#30,d2
.denlop	move.w	(a0),d1
	cmp.b	d0,d1
	bne.s	.notaga
	dbra	d2,.denlop
	btst	#2,d0
	beq.s	.isaga
.notaga	moveq	#2,d0
	bsr	.requestme			; no AGA? complain with requester
	bra	.failtest
.isaga	getbasepc gfx
	cmp.w	#36,20(a6)
	bcs.s	.oldks
	btst	#2,206(a6)
	beq.s	.pal
	bra.s	.notpal

.oldks	getbasepc sys
	cmp.b	#50,530(a6)
	beq.s	.pal
.notpal	moveq	#3,d0
	bsr	.requestme		; we _must_ be PAL.
	tst.b	d0
	beq	.failtest
.pal	tst.l	(sp)
	beq.s	.noreq
	moveq	#4,d0
	bsr	.requestme
	tst.b	d0
	beq	.failtest
.noreq
	move.l	#MEMELEMENTS*8,d0	; allocate memory tracking memory
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.failtest
	lea	memlist(pc),a0
	move.l	d0,(a0)

	move.l	#4*256,d0		; allocate colour buffer memory
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.nocmem
	lea	_colbuf(pc),a0
	move.l	d0,(a0)
	move.l	d0,a0
	move.l	#0,(a0)+
	move.l	#254,d0
.cloop	move.l	#$0fff0fff,(a0)+
	dbra	d0,.cloop

	move.l	#128,d0			; allocate keybuffer memory
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.nokmem
	lea	_keys(pc),a0
	move.l	d0,(a0)

	move.l	#1024,d0		; allocate exceptiontable memory
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.novmem
	lea	vbr(pc),a0
	move.l	d0,(a0)

	moveq	#5*4,d0			; 5 copper instructions
	move.l	#MEMF_PUBLIC!MEMF_CHIP!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq	.nocop
	move.l	d0,a1
	lea	_defcop(pc),a0
	move.l	a1,(a0)
	lea	.cop(pc),a0
	move.l	a1,(a0)
	move.l	#$00960020,(a1)+	; no sprites
	IFD	SCRNCOLOUR
	move.l	#($180<<16)!SCRNCOLOUR,(a1)+
	ELSEIF
	move.l	#$01800000,(a1)+	; black screen
	ENDC
	move.l	#$01dc0020,(a1)+	; pal
	move.l	#$fffffffe,(a1)+	; end cop

	moveq	#0,d0
	IFD	PREDEMO			; now the initial setup is over, we
	jsr	_PreDemo		; call _PreDemo if asked
	tst.l	d0
	bne	.exit
	ENDC

	bsr	_TakeoverScreen
	IFD	DEBUGGING
	bsr	.su
	ELSEIF
	getbasepc sys
	lea	.su(pc),a5
	jsr	_LVOSupervisor(a6)
	ENDC
	lea	.out(pc),a0
	tst.w	(a0)
	bne.s	.outok
	IFD	DEBUGGING
	bsr	.quit
	ELSEIF
	getbasepc sys
	lea	.quit(pc),a5
	jsr	_LVOSupervisor(a6)
	ENDC
	lea	_fail(pc),a0
	move.w	#1,(a0)
	lea	_errnum(pc),a0
	move.w	#14,(a0)
.outok	bsr	_RestoreScreen
	lea	_fail(pc),a0
	tst.w	(a0)
	beq.s	.nofail
	IFND	NO_MESSAGES
	lea	.args(pc),a1
	lea	_errnum(pc),a0
	move.w	(a0),d0
	moveq	#$f,d1
	cmp.w	d1,d0
	blt.s	.errok
	move.w	d1,d0
.errok	move.w	d0,(a1)+
	lea	.errtab(pc),a0
	move.w	(a0,d0.w*2),d0
	lea	(a0,d0.w),a0
	move.l	a0,(a1)+
	lea	_deadpc(pc),a0
	move.l	(a0),(a1)+
	moveq	#5,d0
	bsr	.requestme
	ENDC
.nofail
	IFD	POSTDEMO
	jsr	_PostDemo
	ENDC
.exit	getbasepc sys
	get.l	.cop,a1
	moveq	#5*4,d0
	jsr	_LVOFreeMem(a6)
.nocop	get.l	vbr,a1
	move.l	#1024,d0
	jsr	_LVOFreeMem(a6)
.novmem	get.l	_keys,a1
	move.l	#128,d0
	jsr	_LVOFreeMem(a6)
.nokmem	get.l	_colbuf,a1
	move.l	#4*256,d0
	jsr	_LVOFreeMem(a6)
.nocmem	get.l	memlist,a1
	moveq	#MEMELEMENTS-1,d1
.frelop	move.l	(a1),d0
	tst.l	d0
	beq.s	.notmem
	bsr	_FreeMem
.notmem	addq.l	#8,a1
	dbra	d1,.frelop
	get.l	memlist,a1
	move.l	#MEMELEMENTS*8,d0
	jsr	_LVOFreeMem(a6)
.failtest
	getbasepc sys
	get.l	keybase,a1
	jsr	_LVOCloseLibrary(a6)
.nokey	get.l	dosbase,a1
	jsr	_LVOCloseLibrary(a6)
.nodos	get.l	gfxbase,a1
	jsr	_LVOCloseLibrary(a6)
.nogfx	get.l	intbase,a1
	jsr	_LVOCloseLibrary(a6)
.noint	move.l	(sp)+,d0
	beq.s	.nomsg2
	move.l	d0,a2
	jsr	_LVOForbid(a6)
	move.l	a2,a1
	jsr	_LVOReplyMsg(a6)
	jsr	_LVOPermit(a6)
.nomsg2	move.l	retcode(pc),d0
	lea	.run(pc),a2
	move.w	#0,(a2)			; run no longer! :)
	rts				; byeeeeeeeeeee!!!!!
.su	movem.l	d0-d7/a0-a6,-(sp)
	lea	.stack(pc),a1
	move.l	sp,a0
	move.l	a0,(a1)

	IFD	STACKSIZE
	move.l	#(STACKSIZE+3)&-4,d0	; allocate optional seperate stack
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	.nosmem
	move.l	d0,sp
	lea	.stack2(pc),a0
	move.l	d0,(a0)
	ENDC

	bsr	_Disable

	IFND	NO_REQUESTERS
	getbasepc int			; patch Requesters so we can
	move.l	_LVOAutoRequest+2(a6),d0; SEE a request if one appears.
	lea	.reqjmp(pc),a0
	move.l	d0,(a0)
	lea	.reqpatch(pc),a0
	move.l	a0,_LVOAutoRequest+2(a6)
	move.l	_LVOEasyRequestArgs+2(a6),d0
	lea	.ezjmp(pc),a0
	move.l	d0,(a0)
	lea	.ezpatch(pc),a0
	move.l	a0,_LVOEasyRequestArgs+2(a6)
	ENDC

	moveq	#0,d0			; clear registers
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	IFND	DEBUGGING
	move.w	#1,_custom+copcon	; copper power! (CDANG)
	ENDC
	bsr	___main			; wham!

.quit	lea	.stack(pc),a0		; restore stack
	move.l	(a0),sp
	bsr	_Enable			; reenable ints if we need to

	IFND	NO_REQUESTERS
	getbasepc int			; unpatch requesters
	get.l	.reqjmp,a0
	move.l	a0,_LVOAutoRequest+2(a6)
	get.l	.ezjmp,a0
	move.l	a0,_LVOEasyRequestArgs+2(a6)
	ENDC

	IFD	STACKSIZE
	get.l	.stack2,a1		; free optional stack memory
	move.l	#(STACKSIZE+3)&-4,d0
	getbasepc sys
	jsr	_LVOFreeMem(a6)
.nosmem
	ENDC

	lea	.out(pc),a0		; yes we got out!
	move.w	#1,(a0)

	movem.l	(sp)+,d0-d7/a0-a6
	IFD	DEBUGGING
	rts
	ELSEIF
	rte
	ENDC
.requestme
	IFND	NO_MESSAGES
	lea	.body(pc),a0
	lea	.resp(pc),a1
	lea	.args(pc),a2

	cmp.b	#1,d0
	bne.s	.not_t1
	lea	.thing1(pc),a3
	move.l	a3,(a2)
	bra.s	.doreq
.not_t1	cmp.b	#2,d0
	bne.s	.not_t2
	lea	.thing2(pc),a3
	move.l	a3,(a2)
	bra.s	.doreq
.not_t2	cmp.b	#3,d0
	bne.s	.not_t3
	lea	.thing3(pc),a3
	move.l	a3,(a2)
	lea	.resp3(pc),a1
	bra.s	.doreq
.not_t3	cmp.b	#4,d0
	bne.s	.not_t4
	lea	.body2(pc),a0
	lea	.resp2(pc),a1
	bra.s	.doreq
.not_t4	lea	.body3(pc),a0
.doreq	bra	_SystemRequest
	ELSEIF
	rts
	ENDC
.args	dc.l	0,0,0

	IFND	NO_REQUESTERS
.reqpatch
	lea	_scrn(pc),a6
	tst.w	(a6)			; is wb off?
	beq.s	.ns1
	lea	.chscr(pc),a6		; yes, turn in on
	move.w	#1,(a6)
	bsr	_RestoreScreen
.ns1	getbasepc int
	move.l	a5,-(sp)
	get.l	.reqjmp,a5
	jsr	(a5)
	move.l	(sp)+,a5
	lea	.chscr(pc),a6
	tst.w	(a6)			; did we show wb?
	beq.s	.ns2
	clr.w	(a6)
	bsr	_TakeoverScreen		; hide it again.
.ns2	getbasepc int
	rts
.ezpatch
	lea	_scrn(pc),a6
	tst.w	(a6)			; is wb off?
	beq.s	.ns3
	lea	.chscr(pc),a6		; yes, turn in on
	move.w	#1,(a6)
	bsr	_RestoreScreen
.ns3	getbasepc int
	move.l	a5,-(sp)
	get.l	.ezjmp,a5
	jsr	(a5)
	move.l	(sp)+,a5
	lea	.chscr(pc),a6
	tst.w	(a6)			; did we show wb?
	beq.s	.ns4
	clr.w	(a6)
	bsr	_TakeoverScreen		; hide it again.
.ns4	getbasepc int
	rts
	ENDC

_setpri	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	d0,-(sp)
	getbasepc sys
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,a1
	move.l	(sp)+,d0
	jsr	_LVOSetTaskPri(a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

__sysvars
sysbase	dc.l	0
intbase	dc.l	0
gfxbase	dc.l	0
dosbase	dc.l	0
keybase	dc.l	0
keymap	dc.l	0
memlist	dc.l	0
vbr	dc.l	0
retcode	dc.l	0
arg_ptr	dc.l	0
arg_len	dc.w	0
DIS_LEFTEDGE	dc.w	128
DIS_TOPEDGE	dc.w	44
SYS_WAIT	dc.w	60

*** SYSTEM ***
_oldvbr	dc.l	0
__ciaa	dc.l	0
_1sttm	dc.w	0
_oldint	dc.w	0
_olddma	dc.w	0
_oldadk	dc.w	0
_dmaena	dc.w	0
_intena	dc.w	0
_intsta	dc.w	0
_fail	dc.w	0
	dc.w	0	;	^
	dc.l	0	;	^
_intstk	; stack up the way ----	^
_errnum	dc.w	0
_deadpc	dc.l	0
_retpc	dc.l	0
	IFND	NO_VBLSERVER
__lev3	move.w	d0,-(sp)
	move.w	_custom+intreqr,d0
	and.w	#INTF_VERTB,d0
	beq.s	.exit
	move.l	a0,-(sp)
	lea	__timer(pc),a0
	addq.l	#1,(a0)
	lea	__vert(pc),a0
	eor.w	#-1,(a0)
	move.l	(sp)+,a0
	IFND	NO_RMBQUIT
	btst	#2,$dff016
	bne.s	.normb
	move.w	#$7fff,d0
	move.w	d0,_custom+intena
	move.w	d0,_custom+dmacon
	lea	_intstk(pc),sp
	lea	_retpc(pc),a0
	move.l	(a0),-(sp)
	move.w	#SRF_SUPER,-(sp)
	nop
	rte
.normb
	ENDC
.exit	move.w	(sp)+,d0
	dc.w	$4ef9			; JMP instruction
_jmpadr	dc.l	0

__lev3x	move.w	#INTF_VERTB,_custom+intreq
	nop
	rte

__timer	dc.l	0
__vert	dc.w	0
	ENDC
	IFD	DEBUGGING
_Disable	rts
_Enable		rts
_SetAutovec	rts
_SetTrap	rts
_empty_int
	nop
	rte
	ELSEIF
_Disable
	movem.l	d0-d1/a0-a1/a5-a6,-(sp)
	lea	_intsta(pc),a0
	tst.w	(a0)
	bne	.exit
	move.w	#1,(a0)
	IFND	NO_FILESYSTEM
	lea	_file(pc),a0
	tst.w	(a0)
	beq.s	.nofile
	clr.w	(a0)
	getbasepc dos
	lea	SYS_WAIT(pc),a0
	move.w	(a0),d1
	jsr	_LVODelay(a6)		; delay for disk task to end
	ENDC
.nofile	getbasepc gfx
	jsr	_LVOWaitBlit(a6)	; finish any pending blit
	jsr	_LVOOwnBlitter(a6)	; take over blitter
	getbasepc sys
	lea	.cianam(pc),a1
	jsr	_LVOOpenResource(a6)
	lea	__ciaa(pc),a0
	move.l	d0,(a0)
	moveq	#127,d0
	bsr	_setpri
	jsr	_LVOForbid(a6)		; forbid other tasks
	jsr	_LVODisable(a6)
	lea	_custom,a6
	move.w	#$7fff,d0
	lea	_oldint(pc),a0
	move.w	intenar(a6),(a0)
	or.w	#$c000,(a0)
	move.w	d0,intena(a6)
	move.w	d0,intreq(a6)
	lea	_oldadk(pc),a0
	move.w	adkconr(a6),(a0)
	or.w	#$8000,(a0)
	;move.w	d0,adkcon(a6)		; Don't! System settings are needed!
	lea	_olddma(pc),a0

	move.w	dmaconr(a6),(a0)
	or.w	#$8200,(a0)
	move.w	d0,dmacon(a6)
	lea	_dmaena(pc),a0
	move.w	(a0),d0
	or.w	#$8200,d0
	move.w	d0,dmacon(a6)

	movec	VBR,a0
	lea	_oldvbr(pc),a1
	move.l	a0,(a1)
	get.l	vbr,a1
	move.l	a1,a6

	move.w	#(1024/4)-1,d0
.vbrl	move.l	(a0)+,(a1)+
	dbra	d0,.vbrl

	lea	_1sttm(pc),a0
	tst.w	(a0)
	bne.s	.noset
	move.w	#1,(a0)
	lea	$64(a6),a1
	lea	_empty_int(pc),a0
	moveq	#7-1,d0
.l2	move.l	a0,(a1)+
	dbra	d0,.l2
	lea	$80(a6),a1
	lea	__trap(pc),a0
	moveq	#16-1,d0
.l1	move.l	a0,(a1)+
	dbra	d0,.l1
.noset
	lea	$08(a6),a1
	lea	.err0(pc),a0
	move.l	a0,(a1)+
	lea	.err1(pc),a0
	move.l	a0,(a1)+
	lea	.err2(pc),a0
	move.l	a0,(a1)+
	lea	.err3(pc),a0
	move.l	a0,(a1)+
	lea	.err4(pc),a0
	move.l	a0,(a1)+
	lea	.err5(pc),a0
	move.l	a0,(a1)+
	lea	.err6(pc),a0
	move.l	a0,(a1)+
	lea	.err7(pc),a0
	move.l	a0,(a1)+
	lea	.err8(pc),a0
	move.l	a0,(a1)+
	lea	.err9(pc),a0
	move.l	a0,(a1)+
	addq.l	#8,a1
	lea	.erra(pc),a0
	move.l	a0,(a1)+
	lea	.errb(pc),a0
	move.l	a0,(a1)+
	lea	.errc(pc),a0
	move.l	a0,$60(a6)

	movec	a6,VBR

	IFND	NO_VBLSERVER
	lea	__timer(pc),a0
	clr.l	(a0)
	lea	__lev3(pc),a0
	bsr	_FlushCache
	movec	vbr,a1
	move.l	a0,$6c(a1)
	move.w	#INTF_SETCLR|INTF_INTEN|INTF_VERTB,_custom+intena
	ENDC

	lea	_intena(pc),a0
	move.w	(a0),d0
	or.w	#$c000,d0
	move.w	d0,_custom+intena
.exit	movem.l	(sp)+,d0-d1/a0-a1/a5-a6
	rts
.cianam	dc.b	"ciaa.resource",0
	cnop	0,4
.err0	moveq	#$0,d0
	bra.s	__exerr
.err1	moveq	#$1,d0
	bra.s	__exerr
.err2	moveq	#$2,d0
	bra.s	__exerr
.err3	moveq	#$3,d0
	bra.s	__exerr
.err4	moveq	#$4,d0
	bra.s	__exerr
.err5	moveq	#$5,d0
	bra.s	__exerr
.err6	moveq	#$6,d0
	bra.s	__exerr
.err7	moveq	#$7,d0
	bra.s	__exerr
.err8	moveq	#$8,d0
	bra.s	__exerr
.err9	moveq	#$9,d0
	bra.s	__exerr
.erra	moveq	#$a,d0
	bra.s	__exerr
.errb	moveq	#$b,d0
	bra.s	__exerr
.errc	moveq	#$c,d0
	bra.s	__exerr
__trap	moveq	#$d,d0
__exerr	lea	_errnum(pc),a0
	move.w	d0,(a0)
	lea	_deadpc(pc),a0
	move.l	2(sp),(a0)
	move.w	#$7fff,d0
	move.w	d0,_custom+dmacon
	move.w	d0,_custom+intena
	lea	_fail(pc),a0
	move.w	#1,(a0)
	lea	_intstk(pc),sp
	lea	_retpc(pc),a0
	move.l	(a0),-(sp)
	move.w	#SRF_SUPER,-(sp)
_empty_int
	nop
	rte

_Enable	movem.l	d0-d1/a0/a6,-(sp)
	lea	_intsta(pc),a0
	tst.w	(a0)
	beq	.exit
	clr.w	(a0)
	get.l	sysbase,a0
	move.l	a0,4.w
	get.l	_oldvbr,a0
	movec	a0,VBR
	move.w	#$7fff,d0
	moveq	#0,d1
	lea	_custom,a6
	move.w	dmaconr(a6),d2
	lea	_dmaena(pc),a0
	move.w	d2,(a0)
	move.w	intenar(a6),d2
	lea	_intena(pc),a0
	move.w	d2,(a0)
	move.w	d0,dmacon(a6)
	move.w	d1,aud0vol(a6)
	move.w	d1,aud1vol(a6)
	move.w	d1,aud2vol(a6)
	move.w	d1,aud3vol(a6)
	lea	_oldadk(pc),a0
	move.w	d0,adkcon(a6)
	move.w	(a0),adkcon(a6)
	lea	_olddma(pc),a0
	move.w	(a0),dmacon(a6)
	lea	_oldint(pc),a0
	move.w	d0,intena(a6)
	move.w	(a0),intena(a6)
	getbasepc sys
	jsr	_LVOEnable(a6)
	jsr	_LVOPermit(a6)
	moveq	#0,d0
	bsr	_setpri
	getbasepc gfx
	jsr	_LVOWaitBlit(a6)
	jsr	_LVODisownBlitter(a6)	; free blitter
.exit	movem.l	(sp)+,d0-d1/a0/a6
	rts

_SetTrap
	tst.w	d0
	beq.s	.no
	bls.s	.no
	cmp.w	#15,d0
	bhi.s	.no
	move.l	a1,-(sp)
	movec	vbr,a1
; modified by Vodka !!
	lea	$80(a1),a1
	move.l	a0,(a1,d0.w*4)
	move.l	(sp)+,a1
.no	rts

_ResetTrap
	tst.w	d0
	beq.s	.no
	bls.s	.no
	cmp.w	#15,d0
	bhi.s	.no
	movem.l	a0/a1,-(sp)
	movec	vbr,a1
	lea	$80(a1),a1
	lea	__trap(pc),a0
	move.l	a0,(a1,d0.w*4)
	movem.l	(sp)+,a0/a1
.no	rts

_SetAutovec
	tst.w	d0
	beq.s	.no
	bls.s	.no
	cmp.w	#7,d0
	bhi.s	.no
	movem.l	d0/a0/a1,-(sp)
	IFND	NO_VBLSERVER
	cmp.w	#3,d0
	bne.s	.cont
	lea	_jmpadr(pc),a1
	move.l	a0,(a1)
	bsr.s	_FlushCache
	lea	__lev3(pc),a0
.cont
	ENDC
	subq	#1,d0
	movec	vbr,a1
	move.l	a0,$64(a1,d0.w*4)
	movem.l	(sp)+,d0/a0/a1
.no	rts

_RemAutovec
	tst.w	d0
	beq.s	.no
	bls.s	.no
	cmp.w	#7,d0
	bhi.s	.no
	movem.l	d0/a0/a1,-(sp)
	IFND	NO_VBLSERVER
	cmp.w	#3,d0
	bne.s	.cont
	lea	_jmpadr(pc),a1
	lea	__lev3x(pc),a0
	move.l	a0,(a1)
	bsr.s	_FlushCache
	movem.l	(sp)+,d0/a0/a1
	rts
.cont
	ENDC
	subq	#1,d0
	movec	vbr,a1
	lea	_empty_int(pc),a0
	move.l	a0,$64(a1,d0.w*4)
	movem.l	(sp)+,d0/a0/a1
.no	rts
	ENDC

_FlushCache
	movem.l	d0-d1/a0-a1/a6,-(sp)
	getbasepc sys				; The ONLY safe way to flush
	jsr	_LVOCacheClearU(a6)		; the caches. Period.
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

_CauseDelay
	tst.w	d0
	beq.s	.exit
	move.w	d1,-(sp)
	move.w	_custom+intenar,d1
	move.w	#$7fff,_custom+intena
	move.b	d0,ciaatalo
	ror.w	#8,d0
	move.b	d0,ciaatahi
	rol.w	#8,d0
	move.b	#INMODE!1,ciaacra
	tst.b	ciaaicr
	tst.b	ciaaicr
.wait	btst	#0,ciaaicr
	beq.s	.wait
	bset	#15,d1
	move.w	d1,_custom+intena
	move.w	(sp)+,d1
.exit	rts

_SystemRequest
	movem.l	d1/a0-a3/a6,-(sp)
	moveq	#0,d0
	lea	_intsta(pc),a3
	tst.w	(a3)
	bne.s	.exit
	lea	.fillback(pc),a3
	move.l	a1,-(a3)
	move.l	a0,-(a3)
	lea	.title(pc),a0
	move.l	a0,-(a3)
	move.l	a2,a3
	suba.l	a2,a2
	suba.l	a0,a0
	lea	.ezreq(pc),a1
	getbasepc int
	jsr	_LVOEasyRequestArgs(a6)
.exit	movem.l	(sp)+,d1/a0-a3/a6
	rts
.title	dc.b	"CadOS request",0
.ezreq	dc.l	24			; structure length (futureproofing)
	dc.l	0			; flags
	dc.l	0			; title
	dc.l	0			; bodytext
	dc.l	0			; responce
.fillback

*** MEMORY ***
MEMELEMENTS=128	; up to 128 memory allocations at one time.
__flush	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	#$7ffffff,d0
	moveq	#0,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	.ok
	move.l	d0,a1
	move.l	#$7ffffff,d0
	jsr	_LVOFreeMem(a6)
.ok	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

_AllocMem
	tst.l	d0
	beq.s	.no
	movem.l	d1-d3/a0-a2/a6,-(sp)
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d3
	tst	d1
	beq.s	.fast
	move.l	#MEMF_PUBLIC!MEMF_CHIP!MEMF_CLEAR,d3
.fast	move.l	d0,d2
	get.l	memlist,a2
	moveq	#MEMELEMENTS-1,d0
.findsp	tst.l	(a2)
	beq.s	.gotsp
	addq.l	#8,a2
	dbra	d0,.findsp
	moveq	#0,d0
	bra.s	.fail
.gotsp	move.l	d2,d0
	move.l	d3,d1
	getbasepc sys
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	bne.s	.gotit
	bsr.s	__flush
	move.l	d2,d0
	move.l	d3,d1
	jsr	_LVOAllocMem(a6)
.gotit	move.l	d0,(a2)+
	move.l	d2,(a2)+
.fail	movem.l	(sp)+,d1-d3/a0-a2/a6
.no	rts

_FreeMem
	tst.l	d0
	beq.s	.no
	movem.l	d0-d2/a0-a1/a6,-(sp)
	get.l	memlist,a0
	moveq	#MEMELEMENTS-1,d2
.findsp	move.l	(a0),d1
	cmp.l	d0,d1 ; fix
	beq.s	.gotsp
	addq.l	#8,a0
	dbra	d2,.findsp
	bra.s	.fail
.gotsp	move.l	(a0),a1
	clr.l	(a0)+
	move.l	(a0),d0
	getbasepc sys
	jsr	_LVOFreeMem(a6)
.fail	movem.l	(sp)+,d0-d2/a0-a1/a6
.no	rts

_SizeMem
	move.l	a0,d0
	tst.l	d0
	beq.s	.no
	movem.l	a0/d1-d3,-(sp)
	get.l	memlist,a0
	moveq	#MEMELEMENTS-1,d1
.findsp	move.l	(a0),d2
	cmp.l	d2,d0
	bcs.s	.nxt
	move.l	4(a0),d3
	add.l	d2,d3
	move.l	d0,d2
	exg.l	d0,d3
	sub.l	d3,d0
	bpl.s	.exit
	move.l	d2,d0
.nxt	addq.l	#8,a0
	dbra	d1,.findsp
	moveq	#0,d0
.exit	movem.l	(sp)+,a0/d1-d3
.no	rts

*** DISPLAY ***
	IFND	NO_SPRITES
__wbnam	dc.b	'Workbench',0
	cnop	0,4
_wbscrn	dc.l	0
_tags	dc.l	0
_res	dc.l	0,0
_oldres	dc.l	0
	ENDC
__view	dc.l	0
_colbuf	dc.l	0
_defcop	dc.l	0
_scrn	dc.w	0
_bplcon0 dc.w	0
_bplcon1 dc.w	0
_bplcon2 dc.w	0
_bplcon3 dc.w	0
_bplcon4 dc.w	0
_TakeoverScreen
	IFND	DEBUGGING
	movem.l	d0-d5/a0-a3/a6,-(sp)
	lea	_scrn(pc),a0
	tst.w	(a0)
	bne	.quit
	move.w	#1,(a0)
	getbasepc gfx			; store actiview for return later
	lea	__view(pc),a0
	move.l	34(a6),(a0)

	IFND	NO_SPRITES
*** begin cj stuff ***
	getbasepc int			; this is by comrade j. if the user's
	cmp.w	#39,20(a6)		; mouse pointer is in superhighres,
	bcs.s	.nowb			; the sprite res is wrong in the demo
	lea	__wbnam(pc),a0		; so we turn it to normal before we
	jsr	_LVOLockPubScreen(a6)	; run and restore it later if we need
	lea	_wbscrn(pc),a0		; to. it is the only v39 only code
	move.l	d0,(a0)			; here so we skip it if we are
	tst.l	d0			; running wb2 (it won't let you have
	beq.s	.nowb			; superhires sprites even with aga)
	move.l	d0,a0
	move.l	48(a0),a0
	lea	_tags(pc),a1
	move.l	#$80000032,(a1)
	clr.l	4(a1)
	getbasepc gfx
	jsr	_LVOVideoControl(a6)
	lea	_res(pc),a0
	lea	_oldres(pc),a1
	move.l	(a0),(a1)
	move.l	#1,(a0)
	lea	_tags(pc),a1
	move.l	#$80000031,(a1)
	get.l	_wbscrn,a0
	move.l	48(a0),a0
	lea	_tags(pc),a1
	jsr	_LVOVideoControl(a6)
	getbasepc int
	lea	_wbscrn(pc),a2
	move.l	(a2),a0
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)
	move.l	(a2),a1
	suba.l	a0,a0
	jsr	_LVOUnlockPubScreen(a6)
*** end cj stuff ***
	ENDC
.nowb	getbasepc gfx			; now the fun starts...
	suba.l	a1,a1
	jsr	_LVOLoadView(a6)	; empty display
	jsr	_LVOWaitTOF(a6)		; wait for old copper to finish
	jsr	_LVOWaitTOF(a6)		; x2 in case of interlace
	moveq	#0,d0
	get.l	_defcop,a0
	move.l	a0,_custom+cop1lc
	move.w	d0,_custom+copjmp1
	bsr	_WriteDispRegs
	move.w	#__fmode,_custom+fmode

	moveq	#0,d3			; I'd like to reuse the __writecol
	get.l	_colbuf,a0		; code here, but sadly I can't !
	lea	_custom,a2		; Keeps crashing so I assume on
	move.w	_bplcon2(pc),d2		; requester-generated WB screens
	bclr	#8,d2			; so I assume it means there is too
	move.w	d2,bplcon2(a2)		; much stack required for the
	move.w	#256-1,d2		; possible 1k stack if called from
					; one of our patches!
.recol	move.w	(a0)+,d5
	move.w	(a0)+,d4
	move.b	d3,d0
	asl.w	#8,d0
	move.w	_bplcon3(pc),d1
	andi.w	#%0001110111111111,d1
	andi.w	#%1110000000000000,d0
	or.w	d0,d1
	move.b	d3,d0	
	andi.w	#%11111,d0
	lea	color00(a2),a1
	move.w	d1,bplcon3(a2)
	move.w	d5,(a1,d0.w*2)
	bset	#9,d1
	move.w	d1,bplcon3(a2)
	move.w	d4,(a1,d0.w*2)
	addq	#1,d3
	dbra	d2,.recol
	andi.w	#%0001110111111111,d1
	move.w	d1,bplcon3(a2)
.quit	movem.l	(sp)+,d0-d5/a0-a3/a6
	ENDC
	rts


_RestoreScreen
	IFND	DEBUGGING
	movem.l	d0-d3/a0-a3/a6,-(sp)
	lea	_scrn(pc),a0
	tst.w	(a0)
	beq	.quit
	clr.w	(a0)

	get.l	_colbuf,a0
	lea	_custom,a1

	move.w	_bplcon2(pc),d3
	bset	#8,d3
	move.w	d3,bplcon2(a1)

	move.w	_bplcon3(pc),d3
	moveq	#0,d0
.nxtcol	moveq	#0,d1
	move.b	d0,d1
	asl.w	#8,d1
	andi.w	#%0001110111111111,d3
	andi.w	#%1110000000000000,d1
	or.w	d1,d3
	move.w	d0,d1
	andi.w	#%11111,d1
	add.w	d1,d1
	move.w	d3,bplcon3(a1)
	move.w	color00(a1,d1.w),(a0)+
	bset	#9,d3
	move.w	d3,bplcon3(a1)
	move.w	color00(a1,d1.w),(a0)+
	addq	#1,d0
	tst.b	d0
	bne.s	.nxtcol

	move.w	_bplcon2(pc),d3
	bclr	#8,d3
	move.w	d1,bplcon2(a1)


	getbasepc gfx
	moveq	#0,d0
	move.w	#0,_custom+fmode
	dmaoff	COPPER
	move.l	38(a6),_custom+cop1lc	; _ensure_ copper is restarted
	move.l	50(a6),_custom+cop2lc
	move.w	d0,_custom+copjmp1
	move.w	d0,_custom+copjmp2
	dmaon	COPPER

	IFND	NO_SPRITES
*** begin cj stuff ***
	getbasepc int			; restore sprites resolution if we
	cmp.w	#39,20(a6)		; need to. tnx*1e6, comrade j.
	bcs.s	.nowb
	lea	_wbscrn(pc),a3
	move.l	(a3),d0
	beq.s	.nowb
	lea	__wbnam(pc),a0
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,(a3)
	move.l	d0,a0
	lea	_oldres(pc),a2
	lea	_res(pc),a3
	move.l	(a2),(a3)
	lea	_tags(pc),a1
	move.l	48(a0),a0
	getbasepc gfx
	jsr	_LVOVideoControl(a6)
	getbasepc int
	lea	_wbscrn(pc),a2
	move.l	(a2),a0
	jsr	_LVOMakeScreen(a6)
	move.l	(a2),a1
	suba.l	a0,a0
	jsr	_LVOUnlockPubScreen(a6)
*** end cj stuff ***
	ENDC
.nowb	getbasepc gfx
	get.l	__view,a1
	jsr	_LVOLoadView(a6)	; restore view...
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)
	getbasepc int
	jsr	_LVORethinkDisplay(a6)	; even more sure...
.quit	movem.l	(sp)+,d0-d3/a0-a3/a6
	ENDC
	rts

_AllocBitmap
	tst.w	d0
	beq.s	.no
	tst.w	d1
	beq.s	.no
	tst.w	d2
	beq.s	.no
	move.l	d7,-(sp)
	add.l	#15,d0
	and.l	#-16,d0
	asr.l	#3,d0
	move.l	d0,d7
	mulu	d1,d0
	mulu	d2,d0
	move.w	d1,-(sp)
	moveq	#CHIP,d1
	bsr	_AllocMem
	move.w	(sp)+,d1
	move.l	d0,a0
	move.l	d7,d0
	btst	#0,d3
	beq.s	.norm			; INTERLEAVED:
	exg.l	d0,d1			; bytesplane=xbytes
	mulu	d2,d0			; bytesrow=xbytes*planes
	move.l	d0,d2			; modulo=xbytes*planes-xbytes
	sub.l	d7,d2
	bra.s	.exit			; NONINTERLEAVED
.norm	mulu.l	d0,d1			; bytesrow=xbytes
					; bytesplane=xbytes*yrows
	moveq	#0,d2			; modulo=0
.exit	move.l	(sp)+,d7
.no	rts

_WriteDispRegs
	IFND	DEBUGGING
	movem.l	a0-a1,-(sp)
	lea	_custom,a0
	lea	_bplcon0(pc),a1
	move.w	(a1)+,bplcon0(a0)
	move.w	(a1)+,bplcon1(a0)
	move.w	(a1)+,bplcon2(a0)
	move.w	(a1)+,bplcon3(a0)
	move.w	(a1)+,bplcon4(a0)
	movem.l	(sp)+,a0-a1
	ENDC
	rts

_WriteClxCon
	IFND	DEBUGGING
	movem.l d0-d4/a0,-(sp)
	lea	_custom+clxcon,a0
	move.w	d0,d4
	and.w	#%111111,d4
	lsl.w	#6,d4
	move.w	d1,d3
	and.w	#%111111,d3
	or.w	d3,d4
	and.w	#%1111,d2
	ror.w	#4,d2
	or.w	d2,d4
	move.w	d4,(a0)
	moveq	#0,d4
	btst	#7,d0
	beq.s	.no1
	bset	#7,d4
.no1	btst	#6,d0
	beq.s	.no2
	bset	#6,d4
.no2	btst	#7,d1
	beq.s	.no3
	bset	#1,d4
.no3	btst	#6,d1
	beq.s	.no4
	bset	#0,d4
.no4	move.w	d4,clxcon2-clxcon(a0)
	movem.l (sp)+,d0-d4/a0
	ENDC
	rts

_GenerateScroll
	move.w	d3,-(sp)
	move.w	d1,d0
	lsr.w	#2,d0
	and.w	#%1111,d0
	move.w	d2,d3
	lsl.w	#2,d3
	and.w	#%11110000,d3
	or.w	d3,d0
	btst	#7,d2
	beq.s	.no1
	bset	#15,d0
.no1	btst	#6,d2
	beq.s	.no2
	bset	#14,d0
.no2	btst	#7,d1
	beq.s	.no3			; I think testing 8 nearly arbitrary
	bset	#11,d0			; bits is faster than 4 seperate shifts,
.no3	btst	#6,d1			; masks and layers. especially if the
	beq.s	.no4			; bits are mostly 0s. If anyone has a
	bset	#10,d0			; better method, do tell.
.no4	btst	#1,d2
	beq.s	.no5
	bset	#13,d0
.no5	btst	#0,d2
	beq.s	.no6
	bset	#12,d0
.no6	btst	#1,d1
	beq.s	.no7
	bset	#9,d0
.no7	btst	#0,d1
	beq.s	.no8
	bset	#8,d0
.no8	move.w	(sp)+,d3
	rts

_MakeScreen
	movem.l	d2-d7/a2-a6,-(sp)
	add.w	#__fetch-1,d0
	and.w	#-__fetch,d0
	cmp.w	#__fetch,d0
	bcs.s	.no
; note these max/min screen values were calculated a long time ago,
; and written on my workings sheets of paper "to calculate ddfstrt ($92)
; assumes 96 < leftedge <= 432" - i don't currently have the hardware manual
; and can't recheck these values are the real limits. please inform me if
; they are wrong?
	cmp.w	#8,d2
	bhi.s	.no
	cmp.w	#368,d0
	bls.s	.nohres
	bset	#MSB_HIRES,d6
	cmp.w	#736,d0
	bhi.s	.no
.nohres	cmp.w	#344,d1
	bcs.s	.nolace
	bset	#MSB_LACE,d6
	cmp.w	#688,d1
	bcc.s	.no
.nolace	move.w	d0,d7
	swap	d7
	move.w	d1,d7
	move.l	d7,-(sp)
	move.w	d3,d7
	swap	d7
	move.w	d4,d7
	move.l	d7,-(sp)
	move.w	d2,-(sp)
	moveq	#0,d3
	btst	#MSB_INTERLEAVED,d6
	beq.s	.noint
	moveq	#1,d3
.noint	bsr	_AllocBitmap
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d7
	move.w	(sp)+,d1
	move.l	(sp)+,d2
	move.l	(sp)+,d0
	cmp.l	#0,a0
	beq.s	.no
	move.l	a0,-(sp)
	bsr.s	_MakeCopper
	move.l	(sp)+,a1
	cmp.l	#0,a0
	beq.s	.no
	move.l	d3,d0
	move.l	d4,d1
	bra.s	.exit
.no	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,a0
	move.l	d0,a1
.exit	movem.l	(sp)+,d2-d7/a2-a6
	rts

_MakeCopper
	movem.l	d0-d3/d5/a1/a4-a6,-(sp)
	btst	#MSB_LACE,d6
	beq.s	.nolace
	asr.w	#1,d0
.nolace	swap	d0
	btst	#MSB_HIRES,d6
	beq.s	.nohres
	asr.w	#1,d0
.nohres	lea	DIS_TOPEDGE(pc),a6
	add.w	(a6),d2
	sub.w	#44,d2
	swap	d2
	lea	DIS_LEFTEDGE(pc),a6
	add.w	(a6),d2
	sub.w	#128,d2
	lea	.mc_data(pc),a6
	move.w	d0,(a6)+
	swap	d0
	move.w	d0,(a6)+
	move.w	d2,(a6)+
	swap	d2
	move.w	d2,(a6)+
	move.w	d1,(a6)+

	move.w	d7,(a6)+

	move.l	d3,(a6)+
	move.l	d4,(a6)+
	move.l	d5,(a6)+
	move.l	a0,(a6)+
	lea	.mc_data(pc),a6

	moveq	#100,d0				; \_ optimization of
	add.l	d0,d0				; /  move.l #200,d0
	add.l	_mc_cc(a6),d0
	add.l	_mc_cc(a6),d0
	add.l	_mc_cc(a6),d0
	add.l	_mc_cc(a6),d0
	btst	#MSB_LACE,d6
	beq.s	.nolac2
	add.l	d0,d0
.nolac2	moveq	#CHIP,d1			; now allocate
	bsr	_AllocMem
	tst.l	d0
	beq.s	.no
	move.l	d0,a0
	move.l	d0,a5

	bsr.s	.setregs

	btst	#MSB_LACE,d6
	beq.s	.nolac4
	move.l	a0,d0
	add.l	#12,d0
	bsr.s	.setintl
.nolac4	move.l	#$fffffffe,(a0)+
	btst	#MSB_LACE,d6
	beq.s	.nolac5
	move.l	_mc_br(a6),d0
	add.l	d0,_mc_bmp(a6)
	bsr.s	.setregs
	move.l	a5,d0
	bsr.s	.setintl
	move.l	#$fffffffe,(a0)+	
.nolac5	bra.s	.exit
.no	suba.l	a5,a5
.exit	move.l	a5,a0
	movem.l	(sp)+,d0-d3/d5/a1/a4-a6
	rts

.setintl
	swap	d0
	move.w	#cop1lc,(a0)+
	move.w	d0,(a0)+
	swap	d0
	move.w	#cop1lc+2,(a0)+
	move.w	d0,(a0)+
	rts

.setregs
	move.l	#dmacon<<16!DMAF_RASTER,(a0)+

; calculation of diwstrt and diwstop
	move.l	#$01027fff,d0
	btst	#MSB_WIDEDISPLAY,d6
	bne.s	.diw
	moveq	#0,d0
	moveq	#1,d3
	add.w	_mc_y(a6),d3
	move.b	d3,d0
	rol.l	#8,d0
	moveq	#1,d3
	add.w	_mc_x(a6),d3
	move.b	d3,d0
	rol.l	#8,d0
	moveq	#1,d3
	add.w	_mc_y(a6),d3
	add.w	_mc_h(a6),d3
	move.b	d3,d0
	rol.l	#8,d0
	moveq	#1,d3
	add.w	_mc_x(a6),d3
	add.w	(a6),d3 			; optimisation of add.w _mc_w(a6),d3
	move.b	d3,d0

.diw	swap	d0
	move.w	#diwstrt,d1
	bsr	.writeback
	swap	d0
	addq.w	#2,d1				; diwstop
	bsr	.writeback

; calculation of bpl1mod and bpl2mod
	moveq	#0,d0
	move.w	_mc_mod(a6),d0
	btst	#MSB_LACE,d6
	beq.s	.nolac3
	add.l	_mc_br(a6),d0
.nolac3	move.w	#bpl1mod,d1
	bsr	.writeback
	addq.w	#2,d1
	bsr	.writeback

; calculation of ddfstrt and ddfstop
	move.w	_mc_x(a6),d0
	asr.w	#1,d0
	subq.w	#8,d0
	move.w	#ddfstrt,d1
	bsr	.writeback
	move.w	_mc_x(a6),d0
	add.w	(a6),d0				; optimisation of add.w _mc_w(a6),d0
	asr.w	#1,d0
	sub.w	#__fetch,d0
	IFEQ	FETCHMODE-4
	btst	#MSB_HIRES,d6
	beq.s	.nohres2
	add.w	#32,d0
.nohres2
	ENDC
	addq	#2,d1				; ddfstop
	bsr	.writeback

; calculation of bplcon0 and bplcon3
	lea	_bplcon0(pc),a1
	move.w	(a1),d0
	andi.w	#%0000011111101011,d0
	move.w	_mc_p(a6),d1
	btst	#0,d1
	beq.s	.no1
	bset	#12,d0
.no1	btst	#1,d1
	beq.s	.no2
	bset	#13,d0
.no2	btst	#2,d1
	beq.s	.no3
	bset	#14,d0
.no3	btst	#3,d1
	beq.s	.no4
	bset	#4,d0
.no4	btst	#MSB_HIRES,d6
	beq.s	.no5
	bset	#15,d0
.no5	btst	#MSB_LACE,d6
	beq.s	.no6
	bset	#2,d0
.no6	btst	#MSB_HAM,d6
	beq.s	.no7
	bset	#11,d0
.no7	move.w	#bplcon0,d1
	bsr	.writeback
	move.w	d0,(a1)

	addq	#6,a1			; skip bplcon1 and bplcon2

	move.w	(a1),d0
	bclr	#5,d0
	btst	#MSB_NOBORDER,d6
	beq.s	.no8
	bset	#5,d0
.no8	move.w	d0,(a1)
	move.w	#bplcon3,d1
	bsr.s	.writeback

	move.l	_mc_bmp(a6),a1
	move.w	_mc_p(a6),d0
	move.l	_mc_bp(a6),d1
	bsr	_MakeCprBpl

	lea	.over(pc),a1
	move.w	#0,(a1)
	moveq	#7,d0
	move.w	_mc_y(a6),d1
	bsr.s	.wait

	move.l	#dmacon<<16!DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER,(a0)+

	move.l	_mc_cc(a6),d0
	beq.s	.nocc
	subq	#1,d0
.ccloop	move.l	#$01fe0000,(a0)+
	dbra	d0,.ccloop
.nocc	moveq	#7,d0
	move.w	_mc_y(a6),d1
	add.w	_mc_h(a6),d1
	bsr.s	.wait

	move.w	#dmacon,(a0)+
	move.w	#DMAF_RASTER,(a0)+
	rts

.wait	cmp.w	#255,d1
	bls.s	.nolong
	lea	.over(pc),a1
	tst.w	(a1)
	bne.s	.nolong
	move.l	#$ffe1fffe,(a0)+
	move.w	#1,(a1)
.nolong	move.b	d1,(a0)+
	bset	#0,d0
	move.b	d0,(a0)+
	move.w	#$fffe,(a0)+
	rts
.over	dc.w	0

.writeback
	;d0=regvalue
	;d1=reg to write
	;a0=copperlist
	btst	#MSB_STATICREGS,d6
	bne.s	.still
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	rts
.still	lea	$dff000,a4
	move.w	d0,(a4,d1.w)
	rts

.mc_data
 dc.w 0	; _mc_w(a6)	width
 dc.w 0	; _mc_h(a6)	height
 dc.w 0	; _mc_x(a6)	left edge
 dc.w 0	; _mc_y(a6)	top edge
 dc.w 0	; _mc_p(a6)	planes
 dc.w 0	; _mc_mod(a6)	modulo
 dc.l 0	; _mc_br(a6)	bytesrow
 dc.l 0	; _mc_bp(a6)	bytesplane
 dc.l 0	; _mc_cc(a6)	extra copper commands
 dc.l 0	; _mc_bmp(a6)	bitmap ptr

_MakeCprBpl
;d1=bp d0=#p a1=bmp a0=cpr
	cmp.w	#8,d0
	bhi.s	.no
	movem.l	d0-d2/a1,-(sp)
	exg.l	d1,a1
	subq	#1,d0
	move.w	#$e0,d2
.nxtpln	swap	d1
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	addq.w	#2,d2
	swap	d1
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	addq.w	#2,d2
	add.l	a1,d1
	dbra	d0,.nxtpln
	movem.l	(sp)+,d0-d2/a1
.no	rts

_DisplayIFF
	movem.l	d2-d7/a2,-(sp)
	move.l	d3,d6
	move.l	d2,d5
	move.l	d1,d4
	move.l	d0,d3
	move.l	a0,a2

	move.l	#"CAMG",d0
	bsr	_FindChunk
	tst.l	d0
	beq.s	.nolace
	move.l	(a0),d0
	btst	#15,d0
	beq.s	.nohrez
	bset	#MSB_HIRES,d6
.nohrez	btst	#2,d0
	beq.s	.nolace
	bset	#MSB_LACE,d6
.nolace
	move.l	#"BMHD",d0
	move.l	a2,a0
	bsr	_FindChunk
	tst.l	d0
	beq.s	.fail
	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	d1,d7
	move.b	8(a0),d2

	move.l	a2,a0
	bsr	_MakeScreen
	cmp.l	#0,a0
	beq.s	.fail
	exg.l	a0,a2
	move.l	d7,d2
	bsr.s	_UnpackILBM
	exg.l	a0,a2
.exit	movem.l	(sp)+,d2-d7/a2
	rts

.fail	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,a0
	move.l	d0,a1
	bra.s	.exit

_UnpackILBM
	movem.l	d0-d7/a0-a4,-(sp)
	move.l	d0,d5
	move.l	d1,d6
	move.l	d2,d7
	move.l	a0,a3
	move.l	a1,a4
	move.l	#"BMHD",d0
	bsr	_FindChunk
	tst.l	d0
	beq	.exit
	cmp.b	#0,9(a0)
	bne	.exit			; no support any kind of masks yet
	move.b	10(a0),d1
	moveq	#0,d2
	move.w	(a0),d2
	add.w	#15,d2
	and.w	#-16,d2
	asr.w	#3,d2
	moveq	#0,d3
	move.w	2(a0),d3
	cmp.w	d7,d3
	bls.s	.iffsml
	move.l	d7,d3
.iffsml	subq.w	#1,d3
	moveq	#0,d4
	move.b	8(a0),d4
	subq.b	#1,d4
	move.l	a3,a0
	move.l	#"BODY",d0
	bsr.s	_FindChunk
	tst.l	d0
	beq.s	.exit
	cmp.b	#0,d1
	beq.s	.nocomp
	cmp.b	#1,d1
	beq.s	.comp
	bra.s	.exit			; no other compressions supported

.comp	move.l	a4,a3
	move.l	d4,d7
.pln	move.l	a3,a1

	move.l	a1,a2
	add.l	d2,a2
.nxbt	cmp.l	a1,a2
	beq.s	.end
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	.neg
.norm	cmp.l	a1,a2
	beq.s	.end
	move.b	(a0)+,(a1)+
	dbra	d0,.norm
	bra.s	.nxbt
.neg	neg.b	d0
	bmi.s	.nxbt
	move.b	(a0)+,d1
.rept	cmp.l	a1,a2
	beq.s	.end
	move.b	d1,(a1)+
	dbra	d0,.rept
	bra.s	.nxbt
.end
	add.l	d6,a3
	dbra	d7,.pln
	add.l	d5,a4
	dbra	d3,.comp
	bra.s	.exit

.nocomp	move.l	a4,a3
	move.l	d4,d7
.plane	move.l	a3,a1

	move.l	d2,d0
	asr.l	#1,d0
	subq	#1,d0
.copy	move.w	(a0)+,(a1)+
	dbra	d0,.copy

	add.l	d6,a3
	dbra	d7,.plane
	add.l	d5,a4
	dbra	d3,.nocomp
.exit	movem.l	(sp)+,d0-d7/a0-a4
	rts

_FindChunk
	movem.l	d1-d2,-(sp)
	cmp.l	#"FORM",(a0)+
	bne.s	.badxit
	move.l	(a0)+,d1		;d1=total length
	subq.l	#4,d1			; ignore iff type
	addq.l	#4,a0
	cmp.l	#8,d1
	ble.s	.badxit			; one empty chunk is pointless
.again	cmp.l	(a0)+,d0
	beq.s	.found
	move.l	(a0)+,d2
	addq.l	#1,d2
	bclr	#0,d2			; must be even
	add.l	d2,a0
	subq.l	#8,d1
	sub.l	d2,d1
	tst.l	d1
	bgt.s	.again
	bra.s	.badxit
.found	move.l	(a0)+,d0
	bra.s	.exit
.badxit	moveq	#0,d0
	move.l	d0,a0
.exit	movem.l	(sp)+,d1-d2
	rts

_SetColour
	movem.l	d0-d7/a0,-(sp)
	moveq	#%00001111,d6		;d4=low 12 bits, d5=upper 12 bits
	move.w	#%11110000,d7
	move.l	d1,d4			; get and split red element
	swap	d4
	and.w	#%11111111,d4
	move.w	d4,d5
	and.w	d6,d4
	and.w	d7,d5
	lsl.w	#8,d4
	lsl.w	#4,d5
	move.w	d1,d2			; get and split green element
	lsr.w	#8,d2
	move.w	d2,d3
	and.w	d6,d2
	and.w	d7,d3
	or.w	d3,d5
	lsl.w	#4,d2
	or.w	d2,d4
	move.w	d1,d2			; get and split blue element
	move.w	d2,d3
	and.w	d6,d2
	and.w	d7,d3
	or.w	d2,d4
	lsr.w	#4,d3
	or.w	d3,d5
	bra.s	__writecol

_SetColoursRGB
	movem.l	d0-d4/a0,-(sp)
	move.w	d1,d4
	subq	#1,d4
.lop	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3
	bsr.s	_SetColourRGB
	andi.w	#255,d0
	addq	#1,d0
	dbra	d4,.lop
	movem.l	(sp)+,d0-d4/a0
	rts

_SetColourRGB
	movem.l	d0-d7/a0-a1,-(sp)
	moveq	#%00001111,d6		;d4=low 12 bits, d5=upper 12 bits
	move.w	#%11110000,d7
	move.w	d3,d4			; split blue
	move.w	d3,d5
	and.w	d6,d4
	and.w	d7,d5
	lsr.w	#4,d5
	move.w	d2,d3			; split green
	and.w	d6,d2
	and.w	d7,d3
	lsl.w	#4,d2
	or.w	d2,d4
	or.w	d3,d5
	move.w	d1,d2			; split red
	and.w	d6,d1
	and.w	d7,d2
	lsl.w	#4,d2
	lsl.w	#8,d1
	or.w	d1,d4
	or.w	d2,d5
__writecol
	lea	_bplcon3(pc),a0
	move.w	(a0),d1
	andi.w	#%0001110111111111,d1
	btst	#7,d0
	beq.s	.no2
	bset	#15,d1
.no2	btst	#6,d0
	beq.s	.no1
	bset	#14,d1
.no1	btst	#5,d0
	beq.s	.no0
	bset	#13,d1
.no0	andi.w	#%11111,d0
	lea	_custom,a0
	lea	color00(a0),a1
	move.w	d1,bplcon3(a0)
	move.w	d5,(a1,d0.w*2)
	bset	#9,d1
	move.w	d1,bplcon3(a0)
	move.w	d4,(a1,d0.w*2)
	bclr	#9,d1
	move.w	d1,bplcon3(a0)
	movem.l	(sp)+,d0-d7/a0-a1
	rts

_FadeColoursRGB
	cmp.b	#1,d2
	bls	.no
	cmp.b	#4,d2
	bgt	.no
	cmp.l	#0,a2			; little safety check ;-)
	beq	.no
	movem.l	d0-d7/a0-a3,-(sp)
	move.l	d0,d6			; d6=startcol
	move.l	d1,d7			; d7=#colours
	move.l	a2,a3			; a3=callback ptr
	andi.w	#511,d7
	subq	#1,d2
	moveq	#0,d5
	move.w	d7,d5
	add.w	d7,d5
	add.w	d7,d5			; d5=#colours*3=array length

	lea	.src(pc),a2
	move.l	a0,(a2)
	btst	#1,d2	; bit 1=1: src=colourset, bit1=0: src=colour
	bne.s	.srcset
	move.l	d5,d0
	moveq	#FAST,d1
	bsr	_AllocMem
	move.l	d0,(a2)
	tst.l	d0
	beq	.exit
	move.l	d0,a2
	move.l	d7,d0
	subq	#1,d0
	move.l	a0,d1
.srcfil	swap	d1
	move.b	d1,(a2)+
	rol.l	#8,d1
	move.b	d1,(a2)+
	rol.l	#8,d1
	move.b	d1,(a2)+
	dbra	d0,.srcfil
.srcset
	lea	.dest(pc),a2
	move.l	a1,(a2)
	btst	#0,d2	; bit 0=1: dest=colourset, bit0=0: dest=colour
	bne.s	.dstset
	move.l	d5,d0
	moveq	#FAST,d1
	bsr	_AllocMem
	move.l	d0,(a2)
	tst.l	d0
	beq	.exit
	move.l	d0,a2
	move.l	d7,d0
	subq	#1,d0
	move.l	a1,d1
.dstfil	swap	d1
	move.b	d1,(a2)+
	rol.l	#8,d1
	move.b	d1,(a2)+
	rol.l	#8,d1
	move.b	d1,(a2)+
	dbra	d0,.dstfil
.dstset
	lea	.tmp(pc),a2
	move.l	d5,d0
	moveq	#FAST,d1
	bsr	_AllocMem
	move.l	d0,(a2)
	tst.l	d0
	beq.s	.leave

	moveq	#0,d4
.next	get.l	.src,a0
	get.l	.dest,a1
	get.l	.tmp,a2

	moveq	#-1,d2
	add.w	d7,d2
	add.w	d7,d2
	add.w	d7,d2
.proc	moveq	#0,d0
	moveq	#0,d1
	move.b	(a1)+,d0
	move.b	(a0)+,d1
	sub.w	d1,d0
	muls	d4,d0
	divs	d3,d0
	add.w	d1,d0
	move.b	d0,(a2)+
	dbra	d2,.proc

	get.l	.tmp,a0
	move.l	d6,d0
	move.l	d7,d1
	bsr	_SetColoursRGB
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(a3)
	movem.l	(sp)+,d0-d7/a0-a6
	addq	#1,d4
	cmp.w	d3,d4
	bne.s	.next

.leave	get.l	.dest,a0
	move.l	d6,d0
	move.l	d7,d1
	bsr	_SetColoursRGB
.exit	movem.l	(sp)+,d0-d7/a0-a3
.no	rts
.src	dc.l	0
.dest	dc.l	0
.tmp	dc.l	0

*** INPUT ***
_keys	dc.l	0
__MXmin	dc.w	0
__MYmin	dc.w	0
__MXmax	dc.w	0
__MYmax	dc.w	0
__MX	dc.w	0
__MY	dc.w	0
_keybuf	dc.l	0
_inpevn	dc.l	0	; ie_NextEvent=NULL
	dc.b	1	; ie_Class=IECLASS_RAWKEY
	dc.b	0	; ie_SubClass=IESUBCLASS_COMPATIBLE
_iecode	dc.w	0	; ie_Code=the rawkey code we got
	dc.w	0	; ie_Qualifier=various tests :-)
	dc.b	0	; previous 2 codes and qualifiers!
	dc.b	0	; keydowns only!
	dc.b	0
	dc.b	0
	dc.l	0,0	; TimeVal struct (unused)

_SetMouseLimits
	move.l	a0,-(sp)
	lea	__MXmin(pc),a0
	move.w	d0,(a0)+		; set Xmin
	move.w	d1,(a0)+		; set Ymin
	move.w	d2,(a0)+		; set Xmax
	move.w	d3,(a0)+		; set Ymax
	move.l	#0,(a0)+		; reset X and Y
	move.l	a0,(sp)+
	rts

_GetMouse
	movem.l	d2-d4/a0-a1,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	move.w	_custom+joy0dat,d1
	move.w	d1,d0			; d0 = dx since last read
	lsr.w	#8,d1			; d1 = dy since last read

	lea	.dx(pc),a0		; process X coordinate
	lea	.odx(pc),a1
	move.b	(a0),(a1)
	move.b	d0,(a0)
	sub.b	(a1),d0
	ext.w	d0
	lea	__MXmin(pc),a0
	move.w	(a0),d3			; d3 = X min
	lea	__MXmax(pc),a0
	move.w	(a0),d4			; d4 = X max
	lea	__MX(pc),a0
	move.w	(a0),d2			; d2 = X
	add.w	d0,d2
	cmp.w	d3,d2
	bge.s	.xgt
	move.w	d3,d2
.xgt	cmp.w	d4,d2
	ble.s	.xlt
	move.w	d4,d2
.xlt	move.w	d2,(a0)
	move.w	d2,d0

	lea	.dy(pc),a0		; process Y coordinate
	lea	.ody(pc),a1
	move.b	(a0),(a1)
	move.b	d1,(a0)
	sub.b	(a1),d1
	ext.w	d1
	lea	__MYmin(pc),a0
	move.w	(a0),d3			; d3 = Y min
	lea	__MYmax(pc),a0
	move.w	(a0),d4			; d4 = Y max
	lea	__MY(pc),a0
	move.w	(a0),d2			; d2 = Y
	add.w	d1,d2
	cmp.w	d3,d2
	bge.s	.ygt
	move.w	d3,d2
.ygt	cmp.w	d4,d2
	ble.s	.ylt
	move.w	d4,d2
.ylt	move.w	d2,(a0)
	move.w	d2,d1
	movem.l	(sp)+,d2-d4/a0-a1
	rts

.dx	dc.b	0
.dy	dc.b	0
.odx	dc.b	0
.ody	dc.b	0

_FlushKeyboard
	move.l	d0,-(sp)
.again	move.w	#381,d0
	bsr	_CauseDelay
	bsr.s	_ReadKey
	cmp.b	#-1,d0
	bne.s	.again
	move.l	(sp)+,d0
	rts

_ReadKey
	movem.l	d1-d2/a0,-(sp)
	move.w	_custom+intenar,d2
	bset	#15,d2
	move.w	#$7fff,_custom+intena
.again	moveq	#0,d0
	moveq	#0,d1
	move.b	ciaasdr,d1
	not.b	d1
	ror.b	#1,d1
	; d1=rawcode

	; now handshake
	bset	#SPMODE,ciaacra		; outputmode
	move.b	#64,ciaatalo		; 64*1.4096837ms counts = >90ms,
	move.b	#0,ciaatahi		; slowest keyb needs 85ms shake....
	move.b	#SPMODE!INMODE!1,ciaacra
	tst.b	ciaaicr
	tst.b	ciaaicr
.loop	move.b	#-1,ciaasdr		; write SP high
	btst	#0,ciaaicr
	beq.s	.loop
	bclr	#SPMODE,ciaacra		; back to inputmode

	cmp.b	#$78,d1
	beq.s	.reset

	tst.b	d1			; TEMP bugfix
	beq.s	.nokey

	lea	.oldkey(pc),a0
	move.b	(a0),d0
	move.b	d1,(a0)
	cmp.b	d0,d1
	beq.s	.nokey
	cmp.b	#$f9,d1
	beq.s	.again
	bhi.s	.nokey

	get.l	_keys,a0
	move.b	d1,d0
	bmi.s	.keyup
	andi.w	#$7f,d0
	st.b	(a0,d0.w)
	bra.s	.exit
.keyup	andi.w	#$7f,d0
	sf.b	(a0,d0.w)
.exit	move.l	d1,d0
	andi.w	#$ff,d0
	move.w	d2,_custom+intena
	movem.l	(sp)+,d1-d2/a0
	rts
.nokey	moveq	#-1,d0
	move.w	d2,_custom+intena
	movem.l	(sp)+,d1-d2/a0
	rts
.reset	move.w	#$7fff,_custom+intreq
	move.w	#$7fff,_custom+dmacon
	getbasepc sys
	jmp	_LVOColdReboot(a6)
.oldkey	dc.w	0

* This above is derived from the GET_KEYBOARD
* routine by Fabio Bizzetti <bizzetti@mbox.vol.it>
* and is used with his permission.

_TranslateKey
	movem.l	d1/a0-a2/a6,-(sp)
	lea	_inpevn(pc),a0
	cmp.w	#$80,ie_Code(a0)
	bgt.s	.keyup
	move.b	ie_Prev1DownCode(a0),ie_Prev2DownCode(a0)
	move.b	ie_Prev1DownQual(a0),ie_Prev2DownQual(a0)
	move.b	ie_Code+1(a0),ie_Prev1DownCode(a0)
	move.b	ie_Qualifier+1(a0),ie_Prev1DownQual(a0)
.keyup	clr.w	ie_Code(a0)
	clr.w	ie_Qualifier(a0)
	move.b	d0,ie_Code+1(a0)
	andi.w	#$7f,d0
	cmp.b	#KEYPAD_CLOSE_PARENTHESIS,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_OPEN_PARENTHESIS,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_SLASH,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_STAR,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_PLUS,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_PERIOD,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_ENTER,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_MINUS,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_0,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_1,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_2,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_3,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_4,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_5,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_6,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_7,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_8,d0
	beq.s	.ispad
	cmp.b	#KEYPAD_9,d0
	beq.s	.ispad
	bra.s	.donpad
.ispad	ori.w	#IEQUALIFIER_NUMERICPAD,ie_Qualifier(a0)

.donpad	moveq	#KEY_LSHIFT,d0
	bsr	_CheckKey
	tst.b	d0
	beq.s	.no1
	ori.w	#IEQUALIFIER_LSHIFT,ie_Qualifier(a0)
.no1	moveq	#KEY_RSHIFT,d0
	bsr	_CheckKey
	tst.b	d0
	beq.s	.no2
	ori.w	#IEQUALIFIER_RSHIFT,ie_Qualifier(a0)
.no2	moveq	#KEY_LALT,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no3
	ori.w	#IEQUALIFIER_LALT,ie_Qualifier(a0)
.no3	moveq	#KEY_RALT,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no4
	ori.w	#IEQUALIFIER_RALT,ie_Qualifier(a0)
.no4	moveq	#KEY_LAMIGA,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no5
	ori.w	#IEQUALIFIER_LCOMMAND,ie_Qualifier(a0)
.no5	moveq	#KEY_RAMIGA,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no6
	ori.w	#IEQUALIFIER_RCOMMAND,ie_Qualifier(a0)
.no6	moveq	#KEY_CTRL,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no7
	ori.w	#IEQUALIFIER_CONTROL,ie_Qualifier(a0)
.no7	moveq	#KEY_CAPSLOCK,d0
	bsr.s	_CheckKey
	tst.b	d0
	beq.s	.no8
	ori.w	#IEQUALIFIER_CAPSLOCK,ie_Qualifier(a0)
.no8
	getbasepc key
	lea	_keybuf(pc),a1
	moveq	#3,d1
	get.l	keymap,a2
	jsr	_LVOMapRawKey(a6)
	cmp.b	#1,d0
	bne.s	.fail
	moveq	#0,d0
	lea	_keybuf(pc),a1
	move.b	(a1),d0
	bra.s	.exit
.fail	moveq	#0,d0
.exit	movem.l	(sp)+,d1/a0-a2/a6
	rts

_CheckKey
	andi.w	#$7f,d0
	tst.b	([_keys,pc],d0.w)
	sne	d0
	rts

*** FILE ***
	IFD	NO_FILESYSTEM
_SizeFile
	moveq	#0,d0
	rts
_LoadFile
	moveq	#0,d0
	suba.l	a0,a0
	rts
_SaveFile
	moveq	#0,d0
	rts
_DumpFile
	moveq	#0,d0
	rts
	ELSEIF
*** FILE ***
_file	dc.w	0
_chint	dc.w	0

_dosin	lea	_intsta(pc),a6
	tst.w	(a6)			; are ints off?
	beq.s	.ni
	lea	_chint(pc),a6		; yes, turn them on
	move.w	#1,(a6)
	bsr	_Enable
.ni	rts
_dosout	lea	_file(pc),a6
	move.w	#1,(a6)			; mark that we have loaded/saved
	lea	_chint(pc),a6
	tst.w	(a6)			; did we enable ints?
	beq.s	.no
	clr.w	(a6)
	bsr	_Disable		; disable them again.
.no	rts

_SizeFile
	move.l	a6,-(sp)
	bsr.s	_dosin
	bsr.s	__DOSsizefile
	bsr.s	_dosout
	move.l	(sp)+,a6
	rts
_SaveFile
	move.l	a6,-(sp)
	bsr.s	_dosin
	bsr.s	__DOSsavefile
	bsr.s	_dosout
	move.l	(sp)+,a6
	rts
_LoadFile
	move.l	a6,-(sp)
	bsr.s	_dosin
	bsr	__DOSloadfile
	bsr.s	_dosout
	move.l	(sp)+,a6
	rts
_DumpFile
	move.l	a6,-(sp)
	bsr.s	_dosin
	bsr	__DOSdumpfile
	bsr.s	_dosout
	move.l	(sp)+,a6
	rts


__DOSsizefile
	movem.l	d1-d2/d5-d7/a0-a1,-(sp)
	moveq	#0,d5
	getbasepc	dos
	move.l	a0,d1
	moveq	#SHARED_LOCK,d2
	jsr	_LVOLock(a6)
	move.l	d0,d7
	beq.s	.fail
	move.l	#264,d0
	moveq	#FAST,d1
	bsr	_AllocMem
	move.l	d0,d6
	beq.s	.unlock
	move.l	d7,d1
	move.l	d6,d2
	jsr	_LVOExamine(a6)
	tst.l	d0
	beq.s	.free
	move.l	d6,a0
	move.l	124(a0),d5
.free	move.l	d6,d0
	bsr	_FreeMem
.unlock	move.l	d7,d1
	jsr	_LVOUnLock(a6)
.fail	move.l	d5,d0
	movem.l	(sp)+,d1-d2/d5-d7/a0-a1
	rts

__DOSsavefile
	movem.l	d1-d4/a0-a1,-(sp)
	moveq	#0,d4
	tst.l	d0
	bne.s	.cont
	exg.l	a0,a1
	bsr	_SizeMem
	exg.l	a0,a1
	tst.l	d0
	bne.s	.cont
	move.l	a0,-(sp)
	move.l	a1,a0
.again	tst.b	(a0)+
	beq.s	.found
	bra.s	.again
.found	sub.l	a1,a0
	move.l	a0,d0
	move.l	(sp)+,a0
.cont	tst.l	d0
	beq.s	.fail
	move.l	a1,d3
	move.l	d0,d4
	move.l	a0,d1
	move.l	#MODE_NEWFILE,d2
	getbasepc	dos
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.s	.fail
	move.l	d0,d1
	move.l	d3,d2
	move.l	d4,d3
	move.l	d0,d4
	jsr	_LVOWrite(a6)
	exg.l	d4,d0
	move.l	d0,d1
	jsr	_LVOClose(a6)
	exg.l	d4,d0
	cmp.l	#-1,d0
	bne.s	.noerr
.fail	moveq	#0,d0
.noerr	movem.l	(sp)+,d1-d4/a0-a1
	rts

__DOSdumpfile
	movem.l	d1-d4/a0-a2,-(sp)
	move.l	a1,a2
	tst.l	d0
	bne.s	.cont
	bsr	__DOSsizefile
.cont	move.l	d0,d1
	exg.l	a0,a1
	bsr	_SizeMem
	exg.l	a0,a1
	tst.l	d0
	beq.s	.swap
	cmp.l	d1,d0
	bcs.s	.noswap
.swap	exg.l	d1,d0
.noswap	move.l	d0,d4
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	getbasepc	dos
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.s	.fail
	move.l	a2,d2
	move.l	d4,d3
	move.l	d0,d1
	move.l	d0,d4
	jsr	_LVORead(a6)
	exg.l	d4,d0
	move.l	d0,d1
	jsr	_LVOClose(a6)
	exg.l	d4,d0
	cmp.l	#-1,d0
	bne.s	.noerr
.fail	moveq	#0,d0
.noerr	movem.l	(sp)+,d1-d4/a0-a2
	rts

__DOSloadfile
	movem.l	d1-d7/a1-a5,-(sp)
	move.l	d0,d7
	move.l	a0,a5
	moveq	#0,d0
	lea	.outbuf(pc),a0
	move.l	d0,(a0)
	move.l	d0,4(a0)

	get.l	memlist,a0
	moveq	#MEMELEMENTS-1,d0
.floop	tst.l	(a0)
	beq.s	.cont
	addq.l	#8,a0
	dbra	d0,.floop
	bra	.exit			; failed to find a free memory entry
.cont	moveq	#0,d0
	lea	.inbuf(pc),a0
	move.l	d0,(a0)
	move.l	d0,4(a0)
	move.l	a0,a1
	move.l	a5,a0
	moveq	#4,d0
	bsr	__DOSdumpfile
	tst.l	d0
	beq	.exit
	cmp.l	#"PP20",(a1)
	bne.s	.notpp
;=== powerpacker decrunching ===
	getbasepc	sys
	lea	.ppnam(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq.s	.notpp
	move.l	d0,a6
	moveq	#-1,d1
	move.l	a5,a0
	lea	.outbuf(pc),a1
	lea	.outsze(pc),a2
	move.l	d1,a3
	moveq	#4,d0			; DECR_NONE (no decrunch colour)
	moveq	#0,d1
	tst.b	d7
	beq.s	.notchp
	moveq	#MEMF_PUBLIC!MEMF_CHIP,d1
.notchp	jsr	-30(a6)			; _LVOppLoadFile (shocking!)
	move.l	d0,d7
	move.l	a6,a1
	getbasepc	sys
	jsr	_LVOCloseLibrary(a6)
	tst.l	d7
	bne.s	.ppfail
	get.l	memlist,a0
	moveq	#MEMELEMENTS-1,d0
.f2loop	tst.l	(a0)
	beq.s	.cont2
	addq.l	#8,a0
	dbra	d0,.f2loop
.cont2	lea	.outbuf(pc),a1
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	bra	.exit
.ppfail	moveq	#0,d0
	lea	.outbuf(pc),a0
	move.l	d0,(a0)
	move.l	d0,4(a0)
	bra	.exit
;=== end powerpacker decrunching ===
.notpp	move.l	a5,a0
	bsr	__DOSsizefile
	tst.l	d0
	beq	.exit
	lea	.insze(pc),a0
	move.l	d0,(a0)
	move.l	d0,d2
	move.l	d7,d1
	bsr	_AllocMem
	tst.l	d0
	beq	.exit
	lea	.inbuf(pc),a0
	move.l	d0,(a0)
	move.l	a5,a0
	move.l	d0,a1
	move.l	d2,d0
	bsr	__DOSdumpfile
	tst.l	d0
	beq	.exit
	suba.l	a5,a5			; a5=xfd_BufInfo
	lea	.xfdnam(pc),a1
	moveq	#36,d0
	getbasepc	sys
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq	.noxfd
	move.l	d0,a6
	moveq	#1,d0			; XFDOBJ_BUFFERINFO
	jsr	_LVOxfdAllocObject(a6)
	tst.l	d0
	beq	.noobj
	move.l	d0,a5
	lea	.inbuf(pc),a0
	move.l	(a0),(a5)
	move.l	4(a0),4(a5)
	move.l	a5,a0
	jsr	_LVOxfdRecogBuffer(a6)
	tst.l	d0
	beq.s	.xfail
	move.w	16(a5),d0
	and.w	#%11010000,d0
	tst.l	d0
	bne.s	.xfail	; passwords not supported
	moveq	#0,d0
	tst.b	d7
	beq.s	.nochp2
	moveq	#MEMF_PUBLIC!MEMF_CHIP,d0
.nochp2	move.l	d0,24(a5)
	move.l	a5,a0
	jsr	_LVOxfdDecrunchBuffer(a6)
	tst.l	d0
	beq.s	.xfail
	lea	.inbuf(pc),a0
	move.l	(a0),d0
	bsr	_FreeMem
	move.l	20(a5),(a0)
	move.l	32(a5),4(a0)
	get.l	memlist,a1
	moveq	#MEMELEMENTS-1,d0
.f3loop	tst.l	(a1)
	beq.s	.cont3
	addq.l	#8,a1
	dbra	d0,.f3loop
.cont3	move.l	20(a5),(a1)
	move.l	28(a5),4(a1)
	bra.s	.xfree
.xfail	tst.l	20(a5)
	beq.s	.xfree
	move.l	20(a5),a1
	move.l	28(a5),d0
	move.l	a6,a2
	getbasepc	sys
	jsr	_LVOFreeMem(a6)
	move.l	a2,a6
.xfree	move.l	a5,a1
	jsr	_LVOxfdFreeObject(a6)
.noobj	move.l	a6,a1
	getbasepc	sys
	jsr	_LVOCloseLibrary(a6)
.noxfd	lea	.inbuf(pc),a0
	lea	.outbuf(pc),a1
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
.exit	move.l	.outsze(pc),d0
	get.l	.outbuf,a0
	movem.l	(sp)+,d1-d7/a1-a5
	rts
.inbuf	dc.l	0
.insze	dc.l	0
.outbuf	dc.l	0
.outsze	dc.l	0
.ppnam	dc.b	'powerpacker.library',0
.xfdnam	dc.b	'xfdmaster.library',0
	cnop	0,4
	ENDC
___main
	IFD	USEMAIN
	jmp	_main
	ENDC
	ENDC	__CADOS
