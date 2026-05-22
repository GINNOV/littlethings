; Corso Asm - LEZIONE xx:  ** SUONA SAMPLE MOLTO LUNGHI ANCHE IN FAST 2 **


	SECTION	PlayLongSamples,CODE

Start:
	bset	#1,$bfe001		;spegne il filtro passa-basso
					;>>>> PARAMETRI <<<<
	lea	sample,a0		;indirizzo sample
	move.l	#sample_end-sample,d0	;lunghezza sample in byte
	move.w	#17897,d1		;frequenza di lettura
	moveq	#64,d2			;volume
	bsr.s	playlongsample_init	;INIT routine (comincia)....
					;....CPU libera....
WLMB:	btst	#6,$bfe001		;testa LMB+RMB...provate, dunque,
	bne.s	wlmb			;a girare per il Wb e noterete
	btst	#10,$dff016		;come non avvenga NESSUN rallentamento
	bne.s	wlmb			;....magie del DMA !

	bsr.w	playlongsample_restore	;RESTORE routine (spegne tutto)
	rts


***************************************
*****  Play Long Sample Routines  *****
***************************************

PlayLongSample_init:
		;[a0=sample adr]
		;[d0.l=lunghezza.b sample, d1.w=frequenza, d2.w=volume]
		;* L'AutoVector Lv4 IRQ deve essere disponibile *

_LVOSupervisor	equ	-30
_LVOAllocMem	EQU	-198
_LVOFreeMem	EQU	-210
_LVOAvailMem	EQU	-216
MEMF_CHIP	equ	1<<1
MEMF_LARGEST	equ	1<<17
MEMF_CLEAR	equ	1<<16
AFB_68010	equ	0
AttnFlags	equ	296

Clock		equ	3546895
MaxBanco1	equ	32*1024
MaxBanco2	equ	32*1024

	movem.l	d0-d2/a0-a1/a5-a6,-(sp)
	lea	plsregs(pc),a5
	movem.l	d0/a0,(a5)		;registri fissi di riferimento
	movem.l	d0/a0,4*2(a5)		;registri di lavoro
	move.l	4.w,a6
	move.l	#MEMF_CHIP!MEMF_LARGEST,d1
	jsr	_LVOAvailMem(a6)	;-> d0.l=blocco di chip di grande
	cmp.l	#maxbanco1,d0		;d0.l > MaxBanco1 kB ?
	bls.s	.okmem1			;se NO: prendi la lungh. del blocco
	move.l	#maxbanco1,d0		;se SI: bastano MaxBanco1 kB
.OkMem1:and.w	#~%11,d0		;d0.l=lungh.banco allineata a 32 bit
	move.l	d0,4*4(a5)
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1;MEMF_CLEAR: a 0 la RAM alloccata
	jsr	_LVOAllocMem(a6)	;allocca 1 banco da MaxBanco1 kB
	tst.l	d0			;d0.l=0 ?
	beq.w	.bye			;se SI: RAM non sufficiente -> esci
	move.l	d0,4*5(a5)		;salva base del PRIMO banco in chip
	move.l	#MEMF_CHIP!MEMF_LARGEST,d1
	jsr	_LVOAvailMem(a6)	;-> d0.l=blocco di chip di grande
	cmp.l	#maxbanco2,d0		;d0.l > MaxBanco2 kB ?
	bls.s	.okmem2			;se NO: prendi la lungh. del blocco
	move.l	#maxbanco2,d0		;se SI: bastano MaxBanco2 kB
.OkMem2:and.w	#~%11,d0		;d0.l=lungh.banco allineata a 32 bit
	move.l	d0,4*6(a5)
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1;MEMF_CLEAR: a 0 la RAM alloccata
	jsr	_LVOAllocMem(a6)	;allocca 1 banco da MaxBanco2 kB
	tst.l	d0			;d0.l=0 ?
	beq.w	.bye			;se SI: RAM non sufficiente -> esci
	move.l	d0,4*7(a5)		;salva base del SECONDO banco in chip
	movem.l	4(sp),d1-d2		;ripristina d1-d2 dallo stack
	sub.l	a0,a0
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)	;68010+ ?
	beq.s	.no010
	lea	getvbr(pc),a5		;va a routine con comandi privilegiati
	jsr	_LVOSupervisor(a6)	;in modo supervisore con l'exec
.No010:	lea	$dff000,a6
	move.w	#$0780,$9c(a6)		;azzera eventuali richieste di IRQ
	move.w	$1c(a6),oldint		;salva INTENA dell'OS
	move.w	#$0780,$9a(a6)		;maschera INT AUD0-AUD3
	move.l	$70(a0),oldlv4		;salva l'autovettore del livello 4
	move.l	#lv4irq,$70(a0)		;imposta il nuovo autovettore
	move.w	d2,$a8(a6)		;imposta AUD0VOL
	move.w	d2,$b8(a6)		;imposta AUD1VOL
	move.w	d2,$c8(a6)		;imposta AUD2VOL
	move.w	d2,$d8(a6)		;imposta AUD3VOL
	move.l	#clock,d2
	divu.w	d1,d2			;d2.w=clock/freq = periodo di camp.
	move.w	d2,$a6(a6)		;imposta AUD0PER
	move.w	d2,$b6(a6)		;imposta AUD1PER
	move.w	d2,$c6(a6)		;imposta AUD2PER
	move.w	d2,$d6(a6)		;imposta AUD3PER
	move.w	$2(a6),olddma		;salva DMACON dell'OS
	move.w	#$c400,$9a(a6)		;accende AUD3 IRQ - basta lui...
	move.w	#$8400,$9c(a6)		;forza l'IRQ per comiciare...
	movem.l	(sp)+,d0-d2/a0-a1/a5-a6
