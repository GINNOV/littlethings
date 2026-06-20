
; Lezione9h3.s	Facciamo apparire un immagine una colonna di pixel alla volta
;		Tasto destro per eseguire la blittata, sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0		; + LUNGHEZZA DI UNA PLANE !!!!!
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse1:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse1		; se no, aspetta

	bsr.s	Mostra		; esegui la routine

mouse2:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse2		; se no, torna a mouse2:

	rts


; ************************ LA ROUTINE CHE MOSTRA LA FIGURA *******************

;	     .øØØØØØø.
;	     |¤¯_ _¬¤|
;	    _|___ ___|_
;	   (_| (·T.) l_)
;	    /  ¯(_)¯  \
;	   /____ _ ____\
;	  //    Y Y    \\
;	 //__/\_____/\__\\ xCz
;	(_________________)

Mostra:

; valori iniziali dei puntatori

	lea	picture,a0		; punta all'inizio della figura
	lea	bitplane,a1		; punta all'inizio del primo bitplane

	moveq	#20-1,d7		; esegui per ogni "colonna" di word.
					; lo schermo e` largo 20 word, quindi
					; ci sono 20 colonne.

FaiTutteLeWord:
	moveq	#16-1,d6		; 16 pixel per ogni word.
	move.w	#%1000000000000000,d0	; valore della maschera all'inizio del
					; loop interno. Fa passare solo il
					; pixel piu` a sinistra della word.
FaiUnaWord:

; aspetta il vblank in modo da disegnare una colonna di pixel ad ogni
; fotogramma.

WaitWblank:
	CMP.b	#$ff,$dff006		; vhposr - aspetta la linea 255
	bne.s	WaitWblank
Aspetta:
	CMP.b	#$ff,$dff006		; vhposr - ancora linea 255 ?
	beq.s	Aspetta

	moveq	#3-1,d5			; ripeti per ogni plane

	move.l	a0,a2			; copia i puntatori in altri 2 registri
	move.l	a1,a3			; questo perche` all'interno del loop
					; che disegna i vari plane devono
					; modificare per puntare da un plane
					; all'altro.

FaiUnPlane:
	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit:
	btst	#6,2(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
	move.w	#$ffff,$44(a5)		; BLTAFWM - fa passare tutti i bit
	move.w	d0,$46(a5)		; Carica il valore della maschera nel
					; registro BLTALWM
; carica i puntatori

	move.l	a2,$50(a5)		; bltapt
	move.l	a3,$54(a5)		; bltdpt

; Sia per la sorgente che per la destinazione blittiamo una word appartenente
; ad uno schermo largo 20 word. Il modulo quindi vale 2*(20-1)=38=$26.
; Poiche` i 2 registri hanno indirizzi consecutivi, si puo` usare una sola
; istruzione invece che 2:

	move.l #$00260026,$64(a5)	; bltamod e bltdmod 

; blittiamo una "colonna" di word alta 256 righe (tutto lo schermo)

	move.w	#(256*64)+1,$58(a5)	; bltsize
					; altezza 256 linee
					; larghezza 1 word

	lea	40*256(a2),a2		; punta al prossimo plane sorgente
	lea	40*256(a3),a3		; punta al prossimo plane destinazione

	dbra	d5,FaiUnPlane		; ripeti per tutti i planes

	asr.w	#1,d0			; calcola la maschera per la prossima
					; blittata. Fa passare ogni volta un
					; bit in piu` rispetto alla volta
					; precedente.

	dbra	d6,FaiUnaWord		; ripeti per tutti i pixel
	
	addq.w	#2,a0			; punta alla word seguente
	addq.w	#2,a1			; punta alla word seguente

	dbra	d7,FaiTutteLeWord	; ripeti per tutte le word

	btst	#6,$02(a5)	; dmaconr - aspetta che il blitter finisca
waitblit2:
	btst	#6,$02(a5)
	bne.s	waitblit2

	rts

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; VALORE MODULO = 0
	dc.w	$10a,0		; ENTRAMBI I MODULI ALLO STESSO VALORE.

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

PICTURE:
	incbin	"assembler2:sorgenti6/amiga.raw"
					; qua carichiamo la figura in
					; formato RAWBLIT (o interleaved),
					; convertita col KEFCON.

;****************************************************************************

	section	gnippi,bss_C

bitplane:
		ds.b	40*256	; 3 bitplanes
		ds.b	40*256
		ds.b	40*256
	end

;****************************************************************************

In questo esempio vediamo un nuovo effetto ottenuto grazie ad una maschera.
Disegnamo un'immagine sullo schermo una colonna di pixel per volta partendo
da destra. In pratica dobbiamo copiare sullo schermo l'immagine una "colonna"
di pixel alla volta. La larghezza minima di una blittata, pero` e` di una
word, pari a 16 pixel. Quindi se eseguissimo semplici copie, potremmo solo
copiare gruppi di 16 pixel. Fortunatamente, pero` ci sono le maschere.
Facendo blittate larghe una word, entrambe le maschere si applicano alla
word blittata. A noi comunque ne basta una, per esempio BLTALWM (sarebbe
comunque la stessa cosa se usassimo BLTAFWM). Il trucco e` questo:
copiamo la stessa colonna di 1 word 16 volte, ogni volta nella stessa posizione
dello schermo e ogni volta cambiamo la maschera in modo da far vedere una
colonna di pixel in piu`.
In pratica, la prima volta facciamo la copia con la maschera al valore
%1000000000000000 in modo da far vedere solo la prima colonna di pixel.
La seconda blittata avviene nella stessa posizione della precedente, quindi
sovrascrive quello che abbiamo disegnato la prima volta. Come maschera usiamo
il valore %1100000000000000, in modo che si vedranno solo le prime 2 colonne
di pixel. La terza volta usiamo come maschera %1110000000000000 e disegnamo
le prime 3 colonne di pixel, e cosi` via. La 16-esima volta usiamo come 
maschera %1111111111111111 in modo da disegnare tutte e 16 le colonne di pixel
che compongono la colonna di word. A questo punto dobbiamo iniziare a disegnare
la prima colonna di pixel della colonna di word seguente, pertanto ci spostiamo
di una word a destra, sia nella sorgente che nella destinazione e ricominciamo
con la maschera al valore %1000000000000000. Poiche` le nostre blittate sono
larghe solo una word, non sovrascriveremo la colonna di word precedente che 
pertanto rimane disegnata.
Notate il modo in cui sono ottenuti i valori della maschera.  All'inizio si
mette il valore di partenza (%1000000000000000) nel registro D0. Tale registro
viene copiato in BLTALWM, in modo che la prima blittata faccia passare solo
la prima colonna di pixel. Dopo la blittata viene eseguita una ASR #1,D0.
Questa istruzione, come sapete, effettua uno shift verso destra del contenuto
del registro D0. Inoltre (a differenza della LSR) conserva il segno, cioe`
fa entrare da sinistra un bit dello stesso valore di quello che era il bit
piu` a sinistra (cioe` il bit di segno) prima della shiftata. In questo caso,
il bit di segno vale 1, pertanto da sinistra entra un'altro 1. In questo modo 
il registro D0 assume il valore %1100000000000000. Questo valore viene usato
come maschera per la seconda blittata, e poi viene eseguita un'altra ASR
che porta D0 al valore %1110000000000000. Questo meccanismo viene ripetuto
ad ogni iterazione, generando tutti i valori della maschera.
Per ulteriori chiarimenti sulla ASR consultate la lezione 68000-2.TXT.

