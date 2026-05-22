	IFD	DEBUGGING
dmaoff	macro
	endm
dmaon	macro
	endm
setcop	macro
	endm
vsync	macro
	endm
lofsync	macro
	endm
waitblit macro
	endm
	IFND	NO_VBLSERVER
bumptime macro
	endm
iftime	macro
	endm
ifnottime macro
	endm
settime	macro
	endm
resettime macro
	endm
waituntil macro
	endm
	ENDC

	ELSE

	IFND	NO_VBLSERVER
vsync	macro
	movem.l	d0/a0,-(sp)
	lea	__vert,a0
	move.w	(a0),d0
wv\@$	cmp.w	(a0),d0
	beq.s	wv\@$
	movem.l	(sp)+,d0/a0
	endm
bumptime	macro
	vsync
	cmp.l	#\1,__timer
	bhi.s	bt\@$
	move.l	#\1,__timer
bt\@$
	endm
resettime	macro
	vsync
	move.l	#0,__timer
	endm
settime	macro
	vsync
	move.l	#\1,__timer
	endm
waituntil	macro
wu\@$	cmp.l	#\1,__timer
	bcs.s	wu\@$
	endm
	ELSEIF
vsync	macro
	move.w	d0,-(sp)
wv\@$	move.w	_custom+intreqr,d0
	btst	#INTB_VERTB,d0
	beq.s	wv\@$
	move.w	#INTF_VERTB,_custom+intreq
	move.w	(sp)+,d0
	endm
lofsync	macro
	move.w	d0,-(sp)
wl\@$	move.w	_custom+vposr,d0
	btst	#15,d0
	beq.s	wl\@$
	move.w	(sp)+,d0
	endm
	ENDC
dmaoff	macro
	IFEQ	NARG-6
	move.w	#DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4!DMAF_\5!DMAF_\6,$dff096
	ENDC
	IFEQ	NARG-5
	move.w	#DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4!DMAF_\5,$dff096
	ENDC
	IFEQ	NARG-4
	move.w	#DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4,$dff096
	ENDC
	IFEQ	NARG-3
	move.w	#DMAF_\1!DMAF_\2!DMAF_\3,$dff096
	ENDC
	IFEQ	NARG-2
	move.w	#DMAF_\1!DMAF_\2,$dff096
	ENDC
	IFEQ	NARG-1
	move.w	#DMAF_\1,$dff096
	ENDC
	IFEQ	NARG
	move.w	#1<<9,$dff096
	ENDC
	endm
dmaon	macro
	IFEQ	NARG-6
	move.w	#1<<15!1<<9!DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4!DMAF_\5!DMAF_6,$dff096
	ENDC
	IFEQ	NARG-5
	move.w	#1<<15!1<<9!DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4!DMAF_\5,$dff096
	ENDC
	IFEQ	NARG-4
	move.w	#1<<15!1<<9!DMAF_\1!DMAF_\2!DMAF_\3!DMAF_\4,$dff096
	ENDC
	IFEQ	NARG-3
	move.w	#1<<15!1<<9!DMAF_\1!DMAF_\2!DMAF_\3,$dff096
	ENDC
	IFEQ	NARG-2
	move.w	#1<<15!1<<9!DMAF_\1!DMAF_\2,$dff096
	ENDC
	IFEQ	NARG-1
	move.w	#1<<15!1<<9!DMAF_\1,$dff096
	ENDC
	IFEQ	NARG
	move.w	#1<<15!1<<9,$dff096
	ENDC
	endm
setcop	macro
	move.l	\1,$dff080
	move.w	#0,$dff088
	move.l	\1,_defcop
	endm
waitblit	macro
	btst	#DMAB_BLTDONE-8,_custom+dmaconr
wb\@$	btst	#DMAB_BLTDONE-8,_custom+dmaconr
	bne.s	wb\@$
	endm
	ENDC
colour4	macro
	dc.w	(((\1*\2)/15)*$100)+(((\1*\3)/15)*$10)+((\1*\4)/15)
	endm
colour8	macro
	dc.l	(((\1*\2)/255)*$10000)+(((\1*\3)/255)*$100)+((\1*\4)/255)
	endm
