
; Lezione9i5.s	Clipping di Bob a destra. (By Erra Ugo)
;		Tasto sinistro per uscire.

	section	CLippaD,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"Startup1.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


; Definiamo in queste equ le costanti relative al nostro bob...

XBob	equ	16*8	; Dimenzione X del bob
YBob	equ	29	; Dimenzione Y del bob
XWord	equ	8	; Numero di word del bob

; Definiamo il limiti delo schermo

XMax	=	320-64		; Limite orizontale destro dello schermo
XMin	=	0		; Limite orizontale sinistro dello schermo
YMax	=	200-YBob	; Limite verticale inferiore dello schermo
YMin	=	0		; Limite verticale superiore dello schermo


Start:
	Lea	Screen,a0		; prepariamo il puntatore
	Move.l	a0,d0			; al bitplane.
	Move.w	d0,BPLPointer1+6
	Swap	d0
	Move.w	d0,BPLPointer1+2

	Lea	$dff000,a6		; CUSTOM REGISTER in a5
	Move.w	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
	Move.l	#CopperList,$80(a6)	; Puntiamo la nostra COP
	Move.w	d0,$88(a6)		; Facciamo partire la COP
	Move.w	#0,$1fc(a6)		; Disattiva l'AGA
	Move.w	#$c00,$106(a6)		; Disattiva l'AGA
	Move.w	#$11,$10c(a6)		; Disattiva l'AGA

	Moveq	#100,d0		; d0 e' la coordinata x
	Move.w	#100,d1		; d1 e' la coordinata y
	Moveq	#0,d2		; azzeriamo il resto dei registri dati
	Moveq	#0,d3		; bla bla bla
	Moveq	#0,d4		; bla bla
	Moveq	#0,d5		; bla
	Moveq	#0,d6		
	Moveq	#0,d7

Loop:
	Cmpi.b	#$ff,$6(a6)
	Bne.s	Loop

	Bsr.w	LeggiJoyst	; La routine legge lo stato del joystick
				; ed aggiorna x ed y direttamente nei registri
				; d0 e d1.
	Bsr.w	CheckLimit	; Controlla se la routine e' nei limiti
	Bsr.w	CancellaSchermo	; pulisci lo schermo
	Bsr.s	ClipBobRight	; clippa il bob lo piazza a video
	Btst	#6,$bfe001	; Attende la pressione del tasto sinistro
	Bne.s	Loop		; ...
	Rts

; ****************************************************************************
; La tecnica decritta viene implementata nel seguente modo:
; 1)Se la coordinata in alto a destra e uscita dal limite massimo allora
;   non blitta nulla.
; 2)Calcola di quanti pixel il bob e' uscito fuori, nel seguente modo
;   Xout=(x+xdim)-XMax
; 3)Si calcola quindi esattamente di quante word il bob è uscito fuori e 
;   di quanti pixel, nel seguente modo XOut/16 e XOut mod 16.
; 4)A questo punto dalla tabella maskright preleviamo il valore
;   del registro BLTLWM tramite il valore XOut mod 16
; 5)Prepariamo il modulo A del blitter tramite l'operazione (XBob-XOut)/16
; ****************************************************************************

