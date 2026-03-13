

*****************************************************************************

*                 A M I G A   H a r d w a r e   h e a d e r

*****************************************************************************



* Version: 2.0

* by Yves Grolet

* Date: 20/6/1992






*****************************************************************************

* 	Hardware equivalences

*****************************************************************************


Ciaa	EQU	$bfd000
Ciab	EQU	$bfe001
Padr	EQU	0
Pbdr	EQU	$100
Ddra	EQU	$200
Ddrb	EQU	$300
Tadrl	EQU	$400
Tadrh	EQU	$500
Tbdrl	EQU	$600
Tbdrh	EQU	$700
Todh	EQU	$800
Todm	EQU	$900
Todl	EQU	$a00
Sdr	EQU	$c00
Icr	EQU	$d00
Cra	EQU	$e00
Crb	EQU	$f00
Custom	EQU	$dff000
Dmaconr	EQU	2
Vpos	EQU	4
Vhpos	EQU	6
Joy0dat	EQU	$a
Joy1dat	EQU	$c
Clxdat	EQU	$e
Adkconr	EQU	$10
Dskbytr	EQU	$1a
Intenar	EQU	$1c
Intreqr	EQU	$1e
Dskpt	EQU	$20
Dsklen	EQU	$24
Vposw	EQU	$2a
Vhposw	EQU	$2c
Copcon	EQU	$2e
Joytest	EQU	$36
Bltcon0	EQU	$40
Bltcon1	EQU	$42
Bltafwm	EQU	$44
Bltalwm	EQU	$46
Bltcpt	EQU	$48
Bltbpt	EQU	$4c
Bltapt	EQU	$50
Bltdpt	EQU	$54
Bltsize	EQU	$58
Bltcmod	EQU	$60
Bltbmod	EQU	$62
Bltamod	EQU	$64
Bltdmod	EQU	$66
Bltcdat	EQU	$70
Bltbdat	EQU	$72
Bltadat	EQU	$74
Dsksync	EQU	$7e
Cop1lc	EQU	$80
Cop2lc	EQU	$84
Copjmp1	EQU	$88
Copjmp2	EQU	$8a
Diwstrt	EQU	$8e
Diwstop	EQU	$90
Ddfstrt	EQU	$92
Ddfstop	EQU	$94
Dmacon	EQU	$96
Clxcon	EQU	$98
Intena	EQU	$9a
Intreq	EQU	$9c
Adkcon	EQU	$9e
Aud0lc	EQU	$a0
Aud0len	EQU	$a4
Aud0per	EQU	$a6
Aud0vol	EQU	$a8
Aud0dat	EQU	$aa
Aud1lc	EQU	$b0
Aud1len	EQU	$b4
Aud1per	EQU	$b6
Aud1vol	EQU	$b8
Aud1dat	EQU	$ba
Aud2lc	EQU	$c0
Aud2len	EQU	$c4
Aud2per	EQU	$c6
Aud2vol	EQU	$c8
Aud2dat	EQU	$ca
Aud3lc	EQU	$d0
Aud3len	EQU	$d4
Aud3per	EQU	$d6
Aud3vol	EQU	$d8
Aud3dat	EQU	$da
Bpl1pt	EQU	$e0
Bpl2pt	EQU	$e4
Bpl3pt	EQU	$e8
Bpl4pt	EQU	$ec
Bpl5pt	EQU	$f0
Bpl6pt	EQU	$f4
Bplcon0	EQU	$100
Bplcon1	EQU	$102
Bplcon2	EQU	$104
Bpl1mod	EQU	$108
Bpl2mod	EQU	$10a
Spr0pt	EQU	$120
Spr1pt	EQU	$124
Spr2pt	EQU	$128
Spr3pt	EQU	$12c
Spr4pt	EQU	$130
Spr5pt	EQU	$134
Spr6pt	EQU	$138
Spr7pt	EQU	$13c
Spr0pos	EQU	$140
Spr0ctl	EQU	$142
Spr0data	EQU	$144
Spr0datb	EQU	$146
Spr1pos	EQU	$148
Spr1ctl	EQU	$14a
Spr1data	EQU	$14c
Spr1datb	EQU	$14e
Spr2pos	EQU	$150
Spr2ctl	EQU	$152
Spr2data	EQU	$154
Spr2datb	EQU	$156
Spr3pos	EQU	$158
Spr3ctl	EQU	$15a
Spr3data	EQU	$15c
Spr3datb	EQU	$15e
Spr4pos	EQU	$160
Spr4ctl	EQU	$162
Spr4data	EQU	$164
Spr4datb	EQU	$166
Spr5pos	EQU	$168
Spr5ctl	EQU	$16a
Spr5data	EQU	$16c
Spr5datb	EQU	$16e
Spr6pos	EQU	$170
Spr6ctl	EQU	$172
Spr6data	EQU	$174
Spr6datb	EQU	$176
Spr7pos	EQU	$178
Spr7ctl	EQU	$17a
Spr7data	EQU	$17c
Spr7datb	EQU	$17e
Color	EQU	$180






