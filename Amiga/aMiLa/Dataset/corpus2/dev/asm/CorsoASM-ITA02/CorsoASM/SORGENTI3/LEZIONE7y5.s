
; Lezione7y5.s	- Paesaggio fatto con 2 soli sprite che scorre

;       Questo esempio mostra come sia possibile generare una intera
;	schermata usando direttamente i registri di 2 sprite (il 6 e il 7)
;       La schermata viene inoltre "scrollata"


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Nome lib
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo la vecchia COP

;	Puntiamo un bitplane "vuoto" 

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	NON Puntiamo lo sprite !!!!!!!!!!!!!!!!!!!!


	move.l	#COPPERLIST,$dff080	; nostra COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!


mouse:
	cmpi.b	#$aa,$dff006	; Linea $aa?
	bne.s	mouse

	bsr.w	MuoviPaesaggio	; Fa scrorrere il paesaggio

Aspetta:
	cmpi.b	#$aa,$dff006	; linea $aa?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse


	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la vecchia cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0


; Questa routine fa scorrere i dati degli sprite che formano il paesaggio

MuoviPaesaggio:
	moveq	#14-1,d0	; numero di righe
	lea	FormaSprite,a0	; indirizzo primi dati dello sprite
PaeLoop:

; fa scorrere il piano A degli sprite

	move.w	(a0),d1		; legge valore di spr6data
	swap	d1		; lo mette nella word alta del registro
	move.w	8(a0),d1	; legge valore di spr7data

	ror.l	#1,d1		; fa scorrere i bit della forma degli sprite
	move.w	d1,8(a0)	; scrive valore di spr7data
	swap	d1		; scambia le word del registro
	move.w	d1,(a0)		; scrive valore di spr6data

; fa scorrere il piano B degli sprite

	move.w	4(a0),d1	; legge valore di spr6datb
	swap	d1		; lo mette nella word alta del registro
	move.w	12(a0),d1	; legge valore di spr7datb

	ror.l	#1,d1		; fa scorrere i bit della forma degli sprite
	move.w	d1,12(a0)	; scrive valore di spr7datb
	swap	d1		; scambia le word del registro
	move.w	d1,4(a0)	; scrive valore di spr6datb

	add.w	#140,a0		; prossima riga del paesaggio
	dbra	d0,PaeLoop

	rts



	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; bit 12 acceso!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,$000	; color0	; sfondo nero
	dc.w	$182,$123	; color1	; colore 1 del bitplane, che
						; in questo caso e' vuoto,
						; per cui non compare.

	dc.w	$01ba,$0fff		; colore 29
	dc.w	$01bc,$0aaa		; colore 30
	dc.w	$01be,$0753		; colore 31

