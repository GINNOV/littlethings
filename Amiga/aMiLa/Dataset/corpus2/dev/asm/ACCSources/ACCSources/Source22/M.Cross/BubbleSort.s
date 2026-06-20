

* -------------	Bubble sort routine ©1992 M J Cross -------------------	*


		opt	d+
		
Bubble		lea	Positions,a0
		moveq.l	#0,d0
		
Loop		move.w	(a0),d1
		cmp.w	2(a0),d1
		ble	NoSwap
		move.w	2(a0),(a0)
		move.w	d1,2(a0)
		st	d0
NoSwap		add.l	#2,a0
		cmpa.l	#EndPos,a0
		bcs	Loop
		tst.w	d0
		bne	Bubble	
End		rts
				



Positions	dc.w	8,3,4,5,6,7,8,1,-1,2,6
EndPos		equ	*-2
