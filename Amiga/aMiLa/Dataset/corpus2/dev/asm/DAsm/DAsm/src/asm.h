
/*
 *  ASM65.H
 *
 *  (c)Copyright 1988, Matthew Dillon, All Rights Reserved.
 *
 *  Structures and definitions
 */

#include <stdio.h>

#ifdef LATTICE
#include <stdlib.h>
#include <string.h>
#define ARGS(blah) blah
#define BMov(s,d,n) movmem(((char *)s),((char *)d),(int)n)
#define BSet(s,n,c) setmem(((char *)s),(unsigned)n,(int)c)
#define BZero(s,n)  setmem(((char *)s),(unsigned)n,0)
#define BCmp(s,d,n) memcmp(((char *)s),((char *)d),(int)n)

#else
#define ARGS(blah) ()
extern void *malloc();
extern char *strcpy();
extern char *strcat();
#endif

#ifdef UNIX
#define BMov(s,d,n) bcopy(s,d,n)
#define BSet(s,n,c) xbset(s,n,c)
#endif

#ifdef IBM
#define BMov(s,d,n) movmem(s,d,(int)n)
#define BSet(s,n,c) setmem(s,(int)n,(int)c)
#define BZero(s,n)  setmem(s,(int)n,0)

#endif

#ifdef IBM
typedef char	 ubyte;
typedef unsigned uword;
typedef long	 ulong;
typedef int	 void;
#else
typedef unsigned char ubyte;
typedef unsigned short uword;
typedef unsigned long ulong;
#endif

#define MNE	    struct _MNE
#define MACRO	    struct _MACRO
#define INCFILE     struct _INCFILE
#define REPLOOP     struct _REPLOOP
#define IFSTACK     struct _IFSTACK
#define SEGMENT     struct _SEGMENT
#define SYMBOL	    struct _SYMBOL
#define STRLIST     struct _STRLIST

#define DEFORGFILL  255
#define SHASHSIZE   1024
#define MHASHSIZE   1024
#define SHASHAND    0x03FF
#define MHASHAND    0x03FF
#define ALLOCSIZE   16384
#define MAXMACLEVEL 32
#define TAB	    9

#define OUTFORM1    0
#define OUTFORM2    1
#define OUTFORM3    2

#define AM_IMP		0	    /*	implied 	    */
#define AM_IMM8 	1	    /*	immediate 8  bits   */
#define AM_IMM16	2	    /*	immediate 16 bits   */
#define AM_BYTEADR	3	    /*	address 8 bits	    */
#define AM_BYTEADRX	4	    /*	address 16 bits     */
#define AM_BYTEADRY	5	    /*	relative 8 bits     */
#define AM_WORDADR	6	    /*	index x 0 bits	    */
#define AM_WORDADRX	7	    /*	index x 8 bits	    */
#define AM_WORDADRY	8	    /*	index x 16 bits     */
#define AM_REL		9	    /*	bit inst. special   */
#define AM_INDBYTEX	10	    /*	bit-bra inst. spec. */
#define AM_INDBYTEY	11	    /*	index y 0 bits	    */
#define AM_INDWORD	12	    /*	index y 8 bits	    */
#define AM_0X		13	    /*	index x 0 bits	    */
#define AM_0Y		14	    /*	index y 0 bits	    */
#define AM_BITMOD	15	    /*	ind addr 8 bits     */
#define AM_BITBRAMOD	16	    /*	ind addr 16 bits    */
#define NUMOC		17

#define AF_IMP		(1L << 0 )
#define AF_IMM8 	(1L << 1 )
#define AF_IMM16	(1L << 2 )
#define AF_BYTEADR	(1L << 3 )
#define AF_BYTEADRX	(1L << 4 )
#define AF_BYTEADRY	(1L << 5 )
#define AF_WORDADR	(1L << 6 )
#define AF_WORDADRX	(1L << 7 )
#define AF_WORDADRY	(1L << 8 )
#define AF_REL		(1L << 9 )
#define AF_INDBYTEX	(1L << 10)
#define AF_INDBYTEY	(1L << 11)
#define AF_INDWORD	(1L << 12)
#define AF_0X		(1L << 13)
#define AF_0Y		(1L << 14)
#define AF_BITMOD	(1L << 15)
#define AF_BITBRAMOD	(1L << 16)

#define AM_SYMBOL	(NUMOC+0)
#define AM_EXPLIST	(NUMOC+1)

#define AM_BYTE 	AM_BYTEADR
#define AM_WORD 	AM_WORDADR
#define AM_LONG 	(NUMOC+2)
#define AM_BSS		(NUMOC+3)


STRLIST {
    STRLIST *next;
    ubyte   buf[4];
};

#define MF_IF		0x04
#define MF_MACRO	0x08
#define MF_MASK 	0x10	/*  has mask argument (byte)    */
#define MF_REL		0x20	/*  has rel. address (byte)     */
#define MF_IMOD 	0x40	/*  instruction byte mod.	*/
#define MF_ENDM 	0x80	/*  is v_endm			*/

