
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include	numbersgame.i

	XDEF	CreateScheme,DeleteScheme,VerifyScheme
	XDEF	CreateResult,DeleteResult
	XDEF	CreateMethod,DeleteMethod

	XREF	_EarthBase

	XREF	ResultStash
	XREF	MethodStash

;------------------------
; scheme = CreateScheme()
; d0,a0,Z

CreateScheme
CSRegs	reg	d2/a2
	movem.l	CSRegs,-(sp)
	move.l	#sch_SIZE,d0
	move.l	#MEMF_CLEAR,d1
	BSREXEC	AllocMem		Allocate memory for scheme
	tst.l	d0
	beq.b	CSExit			Abort if failed
	move.l	d0,a2			a2 = address of scheme

	move.l	a2,sch_Self(a2)
	move.l	#SCH_MAGIC,sch_MatchWord(a2)

	lea.l	sch_Hook(a2),a0		a0 = address of hook
	move.l	_EarthBase(_data),a1
	move.l	#_LVONodeValueCmp,d0
	BSREARTH InitLibraryHook	Initialise the compare hook

	lea.l	sch_TreeHeader(a2),a0
	lea.l	sch_Hook(a2),a1
	BSREARTH InitTree		Initialise the tree header

	move.l	#7*lev_SIZE,d2
.loop	lea.l	sch_Levels(a2,d2.l),a0
	NEWLIST	a0			Initialise each level
	sub.l	#lev_SIZE,d2
	bge.b	.loop

	move.l	a2,d0			d0 = scheme

CSExit	move.l	d0,a0			a0 = scheme or NULL
	movem.l	(sp)+,CSRegs
	rts

;---------------------
; DeleteScheme(scheme)
;              a0

DeleteScheme
DSRegs	reg	a2/a3
	movem.l	DSRegs,-(sp)
	move.l	a0,a3			a3 = scheme
	bsr.b	VerifyScheme
	beq.b	.cont2			Exit if invalid address given
;
; Delete the entire tree.
;
	lea.l	sch_TreeHeader(a3),a0
	lea.l	DeleteResultData(pc),a1
	move.l	_data,a2
	move.l	#ORDER_DEPTHFIRST,d0
	BSREARTH ForEachTreeNode
;
; Delete the scheme structure.
;
	move.l	a3,a1
	move.l	#sch_SIZE,d0
	BSREXEC	FreeMem
;
; Get rid of anything stashed.
;
	move.l	ResultStash(_data),d0
	beq.b	.cont1
	move.l	d0,a0
	bsr	DeleteResult
	clr.l	ResultStash(_data)

.cont1	move.l	MethodStash(_data),d0
	beq.b	.cont2
	move.l	d0,a0
	bsr	DeleteMethod
	clr.l	MethodStash(_data)

.cont2	movem.l	(sp)+,DSRegs
	rts

;---------------------
; VerifyScheme(scheme)
;              a0

VerifyScheme
VSRegs	reg	d2/a2
	movem.l	VSRegs,-(sp)
	move.l	a0,a2			a2 = scheme
;
; Make sure that the address given is even.
;
	move.w	a2,d1
	btst	#0,d1
	bne.b	VSFail			Fail if address odd
;
; Make sure that the structure is entirely in RAM.
;
	move.l	a2,a1
	BSREXEC	TypeOfMem
	move.l	d0,d2
	beq.b	VSFail			Fail if address not in RAM
	lea.l	sch_SIZE-1(a2),a1
	BSREXEC	TypeOfMem
	cmp.l	d0,d2
	bne.b	VSFail			Fail if end-of-structure
	;				is in different memory chunk
;
; It is now known to be safe to read the structure.
; Now we check its integrity.
;
	cmp.l	#SCH_MAGIC,sch_MatchWord(a2)
	bne.b	VSFail
	cmp.l	sch_Self(a2),a2
	bne.b	VSFail
VSPass	move.l	#1,d0
	bra.b	VSExit
VSFail	move.l	#0,d0
VSExit	movem.l	(sp)+,VSRegs
	rts

;------------------------------
; DeleteResultData(result,data)
;                  a0     a2

