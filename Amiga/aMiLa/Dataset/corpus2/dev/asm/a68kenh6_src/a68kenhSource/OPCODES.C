/*------------------------------------------------------------------*/
/*								    */
/*			MC68000 Cross Assembler			    */
/*								    */
/*                Copyright 1985 by Brian R. Anderson		    */
/*								    */
/*          Opcode table and scan routine - April 16, 1991	    */
/*								    */
/*   This program may be copied for personal, non-commercial use    */
/*   only, provided that the above copyright notice is included	    */
/*   on all copies of the source code.  Copying for any other use   */
/*   without the consent of the author is prohibited.		    */
/*								    */
/*------------------------------------------------------------------*/
/*								    */
/*		Originally published (in Modula-2) in		    */
/*	    Dr. Dobb's Journal, April, May, and June 1986.	    */
/*								    */
/*	 AmigaDOS conversion copyright 1991 by Charlie Gibbs.	    */
/*								    */
/*------------------------------------------------------------------*/

#include "A68kdef.h"
#include "A68kglb.h"

static int optabsize = 0;	/* Size of opcode table */
static int oplimits['Z'-'A'+2];	/* Table limits by first letter */

/* Opcode table */

struct OpTab {
    char Mnem[8];	/* Instruction mnemonic */
    int  OpBits;	/* Op code bits */
    int  AMA;		/* Address mode bits */
    int  AMB;		/* More address mode bits */
    int  AMC;		/* More address mode bits */
};

