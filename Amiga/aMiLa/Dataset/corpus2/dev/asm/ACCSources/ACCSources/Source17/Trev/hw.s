;
;  Hardware Regs.......
;
custom	EQU   $dff000

bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E

adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potgor	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E

dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E

bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058

bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066

bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074

dsksync	EQU   $07E

cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E
aud0lch	equ	$0a0
aud0lcl	equ	$0a2
aud0len	equ	$0a4
aud0per	equ	$0a6
aud0vol	equ	$0a8
aud0dat	equ	$0aa
aud1lch	equ	$0b0
aud1lcl	equ	$0b2
aud1len	equ	$0b4
aud1per	equ	$0b6
aud1vol	equ	$0b8
aud1dat	equ	$0ba
aud2lch	equ	$0c0
aud2lcl	equ	$0c2
aud2len	equ	$0c4
aud2per	equ	$0c6
aud2vol	equ	$0c8
aud2dat	equ	$0ca
aud3lch	equ	$0d0
aud3lcl	equ	$0d2
aud3len	equ	$0d4
aud3per	equ	$0d6
aud3vol	equ	$0d8
aud3dat	equ	$0da

bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6

bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A

bpldat	EQU   $110

spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E

spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178

spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A

spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c


spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e

col0	EQU   $180
col1 	EQU   $182
col2	EQU   $184
col3    EQU   $186
col4	EQU   $188
col5	equ   $18a
col6	equ   $18c
col7	equ   $18e
col8	EQU   $190
col9	equ   $192
col10	equ   $194
col11	equ   $196
col12	equ   $198
col13	equ   $19a
col14	equ   $19c
col15	equ   $19e
col16   EQU   $1A0	
col17	equ	$1a2
col18	equ	$1a4
col19	equ	$1a6
col20	equ	$1a8
col21	equ	$1aa
col22	equ 	$1ac
col23	equ	$1ae
col24	equ	$1b0
col25	equ	$1b2
col26	equ	$1b4
col27	equ	$1b6
col28	equ	$1b8
col29	equ	$1ba
col30	equ	$1bc
col31	equ	$1be

;
;Cias....
;
ciaa 	equ 	$bfe001
ciab	equ	$bfd000

pra	EQU	$0000
prb	EQU	$0100
ddra	EQU	$0200
ddrb	EQU	$0300
talo	EQU	$0400
tahi	EQU	$0500
tblo	EQU	$0600
tbhi	EQU	$0700
todlow	EQU	$0800
todmid	EQU	$0900
todhi	EQU	$0A00
sp	EQU	$0C00
icr	EQU	$0D00
cra	EQU	$0E00
crb	EQU	$0F00

;
;Copper Intruction Macros...
;
; Cmove Val,Reg
; Cwait X,Y
; Cmwt  X,Y,XM,YM  (7th bit of YM is clear then waits for Blitter
;		    i.e. There's no mask for y bit 7		 )
; Cskip X,Y  	   (Skip next com if beam past X,Y)
; Cmskp X,Y,XM,YM  (Same as Cmwt but for Skip...)
;

Cmove	MACRO
	dc.w \2,\1
	ENDM
		
Cwait	MACRO
	dc.w \2<<8!\1!1,$fffe
	ENDM

Cmwt	MACRO
	dc.w \2<<8!\1!1,(\4<<8!\3)&$fffe	
	ENDM

Cskip 	MACRO
	dc.w \2<<8!\1!1,$ffff
	ENDM

Cmskp	MACRO
	DC.W \2<<8!\1!1,\4<<8!\3!1
	ENDM

;
;Blitter macros...
;

Blitwait MACRO
bw_\@	btst #14,dmaconr(a5)
	bne.s bw_\@
	ENDM

Nomask	MACRO
	move #$ffff,bltafwm(a5)
	move #$ffff,bltalwm(a5)
	ENDM
;
;Misc Macros...
;

CatchVB MACRO
vb1_\@:
	btst #0,vposr+1(a5)
	beq.s vb1_\@
vb2_\@:
	btst #0,vposr+1(a5)
	bne.s vb2_\@
	ENDM

