/*
 * Change history
 * $Log:	analyze.c,v $
 * Revision 3.0  93/09/24  17:53:48  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.5  93/07/18  22:55:38  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.4  93/07/13  11:40:29  Martin_Apel
 * Bug fix: Premature abortion aof analysis is now handled correctly
 *          (see log for amiga.c)
 * 
 * Revision 2.3  93/07/11  21:37:30  Martin_Apel
 * Major mod.: Jump table support tested and changed
 * 
 * Revision 2.2  93/07/10  13:01:34  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.1  93/07/08  20:46:25  Martin_Apel
 * Minor mod.: Moved jump table recognition to examine_unknown_labels
 * 
 * Revision 2.0  93/07/01  11:53:42  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.21  93/07/01  11:37:31  Martin_Apel
 * Minor mod.: Removed dependance on ctype.h
 * 
 * Revision 1.20  93/06/16  20:25:36  Martin_Apel
 * Minor mod.: Moved jump table code to jumptab.c
 * 
 * Revision 1.19  93/06/06  13:44:55  Martin_Apel
 * Minor mod.: Added preliminary support for jump tables recognition
 * 
 * Revision 1.18  93/06/06  00:09:59  Martin_Apel
 * Bug fix: Small change regarding recognition of jump tables
 * 
 * Revision 1.18  93/06/06  00:08:12  Martin_Apel
 * Minor mod.: Fixed bug regarding jump tables
 * 
 * Revision 1.17  93/06/03  20:25:06  Martin_Apel
 * 
 */

#include <exec/types.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "defs.h"

#ifdef AZTEC_C
void Chk_Abort (void);
#endif

static char rcsid [] = "$Id: analyze.c,v 3.0 93/09/24 17:53:48 Martin_Apel Exp $";

PRIVATE BOOL first_try = TRUE;

/**********************************************************************/

void save_flags (void)

{
register ULONG *ptr,
               *seg_end;

make_labels_permanent ();
seg_end = (ULONG*)(flags + (last_address - first_address));
ptr = (ULONG*)flags;
while (ptr < seg_end)
  {
  SAVE_LONG (*ptr);
  ptr++;
  }
}

/**********************************************************************/

void restore_flags (void)

{
register UBYTE *ptr,
               *seg_end;

delete_tmp_labels ();
ptr = flags;
seg_end = flags + last_address - first_address;
while (ptr < seg_end)
  {
  if (*ptr & NEW)
    RESTORE (*ptr);
  ptr++;
  }
}

/*************************************************************************/

PRIVATE void get_first_code_label (void)

{
char *dummy;
UWORD access;

/* get first code label in this hunk */
current_address = first_address;
if (!(find_active_reference (first_address, &dummy, &access) && 
      (access & ACC_CODE)))
  {
  do
    current_address = next_active_reference (current_address, 
                                             last_address, &access);
  while (current_address < last_address && !(access & ACC_CODE));
  }
}

/**********************************************************************/

PRIVATE void examine_direct_refs (USHORT *seg, ULONG seg_size)

/**********************************************************************/
/*  This routine starts disassembling from current_address and then   */
/*                 continuing where code labels are.                  */
/**********************************************************************/
{
register short instr_size;
UWORD access;
BOOL examined_direct_refs = FALSE;
register int i;
ULONG stream_start;
char *dummy;

while (!examined_direct_refs)
  {
  do
    {
    if (!IS_SURE (current_address))
      {
      code = seg + (current_address - first_address) / 2;
      end_instr = FALSE;
      examined_direct_refs = FALSE;
      if (verbose)
        {
        printf (">%5lx\r", current_address);
        fflush (stdout);
        }
#ifdef AZTEC_C
      else
        Chk_Abort ();
#endif
      stream_start = current_address;
      do
        {
        instr_size = disasm_instr ();
        if (detected_illegal || (current_address + 2 * instr_size > 
             next_reference (current_address, last_address, &access)) ||
             IS_RELOCATED (current_address))
          {
          restore_flags ();
          if (print_illegal_instr_address)
            {
            printf ("Illegal instruction found at address: %lx\n", 
                     current_address);
            }
          first_try = FALSE;
          detected_illegal = FALSE;
          return;
          }

        for (i = 0; i < instr_size; i++)
          {
          assert (current_address - first_address + i * 2 + 1 < seg_size);
          *((UWORD*)(flags + current_address - first_address + i * 2)) |=
                    ((TMP_CODE | NEW) << 8) | (TMP_CODE | NEW);
          }
        code += instr_size;
        current_address += instr_size * 2;
        }
      while (!end_instr && current_address < last_address &&
                           !IS_SURE (current_address));

      deactivate_labels (stream_start, current_address);      
      }
    else
      deactivate_labels (current_address, current_address + 2);      
      
    /* advance current_address until next address which has not been 
       examined yet. Then find the next label from there on */
    if (!(find_active_reference (current_address, &dummy, &access) &&
          access & ACC_CODE))
      {
      access = 0;
      while (!(access & ACC_CODE) && current_address < last_address)
        current_address = next_active_reference (current_address, 
                                                 last_address, &access);
      }
    }
  while (current_address < last_address);
  get_first_code_label ();
  if (current_address == last_address)
    examined_direct_refs = TRUE;  
  }
}

/************************************************************************/

PRIVATE BOOL examine_unknown_labels (UWORD *seg, ULONG seg_size)