MNE {
    MNE     *next;	    /*	hash		*/
    void    (*vect) ARGS((char *, MNE *));      /*  dispatch        */
    char    *name;	    /*	actual name	*/
    ubyte   flags;	    /*	special flags	*/
    ulong   okmask;
    uword   opcode[NUMOC];  /*	hex codes, byte or word (>xFF) opcodes  */
};

MACRO {
    MACRO   *next;
    void    (*vect)();
    ubyte   *name;
    ubyte   flags;
    STRLIST *strlist;
};

#define INF_MACRO   0x01

INCFILE {
    INCFILE *next;  /*	previously pushed context   */
    ubyte   *name;  /*	file name		    */
    FILE    *fi;    /*	file handle		    */
    ulong   lineno; /*	line number in file	    */
    ubyte   flags;  /*	flags (macro)               */

	/*  Only if Macro   */

    STRLIST *args;	/*  arguments to macro		*/
    STRLIST *strlist;	/*  current string list 	*/
    ulong   saveidx;	/*  save localindex		*/
};

#define RPF_UNKNOWN 0x01    /*	value unknown	    */

REPLOOP {
    REPLOOP *next;  /*	previously pushed context   */
    ulong   count;  /*	repeat count		    */
    ulong   seek;   /*	seek to top of repeat	    */
    ulong   lineno; /*	line number of line before  */
    INCFILE *file;  /*	which include file are we in*/
    ubyte   flags;
};

#define IFF_UNKNOWN 0x01    /*	value unknown	    */
#define IFF_BASE    0x04

IFSTACK {
    IFSTACK *next;  /*	previous IF		    */
    INCFILE *file;  /*	which include file are we in*/
    ubyte   flags;
    ubyte   true;   /*	1 if true, 0 if false			*/
    ubyte   acctrue;/*	accumulatively true (not incl this one) */
};

#define SF_UNKNOWN  0x01    /*	ORG unknown			*/
#define SF_REF	    0x04    /*	ORG referenced			*/
#define SF_BSS	    0x10    /*	uninitialized area (U flag)     */
#define SF_RORG     0x20    /*	relocatable origin active	*/

SEGMENT {
    SEGMENT *next;  /*	next segment in segment list	*/
    ubyte   *name;  /*	name of segment 		*/
    ubyte   flags;  /*	for ORG 			*/
    ubyte   rflags; /*	for RORG			*/
    ulong   org;    /*	current org			*/
    ulong   rorg;   /*	current rorg			*/
    ulong   initorg;
    ulong   initrorg;
    ubyte   initflags;
    ubyte   initrflags;
};

#define SYM_UNKNOWN 0x01    /*	value unknown		*/
#define SYM_REF     0x04    /*	referenced		*/
#define SYM_STRING  0x08    /*	result is a string	*/
#define SYM_SET     0x10    /*	SET instruction used	*/
#define SYM_MACRO   0x20    /*	symbol is a macro	*/
#define SYM_MASREF  0x40    /*	master reference	*/

SYMBOL {
    SYMBOL  *next;	/*  next symbol in hash list	    */
    ubyte   *name;	/*  symbol name or string if expr.  */
    ubyte   *string;	/*  if symbol is actually a string  */
    ubyte   flags;	/*  flags			    */
    ubyte   addrmode;	/*  addressing mode (expressions)   */
    ulong   value;	/*  current value		    */
    uword   namelen;	/*  name length 		    */
};

extern SYMBOL	*SHash[];
extern MNE	*MHash[];
extern INCFILE	*Incfile;
extern REPLOOP	*Reploop;
extern SEGMENT	*Seglist;
extern IFSTACK	*Ifstack;

extern SEGMENT	*Csegment;  /*	current segment */
extern ubyte	*Av[];
extern ubyte	Avbuf[];
extern uword	Adrbytes[];
extern uword	Cvt[];
extern uword	Opsize[];
extern MNE	Ops[];
extern uword	Mnext;	    /*	mnemonic extension  */
extern uword	Mlevel;

extern ubyte	Xtrace;
extern ubyte	Xdebug;
extern ubyte	MsbOrder;
extern ubyte	Outputformat;
extern ulong	Redo, Redo_why, Redo_eval;
extern ulong	Localindex;

extern ubyte	F_format;
extern ubyte	F_verbose;
extern char	*F_outfile;
extern char	*F_listfile;
extern char	*F_symfile;
extern char	*F_temppath;
extern FILE	*FI_listfile;
extern FILE	*FI_temp;
extern ubyte	Fisclear;
extern ulong	Plab, Pflags;
extern char	Inclevel;
extern char	ListMode;
extern ulong	Processor;

extern uword _fmode;
extern ulong  CheckSum;

