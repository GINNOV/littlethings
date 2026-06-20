/*
 * Change history
 * $Log:	defs.h,v $
 * Revision 3.0  93/09/24  17:54:36  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.4  93/07/18  22:57:05  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.3  93/07/11  21:40:10  Martin_Apel
 * Major mod.: Jump table support tested and changed
 * 
 * Revision 2.2  93/07/10  13:02:39  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.1  93/07/08  20:50:47  Martin_Apel
 * Minor mod.: Added print_flags for debugging purposes
 * 
 * Revision 2.0  93/07/01  11:55:04  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.30  93/07/01  11:46:54  Martin_Apel
 * Minor mod.: Prepared for tabs instead of spaces
 * 
 * Revision 1.29  93/06/19  12:12:20  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.28  93/06/16  20:31:52  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.27  93/06/06  13:48:45  Martin_Apel
 * Minor mod.: Added preliminary support for jump tables recognition
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.26  93/06/06  00:16:26  Martin_Apel
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.25  93/06/04  11:57:34  Martin_Apel
 * New feature: Added -ln option for generation of ascending label numbers
 * 
 * Revision 1.24  93/06/03  20:31:01  Martin_Apel
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.23  93/06/03  18:28:15  Martin_Apel
 * Minor mod.: Added new prototypes an variables for hunk-handling routines.
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C).
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#ifdef MCH_AMIGA
#ifndef AMIGA
#define AMIGA
#endif
#endif

/* $Id: defs.h,v 3.0 93/09/24 17:54:36 Martin_Apel Exp $ */

struct opcode_entry
  {
  int (*handler) (struct opcode_entry*);
                                  
  char *mnemonic;
  unsigned short param;           /* given to handler () */
  unsigned char modes;            /* addressing modes allowed for this 
                                     opcode */
  unsigned char submodes;         /* addressing submodes of mode 7 allowed
                                     for this opcode */
  unsigned short chain;           /* if another opcode is possible for */
                                  /* this bit pattern, this is the index */
                                  /* of another entry in opcode_table. */
                                  /* Otherwise it's zero */
  };

#define TRANSFER 0                /* The handler didn't handle this opcode */
                                  /* Transfer to next in chain */

/* Param values */
/* General */
#define MEM 9
#define REG 10
/* Bitfield instructions */
#define DATADEST 0
#define DATASRC  1
#define SINGLEOP 2
/* MOVE to or from SR, CCR */
#define TO_CCR   0
#define FROM_CCR 1
#define TO_SR    2
#define FROM_SR  3
/* Extended precision and BCD instructions */
#define NO_ADJ 0
#define ADJUST 1


/* Bit masks */
#define EA_MODE 0x038      /* Bits 5 - 3 */
#define EA_REG  0x007      /* Bits 2 - 0 */
#define REG2    0xe00      /* Bits 11 - 9 */
#define OP_MODE 0x1c0      /* Bits 8 - 6 */

/* Shift values */
#define MODE_SHIFT 3
#define REG2_SHIFT 9
#define OP_MODE_SHIFT 6

#define MODE_NUM(x) ((short)(((x) >> 3) & 0x7))
#define REG_NUM(x)  ((short)((x) & EA_REG))

#define USE_SIGN    TRUE
#define NO_SIGN     FALSE
#define USE_LABEL   TRUE
#define NO_LABEL    FALSE
#define USE_COMMENT TRUE
#define NO_COMMENT  FALSE

#define DEF_BUF_SIZE (10L * 1024L)

enum 
  {
  SR, CCR, USP, SFC, DFC, CACR, VBR, CAAR, MSP, ISP, TC, 
  ITT0, ITT1, DTT0, DTT1, MMUSR, URP, SRP, TT0, TT1, CRP
  };

/* Access types for reference table. */
#define NO_ACCESS   (UWORD)0x00     /* not referenced yet */
#define ACC_BYTE    (UWORD)0x01     /* referenced as bytewide data */
#define ACC_WORD    (UWORD)0x02
#define ACC_LONG    (UWORD)0x04
#define ACC_DOUBLE  (UWORD)0x08
#define ACC_EXTEND  (UWORD)0x10
#define ACC_CODE    (UWORD)0x20     /* referenced as code */
#define ACC_DATA    (UWORD)0x40     /* referenced as data, but size unknown */
#define ACC_UNKNOWN (UWORD)0x80     /* accessed but it's unknown, if it's code */
                                    /* or data */

