; Chunky2Planar algorithm.
;
; 	Cpu only solution
;	Optimised for 020+fastram
;	Aim for less than 90ms for 320x200x256 on 14MHz 020

	output	five_pass.o
	opt	l+	;Linkable code
	opt	c+	;Case sensitive
	opt	d-	;No debugging information
	opt	m+	;Expand macros in listing
	opt	o-	;No optimisation
	
	xdef	_chunky2planar
		
;  a0 -> chunky pixels
;  a1 -> plane0

width		equ	320		; must be multiple of 32
height		equ	200
plsiz		equ	(width/8)*height

wordmerge	macro
	; i1	i2	tmp
	; \1	\2	\3
;; speedup			\1 AB \2 CD
	move.l	\2,\3		\3 = CD
	move.w	\1,\2		\2 = CB
	swap	\2		\2 = BC
	move.w	\2,\1		\1 = AC
	move.w	\3,\2		\2 = BD
	endm

		
merge	macro	;	i1	i2	t3	t4	m	s
		;	\1	\2	\3	\4	\5	\6
		;	output as \1,\3
			; \1 = abqr
			; \2 = ijyz
	move.l	\5,\3	; \3 = 0x0x
	move.l	\5,\4	; \4 = 0x0x
	and.l	\1,\3	; \3 = 0b0r
	and.l	\2,\4	; \4 = 0j0z
	eor.l	\3,\1	; \1 = a0q0
	eor.l	\4,\2	; \2 = i0y0
	IFEQ	\6-1
	add.l	\3,\3
	ELSE
	lsl.l	#\6,\3	; \3 = b0r0
	ENDC
	lsr.l	#\6,\2	; \2 = 0i0y
	or.l	\2,\1		; \1 = aiqy
	or.l	\4,\3		; \2 = bjrz
	endm
		
_chunky2planar:
		;a0 = chunky buffer
		;a1 = first bitplane
		
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a0,a2
	add.l	#plsiz*8,a2	;a2 = end of chunky buffer
	
	;; Sweep thru the whole chunky data once,
	;; Performing 3 merge operations on it.
	
	move.l	#$00ff00ff,a3	; load byte merge mask
	move.l	#$0f0f0f0f,a4	; load nibble merge mask
	
firstsweep

	; pass 1
	movem.l	(a0),d0-d7	;8+4n 	40	cycles
	; d0-7 = abcd efgh ijkl mnop qrst uvwx yzAB CDEF
	;; 40c
	
	wordmerge	d0,d4,a6	;d0/4 = abqr cdst
	wordmerge	d1,d5,a6	;d1/5 = efuv ghwx
	wordmerge	d2,d6,a6	;d2/6 = ijyz klAB
	wordmerge	d3,d7,a6 	;d3/7 = mnCD opEF
	;; 4*14c

	; save off a bit of shit
	move.l	d7,a6
	move.l	d6,a5
	;; 4c
		
	; pass 2
	merge	d0,d2,d6,d7,a3,8	;d0/d6 = aiqy bjrz
	merge	d1,d3,d7,d2,a3,8	;d1/d7 = emuc fnvD
	;; 2*24
	
	; pass 3
	merge	d0,d1,d2,d3,a4,4	;d0/d2  = ae74... ae30...
	merge	d6,d7,d3,d1,a4,4	;d6/d3  = bf74... bf30...
	;; 2*24
	
	move.l	d0,(a0)+
	move.l	d2,(a0)+
	move.l	d6,(a0)+
	move.l	d3,(a0)+
	;; 4*4c
	
	; bring it back
	move.l	a6,d7
	move.l	a5,d6
	;; 2*2c
		
	; pass 2
	merge	d4,d6,d0,d1,a3,8	;d4/d0 = cksA dltB
	merge	d5,d7,d1,d6,a3,8	;d5/d1 = gowE hpxF
	;; 2*24c
	
	; pass 3			
	merge	d4,d5,d6,d7,a4,4	;d4/d6 = cg74.. cg30..
	merge	d0,d1,d7,d5,a4,4	;d0/d7 = dh74.. dh30..
	;; 2*24c
		
	move.l	d4,(a0)+
	move.l	d6,(a0)+
	move.l	d0,(a0)+
	move.l	d7,(a0)+
	;; 4*4c
	
	cmp.l	a0,a2		;; 4c
	bne.w	firstsweep	;; 6c

	;; 338
	
	; (a0) 	ae74.. ae30.. bf74.. bf30.. cg74.. cg30.. dh74.. dh30..

;	bra.w	exit
	
	sub.l	#plsiz*8,a0
	move.l	#$33333333,a5
	move.l	#$55555555,a6


	lea	plsiz*4(a1),a1	;a2 = plane4
	
secondsweep

	move.l	(a0),d0
	move.l	8(a0),d1
	move.l	16(a0),d2
	move.l	24(a0),d3
	;; 6+3*7
	
	;; pass 4	
	merge	d0,d2,d6,d7,a5,2	;d0/d6 = aceg76.. aceg54..
	merge	d1,d3,d7,d2,a5,2	;d1/d7 = bdhf76.. bdhf54..
	;; 24*2c
	
	;; pass 5	
	merge	d0,d1,d2,d3,a6,1	;d0/d2 = abcd7... abcd6...
	merge	d6,d7,d3,d1,a6,1	;d6/d3 = abcd5... abcd4...
	;; 24*2c

	move.l	d0,plsiz*3(a1)
	move.l	d2,plsiz*2(a1)
	move.l	d6,plsiz*1(a1)
	move.l	d3,(a1)+
	;;3*5+4c
		
	move.l	4(a0),d0
	move.l	12(a0),d1
	move.l	20(a0),d2
	move.l	28(a0),d3
	;;4*7c
	;; pass 4	
	merge	d0,d2,d6,d7,a5,2	;d0/d6 = aceg32.. aceg10..
	merge	d1,d3,d7,d2,a5,2	;d1/d7 = bdhf32.. bdhf10..
	;;2*24
	;; pass 5	
	merge	d0,d1,d2,d3,a6,1	;d0/d2 = abcd3... abcd2...
	merge	d6,d7,d3,d1,a6,1	;d6/d3 = abcd1... abcd0...
	;;2*24
	
	move.l	d0,-4-plsiz*1(a1)
	move.l	d2,-4-plsiz*2(a1)
	move.l	d6,-4-plsiz*3(a1)
	move.l	d3,-4-plsiz*4(a1)
	;;4*5
	
	add.w	#32,a0	;;4c
	cmp.l	a0,a2	;;4c
	bne.w	secondsweep	;;6c

	;300
	
exit	
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