DeleteResultData
	movem.l	_data,-(sp)
	move.l	a2,_data
	bsr.b	DeleteResult
	movem.l	(sp)+,_data
	move.l	#0,d0
	rts

;-----------------------------
; result = CreateResult(value)
; d0,a0,Z               d0

CreateResult
CRRegs	reg	d2/a2
	movem.l	CRRegs,-(sp)
	move.l	d0,d2			d2 = value
	move.l	ResultStash(_data),a2	a2 = stashed structure or NULL
	clr.l	ResultStash(_data)
	move.l	a2,d0
	bne.b	CRUnstash		Branch if we have a structure stashed.

	move.l	#res_SIZE,d0
	move.l	#0,d1
	BSREXEC	AllocMem		Allocate memory for result
	tst.l	d0
	beq.b	CRExit			Abort if failed

	move.l	d0,a2			a2 = address of structure
	lea.l	res_MethodList(a2),a0
	NEWLIST	a0

CRUnstash
	move.l	a2,a0
	move.l	d2,tn_Value(a0)		Fill in value field
	move.l	a0,d0

CRExit	movem.l	(sp)+,CRRegs
	rts

;---------------------
; DeleteResult(result)
;              a0

DeleteResult
DRRegs	reg	d3/a2-a3
	movem.l	DRRegs,-(sp)
	move.l	a0,a2			a2 = result
	move.l	res_MethodList(a2),d3
.loop	move.l	d3,a3
	move.l	MLN_SUCC(a3),d3
	beq.b	.cont			Branch if list empty

	move.l	a3,a1
	REMOVE

	lea.l	-mth_ValueNode(a3),a0
	bsr	DeleteMethod
	bra.b	.loop

.cont	tst.l	ResultStash(_data)
	bne.b	DRFree
	move.l	a2,ResultStash(_data)
	bra.b	DRExit

DRFree	move.l	a2,a1
	move.l	#res_SIZE,d0
	BSREXEC FreeMem

DRExit	movem.l	(sp)+,DRRegs
	rts

;-----------------------------
; method = CreateMethod(scheme,value)
; d0,a0,Z               a0     d0

CreateMethod
CMRegs	reg	d2/a2-a4
	movem.l	CMRegs,-(sp)
	move.l	a0,a2			a2 = scheme
	move.l	d0,d2			d2 = value
;
; The first thing we do is to create a Result for this value.
;
	bsr	CreateResult		Create result
	beq.b	CMExit			Abort if failed
	move.l	d0,a3			a3 = new Result
;
; Now to add this result to the tree.
;
	lea.l	sch_TreeHeader(a2),a0	a0 = tree
	move.l	a3,a1			a1 = node
	move.l	#FALSE,d0
	BSREARTH AddTreeNode		Add node to tree
	beq.b	CMMethod		Branch if successful
;
; If the result already existed on the tree then we must delete
; the new Result and use the old one.
;
	exg.l	d0,a3			a3 = existing Result
	move.l	d0,a0			a0 = new Result
	bsr	DeleteResult		Delete the new result
;
; We now have a Result in a3.
; Here we create a Method.
;
CMMethod
	move.l	MethodStash(_data),a4	a4 = stashed structure or NULL
	clr.l	MethodStash(_data)
	move.l	a4,d0
	bne.b	CMUnstash		Branch if we have a structure stashed.

	move.l	#mth_SIZE,d0
	move.l	#0,d1
	BSREXEC	AllocMem		Allocate memory for method
	tst.l	d0
	beq.b	CMExit			Abort if failed
	move.l	d0,a4			a4 = address of structure

CMUnstash
	lea.l	res_MethodList(a3),a0
	lea.l	mth_ValueNode(a4),a1
	ADDTAIL				Add to linked list
	move.w	d2,mth_Value(a4)	Fill in value field
	move.l	a4,a0
	move.l	a0,d0

CMExit	movem.l	(sp)+,CMRegs
	rts

;---------------------
; DeleteMethod(method)
;              a0

DeleteMethod
	tst.l	MethodStash(_data)
	bne.b	DMFree
	move.l	a0,MethodStash(_data)
	rts

DMFree	move.l	a0,a1
	move.l	#mth_SIZE,d0
	BSREXEC FreeMem
	rts

