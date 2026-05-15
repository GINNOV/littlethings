;=============================================================================
; This include file defines all the custom chip registers as well as the bits
; defined in those registers.  It's a little more complete than the one
; provided with the standard Amiga include files.
;=============================================================================

_custom		EQU $DFF000

CLRBIT		EQU $0000
SETBIT		EQU $8000

BBUSYBIT	EQU 14
BZEROBIT	EQU 13

BBUSY		EQU 1<<BBUSYBIT
BZERO		EQU 1<<BZEROBIT

LINEMODE	EQU 1
OCT0		EQU 0!LINEMODE
OCT1		EQU 1<<2!LINEMODE
OCT2		EQU 2<<2!LINEMODE
OCT3		EQU 3<<2!LINEMODE
OCT4		EQU 4<<2!LINEMODE
OCT5		EQU 5<<2!LINEMODE
OCT6		EQU 6<<2!LINEMODE
OCT7		EQU 7<<2!LINEMODE

USEA		EQU 1<<11
USEB		EQU 1<<10
USEC		EQU 1<<9
USED		EQU 1<<8

SIGN		EQU 1<<6

BLTPRI		EQU 1<<10
DMAEN		EQU 1<<9
BPLEN		EQU 1<<8
COPEN		EQU 1<<7
BLTEN		EQU 1<<6
SPREN		EQU 1<<5
DSKEN		EQU 1<<4

AUD3EN		EQU 1<<3
AUD2EN		EQU 1<<2
AUD1EN		EQU 1<<1
AUD0EN		EQU 1

INTEN		EQU 1<<14
INTB_EXTER	EQU 13
EXTER		EQU 1<<13
DSKSYN		EQU 1<<12
RBF		EQU 1<<11
INTB_AUD3	EQU 10
AUD3		EQU 1<<10
INTB_AUD2	EQU 9
AUD2		EQU 1<<9
INTB_AUD1	EQU 8
AUD1		EQU 1<<8
INTB_AUD0	EQU 7
AUD0		EQU 1<<7
BLIT		EQU 1<<6
INTB_VERTB	EQU 5
VERTB		EQU 1<<5
INTB_COPER	EQU 4
COPER		EQU 1<<4
INTB_PORTS	equ 3
PORTS		EQU 1<<3
SOFT		EQU 1<<2
DSKBLK		EQU 1<<1
TBE		EQU 1

bltddat		EQU $000
dmaconr		EQU $002
vposr		EQU $004
vhposr		EQU $006
dskdatr		EQU $008
joy0dat		EQU $00A
joy1dat		EQU $00C
clxdat		EQU $00E

adkconr		EQU $010
pot0dat		EQU $012
pot1dat		EQU $014
potinp		EQU $016
serdatr		EQU $018
dskbytr		EQU $01A
intenar		EQU $01C
intreqr		EQU $01E

dskpth		EQU $020
dskptl		EQU $022
dsklen		EQU $024
dskdat		EQU $026
refptr		EQU $028
vposw		EQU $02A
vhposw		EQU $02C
copcon		EQU $02E
serdat		EQU $030
serper		EQU $032
potgo		EQU $034
joytest		EQU $036
strequ		EQU $038
strvbl		EQU $03A
strhor		EQU $03C
strlong		EQU $03E

bltcon0		EQU $040
bltcon1		EQU $042
bltafwm		EQU $044
bltalwm		EQU $046
bltcpth		EQU $048
bltcptl		EQU $04A
bltbpth		EQU $04C
bltbptl		EQU $04E
bltapth		EQU $050
bltaptl		EQU $052
bltdpth		EQU $054
bltdptl		EQU $056
bltsize		EQU $058

bltcmod		EQU $060
bltbmod		EQU $062
bltamod		EQU $064
bltdmod		EQU $066

bltcdat		EQU $070
bltbdat		EQU $072
bltadat		EQU $074

dsksync		EQU $07E

cop1lch		EQU $080
cop1lcl		EQU $082
cop2lch		EQU $084
cop2lcl		EQU $086
copjmp1		EQU $088
copjmp2		EQU $08A
copins		EQU $08C
diwstrt		EQU $08E
diwstop		EQU $090
ddfstrt		EQU $092
ddfstop		EQU $094
dmacon		EQU $096
clxcon		EQU $098
intena		EQU $09A
intreq		EQU $09C
adkcon		EQU $09E

