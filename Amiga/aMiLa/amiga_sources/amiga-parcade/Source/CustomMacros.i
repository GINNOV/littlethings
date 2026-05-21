
	IFND _CUSTOMMACROS_I
_CUSTOMMACROS_I SET 1

*********************************************
* Custom Macro File (c)1989-2016 Antiriad / *
* Jonathan Bennett <jon@autoitscript.com    *
*********************************************

;CIAA chips

CiaA		=$bfe001
CiaB		=$bfd000

CiaPra		=$0
CiaPrb		=$100
CiaDdra		=$200
CiaDdrb		=$300
CiaTalo		=$400
CiaTahi		=$500
CiaTblo		=$600
CiaTbhi		=$700
CiaTodlo	=$800
CiaTodmid	=$900
CiaTodhi	=$a00
CiaSdr		=$c00
CiaIcr		=$d00
CiaCra		=$e00
CiaCrb		=$f00


;Execbase stuff

_ExecBase	=4

;offsets from execbase

_ColdCapture	=42
_CoolCapture	=46
_ChkSum		=82
_KickTagPtr	=550
_KickMemPtr	=546
_KickCheckSum	=554

_MaxChipMemory	=62
_MaxExtMemory	=78
_AttnFlags	=296
_VBlankFrequency	=530
_PowerSupplyFrequency =531
_SysStackUpper	=54
_SysStackLower	=58
_MemList		=322

;offsets from lib struc

_Lib_Version	=20
_Lib_Revision	=22


_Bus_Error	=$08
_Address_Error	=$0c
_Illegal_Inst	=$10
_Div_By_Zero	=$14
_CHK_Inst	=$18
_TRAPV_Inst	=$1c
_Privilege_Vio	=$20
_Trace		=$24
_LineA_Emu	=$28
_LineF_Emu	=$2c

_Level1Vector	=$64
_Level2Vector	=$68
_Level3Vector	=$6c
_Level4Vector	=$70
_Level5Vector	=$74
_Level6Vector	=$78
_Level7Vector	=$7c

_Trap0		=$80
_Trap1		=$84


;Exec library offsets

_AllocMem	=-198
_AllocAbs	=-204
_FreeMem	=-210
_Supervisor	=-30
_OldOpenLib	=-408
_OpenLib	=-552
_CloseLib	=-414
_AddDevice	=-432
_RemDevice	=-438
_Addport	=-354
_Remport	=-360
_OpenDevice	=-444
_CloseDevice	=-450
_DoIO		=-456
_SendIO		=-462
_FindResident	=-96
_FindTask	=-294
_SumKickData	=-612
_Superstate	=-150
_Userstate	=-156
_Forbid		=-132
_Permit		=-138


;DOS lib stuff

_Open		=-30
_Close		=-36
_Read		=-42
_Write		=-48
_Deletefile	=-72
_Rename		=-78
_Execute	=-222
_Lock		=-84
_Loadseg	=-150
_Unloadseg	=-156
_Createproc	=-138

Mode_old	=1005			;file handles
Mode_new	=1006


;GRAPHICS lib stuff

Gb_ActiView	=34
Gb_CopInit	=38

_LoadView	=-222
_WaitTOF	=-270
_OwnBlitter	=-456
_DisownBlitter	=-462
_WaitBlit	=-228


;Mem types

PublicMem	=$01
ChipMem		=$02
FastMem		=$04
ClearMem	=$10000
LargestMem	=$20000


;Misc

Kickstart_Version=$f8000c


; Cache Control Register ( CACR )
;
; 	BIT#	FUNCTION
;	0	Inst Cache Enable
;	1	Freeze Inst Cache
;	2	Clear Entry in Inst Cache
;	3	Clear Inst Cache
;	4	Inst Burst Enable
;	5	0
;	6	0	
;	7	0
;	8	Data Cache Enable
;	9	Freeze Data Cache
;	10	Clear Entry in Data Cache
;	11	Clear Data Cache
;	12	Data Burst Enable
;	13	Write Allocate (always set - I think...)
;
;	movec.l	dn,CACR




;Hardware registers, correct up to AA chipset

CUSTOM	=$DFF000

BLTDDAT	=$0
DMACONR	=$2
VPOSR	=$4
VHPOSR	=$6
DSKDATR	=$8
JOY0DAT	=$a
JOY1DAT	=$c
CLXDAT	=$e
ADKCONR	=$10
POT0DAT	=$12
POT1DAT	=$14
POTGOR	=$16
SERDATR	=$18
DSKBYTR	=$1a
INTENAR	=$1c
INTREQR	=$1e
REFPTR	=$28
VPOSW	=$2a
VHPOSW	=$2c
COPCON	=$2e
SERDAT	=$30
SERPER	=$32
POTGO	=$34
JOYTEST	=$36
STREQU	=$38
STRVBL	=$3a
STRHOR	=$3c
STRLONG	=$3e
DIWSTRT	=$8e
DIWSTOP	=$90
DDFSTRT	=$92
DDFSTOP	=$94
DMACON	=$96
CLXCON	=$98
INTENA	=$9a
INTREQ	=$9c
ADKCON	=$9e

