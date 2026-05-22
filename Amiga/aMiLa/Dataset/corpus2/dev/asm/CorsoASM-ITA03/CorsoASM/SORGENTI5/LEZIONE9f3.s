
; Lezione9f3.s		In questo listato una figura di 16*15 pixel, a 2
;			bitplanes, viene blittata ripetutamente fino a
;			riempire lo schermo (320*256 lowres 2 bitplanes).
;			La temporizzazione col Wblank fa in modo che venga
;			blittata solo una mattonella per fotogramma.

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

;	Puntiamo il secondo bitplane

	MOVE.L	#BitPlane2,d0	; dove puntare
	LEA	BPLPOINTER2,A1	; puntatori COP
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

;	  .---^---^---.
;	  |           |
;	  |           |
;	  | ¯¯¯   --- |
;	 _| ___   ___ l_
;	/__ `°(___)°' __\
;	\ \_/\_____/\_/ /
;	 \____`---'____/
;	    T`-----'T
;	    l_______| xCz

fillmem:
	lea	Bitplane1,a0	; primo bitplane
	lea	Bitplane2,a1	; secondo bitplane
	lea	gfxdata1,a3	; fig. plane 1
	lea	gfxdata2,a4	; fig. plane 2

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo
	move.w	#0,$64(a5)		; BLTAMOD = 0
	move.w	#38,$66(a5)		; BLTDMOD (40-2=38), infatti ogni
					; "mattonella" e' larga 16 pixel,
					; cioe' 2 bytes, che dobbiamo togliere
					; alla larghezza totale di una linea,
					; cioe' 40, e il risultato e' 40-2=38!
	move.w	#$0000,$42(a5)		; BLTCON1 - lo spiegheremo dopo
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)

	moveq	#16-1,d7		; 16 file di blocchi per arrivare
					; verticalmente fino in fondo, infatti
					; le mattonelle sono alte 15 pixel,
					; piu' 1 di "spaziatura" tra una e
					; l'altra, sotto ognuna, fa un
					; ingombro di 16 pixel per piastrella,
					; dunque 256/16=16 mattonelle.
FaiTutteLeRighe:
	moveq	#20-1,d6		; 20 blocchi per linea (fila), infatti,
					; essendo le mattonelle larghe 16
					; pixel, cioe' 2 bytes, ne deriva che
					; ce ne possono stare 320/16=20 per
					; linea orizzontale.
FaiUnaRigaLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

; Blitta il primo bitplane di una mattonella

	move.l	a0,$54(a5)		; BLTDPT - destinazione (bitpl 1)
	move.l	a3,$50(a5)		; BLTAPT - sorgente (fig1)
	move.w	#(15*64)+1,$58(a5)	; BLTSIZE - altezza 15 words,
					;           larghezza 1 word
					; Per Fare il Primo Bitplane

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

; Blitta il secondo bitplane di una mattonella

	move.l	a1,$54(a5)		; BLTDPT - destinazione (bitpl 2)
	move.l	a4,$50(a5)		; BLTAPT - sorgente (fig2)
	move.w	#(15*64)+1,$58(a5)	; BLTSIZE - altezza 15 words,
					;           larghezza 1 word
					; Per Fare il Primo Bitplane

	btst	#6,2(a5) ; dmaconr
WBlit3:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit3

	addq.w	#2,a0	; salta 1 word (16 pixel) nel bitplane 1, scattando
			; in "avanti" per la prossima mattonella
	addq.w	#2,a1	; salta 1 word (16 pixel) nel bitplane 2
	dbra	d6,FaiUnaRigaLoop	; e cicla fino a che non sono state
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
	lea	15*40(a1),a1	; salta 15 linee nel bitplane 2
	dbra	d7,FaiTutteLeRighe	; fai tutte le 16 righe

 	rts	

;******************************************************************************

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

	dc.w $100,$2200		; BPLCON0 - 2 bitplanes lowres

	dc.w $180,$000	; Color0
	dc.w $182,$FED	; Color1
	dc.w $184,$33a	; Color2
	dc.w $186,$888	; Color3

BPLPOINTER1:
	dc.w $e0,0,$e2,0	;primo	 bitplane
BPLPOINTER2:
	dc.w $e4,0,$e6,0	;secondo bitplane

	dc.l	$ffff,$fffe	; fine della copperlist

******************************************************************************

;	Figura, composta da 2 biplanes. larghezza = 1 word, altezza = 15 linee

gfxdata1:
	dc.w	%1111111111111100
	dc.w	%1111111111111100
	dc.w	%1100000000001100
	dc.w	%1101111111111100
	dc.w	%1101111111111100
	dc.w	%1101111111011100
	dc.w	%1101110011011100
	dc.w	%1101110111011100
	dc.w	%1101111111011100
	dc.w	%1101111111011100
	dc.w	%1101100000011100
	dc.w	%1101111111111100
	dc.w	%1111111111111100
	dc.w	%1111111111111100
	dc.w	%0000000000000000

gfxdata2:
	dc.w	%0000000000000010
	dc.w	%0111111111111110
	dc.w	%0111111111110110
	dc.w	%0111111111110110
	dc.w	%0111000000010110
	dc.w	%0111011111110110
	dc.w	%0111011101110110
	dc.w	%0111011101110110
	dc.w	%0111010001110110
	dc.w	%0111011111110110
	dc.w	%0111011111110110
	dc.w	%0111111111110110
	dc.w	%0100000000000110
	dc.w	%0111111111111110
	dc.w	%1111111111111110

;******************************************************************************

	section	gnippi,bss_C

bitplane1:
		ds.b	40*256
bitplane2:
		ds.b	40*256

	end

;******************************************************************************

Questo esempio e` una variazione dell'esempio lezione9c2.s.
Questa volta abbiamo uno schermo da 2 planes.
Anche le nostre mattonelle sono costituite da 2 planes.
La routine che esegue la "piastrellatura" dello schermo, ha la stessa
struttura di quella dell'esempio lezione9c2.s, solo che vengono effettuate 2
copie: il primo bitplane della mattonella sul primo bitplane dello schermo e
il secondo bitplane della mattonella sul secondo dello schermo.
Inoltre, tanto per renderlo piu` interessante, abbiamo rallentato la routine
mettendo un loop di attesa del Vertical Blank.
In questo modo, le mattonelle vengono copiate una ogni Vertical Blank, ed e`
possibile osservare ad occhio l'ordine in cui vengono copiate.