************************************************************************

* 	Copper macro language

************************************************************************


C_MOVE	MACRO
	DC.W	\2&$fffe,\1
	ENDM


C_WAIT	MACRO
	IFC	'\2',''
	DC.W	\1<<8!1,$fffe
	ELSEIF
	DC.W	\2<<8!\1>>1!1,$fffe
	ENDC
	ENDM

C_END	MACRO
	DC.W	$ffff,$fffe
	ENDM






************************************************************************

*	System macros

************************************************************************



SYSTEM_OFF	MACRO

Entry
                  IFNE	Asm_Absolute=0

	move.l	4,a6
	lea	Gfxname,a1
	jsr	-$198(a6)
	move.l	d0,a0

	lea	Safe_Buffer(pc),a1
	move.l	$26(a0),Safe_Cl(a1)	* safe copper list

	lea	Custom,a0

	move	Intenar(a0),Safe_Intena(a1) 	* safe intena

	move	#$7fff,d0
	move	d0,Intena(a0)   	* system int & dma off
	move	d0,Intreq(a0)
	move	d0,Dmacon(a0)

                  lea	$0,a2            	* safe vector ($0->$400)
	lea	Safe_Vectors(a1),a3
	move	#$ff,d0
Safe_Vect_Loop
	move.l	(a2)+,(a3)+
	dbra	d0,Safe_Vect_Loop

	move	SR,Safe_Sr(a1)	* safe sr
	move.l	SP,Safe_Usp(a1)	* safe usp

                  move.l	#Supervisor,$20.w
 	move	#$2000,SR
Supervisor
	move.l	SP,Safe_Ssp(a1)	* safe ssp

	move.l	#No_Cache,$10.w	* turn off the cache on 68020 &+
	dc.w	$4e7a,2
	bclr	#0,d0
	dc.w	$4e7b,2
No_Cache
	lea	Break_Int(pc),a2	* revectorise all break source
	move.l	a2,$8.w	* (anti-guru!)
	move.l	a2,$c.w
	move.l	a2,$10.w
	move.l	a2,$14.w
	move.l	a2,$18.w
	move.l	a2,$1c.w
	move.l	a2,$20.w
	move.l	a2,$24.w
	move.l	a2,$28.w
	move.l	a2,$2c.w
	move.l	a2,$3c.w
	lea	$60,a3
	lea	$c0,a4
Revect_Loop
	move.l	a2,(a3)+
	cmp.l	a4,a3
	bne	Revect_Loop

	move	#$e000,Intena(a0)   * enable int 6&7 super break

	bra     Main
                                              * DATA
	RSRESET
Safe_Cl	RS.L	1
Safe_Intena	RS.W	1
Safe_Vectors	RS.B	$400
Safe_Sr	RS.W	1
Safe_Usp	RS.L	1
Safe_Ssp	RS.L	1
Safe_Sizeoff	RS.B	0

Safe_Buffer
	DS.B	Safe_Sizeoff
