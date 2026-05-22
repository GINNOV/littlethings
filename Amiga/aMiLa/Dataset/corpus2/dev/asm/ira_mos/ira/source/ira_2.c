;/*
	failat 20
   sc gst=include:all.gst parms=register nostackcheck opttime optimize IRA_2.c
;   slink lib:c.o IRA.o IRA20_1.o IRA_2.o to IRA sc sd nd lib lib:sc.lib

   QUIT

   TABSIZE == 3 !!

   Author   : Tim Ruehsen
   Project  : IRA  -  680x0 Interactive ReAssembler
   Part     : IRA_2.c
   Purpose  : Contains data and some subroutines for IRA
   Version  : $VER: IRA_2.c 1.04
   Date     : 23.05.1995
   Copyright: (C)1993-1995 Tim Ruehsen

*/

#include "IRA.h"

struct OpCode {
	UBYTE  *mnemonic;
	UWORD result;
	UWORD maske;
	UWORD sourceadr;
	UWORD destadr;
	UWORD cputype;
	UBYTE  flags;
	};

CONST TEXT cpuname[][8]={"MC68000","MC68010","MC68020","MC68030","MC68040","MC68060"};

CONST TEXT opcode[][8]={
/*  0*/	"BF","","",
/*  3*/	"ILLEGAL","NOP","RESET","RTE","RTR","RTS","RTD","STOP","TRAPV","MOVEC",
/* 13*/	"BKPT","SWAP","LINK","LINK.L","UNLK","EXT","EXT.L","EXTB.L","MOVE.L","MOVE.L","TRAP",
/* 24*/	"DIV","MUL","TAS","JMP","JSR","PEA","NBCD","MOVE","MOVE","MOVE","MOVE",
/* 35*/	"MOVEM","MOVEM","MOVEM.L","MOVEM.L","LEA","CHK","CHK.L","CLR",
/* 43*/	"TST","NOT","NEG","NEGX",
/* 47*/	"ADDA","ADDA.L","ADDX","ADDX","ADD","ADD","EXG","EXG","EXG",
/* 56*/	"ABCD","ABCD","MULS","MULU","AND","AND",
/* 62*/	"CMPA","CMPA.L","CMPM","CMP","EOR",
/* 67*/	"PACK","PACK","UNPK","UNPK","SBCD","SBCD","DIVS","DIVU","OR","OR",
/* 77*/	"MOVE.B","MOVEA","MOVE","MOVEA.L","MOVE.L","MOVEQ",
/* 83*/	"SUBA","SUBA.L","SUBX","SUBX","SUB","SUB",
/* 89*/	"MOVEP","MOVEP","MOVEP.L","MOVEP.L","B","CAS2","CAS","RTM","CALLM","C",
/* 99*/	"CMPI","EORI","ANDI","ADDI","SUBI","ORI","B","MOVES",
/*107*/	"DB","TRAP","TRAP","TRAP","S","ADDQ","SUBQ","B",
/*115*/	"MOVE16","MOVE16","C"," "
};
CONST UWORD result[]={
	0xe8c0,0xe0c0,0xe000,
	0x4afc,0x4e71,0x4e70,0x4e73,0x4e77,0x4e75,0x4e74,0x4e72,0x4e76,0x4e7a,
	0x4848,0x4840,0x4e50,0x4808,0x4e58,0x4880,0x48c0,0x49c0,0x4e68,0x4e60,0x4e40,
	0x4c40,0x4c00,0x4ac0,0x4ec0,0x4e80,0x4840,0x4800,0x44c0,0x46c0,0x40c0,0x42c0,
	0x4880,0x4c80,0x48c0,0x4cc0,0x41c0,0x4180,0x4100,0x4200,
	0x4a00,0x4600,0x4400,0x4000,
	0xd0c0,0xd1c0,0xd100,0xd108,0xd100,0xd000,0xc140,0xc148,0xc188,
	0xc100,0xc108,0xc1c0,0xc0c0,0xc100,0xc000,
	0xb0c0,0xb1c0,0xb108,0xb000,0xb100,
	0x8148,0x8140,0x8188,0x8180,0x8100,0x8108,0x81c0,0x80c0,0x8100,0x8000,
	0x1000,0x3040,0x3000,0x2040,0x2000,0x7000,
	0x90c0,0x91c0,0x9100,0x9108,0x9100,0x9000,
	0x0188,0x0108,0x01c8,0x0148,0x0800,0x08fc,0x08c0,0x06c0,0x06c0,0x00c0,
	0x0c00,0x0a00,0x0200,0x0600,0x0400,0x0000,0x0100,0x0e00,
	0x50c8,0x50fc,0x50fa,0x50fb,0x50c0,0x5000,0x5100,0x6000,
	0xf620,0xf600,0xf400,0x0000
	};

CONST UWORD maske[]={
	0xf8c0,0xf8c0,0xf000,
	0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xfffe,
	0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff8,0xfff0,
	0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,
	0xffc0,0xffc0,0xffc0,0xffc0,0xf1c0,0xf1c0,0xf1c0,0xff00,
	0xff00,0xff00,0xff00,0xff00,
	0xf1c0,0xf1c0,0xf138,0xf138,0xf100,0xf100,0xf1f8,0xf1f8,0xf1f8,
	0xf1f8,0xf1f8,0xf1c0,0xf1c0,0xf100,0xf100,
	0xf1c0,0xf1c0,0xf138,0xf100,0xf100,
	0xf1f8,0xf1f8,0xf1f8,0xf1f8,0xf1f8,0xf1f8,0xf1c0,0xf1c0,0xf100,0xf100,
	0xf000,0xf1c0,0xf000,0xf1c0,0xf000,0xf100,
	0xf1c0,0xf1c0,0xf138,0xf138,0xf100,0xf100,
	0xf1f8,0xf1f8,0xf1f8,0xf1f8,0xff00,0xf9ff,0xf9c0,0xfff0,0xffc0,0xf9c0,
	0xff00,0xff00,0xff00,0xff00,0xff00,0xff00,0xf100,0xff00,
	0xf0f8,0xf0ff,0xf0ff,0xf0ff,0xf0c0,0xf100,0xf100,0xf000,
	0xfff8,0xffe0,0xff10,0x0000
	};

	/* Achtung ! Gilt nur fuer sourceadr[] und destadr[]. */
	/* Bit 15 (0x8000) : 1 ==> Im unteren Byte steht die einzig moegl. */
	/*                         Adressierungsart. */
	/* Bit 13 (0x2000) : 0 ==> reg=reg2 */
	/*							1 ==> reg=reg1 */
	/*							Bestimmt, ob reg1 oder reg2 bestimmend ist. */
UWORD sourceadr[]={
	0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x8001,0x8001,0x0000,0x0000,0x0000,0x0000,0x800e,0x8001,0x0000,
	0x0bff,0x0bff,0x0000,0x0000,0x0000,0x0000,0x0000,0x0bff,0x0bff,0x800d,0x800c,
	0x800f,0x037e,0x800f,0x037e,0x027e,0x0bff,0x0bff,0x0000,
	0x0bf8,0x0000,0x0000,0x0000,
	0x0fff,0x0fff,0x8000,0x8004,0xa000,0x0fff,0xa000,0xa001,0xa000,
	0x8000,0x8004,0x0bff,0x0bff,0xa000,0x0bff,
	0x0fff,0x0fff,0x8003,0x0fff,0xa000,
	0x8004,0x8000,0x8004,0x8000,0x8000,0x8004,0x0bff,0x0bff,0xa000,0x0bff,
	0x0fff,0x0fff,0x0fff,0x0fff,0x0fff,0x8014,
	0x0fff,0x0fff,0x8000,0x8004,0xa000,0x0fff,
	0xa000,0x8005,0xa000,0x8005,0x8017,0x0000,0x801c,0x0000,0x800b,0x027e,
	0x800b,0x800b,0x800b,0x800b,0x800b,0x800b,0xa017,0x0000,
	0x8000,0x0000,0x800b,0x800b,0x0000,0xa010,0xa010,0x0000,
	0x8003,0x0000,0x8020,0x8000+NOADRMODE
	};
