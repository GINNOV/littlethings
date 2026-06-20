
***** Custom chip register table *****

_custom	=	$DFF000

;General registers

dmaconr	=	$2
vposr	=	$4
vhposr	=	$6
dskdatr   =	$8
joy0dat	=	$A
joy1dat	=	$C
clxdat	=	$E
potinp	=	$16
dskbytr	=	$1A
intenar	=	$1C
intreqr	=	$1E
dskpth	=	$20
dskptl	=	$22
dsklen	=	$24
dskdat	=	$26
copcon	=	$2E
joytest	=	$36
dsksync	=	$7E
adkcon	=	$9E

;Blitter registers

bltcon0		= $40
bltcon1		= $42
bltafwm		= $44
bltalwm		= $46
bltcpth		= $48
bltcptl		= $4A
bltbpth		= $4C
bltbptl		= $4E
bltapth		= $50
bltaptl		= $52
bltdpth		= $54
bltdptl		= $56
bltsize		= $58
bltcmod		= $60
bltbmod		= $62
bltamod		= $64
bltdmod		= $66
bltcdat		= $70
bltbdat		= $72
bltadat		= $74

;Copper registers

cop1lc		= $80
cop1lch		= $80
cop1lcl		= $82
cop2lc		= $84
cop2lch		= $84
cop2lcl		= $86
copjmp1		= $88
copjmp2		= $8A
diwstrt		= $8E
diwstop		= $90
ddfstrt		= $92
ddfstop		= $94
dmacon		= $96
clxcon		= $98
intena		= $9A
intreq		= $9C
color0		= $180
color00		=	color0
color1		= $182
color01		=	color1
color2		= $184
color02		=	color2
color3		= $186
color03		=	color3
color4		= $188
color04		=	color4
color5		= $18A
color05		=	color5
color6		= $18C
color06		=	color6
color7		= $18E
color07		=	color7
color8		= $190
color08		=	color8
color9		= $192
color09		=	color9
color10		= $194
color11		= $196
color12		= $198
color13		= $19A
color14		= $19C
color15		= $19E
color16		= $1A0
color17		= $1A2
color18		= $1A4
color19		= $1A6
color20		= $1A8
color21		= $1AA
color22		= $1AC
color23		= $1AE
color24		= $1B0
color25		= $1B2
color26		= $1B4
color27		= $1B6
color28		= $1B8
color29		= $1BA
color30		= $1BC
color31		= $1BE

bpl1pth		= $E0
bpl1ptl		= $E2
bpl2pth		= $E4
bpl2ptl		= $E6
bpl3pth		= $E8
bpl3ptl		= $EA
bpl4pth		= $EC
bpl4ptl		= $EE
bpl5pth		= $F0
bpl5ptl		= $F2
bpl6pth		= $F4
bpl6ptl		= $F6
bplcon0		= $100
bplcon1		= $102
bplcon2		= $104
bpl1mod		= $108
bpl2mod		= $10A

spr0pth		= $120
spr0ptl		= $122
spr1pth		= $124
spr1ptl		= $126
spr2pth		= $128
spr2ptl		= $12A
spr3pth		= $12C
spr3ptl		= $12E
spr4pth		= $130
spr4ptl		= $132
spr5pth		= $134
spr5ptl		= $136
spr6pth		= $138
spr6ptl		= $13A
spr7pth		= $13C
spr7ptl		= $13E
spr0pos		= $140
spr0ctl		= $142
spr0data	= $144
spr0datb	= $146
spr1pos		= $148
spr1ctl		= $14A
spr1data	= $14C
spr1datb	= $14E
spr2pos		= $150
spr2ctl		= $152
spr2data	= $154
spr2datb	= $156
spr3pos		= $158
spr3ctl		= $15A
spr3data	= $15C
spr3datb	= $15E
spr4pos		= $160
spr4ctl		= $162
spr4data	= $164
spr4datb	= $166
spr5pos		= $168
spr5ctl		= $16A
spr5data	= $16C
spr5datb	= $16E
spr6pos		= $170
spr6ctl		= $172
spr6data	= $174
spr6datb	= $176
spr7pos		= $178
spr7ctl		= $17A
spr7data	= $17C
spr7datb	= $17E

;	CIA Registers:

ciaapra	equ	$bfe001

;Macros to help in writing copperlists

Mov	Macro
Temp set \2&$1fe
	Dc.w	Temp
	Dc.w	\1
	Endm

Wait	Macro
Temp set \2&$FF
	Dc.b	Temp
Temp set \1&$FE
	Dc.b	Temp!1
	Dc.w	$FFFE		
	Endm			

WaitV	Macro
Temp set \2&$FF
	Dc.b	Temp
Temp set \1&$FE
	Dc.b	Temp!1
	Dc.w	$FF00		
	Endm			

Skip	Macro		
Temp set \2&$FF	
	Dc.b	Temp
Temp set \1&$FE	
	Dc.b	Temp
	Dc.w	$FFFE
	Endm
