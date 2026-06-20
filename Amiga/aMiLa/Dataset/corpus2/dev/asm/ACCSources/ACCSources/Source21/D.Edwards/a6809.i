

* A6809 include file

* Contains the code that generates the actual machine language
* binary opcodes. All should return zero in D0 if no errors are
* encountered, else return an error code shoule be returned.

* For ALL of them, assume: 

* d0-d7/a1-a3 corrupt 

* even if this isn't the case, because the one being
* called CANNOT be guaranteed.


* First, the single-byte inherents. All follow the same plan as ABX
* for opcodes. SYNC timing handled slightly differently.


Do_ABX		moveq	#1,d0
		move.b	d0,opsize(a6)
		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1
		move.b	d1,instruction(a6)
		add.w	d0,pc_value(a6)

		cmp.b	#$13,d1		;SYNC?
		bne.s	Do_ABX_1		;skip if not
		st	timinc(a6)	;else signal '+' timing

Do_ABX_1		lea	timelist(pc),a3	;do timing
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3)+,d0		;main timing byte
		move.b	(a3),d1		;this for RTI
		move.b	d0,timing1(a6)
		move.b	d1,totime2(a6)
		moveq	#0,d0
		rts


* Push and pop instructions all handled here.


Do_PSHS		lea	instruction(a6),a2
		moveq	#2,d0
		moveq	#0,d1
		move.b	d0,opsize(a6)
		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1
		move.b	d1,(a2)+		;pop in the opcode
		move.b	pb_PSHS(a6),d2
		move.b	d2,(a2)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d1,d0
		add.l	d1,d0
		add.l	d0,a3

		move.b	(a3),timing1(a6)

* This lot creates timing byte for PSHS etc. 1 extra cycle per
* BYTE pushed/pulled.

		moveq	#0,d3
		lsr.b	#1,d2		;pushed CC?
		bcc.s	Do_PSHS_2	;no
		addq.b	#1,d3		;else +1
Do_PSHS_2	lsr.b	#1,d2		;pushed A?
		bcc.s	Do_PSHS_3	;no
		addq.b	#1,d3		;else +1
Do_PSHS_3	lsr.b	#1,d2		;pushed B?
		bcc.s	Do_PSHS_4	;no
		addq.b	#1,d3		;else +1
Do_PSHS_4	lsr.b	#1,d2		;pushed DP?
		bcc.s	Do_PSHS_5	;no
		addq.b	#1,d3		;else +1
Do_PSHS_5	lsr.b	#1,d2		;pushed X?
		bcc.s	Do_PSHS_6	;no
		addq.b	#2,d3		;else +2
Do_PSHS_6	lsr.b	#1,d2		;pushed Y?
		bcc.s	Do_PSHS_7	;no
		addq.b	#2,d3		;else +2
Do_PSHS_7	lsr.b	#1,d2		;pushed U/S?
		bcc.s	Do_PSHS_8	;no
		addq.b	#2,d3		;else +2
Do_PSHS_8	lsr.b	#1,d2		;pushed PC?
		bcc.s	Do_PSHS_9	;no
		addq.b	#2,d3		;else +2
Do_PSHS_9	move.b	d3,timing2(a6)	;save total
		
;		move.w	opcodenum(a6),d1
;		sub.w	#59,d1

		sub.b	#$34,d1			;check for
		lea	PSHS_Mask(pc),a1		;register clash
		add.w	d1,a1			;e.g. PSHS S,X
		move.b	(a1),d1			;which isn't allowed
		and.b	sucheck(a6),d1
		beq.s	Do_PSHS_1		;skip if no clash

		moveq	#_ERR_REGCLASH,d0		;else error
		rts

Do_PSHS_1	moveq	#0,d0
		rts

PSHS_Mask	dc.b	%00000010
		dc.b	%00000010
		dc.b	%00000001
		dc.b	%00000001

;PSHS_Mask	dc.b	%00000010
;		dc.b	%00000001
;		dc.b	%00000010
;		dc.b	%00000001


* This does both TFR and EXG


Do_EXG		lea	instruction(a6),a2
		moveq	#2,d0
		move.b	d0,opsize(a6)
		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1
		move.b	d1,(a2)+
		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		move.b	pb_TFR(a6),d1
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)
		and.b	#$88,d1
		move.b	d1,d2
		and.b	#$F,d2
		lsr.b	#4,d1
		eor.b	d1,d2		;test for size clash
		beq.s	Do_EXG_1

		moveq	#_ERR_SIZE,d0	;report it if so
		rts

Do_EXG_1		moveq	#0,d0
		rts


* This does CWAI on its own.


Do_CWAI		lea	instruction(a6),a2
		moveq	#2,d0
		move.b	d0,opsize(a6)
		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		st	timinc(a6)	;signal + to display
		add.w	d1,a1
		move.b	(a1),d1
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		add.w	d0,pc_value(a6)
		lsr.w	#8,d3
		tst.b	d3		;byte sized immediate operand?
		beq.s	Do_CWAI_1	;skip if so

		moveq	#_ERR_TOOBIG,d0	;else report error
		rts

Do_CWAI_1	moveq	#0,d0
		rts


* This does SWI, SWI 1, SWI 2, SWI 3.


Do_SWI		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		lea	instruction(a6),a1
		moveq	#1,d0
		move.w	operand(a6),d2
		beq.s	Do_SWI_1		;it's SWI

		cmp.w	#1,d2
		beq.s	Do_SWI_1		;it's SWI 1

		cmp.w	#2,d2
		bne.s	Do_SWI_2
		moveq	#2,d0		;here it's SWI 2
		move.b	#$10,(a1)+
		move.b	d1,(a1)
		move.b	#20,timing1(a6)
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		moveq	#0,d0
		rts

Do_SWI_2		cmp.w	#3,d2
		bne.s	Do_SWI_Err
		moveq	#2,d0		;here it's SWI 3
		move.b	#$11,(a1)+
		move.b	d1,(a1)
		move.b	#20,timing1(a6)
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		moveq	#0,d0
		rts

Do_SWI_1		move.b	d1,(a1)		;here it's SWI or SWI 1
		move.b	#19,timing1(a6)
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		moveq	#0,d0		
		rts

Do_SWI_Err	move.b	d1,(a1)		;just do SWI 1
		move.b	#19,timing1(a6)
		move.b	d0,opsize(a6)	;when error hit
		add.w	d0,pc_value(a6)

		moveq	#_ERR_SWI,d0	;else there's an error
		rts


* This code does BIT


Do_BIT		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		lea	instruction(a6),a2	;point to this

		moveq	#2,d0

		tst.b	gotargs(a6)	;got operand?
		bne.s	Do_BIT_1		;skip if so