UWORD destadr[]={
	0x8019,0x03f8,0x8000,
	0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x8016,0x8018,0x0000,0x8021,
	0x8011,0x8000,0x8016,0x801e,0x8001,0x8000,0x8000,0x8000,0x8001,0x800e,0x8013,
	0x801d,0x801d,0x0bf8,0x027e,0x027e,0x027e,0x0bf8,0x800c,0x800d,0x0bf8,0x0bf8,
	0x02f8,0x800f,0x02f8,0x800f,0xa001,0xa000,0xa000,0x0bf8,
	0x0000,0x0bf8,0x0bf8,0x0bf8,
	0xa001,0xa001,0xa000,0xa004,0x03f8,0xa000,0x8000,0x8001,0x8001,
	0xa000,0xa004,0xa000,0xa000,0x03f8,0xa000,
	0xa001,0xa001,0xa003,0xa000,0x0bf8,
	0xa004,0xa000,0xa004,0xa000,0xa000,0xa004,0xa000,0xa000,0x03f8,0xa000,
	0x0bf8,0xa001,0x0bf8,0xa001,0x0bf8,0xa000,
	0xa001,0xa001,0xa000,0xa004,0x03f8,0xa000,
	0x8005,0xa000,0x8005,0xa000,0x0000,0x801b,0x03f8,0x801a,0x027e,0x0000,
	0x0bf8,0x0bf9,0x0bf9,0x0bf8,0x0bf8,0x0bf9,0x0000,0x0000,
	0x8012,0x0000,0x0000,0x0000,0x0bf8,0x0ff8,0x0ff8,0x8015,
	0x801f,0x0000,0x8002,0x0000
	};
/*
	FLAGS:
   0x80 : operand size is in bits [0:1] (0=.B,1=.W,2=.L)
          else use opsize from opcode
   0x40 : operand size has to be appended to mnemonic
	0x20 : one further word has to be saved before further processing.
	0x10 : the condition code identifier has to be appended to the mnemonic.
*/
CONST UBYTE flags[]={
	0x20,0x81,0x40,
	0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x82,
	0x80,0x80,0x81,0x81,0x81,0x81,0x82,0x82,0x82,0x82,0x80,
	0xa2,0xa2,0x80,0x81,0x81,0x80,0x80,0x81,0x81,0x81,0x81,
	0xa1,0xa1,0xa2,0xa2,0x80,0x81,0x82,0x40,
	0x40,0x40,0x40,0x40,
	0x81,0x82,0x40,0x40,0x40,0x40,0x82,0x82,0x82,
	0x80,0x80,0x81,0x81,0x40,0x40,
	0x81,0x82,0x40,0x40,0x40,
	0xa1,0xa1,0xa1,0xa1,0x80,0x80,0x81,0x81,0x40,0x40,
	0x80,0x81,0x81,0x82,0x82,0x80,
	0x81,0x82,0x40,0x40,0x40,0x40,
	0x81,0x81,0x82,0x82,0x00,0x20,0x00,0x00,0x81,0x40,
	0x40,0x40,0x40,0x40,0x40,0x40,0x00,0x40,
	0x90,0x90,0x91,0x92,0x90,0x40,0x40,0x90,
	0x82,0x82,0x00,0x80
	};
CONST UBYTE cputype[]={
	M020UP,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M010UP,M680x0,M680x0,M010UP,
	M020UP,M680x0,M680x0,M020UP,M680x0,M680x0,M680x0,M020UP,M680x0,M680x0,M680x0,
	M020UP,M020UP,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M010UP,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M020UP,M680x0,
	M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,
	M020UP,M020UP,M020UP,M020UP,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,
	M680x0,M680x0,M680x0,M680x0,M680x0,M020UP,M020UP,M68020,M68020,M020UP,
	M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M680x0,M010UP,
	M680x0,M020UP,M020UP,M020UP,M680x0,M680x0,M680x0,M680x0,
	M040UP,M040UP,M68040,M680x0
	};

CONST TEXT bitshift[][4]   ={"AS","LS","ROX","RO"};
CONST TEXT condcode[][3]   ={
	"T","F","HI","LS","CC","CS","NE","EQ","VC","VS","PL","MI",
	"GE","LT","GT","LE","RA","SR"};
STATIC CONST TEXT mmu_cc[][3]     ={
	"BS","BC","LS","LC","SS","SC","AS","AC",
	"WS","WC","IS","IC","GS","GC","CS","CC"};
STATIC CONST TEXT fpu_cc[][5]     ={
	"F","EQ","OGT","OGE","OLT","OLE","OGL","OR",
	"UN","UEQ","UGT","UGE","ULT","ULE","NE","T",
	"SF","SEQ","GT","GE","LT","LE","GL","GLE",
	"NGLE","NGL","NLE","NLT","NGE","NGT","SNE","ST"};
CONST TEXT extension[][3]  ={".B","",".L"};
CONST TEXT caches[][3]     ={"NC","DC","IC","BC"};
CONST TEXT bitop[][4]      ={"TST","CHG","CLR","SET"};
CONST TEXT memtypename[][7]= {"PUBLIC","CHIP","FAST","???"};
CONST TEXT modname[][5]    ={"CODE","DATA","BSS"};
CONST TEXT bitfield[][5]   ={"TST","EXTU","CHG","EXTS","CLR","FFO","SET","INS"};
CONST TEXT cregname[][6]   ={"SFC","DFC","CACR","TC", "ITT0","ITT1", "DTT0","DTT1","BUSCR",
                       "USP","VBR","CAAR","MSP","ISP", "MMUSR","URP", "SRP","PCR"};
CONST UWORD cregflag[18]   ={M010UP,M010UP,M020UP,M040UP,M040UP,M040UP,M040UP,M040UP,M68060,
                       M010UP,M010UP,M68020|M68030,M020UP,M020UP,M68040,M040UP,M040UP,M68060};