aud		EQU $0A0
aud0lch		EQU $0A0
aud0lcl		EQU $0A2
aud0len		EQU $0A4
aud0per		EQU $0A6
aud0vol		EQU $0A8
aud0dat		EQU $0AA

aud1		EQU $0B0
aud1lch		EQU $0B0
aud1lcl		EQU $0B2
aud1len		EQU $0B4
aud1per		EQU $0B6
aud1vol		EQU $0B8
aud1dat		EQU $0BA

aud2		EQU $0C0
aud2lch		EQU $0C0
aud2lcl		EQU $0C2
aud2len		EQU $0C4
aud2per		EQU $0C6
aud2vol		EQU $0C8
aud2dat		EQU $0CA

aud3		EQU $0D0
aud3lch		EQU $0D0
aud3lcl		EQU $0D2
aud3len		EQU $0D4
aud3per		EQU $0D6
aud3vol		EQU $0D8
aud3dat		EQU $0DA

ac_ptr		EQU $00
ac_len		EQU $04
ac_per		EQU $06
ac_vol		EQU $08
ac_dat		EQU $0A
ac_SIZEOF	EQU $10

bplpt		EQU $0E0
bpl1pth		EQU $0E0
bpl1ptl		EQU $0E2
bpl2pth		EQU $0E4
bpl2ptl		EQU $0E6
bpl3pth		EQU $0E8
bpl3ptl		EQU $0EA
bpl4pth		EQU $0EC
bpl4ptl		EQU $0EE
bpl5pth		EQU $0F0
bpl5ptl		EQU $0F2
bpl6pth		EQU $0F4
bpl6ptl		EQU $0F6

bplcon0		EQU $100
bplcon1		EQU $102
bplcon2		EQU $104
bpl1mod		EQU $108
bpl2mod		EQU $10A

bpldat		EQU $110
bpl1dat		EQU $110
bpl2dat		EQU $112
bpl3dat		EQU $114
bpl4dat		EQU $116
bpl5dat		EQU $118
bpl6dat		EQU $11A

sprpt		EQU $120
spr0pth		EQU $120
spr0ptl		EQU $122
spr1pth		EQU $124
spr1ptl		EQU $126
spr2pth		EQU $128
spr2ptl		EQU $12A
spr3pth		EQU $12C
spr3ptl		EQU $12E
spr4pth		EQU $130
spr4ptl		EQU $132
spr5pth		EQU $134
spr5ptl		EQU $136
spr6pth		EQU $138
spr6ptl		EQU $13A
spr7pth		EQU $13C
spr7ptl		EQU $13E

spr0pos		EQU $140
spr0ctl		EQU $142
spr0data	EQU $144
spr0datb	EQU $146

spr1pos		EQU $148
spr1ctl		EQU $14A
spr1data	EQU $14C
spr1datb	EQU $14E

spr2pos		EQU $150
spr2ctl		EQU $152
spr2data	EQU $154
spr2datb	EQU $156

spr3pos		EQU $158
spr3ctl		EQU $15A
spr3data	EQU $15C
spr3datb	EQU $15E

spr4pos		EQU $160
spr4ctl		EQU $162
spr4data	EQU $164
spr4datb	EQU $166

spr5pos		EQU $168
spr5ctl		EQU $16A
spr5data	EQU $16C
spr5datb	EQU $16E

spr6pos		EQU $170
spr6ctl		EQU $172
spr6data	EQU $174
spr6datb	EQU $176

spr7pos		EQU $178
spr7ctl		EQU $17A
spr7data	EQU $17C
spr7datb	EQU $17E

sd_pos		EQU $00
sd_ctl		EQU $02
sd_dataa	EQU $04
sd_datab	EQU $08

color00		EQU $180
color01		EQU $182
color02		EQU $184
color03		EQU $186
color04		EQU $188
color05		EQU $18A
color06		EQU $18C
color07		EQU $18E
color08		EQU $190
color09		EQU $192
color10		EQU $194
color11		EQU $196
color12		EQU $198
color13		EQU $19A
color14		EQU $19C
color15		EQU $19E
color16		EQU $1A0
color17		EQU $1A2
color18		EQU $1A4
color19		EQU $1A6
color20		EQU $1A8
color21		EQU $1AA
color22		EQU $1AC
color23		EQU $1AE
color24		EQU $1B0
color25		EQU $1B2
color26		EQU $1B4
color27		EQU $1B6
color28		EQU $1B8
color29		EQU $1BA
color30		EQU $1BC
color31		EQU $1BE