.Bye:	rts
;--------------------------------------
GetVBR:
	dc.l	$4e7a8801	;movec	vbr,a0	;base dei vettori di eccezione
	rte
;--------------------------------------
PlayLongSample_restore:
	movem.l	d0-d2/a0-a1/a5-a6,-(sp)
	sub.l	a0,a0
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)
	beq.s	.no010
	lea	getvbr(pc),a5
	jsr	_LVOSupervisor(a6)
.No010:	lea	$dff000,a6
	move.w	#$0780,$9c(a6)		;azzera le richieste di tutti i canali
	move.w	#$0400,$9a(a6)		;maschera l'INT AUD3
	move.l	oldlv4(pc),$70(a0)	;reimposta l'autovettore 4 dell'OS
	move.w	#$000f,$96(a6)		;spegne tutti i DMA audio
	move.w	oldint(pc),d0
	or.w	#$8000,d0		;imposta SET/CLR che e' a 0 in INTENAR 
	move.w	d0,$9a(a6)		;reimposta l'INTENA dell'OS
	move.w	olddma(pc),d0
	or.w	#$8000,d0		;imposta SET/CLR che e' a 0 in DMACONR
	move.w	d0,$96(a6)		;reimposta il DMACON dell'OS
	move.l	4.w,a6
	movem.l	plsregs+4*4(pc),d0/a1
	jsr	_LVOFreeMem(a6)		;libera la RAM del PRIMO banco
	movem.l	plsregs+4*6(pc),d0/a1
	jsr	_LVOFreeMem(a6)		;libera la RAM del SECONDO banco
	movem.l	(sp)+,d0-d2/a0-a1/a5-a6
	rts
;--------------------------------------
PlayLongSample_IRQ:
	movem.l	d0-d2/a0-a1/a5-a6,-(sp)
	lea	$dff000,a6
	lea	plsregs(pc),a5
	movem.l	4*2(a5),d0/a0		;d0.l=lungh.mancante/a0=base sample
	movem.l	4*4(a5),d1/a1		;d1.l=lungh.banco/a1=base banco
	move.l	a1,$a0(a6)		;imposta gli AUDLC
	move.l	a1,$b0(a6)
	move.l	a1,$c0(a6)
	move.l	a1,$d0(a6)
	cmp.l	d0,d1			;banco <= lungh.mancante ?
	bls.s	.longc
	move.l	d0,d1			;se NO: copia e suona lungh.mancante
.LongC:	move.l	d1,d2
	lsr.l	#1,d1			;devidi per 2 per AUDLEN in word
	move.w	d1,$a4(a6)		;imposta gli AUDLEN
	move.w	d1,$b4(a6)
	move.w	d1,$c4(a6)
	move.w	d1,$d4(a6)
	lsr.l	#1,d1			;dividi per 2 per copiare longword
	subq.w	#1,d1
	move.w	#$007,$180(a6)	;blu quando comicia a copiare
.CopyLp:move.l	(a0)+,(a1)+
	dbra	d1,.copylp
	move.w	#$000,$180(a6)	;nero quando finisce
	move.l	4*3(a5),a0
	add.l	d2,a0			;punta a0 al prossimo blocco
	sub.l	d2,d0			;lunghezza MENO lungh.suonata
	bhi.s	.noloop			;d0 => 1 ? (manca ancora ALMENO 1 byte)
	movem.l	(a5),d0/a0		;se NO: reimposta registri originali
.NoLoop:movem.l	d0/a0,4*2(a5)		;salva comunque d0 e a0 nelle copie
	movem.l	4*4(a5),d0-d1/a0-a1	;scambia puntatori e lunghezza
	exg	d0,a0		;commendole viene usato un solo buffer
	exg	d1,a1		;
	movem.l	d0-d1/a0-a1,4*4(a5)
	move.w	#$820f,$96(a6)
	movem.l	(sp)+,d0-d2/a0-a1/a5-a6
	rts
;--------------------------------------
OldINT:	dc.w	0
OldDMA:	dc.w	0
OldLv4:	dc.l	0
PLSRegs:dc.l	0,0	;lunghezza,puntatore del sample - fissi
	dc.l	0,0	;lunghezza,puntatore del sample- variabili
	dc.l	0,0	;lunghezza,puntatore del banco 1 - fissi
	dc.l	0,0	;lunghezza,puntatore del banco 2 - fissi


***************************************
*****  Level 4 Interrupt Handler  *****
***************************************

	cnop	0,8
Lv4IRQ:	
	btst	#10-8,$dff01e		;IRQ AUD3 ?
	beq.s	.exit
	move.w	#$0780,$dff09c
	bsr.w	playlongsample_irq
.Exit:	rte



	SECTION	Sample,DATA_F

	; MammaGamma by Alan Parsons Project (©1981)
Sample:
	incbin	"assembler2:sorgenti8/Mammagamma.17897"
Sample_end:

	END


Questa volta non è cambiato poi molto: ora i banchi sono di lunghezza e di
posizione indipendente, non più adiacenti ne' lunghi uguali.
La routine non ha subito particolari cambiamenti: allocca i due buffer
separatamente, e nella _IRQ si limita a scambiare anche le loro lunghezze,
oltre ai puntatori.

N.B.:	Le note dell'esempio precedente valgono anche per questo.