Do_BIT_Err	move.b	d1,(a2)		;do BIT <$0
		clr.b	(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		moveq	#_ERR_MISSING,d0
		rts

Do_BIT_1		move.b	regnum(a6),d3
		cmp.b	#8,d3		;BITA?
		beq.s	Do_BIT_7
		cmp.b	#9,d3		;BITB?
		beq.s	Do_BIT_7

		bsr	Do_BIT_Err
		moveq	#_ERR_ACC,d0
		rts

Do_BIT_7		subq.b	#8,d3
		lsl.b	#6,d3
		add.b	d3,d1		;make BITA/BITB

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect bit
		bne.s	Do_BIT_2		;skip if not immediate

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_BIT_2		cmp.b	#_ADR_IND,d2	;indexed mode?
		bne.s	Do_BIT_3		;skip if not

		add.b	#$20,d1		;make indexed opcode
		bsr	MakeIndexed

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_BIT_3		cmp.b	#_ADR_DIR,d2	;direct mode?
		bne.s	Do_BIT_4		;skip if not

		add.b	#$10,d1		;make direct opcode
		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_BIT_3A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_BIT_3A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_BIT_3A	moveq	#0,d0
		rts

Do_BIT_4		cmp.b	#_ADR_EXT,d2	;extended address?
		bne.s	Do_BIT_5

		move.w	addrmode(a6),d2
		and.b	#_ADR_PTR,d2	;indirect?
		beq.s	Do_BIT_6
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0
		add.b	#$20,d1		;make indexed opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_BIT_6		add.b	#$30,d1		;make extended opcode
		moveq	#3,d0
		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_BIT_5		bsr	Do_BIT_Err
		moveq	#_ERR_ADMODE,d0
		rts


* This routine handles things such as CLR, which can take the
* forms CLRA, CLRB or CLR MM. Since it has to work for all
* opcodes taking this form, the way in which the opcode is
* obtained differs from the above routines.

* Handles: ASL, ASR, CLR, COM, DEC, INC, JMP, LSL, LSR, NEG,
*	  ROL, ROR, TST.


Do_CLR		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		lea	instruction(a6),a2	;point to this

		tst.b	gotargs(a6)	;got args?
		beq	Do_CLR_1		;nope, so skip

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect flag

		cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_CLR_3		;no

		add.b	#$60,d1		;create indexed opcode
		moveq	#2,d0
		bsr	MakeIndexed
		move.b	d0,opsize(a6)	;no of bytes
		add.w	d0,pc_value(a6)	;new PC

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_CLR_3		cmp.b	#_ADR_EXT,d2	;extended?
		bne.s	Do_CLR_4

		add.b	#$70,d1		;make extended opcode
		moveq	#3,d0		;no of bytes
		move.w	addrmode(a6),d3
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_CLR_3a	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;this no of bytes instead
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		sub.b	#$10,d1		;make indexed opcode
		move.b	d1,(a2)+		;opcode
		move.b	#$9F,(a2)+	;indirect postbyte
		move.w	operand(a6),d3
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CLR_3a	move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CLR_4		cmp.b	#_ADR_DIR,d2	;direct mode?
		bne.s	Do_CLR_5		;skip if not

		moveq	#2,d0		;no of bytes
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_CLR_4A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_CLR_4A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_CLR_4A	moveq	#0,d0
		rts

Do_CLR_5		moveq	#_ERR_ADMODE,d0	;error if here
		rts

Do_CLR_1		cmp.b	#$0E,d1		;JMP?
		beq.s	Do_CLR_6		;handle separately if so

		moveq	#1,d0		;no of bytes
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		move.b	regnum(a6),d0	;get register
		cmp.b	#8,d0		;A?
		beq.s	Do_CLR_2		;ok if so
		cmp.b	#9,d0		;B?
		beq.s	Do_CLR_2		;ok if so

		moveq	#_ERR_ACC,d0
		rts

Do_CLR_2		subq.b	#8,d0		;make 0 or 1
		lsl.b	#4,d0		;* 16
		add.b	d0,d1
		add.b	#$40,d1
		move.b	d1,(a2)		;create opcode

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;signal all's well
		rts

Do_CLR_6		moveq	#3,d0		;here handle illegal

		move.b	d0,opsize(a6)	;JMP inherent
		add.w	d0,pc_value(a6)

		move.b	#$6E,d1
		move.b	d1,(a2)+
		clr.b	(a2)+
		clr.b	(a2)+

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ADMODE,d0
		rts


* This handles BRA/BSR and LBRA/LBSR etc.


Do_BRA		moveq	#2,d0		;opcode size

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		cmp.b	#2,pass(a6)	;Pass 2?
		beq.s	Do_BRA_6		;skip if so

		moveq	#0,d2		;else pseudo-branch
		bra.s	Do_BRA_2

Do_BRA_6		move.w	operand(a6),d2	;branch
		sub.w	pc_value(a6),d2
		subq.w	#2,d2		;create relative offset

		bpl.s	Do_BRA_1		;skip if positive

		move.w	d2,d3
		neg.w	d3
		and.w	#$FF00,d3	;long branch?
		beq.s	Do_BRA_2		;skip if not

Do_BRA_3		tst.w	longopcode(a6)	;specified long branch?
		bne.s	Do_BRA_5		;skip if so

		move.b	d0,opsize(a6)	;generate opcode anyway
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.b	d2,(a2)+

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_LBRA,d0	;then signal error
		rts

Do_BRA_1		move.w	d2,d3
		and.w	#$FF00,d3	;long branch?
		bne.s	Do_BRA_3		;skip back if long

Do_BRA_2		tst.w	longopcode(a6)	;user WANTS long branch anyway?
		beq	Do_BRA_4		;skip if not

Do_BRA_5		cmp.b	#$20,d1		;LBRA?
		bne.s	Do_BRA_7

		moveq	#$16,d1		;true LBRA
		moveq	#3,d0		;true opcode size
		subq.w	#1,d2		;true branch
		bra.s	Do_BRA_9		;and continue

Do_BRA_7		cmp.b	#$8D,d1		;LBSR?
		bne.s	Do_BRA_8

		moveq	#$17,d1		;true LBSR
		moveq	#3,d0		;true opcode size
		subq.w	#1,d2		;true branch
		bra.s	Do_BRA_9		;and continue

Do_BRA_8		moveq	#4,d0		;else this is opcode size
		subq.w	#2,d2		;true branch

		moveq	#_ADR_LREL,d3
		move.w	d3,addrmode(a6)	;for timing later
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	#$10,(a2)+	;$10 prebyte
		move.b	d1,(a2)+		;branch opcode
		move.b	d2,1(a2)		;LOW byte of operand
		lsr.w	#8,d2
		move.b	d2,(a2)		;HIGH byte of operand

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3)+,d2
		move.b	(a3)+,timing1(a6)
		move.b	(a3)+,totime2(a6)

		moveq	#0,d0		;all's well
		rts

Do_BRA_9		moveq	#_ADR_LREL,d3
		move.w	d3,addrmode(a6)	;for timing later
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+		;LBRA/LBSR opcode
		move.b	d2,1(a2)		;LOW byte of operand
		lsr.w	#8,d2
		move.b	d2,(a2)		;HIGH byte of operand

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3)+,d2
		move.b	(a3)+,timing1(a6)
		move.b	(a3)+,totime2(a6)

		moveq	#0,d0
		rts

Do_BRA_4		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.b	d2,(a2)+

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3)+,timing1(a6)

		moveq	#0,d0
		rts


* This code performs ADC, ADD and the like.


Do_ADC		moveq	#2,d0		;no of bytes

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		move.w	addrmode(a6),d2	;check address mode
		and.b	#$7F,d2		;mask off indirect bit

		cmp.w	#_ADR_IND,d2	;indexed?
		bne.s	Do_ADC_1		;skip if not

		add.b	#$20,d1		;create indexed opcode byte

		move.b	regnum(a6),d2	;get register number
		bne.s	Do_ADC_R1	;skip if not D

		cmp.b	#$AB,d1		;ADDD?
		beq.s	Do_ADC_R4	;do it if so

		cmp.b	#$A0,d1		;SUBD?
		beq.s	Do_ADC_R21	;do it if so

		bra.s	Do_ADC_R3	;else do ...A ,X etc + error

Do_ADC_R4	add.b	#$38,d1		;make ADDD opcode
		bra.s	Do_ADC_R2

Do_ADC_R21	addq.b	#3,d1		;make SUBD opcode
		bra.s	Do_ADC_R2

Do_ADC_R1	cmp.b	#8,d2
		beq.s	Do_ADC_R2	;skip if A

		cmp.b	#9,d2
		bne.s	Do_ADC_R3	;skip if not B

		add.b	#$40,d1		;make ...B opcode
		bra.s	Do_ADC_R2

Do_ADC_R3	bsr	MakeIndexed	;create whole opcode

		move.b	d0,opsize(a6)	;instruction size
		add.w	d0,pc_value(a6)	;new PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ACC,d0	;signal error
		rts

Do_ADC_R2	bsr	MakeIndexed	;create whole opcode

		move.b	d0,opsize(a6)	;instruction size
		add.w	d0,pc_value(a6)	;new PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0		;signal all's well
		move.w	d5,d0		;indexed mode error code
		rts

Do_ADC_1		tst.w	d2		;immediate operand?

;		cmp.w	#_ADR_IMM,d2	;immediate?

		bne	Do_ADC_2		;skip if not

		move.w	operand(a6),d3	;get immediate operand

		move.b	regnum(a6),d2	;get register number
		bne.s	Do_ADC_R5	;skip if not D

		cmp.b	#$8B,d1		;ADDD?
		bne.s	Do_ADC_R8	;skip if not

		add.b	#$38,d1		;make ADDD opcode
		bra.s	Do_ADC_R6	;and form instruction

Do_ADC_R8	cmp.b	#$80,d1		;SUBD?
		bne.s	Do_ADC_R7	;skip if not

		addq.b	#3,d1		;make SUBD opcode
		bra.s	Do_ADC_R6	;and form instruction

Do_ADC_R5	cmp.b	#8,d2
		beq.s	Do_ADC_R6	;skip if A

		cmp.b	#9,d2
		bne.s	Do_ADC_R9	;skip if not B

		add.b	#$40,d1		;make ...B opcode
		bra.s	Do_ADC_R6

Do_ADC_R9	cmp.b	#10,d2		;is it CC?
		bne.s	Do_ADC_R7	;skip to error if not

		cmp.b	#$84,d1		;AND?
		bne.s	Do_ADC_R10	;skip if not
		move.b	#$1C,d1		;make it ANDCC
		bra.s	Do_ADC_R6	;and execute

