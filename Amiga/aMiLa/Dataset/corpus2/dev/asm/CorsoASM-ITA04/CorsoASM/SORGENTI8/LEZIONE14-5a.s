
; Lezione14-5a.s	** SUONA SAMPLE MOLTO LUNGHI **


	SECTION	PlayLongSamples,CODE

Start:
	bset	#1,$bfe001		; spegne il filtro passa-basso

					; >>>> PARAMETRI <<<<
	lea	sample,a0		; indirizzo sample
	move.l	#sample_end-sample,d0	; lunghezza sample in byte
	move.w	#17897,d1		; frequenza di lettura
	moveq	#64,d2			; volume
	bsr.s	playlongsample_init	; INIT routine (comincia)....
					; ....CPU libera....
WLMB:
	btst	#6,$bfe001		; testa LMB+RMB...provate, dunque,
	bne.s	wlmb			; a girare per il Wb e noterete
	btst	#10,$dff016		; come non avvenga NESSUN rallentamento
	bne.s	wlmb			; ....magie del DMA !

	bsr.w	playlongsample_restore	; RESTORE routine (spegne tutto)
	rts


***************************************
*****  Play Long Sample Routines  *****
***************************************
;
; a0	= sample adr
; d0.l  = lunghezza.b sample, d1.w=frequenza, d2.w=volume
;
; L'AutoVector Lv4 IRQ deve essere disponibile


_LVOSupervisor	equ	-30
Clock		equ	3546895
AFB_68010	equ	0
AttnFlags	equ	296

PlayLongSample_init:
	movem.l	d2/a0/a6,-(sp)
	movem.l	d0/a0,plsregs		; registri fissi di riferimento
	movem.l	d0/a0,plsregs+4*2	; registri di lavoro
	sub.l	a0,a0			; FAST CLEAR An
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)	; 68010+ ?
	beq.s	.no010
	lea	getvbr(pc),a5
	jsr	_LVOSupervisor(a6)
.No010:
	lea	$dff000,a6
	move.w	#$0780,$9c(a6)		; azzera eventuali richieste di IRQ
	move.w	$1c(a6),oldint		; salva INTENA dell'OS
	move.w	#$0780,$9a(a6)		; maschera INT AUD0-AUD3
	move.l	$70(a0),oldlv4		; salva l'autovettore del livello 4
	move.l	#lv4irq,$70(a0)		; imposta il nuovo autovettore
	move.w	d2,$a8(a6)		; imposta AUD0VOL
	move.w	d2,$b8(a6)		; imposta AUD1VOL
	move.w	d2,$c8(a6)		; imposta AUD2VOL
	move.w	d2,$d8(a6)		; imposta AUD3VOL
	move.l	#clock,d2
	divu.w	d1,d2			; d2.w=clock/freq = periodo di camp.
	move.w	d2,$a6(a6)		; imposta AUD0PER
	move.w	d2,$b6(a6)		; imposta AUD1PER
	move.w	d2,$c6(a6)		; imposta AUD2PER
	move.w	d2,$d6(a6)		; imposta AUD3PER
	move.w	$2(a6),olddma		; salva DMACON dell'OS
	move.w	#$8400,$9a(a6)		; accende AUD3 IRQ - basta lui...
	move.w	#$8400,$9c(a6)		; forza l'IRQ per comiciare...
	movem.l	(sp)+,d2/a0/a6
	rts

;--------------------------------------
GetVBR:
	dc.l	$4e7a8801	;movec	vbr,a0	;base dei vettori di eccezione
	rte
;--------------------------------------

PlayLongSample_restore:
	movem.l	d0/a0/a6,-(sp)
	sub.l	a0,a0
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)
	beq.s	.no010
	lea	getvbr(pc),a5
	jsr	_LVOSupervisor(a6)
.No010:
	lea	$dff000,a6
	move.w	#$0780,$9c(a6)		; azzera le richieste di tutti i canali
	move.w	#$0400,$9a(a6)		; maschera l'INT AUD3
	move.l	oldlv4(pc),$70(a0)	; reimposta l'autovettore 4 dell'OS
	move.w	#$000f,$96(a6)		; spegne tutti i DMA audio
	move.w	oldint(pc),d0
	or.w	#$8000,d0		; imposta SET/CLR che e' a 0 in INTENAR 
	move.w	d0,$9a(a6)		; reimposta l'INTENA dell'OS
	move.w	olddma(pc),d0
	or.w	#$8000,d0		; imposta SET/CLR che e' a 0 in DMACONR
	move.w	d0,$96(a6)		; reimposta il DMACON dell'OS
	movem.l	(sp)+,d0/a0/a6
	rts

;--------------------------------------

PlayLongSample_IRQ:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	lea	$dff000,a6
	movem.l	plsregs+4*2(pc),d0/a0	; grabba i registri di lavoro
	move.l	a0,$a0(a6)		; imposta AUD0LC
	move.l	a0,$b0(a6)		; imposta AUD1LC
	move.l	a0,$c0(a6)		; imposta AUD2LC
	move.l	a0,$d0(a6)		; imposta AUD3LC
	move.l	d0,d1			; d1.l=lunghezza mancante
	and.l	#~(128*1024-1),d1	; mancano ancora piu' di 128 kB
	bne.s	.long			; se SI: vai a .long
	move.l	d0,d1			; se NO: usa lungh. mancante (< 128 kB)