colfade	macro
__cfc	set	0
	rept	(\7)
__cfr	set	(\1)+(((\4)-(\1))*__cfc)/(\7)
__cfg	set	(\2)+(((\5)-(\2))*__cfc)/(\7)
__cfb	set	(\3)+(((\6)-(\3))*__cfc)/(\7)
__cfc	set	__cfc+1
	IFEQ	(\8)-1
	dc.b	__cfr,__cfg,__cfb
	ENDC
	IFEQ	(\8)-2
	dc.b	(__cfr&$ff)*$10000+(__cfg&$ff)*$100+(__cfb&$ff)
	ENDC
	IFEQ	(\8)-3
	dc.w	((__cfr/16)&$f)*$100+((__cfg/16)&$f)*$10+((__cfb/16)&$f)
	ENDC
	endr
	endm
costab	macro
__ang	set.d	0
	rept	(\3)
__cos	int	(\1)*cos(__ang)+(\2)
	dc.\0	__cos
__ang	set.d	(6.2831853072/(\3))+__ang
	endr
	endm
get	macro
	lea	\1(pc),\2
	move.\0	(\2),\2
	endm
getbasepc	macro
	IFC	'\1','exec'
	move.l	4.w,a6
	ELSEIF
	lea	\1base(pc),a6
	move.l	(a6),a6
	ENDC
	endm
getbase	macro
	IFC	'\1','exec'
	move.l	4.w,a6
	ELSEIF
	move.l	\1base,a6
	ENDC
	endm
	IFD	NO_FILESYSTEM
NO_REQUESTERS	set	1
load_ch	macro
	endm
load_fa	macro
	endm
	ELSEIF
load_ch	macro
	lea	c\@$(pc),a0
	move.l	a0,-(sp)
	lea	n\@$(pc),a0
	moveq	#1,d0
	jmp	_LoadFile
n\@$	dc.b	"\1",0
	cnop	0,4
c\@$
	endm
load_fa	macro
	lea	c\@$(pc),a0
	move.l	a0,-(sp)
	lea	n\@$(pc),a0
	moveq	#0,d0
	jmp	_LoadFile
n\@$	dc.b	"\1",0
	cnop	0,4
c\@$
	endm
	ENDC
QUITDEMO	macro
	move.w	#$7fff,d0
	move.w	d0,_custom+intena
	move.w	d0,_custom+dmacon
	lea	retpc,sp
	rts
	endm
QUITDEMO_FROMINT	macro
	move.w	#$7fff,d0
	move.w	d0,_custom+intena
	move.w	d0,_custom+dmacon
	lea	_intstk,sp
	move.l	retpc,-(sp)
	move.w	#SRF_SUPER,-(sp)
	nop
	rte
	endm
sintab	macro
__ang	set.d	0
	rept	(\3)
__sin	int	(\1)*sin(__ang)+(\2)
	dc.\0	__sin
__ang	set.d	(6.2831853072/(\3))+__ang
	endr
	endm
sincostab	macro
; cos entries start from (no.of entries)/4
__ang	set.d	0
	rept	(\3)/4+(\3)
__sin	int	(\1)*sin(__ang)+(\2)
	dc.\0	__sin
__ang	set.d	(6.2831853072/(\3))+__ang
	endr
	endm
tstlmb	macro
	btst	#6,$bfe001
	beq.s	\1
	endm
tstrmb	macro
	btst	#2,$dff016
	beq.s	\1
	endm
	IFND	FETCHMODE
FETCHMODE	set	4
	ENDC
	IFGT	FETCHMODE-4
FETCHMODE	set	4
	ENDC
	IFLT	FETCHMODE-1
FETCHMODE	set	4
	ENDC
	IFEQ	FETCHMODE-3
FETCHMODE	set	4
	ENDC

	IFEQ	FETCHMODE-4
__fetch	set	64
__fmode	set	%1111
	ENDC
	IFEQ	FETCHMODE-2
__fetch	set	32
__fmode	set	%1010
	ENDC
	IFEQ	FETCHMODE-1
