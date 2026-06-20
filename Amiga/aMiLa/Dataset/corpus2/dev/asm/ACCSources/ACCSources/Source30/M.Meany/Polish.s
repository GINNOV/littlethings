
*****		Start of a reverse polish expression evaluator. M.Meany,1993.


Test		lea		String,a0
		bsr		Eval

		lea		String1,a0
		bsr		Eval

		lea		String2,a0
		bsr		Eval

		lea		String3,a0
		bsr		Eval



		rts

; The followin is evaluated:    (   8  +  4  ) * (   5  +  6  *  9  ) = 708

String		dc.b		10,'8',6,'4',9,8,10,'5',6,'6',8,'9',9,0
		even

;				 8  +  3  *  7  = 29

String1		dc.b		'8',6,'3',8,'7',0
		even

;				(   8  +  3  ) *  7    = 77

String2		dc.b		10,'8',6,'3',9,8,'7',0
		even

;	       (  (   8  + (   2  +  6  ) /  4  ) /  5  ) * (   8  -  6  ) =4

String3	 dc.b  10,10,'8',6,10,'2',6,'6',9,7,'4',9,7,'5',9,8,10,'8',5,'6',9,0
	 even
;			******************************
;			**** Expression Evaluator ****
;			******************************

; At present is using position as a measure of priority. Needs to recognise
;equal priority operators and deal with situation accordingly!


; a0->string to evaluate. Builds a polish string.

Eval		move.l		a7,a5
		
		lea		Parenthesis,a2		a2->storage point
		moveq.l		#0,d1
		moveq.l		#0,d2

; Locate end of string

		move.l		a0,a1
SELoop		tst.b		(a1)+
		bne.s		SELoop
		
		subq.l		#1,a1			correct

; Start parsing the string

Parse		cmpa.l		a0,a1
		beq		ParseDone
		
		moveq.l		#0,d1
		move.b		-(a1),d1		get byte

; Is it a close brace?

		cmpi.b		#9,d1
		bne.s		NotClosed

	;Check there is an operator
		
		tst.l		d2			got an operator?
		beq		Parse

	;And room for further nesting
	
		cmpi.l		#-1,(a2)
		beq		Parse			no more nesting!!!!

		move.l		d2,(a2)+
		moveq.l		#0,d2
		bra		Parse

; Check for open brace

NotClosed	cmpi.b		#10,d1
		bne.s		NotOpen

	;Is an open brace, preform current operation
	
		move.l		d2,d1
		subq.w		#1,d1
		bmi.s		Parse

		asl.l		#2,d1
		add.l		#SubTable,d1
		move.l		d1,a3
		move.l		(a3),a3
		jsr		(a3)
		
		moveq.l		#0,d2			restore last operator
		cmpi.l		#-1,-4(a2)
		beq		Parse
		move.l		-(a2),d2
		bra		Parse

; See if it's an operator

NotOpen		cmp.b		#10,d1
		bgt.s		IsNumber

; It is, compare with last operator

		tst.l		d2
		bne.s		CanGo
		move.l		d1,d2
		bra		Parse

CanGo		cmp.l		d1,d2
		blt.s		GotHighest

		exg.l		d1,d2

GotHighest	subq.w		#1,d1
		asl.l		#2,d1
		add.l		#SubTable,d1
		move.l		d1,a3
		move.l		(a3),a3
		jsr		(a3)
		bra		Parse

IsNumber	sub.w		#'0',d1			convert to literal
		move.l		d1,-(sp)
		bra		Parse

ParseDone	move.l		d2,d1
		subq.w		#1,d1
		beq.s		EvalDone
		asl.l		#2,d1
		add.l		#SubTable,d1
		move.l		d1,a3
		move.l		(a3),a3
		jsr		(a3)
		
EvalDone	move.l		(sp)+,d0
		move.l		a5,a7
		rts

		dc.l		-1			for error trapping
Parenthesis	ds.l		16			for nesting
		dc.l		-1			for error trapping


OperatorTable	dc.b		'(',10,9
		dc.b		')',9,9
		dc.b		'*',8,8
		dc.b		'/',7,8
		dc.b		'+',6,7
		dc.b		'-',5,7
		dc.b		'<',4,6
		dc.b		'>',3,6

SubTable	dc.l		Nought		1
		dc.l		Nought		2
		dc.l		Greater		3
		dc.l		Smaller		4
		dc.l		Subtract
		dc.l		Addem
		dc.l		Divide
		dc.l		Multiply

Nought		rts

Greater		move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		move.l		#0,-(sp)
		
		sub.l		d7,d6
		blt		.done
		move.l		#1,(sp)

.done		move.l		a3,-(sp)
		rts

Smaller		move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		move.l		#0,-(sp)
		
		sub.l		d6,d7
		blt		.done
		move.l		#1,(sp)

.done		move.l		a3,-(sp)
		rts

Subtract	move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		
		sub.l		d7,d6
		move.l		d6,-(sp)

.done		move.l		a3,-(sp)
		rts

Addem		move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		
		add.l		d7,d6
		move.l		d6,-(sp)

.done		move.l		a3,-(sp)
		rts

Divide		move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		
		divu		d7,d6
		and.l		#$ffff,d6
		move.l		d6,-(sp)

.done		move.l		a3,-(sp)
		rts

Multiply	move.l		(a7)+,a3
		move.l		(sp)+,d6
		move.l		(sp)+,d7
		
		mulu		d7,d6
		move.l		d6,-(sp)

.done		move.l		a3,-(sp)
		rts
