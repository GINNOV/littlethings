/*
 * Change history
 * $Log:	main.c,v $
 * Revision 3.0  93/09/24  17:54:06  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.3  93/07/18  22:56:07  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.2  93/07/11  21:38:36  Martin_Apel
 * Major mod.: Deleted -ce option
 * 
 * Revision 2.1  93/07/10  13:06:59  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.0  93/07/01  11:54:11  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.23  93/07/01  11:41:05  Martin_Apel
 * 
 * Revision 1.22  93/06/19  19:01:28  Martin_Apel
 * Bug fix: Upon non-FPU disassembly the first opcodes in the opcode table
 *          were marked illegal. 
 * 
 * Revision 1.21  93/06/19  12:11:11  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.20  93/06/16  20:28:45  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.19  93/06/06  13:46:58  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.18  93/06/06  00:12:16  Martin_Apel
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.17  93/06/04  11:51:22  Martin_Apel
 * New feature: Added -ln option for generation of ascending label numbers
 * 
 * Revision 1.16  93/06/03  20:28:23  Martin_Apel
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.15  93/06/03  18:34:36  Martin_Apel
 * Minor mod.: Table size for symbol table is now derived from the size of
 *             the load file instead of from the sum of the hunk sizes
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C)
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __GNUC__
#include <sys/stat.h>
#include <signal.h>
#else
#ifdef _DCC
#include <sys/stat.h>
#else
#include <stat.h>
#endif
#endif
#include "defs.h"

static char rcsid [] = "$Id: main.c,v 3.0 93/09/24 17:54:06 Martin_Apel Exp $";

PRIVATE void Usage (void)

{
puts ("Usage: ADis [options] filename");
puts ("");
puts ("  Options is one of the following");
puts ("     -a                               add absolute offset in file as comment");
puts ("     -b num                           set buffersize for file buffers in KB");
puts ("                                      default: 10 KB");
puts ("     -c2                              enable 68020 instruction disassembly");
puts ("     -c3                              enable 68030 instruction disassembly");
puts ("     -c4                              enable 68040 instruction disassembly");
puts ("     -c8                              enable 68881 instruction disassembly");
puts ("                                      (only in conjunction with -c2, -c3, -c4)");
#ifdef AMIGA
puts ("     -dl                              disassemble as library (or device)");
#endif
puts ("     -fs                              put hunks in a single file");
puts ("     -fm                              put each hunk in a separate file");
puts ("     -i                               print addresses where illegal");
puts ("                                      instructions were found");
puts ("     -lc hex_address                  disassemble as code");
puts ("     -ld hex_address                  disassemble as data");
puts ("     -ln                              name labels with ascending numbers");
puts ("                                      instead of code addresses");
puts ("     -ml                              disassemble using large memory model");
puts ("     -ms[base_offset]                 attempt to address code and ");
puts ("                                      data relative to a4 (default 0x7ffe)");
puts ("     -o outfilename                   filename of output file");
puts ("                                      default: <filename>.dec");
puts ("     -q                               quick disassembly, no labels");
puts ("                                      no data recognition in code segments");
puts ("     -v                               verbose");
puts ("");
exit (0);
}

#define NEXT_OPT continue

void parse_args (int argc, char *argv [])

/* Possible parameters are:
    filename                         input file name
    -ms[base_offset]                 attempt to address code and
                                     data relative to a4 (default 0x7ffe)
    -ml                              disassemble using large memory model
    -c2                              enable 68020 instruction disassembly
    -c3                              enable 68030 instruction disassembly
    -c4                              enable 68040 instruction disassembly
    -c8                              enable 68881 instruction disassembly
    -dl                              disassemble as library (or device)
    -lc hex_address                  disassemble as code
    -ld hex_address                  disassemble as data
    -ln                              name labels with ascending numbers
                                     instead of code addresses
    -fs                              put hunks in a single file
    -fm                              put each hunk in a separate file
    -o outfilename                   filename of output file
                                     default: <filename>.dec
    -q                               quick disassembly, no labels
                                     no data recognition in code segments
    -b  num                          set buffersize for file buffers in KB
                                     default: 10 KB
    -i                               print addresses where illegal
                                     instructions were found
    -v                               verbose
    -a                               add absolute offset in file as comment
*/
{
int i;
ULONG address;

if (argc < 2)
  Usage ();

output_filename [0] = 0;
for (i = 1; i < argc; i++)
  {
  if (*argv [i] == '-')
    {
    switch (*(argv [i] + 1))
      {
      case 'm': /* Memory model to be used */
                switch (*(argv [i] + 2))
                  {
                  case 's':
                    try_small = TRUE;
                    if (*(argv [i] + 3) != 0)
                      {
                      if (sscanf (argv [i] + 3, "%lx", &a4_offset) != 1)
                        {
                        fprintf (stderr, "Invalid base for a4 relative addressing");
                        ExitADis ();
                        }
                      }
                    NEXT_OPT;
                  case 'l': 
                    try_small = FALSE;
                    NEXT_OPT;
                  }
                break;
      case 'c': /* For which processor to generate output */
                switch (*(argv [i] + 2))
                  {
                  case '4': mc68040 = TRUE;
                            mc68881 = TRUE;
                  case '3': mc68030 = TRUE;
                  case '2': mc68020 = TRUE;
                            ext_68020_modes = TRUE;
                            NEXT_OPT;
                  case '8': mc68881 = TRUE;
                            NEXT_OPT;
                  }
                break;
#ifdef AMIGA
      case 'd': if (*(argv [i] + 2) != 'l')
                  break;
                disasm_as_lib = TRUE;
                NEXT_OPT;
#endif
      case 'f': /* Whether to put the hunks in a single file or not */
                switch (*(argv [i] + 2))
                  {
                  case 's': user_wants_single_file = TRUE;
                            NEXT_OPT;
                  case 'm': user_wants_separate_files = TRUE;
                            NEXT_OPT;
                  }
                break;
      case 'o': strcpy (output_filename, argv [++i]);
                NEXT_OPT;
      case 'b': buf_size = atoi (argv [++i]) * 1024L;
                NEXT_OPT;
      case 'v': verbose = TRUE;
                NEXT_OPT;
      case 'i': print_illegal_instr_address = TRUE;
                NEXT_OPT;
      case 'l': /* labels */
                switch (*(argv [i] + 2))
                  {
                  case 'c': 
                    if (sscanf (argv [++i], "%lx", &address) != 1)
                      {
                      fprintf (stderr, "Invalid address for code label");
                      ExitADis ();
                      }
                    if (address & 1)
                      {
                      fprintf (stderr, "Code labels not allowed on odd addresses");
                      ExitADis ();
                      }
                    predefine_label (address, ACC_CODE);
                    NEXT_OPT;
                  case 'd': 
                    if (sscanf (argv [++i], "%lx", &address) != 1)
                      {
                      fprintf (stderr, "Invalid address for data label");
                      ExitADis ();
                      }
                    predefine_label (address, ACC_DATA);
                    NEXT_OPT;
                  case 'n':
                    ascending_label_numbers = TRUE;
                    NEXT_OPT;
                  }
                break;
      case 'q': disasm_quick = TRUE;
                NEXT_OPT;
      case 'a': add_file_offset = TRUE;
                NEXT_OPT;

      }
    fprintf (stderr, "ERROR: Invalid option '%s'\n", argv [i]);
    Usage ();
    }
  else if (input_filename == 0)
    input_filename = argv [i];
  else
    {
    fprintf (stderr, "ERROR: Only one program can be disassembled at a time\n");
    Usage ();
    }
  }
}