__fetch	set	16
__fmode	set	%0000
	ENDC

; custom registers
_custom=$dff000
bltddat=0
dmaconr=2
vposr=4
vhposr=6
dskdatr=8
joy0dat=10
joy1dat=12
clxdat=14
adkconr=16
pot0dat=18
pot1dat=20
potgor=22
serdatr=24
dskbytr=26
intenar=28
intreqr=30
dskpt=32
dsklen=36
dskdat=38
refptr=40
vposw=42
vhposw=44
copcon=46
serdat=48
serper=50
potgo=52
joytest=54
strequ=56
strvbl=58
strhor=60
strlong=62
bltcon0=64
bltcon1=66
bltafwm=68
bltalwm=70
bltcpt=72
bltbpt=76
bltapt=80
bltdpt=84
bltsize=88
bltcon0l=90
bltsizv=92
bltsizh=94
bltcmod=96
bltbmod=98
bltamod=$64
bltdmod=$66
bltcdat=$70
bltbdat=$72
bltadat=$74
sprhdat=$78
bplhdat=$7a
lisaid=$7c
dsksync=$7e
cop1lc=$80
cop2lc=$84
copjmp1=$88
copjmp2=$8a
copins=$8c
diwstrt=$8e
diwstop=$90
ddfstrt=$92
ddfstop=$94
dmacon=$96
clxcon=$98
intena=$9a
intreq=$9c
adkcon=$9e
aud0=$a0
aud0ptr=$a0
aud0len=$a4
aud0per=$a6
aud0vol=$a8
aud0dat=$aa
aud1=$b0
aud1ptr=$b0
aud1len=$b4
aud1per=$b6
aud1vol=$b8
aud1dat=$ba
aud2=$c0
aud2ptr=$c0
aud2len=$c4
aud2per=$c6
aud2vol=$c8
aud2dat=$ca
aud3=$d0
aud3ptr=$d0
aud3len=$d4
aud3per=$d6
aud3vol=$d8
aud3dat=$da
bpl1pt=$e0
bpl2pt=$e4
bpl3pt=$e8
bpl4pt=$ec
bpl5pt=$f0
bpl6pt=$f4
bpl7pt=$f8
bpl8pt=$fc
bplcon0=$100
bplcon1=$102
bplcon2=$104
bplcon3=$106
bpl1mod=$108
bpl2mod=$10a
bplcon4=$10c
clxcon2=$10e
bpl1dat=$110
bpl2dat=$112
bpl3dat=$114
bpl4dat=$116
bpl5dat=$118
bpl6dat=$11a
bpl7dat=$11c
bpl8dat=$11e
sprpt=$120
spr0pt=$120
spr1pt=$124
spr2pt=$128
spr3pt=$12c
spr4pt=$130
spr5pt=$134
spr6pt=$138
spr7pt=$13c
spr0pos=$140
spr0ctl=$142
spr0data=$144
spr0datb=$146
spr1pos=$148
spr1ctl=$14a
spr1data=$14c
spr1datb=$14e
spr2pos=$150
spr2ctl=$152
spr2data=$154
spr2datb=$156
spr3pos=$158
spr3ctl=$15a
spr3data=$15c
spr3datb=$15e
spr4pos=$160
spr4ctl=$162
spr4data=$164
spr4datb=$166
spr5pos=$168
spr5ctl=$16a
spr5data=$16c
spr5datb=$16e
spr6pos=$170
spr6ctl=$172
spr6data=$174
spr6datb=$176
spr7pos=$178
spr7ctl=$17a
spr7data=$17c
spr7datb=$17e
color=$180
color00=$180
color01=$182
color02=$184
color03=$186
color04=$188
color05=$18a
color06=$18c
color07=$18e
color08=$190
color09=$192
color10=$194
color11=$196
color12=$198
color13=$19a
color14=$19c
color15=$19e
color16=$1a0
color17=$1a2
color18=$1a4
color19=$1a6
color20=$1a8
color21=$1aa
color22=$1ac
color23=$1ae
color24=$1b0
color25=$1b2
color26=$1b4
color27=$1b6
color28=$1b8
color29=$1ba
color30=$1bc
color31=$1be
htotal=$1c0
hsstop=$1c2
hbstrt=$1c4
hbstop=$1c6
vtotal=$1c8
vsstop=$1ca
vbstrt=$1cc
vbstop=$1ce
sprhstrt=$1d0
sprhstop=$1d2
bplhstrt=$1d4
bplhstop=$1d6
hhposw=$1d8
hhposr=$1da
beamcon0=$1dc
hsstrt=$1de
vsstrt=$1e0
hcenter=$1e2
diwhigh=$1e4
bplhmod=$1e6
sprhpt=$1e8
bplhpt=$1ec
fmode=$1fc
potinp=potgor

