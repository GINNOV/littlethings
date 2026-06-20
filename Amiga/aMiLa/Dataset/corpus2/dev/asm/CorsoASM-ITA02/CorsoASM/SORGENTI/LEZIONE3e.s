
; Lezione3e.s	Effetto di scorrimento di uno sfondo sfumato


;	Routine eseguita 1 volta ogni 3 fotogrammi


	SECTION	CiriCop,CODE	; anche in Fast va bene

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - ferma il multitasking
	lea	GfxName(PC),a1	; Indirizzo del nome della lib da aprire in a1
	jsr	-$198(a6)	; OpenLibrary, routine della EXEC che apre
				; le librerie, e da in uscita l'indirizzo
				; di base di quella libreria da cui fare le
				; distanze di indirizzamento (Offset)
	move.l	d0,GfxBase	; salvo l'indirizzo base GFX in GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; salviamo l'indirizzo della copperlist
				; di sistema
	move.l	#MIACOPPER,$dff080	; Puntiamo la nostra COP
	move.w	d0,$dff088		; Facciamo partire la COP
mouse:
	cmpi.b	#$ff,$dff006	; Siamo alla linea 255?
	bne.s	mouse		; Se non ancora, non andare avanti
frame:
	cmpi.b	#$fe,$dff006	; Siamo alla linea 254? (deve rifare il giro!)
	bne.s	frame		; Se non ancora, non andare avanti
frame2:
	cmpi.b	#$fd,$dff006	; Siamo alla linea 253? (deve rifare il giro!)
	bne.s	frame2		; Se non ancora, non andare avanti

	bsr.s	ScrollColors	; Una cosiddetta RASTER BAR!

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; Puntiamo la cop di sistema
	move.w	d0,$dff088		; facciamo partire la cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	move.l	gfxbase(PC),a1	; Base della libreria da chiudere
				; (vanno aperte e chiuse le librerie!!!)
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	rts


