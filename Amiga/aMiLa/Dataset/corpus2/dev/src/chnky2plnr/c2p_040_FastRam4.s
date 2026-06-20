; Chunky2Planar algorithm.
;
; 	Cpu only solution VERSION 2
;	Optimised for 040+fastram
;	analyse instruction offsets to check performance

	output	five_pass.o
	opt	l+	;Linkable code
	opt	c+	;Case sensitive
	opt	d-	;No debugging information
	opt	m+	;Expand macros in listing
	opt	o-	;No optimisation

;quad_begin:
;	cnop	0,16

	xdef	_chunky2planar

;  a0 -> chunky pixels
;  a1 -> plane0

width		equ	320		; must be multiple of 32
height		equ	200
plsiz		equ	(width/8)*height


merge	MACRO in1,in2,tmp3,tmp4,mask,shift
	;		\1 = abqr
	;		\2 = ijyz
	move.l	\2,\4
	move.l	#\5,\3
	and.l	\3,\2	\2 = 0j0z
	and.l	\1,\3	\3 = 0b0r
	eor.l	\3,\1	\1 = a0q0
	eor.l	\2,\4	\4 = i0y0
	IFEQ	\6-1
	add.l	\3,\3
	ELSE
	lsl.l	#\6,\3	\3 = b0r0
	ENDC
	lsr.l	#\6,\4	\4 = 0i0y
	or.l	\3,\2	\2 = bjrz
	or.l	\4,\1	\1 = aiqy
	ENDM


_chunky2planar:
	jmp	next
next
	; round down address of c2p
	lea	c2p(pc),a0
	move.l	a0,d0
	and.b	#%11110000,d0
	move.l	d0,a1
	
	; patch jmp
	move.l	d0,_chunky2planar+2
	move.w	#(end-c2p)-1,d0
loop	move.b	(a0)+,(a1)+
	dbra	d0,loop

	;tidy cache
	movem.l	d2-d7/a2-a6,-(sp)	
	move.l	$4.w,a6
	jsr	-636(a6)
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
	cnop	0,16
c2p:
		movem.l	d2-d7/a2-a6,-(sp)

		; a0 = chunky buffer
		; a1 = output area
		
		lea	4*plsiz(a1),a1	; a1 -> plane4
		
		move.l	a0,d0
		add.l	#16,d0
		and.b	#%11110000,d0
		move.l	d0,a0
		
		move.l	a0,a2
		add.l	#8*plsiz,a2

		lea	p0(pc),a3		
		bra.s	mainloop

	cnop	0,16
mainloop:
	move.l	0(a0),d0
 	move.l	4(a0),d2
 	move.l	8(a0),d1
	move.l	12(a0),d3
	move.l	2(a0),d4
 	move.l	10(a0),d5
	move.l	6(a0),d6
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	24(a0),d1
	move.w	20(a0),d2
	move.w	28(a0),d3
 	move.w	18(a0),d4
 	move.w	26(a0),d5
	move.w	22(a0),d6
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a3)	;plane2
	move.l	d2,3*4(a3)	;plane3
	move.l	d1,0*4(a3)	;plane0
	move.l	d0,1*4(a3)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a3)		;bitplane6
	move.l	d2,7*4(a3)		;bitplane7
	move.l	d5,4*4(a3)		;bitplane4
	move.l	d4,5*4(a3)		;bitplane5


inner:
	move.l	0(a0),d0
 	move.l	4(a0),d2
 	move.l	8(a0),d1
	move.l	12(a0),d3
	move.l	2(a0),d4
 	move.l	10(a0),d5
	move.l	6(a0),d6
	move.l	14(a0),d7

 	move.w	16(a0),d0
 	move.w	24(a0),d1
	move.w	20(a0),d2
	move.w	28(a0),d3
 	move.w	18(a0),d4
 	move.w	26(a0),d5
	move.w	22(a0),d6
	move.w	30(a0),d7
	
	adda.w	#32,a0
	move.l	d6,a5
	move.l	d7,a6

	; write	bitplane 7	

	move.l	2*4(a3),-2*plsiz(a1)	;plane2
	merge	d0,d1,d6,d7,$00FF00FF,8
	merge	d2,d3,d6,d7,$00FF00FF,8

	; write	
	move.l	3*4(a3),-plsiz(a1)	;plane3
	merge	d0,d2,d6,d7,$0F0F0F0F,4	
	merge	d1,d3,d6,d7,$0F0F0F0F,4

	exg.l	d0,a5
	exg.l	d1,a6	
	
	; write
	move.l	0*4(a3),-4*plsiz(a1)	;plane0
	merge	d4,d5,d6,d7,$00FF00FF,8
	merge	d0,d1,d6,d7,$00FF00FF,8
	
	; write	
	move.l	1*4(a3),-3*plsiz(a1) ;plane1
	merge	d4,d0,d6,d7,$0F0F0F0F,4
	merge	d5,d1,d6,d7,$0F0F0F0F,4

	; write	
	move.l	6*4(a3),2*plsiz(a1)	;bitplane6
	merge	d2,d0,d6,d7,$33333333,2
	merge	d3,d1,d6,d7,$33333333,2	

	; write
	move.l	7*4(a3),3*plsiz(a1)	;bitplane7
	merge	d2,d3,d6,d7,$55555555,1
	merge	d0,d1,d6,d7,$55555555,1
	move.l	d3,2*4(a3)	;plane2
	move.l	d2,3*4(a3)	;plane3
	move.l	d1,0*4(a3)	;plane0
	move.l	d0,1*4(a3)	;plane1

	move.l	a5,d2
	move.l	a6,d3

	move.l	4*4(a3),(a1)+		;bitplane4	
	merge	d2,d4,d6,d7,$33333333,2
	merge	d3,d5,d6,d7,$33333333,2

	move.l	5*4(a3),-4+1*plsiz(a1)	;bitplane5
	merge	d2,d3,d6,d7,$55555555,1
	merge	d4,d5,d6,d7,$55555555,1
	move.l	d3,6*4(a3)		;bitplane6
	move.l	d2,7*4(a3)		;bitplane7
	move.l	d5,4*4(a3)		;bitplane4
	move.l	d4,5*4(a3)		;bitplane5

	cmpa.l	a0,a2
	bne.w	inner

	move.l	2*4(a3),-2*plsiz(a1)	;plane2
	move.l	3*4(a3),-plsiz(a1)	;plane3
	move.l	0*4(a3),-4*plsiz(a1)	;plane0
	move.l	1*4(a3),-3*plsiz(a1) 	;plane1
	move.l	6*4(a3),2*plsiz(a1)	;bitplane6
	move.l	7*4(a3),3*plsiz(a1)	;bitplane7
	move.l	4*4(a3),(a1)+		;bitplane4	
	move.l	5*4(a3),-4+1*plsiz(a1)	;bitplane5

exit
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	cnop	0,4
end:
p0	dc.l	0
p1	dc.l	0
p2	dc.l	0
p3	dc.l	0
p4	dc.l	0
p5	dc.l	0
p6	dc.l	0
p7	dc.l	0