; adkcon bits
ADKB_SETCLR=15
ADKF_SETCLR=1<<15
ADKB_PRECOMP1=14
ADKF_PRECOMP1=1<<14
ADKB_PRECOMP0=13
ADKF_PRECOMP0=1<<13
ADKB_MFMPREC=12
ADKF_MFMPREC=1<<12
ADKB_UARTBRK=11
ADKF_UARTBRK=1<<11
ADKB_WORDSYNC=10
ADKF_WORDSYNC=1<<10
ADKB_MSBSYNC=9
ADKF_MSBSYNC=1<<9
ADKB_FAST=8
ADKF_FAST=1<<8
ADKB_USE3PN=7
ADKF_USE3PN=1<<7
ADKB_USE2P3=6
ADKF_USE2P3=1<<6
ADKB_USE1P2=5
ADKF_USE1P2=1<<5
ADKB_USE0P1=4
ADKF_USE0P1=1<<4
ADKB_USE3VN=3
ADKF_USE3VN=1<<3
ADKB_USE2V3=2
ADKF_USE2V3=1<<2
ADKB_USE1V2=1
ADKF_USE1V2=1<<1
ADKB_USE0V1=0
ADKF_USE0V1=1<<0
ADKF_PRE000NS=0
ADKF_PRE140NS=1<<13
ADKF_PRE280NS=1<<14
ADKF_PRE560NS=3<<13

; dmacon bits
DMAB_SETCLR=15
DMAF_SETCLR=1<<15
DMAB_BLTDONE=14
DMAF_BLTDONE=1<<14
DMAB_BLTNZERO=13
DMAF_BLTNZERO=1<<13
DMAF_BLITHOG=1<<10
DMAB_BLITHOG=10
DMAB_MASTER=9
DMAF_MASTER=1<<9
DMAB_RASTER=8
DMAF_RASTER=1<<8
DMAB_COPPER=7
DMAF_COPPER=1<<7
DMAB_BLITTER=6
DMAF_BLITTER=1<<6
DMAB_SPRITE=5
DMAF_SPRITE=1<<5
DMAB_DISK=4
DMAF_DISK=1<<4
DMAB_AUD3=3
DMAF_AUD3=1<<3
DMAB_AUD2=2
DMAF_AUD2=1<<2
DMAB_AUD1=1
DMAF_AUD1=1<<1
DMAB_AUD0=0
DMAF_AUD0=1<<0
DMAF_AUDIO=15
DMAF_ALL=511
ABC=$80
ABNC=$40
ANBC=$20
ANBNC=$10
NABC=8
NABNC=4
NANBC=2
NANBNC=1
BC0B_DEST=8
BC0F_DEST=1<<8
BC0B_SCRC=9
BC0F_SCRC=1<<9
BC0B_SCRB=10
BC0F_SCRB=1<<10
BC0B_SCRA=11
BC0F_SRCA=1<<11
BC1F_DESC=2
DEST=$100
SRCC=$200
SRCB=$400
SRCA=$800
ASHIFTSHIFT=12
BSHIFTSHIFT=12
LINEMODE=1
BLITREVERSE=2
ONEDOT=2
FILL_CARRYIN=4
FILL_OR=8
FILL_XOR=$10
OVFLAG=$20
SIGNFLAG=$40
SUD=16
SUL=8
AUL=4
OCTANT8=24
OCTANT7=4
OCTANT6=12
OCTANT5=28
OCTANT4=20
OCTANT3=8
OCTANT2=0
OCTANT1=16

