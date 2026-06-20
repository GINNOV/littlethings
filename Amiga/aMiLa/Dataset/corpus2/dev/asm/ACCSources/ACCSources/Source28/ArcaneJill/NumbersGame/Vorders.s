
	incdir	include
	include	earth/earth.i
	include	earth/earth_lib.i
	include	libraries/arpbase.i
	include	numbersgame.i

	XDEF	EvaluateAll

	XREF	_ArpBase
	XREF	_EarthBase
	XREF	NumSeeds,SeedValues

	XREF	CreateScheme,DeleteScheme
	XREF	CreateResult,DeleteResult
	XREF	CreateMethod,DeleteMethod

;-----------------------
; scheme = EvaluateAll()
; d0,a0,Z
;
; This subroutine is the biggie.
; It evaluates ALL POSSIBLE outcomes of a given initial seed set.
;
EvaluateAll
EARegs	reg	d2-d4/a2-a4
	movem.l	EARegs,-(sp)
	lea.l	SeedValues(_data),a2	a2 = address of seed array
	move.l	NumSeeds(_data),d2	d2 = number of seeds
	move.l	d2,d4			d4 = number of seeds
	bsr	CreateScheme		Create empty scheme
	tst.l	d0
	beq	EAExit0			Abort if failed
;
; The first part of our evaluation is easy.
; We just stash the seed values
; - (they are after all results in their own right).
;
EASeeds	move.l	d0,a3			a3 = address of scheme
	lea.l	sch_Levels(a3),a4	a4 = level list
	move.l	#1,d3			d3 = bit value for first seed
	bra.b	.next

.loop	move.l	(a2)+,d0
	move.l	a3,a0
	bsr	CreateMethod		Create new method
	beq	EAExit1			Abort if failed

	move.b	d3,mth_Atoms(a0)
	asl.b	d3
	move.b	#METHOD_SEED,mth_Type(a0)
	clr.l	mth_Parent1(a0)
	clr.l	mth_Parent2(a0)

	move.l	a0,a1
	move.l	a4,a0
	ADDTAIL				Link into level list

.next	dbra	d2,.loop
;
; Now to evaluate all possible outcomes of this seed set.
;
EAResults
	move.l	#1,d3			d3 = initial level number
.loop	cmp.l	d3,d4
	beq.b	EAExit0			Exit if finished
	add.l	#1,d3			Increment level number

	move.l	a3,a0			a0 = scheme
	move.l	d3,d0			d0 = level number
	bsr	EvaluateLevel		Evaluate next level completely
	bne.b	.loop			Loop back unless there was an error
;
; If anything went wrong, we tidy up and return zero.
;
EAExit1	move.l	a3,a0
	bsr	DeleteScheme
	sub.l	a3,a3
;
; If successful, we return the address of the scheme.
;
EAExit0	move.l	a3,a0
	move.l	a0,d0
	movem.l	(sp)+,EARegs
	rts

;-----------------------------------------
; success = EvaluateLevel(scheme,levelnum)
; d0,Z                    a0     d0
;
; This function evaluates all possible results of a given level.
; (Level 1 results are the seeds themselves, level 2 results are
; results which require 2 seeds, and in general, level n results
; are results which require n seeds).
;
; At this point, we know that all lower levels have already been
; fully evaluated.

EvaluateLevel
ELRegs	reg	d2/d3-d5/a2-a3
	movem.l	ELRegs,-(sp)
	move.l	a0,a3			a3 = scheme
	move.l	d0,d2			d2 = level number
	move.l	d0,d4			d4 = level number
	move.l	d0,d5			d5 = level number
;
; Set up left and right levels such that
; left_level + right_level = current_level.
;
	asr.l	#1,d4			d4 = left level number
	sub.l	d4,d5			d5 = right level number
;
; Loop through all possible combinations of left and right levels,
; such that at all times, left_level + right_level = current_level.
;
.loop	move.l	a3,a0
	move.l	d4,d0
	move.l	d5,d1
	bsr	CombineLevels		Combine left and right levels
	beq.b	ELExit			Exit if error occured
	add.l	#1,d5
	sub.l	#1,d4
	bgt.b	.loop
;
; All done, so report success.
;
	move.l	#1,d0
ELExit	movem.l	(sp)+,ELRegs
	rts

;------------------------------------------------------------
; success = CombineLevels(scheme,leftnum,rightnum,currentnum)
; d0                      a0     d0      d1       d2
;
; This function combines two levels to create new results for
; the current level.

CombineLevels
CLRegs	reg	d2-d4/a2-a4
	movem.l	CLRegs,-(sp)
	move.l	a0,a4			a4 = address of scheme
;
; Locate the Level structures.
;
	mulu	#lev_SIZE,d0
	mulu	#lev_SIZE,d1
	mulu	#lev_SIZE,d2

	lea.l	sch_Levels-lev_SIZE(a4,d0.l),a0		a0 = left Level
	lea.l	sch_Levels-lev_SIZE(a4,d1.l),a1		a1 = right Level
	lea.l	sch_Levels-lev_SIZE(a4,d2.l),a2		a2 = current Level

	move.l	a0,d2			d2 = left level
	move.l	a1,d3			d3 = right level
	move.l	a2,d4			d4 = current level

	move.l	d2,a2			a2 = left level
;
; Test for control C here
;
	move.l	#0,d0
	move.l	#SIGBREAKF_CTRL_C,d1
	BSREXEC	SetSignal
	btst	#SIGBREAKB_CTRL_C,d0
	beq.b	CLOuterLoop
	lea.l	M_Break(pc),a0
	BSRARP	Printf
	bra.b	CLFail
