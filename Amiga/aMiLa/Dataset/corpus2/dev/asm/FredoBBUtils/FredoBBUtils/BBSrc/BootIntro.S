*** Code d'un bootblock installé par BOOTINTRO 1.0 (de Roger Fischlin)

start
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-96(a6)		;findresident()
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	movem.l	d0-a6,-(a7)
*** allouer mémoire pour les variables, les bitplanes & la copperlist
	move.l	#$2ee0,d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)	;allocmem()

	lea	lb_02c0(pc),a4
	move.l	d0,(a4)
	beq.w	lb_0248

	add.l	#1500,d0
	move.l	d0,4(a4)
	jsr	-$84(a6)	;forbid()
	move.l	(a4),a1
*** adresse des bitplanes dans la copperlist
	move	#$e0,(a1)+
	move.l	4(a4),d0
	swap	d0
	move	d0,(a1)+
	move	#$e2,(a1)+
	swap	d0
	move	d0,(a1)+
*** construire les rasters (dégradés de couleur)
	move.l	#$01800000,(a1)+	;couleur0
	move.l	#$01820fff,(a1)+	;couleur1
	moveq	#60,d0		;ystart
	moveq	#$001,d1	;valeur rgb de départ
	bsr.w	lb_0260		;construit raster
	move	#135,d0		;ystart
	move	#$111,d1	;valeur rgb...
	bsr.w	lb_0260
	move	#210,d0
	move	#$100,d1
	bsr.w	lb_0260
	move.l	#$fffffffe,(a1)+	;fin de la liste copper
	lea	$dff000,a5
	move	#$03e0,$0096(a5)	;bloquer dma
	move.l	(a4),$80(a5)
	clr	$88(a5)
	move.l	#$298129c1,$8e(a5)
	move.l	#$003800d0,$92(a5)
	clr	$102(a5)
	clr	$104(a5)
	clr	$108(a5)
	move	#$1000,$100(a5)
	move	#$8380,$96(a5)		;start dma
	lea	gfxname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		;openlibrary()
	move.l	d0,a6
	lea	topaz.textattr(pc),a0
	jsr	-72(a6)			;openfont()
	move.l	d0,8(a4)
	move.l	4(a4),a3
	moveq	#0,d0
	lea	2610(a3),a3

	lea	titre(pc),a5
lb_0114	move.l	8(a4),a2	;struct *textfont
	move.l	34(a2),a2	;aptr tf_chardata
	move.b	(a5)+,d0	;caractère du titre en d0
	beq.b	lb_016a		;nul?
	cmp.b	#$7f,d0
	bls.b	lb_012e
	sub.b	#$20,d0
lb_012e	sub.b	#$20,d0
	add.l	d0,a2
	move.b	(a2),(a3)
	move.b	$00c0(a2),$0050(a3)
	move.b	$0180(a2),$00a0(a3)
	move.b	$0240(a2),$00f0(a3)
	move.b	$0300(a2),$0140(a3)
	move.b	$03c0(a2),$0190(a3)
	move.b	$0480(a2),$01e0(a3)
	move.b	$0540(a2),$0230(a3)
	addq.l	#1,a3
	bra.b	lb_0114

*** boucle principale: scrolling

lb_016a	lea	scrolltext(pc),a5
	moveq	#0,d5
mainloop
lb_0170
	moveq	#7,d4
	and.l	d4,d5
	bne.b	lb_01aa
	move.l	8(a4),a2	;textfont
	move.l	34(a2),a2	;tf_chardata
	lea	1344(a2),a2
	moveq	#0,d0
lb_018a	move.b	(a5)+,d0
	bne.b	lb_0198
	lea	scrolltext(pc),a5
	bra.b	lb_018a
lb_0198
	cmp.b	#$7f,d0
	bls.b	lb_01a4
	sub.b	#$20,d0
lb_01a4
	sub.b	#$20,d0
	add.l	d0,a2
lb_01aa	or.b	#8,d5
	move.l	4(a4),a0
	lea	$1888(a0),a0
	moveq	#$07,d1
	move.l	a2,a1
*** attendre le prochain vertblank
lb_01c0
	move.w	$dff006,d0	;vposr (position verticale du faisceau)
	lsr	#8,d0
	cmp	#80,d0
	bhi.b	lb_01c0
lb_01ce	moveq	#20-1,d0	;hauteur du caractère
	moveq	#0,d2
	move.b	(a1),d2
	roxl	#1,d2
	roxl	d5,d2
	lea	-192(a1),a1
lb_01e2	roxl	-(a0)
	dbf	d0,lb_01e2
	lea	-40(a0),a0
	dbf	d1,lb_01ce
	move.l	#3584,d0
lb_01f8	dbf	d0,lb_01f8
	addq	#1,d5

	btst	#$06,$00bfe001
	bne.b	mainloop
*** ouvrir gfxlib & restaurer liste copper
	lea	gfxname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)	;openlibrary()
	move.l	d0,a0
	lea	$00dff000,a5
	move.l	38(a0),$80(a5)	;liste copper système
	clr	$88(a5)
	move	#$8060,$96(a5)
	move.l	(a4),a1
*** libérer buffer
	move.l	#$2ee0,d0
	move.l	4.w,a6
	jsr	-$d2(a6)	;freemem()
	jsr	-$8a(a6)	;permit()
lb_0248	movem.l	(a7)+,d0-a6
	rts	
lb_0260
	moveq	#0,d2
	moveq	#14,d3
	lsl	#8,d0
	or.b	#$0f,d0
lb_0270	add	d1,d2
	move	d0,(a1)+
	move.l	#$fffe0180,(a1)+
	move	d2,(a1)+
	add	#$100,d0
	dbf	d3,lb_0270
	moveq	#14,d3
lb_028a	sub	d1,d2
	move	d0,(a1)+
	move.l	#$fffe0180,(a1)+
	move	d2,(a1)+
	add	#$100,d0
	dbf	d3,lb_028a
	rts	
lb_02c0	ds.l	4
topaz.textattr
	dc.l	topaz.name
	dc.w	8
	dc.b	0
	dc.b	0
topaz.name
	dc.b	"topaz.font",0
gfxname	dc.b	"graphics.library",0
dosname	dc.b	"dos.library",0

titre
 DC.B	"BootIntro V1.0",0
scrolltext
 dc.b	"Bonjour tout le monde ! Comment ca va??"
 dc.b	"                    ",0

End:
