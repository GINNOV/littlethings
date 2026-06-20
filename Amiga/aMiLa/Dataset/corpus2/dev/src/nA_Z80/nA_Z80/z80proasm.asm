שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
; Z80 disassembler by JUEN/VEEZYA'03

; thiz file is made only for fun!

; program: label - z80 code
; output ram:source_z80.asm
; z80 support: 99%
; juen@poczta.fm


TAB	=		5

m_long	=	1

	include	mAcra_juen.asm

	sect	code_P

start:	init

;	openin	__progname
;	move.l	d0,inprog
	openout	__sourcename
	move.l	d0,outprog
	move.l	#procomend-procom,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#procom,d2
	jsr	-48(a6)

	lea	program,a2

main_loop_phase1
	move.l	a2,a5
.pl	lea	code,a0
	moveq	#0,d2
.l0	move.l	(a0),d6
	move.b	(a5),d0
	cmp.b	(a0),d0
	beq.s	.sa
.l	cmp.w	#$FF00,(a0)
	beq.w	_nextphase
	cmp.w	#$FE00,(a0)	;koniec	kodu?
	beq.s	.tak
	addq.l	#1,a0
	bra.s	.l
.tak	addq.l	#2,a0
	addq.l	#1,d2
	bra.s	.l0
.sa	addq.l	#1,a0
	move.l	a5,a6
	move.l	len,len2
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	_koniec
.l1	cmp.w	#$FE00,(a0)	;end code?
	beq.s	.done
	cmp.w	#$FF00,(a0)
	beq.w	_nextphase
	move.b	(a5),d0
	cmp.b	(a0),d0
	bne.s	.nieto
	addq.l	#1,a0
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	_koniec
	bra.s	.l1
.nieto	move.l	a6,a5
	addq.l	#1,a0
	move.l	len2,len
	bra.w	.l0
.done	move.l	a6,-(sp)

	lea	commands,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	move.l	a1,a0
	sub.l	d4,d4
	subq.l	#1,d4
.la2	addq.l	#1,d4
	cmp.b	#0,(a0)+
	bne.s	.la2

	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	d4,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	a1,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)

	move.l	(sp)+,a6
	bra.l	.pl

__koniec:
	getr
_koniec:
;	closef	inprog
	closef	outprog

	dosend

_nextphase:
	putr
	lea	codeph2,a0
	moveq	#0,d2

.l	move.b	(a5),d7
	cmp.b	(a0)+,d7
	beq.s	.done
	cmp.b	#$FF,(a0)
	beq.w	.nothing
	addq.l	#1,d2
	bra.s	.l
.done	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.s	__koniec
	lea	commandsph2,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	sub.l	d3,d3
	lea	realcom,a0
.ll2	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#"$",(a1)
	bne.s	.ll2
	addq.l	#1,a1
	;wstaw 8bit
	sub.l	d0,d0
	move.b	(a5)+,d0
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+6,a4
	cmp.b	#"9",(a4)
	ble	.sk
	move.b	#"0",(a0)+
	addq.l	#1,d3
.sk	move.w	(a4),(a0)+
	move.b	#"H",(a0)+
	addq.l	#3,d3
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#0,(a1)
	bne.s	.l4
.okk
	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#realcom,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	a5,realcom
	getr
	move.l	realcom,a5
	bra.w	main_loop_phase1\.pl
	

.nothing
	getr

_phase3:putr
	lea	codeph3,a0
	moveq	#0,d2

.l	move.b	(a5),d7
	cmp.b	(a0)+,d7
	beq.s	.done
	cmp.b	#$FF,(a0)
	beq.w	.nothing
	addq.l	#1,d2
	bra.s	.l
.done	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	lea	commandsph3,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	sub.l	d3,d3
	lea	realcom,a0
.ll2	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#"$",(a1)
	bne.s	.ll2
	addq.l	#1,a1
	;wstaw 16bit
	sub.l	d0,d0
	move.w	(a5)+,d0
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+4,a4
	move.w	2(a4),d0
	move.w	(a4),2(a4)
	move.w	d0,(a4)
	cmp.b	#"9",(a4)
	ble	.sk
	move.b	#"0",(a0)+
	addq.l	#1,d3
.sk	move.l	(a4),(a0)+
	move.b	#"H",(a0)+
	addq.l	#5,d3
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#0,(a1)
	bne.s	.l4
.okk
	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#realcom,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	a5,realcom
	getr
	move.l	realcom,a5
	bra.w	main_loop_phase1\.pl
	

.nothing
	getr

_phase4:putr
	lea	codeph4,a0
	moveq	#0,d2

.l	move.w	(a5),d7
	cmp.w	(a0)+,d7
	beq.s	.done
	cmp.w	#$FFFF,(a0)
	beq.w	.nothing
	addq.l	#1,d2
	bra.s	.l
.done	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	lea	commandsph4,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	sub.l	d3,d3
	lea	realcom,a0
.ll2	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#"$",(a1)
	bne.s	.ll2
	addq.l	#1,a1
	;wstaw 16bit
	sub.l	d0,d0
	move.w	(a5)+,d0
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+4,a4
	move.b	1(a4),d0
	move.b	(a4),1(a4)
	move.b	d0,(a4)
	cmp.b	#"9",(a4)
	ble	.sk
	move.b	#"0",(a0)+
	addq.l	#1,d3
.sk	move.l	(a4),(a0)+
	move.b	#"H",(a0)+
	addq.l	#5,d3
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#0,(a1)
	bne.s	.l4
.okk
	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#realcom,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	a5,realcom
	getr
	move.l	realcom,a5
	bra.w	main_loop_phase1\.pl
	

.nothing
	getr

_phase5:putr
	lea	codeph5,a0
	moveq	#0,d2

.l	move.w	(a5),d7
	cmp.w	(a0)+,d7
	beq.s	.done
	cmp.w	#$FFFF,(a0)
	beq.w	.nothing
	addq.l	#1,d2
	bra.s	.l
.done	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	lea	commandsph5,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	sub.l	d3,d3
	lea	realcom,a0
.ll2	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#"$",(a1)
	bne.s	.ll2
	addq.l	#1,a1
	;wstaw 8bit
	sub.l	d0,d0
	move.b	(a5)+,d0
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+6,a4
	cmp.b	#"9",(a4)
	ble	.sk
	move.b	#"0",(a0)+
	addq.l	#1,d3
.sk	move.w	(a4),(a0)+
	move.b	#"H",(a0)+
	addq.l	#3,d3
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#0,(a1)
	bne.s	.l4
