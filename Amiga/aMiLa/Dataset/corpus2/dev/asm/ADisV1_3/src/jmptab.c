/*
 * Change history
 * $Log $
 */

#include <exec/types.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: jmptab.c,v 3.0 93/09/24 17:54:04 Martin_Apel Exp $";

/*
 * This list handles all references made through PC-relative with index
 * addressing modes. It contains all data that's important for disassembling
 * jump tables.
 * Idea for handling jump tables:
 * The instruction stream that handles the calling of the corresponding
 * routine cannot be jmuped into in the middle, i.e. the last reference
 * to the current code hunk before the JMP at the end of that instruction
 * stream is the loading of the start address of the jump table and it's
 * guaranteed that those two instructions will be disassembled nearly
 * consecutively.
 * Implementation:
 * Introduce a static variable in decode_ea, which always stores the last
 * reference to the current code hunk (PC rel or relocated). When the JMP
 * instruction is disassembled it uses this information and enters the
 * jump table into the list.
 */

struct jmptab_descr
  {
  struct jmptab_descr *Next;
  ULONG Start,
        End,
        ReferencingInstr,
        JmpOffset;
  BOOL  ReallyJmpTable;              /* for backtracking */
  BOOL  AllDone;
  };

PRIVATE struct jmptab_descr *JmpTables = NULL;
PRIVATE last_code_ref_from_jmptab = UNSET;

/*********************************************************************/

void free_jmptab_list ()

{
struct jmptab_descr *tmp;

while (JmpTables != NULL)
  {
  tmp = JmpTables->Next;
  release_mem (JmpTables);
  JmpTables = tmp;
  }
}

/*********************************************************************/

void enter_jmptab (ULONG start, ULONG jmp_offset)

{
struct jmptab_descr *tmp;
ULONG ref;
short offset;

/* Search if this jump-table has already been entered */
for (tmp = JmpTables; tmp != NULL; tmp = tmp->Next)
  {
  if (tmp->ReferencingInstr == current_address)
    {
#ifdef DEBUG    
    fprintf (stderr, "enter_jmptab: JumpTable multiply added\n");
#endif
    return;
    }
  }

/* Jump tables either lie directly after the JMP instruction or
 * before it.
 */

offset = *(code + (start - current_address) / 2);
ref = current_address + offset + jmp_offset + 2;

if (((start != current_address + 4) && (start >= current_address)) ||
    ODD (offset) || (ref < first_address) || (ref >= last_address))
  return;

/* To prevent ADis to backtrack completely in case of wrongly recognized
 * jump table, I do a save flags before entering the new jump table
 */

save_flags ();

/* Compute the first location the jump-table points to, and enter
 * that into the symbol-table as a code reference.
 */

enter_ref (ref, NULL, ACC_CODE);
last_code_ref_from_jmptab = start;

/* Didn't find an entry, make a new one */
tmp = get_mem (sizeof (struct jmptab_descr));
tmp->Start = start;
tmp->End = start + 2;
tmp->JmpOffset = jmp_offset;
tmp->ReferencingInstr = current_address;
tmp->ReallyJmpTable = TRUE;
tmp->AllDone = FALSE;
tmp->Next = JmpTables;
JmpTables = tmp;
}

/*********************************************************************/

BOOL next_code_ref_from_jmptab (UWORD *seg)

{
/* Searches for the next jump table that has not been fully disassembled.
 * It enters the corresponding location into the symbol table as a code
 * reference. If it doesn't find another entry it returns FALSE.
 */

struct jmptab_descr *tmp;
ULONG ref;
short offset;

for (tmp = JmpTables; tmp != NULL; tmp = tmp->Next)
  {
  if (tmp->ReallyJmpTable && !tmp->AllDone &&
      tmp->Start != UNSET && tmp->End != UNSET && tmp->JmpOffset != UNSET)
    {
    if (IS_PROBABLE (tmp->End))
      tmp->AllDone = TRUE;
    else
      {
      offset = (short)*(seg + (tmp->End - first_address) / 2);
      ref = tmp->ReferencingInstr + offset + tmp->JmpOffset + 2;
      if (ODD (offset) || ref < first_address || ref >= last_address)
        {
        tmp->AllDone = TRUE;
        continue;
        }
      enter_ref (ref, NULL, ACC_CODE);
      last_code_ref_from_jmptab = tmp->End;
      tmp->End += 2;
      return (TRUE);
      }
    }
  }
return (FALSE);
}

/*********************************************************************/

BOOL invalidate_last_jmptab_entry ()

{
/* The last code reference from a jump table has led to an error.
 * Mark it as data and mark the jump table as fully disassembled.
 */

struct jmptab_descr *tmp;

for (tmp = JmpTables; tmp != NULL; tmp = tmp->Next)
  {
  if (last_code_ref_from_jmptab == tmp->End - 2 && !tmp->AllDone)
    {
    tmp->End -= 2;
    tmp->AllDone = TRUE;
    if (last_code_ref_from_jmptab == tmp->Start)
      {
      last_code_ref_from_jmptab = UNSET;
      tmp->ReallyJmpTable = FALSE;
      }
    return (TRUE);
    }
  }
return (FALSE);
}

/**************************************************************************/

BOOL find_jmptab_and_print (char *string)

/* Tests if current_address lies within a jump-table. If it does, it 
 * prints a label description to string.
 * When this routine is called, code points to data at current_address.
 */
{
struct jmptab_descr *tmp;

for (tmp = JmpTables; tmp != NULL; tmp = tmp->Next)
  {
  if (tmp->Start != UNSET && tmp->End != UNSET && tmp->JmpOffset != UNSET &&
      current_address >= tmp->Start && current_address < tmp->End)
    {
    gen_label (string, tmp->ReferencingInstr + (short)*code + 
               tmp->JmpOffset + 2, USE_LABEL);
    strcat (string, "-");
    gen_label (string + strlen (string), tmp->ReferencingInstr, USE_LABEL);
    strcat (string, "-");
    format_d (string + strlen (string), 
              (short)(2L + tmp->JmpOffset), USE_SIGN);
    return (TRUE);
    }
  }
return (FALSE);
}

/**************************************************************************/

#ifdef DEBUG

void print_jmptab_list ()

{
struct jmptab_descr *tmp;

for (tmp = JmpTables; tmp != 0; tmp = tmp->Next)
  printf ("Jump table at %lx ref'd from %lx\n", tmp->Start, 
          tmp->ReferencingInstr);
}
#endif