{
BOOL new_labels_found;
char *maybe_string;
int length;
UWORD access;
int i;

new_labels_found = FALSE;
current_address = first_address;

while (current_address < last_address)
  {
  if (!IS_PROBABLE (current_address))
    {
    if (verbose)
      {
      printf (">%5lx\r", current_address);
      fflush (stdout);
      }
#ifdef AZTEC_C
      else
        Chk_Abort ();
#endif
    maybe_string = (char*)seg + (current_address - first_address);

    if ((ODD (current_address)) || 
        (is_string (maybe_string, last_address - current_address) && 
         *(USHORT*)maybe_string != 0x4e55))
      {
      /* label is at an odd address, or it's definitely a string but not
         a link instruction */
      length = strlen (maybe_string) + 1;
      if (current_address + length > last_address)
        {
        *(flags + (current_address - first_address)) |= 
                                                  TMP_DATA | NEW;
        assert (current_address - first_address < seg_size);
        }
      else if (first_try && length < 5 &&
               next_reference (current_address, last_address, &access) -
               current_address > 10 && !ODD (current_address))
        {
        new_labels_found = TRUE;
        break;
        }
      else
        {
        for (i = 0; i < length; i++)
          {
          *(flags + (current_address - first_address + i)) |= 
                                    TMP_STRING | NEW;
          assert (current_address - first_address + i < seg_size);
          }
        deactivate_labels (first_address, current_address + 1);
        save_flags ();
        first_try = TRUE;
        }
      }
    else if (first_try)
      {
      /* try to disassemble it */
      new_labels_found = TRUE;
      break;
      }
    else 
      {
      *(flags + (current_address - first_address)) |= TMP_DATA;
      *(flags + (current_address - first_address) + 1) |= TMP_DATA;
      first_try = TRUE;
      deactivate_labels (first_address, current_address);
      save_flags ();
      }
    }

  current_address = next_active_reference (current_address, 
                                           last_address, &access);
  }

deactivate_labels (first_address, current_address);
return (new_labels_found);
}
    
/**************************************************************************/

PRIVATE BOOL guess (UWORD *seg, ULONG seg_size)

{
/*
 * Try to disassemble the rest of the code segment.  There are no
 * labels left where to orient.  
 */

UBYTE *ptr,
      *seg_end;
static ULONG last_guessed_address;


if (!first_try)
  {
  if (invalidate_last_jmptab_entry ())
    first_try = TRUE;
  }

if (next_code_ref_from_jmptab (seg))
  {
  current_address = first_address;
  return (TRUE);
  }

ptr = flags;
code = seg;
seg_end = flags + last_address - first_address;

if (!first_try)
  {
  *(flags + last_guessed_address - first_address) |= PERM_DATA | TMP_DATA;
  *(flags + last_guessed_address - first_address + 1) |= PERM_DATA | TMP_DATA;
  first_try = TRUE;
  }

while (ptr < seg_end && (IS_PROBABLE_P (ptr) ||
       ((*code != 0x48e7) &&                                /* MOVEM ,-(SP) */
        (*code != 0x4e55) &&                                /* LINK instr. */
        (*code != 0x6000) &&                                /* BRA.L */
        (*code != 0x6100) &&                                /* BSR.L */
        (*code != 0x4efa) &&                                /* JMP d16(PC) */
        !((*code == 0x4ef9) && IS_RELOCATED_P (ptr + 2)) && /* JMP xxx.L */
        (*code != 0x4eba) &&                                /* JSR d16(PC) */
        !((*code == 0x4eb9) && IS_RELOCATED_P (ptr + 2))))) /* JSR xxx.L */
  {
  ptr += 2;
  code++;
  }

if (ptr >= seg_end)
  return (FALSE);

last_guessed_address = first_address + ptr - flags;
current_address = last_guessed_address;
return (TRUE);
}

/***************************************************************************/

PRIVATE void last_touch (UWORD *seg, ULONG seg_size)

{
for (current_address = first_address; current_address < last_address; 
     current_address++)
  {
  if (!IS_PROBABLE (current_address))
    *(flags + (current_address - first_address)) |= TMP_DATA;
  assert (current_address - first_address < seg_size);
  }
}

/***************************************************************************/



void disasm_code_1st (USHORT *seg, ULONG seg_size)

{
BOOL examine_direct;
BOOL new_labels;
BOOL aborted = FALSE;

get_first_code_label ();
if (current_address < last_address)
  examine_direct = TRUE;
else
  examine_direct = FALSE;

first_try = TRUE;
do
  {
  do
    {
    if (examine_direct)
      {
      examine_direct_refs (seg, seg_size);
      save_flags ();
      }
    examine_direct = TRUE;
    new_labels = examine_unknown_labels (seg, seg_size);
    aborted = user_aborted_analysis ();
    } 
  while (new_labels && !aborted);

  new_labels = guess (seg, seg_size);
  aborted = aborted || user_aborted_analysis ();
  } 
while (new_labels && !aborted);
last_touch (seg, seg_size);
}

/***************************************************************************/

#ifdef DEBUG

void print_flags (ULONG from)

{
ULONG count;
char id;

for (count = 0; count < 0x40; count++)
  {
  if ((count % 0x10) == 0)
    printf ("%lx: ", from + count);

  if (IS_CODE (from + count))
    if (IS_SURE (from + count))
      id = 'C';
    else
      id = 'c';
  else if (IS_DATA (from + count))
    if (IS_SURE (from + count))
      id = 'D';
    else
      id = 'd';
  else if (IS_STRING (from + count))
    if (IS_SURE (from + count))
      id = 'S';
    else
      id = 's';
  else
    id = '?';

  printf ("%c ", id);
  if ((count % 0x10) == 0xf)
    printf ("\n");
  }

printf ("\n");
}

#endif