CONST struct x_adr x_adrs[] =
{
	{ "ABSEXECBASE",0x0004 },
	{ "BUS_ERROR",  0x0008 },
	{ "ADR_ERROR",  0x000C },
	{ "ILLEG_OPC",  0x0010 },
	{ "DIVISION0",  0x0014 },
	{ "CHK",        0x0018 },
	{ "TRAPV",      0x001C },
	{ "PRIVILEG",   0x0020 },
	{ "TRACE",      0x0024 },
	{ "LINEA_EMU",  0x0028 },
	{ "LINEF_EMU",  0x002C },
	{ "INT_NOINI",  0x003C },
	{ "INT_WRONG",  0x0060 },
	{ "AUTO_INT1",  0x0064 },
	{ "AUTO_INT2",  0x0068 },
	{ "AUTO_INT3",  0x006C },
	{ "AUTO_INT4",  0x0070 },
	{ "AUTO_INT5",  0x0074 },
	{ "AUTO_INT6",  0x0078 },
	{ "NMI",        0x007C },
	{ "TRAP_01",    0x0080 },
	{ "TRAP_02",    0x0084 },
	{ "TRAP_03",    0x0088 },
	{ "TRAP_04",    0x008C },
	{ "TRAP_05",    0x0090 },
	{ "TRAP_06",    0x0094 },
	{ "TRAP_07",    0x0098 },
	{ "TRAP_08",    0x009C },
	{ "TRAP_09",    0x00A0 },
	{ "TRAP_10",    0x00A4 },
	{ "TRAP_11",    0x00A8 },
	{ "TRAP_12",    0x00AC },
	{ "TRAP_13",    0x00B0 },
	{ "TRAP_14",    0x00B4 },
	{ "TRAP_15",    0x00B8 },
	{ "CIAB_PRA",   0xBFD000 },
	{ "CIAB_PRB",   0xBFD100 },
	{ "CIAB_DDRA",  0xBFD200 },
	{ "CIAB_DDRB",  0xBFD300 },
	{ "CIAB_TALO",  0xBFD400 },
	{ "CIAB_TAHI",  0xBFD500 },
	{ "CIAB_TBLO",  0xBFD600 },
	{ "CIAB_TBHI",  0xBFD700 },
	{ "CIAB_TDLO",  0xBFD800 },
	{ "CIAB_TDMD",  0xBFD900 },
	{ "CIAB_TDHI",  0xBFDA00 },
	{ "CIAB_SDR",   0xBFDC00 },
	{ "CIAB_ICR",   0xBFDD00 },
	{ "CIAB_CRA",   0xBFDE00 },
	{ "CIAB_CRB",   0xBFDF00 },
	{ "CIAA_PRA",   0xBFE001 },
	{ "CIAA_PRB",   0xBFE101 },
	{ "CIAA_DDRA",  0xBFE201 },
	{ "CIAA_DDRB",  0xBFE301 },
	{ "CIAA_TALO",  0xBFE401 },
	{ "CIAA_TAHI",  0xBFE501 },
	{ "CIAA_TBLO",  0xBFE601 },
	{ "CIAA_TBHI",  0xBFE701 },
	{ "CIAA_TDLO",  0xBFE801 },
	{ "CIAA_TDMD",  0xBFE901 },
	{ "CIAA_TDHI",  0xBFEA01 },
	{ "CIAA_SDR",   0xBFEC01 },
	{ "CIAA_ICR",   0xBFED01 },
	{ "CIAA_CRA",   0xBFEE01 },
	{ "CIAA_CRB",   0xBFEF01 },
	{ "CLK_S1",     0xDC0000 },
	{ "CLK_S10",    0xDC0004 },
	{ "CLK_MI1",    0xDC0008 },
	{ "CLK_MI10",   0xDC000C },
	{ "CLK_H1",     0xDC0010 },
	{ "CLK_H10",    0xDC0014 },
	{ "CLK_D1",     0xDC0018 },
	{ "CLK_D10",    0xDC001C },
	{ "CLK_MO1",    0xDC0020 },
	{ "CLK_MO10",   0xDC0024 },
	{ "CLK_Y1",     0xDC0028 },
	{ "CLK_Y10",    0xDC002E },
	{ "CLK_WEEK",   0xDC0030 },
	{ "CLK_CD",     0xDC0034 },
	{ "CLK_CE",     0xDC0038 },
	{ "CLK_CF",     0xDC003C },
	{ "HARDBASE",   0xDFF000 },
	{ "DMACONR",    0xDFF002 },
	{ "VPOSR",      0xDFF004 },
	{ "VHPOSR",     0xDFF006 },
	{ "DSKDATR",    0xDFF008 },
	{ "JOY0DAT",    0xDFF00A },
	{ "JOY1DAT",    0xDFF00C },
	{ "CLXDAT",     0xDFF00E },
	{ "ADKCONR",    0xDFF010 },
	{ "POT0DAT",    0xDFF012 },
	{ "POT1DAT",    0xDFF014 },
	{ "POTGOR",     0xDFF016 },
	{ "SERDATR",    0xDFF018 },
	{ "DSKBYTR",    0xDFF01A },
	{ "INTENAR",    0xDFF01C },
	{ "INTREQR",    0xDFF01E },
	{ "DSKPTH",     0xDFF020 },
	{ "DSKPTL",     0xDFF022 },
	{ "DSKLEN",     0xDFF024 },
	{ "DSKDAT",     0xDFF026 },
	{ "REFPTR",     0xDFF028 },
	{ "VPOSW",      0xDFF02A },
	{ "VHPOSW",     0xDFF02C },
	{ "COPCON",     0xDFF02E },
	{ "SERDAT",     0xDFF030 },
	{ "SERPER",     0xDFF032 },
	{ "POTGO",      0xDFF034 },
	{ "JOYTEST",    0xDFF036 },
	{ "STREQU",     0xDFF038 },
	{ "STRVBL",     0xDFF03A },
	{ "STRHOR",     0xDFF03C },
	{ "STRLONG",    0xDFF03E },
	{ "BLTCON0",    0xDFF040 },
	{ "BLTCON1",    0xDFF042 },
	{ "BLTAFWM",    0xDFF044 },
	{ "BLTALWM",    0xDFF046 },
	{ "BLTCPTH",    0xDFF048 },
	{ "BLTCPTL",    0xDFF04A },
	{ "BLTBPTH",    0xDFF04C },
	{ "BLTBPTL",    0xDFF04E },
	{ "BLTAPTH",    0xDFF050 },
	{ "BLTAPTL",    0xDFF052 },
	{ "BLTDPTH",    0xDFF054 },
	{ "BLTDPTL",    0xDFF056 },
	{ "BLTSIZE",    0xDFF058 },
	{ "BLTCON01",   0xDFF05A }, /* ECS */
	{ "BLTSIZV",    0xDFF05C }, /* ECS */
	{ "BLTSIZH",    0xDFF05E }, /* ECS */
	{ "BLTCMOD",    0xDFF060 },
	{ "BLTBMOD",    0xDFF062 },
	{ "BLTAMOD",    0xDFF064 },
	{ "BLTDMOD",    0xDFF066 }, /* 50 */
	{ "BLTCDAT",    0xDFF070 },
	{ "BLTBDAT",    0xDFF072 },
	{ "BLTADAT",    0xDFF074 },
	{ "BLTDDAT",    0xDFF076 },
	{ "SPRHDAT",    0xDFF078 }, /* ECS */
	{ "DENISEID",   0xDFF07C }, /* ECS */
	{ "DSKSYNC",    0xDFF07E },
	{ "COP1LCH",    0xDFF080 },
	{ "COP1LCL",    0xDFF082 },
	{ "COP2LCH",    0xDFF084 },
	{ "COP2LCL",    0xDFF086 },
	{ "COPJMP1",    0xDFF088 },
	{ "COPJMP2",    0xDFF08A },
	{ "COPINS",     0xDFF08C },
	{ "DIWSTRT",    0xDFF08E },
	{ "DIWSTOP",    0xDFF090 },
	{ "DDFSTRT",    0xDFF092 },
	{ "DFFSTOP",    0xDFF094 },
	{ "DMACON",     0xDFF096 },
	{ "CLXCON",     0xDFF098 },
	{ "INTENA",     0xDFF09A },
	{ "INTREQ",     0xDFF09C },
	{ "ADKCON",     0xDFF09E },
	{ "AUD0LCH",    0xDFF0A0 },
	{ "AUD0LCL",    0xDFF0A2 },
	{ "AUD0LEN",    0xDFF0A4 },
	{ "AUD0PER",    0xDFF0A6 },
	{ "AUD0VOL",    0xDFF0A8 },
	{ "AUD0DAT",    0xDFF0AA },
	{ "AUD1LCH",    0xDFF0B0 },
	{ "AUD1LCL",    0xDFF0B2 },
	{ "AUD1LEN",    0xDFF0B4 },
	{ "AUD1PER",    0xDFF0B6 },
	{ "AUD1VOL",    0xDFF0B8 },
	{ "AUD1DAT",    0xDFF0BA },
	{ "AUD2LCH",    0xDFF0C0 },
	{ "AUD2LCL",    0xDFF0C2 },
	{ "AUD2LEN",    0xDFF0C4 },
	{ "AUD2PER",    0xDFF0C6 },
	{ "AUD2VOL",    0xDFF0C8 },
	{ "AUD2DAT",    0xDFF0CA },
	{ "AUD3LCH",    0xDFF0D0 },
	{ "AUD3LCL",    0xDFF0D2 },
	{ "AUD3LEN",    0xDFF0D4 },
	{ "AUD3PER",    0xDFF0D6 },
	{ "AUD3VOL",    0xDFF0D8 },
	{ "AUD3DAT",    0xDFF0DA },
	{ "BPL1PTH",    0xDFF0E0 },
	{ "BPL1PTL",    0xDFF0E2 },
	{ "BPL2PTH",    0xDFF0E4 },
	{ "BPL2PTL",    0xDFF0E6 },
	{ "BPL3PTH",    0xDFF0E8 },
	{ "BPL3PTL",    0xDFF0EA },
	{ "BPL4PTH",    0xDFF0EC },
	{ "BPL4PTL",    0xDFF0EE },
	{ "BPL5PTH",    0xDFF0F0 },
	{ "BPL5PTL",    0xDFF0F2 },
	{ "BPL6PTH",    0xDFF0F4 },
	{ "BPL6PTL",    0xDFF0F6 },
	{ "BPLCON0",    0xDFF100 },
	{ "BPLCON1",    0xDFF102 },
	{ "BPLCON2",    0xDFF104 },
	{ "BPLCON3",    0xDFF106 }, /* ECS */
	{ "BPL1MOD",    0xDFF108 },
	{ "BPL2MOD",    0xDFF10A },
	{ "BPL1DAT",    0xDFF110 },
	{ "BPL2DAT",    0xDFF112 },
	{ "BPL3DAT",    0xDFF114 },
	{ "BPL4DAT",    0xDFF116 },
	{ "BPL5DAT",    0xDFF118 },
	{ "BPL6DAT",    0xDFF11A },
	{ "SPR0PTH",    0xDFF120 },
	{ "SPR0PTL",    0xDFF122 },
	{ "SPR1PTH",    0xDFF124 },
	{ "SPR1PTL",    0xDFF126 },
	{ "SPR2PTH",    0xDFF128 },
	{ "SPR2PTL",    0xDFF12A },
	{ "SPR3PTH",    0xDFF12C },
	{ "SPR3PTL",    0xDFF12E },
	{ "SPR4PTH",    0xDFF130 },
	{ "SPR4PTL",    0xDFF132 },
	{ "SPR5PTH",    0xDFF134 },
	{ "SPR5PTL",    0xDFF136 },
	{ "SPR6PTH",    0xDFF138 },
	{ "SPR6PTL",    0xDFF13A },
	{ "SPR7PTH",    0xDFF13C },
	{ "SPR7PTL",    0xDFF13E },
	{ "SPR0POS",    0xDFF140 },
	{ "SPR0CTL",    0xDFF142 },
	{ "SPR0DATA",   0xDFF144 },
	{ "SPR0DATB",   0xDFF146 },
	{ "SPR1POS",    0xDFF148 },
	{ "SPR1CTL",    0xDFF14A },
	{ "SPR1DATA",   0xDFF14C },
	{ "SPR1DATB",   0xDFF14E },
	{ "SPR2POS",    0xDFF150 },
	{ "SPR2CTL",    0xDFF152 },
	{ "SPR2DATA",   0xDFF154 },
	{ "SPR2DATB",   0xDFF156 },
	{ "SPR3POS",    0xDFF158 },
	{ "SPR3CTL",    0xDFF15A },
	{ "SPR3DATA",   0xDFF15C },
	{ "SPR3DATB",   0xDFF15E },
	{ "SPR4POS",    0xDFF160 },
	{ "SPR4CTL",    0xDFF162 },
	{ "SPR4DATA",   0xDFF164 },
	{ "SPR4DATB",   0xDFF166 },
	{ "SPR5POS",    0xDFF168 },
	{ "SPR5CTL",    0xDFF16A },
	{ "SPR5DATA",   0xDFF16C },
	{ "SPR5DATB",   0xDFF16E },
	{ "SPR6POS",    0xDFF170 },
	{ "SPR6CTL",    0xDFF172 },
	{ "SPR6DATA",   0xDFF174 },
	{ "SPR6DATB",   0xDFF176 },
	{ "SPR7POS",    0xDFF178 },
	{ "SPR7CTL",    0xDFF17A },
	{ "SPR7DATA",   0xDFF17C },
	{ "SPR7DATB",   0xDFF17E },
	{ "COLOR00",    0xDFF180 },
	{ "COLOR01",    0xDFF182 },
	{ "COLOR02",    0xDFF184 },
	{ "COLOR03",    0xDFF186 },
	{ "COLOR04",    0xDFF188 },
	{ "COLOR05",    0xDFF18A },
	{ "COLOR06",    0xDFF18C },
	{ "COLOR07",    0xDFF18E },
	{ "COLOR08",    0xDFF190 },
	{ "COLOR09",    0xDFF192 },
	{ "COLOR10",    0xDFF194 },
	{ "COLOR11",    0xDFF196 },
	{ "COLOR12",    0xDFF198 },
	{ "COLOR13",    0xDFF19A },
	{ "COLOR14",    0xDFF19C },
	{ "COLOR15",    0xDFF19E },
	{ "COLOR16",    0xDFF1A0 },
	{ "COLOR17",    0xDFF1A2 },
	{ "COLOR18",    0xDFF1A4 },
	{ "COLOR19",    0xDFF1A6 },
	{ "COLOR20",    0xDFF1A8 },
	{ "COLOR21",    0xDFF1AA },
	{ "COLOR22",    0xDFF1AC },
	{ "COLOR23",    0xDFF1AE },
	{ "COLOR24",    0xDFF1B0 },
	{ "COLOR25",    0xDFF1B2 },
	{ "COLOR26",    0xDFF1B4 },
	{ "COLOR27",    0xDFF1B6 },
	{ "COLOR28",    0xDFF1B8 },
	{ "COLOR29",    0xDFF1BA },
	{ "COLOR30",    0xDFF1BC },
	{ "COLOR31",    0xDFF1BE },
	{ "HTOTAL",     0xDFF1C0 }, /* Ab hier nur ECS-Register */
	{ "HSSTOP",     0xDFF1C2 },
	{ "HBSTRT",     0xDFF1C4 },
	{ "HBSTOP",     0xDFF1C6 },
	{ "VTOTAL",     0xDFF1C8 },
	{ "VSSTOP",     0xDFF1CA },
	{ "VBSTRT",     0xDFF1CC },
	{ "VBSTOP",     0xDFF1CE },
	{ "SPRHSTRT",   0xDFF1D0 },
	{ "SPRHSTOP",   0xDFF1D2 },
	{ "BPLHSTRT",   0xDFF1D4 },
	{ "BPLHSTOP",   0xDFF1D6 },
	{ "HHPOSW",     0xDFF1D8 },
	{ "HHPOSR",     0xDFF1DA },
	{ "BEAMCON0",   0xDFF1DC },
	{ "HSSTRT",     0xDFF1DE },
	{ "VSSTRT",     0xDFF1E0 },
	{ "HCENTER",    0xDFF1E2 },
	{ "DIWHIGH",    0xDFF1E4 },
	{ "BPLHMOD",    0xDFF1E6 },
	{ "SPRHPTH",    0xDFF1E8 },
	{ "SPRHPTL",    0xDFF1EA },
	{ "BPLHPTH",    0xDFF1EC },
	{ "BPLHPTL",    0xDFF1EE },
	{ "FMODE",      0xDFF1FE }
};