#define OPCODE_COL 20               /* at which column opcode and params are */
#define PARAM_COL 35                /* placed */
#define COMMENT_COL 60

#define PC (short)16                /* index into reg_names array */


#define TMP_CODE               0x01
#define TMP_DATA               0x02
#define TMP_STRING             0x04
#define PERM_CODE              0x08
#define PERM_DATA              0x10
#define PERM_STRING            0x20
#define PERM_RELOC             0x40
#define NEW                    0x80

#define PERM_MASK              (PERM_CODE|PERM_DATA|PERM_STRING)
#define TMP_MASK               (TMP_CODE|TMP_DATA|TMP_STRING)
#define PERM2TMP               3       /* Shift value to restore old settings */
                                       /* for TMP bits */
#define TMP2PERM               3       /* Shift value to save settings */
                                       /* settings for PERM bits */

/* Restore old settings of flag bits */
#define RESTORE(x)             {\
                               (x) = ((x) & (PERM_MASK | PERM_RELOC)) |\
                                     (((x) & PERM_MASK) >> PERM2TMP);\
                               }

#define SAVE(x)                {\
                               (x) |= ((x) & TMP_MASK) << TMP2PERM;\
                               (x) &= ~NEW;\
                               }

#define SAVE_LONG(x)           {\
                               (x) |= ((x) & (TMP_MASK | (TMP_MASK << 8) |\
                                      (TMP_MASK << 16) | (TMP_MASK << 24)))\
                                      << TMP2PERM;\
                               (x) &= ~(NEW | (NEW << 8) | (NEW << 16) | (NEW << 24));\
                               }

#define IS_RELOCATED(address)  (*(flags + (address) - first_address) & PERM_RELOC)
#define IS_CODE(address)       (*(flags + (address) - first_address) & TMP_CODE)
#define IS_DATA(address)       (*(flags + (address) - first_address) & TMP_DATA)
#define IS_STRING(address)     (*(flags + (address) - first_address) & TMP_STRING)
#define IS_SURE(address)       (*(flags + (address) - first_address) &\
                                        (TMP_CODE | TMP_DATA))
#define IS_PROBABLE(address)   (*(flags + (address) - first_address) &\
                                        (TMP_CODE | TMP_DATA | TMP_STRING))
#define IS_NEW(address)        (*(flags + (address) - first_address) & NEW)

#define IS_RELOCATED_P(ptr)  (*(ptr) & PERM_RELOC)
#define IS_CODE_P(ptr)       (*(ptr) & TMP_CODE)
#define IS_DATA_P(ptr)       (*(ptr) & TMP_DATA)
#define IS_STRING_P(ptr)     (*(ptr) & TMP_STRING)
#define IS_SURE_P(ptr)       (*(ptr) & (TMP_CODE | TMP_DATA))
#define IS_PROBABLE_P(ptr)   (*(ptr) & (TMP_CODE | TMP_DATA | TMP_STRING))
#define IS_NEW_P(address)    (*(ptr) & NEW)

#define TMP_FILENAME "t:ADis68k"

/* Marker for jump-tables */
#define UNSET 0xffffffffL

#define ODD(x) ((x) & 1)
#define EVEN(x) (!ODD(x))

extern unsigned short *code;
extern char opcode [];
extern char src [];
extern char dest [];
extern char instruction [];
extern struct opcode_entry opcode_table [];
extern struct opcode_entry mmu_opcode_table [];
extern unsigned long current_address;
extern unsigned long first_address;     /* start address of current hunk */
extern unsigned long last_address;      /* last address of current hunk */
extern unsigned long current_hunk;
extern unsigned long total_size;
extern unsigned char *flags;
extern BOOL end_instr;
extern BOOL verbose;
extern char *reg_names []; 
extern char *special_regs [];
extern char *conditions [];
extern FILE *in,
            *out,
            *tmp_f;
extern char *in_buf,
            *out_buf;
extern char *input_filename;
extern char output_filename[];
extern int buf_size;
extern BOOL try_small;
extern long a4_offset;
extern long *hunk_start,
            *hunk_end,
            *hunk_offset;