; per comodita` usiamo dei simboli

spr6pos		= $170
spr6data	= $174
spr6datb	= $176
spr7pos		= $178
spr7data	= $17c
spr7datb	= $17e

; linea $50 - (le istruzioni copper per una linea sono lunghe 140 bytes)

	dc.w	$5025,$fffe	; Wait
	dc.w	spr6data
FormaSprite:			; Da questa label faremo gli offset per
	dc.w	$0		; raggiungere tutti gli altri sprxdat
	dc.w	spr6datb
	dc.w	$0
	dc.w	spr7data
	dc.w	$f000
	dc.w	spr7datb
	dc.w	$0
	dc.w	spr6pos,$40,spr7pos,$48,$504b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$505b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$506b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$507b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$508b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$509b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$50ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$50bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$50cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$50db,$fffe

; linea $51
	dc.w	$5125,$fffe
	dc.w	spr6data,$0001,spr6datb,$0000,spr7data,$b800,spr7datb,$4000
	dc.w	spr6pos,$40,spr7pos,$48,$514b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$515b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$516b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$517b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$518b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$519b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$51ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$51bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$51cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$51db,$fffe

; linea $52
	dc.w	$5225,$fffe
	dc.w	spr6data,$0003,spr6datb,$0000,spr7data,$bc00,spr7datb,$4000
	dc.w	spr6pos,$40,spr7pos,$48,$524b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$525b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$526b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$527b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$528b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$529b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$52ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$52bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$52cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$52db,$fffe

; linea $53
	dc.w	$5325,$fffe
	dc.w	spr6data,$0002,spr6datb,$0001,spr7data,$ec00,spr7datb,$1200
	dc.w	spr6pos,$40,spr7pos,$48,$534b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$535b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$536b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$537b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$538b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$539b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$53ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$53bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$53cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$53db,$fffe

; linea $54
	dc.w	$5425,$fffe
	dc.w	spr6data,$0007,spr6datb,$0000,spr7data,$2b00,spr7datb,$d400
	dc.w	spr6pos,$40,spr7pos,$48,$544b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$545b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$546b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$547b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$548b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$549b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$54ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$54bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$54cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$54db,$fffe

; linea $55
	dc.w	$5525,$fffe
	dc.w	spr6data,$001c,spr6datb,$0003,spr7data,$e780,spr7datb,$1800
	dc.w	spr6pos,$40,spr7pos,$48,$554b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$555b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$556b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$557b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$558b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$559b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$55ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$55bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$55cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$55db,$fffe

; linea $56
	dc.w	$5625,$fffe
	dc.w	spr6data,$803e,spr6datb,$0001,spr7data,$9ac1,spr7datb,$6500
	dc.w	spr6pos,$40,spr7pos,$48,$564b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$565b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$566b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$567b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$568b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$569b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$56ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$56bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$56cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$56db,$fffe

; linea $57
	dc.w	$5725,$fffe
	dc.w	spr6data,$c079,spr6datb,$0006,spr7data,$b6e7,spr7datb,$4910
	dc.w	spr6pos,$40,spr7pos,$48,$574b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$575b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$576b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$577b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$578b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$579b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$57ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$57bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$57cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$57db,$fffe

; linea $58
	dc.w	$5825,$fffe
	dc.w	spr6data,$c07f,spr6datb,$0048,spr7data,$fff6,spr7datb,$2009
	dc.w	spr6pos,$40,spr7pos,$48,$584b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$585b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$586b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$587b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$588b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$589b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$58ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$58bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$58cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$58db,$fffe

; linea $59
	dc.w	$5925,$fffe
	dc.w	spr6data,$e06f,spr6datb,$0096,spr7data,$7eaf,spr7datb,$a150
	dc.w	spr6pos,$40,spr7pos,$48,$594b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$595b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$596b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$597b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$598b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$599b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$59ab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$59bb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$59cb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$59db,$fffe

; linea $5a
	dc.w	$5a25,$fffe
	dc.w	spr6data,$61ed,spr6datb,$9013,spr7data,$dfff,spr7datb,$6cab
	dc.w	spr6pos,$40,spr7pos,$48,$5a4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5a5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5a6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5a7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5a8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5a9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5aab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5abb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5acb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5adb,$fffe

; linea $5b
	dc.w	$5b25,$fffe
	dc.w	spr6data,$db9f,spr6datb,$72ed,spr7data,$ffff,spr7datb,$dbee
	dc.w	spr6pos,$40,spr7pos,$48,$5b4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5b5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5b6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5b7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5b8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5b9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5bab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5bbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5bcb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5bdb,$fffe

; linea $5c
	dc.w	$5c25,$fffe
	dc.w	spr6data,$ffff,spr6datb,$cfbf,spr7data,$ffff,spr7datb,$ff3f
	dc.w	spr6pos,$40,spr7pos,$48,$5c4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5c5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5c6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5c7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5c8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5c9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5cab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5cbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5ccb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5cdb,$fffe

; linea $5d
	dc.w	$5d25,$fffe
	dc.w	spr6data,$ffff,spr6datb,$ffff,spr7data,$ffff,spr7datb,$feff
	dc.w	spr6pos,$40,spr7pos,$48,$5d4b,$fffe
	dc.w	spr6pos,$50,spr7pos,$58,$5d5b,$fffe
	dc.w	spr6pos,$60,spr7pos,$68,$5d6b,$fffe
	dc.w	spr6pos,$70,spr7pos,$78,$5d7b,$fffe
	dc.w	spr6pos,$80,spr7pos,$88,$5d8b,$fffe
	dc.w	spr6pos,$90,spr7pos,$98,$5d9b,$fffe
	dc.w	spr6pos,$a0,spr7pos,$a8,$5dab,$fffe
	dc.w	spr6pos,$b0,spr7pos,$b8,$5dbb,$fffe
	dc.w	spr6pos,$c0,spr7pos,$c8,$5dcb,$fffe
	dc.w	spr6pos,$d0,spr7pos,$d8,$5ddb,$fffe

; istruzioni copper per disattivare gli sprite

	dc.w	$5e07,$fffe		; aspetta inizio riga
	dc.w	$172,0			; spr6ctl
	dc.w	$17a,0			; spr7ctl

	dc.w	$FFFF,$FFFE	; Fine della copperlist




	SECTION	PLANEVUOTO,BSS_C	; Il bitplane azzerato che usiamo,
					; perche' per vedere gli sprite
					; e' necessario che ci siano bitplanes
					; abilitati
BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

In questo esempio facciamo scorrere il paesaggio fatto con gli sprite.
A tale scopo non e` possibile usare il registro BPLCON1, che abbiamo usato
per far scorrere i bit-planes, perche` esso non ha effetto sugli sprite.
Per far scorrere il paesaggio dobbiamo far scorrere tutti i pixel che lo
compongono. In questo caso ci e` molto utile il fatto che il paesaggio
sia composto sempre dalla stessa figura che si ripete orizzontalmente
ogni 32 pixel.
Il paesaggio infatti e` costituito da 2 sprite (16 pixel ognuno) che si
ripetono sempre uguali per tutta la riga. Per far scorrere tutto il paesaggio,
bastera` quindi far scorrere i pixel che compongono la forma dei 2 sprite.
Ma tali pixel vengono scritti ad ogni nuova riga del paesaggio nei registri
SPR6DATA, SPR6DATB, SPR7DATA e SPR7DATB.
Quindi dovremo far scorrere il contenuto di questi registri
che si trova nella copperlist. All'indirizzo FormaSprite nella copperlist
possiamo trovare il dato che viene scritto in SPR6DATA nella prima riga del 
paesaggio. Rispettivamente 4,8 e 12 bytes dopo, c'e` il contenuto dei registri
SPR6DATB, SPR7DATA e SPR7DATB, sempre della prima riga.
Facendo scorrere il contenuto dei nostri registri in tutte le 14 righe del
paesaggio avremo raggiunto il nostro scopo.