static struct OpTab MnemTab[] = {
	"=",     0,      0xFFFF, Equ, 0,
	"ABCD",  0xC100, Rx911 | RegMem3 | Ry02, 0, 0,
	"ADD",   0xD000, OpM68D, EA05y, 0,
	"ADDA",  0xD000, OpM68A, EA05a, 0,
	"ADDI",  0x0600, 0, Size67 | EA05e | Exten, 0,
	"ADDQ",  0x5000, Data911, Size67 | EA05d, 0,
	"ADDX",  0xD100, Rx911 | RegMem3 | Ry02, Size67, 0,
	"AND",   0xC000, OpM68D, EA05x, 0,
	"ANDI",  0x0200, 0, Size67 | EA05e | Exten, 0,
	"ASL",   0xE100, CntR911, 0, 0,
	"ASR",   0xE000, CntR911, 0, 0,
	"BCC",   0x6400, Brnch, 0, 0,
	"BCHG",  0x0040, 0, EA05e | Exten | Bit811, 0,
	"BCLR",  0x0080, 0, EA05e | Exten | Bit811, 0,
	"BCS",   0x6500, Brnch, 0, 0,
	"BEQ",   0x6700, Brnch, 0, 0,
	"BFCHG",  0xEAC0, 0, EA05e | Size67, bf,
	"BFCLR",  0xECC0, 0, EA05e | Size67, bf,
	"BFEXTS", 0xEBC0, 0, EA05a, bf | destD,
	"BFEXTU", 0xE9C0, 0, EA05a, bf | destD,
	"BFFFO",  0xEDC0, 0, EA05a, bf | destD,
	"BFINS",  0xEFC0, OpM68X, EA05e, bf | srcD,
	"BFSET",  0xEEC0, 0, EA05e | Size67, bf,
	"BFTST",  0xE8C0, 0, EA05e | Size67, bf,
	"BGE",   0x6C00, Brnch, 0, 0,
	"BGT",   0x6E00, Brnch, 0, 0,
	"BHI",   0x6200, Brnch, 0, 0,
	"BHS",   0x6400, Brnch, 0, 0,
	"BLE",   0x6F00, Brnch, 0, 0,
	"BLO",   0x6500, Brnch, 0, 0,
	"BLS",   0x6300, Brnch, 0, 0,
	"BLT",   0x6D00, Brnch, 0, 0,
	"BMI",   0x6B00, Brnch, 0, 0,
	"BNE",   0x6600, Brnch, 0, 0,
	"BPL",   0x6A00, Brnch, 0, 0,
	"BRA",   0x6000, Brnch, 0, 0,
	"BSET",  0x00C0, 0, EA05e | Exten | Bit811, 0,
	"BSR",   0x6100, Brnch, 0, 0,
	"BSS",   0,      0xFFFF, BSS, 0,
	"BTST",  0x0000, 0, EA05c | Exten | Bit811, 0,
	"BVC",   0x6800, Brnch, 0, 0,
	"BVS",   0x6900, Brnch, 0, 0,
	"CAS",   0x08C0, 0, Exten, Oprnds3 | OpCAS,
	"CAS2",  0x08FC, 0, Exten, Oprnds3 | OpCAS2,
	"CHK",   0x4000, Rx911, EA05b, 0,
	"CHK2",  0x00C0, 0, Exten, Bounds,
	"CLR",   0x4200, 0, Size67 | EA05e, 0,
	"CMP",   0xB000, OpM68C, EA05a, 0,
	"CMP2",  0x00C0, 0, Exten, Bounds,
	"CMPA",  0xB000, OpM68A, EA05a, 0,
	"CMPI",  0x0C00, 0, Size67 | EA05e | Exten, 0,
	"CMPM",  CMPM,   Rx911 | Ry02, Size67, 0,
	"CNOP",  0,      0xFFFF, Cnop, 0,
	"CODE",  0,      0xFFFF, CSeg, 0,
	"CSEG",  0,      0xFFFF, CSeg, 0,
	"DATA",  0,      0xFFFF, DSeg, 0,
	"DBCC",  0x54C8, DecBr, 0, 0,
	"DBCS",  0x55C8, DecBr, 0, 0,
	"DBEQ",  0x57C8, DecBr, 0, 0,
	"DBF",   0x51C8, DecBr, 0, 0,
	"DBGE",  0x5CC8, DecBr, 0, 0,
	"DBGT",  0x5EC8, DecBr, 0, 0,
	"DBHI",  0x52C8, DecBr, 0, 0,
	"DBLE",  0x5FC8, DecBr, 0, 0,
	"DBLS",  0x53C8, DecBr, 0, 0,
	"DBLT",  0x5DC8, DecBr, 0, 0,
	"DBMI",  0x5BC8, DecBr, 0, 0,
	"DBNE",  0x56C8, DecBr, 0, 0,
	"DBPL",  0x5AC8, DecBr, 0, 0,
	"DBRA",  0x51C8, DecBr, 0, 0,
	"DBT",   0x50C8, DecBr, 0, 0,
	"DBVC",  0x58C8, DecBr, 0, 0,
	"DBVS",  0x59C8, DecBr, 0, 0,
	"DC",    0,      0xFFFF, DC, 0,
	"DCB",   0,      0xFFFF, DCB, 0,
	"DIVS",  0x81C0, Rx911, EA05b, DivMul | Signed,
	"DIVSL", 0x4C40, Rx911, EA05b, DivMul | DivL | Signed,
	"DIVU",  0x80C0, Rx911, EA05b, DivMul ,
	"DIVUL", 0x4C40, Rx911, EA05b, DivMul | DivL,
	"DS",    0,      0xFFFF, DS, 0,
	"DSEG",  0,      0xFFFF, DSeg, 0,
	"END",   0,      0xFFFF, End, 0,
	"ENDC",  0,      0xFFFF, EndC, 0,
	"ENDIF", 0,      0xFFFF, EndC, 0,
	"EOR",   0xB000, OpM68X, EA05e, 0,
	"EORI",  0x0A00, 0, Size67 | EA05e | Exten, 0,
	"EQU",   0,      0xFFFF, Equ, 0,
	"EQUR",  0,      0xFFFF, Equr, 0,
	"EVEN",  0,      0xFFFF, Even, 0,
	"EXG",   0xC100, OpM37, 0, 0,
	"EXT",   0x4800, OpM68S, 0, 0,
	"EXTB",  0x4800, OpM68S, 0, OpM68L,
	"FAR",   0,      0xFFFF, Far, 0,
	"IDNT",  0,      0xFFFF, Idnt, 0,
	"IFC",   0,      0xFFFF, IfC, 0,
	"IFD",   0,      0xFFFF, IfD, 0,
	"IFEQ",  0,      0xFFFF, IfEQ, 0,
	"IFGE",  0,      0xFFFF, IfGE, 0,
	"IFGT",  0,      0xFFFF, IfGT, 0,
	"IFLE",  0,      0xFFFF, IfLE, 0,
	"IFLT",  0,      0xFFFF, IfLT, 0,
	"IFNC",  0,      0xFFFF, IfNC, 0,
	"IFND",  0,      0xFFFF, IfND, 0,
	"IFNE",  0,      0xFFFF, IfNE, 0,
	"ILLEGAL", 0x4AFC, 0, 0, 0,
	"INCBIN",  0,    0xFFFF, Incbin, 0,
	"INCLUDE", 0,    0xFFFF, Include, 0,
	"JMP",   JMP,    0, EA05f, 0,
	"JSR",   JSR,    0, EA05f, 0,
	"LEA",   LEA,    Rx911, EA05f, 0,
	"LINK",  LINK,   Ry02, Exten, 0,
	"LIST",  0,      0xFFFF, DoList, 0,
	"LSL",   0xE308, CntR911, 0, 0,
	"LSR",   0xE208, CntR911, 0, 0,
	"MACRO", 0,      0xFFFF, Macro, 0,
	"MOVE",  0x0000, 0, Sz1213A | EA611, 0,
	"MOVEA", 0x0040, Rx911, Sz1213 | EA05a, 0,
	"MOVEC", MOVEC,  0, Exten, 0,
	"MOVEM", 0x4880, 0, Size6 | EA05z | Exten, 0,
	"MOVEP", 0x0008, OpM68R, Exten, 0,
	"MOVEQ", 0x7000, Data07, 0, 0,
	"MULS",  0xC1C0, Rx911, EA05b, DivMul | Mul | Signed,
	"MULU",  0xC0C0, Rx911, EA05b, DivMul | Mul,
	"NBCD",  0x4800, 0, EA05e, 0,
	"NEAR",  0,      0xFFFF, Near, 0,
	"NEG",   0x4400, 0, Size67 | EA05e, 0,
	"NEGX",  0x4000, 0, Size67 | EA05e, 0,
	"NOL",   0,      0xFFFF, NoList, 0,
	"NOLIST",0,      0xFFFF, NoList, 0,
	"NOP",   NOP,    0, 0, 0,
	"NOT",   0x4600, 0, Size67 | EA05e, 0,
	"OR",    0x8000, OpM68D, EA05x, 0,
	"ORG",   0,      0xFFFF, Org, 0,
	"ORI",   0x0000, 0, Size67 | EA05e | Exten, 0,
	"PACK",  0x8140, 0, Exten, Oprnds3 | DgtCvt,
	"PAGE",  0,      0xFFFF, Page, 0,
	"PEA",   PEA,    0, EA05f, 0,
	"PUBLIC",0,      0xFFFF, Public, 0,
	"REG",   0,      0xFFFF, Reg, 0,
	"RESET", 0x4E70, 0, 0, 0,
	"ROL",   0xE718, CntR911, 0, 0,
	"ROR",   0xE618, CntR911, 0, 0,
	"RORG",  0,      0xFFFF, Org, 0,
	"ROXL",  0xE510, CntR911, 0, 0,
	"ROXR",  0xE410, CntR911, 0, 0,
	"RTE",   0x4E73, 0, 0, 0,
	"RTR",   0x4E77, 0, 0, 0,
	"RTS",   0x4E75, 0, 0, 0,
	"SBCD",  0x8100, Rx911 | RegMem3 | Ry02, 0, 0,
	"SCC",   0x54C0, 0, EA05e, 0,
	"SCS",   0x55C0, 0, EA05e, 0,
	"SECTION", 0,    0xFFFF, Section, 0,
	"SEQ",   0x57C0, 0, EA05e, 0,
	"SET",   0,      0xFFFF, Set, 0,
	"SF",    0x51C0, 0, EA05e, 0,
	"SGE",   0x5CC0, 0, EA05e, 0,
	"SGT",   0x5EC0, 0, EA05e, 0,
	"SHI",   0x52C0, 0, EA05e, 0,
	"SLE",   0x5FC0, 0, EA05e, 0,
	"SLS",   0x53C0, 0, EA05e, 0,
	"SLT",   0x5DC0, 0, EA05e, 0,
	"SMI",   0x5BC0, 0, EA05e, 0,
	"SNE",   0x56C0, 0, EA05e, 0,
	"SPC",   0,      0xFFFF, Space, 0,
	"SPL",   0x5AC0, 0, EA05e, 0,
	"ST",    0x50C0, 0, EA05e, 0,
	"STOP",  STOP,   0, Exten, 0,
	"SUB",   0x9000, OpM68D, EA05y, 0,
	"SUBA",  0x9000, OpM68A, EA05a, 0,
	"SUBI",  0x0400, 0, Size67 | EA05e | Exten, 0,
	"SUBQ",  0x5100, Data911, Size67 | EA05d, 0,
	"SUBX",  0x9100, Rx911 | RegMem3 | Ry02, Size67, 0,
	"SVC",   0x58C0, 0, EA05e, 0,
	"SVS",   0x59C0, 0, EA05e, 0,
	"SWAP",  0x4840, Ry02, 0, 0,
	"TAS",   0x4AC0, 0, EA05e, 0,
	"TITLE", 0,      0xFFFF, Title, 0,
	"TRAP",  0x4E40, Data03, 0, 0,
	"TRAPV", 0x4E76, 0, 0, 0,
	"TST",   0x4A00, 0, Size67 | EA05e, 0,
	"TTL",   0,      0xFFFF, Title, 0,
	"UNLK",  UNLK,   Ry02, 0, 0,
	"UNPK",  0x8180, 0, Exten, Oprnds3 | DgtCvt,
	"XDEF",  0,      0xFFFF, Xdef, 0,
	"XREF",  0,      0xFFFF, Xref, 0,
	"",0,0,0,0};		/* End-of-table flag */



