ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;Radix sort
;Revdate: 28.2.03
;Ostyl of Mankind! 
;a0 = *struct lwobj

	INCDIR	INCLUDES:
	INCLUDE	HARDWARE/FPUBITS.i
	INCLUDE	POWERPC/GRAPHICSPPC.i

	XDEF	SortPolyList
	XDEF	TriZAverage

SortPolyList:
	Bsr.W	TriZAverage
	Move.L	lwo_Transforms+nobj_SortList(a0),a1
	Move.L	lwo_Transforms+nobj_PolyZMoyList(a0),a0
	Moveq	#0,d0
	Move	(a1)+,d0
	Beq.B	Stop
	Bsr.B	XorSignBit
	Bsr.B	ubsort
	Bsr.B	XorSignBit
Stop	Rts

	;----

XorSignBit
	Movem.L	d1-d2/a1,-(sp)
	Move.L	d0,d1
	Move.L	a0,a1
	Subq	#1,d1
	Move	#$8000,d2
XorLoop	Eor	d2,(a1)+
	Dbf	d1,XorLoop
	Movem.L	(sp)+,d1-d2/a1
	Rts

	;----

ubsort	Movem.L	d0-d3/a0/a1/a4/a5,-(sp)
	Move.L	a0,a4
	Move.L	a1,a5

;a0 = a4 = PTR sur liste des Z
;a1 = a5 = PTR sur poly.index

	Subq.L	#1,d0
	Add.L	d0,d0		;d0 = (nombre d'éléments - 1) * 2
	Move.L	d0,a1
	Add.L	a0,a1		;a1 = PTR sur la fin de la liste des Z
	Moveq	#15,d0		;d0 = pour bit-test (bit 15)
	Bsr.B	Sort
	Movem.L	(sp)+,d0-d3/a0/a1/a4/a5
	Rts

	;----

Sort	Movem.L	a2/a3,-(sp)
	Move.L	a0,a2		;a0 = a2 = PTR sur liste des Z
	Move.L	a1,a3		;a1 = a3 = PTR sur la fin de la liste des Z

Loop	Move	(a2),d1		;d1 = Z (à partir du début)
	Btst	d0,d1		;test le signe de Z
	Beq.B	CountUp		;si SignBit=1 -> Z est positif -> CountUp

	;---- Z est négatif

CountDown
	Cmp.L	a2,a3
	Bls.B	J2
	Move	(a3),d2		;d2 = Z (à partir de la fin)
	Btst	d0,d2		;test le signe de Z

;Déplacement des Z positif en debut de liste
;-> Z(d1) est négatif
;si Z(d2) est positif => Swap
;si Z(d2) est aussi négatif => Prochain Z (à partir de la fin)

	Beq.S	Swap
	Subq.L	#2,a3		;a3 = fin de la liste Z - 2
    	Bra.B	CountDown

	;---- Z est positif

CountUp	Addq.L	#2,a2		;Prochain Z
	Cmpa.L	a3,a2		;DébutListeZ = FinListeZ ?
	Bls.B	Loop		;Non => Loop
	Bra.B	J1


	;---- SWAP Z & INDEX ----

Swap	Move	d1,(a3)			;SWAP LES Z
	Move	d2,(a2)			;
	Move.L	a2,d2
	Sub.L	a4,d2		
;	Add.L	d2,d2			;d2 = (PTR_DebutListeZ - PTR_ListeZSupérieur) * 2
	Move.L	a3,d3
	Sub.L	a4,d3
;	Add.L	d3,d3			;d3 = (PTR_DebutListeZ - PTR_ListeZInférieur) * 2
	Move	(a5,d2.L),d1		;SWAP LES INDEXS
	Move	(a5,d3.L),(a5,d2.L)	;
	Move	d1,(a5,d3.L)		;
	Addq.L	#2,a2
	Subq.L	#2,a3
	Cmp.L	a2,a3
	Bge.B	Loop

	;----

J1	Addq.L	#2,a3		;PTR2 Fin liste des Z + 2
J2	Subq.L	#2,a2		;PTR2 liste des Z - 2

BitSorted
	Tst.B	d0		
	Beq.B	Return		;bit 0 atteind => FIN
	Subq.B	#1,d0		;num.bit - 1


	;---- Sort The Higher

SortTheHigher
	Cmp.L	a0,a2
	Ble.B	SortTheLower
	Exg.L	a1,a2		;Echange PTR ZList<->ZFinList
	Bsr.B	Sort
	Exg.L	a1,a2		;Echange PTR ZList<->ZFinList

	;---- Sort The Lower
	
SortTheLower
	Cmp.L	a1,a3
	Bge.B	Fin
	Move.L	a0,d1
	Exg.L	a0,a3		;Echange PTR ZList<->ZFinList
	Bsr.B    Sort
	Exg.L	a0,a3		;Echange PTR ZList<->ZFinList

Fin	Addq.B	#1,d0
Return	Movem.L	(sp)+,a2/a3
	Rts

;------------------------------------------------
;------------------------------------------------
;Moyennage des Z aux sommets
;Revdate 18.2.03
;Ostyl of Mankind!
;a0 = *struct lwobj

X	EQU	0
Y	EQU	4
Z	EQU	8

TriZAverage:
	Move.L	a0,-(sp)
	
	Moveq	#FPUF_PRECS+FPUF_RDNGZ,d0
	FMove.L	d0,fpcr

	Move.L	a0,a3
	Move.L	lwo_Transforms+nobj_3dVertices(a3),a0
	Move.L	lwo_PolygonsPTR(a3),a1
	Move.L	lwo_Transforms+nobj_SortList(a3),a2
	Move.L	lwo_Transforms+nobj_PolyZMoyList(a3),a3

	Moveq	#0,d0	
	Move	(a2)+,d0
	Subq	#1,d0
	Bmi.B	Done
	
Loop2	Moveq	#0,d1
	Move	(a2)+,d1
	Moveq	#10,d2
	Mulu	d2,d1
	Lea	(a1,d1.L),a4		
	Lea	2(a4),a4
	Movem	(a4),d1-d3
	Moveq	#X+Y+Z,d4
	Mulu	d4,d1
	Mulu	d4,d2
	Mulu	d4,d3
	Move.L	Z(a0,d1.W),d4		;z1
	Add.L	Z(a0,d2.W),d4		;z2
	Add.L	Z(a0,d3.W),d4		;z3
	Asr.L	#2,d4
	Move	d4,(a3)+
	Dbf	d0,Loop2
Done	Move.L	(sp)+,a0
	Rts
