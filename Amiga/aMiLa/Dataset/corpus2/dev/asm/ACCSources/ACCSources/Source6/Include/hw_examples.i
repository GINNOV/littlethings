* TYPED IN BY MIKE CROSS - APRIL 1990
* FROM `AMIGA HARDWARE REFERANCE MANUAL'

			IFND HARDWARE_HW_EXAMPLES_I
HARDWARE_HW_EXAMPLES_I  SET  1
**
**       Filename: hardware/hw_examples.i
**	$Release: 1.3 $
**
**
**	(C) Copyright 1985,1986,1987,1988,1989 Commodore-Amiga, Inc
**	    All Rights Reserved
**
*******************************************************************************

	IFND	HARDWARE_CUSTOM_I
	INCLUDE "df0:include/hardware/custom.i"
	ENDC
	
*******************************************************************************
*
*  This include file is designed to be used in conjunction with the hardware
*  manual examples.   This file defines the register names based on the
*  hardware/custom.i defination file.  There is no C-Language version of this
*  file
*
*******************************************************************************
*
COPPER_HALT	EQU	$FFFFFFFE
*
*******************************************************************************
*
* This is the offset in the 680x0 address space to the custom chip registers
* it is the same as _custom when linking with AMIGA.lib
*
CUSTOM		equ 	$dff000
*
* Various control registers
*
DMACONR		EQU	dmaconr
VPOSR		EQU	vposr
VHPOSR		EQU	vhposr
JOY0DAT		EQU	joy0dat
JOY1DAT		EQU	joy1dat
CLXDAT		EQU	clxdat
ADKCONR		EQU	adkconr
POT0DAT		EQU	pot0dat
POT1DAT		EQU	pot1dat
POTINP		EQU	potinp
SERDATR		EQU 	serdatr
INTENAR		EQU	intenar
INTREQR		EQU	intreqr
REFTR		EQU	refptr
VPOSW		EQU	vposw
VHPOSW		EQU	vhposw
SERDAT		EQU	serdat
SERPER		EQU	serper
POTGO		EQU	potgo
JOYTEST		EQU	joytest
STREQU		EQU	strequ
STRVBL		EQU	strvbl
STRHOR		EQU	strhor
STRLONG		EQU	strlong
DIWSTRT		EQU	diwstrt
DIWSTOP		EQU	diwstop
DDFSTRT		EQU	ddfstrt
DDFSTOP		EQU	ddfstop
DMACON		EQU	dmacon
INTENA		EQU	intena
INTREQ		EQU	intreq

*
* DISK CONTROL REGISTERS
*
DSKBYTR		EQU	dskbytr
DSKPT		EQU	dskpt
DSKPTH		EQU	dskpt
DSKPTLN		EQU	dskpt+$02
DSKLEN		EQU	dsklen
DSKDAT		EQU	dskdat
DSKSYNC		EQU	dsksync
*
* BLITTER REGISTERS
*
BLTCON0		EQU	bltcon0
BLTCON1		EQU	bltcon1
BLTAFWM		EQU	bltafwm
BLTALWM		EQU	bltalwm
BLTCPT		EQU	bltcpt
BLTCPTH		EQU	bltcpt
BLTCPTL		EQU	bltcpt+$02
BLTBPT		EQU	bltbpt
BLTBPTH		EQU	bltbpt
BLTBPTL		EQU	bltbpt+$02
BLTAPT		EQU	bltapt
BLTAPTH		EQU	bltapt
BLTAPTL		EQU	bltapt+$02
BLTDPT		EQU	bltdpt
BLTDPTH		EQU	bltdpt
BLTDPTL		EQU	bltdpt+$02
BLTSIZE		EQU	bltsize
BLTCMOD		EQU	bltcmod
BLTBMOD		EQU	bltbmod
BLTAMOD		EQU	bltamod
BLTDMOD		EQU	bltdmod
BLTCDAT		EQU	bltcdat
BLTBDAT		EQU	bltbdat
BLTADAT		EQU	bltadat
BLTDDAT		EQU	bltddat
*
* COPPER CONTROL REGISTERS
*
COPCON		EQU	copcon
COPINS		EQU	copins
COPJMP1		EQU	copjmp1
COPJMP2		EQU	copjmp2
COP1LC		EQU	cop1lc
COP1LCH		EQU	cop1lc
COP1LCL		EQU	cop1lc+$02
COP2LC		EQU	cop2lc
COP2LCH		EQU	cop2lc
COP2LCL		EQU	cop2lc+$02
*
* AUDIO CHANNELS REGISTERS
*
ADKCON		EQU	adkcon

AUD0LC		EQU	aud0
AUD0LCH		EQU	aud0
AUD0LCL		EQU	aud0+$02
AUD0LEN		EQU	aud0+$04
AUD0PER		EQU	aud0+$06
AUD0VOL		EQU	aud0+$08
AUD0DAT		EQU	aud0+$0a

AUD1LC		EQU	aud1
AUD1LCH		EQU	aud1
AUD1LCL		EQU	aud1+$02
AUD1LEN		EQU	aud1+$04
AUD1PER		EQU	aud1+$06
AUD1VOL		EQU	aud1+$08
AUD1DAT		EQU	aud1+$0a

AUD2LC		EQU	aud2
AUD2LCH		EQU	aud2
AUD2LCL		EQU	aud2+$02
AUD2LEN		EQU	aud2+$04
AUD2PER		EQU	aud2+$06
AUD2VOL		EQU	aud2+$08
AUD2DAT		EQU	aud2+$0a

AUD3LC		EQU	aud3
AUD3LCH		EQU	aud3
AUD3LCL		EQU	aud3+$02
AUD3LEN		EQU	aud3+$04
AUD3PER		EQU	aud3+$06
AUD3VOL		EQU	aud3+$08
AUD3DAT		EQU	aud3+$0a
*
* THE BITPLANE REGISTERS
*
BPL1PT		EQU	bplpt+$00
BPL1PTH		EQU	bplpt+$00
BPL1PTL		EQU	bplpt+$02
BPL2PT		EQU	bplpt+$04
BPL2PTH		EQU	bplpt+$04
BPL2PTL		EQU	bplpt+$06
BPL3PT		EQU	bplpt+$08
BPL3PTH		EQU	bplpt+$08
BPL3PTL		EQU	bplpt+$0A
BPL4PT		EQU	bplpt+$0C
BPL4PTH		EQU	bplpt+$0C
BPL4PTL		EQU	bplpt+$0E
BPL5PT		EQU	bplpt+$10
BPL5PTH		EQU	bplpt+$10
BPL5PTL		EQU	bplpt+$12
BPL6PT		EQU	bplpt+$14
BPL6PTH		EQU	bplpt+$14
BPL6PTL		EQU	bplpt+$16
	
BPLCON0		EQU	bplcon0
BPLCON1		EQU	bplcon1
BPLCON2		EQU	bplcon2
BPL1MOD		EQU	bpl1mod
BPL2MOD		EQU	bpl2mod

DPL1DATA	EQU	bpldat+$00
DPL2DATA	EQU	bpldat+$02
DPL3DATA	EQU	bpldat+$04
DPL4DATA	EQU	bpldat+$06
DPL5DATA	EQU	bpldat+$08
DPL6DATA	EQU	bpldat+$0a
*
* SPRITE CONTROL REGISTERS
*
SPR0PT		EQU	sprpt+$00
SPR0PTH		EQU	SPR0PT+$00
SPR0PTL		EQU	SPR0PT+$02
SPR1PT		EQU	sprpt+$04
SPR1PTH		EQU	SPR1PT+$00
SPR1PTL		EQU	SPR1PT+$02
SPR2PT		EQU	sprpt+$08
SPR2PTH		EQU	SPR2PT+$00
SPR2PTL		EQU	SPR2PT+$02
SPR3PT		EQU	sprpt+$0c
SPR3PTH		EQU	SPR3PT+$00
SPR3PTL		EQU	SPR3PT+$02
SPR4PT		EQU	sprpt+$10
SPR4PTH		EQU	SPR4PT+$00
SPR4PTL		EQU	SPR4PT+$02
SPR5PT		EQU	sprpt+$14
SPR5PTH		EQU	SPR5PT+$00
SPR5PTL		EQU	SPR5PT+$02
SPR6PT		EQU	sprpt+$18
SPR6PTH		EQU	SPR6PT+$00
SPR6PTL		EQU	SPR6PT+$02
SPR7PT		EQU	sprpt+$1c
SPR7PTH		EQU	SPR7PT+$00
SPR7PTL		EQU	SPR7PT+$02


SPR0POS		EQU	spr+$00
SPR0CTL		EQU	SPR0POS+sd_ctl
SPR0DATA	EQU	SPR0POS+sd_dataa
SPR0DATB	EQU	SPR0POS+$06

SPR1POS		EQU	spr+$08
SPR1CTL		EQU	SPR1POS+sd_ctl
SPR1DATA	EQU	SPR1POS+sd_dataa
SPR1DATB	EQU	SPR1POS+$06

SPR2POS		EQU	spr+$10
SPR2CTL		EQU	SPR2POS+sd_ctl
SPR2DATA	EQU	SPR2POS+sd_dataa
SPR2DATB	EQU	SPR2POS+$06

SPR3POS		EQU	spr+$18
SPR3CTL		EQU	SPR3POS+sd_ctl
SPR3DATA	EQU	SPR3POS+sd_dataa
SPR3DATB	EQU	SPR3POS+$06

SPR4POS		EQU	spr+$20
SPR4CTL		EQU	SPR4POS+sd_ctl
SPR4DATA	EQU	SPR4POS+sd_dataa
SPR4DATB	EQU	SPR4POS+$06

SPR5POS		EQU	spr+$28
SPR5CTL		EQU	SPR5POS+sd_ctl
SPR5DATA	EQU	SPR5POS+sd_dataa
SPR5DATB	EQU	SPR5POS+$06

SPR6POS		EQU	spr+$30
SPR6CTL		EQU	SPR6POS+sd_ctl
SPR6DATA	EQU	SPR6POS+sd_dataa
SPR6DATB	EQU	SPR6POS+$06

SPR7POS		EQU	spr+$38
SPR7CTL		EQU	SPR7POS+sd_ctl
SPR7DATA	EQU	SPR7POS+sd_dataa
SPR7DATB	EQU	SPR7POS+$06
*
* COLOUR REGISTERS...
*
COLOR00		EQU	color+$00
COLOR01		EQU	color+$02
COLOR02		EQU	color+$04
COLOR03		EQU	color+$06
COLOR04		EQU	color+$08
COLOR05		EQU	color+$0a
COLOR06		EQU	color+$0c
COLOR07		EQU	color+$0e
COLOR08		EQU	color+$10
COLOR09		EQU	color+$12
COLOR10		EQU	color+$14
COLOR11		EQU	color+$16
COLOR12		EQU	color+$18
COLOR13		EQU	color+$1a
COLOR14		EQU	color+$1c
COLOR15		EQU	color+$1e
COLOR16		EQU	color+$20
COLOR17		EQU	color+$22
COLOR18		EQU	color+$24
COLOR19		EQU	color+$26
COLOR20		EQU	color+$28
COLOR21		EQU	color+$2a
COLOR22		EQU	color+$2c
COLOR23		EQU	color+$2e
COLOR24		EQU	color+$30
COLOR25		EQU	color+$32
COLOR26		EQU	color+$34
COLOR27		EQU	color+$36
COLOR28		EQU	color+$38
COLOR29		EQU	color+$3a
COLOR30		EQU	color+$3c
COLOR31		EQU	color+$3e

*******************************************************************

		ENDC

		



	