extern SYMBOL	*eval ARGS((char *));
extern int	alphanum ARGS((int));
extern void	evaltop ARGS((void));
extern void	stackarg ARGS((long, int, ubyte *));
extern void	doop ARGS((void(*) ARGS((long,long,long,long)), int));
extern void	op_takelsb ARGS((long, long, long, long));
extern void	op_takemsb ARGS((long, long, long, long));
extern void	op_negate ARGS((long, long, long, long));
extern void	op_invert ARGS((long, long, long, long));
extern void	op_not	  ARGS((long, long, long, long));
extern void	op_mult   ARGS((long, long, long, long));
extern void	op_div	  ARGS((long, long, long, long));
extern void	op_mod	  ARGS((long, long, long, long));
extern void	op_question ARGS((long, long, long, long));
extern void	op_add	    ARGS((long, long, long, long));
extern void	op_sub	    ARGS((long, long, long, long));
extern void	op_shiftright ARGS((long, long, long, long));
extern void	op_shiftleft  ARGS((long, long, long, long));
extern void	op_greater    ARGS((long, long, long, long));
extern void	op_greatereq  ARGS((long, long, long, long));
extern void	op_smaller    ARGS((long, long, long, long));
extern void	op_smallereq  ARGS((long, long, long, long));
extern void	op_eqeq       ARGS((long, long, long, long));
extern void	op_noteq      ARGS((long, long, long, long));
extern void	op_andand     ARGS((long, long, long, long));
extern void	op_oror       ARGS((long, long, long, long));
extern void	op_xor	      ARGS((long, long, long, long));
extern void	op_and	      ARGS((long, long, long, long));
extern void	op_or	      ARGS((long, long, long, long));

extern ubyte	*pushchar   ARGS((ubyte *));
extern ubyte	*pushhex    ARGS((ubyte *));
extern ubyte	*pushoct    ARGS((ubyte *));
extern ubyte	*pushdec    ARGS((ubyte *));
extern ubyte	*pushbin    ARGS((ubyte *));
extern ubyte	*pushstr    ARGS((ubyte *));
extern ubyte	*pushsymbol ARGS((ubyte *));

extern void	v_mnemonic  ARGS((char *, MNE *));
extern void	v_processor ARGS((char *, MNE *));
extern void	v_trace     ARGS((char *, MNE *));
extern void	v_list	    ARGS((char *, MNE *));
extern void	v_include   ARGS((char *, MNE *));
extern void	v_seg	    ARGS((char *, MNE *));
extern void	v_hex	    ARGS((char *, MNE *));
extern void	v_err	    ARGS((char *, MNE *));
extern void	v_dc	    ARGS((char *, MNE *));
extern void	v_ds	    ARGS((char *, MNE *));
extern void	v_org	    ARGS((char *, MNE *));
extern void	v_rorg	    ARGS((char *, MNE *));
extern void	v_rend	    ARGS((char *, MNE *));
extern void	v_align     ARGS((char *, MNE *));
extern void	v_subroutine ARGS((char *, MNE *));
extern void	v_equ	    ARGS((char *, MNE *));
extern void	v_eqm	    ARGS((char *, MNE *));
extern void	v_echo	    ARGS((char *, MNE *));
extern void	v_set	    ARGS((char *, MNE *));

extern void	v_execmac   ARGS((char *, MACRO *));

extern void	v_end	    ARGS((char *, MNE *));
extern void	v_endm	    ARGS((char *, MNE *));
extern void	v_mexit     ARGS((char *, MNE *));

extern void	v_ifconst   ARGS((char *, MNE *));
extern void	v_ifnconst  ARGS((char *, MNE *));
extern void	v_if	    ARGS((char *, MNE *));
extern void	v_else	    ARGS((char *, MNE *));
extern void	v_endif     ARGS((char *, MNE *));
extern void	v_repeat    ARGS((char *, MNE *));
extern void	v_repend    ARGS((char *, MNE *));

extern int	gethexdig   ARGS((int));
extern void	generate    ARGS((void));
extern void	closegenerate ARGS((void));
extern void	genfill     ARGS((long, long, int));
extern void	pushif	    ARGS((int));

extern int	tabit	    ARGS((char *, char *));
extern ubyte	*sftos	    ARGS((long, int));
extern void	clearsegs   ARGS((void));
extern void	clearrefs   ARGS((void));
extern void	panic	    ARGS((char *));
extern void	findext     ARGS((ubyte *));
extern void	rmnode	    ARGS((ulong **, int));
extern void	parse	    ARGS((ubyte *));
extern MNE	*findmne    ARGS((ubyte *));

extern void	v_macro     ARGS((char *, MNE *));
extern void	addhashtable ARGS((MNE *));
extern void	pushinclude ARGS((char *));
extern void	asmerr	    ARGS((short, short));
extern ubyte	*zmalloc    ARGS((int));
extern ubyte	*permalloc  ARGS((int));
extern ubyte	*strlower   ARGS((ubyte *));

extern void	setspecial  ARGS((int, int));
extern SYMBOL	*findsymbol ARGS((ubyte *, int));
extern SYMBOL	*createsymbol ARGS((ubyte *, int));
extern void	programlabel	ARGS((void));
extern SYMBOL	*allocsymbol	ARGS((void));
extern void	freesymbol  ARGS((SYMBOL *));
extern void	freesymbollist ARGS((SYMBOL *));


