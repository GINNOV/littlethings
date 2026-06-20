
; Corso Asm - LEZIONE xx:  ** EFFETTO FAKE-SURROND **
			; N.B.: funziona bene sui computer lenti per il
			;       ritardo tra le due voci per cassa.

; debug, stesso di prima

WLMB	macro
\@	btst	#6,$bfe001
	bne.s	\@
	endm

WRMB	macro
\@	btst	#10,$dff016
	bne.s	\@
	endm

	SECTION	PlayLongSamples,CODE

Start:
	bset	#1,$bfe001		;spegne il filtro passa-basso
					;>>>> PARAMETRI <<<<
	lea	sample,a0		;indirizzo sample
	move.l	#sample_end-sample,d0	;lunghezza sample in byte
	move.w	#17897,d1		;frequenza di lettura
	moveq	#64,d2			;volume

	moveq	#0,d3			;suona voce 0
	bsr.w	playlongsample_init
	moveq	#3,d3			;suona voce 3
	bsr.w	playlongsample_init
	WLMB
	moveq	#1,d3			;suona voce 1
	bsr.s	playlongsample_init
	moveq	#2,d3			;suona voce 2
	bsr.s	playlongsample_init
	WRMB

	moveq	#0,d3			;spegni voce 0 
	bsr.w	playlongsample_restore
	moveq	#1,d3			;spegni voce 1
	bsr.w	playlongsample_restore
	moveq	#2,d3			;spegni voce 2
	bsr.w	playlongsample_restore
	moveq	#3,d3			;spegni voce 3
	bsr.w	playlongsample_restore
	rts



***************************************
*****  Play Long Sample Routines  *****
***************************************

PlayLongSample_init:
		;[a0=sample adr]
		;[d0.l=lunghezza.b sample, d1.w=frequenza, d2.w=volume]
		;[d3.w=voce (0..3)]
		;* L'AutoVettore Lv4 IRQ deve essere disponibile *

_LVOSupervisor	equ	-30
Clock		equ	3546895
AFB_68010	equ	0
AttnFlags	equ	296

	movem.l	d0-d7/a0-a1/a6,-(sp)
	and.w	#3,d3			;al massimo 3 canali
 	lea	$dff000,a6
	moveq	#1,d4
	lsl.w	d3,d4
	move.w	d4,d6
	and.w	$2(a6),d4		;maschera DMA della voce
	move.w	#1<<7,d5
	lsl.w	d3,d5
	move.w	d5,d7
	and.w	$1c(a6),d5		;maschera INT della voce
	add.w	d3,d3			;d3=d3*2: esprime offset di word
	lea	olddmas(pc),a1
	move.w	d4,(a1,d3.w)		;salva stato vecchio del DMA della voce
	lea	oldints(pc),a1
	move.w	d5,(a1,d3.w)		;salva stato vecchio del INT della voce
	move.w	d7,$9c(a6)		;azzera eventuali IRQ
	move.w	d6,$96(a6)		;spegni DMA della voce
	move.w	d7,$9a(a6)		;spegni INT della voce
	sub.l	a1,a1				;FAST CLEAR An
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)	;68010+ ?
	beq.s	.no010
	lea	.getvbr(pc),a5
	jsr	_LVOSupervisor(a6)
.No010:	cmp.l	#lv4irq,$70(a1)
	beq.s	.nochg
	move.l	$70(a1),oldlv4		;salva l'autovettore del livello 4
	move.l	#lv4irq,$70(a1)		;imposta il nuovo autovettore
.NoChg:	lsl.w	#4-1,d3			;d3=d3*8: ora esprime offset di 16 byte
	lea	$dff0a0,a6
	move.w	d2,$8(a6,d3.w)		;imposta AUDxVOL
	move.l	#clock,d2
	divu.w	d1,d2			;d2.w=clock/freq = periodo di camp.
	move.w	d2,$6(a6,d3.w)		;imposta AUDxPER
	lea	$dff000,a6
	or.w	#$8000,d7
	move.w	d7,$9a(a6)		;accende INT della voce
	lea	plsregs(pc,d3.w),a1
	movem.l	d0/a0,(a1)		;registri fissi
	movem.l	d0/a0,4*2(a1)		;registri di lavoro
	move.w	d7,$9c(a6)		;forza IRQ della voce...
	movem.l	(sp)+,d0-d7/a0-a1/a6
	rts
.GetVBR:
	dc.l	$4e7a9801	;movec	vbr,a1	;base dei vettori di eccezione
	rte
;--------------------------------------
PLSRegs:	;DEVONO STARE TRA _INIT E _IRQ PER IL MODO DI INDIRIZZAMENTO
		;USATO: XX(pc,Rn) CHE CONSENTE SOLO 8 BIT CON SEGNO AD "XX"
PLSAud0Regs:	dc.l	0,0	;lunghezza,puntatore - fissi
		dc.l	0,0	;lunghezza,puntatore - variabili
PLSAud1Regs:	dc.l	0,0	;lunghezza,puntatore - fissi
		dc.l	0,0	;lunghezza,puntatore - variabili
PLSAud2Regs:	dc.l	0,0	;lunghezza,puntatore - fissi
		dc.l	0,0	;lunghezza,puntatore - variabili
PLSAud3Regs:	dc.l	0,0	;lunghezza,puntatore - fissi
		dc.l	0,0	;lunghezza,puntatore - variabili