Do_ADC_R10	cmp.b	#$8A,d1		;OR?
		bne.s	Do_ADC_R7	;skip to error if not
		move.b	#$1A,d1		;make it ORCC
		bra.s	Do_ADC_R6	;and execute

Do_ADC_R7	move.b	d1,(a2)+		;make it ADCA #0 etc
		clr.b	(a2)

		move.b	d0,opsize(a6)	;instruction size
		add.w	d0,pc_value(a6)	;new PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ACC,d0	;signal error
		rts

Do_ADC_R6	tst.b	d2		;ADDD etc?
		beq.s	Do_ADC_3		;skip if so

		move.b	d1,(a2)+		;make opcode
		move.b	d3,(a2)		;save operand byte

		move.b	d0,opsize(a6)	;instruction size
		add.w	d0,pc_value(a6)	;new PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;signal all's well
		rts

Do_ADC_3		moveq	#3,d0		;it's an ADDD/SUBD

		move.b	d1,(a2)+		;do opcode
		move.b	d3,1(a2)		;operand LOW byte here
		lsr.w	#8,d3
		move.b	d3,(a2)		;operand HIGH byte here

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;signal all's well
		rts

Do_ADC_2		cmp.w	#_ADR_DIR,d2	;direct mode operand?
		bne	Do_ADC_4		;skip if not

		move.w	operand(a6),d3	;get operand
		add.b	#$10,d1		;make direct mode opcode

		move.b	regnum(a6),d2	;check which reg
		beq.s	Do_ADC_R11	;it's D-skip

		cmp.b	#8,d2
		beq.s	Do_ADC_R12	;it's A-skip

		cmp.b	#9,d2
		bne.s	Do_ADC_R13	;skip if not B

		add.b	#$40,d1		;else make ADCB etc
		bra.s	Do_ADC_R12	;& do it

Do_ADC_R11	cmp.b	#$9B,d1		;is it ADDD?
		beq.s	Do_ADC_R14	;skip if so
		cmp.b	#$90,d1		;is it SUBD?
		beq.s	Do_ADC_R19	;skip if so

Do_ADC_R13	move.b	d0,opsize(a6)	;make it ADCA <$0
		add.w	d0,pc_value(a6)	;plus error code

		move.b	d1,(a2)+
		clr.b	(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ACC,d0
		rts


Do_ADC_R12	move.b	d0,opsize(a6)	;normal ADC type here
		add.w	d0,pc_value(a6)

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ADC_R12A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ADC_R12A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ADC_R12A	moveq	#0,d0
		rts

Do_ADC_R19	addq.b	#3,d1		;make SUBD
		bra.s	Do_ADC_R20	;and form instruction

Do_ADC_R14	add.b	#$38,d1		;make ADDD

Do_ADC_R20	move.b	d0,opsize(a6)	;here do xxxA/B/D <nnn
		add.w	d0,pc_value(a6)

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ADC_R20A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ADC_R20A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ADC_R20A	moveq	#0,d0
		rts

Do_ADC_4		cmp.w	#_ADR_EXT,d2	;Extended address?
		bne	Do_ADC_5		;skip if not

		moveq	#3,d0
		move.w	operand(a6),d3

		move.w	operand(a6),d3	;get operand
		add.b	#$30,d1		;make direct mode opcode

		move.b	regnum(a6),d2	;check which reg
		beq.s	Do_ADC_R15	;it's D-skip

		cmp.b	#8,d2
		beq.s	Do_ADC_R16	;it's A-skip

		cmp.b	#9,d2
		bne.s	Do_ADC_R17	;skip if not B

		add.b	#$40,d1		;else make ADCB etc
		bra.s	Do_ADC_R16	;& do it

Do_ADC_R15	cmp.b	#$BB,d1		;is it ADDD?
		beq	Do_ADC_R18	;skip if so
		cmp.b	#$B0,d1		;is it SUBD?
		beq	Do_ADC_R23	;skip if so

Do_ADC_R17	move.b	d0,opsize(a6)	;make it ADCA >$0
		add.w	d0,pc_value(a6)	;plus error code

		move.b	d1,(a2)+
		clr.b	(a2)
		clr.b	(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ACC,d0
		rts

Do_ADC_R16	move.w	addrmode(a6),d2	;check for ext. indirect
		and.b	#_ADR_PTR,d2
		beq.s	Do_ADC_R24	;skip if not indirect
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0
		sub.b	#$10,d1		;make indexed opcode

		move.b	d0,opsize(a6)	;normal ADC type here
		add.w	d0,pc_value(a6)

		move.b	d1,(a2)+		;opcode
		move.b	#$9F,(a2)+	;ext. ind postbyte
		move.b	d3,1(a2)		;then address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ADC_R24	move.b	d0,opsize(a6)	;normal ADC type here
		add.w	d0,pc_value(a6)

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ADC_R18	add.b	#$38,d1		;make ADDD
		bra.s	Do_ADC_R22

Do_ADC_R23	addq.b	#3,d1		;make SUBD

Do_ADC_R22	move.w	addrmode(a6),d2
		and.b	#_ADR_PTR,d2	;check for indirect
		beq.s	Do_ADC_R25	;skip if not

		addq.b	#1,d0		;1 more byte
		sub.b	#$10,d1		;make indexed opcode

		move.b	d1,(a2)+		;ADDD/SUBD indexed
		move.b	#$9F,(a2)+	;ext. indirect postbyte
		move.b	d3,1(a2)		;operand HIGH byte
		lsr.w	#8,d3
		move.b	d3,(a2)		;operand LOW byte

		move.b	#5,timing2(a6)	;create timing addon

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ADC_R25	move.b	d0,opsize(a6)	;here do xxxA/B/D >nnn
		add.w	d0,pc_value(a6)

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ADC_5		move.b	d0,opsize(a6)	;here illegal addr mode
		add.w	d0,pc_value(a6)	;just do xxxA #0

		move.b	d1,(a2)+
		clr.b	(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ADMODE,d0	;and error exit

		rts


* Here handle JSR on its own


Do_JSR		moveq	#2,d0		;no of bytes

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		move.w	addrmode(a6),d2	;check address mode
		and.b	#$7F,d2		;mask off indirect bit

		cmp.w	#_ADR_IND,d2	;indexed?
		bne.s	Do_JSR_1		;skip if not

		add.b	#$20,d1		;create indexed opcode byte
		bsr	MakeIndexed
		move.b	d0,opsize(a6)	;no of bytes
		add.w	d0,pc_value(a6)	;new PC

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_JSR_1		cmp.b	#_ADR_EXT,d2	;extended?
		bne.s	Do_JSR_2		;skip if not

		add.b	#$30,d1		;make extended opcode
		moveq	#3,d0		;no of bytes
		move.w	addrmode(a6),d3
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_JSR_3a	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;this no of bytes instead
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		sub.b	#$10,d1		;make indexed opcode
		move.b	d1,(a2)+		;opcode
		move.b	#$9F,(a2)+	;indirect postbyte
		move.w	operand(a6),d3
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_JSR_3a	move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_JSR_2		cmp.b	#_ADR_DIR,d2	;direct?
		bne.s	Do_JSR_3		;skip if not

		add.b	#$10,d1		;make direct opcode
		moveq	#2,d0		;no of bytes
		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_JSR_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_JSR_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_JSR_2A	moveq	#0,d0
		rts

Do_JSR_3		moveq	#3,d0		;here if illegal JSR
		move.b	d0,opsize(a6)	;address mode
		add.w	d0,pc_value(a6)
		move.b	#$7E,d1
		move.b	d1,(a2)+
		move.w	operand(a6),d3
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_ADMODE,d0	;error if here
		rts


* This code handles LD.


Do_LD		moveq	#2,d0		;instruction size

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		tst.b	gotargs(a6)	;any operand?
		bne.s	Do_LD_1		;skip if so

Do_LD_Err	move.b	d0,opsize(a6)	;just generate LDA <$0
		add.w	d0,pc_value(a6)	;and exit with error

		move.b	d1,(a2)+
		clr.b	(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_MISSING,d0
		rts

Do_LD_1		move.b	regnum(a6),d2	;get register #
		bne	Do_LD_2		;not D-skip

		add.b	#$46,d1		;create LDD

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		bne.s	Do_LD_1_1	;skip if not immediate

		moveq	#3,d0		;no of bytes
		move.w	operand(a6),d3

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,1(a2)		;then operand HIGH byte
		lsr.w	#8,d3
		move.b	d3,(a2)		;then operand LOW byte

		move.b	d0,opsize(a6)	;update assembler
		add.w	d0,pc_value(a6)	;PC etc

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)	;get timing

		moveq	#0,d0
		rts

Do_LD_1_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_LD_1_2

		add.b	#$20,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LD_1_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_LD_1_3

		add.b	#$10,d1		;create direct opcode
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_LD_1_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_LD_1_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_LD_1_2A	moveq	#0,d0
		rts

Do_LD_1_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_LD_1_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_LD_1_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$20,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_1_4	moveq	#3,d0		;new opcode size
		add.b	#$30,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_1_5	bsr	Do_LD_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_LD_2		cmp.b	#1,d2		;X?
		bne	Do_LD_3		;skip if not

Do_LD_2A		addq.b	#8,d1		;create LDX

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		bne.s	Do_LD_2_1	;skip if not immediate

		moveq	#3,d0
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_2_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_LD_2_2

		add.b	#$20,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LD_2_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_LD_2_3

		add.b	#$10,d1		;create direct opcode
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_LD_2_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_LD_2_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_LD_2_2A	moveq	#0,d0
		rts

Do_LD_2_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_LD_2_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_LD_2_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$20,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_2_4	moveq	#3,d0		;new opcode size
		add.b	#$30,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_2_5	bsr	Do_LD_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_LD_3		cmp.b	#2,d2		;Y?
		bne.s	Do_LD_4		;skip if not

		bsr	Do_LD_2A		;do code for LDX

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_LD_3_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_LD_3_1

		move.b	#$10,(a2)	;put in $10 prebyte
		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)

		addq.b	#1,timing1(a6)	;update timing too

		tst.w	d0
		rts

Do_LD_4		cmp.b	#3,d2		;U?
		bne	Do_LD_5		;skip if not

Do_LD_4A		add.b	#$48,d1		;create LDU

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		bne.s	Do_LD_4_1	;skip if not immediate

		moveq	#3,d0
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_4_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_LD_4_2

		add.b	#$20,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LD_4_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_LD_4_3

		add.b	#$10,d1		;create direct opcode
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_LD_4_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_LD_4_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_LD_4_2A	moveq	#0,d0
		rts

Do_LD_4_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_LD_4_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_LD_4_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$20,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_4_4	moveq	#3,d0		;new opcode size
		add.b	#$30,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_4_5	bsr	Do_LD_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_LD_5		cmp.b	#4,d2		;S?
		bne.s	Do_LD_6		;skip if not

		bsr	Do_LD_4A		;do code for LDU

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_LD_5_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_LD_5_1

		move.b	#$10,(a2)	;put in $10 prebyte
		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)

		addq.b	#1,timing1(a6)	;update timing too

		tst.w	d0
		rts

Do_LD_6		cmp.b	#8,d2		;A?
		bne	Do_LD_7		;skip if not

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		bne.s	Do_LD_6_1	;skip if not immediate

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_6_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_LD_6_2

		add.b	#$20,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LD_6_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_LD_6_3

		add.b	#$10,d1		;create direct opcode
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_LD_6_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_LD_6_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_LD_6_2A	moveq	#0,d0
		rts

Do_LD_6_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_LD_6_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_LD_6_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$20,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_6_4	moveq	#3,d0		;new opcode size
		add.b	#$30,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_6_5	bsr	Do_LD_Err
		moveq	#_ERR_ADMODE,d0
		rts


Do_LD_7		cmp.b	#9,d2		;B?
		bne	Do_LD_8		;skip if not

		add.b	#$40,d1		;create LDB

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		bne.s	Do_LD_7_1	;skip if not immediate

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_7_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_LD_7_2

		add.b	#$20,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LD_7_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_LD_7_3

		add.b	#$10,d1		;create direct opcode
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_LD_7_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_LD_7_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_LD_7_2A	moveq	#0,d0
		rts

Do_LD_7_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_LD_7_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_LD_7_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$20,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_7_4	moveq	#3,d0		;new opcode size
		add.b	#$30,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_LD_7_5	bsr	Do_LD_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_LD_8		bsr	Do_LD_Err
		moveq	#_ERR_ACC,d0
		rts


* This code handles ST.


Do_ST		moveq	#2,d0		;instruction size

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		tst.b	gotargs(a6)	;any operand?
		bne.s	Do_ST_1		;skip if so

Do_ST_Err	move.b	d0,opsize(a6)	;just generate STA <$0
		add.w	d0,pc_value(a6)	;and exit with error

		move.b	d1,(a2)+
		clr.b	(a2)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_MISSING,d0
		rts

Do_ST_1		move.b	regnum(a6),d2	;get register #
		bne	Do_ST_2		;not D-skip

		add.b	#$46,d1		;create STD

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		beq	Do_ST_1_5	;error if immediate

Do_ST_1_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_ST_1_2

		add.b	#$10,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_ST_1_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_ST_1_3	;skip if not

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ST_1_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ST_1_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ST_1_2A	moveq	#0,d0
		rts

Do_ST_1_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_ST_1_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_ST_1_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$10,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_1_4	moveq	#3,d0		;new opcode size
		add.b	#$20,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_1_5	bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_ST_2		cmp.b	#1,d2		;X?
		bne	Do_ST_3		;skip if not

Do_ST_2A		addq.b	#8,d1		;create STX

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		beq	Do_ST_2_5	;error if immediate

Do_ST_2_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_ST_2_2

		add.b	#$10,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_ST_2_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_ST_2_3	;skip if not

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ST_2_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ST_2_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ST_2_2A	moveq	#0,d0
		rts

Do_ST_2_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_ST_2_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_ST_2_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$10,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_2_4	moveq	#3,d0		;new opcode size
		add.b	#$20,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_2_5	bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_ST_3		cmp.b	#2,d2		;Y?
		bne.s	Do_ST_4		;skip if not

		bsr	Do_ST_2A		;do code for STX

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_ST_3_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_ST_3_1

		move.b	#$10,(a2)	;put in $10 prebyte
		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)

		addq.b	#1,timing1(a6)	;and update timing too

		tst.w	d0
		rts

