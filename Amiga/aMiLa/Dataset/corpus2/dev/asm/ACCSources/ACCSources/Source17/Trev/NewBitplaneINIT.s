**************************************************************************
*
*                  New Bitplane/Sprite/Etc Initialisation
*                ------------------------------------------
*
* When initialising bitplane or sprite pointers to their new respective 
* memory locations you would normally use have to init each bitplane 
* individually using seperate code for each bitplane pointer you init.
*
* Well this small piece of code can save lots of extra code as it can 
* initialiase any number of bitplane pointers using the same code
* You simply just pass the required parameters to it.
*
**************************************************************************

**************************************************************************
* Init Bitplanes        Regesters Effected: d0-d1/a0-a2     Mem Type: ANY
* --------------        -------------------------------     -------------
*
* a0 = pointer to bitmap/sprite/etc data
* a1 = pointer to copperlist (position of first zero pointer)
* a2 = size of 1 bitplane
* d0 = no. of bitplanes to init
*
**************************************************************************

size1		equ	10240		; size of 1 bitplane


ExampleCall:	lea	logo1,a0	; ptr to bitmap data
		lea	bplanes1,a1	; ptr in copperlist
		move.l	#size1,a2	; size of 1 bitplane
		moveq.l	#5-1,d1		; no of bitplanes  (-1 using dbra)	
		bsr	InitPlanes	; Init those BITPLANES!!!

		rts




InitPlanes:	move.l	a0,d0		; get logo ptr in d0
		swap	d0
		move.l	d0,a0
		move.w	a0,(a1)		; low word
		move.l	a0,d0
		swap	d0
		move.l	d0,a0
		move.w	a0,4(a1)	; high word
		add.w	a2,a0		; get plane size
		adda.w	#8,a1		; next copper ptr
		dbra	d1,InitPlanes	; loop until all bitplanes are done
		rts


;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
; Bitplane Pointers (placed into the copperlist at desired position!)

		dc.w	bpl1pth
bplanes1	dc.w 	0,bpl1ptl
		dc.w 	0,bpl2pth
		dc.w 	0,bpl2ptl
		dc.w 	0,bpl3pth
		dc.w 	0,bpl3ptl
		dc.w 	0,bpl4pth
		dc.w 	0,bpl4ptl
		dc.w 	0,bpl5pth
		dc.w 	0,bpl5ptl
		dc.w 	0

logo1		;incbin	'logo.bm',0

*****************************************************************************
* Define some Equ's for the Amiga Hardware References and libraries
*****************************************************************************
SysCop1		equ $26
_ciaa:		equ $bfe001
_ciab:		equ $bfd000
left		equ 6

