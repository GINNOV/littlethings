ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;Merge les polygones
;Revdate: 17.2.03
;Ostyl of Mankind!
;>a0	*struct lwobj

	INCLUDE	INCLUDES:POWERPC/GRAPHICSPPC.i

	XDEF	MergePolygons

MergePolygons
	Move.L	a0,a5
	Move.L	lwo_PolygonsPTR(a5),a0
	Move.L	lwo_Transforms+nobj_MergeList(a5),a1
	Move	lwo_TotalPolygons(a5),d3
	Move	lwo_TotalVertices(a5),d5	
	Subq	#1,d5
	Bmi.B	Erreur

	Tst.L	a1
	Beq.B	Erreur

	Moveq	#0,d0

;--------------------------------
;--------------------------------
;Recherche tous le polygones 
;appartenant à ce point
;
Recherche
	Movem.L	d3/a0,-(sp)
	Moveq	#0,d1
	Subq	#1,d3

;sauve l'adresse ou se trouvera le
;nombre de polygones
;>a1	tableau de destination
;a2>	case memoire du nombre de polygones
;
	Move.L	a1,a2
	Addq.L	#2,a1		;reserve 2 octets

CompteurPoly	EQUR	d4

	Moveq	#0,CompteurPoly
	
;boucle des polygones
;>a0	adresse du polygone
;d2>	nombre de points (triangle=3)
;
LoopPoly
	Move	(a0)+,d2
	Cmp	#3,d2
	Bne.B	Erreur
	Subq.L	#1,d2

;-----------------------------
	
;boucle des points	
;>a0	adresse du polygone
;>a1	adresse destination
;>d1	numero du polygone courrant
;
LoopPnt	Cmp	(a0)+,d0
	Bne.B	ProchainPoint
	Move	d1,(a1)+	;sauve le numéro du polygone
	Addq.L	#1,CompteurPoly
ProchainPoint
	Dbf	d2,LoopPnt
;-----------------------------

	Addq.L	#2,a0		;on zap l'index de lightwave

	Addq.L	#1,d1		;polygone suivant	
	Dbf	d3,LoopPoly

	Move	CompteurPoly,(a2)
	Addq.L	#1,d0		;prochain sommet
	Movem.L	(sp)+,d3/a0
	Dbf	d5,Recherche

	Move.L	lwo_Transforms+nobj_MergeList(a5),d0
	Rts

Erreur	Moveq	#0,d0
	Rts
