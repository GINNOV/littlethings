/*
 * Change history
 * $Log:	disasm_code.c,v $
 * Revision 3.0  93/09/24  17:53:52  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:55:46  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:53:49  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.15  93/07/01  11:39:11  Martin_Apel
 * Minor mod.: Removed dependance on ctype.h
 * 
 * Revision 1.14  93/06/06  13:46:15  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.13  93/06/03  20:25:45  Martin_Apel
 * Minor mod.: Additional linefeed generation for end instructions has been
 *             moved to format_line
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: disasm_code.c,v 3.0 93/09/24 17:53:52 Martin_Apel Exp $";

short disasm_instr ()

/**********************************************************************/
/*    Returns number of words disassembled                            */
/**********************************************************************/

{
register struct opcode_entry *op;
short size;

opcode [0] = src [0] = dest [0] = 0;
size = 0;

for (op = &(opcode_table [(code [0]) >> 6]);
     size == 0; 
     op = &(opcode_table [op->chain]))
  {
  /* Test for validity of ea_mode */
  if (op->modes & (1 << MODE_NUM (*code)))
    {
    if ((MODE_NUM (*code) == 7) && !(op->submodes & (1 << REG_NUM (*code))))
      continue;

    if (pass3 && op->mnemonic != 0)
      {
      strcpy (opcode, op->mnemonic);
      }
    size = (*op->handler) (op);
    }
  }

return (size);
}

/**************************************************************************/

PRIVATE void disasm_code_2nd (USHORT *seg, ULONG seg_size)

{
short instr_size;
UBYTE *b_ptr;
int i;
int data_size;
BOOL write_far_directives = FALSE;
static ULONG last_address_printed = 0L;
BOOL currently_far;                /* Is true when all current instructions
                                      are meant as far */

if (try_small)
  {
  currently_far = FALSE;
  /*
  put ("                    NEAR           CODE\n\n");
  */
  put ("                    NEAR\n\n");
  }
else
  {
  currently_far = TRUE;
  /*
  put ("                    FAR            CODE\n\n");
  */
  put ("                    FAR\n\n");
  }


b_ptr = (UBYTE*)seg;
for (current_address = first_address; current_address < last_address;)
  {
  if (verbose && (current_address - last_address_printed > 0x200))
    {
    printf (">%5lx\r", current_address);
    fflush (stdout);
    last_address_printed = current_address;
    }
  if (IS_CODE (current_address))
    {    
#ifdef DEBUG
    if (current_address & 1)
      fprintf (stderr, "Code starting at odd address: %lx\n", current_address);
#endif
    end_instr = FALSE;
    code = (USHORT*)b_ptr;
    instr_size = disasm_instr ();
#ifdef DEBUG
    if (detected_illegal)
      fprintf (stderr, "Detected illegal opcode during second pass at %lx\n", 
               current_address);
#endif
    if (try_small)
      {
      /* The instruction word itself can't be relocated */
      for (i = 2; i < instr_size * 2; i += 2)
        {
        if (IS_RELOCATED (current_address + i))
          write_far_directives = TRUE;
        }
      }

    format_line (FALSE, TRUE);
    if (!currently_far && write_far_directives)
      {
      /*
      put ("\n                    FAR            CODE\n");
      */
      put ("\n                    FAR\n");
      currently_far = TRUE;
      }
    else if (currently_far && !write_far_directives && try_small)
      {
      /*
      put ("                    NEAR           CODE\n\n");
      */
      put ("                    NEAR\n\n");
      currently_far = FALSE;
      }

    put (instruction);
    write_far_directives = FALSE;

    b_ptr += 2 * instr_size;
    current_address += 2 * instr_size;
    }
  else 
    {
    i = current_address;    
    while (!IS_CODE (i) && i < last_address)
      i++;
    data_size = i - current_address;
    disasm_data (b_ptr, data_size);
    b_ptr += data_size;
    }
  }

put ("\n");
}

/**************************************************************************/

PRIVATE void quick_and_dirty (USHORT *seg, ULONG seg_size)

{
short instr_size;
int i;
BOOL write_far_directives = FALSE;
ULONG last_address_printed;
BOOL currently_far;                /* Is true when all current instructions
                                      are meant as far */
if (try_small)
  {
  currently_far = FALSE;
  put ("                    NEAR\n\n");
  }
else
  {
  currently_far = TRUE;
  put ("                    FAR\n\n");
  }


last_address_printed = first_address;
code = seg;
for (current_address = first_address; current_address < last_address;)
  {
  if (verbose && (current_address - last_address_printed > 0x200))
    {
    printf (">%5lx\r", current_address);
    fflush (stdout);
    last_address_printed = current_address;
    }

  detected_illegal = FALSE;
  end_instr = FALSE;
  instr_size = disasm_instr ();
  if (detected_illegal || current_address + 2 * instr_size > last_address)
    {
    strcpy (opcode, "DC.W");
    format_d (src, *code, FALSE);
    dest [0] = 0;
    instr_size = 1;
    }

  if (try_small)
    {
    /* The instruction word itself can't be relocated */
    for (i = 2; i < instr_size * 2; i += 2)
      {
      if (IS_RELOCATED (current_address + i))
        write_far_directives = TRUE;
      }
    }

  format_line (TRUE, TRUE);
  if (!currently_far && write_far_directives)
    {
    put ("\n                    FAR\n");
    currently_far = TRUE;
    }
  else if (currently_far && !write_far_directives && try_small)
    {
    put ("                    NEAR\n\n");
    currently_far = FALSE;
    }

  put (instruction);
  write_far_directives = FALSE;

  code += instr_size;
  current_address += 2 * instr_size;
  }

put ("\n");
}

/**************************************************************************/

void disasm_code (USHORT *seg, ULONG seg_size)

{
if (pass2)
  {
  disasm_code_1st (seg, seg_size);
  }
else if (disasm_quick)
  quick_and_dirty (seg, seg_size);
else
  disasm_code_2nd (seg, seg_size);
}