.okk
	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#realcom,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	a5,realcom
	getr
	move.l	realcom,a5
	bra.w	main_loop_phase1\.pl
	

.nothing
	getr

_phase6:putr
	lea	codeph6,a0
	moveq	#0,d2

.l	move.w	(a5),d7
	cmp.w	(a0)+,d7
	beq.s	.done
	cmp.b	#$FF,(a0)
	beq.w	.nothing
	addq.l	#1,d2
	addq.l	#2,a0
	bra.s	.l
.done	addq.l	#1,a0
	move.b	(a0)+,d7
	addq.l	#1,d2
	cmp.b	3(a5),d7
	bne.w	.l
	subq.l	#1,d2
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	lea	commandsph6,a1
.t1	tst.l	d2
	beq.s	.ok1
.la1	cmp.b	#0,(a1)+
	bne.s	.la1
	subq.l	#1,d2
	bra.s	.t1
.ok1	sub.l	d3,d3
	lea	realcom,a0
.ll2	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#"$",(a1)
	bne.s	.ll2
	addq.l	#1,a1
	;wstaw 8bit
	sub.l	d0,d0
	move.b	(a5)+,d0
	addq.l	#1,a5
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+6,a4
	cmp.b	#"9",(a4)
	ble	.sk
	move.b	#"0",(a0)+
	addq.l	#1,d3
.sk	move.w	(a4),(a0)+
	move.b	#"H",(a0)+
	addq.l	#3,d3
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	addq.l	#1,d3
	cmp.b	#0,(a1)
	bne.s	.l4
.okk
	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#realcom,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	a5,realcom
	getr
	move.l	realcom,a5
	bra.w	main_loop_phase1\.pl
	

.nothing
	getr

_db
	sub.l	d0,d0
	move.b	(a5)+,d0
	sub.l	#1,len
	cmp.l	#0,len
	beq.w	__koniec
	putr
	lea	da_bin1+8,a1
	bsr.w	hex_print	;zamiana numeru bin na ascii
	getr
	lea	da_bin1+6,a4
	cmp.b	#"9",(a4)
	ble	.sk
	lea	what+3,a0
	move.b	#"0",(a0)+
.sk	move.w	(a4),(a0)+
	move.b	#"H",(a0)+
	tst.b	(a1)
	beq.s	.okk
.l4	move.b	(a1)+,(a0)+
	cmp.b	#0,(a1)
	bne.s	.l4
.okk

	move.l	a5,-(sp)

	putr
	moveq	#TAB,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#space,d2
	jsr	-48(a6)
	getr

	moveq	#10,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#WHAT,d2
	jsr	-48(a6)
	moveq	#1,d3
	move.l	dosbase,a6
	move.l	outprog,d1
	move.l	#enter,d2
	jsr	-48(a6)
	move.l	(sp)+,a5

	bra.l	main_loop_phase1\.pl


	print	"ERROR!: Unknow code!"
	closef	outprog
	dosend

Hex_Print
	movem.l	d0/d1/a1/a2,-(a7)
	clr.l	d1
	lea	CharHex,a2
	moveq	#3,d2
Hex_Print_Loop
	move.b	d0,d1
	and.b	#$f,d1
	move.b	(a2,d1),-(a1)
	move.b	d0,d1
	lsr.b	#4,d1
	move.b	(a2,d1),-(a1)
	lsr.l	#8,d0
	dbf	d2,Hex_Print_Loop
	movem.l	(a7)+,d0/d1/a1/a2
	lea	-$13(a1),a1
	rts	
;-----------------------
CharHex	dc.b	"0123456789ABCDEF"
;-----------------------

what	dc.b	"DB       ;",0
space	dc.b	"                           "
enter	dc.b	10

len	dc.l	(programend-program)
len2	dc.l	0

inprog	dc.l	0
outprog	dc.l	0

program:

; cbcc -> cbff?

	dc.b	0,$cb,$cb,2
	dc.b	0,$cb,$dd,$dd,$f9,$cb,$ff,$cb,$cc,$06,$10,0
	dc.b	$f2,$CA,$FE
;	incbin	!:migus.z80
	dc.b	$00,$00,$00,$dd,$cb,$10,$2e,$ff,$ff

;	incbin	ram:migus.z80

	dc.b	$00
programend

__progname:
	dc.b	'!:program.z80',0
__sourcename:
	dc.b	'RAM:source_z80.asm',0

	sect	data_p

codeph6	;XXXXddXX

	dc.l	$ddcb0006
	dc.l	$ddcb000e
	dc.l	$ddcb0016
	dc.l	$ddcb001e
	dc.l	$ddcb0026
	dc.l	$ddcb002e
	dc.l	$ddcb003e
	dc.l	$ddcb0046
	dc.l	$ddcb004e
	dc.l	$ddcb0056
	dc.l	$ddcb005e
	dc.l	$ddcb0066
	dc.l	$ddcb006e
	dc.l	$ddcb0076
	dc.l	$ddcb007e
	dc.l	$ddcb0086
	dc.l	$ddcb008e
	dc.l	$ddcb0096
	dc.l	$ddcb009e
	dc.l	$ddcb00a6
	dc.l	$ddcb00ae
	dc.l	$ddcb00b6
	dc.l	$ddcb00be
	dc.l	$ddcb00c6
	dc.l	$ddcb00ce
	dc.l	$ddcb00d6
	dc.l	$ddcb00de
	dc.l	$ddcb00e6
	dc.l	$ddcb00ee
	dc.l	$ddcb00f6
	dc.l	$ddcb00fe

	dc.l	$fdcb0006
	dc.l	$fdcb000e
	dc.l	$fdcb0016
	dc.l	$fdcb001e
	dc.l	$fdcb0026
	dc.l	$fdcb002e
	dc.l	$fdcb003e
	dc.l	$fdcb0046
	dc.l	$fdcb004e
	dc.l	$fdcb0056
	dc.l	$fdcb005e
	dc.l	$fdcb0066
	dc.l	$fdcb006e
	dc.l	$fdcb0076
	dc.l	$fdcb007e
	dc.l	$fdcb0086
	dc.l	$fdcb008e
	dc.l	$fdcb0096
	dc.l	$fdcb009e
	dc.l	$fdcb00a6
	dc.l	$fdcb00ae
	dc.l	$fdcb00b6
	dc.l	$fdcb00be
	dc.l	$fdcb00c6
	dc.l	$fdcb00ce
	dc.l	$fdcb00d6
	dc.l	$fdcb00de
	dc.l	$fdcb00e6
	dc.l	$fdcb00ee
	dc.l	$fdcb00f6
	dc.l	$fdcb00fe
	dc.l	$ffffffff

