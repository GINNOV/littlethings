	xref	func

test:

	.REG	d7
	.BRANCH	w

	.FOR	d0.w = #1 to #10 STEP #2
	addq.w	#1,d1
	.NEXT
	.IF	(a0) + #100 <> #10
	moveq	#0,d0
	.ELSE
	moveq	#1,d0
	.ENDIF

	.IF	d0 = #10
	moveq	#0,d0
	.ELSE
	moveq	#1,d0
	.ENDIF


	.WHILE	d0 <> #0
	addq.w	#1,d1
	.ENDWHILE


	.CALL	func , test + #100 - #20 , #test
	.RETURN	d1 + d2 + #$100
	.RETURN	(a0)

	.DEF	rout , d0.w , d1 , (a0)
	.ENDDEF



	.LET	+ #100 - #10 << #7
	.LET	d1 = (a1) - (a0)
