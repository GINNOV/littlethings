;
;Here comes startup module for CLI-Only asm-tools.
;
;It:
;	- preserves args in A0,D0
;	- allocates larger stack if necessary
;	- requires os 37+
;	- shows message when executed from an icon
;	- doesn't need includes
;
;Usage:
;	- include this source before your code
;	- copy/paste this source before your code
;	- include as binary before your code
;
;How to make binary version of the file (AsmOne):
;
;	- set desired minimal stack size:

MinStack	=	4000

;	- assemble
;	- type WB
;	- choose file name
;	- answer: StBegin
;	- answer: StEnd
;
;Comments:	zeeball@Interia.pl
;

StBegin:
	exg	d0,d6			;store args
	exg	a0,a3

	move.l	4.W,a6

	cmp.l	#$25,$14(a6)		;version
	bcs.s	.cont

	sub.l	a1,a1
	jsr	-$126(a6)		;FindTask

	move.l	#MinStack,d2		;minimal stack size

	move.l	d0,a0
	move.l	$3E(a0),d0		;tc_SPUpper
	sub.l	$3A(a0),d0		;tc_SPLower
	cmp.l	d2,d0
	bge.s	.cont

	move.l	d2,d0
	move.l	#$10000,d1		;Clear+Any
	jsr	-684(a6)		;AllocVec
	move.l	d0,d3
	beq.s	.cont

	lea	-12(sp),sp		;alloc SwapStackStruct
	move.l	sp,a4

	move.l	d0,(a4)			;stk_Lower
	add.l	d2,d0
	move.l	d0,4(a4)		;stk_Upper
	move.l	d0,8(a4)		;stk_Pointer
	move.l	a4,a0
	jsr	-$2DC(a6)		;StackSwap

	movem.l	d1-a6,-(sp)
	bsr.b	.cont
	movem.l	(sp)+,d1-a6

	move.l	d0,d7			;result!
	
	move.l	a4,a0
	jsr	-$2DC(a6)		;StackSwap
	
	lea	12(sp),sp		;free SwapStackStruct

	move.l	d3,a1
	jsr	-690(a6)		;FreeVec
	
	move.l	d7,d0
	rts

.cont:
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	-$126(a6)		;FindTask
	move.l	d0,a5
	tst.l	$ac(a5)
	bne.w	.continue

	lea.l	$5c(a5),a0		;MsgPort
	jsr	-$180(a6)		;WaitPort
	lea.l	$5c(a5),a0		;MsgPort
	jsr	-$174(a6)		;GetMsg
	move.l	d0,-(sp)

	lea	$17a(a6),a0		;LibList
	lea.l	.IntuiName(pc),a1	;Name
	jsr	-276(a6)		;FindName
	move.l	d0,a6

	pea.l	.SorryGad(pc)		;EasyStruct made in reverse
	pea.l	.Sorry(pc)		;order at stack area...
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#$14,d0
	move.l	d0,-(sp)

	move.l	a7,a1
	
	sub.l	a0,a0
	move.l	a0,a2
	move.l	a0,a3
	jsr	-$24c(a6)		;EasyRequestArgs

	lea.l	5*4(a7),a7		;free memory from stack...

	move.l	4.w,a6
	jsr	-$84(a6)		;Forbid
 	move.l	(sp)+,a1
	jsr	-$17a(a6)		;ReplyMsg
	moveq	#0,d0
	rts


.IntuiName:
	dc.b	"intuition.library",0
.sorry:
	dc.b	"This program is CLI only, sorry...",0
.sorryGad:
	dc.b	" OK ",0

	cnop	0,4
.continue:
	exg	d0,d6			;get args
	exg	a0,a3

StEnd:

;--------------
;your stuffs...
;
;	rts