DSKPTH	=$20
DSKPTL	=$22
DSKLEN	=$24
DSKDAT	=$26
DSKSYNC	=$7E

BLTCON0	=$40
BLTCON1	=$42
BLTAFWM	=$44
BLTALWM	=$46
BLTCPTH	=$48
BLTCPTL	=$4a
BLTBPTH	=$4c
BLTBPTL	=$4e
BLTAPTH	=$50
BLTAPTL	=$52
BLTDPTH	=$54
BLTDPTL	=$56
BLTSIZE	=$58
BLTCON0L=$5a
BLTSIZV =$5c
BLTSIZH =$5e
BLTCMOD	=$60
BLTBMOD	=$62
BLTAMOD	=$64
BLTDMOD	=$66
BLTCDAT	=$70
BLTBDAT	=$72
BLTADAT	=$74

COP1LCH	=$80
COP1LCL	=$82
COP2LCH	=$84
COP2LCL	=$86
COPJMP1	=$88
COPJMP2	=$8a
COPINS	=$8c

AUD0LCH	=$a0
AUD0LCL	=$a2
AUD0LEN	=$a4
AUD0PER	=$a6
AUD0VOL	=$a8
AUD0DAT	=$aa
AUD1LCH	=$b0
AUD1LCL	=$b2
AUD1LEN	=$b4
AUD1PER	=$b6
AUD1VOL	=$b8
AUD1DAT	=$ba
AUD2LCH	=$c0
AUD2LCL	=$c2
AUD2LEN	=$c4
AUD2PER	=$c6
AUD2VOL	=$c8
AUD2DAT	=$ca
AUD3LCH	=$d0
AUD3LCL	=$d2
AUD3LEN	=$d4
AUD3PER	=$d6
AUD3VOL	=$d8
AUD3DAT	=$da

BPLCON0	=$100
BPLCON1	=$102
BPLCON2	=$104
BPLCON3	=$106
BPLCON4	=$10C
BPL1MOD	=$108
BPL2MOD	=$10a
BPL1PTH	=$e0
BPL1PTL	=$e2
BPL2PTH	=$e4
BPL2PTL	=$e6
BPL3PTH	=$e8
BPL3PTL	=$ea
BPL4PTH	=$ec
BPL4PTL	=$ee
BPL5PTH	=$f0
BPL5PTL	=$f2
BPL6PTH	=$f4
BPL6PTL	=$f6
BPL7PTH	=$f8
BPL7PTL	=$fa
BPL8PTH	=$fc
BPL8PTL	=$fe

BPL1DAT	=$110
BPL2DAT	=$112
BPL3DAT	=$114
BPL4DAT	=$116
BPL5DAT	=$118
BPL6DAT	=$11A
BPL7DAT	=$11C
BPL8DAT	=$11E

SPR0PTH	=$120
SPR0PTL	=$122
SPR1PTH	=$124
SPR1PTL	=$126
SPR2PTH	=$128
SPR2PTL	=$12a
SPR3PTH	=$12c
SPR3PTL	=$12e
SPR4PTH	=$130
SPR4PTL	=$132
SPR5PTH	=$134
SPR5PTL	=$136
SPR6PTH	=$138
SPR6PTL	=$13a
SPR7PTH	=$13c
SPR7PTL	=$13e

SPR0POS	=$140
SPR0CTL	=$142
SPR0DATA=$144
SPR0DATB=$146
SPR1POS	=$148
SPR1CTL	=$14A
SPR1DATA=$14C
SPR1DATB=$14E
SPR2POS	=$150
SPR2CTL	=$152
SPR2DATA=$154
SPR2DATB=$156
SPR3POS	=$158
SPR3CTL	=$15A
SPR3DATA=$15C
SPR3DATB=$15E
SPR4POS	=$160
SPR4CTL	=$162
SPR4DATA=$164
SPR4DATB=$166
SPR5POS	=$168
SPR5CTL	=$16A
SPR5DATA=$16C
SPR5DATB=$16E
SPR6POS	=$170
SPR6CTL	=$172
SPR6DATA=$174
SPR6DATB=$176
SPR7POS	=$178
SPR7CTL	=$17A
SPR7DATA=$17C
SPR7DATB=$17E

