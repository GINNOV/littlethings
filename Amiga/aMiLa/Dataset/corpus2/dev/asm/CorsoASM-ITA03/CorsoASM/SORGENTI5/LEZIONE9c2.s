
; Lezione9c2.s		In questo listato una figura di 16*15 pixel, ad
;			un solo bitplane, viene blittata ripetutamente fino a
;			riempire lo schermo (320*256 lowres 1 bitplane).

	section	bau,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo il primo bitplane

	MOVE.L	#BitPlane1,d0	; dove puntare
	LEA	BPLPOINTER1,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	bsr.s	fillmem			; riempi lo schermo di "mattonelle"
					; col blitter.
mouse:
	btst	#6,$bfe001		; testa il tasto sin. del mouse
	bne.s	mouse

	rts				; uscita


;*****************************************************************************
; Questa routine riempie lo schermo di mattonelle. 
;*****************************************************************************

;	   .-----------.
;	   |         ¬ |
;	   |           |
;	   |  ___      |
;	  _j / __\     l_
;	 /,_  /  \ __  _,\
;	.\¬| /    \__¬ |¬/....
;	  ¯l_\_o__/° )_|¯    :
;	   /   ¯._.¯¯  \     :
;	.--\_ -^---^- _/--.  :
;	|   `---------'   |  :
;	|   T    °    T   |  :
;	|   `-.--.--.-'   | .:
;	l_____|  |  l_____j
;	   T  `--^--'  T
;	   l___________|
;	   /     _    T
;	  /      T    | xCz
;	 _\______|____l_
;	(________X______)

fillmem:
	lea	Bitplane1,a0	; indirizzo bitplane destinazione
	lea	gfxdata1,a3	; fig. mattonella 16*15

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; BLTAFWM/LWM - li spiegheremo dopo
	move.w	#0,$64(a5)		; BLTAMOD = 0, infatti la figura della
					; mattonella NON e` contenuta dentro
					; uno schermo piu` grande e quindi
					; le righe che la compongono sono
					; consecutive in memoria.
	move.w	#38,$66(a5)		; BLTDMOD (40-2=38), infatti ogni
					; "mattonella" e' larga 16 pixel,
					; cioe' 2 bytes, che dobbiamo togliere
					; alla larghezza totale di una linea,
					; cioe' 40, e il risultato e' 40-2=38!
	move.w	#$0000,$42(a5)		; BLTCON1 - no modi speciali
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)

	moveq	#16-1,d2		; 16 file di mattonelle per arrivare
					; verticalmente fino in fondo, infatti
					; le mattonelle sono alte 15 pixel,
					; piu' 1 di "spaziatura" tra una e
					; l'altra, sotto ognuna, fa un
					; ingombro di 16 pixel per piastrella,
					; dunque 256/16=16 mattonelle.
FaiTutteLeRighe:
	moveq	#20-1,d0		; 20 mattonelle per linea (fila),
					; infatti, essendo le mattonelle
					; larghe 16 pixel, cioe' 2 bytes, ne
					; deriva che ce ne possono stare
					; 320/16=20 per linea orizzontale.
FaiUnaRigaLoop:
	move.l	a0,$54(a5)		; BLTDPT - destinazione (bitpl 1)
	move.l	a3,$50(a5)		; BLTAPT - sorgente (fig1)
	move.w	#(15*64)+1,$58(a5)	; BLTSIZE - altezza 15 words,
					;           larghezza 1 word (16 pix.)
	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	addq.w	#2,a0	; salta 1 word (16 pixel) nel bitplane 1, scattando
			; in "avanti" per la prossima mattonella

	dbra	d0,FaiUnaRigaLoop	; e cicla fino a che non sono state
					; blittate tutte le 20 mattonelle
					; di una riga.
 
	lea	15*40(a0),a0	; salta 15 linee nel bitplane 1. Siccome
				; abbiamo gia' incrementato a0 a forza di
				; addq #2,a0, abbiamo gia' saltato una linea
				; intera prima di arrivare qua. Per ogni loop,
				; dunque, vengono saltate 16 linee, lasciando
				; tra una mattonella e l'altra una "striscia"
				; di sfondo azzerato, dato che le mattonelle
				; sono alte solo 15 pixel.
	dbra	d2,FaiTutteLeRighe	; fai tutte le 16 righe
 	rts	

;*****************************************************************************

		section	cop,data_C

copperlist
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w $100,$1200		; BPLCON0 - 1 bitplane lowres

	dc.w $180,$126	; Color0
	dc.w $182,$0a0	; Color1

BPLPOINTER1:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.l	$ffff,$fffe	; fine della copperlist

;*****************************************************************************

;	Figura, composta da 1 biplane. larghezza = 1 word, altezza = 15 linee

gfxdata1:
	dc.w	%1111111111111100	; 1
	dc.w	%1111111111111100	; 2
	dc.w	%1100000000001100	; 3
	dc.w	%1100000000001100
	dc.w	%1100011110001100
	dc.w	%1100111111001100
	dc.w	%1100110011001100
	dc.w	%1100110011001100
	dc.w	%1100111111001100
	dc.w	%1100011110001100
	dc.w	%1100000000001100
	dc.w	%1100000000001100
	dc.w	%1111111111111100
	dc.w	%1111111111111100
	dc.w	%0000000000000000	; 15

	section	gnippi,bss_C

bitplane1:
		ds.b	40*256

	end

;*****************************************************************************

In questo esempio usiamo una piccola figura (larga 16 pixel e alta 15 linee)
come "mattonella" per "piastrellare" lo schermo. In pratica copiamo la figura
sorgente tante volte, in modo da ricoprire tutto lo schermo. Poiche` lo
schermo e` largo 320 pixel e la mattonella 16, in una riga disegnamo
320/16=20 mattonelle. In altezza invece lo schermo misura 256 pixel e la
mattonella 15. Siccome lasciamo una riga di pixel vuota tra 2 file di
mattonelle, 256/(15+1)=16 mattonelle per ogni colonna.
Ogni mattonella viene copiata mediante una blittata. Le dimensioni della
blittata sono di 1 word (16 pixel) in larghezza e 15 righe in altezza.
Il modulo della sorgente vale 0, perche` la sorgente NON appartiene ad
uno schermo, e le righe che compongono la figura della mattonella sono
disposte consecutivamente in memoria. La destinazione invece e` dentro uno
schermo largo 20 words, e quindi il modulo viene calcolato secondo la fomula
vista nella lezione.
Le istruzioni che eseguono la blittata si trovano all'interno di 2 loop
posti uno dentro l'altro. Il loop piu` interno ripete la blittata 20 volte,
in modo da disegnare una fila orizzontale di mattonelle. Il loop piu`
esterno fa ripetere il loop interno 16 volte, in modo da disegnare in totale
16 file di mattonelle. Tra una blittata e l'altra varia naturalmente 
l'indirizzo della destinazione in modo da disegnare la mattonella ogni volta
in un punto diverso dello schermo. Per questo motivo metteremo il puntatore 
alla destinazione in un registro che modificheremo durante la routine.
Nel loop interno, disegnamo una alla volta, le mattonelle che formano una fila
orizzontale. Quindi dopo aver disegnato una mattonella, dobbiamo spostare il
puntatore alla destinazione di una word verso destra, cioe` dobbiamo farlo
puntare alla word seguente in memoria. Cio` equivale ad aggiungere 2
all'indirizzo (una word = 2 bytes). In questo modo quando arriviamo all'ultima
iterazione del ciclo interno, il puntatore alla destinazione punta all'ultima 
word della riga. Dopo la stampa della mattonella (che e` l'ultima
della fila orizzontale) viene aggiunto ancora 2 al puntatore, facendolo puntare
alla prima word della riga seguente. Noi invece vogliamo iniziare a stampare
un'altra fila di mattonelle. Siccome una fila di mattonelle e` alta 16 linee,
dobbiamo disegnare la prossima fila 16 linee piu` in basso di quella che
abbiamo appena terminato. Il nostro puntatore invece come abbiamo detto punta
una linea piu` in basso di quella attuale. Quindi, dobbiamo farlo puntare 
altre 15 linee piu` in basso. Cio` equivale ad aggiungere 15*40 all'indirizzo,
perche` ogni riga occupa 40 bytes (20 words), cosa che viene fatta ad ogni
iterazione del ciclo esterno.


		prima di iniziare la prima iterazione del ciclo interno
		il puntatore punta qui.
		
		   |
		   V

riga Y		|      |      |      |
riga Y+1	|      |      |      |
.
.		   ^
		   |
		   
		dopo l'ultima iterazione del ciclo interno
		il puntatore punta a questa word.

		Per stampare la nuova fila invece deve puntare a QUESTA word
		Per farcelo arrivare dobbiamo spostarlo in basso di 15 linee
		aggiungendogli 40 per ogni linea.

		   |
		   V

riga Y+16	|      |      |      |





