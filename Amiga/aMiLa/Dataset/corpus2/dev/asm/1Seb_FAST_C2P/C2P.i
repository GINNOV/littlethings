;-------------------------------------------------
;-                                               -
;-      Routine de Conversion d'une fenetre      -
;-          Chunky de 320*256 en 8 plans         -
;-                pour 020 et 030                -
;-                                               -
;-------------------------------------------------

		cnop	0,8

C2P.020_030.1.1.256c:
	lea	CnkScreen,a0
	move.l	(Screen+4)(pc),a1
	add.l	#320*256/8*4,a1

	move.l	#$f0f0f0f0,d6
	move.l	#$cccccccc,a4
	move.l	#$ff00ff00,a5
	move.l	#$aaaaaaaa,a6

** Demarage de la boucle

	move.l	(a0)+,d0
	and.l	d6,d0
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d0			;d0 = AEBFCGDH 8765

	move.l	(a0)+,d1
	and.l	d6,d1
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d1			;d1 = IMJNKOLP 8765

	move.l	(a0)+,d2
	and.l	d6,d2
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d2			;d2 = A'E'B'F'C'G'D'H' 8765

	move.l	(a0)+,d3
	and.l	d6,d3
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d3			;d3 = I'M'J'N'K'O'L'P' 8765

	swap	d2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2			;d2 = CGDHC'G'D'H' 8765
	swap	d3			;d3 = KOLPK'O'L'P' 8765

	move.l	a4,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#2,d4
	eor.l	d2,d4
	and.l	d5,d4
	eor.l	d4,d2			;d2 = ACEGBDFHA'C'E'G'B'D'F'H' 65
	lsr.l	#2,d4
	eor.l	d4,d0			;d0 = ACEGBDFHA'C'E'G'B'D'F'H' 87

	move.l	d1,d4
	lsl.l	#2,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = IKMOJLNPI'K'M'O'J'L'N'P' 65
	lsr.l	#2,d4
	eor.l	d4,d1			;d1 = IKMOJLNPI'K'M'O'J'L'N'P' 87

	move.l	a5,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#8,d4
	eor.l	d1,d4
	and.l	d5,d4
	eor.l	d4,d1			;d1 = BDFHJLNPB'D'F'H'J'L'N'P' 87
	lsr.l	#8,d4
	eor.l	d4,d0			;d0 = ACEGIKMOA'C'E'G'I'K'M'O' 87

	move.l	d2,d4
	lsl.l	#8,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = BDFHJLNPB'D'F'H'J'L'N'P' 65
	lsr.l	#8,d4
	eor.l	d4,d2			;d2 = ACEGIKMOA'C'E'G'I'K'M'O' 65

	move.l	a6,d5			;chargement du masque

	move.l	d0,d4
	add.l	d4,d4
	eor.l	d1,d4
	and.l	d5,d4
	eor.l	d4,d1			;d1 = ABCDEFGHIJKLMNOP(idem avec') 7
	lsr.l	#1,d4

	move.l	d1,(320*256*2/8)(a1)

	eor.l	d4,d0			;d0 = ABCDEFGHIJKLMNOP(idem avec') 8

	move.l	d2,d4
	move.l	d0,a2
	add.l	d4,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = ABCDEFGHIJKLMNOP(idem avec') 5
	lsr.l	#1,d4
	move.l	d3,a3
	eor.l	d2,d4			;d4 = ABCDEFGHIJKLMNOP(idem avec') 6

	move.w	Size,d7

	CALIGN

.loop.pass1_C2P.020_030.1.1.256c:
	move.l	(a0)+,d0
	and.l	d6,d0
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d0			;d0 = AEBFCGDH 8765

	move.l	(a0)+,d1
	and.l	d6,d1
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d1			;d1 = IMJNKOLP 8765

	move.l	(a0)+,d2
	and.l	d6,d2
	move.l	(a0)+,d5
	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d2			;d2 = A'E'B'F'C'G'D'H' 8765

	move.l	(a0)+,d3
	and.l	d6,d3
	move.l	(a0)+,d5

	move.l	d4,(320*256*1/8)(a1)

	and.l	d6,d5
	lsr.l	#4,d5
	or.l	d5,d3			;d3 = I'M'J'N'K'O'L'P' 8765

	swap	d2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2			;d2 = CGDHC'G'D'H' 8765
	swap	d3			;d3 = KOLPK'O'L'P' 8765

	move.l	a4,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#2,d4

	move.l	a3,(a1)+

	eor.l	d2,d4
	and.l	d5,d4
	eor.l	d4,d2			;d2 = ACEGBDFHA'C'E'G'B'D'F'H' 65
	lsr.l	#2,d4
	eor.l	d4,d0			;d0 = ACEGBDFHA'C'E'G'B'D'F'H' 87

	move.l	d1,d4
	lsl.l	#2,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = IKMOJLNPI'K'M'O'J'L'N'P' 65
	lsr.l	#2,d4
	eor.l	d4,d1			;d1 = IKMOJLNPI'K'M'O'J'L'N'P' 87

	move.l	a5,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#8,d4
	eor.l	d1,d4

	move.l	a2,(320*256*3/8-4)(a1)

	and.l	d5,d4
	eor.l	d4,d1			;d1 = BDFHJLNPB'D'F'H'J'L'N'P' 87
	lsr.l	#8,d4
	eor.l	d4,d0			;d0 = ACEGIKMOA'C'E'G'I'K'M'O' 87

	move.l	d2,d4
	lsl.l	#8,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = BDFHJLNPB'D'F'H'J'L'N'P' 65
	lsr.l	#8,d4
	eor.l	d4,d2			;d2 = ACEGIKMOA'C'E'G'I'K'M'O' 65

	move.l	a6,d5			;chargement du masque

	move.l	d0,d4
	add.l	d4,d4
	eor.l	d1,d4
	and.l	d5,d4
	eor.l	d4,d1			;d1 = ABCDEFGHIJKLMNOP(idem avec') 7

	move.l	d1,(320*256*2/8)(a1)

	lsr.l	#1,d4
	eor.l	d4,d0			;d0 = ABCDEFGHIJKLMNOP(idem avec') 8

	move.l	d2,d4

	move.l	d0,a2

	add.l	d4,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = ABCDEFGHIJKLMNOP(idem avec') 5
	lsr.l	#1,d4

	move.l	d3,a3

	eor.l	d2,d4			;d4 = ABCDEFGHIJKLMNOP(idem avec') 6

	dbf	d7,.loop.pass1_C2P.020_030.1.1.256c

** Seconde partie de la conversion

	lea	CnkScreen,a0
	not.l	d6

** Demarage de la seconde boucle et fin de la premiere

	move.l	(a0)+,d0
	and.l	d6,d0
	lsl.l	#4,d0
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d0			;d0 = AEBFCGDH 4321

	move.l	(a0)+,d1
	and.l	d6,d1
	lsl.l	#4,d1
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d1			;d1 = IMJNKOLP 4321

	move.l	(a0)+,d2
	and.l	d6,d2
	lsl.l	#4,d2
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d2			;d2 = A'E'B'F'C'G'D'H' 4321

	move.l	(a0)+,d3
	and.l	d6,d3
	lsl.l	#4,d3
	move.l	(a0)+,d5

	move.l	d4,(320*256*1/8)(a1)

	and.l	d6,d5
	or.l	d5,d3			;d3 = I'M'J'N'K'O'L'P' 4321

	swap	d2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2			;d2 = CGDHC'G'D'H' 4321
	swap	d3			;d3 = KOLPK'O'L'P' 4321

	move.l	a4,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#2,d4

	move.l	a3,(a1)

	eor.l	d2,d4
	and.l	d5,d4
	eor.l	d4,d2			;d2 = ACEGBDFHA'C'E'G'B'D'F'H' 21
	lsr.l	#2,d4
	eor.l	d4,d0			;d0 = ACEGBDFHA'C'E'G'B'D'F'H' 43

	move.l	d1,d4
	lsl.l	#2,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = IKMOJLNPI'K'M'O'J'L'N'P' 21
	lsr.l	#2,d4
	eor.l	d4,d1			;d1 = IKMOJLNPI'K'M'O'J'L'N'P' 43

	move.l	a5,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#8,d4
	eor.l	d1,d4

	move.l	a2,(320*256*3/8)(a1)

	and.l	d5,d4
	eor.l	d4,d1			;d1 = BDFHJLNPB'D'F'H'J'L'N'P' 43
	lsr.l	#8,d4
	eor.l	d4,d0			;d0 = ACEGIKMOA'C'E'G'I'K'M'O' 43

	move.l	d2,d4
	lsl.l	#8,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = BDFHJLNPB'D'F'H'J'L'N'P' 21
	lsr.l	#8,d4
	eor.l	d4,d2			;d2 = ACEGIKMOA'C'E'G'I'K'M'O' 21

	move.l	a6,d5			;chargement du masque

	move.l	d0,d4
	add.l	d4,d4

	move.l	(Screen+4)(pc),a1

	eor.l	d1,d4
	and.l	d5,d4
	eor.l	d4,d1			;d1 = ABCDEFGHIJKLMNOP(idem avec') 3

	move.l	d1,(320*256*2/8)(a1)

	lsr.l	#1,d4
	eor.l	d4,d0			;d0 = ABCDEFGHIJKLMNOP(idem avec') 4

	move.l	d2,d4

	move.l	d0,a2

	add.l	d4,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = ABCDEFGHIJKLMNOP(idem avec') 1
	lsr.l	#1,d4

	move.l	d3,a3

	eor.l	d2,d4			;d4 = ABCDEFGHIJKLMNOP(idem avec') 2

	move.w	Size,d7

	CALIGN

.loop.pass2_C2P.020_030.1.1.256c:
	move.l	(a0)+,d0
	and.l	d6,d0
	lsl.l	#4,d0
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d0			;d0 = AEBFCGDH 4321

	move.l	(a0)+,d1
	and.l	d6,d1
	lsl.l	#4,d1
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d1			;d1 = IMJNKOLP 4321

	move.l	(a0)+,d2
	and.l	d6,d2
	lsl.l	#4,d2
	move.l	(a0)+,d5
	and.l	d6,d5
	or.l	d5,d2			;d2 = A'E'B'F'C'G'D'H' 4321

	move.l	(a0)+,d3
	and.l	d6,d3
	lsl.l	#4,d3
	move.l	(a0)+,d5

	move.l	d4,(320*256*1/8)(a1)

	and.l	d6,d5
	or.l	d5,d3			;d3 = I'M'J'N'K'O'L'P' 4321

	swap	d2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2			;d2 = CGDHC'G'D'H' 4321
	swap	d3			;d3 = KOLPK'O'L'P' 4321

	move.l	a4,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#2,d4

	move.l	a3,(a1)+

	eor.l	d2,d4
	and.l	d5,d4
	eor.l	d4,d2			;d2 = ACEGBDFHA'C'E'G'B'D'F'H' 21
	lsr.l	#2,d4
	eor.l	d4,d0			;d0 = ACEGBDFHA'C'E'G'B'D'F'H' 43

	move.l	d1,d4
	lsl.l	#2,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = IKMOJLNPI'K'M'O'J'L'N'P' 21
	lsr.l	#2,d4
	eor.l	d4,d1			;d1 = IKMOJLNPI'K'M'O'J'L'N'P' 43

	move.l	a5,d5			;chargement du masque

	move.l	d0,d4
	lsl.l	#8,d4
	eor.l	d1,d4

	move.l	a2,(320*256*3/8-4)(a1)

	and.l	d5,d4
	eor.l	d4,d1			;d1 = BDFHJLNPB'D'F'H'J'L'N'P' 43
	lsr.l	#8,d4
	eor.l	d4,d0			;d0 = ACEGIKMOA'C'E'G'I'K'M'O' 43

	move.l	d2,d4
	lsl.l	#8,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = BDFHJLNPB'D'F'H'J'L'N'P' 21
	lsr.l	#8,d4
	eor.l	d4,d2			;d2 = ACEGIKMOA'C'E'G'I'K'M'O' 21

	move.l	a6,d5			;chargement du masque

	move.l	d0,d4
	add.l	d4,d4
	eor.l	d1,d4
	and.l	d5,d4
	eor.l	d4,d1			;d1 = ABCDEFGHIJKLMNOP(idem avec') 3

	move.l	d1,(320*256*2/8)(a1)

	lsr.l	#1,d4
	eor.l	d4,d0			;d0 = ABCDEFGHIJKLMNOP(idem avec') 4

	move.l	d2,d4

	move.l	d0,a2

	add.l	d4,d4
	eor.l	d3,d4
	and.l	d5,d4
	eor.l	d4,d3			;d3 = ABCDEFGHIJKLMNOP(idem avec') 1
	lsr.l	#1,d4

	move.l	d3,a3

	eor.l	d2,d4			;d4 = ABCDEFGHIJKLMNOP(idem avec') 2

	dbf	d7,.loop.pass2_C2P.020_030.1.1.256c

	move.l	d4,(320*256*1/8)(a1)
	move.l	a3,(a1)
	move.l	a2,(320*256*3/8)(a1)

	rts



;-------------------------------------------------
;-                                               -
;-      Initilisation du C2P pour 040 et 060     -
;-                                               -
;-------------------------------------------------
;- d0 ---> Size of the Chunky screen             -
;-------------------------------------------------

		cnop	0,8

Init.C2P.040_060.1.1.256c:
	lea	CnkScreen,a0
	lea	(a0,d0.l),a1
	move.l	a1,smc.c2p+2

	move.l	ExecBase.w,a6
	jsr	CacheClearU(a6)

	rts



;-------------------------------------------------
;-                                               -
;-      Routine de Conversion d'une fenetre      -
;-          Chunky de 320*256 en 8 plans         -
;-                pour 040 et 060                -
;-                                               -
;-------------------------------------------------

		cnop	0,16

C2P.040_060.1.1.256c:
	lea	CnkScreen,a0
	move.l	(Screen+4)(pc),a1
	lea	(a1,40960.l),a2

** Demarage de la boucle

	move.l	(a0),d0
	move.l	8(a0),d2
	move.l	16(a0),d4
	move.l	24(a0),d6

	MERGEw	d0,d4
	MERGEw	d2,d6

	MERGE	d0,d2,d5,#$00ff00ff,8
	MERGE	d4,d6,d5,#$00ff00ff,8

	move.l	4(a0),d1
	move.l	12(a0),d3
	move.l	20(a0),d5
	move.l	28(a0),d7

	MERGEw	d1,d5
	MERGEw	d3,d7

	move.l	d6,a6				;a6=d6
	add.l	#32,a0

	MERGE	d1,d3,d6,#$00ff00ff,8
	MERGE	d5,d7,d6,#$00ff00ff,8

	MERGE	d0,d1,d6,#$0f0f0f0f,4
	MERGE	d2,d3,d6,#$0f0f0f0f,4
	MERGE	d4,d5,d6,#$0f0f0f0f,4

	exg	d3,a6				;a6=d3;d3=d6

	MERGE	d3,d7,d6,#$0f0f0f0f,4

	MERGE	d0,d4,d6,#$33333333,2
	MERGE	d2,d3,d6,#$33333333,2

	MERGE1	d0,d2,d6
	MERGE1	d4,d3,d6

	move.l	d0,(320*256*3/8)(a2)		;8

	exg.l	d3,a6				;a6=d6

	MERGE	d1,d5,d6,#$33333333,2
	MERGE	d3,d7,d6,#$33333333,2

	MERGE1	d1,d3,d6

	move.l	d1,(320*256*3/8)(a1)		;4

	MERGE1	d5,d7,d6

	move.l	d2,a3
	move.l	d4,a4
	move.l	d5,a5


	CALIGN

loop_C2P.040_060.1.1.256c:
	tst.w	0*16+15(a0)
	tst.w	2*16+15(a0)
	tst.w	4*16+15(a0)
	tst.w	6*16+15(a0)

	rept	4

	move.l	(a0),d0
	move.l	8(a0),d2
	move.l	16(a0),d4
	move.l	24(a0),d6

	MERGEw	d0,d4
	MERGEw	d2,d6

	move.l	d3,(320*256*2/8)(a1)		;3

	MERGE	d0,d2,d5,#$00ff00ff,8
	MERGE	d4,d6,d5,#$00ff00ff,8

	move.l	4(a0),d1
	move.l	12(a0),d3
	move.l	20(a0),d5

	add.l	#32,a0

	move.l	d7,(a1)+			;1

	move.l	-4(a0),d7

	MERGEw	d1,d5
	MERGEw	d3,d7

	move.l	a6,(a2)+			;5
	move.l	d6,a6				;a6=d6

	MERGE	d1,d3,d6,#$00ff00ff,8
	MERGE	d5,d7,d6,#$00ff00ff,8

	move.l	a5,(320*256*1/8-4)(a1)		;2

	MERGE	d0,d1,d6,#$0f0f0f0f,4
	MERGE	d2,d3,d6,#$0f0f0f0f,4

	move.l	a4,(320*256*1/8-4)(a2)		;6

	MERGE	d4,d5,d6,#$0f0f0f0f,4

	exg	d3,a6				;a6=d3;d3=d6

	MERGE	d3,d7,d6,#$0f0f0f0f,4

	MERGE	d0,d4,d6,#$33333333,2

	move.l	a3,(320*256*2/8-4)(a2)		;7

	MERGE	d2,d3,d6,#$33333333,2

	MERGE1	d0,d2,d6
	MERGE1	d4,d3,d6

	move.l	d0,(320*256*3/8)(a2)		;8

	exg.l	d3,a6				;a6=d6

	MERGE	d1,d5,d6,#$33333333,2
	MERGE	d3,d7,d6,#$33333333,2

	MERGE1	d1,d3,d6

	move.l	d1,(320*256*3/8)(a1)		;4

	MERGE1	d5,d7,d6

	move.l	d2,a3
	move.l	d4,a4
	move.l	d5,a5

	endr

smc.c2p:
	cmp.l	#$0BADC0DE,a0
	blt	loop_C2P.040_060.1.1.256c

;	move.l	d3,(320*256*2/8)(a1)		;3
;	move.l	d7,(a1)+			;1
;	move.l	a6,(a2)+			;5
;	move.l	a5,(320*256*1/8-4)(a1)		;2
;	move.l	a4,(320*256*1/8-4)(a2)		;6
;	move.l	a3,(320*256*2/8-4)(a2)		;7

	rts
