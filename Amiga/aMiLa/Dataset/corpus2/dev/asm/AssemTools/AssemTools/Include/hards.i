*************************************************************************
*									*
*			 Hardware register map				*
*									*
*			 Created 880424 by JM				*
*									*
*									*
*	Edited 880710 by JM						*
*	Edited 880728 by JM						*
*	Edited 881021 by JM: CUSTOM changed to Custom			*
*	Edited 890311 by JM: Copper macros renamed.			*
*									*
*************************************************************************

Custom		equ	$dff000
JOY0DAT		equ	$00a
JOY1DAT		equ	$00c

POT0DAT		equ	$012
POT1DAT		equ	$014

INTENAR		equ	$01c
INTREQR		equ	$01e
INTENA		equ	$09a
INTREQ		equ	$09c

AUD0LC		equ	$0a0
AUD0LEN		equ	$0a4
AUD0PER		equ	$0a6
AUD0VOL		equ	$0a8
AUD0DAT		equ	$0aa
AUD1LC		equ	$0b0
AUD1LEN		equ	$0b4
AUD1PER		equ	$0b6
AUD1VOL		equ	$0b8
AUD1DAT		equ	$0ba
AUD2LC		equ	$0c0
AUD2LEN		equ	$0c4
AUD2PER		equ	$0c6
AUD2VOL		equ	$0c8
AUD2DAT		equ	$0ca
AUD3LC		equ	$0d0
AUD3LEN		equ	$0d4
AUD3PER		equ	$0d6
AUD3VOL		equ	$0d8
AUD3DAT		equ	$0da

COP1LCH		equ	$080
COP1LCL		equ	$082
COP2LCH		equ	$084
COP2LCL		equ	$086
COPJMP1		equ	$088
COPJMP2		equ	$08a
COPINS		equ	$08c

DIWSTRT		equ	$08e
DIWSTOP		equ	$090
DDFSTRT		equ	$092
DDFSTOP		equ	$094

DMACON		equ	$096
DMACONR		equ	$002

BLTCON0		equ	$040
BLTCON1		equ	$042
BLTAFWM		equ	$044
BLTALWM		equ	$046
BLTCPT		equ	$048
BLTBPT		equ	$04c
BLTAPT		equ	$050
BLTDPT		equ	$054
BLTSIZE		equ	$058
BLTCMOD		equ	$060
BLTBMOD		equ	$062
BLTAMOD		equ	$064
BLTDMOD		equ	$066
BLTCDAT		equ	$070
BLTBDAT		equ	$072
BLTADAT		equ	$074

BPL1PTH		equ	$0e0
BPL1PTL		equ	$0e2
BPL2PTH		equ	$0e4
BPL2PTL		equ	$0e6
BPL3PTH		equ	$0e8
BPL3PTL		equ	$0ea
BPL4PTH		equ	$0ec
BPL4PTL		equ	$0ee
BPL5PTH		equ	$0f0
BPL5PTL		equ	$0f2
BPL6PTH		equ	$0f4
BPL6PTL		equ	$0f6
BPL7PTH		equ	$0f8
BPL7PTL		equ	$0fa
BPL8PTH		equ	$0fc
BPL8PTL		equ	$0fe

BPLCON0		equ	$100
BPLCON1		equ	$102
BPLCON2		equ	$104
BPL1MOD		equ	$108
BPL2MOD		equ	$10a

BPL1DAT		equ	$110
BPL2DAT		equ	$112
BPL3DAT		equ	$114
BPL4DAT		equ	$116
BPL5DAT		equ	$118
BPL6DAT		equ	$11a
BPL7DAT		equ	$11c
BPL8DAT		equ	$11e

SPR0PTH		equ	$120
SPR0PTL		equ	$122
SPR1PTH		equ	$124
SPR1PTL		equ	$126
SPR2PTH		equ	$128
SPR2PTL		equ	$12a
SPR3PTH		equ	$12c
SPR3PTL		equ	$12e
SPR4PTH		equ	$130
SPR4PTL		equ	$132
SPR5PTH		equ	$134
SPR5PTL		equ	$136
SPR6PTH		equ	$138
SPR6PTL		equ	$13a
SPR7PTH		equ	$13c
SPR7PTL		equ	$13e

SPR0POS		equ	$140
SPR1POS		equ	$148
SPR2POS		equ	$150
SPR3POS		equ	$158
SPR4POS		equ	$160
SPR5POS		equ	$168
SPR6POS		equ	$170
SPR7POS		equ	$178

SPR0CTL		equ	$142
SPR1CTL		equ	$14a
SPR2CTL		equ	$152
SPR3CTL		equ	$15a
SPR4CTL		equ	$162
SPR5CTL		equ	$16a
SPR6CTL		equ	$172
SPR7CTL		equ	$17a

SPR0DATA	equ	$144
SPR1DATA	equ	$14c
SPR2DATA	equ	$154
SPR3DATA	equ	$15c
SPR4DATA	equ	$164
SPR5DATA	equ	$16c
SPR6DATA	equ	$174
SPR7DATA	equ	$17c

SPR0DATB	equ	$146
SPR1DATB	equ	$14e
SPR2DATB	equ	$156
SPR3DATB	equ	$15e
SPR4DATB	equ	$166
SPR5DATB	equ	$16e
SPR6DATB	equ	$176
SPR7DATB	equ	$17e

COLOR0		equ	$180
COLOR1		equ	$182
COLOR2		equ	$184
COLOR3		equ	$186
COLOR4		equ	$188
COLOR5		equ	$18a
COLOR6		equ	$18c
COLOR7		equ	$18e
COLOR8		equ	$190
COLOR9		equ	$192
COLOR10		equ	$194
COLOR11		equ	$196
COLOR12		equ	$198
COLOR13		equ	$19a
COLOR14		equ	$19c
COLOR15		equ	$19e
COLOR16		equ	$1a0
COLOR17		equ	$1a2
COLOR18		equ	$1a4
COLOR19		equ	$1a6
COLOR20		equ	$1a8
COLOR21		equ	$1aa
COLOR22		equ	$1ac
COLOR23		equ	$1ae
COLOR24		equ	$1b0
COLOR25		equ	$1b2
COLOR26		equ	$1b4
COLOR27		equ	$1b6
COLOR28		equ	$1b8
COLOR29		equ	$1ba
COLOR30		equ	$1bc
COLOR31		equ	$1be



C_MOVE		macro
		dc.w	\2
		dc.w	\1
		endm

C_WAIT		macro
		ifc	'\2',''
		dc.w	\1<<8!1,$fffe
		endc
		ifnc	'\2',''
		dc.w	\1<<8!\2!1,$fffe
		endc
		endm

C_STOP		macro
		dc.w	$ffff,$fffe
		endm