extern UBYTE
  **SymbolName,
    StdName[STDNAMELENGTH];

extern void
    InsertSymbol(UBYTE *, ULONG value),
    InsertCodeAdr(ULONG);

extern UWORD
   *buffer,
   *memtype,
   *DRelocBuffer;

extern ULONG
    PASS,
    prgstart,
    prgende,
    prgcount,
    pflags,
    basesec,
    SymbolCount,
   *SymbolValue,
    LabelMax,
   *LabelAdr,
   *LabelAdr2,
    labcount,
    relocount,
    relocmax,
   *RelocAdr,
   *RelocVal,
   *RelocOff,
   *RelocMod,
   *RelocBuffer,
    RelocNumber,
    nextreloc,
  **modulstrt,
   *moduloffs,
   *modultab,
   *modultype,
    modulcount,
    modulcnt,
    LastModul,
    XRefCount,
    LabX_len,
   *XRefListe;

extern FILE
    *sourcefile,
    *targetfile,
    *binfile;

void chkabort(void);

 

void *GetPMem(ULONG len)
{
void *ptr=0;

	if (len)
	{
		if (!(ptr = AllocTaskPooled(len)))
			ExitPrg("Not enough memory (%lu Bytes) !\n",len);
		/* printf("Allo: %08X  %8ld\n",ptr,len); */

		bzero(ptr, len);
	}
	return(ptr);
}

