; ===================================================================
;
;                              DBUG.library
;   
;                         Small System Debugger
;
;                                 V 1.3
;
;
;                              Source-code
;
; ===================================================================

	INCLUDE	'include:sos/sos.i'
	INCLUDE	'include:sos/sosprivate.i'
	INCLUDE	'include:sos/sosamprivate.i'
	INCLUDE	'DBUG.i'


	moveq	#-1,d0
	rts

Start	lea	DBUGBase(pc),a0
	rts

	jmp	SetPSS
	jmp	StripColor0
	jmp	LoadDebugger
	jmp	Interrupt
	jmp	_nothing
DBUGBase	ds.l	LIB_SIZEOF

_nothing	moveq	#0,d0
	rts

******* DBUG.library/CheckDBUG *********************************************
*
*   NAME
*	CheckDBUG -- Test if debugger should be activated.
*
*   SYNOPSIS
*	CheckDBUG()
*
*	void CheckDBUG(void);
*
*   FUNCTION
*	Checks if the hotkey for the debugger was pressed.
*	If it is pressed, the small system debugger is called.
*
*	You need not supply the library base.
*
*   BUGS
*
****************************************************************************


Interrupt:
	btst	#7,$bfe001		; Feuer?
	bne.s	_rts			; -> nein!
	jsr	_GetKey(a6)		; Taste ?
	tst.b	d0
	beq.s	_rts			; -> nein!
	bmi.s	_rts			; -> KeyUp

	move.l	d0,-(a7)
	lea	Register(pc),a0
	move.l	a0,Registers
	lea	6(a7),a1
	bsr	SetPSS
	move.l	(a7)+,d0

Menu:	move.w	d0,-(a7)			; Rette Taste

	jsr	_SetDefault(a6)
	moveq	#0,d0			; Rette System
	move.l	d0,a0
	jsr	_SetInt(a6)
	jsr	_OpenScreen(a6)

	move.w	(a7)+,d0			; d0 = Taste
	bsr	Selector
	tst.w	d0
	bpl.s	.end
	bsr	_Menu

.end	tst.w	d0
	bne.s	.skip
	lea	EndMsg(pc),a0		; Warte auf Taste
	jsr	_PutScreen(a6)
.wait	jsr	_GetKey(a6)
	tst.b	d0
	beq.s	.wait
	bmi.s	.wait

.skip	jsr	_ClrDefault(a6)		; Ausgangsstellung

_rts
.rts	;
.rts2	rts

; ===================================================================

Selector	cmp.b	#'m',d0			; Was is loß?
	beq	_Memory
	cmp.b	#'a',d0
	beq	_About
	cmp.b	#'x',d0
	beq	_Xit
	cmp.b	#'s',d0
	beq	_Status
	cmp.b	#'d',d0
	beq	_Debug
	moveq	#-1,d0
	rts

; ===================================================================

_About	lea	AboutTxt(pc),a0		; About Text
	jsr	_PutScreen(a6)
	moveq	#0,d0
	rts

; ===================================================================

_Memory	move.l	d7,-(a7)
	lea	Mem1(pc),a0		; Topic Mem
	jsr	_PutScreen(a6)
	jsr	_GetPISS(a6)
	move.l	PISS_TopicMem(a0),a0
	bsr	ShowMem

	lea	Mem2(pc),a0		; Default Mem
	jsr	_PutScreen(a6)
	jsr	_GetPISS(a6)
	move.l	PISS_DefaultMem(a0),a0
	move.b	MN_Flags(a0),d7
	move.l	MN_Previous(a0),a0
	lea	MN_MemAgent(a0),a0
	bsr	ShowMem

	lea	Mem3(pc),a0		; Total Mem
	jsr	_PutScreen(a6)
	jsr	_GetPISS(a6)
	move.l	PISS_TotalMem(a0),a0
	bsr	ShowMem
	
	lea	AltMsg0,a0
	jsr	_PutScreen(a6)

	lea	AltMsg1,a0
	btst	#0,d7
	beq.s	.sa1
	addq.l	#3,a0
.sa1	jsr	_PutScreen(a6)

	lea	AltMsg2,a0
	btst	#1,d7
	beq.s	.sa2
	addq.l	#3,a0
.sa2	jsr	_PutScreen(a6)

	jsr	_GetPISS(a6)		; free memory
	move.l	PISS_TopicMem(a0),a0
	moveq	#MA_CHUNKS-1,d0
	moveq	#0,d1
.loopf	sub.l	(a0)+,d1
	add.l	(a0)+,d1
	dbf	d0,.loopf
	lea	FreeMod,a1
	move.l	d1,d0
	bsr.w	hex
	lea	FreeTxt,a0
	jsr	_PutScreen(a6)	

	jsr	_GetPISS(a6)		; Used memory
	move.l	PISS_TopicMem(a0),a1
	move.l	PISS_TotalMem(a0),a0
	moveq	#MA_CHUNKS-1,d0
	moveq	#0,d1