Do_ST_4		cmp.b	#3,d2		;U?
		bne	Do_ST_5		;skip if not

Do_ST_4A		add.b	#$48,d1		;create STU

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		beq	Do_ST_4_5	;error if immediate

Do_ST_4_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_ST_4_2

		add.b	#$10,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_ST_4_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_ST_4_3	;skip if not

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ST_4_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ST_4_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ST_4_2A	moveq	#0,d0
		rts

Do_ST_4_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_ST_4_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_ST_4_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$10,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_4_4	moveq	#3,d0		;new opcode size
		add.b	#$20,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_4_5	bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_ST_5		cmp.b	#4,d2		;S?
		bne.s	Do_ST_6		;skip if not

		bsr	Do_ST_4A		;do code for STU

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_ST_5_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_ST_5_1

		move.b	#$10,(a2)	;put in $10 prebyte
		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)

		addq.b	#1,timing1(a6)	;and update timing too

		tst.w	d0
		rts


Do_ST_6		cmp.b	#8,d2		;A?
		bne	Do_ST_7		;skip if not

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		beq	Do_ST_6_5	;error if immediate

Do_ST_6_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_ST_6_2

		add.b	#$10,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_ST_6_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_ST_6_3	;skip if not

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ST_6_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ST_6_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ST_6_2A	moveq	#0,d0
		rts

Do_ST_6_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_ST_6_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_ST_6_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$10,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_6_4	moveq	#3,d0		;new opcode size
		add.b	#$20,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_6_5	bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_ST_7		cmp.b	#9,d2		;B?
		bne	Do_ST_8		;skip if not

		add.b	#$40,d1		;create STB

		move.w	addrmode(a6),d3	;get address mode
		and.b	#$7F,d3		;mask off indirect bit

		beq	Do_ST_7_5	;error if immediate

Do_ST_7_1	cmp.b	#_ADR_IND,d3	;indexed mode?
		bne.s	Do_ST_7_2

		add.b	#$10,d1		;create indexed opcode
		bsr	MakeIndexed	;create full indexed instruction

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_ST_7_2	cmp.b	#_ADR_DIR,d3	;direct mode?
		bne.s	Do_ST_7_3	;skip if not

		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d3		;check high byte
		beq.s	Do_ST_7_2A	;zero so OK
		cmp.b	dpage(a6),d3	;matches direct page?
		beq.s	Do_ST_7_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_ST_7_2A	moveq	#0,d0
		rts