ULONG FileLength(UBYTE *name)
{
#if 0
	LONG len;
	FILE *file;
	if (name) {
		if (!(file = fopen(name,"r")))
			ExitPrg("Can't open %s\n",name);
		if (fseek(file,0,SEEK_END))
			ExitPrg("seek error (%s)\n",name);
		if ((len = ftell(file)) == -1L)
			ExitPrg("ftell error (%s)\n",name);
		fclose(file);
	}
	else printf("FileLength: Got no Name!\n");
#else
	ULONG len = 0;

	if (name)
	{
		BPTR lock = Lock(name, ACCESS_READ);

		if (lock)
		{
			struct FileInfoBlock fib;

			if (Examine(lock, &fib))
			{
				len = fib.fib_Size;
			}
			else
			{
				ExitPrg("Examine() error (%s)\n",name);
			}

			UnLock(lock);
		}
		else
		{
			ExitPrg("Can't lock %s\n",name);
		}
	}
	else
	{
		printf("FileLength: Got no Name!\n");
	}
#endif
	return ((ULONG)len);
}
void *GetNewVarBuffer(void *p,ULONG size)
{
	UBYTE *np;
	np = AllocTaskPooled(size * 8);

	if (!np)
	{
		ExitPrg("Not enough memory (%lu Bytes) !\n",size * 8);
	}

	CopyMem(p, np, size * 4);
	bzero(np + size * 4, size * 4);
	FreeTaskPooled(p,size*4);
	return(np);
}
#ifdef __SASC
int _abort(void)
{
	fflush(stdout);
	ExitPrg("***User-Break\n");
	return 1;
}
#endif

ULONG ReadSymbol(FILE *file,ULONG *val,UBYTE *type)
{
	ULONG length,dummy;
	if ((fread(&length,4,1,file)) != 1) ExitPrg("ReadSymbol error (1)\n");
	if (!length) return(0);
	if (type) {
		*type   = (length>>24);
		length &= 0x00FFFFFF;
	}
	length*=4;
	if (length >= STDNAMELENGTH) dummy=STDNAMELENGTH-1;
	else dummy=length;
	if ((fread(StdName,1,dummy,file)) != dummy) ExitPrg("ReadSymbol error (2)\n");
	StdName[dummy] = 0;
	if (length > dummy) fseek(file,length-dummy,SEEK_CUR);
	if (val)
		if ((fread(val,4,1,file)) != 1) ExitPrg("ReadSymbol error (3)\n");
	return(dummy);
}
void InsertReloc(ULONG adr,ULONG value,LONG offs,ULONG mod)
/*
   adr     Adresse, auf der reloziert wird
   value   Inhalt der Adresse (stellt auch eine Adresse dar)
*/
{
ULONG l=0,m,r=relocount;

	/* Dieser Fall tritt sehr haeufig auf */
	if (adr > RelocAdr[relocount-1] && relocount) {
			RelocAdr[relocount]   = adr;
			RelocVal[relocount]   = value;
			RelocOff[relocount]   = offs;
			RelocMod[relocount++] = mod;
	}
	else {
		/* Binaeres Suchen von adr */
		while (l<r) {
			m=(l+r)/2;
			if (RelocAdr[m]<adr) l=m+1;
			else                 r=m;
		}
		if (RelocAdr[r]!=adr || r==relocount) {
			lmovmem(&RelocAdr[r],&RelocAdr[r+1],relocount-r);
			lmovmem(&RelocOff[r],&RelocOff[r+1],relocount-r);
			lmovmem(&RelocVal[r],&RelocVal[r+1],relocount-r);
			lmovmem(&RelocMod[r],&RelocMod[r+1],relocount-r);
			RelocAdr[r] = adr;
			RelocOff[r] = offs;
			RelocVal[r] = value;
			RelocMod[r] = mod;
			relocount++;
		}
	}
	if (relocount == relocmax) {
		RelocAdr = GetNewVarBuffer(RelocAdr,relocmax);
		RelocVal = GetNewVarBuffer(RelocVal,relocmax);
		RelocOff = GetNewVarBuffer(RelocOff,relocmax);
		RelocMod = GetNewVarBuffer(RelocMod,relocmax);
		relocmax *= 2;
	}

}
void InsertLabel(LONG adr)
{
ULONG l=0,m,r=labcount;

	if (PASS == 0) return;

	/* Dieser Fall tritt sehr haeufig auf */
	if (adr > (LONG)LabelAdr[labcount-1] && labcount) {
		LabelAdr[labcount++] = adr;
	}
	else {
		/* Binaeres Suchen von adr */
		while (l<r) {
			m=(l+r)/2;
			if ((LONG)LabelAdr[m]<adr) l=m+1;
			else                         r=m;
		}
		if (LabelAdr[r]!=adr || r==labcount) {
			lmovmem(&LabelAdr[r],&LabelAdr[r+1],labcount-r);
			LabelAdr[r] = adr;
			labcount++;
		}
	}
	if (labcount == LabelMax) {
		LabelAdr  = GetNewVarBuffer(LabelAdr,LabelMax);
		LabelMax *= 2;
	}
}
void InsertXref(ULONG adr)
{
ULONG  l=0,m,r=XRefCount;

	if (PASS == 0) return;

	/* Binaeres Suchen von adr */
	while (l<r) {
		m=(l+r)/2;
		if (XRefListe[m]<adr) l=m+1;
		else                  r=m;
	}
	if (XRefListe[r]!=adr || r==XRefCount) {
		lmovmem(&XRefListe[r],&XRefListe[r+1],XRefCount-r);
		XRefListe[r]   = adr;
		XRefCount++;
	}

	if (XRefCount == LabX_len) {
		XRefListe   = GetNewVarBuffer(XRefListe,LabX_len);
		LabX_len *= 2;
	}
}

extern UWORD opcstart[16];
extern UWORD opccount[16];
extern UWORD SIZEOF_RESULT;
extern ULONG ADRCOUNT;
void InitOpcode(void)
{
UWORD i;

	SIZEOF_RESULT=sizeof(result);
	ADRCOUNT=sizeof(x_adrs)/sizeof(struct x_adr);
	for(i=0;i<(sizeof(result))/sizeof(UWORD)-1;i++) {
		if (opccount[result[i]>>12]==0) opcstart[result[i]>>12]=i;
		opccount[result[i]>>12]++;
	}

	if (sizeof(result)!=sizeof(sourceadr))
		ExitPrg("sizeof(result) != sizeof(sourceadr)");
	if (sizeof(result)!=sizeof(destadr))
		ExitPrg("sizeof(result) != sizeof(destadr)");
	if (sizeof(result)!=sizeof(maske))
		ExitPrg("sizeof(result) != sizeof(maske)");
	if (sizeof(result)/sizeof(UWORD)!=sizeof(flags)/sizeof(UBYTE))
		ExitPrg("sizeof(result) != sizeof(flags)");

}
int GetSymbol(ULONG adr)
{
ULONG i;

	// printf("GETSYMBOL(%08X)\n",adr);

	for(i=0;i<SymbolCount;i++) {
		if (SymbolValue[i] == adr) {
			adrcat(SymbolName[i]);
			return(-1);
		}
	}
	return(0);
}

