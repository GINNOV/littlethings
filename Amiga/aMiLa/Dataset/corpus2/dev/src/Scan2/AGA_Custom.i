**
**	$Filename: hardware/aga_custom.i $
**	$Release: V40.0 $
**	$Revision: 40.0 $
**	$Date: 95/07/10 $
**	$Author: Fabrizio Farenga $
**
**

bltddat     EQU   $DFF000
dmaconr     EQU   $DFF002
vposr	    EQU   $DFF004
vhposr	    EQU   $DFF006
dskdatr     EQU   $DFF008
joy0dat     EQU   $DFF00A
joy1dat     EQU   $DFF00C
clxdat	    EQU   $DFF00E

adkconr     EQU   $DFF010
pot0dat     EQU   $DFF012
pot1dat     EQU   $DFF014
potinp	    EQU   $DFF016
serdatr     EQU   $DFF018
dskbytr     EQU   $DFF01A
intenar     EQU   $DFF01C
intreqr     EQU   $DFF01E

dskpt	    EQU   $DFF020
dsklen	    EQU   $DFF024
dskdat	    EQU   $DFF026
refptr	    EQU   $DFF028
vposw	    EQU   $DFF02A
vhposw	    EQU   $DFF02C
copcon	    EQU   $DFF02E
serdat	    EQU   $DFF030
serper	    EQU   $DFF032
potgo	    EQU   $DFF034
joytest     EQU   $DFF036
strequ	    EQU   $DFF038
strvbl	    EQU   $DFF03A
strhor	    EQU   $DFF03C
strlong     EQU   $DFF03E

bltcon0     EQU   $DFF040
bltcon1     EQU   $DFF042
bltafwm     EQU   $DFF044
bltalwm     EQU   $DFF046
bltcpt	    EQU   $DFF048
bltbpt	    EQU   $DFF04C
bltapt	    EQU   $DFF050
bltdpt	    EQU   $DFF054
bltsize     EQU   $DFF058
bltcon0l    EQU   $DFF05B		; note: byte access only
bltsizv     EQU   $DFF05C
bltsizh     EQU   $DFF05E

bltcmod     EQU   $DFF060
bltbmod     EQU   $DFF062
bltamod     EQU   $DFF064
bltdmod     EQU   $DFF066

bltcdat     EQU   $DFF070
bltbdat     EQU   $DFF072
bltadat     EQU   $DFF074

deniseid    EQU   $DFF07C
dsksync     EQU   $DFF07E

cop1lc	    EQU   $DFF080
cop2lc	    EQU   $DFF084
copjmp1     EQU   $DFF088
copjmp2     EQU   $DFF08A
_copins	    EQU   $DFF08C
diwstrt     EQU   $DFF08E
diwstop     EQU   $DFF090
ddfstrt     EQU   $DFF092
ddfstop     EQU   $DFF094
dmacon	    EQU   $DFF096
clxcon	    EQU   $DFF098
intena	    EQU   $DFF09A
intreq	    EQU   $DFF09C
adkcon	    EQU   $DFF09E

aud	    EQU   $DFF0A0
aud0	    EQU   $DFF0A0
aud1	    EQU   $DFF0B0
aud2	    EQU   $DFF0C0
aud3	    EQU   $DFF0D0

* AudChannel
ac_ptr	    EQU   $00	; ptr to start of waveform data
ac_len	    EQU   $04	; length of waveform in words
ac_per	    EQU   $06	; sample period
ac_vol	    EQU   $08	; volume
ac_dat	    EQU   $0A	; sample pair
ac_SIZEOF   EQU   $10


aud0lc	    EQU   $DFF0A0
aud0len	    EQU   $DFF0A4
aud0per	    EQU   $DFF0A6
aud0vol	    EQU   $DFF0A8
aud0dat	    EQU   $DFF0AA