.Long:	lsr.l	#1,d1			; trasforma la lungh. da suonare in .W
	move.w	d1,$a4(a6)		; imposta AUD0LEN
	move.w	d1,$b4(a6)		; imposta AUD1LEN
	move.w	d1,$c4(a6)		; imposta AUD2LEN
	move.w	d1,$d4(a6)		; imposta AUD3LEN
	add.l	#128*1024,a0		; punta a0 al prossimo blocco
	sub.l	#128*1024,d0		; lunghezza MENO 128 kB
	bhi.s	.noloop			; d0 => 1 ? (manca ALMENO 1 byte)
	movem.l	plsregs(pc),d0/a0	; se NO: reimposta registri originali
.NoLoop:movem.l	d0/a0,plsregs+4*2	; salva comunque d0 e a0 nelle copie
	move.w	#$820f,$96(a6)		; accende tutti i DMA audio, e viene
					; generato subito l'IRQ, nel caso
					; della prima accensione dell'audio
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

;--------------------------------------

OldINT:	dc.w	0
OldDMA:	dc.w	0
OldLv4:	dc.l	0
PLSRegs: dc.l	0,0	; lunghezza,puntatore - fissi
	dc.l	0,0	; lunghezza,puntatore - variabili


***************************************
*****  Level 4 Interrupt Handler  *****
***************************************

	cnop	0,8
Lv4IRQ:	
	btst	#10-8,$dff01e		;IRQ AUD3 ?
	beq.s	.exit			;se NO: esci
	move.w	#$0400,$dff09c		;spegni subito la richiesta, poiche'
					;nella routine vengono accesi i DMA
					;ed il nuovo IRQ viene subito generato:
					;spegnendo la richiesta dopo la routine
					;si corre il rischio di annullare la
					;richiesta di IRQ al primo ciclo
					;dell'interrupt (appena avviata la
					;routine).
	bsr.w	playlongsample_irq
.Exit:
	rte



	SECTION	Sample,DATA_C

	; MammaGamma by Alan Parsons Project (©1981)
Sample:
	incbin	"assembler2:sorgenti8/Mammagamma.17897"
Sample_end:

	END


Ora le cosa ricominciano a complicarsi... Abbiamo iniziato ad usare interrupt
e routine non piu' - diciamo - banali.
Come e' stato gia' scritto nella LEZIONE, i canali audio sono associati a 4
diversi interrupt assegnati al livello 4 del 680x0; tali interrupt vengono
generati dall'harware ogni qual volta un canale viene forzato a leggere i dati
in memoria a partire dall'indirizzo contenuto nel suo AUDLC: avvegono, dunque,
appena acceso il DMA ed ogni volta all'inizio di un nuovo loop del sample.
* Appena un canale comincia a suonare dall'inizio un sample, oltre a venir
"sparato" l'IRQ, il suo AUDLC rimane immutato e, pertanto, ALTERABILE:
in questo modo funziona la routine "PlayLongSample": ogni volta che il DMA
comincia a leggere un pezzo (da 128 kB o meno, a seconda che la parte di
sample mancante da suonare sia piu' lunga della massima AUDLEN loopabile) viene
generato l'interrupt, ed i registri di locazione AUDxLC (tutti e 4, in questo
caso, poiche' vengono utilizzati tutti per suonare i medesimi dati) vengono
ricalcolati e fatti avanzare o retrocedere in base al "pezzetto" di sample
a cui PRECEDENTEMENTE putavano e che ORA il DMA sta' leggendo *.
*** In sostanza, con questa tecnica, e' possibile far suonare all'Amiga tanti
pezzi di 128 kB - o meno, per quanto riguarda l'ultimo pezzo - di dati audio
adiacenti in memoria, senza far sentire lo "stacco" tra uno e l'altro ***. 

N.B.:	una volta avviata la routine, essa continua a far loopare il sample
	all'infinito solo dal codice in interrupt, per cui ** e' COMPLETAMENTE
	INDIPENDENTE: in altre parole, dopo l'"_init", tornate in main
	ed avete normale controllo di tutto l'hardware (escluso quello sonoro,
	ovviamente) e della CPU (escluso l'interrupt di livello 4, che e'
	quello utilizzato dalla "PlayLongSample") **.
	Quando volete spegnere il sample, chiamate la "_restore" e tutto
	tornera' come prima di aver chiamato la "_init" (eventuali routine
	su interrupt audio comprese !).

P.S.:	un'ultima precisazione: qui e' stato utilizzato solo un IRQ per
	tutte le voci, visto che tutte suonavano contemporaneamente la
	medesima cosa, e precisamente quello della voce 3, ovvero il piu'
	alto di priorita' hardware.
	In teoria non dovrebbe cambiare nulla nell'usare quello di quelche
	altra voce, * a patto che si mascherino gli altri - o che comunque
	vengano ignorati dall'handler -, altrimenti al termine di ogni blocco
	letto verrebbero generati 4 interrupt.