int Instructions (loc) int loc;
/* Looks up opcode and addressing mode bit patterns
   If the opcode corresponds to an executable instruction,
     returns TRUE with the following fields set up:
	Op       - operation code bits
	AdrModeA - addressing mode bits
	AdrModeB - more addressing mode bits
	Dir      - None
   If the opcode corresponds to a directive (AdrModeA in the table
     is 0xFFFF), returns TRUE with the following fields set up:
	Op       - 0
	AdrModeA - 0
	AdrModeB - 0
	Dir      - the appropriate directive value
   If not found, returns FALSE with all the above fields set to zero.

   NOTE: The binary search doesn't use strcmp because this function
    returns incorrect values under MS-DOS Lattice 2.12.		      */
{
    register char *i, *j;
    register int  lower, upper, mid;	/* Binary search controls */


    if (optabsize == 0) {	/* Determine size of opcode table. */
	while (MnemTab[optabsize].Mnem[0])
	    optabsize++;
	oplimits[0] = 0;
	oplimits['Z'-'A'+1] = optabsize;
	mid = 0;
	for (lower = 0; lower < optabsize; lower++) {
	    upper = (unsigned int) MnemTab[lower].Mnem[0] - 'A' + 1;
	    if (upper != mid) {
		if (upper > 0) {	/* Start of the next letter */
		    mid++;
		    while (mid < upper)
			oplimits[mid++] = lower;
		    oplimits[mid] = lower;
		}
	    }
	}
	mid++;
	while (mid < 'Z'-'A'+1) {
	    oplimits[mid++]=optabsize;	/* In case we didn't get to Z */
	}
    }
    mid = (unsigned int) OpCode[0] - 'A' + 1;
    if (mid < 0) {			/* This catches stuff like "=". */
	lower = 0;
	upper = oplimits[1];
    } else if (mid > 'Z'-'A'+1) {
	lower = upper = 0;		/* Reject this one. */
    } else {
	lower = oplimits[mid++];
	upper = oplimits[mid];
    }
    while (lower < upper) {
	mid = (lower + upper) / 2;	/* Search the opcode table. */
	for (i = OpCode, j = MnemTab[mid].Mnem; *i == *j; i++, j++)
	    if (*i == '\0')
		break;		/* Find the first non-match. */
	if (*i < *j)
	    upper = mid;	/* Search lower half of table. */
	else if (*i > *j)
	    lower = mid + 1;	/* Search upper half of table. */
	else if (MnemTab[mid].AMA != 0xFFFF) {	/* Found it. */
	    Op = MnemTab[mid].OpBits;	/* Executable instruction */
	    AdrModeA = MnemTab[mid].AMA;
	    AdrModeB = MnemTab[mid].AMB;
	    AdrModeC = MnemTab[mid].AMC;
	    Dir = None;
	    return (TRUE);
	} else {
	    Op = AdrModeA = AdrModeB = AdrModeC = 0;	/* Directive */
	    Dir = MnemTab[mid].AMB;
	    return (TRUE);
	}
    }
    Op = AdrModeA = AdrModeB = AdrModeC = Dir = 0;
    return (FALSE);			/* We didn't find it. */
}