Do_ST_7_3	cmp.b	#_ADR_EXT,d3	;extended mode?
		bne	Do_ST_7_5	;skip if not

		move.w	addrmode(a6),d3	;final check
		and.b	#_ADR_PTR,d3	;indirect?
		beq.s	Do_ST_7_4	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		moveq	#4,d0		;new instuction size
		move.w	operand(a6),d3
		add.b	#$10,d1		;create indexed opcode
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+	;create ext. ind postbyte
		move.b	d3,1(a2)		;append address operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_7_4	moveq	#3,d0		;new opcode size
		add.b	#$20,d1		;new extended opcode

		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_ST_7_5	bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_ST_8		bsr	Do_ST_Err
		moveq	#_ERR_ACC,d0
		rts


* This code performs LEA


Do_LEA		moveq	#2,d0		;instruction size

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		tst.b	gotargs(a6)	;any operand?
		bne.s	Do_LEA_1		;skip if so

Do_LEA_Err	move.b	d1,(a2)+		;do LEAX ,X then
		move.b	#$84,(a2)	;exit with error

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_MISSING,d0
		rts

Do_LEA_1		move.b	regnum(a6),d2	;get register
		cmp.b	#1,d2		;exit with error
		bcs.s	Do_LEA_Err	;if reg no in range
		cmp.b	#4,d2		;X,Y,U,S
		bhi.s	Do_LEA_Err

		subq.b	#1,d2
		add.b	d2,d1		;create LEAr opcode

		move.w	addrmode(a6),d2
		and.b	#$7F,d2

		cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_LEA_2		;skip if not

		bsr	MakeIndexed

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_LEA_2		cmp.b	#_ADR_EXT,d2	;extended?
		bne.s	Do_LEA_3		;error if not

		move.w	addrmode(a6),d2
		and.b	#_ADR_PTR,d2	;indirect?
		beq.s	Do_LEA_3		;error if not

		moveq	#4,d0
		move.w	operand(a6),d3
		move.b	d1,(a2)+
		move.b	#$9F,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d0
		addq.b	#5,d0		;make timing addon for [...]
		move.b	d0,timing1(a6)

		moveq	#0,d0
		rts
		
Do_LEA_3		bsr	Do_ST_Err
		moveq	#_ERR_ADMODE,d0
		rts


* This code performs CMP


Do_CMP		moveq	#2,d0		;instruction size

		lea	instruction(a6),a2

		lea	opbases(pc),a1
		move.w	opcodenum(a6),d1
		sub.w	#_1ST_OPCODE,d1
		add.w	d1,a1
		move.b	(a1),d1		;get base opcode

		tst.b	gotargs(a6)	;any operand?
		bne.s	Do_CMP_1		;skip if so

Do_CMP_Err	move.b	d1,(a2)+		;do CMPA <$0 then
		clr.b	(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#_ERR_MISSING,d0
		rts

Do_CMP_1		move.b	regnum(a6),d2	;get which register

		bne	Do_CMP_2		;skip if not CMPD

Do_CMP_1A	addq.b	#2,d1		;make CMPD opcode

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect bit
		bne.s	Do_CMP_1_1	;skip if not immediate

		moveq	#4,d0
		move.w	operand(a6),d3

		move.b	#$10,(a2)+	;pop in $10 prebyte
		move.b	d1,(a2)+		;pop in opcode (act. SUBD)
		move.b	d3,1(a2)		;and immediate operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)	;set instruction size
		add.w	d0,pc_value(a6)	;and update PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d1		;do this because CMPD is
		addq.b	#1,d1		;1 cycle longer than the
		move.b	d1,timing1(a6)	;SUBD it's derived from

		moveq	#0,d0		;no error
		rts

Do_CMP_1_1	cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_CMP_1_2	;skip if not

		add.b	#$20,d1		;make indexed opcode
		bsr	MakeIndexed	;and handle it

		lea	instruction(a6),a2
		moveq	#0,d2
		move.b	d0,d2		;no of bytes to shuffle along
		add.w	d2,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_CMP_1_5	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d2
		bne.s	Do_CMP_1_5

		move.b	#$10,(a2)	;put in $10 prebyte
		addq.b	#1,d0

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d1		;do this because CMPD is
		addq.b	#1,d1		;1 cycle longer than the
		move.b	d1,timing1(a6)	;SUBD it's derived from

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_CMP_1_2	cmp.b	#_ADR_DIR,d2	;direct addressing?
		bne.s	Do_CMP_1_3	;skip if not

		add.b	#$10,d1		;make direct opcode
		moveq	#3,d0		;instruction size
		move.w	operand(a6),d2

		move.b	#$10,(a2)+	;pop in $10 prebyte
		move.b	d1,(a2)+		;then opcode
		move.b	d2,(a2)+		;then operand

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d1		;do this because CMPD is
		addq.b	#1,d1		;1 cycle longer than the
		move.b	d1,timing1(a6)	;SUBD it's derived from

		lsr.w	#8,d2		;check high byte
		beq.s	Do_CMP_1_2A	;zero so OK
		cmp.b	dpage(a6),d2	;matches direct page?
		beq.s	Do_CMP_1_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_CMP_1_2A	moveq	#0,d0
		rts

Do_CMP_1_3	cmp.b	#_ADR_EXT,d2	;extended addressing?
		bne	Do_CMP_1_4	;skip if not

		move.w	addrmode(a6),d2
		and.b	#_ADR_PTR,d2	;indirect?
		beq.s	Do_CMP_1_6	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		add.b	#$20,d1		;make indexed opcode
		moveq	#5,d0		;instruction size
		move.w	operand(a6),d3
		move.b	#$10,(a2)+	;pop in prebyte
		move.b	d1,(a2)+		;then opcode
		move.b	#$9F,(a2)+	;then indirect postbyte
		move.b	d3,1(a2)		;then memory address
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d1		;do this because CMPD is
		addq.b	#1,d1		;1 cycle longer than the
		move.b	d1,timing1(a6)	;SUBD it's derived from

		moveq	#0,d0
		rts

Do_CMP_1_6	add.b	#$30,d1		;make extended opcode
		moveq	#4,d0		;this many bytes
		move.w	operand(a6),d3

		move.b	#$10,(a2)+	;pop in $10 prebyte
		move.b	d1,(a2)+		;then opcode
		move.b	d3,1(a2)		;then memory
		lsr.w	#8,d3		;address
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),d1		;do this because CMPD is
		addq.b	#1,d1		;1 cycle longer than the
		move.b	d1,timing1(a6)	;SUBD it's derived from

		moveq	#0,d0
		rts

Do_CMP_1_4	bsr	Do_CMP_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_CMP_2		cmp.b	#1,d2
		bne	Do_CMP_3		;skip if not CMPX

Do_CMP_2A	add.b	#$0B,d1		;make CMPX opcode

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect bit
		bne.s	Do_CMP_2_1	;skip if not immediate

		moveq	#3,d0
		move.w	operand(a6),d3

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,1(a2)		;and immediate operand
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)	;set instruction size
		add.w	d0,pc_value(a6)	;and update PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;no error
		rts

Do_CMP_2_1	cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_CMP_2_2	;skip if not

		add.b	#$20,d1		;make indexed opcode
		bsr	MakeIndexed	;and handle it

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_CMP_2_2	cmp.b	#_ADR_DIR,d2	;direct addressing?
		bne.s	Do_CMP_2_3	;skip if not

		add.b	#$10,d1		;make direct opcode
		move.w	operand(a6),d2

		move.b	d1,(a2)+		;pop in opcode
		move.b	d2,(a2)+		;and address

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d2		;check high byte
		beq.s	Do_CMP_2_2A	;zero so OK
		cmp.b	dpage(a6),d2	;matches direct page?
		beq.s	Do_CMP_2_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_CMP_2_2A	moveq	#0,d0
		rts

Do_CMP_2_3	cmp.b	#_ADR_EXT,d2	;extended addressing?
		bne.s	Do_CMP_2_4	;skip if not

		move.w	addrmode(a6),d2	;indirect?
		and.b	#_ADR_PTR,d2
		beq.s	Do_CMP_2_5	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		move.w	operand(a6),d3
		add.b	#$20,d1		;make indexed opcode
		moveq	#4,d0		;instruction size
		move.b	d1,(a2)+		;pop in opcode
		move.b	#$9F,(a2)+	;then indirect postbyte
		move.b	d3,1(a2)		;then memory address
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_2_5	add.b	#$30,d1		;make extended opcode
		moveq	#3,d0		;this many bytes
		move.w	operand(a6),d3

		move.b	d1,(a2)+		;opcode
		move.b	d3,1(a2)
		lsr.w	#8,d3		;then memory
		move.b	d3,(a2)		;address

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_2_4	bsr	Do_CMP_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_CMP_3		cmp.b	#2,d2
		bne.s	Do_CMP_4		;skip if not CMPY

		bsr	Do_CMP_2A	;do code for CMPX

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1	;no of bytes to shuffle along
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_CMP_3_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_CMP_3_1

		move.b	#$10,(a2)	;put in $10 prebyte

		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)
		addq.b	#1,timing1(a6)	;and update timing too

		tst.w	d0
		rts