;	       . . . .
;	      :¦:¦:¦:¦:¦       
;	      ¦    ____l___    
;	      |__  '______/    
;	     _!\____,---.|     
;	.---/___ (¯°) °_||----.
;	|   \ \/\ ¯¯¯¯T  l_   |
;	|  _ \ \/\___,_)__ \  |
;	|  |  \ \/ /| | l/ /  |
;	|  |   \ \/¯T¯T¯/ /T  |
;	|  |    \_¯¯¯¯¯¯_/ |  |
;	|  |     `------'  |  |
;	|  l_______/¯¯)¯¯\_|  |
;	l_______l__  _(_  (___|
;	.. .  .   \___)___/ xCz

ClipBobRight:
	Movem.l	d0-d7/a0,-(a7)
	Cmpi.w	#XMax,d0	; Confronta la coordinata in alto a sinistra
				; con il XMax
	Bge.w	ExitClipRight	; se e' maggiore allora il bob e' completamente
				; fuori, e quindi non facciamo nulla

	Move.w	#XBob,d7	; d7=Dimensione del bob
	Add.w	d0,d7		; Sommo a d7 la coordinata x, quindi d7 e'
				; uguale alla coordinata in alto a destra. 
	Subi.w	#XMax,d7	; Calcolo di quanti pixel il bob e'uscito fuori
	Ble.w	IsInLeft	; Se il risultato e' mimore di zero allora
				; il bob e' uscito completamente fuori.

	Move.w	d7,d6		; d7=d6=numero di pixel out
	Lsr.w	#4,d6		; d6=d6/16 numero di word out
	Move.w	#XWord,d2	; d2=numero di word del bob originariamente
	Andi.w	#15,d7		; d7=numero di pixel out

				; Adesso calcolo il nuovo valore di bltsize
	Move.w	d2,d5		; d5=numero di word del bob originariamente
	Sub.w	d6,d2		; d2 numero di word in
	Move.w	#YBob,d3	; Dimensione verticale in d3
	Lsl.w	#6,d3		; Moltiplico d3 per 64
	Add.w	d2,d3		; d3=bltsize ridotto

				; Calcoliamo il nuovo modulo della destinazione
	Moveq	#40,d4		; Per calcolare il nuovo modulo della
				; destinazione. Non facciamo che sottrarre
				; le dimensioni restanti del bob a 40.
	Add.w	d5,d5		; d5=d5*2 numero di byte del bob originariam.
	Add.w	d6,d6		; d6=d6*2 modulo di A in byte
	Sub.w	d6,d5		; d5=numero di byte out
	Sub.w	d5,d4		; d4=modulo di D

	Moveq	#-1,d5
	Add.w	d7,d7		; con d7 preleviamo il valore della maschera
	Lea	MaskRight,a0	; in a0 l'ind. della tabella
	Move.w	(a0,d7.w),d5	; d5=maskera	

	Mulu	#40,d1		; Da qui blitting normale...
	Move.w	d0,d2
	Lsr.w	#3,d0	
	Add.w	d0,d1	
	Lea	Screen,a0
	Adda.l	d1,a0
	Andi.w	#$000f,d2
	Ror.w	#4,d2		; piu` efficente che fare LSL #4,d2 e
				; poi LSL #8,D2
	Ori.w	#$09f0,d2		

	Btst	#6,2(a6)
WaitBlit1b:
	Btst	#6,2(a6)	; dmaconr - aspetta che il blitter sia libero
	bne.s	WaitBlit1b

	Move.w	d2,$40(a6)	; bltcon0
	Move.l	d5,$44(a6)	; bltafwm
	Move.l	#Bob,$50(a6)	; bltapt
	Move.l	a0,$54(a6)	; bltdpt
	Move.w	d6,$64(a6)	; bltamod
	Move.w	d4,$66(a6)	; bltdmod
	Move.w	d3,$58(a6)	; bltsize
	Movem.l	(a7)+,d0-d7/a0
	Rts

IsInLeft:
	Mulu.w	#40,d1		; In questo caso usufruiamo del blitter
	Move.w	d0,d2		; normalmente poiche' il bob si trova entro
	Lsr.w	#3,d0		; il limiti prefissati.
	Add.w	d0,d1	
	Lea	Screen,a0
	Add.l	d1,a0
	Andi.w	#$000f,d2
	Ror.w	#4,d2
	Ori.w	#$09f0,d2		

	Moveq	#-1,d7
	Clr.w	d7

	Btst	#6,2(a6)
WaitBlit1a:
	Btst	#6,2(a6)	; dmaconr - aspetta che il blitter sia libero
	bne.s	WaitBlit1a

	Move.w	d2,$40(a6)	; bltcon0
	Move.w	#0,$42(a6)	; bltcon1
	Move.l	d7,$44(a6)	; bltafwm
	Move.l	#Bob,$50(a6)	; bltapt
	Move.l	a0,$54(a6)	; bltdpt
	Move.w	#-2,$64(a6)	; bltamod
	Move.w	#40-18,$66(a6)	; bltdmod
	Move.w	#(29*64)+(144/16),$58(a6)	; bltsize
ExitClipRight:
	Movem.l	(a7)+,d0-d7/a0
	Rts

; ****************************************************************************
; Questa routine controlla che il bob non esca dai limti fisici dello
; schermo. Infatti abbiamo realizzato una routine che taglia le parti che
; escono al di fuori della nostra destra, ma non abbiamo fatto nulla per
; gli altri limiti dello schermo. Quindi questa routine controlla se le 
; coordinate sono sempre nel range giusto.
; ****************************************************************************