Vediamo ora come si effettua lo scorrimento, per esempio verso destra

Noi conosciamo gia` un istruzione che fa scorrere i pixel di una locazione di
memoria o di un registro del 68000, la LSR. Questa istruzione fa scorrere
i bit verso destra e fa entrare a sinistra dei bit di valore 0.
Per esempio:

        move.b  #%00100101,d0
        lsr.b   #3,d0

dopo queste istruzioni in d0 ci sara` il valore %00000100
Nel nostro caso questo non va bene, perche` i bit di valore 0 che entrano da
sinistra producono un "buco" nello sprite che si allarga sempre di piu`, fino
a cancellare del tutto la figura.

Quello che ci occorre e` un'istruzione che faccia scorrere i bit verso
destra, ma che faccia rientrare a sinistra i bit che sono usciti a destra.
Cioe` in pratica che faccia ruotare i bit all'interno del registro.
Questa istruzione esiste, e si chiama ROR ("ROtate Right")
Vediamo subito un esempio:

        move.b  #%00100101,d0
        ror.b   #3,d0

dopo queste istruzioni in d0 ci sara` il valore %10100100. In pratica i 3
bit che prima della ROR si trovavano a destra sono rientrati da sinistra,
seguendo il percorso indicato sotto:

bit:     7 6 5 4 3 2 1 0
        -----------------
        | | | | | | | | |
        -----------------
       ->   -->   -->   -->
      |                     |   direzione di scorrimento.
        <--   <--   <--   <-

La routine "MuoviPaesaggio" utilizza un'istruzione ROR per far scorrere
i pixel. Notate che il contenuto del registro SPR6DATA e il contenuto di
SPR7DATA vengono messi nello stesso registro e vengono fatti ruotare
insieme, in modo che i bit che escono a sinistra da SPR6DATA entrano a destra
in SPR7DATA e i bit che escono a sinistra da SPR7DATA entrano a destra in
SPR6DATA.
La stessa operazione viene ripetuta anche per i contenuti dei registri 
SPR6DATB e SPR7DATB che costituiscono il secondo piano degli sprite.

Per rendervi conto meglio della differenza tra la LSR e la ROR, provate
a sostituire LSR al posto di ROR nella routine "MuoviPaesaggio".
Vedrete che non e` esattamente quello che volevamo!

Naturalmente oltre alla ROR esiste un'istruzione per ruotare i bit verso
sinistra, che si chiama ROL ("ROtate Left") e che funziona esattamente nello
stesso modo. Potete tranquillamente sostituirla a ROR e vedrete il paesaggio
scorrere in direzione opposta.

In teoria con soli 2 sprite si potrebbe riempire tutto lo schermo, partendo
dalle nuvole in alto, poi i monti, la prateria e gli alberelli in primo piano,
e si potrebbe anche far scorrere a diverse velocita' i vari livelli della
parallasse, cioe' i monti "lontani" piu' piano, la prateria velocita' media,
gli alberi in primo piano velocemente. Tutto cio' richiederebbe una copperlist
enorme e la routine per muovere tutto sarebbe molto lenta, questo e' uno dei
motivi per cui le parallassi di questo genere sono fatte con i bitplanes, che
sono piu' colorati e veloci da muovere. Comunque se qualcuno osasse dire che
l'Amiga ha solo 8 piccoli sprites, potreste fargli vedere la schermata in
parallasse fatta con gli sprites in sovraimpressione su un disegno a 4096
colori HAM, e vi rimarrebbero anche 6 sprites per farci le stelline e qualche
astronave. Se poi ci faceste girare in mezzo anche un centinaio di BOB col
blitter... forse non si capirebbe piu' niente, ma sarebbe interessante.

