	IFND PLAYER_I
PLAYER_I SET 1

**	$Filename: Player.i $
**	$Release: 6.0A $
**	$Revision: 600.2 $
**	$Date: 94/01/13 $
**
**	The Player 6.0A definitions
**
**	(C) Copyright 1992-94 Jarno Paananen
**	All Rights Reserved
**

	IFND EXEC_TYPES_I
	include dh2:jezyki/sc/include/exec/types.i
	ENDC

**************
* The header *
**************

  STRUCTURE Player_Header,0
** Instructions to jump to P60_Init
	ULONG	P60_InitOffset
** ... to P60_Music (rts, if CIA-Version)
	ULONG	P60_MusicOffset
** ... to P60_End
	ULONG	P60_EndOffset
** ... to P60_SetRepeat (if present, otherwise rts)
	ULONG	P60_SetRepeatOffset
** Master volume (used if told to...)
	UWORD	P60_MasterVolume
** If non-zero, tempo will be used
	UWORD	P60_UseTempo
** If zero, playing is stopped
	UWORD	P60_PlayFlag
** Info nybble after command E8
	UWORD	P60_E8_info
** Offset to channel 0 block from the beginning
	APTR	P60_Cha0Offset
** Offset to channel 1 block from the beginning
	APTR	P60_Cha1Offset
** Offset to channel 2 block from the beginning
	APTR	P60_Cha2Offset
** Offset to channel 3 block from the beginning
	APTR	P60_Cha3Offset

	LABEL Player_Header_SIZE


*********************************************************
** The structure of the channel blocks (P60_Temp[0-3]) **
*********************************************************

  STRUCTURE Channel_Block,0

** Note and the MSB of the sample number
	UBYTE	P60_SN_Note
** Lower nybble of the sample number and the command
	UBYTE	P60_Command
** Info byte
	UBYTE	P60_Info
** Packing info
	UBYTE	P60_Pack
** Pointer to the sample block of the current sample
	APTR	P60_Sample
** Current note (offset to the period table)
	UWORD	P60_Note
** Period
	UWORD	P60_Period
** Volume (NOT updated in tremolo!)
	UWORD	P60_Volume
** Current finetune
	UWORD	P60_Fine
** Sample offset
	UWORD	P60_Offset
** To period for tone portamento
	UWORD	P60_ToPeriod
** Speed for tone portamento
	UWORD	P60_TPSpeed
** Vibrato command
	UBYTE	P60_VibCmd
** Vibrato position
	UBYTE	P60_VibPos
** Tremolo command
	UBYTE	P60_TreCmd
** Tremolo position
	UBYTE	P60_TrePos
** Retrig note counter
	UWORD	P60_RetrigCount

** Invert loop speed
	UBYTE	P60_Funkspd
** Invert loop offset
	UBYTE	P60_Funkoff
** Invert loop offset
	APTR	P60_Wave

** Internal switch to the packing
	UWORD	P60_OnOff
** Pointer to the current pattern data
	APTR	P60_ChaPos
** A packing pointer to data elsewhere in the pattern data
	APTR	P60_TempPos
** Lenght of the temporary positions
	UWORD	P60_TempLen
** Temp pointers for patternloop
	UWORD	P60_TData
	APTR	P60_TChaPos
	APTR	P60_TTempPos
	UWORD	P60_TTempLen

** Shadow address for fading (updated also in tremolo!)
	UWORD	P60_Shadow

** Bit in DMACON ($DFF096)
	UWORD	P60_DMABit

	LABEL Channel_Block_SIZE



************************************************
** The structure of the sample block that     **
** the Player does at the init to P60_Samples **
************************************************

  STRUCTURE Sample_Block,0

** Pointer to the beginning of the sample
	APTR	P60_SampleOffset
** Lenght of the sample
	UWORD	P60_SampleLength
** Pointer to the repeat
	APTR	P60_RepeatOffset
** Lenght of the repeat
	UWORD	P60_RepeatLength
** Volume of the sample
	UWORD	P60_SampleVolume
** Finetune (offset to the period table)
	UWORD	P60_FineTune

	LABEL Sample_Block_SIZE

************************************************
** Some internal stuff for the Usecode-system **
************************************************


** if finetune is used
P60_ft = use&1
** portamento up
P60_pu = use&2
** portamento down
P60_pd = use&4
** tone portamento
P60_tp = use&40
** vibrato
P60_vib = use&80
** tone portamento and volume slide
P60_tpvs = use&32
** vibrato and volume slide
P60_vbvs = use&64
** tremolo
P60_tre = use&$80
** arpeggio
P60_arp = use&$100
** sample offset
P60_sof = use&$200
** volume slide
P60_vs = use&$400
** position jump
P60_pj = use&$800
** set volume
P60_vl = use&$1000
** pattern break
P60_pb = use&$2800
** set speed
P60_sd = use&$8000

** E-commands
P60_ec = use&$ffff0000

** filter
P60_fi = use&$10000
** fine slide up
P60_fsu = use&$20000
** fine slide down
P60_fsd = use&$40000
** set finetune
P60_sft = use&$200000
** pattern loop
P60_pl = use&$400000
** E8 for timing purposes
P60_timing = use&$1000000
** retrig note
P60_rt = use&$2000000
** fine volume slide up
P60_fvu = use&$4000000
** fine volume slide down
P60_fvd = use&$8000000
** note cut
P60_nc = use&$10000000
** note delay
P60_nd = use&$20000000
** pattern delay
P60_pde = use&$40000000
** invert loop
P60_il = use&$80000000

   ENDC ; PLAYER_I