commandsph6

	dc.b	"RLC (IX+$)",0,"RRC (IX+$)",0,"RL (IX+$)",0,"RR (IX+$)",0
	dc.b	"SLA (IX+$)",0,"SRA (IX+$)",0,"SRL (IX+$)",0
	dc.b	"BIT 0,(IX+$)",0
	dc.b	"BIT 1,(IX+$)",0
	dc.b	"BIT 2,(IX+$)",0
	dc.b	"BIT 3,(IX+$)",0
	dc.b	"BIT 4,(IX+$)",0
	dc.b	"BIT 5,(IX+$)",0
	dc.b	"BIT 6,(IX+$)",0
	dc.b	"BIT 7,(IX+$)",0
	dc.b	"RES 0,(IX+$)",0
	dc.b	"RES 1,(IX+$)",0
	dc.b	"RES 2,(IX+$)",0
	dc.b	"RES 3,(IX+$)",0
	dc.b	"RES 4,(IX+$)",0
	dc.b	"RES 5,(IX+$)",0
	dc.b	"RES 6,(IX+$)",0
	dc.b	"RES 7,(IX+$)",0
	dc.b	"SET 0,(IX+$)",0
	dc.b	"SET 1,(IX+$)",0
	dc.b	"SET 2,(IX+$)",0
	dc.b	"SET 3,(IX+$)",0
	dc.b	"SET 4,(IX+$)",0
	dc.b	"SET 5,(IX+$)",0
	dc.b	"SET 6,(IX+$)",0
	dc.b	"SET 7,(IX+$)",0

	dc.b	"RLC (IY+$)",0,"RRC (IY+$)",0,"RL (IY+$)",0,"RR (IY+$)",0
	dc.b	"SLA (IY+$)",0,"SRA (IY+$)",0,"SRL (IY+$)",0
	dc.b	"BIT 0,(IY+$)",0
	dc.b	"BIT 1,(IY+$)",0
	dc.b	"BIT 2,(IY+$)",0
	dc.b	"BIT 3,(IY+$)",0
	dc.b	"BIT 4,(IY+$)",0
	dc.b	"BIT 5,(IY+$)",0
	dc.b	"BIT 6,(IY+$)",0
	dc.b	"BIT 7,(IY+$)",0
	dc.b	"RES 0,(IY+$)",0
	dc.b	"RES 1,(IY+$)",0
	dc.b	"RES 2,(IY+$)",0
	dc.b	"RES 3,(IY+$)",0
	dc.b	"RES 4,(IY+$)",0
	dc.b	"RES 5,(IY+$)",0
	dc.b	"RES 6,(IY+$)",0
	dc.b	"RES 7,(IY+$)",0
	dc.b	"SET 0,(IY+$)",0
	dc.b	"SET 1,(IY+$)",0
	dc.b	"SET 2,(IY+$)",0
	dc.b	"SET 3,(IY+$)",0
	dc.b	"SET 4,(IY+$)",0
	dc.b	"SET 5,(IY+$)",0
	dc.b	"SET 6,(IY+$)",0
	dc.b	"SET 7,(IY+$)",0

codeph5	;XXXXdd

	dc.w	$dd46,$dd4e,$dd56,$dd5e,$dd66,$dd6e,$dd70,$dd71,$dd72,$dd73
	dc.w	$dd74,$dd75,$dd77,$dd7e,$dd86,$dd8e,$dd96,$dd9e,$dda6,$ddae
	dc.w	$ddb6,$ddbe,$fd34,$fd35,$fd46,$fd4e,$fd56,$fd5e,$fd66,$fd6e
	dc.w	$fd70,$fd71,$fd72,$fd73,$fd74,$fd75,$fd77,$fd7e,$fd86,$fd8e
	dc.w	$fd96,$fd9e,$fda6,$fdae,$fdb6,$fdbe,$ffff;juenNAH_APXam1ga!

commandsph5

	dc.b	"LD B,(IX+$)",0,"LD C,(IX+$)",0,"LD D,(IX+$)",0,"LD E,(IX+$)",0
	dc.b	"LD H,(IX+$)",0,"LD L,(IX+$)",0,"LD (IX+$),B",0,"LD (IX+$),C",0
	dc.b	"LD (IX+$),D",0,"LD (IX+$),E",0,"LD (IX+$),H",0,"LD (IX+$),L",0
	dc.b	"LD (IX+$),A",0,"LD A,(IX+$)",0,"ADD A,(IX+$)",0,"ADC A,(IX+$)",0
	dc.b	"SUB (IX+$)",0,"SBC (IX+$)",0,"AND (IX+$)",0,"XOR (IX+$)",0
	dc.b	"OR (IX+$)",0,"CP (IX+$)",0,"INC (IY+$)",0,"DEC (IY+$)",0
	dc.b	"LD B,(IY+$)",0,"LD C,(IY+$)",0,"LD D,(IY+$)",0,"LD E,(IY+$)",0
	dc.b	"LD H,(IY+$)",0,"LD L,(IY+$)",0,"LD (IY+$),B",0,"LD (IY+$),C",0
	dc.b	"LD (IY+$),D",0,"LD (IY+$),E",0,"LD (IY+$),H",0,"LD (IY+$),L",0
	dc.b	"LD (IY+$),A",0,"LD A,(IY+$)",0,"ADD A,(IY+$)",0,"ADC A,(IY+$)",0
	dc.b	"SUB (IY+$)",0,"SBC A,(IY+$)",0,"AND (IY+$)",0,"XOR (IY+$)",0
	dc.b	"OR (IY+$)",0,"CP (IY+$)",0

codeph4	;XXXXnnnn
	dc.w	$dd21,$dd22,$dd2a,$ed43,$ed4b,$ed53,$ed5b,$ed73,$ed7b,$fd21
	dc.w	$fd22,$fd2a,$ffff

commandsph4
	dc.b	"LD IX,$",0,"LD ($),IX",0,"LD IX,($)",0,"LD ($),BC",0
	dc.b	"LD BC,($)",0,"LD ($),DE",0,"LD DE,($)",0,"LD ($),SP",0
	dc.b	"LD SP,($)",0,"LD IY,$",0,"LD ($),IY",0,"LD IY,($)",0

codeph3	;XXnnnn
	dc.b	$f2,$f4,$fa,$fc
	dc.b	1,$11,$21,$22,$2a,$31,$32,$3a
	dc.b	$c2,$c3,$c4,$ca,$cc,$cd,$d2,$d4,$da,$dc,$e2,$e4,$ea,$ec
	dc.b	$ff	;end phase3