Do_CMP_4		cmp.b	#3,d2
		bne.s	Do_CMP_5		;skip if not CMPU

		move.l	a2,-(sp)		;save pointer
		bsr	Do_CMP_1A	;do opcode for CMPD
		move.l	(sp)+,a2
		move.b	#$11,(a2)	;change the prebyte
		tst.w	d0		;all done
		rts

Do_CMP_5		cmp.b	#4,d2
		bne.s	Do_CMP_6		;skip if not CMPS

		bsr	Do_CMP_2A	;do code for CMPX

		lea	instruction(a6),a2
		moveq	#0,d1
		move.b	opsize(a6),d1	;no of bytes to shuffle along
		add.w	d1,a2
		move.l	a2,a3
		addq.l	#1,a3

Do_CMP_5_1	move.b	-(a2),-(a3)	;move all 1 byte along
		subq.b	#1,d1
		bne.s	Do_CMP_5_1

		move.b	#$11,(a2)	;put in $11 prebyte
		addq.b	#1,opsize(a6)
		addq.w	#1,pc_value(a6)
		addq.b	#1,timing1(a6)	;and update timing too

		tst.w	d0
		rts

Do_CMP_6		cmp.b	#8,d2
		bne	Do_CMP_7		;skip if not CMPA

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect bit
		bne.s	Do_CMP_6_1	;skip if not immediate

		move.w	operand(a6),d3

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and immediate operand

		move.b	d0,opsize(a6)	;set instruction size
		add.w	d0,pc_value(a6)	;and update PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;no error
		rts

Do_CMP_6_1	cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_CMP_6_2	;skip if not

		add.b	#$20,d1		;make indexed opcode
		bsr	MakeIndexed	;and handle it

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_CMP_6_2	cmp.b	#_ADR_DIR,d2	;direct addressing?
		bne.s	Do_CMP_6_3	;skip if not

		add.b	#$10,d1		;make direct opcode
		move.w	operand(a6),d2

		move.b	d1,(a2)+
		move.b	d2,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d2		;check high byte
		beq.s	Do_CMP_6_2A	;zero so OK
		cmp.b	dpage(a6),d2	;matches direct page?
		beq.s	Do_CMP_6_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_CMP_6_2A	moveq	#0,d0
		rts

Do_CMP_6_3	cmp.b	#_ADR_EXT,d2	;extended addressing?
		bne.s	Do_CMP_6_4	;skip if not

		move.w	addrmode(a6),d2	;indirect?
		and.b	#_ADR_PTR,d2
		beq.s	Do_CMP_6_5	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		move.w	operand(a6),d3
		add.b	#$20,d1		;make indexed opcode
		moveq	#4,d0		;instruction size
		move.b	d1,(a2)+		;pop in opcode
		move.b	#$9F,(a2)+	;then indirect postbyte
		move.b	d3,1(a2)		;then memory address
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_6_5	add.b	#$30,d1		;make extended opcode
		moveq	#3,d0		;this many bytes
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_6_4	bsr	Do_CMP_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_CMP_7		cmp.b	#9,d2
		bne	Do_CMP_8		;skip if not CMPB

		add.b	#$40,d1		;create CMPB opcode

		move.w	addrmode(a6),d2	;get address mode
		and.b	#$7F,d2		;mask off indirect bit
		bne.s	Do_CMP_7_1	;skip if not immediate

		move.w	operand(a6),d3

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and immediate operand

		move.b	d0,opsize(a6)	;set instruction size
		add.w	d0,pc_value(a6)	;and update PC value

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0		;no error
		rts

Do_CMP_7_1	cmp.b	#_ADR_IND,d2	;indexed?
		bne.s	Do_CMP_7_2	;skip if not

		add.b	#$20,d1		;make indexed opcode
		bsr	MakeIndexed	;and handle it

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

;		moveq	#0,d0
		move.w	d5,d0		;indexed mode error code
		rts

Do_CMP_7_2	cmp.b	#_ADR_DIR,d2	;direct addressing?
		bne.s	Do_CMP_7_3	;skip if not

		add.b	#$10,d1		;make direct opcode
		move.w	operand(a6),d2

		move.b	d1,(a2)+
		move.b	d2,(a2)+

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		lsr.w	#8,d2		;check high byte
		beq.s	Do_CMP_7_2A	;zero so OK
		cmp.b	dpage(a6),d2	;matches direct page?
		beq.s	Do_CMP_7_2A	;does so OK

		moveq	#_ERR_DPAGE,d0
		rts

Do_CMP_7_2A	moveq	#0,d0
		rts

Do_CMP_7_3	cmp.b	#_ADR_EXT,d2	;extended addressing?
		bne.s	Do_CMP_7_4	;skip if not

		move.w	addrmode(a6),d2	;indirect?
		and.b	#_ADR_PTR,d2
		beq.s	Do_CMP_7_5	;skip if not
		move.b	#5,timing2(a6)	;set timing addon

		move.w	operand(a6),d3
		add.b	#$20,d1		;make indexed opcode
		moveq	#4,d0		;instruction size
		move.b	d1,(a2)+		;pop in opcode
		move.b	#$9F,(a2)+	;then indirect postbyte
		move.b	d3,1(a2)		;then memory address
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_7_5	add.b	#$30,d1		;make extended opcode
		moveq	#3,d0		;this many bytes
		move.w	operand(a6),d3

		move.b	d1,(a2)+
		move.b	d3,1(a2)
		lsr.w	#8,d3
		move.b	d3,(a2)

		move.b	d0,opsize(a6)
		add.w	d0,pc_value(a6)

		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3),timing1(a6)

		moveq	#0,d0
		rts

Do_CMP_7_4	bsr	Do_CMP_Err
		moveq	#_ERR_ADMODE,d0
		rts

Do_CMP_8		bsr	Do_CMP_Err
		moveq	#_ERR_ACC,d0
		rts


* This code generates opcodes for indexed mode operands.

* Input:

* opcode byte in d1
* instruction size in bytes in d0
* ptr to instruction buffer in a2

* Output:

* Index type in d2
* postbyte in d3
* offset/end data in d4 if it exists
* new instruction size in d0
* opcode byte in d1
* error code in d5 if exists


MakeIndexed	move.b	indtype(a6),d2	;get indexing type
		cmp.b	#_IX_ZERO,d2	;zero offset?
		bne.s	MID_1		;skip if not

		move.b	#$84,d3		;zero offset postbyte
		clr.b	timing2(a6)	;set timing addon
		move.b	indreg(a6),d4	;get index reg
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte

		move.w	addrmode(a6),d4
		and.b	#_ADR_PTR,d4	;indirect mode?
		beq.s	MID_1a
		add.b	#$10,d3		;make indirect indexed postbyte
		move.b	#3,timing2(a6)	;set timing addon

MID_1a		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and postbyte
		moveq	#0,d5		;no error found
		rts


MID_1		cmp.b	#_IX_C5,d2	;5-bit offset?
		bne.s	MID_2		;skip if not

		moveq	#0,d3		;5-bit offset postbyte
		move.b	#1,timing2(a6)
		move.b	indreg(a6),d4	;get index reg
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte

		move.w	indoff(a6),d4	;get offset
		and.b	#$1F,d4		;make 5 bits
		add.b	d4,d3		;add to postbyte

		move.w	addrmode(a6),d4
		and.b	#_ADR_PTR,d4	;indirect mode?
		beq.s	MID_2a

		move.b	#4,timing2(a6)	;set timing addon
		add.b	#$10,d3		;make indirect indexed postbyte
		and.b	#$F0,d3		;and convert to 8-bit offset
		addq.b	#8,d3
		move.w	indoff(a6),d4

		addq.b	#1,d0		;1 extra byte
		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,(a2)		;and displacement
		moveq	#0,d5		;no error found
		rts


MID_2a		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and postbyte
		moveq	#0,d5		;no error found
		rts


MID_2		cmp.b	#_IX_C8,d2	;8-bit offset?
		bne.s	MID_3		;skip if not

		move.b	#$88,d3		;8-bit offset postbyte
		move.b	#1,timing2(a6)	;set timing addon
		move.b	indreg(a6),d4	;;get index reg
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte
		move.w	indoff(a6),d4	;and get offset separately

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_3a
		add.b	#$10,d3		;make indirect indexed postbyte
		move.b	#4,timing2(a6)	;set timing addon