CheckLimit:
	Cmpi.w	#XMin,d0	; E' uscito dalla sinistra ?
	Bge.s	Limit2		; no, allora vedi sopra e sotto
	Move.w	#XMin,d0	; si, allora rimettilo nei nostri limiti
Limit2:
	Cmpi.w	#YMin,d1	;E' uscito da sopra ?
	Bge.s	Limit3		;no,allora vedi sotto
	Move.w	#YMin,d1	;si, allora rimettilo nei limiti
	Bra.s	End_Limit	;e' euindi esci fuori poiche' il nostro bob non
				;puo' stare contemporaneamente sopra e sotto.
Limit3:
	Cmpi.w	#YMax,d1	; Come sopra ma controlliamo il limite
	Blt.s	End_Limit	; verticale in basso.
	Move.w	#YMax,d1
End_Limit
	Rts



; ****************************************************************************
; Questa routine legge il joystick e aggiorna i valori contenuti nelle
; variabili sprite_x e sprite_y
; ****************************************************************************

LeggiJoyst:
	Move.w	$dff00c,D3	; JOY1DAT
	Btst.l	#1,D3		; il bit 1 ci dice se si va a destra
	Beq.s	NODESTRA	; se vale zero non si va a destra
	Addq.w	#1,d0		; se vale 1 sposta a di un pixel lo sprite
	Bra.s	CHECK_Y		; vai al controllo della Y
NODESTRA:
	Btst	#9,D3		; il bit 9 ci dice se si va a sinistra
	Beq.s	CHECK_Y		; se vale zero non si va a sinistra
	Subq.w	#1,d0		; se vale 1 sposta lo sprite
CHECK_Y:
	Move.w	D3,D2		; copia il valore del registro
	Lsr.w	#1,D2		; fa scorrere i bit di un posto verso destra 
	Eor.w	D2,D3		; esegue l'or esclusivo. Ora possiamo testare
	Btst	#8,D3		; testiamo se va in alto
	Beq.s	NOALTO		; se no controlla se va in basso
	Subq.w	#1,d1		; se si sposta lo sprite
	Bra.s	ENDJOYST
NOALTO:
	Btst	#0,D3		; testiamo se va in basso
	Beq.s	ENDJOYST	; se no finisci
	Addq.w	#1,d1		; se si sposta lo sprite
ENDJOYST:
	Rts

;****************************************************************************
; Questa routine cancella lo schermo mediante il blitter.
;****************************************************************************

CancellaSchermo:
	btst	#6,2(a6)
WBlit3:
	btst	#6,2(a6)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a6)	; BLTCON0 e BLTCON1: Cancella
	move.w	#$0000,$66(a6)		; BLTDMOD=0
	move.l	#Screen,$54(a6)		; BLTDPT - indirizzo schermo
	move.w	#(64*256)+20,$58(a6)	; BLTSIZE (via al blitter !)
					; cancella tutto lo schermo

	rts

; ****************************************************************************

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

	dc.w $100,$1200		; BPLCON0 - 2 bitplanes lowres

	dc.w $180,$000	; Color0
	dc.w $182,$aaa	; Color1

BPLPOINTER1:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.l	$ffff,$fffe	; fine della copperlist

******************************************************************************

; il bob e' ad 1 bitplane, largo 128 pixel e alto 29 linee

Bob:
	Incbin	"Amiga.bmp"

; ****************************************************************************

; Questa e' la tabella che ci serve per "mozzare" i pixel indesiderati.

MaskRight:
	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111111111111100
	dc.w	%1111111111111000
	dc.w	%1111111111110000
	dc.w	%1111111111100000
	dc.w	%1111111111000000
	dc.w	%1111111110000000
	dc.w	%1111111100000000
	dc.w	%1111111000000000
	dc.w	%1111110000000000
	dc.w	%1111100000000000
	dc.w	%1111000000000000
	dc.w	%1110000000000000
	dc.w	%1100000000000000
	dc.w	%1000000000000000

; ****************************************************************************

	Section Miobuffero,BSS_C