;ECS and AA regs

SPRHDAT	=$078
BPLHDAT	=$07A
LISAID	=$07C
CLXCON2	=$10E
HTOTAL	=$1C0
HSSTOP	=$1C2
HBSTRT	=$1C4
HBSTOP	=$1C6
VTOTAL	=$1C8
VSSTOP	=$1CA
VBSTRT	=$1CC
VBSTOP	=$1CE
SPRHSTRT=$1D0
SPRHSTOP=$1D2
BPLHSTRT=$1D4
BPLHSTOP=$1D6
HHPOSW	=$1D8
HHPOSR	=$1DA
BEAMCON0=$1DC
HSSTRT	=$1DE
VSSTRT	=$1E0
HCENTER	=$1E2
DIWHIGH	=$1E4
BPLHMOD	=$1E6
SPRHPTH	=$1E8
SPRHPTL	=$1EA
BPLHPTH	=$1EC
BPLHPTL	=$1EE
FMODE	=$1FC
NULL	=$1FE


COLOR00	=$180
COLOR01	=$182
COLOR02	=$184
COLOR03	=$186
COLOR04	=$188
COLOR05	=$18A
COLOR06	=$18C
COLOR07	=$18E
COLOR08	=$190
COLOR09	=$192
COLOR10	=$194
COLOR11	=$196
COLOR12	=$198
COLOR13	=$19A
COLOR14	=$19C
COLOR15	=$19E
COLOR16	=$1A0
COLOR17	=$1A2
COLOR18	=$1A4
COLOR19	=$1A6
COLOR20	=$1A8
COLOR21	=$1AA
COLOR22	=$1AC
COLOR23	=$1AE
COLOR24	=$1B0
COLOR25	=$1B2
COLOR26	=$1B4
COLOR27	=$1B6
COLOR28	=$1B8
COLOR29	=$1BA
COLOR30	=$1BC
COLOR31	=$1BE


;Macros

TIMERON		MACRO
		Ifne	RasterTest
		move.w	#\1,COLOR00+CUSTOM
		Endc
		ENDM

TIMEROFF	MACRO
		Ifne	RasterTest
		move.w	#0,COLOR00+CUSTOM
		Endc
		ENDM

RTS_EQ		MACRO
		bne.s	.re\@
		rts
.re\@
		ENDM

RTS_NE		MACRO
		beq.s	.rne\@
		rts
.rne\@
		ENDM

SAVEREGS	MACRO
		movem.l	a0-a6/d0-d7,-(sp)
		ENDM
		
LOADREGS	MACRO
		movem.l	(sp)+,a0-a6/d0-d7
		ENDM

WAITBLIT_A1000_A5	MACRO
		tst.w	DMACONR(a5)		;for compatibility on A1000 with fastmem
.bw\@		btst.b	#6,DMACONR(a5)		;=bit 14 of DMACONR!
		bne.s	.bw\@
		ENDM

WAITBLIT_A1000	MACRO
		tst.w	DMACONR+CUSTOM		;for compatibility on A1000 with fastmem
.bw\@		btst.b	#6,DMACONR+CUSTOM	;=bit 14 of DMACONR!
		bne.s	.bw\@
		ENDM

; New version relies on NOT using blitter nasty except when waiting!
BLIT_NASTY_ON_A5	MACRO
		move.w	#$8400,DMACON(a5)	;Blitter nasty on
		ENDM

BLIT_NASTY_OFF_A5	MACRO
		move.w	#$0400,DMACON(a5)	;Blitter nasty off
		ENDM

WAITBLIT_A5	MACRO
.bw\@		btst.b	#6,DMACONR(a5)		;=bit 14 of DMACONR!
		bne.s	.bw\@
		ENDM

WAITBLIT	MACRO
.bw\@		btst.b	#6,DMACONR+CUSTOM	;=bit 14 of DMACONR!
		bne.s	.bw\@
		ENDM


VBLANKWAIT2	MACRO
.w2\@		cmpi.b	#$ff,VHPOSR+CUSTOM	; Line 255
		bne.s	.w2\@
		ENDM


AllocMem	MACRO				;SIZE, TYPE, WHERE
		move.l	(ExecBase).w,a6
		move.l	\1,d0
		move.l	\2,d1			;TYPE
		jsr	_AllocMem(a6)
		move.l	d0,\3
		ENDM

AllocAbs	MACRO				;SIZE, ADR, WHERE
		move.l	(ExecBase).w,a6
		move.l	\1,d0
		move.l	\2,a1
		jsr	_AllocAbs(a6)
		move.l	d0,\3
		ENDM

FreeMem		MACRO				;SIZE,WHERE
		move.l	(ExecBase).w,a6
		move.l	\1,d0
		move.l	\2,a1
		jsr	_FreeMem(A6)
		ENDM

