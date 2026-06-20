#ifndef _tlcs900d_h_included
#define _tlcs900d_h_included

//
//
//

#ifndef __GNUC__
#include <stdint.h>     // would require C99 compliant compiler
#else
#include <sys/types.h>    // ..but this is just fine for gcc

// Fix some C99 stuff..

#if !defined(uint8_t)
typedef unsigned char uint8_t;
#endif

#if !defined(uint16_t)
typedef unsigned short uint16_t;
#endif

#if !defined(uint32_t)
typedef unsigned int uint32_t;
#endif
#endif

#if !defined(int8_t)
typedef signed char int8_t;
#endif

#if !defined(int16_t)
typedef signed short int16_t;
#endif

#if !defined(int32_t)
typedef signed int int32_t;
#endif


//
//
//

#define NGD_VERSION "0.36"

//

#define OPS_LEN 80
#define MEM_LEN 80
#define MAX_CMD 80

struct tlcs900d {
  uint8_t *buffer;
  uint32_t pos;
  uint32_t base;
  int32_t len;
  int opt;        // Output type..
  char *opf;
  char ops[OPS_LEN];
  FILE *fh;
  int lines;
  int space;
};

/*
 *
 *
 */

uint8_t get8u( unsigned char * );
uint16_t get16u( unsigned char * );
uint32_t get24u( unsigned char * );
uint32_t get32u( unsigned char * );
int8_t get8( unsigned char * );
int16_t get16( unsigned char * );
int32_t get32( unsigned char * );

int getR( unsigned char * );
int getr( unsigned char * );
int getcc( unsigned char * );
int getzz( unsigned char * );
int getzzz( unsigned char * );
int getmem( unsigned char * );
int getz1( unsigned char * );
int getz4( unsigned char * );
int get3( unsigned char * );
int get4( unsigned char * );
int retmem( unsigned char *, char *, int );
char **getregs( int, int );


enum opcodes {
	LD=0,	LDW,  PUSH,	PUSHW,  POP,	POPW,   LDA,	  LDAR,
	EX,		MIRR, LDI,  LDIW,	  LDIR, LDIRW,	LDD,	  LDDW,
  LDDR, LDDRW,CPI,	CPIR,	  CPD,	CPDR, 	ADD,	  ADDW,
  ADC,	ADCW, SUB,	SUBW,   SBC,	SBCW,   CP,     CPW,
  INC,  INCW,	DEC,  DECW,	  NEG,  EXTZ,	  EXTS,	  DAA,
	PAA,	MUL,	MULS,	DIV,	  DIVS,	MULA,	  MINC1,  MINC2,
  MINC4,MDEC1,MDEC2,MDEC4,	AND,	ADNW,   OR,     ORW,
  XOR,  XORW,	CPL,  LDCF,	  STCF,	ANDCF,	ORCF,	  XORCF,
  RCF,	SCF,	CCF,	ZCF,	  BIT,	RES,	  SET,	  CHG,
  TSET,	BS1F, BS1B,	NOP,	  EI,		DI,		  SWI,	  HALT,
  LDC,	LDX,  LINK,	UNLK,	  LDF,  INCF,   DECF,	  SCC,
  RLC,	RRC,  RL,	  RR,		  SLA,  SRA,    SLL,    SRL,
	RLD,	RRD,  JP,	  JR,	    JRL,  CALL,   CALR,	  DJNZ,
  RET,	RETD, RETI,
  INVALID
};

enum maddressingmodes {
	ARI_XWA=0,ARI_XBC,ARI_XDE,ARI_XHL,ARI_XIX,ARI_XIY,ARI_XIZ,ARI_XSP,
	ARID_XWA,ARID_XBC,ARID_XDE,ARID_XHL,ARID_XIX,ARID_XIY,ARID_XIZ,ARID_XSP,
	ABS_B,ABS_W,ABS_L,
	ARI,
	ARI_PD,ARI_PI
};

enum output_types {
  OPT_1_0_0, OPT_1_1_0, OPT_1_1_1, OPT_1_1_2, OPT_1_2_0, OPT_1_3_0,
  OPT_2_1_2, OPT_2_0_0, OPT_1_n_1, OPT_1_n_1_1, OPT_1_n_1_2,
  OPT_1_n_2, OPT_1_n_1_4, OPT_1_4_0, OPT_1_1_1_1_1_1
};

//
//
//

extern char *opcode_names[];
extern char *R8_names[];
extern char *R16_names[];
extern char *R32_names[];
extern char *r8_names[];
extern char *r16_names[];
extern char *r32_names[];
extern char *cc_names[];
extern char *cr_names[];
extern char *addr_names[];

//
// Disassembly functions..
//

int decode_fixed( struct tlcs900d * );
int decode_B0_mem( struct tlcs900d * );
int decode_xx( struct tlcs900d * );
int decode_zz_r( struct tlcs900d * );
int decode_zz_R( struct tlcs900d * );
int decode_zz_mem( struct tlcs900d * );
int decode( struct tlcs900d * );
int checkrom( struct tlcs900d *, int );
int loadrom_and_init( char *, struct tlcs900d * );

#endif