commandsph3
	dc.b	"JP P,$",0,"CALL P,$",0,"JP M,$",0,"CALL M,$",0

	dc.b	"LD BC,$",0,"LD DE,$",0,"LD HL,$",0,"LD ($),HL",0,"LD HL,($)",0
	DC.B	"LD SP,$",0,"LD ($),A",0,"LD A,($)",0

	DC.B	"JP NZ,$",0,"JP $",0,"CALL NZ,$",0,"JP Z,$",0,"CALL Z,$",0
	DC.B	"CALL $",0,"JP NC,$",0,"CALL NC,$",0,"JP C,$",0,"CALL C,$",0
	DC.B	"JP PO,$",0,"CALL PO,$",0,"JP PE,$",0,"CALL PE,$",0

codeph2	;XXnn
	dc.b	$06,$e,$10,$16,$18,$1e,$20,$26,$28,$2e,$30,$36,$38,$3e
	dc.b	$c6,$ce,$d3,$d6,$db,$de,$e6,$ee
	dc.b	$f6,$fe
	dc.b	$FF	;end phase2

commandsph2
	dc.b	"LD B,$",0,"LD C,$",0,"DJNZ $",0,"LD D,$",0,"JR $",0,"LD E,$",0
	dc.b	"JR NZ,$",0,"LD H,$",0,"JR Z,$",0,"LD L,$",0,"JR NC,$",0
	DC.B	"LD (HL),$",0,"JR C,$",0,"LD A,$",0

	DC.B	"ADD A,$",0,"ADC A,$",0,"OUT ($),A",0,"SUB $",0,"IN A,($)",0,"SBC A,$",0,"AND $",0,"XOR $",0

	DC.B	"OR $",0,"CP $",0