Screen:
		ds.b	(320*256)/8

	end

 Questo breve programma mostra come sia possibile attraverso il blitter 
 effettuare il clipping di bob, utile in molti videogiochi. Innanzitutto
 vediamo cos'è il clipping in generale. Le routine di clipping sono famose
 sopratutto nella grafica 2d e anche 3d, infatti capita spesso di dover
 tracciare line che escono al di fuori della memoria video disponibile, ad
 esempio, si pensi ad un linea che abbia una coordinata (300,450) e che si 
 debba disegnare in un aria video di 320x256, si nota immediatamente che
 la linea se disegnata con un qualunque algoritmo, quest' ultimo potrebbe
 scrivere in una zona di memoria riserveta ad esempio per il codice e 
 quindi mandare in crash la macchina. Lo stesso discorso vale per i bob.
 Infatti supponiamo di avere un' area video di dimensioni 320x256, e un bob
 di 64x20 pixel, ebbene il nostro verra piazzato a video basandoce sulla
 coordinate in alto a sinistra(puo' anche essere un' altra coordinata) siano
 esse x e y. Attraverso il blitter potremo piazzare questo bob in un qualunque
 punto dell'area disponibile, ma cosa accade se piazziamo il nostro bob
 nel punto di coordinata ad esempio (300,120). Osserviamo il disegno


  (0x0) _______________________
	|			|
	|			|
	|	   (300x120) ___|___
	|		    |	|   |
	|		    | A	| B |
	|		    |___|___|
	|			|
	|			|
	|			|
	|			|
	|_______________________|(320x256)



 Come si vede la porsione del bob "B" non entra nell'area video ed esce
 al di fuori. La domanda e' "Ma dove và esattamente?", la risposta e' 
 "dipende dai casi". Infatti supponiamo sempre di avere un' area video
 di 320x256 ad 1 bitplane, ebbene finchè ci manteniamo in un range di 
 coordinate non c'e' nessun rischio che il blitter rovini zone di memorie
 particolari, infatti la porzione di bob uscita fuori rientrera' della
 sinistra, ma di un pixel piu' in basso cioe' avverà una cosa del genere.



  (0x0) _______________________
	|			|
	|			|
	|	   (300x120) ___|
	|___		    |	|
	|   |		    | A	|
	| B |		    |___|
	|___|			|
	|			|
	|			|
	|			|
	|_______________________|(320x256)


 Basti pensare al fatto che la memoria e' sequenziale, quindi arrivati
 all' ultima word di una riga la succesiva word sara' la prima della riga
 successiva. Quindi in questo caso si vede che c'è un rischio per i
 nostri dati o il nostro codice, ma supponiamo che la cordinata sia
 tremendamente vicina alla (320,256), in questo caso rischiamo davvero
 grosso! In ogni modo resta un fatto, quella porzione di bob e' antiestetica.
 Avete mai visto un gioco in cui i bob che escono dalla destra entrano dalla
 sinitra alla Silvan ? Ci sono varie soluzion per eliminare quella porzione
 di bob diventata inutile e pericolosa. Una potrebbe essere quella di fare
 un area video piu' grande, cioe' aggiungere dei delle zone di sicurezza a
 destra e a sinistra della memoria video. Cioe' una cosa di questo genere:




  	 _______________________________________
	|\\\\\\\|			|\\\\\\\|	
	|\\\\\\\|			|\\\\\\\|
	|\\\\\\\|	   		|\\\\\\\|
	|\\\\\\\|		    	|\\\\\\\|
	|\\\\\\\|		    	|\\\\\\\|
	|\\\\\\\|		    	|\\\\\\\|  
	|\\\\\\\|			|\\\\\\\|
	|\\\\\\\|			|\\\\\\\|
	|\\\\\\\|			|\\\\\\\|
	|\\\\\\\|			|\\\\\\\|
	|\\\\\\\|_______________________|\\\\\\\|
       

       |\\\|
       |\\\| <- Area di memoria di sicurezza
       |\\\|


 Come si vede dal disegno, questa soluzione ci garantisce due cose: la prima
 e' che le porzioni di bob superflue non intaccheranno i nostri dati e la 
 seconda che quelle porzioni non rientreranno dalla sinistra. Ma facciamo un
 po' i conti... le dimensioni di quelle aree dovranno essere al piu' uguali
 alla dimesione orizontale massima dei bob, quindi se abbiamo un bob che ha
 dimensione massima orizontale 128 pixel ed inoltre lo adoperiamo in un
 contesto di 5 bitplane avremo bisogno di 2 aree di ((256x128)/8)*5=20480
 cioè in totale 40960, inoltre dobbiamo considerare anche le aree di
 sicurezza che si dovrebbero porre in alto ed in basso della nostra area
 video, quindi l'occupazione di memoria sarebbe troppa.
 La soluzione quindi va cercata in un algoritmo che sia in grado di prelevare
 le porzioni di bob che a noi interessano in quel momento e di scriverle
 nelle zone di memoria corrette. Il tutto puo' essere fatto col blitter.
 Quindi il programma mostra come sia possibile realizzarlo partendo da
 alcune considerazioni. Innanzitutto se il nostro bob deve essere piazzato ad
 una coordinata tale che tutto il bob rientra nella memoria video allora
 questo lo si puo' fare con una classica routine per spostare un bob col
 blitter. Le varianti avvengono quando la coordinata xb in basso a destra 
 coincide con il limite massimo della memoria video e la supera totalmente.
 Prepariamoci per un ragionamento abbastanza intreccioso. 
 Sia XM la coordinata limite della nostra area video d'ora in poi finestra,
 ed inoltre supponiamo che XM sia un multiplo di 16 pixel(per comodita')
 quindi facciamo delle osservazioni. Il nostro bob quando coincidera' con XM,
 la coordinata xa in alto a sinistra sara' anch'essa un multiplo di 16 pixel,
 poiche' il bob ha dimensione orizzontale multipla di 16 pixel. Infatti
 se abbiamo un bob di 64 pixel ed XM=320 allora quando xb coincidera' con XM
 si avra'  che xa=320-64=256 che e' ancora un multiplo di 16, questo significa
 che se il nostro bob si sposta solamente di un'altro pixel xb sara' uguale 
 a XM+1 ma la cosa importante e' che andremo a scrivere nel primo bit della 
 word successiva a (XM/16) nel nostro esempio essendo XM=320 la word che 
 invaderemo sara' la 41-nesima. Se avete capito questo allora avete superato
 il peggio e se qualcuno di voi ha sperimentato moltissimo col blitter forse
 già vede la soluzione del problema. Infatti quello che dobbiamo fare ora e'
 impedire che il blitter scriva nella word invasa questo l'ho realizziamo 
 molto semplicemente col registro del blitter BLTLWM settendolo a 
 "1111111111111110", in questo modo gli ultimi bit dell'ultima word del nostro
 bob non verrano copiati. Se il nostro bob si sposterà di un'altro pixel
 allora la word sarà settata a "1111111111111100". Ma cosa accade se il nostro
 bob esce di 16 pixel in piu' dalla finestra video ? E' evidente che non
 possiamo piu' utilizzare il registro BLTLWM ma dobbiamo usufruire anche del
 modulo. Se noi abbiamo un bob non in formato RAW le informazioni sono 
 memorizzate una di seguito all'altra, quindi settiamo il modulo della 
 sorgente a zero se ora il nostro bob e' uscito di 16 pixel fuori, allora 
 dobbiamo dire al nostro blitter una cosa di questo genere: il mio bob
 ha oramai dimensione x-16 e altezza y quindi leggi x-16 bit e subito dopo
 saltane 16(quelli fuori dalla finestra video), invece quando scrivi, scrivine
 x-16 e poi salta di 320-(x-16) pixel. E' evidenete che non parliamo al 
 blitter in questo modo, e ne in termini di pixel ma spero di avervi fatto
 capire. Quindi unendo le due tecniche della mascherazione dei bit indesiderati
 e del salto delle informazioni inutili tramite il modulo riusciamo a fare
 un clipping di bob velocemente, logicamente impieghiamo meno tempo a non
 farlo ma pensiamo anche al fatto che in questo modo piu' porzione di bob
 esce fuori e' piu' il blitter termina il lavoro di copia.

 Tramite joystick potete spostare un bob di 128x29 pixel, provate a cambiare
 la coordinata XMax(deve essere multiplo di 16).

 In questo esempio ci limitiamo ad illustrare la tecnica del "taglio" del bob
 senza preoccuparci dello sfondo. Infatti disegnamo il nostro bob mediante una
 semplice copia. Inoltre per non complicare il listato, eseguiamo ogni volta
 una cancellazione dell'intero schermo invece che del solo rettangolo che
 racchiude il bob.
 Potete provare voi ad estendere questa tecnica all'esempio del bob completo
 (cioe` con ripristino dello sfondo). In questo caso dovete tenere presente
 che quando il bob viene "tagliato" a destra bisogna variare il modulo e la
 dimensione della blittata non solo nella routine di disegno del bob (come
 avviene in questo esempio) ma anche nelle routine di salvataggio e ripristino
 dello sfondo.
 
