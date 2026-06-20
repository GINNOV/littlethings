
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include	numbersgame.i

	XDEF	QuerySchemeExact,QueryScheme

	XREF	_EarthBase

	XREF	CreateScheme,DeleteScheme,VerifyScheme
	XREF	CreateResult,DeleteResult
	XREF	CreateMethod,DeleteMethod

;-----------------------------------------
; method = QuerySchemeExact(scheme,number)
; d0,a0,Z                   a0     d0
;
; This function extracts the method for computing a given number
; from a given scheme, if this is possible.
;
; If it is NOT possible, then we return NULL.

QuerySchemeExact
;
; Check whether the address is valid.
;
	movem.l	d0/a0,-(sp)
	bsr	VerifyScheme
	movem.l	(sp)+,d0/a0
	beq.b	QSFail

	lea.l	-res_SIZE(sp),sp	Create (fake) result on stack
	move.l	d0,tn_Value(sp)		Set value field
	move.l	sp,a1
	BSREARTH FindTreeNode		(Attempt to) find node on tree
	move.l	d0,a0			Get value into d0 and a0
	lea.l	res_SIZE(sp),sp		Restore stack
	rts

QSFail	move.l	#0,d0
	move.l	d0,a0
	rts

;------------------------------------
; method = QueryScheme(scheme,number)
; d0,a0,Z              a0     d0
;
; This function extracts the method for computing a given number
; from a given scheme, if this is possible.
;
; If it is NOT possible, then we return the method which produces
; the closest possible value.

QueryScheme
QSRegs	reg	d2-d4/a2-a4
;
; Check whether the address is valid.
;
	movem.l	d0/a0,-(sp)
	bsr	VerifyScheme
	movem.l	(sp)+,d0/a0
	beq.b	QSFail

	movem.l	QSRegs,-(sp)
	move.l	a0,a2
	move.l	d0,d2
;
; Construct a fake result.
;
	lea.l	-res_SIZE(sp),sp	Create (fake) result on stack
	move.l	d2,tn_Value(sp)		Set value field
;
; If we were only interested in an exact match then it would have
; been sufficient to call FindTreeNode(). However, since we are
; interested in finding the closest possible match then we must be
; a bit more devious than that.
;
	lea.l	sch_TreeHeader(a2),a0
	move.l	sp,a1
	move.l	#FALSE,d0
	BSREARTH AddTreeNode		(Attempt to) add node to tree
	bne.b	QSFound			Branch if unsuccessful
;
; If we were able to add the fake node to the tree, it means that
; a node of that value did not already exist.
; Now to find the nearest match.
;
	move.l	#$80000001,d3		d3 = small number
	move.l	#$7FFFFFFF,d4		d4 = big number

	lea.l	sch_TreeHeader(a2),a0
	move.l	sp,a1
	BSREARTH TreeNodePredecessor
	tst.l	d0
	beq.b	.cont1			Branch if no lower node
	move.l	d0,a3			a3 = lower node
	move.l	tn_Value(a3),d3		d3 = value of lower node

.cont1	lea.l	sch_TreeHeader(a2),a0
	move.l	sp,a1
	BSREARTH TreeNodeSuccessor
	beq.b	.cont2			Branch if no lower node
	move.l	d0,a4			a4 = higher node
	move.l	tn_Value(a4),d4		d4 = value of higher node
;
; Now disconnect the fake node from the tree (very important).
;
.cont2	lea.l	sch_TreeHeader(a2),a0
	move.l	sp,a1
	BSREARTH RemoveTreeNode		Unlink fake node
;
; Now to determine which of the two nodes is closer.
;
QSNearest
	move.l	d2,d0
	sub.l	d3,d0
	bge.b	.cont1
	neg.l	d0			d0 = difference in lower values

.cont1	move.l	d2,d1
	sub.l	d4,d1
	bge.b	.cont2
	neg.l	d1			d1 = difference in higher values

.cont2	cmp.l	d1,d0
	blo.b	QSLower			Branch if lower node closer

QSHigher
	move.l	a4,a0
	bra.b	QSFound

QSLower	move.l	a3,a0

QSFound	move.l	a0,d0			Get return value into a0 and d0
	lea.l	res_SIZE(sp),sp		Remove fake node from stack
	movem.l	(sp)+,QSRegs
	rts