code
	dc.b	$00,$FE,$0,$02,$FE,$0,$03,$FE,$0,$04,$FE,$0,$05,$FE,$0,$07,$fe,$0,$08,$fe,$0,$09,$fe,$0,$0a,$fe,$0,$0b,$fe,$0
	dc.b	$0c,$fe,$0,$0d,$fe,$0,$0f,$fe,$0,$12,$fe,$0,$13,$fe,$0,$14,$fe,$0,$15,$fe,$0,$17,$fe,$0,$19,$fe,$0,$1a,$fe,$0
	dc.b	$1b,$fe,$0,$1c,$fe,$0,$1d,$fe,$0,$1f,$fe,$0,$23,$fe,$0,$24,$fe,$0,$25,$fe,$0,$27,$fe,$0,$29,$fe,$0,$2b,$fe,$0
	dc.b	$2c,$fe,$0,$2d,$fe,$0,$2f,$fe,$0,$33,$fe,$0,$34,$fe,$0,$35,$fe,$0,$37,$fe,$0,$39,$fe,$0,$3b,$fe,$0,$3c,$fe,$0
	dc.b	$3d,$fe,$0,$3f,$fe,$0,$40,$fe,$0,$41,$fe,$0,$42,$fe,$0,$43,$fe,$0,$44,$fe,$0,$45,$fe,$0,$46,$fe,$0,$47,$fe,$0
	dc.b	$48,$fe,$0,$49,$fe,$0,$4a,$fe,$0,$4b,$fe,$0,$4c,$fe,$0,$4d,$fe,$0,$4e,$fe,$0,$4f,$fe,$0,$50,$fe,$0,$51,$fe,$0
	dc.b	$52,$fe,$0,$53,$fe,$0

	dc.b	$54,$FE,$0,$55,$FE,$0,$56,$FE,$0,$57,$FE,$0,$58,$FE,$0,$59,$FE,$0,$5a,$FE,$0,$5b,$FE,$0,$5c,$FE,$0,$5d,$FE,$0
	dc.b	$5e,$FE,$0,$5f,$FE,$0,$60,$FE,$0,$61,$FE,$0,$62,$FE,$0,$63,$FE,$0,$64,$FE,$0,$65,$FE,$0,$66,$FE,$0,$67,$FE,$0
	dc.b	$68,$FE,$0,$69,$FE,$0,$6a,$FE,$0,$6b,$FE,$0,$6c,$FE,$0,$6d,$FE,$0,$6e,$FE,$0,$6f,$FE,$0,$70,$FE,$0,$71,$FE,$0
	dc.b	$72,$FE,$0,$73,$FE,$0,$74,$FE,$0,$75,$FE,$0,$76,$FE,$0,$77,$FE,$0,$78,$FE,$0,$79,$FE,$0,$7a,$FE,$0,$7b,$FE,$0
	dc.b	$7c,$FE,$0,$7d,$FE,$0,$7e,$FE,$0,$7f,$FE,$0,$80,$FE,$0,$81,$FE,$0,$82,$FE,$0,$83,$FE,$0,$84,$FE,$0,$85,$FE,$0
	dc.b	$86,$FE,$0,$87,$FE,$0,$88,$FE,$0,$89,$FE,$0,$8a,$FE,$0,$8b,$FE,$0,$8c,$FE,$0,$8d,$FE,$0,$8e,$FE,$0,$8f,$FE,$0
	dc.b	$90,$FE,$0,$91,$FE,$0,$92,$FE,$0,$93,$FE,$0,$94,$FE,$0,$95,$FE,$0,$96,$FE,$0,$97,$FE,$0,$98,$FE,$0,$99,$FE,$0
	dc.b	$9a,$FE,$0,$9b,$FE,$0,$9c,$FE,$0,$9d,$FE,$0,$9e,$FE,$0,$9f,$FE,$0,$a0,$FE,$0,$a1,$FE,$0,$a2,$FE,$0,$a3,$FE,$0
	dc.b	$a4,$FE,$0,$a5,$FE,$0,$a6,$FE,$0,$a7,$FE,$0,$a8,$FE,$0,$a9,$FE,$0,$aa,$FE,$0,$ab,$FE,$0,$ac,$FE,$0,$ad,$FE,$0
	dc.b	$ae,$FE,$0,$af,$FE,$0,$b0,$FE,$0,$b1,$FE,$0,$b2,$FE,$0,$b3,$FE,$0,$b4,$FE,$0,$b5,$FE,$0,$b6,$FE,$0,$b7,$FE,$0
	dc.b	$b8,$FE,$0,$b9,$FE,$0,$ba,$FE,$0,$bb,$FE,$0,$bc,$FE,$0,$bd,$FE,$0,$be,$FE,$0,$bf,$FE,$0,$c0,$FE,$0,$c1,$FE,$0
	dc.b	$c5,$FE,$0,$c7,$FE,$0,$c8,$FE,$0,$c9,$FE,$0,$cf,$FE,$0,$d0,$FE,$0,$d1,$FE,$0,$d5,$FE,$0,$d7,$FE,$0,$d8,$FE,$0
	dc.b	$d9,$FE,$0,$df,$FE,$0,$e0,$FE,$0,$e1,$FE,$0,$e3,$FE,$0,$e5,$FE,$0,$e7,$FE,$0,$e8,$FE,$0,$e9,$FE,$0,$eb,$FE,$0
	dc.b	$ef,$FE,$0,$f0,$FE,$0,$f1,$FE,$0,$f3,$FE,$0,$f5,$FE,$0,$f7,$FE,$0,$f8,$FE,$0,$f9,$FE,$0,$fb,$FE,$0,$ff,$FE,$0

	dc.b	$CB,$00,$FE,$00

	dc.w	$cb01,$Fe00,$cb02,$fe00,$cb03,$fe00,$cb04,$fe00,$cb05,$fe00
	dc.w	$cb06,$Fe00,$cb07,$fe00,$cb08,$fe00,$cb09,$fe00,$cb0a,$fe00
	dc.w	$cb0b,$Fe00,$cb0c,$fe00,$cb0d,$fe00,$cb0e,$fe00,$cb0f,$fe00
	dc.w	$cb10,$Fe00,$cb11,$fe00,$cb12,$fe00,$cb13,$fe00,$cb14,$fe00
	dc.w	$cb15,$Fe00,$cb16,$fe00,$cb17,$fe00,$cb18,$fe00,$cb19,$fe00
	dc.w	$cb1a,$Fe00,$cb1b,$fe00,$cb1c,$fe00,$cb1d,$fe00,$cb1e,$fe00
	dc.w	$cb1f,$Fe00,$cb20,$fe00,$cb21,$fe00,$cb22,$fe00,$cb23,$fe00
	dc.w	$cb24,$Fe00,$cb25,$fe00,$cb26,$fe00,$cb27,$fe00,$cb28,$fe00
	dc.w	$cb29,$Fe00,$cb2a,$fe00,$cb2b,$fe00,$cb2c,$fe00,$cb2d,$fe00
	dc.w	$cb2e,$Fe00,$cb2f,$fe00
	dc.w	$cb38,$Fe00,$cb39,$fe00,$cb3a,$fe00,$cb3b,$fe00,$cb3c,$fe00
	dc.w	$cb3d,$Fe00,$cb3e,$fe00,$cb3f,$fe00,$cb40,$fe00,$cb41,$fe00
	dc.w	$cb42,$Fe00,$cb43,$fe00,$cb44,$fe00,$cb45,$fe00,$cb46,$fe00
	dc.w	$cb47,$Fe00,$cb48,$fe00,$cb49,$fe00,$cb4a,$fe00,$cb4b,$fe00
	dc.w	$cb4c,$Fe00,$cb4d,$fe00,$cb4e,$fe00,$cb4f,$fe00,$cb50,$fe00
	dc.w	$cb51,$Fe00,$cb52,$fe00,$cb53,$fe00,$cb54,$fe00,$cb55,$fe00
	dc.w	$cb56,$Fe00,$cb57,$fe00,$cb58,$fe00,$cb59,$fe00,$cb5a,$fe00
	dc.w	$cb5b,$Fe00,$cb5c,$fe00,$cb5d,$fe00,$cb5e,$fe00,$cb5f,$fe00
	dc.w	$cb60,$Fe00,$cb61,$fe00,$cb62,$fe00,$cb63,$fe00,$cb64,$fe00
	dc.w	$cb65,$Fe00,$cb66,$fe00,$cb67,$fe00,$cb68,$fe00,$cb69,$fe00
	dc.w	$cb6a,$Fe00,$cb6b,$fe00,$cb6c,$fe00,$cb6d,$fe00,$cb6e,$fe00
	dc.w	$cb6f,$Fe00,$cb70,$fe00,$cb71,$fe00,$cb72,$fe00,$cb73,$fe00
	dc.w	$cb74,$Fe00,$cb75,$fe00,$cb76,$fe00,$cb77,$fe00,$cb78,$fe00
	dc.w	$cb79,$Fe00,$cb7a,$fe00,$cb7b,$fe00,$cb7c,$fe00,$cb7d,$fe00
	dc.w	$cb7e,$Fe00,$cb7f,$fe00,$cb80,$fe00,$cb81,$fe00,$cb82,$fe00
	dc.w	$cb83,$Fe00,$cb84,$fe00,$cb85,$fe00,$cb86,$fe00,$cb87,$fe00
	dc.w	$cb88,$Fe00,$cb89,$fe00,$cb8a,$fe00,$cb8b,$fe00,$cb8c,$fe00
	dc.w	$cb8d,$Fe00,$cb8e,$fe00,$cb8f,$fe00,$cb90,$fe00,$cb91,$fe00
	dc.w	$cb92,$Fe00,$cb93,$fe00,$cb94,$fe00,$cb95,$fe00,$cb96,$fe00
	dc.w	$cb97,$Fe00,$cb98,$fe00,$cb99,$fe00,$cb9a,$fe00,$cb9b,$fe00
	dc.w	$cb9c,$Fe00,$cb9d,$fe00,$cb9e,$fe00,$cb9f,$fe00,$cba0,$fe00
	dc.w	$cba1,$Fe00,$cba2,$fe00,$cba3,$fe00,$cba4,$fe00,$cba5,$fe00
	dc.w	$cba6,$Fe00,$cba7,$fe00,$cba8,$fe00,$cba9,$fe00,$cbaa,$fe00
	dc.w	$cbab,$Fe00,$cbac,$fe00,$cbad,$fe00,$cbae,$fe00,$cbaf,$fe00
	dc.w	$cbb0,$Fe00,$cbb1,$fe00,$cbb2,$fe00,$cbb3,$fe00,$cbb4,$fe00
	dc.w	$cbb5,$Fe00,$cbb6,$fe00,$cbb7,$fe00,$cbb8,$fe00,$cbb9,$fe00
	dc.w	$cbba,$Fe00,$cbbb,$fe00,$cbbc,$fe00,$cbbd,$fe00,$cbbe,$fe00
	dc.w	$cbbf,$Fe00,$cbc0,$fe00,$cbc1,$fe00,$cbc2,$fe00,$cbc3,$fe00
	dc.w	$cbc4,$Fe00,$cbc5,$fe00,$cbc6,$fe00,$cbc7,$fe00,$cbc8,$fe00
	dc.w	$cbc9,$Fe00,$cbca,$fe00,$cbcb,$fe00,$cbcc,$fe00,$cbcd,$fe00
	dc.w	$cbce,$Fe00,$cbcf,$fe00,$cbd0,$fe00,$cbd1,$fe00,$cbd2,$fe00
	dc.w	$cbd3,$Fe00,$cbd4,$fe00,$cbd5,$fe00,$cbd6,$fe00,$cbd7,$fe00
	dc.w	$cbd8,$Fe00,$cbd9,$fe00,$cbda,$fe00,$cbdb,$fe00,$cbdc,$fe00
	dc.w	$cbdd,$Fe00,$cbde,$fe00,$cbdf,$fe00,$cbe0,$fe00,$cbe1,$fe00
	dc.w	$cbe2,$Fe00,$cbe3,$fe00,$cbe4,$fe00,$cbe5,$fe00,$cbe6,$fe00
	dc.w	$cbe7,$Fe00,$cbe8,$fe00,$cbe9,$fe00,$cbea,$fe00,$cbeb,$fe00
	dc.w	$cbec,$Fe00,$cbed,$fe00,$cbee,$fe00,$cbef,$fe00,$cbf0,$fe00
	dc.w	$cbf1,$Fe00,$cbf2,$fe00,$cbf3,$fe00,$cbf4,$fe00,$cbf5,$fe00
	dc.w	$cbf6,$Fe00,$cbf7,$fe00,$cbf8,$fe00,$cbf9,$fe00,$cbfa,$fe00
	dc.w	$cbfb,$Fe00,$cbfc,$fe00,$cbfd,$fe00,$cbfe,$fe00,$cbff,$fe00
	dc.w	$dd09,$Fe00,$dd19,$fe00,$dd23,$fe00,$dd29,$fe00,$dd2b,$fe00
	dc.w	$dd39,$Fe00,$dde1,$fe00,$dde3,$fe00,$dde5,$fe00,$dde9,$fe00
	dc.w	$ddf9,$Fe00,$ed40,$fe00,$ed41,$fe00,$ed42,$fe00,$ed44,$fe00
	dc.w	$ed45,$Fe00,$ed46,$fe00,$ed47,$fe00,$ed48,$fe00,$ed49,$fe00
	dc.w	$ed4a,$Fe00,$ed4d,$fe00,$ed4f,$fe00,$ed50,$fe00,$ed51,$fe00
	dc.w	$ed52,$Fe00,$ed56,$fe00,$ed57,$fe00,$ed58,$fe00,$ed59,$fe00
	dc.w	$ed5a,$Fe00,$ed5e,$fe00,$ed5f,$fe00,$ed60,$fe00,$ed61,$fe00
	dc.w	$ed62,$Fe00,$ed67,$fe00,$ed68,$fe00,$ed69,$fe00,$ed6a,$fe00
	dc.w	$ed6f,$Fe00,$ed72,$fe00,$ed78,$fe00,$ed79,$fe00,$ed7a,$fe00
	dc.w	$eda0,$Fe00,$eda1,$fe00,$eda2,$fe00,$eda3,$fe00,$eda8,$fe00
	dc.w	$eda9,$Fe00,$edaa,$fe00,$edab,$fe00,$edb0,$fe00,$edb1,$fe00
	dc.w	$edb2,$Fe00,$edb3,$fe00,$edb8,$fe00,$edb9,$fe00,$edba,$fe00
	dc.w	$edbb,$Fe00,$fd09,$fe00,$fd19,$fe00,$fd23,$fe00,$fd29,$fe00
	dc.w	$fd2b,$Fe00,$fd39,$fe00,$fde1,$fe00,$fde3,$fe00,$fde5,$fe00
	dc.w	$fde9,$Fe00,$fdf9,$fe00

	dc.b	$FD,$FD,$FE,0,$FF,$00
