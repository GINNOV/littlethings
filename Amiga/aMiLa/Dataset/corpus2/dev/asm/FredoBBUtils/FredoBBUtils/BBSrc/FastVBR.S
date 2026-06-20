; FastVBR - transférer le contenu du vecteur VBR en mémoire FAST
; Nécessite un MC68010 ou + ainsi que de la mémoire FAST

FastVBR:
	move.l	#$400,d0
	moveq	#4!1,d1		;fast!public
	move.l	4.w,a6
	jsr	-198(a6)	;AllocMem()
	move.l	d0,a3
	move.l	a3,d0
	beq.s	.no_fast
	move.l	a3,a4

; copy system vectors into fast ram
	suba.l	a0,a0
	move	#($400/4)-1,d0
.cop	move.l	(a0)+,(a3)+
	dbf	d0,.cop

	lea	.put_vbr(pc),a5
	jsr	-30(a6)		;Supervisor()
.no_fast
	rts

.put_vbr
; put fast ram system vectors adress into VBR register
	movec	a4,VBR
	rte