;--------------------------------------
PlayLongSample_IRQ:
		;[a1=PLSAudxRegs]
		;[d3.w=voce]
	movem.l	d0-d3/a0-a1/a6,-(sp)
	and.w	#3,d3			;al massimo 3 voci
	move.w	d3,d2
	lsl.w	#4,d3			;d3=d3*16: esprime offset di 16 byte
	lea	plsregs(pc,d3.w),a1
	movem.l	4*2(a1),d0/a0		;grabba i registri di lavoro
	lea	$dff0a0,a6
	move.l	a0,$0(a6,d3.w)		;imposta AUDxLC
	move.l	d0,d1			;d1.l=lunghezza mancante
	and.l	#~(128*1024-1),d1	;mancano ancora piu' di 128 kB
	bne.s	.long			;se SI: vai a .long
	move.l	d0,d1			;se NO: usa lungh. mancante (< 128 kB)
.Long:	lsr.l	#1,d1			;trasforma la lungh. da suonare in WORD
	move.w	d1,$4(a6,d3.w)		;imposta AUDxLEN
	add.l	#128*1024,a0		;punta a0 al prossimo blocco
	sub.l	#128*1024,d0		;lunghezza MENO 128 kB
	bhi.s	.noloop			;d0 => 1 ? (manca ancora ALMENO 1 byte)
	movem.l	(a1),d0/a0		;se NO: reimposta registri originali
.NoLoop:movem.l	d0/a0,4*2(a1)		;salva comunque d0 e a0 nelle copie
	move.w	#%1<<7,d0
	lsl.w	d2,d0
	move.w	d0,$dff09c		;azzera IRQ della voce per non subire
					;un nuovo interrupt appena uscito
	moveq	#%1,d0
	lsl.w	d2,d0
	or.w	#$8200,d0		;accende DMA della voce
	move.w	d0,$dff096
	movem.l	(sp)+,d0-d3/a0-a1/a6
	rts
;--------------------------------------
PlayLongSample_restore:
		;[d3.w=voce (0..3)]
	movem.l	d0-d1/d3/a0/a6,-(sp)
	and.w	#3,d3			;al massimo 3 voci
 	lea	$dff000,a6
	moveq	#1,d0
	lsl.w	d3,d0
	move.w	#1<<7,d1
	lsl.w	d3,d1
	move.w	d1,$9c(a6)		;azzera eventuali IRQ della voce
	move.w	d0,$96(a6)		;spegne DMA della voce
	move.w	d1,$9a(a6)		;spegne INT della voce
	move.w	$1c(a6),d0
	and.w	#$0780,d0		;spente tutte le voci = ultima voce ?
	bne.s	.NoOFF
	sub.l	a0,a0			;se SI:...
	move.l	4.w,a6
	btst	#afb_68010,attnflags+1(a6)
	beq.s	.no010
	lea	.getvbr(pc),a5
	jsr	_LVOSupervisor(a6)
.No010:	move.l	oldlv4(pc),$70(a0)	;...reimposta il vecchio autovettore
.NoOFF:	lea	$dff000,a6
	add.w	d3,d3			;d3=d3*2: esprime offset di word
	move.w	oldints(pc,d3.w),d0
	or.w	#$8000,d0
	move.w	d0,$9a(a6)		;accende vecchi INT
	move.w	olddmas(pc,d3.w),d0
	or.w	#$8000,d0
	move.w	d0,$96(a6)		;accende vecchi DMA
	movem.l	(sp)+,d0-d1/d3/a0/a6
	rts
.GetVBR:
	dc.l	$4e7a8801	;movec	vbr,a0	;base dei vettori di eccezione
	rte
;--------------------------------------
OldINTs:dc.w	0,0,0,0
OldDMAs:dc.w	0,0,0,0
OldLv4:	dc.l	0


***************************************
*****  Level 4 Interrupt Handler  *****
***************************************

	cnop	0,8
Lv4IRQ:	
	move.w	d3,-(sp)
	pea	.exit(pc)		;pusha il ritorno per l'RTS nello stack

	moveq	#3,d3
	btst	#10-8,$dff01e		;aud3 IRQ ?
	bne.w	playlongsample_irq	;se SI: bracha (seza ritorno) alla _IRQ

	moveq	#2,d3
	btst	#9-8,$dff01e		;aud2 IRQ ?
	bne.w	playlongsample_irq

	moveq	#1,d3
	btst	#8-8,$dff01e		;aud1 IRQ ?
	bne.w	playlongsample_irq

	moveq	#0,d3			;aud0 IRQ ?
	btst	#7,$dff01f
	bne.w	playlongsample_irq

.Exit:	move.w	(sp)+,d3		;anche ritorno per l'RTS della _IRQ
	rte




	SECTION	Sample,DATA_C

	; MammaGamma by Alan Parsons Project (©1981)
Sample:
	incbin	"assembler2:sorgenti8/Mammagamma.17897"
Sample_end:

	END


Non c'è molto da dire... Non è real surround, ma gli assomiglia... Provate
a ritardare di più le due voci con un loop o qualcosa del genere e sentite
che effetti fà (arriva a fare l'effetto "sega elettrica" con un ritardo alto).
...Occhio a non ritardare troppo: generereste un'eco...
