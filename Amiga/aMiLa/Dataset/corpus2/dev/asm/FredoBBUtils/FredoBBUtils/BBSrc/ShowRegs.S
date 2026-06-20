* Bootblock Spécial:	ShowRegs
* par Frédo	(Déc.94)
*
* Affiche le contenu des registres CPU au moment du boot
*
* Displays CPU registers' contents at boot time. (Not of great use!!)
* Coded a long time ago... NOT system friendly (trashes memory)
*
	rsreset
gfxbase	rs.l	1
MaxRow	rs.w	1
MaxCol	rs.w	1
Ysize	rs.w	1
Xsize	rs.w	1
cnt	rs.w	1
ctrflag	rs.b	1
VARSIZE	rs.w	0

Start:	dc.b	"DOS",0
	dc.l	0
	dc.l	$370	;rootblock
BLKBUF=$70000
REGS=BLKBUF-(16*4)
CIBLE=BLKBUF+$200
DATA=BLKBUF
Xstart=10

Main:
	movem.l	d0-a6,REGS
	movem.l	d0-a6,-(sp)
	lea	VARS(pc),a5
	move.l	4.w,a6
	move.l	$9c(a6),gfxbase(a5)
ShowRegs:
	lea	REGS,a0
	lea	DATA,a1
	moveq	#15,d0
.cop	move.l	(a0)+,(a1)+
	dbf	d0,.cop
	move.l	sp,(a1)+
	move	sr,(a1)+
	bsr.w	DoFmt
	lea	CIBLE,a0
	move.l	a0,a1
	add	cnt(a5),a1
	move.l	a1,d5		;ptr dest
Guru:
	movem.l	d5/a0/a1,-(sp)
	lea	intname(pc),a1
	move.l	4.w,a6
	jsr	-408(a6)
	movem.l	(sp)+,d5/a0/a1
	tst.l	d0
	beq.w	Init
	move.l	d0,a6

	move.l	gfxbase(a5),a2
	move.l	216(a2),MaxRow(a5)
	move.l	154(a2),a2
	move	20(a2),Ysize(a5)
	move	24(a2),Xsize(a5)

* Construire la mise en page des données texte
build
	moveq	#Xstart,d0	;position X de départ
	moveq	#12,d1		;pos Y de départ
	clr.l	d2
.bcl
	clr.b	(a1)+
	move.l	a1,a2
	move.b	d0,(a1)+
	move.b	d1,(a1)+
	add	Ysize(a5),d1	;proch. ligne
	clr.b	ctrflag(a5)
.coptx
	move.b	(a0)+,d7
	tst.b	d7		;0=fin
	beq.b	.end
	cmp.b	#$a,d7		;linefeed?
	beq.b	.nxt
	cmp.b	#1,d7		;centrer le texte?
	bne.b	.put
	st	ctrflag(a5)	;set flag
	bra.b	.coptx
.put
	move.b	d7,(a1)+	;copier octet
	add	Xsize(a5),d2	;ajter x pixels (1 caract.)
	bra.b	.coptx
.nxt
	bsr.b	Centre
	clr.b	(a1)+
	move.b	#1,(a1)+
	bra.b	.bcl
.end
	bsr.b	Centre
	clr.b	(a1)+		;0 de fin

* Produire l'alerte
myalert
	move.l	d5,a0
	moveq	#0,d0		;n°alerte
;	clr.l	d1
;	move	MaxRow(a5),d1	;Hauteur fenètre
	jsr	-90(a6)		;DisplayAlert()
	tst.l	d0
	bne.b	Reset

myCloseAll
	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)

	bra.b	Init

* Copier des données
Copy	move.b	(a0)+,(a1)+
	dbf	d0,Copy
	rts
Reset	move.l	#$f80000,$80.w
	trap	#0

* Centrer le texte
* <--	a2: adresse où on reportera la nouvelle Xpos
* 	d2: nbre de caractères de la ligne
Centre
	tst.b	ctrflag(a5)	;flag posé?
	beq.b	.f		;si non, alors exit
	sub	MaxCol(a5),d2
	not	d2
	asr	#1,d2		;div. /2
	move.b	d2,(a2)		;reporter Xpos
	clr.l	d2
.f	rts

* Convertir avec RawDoFmt()
* <-- a0: format string
*	a1: adr des données à convertir
*	a3: adr buffer cible
DoFmt:
	movem.l	d0-a6,-(sp)
	lea	VARS(pc),a5
	clr	cnt(a5)
	clr	d7
	lea	format(pc),a0
	lea	DATA,a1
	lea	.put(pc),a2
	lea	CIBLE,a3
	move.l	4.w,a6
	jsr	-522(a6)	;RawDoFmt()
	move	d7,cnt(a5)
	movem.l	(sp)+,d0-a6
	rts
.put	move.b	d0,(a3)+
	addq	#1,d7
	rts

Init:
	movem.l	(sp)+,d0-a6
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-96(a6)
	tst.l	d0
	beq.b	.err
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts
.err	moveq	#-1,d0
	rts

	even
VARS:		dcb.b VARSIZE,0
intname:	dc.b "intuition.library",0
gfxname:	dc.b "graphics.library",0
dosname:	dc.b "dos.library",0

format:		dc.b 1,"--- Contenu des Registres ---",$a,$a
		dc.b "d0: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx",$a
		dc.b "a0: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx",$a
		dc.b 1,"USP=%08lx SR=%04x",$a,$a
		dc.b 1,"LEFT = Reset  <Click Mouse>  Abort = RIGHT",0
End:
 blk.b 512*2,0
