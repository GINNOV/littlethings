	opt	c-

	section	"Disk Trakker",CODE_C

_ciaa   EQU     $bfe001
_ciab   EQU     $bfd100
_ciac   equ     $bfdd00
_custom EQU     $DFF000

mysync	= $4489

;  Psykos Disk driver routines - The COMPLETELY WORKING version       V6.7
;  comp 10:02pm    4-8-91                            (C) 1991 Cyrus UK....

;    variables are:-
; databuffer- points to disk mfm buffer            (14720 bytes)
; tempbuff  - points to the disk decoder workspace (5632 bytes)
; track     - the track number to go to
; side      - bit 0 controls side (0=side 0....)
; sync      - the disk syncro for the dma pickup

; NOTE!   If you want to load track by track, don't increase the TRACK var
; and jump to this routine because the `gototr' routine always returns the
; the head to track 0, then counts to the track you want. This'll fuck your
; drive up, so use `advtr' which just jumps up by 1 track, or `dectr' that
; does the opposite....

start
      	movem.l   d0-d7/a0-a6,-(sp)

	move.l #$70000,databuffer     ; the data buffer pointer
	move.l #$40000,tempbuff       ; the tempory buffer pointer

	jsr     init	; set the dma & interupts
	jsr     startd	; switch the drive on
	jsr     gototr	; goto the track numbered in the TRACK var
	jsr     readtr	; read the track into memory buffer
	jsr     decco	; do the MFM decoding
	jsr     stoppit	; return system back to normal

	movem.l   (sp)+,d0-d7/a0-a6
	rts

track	dc.w    0

side	dc.b    0

drive	dc.b	0
	
init	movea.l #_custom,a6
	move.w  intenar(a6),d0
	move.w  d0,intesav
	move.w  intreqr(a6),d0
	move.w  d0,intrsav
	move.w  dmaconr(a6),d0
	move.w  d0,dmasav
	move.w  adkconr(a6),d0
	move.w  d0,adksav
	move.w  #$0010,dmacon(a6)
	move.w  #$4000,intena(a6)
	move.w  #$0002,intreq(a6)
	move.w  #$7fff,adkcon(a6)
	move.w  #$8100,adkcon(a6)
	or.b    #$78,_ciab
	rts

startd	bclr    #7,_ciab
	moveq   #100,d0
	cmpi.b	#0,drive
	beq	st0
	cmpi.b	#1,drive
	beq	st1
	cmpi.b	#2,drive
	beq	st2
	bra	st3
st0	bclr    #3,_ciab
       	dbf     d0,st0
	bra	bta        	
st1	bclr    #4,_ciab
       	dbf     d0,st1
	bra	bta        	
st2	bclr    #5,_ciab
       	dbf     d0,st2
	bra	bta        	
st3	bclr    #6,_ciab
       	dbf     d0,st3
bta	bsr     wtrdy
    	rts

wtrdy  	move.w  #3000,d6
wt1    	dbf     d6,wt1
wt2  	btst    #5,_ciaa
        bne.s   wt2
        rts

gotot0  btst    #4,_ciaa
        beq.s   t0e
        bset    #1,_ciab
        bclr    #0,_ciab
        bset    #0,_ciab
        bsr     wtrdy
        bra.s   gotot0
t0e     rts

advtr
        bclr    #1,_ciab
        nop
        nop
        nop
        bclr    #0,_ciab
        nop
        nop
        nop
        bset    #0,_ciab
        bsr     wtrdy
	rts

dectr
        bset    #1,_ciab
        nop
        nop
        nop
        bclr    #0,_ciab
        nop
        nop
        nop
        bset    #0,_ciab
        bsr     wtrdy
	rts
gototr
        btst    #4,_ciaa
        beq.s   go1
        bsr     gotot0
        bra.s   gototr
go1     move.w  TRACK,d2
go2     cmpi.w  #0,d2
        beq.s   go3
        bclr    #1,_ciab
        nop
        nop
        nop
        bclr    #0,_ciab
        nop
        nop
        nop
        bset    #0,_ciab
        bsr     wtrdy
        subq.w  #1,d2
        bra.s   go2
go3     rts

readtr
two     cmpi.b	#1,side
	beq     side1
	bset.b  #2,_ciab       set side 0
	bra     cont
side1	bclr    #2,_ciab       set side 1
cont    move.w  #$8210,dmacon(a6)

	LEA	$dff000,A2
	MOVE.W	#$4000,$24(A2)
	MOVE.W	#2,$009C(A2)
	MOVE.W	#$7FFF,$9E(A2)
	MOVE.W	#$9500,$9E(A2)
	MOVE.W	#mysync,$7E(A2)
	MOVE.L	A3,-(SP)
	MOVE.L	databuffer,a3
	MOVE.L	A3,$20(A2)
	MOVE.L	(SP)+,A3
	MOVE.W	#$9CBE,$24(A2)
	MOVE.W	#$9CBE,$24(A2)
	BSR	waitdrive
	MOVE.W	#2,$9C(A2)
	MOVE.W	#$4000,$24(A2)
	RTS	
 
