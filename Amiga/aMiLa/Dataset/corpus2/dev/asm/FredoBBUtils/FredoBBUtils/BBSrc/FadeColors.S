; Fondu vers une couleur donnee
; en entree:	A0 pointe sur une table de couleurs (qui sera modifiee)
;		A1 pointe sur la routine a executer
;		   pour le rafraichissement des couleurs
;		D0 contient le nombre de couleurs de cette table
;		D1 contient la valeur de la couleur d'arrivee (ex: $7ad)
; en sortie: rien
;
;----------------------------------------------------------------------------
; A little fading routine.
; Call with:
;	A0: address of a color table (dc.w $000,$fff,...)
;	A1: pointer to refresh routine
;	D0: number of colors in the color table
;	D1: value of the final color
;
; See the BootFade.S example.
;
FadePalette:
	movem.l	d1-d7/a4,-(sp)
	move	d1,d6
	moveq	#$f,d5		;compteur: nombre d'iterations
.debut
	move.l	a0,a4
	move.l	d0,d4
.coul_suiv
	tst	d0
	beq.s	.prochain_tour
	subq	#1,d0
	moveq	#0,d1
	move	(a0)+,d1
	cmp	d6,d1		;couleur d'arrivee?
	beq.s	.coul_suiv
.fade_coul
	move.b	d1,d3
	and.b	#$0f,d3		;composante bleue en d3
	lsr	#4,d1
	move.b	d1,d2
	and.b	#$0f,d2		;composante verte en d2
	lsr	#4,d1
;	and	#$000f,d1	;composante rouge en d1
.rouge
	move	d6,d7
	lsr	#8,d7
	and.b	#$0f,d7
	cmp.b	d7,d1
	beq.s	.vert
	blo.s	.r1
	subq.b	#1,d1
	bra.s	.vert
.r1	addq.b	#1,d1
.vert
	move	d6,d7
	lsr	#4,d7
	and.b	#$0f,d7
	cmp.b	d7,d2
	beq.s	.bleu
	blo.s	.v1
	subq.b	#1,d2
	bra.s	.bleu
.v1	addq.b	#1,d2
.bleu
	move	d6,d7
	and.b	#$0f,d7
	cmp.b	d7,d3
	beq.s	.save_coul
	blo.s	.b1
	subq.b	#1,d3
	bra.s	.save_coul
.b1	addq.b	#1,d3
.save_coul
	lsl	#8,d1
	lsl	#4,d2
	or	d2,d1
	or.b	d3,d1
	and	#$0fff,d1
	move	d1,-2(a0)	;sauver la nouvelle valeur RGB
	bra.s	.coul_suiv
.prochain_tour
	move.l	d4,d0		;nombre de couleurs
	move.l	a4,a0		;adresse de la table de couleurs

; Appel de la routine de rafraichissement de la palette
;  ex: Un WaitTOF() puis LoadRGB4() etc...

	jsr	(a1)

	dbf	d5,.debut
.fin
	movem.l	(sp)+,d1-d7/a4
	rts