.loopu	sub.l	(a0)+,d1
	add.l	(a0)+,d1
	add.l	(a1)+,d1
	sub.l	(a1)+,d1
	dbf	d0,.loopu
	lea	UsedMod,a1
	move.l	d1,d0
	bsr.w	hex
	lea	UsedTxt,a0
	jsr	_PutScreen(a6)	

	moveq	#0,d0
	move.l	(a7)+,d7
	rts

; ===================================================================

_Xit	moveq	#ERR_End,d0		; Ende
	jmp	_Error(a6)

; ===================================================================

_Menu	lea	HelpTxt(pc),a0		; About Text
	jsr	_PutScreen(a6)

.get	jsr	_GetKey(a6)		; Taste ?
	tst.b	d0
	beq.s	.get			; -> nein!
	bmi.s	.get			; -> KeyUp

	cmp.b	#'c',d0			; -> Continue demo?
	beq.s	.end

	bsr	Selector			; Do It?
	bra	_Menu			; Loop

.end	moveq	#1,d0
	rts

; ===================================================================

_Status
Status	jsr	_OpenScreen(a6)		; Meldung ausgeben
	jsr	_GetPISS(a6)
	move.l	a0,a2
	lea	CpuMsg(pc),a0		; CPU-Text
	moveq	#0,d0
	move.w	PISS_TurboCPU(a2),d0
	divs	#10,d0
	add.b	#"0",d0
	move.b	d0,4+2(a0)
	jsr	_PutScreen(a6)

	lea	GenMsg(pc),a0			; Genlock-Text
	btst	#1,PISS_BPLCON0+1(a2)
	beq.s	.skip
	addq.l	#3,a0
.skip	jsr	_PutScreen(a6)

	lea	BlitMsg(pc),a0			; Large-Blits Text
	btst	#0,PISS_Configur+1(a2)
	beq.s	.skip2
	addq.l	#3,a0
.skip2	jsr	_PutScreen(a6)

	lea	ChipMsg(pc),a0			; Chips Level
	lea	ChipTyp(pc),a1
	moveq	#0,d0
	move.b	PISS_Level(a2),d0
	mulu.w	#3,d0
	add.w	d0,a1
	move.b	(a1)+,9(a0)
	move.b	(a1)+,10(a0)
	move.b	(a1)+,11(a0)
	jsr	_PutScreen(a6)
	rts


;	lea	MemMsg(pc),a0
;	jsr	_PutScreen(a6)
;	movem.l	d2/d3/a2,-(a7)
;	moveq	#MA_CHUNKS-1,d2		; d2 = Counter
;	lea	SB_SystemMem+MN_MemAgent(a6),a2	; a2 = Memory
;.loop	lea	MemMsg1(pc),a0
;	move.l	(a2),d0
;	beq.s	.next
;	lea	2(a0),a1
;	bsr.s	hex
;	move.l	4(a2),d0
;	lea	2(a1),a1
;	bsr.s	hex
;	jsr	_PutScreen(a6)
;.next	lea	8(a2),a2
;	dbf	d2,.loop
;	movem.l	(a7)+,d2/d3/a2
;	rts


; ===================================================================


; ===================================================================
; Show MemAgent
; a0 = MemAgent

ShowMem	movem.l	d2/d3/a2,-(a7)
	move.l	a0,a2
	moveq	#MA_CHUNKS-1,d2		; d2 = Counter
.loop	lea	MemMsg1(pc),a0
	move.l	(a2),d0
	beq.s	.next
	lea	2(a0),a1
	bsr.s	hex
	move.l	4(a2),d0
	lea	2(a1),a1
	bsr.s	hex
	jsr	_PutScreen(a6)
.next	lea	8(a2),a2
	dbf	d2,.loop
	movem.l	(a7)+,d2/d3/a2
	moveq	#0,d0
	rts

hex	moveq	#7,d3			; gebe d0 bei a1 aus
.hex1	rol.l	#4,d0
	moveq	#$f,d1
	and.w	d0,d1
	move.b	.heximg(pc,d1.w),(a1)+
	dbf	d3,.hex1
	rts

.heximg	dc.b	'0123456789ABCDEF'
	even


******* DBUG.library/LoadDebugger ******************************************
*
*   NAME
*	LoadDebugger -- Load and start the MOD3 monitor.
*
*   SYNOPSIS
*	LoadDebugger(PSS)
*	             a0
*
*	void LoadDebugger(struct ProcessorStatus *);
*
*   FUNCTION
*	Load and start the MOD3 debugger and pass the processor 
*	register structure.
*
*   INPUTS
*	PSS   - Zeiger auf eine Processor Save Structur
*
*   BUGS
*
****************************************************************************

LoadDebugger:
	move.l	a0,Registers
	bra	Menu


_Debug	move.l	Registers(pc),a0
	move.l	a0,-(a7)
	jsr	_SetDefault(a6)
	lea	DebName(pc),a0		; Lade Debugger
	jsr	_LoadSeg(a6)
	move.l	a0,a1
	move.l	(a7)+,a0
	move.l	#'MAGE',d0
	movem.l	d2-d7/a2-a6,-(a7)
	jsr	4(a1)
	movem.l	(a7)+,d2-d7/a2-a6
	jsr	_ClrDefault(a6)
	moveq	#0,d0
	rts