void open_files (void)

{
/* This opens only the input file, but already allocates the buffer 
   for the output file */

in_buf = get_mem (buf_size);
out_buf = get_mem (buf_size);

if ((in = fopen (input_filename, "r")) == 0)
  {
  fprintf (stderr, "Couldn't find input file\n");
  ExitADis ();
  }
setvbuf (in, in_buf, _IOFBF, buf_size);
}


void close_files (void)

{
if (in)
  fclose (in);
if (out)
  fclose (out);
if (in_buf)
  release_mem (in_buf);
if (out_buf)
  release_mem (out_buf);
if (tmp_f)
  fclose (tmp_f);
}


void open_output_file (void)

{
char open_mode [2] = "w";
char act_outname [200];

if (out != NULL)
  return;

if (single_file)
  {
  if (output_filename [0] == 0)
    strcat (strcpy (act_outname, input_filename), ".dec");
  else
    strcpy (act_outname, output_filename);

  if (current_hunk != 0)
    open_mode [0] = 'a';           /* open for appending */
  }
else
  {
  if (output_filename [0] == 0)  
    sprintf (act_outname, "%s.dec.%d", input_filename, current_hunk + 1);
  else
    sprintf (act_outname, "%s.%d", output_filename, current_hunk + 1);    
  }


if ((out = fopen (act_outname, &(open_mode [0]))) == 0)
  {
  fprintf (stderr, "Couldn't open output file\n");
  ExitADis ();
  }
setvbuf (out, out_buf, _IOFBF, buf_size);

if (mc68020)
  put ("                    MACHINE        MC68020\n");
if (mc68881)
  put ("                    MC68881\n");
}


void close_output_file (void)