;
; Cycle through all results in the left level.
;
CLOuterLoop
	move.l	MLN_SUCC(a2),a2
	tst.l	MLN_SUCC(a2)
	beq.b	CLDone			Exit if all done
;
; Cycle through all results in the right level.
;
	cmp.l	d2,d3
	bne.b	.cont		Branch unless combining level with itself
	move.l	a2,a3		In which case start from current position
	bra.b	CLInnerLoop

.cont	move.l	d3,a3
CLInnerLoop
	move.l	MLN_SUCC(a3),a3
	tst.l	MLN_SUCC(a3)
	beq.b	CLOuterLoop

	move.l	d4,a0			a0 = current level
	bsr	CombineMethods		Combine the two methods
	bne.b	CLInnerLoop		Loop back unless error occurred

CLFail	move.l	#FALSE,d0		d0 = FALSE, indicating error
	bra.b	CLExit

CLDone	move.l	#TRUE,d0		d0 = TRUE, indicating success
CLExit	movem.l	(sp)+,CLRegs
	rts

;--------------------------------------------------------------
; success = CombineMethods(leftmethod,rightmethod,scheme,level)
; d0,Z                     a2         a3          a4     d4
;
; This function combines two methods to produce a new method,
; which is then linked into the scheme.

CombineMethods
CMRegs	reg	d2-d3/d5/a2-a3
;
; First we must ask "Is it legal to combine these methods?".
;
	move.b	mth_Atoms(a2),d0
	and.b	mth_Atoms(a3),d0
	beq.b	CMLegal			Branch if so
	rts				Otherwise exit (no error).
;
; There are four possible ways to combine the methods.
; We try them all
;
CMLegal	movem.l	CMRegs,-(sp)
	move.l	#0,d2
	move.l	#0,d3
	move.w	mth_Value(a2),d2	d2 = left value
	move.w	mth_Value(a3),d3	d3 = right value

CMTrySubtract
	move.w	d2,d0
	sub.w	d3,d0			Try a subtraction
	beq.b	CMTryAdd		Ignore zero results
	bgt.b	.cont			Accept positive results
	exg.l	d2,d3
	exg.l	a2,a3			Ensure left value > right value
	neg.w	d0			d0 now positive
.cont	move.l	#METHOD_DIFFERENCE,d5
	bsr	AddNewMethod		Create method for this result
	beq.b	CMExit			Abort if error

CMTryAdd
	move.w	d2,d0
	add.w	d3,d0			Try an addition
	cmp.w	#MAX_LEGAL_VALUE,d0
	bhs.b	CMTryMultiply		Branch if result too big
	move.l	#METHOD_SUM,d5
	bsr	AddNewMethod		Create method for this result
	beq.b	CMExit			Abort if error

CMTryMultiply
	cmp.w	#1,d3
	beq.b	CMDone			Don't bother multiplying by 1
	move.l	d2,d0
	mulu	d3,d0			Try a multiplication
	cmp.l	#MAX_LEGAL_VALUE,d0
	bhs.b	CMTryDivide		Branch if result too big
	move.l	#METHOD_PRODUCT,d5
	bsr	AddNewMethod		Create method for this result
	beq.b	CMExit			Abort if error

CMTryDivide
	move.l	d2,d0
	divu	d3,d0			Try a division
	cmp.l	#MAX_LEGAL_VALUE,d0
	bhs.b	CMDone			Branch if result non-integral
	move.l	#METHOD_QUOTIENT,d5
	bsr	AddNewMethod		Create method for this result
	beq.b	CMExit			Abort if error

CMDone	move.l	#TRUE,d0		d0 = TRUE, indicating success
CMExit	movem.l	(sp)+,CMRegs
	rts

;-----------------------------------------------------------------------
; success = AddNewMethod(leftmethod,rightmethod,scheme,value,level,type)
; d0                     a2         a3          a4     d0    d4    d5
;
; This function creates a new method and links it into the scheme,
; UNLESS the method turns out to be redundant.

AddNewMethod
	move.l	a4,a0
	bsr	CreateMethod		Create structure
	beq.b	ANMExit			Abort if error
;
; Fill in the structure fields.
;
	move.b	mth_Atoms(a2),d0
	or.b	mth_Atoms(a3),d0
	move.b	d0,mth_Atoms(a0)	Set the atoms field
	move.b	d5,mth_Type(a0)		Set the type field
	move.l	a2,mth_Parent1(a0)
	move.l	a3,mth_Parent2(a0)	Set the parent methods
;
; We must now determine whether or not the result is redundant.
; The method is considered redundant if it can be constructed by an
; alternative method using the same seeds, or a subset thereof.
;
	move.l	a0,a1			a1 = current method
	move.b	d0,d1			d1 = current seeds
	not.b	d1

ANMTestRedundant
	move.l	mth_ValueNode+MLN_PRED(a1),a1	a1 = previous list node
	tst.l	MLN_PRED(a1)			Test whether list exhausted
	beq.b	ANMLink				Branch if not redundant
	lea.l	-mth_ValueNode(a1),a1		a1 = previous method

	move.b	mth_Atoms(a1),d0
	and.b	d1,d0
	bne.b	ANMTestRedundant		Loop back unless redundant
;
; If the method is redundant then we delete it.
;
ANMDelete
	movem.l	a0,-(sp)
	lea.l	mth_ValueNode(a0),a1
	REMOVE
	movem.l	(sp)+,a0
	bsr	DeleteMethod
	bra.b	ANMDone
;
; If all is well, we link the new method in.
;
ANMLink	move.l	a0,a1
	move.l	d4,a0
	ADDTAIL
;
; All done, so return success.
;
ANMDone	move.l	#TRUE,d0
ANMExit	rts

M_Break	dc.b	'*** BREAK',$A,0

