; © 1995 by Fabrizio Farenga
;
; f.farenga@agora.stm.it
; http://www.agora.stm.it/htbin/wwx?fi^F.Farenga
;
; ##############################################################
;
; Build-up a scan-doubled hi-res noflicker screen (DBLPAL noflicker)
; by-passing O.S.
;
; ##############################################################
;
; These examples are provided "as-is" and are subject to change;
; no warranties are made.  All use is at your own risk.
; No liability or responsibility is assumed.
;
;
;
; ** USE THE O.S. LUKE! **
;



	incdir "include:"
	include "exec/exec.i"
	include "exec/exec_lib.i"
	include "graphics/graphics_lib.i"
	include "graphics/rastport.i"
	include "intuition/intuition_lib.i"
	include "dos/dos.i"
	include "dos/dos_lib.i"

	include	"AGA_Custom.i"

PALSYNC:	EQU $0020
NTSCSYNC:	EQU $0000
DOUBLESYNC:	EQU $1B88

	Section code,CODE


SCL:	EQU	(640*512*8)/8		;Screen 320*200*256c size
SCPL:	EQU     (640*512)/8		;Single plane size

Start:
	CALLEXEC Forbid

	moveq	#0,D0			;Opens  graphics.library
	lea	GFX_Name,A1
	CALLEXEC OpenLibrary
	move.l	d0,_GFXBase

	move.l	d0,A5
	move.l	$26(A5),OLDCOP		;Saves the original Copper-lists
	move.l	$32(a5),OLDCOP2

	lea	Intuition_Name,A1	;Opens intuition.library
	moveq	#0,D0
	CALLEXEC OpenLibrary
	move.l	d0,Intuition_Base

	lea	Dos_Name,A1
	moveq	#0,D0
	CALLEXEC OpenLibrary
	move.l	D0,_DOSBase

;	MOVE.L  #0,A1		;load a Null ViewPort
;	move.l	_GFXBase,A6
;	JSR     _LVOLoadView(A6)

;	JSR     _LVOWaitTOF(A6)   ;Wait two 
;	JSR     _LVOWaitTOF(A6)   ;V retrace.  

	move.w	#DOUBLESYNC,BEAMCON0	;Turn on DOUBLESYNC

	move.l	#COP0,COP1LC

	move.w	DMACONR,OLDDMACON

	move.w	#$7fff,DMACON
	move.w	#%1000001110000000,DMACON

	move.l	#SCL,D0
	move.l	#MEMF_CHIP,D1
	CALLEXEC AllocMem
	move.l	D0,ScrBuffer
	beq	NotEnoghMem

	jsr	LoadPicture
	jsr	SetupScreenBuffers

	move.l	#COPA,COP1LC

	jsr	WaitLMB

	move.l	#COP0,COP1LC

	move.l	#SCL,D0
	move.l	ScrBuffer,A1
	CALLEXEC FreeMem
NotEnoghMem:

Exit:				;Exits safely.
;-----------------------

	move.l	OLDCOP,cop1lc
	move.w	#0,copjmp1
	move.l	OLDCOP2,cop2lc

;Read original intuition sync
	move.l	_GFXBase,a6			;Is graphics.library >V36?
	cmp.w	#36,$14(a6)			;
	blo	NoViewExtra			;If not, ViewExtra doesn't
						;exist...

	move.l	$22(a6),a0			;Take active View.
	move.l	_GFXBase,a6			;Ask for extensions.
	jsr	-702(a6)			;Gfx _GfxLookUp
	tst.l	d0				;If no extensions available,
	beq	NoViewExtra			;no ViewPort extra!
	move.l	d0,a0				;
	move.l	$1c(a0),a0			;Read ptr to Monitor
	move.w	$28(a0),d0			;Read Monitor Sync,
	move.w	d0,BEAMCON0			;and write it into the
						;Custom Sync Register.