extern BOOL pass1,
            pass2,
            pass3;
extern BOOL detected_illegal;
extern BOOL mc68020,
            mc68881,
            ext_68020_modes,
            mc68030,
            mc68040;
extern BOOL disasm_quick;
extern BOOL print_illegal_instr_address;
extern BOOL warning_printed;
extern BOOL user_wants_single_file,
            user_wants_separate_files;
extern BOOL add_file_offset;
extern BOOL single_file;
extern int num_code_hunks;
extern int num_data_hunks;
extern int num_bss_hunks;
extern int num_hunks;
extern long f_offset;
/* pointer to format_line function: */
extern void (*format_line) (BOOL, BOOL);

extern BOOL ascending_label_numbers;
#ifdef AMIGA
extern BOOL disasm_as_lib;
extern BOOL ROMTagFound;
#endif
extern short mc68020_disabled [];
extern short mc68030_disabled [];
extern short mc68040_disabled [];
extern short mc68881_disabled [];
extern BOOL use_tabs;
extern short tabsize;

/* Prototypes */

/* analyze.c */
void save_flags(void);
void restore_flags(void);
#ifdef DEBUG
void get_first_code_label(void);
void examine_direct_refs(unsigned short *seg, unsigned long seg_size);
short examine_unknown_labels(unsigned short *seg, unsigned long seg_size);
short guess(unsigned short *seg, unsigned long seg_size);
void last_touch(unsigned short *seg, unsigned long seg_size);
#endif
void disasm_code_1st(unsigned short *seg, unsigned long seg_size);
#ifdef DEBUG
void print_flags (ULONG from);
#endif

/* decode_ea.c */
int decode_ea (short mode, short reg, char *where_to, short access, 
               short first_ext);

/* disasm_code.c */
short disasm_instr (void);
void disasm_code (USHORT *seg, ULONG seg_size);
void disasm_code_1st (USHORT *seg, ULONG seg_size);

/* disasm_data.c */
void disasm_data (UBYTE *data_seg, ULONG seg_size);
void disasm_bss (void);

/* main.c */
void main (int argc, char *argv []);
void parse_args (int argc, char *argv []);
#ifdef DEBUG
void Usage (void);
#endif
void open_files (void);
void close_files (void);
void open_output_file (void);
void close_output_file (void);
void ExitADis (void);
#ifdef AZTEC_C
void _abort (void);
#endif
#ifdef DEBUG
void check_consistency (void);
#endif

/* util.c */
char *format_d (char *where, short val, BOOL sign);
char *format_ld  (char *where, long val, BOOL sign);
char *format_ld_no_dollars  (char *where, long val, BOOL sign);
void format_reg_list (char *where, unsigned short list, BOOL to_mem, 
                      short reglist_offset);
char *immed (char *to, long val);
void pre_dec (char *to, short reg_num);
void post_inc (char *to, short reg_num);
void indirect (char *to, short reg_num);
void disp_an (char *to, short reg_num, short disp);
void disp_an_indexed (char *to, short an, char disp, short index_reg, 
                      short scale, short size);
int full_extension (char *to, unsigned short *extension, short mode, short reg);
void format_line_spaces (BOOL labeled, BOOL commented);
int gen_label (char *where_to, ULONG ref, BOOL anyway);
BOOL is_string (char *maybe_string, ULONG max_len);
void put (char *string);
char *cpstr (char *dest, char *src, int max_len);
void gen_xref (ULONG address);
void assign_label_names (void);

void mark_entry_illegal (int entry);

/* hunks.c */
long getlong(void);
unsigned short getword(void);
BOOL readfile(void);
BOOL read_hunk_header(void);
BOOL read_hunk_overlay(void);
BOOL read_code_hunk(void);
BOOL read_data_hunk(void);
BOOL read_bss_hunk(void);
BOOL read_symbol_hunk(void);
BOOL read_reloc32_hunk(USHORT *hunk_start);
BOOL read_reloc16_hunk(USHORT *hunk_start);