; intena/intreq bits
INTB_SETCLR=15
INTF_SETCLR=1<<15
INTB_INTEN=14
INTF_INTEN=1<<14
INTB_EXTER=13
INTF_EXTER=1<<13
INTB_DSKSYNC=12
INTF_DSKSYNC=1<<12
INTB_RBF=11
INTF_RBF=1<<11
INTB_AUD3=10
INTF_AUD3=1<<10
INTB_AUD2=9
INTF_AUD2=1<<9
INTB_AUD1=8
INTF_AUD1=1<<8
INTB_AUD0=7
INTF_AUD0=1<<7
INTB_BLIT=6
INTF_BLIT=1<<6
INTB_VERTB=5
INTF_VERTB=1<<5
INTB_COPER=4
INTF_COPER=1<<4
INTB_PORTS=3
INTF_PORTS=1<<3
INTB_SOFTINT=2
INTF_SOFTINT=1<<2
INTB_DSKBLK=1
INTF_DSKBLK=1<<1
INTB_TBE=0
INTF_TBE=1<<0

; cia registers and bits
ciaapra=$bfe001
ciaaprb=$bfe101
ciaaddrb=$bfe201
ciaaddra=$bfe301
ciaatalo=$bfe401
ciaatahi=$bfe501
ciaatblo=$bfe601
ciaatbhi=$bfe701
ciaasdr=$bfec01
ciaaicr=$bfed01
ciaacra=$bfee01
ciaacrb=$bfef01
ciabpra=$bfd000
ciabprb=$bfd100
ciabddrb=$bfd200
ciabddra=$bfd300
ciabtalo=$bfd400
ciabtahi=$bfd500
ciabtblo=$bfd600
ciabtbhi=$bfd700
ciabsdr=$bfdc00
ciabicr=$bfdd00
ciabcra=$bfde00
ciabcrb=$bfdf00
TA=0
TB=1
ALRM=2
;SP=3	; Vodka/Saturne says AsmOne don't like this - Kyzer
FLG=4
IR=7
SETCLR=7
;START=0	;; erk! this name is reserved for a better cause ;-P
PBON=1
OUTMODE=2
RUNMODE=3
;LOAD=4		; so is this one
INMODE=5
SPMODE=6
TODIN=7
INMODE0=5
INMODE1=6
ALARM=7
IN_PHI2=0
IN_CNT=1<<5
IN_TA=1<<6
IN_CNT_TA=3<<5
GAMEPORT1=7
GAMEPORT0=6
DSKRDY=5
DSKTRACK0=4
DSKPROT=3
DSKCHANGE=2
LED=1
OVERLAY=0
COMDTR=7
COMRTS=6
COMCD=5
COMCTS=4
COMDSR=3
PRTRSEL=2
PRTROUT=1
PRTRBUSY=0
DSKMOTOR=7
DSKSEL3=6
DSKSEL2=5
DSKSEL1=4
DSKSEL0=3
DSKSIDE=2
DSKDIREC=1
DSKSTEP=0

; memory defines
MEMF_ANY=0
MEMF_PUBLIC=1
MEMF_CHIP=2
MEMF_FAST=4
MEMF_CLEAR=1<<16

; processor types
AFB_68010=0
AFB_68020=1
AFB_68030=2
AFB_68040=3
AFB_68881=4
AFB_68882=5
AFB_FPU40=6
AFB_68060=7
AFF_68010=1
AFF_68020=2
AFF_68030=4
AFF_68040=8
AFF_68881=16
AFF_68882=32
AFF_FPU40=64
AFF_68060=128

; status register bits
SRB_TRACE=15
SRB_SUPER=13
SRB_INT2=10
SRB_INT1=9
SRB_INT0=8
SRB_EXTEND=4
SRB_NEGATIVE=3
SRB_ZERO=2
SRB_OVERFLOW=1
SRB_CARRY=0
SRF_TRACE=1<<15
SRF_SUPER=1<<13
SRF_INT2=1<<10
SRF_INT1=1<<9
SRF_INT0=1<<8
SRF_EXTEND=1<<4
SRF_NEGATIVE=1<<3
SRF_ZERO=1<<2
SRF_OVERFLOW=1<<1
SRF_CARRY=1<<0