Gfxname
	DC.B	"graphics.library",0
	EVEN
Break_Int
	move.l	2(sp),Error_Pc
	FLASH
	SYSTEM_ON
Error_Pc
	DS.L	1

	ELSEIF		* ABSOLUTE

	lea	Custom,a0

	move	#$7fff,d0
	move	d0,Intena(a0)	* system int & dma off
	move	d0,Intreq(a0)
	move	d0,Dmacon(a0)

                  move.l	#Supervisor,$20.w
 	move	#$2000,sr
Supervisor
	ENDC

Main
	ENDM



************************************************************************



	IFNE	Asm_Absolute=0
SYSTEM_ON	MACRO

	lea	Custom,a0
	lea	Safe_Buffer(pc),a1
	move	#$7fff,Intreq(a0)

	lea	Safe_Vectors(a1),a2
                  lea	$0,a3
	move	#$ff,d0
Rest_Vect_Loop\@
	move.l	(a2)+,(a3)+
	dbra	d0,Rest_Vect_Loop\@

	move	Safe_Intena(a1),d0
	or	#$8000,d0
	move	d0,Intena(a0)
	eor	#$ffff,d0
	move	d0,Intena(a0)

	move.l	Safe_Ssp(a1),SP
	move	Safe_Sr(a1),SR
	move.l	Safe_Usp(a1),SP

	move	#$83f0,Dmacon(a0)

	move.l	Safe_Cl(a1),Cop1lc(a0)
	move	d0,Copjmp1(a0)

	moveq	#0,d0
	rts

	ENDM
	ENDC





************************************************************************

*                 Relative data macros

************************************************************************




_	MACRO
	IFNE	(*-Rel_Start-32768)>65535
	FAIL	"Relative Zone Too Big."
	ENDC
\1	EQU     *-Rel_Start-32768
_\1
	ENDM




************************************************************************

*	Mouse macros

************************************************************************




WAIT_CLICK	MACRO

Wc_Loop\@
	btst	#6,$bfe001
	beq	Wc_Loop\@
Wc_Loop_2\@
	btst	#6,$bfe001
	bne	Wc_Loop_2\@

	ENDM




************************************************************************



EXIT_TEST	MACRO

	IFNE	Asm_Absolute=0
	btst	#6,$bfe001
	bne	Cont\@
	SYSTEM_ON
Cont\@
	ENDC
	ENDM






************************************************************************

*	Blitter macros

************************************************************************



WAIT_BLIT	MACRO

.wb_loop\@
	btst	#6,Dmaconr(C)
	bne     .wb_loop\@
	ENDM






************************************************************************

*	Screen macros

************************************************************************



WAIT_SYNCH	MACRO
	move.l	d0,-(sp)
.ws_loop\@
	move.l	Vpos+Custom,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00001000,d0
	bne	.ws_loop\@
	move.l	(sp)+,d0
	ENDM




************************************************************************



WAIT_SYNCH_D0_C	MACRO

.ws_loop\@
	move.l	Vpos(C),d0
	and.l	#$0001ff00,d0
	cmp.l	#$00001000,d0
	bne	.ws_loop\@
	ENDM




************************************************************************



WAIT_SYNCH2	MACRO
	move.l	d0,-(sp)
.ws_loop\@
	move.l	Vpos+Custom,d0
	and.l	#$0001ff00,d0
	cmp.l	#$00000800,d0
	bne	.ws_loop\@
	move.l	(sp)+,d0
	ENDM




************************************************************************



RLINE	MACRO
	IFNE	ASM_Absolute=0
	btst	#6,$bfe001
	bne	Cont\@
                  REPT    20
	move	#\1,Color+Custom
	ENDR
	clr	Color+Custom
Cont\@
                  ENDC
	ENDM




************************************************************************



FLASH	MACRO
	move.l	d0,-(sp)
	move	#$5000,d0
Flash_Loop\@
	move	d0,$dff180
	dbra	d0,Flash_Loop\@
	move.l	(sp)+,d0
	ENDM