;	Questa routine fa scorrere i 14 colori della nostra copperlist verde
;	in modo da simulare uno scorrimento verso l'alto continuato, come
;	se attraverso una fessura vedessimo scorrere una serie illimitata
;	di barrette sfumate. In pratica sposta ogni volta i colori copiandoli,
;	partendo copiando il secondo nel primo, il terzo nel secondo ecc., come
;	se avessimo una fila di palline colorate in serie: supponete di
;	prendere la seconda e metterla al posto della prima, che vi mettete
;	in tasca, creando un "buco": proseguirete spostando tutte le palline
;	una ad una di un posto: la terza al posto della seconda, la quarta
;	al posto della terza, e cosi' via, fino a che non arrivate alla
;	quattordicesima (l'ultima) che spostate dove era la tredicesima,
;	creando il "buco" che prima si trovava al posto della prima.
;	per tappare questo buco riprendete la prima pallina dalla tasca
;	e mettetela al posto della quattordicesima (si noti l'ultima istruzione
;	che infatti e' "move.w col1,col14", ossia dopo aver fatto "scrorrere"
;	il "buco" dalla prima posizione alla quattordicesima, lo "tappiamo"
;	con la prima pallina, creando un ciclo di continita' (infinito!) come
;	lo scorrimento della catena della bicicletta:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^ 		      v
;	 <<<<<<<<<<<<<<<<<<<<
;
;	ma senza la parte inferiore della catena: semplicemente quando un
;	anello della catena (un colore) arriva al termine (v), viene
;	copiato alla prima posizione (^), rendendo possibile il ciclo
;	infinito:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^ 		      v
;
;	Infatti per interrompere la routine basta eliminare una qualsiasi
;	delle istruzioni che copiano: provate ad esempio a mettere un ;
;	alla prima: (move.w col2,col1) e verificherete che scrorre una sola
;	volta, dopodiche' finiscono i colori, essendo "ROTTO UN ANELLO DELLA
;	CATENA", che non fornisce piu' il colore precedente.


Scrollcolors:	
	move.w	col2,col1	; col2 copiato in col1
	move.w	col3,col2	; col3 copiato in col2
	move.w	col4,col3	; col4 copiato in col3
	move.w	col5,col4	; col5 copiato in col4
	move.w	col6,col5	; col6 copiato in col5
	move.w	col7,col6	; col7 copiato in col6
	move.w	col8,col7	; col8 copiato in col7
	move.w	col9,col8	; col9 copiato in col8
	move.w	col10,col9	; col10 copiato in col9
	move.w	col11,col10	; col11 copiato in col10
	move.w	col12,col11	; col12 copiato in col11
	move.w	col13,col12	; col13 copiato in col12
	move.w	col14,col13	; col14 copiato in col13
	move.w	col1,col14	; col1 copiato in col14
	rts

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Qua ci va l'indirizzo di base per gli Offset
	dc.l	0	; della graphics.library

OldCop:			; Qua ci va l'indirizzo della vecchia COP di sistema
	dc.l	0


;=========== Copperlist ==========================


	section	cop,data_C

MIACOPPER:
	dc.w	$100,$200	; BPLCON0 - schermo senza bitplanes, solo il
				; colore di sfondo $180 e' visibile.

	DC.W	$180,$000	; COLOR0 - iniziamo col colore NERO

	dc.w	$9a07,$fffe	; aspettiamo la linea 154 ($9a in esadecimale)
	dc.w	$180		; REGISTRO COLOR0
col1:
	dc.w	$0f0		; VALORE DEL COLOR 0 (che sara' modificato)
	dc.w	$9b07,$fffe ; aspettiamo la linea 155 (non sara' modificata)
	dc.w	$180		; REGISTRO COLOR0 (non sara' modificato)
col2:
	dc.w	$0d0		; VALORE DEL COLOR 0 (sara' modificato)
	dc.w	$9c07,$fffe	; aspettiamo la linea 156 (non modificato,ecc.)
	dc.w	$180		; REGISTRO COLOR0
col3:
	dc.w	$0b0		; VALORE DEL COLOR 0
	dc.w 	$9d07,$fffe	; aspettiamo la linea 157
	dc.w	$180		; REGISTRO COLOR0
col4:
	dc.w	$090		; VALORE DEL COLOR 0
	dc.w	$9e07,$fffe	; aspettiamo la linea 158
	dc.w	$180		; REGISTRO COLOR0
col5:
	dc.w	$070		; VALORE DEL COLOR 0
	dc.w	$9f07,$fffe	; aspettiamo la linea 159
	dc.w	$180		; REGISTRO COLOR0
col6:
	dc.w	$050		; VALORE DEL COLOR 0
	dc.w	$a007,$fffe	; aspettiamo la linea 160
	dc.w	$180		; REGISTRO COLOR0
col7:
	dc.w	$030		; VALORE DEL COLOR 0
	dc.w	$a107,$fffe	; aspettiamo la linea 161
	dc.w	$180		; color0... (ora avete capito i commenti,
col8:				; posso anche smettere di metterli da qua!)
	dc.w	$030
	dc.w	$a207,$fffe	; linea 162
	dc.w	$180
col9:
	dc.w	$050
	dc.w	$a307,$fffe	;  linea 163
	dc.w	$180
col10:
	dc.w	$070
	dc.w	$a407,$fffe	;  linea 164
	dc.w	$180
col11:
	dc.w	$090
	dc.w	$a507,$fffe	;  linea 165
	dc.w	$180
col12:
	dc.w	$0b0
	dc.w	$a607,$fffe	;  linea 166
	dc.w	$180
col13:
	dc.w	$0d0
	dc.w	$a707,$fffe	;  linea 167
	dc.w	$180
col14:
	dc.w	$0f0
	dc.w 	$a807,$fffe	;  linea 168

	dc.w 	$180,$0000	; Decidiamo il colore NERO per la parte
				; di schermo sotto l'effetto

	DC.W    $FFFF,$FFFE	; Fine della Copperlist

	END

MODIFICHE: Provate ad aggiungere questo comando alla fine della routine
"Scrollcolors", ed otterrete un cambiamento dei colori (aggiungiamo 1 alla
componente RED, ossia ROSSO)

	add.w   #$100,col13

Provate poi a cambiare il valore dell'add, per ottenere variazioni di colore
diverse. Chiaramente e' un sistema un po' approssimativo per fare sfumature,
ma puo' essere utile per sincerarsi di aver capito la routine.

