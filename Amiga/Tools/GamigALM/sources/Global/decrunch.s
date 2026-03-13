
	OPT	O+

RELOCATOR_ADDR:	equ	$0100
PROGRAM_ADDR:	equ	$0400

RELOC:
	move.w	#$7fff,d0
	move.w	d0,$dff096
	move.w	d0,$dff09a
	move.w	d0,$dff09e
	clr.w	$dff180

	lea	RELOC_START(pc),a0
	lea	FILE(pc),a1
	lea	RELOCATOR_ADDR,a2
	move.l	a2,$80.w
.loop	move.w	(a0)+,(a2)+
	cmp.l	a0,a1
	bne.s	.loop

	trap	#0

RELOC_START:
	move.w	#$2700,sr

	lea	PROGRAM_ADDR,a7

	add.l	#FILE_END-FILE,a1
	lea	$80000,a2

	cmp.l	a1,a2
	bcs.s	.no_reloc

.loop:	move.w	-(a1),-(a2)	* Adresse Source
	cmp.l	a0,a1
	bne.s	.loop
	move.l	a2,a0
.no_reloc:	move.l	a0,a1

	lea	PROGRAM_ADDR,a0	* Adresse Destination

	move.l	a0,a3
	move.l	(a1)+,a2	* Longueur Fichier Destination
	add.l	a2,a3	* Fin Destination

	moveq	#32,d3
	moveq	#%11111,d4
	move.w	#%1111111111111,d5
	moveq	#34,d6

	move.b	(a1)+,d7	* Most Repeated Byte

********************************************************************************
*	Boucle Principale                                          *
********************************************************************************

LOOP:	moveq.l	#0,d0
	move.b	(a1)+,d0	* Prochain Byte Controle
	btst.l	#7,d0	* Séquence ???
	bne	SEQUENCE
	btst.l	#6,d0	* Bloc Non Crunché ou Répétition Court(e) ???
	beq.s	SMALL_LENGHT

********************************************************************************
*	Bloc Non Crunché ou Répétition Long(ue)                    *
********************************************************************************

	btst.l	#5,d0	* Bloc ou Répétition ???
	beq.s	.block

	lsl.w	#8,d0
	or.b	(a1)+,d0	* Longueur Bloc ou Répétition sur 13 bits
	and.w	d5,d0	* Eliminer Bits Contrôle

	bclr.l	#8+4,d0
	beq.s	.repeat_next_byte

	add.w	#17,d0
.repeat1:	move.b	d7,(a0)+	* Longue Répétition d'un Caractère
	dbra	d0,.repeat1
	cmp.l	a0,a3	* Fin ???
	bgt.s	LOOP
	bra	END
	
.repeat_next_byte:	add.w	#17,d0
	move.b	(a1)+,d1	* Caractère à Recopier
.repeat2:	move.b	d1,(a0)+	* Longue Répétition d'un Caractère
	dbra	d0,.repeat2
	cmp.l	a0,a3	* Fin ???
	bgt.s	LOOP
	bra	END

.block:	lsl.w	#8,d0
	or.b	(a1)+,d0	* Longueur Bloc ou Répétition sur 13 bits
	and.w	d5,d0	* Eliminer Bits Contrôle
	add.w	d3,d0

.block_loop:	move.b	(a1)+,(a0)+	* Recopie Long Bloc
	dbra	d0,.block_loop
	cmp.l	a0,a3	* Fin ???
	bgt.s	LOOP
	bra	END

********************************************************************************
*	Bloc Non Crunché ou Répétition Court(e)                    *
********************************************************************************

SMALL_LENGHT:
	btst.l	#5,d0	* Bloc ou Répétition ???
	beq.s	.block

	and.w	d4,d0	* Longueur Bloc ou Répétition sur 5 bits
			* Eliminer Bits Contrôle

	bclr.l	#4,d0
	beq.s	.repeat_next_byte

	move.b	d7,(a0)+
.repeat1:	move.b	d7,(a0)+	* Longue Répétition d'un Caractère
	dbra	d0,.repeat1
	cmp.l	a0,a3	* Fin ???
	bgt	LOOP
	bra.s	END
	
.repeat_next_byte:	move.b	(a1)+,d1	* Caractère à Recopier
	move.b	d1,(a0)+
.repeat2:	move.b	d1,(a0)+	* Longue Répétition d'un Caractère
	dbra	d0,.repeat2
	cmp.l	a0,a3	* Fin ???
	bgt	LOOP
	bra.s	END

.block:	and.w	d4,d0	* Longueur Bloc ou Répétition sur 5 bits
			*   Et Eliminer Bits Contrôle
.block_loop:	move.b	(a1)+,(a0)+	* Recopie Bloc Court
	dbra	d0,.block_loop
	cmp.l	a0,a3	* Fin ???
	bgt	LOOP
	bra.s	END

********************************************************************************
*	Recopier Séquence                                          *
********************************************************************************

SEQUENCE:
	btst.l	#6,d0	* Séquence Courte ???
	beq.s	.small_x
	move.b	d0,d1
	lsl.w	#8,d1
	or.b	(a1)+,d1	* Longueur Séquence 13 bits
	and.w	d5,d1	* Eliminer Bits Contrôle
	add.w	d6,d1	* Ajouter Longueur Minimum
	bra.s	.read_y	* Aller Lire Offset
.small_x:	move.b	d0,d1	* Longueur Séquence 5 bits
	and.w	d4,d1	* Eliminer Bits Contrôle
	addq.w	#2,d1	* Ajouter Longueur Minimum

.read_y:	btst.l	#5,d0	* Offset Proche ???
	beq.s	.small_y
	moveq.l	#0,d2
	move.b	(a1)+,d2
	lsl.w	#8,d2
	or.b	(a1)+,d2	* Offset Fin Séquence 16 Bits
	lea	-257(a0),a4
	sub.l	d2,a4
	sub.w	d1,a4	* Adresse Début Séquence
.copy_seq1:	move.b	(a4)+,(a0)+	* Copier Séquence
	dbra	d1,.copy_seq1
	cmp.l	a0,a3	* Fin ???
	bgt	LOOP
	bra.s	END

.small_y:	moveq.l	#0,d2
	move.b	(a1)+,d2	* Offset Fin Séquence 8 Bits
	lea	-1(a0),a4
	sub.w	d2,a4
	sub.w	d1,a4	* Adresse Début Séquence
.copy_seq2:	move.b	(a4)+,(a0)+	* Copier Séquence
	dbra	d1,.copy_seq2
	cmp.l	a0,a3	* Fin ???
	bgt	LOOP

********************************************************************************
*	Sortie Routine Decrunch                                    *
********************************************************************************

END:	jmp	PROGRAM_ADDR
RELOC_END:

FILE:	incbin	dh0:ag_demo_bin/intro.crn
FILE_END:	EVEN