LEFTMOUSEWAIT	MACRO
.wait\@		btst.b	#6,$bfe001
		bne.s	.wait\@
		ENDM

RIGHTMOUSEWAIT	MACRO
.wait\@		btst.b	#10-8,$dff016
		bne.s	.wait\@
		ENDM

NO_BLITMASK_A5	MACRO
		move.l	#-1,BLTAFWM(a5)
		ENDM

ENABLE_COPPER_DANGER_A5	MACRO
		move.w	#2,COPCON(a6)
		ENDM

ENABLE_LEV3_A5	MACRO
		move.w	#$c020,INTENA(a5)
		ENDM

DISABLE_LEV3_A5	MACRO
		move.w	#$0020,INTENA(a5)
		ENDM

RESET_LEV3	MACRO
		move.w	#$0020,INTREQ+CUSTOM
		move.w	#$0020,INTREQ+CUSTOM	;twice for A4000 compat
		ENDM

RESET_LEV3_A5	MACRO
		move.w	#$0020,INTREQ(a5)
		move.w	#$0020,INTREQ(a5)	;twice for A4000 compat
		ENDM
		


AGA_Palette_Load	MACRO

;\1=Palette Adr
;\2=Copper palette Adr
;\3=Number of colours

		move.l	\1,a0			;Palette data
		move.l	\2,a1			;Copper palette data
	
		move.w	\3/32-1,d7		;Number of colours
.ColLoop1\@
		addq.l	#4,a1			;miss bank select

		move.w	#32-1,d6
.ColLoop2\@
		move.w	(a0)+,2(a1)		;high bit
		move.w	(a0)+,132+2(a1)		;low bit
		addq.l	#4,a1
		dbf	d6,.ColLoop2\@

		lea	132(a1),a1
		dbf	d7,.ColLoop1\@

		ENDM


;Copper macros

CWAIT		MACRO
		dc.w	(\1&$ff)*256+(\2&$fe!1)
		dc.w	$fffe
		ENDM

CBLITWAIT	MACRO
		dc.w    $0001,$7ffe
		ENDM
		
COPPEREND	MACRO
		dc.w $ffff,$fffe
		ENDM

CSKIP		MACRO
		dc.b	\1,\2,$ff,$ff	
		ENDM
		
CMOVE		MACRO
		dc.w	\1,\2			
		ENDM


COL24BIT	MACRO			;Assumes bplcon3 =$0c00
					;High bits, Low bits
		CMOVE	\1,((\2&$f00000)>>12)!((\2&$f000)>>8)!((\2&$f0)>>4)
		CMOVE	BPLCON3,$0e00
		CMOVE	\1,((\2&$f0000)>>8)!((\2&$f00)>>4)!(\2&$0f)
		CMOVE	BPLCON3,$0c00
		ENDM
		
ALL_COLS	MACRO

		CMOVE	COLOR00,$000
		CMOVE	COLOR01,$000
		CMOVE	COLOR02,$000
		CMOVE	COLOR03,$000
		CMOVE	COLOR04,$000
		CMOVE	COLOR05,$000
		CMOVE	COLOR06,$000
		CMOVE	COLOR07,$000
		CMOVE	COLOR08,$000
		CMOVE	COLOR09,$000
		CMOVE	COLOR10,$000
		CMOVE	COLOR11,$000
		CMOVE	COLOR12,$000
		CMOVE	COLOR13,$000
		CMOVE	COLOR14,$000
		CMOVE	COLOR15,$000
		CMOVE	COLOR16,$000
		CMOVE	COLOR17,$000
		CMOVE	COLOR18,$000
		CMOVE	COLOR19,$000
		CMOVE	COLOR20,$000
		CMOVE	COLOR21,$000
		CMOVE	COLOR22,$000
		CMOVE	COLOR23,$000
		CMOVE	COLOR24,$000
		CMOVE	COLOR25,$000
		CMOVE	COLOR26,$000
		CMOVE	COLOR27,$000
		CMOVE	COLOR28,$000
		CMOVE	COLOR29,$000
		CMOVE	COLOR30,$000
		CMOVE	COLOR31,$000

		ENDM

		
;AGA_Copper_Palette	MACRO
;
;a SET $0c00
;b SET $0e00
;		REPT	(\1)/32
;	
;		CMOVE	BPLCON3,a		;bank x, high bits
;		All_Cols
;		CMOVE	BPLCON3,b		;bank x, low bits
;		All_Cols
;a SET a+$2000
;b SET b+$2000
;		ENDR
;		
;		ENDM
		
	ENDC	;CUSTOMMACROS_I