NoViewExtra:

	move.l	Intuition_Base,A6
	move.l	60(A6),A0
	jsr	_LVOMakeScreen(A6)

	move.l	Intuition_Base,A6
	jsr	_LVORethinkDisplay(A6)

	move.l	_GFXBase,A1		;Closes graphics.library
	CALLEXEc CloseLibrary

	move.l	Intuition_Base,A1	;Closes intuition.library
	CALLEXEc CloseLibrary

	move.l	_DOSBase,A1		;Closes dos.library
	CALLEXEC CloseLibrary

	bset	#15,OLDDMACON		;Restore DMACON
	move.w	OLDDMACON,dmacon

	CALLEXEC Permit

	rts

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


SetupScreenBuffers:
	lea	COPA_PLANES,A0
	move.l	ScrBuffer,D0
	move.w	D0,6(A0)	;1st bitplane
	swap	D0
	move.w	D0,2(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,14(A0)	;2nd bitplane
	swap	D0
	move.w	D0,10(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,22(A0)	;3rd bitplane
	swap	D0
	move.w	D0,18(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,30(A0)	;4th bitplane
	swap	D0
	move.w	D0,26(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,38(A0)	;5th bitplane
	swap	D0
	move.w	D0,34(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,46(A0)	;6th bitplane
	swap	D0
	move.w	D0,42(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,54(A0)	;7th bitplane
	swap	D0
	move.w	D0,50(A0)
	swap	D0

	add.l	#SCPL,D0
	move.w	D0,62(A0)	;8th bitplane
	swap	D0
	move.w	D0,58(A0)
	swap	D0

	rts

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

LoadPicture:
	move.l	#FileName,d1
	move.l	#MODE_OLDFILE,d2
	CALLDOS	Open
	move.l	d0,PicHandle

	move.l	PicHandle,D1
	move.l	ScrBuffer,D2
	move.l	#SCL,D3
	CALLDOS	Read

	move.l	PicHandle,d1
	CALLDOS Close

	rts


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


WaitLMB:
	btst	#6,$bfe001
	bne	WaitLMB
	rts

WaitRMB:
	btst	#10,POTINP
	bne	WaitRMB
	rts



;*****************************************************************

;-------------------------------------------------------------------
; Data Zone
;-------------------------------------------------------------------

GFX_Name:	dc.b 'graphics.library',0
Intuition_Name:	dc.b 'intuition.library',0
DOS_Name:	DOSNAME
FileName:	dc.b '256c_hi.raw',0
	CNOP 0,2

PicHandle:	dc.l 0		;File Handle.
OLDCOP:		dc.l 0		;System COP1LC.
OLDCOP2:	dc.l 0		;System COP2LC.
OLDINTENA:	dc.w 0		;System INTENA.
OLDDMACON:	dc.w 0		;System DMACON.
_GFXBase:	dc.l 0
Intuition_Base:	dc.l 0
_DOSBase:	dc.l 0
ScrBuffer:	dc.l 0		;Screen memory pointer.

	CNOP 0,4

	Section data,DATA_C

COP0:
	DC.W $01FC,$C003			;FMODE
	dc.w $0100,$0201,$0180,$0000,$ffff,$fffe



COPA:
	dc.w $0001,$fffe,$0100,$0201
	dc.w $0180,$0000

	DC.W $0106,$0CE1	;Set up Palette
	DC.W $0180,$0000,$0182,$0BCD,$0184,$0ABC,$0186,$09BB
	DC.W $0188,$07AA,$018A,$0699,$018C,$0588,$018E,$0577
	DC.W $0190,$0466,$0192,$0112,$0194,$0123,$0196,$0234
	DC.W $0198,$0DCB,$019A,$0DEF,$019C,$0DDD,$019E,$0FFF
	DC.W $01A0,$0BDF,$01A2,$0DBA,$01A4,$08CF,$01A6,$0ADF
	DC.W $01A8,$0DEE,$01AA,$07CE,$01AC,$08BE,$01AE,$0ACE
	DC.W $01B0,$05BD,$01B2,$06AC,$01B4,$0365,$01B6,$06AB
	DC.W $01B8,$06BD,$01BA,$08CE,$01BC,$08AB,$01BE,$0789

	DC.W $0106,$2CE1
	DC.W $0180,$029E,$0182,$029E,$0184,$029E,$0186,$03AE
	DC.W $0188,$04AE,$018A,$05AE,$018C,$06AE,$018E,$06AE
	DC.W $0190,$07BE,$0192,$08BE,$0194,$08BE,$0196,$09BE
	DC.W $0198,$09BE,$019A,$09CE,$019C,$0ACE,$019E,$0ACE
	DC.W $01A0,$0ADE,$01A2,$0ADE,$01A4,$0ADE,$01A6,$0BDE
	DC.W $01A8,$0BDE,$01AA,$0CDD,$01AC,$06BC,$01AE,$06BC
	DC.W $01B0,$06BC,$01B2,$06CC,$01B4,$06CC,$01B6,$06CC
	DC.W $01B8,$06DC,$01BA,$06DC,$01BC,$06DC,$01BE,$06DC

	DC.W $0106,$4CE1
	DC.W $0180,$0300,$0182,$0400,$0184,$0600,$0186,$0700
	DC.W $0188,$0800,$018A,$0A00,$018C,$0B00,$018E,$0C00
	DC.W $0190,$0D30,$0192,$0020,$0194,$0030,$0196,$0030
	DC.W $0198,$0040,$019A,$0050,$019C,$0050,$019E,$0160
	DC.W $01A0,$0160,$01A2,$0170,$01A4,$0270,$01A6,$0280
	DC.W $01A8,$0281,$01AA,$0391,$01AC,$03A1,$01AE,$0221
	DC.W $01B0,$0342,$01B2,$0453,$01B4,$0564,$01B6,$0675
	DC.W $01B8,$0796,$01BA,$08A7,$01BC,$0AB8,$01BE,$0BD9

	DC.W $0106,$6CE1
	DC.W $0180,$0999,$0182,$0898,$0184,$0688,$0186,$0587
	DC.W $0188,$0487,$018A,$0376,$018C,$0E09,$018E,$0DEE
	DC.W $0190,$0EFF,$0192,$0841,$0194,$0F0F,$0196,$054C
	DC.W $0198,$083A,$019A,$0000,$019C,$0100,$019E,$0111
	DC.W $01A0,$0222,$01A2,$0332,$01A4,$0433,$01A6,$0544
	DC.W $01A8,$0554,$01AA,$0665,$01AC,$0766,$01AE,$0877
	DC.W $01B0,$0987,$01B2,$0998,$01B4,$0A99,$01B6,$0BAA
	DC.W $01B8,$0CBB,$01BA,$0DCC,$01BC,$0DDC,$01BE,$0EED

	DC.W $0106,$8CE1
	DC.W $0180,$0456,$0182,$0466,$0184,$0466,$0186,$0477
	DC.W $0188,$0577,$018A,$0587,$018C,$0588,$018E,$0588
	DC.W $0190,$0698,$0192,$0699,$0194,$06A9,$0196,$0540
	DC.W $0198,$0540,$019A,$0860,$019C,$0FD0,$019E,$05AC
	DC.W $01A0,$059B,$01A2,$059B,$01A4,$049A,$01A6,$049A
	DC.W $01A8,$0499,$01AA,$0399,$01AC,$0389,$01AE,$0388
	DC.W $01B0,$0287,$01B2,$0287,$01B4,$0276,$01B6,$0026
	DC.W $01B8,$003A,$01BA,$004C,$01BC,$005E,$01BE,$007F

	DC.W $0106,$ACE1
	DC.W $0180,$0110,$0182,$0211,$0184,$0221,$0186,$0322
	DC.W $0188,$0332,$018A,$0432,$018C,$0433,$018E,$0543
	DC.W $0190,$0544,$0192,$0654,$0194,$0655,$0196,$0765
	DC.W $0198,$0866,$019A,$0876,$019C,$0977,$019E,$0987
	DC.W $01A0,$0A98,$01A2,$0A98,$01A4,$0AA9,$01A6,$0BAA
	DC.W $01A8,$0BBA,$01AA,$0CBB,$01AC,$0CCC,$01AE,$0DDC
	DC.W $01B0,$0E40,$01B2,$0E50,$01B4,$0E60,$01B6,$0E70
	DC.W $01B8,$0E90,$01BA,$0EA0,$01BC,$0EB0,$01BE,$0EC0

	DC.W $0106,$CCE1
	DC.W $0180,$0557,$0182,$0556,$0184,$0555,$0186,$0555
	DC.W $0188,$0544,$018A,$0544,$018C,$0DFF,$018E,$0315
	DC.W $0190,$0000,$0192,$0111,$0194,$0111,$0196,$0222
	DC.W $0198,$0333,$019A,$0333,$019C,$0444,$019E,$0555
	DC.W $01A0,$0555,$01A2,$0666,$01A4,$0777,$01A6,$0777
	DC.W $01A8,$0888,$01AA,$0999,$01AC,$0999,$01AE,$0AAA
	DC.W $01B0,$0BBB,$01B2,$0BBB,$01B4,$0CCC,$01B6,$0DDD
	DC.W $01B8,$0DDD,$01BA,$0EEE,$01BC,$0FFF,$01BE,$0FFF

	DC.W $0106,$ECE1
	DC.W $0180,$0A33,$0182,$074C,$0184,$0528,$0186,$00F0
	DC.W $0188,$08BE,$018A,$08CE,$018C,$0D64,$018E,$0D75
	DC.W $0190,$0E76,$0192,$0E87,$0194,$0EA9,$0196,$0EBA
	DC.W $0198,$0FCB,$019A,$0FDD,$019C,$0FEE,$019E,$0FFF
	DC.W $01A0,$0C53,$01A2,$0833,$01A4,$0422,$01A6,$0633
	DC.W $01A8,$0743,$01AA,$0844,$01AC,$0954,$01AE,$0B65
	DC.W $01B0,$0C76,$01B2,$0EC2,$01B4,$0CB2,$01B6,$0BA2
	DC.W $01B8,$0A92,$01BA,$0982,$01BC,$0872,$01BE,$0762


	dc.w $1001,$fffe			;Start!

COPA_PLANES:					;Bitplanes pointers
	dc.w $00e0,$0000,$00e2,$0000
	dc.w $00e4,$0000,$00e6,$0000
	dc.w $00e8,$0000,$00ea,$0000
	dc.w $00ec,$0000,$00ee,$0000
	dc.w $00f0,$0000,$00f2,$0000
	dc.w $00f4,$0000,$00f6,$0000
	dc.w $00f8,$0000,$00fa,$0000
	dc.w $00fc,$0000,$00fe,$0000

	DC.W $010C,$0011			;BPLCON4
	dc.w $008e,$3d4b			;DIWSTRT
	DC.W $0100,$0251			;BPLCON3
	DC.W $0104,$0224			;BPLCON2
	DC.W $0106,$0CE1			;BPLCON3
	dc.w $0090,$3DEB			;DIWSTOP
	dc.w $0092,$0018			;DDFSTRT
	dc.w $0094,$0068			;DDFSTOP
	DC.W $0102,$00AA			;BPLCON1

	dc.w $0108,-8,$010a,-8			;MODULO
;	dc.w $0108,-8,$010a,-8-80		;<-Try This!

	DC.W $01E4,$0200
	DC.W $01fc,$c007			;FMODE

	dc.w $ffff,$fffe


ChipEnd:

END:

;-------------------------------------------------