_custom:	equ $dff000
bltddat:	equ $000
dmaconr:	equ $002
vposr:		equ $004
vhposr:		equ $006
dskdatr:	equ $008
joy0dat:	equ $00a
joy1dat:	equ $00c
clxdat:		equ $00e
adkconr:	equ $010
pot0dat:	equ $012
pot1dat:	equ $014
potgor:		equ $016
serdatr:	equ $018
dskbytr:	equ $01a
intenar:	equ $01c
intreqr:	equ $01e
dskpth:		equ $020
dskptl:		equ $022
dsklen:		equ $024
dskdat:		equ $026
refptr:		equ $028
vposw:		equ $02a
vhposw:		equ $02c
copcon:		equ $02e
serdat:		equ $030
serper:		equ $032
potgo:		equ $034
joytest:	equ $036
strequ:		equ $038
strvbl:		equ $03a
strhor:		equ $03c
strlong:	equ $03e
bltcon0:	equ $040
bltcon1:	equ $042
bltafwm:	equ $044
bltalwm:	equ $046
bltcpth:	equ $048
bltcptl:	equ $04a
bltbpth:	equ $04c
bltbptl:	equ $04e
bltapth:	equ $050
bltaptl:	equ $052
bltdpth:	equ $054
bltdptl:	equ $056
bltsize:	equ $058
bltcmod:	equ $060
bltbmod:	equ $062
bltamod:	equ $064
bltdmod:	equ $066
bltcdat:	equ $070
bltbdat:	equ $072
bltadat:	equ $074
dsksync:	equ $07e
cop1lch:	equ $080
cop1lcl:	equ $082
cop2lch:	equ $084
cop2lcl:	equ $086
copjmp1:	equ $088
copjmp2:	equ $08a
copins:		equ $08c
diwstrt:	equ $08e
diwstop:	equ $090
ddfstrt:	equ $092
ddfstop:	equ $094
dmacon:		equ $096
clxcon:		equ $098
intena:		equ $09a
intreq:		equ $09c
adkcon:		equ $09e
aud0pth:	equ $0a0
aud0ptl:	equ $0a2
aud0len:	equ $0a4
aud0per:	equ $0a6
aud0vol:	equ $0a8
aud0dat:	equ $0aa
aud1pth:	equ $0b0
aud1ptl:	equ $0b2
aud1len:	equ $0b4
aud1per:	equ $0b6
aud1vol:	equ $0b8
aud1dat:	equ $0ba
aud2pth:	equ $0c0
aud2ptl:	equ $0c2
aud2len:	equ $0c4
aud2per:	equ $0c6
aud2vol:	equ $0c8
aud2dat:	equ $0ca
aud3pth:	equ $0d0
aud3ptl:	equ $0d2
aud3len:	equ $0d4
aud3per:	equ $0d6
aud3vol:	equ $0d8
aud3dat:	equ $0da
bpl1pth:	equ $0e0
bpl1ptl:	equ $0e2
bpl2pth:	equ $0e4
bpl2ptl:	equ $0e6
bpl3pth:	equ $0e8
bpl3ptl:	equ $0ea
bpl4pth:	equ $0ec
bpl4ptl:	equ $0ee
bpl5pth:	equ $0f0
bpl5ptl:	equ $0f2
bpl6pth:	equ $0f4
bpl6ptl:	equ $0f6
bplcon0:	equ $100
bplcon1:	equ $102
bplcon2:	equ $104
bpl1mod:	equ $108
bpl2mod:	equ $10a
bpl1dat:	equ $110
bpl2dat:	equ $112
bpl3dat:	equ $114
bpl4dat:	equ $116
bpl5dat:	equ $118
bpl6dat:	equ $11a
spr0pth:	equ $120
spr0ptl:	equ $122
spr1pth:	equ $124
spr1ptl:	equ $126
spr2pth:	equ $128
spr2ptl:	equ $12a
spr3pth:	equ $12c
spr3ptl:	equ $12e
spr4pth:	equ $130
spr4ptl:	equ $132
spr5pth:	equ $134
spr5ptl:	equ $136
spr6pth:	equ $138
spr6ptl:	equ $13a
spr7pth:	equ $13c
spr7ptl:	equ $13e
spr0pos:	equ $140
spr0ctl:	equ $142
spr0data:	equ $144
spr0datb:	equ $146
spr1pos:	equ $148
spr1ctl:	equ $14a
spr1data:	equ $14c
spr1datb:	equ $14e
spr2pos:	equ $150
spr2ctl:	equ $152
spr2data:	equ $154
spr2datb:	equ $156
spr3pos:	equ $158
spr3ctl:	equ $15a
spr3data:	equ $15c
spr3datb:	equ $15e
spr4pos:	equ $160
spr4ctl:	equ $162
spr4data:	equ $164
spr4datb:	equ $166
spr5pos:	equ $168
spr5ctl:	equ $16a
spr5data:	equ $16c
spr5datb:	equ $16e
spr6pos:	equ $170
spr6ctl:	equ $172
spr6data:	equ $174
spr6datb:	equ $176
spr7pos:	equ $178
spr7ctl:	equ $17a
spr7data:	equ $17c
spr7datb:	equ $17e
color00:	equ $180
color01:	equ $182
color02:	equ $184
color03:	equ $186
color04:	equ $188
color05:	equ $18a
color06:	equ $18c
color07:	equ $18e
color08:	equ $190
color09:	equ $192
color10:	equ $194
color11:	equ $196
color12:	equ $198
color13:	equ $19a
color14:	equ $19c
color15:	equ $19e
color16:	equ $1a0
color17:	equ $1a2
color18:	equ $1a4
color19:	equ $1a6
color20:	equ $1a8
color21:	equ $1aa
color22:	equ $1ac
color23:	equ $1ae
color24:	equ $1b0
color25:	equ $1b2
color26:	equ $1b4
color27:	equ $1b6
color28:	equ $1b8
color29:	equ $1ba
color30:	equ $1bc
color31:	equ $1be

*****************************************************************************
*       dos.lib/offsets
*****************************************************************************

open:		equ -30
close:		equ -36
read:		equ -42
write:		equ -48
input:		equ -54
output:		equ -60
seek:		equ -66
deletefile:	equ -72
rename:		equ -78
lock:		equ -84
unlock:		equ -90
duplock:	equ -96
examine:	equ -102
exnext:		equ -108
info:		equ -114
createdir:	equ -120
currentdir:	equ -126
ioErr:		equ -132
CreateProc:	equ -138
exit:		equ -144
loadseg:	equ -150
unloadseg:	equ -156
getpacket:	equ -162
queupacket:	equ -168
deviceproc:	equ -174
setcomment:	equ -180
setprotection:	equ -186
datestamp:	equ -192
;delay:		equ -198
waitforchar:	equ -204
parentdir:	equ -210
IsInteractive:	equ -216
Execute:	equ -222

*****************************************************************************
*       exec.lib.offsets
*****************************************************************************

AbsExecBase:	equ 4
forbid		equ -132
permit		equ -138
allocmem:	equ -198
freemem:	equ -210
getmsg:		equ -372
replymsg:	equ -378
waitport:	equ -384
closelibrary:	equ -414
opendevice:	equ -444
closedevice:	equ -450
doio:		equ -456
oldopenlibrary	equ -408
openlibrary:	equ -552