aud1lc	    EQU   $DFF0B0
aud1len	    EQU   $DFF0B4
aud1per	    EQU   $DFF0B6
aud1vol	    EQU   $DFF0B8
aud1dat	    EQU   $DFF0BA

aud2lc	    EQU   $DFF0C0
aud2len	    EQU   $DFF0C4
aud2per	    EQU   $DFF0C6
aud2vol	    EQU   $DFF0C8
aud2dat	    EQU   $DFF0CA

aud3lc	    EQU   $DFF0D0
aud3len	    EQU   $DFF0D4
aud3per	    EQU   $DFF0D6
aud3vol	    EQU   $DFF0D8
aud3dat	    EQU   $DFF0DA


bplpt	    EQU   $DFF0E0

bplcon0     EQU   $DFF100
bplcon1     EQU   $DFF102
bplcon2     EQU   $DFF104
bplcon3     EQU   $DFF106
bpl1mod     EQU   $DFF108
bpl2mod     EQU   $DFF10A
bplcon4     EQU   $DFF10C
clxcon2     EQU   $DFF10E

bpldat	    EQU   $DFF110

sprpt	    EQU   $DFF120

spr	    EQU   $DFF140

* SpriteDef
sd_pos	    EQU   $00
sd_ctl	    EQU   $02
sd_dataa    EQU   $04
sd_dataB    EQU   $06
sd_SIZEOF   EQU   $08

spr0pos		EQU $DFF140
spr0ctl		EQU $DFF142
spr0data	EQU $DFF144
spr0datb	EQU $DFF146

spr1pos		EQU $DFF148
spr1ctl		EQU $DFF14A
spr1data	EQU $DFF14C
spr1datb	EQU $DFF14E

spr2pos		EQU $DFF150
spr2ctl		EQU $DFF152
spr2data	EQU $DFF154
spr2datb	EQU $DFF156

spr3pos		EQU $DFF158
spr3ctl		EQU $DFF15A
spr3data	EQU $DFF15C
spr3datb	EQU $DFF15E

spr4pos		EQU $DFF160
spr4ctl		EQU $DFF162
spr4data	EQU $DFF164
spr4datb	EQU $DFF166

spr5pos		EQU $DFF168
spr5ctl		EQU $DFF16A
spr5data	EQU $DFF16C
spr5datb	EQU $DFF16E

spr6pos		EQU $DFF170
spr6ctl		EQU $DFF172
spr6data	EQU $DFF174
spr6datb	EQU $DFF176

spr7pos		EQU $DFF178
spr7ctl		EQU $DFF17A
spr7data	EQU $DFF17C
spr7datb	EQU $DFF17E

spr0pt	    EQU   $DFF120
spr1pt	    EQU   $DFF124
spr2pt	    EQU   $DFF128
spr3pt	    EQU   $DFF12C
spr4pt	    EQU   $DFF130
spr5pt	    EQU   $DFF134
spr6pt	    EQU   $DFF138
spr7pt	    EQU   $DFF13C


color	    EQU   $DFF180

htotal	    EQU   $DFF1c0
hsstop	    EQU   $DFF1c2
hbstrt	    EQU   $DFF1c4
hbstop	    EQU   $DFF1c6
vtotal	    EQU   $DFF1c8
vsstop	    EQU   $DFF1ca
vbstrt	    EQU   $DFF1cc
vbstop	    EQU   $DFF1ce
sprhstrt    EQU   $DFF1d0
sprhstop    EQU   $DFF1d2
bplhstrt    EQU   $DFF1d4
bplhstop    EQU   $DFF1d6
hhposw	    EQU   $DFF1d8
hhposr	    EQU   $DFF1da
beamcon0    EQU   $DFF1dc
hsstrt	    EQU   $DFF1de
vsstrt	    EQU   $DFF1e0
hcenter     EQU   $DFF1e2
diwhigh     EQU   $DFF1e4
fmode	    EQU   $DFF1fc

