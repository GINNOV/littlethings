/*
 * Change history
 * $Log:	disasm_data.c,v $
 * Revision 3.0  93/09/24  17:53:54  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.2  93/07/18  22:55:49  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.1  93/07/10  13:02:02  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.0  93/07/01  11:53:52  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.17  93/07/01  11:39:28  Martin_Apel
 * Minor mod.: Removed dependance on ctype.h
 * 
 * Revision 1.16  93/06/06  00:10:55  Martin_Apel
 * Bug fix: DC.B $80 was printed as DC.B -$7F
 * 
 * Revision 1.15  93/06/03  20:26:58  Martin_Apel
 * Minor mod.: Additional linefeed generation for end instructions has been
 *             moved to format_line
 * 
 * Revision 1.14  93/06/03  18:29:49  Martin_Apel
 * Minor mod.: Addressing relative to hunk end changed
 * 
 */

#include <stdio.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: disasm_data.c,v 3.0 93/09/24 17:53:54 Martin_Apel Exp $";

void disasm_data (UBYTE *data_seg, ULONG seg_size)

{
/* data_seg is guaranteed to be an even address */

register char *data_ptr;
char *seg_end;
ULONG offset;
char *next_label,
     *last_label;
UWORD dummy_access;
ULONG size;
BOOL first_time = TRUE;
BOOL valid_string;
ULONG last_address_printed;
ULONG tmp_offset;

seg_end = (char*)data_seg + seg_size;
data_ptr = (char*)data_seg;
offset = current_address - first_address;
last_address_printed = current_address;
dest [0] = 0;
end_instr = FALSE;

next_label = data_ptr;
while (data_ptr < seg_end)
  {
  /* find next label */
  last_label = next_label;
  next_label = data_ptr - current_address +
            next_reference (current_address, last_address, &dummy_access);
  if (next_label > seg_end)
    next_label = seg_end;

  /* Search from data_ptr forward to next_label until stepping onto
     a relocated address. If found, mark this as the next label.
     This way no strings will cross relocated addresses */
  if (IS_RELOCATED (current_address))
    tmp_offset = 4;
  else
    tmp_offset = 2;
  for (; data_ptr + tmp_offset < next_label; tmp_offset++)
    {
    if (IS_RELOCATED (current_address + tmp_offset))
      {
      next_label = data_ptr + tmp_offset;
      break;
      }
    }

  while (data_ptr < next_label)
    {
    if (verbose && (current_address - last_address_printed > 0x200))
      {
      printf (">%5lx\r", current_address);
      fflush (stdout);
      last_address_printed = current_address;
      }

    valid_string = is_string (data_ptr, next_label - data_ptr);

    if (!ODD (offset) && IS_RELOCATED (current_address))
      {
       /* The long word starting at this address is relocated */
      strcpy (opcode, "DC.L");
      gen_label (src, *((ULONG*)data_ptr), TRUE);
      size = 4;
      }
    else if (!ODD (offset) && (code = (unsigned short*)data_ptr,
                               find_jmptab_and_print (src)))
      {
      strcpy (opcode, "DC.W");
      size = 2;
      }
    else if (!ODD (offset) && (next_label - data_ptr == 4) &&
             (data_ptr == last_label) && !valid_string)
      {
      /* It seems to be a longword */
      strcpy (opcode, "DC.L");
      format_ld (src, *((ULONG*)data_ptr), TRUE);
      size = 4;
      }
    else if (valid_string)
      {
      char *to_be_copied;
      
      strcpy (opcode, "DC.B");
      to_be_copied = cpstr (src, data_ptr, 75 - PARAM_COL);
      if (to_be_copied == NULL)
        size = strlen (data_ptr) + 1;
      else
        size = to_be_copied - data_ptr;
      }
    else if ((current_address & 1) == 0 && (data_ptr + 1 != next_label))
      {    
      strcpy (opcode, "DC.W");
      format_d (src, *(UWORD*)data_ptr, TRUE);
      size = 2;
      }
    else  /* write a single byte */
      {
      strcpy (opcode, "DC.B");
      format_d (src, (UBYTE)*data_ptr, TRUE);
      size = 1;
      }

    format_line (first_time, TRUE);
    first_time = FALSE;
    put (instruction);
    current_address += size;
    data_ptr += size;
    offset += size;
    }
  }
}


void disasm_bss ()

{
ULONG seg_end;
ULONG next_label;
UWORD dummy_access;

seg_end = *(hunk_end + current_hunk);
end_instr = FALSE;

while (current_address < seg_end)
  {
  next_label = next_reference (current_address, last_address, &dummy_access);

  if (((current_address & 1) == 0) && 
      (((next_label - current_address) & 0x3) == 0))
    {
    /* Multiple of 4 bytes */
    strcpy (opcode, "DS.L");
    format_d (src, (UWORD)((next_label - current_address) / 4), FALSE);
    }
  else if (((current_address & 1) == 0) && 
      (((next_label - current_address) & 0x1) == 0))
    {
    /* Multiple of 2 bytes */
    strcpy (opcode, "DS.W");
    format_d (src, (UWORD)((next_label - current_address) / 2), FALSE);
    }
  else  /* write a single byte */
    {
    strcpy (opcode, "DS.B");
    format_d (src, (UWORD)(next_label - current_address), FALSE);
    }

  format_line (FALSE, FALSE);
  put (instruction);
  current_address = next_label;  
  }

put ("\n");
}
