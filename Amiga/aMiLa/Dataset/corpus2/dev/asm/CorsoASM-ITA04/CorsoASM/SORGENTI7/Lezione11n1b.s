
; Lezione11n1.s -Routine di temporizzazione che permette di attendere un
;		 certo numero di microsecondi usando un timer B del CIAA/B

; Questa routine di test permette di verificare a quante linee video
; corrispondono un certo un certo numero di microsecondi.
; (la parte ROSSA dello schermo e' quella in cui viene eseguita la routine)


MICS:	equ	2000		; ~2000 microsecondi = ~2 millisecondi
				; valore = mics/1,4096837
				; 1 microsecondo = 1 sec/1 milione
				; NOTA: per raffrontare questa routine con
				; quella che attende le linee raster, fate
				; conto che 200 millisecondi corrispondono
				; circa a 5 linee di raster, 400 millisecondi
				; a 9,5 linee, 600 millis. a 14 linee eccetera

Start:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$84(a6)	; forbid
	jsr	-$78(a6)	; disable
	LEA	$DFF000,A5

WBLANNY:
	MOVE.L	4(A5),D0	; $dff004 - VPOSR/VHPOSR
	ANDI.L	#$1FF00,D0	; con interessano solo i bit della linea vert.
	CMPI.L	#$08000,D0	; aspetta la linea $080
	BNE.S	WBLANNY

	move.w	#$f00,$180(a5)	; Colore zero ROSSO

	bsr.s	CIAMIC

	move.w	#$0f0,$180(a5)	; Colore zero VERDE

	btst	#6,$bfe001
	bne.s	WBLANNY


	move.l	4.w,a6		; Execbase in a6
	jsr	-$7e(a6)	; enable
	jsr	-$8a(a6)	; permit
	rts

;	Ecco la routine che aspetta un numero specifico di MICROSECONDI,
;	usando il timer B del CIAB. Per usare il timer B del CIAA basta
;	sostituire il "lea $bfd000,a4" con un "lea $bfe001,a4". Nel listato
;	e' gia' presente, basta togliere il punto e virgola, e metterlo
;	invece al CIAB base. Comunque e' meglio usare il CIAB perche' il
;	timer CIAA e' usato dal sistema operativo per vari compiti.
;       Infatti, se usate il timerB del ciaA, si blocca tutto!

CIAMIC:
	movem.l	d0/a4,-(sp)		; salviamo i registri usati
	lea	$bfd000,a4		; CIAB base

; 	lea	$bfe001,a4		; CIAA base - PERO' MANDA IN BLOCCO
					; TUTTO, DATO CHE LO USA IL SISTEMA
					; OPERATIVO! NON USATE IL TIMER B
					; DEL CIAA, PER FAVORE!

	move.b  $f00(a4),d0		; $bfde00 - CRB, CIAB control reg. B
	andi.b   #%11000000,d0		; azzera i bit 0-5
	ori.b    #%00001000,d0		; One-Shot mode (runmode singolo)
	move.b  d0,$f00(a4)		; CRB - Setta il registro di controllo
	move.b  #%01111101,$d00(a4)	; ICR - cancella gli interrupts CIA
	move.b  #(MICS&$FF),$600(a4)	; TBLO - metti il byte basso del time
	move.b  #(MICS>>8),$700(a4)	; TBHI - metti il byte alto del time
	bset.b  #0,$f00(a4)		; CRB - Start timer!!
wait:
	btst.b  #1,$d00(a4)	; ICR - Attendiamo che il tempo sia scaduto.
				; da notare che si testa il bit 1, e non lo
				; zero, per attendere il timer B.
	beq.s   wait
	movem.l	(sp)+,d0/a4		; ripristiniamo i registri
	rts

	end

Solo un'ultima cosa. Se eveste il tempo da aspettare in una label, potreste
"spezzettarlo" in byte basso e byte alto con un lsr:

	lea	$bfd000,a4		; cia_b base
	move.w	TimerValue(PC),d0	; countdown
	move.b	d0,$600(a4)		; timer B - set lo byte
	lsr.w	#8,d0
	move.b	d0,$700(a4)		; timer B - set hi byte
		; 76543210
	move.b  #%01111101,$d00(a4)	; ICR - cancella gli interrupts CIA
	move.b	#%00011001,$f00(a4)	; CRB - start
					; 7 - Alarm -> 0
					; 6,5 - Inmode bits -> 00
					; 4 - Load bit -> 1 (fa caricare al
					;     timer il valore, e comincia
					;     il conto alla rovescia).
					; 3 - RunMode -> 1 (One shot, 1 volta)
					; 2 - OutMode -> 0 (per ricev. pulse)
					; 1 - PBON -> 0
					; 0 - Start -> comuncia il conto alla
					;     rovescia; giuto a 0->interrupt
	MOVE.B	#%10000010,$d00(a4)	; ICR - Abilita interr. timer B ciaB
loop:
	btst	#1,$d00(a4)		; ICR - test tb-bit ->clear ICR
	beq.s	loop			; not set->wait
	rts


; CIA:	ICR  (Interrupt Control Register)				[d]
;
; 0	TA		underflow
; 1	TB		underflow
; 2	ALARM		TOD alarm
; 3	SP		serial port full/empty
; 4	FLAG		flag
; 5-6	unused
; 7  R	IR
; 7  W	set/clear
;
; CIA:  CRA, CRB  (Control Register)					[e-f]
;
; 0	START		0 = stop / 1 = start TA; {0}=0 when TA underflow
; 1	PBON		1 = TA output on PB / 0 = normal mode
; 2	OUTMODE		1 = toggle / 0 = pulse
; 3	RUNMODE		1 = one-shot / 0 = continous mode
; 4  S	LOAD		1 = force load (strobe, always 0)
; 5   A	INMODE		1 = TA counts positive CNT transition
;			0 = TA counts 02 pulses
; 6   A	SPMODE		serial port....
; 7   A	unused
; 6-5 B	INMODE		00 = TB counts 02 pulses
;			01 = TB counts positive CNT transition
;			10 = TB counts TA underflow pulses
;			11 = TB counts TA underflow pulses while CNT is high
; 7   B	ALARM		1 = writing TOD sets alarm
;			0 = writing TOD sets clock
;			Reading TOD always reads TOD clock


