/*
 * Change history
 * $Log:	amiga.c,v $
 * Revision 3.0  93/09/24  17:52:53  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.3  93/07/18  22:55:33  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.2  93/07/13  11:39:26  Martin_Apel
 * Bug fix: user_aborted_analysis now resets CTRL-D signal upon abortion
 * 
 * Revision 2.1  93/07/08  20:46:06  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:53:34  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.5  93/06/06  00:07:25  Martin_Apel
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.4  93/06/03  18:20:27  Martin_Apel
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C)
 * 
 */

static char rcsid [] = "$Id: amiga.c,v 3.0 93/09/24 17:52:53 Martin_Apel Exp $";

#include <exec/types.h>
#include "defs.h"

#ifdef AMIGA
#include <exec/resident.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

/******************************************************************/

BOOL user_aborted_analysis ()

{
if (SetSignal (0L, SIGBREAKF_CTRL_D) & SIGBREAKF_CTRL_D)
  {
  fprintf (stderr, "Analysis aborted...\n");
  return (TRUE);
  }
return (FALSE);
}

/******************************************************************/

void delete_tmp_files ()

{
char command [40];

/* See hunks.c for generation of tmp file name */
sprintf (command, "delete %s%lx#? >nil:", TMP_FILENAME, &current_address);
Execute ((UBYTE*)command, NULL, NULL);
}

/******************************************************************/

static void mark_as_long (void *address)

{
/**********************************************************************/
/*     Address points into the code area. mark_as_long marks the      */
/*     corresponding place in the flags array as data. If written     */
/*        directly into disasm_as_lib, it clutters up the code        */
/**********************************************************************/

*((ULONG*)(flags + ((UBYTE*)address - (UBYTE*)code))) |=
      TMP_DATA | (TMP_DATA << 8) | (TMP_DATA << 16) | (TMP_DATA << 24);
}

/******************************************************************/

static void mark_as_word (void *address)

{
*((UWORD*)(flags + ((UBYTE*)address - (UBYTE*)code))) |= 
     TMP_DATA | (TMP_DATA << 8);
}

/******************************************************************/

static void process_func_table_l (ULONG *func_table, UBYTE type)

{
int i;
char label_name [20];

enter_ref (*func_table,       "Open", ACC_CODE);    mark_as_long (func_table);
enter_ref (*(func_table + 1), "Close", ACC_CODE);   mark_as_long (func_table + 1);
enter_ref (*(func_table + 2), "Expunge", ACC_CODE); mark_as_long (func_table + 2);
enter_ref (*(func_table + 3), "Null", ACC_CODE);    mark_as_long (func_table + 3);

if (type == NT_DEVICE)
  { 
  enter_ref (*(func_table + 4), "BeginIO", ACC_CODE);
  mark_as_long (func_table + 4);
  enter_ref (*(func_table + 5), "AbortIO", ACC_CODE);
  mark_as_long (func_table + 5);
  }
else
  {
  for (i = 4; *(func_table + i) != 0xffffffff; i++)
    {
    sprintf (label_name, "Func%d", i - 4);
    enter_ref (*(func_table + i), label_name, ACC_CODE);
    mark_as_long (func_table + i);
    }
  }
}

/******************************************************************/

static void process_func_table_w (UWORD *func_table, UBYTE type)

{
int i;
char label_name [20];
/* relative to start of function table */
ULONG base = (ULONG)((UBYTE*)func_table - (UBYTE*)code) - 2 + first_address;

enter_ref (base + *func_table,       "Open", ACC_CODE);
mark_as_word (func_table);
enter_ref (base + *(func_table + 1), "Close", ACC_CODE);   
mark_as_word (func_table + 1);
enter_ref (base + *(func_table + 2), "Expunge", ACC_CODE); 
mark_as_word (func_table + 2);
enter_ref (base + *(func_table + 3), "Null", ACC_CODE);    
mark_as_word (func_table + 3);

if (type == NT_DEVICE)
  { 
  enter_ref (base + *(func_table + 4), "BeginIO", ACC_CODE);
  mark_as_word (func_table + 4);

  enter_ref (base + *(func_table + 5), "Abort", ACC_CODE);
  mark_as_word (func_table + 5);
  }
else
  {
  for (i = 4; *(func_table + i) != 0xffff; i++)
    {
    sprintf (label_name, "Func%d", i - 4);
    enter_ref (base + *(func_table + i), label_name, ACC_CODE);
    mark_as_word (func_table + i);
    }
  }
}