MID_3a		addq.b	#1,d0		;1 extra byte
		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,(a2)+		;and displacement
		moveq	#0,d5		;no error found
		rts


MID_3		cmp.b	#_IX_C16,d2	;16-bit offset?
		bne.s	MID_4		;skip if not

		move.b	#$89,d3		;16-bit offset postbyte
		move.b	#4,timing2(a6)	;set timing addon
		move.b	indreg(a6),d4	;get index reg
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte
		move.w	indoff(a6),d4	;get offset separately

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_4a
		add.b	#$10,d3		;make indirect indexed postbyte
		move.b	#7,timing2(a6)	;set timing addon

MID_4a		addq.b	#2,d0		;2 extra bytes
		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,1(a2)		;displacement low
		lsr.w	#8,d4
		move.b	d4,(a2)		;and high bytes
		moveq	#0,d5		;no error found

		rts


MID_4		cmp.b	#_IX_ACC,d2	;accumulator offset?
		bne.s	MID_5		;skip if not

		move.w	indoff(a6),d4	;get accumulator chosen
		bne.s	MID_4b		;skip if not D
		move.b	#$8B,d3		;else use this postbyte
		move.b	#4,timing2(a6)	;set timing addon
		bra.s	MID_4x

MID_4b		cmp.b	#8,d4		;A,X etc?
		bne.s	MID_4c		;skip if not
		move.b	#$86,d3		;else use this postbyte
		move.b	#1,timing2(a6)	;set timing addon
		bra.s	MID_4x

MID_4c		move.b	#$85,d3		;this postbyte for B,X etc
		move.b	#1,timing2(a6)	;set timing addon

MID_4x		move.b	indreg(a6),d4	;get index reg
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_5a
		add.b	#$10,d3		;make indirect indexed postbyte
		add.b	#3,timing2(a6)	;set timing addon

MID_5a		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and postbyte
		moveq	#0,d5		;no error found

		rts


MID_5		cmp.b	#_IX_AUTOINC,d2	;autoincrement?
		bne.s	MID_6		;skip if not

		move.b	#$80,d3		;initial postbyte
		move.b	autoskip(a6),d4
		subq.b	#1,d4
		add.b	d4,d3		;create postbyte
		move.b	#2,timing2(a6)	;set timing addon
		add.b	d4,timing2(a6)	;set timing addon

		move.b	indreg(a6),d4	;get index register
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_6a
		add.b	#$10,d3		;make indirect indexed postbyte
		add.b	#3,timing2(a6)	;set timing addon

MID_6a		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and postbyte
		moveq	#0,d5		;no error found
		rts


MID_6		cmp.b	#_IX_AUTODEC,d2	;autodecrement?
		bne.s	MID_7		;skip if not

		move.b	#$82,d3		;initial postbyte
		move.b	autoskip(a6),d4
		subq.b	#1,d4
		add.b	d4,d3		;create postbyte
		move.b	#2,timing2(a6)	;set timing addon
		add.b	d4,timing2(a6)	;set timing addon

		move.b	indreg(a6),d4	;get index register
		subq.b	#1,d4
		lsl.b	#5,d4
		add.b	d4,d3		;create postbyte

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_7a
		add.b	#$10,d3		;make indirect indexed postbyte
		add.b	#3,timing2(a6)	;set timing addon

MID_7a		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;and postbyte
		moveq	#0,d5		;no error found
		rts


MID_7		cmp.b	#_IX_PCR8,d2	;PCR 8-bit?
		bne.s	MID_8		;skip if not

		move.b	#$8C,d3		;create postbyte
		move.b	#1,timing2(a6)	;set timing addon
		move.w	indoff(a6),d4

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_8a
		add.b	#$10,d3		;make indirect indexed postbyte
		move.b	#4,timing2(a6)	;set timing addon

MID_8a		addq.b	#1,d0		;1 extra byte

		move.w	pc_value(a6),d5	;create PC relative
		add.w	d0,d5		;offset
		sub.w	d5,d4
		cmp.b	#2,pass(a6)	;pass 2?
		bne.s	MID_8d		;skip if not
		move.w	d4,d5
		bpl.s	MID_8b

		neg.w	d5

MID_8b		lsr.w	#8,d5

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,(a2)+		;and displacement
		tst.b	d5		;offset too big for short?
		beq.s	MID_8c		;skip if not

		moveq	#_ERR_BIGPC,d5

MID_8c		rts


MID_8d		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,(a2)+		;and displacement

		moveq	#0,d5		;signal no error
		rts


MID_8		cmp.b	#_IX_PCR16,d2	;PCR 16-bit?
		bne.s	MID_9		;skip if not

		move.b	#$8D,d3		;create postbyte
		move.b	#5,timing2(a6)	;set timing addon
		move.w	indoff(a6),d4

		move.w	addrmode(a6),d5
		and.b	#_ADR_PTR,d5	;indirect mode?
		beq.s	MID_9a
		add.b	#$10,d3		;make indirect indexed postbyte
		move.b	#8,timing2(a6)	;set timing addon

MID_9a		addq.b	#2,d0		;2 extra bytes

		move.w	pc_value(a6),d5	;create PC relative
		add.w	d0,d5		;offset
		sub.w	d5,d4

		move.b	d1,(a2)+		;pop in opcode
		move.b	d3,(a2)+		;postbyte
		move.b	d4,1(a2)		;displacement low
		lsr.w	#8,d4
		move.b	d4,(a2)		;and high bytes
		moveq	#0,d5		;no error found
		rts


MID_9		moveq	#0,d5		;no error found
		rts


* This code handles DEF. Because of the complexities of string
* handling, this is a LONG routine!


Do_DEF		clr.w	defcount(a6)	;no DEFs yet!

		tst.b	gotargs(a6)	;any arguments?
		bne.s	Do_DEF_1

		moveq	#_ERR_MISSING,d0
		rts

Do_DEF_1		move.b	regnum(a6),d0	;get type B/W/S/T

		bne.s	Do_DEF_2		;skip if not DEFB

		move.l	argptr(a6),a0

Do_DEF_1A	move.l	a0,-(sp)		;save pointer

Do_DEF_1B	move.b	(a0)+,d0		;get char
		beq.s	Do_DEF_1C	;skip if EOS met
		cmp.b	#",",d0		;found a comma?
		bne.s	Do_DEF_1B	;back if not

		clr.b	-1(a0)		;EOS out the comma
		move.l	(sp)+,a0		;recover the pointer
		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_DEF_1D	;skip if error

		move.l	defarea(a6),a1	;point to buffer start
		move.w	defcount(a6),d0	;position in buffer
		add.w	d0,a1		;point to buffer pos
		move.b	d1,(a1)		;write in value

		addq.w	#1,defcount(a6)	;update pointer

		addq.l	#1,a0		;point to next arg
		bra.s	Do_DEF_1A

Do_DEF_1C	move.l	(sp)+,a0

		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_DEF_1D	;skip if error

		move.l	defarea(a6),a1	;point to buffer start
		move.w	defcount(a6),d0	;position in buffer
		add.w	d0,a1		;point to buffer pos
		move.b	d1,(a1)		;write in value

		addq.w	#1,defcount(a6)	;update pointer

		move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)	;adjust PC value

		moveq	#0,d0		;signal all's well
		rts

Do_DEF_1D	moveq	#_ERR_EXP,d0
		rts

Do_DEF_2		cmp.b	#1,d0
		bne.s	Do_DEF_3		;skip if not DEFW

		move.l	argptr(a6),a0

Do_DEF_2A	move.l	a0,-(sp)		;save pointer

Do_DEF_2B	move.b	(a0)+,d0		;get char
		beq.s	Do_DEF_2C	;skip if EOS met
		cmp.b	#",",d0		;found a comma?
		bne.s	Do_DEF_2B	;back if not

		clr.b	-1(a0)		;EOS out the comma
		move.l	(sp)+,a0		;recover the pointer
		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_DEF_2D	;skip if error

		move.l	defarea(a6),a1	;point to buffer start
		move.w	defcount(a6),d0	;position in buffer
		add.w	d0,a1		;point to buffer pos
		move.w	d1,(a1)		;write in value

		addq.w	#2,defcount(a6)	;update pointer

		addq.l	#1,a0		;point to next arg
		bra.s	Do_DEF_2A