{
#ifdef DEBUG
if (out == NULL)
  {
  fprintf (stderr, "INTERNAL ERROR: close_output_file: Trying to close closed file\n");
  ExitADis ();
  }
#endif

if (!single_file || current_address == total_size)
  {
  put ("\n                    END\n");
  fclose (out);
  out = NULL;
  }
}


void main (int argc, char *argv [])

{
struct stat status;

#ifdef __GNUC__
  signal (SIGINT, ExitADis);
#endif

print_version ();
parse_args (argc, argv);
open_files ();
stat (input_filename, &status);
init_ref_table (status.st_size);

if (!mc68881)
  {
  int i;
  for (i = 0; mc68881_disabled [i] != 0; i++)
    mark_entry_illegal ((int)(mc68881_disabled [i]));
  }
if (!mc68020)
  {
  int i;
  for (i = 0; mc68020_disabled [i] != 0; i++)
    mark_entry_illegal ((int)(mc68020_disabled [i]));

  /* Disable extended addressign modes for TST instruction */
  for (i = (0x4a00 >> 6); i <= (0x4a80 >> 6); i++)
    {
    opcode_table [i].modes = 0xfd;
    opcode_table [i].submodes = 0x0f;
    }
  }

if (!mc68030)
  {
  int i;
  for (i = 0; mc68030_disabled [i] != 0; i++)
    mark_entry_illegal ((int)(mc68030_disabled [i]));
  }

if (!mc68040)
  {
  int i;
  for (i = 0; mc68040_disabled [i] != 0; i++)
    mark_entry_illegal ((int)(mc68040_disabled [i]));
  }

pass1 = TRUE;
pass2 = pass3 = FALSE;

if (verbose)
  puts ("Reading relocation and symbol information...");

if (!readfile ())
  {
  fprintf (stderr, "ERROR: Couldn't disassemble file\n");
  ExitADis ();
  }

/* The only thing I'm sure about right now is, that the first address in the
   file has to be executable */
enter_ref (0L, 0L, ACC_CODE);
add_predefined_labels ();


pass1 = FALSE;
pass2 = TRUE;
if (!disasm_quick)
  {
  rewind (in);
  if (verbose)
    puts ("Analyzing...");

  if (!readfile ())
    {
    fprintf (stderr, "ERROR: Couldn't disassemble file\n");
    ExitADis ();
    }
  if (ascending_label_numbers)
    assign_label_names ();
  }

if (!user_wants_single_file && 
    (num_code_hunks > 1 || num_data_hunks > 1 || num_bss_hunks > 1 ||
    user_wants_separate_files))
  single_file = FALSE;

rewind (in);
pass2 = FALSE;
pass3 = TRUE;
if (verbose)
  puts ("Disassembling...");

if (!readfile ())
  {
  fprintf (stderr, "ERROR: Couldn't disassemble file\n");
  ExitADis ();
  }

free_jmptab_list ();
kill_ref_table ();
close_files ();
delete_tmp_files ();
exit (0);
}


void ExitADis (void)

{
free_jmptab_list ();
kill_ref_table ();
close_files ();
delete_tmp_files ();
fprintf (stderr, "ADis aborted...\n");
exit (1);
}

#ifdef AZTEC_C
void _abort (void)

{
ExitADis ();
}
#endif

#ifdef DEBUG
void check_consistency ()

{
int i;
struct opcode_entry *oe;

for (i = 0; i <= 1055; i++)
  {
  oe = &opcode_table [i];
  if (oe->handler == dual_op)
    continue;
  if (oe->handler == move)
    continue;
  if (oe->handler == branch)
    continue;
  if (oe->handler == illegal)
    continue;
  if (oe->handler == op_l)
    continue;
  if (oe->handler == op_w)
    continue;
  if (oe->handler == quick)
    continue;
  if (oe->handler == single_op)
    continue;
  if (oe->handler == shiftreg)
    continue;
  if (oe->handler == bit_reg)
    continue;
  if (oe->handler == dbranch)
    continue;
  if (oe->handler == immediate)
    continue;
  if (oe->handler == moveq)
    continue;
  if (oe->handler == bit_mem)
    continue;
  if (oe->handler == cmpm)
    continue;
  if (oe->handler == end_single_op)
    continue;
  if (oe->handler == exg)
    continue;
  if (oe->handler == movem)
    continue;
  if (oe->handler == movep)
    continue;
  if (oe->handler == movesrccr)
    continue;
  if (oe->handler == restrict)
    continue;
  if (oe->handler == scc)
    continue;
  if (oe->handler == special)
    continue;
  if (oe->handler == srccr)
    continue;
  fprintf (stderr, "Invalid opcode handler found at entry %d\n", i);
  }
}
#endif