/******************************************************************/

BOOL add_lib_labels (UWORD *code_seg)

{
/*
The  first  code  hunk  has  been read in.  We expect to find a ROMTag
structure at the start of the segment.
*/
UWORD *code_ptr;
struct Resident *LibHeader;
UBYTE type;
ULONG *data_table,
      *func_table,
      *init_table;
ULONG i;

code = code_seg;
for (code_ptr = code_seg, current_address = first_address; 
     *code_ptr != RTC_MATCHWORD && current_address < last_address;
     code_ptr++, current_address += 2);

if (*code_ptr != RTC_MATCHWORD)
  return (FALSE);

LibHeader = (struct Resident*)code_ptr;
if ((ULONG)LibHeader->rt_MatchTag != current_address)
  return (FALSE);

/* Mark ROMTag structure as data */

for (i = 0; i < sizeof (struct Resident); i++)
  *(flags + current_address - first_address + i) |= TMP_DATA;

type = LibHeader->rt_Type;
enter_ref (current_address, "ROMTag", (UWORD)(ACC_DATA | ACC_WORD));
enter_ref (current_address + (long)&(LibHeader->rt_Flags) - (long)LibHeader, 
           "Flags", (UWORD)(ACC_DATA | ACC_BYTE));
enter_ref (current_address + (long)&(LibHeader->rt_Version) - (long)LibHeader, 
           "Version", (UWORD)(ACC_DATA | ACC_BYTE));
enter_ref (current_address + (long)&(LibHeader->rt_Type) - (long)LibHeader, 
           "Type", (UWORD)(ACC_DATA | ACC_BYTE));
enter_ref (current_address + (long)&(LibHeader->rt_Pri) - (long)LibHeader, 
           "Pri", (UWORD)(ACC_DATA | ACC_BYTE));
enter_ref (current_address + (long)&(LibHeader->rt_Name) - (long)LibHeader, 
           "Name", (UWORD)(ACC_DATA | ACC_LONG));
enter_ref (current_address + (long)&(LibHeader->rt_IdString) - (long)LibHeader,
           "IdString", (UWORD)(ACC_DATA | ACC_LONG));
if (!(LibHeader->rt_Flags & RTF_AUTOINIT))
  {
  /* rt_Init points to init routine */
  enter_ref ((ULONG)LibHeader->rt_Init, "Init", ACC_CODE);
  save_flags ();
  return (TRUE);
  }

/* 
rt_Init points to data structure. The second longword is a pointer to
a function table, the third a pointer to a data table, and the fourth
a pointer to an init routine
*/
init_table = (ULONG*)((UBYTE*)code_seg + (long)(LibHeader->rt_Init) 
               - first_address);
mark_as_long (init_table);
mark_as_long (init_table + 1);
mark_as_long (init_table + 2);
mark_as_long (init_table + 3);
enter_ref (*(init_table + 3), "Init", ACC_CODE);

/* Maybe func_table is zero */
if (IS_RELOCATED ((ULONG)LibHeader->rt_Init + 4))
  {
  func_table = (ULONG*)((UBYTE*)code_seg + *(init_table + 1) - first_address);
  if (*((UWORD*)func_table) == 0xffff)
    process_func_table_w (((UWORD*)func_table) + 1, type);
  else
    process_func_table_l (func_table, type);
  }

/* Maybe data_table is zero */
if (IS_RELOCATED ((ULONG)LibHeader->rt_Init + 8))
  {
  /* It's quite difficult to find the end of the data table without
     using InitStruct. So I just mark the first word as data and
     leave the rest to the analysis pass */
  data_table = (ULONG*)((UBYTE*)code_seg + *(init_table + 2) - first_address);
  mark_as_word (data_table);
  }

save_flags ();
return (TRUE);
}

#else


BOOL user_aborted_analysis ()

{
return (FALSE);
}

/******************************************************************/

void delete_tmp_files ()

{
}

#endif