waitdrive	BTST	#1,$001F(A2)
	BEQ.S	waitdrive
	RTS	
	
        clr.w   dsklen(a6)
        move.w  #$0010,dmacon(a6)
        rts

waitidx move.b  _ciac,d6
idx1    move.b  _ciac,d6
        btst    #4,d6
        beq.s   idx1
        rts

decco	move.l	databuffer,a3

findgap	cmpi.w	#mysync,(a3)+
	bne	findgap
	cmpi.w	#mysync,(a3)
	bne	foundgap
	bra	findgap

foundgap	sub.l	#16,a3

	lea	$50000,a6
	move.l	tempbuff,a5
	move.w	#2,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$200,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$400,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$600,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$800,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$a00,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$c00,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$e00,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$1000,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$1200,a5
	move.w	#0,d2
	jsr     decode
	move.l	tempbuff,a5
	add.l	#$1400,a5
	move.w	#0,d2
	jsr     decode


	move.l	sec0ad,d0
	cmpi.l	#0,d0
	beq	fuk
	move.l	databuffer,d1
	move.l	tempbuff,d2
	move.l	d2,d3
	add.l	#$1600,d3
	sub.l	d0,d3
	sub.l	d2,d0
	move.l	sec0ad,a0
	move.l	d1,a1
	sub.l	#1,d3
	sub.l	#1,d0	
	
piss	move.b	(a0)+,(a1)+
	dbf	d3,piss
	move.l	d2,a0
piss2	move.b	(a0)+,(a1)+
	dbf	d0,piss2
	rts

fuk	move.l	databuffer,a0
	move.l	tempbuff,a1
	move.l	#$1600,d0
piss3	move.b	(a1)+,(a0)+
	dbf	d0,piss3
	rts

stoppit
        bset    #7,_ciab
        bset    #3,_ciab
        bclr    #3,_ciab
        move.w  intesav,d0
        bset    #15,d0
        move.w  d0,intena(a6)
        move.w  intrsav,d0
        bset    #15,d0
        move.w  d0,intreq(a6)
        move.w  dmasav,d0
        bset    #15,d0
        move.w  d0,dmacon(a6)
        move.w  adksav,d0
        bset    #15,d0
        move.w  d0,adkcon(a6)
        rts

decode	MOVE.L	#$55555555,D0
	MOVE.W	#$a,D1
synco1	CMP.W	#mysync,(A3)+
	BNE.S	synco1
	sub.w	d2,a3
	MOVE.L	(A3),D3
	MOVE.L	4(A3),D4
	AND.W	D0,D3
	LSL.W	#1,D3
	AND.W	D0,D4
	OR.W	D4,D3
	ASR.W	#8,D3
	MOVE.L	A5,A4
	cmpi.l	#$4489ffff,d3
	bne	notsec0
	bra	boloks
notsec0	sub.l	#2,a3
	move.l	a5,sec0ad
	
boloks	MULU	#0,D3
	ADD.W	D3,A4
	MOVE.L	$30(A3),D5
	MOVE.L	$34(A3),D4
	AND.L	D0,D5
	LSL.L	#1,D5
	AND.L	D0,D4
	OR.L	D4,D5

	LEA	$3a(A3),A3
	MOVEQ.L	#$7F,D2
redoo	MOVE.L	$200(A3),D3
	MOVE.L	(A3)+,D4
	AND.L	D0,D4
	LSL.L	#1,D4
	AND.L	D0,D3
	OR.L	D3,D4
	MOVE.L	D4,(A4)+
	EOR.L	D4,D5
	DBRA	D2,redoo
	MOVE.L	D5,D4
	LSR.L	#1,D5
	AND.L	D0,D4
	AND.L	D0,D5
	EOR.L	D4,D5
	BNE.S	notdone
	DBRA	D1,synco1
notdone	RTS	

databuffer 	dc.l    $70000
tempbuff	dc.l    $40000
intesav 	dc.w    0
intrsav 	dc.w    0
dmasav  	dc.w    0
adksav  	dc.w    0
sec0ad		dc.l	0

dskdatr	equ $008
dskbytr	equ $01a
intenar	equ $01c
intreqr	equ $01e
dskpt	equ $020
dsklen	equ $024
dskdat	equ $026
dsksync	equ $07e
dmacon	equ $096
intena	equ $09a
intreq	equ $09c
dmaconr	equ $002
adkconr	equ $010
adkcon	equ $09e