Do_DEF_2C	move.l	(sp)+,a0

		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_DEF_2D	;skip if error

		move.l	defarea(a6),a1	;point to buffer start
		move.w	defcount(a6),d0	;position in buffer
		add.w	d0,a1		;point to buffer pos
		move.w	d1,(a1)		;write in value

		addq.w	#2,defcount(a6)	;update pointer

		move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)	;adjust PC value

		moveq	#0,d0		;signal all's well
		rts

Do_DEF_2D	moveq	#_ERR_EXP,d0
		rts

Do_DEF_3		cmp.b	#2,d0
		bne.s	Do_DEF_4		;skip if not DEFS

		move.l	argptr(a6),a0	;get text arg ptr

Do_DEF_3A	move.b	(a0)+,d0		;get char fo operand string
		beq.s	Do_DEF_3B	;skip if EOS hit
		cmp.b	#_QUOTE,d0	;is it double quotes?
		bne.s	Do_DEF_3A	;skip if not

Do_DEF_3C	move.b	(a0)+,d0		;get char of operand string
		beq.s	Do_DEF_3D	;skip if EOS hit
		cmp.b	#"\",d0		;backslash char?
		bne.s	Do_DEF_3E	;skip if not

		move.b	(a0)+,d0		;copy next char verbatim

Do_DEF_3G	move.l	defarea(a6),a1	;point to buffer
		move.w	defcount(a6),d1	;position in buffer
		add.w	d1,a1		;point to actual position
		move.b	d0,(a1)		;insert char into buffer

		addq.w	#1,defcount(a6)	;next counter
		bra.s	Do_DEF_3C	;and back for next char

Do_DEF_3E	cmp.b	#"^",d0		;CTRL-char prefix?
		bne.s	Do_DEF_3F	;skip if not

		move.b	(a0)+,d0		;get next char
		and.b	#$1F,d0		;make control char
		bra.s	Do_DEF_3G

Do_DEF_3F	cmp.b	#_QUOTE,d0	;hit end quote?
		bne.s	Do_DEF_3G	;copy verbatim if not

Do_DEF_3B	move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)

		moveq	#0,d0
		rts

Do_DEF_3D	move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)

		move.b	#_QUOTE,errchar+1(a6)	;signal missing "
		moveq	#_ERR_CHAR,d0		;error
		rts

Do_DEF_4		cmp.b	#3,d0
		bne.s	Do_DEF_5		;skip if not DEFT

		move.l	argptr(a6),a0	;get text arg ptr

Do_DEF_4A	move.b	(a0)+,d0		;get char fo operand string
		beq.s	Do_DEF_4B	;skip if EOS hit
		cmp.b	#_QUOTE,d0	;is it double quotes?
		bne.s	Do_DEF_4A	;skip if not

Do_DEF_4C	move.b	(a0)+,d0		;get char of operand string
		beq.s	Do_DEF_4D	;skip if EOS hit
		cmp.b	#"\",d0		;backslash char?
		bne.s	Do_DEF_4E	;skip if not

		move.b	(a0)+,d0		;copy next char verbatim

Do_DEF_4G	move.l	defarea(a6),a1	;point to buffer
		move.w	defcount(a6),d1	;position in buffer
		add.w	d1,a1		;point to actual position
		move.b	d0,(a1)		;insert char into buffer

		addq.w	#1,defcount(a6)	;next counter
		bra.s	Do_DEF_4C	;and back for next char

Do_DEF_4E	cmp.b	#"^",d0		;CTRL-char prefix?
		bne.s	Do_DEF_4F	;skip if not

		move.b	(a0)+,d0		;get next char
		and.b	#$1F,d0		;make control char
		bra.s	Do_DEF_4G

Do_DEF_4F	cmp.b	#_QUOTE,d0	;hit end quote?
		bne.s	Do_DEF_4G	;copy verbatim if not

Do_DEF_4B	move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)

		subq.w	#1,d0
		move.l	defarea(a6),a1
		add.w	d0,a1		;point to last char
		bset	#7,(a1)		;and set its top bit

		moveq	#0,d0
		rts

Do_DEF_4D	move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)

		subq.w	#1,d0
		move.l	argptr(a6),a1
		add.w	d0,a1		;point to last char
		bset	#7,(a1)		;and set its top bit

		move.b	#_QUOTE,errchar+1(a6)	;signal missing "
		moveq	#_ERR_CHAR,d0		;error
		rts

Do_DEF_5		moveq	#_ERR_DTYPE,d0
		rts


* This code handles RESB/RESW.


Do_RES		clr.w	defcount(a6)	;no DEFs yet!
		clr.w	resfill(a6)

		tst.b	gotargs(a6)	;any arguments?
		bne.s	Do_RES_1

		moveq	#_ERR_MISSING,d0
		rts

Do_RES_1		move.b	regnum(a6),d0	;get whether RESB/RESW
		bne.s	Do_RES_2		;skip if not RESB

		move.l	argptr(a6),a0

Do_RES_1A	move.l	a0,-(sp)		;save pointer

Do_RES_1B	move.b	(a0)+,d0		;get char
		beq.s	Do_RES_1C	;skip if EOS met
		cmp.b	#",",d0		;found a comma?
		bne.s	Do_RES_1B	;back if not

		clr.b	-1(a0)		;EOS out the comma
		move.l	(sp)+,a0		;recover the pointer
		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_1D	;skip if error

		move.w	d1,defcount(a6)
		
		addq.l	#1,a0		;point to next arg

		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_1D	;skip if error

		move.w	d1,resfill(a6)
		bra.s	Do_RES_1G

Do_RES_1C	move.l	(sp)+,a0

Do_RES_1E	lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_1D	;skip if error

		move.w	d1,defcount(a6)
		moveq	#0,d1

Do_RES_1G	move.w	defcount(a6),d0
		add.w	d0,pc_value(a6)	;adjust PC value

		move.l	defarea(a6),a1	;ptr to buffer

Do_RES_1F	move.b	d1,(a1)+		;fill with given bytes
		subq.w	#1,d0
		bne.s	Do_RES_1F	;do this many

		moveq	#0,d0		;signal all's well
		rts

Do_RES_1D	moveq	#_ERR_EXP,d0
		rts

Do_RES_2		cmp.b	#1,d0
		bne.s	Do_RES_3		;skip if not RESW

		move.l	argptr(a6),a0

Do_RES_2A	move.l	a0,-(sp)		;save pointer

Do_RES_2B	move.b	(a0)+,d0		;get char
		beq.s	Do_RES_2C	;skip if EOS met
		cmp.b	#",",d0		;found a comma?
		bne.s	Do_RES_2B	;back if not

		clr.b	-1(a0)		;EOS out the comma
		move.l	(sp)+,a0		;recover the pointer
		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_2D	;skip if error

		move.w	d1,d2
		add.w	d2,d2		;make no of BYTES!
		move.w	d2,defcount(a6)
		
		addq.l	#1,a0		;point to next arg

		lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_2D	;skip if error

		move.w	d1,resfill(a6)
		move.w	defcount(a6),d2	;get BYTE count
		move.w	d2,d0
		lsr.w	#1,d0		;make WORD count again
		bra.s	Do_RES_2G

Do_RES_2C	move.l	(sp)+,a0

Do_RES_2E	lea	CompOps(pc),a1
		lea	Funcs(pc),a2
		bsr	DoExp		;get operand value
		bne.s	Do_RES_2D	;skip if error

		move.w	d1,d2		;no of WORDS
		add.w	d2,d2		;no of BYTES
		move.w	d2,defcount(a6)	;save BYTE count

		move.w	d1,d0
		moveq	#0,d1

Do_RES_2G	add.w	d2,pc_value(a6)	;adjust PC value

		move.l	defarea(a6),a1	;ptr to buffer

Do_RES_2F	move.w	d1,(a1)+		;fill with given bytes
		subq.w	#1,d0
		bne.s	Do_RES_2F	;do this many

		moveq	#0,d0		;signal all's well
		rts

Do_RES_2D	moveq	#_ERR_EXP,d0
		rts

Do_RES_3		moveq	#_ERR_DTYPE,d0
		rts


* Here handle SHORT and LONG directives


Do_SHORT		clr.b	shortlong(a6)
		moveq	#0,d0
		rts

Do_LONG		st	shortlong(a6)
		moveq	#0,d0
		rts


* Use this code to point to timing entries

* Input:

* d1 = opcode

* Output

* d0-d2 = timing values


		lea	timelist(pc),a3
		moveq	#0,d0
		move.b	d1,d0
		move.l	d0,d1
		add.l	d0,d1
		add.l	d0,d1
		add.l	d1,a3

		move.b	(a3)+,d2
		move.b	(a3)+,d1
		move.b	(a3)+,d0



