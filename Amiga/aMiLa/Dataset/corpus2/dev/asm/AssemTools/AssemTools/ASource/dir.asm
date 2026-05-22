
; Directoryn latausohjelma (C) 1988 by TM


	include	"jmplibs.i"
	include	"numeric.i"
	include	"exec/types.i"
	include	"dos.i"
	include	"exec.xref"
	include	"dos.xref"

BUFFER	equ	16384			;Puskurin koko
FIB	equ	260			;FileInfoBlockin koko


; P‰‰ohjelma

begin	openlib	Dos,clean		;Avaa Dos

	move.l	#BUFFER+FIB,d0		;Tavum‰‰r‰
	moveq	#0,d1			;Tyyppi
	lib	Exec,AllocMem		;Varaa muistia
	move.l	d0,mem			;Tallenna osoite
	beq	clean			;Ei muistia: virhe

	move.l	mem(pc),a0		;Jaa muisti
	move.l	a0,buffer		; nimipuskurin
	lea	BUFFER(a0),a0		; ja
	move.l	a0,fib			; FileInfoBlockin kesken

	bsr	asknam			;Kysy hakemiston nimi
	bsr	loaddir			;Lataa hakemisto
	bsr	typedir			;Tulosta hakemisto

clean	move.l	mem(pc),d0
	beq	clean1			;Muistia ei oltu saatu; ei vapauteta
	move.l	d0,a1			;Osoitin
	move.l	#BUFFER+FIB,d0		;Tavum‰‰r‰
	lib	Exec,FreeMem		;Vapauta muisti
	clr.l	buffer

clean1	closlib	Dos			;Sulje Dos
	moveq	#0,d0
	rts				;Poistu


; Aliohjelmat

asknam	print	<'Hakemiston nimi: '>	;Tulosta kysymys
	lib	Dos,Input		;Input File Handle
	move.l	d0,d1			;-> d1
	lea	inpbuf(pc),a0		;Puskurin osoite
	move.l	a0,d2			;-> d2
	moveq	#40,d3			;Maksimipituus -> d3
	lib	Dos,Read
	move.l	d2,a0
	clr.b	-1(a0,d0.l)		;Loppuun NULL
	rts

print10	push	all			;T‰m‰ tulostaa 10-j‰rjestelm‰n
	lea	inpbuf(pc),a0		; luvun D0:sta.
	numlib	put10
	lea	inpbuf(pc),a0
	printa	a0
	pull	all
	rts

loaddir	move.l	buffer(pc),a2		;Puskurin osoite
	clr.b	(a2)
	moveq.l	#0,d7			;Nollataan yhteispituus
	lea	inpbuf(pc),a0		;Nimen osoite
	move.l	a0,d1			;-> d1
	moveq	#ACCESS_READ,d2
	lib	Dos,Lock		;Lockataan hakemisto
	move.l	d0,lock
	bne	lddir1			;Ei virhett‰
	print	<'Ei onnistu!',10>	;Virhe, valita
	rts
lddir1	move.l	lock(pc),d1		;Lock
	move.l	fib(pc),d2		;FileInfoBlock
	lib	Dos,Examine		;Saadaan hakemiston tiedot
	move.l	d2,a0			;fib -> a0
	tst.l	fib_DirEntryType(a0)	;Nimen tyyppi
	bpl	lddir2			;Directory, jatketaan
	print	<'T‰m‰h‰n on tiedosto!',10>
	bra	lddir6			;t‰m‰ on tiedosto -> poistutaan

lddir2	move.l	lock(pc),d1		;Lock
	move.l	fib(pc),d2		;FileInfoBlock
	lib	Dos,ExNext		;Ensimm‰inen nimi
	tst.l	d0
	beq	lddir6			;->Nimet loppuivat
	move.l	d2,a0			;fib -> a0
	add.l	fib_Size(a0),d7		;lis‰t‰‰n yhteispituuteen
	lea	fib_FileName(a0),a1	;Nimen osoite -> a1
lddir3	move.b	(a1)+,(a2)+		;Nimi puskuriin
	bne	lddir3
	tst.l	fib_DirEntryType(a0)	;Nimen tyyppi
	bmi	lddir5			;Ei directory, lis. vain rivinvaihto
	subq.l	#1,a2			;Nimi ei lopukaan
	lea	text1(pc),a1
lddir4	move.b	(a1)+,(a2)+		;Lis‰‰ nimeen " (dir)"
	bne	lddir4
lddir5	move.b	#10,-1(a2)		;Lis‰‰ nimen loppuun rivinvaihto...
	clr.b	(a2)+			; ja nolla
	bra	lddir2			;Seuraava nimi
lddir6	clr.b	(a2)			;Lis‰‰ puskurin loppuun ylim. NULL
	move.l	lock(pc),d1
	lib	Dos,UnLock		;Vapauta Lock
	move.l	d7,len			;Tallenna yhteispituus
	rts

typedir	move.l	buffer(pc),a2		;Puskurin alkuosoite
typdir1	move.l	a2,a0
	tst.b	(a0)			;Lis‰‰ nimi‰?
	beq	typdir3			;Ei, lopeta
	printa	a0			;Tulosta teksti
typdir2	tst.b	(a2)+			;Etsi nimen loppu
	bne	typdir2
	bra	typdir1			;Seuraava
typdir3	print	<10,'Tiedostojen yhteispituus on '>
	move.l	len(pc),d0
	bsr	print10
	print	<' tavua.',10>
	rts

	numlib				;luvuntulostusrutiinikirjasto

; Muuttujat

mem	dc.l	0	;varatun muistin alku
buffer	dc.l	0	;nimipuskurin osoite
fib	dc.l	0	;FileInfoBlock-osoitin
lock	dc.l	0	;Lock-osoitin
len	dc.l	0	;yhteispituus

inpbuf	ds.b	44	;v‰liaikainen puskuri


; Tekstit

text1	dc.b	' (dir)',0
text2	dc.b	10,0

	libnames
	end