void GetLabel(LONG adr,UWORD adrmode)
{
	ULONG dummy=-1;
	TEXT  buf[20];
	ULONG l=0,m = m,r=labcount,r2;

	/* Search for an entry in LabelAdr */
	while (l<r) {
		m=(l+r)/2;
		if ((LONG)LabelAdr[m]<adr) l=m+1;
		else                       r=m;
	}
	if (LabelAdr[r]!=adr) {
		fprintf(stderr,"ADR=%08x not found! (mode=%d) relocount=%ld nextreloc=%ld\n",(unsigned int)adr,adrmode,relocount,nextreloc);
		fprintf(stderr,"LabelAdr[l=%lu]=%08x\n",l,(unsigned int)LabelAdr[l]);
		fprintf(stderr,"LabelAdr[m=%lu]=%08x\n",m,(unsigned int)LabelAdr[m]);
		fprintf(stderr,"LabelAdr[r=%lu]=%08x\n\n",r,(unsigned int)LabelAdr[r]);
		adrcat("LAB_");
		adrcat(itohex(adr,8));
		return;
	}

	/* to avoid several label at the same address */
	r2=r;
	while(r && (LabelAdr2[r]==LabelAdr2[r-1])) r--;

	/* Pass 2 */
	if (adrmode==9999) {
		if (LabelAdr2[r] == moduloffs[RelocMod[nextreloc]]) {
			if (!GetSymbol(LabelAdr[r2])) {
				adrcat("SECSTRT_");
				adrcat(itoa(RelocMod[nextreloc]));
			}
			if ((dummy=RelocOff[nextreloc])) {
				if ((LONG)RelocOff[nextreloc] > 0) adrcat("+");
				adrcat(itoa(RelocOff[nextreloc]));
			}
			else if ((dummy = LabelAdr[r2]-LabelAdr2[r])) {
				adrcat("+");
				adrcat(itoa(dummy));
			}
		} else {
			if (!GetSymbol(LabelAdr[r2])) {
				sprintf(buf,"LAB_%04lX",r);
				adrcat(buf);
			}
			if ((dummy = LabelAdr[r2]-LabelAdr2[r])) {
				adrcat("+");
				adrcat(itoa(dummy));
			}
		}
	} else if (LabelAdr2[r] == moduloffs[modulcnt] && adrmode!=5) {
		if (!GetSymbol(LabelAdr[r2])) {
			adrcat("SECSTRT_");
			adrcat(itoa(modulcnt));
		}
		if (adr > (long)moduloffs[modulcnt]) {
			adrcat("+");
			adrcat(itoa(adr-moduloffs[modulcnt]));
		}
		else if (adr < (long)moduloffs[modulcnt])
			adrcat(itoa(adr-moduloffs[modulcnt]));
	} else {
		if (!GetSymbol(LabelAdr[r2])) {
			if (adrmode==5 && LabelAdr2[r2]==moduloffs[basesec]) {
				adrcat("SECSTRT_");
				adrcat(itoa(basesec));
			}
			else {
				sprintf(buf,"LAB_%04lX",r);
				adrcat(buf);
			}
		}
		if ((dummy = LabelAdr[r2]-LabelAdr2[r])) {
			adrcat("+");
			adrcat(itoa(dummy));
		}
	}
}
void GetExtName(ULONG index)
{
register ULONG xref;
ULONG  l=0,m,r=ADRCOUNT;

	xref = XRefListe[index];
	if (xref >= 0xDC0000 && xref<=0xDCFFFF) xref&=0xDC00FC;

	/* Binaere Suche nach Eintrag */
	while (l<r) {
		m=(l+r)/2;
		if (x_adrs[m].adr<xref) l=m+1;
		else                    r=m;
	}
	if (x_adrs[r].adr!=xref) {
		adrcat("EXT_");
		adrcat(itohex(index,4));
	}
	else
		adrcat(&x_adrs[r].name[0]);
}
void GetXref(ULONG adr)
{
ULONG l=0,m,r=XRefCount;

	/* Vorhandenen Eintrag in XRefListe suchen */
	while (l<r) {
		m=(l+r)/2;
		if (XRefListe[m]<adr) l=m+1;
		else                  r=m;
	}
	if (XRefListe[r]!=adr) {
		fprintf(stderr,"XRef ADR=%08x not found!\n", (unsigned int)adr);
		adrcat("EXT_");
		adrcat(itohex(adr,8));
	}
	else GetExtName(r);
}
void ExamineHunks(void)
{
	TEXT   modulname[STDNAMELENGTH];
	UBYTE  type;
	ULONG  i,dummy,offset,offs,value;
	ULONG  relocnt,relocnt1;
	UWORD  nextmodul=0,out_of_range=0,DREL32BUF[2];
	ULONG  modullen=0,hunk,relomod;
	ULONG  OVL_Size,OVL_Level,OVL_Data[8];


	modulname[0]=0;

	for(offs=prgstart,i=0;i<modulcount;i++) {
		memtype[i]   = (modultab[i]>>30);     /* PUBLIC,CHIP,FAST,EXTENSION */
		/* calculate offsets for relocation */
		modultab[i] *= 4;
		moduloffs[i] = offs;
		offs += modultab[i];

		/* get memory for the modules */
		modulstrt[i] = GetPMem(modultab[i]);
	}

	/* read modules and relocate */
	for(i=0;i<modulcount;) {

		/* sort of modul (Code,Data,...) */
		if ((fread(&hunk,4,1,sourcefile)) != 1) break;

		hunk   &= 0x0000ffff;

		switch (hunk) {
			case 0x03E9: /* CODE */
			case 0x03EA: /* DATA */
			case 0x03EB: /* BSS  */
					i+=nextmodul;
					nextmodul=1;

					if (memtype[i] == 3) fread(&dummy,4,1,sourcefile); /* Aufwaertskompatibel */

					modultype[i] = hunk;
					fread(&modullen,4,1,sourcefile); /* length of module */

					/* Evtl. Overlay-Hunks */
					if (i > LastModul) {
						printf("i > LastModul\n");
						/* Offsets fuer Relokation errechnen */
						modultab[i]  = modullen*4;
						moduloffs[i] = offs;
						offs += modultab[i];
						/* Speicher fuer Module beschaffen */
						modulstrt[i] = GetPMem(modultab[i]);
					}

					if (hunk != 0x03EB)      /* Nur bei Code und Data */
						fread(modulstrt[i],4,modullen,sourcefile); /* Langwoerter in Speicher */

					if (pflags&SHOW_RELOCINFO) {
						printf("\n    Module %d : %s ,%-6s",(int)i,modname[modultype[i]-0x03E9],memtypename[memtype[i]]);
						if (modulname[0]) {
							printf(" ,Name='%s'",modulname);
							modulname[0]=0;
						}
						if (modultype[i] == 0x03EB)
							printf(" ,%ld Bytes.\n",modultab[i]);
						else {
							printf(" ,%ld Bytes",modullen*4);
							if (modultab[i]-modullen*4)
								printf(" (+ %ld BSS).\n",modultab[i]-modullen*4);
							else
								printf(".\n");
						}
					}
				break;
			case 0x03F8: /* HUNK_DREL16 */
			case 0x03F9: /* HUNK_DREL8  */
			case 0x03ED: /* HUNK_RELOC16 */
			case 0x03EE: /* HUNK_RELOC8  */
					relocnt1 = 0;
					do {
						/* read number of reloctions */
						if ((fread(&relocnt,4,1,sourcefile)) != 1) break;
						relocnt1 += relocnt;
						if (relocnt) fseek(sourcefile,(relocnt+1)*4,SEEK_CUR);
					} while (relocnt);
					if (pflags&SHOW_RELOCINFO)
						printf("      Hunk_(D)Reloc16/8: %ld entries\n",relocnt1);
				break;
			case 0x03F7: /* HUNK_DREL32 (V37+) */
			case 0x03FC: /* HUNK_RELOC32SHORT (V39+) */
					if (pflags&SHOW_RELOCINFO) {
						if (hunk==0x03F7) printf("      Hunk_DRel32: ");
						if (hunk==0x03FC) printf("      Hunk_Reloc32Short: ");
					}
					relocnt1 = 0;
					do {
						/* read number of relocations */
						if ((fread(DREL32BUF,sizeof(DREL32BUF),1,sourcefile)) != 1) break;
						if (!(relocnt = DREL32BUF[0])) break;
						relocnt1 += relocnt;

						/* Bezugsmodul einlesen */
						relomod = DREL32BUF[1];
						if (relomod > LastModul)
							ExitPrg("Relocation: Bad Modul (%ld)\n",relomod);

						/* Relokation durchfuehren */
						RelocNumber  = relocnt;
						DRelocBuffer = GetPMem(RelocNumber*sizeof(UWORD));
						fread(DRelocBuffer,sizeof(UWORD),RelocNumber,sourcefile);
						while (relocnt--) {
							offset = DRelocBuffer[relocnt];
							if ((long)offset<0 || offset>(modultab[i]-4))
								ExitPrg("Relocation: Bad offset (0 <= (offset=%ld) <= %ld)\n",offset,modultab[i]-4);
							dummy = *((long *)((ULONG)modulstrt[i]+offset));
							if ((long)dummy<0L || dummy>=modultab[relomod]) out_of_range=1;
							dummy += (long)moduloffs[relomod];
							*((ULONG *)((ULONG)modulstrt[i]+offset)) = dummy;

							if (out_of_range) { /* HUNK-Uebergreifende Labels */
/* printf("out_of_range In Hunk %ld  To Hunk %ld  $%08X - $%08X  $%08X\n",i,relomod,moduloffs[relomod],moduloffs[relomod]+modultab[relomod],dummy); */
								InsertReloc(moduloffs[i]+offset,moduloffs[relomod],dummy-moduloffs[relomod],relomod);
								InsertLabel(moduloffs[relomod]);
								out_of_range=0;
							}
							else {
								InsertReloc(moduloffs[i]+offset,dummy,0L,relomod);
								InsertLabel(dummy);
							}

						}
						FreeTaskPooled(DRelocBuffer,RelocNumber*2);
						DRelocBuffer = 0;
					} while (1);
					if (pflags&SHOW_RELOCINFO)
						printf("%ld entries\n",relocnt1);
				break;
			case 0x03EC: /* HUNK_RELOC32 */
					if (pflags&SHOW_RELOCINFO) {
						if (hunk==0x03EC) printf("      Hunk_Reloc32: ");
					}
					relocnt1 = 0;
					do {
						/* read number of relocations */
						if ((fread(&relocnt,4,1,sourcefile)) != 1) break;
						if (!relocnt) break;
						relocnt1 += relocnt;

						/* Bezugsmodul einlesen */
						if ((fread(&relomod,4,1,sourcefile)) != 1) break;
						if (relomod > LastModul)
							ExitPrg("Relocation: Bad Modul (%d)\n",relomod);

						/* Relokation durchfuehren */
						RelocNumber = relocnt;
						RelocBuffer = GetPMem(RelocNumber*4);
						fread(RelocBuffer,4,RelocNumber,sourcefile);
						while (relocnt--) {
							offset = RelocBuffer[relocnt];
							if ((long)offset<0 || offset>(modultab[i]-4))
								ExitPrg("Relocation: Bad offset (0 <= (offset=%ld) <= %ld)\n",offset,modultab[i]-4);
							dummy = *((long *)((ULONG)modulstrt[i]+offset));
							if ((long)dummy<0L || dummy>=modultab[relomod]) out_of_range=1;
							dummy += (long)moduloffs[relomod];
							*((ULONG *)((ULONG)modulstrt[i]+offset)) = dummy;

							if (out_of_range) { /* HUNK-Uebergreifende Labels */
/* printf("out_of_range In Hunk %ld  To Hunk %ld  $%08X - $%08X  $%08X\n",i,relomod,moduloffs[relomod],moduloffs[relomod]+modultab[relomod],dummy); */
								InsertReloc(moduloffs[i]+offset,moduloffs[relomod],dummy-moduloffs[relomod],relomod);
								InsertLabel(moduloffs[relomod]);
								out_of_range=0;
							}
							else {
								InsertReloc(moduloffs[i]+offset,dummy,0L,relomod);
								InsertLabel(dummy);
							}

						}
						FreeTaskPooled(RelocBuffer,RelocNumber*4);
						RelocBuffer = 0;
					} while (1);
					if (pflags&SHOW_RELOCINFO)
						printf("%ld entries\n",relocnt1);
				break;
			case 0x03F5: /* HUNK_OVERLAY */
					fread(&OVL_Size,4,1,sourcefile);
					fread(&OVL_Level,4,1,sourcefile);
					fread(&dummy,4,1,sourcefile);
					fseek (sourcefile, -4, SEEK_CUR);
					if (dummy == 0) {
						OVL_Level -= 2;
						OVL_Size = (OVL_Size-OVL_Level+1)/8;
						fseek(sourcefile,(OVL_Level+1)*4,SEEK_CUR);
					}
					else
						OVL_Size = OVL_Size/8;
					if (pflags&SHOW_RELOCINFO)
						printf("\n    Hunk_Overlay: %ld Level, %ld Entries\n",OVL_Level,OVL_Size);
					while (OVL_Size--) {
						fread(&OVL_Data,4,8,sourcefile);
						if (pflags&SHOW_RELOCINFO) {
							printf("      SeekOffset: $%08lx\n",OVL_Data[0]);
							printf("      Dummy1    : %ld\n",OVL_Data[1]);
							printf("      Dummy2    : %ld\n",OVL_Data[2]);
							printf("      Level     : %ld\n",OVL_Data[3]);
							printf("      Ordinate  : %ld\n",OVL_Data[4]);
							printf("      FirstHunk : %ld\n",OVL_Data[5]);
							printf("      SymbolHunk: %ld\n",OVL_Data[6]);
							printf("      SymbolOffX: %08lx\n\n",OVL_Data[7]);
						}
					}
				break;
			case 0x03F2: /* HUNK_END   */
			case 0x03F6: /* HUNK_BREAK */
					i+=nextmodul;
					nextmodul=0;
				break;
			case 0x03E8: /* HUNK_NAME */
					ReadSymbol(sourcefile,0,0);
					strcpy(modulname,StdName);
				break;
			case 0x03F1: /* HUNK_DEBUG */
					if (pflags&SHOW_RELOCINFO) printf("      hunk_debug (skipped).\n");
					fread(&dummy,4,1,sourcefile);
					fseek(sourcefile,dummy*4,SEEK_CUR);
				break;
			case 0x03F0: /* HUNK_SYMBOL */
					if (pflags&SHOW_RELOCINFO) printf("      hunk_symbol:\n");
					while ((dummy=ReadSymbol(sourcefile,&value,0))) {
						value += (moduloffs[i]);
						if (pflags&SHOW_RELOCINFO) printf("        %s = %08x\n",StdName, (unsigned int)value);
						InsertSymbol(StdName, value);
						InsertLabel(value);
					}
				break;
			case 0x03EF: /* HUNK_EXT */
					if (pflags&SHOW_RELOCINFO) printf("      hunk_ext:\n");
					do {
						dummy=ReadSymbol(sourcefile,&value,&type);
						if (dummy) {
							switch (type) {
								ULONG ref;
								case 0: /* EXT_SYMB */
									if (pflags&SHOW_RELOCINFO) printf("        ext_symb:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s = %08lx\n",StdName,value);
									break;
								case 1: /* EXT_DEF  */
									if (pflags&SHOW_RELOCINFO) printf("        ext_def:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s = %08lx\n",StdName,value);
									break;
								case 2: /* EXT_ABS  */
									if (pflags&SHOW_RELOCINFO) printf("        ext_abs:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s = %08lx\n",StdName,value);
									break;
								case 3: /* EXT_RES  */
									if (pflags&SHOW_RELOCINFO) printf("        ext_res:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s = %08lx\n",StdName,value);
									break;
								case 130: /* EXT_COMMON */
									if (pflags&SHOW_RELOCINFO) printf("        ext_common:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, Size=%ld\n",StdName,value);
									fread(&value,4,1,sourcefile);
									fseek(sourcefile,value*4,SEEK_CUR);
									break;
								case 129: /* EXT_REF32 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_ref32:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								case 131: /* EXT_REF16 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_ref16:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								case 132: /* EXT_REF8 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_ref8:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								case 133: /* EXT_DEXT32 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_dext32:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								case 134: /* EXT_DEXT16 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_dext16:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								case 135: /* EXT_DEXT8 */
									if (pflags&SHOW_RELOCINFO) printf("        ext_dext8:\n");
									if (pflags&SHOW_RELOCINFO) printf("          %s, %ld reference(s)\n",StdName,value);
									while (value--) {
										fread(&ref,4,1,sourcefile);
										if (pflags&SHOW_RELOCINFO) printf("          %08lx\n",ref);
									}
									break;
								default:
									ExitPrg("Unknown HUNK_EXT sub-type=%d !\n",type);
									break;
							}
						}
					} while (dummy);
				break;
			case 0x03E7: /* HUNK_UNIT */
			case 0x03FA: /* HUNK_LIB     */
			case 0x03FB: /* HUNK_INDEX   */
			default:
					ExitPrg("Hunk...:%08x  NOT SUPPORTED.\n",hunk);
				break;

		} /* End of switch() */

	} /* read next modul */
	printf("\n");

	/* write data to file and release memory */
	for(i=0;i<modulcount;i++) {
		fwrite(modulstrt[i],1,modultab[i],binfile);
		FreeTaskPooled(modulstrt[i],modultab[i]);
	}
	FreeTaskPooled(modulstrt,modulcount*sizeof(ULONG *));
	modulstrt = 0;
}

