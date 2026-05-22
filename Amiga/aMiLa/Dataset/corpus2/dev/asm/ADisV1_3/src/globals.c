/*
 * Change history
 * $Log:	globals.c,v $
 * Revision 3.0  93/09/24  17:54:00  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:55:57  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:54:00  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.15  93/07/01  11:39:52  Martin_Apel
 * Minor mod.: Prepared for tabs instead of spaces.
 * Minor mod.: Added 68030 opcodes to disable list
 * 
 * Revision 1.14  93/06/19  12:08:38  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.13  93/06/16  20:28:04  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.12  93/06/06  13:46:34  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.11  93/06/06  00:11:41  Martin_Apel
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.10  93/06/04  11:50:40  Martin_Apel
 * New feature: Added -ln option for generation of ascending label numbers
 * 
 * Revision 1.9  93/06/03  20:27:16  Martin_Apel
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.8  93/06/03  18:31:10  Martin_Apel
 * Minor mod.: Added hunk_end array
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C)
 * 
 */

#include <exec/types.h>
#include "defs.h"

static char rcsid [] = "$Id: globals.c,v 3.0 93/09/24 17:54:00 Martin_Apel Exp $";

unsigned short *code;
char opcode [20];
char src [200];
char dest [200];
char instruction [400];

unsigned long current_address;
unsigned long first_address;
unsigned long last_address;
unsigned long total_size;
unsigned long current_hunk;
unsigned char *flags;
long *hunk_start = NULL,
     *hunk_end = NULL,
     *hunk_offset = NULL;
long f_offset; 
short tabsize;

BOOL end_instr;

FILE *in = 0,
     *out = 0,
     *tmp_f = NULL;
char *in_buf = 0,
     *out_buf = 0;
char *input_filename = 0;
BOOL pass1,
     pass2,
     pass3;
BOOL detected_illegal;
BOOL warning_printed = FALSE;
BOOL single_file = TRUE;
int num_code_hunks = 0;
int num_data_hunks = 0;
int num_bss_hunks = 0;
int num_hunks;
BOOL ROMTagFound = FALSE;
/* pointer to format_line function: */
void (*format_line) (BOOL, BOOL) = format_line_spaces;

/* Variables for options */
char output_filename [200];        /* -o */
int buf_size = DEF_BUF_SIZE;       /* -b */

/* Try to resolve addressing used by many compilers in small mode. */
/* (Addressing relative to A4) */
BOOL try_small = TRUE;             /* -s */
long a4_offset = -1;
                                   
BOOL print_illegal_instr_address = FALSE;         /* -i */
BOOL mc68881 = FALSE,              /* -c8 */
     mc68020 = FALSE,              /* -c2 */
     ext_68020_modes = FALSE,      /* -ce */
     mc68030 = FALSE,              /* -c3 */
     mc68040 = FALSE;              /* -c4 */
BOOL disasm_quick = FALSE;         /* -q */
BOOL user_wants_single_file = FALSE,    /* -fs */
     user_wants_separate_files = FALSE; /* -fm */
BOOL add_file_offset = FALSE;           /* -a  */
BOOL ascending_label_numbers = FALSE;   /* -ln */
BOOL use_tabs = FALSE;                  /* -t */
#ifdef AMIGA
BOOL disasm_as_lib = FALSE;             /* -dl */
#endif

#ifdef DEBUG
BOOL verbose = TRUE;               /* -v */
#else
BOOL verbose = FALSE;
#endif

char *reg_names [] =
  {
  "D0",
  "D1",
  "D2",
  "D3",
  "D4",
  "D5",
  "D6",
  "D7",
  "A0",
  "A1",
  "A2",
  "A3",
  "A4",
  "A5",
  "A6",
  "SP",
  "PC",       /* Start at offset 17 */
  "FP0",
  "FP1",
  "FP2",
  "FP3",
  "FP4",
  "FP5",
  "FP6",
  "FP7"
  };

char *conditions [] =
  {
  "T",
  "F",
  "HI",
  "LS",
  "CC",
  "CS",
  "NE",
  "EQ",
  "VC",
  "VS",
  "PL",
  "MI",
  "GE",
  "LT",
  "GT",
  "LE"
  };

char *special_regs [] =
  {
  "SR",        /* 0 */
  "CCR",       /* 1 */
  "USP",       /* 2 */
  "SFC",       /* 3 */
  "DFC",       /* 4 */
  "CACR",      /* 5 */
  "VBR",       /* 6 */
  "CAAR",      /* 7 */
  "MSP",       /* 8 */
  "ISP",       /* 9 */
  "TC",        /* 10 */
  "ITT0",      /* 11 */
  "ITT1",      /* 12 */
  "DTT0",      /* 13 */
  "DTT1",      /* 14 */
  "MMUSR",     /* 15 */
  "URP",       /* 16 */
  "SRP",       /* 17 */
  "TT0",       /* 18 */
  "TT1",       /* 19 */
  "CRP"        /* 20 */
  };

/**********************************************************************/
/*      When the program is compiled for use on a 68020 system,       */
/*        68020 instructions disassembly can be switched off          */
/*                     via a command line switch.                     */
/*      Then those following instructions are marked as illegal       */
/**********************************************************************/

short mc68020_disabled [] =
  {
    3, /* CHK2, CMP2 */
   11, /* CHK2, CMP2 */
   19, /* CHK2, CMP2 */
   27, /* CALLM */
   43, /* CAS */
   51, /* CAS */
   56, /* MOVES */
   57, /* MOVES */
   58, /* MOVES */
   59, /* CAS */
  260, /* CHK.L */
  268, /* CHK.L */
  276, /* CHK.L */
  284, /* CHK.L */
  292, /* CHK.L */
  300, /* CHK.L */
  304, /* MUL .L */
  305, /* DIV .L */
  308, /* CHK.L */
  316, /* CHK.L */
  931, /* BFTST */
  935, /* BFEXTU */
  939, /* BFCHG */
  943, /* BFEXTS */
  947, /* BFCLR */
  951, /* BFFFO */
  955, /* BFSET */
  959, /* BFINS */
 1027, /* RTM */
 1028, /* UNPK */
 1032, /* PACK */
 1040, /* CAS2 */
 1041, /* CAS2 */
 1042, /* CAS2 */
 1045, /* TRAPcc */
 1049, /* BKPT */
 1051, /* EXTB.L */
    0
  };

short mc68881_disabled [] =
  {
  968, /* General fpu opcode */
  969, /* FScc */
  970, /* FBcc */
  971, /* FBcc */
  972, /* FSAVE */
  973, /* FRESTORE */
 1047, /* FDBcc */
 1048, /* FTRAPcc */
    0
  };

short mc68030_disabled [] =
  {
  960, /* MMU instructions */
  0
  };

short mc68040_disabled [] =
  {
  976, /* CPUSH, CINV */
  977, /* CPUSH, CINV */
  978, /* CPUSH, CINV */
  979, /* CPUSH, CINV */
  980, /* PFLUSH */
  981, /* PTEST */
  984, /* MOVE16 */
    0
  };