; misc dos stuff
MODE_OLDFILE=1005
MODE_NEWFILE=1006
MODE_READWRITE=1004
OFFSET_BEGINNING=-1
OFFSET_CURRENT=0
OFFSET_END=1
OFFSET_BEGINING=-1
SHARED_LOCK=-2
ACCESS_READ=-2
EXCLUSIVE_LOCK=-1
ACCESS_WRITE=-1

; amiga system calls
_LVOSupervisor=-30
_LVODisable=-120
_LVOEnable=-126
_LVOForbid=-132
_LVOPermit=-138
_LVOAllocMem=-198
_LVOAllocAbs=-204
_LVOFreeMem=-210
_LVOFindName=-276
_LVOFindTask=-294
_LVOSetTaskPri=-300
_LVOPutMsg=-366
_LVOGetMsg=-372
_LVOReplyMsg=-378
_LVOWaitPort=-384
_LVOFindPort=-390
_LVOOldOpenLibrary=-408
_LVOCloseLibrary=-414
_LVOOpenLibrary=-552
_LVOCopyMem=-624
_LVOCopyMemQuick=-630
_LVOCacheClearU=-636
_LVOCacheClearE=-642
_LVOCacheControl=-648
_LVOColdReboot=-726
_LVOOpenResource=-$1f2
_LVOOpen=-30
_LVOClose=-36
_LVORead=-42
_LVOWrite=-48
_LVOInput=-54
_LVOOutput=-60
_LVOSeek=-66
_LVOLock=-84
_LVOUnLock=-90
_LVOExamine=-102
_LVOExNext=-108
_LVOInfo=-114
_LVOIoErr=-132
_LVODelay=-198

_LVOLoadView=-222
_LVOWaitBlit=-228
_LVOWaitTOF=-270
_LVOOwnBlitter=-456
_LVODisownBlitter=-462
_LVOVideoControl=-708

_LVOCloseWorkBench=-78
_LVOCurrentTime=-84
_LVOOpenWorkBench=-210
_LVOMakeScreen=-378
_LVOAutoRequest=-348
_LVORemakeDisplay=-384
_LVORethinkDisplay=-390
_LVOLockPubScreen=-510
_LVOUnlockPubScreen=-516
_LVOEasyRequestArgs=-588

_LVOAskKeyMapDefault=-36
_LVOMapRawKey=-42

_LVOxfdRecogBuffer=-54
_LVOxfdDecrunchBuffer=-60
_LVOxfdAllocObject=-114
_LVOxfdFreeObject=-120

; InputEvent stuff
ie_NextEvent=0
ie_Class=4
ie_SubClass=5
ie_Code=6
ie_Qualifier=8
ie_Prev1DownCode=10
ie_Prev1DownQual=11
ie_Prev2DownCode=12
ie_Prev2DownQual=13
ie_TimeStamp=14
ie_SIZEOF=22

IEQUALIFIER_LSHIFT=1<<0
IEQUALIFIER_RSHIFT=1<<1
IEQUALIFIER_CAPSLOCK=1<<2
IEQUALIFIER_CONTROL=1<<3
IEQUALIFIER_LALT=1<<4
IEQUALIFIER_RALT=1<<5
IEQUALIFIER_LCOMMAND=1<<6
IEQUALIFIER_RCOMMAND=1<<7
IEQUALIFIER_NUMERICPAD=1<<8

IEQUALIFIERB_LSHIFT=0
IEQUALIFIERB_RSHIFT=1
IEQUALIFIERB_CAPSLOCK=2
IEQUALIFIERB_CONTROL=3
IEQUALIFIERB_LALT=4
IEQUALIFIERB_RALT=5
IEQUALIFIERB_LCOMMAND=6
IEQUALIFIERB_RCOMMAND=7
IEQUALIFIERB_NUMERICPAD=8

; keyboard stuff
; note that ONLY standardized keys (ie keys that do not change meaning
; when you change keymap) are listed here
; use TranslateKey to find it's true meaning.
KEYUP=$80

