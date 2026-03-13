
*****************************************************************************
;                 AMIGA presets file
*****************************************************************************

; Defined by Yves GROLET
; Version: 1.3
; Date: 10/10/1989

*****************************************************************************
; 	Hardware equivalences
*****************************************************************************
;
ciaa	equ	$bfd000
ciab	equ	$bfe001
padr	equ	0
pbdr	equ	$100
ddra	equ	$200
ddrb	equ	$300
tadrl	equ	$400
tadrh	equ	$500
tbdrl	equ	$600
tbdrh	equ	$700
todh	equ	$800
todm	equ	$900
todl	equ	$a00
sdr	equ	$c00
icr	equ	$d00
cra	equ	$e00
crb	equ	$f00
custom	equ	$dff000
dmaconr	equ	2
vpos	equ	4
vhpos	equ	6
joy0dat	equ	$a
joy1dat	equ	$c
clxdat	equ	$e
adkconr	equ	$10
dskbytr	equ	$1a
intenar	equ	$1c
intreqr	equ	$1e
dskpt	equ	$20
dsklen	equ	$24
vposw	equ	$2a
vhposw	equ	$2c
copcon	equ	$2e
joytest	equ	$36
bltcon0	equ	$40
bltcon1	equ	$42
bltafwm	equ	$44
bltalwm	equ	$46
bltcpt	equ	$48
bltbpt	equ	$4c
bltapt	equ	$50
bltdpt	equ	$54
bltsize	equ	$58
bltcmod	equ	$60
bltbmod	equ	$62
bltamod	equ	$64
bltdmod	equ	$66
bltcdat	equ	$70
bltbdat	equ	$72
bltadat	equ	$74
dsksync	equ	$7e
cop1lc	equ	$80
cop2lc	equ	$84
copjmp1	equ	$88
copjmp2	equ	$8a
diwstrt	equ	$8e
diwstop	equ	$90
ddfstrt	equ	$92
ddfstop	equ	$94
dmacon	equ	$96
clxcon	equ	$98
intena	equ	$9a
intreq	equ	$9c
adkcon	equ	$9e
aud0lc	equ	$a0
aud0len	equ	$a4
aud0per	equ	$a6
aud0vol	equ	$a8
aud0dat	equ	$aa
aud1lc	equ	$b0
aud1len	equ	$b4
aud1per	equ	$b6
aud1vol	equ	$b8
aud1dat	equ	$ba
aud2lc	equ	$c0
aud2len	equ	$c4
aud2per	equ	$c6
aud2vol	equ	$c8
aud2dat	equ	$ca
aud3lc	equ	$d0
aud3len	equ	$d4
aud3per	equ	$d6
aud3vol	equ	$d8
aud3dat	equ	$da
bpl1pt	equ	$e0
bpl2pt	equ	$e4
bpl3pt	equ	$e8
bpl4pt	equ	$ec
bpl5pt	equ	$f0
bpl6pt	equ	$f4
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10a
spr0pt	equ	$120
spr1pt	equ	$124
spr2pt	equ	$128
spr3pt	equ	$12c
spr4pt	equ	$130
spr5pt	equ	$134
spr6pt	equ	$138
spr7pt	equ	$13c
spr0pos	equ	$140
spr0ctl	equ	$142
spr0data	equ	$144
spr0datb	equ	$146
spr1pos	equ	$148
spr1ctl	equ	$14a
spr1data	equ	$14c
spr1datb	equ	$14e
spr2pos	equ	$150
spr2ctl	equ	$152
spr2data	equ	$154
spr2datb	equ	$156
spr3pos	equ	$158
spr3ctl	equ	$15a
spr3data	equ	$15c
spr3datb	equ	$15e
spr4pos	equ	$160
spr4ctl	equ	$162
spr4data	equ	$164
spr4datb	equ	$166
spr5pos	equ	$168
spr5ctl	equ	$16a
spr5data	equ	$16c
spr5datb	equ	$16e
spr6pos	equ	$170
spr6ctl	equ	$172
spr6data	equ	$174
spr6datb	equ	$176
spr7pos	equ	$178
spr7ctl	equ	$17a
spr7data	equ	$17c
spr7datb	equ	$17e
color	equ	$180

