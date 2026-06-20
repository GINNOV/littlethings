
; Lezione2l.s

Inizio:
	lea	$dff000,a0	; metti $dff000 in a0
Waitmouse:
	move.w	#$20,$1dc(a0)	; BEAMCON0 (ECS+) Risoluzione video PAL
	bsr.s	Lampeggio	; Fa lampeggiare lo schermo
	bsr.s	ColorFreccia	; Fa lampeggiare la freccia
	btst	#2,$16(a0)	; POTINP - Tasto destro del mouse premuto?
				; (bit 2 del $dff016
	bne.s	nonpremuto	; Se non e' premuto, salta FaiConfusione
	bsr.s	FaiConfusione	; 
nonpremuto:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	Waitmouse	; se no ritorna a waitmouse e ripeti tutto
	rts			; esci

ColorFreccia:
	moveq	#-1,d1		; OSSIA moveq #$FFFFFFFF,d1
	moveq	#20-1,d0	; numero di cicli colorfreccia
flash:
	subq.w	#8,d1		; cambia il colore da mettere in $dff1a4
	move.w	d1,$1a4(a0)	; COLOR18 - metti il valore di d1 in $dff1a4
				; (il colore della freccia del mouse!)
	dbra	d0,flash
	rts

Lampeggio:
	move.w	6(a0),$180(a0)	; metti il valore .w di $dff006 nel color 0
	move.b	6(a0),$182(a0)	; metti il valore .b di $dff006 nel color 1
	rts

FaiConfusione:
	move.w	#0,$1dc(a0)	; BEAMCON0 (ECS+) Risuluzione video NTSC
	rts

	END

Questo programmino e' interessante solo per la sua struttura, infatti
ha un programma principale, quello da Inizio all'RTS, il quale richiama
delle subroutine (ovvero sottoprogrammi, che non sono altro che parti del
programma denominati da una label (cioe' da un nome) e terminanti in un RTS.
Con il debugger "AD" provate a seguire il corso del programma: per seguire
tutte le subroutine andate avanti con il tasto con la freccia verso destra,
e noterete tra l'altro nella routine ColorFreccia come il registro d0
sia decrementato di 1 in 1.

Il problema fondamentale delle strutture BSR/BEQ/BNE/RTS sta nel fatto che
tutto e' regolato da salti che possono determinare un ritorno tramite RTS al
punto dove e' stato eseguito tale salto (BSR LABEL), e da salti che invece
sono come i rami di un albero: una volta scelto se prendere la diramazione
destra o sinistra si continua per quella e non si puo' piu' tornare indietro

		    ramo 1
		   _______ _ _ eccetera _ _ _ RTS, uscita da questa parte
    bivio beq/bne /
    _____________/
		 \ ramo 2
		  \______ _ _ eccetera _ _ _ RTS, uscita da questa altra parte


Un salto BEQ/BNE e' come decidere di andare a Milano o a Palermo, si passa da
altre strade, e una volta arrivati alla destinazione si passa la notte in una
di quelle due citta' (dove troviamo l'RTS), avendo percorso diverse autostrade.

Invece se troviamo un BSR.w Milano, saltiamo a Milano, eseguiamo le istruzioni
che troviamo a Milano, poi quando troviamo un RTS ci "teletrasportiamo" al
punto dove avevamo imboccato la strada per Milano, miracolosamente, e' come
se leggessimo un libro magico, in cui in ogni pagina c'e' la figura di un
paesaggio, dunque con un AbraCadaBSR entriamo nel disegno della prima pagina,
ci passiamo un po' di tempo, poi imbattendoci in un AmuletRTS torniamo seduti
davanti al libro, pronti ad un AbraCadaBSR nella seconda pagina.


NOTA1: Premendo il tasto destro viene eseguita una routine che altrimenti
viene saltata:

	btst	#2,$16(a0)	; Tasto destro del mouse premuto?
				; (bit 2 del $dff016 - POTINP)
	bne.s	nonpremuto	; Se non e' premuto, salta FaiConfusione
	bsr.s	FaiConfusione	; 
nonpremuto:

ricordatevi bene questo metodo per eseguire una subroutine solo a patto
che una certa condizione sia soddisfatta, in questo caso che il tasto
destro del mouse sia premuto; programmando si fanno spesso di queste cose.
Il registro usato per fare "Confusione" e' il $dff1dc, il cui bit 5 serve
per scambiare la modalita' video tra PAL europea o NTSC americana; questo
registro esiste solo nei computer fabbricati dopo il 1989, a qualcuno che
ha un'Amiga vecchio potrebbe non funzionare. Se vi funziona noterete che
premendo il tasto destro lo schermo oltre a lampeggiare sembrera' che
esploda, infatti scambiando molto velocemente modalita' questo e' il
risultato. Se volete fare 2 programmini richiamabili da AmigaDos che scambino
il modo video, basta che facciate:

	move.w	#0,$dff1dc	; BEAMCON0
	rts

assemblatelo, e salvatelo su un disco con WO (cioe' come file che potete
eseguire) con il nome NTSC, poi assemblate quest'altro:

	move.w	#$20,$dff1dc	; BEAMCON0
	rts

E salvatelo come PAL. Da SHELL potrete cosi' cambiare modo video
chiamando i 2 programmini PAL e NTSC.

Se non vi orientate in questo programma considerate che quelli VERI sono
mille volte piu' complicati come BSR vari, quindi vedete di capirlo al 100%
prima di cominciare la LEZIONE3, intitolata: "POTEVAMO STUPIRVI CON EFFETTI
SPECIALI E COLORI ULTRAVIVACI, MA NON SAPPIAMO ANCORA FARE".