KEYPAD_CLOSE_PARENTHESIS=$5a
KEYPAD_OPEN_PARENTHESIS=$5b
KEYPAD_SLASH=$5c
KEYPAD_STAR=$5d
KEYPAD_PLUS=$5e
KEYPAD_PERIOD=$3c
KEYPAD_ENTER=$43
KEYPAD_MINUS=$4a

KEYPAD_NUMLOCK=KEYPAD_OPEN_PARENTHESIS
KEYPAD_SCROLLLOCK=KEYPAD_CLOSE_PARENTHESIS
KEYPAD_SYSTEMREQUEST=KEYPAD_SLASH
KEYPAD_PRINTSCREEN=KEYPAD_STAR
KEYPAD_DIVIDE=KEYPAD_SLASH
KEYPAD_MULTIPLY=KEYPAD_STAR
KEYPAD_POINT=KEYPAD_PERIOD

CURS_UP=$4c
CURS_DOWN=$4d
CURS_RIGHT=$4e
CURS_LEFT=$4f

KEY_LSHIFT=$60
KEY_RSHIFT=$61
KEY_CTRL=$63
KEY_LALT=$64
KEY_RALT=$65
KEY_LAMIGA=$66
KEY_RAMIGA=$67

KEY_SPACE=$40
KEY_BACKSPACE=$41
KEY_TAB=$42
KEY_RETURN=$44
KEY_ESC=$45
KEY_DEL=$46
KEY_HELP=$5f
KEY_CAPSLOCK=$62

KEY_A=$20
KEY_B=$35
KEY_C=$33
KEY_D=$22
KEY_E=$12
KEY_F=$23
KEY_G=$24
KEY_H=$25
KEY_I=$17
KEY_J=$26
KEY_K=$27
KEY_L=$28
KEY_M=$37
KEY_N=$36
KEY_O=$18
KEY_P=$19
KEY_Q=$10
KEY_R=$13
KEY_S=$21
KEY_T=$14
KEY_U=$16
KEY_V=$34
KEY_W=$11
KEY_X=$32

KEY_1=$01
KEY_2=$02
KEY_3=$03
KEY_4=$04
KEY_5=$05
KEY_6=$06
KEY_7=$07
KEY_8=$08
KEY_9=$09
KEY_0=$0a

KEYPAD_0=$0f
KEYPAD_1=$1d
KEYPAD_2=$1e
KEYPAD_3=$1f
KEYPAD_4=$2d
KEYPAD_5=$2e
KEYPAD_6=$2f
KEYPAD_7=$3d
KEYPAD_8=$3e
KEYPAD_9=$3f

KEY_F1=$50
KEY_F2=$51
KEY_F3=$52
KEY_F4=$53
KEY_F5=$54
KEY_F6=$55
KEY_F7=$56
KEY_F8=$57
KEY_F9=$58
KEY_F10=$59

; AllocMem stuff
CHIP=1
FAST=0

; MakeScreen stuff
MSB_HIRES=0
MSB_LACE=1
MSB_HAM=2
MSB_INTERLEAVED=3
MSB_WIDEDISPLAY=4
MSB_STATICREGS=5
MSB_NOBORDER=6
MSB_DUALPLAY=7	; not implemented yet!
MSB_HALFBRITE=8	; not implemented yet!
MSF_HIRES=1
MSF_LACE=2
MSF_HAM=4
MSF_INTERLEAVED=8
MSF_WIDEDISPLAY=16
MSF_STATICREGS=32
MSF_NOBORDER=64
MSF_DUALPLAY=128	; not implemented yet!
MSF_HALFBRITE=256	; not implemented yet!

; FadeColoursRGB stuff
FADE_COL_COL=1
FADE_COL_SET=2
FADE_SET_COL=3
FADE_SET_SET=4

; MakeCopper stuff
_mc_w=0
_mc_h=2
_mc_x=4
_mc_y=6
_mc_p=8
_mc_mod=10
_mc_br=12
_mc_bp=16
_mc_cc=20
_mc_bmp=24