;************************************************************************
; 	Copper macro language
;************************************************************************
;
c_move	macro

	dc.w	\2&$fffe,\1

	endm

c_wait	macro

	ifc	'\2',''
		dc.w	(\1-$10)<<8!1,$fffe
	elseif
		dc.w	(\2-$10)<<8!\1>>1!1,$fffe
	endc

	endm

c_end	macro

	dc.w	$ffff,$fffe

	endm

;************************************************************************
;	Environement macros
;************************************************************************
;
system_off	macro

                  ifne	debug=1
	move.l	4,a6
	lea	gfxname,a1
	jsr	-$198(a6)
	move.l	d0,a0
	move.l	$26(a0),safe_system+7*4
	movem.l	$64,d0-d7
	movem.l	d0-d6,safe_system
	move	sr,safe_system+8*4
	move.l	sp,safe_system+9*4     safe usp
	endc
	lea	entry\@(pc),a0
	move.l	a0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	movem.l	a0/d0-d6,$64
	move.l	d0,$10
                  illegal
;loop\@ bra loop\@

	ifne	debug=1
safe_system
	even
	ds.l	13
gfxname
	dc.b	"graphics.library",0
	even
int6
	system_on
	rts
	endc
entry\@
	move	#%0111111111111111,intreq+custom
 	move	#%0010010100000000,sr
	ifne	debug=1
	move.l	sp,safe_system+10*4	safe ssp
	move.l	#int6,$78
	move	intenar+custom,safe_system+12*4
	move	#%0001111111111111,intena+custom
	move	#%1110000000000000,intena+custom
	elseif
	move	#%0011111111111111,intena+custom
	endc
	endm

	ifne	debug=1
system_on	macro

	lea	custom,a0
	move	#%01111111111111,intreq(a0)
	move	safe_system+12*4,d0
	or	#$8000,d0
	move	d0,intena(a0)
	eor	#$ffff,d0
	move	d0,intena(a0)
	move.l	safe_system+10*4,sp	restore ssp
	movem.l	safe_system,d0-d6
	movem.l	d0-d6,$64
	move	safe_system+8*4,sr	user mode
	move.l	safe_system+9*4,sp      restore usp
	move	#$83f0,dmacon(a0)
	move.l	safe_system+7*4,cop1lc(a0)
	clr	copjmp1(a0)
	moveq	#0,d0
	rts
	endm
	endc

wait_click	macro
wc_loop\@
	btst	#6,$bfe001
	beq	wc_loop\@
wc_loop_2\@
	btst	#6,$bfe001
	bne	wc_loop_2\@

	endm

exit_test	macro

	btst	#6,$bfe001
	bne	cont\@
	system_on
	rts
cont\@
	endm

wait_blt	macro		;wait blitter macro
.wb_loop\@
	btst	#6,dmaconr(a0)
	bne     .wb_loop\@
	endm

wait_blit	macro		;wait blitter macro
.wb_loop\@
	btst	#6,Dmaconr(C)
	bne     .wb_loop\@
	endm

wait_synch	macro
	move.l	d0,-(sp)
.ws_loop\@
	move.l	vpos+custom,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00001000,d0
	bne	.ws_loop\@
	move.l	(sp)+,d0
	endm

wait_synch2	macro
	move.l	d0,-(sp)
.ws_loop\@
	move.l	vpos+custom,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00000800,d0
	bne	.ws_loop\@
	move.l	(sp)+,d0
	endm

blt_test	macro		;blitter test macro
	btst	#6,dmaconr(a0)
	beq     bt_cont\@
	trap	#0
bt_cont\@
	endm

col_on	macro
	ifne	raster_time=1
	st	color+custom
	endc
	endm

col_off	macro
	ifne	raster_time=1
	clr	color+custom
	endc
	endm

Flash	macro
	move.l	d0,-(sp)
	move	#$3000,d0
sheet_loop
	move	d0,$dff180
	dbra	d0,sheet_loop
	move.l	(sp)+,d0
	endm

rclr	macro
	moveq	#0,\1
	endm

error	MACRO
	ifne	debug=1
	move.l	#'YANN',d1
	trap	#0
	dc.b	\1,0
	even
	endc
	ENDM




