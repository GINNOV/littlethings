
; Lezione11n2.s -Routine di temporizzazione che permette di attendere un
;		 certo numero di Hertz

Start:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$84(a6)	; forbid
	jsr	-$78(a6)	; disable
	LEA	$DFF000,A5

	bsr.s	CIAHZ	; Attendi un paio di secondi

	move.l	4.w,a6		; Execbase in a6
	jsr	-$7e(a6)	; enable
	jsr	-$8a(a6)	; permit
	rts


; bfe801 todlo	-	1=~0,02 secs o 1/50 sec (PAL) o 1/60 sec (NTSC)
; bfe901 todmid	-	1=~3 secs
; bfea01 todhi	-	1=~21 mins
;
; In pratica e' un timer che puo' contenere un numero a 23 bit, e tale num.
; e' diviso: bits 0-7 in TODLO, bits 8-15 in TODMID e bits 16-23 in TODHI.


CIAHZ:
	MOVE.L	A2,-(SP)
	LEA	$BFE001,A2	; CIAA base -> USATO
;	LEA	$BFD000,A2	; CIAB base

	MOVE.B	#0,$800(A2)	; TODLO - bit 7-0 del timer a 50-60hz
				; reset timer!
WCIA:
	CMPI.B	#50*2,$800(A2)	; TODLO - Wait time = 2 secondi...
	BGE.S	DONE
	BRA.S	WCIA
DONE:
	MOVE.L	(SP)+,A2
	RTS

	end

Da notare che se si vuole usare il CIAB, si passa ad un timer di sync
orizzontale e non verticale, per cui e' mooolto piu' veloce. Per attendere
2 secondi circa occorre scomodare il TODMID:

CIAHZ:
	MOVE.L	A2,-(SP)
;	LEA	$BFE001,A2	; CIAA base
	LEA	$BFD000,A2	; CIAB base -> USATO

	MOVE.B	#0,$800(A2)	; TODLO - bit 7-0 del timer a 50-60hz
				; reset timer!
WCIA:
	CMPI.B	#120,$900(A2)	; TODMID - Wait time = 2 secondi...
	BGE.S	DONE
	BRA.S	WCIA
DONE:
	MOVE.L	(SP)+,A2
	RTS

Attenzione al fatto che il TOD del CIAA e' usato dal timer.device, mentre il
TOD del CIAB e' usato dalla graphics.library!

Se potete, aspettate tempi brevi con la classica routine:

	lea	$dff006,a0	; VHPOSR
	moveq	#XXX-1,d0	; Numero di linee da aspettare
waitlines:
	move.b	(a0),d1		; $dff006 - linea verticale attuale in d1
stepline:
	cmp.b	(a0),d1		; siamo sempre alla stessa linea?
	beq.s	stepline	; se si aspetta
	dbra	d0,waitlines	; linea "aspettata", aspetta d0-1 linee