commands
	dc.b	"NOP",0,	"LD (BC),A",0,	"INC BC",0,	"INC B",0
	dc.b	"DEC B",0,	"RLCA",0
	dc.b	"EX AF,AF",0,	"ADD HL,BC",0,	"LD A,(BC)",0,	"DEC BC",0
	dc.b	"INC C",0,	"DEC C",0,	"RRCA",0,	"LD (DE),A",0
	dc.b	"INC DE",0,	"INC D",0,	"DEC D",0,	"RLA",0
	dc.b	"ADD HL,DE",0,	"LD A,(DE)",0,	"DEC DE",0,	"INC E",0
	dc.b	"DEC E",0,	"RRA",0,	"INC HL",0,	"INC H",0
	dc.b	"DEC H",0,	"DAA",0,	"ADD HL,HL",0,	"DEC HL",0
	dc.b	"INC L",0,	"DEC L",0,	"CPL",0,	"INC SP",0
	dc.b	"INC (HL)",0,	"DEC (HL)",0,	"SCF",0,	"ADD HL,SP",0
	dc.b	"DEC SP",0,	"INC A",0,	"DEC A",0,	"CCF",0
	dc.b	"LD B,B",0,	"LD B,C",0,	"LD B,D",0,	"LD B,E",0
	dc.b	"LD B,H",0,	"LD B,L",0,	"LD B,(HL)",0,	"LD B,A",0
	dc.b	"LD C,B",0,	"LD C,C",0,	"LD C,D",0,	"LD C,E",0
	dc.b	"LD C,H",0,	"LD C,L",0,	"LD C,(HL)",0,	"LD C,A",0
	dc.b	"LD D,B",0,	"LD D,C",0,	"LD D,D",0,	"LD D,E",0

	dc.b	"LD D,H",0,	"LD D,L",0,	"LD D,(HL)",0,	"LD D,A",0
	dc.b	"LD E,B",0,	"LD E,C",0,	"LD E,D",0,	"LD E,E",0
	dc.b	"LD E,H",0,	"LD E,L",0,	"LD E,(HL)",0,	"LD E,A",0
	dc.b	"LD H,B",0,	"LD H,C",0,	"LD H,D",0,	"LD H,E",0
	dc.b	"LD H,H",0,	"LD H,L",0,	"LD H,(HL)",0,	"LD H,A",0
	dc.b	"LD L,B",0,	"LD L,C",0,	"LD L,D",0,	"LD L,E",0
	dc.b	"LD L,H",0,	"LD L,L",0,	"LD L,(HL)",0,	"LD L,A",0
	dc.b	"LD (HL),B",0,	"LD (HL),C",0,	"LD (HL),D",0,	"LD (HL),E",0
	dc.b	"LD (HL),H",0,	"LD (HL),L",0,	"HALT	;Z80PROASM BY JUEN/NAH-KOLOR^APPENDIX (AMIGA RULEZ!)",0,	"LD (HL),A",0
	dc.b	"LD A,B",0,	"LD A,C",0,	"LD A,D",0,	"LD A,E",0
	dc.b	"LD A,H",0,	"LD A,L",0,	"LD A,(HL)",0,	"LD A,A",0
	dc.b	"ADD A,B",0,	"ADD A,C",0,	"ADD A,D",0,	"ADD A,E",0
	dc.b	"ADD A,H",0,	"ADD A,L",0,	"ADD A,(HL)",0,	"ADD A,A",0
	dc.b	"ADC A,B",0,	"ADC A,C",0,	"ADC A,D",0,	"ADC A,E",0
	dc.b	"ADC A,H",0,	"ADC A,L",0,	"ADC A,(HL)",0,	"ADC A,A",0
	dc.b	"SUB B",0,	"SUB C",0,	"SUB D",0,	"SUB E",0
	dc.b	"SUB H",0,	"SUB L",0,	"SUB (HL)",0,	"SUB A",0
	dc.b	"SBC A,B",0,	"ABC A,C",0,	"ABC A,D",0,	"SBC A,E",0
	dc.b	"SBC A,H",0,	"SBC A,L",0,	"SBC A,(HL)",0,	"SBC A,A",0
	dc.b	"AND B",0,	"AND C",0,	"AND D",0,	"AND E",0
	dc.b	"AND H",0,	"AND L",0,	"AND (HL)",0,	"AND A",0
	dc.b	"XOR B",0,	"XOR C",0,	"XOR D",0,	"XOR E",0
	dc.b	"XOR H",0,	"XOR L",0,	"XOR (HL)",0,	"XOR A",0
	dc.b	"OR B",0,	"OR C",0,	"OR D",0,	"OR E",0
	dc.b	"OR H",0,	"OR L",0,	"OR (HL)",0,	"OR A",0
	dc.b	"CP B",0,	"CP C",0,	"CP D",0,	"CP E",0
	dc.b	"CP H",0,	"CP L",0,	"CP (HL)",0,	"CP A",0
	dc.b	"RET NZ",0,	"POP BC",0,	"PUSH BC",0,	"RST 0",0
	dc.b	"RET Z",0,	"RET",0,	"RST 8",0,	"RET NC",0
	dc.b	"POP DE",0,	"PUSH DE",0,	"RST 10H",0,	"RET C",0
	dc.b	"EXX",0,	"RST 18H",0,	"RET PO",0,	"POP HL",0
	dc.b	"EX (SP),HL",0,	"PUSH HL",0,	"RST 20H",0,	"RET PE",0
	dc.b	"JP (HL)",0,	"EX DE,HL",0,	"RST 28H",0,	"RET P",0
	dc.b	"POP AF",0,	"DI",0,	"PUSH AF",0,	"RST 30H",0
	dc.b	"RET M",0,	"LD SP,HL",0,	"EI",0,	"RST 38H",0,"RLC B",0

	dc.b	"RLC C",0,	"RLC D",0,	"RLC E",0,	"RLC H",0
	dc.b	"RLC L",0,	"RLC (HL)",0,	"RLC A",0,	"RRC B",0
	dc.b	"RRC C",0,	"RRC D",0,	"RRC E",0,	"RRC H",0
	dc.b	"RRC L",0,	"RRC (HL)",0,	"RRC A",0,	"RL B",0
	dc.b	"RL C",0,	"RL D",0,	"RL E",0,	"RL H",0
	dc.b	"RL L",0,	"RL (HL)",0,	"RL A",0,	"RR B",0
	dc.b	"RR C",0,	"RR D",0,	"RR E",0,	"RR H",0
	dc.b	"RR L",0,	"RR (HL)",0,	"RR A",0,	"SLA B",0
	dc.b	"SLA C",0,	"SLA D",0,	"SLA E",0,	"SLA H",0
	dc.b	"SLA L",0,	"SLA (HL)",0,	"SLA A",0,	"SRA B",0
	dc.b	"SRA C",0,	"SRA D",0,	"SRA E",0,	"SRA H",0
	dc.b	"SRA L",0,	"SRA (HL)",0,	"SRA A",0,	"SRL B",0
	dc.b	"SRL C",0,	"SRL D",0,	"SRL E",0,	"SRL H",0
	dc.b	"SRL L",0,	"SRL (HL)",0,	"SRL A",0,	"BIT 0,B",0
	dc.b	"BIT 0,C",0,	"BIT 0,D",0,	"BIT 0,E",0,	"BIT 0,H",0
	dc.b	"BIT 0,L",0,	"BIT 0,(HL)",0,	"BIT 0,A",0,	"BIT 1,B",0
	dc.b	"BIT 1,C",0,	"BIT 1,D",0,	"BIT 1,E",0,	"BIT 1,H",0
	dc.b	"BIT 1,L",0,	"BIT 1,(HL)",0,	"BIT 1,A",0,	"BIT 2,B",0
	dc.b	"BIT 2,C",0,	"BIT 2,D",0,	"BIT 2,E",0,	"BIT 2,H",0
	dc.b	"BIT 2,L",0,	"BIT 2,(HL)",0,	"BIT 2,A",0,	"BIT 3,B",0
	dc.b	"BIT 3,C",0,	"BIT 3,D",0,	"BIT 3,E",0,	"BIT 3,H",0
	dc.b	"BIT 3,L",0,	"BIT 3,(HL)",0,	"BIT 3,A",0,	"BIT 4,B",0
	dc.b	"BIT 4,C",0,	"BIT 4,D",0,	"BIT 4,E",0,	"BIT 4,H",0
	dc.b	"BIT 4,L",0,	"BIT 4,(HL)",0,	"BIT 4,A",0,	"BIT 5,B",0
	dc.b	"BIT 5,C",0,	"BIT 5,D",0,	"BIT 5,E",0,	"BIT 5,H",0
	dc.b	"BIT 5,L",0,	"BIT 5,(HL)",0,	"BIT 5,A",0,	"BIT 6,B",0
	dc.b	"BIT 6,C",0,	"BIT 6,D",0,	"BIT 6,E",0,	"BIT 6,H",0
	dc.b	"BIT 6,L",0,	"BIT 6,(HL)",0,	"BIT 6,A",0,	"BIT 7,B",0
	dc.b	"BIT 7,C",0,	"BIT 7,D",0,	"BIT 7,E",0,	"BIT 7,H",0
	dc.b	"BIT 7,L",0,	"BIT 7,(HL)",0,	"BIT 7,A",0,	"RES 0,B",0
	dc.b	"RES 0,C",0,	"RES 0,D",0,	"RES 0,E",0,	"RES 0,H",0
	dc.b	"RES 0,L",0,	"RES 0,(HL)",0,	"RES 0,A",0,	"RES 1,B",0
	dc.b	"RES 1,C",0,	"RES 1,D",0,	"RES 1,E",0,	"RES 1,H",0
	dc.b	"RES 1,L",0,	"RES 1,(HL)",0,	"RES 1,A",0,	"RES 2,B",0
	dc.b	"RES 2,C",0,	"RES 2,D",0,	"RES 2,E",0,	"RES 2,H",0
	dc.b	"RES 2,L",0,	"RES 2,(HL)",0,	"RES 2,A",0,	"RES 3,B",0
	dc.b	"RES 3,C",0,	"RES 3,D",0,	"RES 3,E",0,	"RES 3,H",0
	dc.b	"RES 3,L",0,	"RES 3,(HL)",0,	"RES 3,A",0,	"RES 4,B",0
	dc.b	"RES 4,C",0,	"RES 4,D",0,	"RES 4,E",0,	"RES 4,H",0
	dc.b	"RES 4,L",0,	"RES 4,(HL)",0,	"RES 4,A",0,	"RES 5,B",0
	dc.b	"RES 5,C",0,	"RES 5,D",0,	"RES 5,E",0,	"RES 5,H",0
	dc.b	"RES 5,L",0,	"RES 5,(HL)",0,	"RES 5,A",0,	"RES 6,B",0
	dc.b	"RES 6,C",0,	"RES 6,D",0,	"RES 6,E",0,	"RES 6,H",0
	dc.b	"RES 6,L",0,	"RES 6,(HL)",0,	"RES 6,A",0,	"RES 7,B",0
	dc.b	"RES 7,C",0,	"RES 7,D",0,	"RES 7,E",0,	"RES 7,H",0
	dc.b	"RES 7,L",0,	"RES 7,(HL)",0,	"RES 7,A",0,	"SET 0,B",0
	dc.b	"SET 0,C",0,	"SET 0,D",0,	"SET 0,E",0,	"SET 0,H",0
	dc.b	"SET 0,L",0,	"SET 0,(HL)",0,	"SET 0,A",0,	"SET 1,B",0
	dc.b	"SET 1,C",0,	"SET 1,D",0,	"SET 1,E",0,	"SET 1,H",0
	dc.b	"SET 1,L",0,	"SET 1,(HL)",0,	"SET 1,A",0,	"SET 2,B",0
	dc.b	"SET 2,C",0,	"SET 2,D",0,	"SET 2,E",0,	"SET 2,H",0
	dc.b	"SET 2,L",0,	"SET 2,(HL)",0,	"SET 2,A",0,	"SET 3,B",0
	dc.b	"SET 3,C",0,	"SET 3,D",0,	"SET 3,E",0,	"SET 3,H",0
	dc.b	"SET 3,L",0,	"SET 3,(HL)",0,	"SET 3,A",0,	"SET 4,B",0
	dc.b	"SET 4,C",0,	"SET 4,D",0,	"SET 4,E",0,	"SET 4,H",0
	dc.b	"SET 4,L",0,	"SET 4,(HL)",0,	"SET 4,A",0,	"SET 5,B",0
	dc.b	"SET 5,C",0,	"SET 5,D",0,	"SET 5,E",0,	"SET 5,H",0
	dc.b	"SET 5,L",0,	"SET 5,(HL)",0,	"SET 5,A",0,	"SET 6,B",0
	dc.b	"SET 6,C",0,	"SET 6,D",0,	"SET 6,E",0,	"SET 6,H",0
	dc.b	"SET 6,L",0,	"SET 6,(HL)",0,	"SET 6,A",0,	"SET 7,B",0
	dc.b	"SET 7,C",0,	"SET 7,D",0,	"SET 7,E",0,	"SET 7,H",0
	dc.b	"SET 7,L",0,	"SET 7,(HL)",0,	"SET 7,A",0,	"ADD IX,BC",0
	dc.b	"ADD IX,DE",0,	"INC IX",0,	"ADD IX,IY",0,	"DEC IX",0
	dc.b	"ADD IX,SP",0,	"POP IX",0,	"EX (SP),IX",0,	"PUSH IX",0
	dc.b	"JP (IX)",0,	"LD SP,IX",0,	"IN B,(C)",0,	"OUT (C),B",0
	dc.b	"SBC HL,BC",0,	"NEG",0,	"RETN",0,	"IM 0",0
	dc.b	"LD I,A",0,	"IN C,(C)",0,	"OUT (C),C",0,	"ADC HL,BC",0
	dc.b	"RETI",0,	"LD R,A",0,	"IN D,(C)",0,	"OUT (C),D",0
	dc.b	"SBC HL,DE",0,	"IM 1",0,	"LD A,I",0,	"IN E,(C)",0
	dc.b	"OUT (C),E",0,	"ADC HL,DE",0,	"IM 2",0,	"LD A,R",0
	dc.b	"IN H,(C)",0,	"OUT (C),H",0,	"SBC HL,HL",0,	"RRD",0
	dc.b	"IN L,(C)",0,	"OUT (C),L",0,	"ADC HL,HL",0,	"RLD",0
	dc.b	"SBC HL,SP",0,	"IN A,(C)",0,	"OUT (C),A",0,	"ADC HL,SP",0
	dc.b	"LDI",0,	"CPI",0,	"INI",0,	"OUTI",0
	dc.b	"LDD",0,	"CPD",0,	"IND",0,	"OUTD",0
	dc.b	"LDIR",0,	"CPIR",0,	"INIR",0,	"OTIR",0
	dc.b	"LDDR",0,	"CPDR",0,	"INDR",0,	"OTDR",0
	dc.b	"ADD IY,BC",0,	"ADD IY,DE",0,	"INC IY",0,	"ADD IY,IY",0
	dc.b	"DEC IY",0,	"ADD IY,SP",0,	"POP IY",0,	"EX (SP),IY",0
	dc.b	"PUSH IY",0,	"JP (IY)",0,	"LD SP,IY",0

	dc.b	"END",0

da_bin1	dc.b	'FF00FF00'

realcom	dc.b	'                               ',0

procom:	dc.b	"; z80pro (disam) by Pawel Nowak aka Juen/NAH^APX|am1ga",$a,$a
procomend