/* ref_table.c */
BOOL init_ref_table (ULONG size);
void kill_ref_table (void);
void enter_ref (ULONG offset, char *name, UWORD access_type);
ULONG ext_enter_ref (ULONG offset, ULONG hunk, char *name, UWORD access_type);
BOOL find_reference (ULONG offset, char **name, UWORD *access_type);
BOOL find_active_reference (ULONG offset, char **name, UWORD *access_type);
ULONG next_reference (ULONG from, ULONG to, UWORD *access);
ULONG next_active_reference (ULONG from, ULONG to, UWORD *access);
void deactivate_labels (ULONG from, ULONG to);
void make_labels_permanent (void);
void delete_tmp_labels (void);

/* mem.c */
void *get_mem(unsigned long size);
void release_mem(void *buffer);

/* user_defined.c */
void predefine_label(unsigned long address, unsigned short access);
void add_predefined_labels(void);

#ifdef DEBUG
void print_ref_table (ULONG from, ULONG to);
void print_active_table (ULONG from, ULONG to);
void check_active_table (void);
#endif

#ifdef DEBUG
#define PRIVATE
#else
#define PRIVATE static
#endif

/* opcode_handler.c */
int bit_reg (struct opcode_entry *op);
int bit_mem (struct opcode_entry *op);
int move    (struct opcode_entry *op);
int movem   (struct opcode_entry *op);
int moveq   (struct opcode_entry *op);
int srccr   (struct opcode_entry *op);
int special (struct opcode_entry *op);
int off_illegal (struct opcode_entry *op);
int illegal (struct opcode_entry *op);
int immediate (struct opcode_entry *op);
int ori_b   (struct opcode_entry *op);
int single_op (struct opcode_entry *op);
int end_single_op (struct opcode_entry *op);
int dual_op (struct opcode_entry *op);
int quick   (struct opcode_entry *op);
int branch  (struct opcode_entry *op);
int dbranch (struct opcode_entry *op);
int shiftreg(struct opcode_entry *op);
int op_w    (struct opcode_entry *op);
int op_l    (struct opcode_entry *op);
int restrict(struct opcode_entry *op);
int scc     (struct opcode_entry *op);
int exg     (struct opcode_entry *op);
int movesrccr (struct opcode_entry *op);
int cmpm    (struct opcode_entry *op);
int movep   (struct opcode_entry *op);
int bkpt    (struct opcode_entry *op);
int muldivl (struct opcode_entry *op);
int bf_op   (struct opcode_entry *op);
int trapcc  (struct opcode_entry *op);
int chkcmp2 (struct opcode_entry *op);
int cas     (struct opcode_entry *op);
int cas2    (struct opcode_entry *op);
int moves   (struct opcode_entry *op);
int link_l  (struct opcode_entry *op);
int move16  (struct opcode_entry *op);
int cache   (struct opcode_entry *op);

#define SNG_ALL 1        /* Single operand syntax allowed */

/* fpu_opcodes.c */
extern struct opcode_entry fpu_opcode_table [];
extern char *xfer_size [];
extern short sizes [];
extern char *fpu_conditions [];

/* opcode_handler_fpu.c */
int fpu (struct opcode_entry *op);
int std_fpu (struct opcode_entry *op);
int fsincos (struct opcode_entry *op);
int fscc (struct opcode_entry *op);
int fbranch (struct opcode_entry *op);
int fdbranch (struct opcode_entry *op);
int ftrapcc (struct opcode_entry *op);

/* opcode_handler_mmu.c */
int pflush40(struct opcode_entry *op);
int ptest40(struct opcode_entry *op);
int mmu30(struct opcode_entry *op);
int ptest30(struct opcode_entry *op);
int pfl_or_ld(struct opcode_entry *op);
int pflush30(struct opcode_entry *op);
int pmove30(struct opcode_entry *op);

/* amiga.c */
BOOL user_aborted_analysis (void);
void delete_tmp_files (void);
#ifdef AMIGA
BOOL add_lib_labels (UWORD *seg);
#endif

/* version.c */
void print_version (void);

/* jmptab.c */
void free_jmptab_list (void);
void enter_jmptab (ULONG start, ULONG offset);
BOOL next_code_ref_from_jmptab (UWORD *seg);
BOOL invalidate_last_jmptab_entry (void);
BOOL find_jmptab_and_print (char *string);

#ifdef DEBUG
void print_jmptab_list (void);
#endif