STATIC void CreateSymbol(CONST_STRPTR name,ULONG symptr,ULONG refptr,ULONG module,ULONG number)
{
	TEXT symbol[32];

	strcpy(symbol,name);
	if (number) strcat(symbol,itoa(number));
	InsertReloc(refptr+prgstart,symptr,0L,module);
	InsertSymbol(symbol,symptr);
	InsertLabel(symptr);
}

void SearchRomTag(void)
{
	UBYTE name[80];
	ULONG number=0;
	ULONG ptr,refptr = refptr,functable,module=0;
	LONG  i,j,k,l;
	UBYTE flags,Type;
	UWORD relative=0;
	STATIC CONST CONST_STRPTR FuncName[]={"OPEN","CLOSE","EXPUNGE","RESERVED","BEGINIO","ABORTIO"};

	for(i=0;i<(LONG)(prgende-prgstart-24)/2;i++) {
		if (buffer[i] == 0x4AFC) {
			i+=1;
			ptr = *((ULONG *)&buffer[i]);

			/* OK. RomTag structure found */
			if ((ptr-prgstart) == (i-1)*2) {
				for(l=0;l<=LastModul;l++) {
					if (modultab[l]) {
						if (i*2 >= moduloffs[l] && i*2 < moduloffs[l]+modultab[l]) {
							module=l;
							break;
						}
					}
				}
				if (i==1) pflags |= ROMTAGatZERO;

				CreateSymbol("ROMTAG",ptr,i*2,module,number);
				i+=2;
				CreateSymbol("ENDSKIP",*((ULONG *)&buffer[i]),i*2,module,number);
				i+=2;
				flags=(UBYTE)(buffer[i++]>>8);
				Type =(UBYTE)(buffer[i++]>>8);
				ptr = *((ULONG *)&buffer[i]);
				stccpy(name,(char *)ptr,16);
				strupr(name);
				for(k=0;k<16;k++) if (!isalnum(name[k])) name[k]=0;
				if (Type==NT_LIBRARY) {
					strcat(name,"LIBNAME");
					CreateSymbol(name,ptr,i*2,module,0);
				}
				else if (Type==NT_DEVICE) {
					strcat(name,"DEVNAME");
					CreateSymbol(name,ptr,i*2,module,0);
				}
				else if (Type==NT_RESOURCE) {
					strcat(name,"RESNAME");
					CreateSymbol(name,ptr,i*2,module,0);
				}
				else {
					strcat(name,"NAME");
					CreateSymbol(name,ptr,i*2,module,number);
				}
				i+=2;

				CreateSymbol("IDSTRING",*((ULONG *)&buffer[i]),i*2,module,number);
				i+=2;
				ptr = *((ULONG *)&buffer[i]);
				CreateSymbol("INIT",ptr,i*2,module,number);
				i+=2;
				/* if RTF_AUTOINIT is set, INIT points to a special structure. */
				if (flags&0x80) {
					j=(ptr-prgstart)/2;
					ptr=((ULONG *)&buffer[j])[3];
					if (ptr) {
						CreateSymbol("INITFUNCTION",ptr,(j+6)*2,module,number);
						InsertCodeAdr(ptr);
					}
					ptr=((ULONG *)&buffer[j])[2];
					if (ptr) {
						CreateSymbol("DATATABLE",ptr,(j+4)*2,module,number);
					}
					functable=((ULONG *)&buffer[j])[1];
					if (functable) {
						CreateSymbol("FUNCTABLE",functable,(j+2)*2,module,number);
						functable-=prgstart;
						j=functable/2;
						if (buffer[j] == 0xFFFF) relative=1;

						k=j+relative;
						l=0;
						if (Type == NT_DEVICE) l=6;
						if (Type == NT_LIBRARY) l=4;
						ptr=0;
						while (ptr != 0xFFFFFFFF) {
							if (relative==1) {
								if (buffer[k]==0xFFFF) ptr=0xFFFFFFFF;
								else ptr=functable+(WORD)buffer[k];
							}
							else {
								ptr=((ULONG *)&buffer[j])[k-j];
								refptr=j*2+(k-j)*4;
							}
							k++;
							if (ptr && (ptr != 0xFFFFFFFF)) {
								if (k-j > l) {
									strcpy(name,"LIBFUNC");
									if (number) strcat(name,itoa(number));
									strcat(name,"_");
									strcat(name,itoa(k-j-l-1));
								}
								else {
									strcpy(name,FuncName[k-j-1-relative]);
									if (number) strcat(name,itoa(number));
								}
								if (relative==0)
									InsertReloc(refptr+prgstart,ptr+prgstart,0L,module);
								InsertSymbol(name,ptr+prgstart);
								InsertCodeAdr(ptr+prgstart);
								InsertLabel(ptr+prgstart);
							}
						}
					}
				}
				else {
					InsertCodeAdr(ptr);
				}
				number ++;
			}
		}
	}
}
void WriteTarget(void *ptr,ULONG len)
{
	chkabort();
	if ((fwrite(ptr,1,len,targetfile)) != len)
		ExitPrg("Write Error !\n");
}