******* DBUG.library/SetPSS ************************************************
*
*   NAME
*	SetPSS -- Create ProcessorSave structure.
*
*   SYNOPSIS
*	SetPSS(PSS,Stack)
*	       a0  a1
*
*	void SetPSS(struct ProcessorSave,APTR);
*
*   FUNCTION
*	This routine initialises a ProcessorSave structure.
*	
*	When the MOD3 debugger is called with hotkey, it is not
*	possible to find the real register values for d0-d7/a0-a6.
*	therefore these registers are set zero or filled with
*	values that have a special meaning in the system. 
*	These values are documented in the main documentation.
*
*	This function does the neccessary setup.
*
*   INPUTS
*	PSS       - pointer to an empty PSS
*	Stack     - Pointer to stack, needed to find a good value for PC.
*
*   BUGS
*
*   SEE ALSO
*	LoadDebugger(), CheckDBUG().
*
****************************************************************************

SetPSS	move.l	a2,-(a7)
	lea	PSS_Adress(a0),a2
	movem.l	a5/a6/a7,5*4(a2)
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	jsr	_GetPISS(a6)
	move.l	PISS_TurboVBR(a0),a1
	adda.w	#$6c,a1
	move.l	(a1),(a2)+
	move.l	PISS_Copper(a0),(a2)+
	move.l	(a7)+,a2
	rts

******* dbug.library/StripColor0 ******************************************
*
*   NAME
*	StripColor0 -- remove all CMOVE x,Color0 from CList.
*
*   SYNOPSIS
*	StripColor0(CList)
*	            a0
*
*	void StripColor0(UWORD *);
*
*   FUNCTION
*	Replace all CMOVE x,$0180 by CMOVE x,$01fe (nop).
*	The modified copperlist will leave the background color
*	unchanged. This simplifies debugging with DEBCOL.
*	This is especially usefull when working with generated 
*	copperlists as done in the Inyerface/Broken Promisses system.
*	The copperlist must end with $fffffffe, even if you exit with
*	a copperjump. In this case you must simply add the $fffffffe.
*	Copperjumps are not processed.
*
*   INPUTS
*	CList  - Pointer to copperlist
*
*   BUGS
*
*   SEE ALSO
*
****************************************************************************

StripColor0:
	move.w	#$180,d0
	bra.s	.end
.loop	cmp.w	d0,d1
	bne.s	.nohit
	move.w	#$1fe,(a0)
.nohit	addq.l	#4,a0
.end	move.w	(a0),d1
	bpl.s	.loop
	rts

; ===================================================================

Register	ds.b	PSS_SIZEOF
Registers	ds.l	1

AboutTxt	dc.b	10,10,10
	dc.b	10,'Small System Debugger V1.3'
	dc.b	10,'(c) Dierk Ohlerich (Chaos) 1992/95'
	dc.b	10,'contact me if you want:'
	dc.b	10,'Dierk Ohlerich'
	dc.b	10,'Thuner Str. 181'
	dc.b	10,'21680 Stade'
	dc.b	10,'Germany'
	dc.b	10,'Tel. 04141/69509',0
Mem1	dc.b	10,10,'Free Memory:',0
Mem2	dc.b	10,'Default Memory:',0
Mem3	dc.b	10,'Total Memory:',0
EndMsg	dc.b	10,10,10
	dc.b	10,'Press any key to resume',10,0 
HelpTxt	dc.b	10,10,10
	dc.b	10,'Small System Debugger V1.3 Help Page'
	dc.b	10,'------------------------------------'
	dc.b	10,'a - About'
	dc.b	10,'c - Continue Demo'
	dc.b	10,'d - Monitor/Debugger'
	dc.b	10,'m - Memory Configuration'
	dc.b	10,'s - System Status (CPU+Genlock)'
	dc.b	10,'x - Exit Demo',0

DebName	dc.b	'mod3_sos',0
CpuMsg	dc.b	10,10,10,'680x0 CPU found.',10,0
BlitMsg	dc.b	'no large blits.',0
GenMsg	dc.b	'no genlock found.',10,0
AltMsg0 dc.b	10,0
AltMsg1 dc.b	'no alternating memory',10,0
AltMsg2 dc.b	'no reverse allocation',10,0
ChipMsg	dc.b	10,'ChipSet:xxx',0
MemMsg	dc.b	10,10,10,'Memory found and utilised:',0
MemMsg1	dc.b	10,'$xxxxxxxx-$'
NumTxt	dc.b	'xxxxxxxx',0
FreeTxt	dc.b	'Free Memory:$'
FreeMod	dc.b	'xxxxxxxx Bytes.',10,0
UsedTxt	dc.b	'Used Memory:$'
UsedMod	dc.b	'xxxxxxxx Bytes.',10,0
ChipTyp	dc.b	'???OCSECSAGAAAA'
