/*
 * Change history
 * $Log:	hunks.c,v $
 * Revision 3.0  93/09/24  17:54:01  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.3  93/07/28  23:37:15  Martin_Apel
 * Bug fix: Enabled null-sized data hunks
 * 
 * Revision 2.2  93/07/18  22:56:00  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.1  93/07/11  21:38:19  Martin_Apel
 * Major mod.: Jump table support tested and changed
 * 
 * Revision 2.0  93/07/01  11:54:04  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.26  93/07/01  11:40:58  Martin_Apel
 * 
 * Revision 1.25  93/06/19  12:09:01  Martin_Apel
 * Minor mod.: On relocation info reading, the previous word is now
 *             checked for JSR also, instead of for JMP only
 * 
 * Revision 1.24  93/06/06  13:46:43  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.23  93/06/06  00:12:03  Martin_Apel
 * Major mod.: Added support for library/device disassembly (option -dl)
 * 
 * Revision 1.22  93/06/03  20:28:10  Martin_Apel
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.21  93/06/03  18:32:46  Martin_Apel
 * Major mod.: Rewritten part of the hunk handling routines.
 *             Overlay files are now handled correctly
 * Minor mod.: Remove temporary files upon exit (even with CTRL-C)
 * 
 */

#include <exec/types.h>
#include <dos/doshunks.h>
#include <stdio.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: hunks.c,v 3.0 93/09/24 17:54:01 Martin_Apel Exp $";

long getlong ()

{
long res;

res = fgetc (in) << 24;
res |= fgetc (in) << 16;
res |= fgetc (in) << 8;
res |= fgetc (in);
f_offset += 4L;
return (res);
}

/*****************************************************************/

unsigned short getword ()

{
unsigned short res;

res = fgetc (in) << 8;
res |= fgetc (in);
f_offset += 2L;
return (res);
}

/*****************************************************************/

BOOL readfile ()

{
long hunk_type;

total_size = 0L;
current_hunk = 0;
f_offset = 0L;
hunk_type = getlong ();
if (hunk_type != HUNK_HEADER)
  {
  fprintf (stderr, "ERROR: File is not executable\n");
  return (FALSE);
  }

do
  {
  switch (hunk_type)
    {
    case HUNK_HEADER:  read_hunk_header (); break;
    case HUNK_OVERLAY: read_hunk_overlay (); break;
    case HUNK_BREAK:   break;                          /* Ignore BREAK hunk */
    default: fprintf (stderr, "ERROR: Unknown hunk type encountered\n");
             release_mem (hunk_start);
             return (FALSE);
    }
  hunk_type = getlong ();
  }
while (!feof (in));

if (pass2 && try_small && a4_offset == -1 && !warning_printed)
  {
  a4_offset = *(hunk_start + 1) + 0x7ffe;
  fprintf (stderr, "WARNING: A4 is probably not used for base register relative addressing\n");
  fprintf (stderr, "         Default address of hunk 1 plus 0x7ffe is used\n");
  fprintf (stderr, "         Try disassembling in large mode\n");
  warning_printed = TRUE;
  }

#ifdef AMIGA
if (pass2 && disasm_as_lib && !ROMTagFound)
  {
  fprintf (stderr, "ERROR: %s is not a library or device\n", input_filename);
  ExitADis ();
  }
#endif

if (pass3)
  release_mem (hunk_start);
return (TRUE);
}

/*****************************************************************/

BOOL read_hunk_header ()

{
long table_size,
     name_size,
     hunk_size,
     first_hunk,
     last_hunk,
     hunk_type;
int i;

name_size = getlong ();
for (i = 0; i < name_size; i++)
  getlong ();                      /* Not interested in resident libraries */

table_size = getlong ();
if (hunk_start == NULL)
  {
  hunk_start = get_mem (3 * table_size * sizeof (long));
  hunk_end = hunk_start + table_size;
  hunk_offset = hunk_end + table_size;
  num_hunks = table_size;
  }
else if (table_size > num_hunks)
  {
  fprintf (stderr, "ERROR: Invalid hunk structure\n");
  release_mem (hunk_start);
  return (FALSE);
  }

first_hunk = getlong ();
last_hunk = getlong ();
for (i = first_hunk; i <= last_hunk; i++)
  {
  hunk_size = (getlong () & 0x3fffffff) * 4;
  *(hunk_start + i) = total_size;
  total_size += hunk_size;
  *(hunk_end   + i) = total_size;
  if (pass1 && verbose)
    printf ("Hunk %d: Start: %lx, Length: %lx\n", i, *(hunk_start + i),
             hunk_size);
  }

for (i = first_hunk; i <= last_hunk; i++)
  {  
  /* Bit 30 means: load this hunk into chip ram,
     Bit 31 means: load this hunk into fast ram.
     We're not interested in this kind of information, so we mask it out */
  hunk_type = getlong () & 0x3fffffff;
  if (feof (in))
    {
    fprintf (stderr, "ERROR: Premature end in load file\n");
    release_mem (hunk_start);
    return (FALSE);
    }

  if (pass3)
    open_output_file ();

#ifdef DEBUG
  printf ("Reading hunk %d, type %lx\n", current_hunk, hunk_type);
#endif

  switch (hunk_type)
    {
    case HUNK_CODE   : if (!read_code_hunk ())
                         {
                         release_mem (hunk_start);
                         return (FALSE);
                         }
                       break;
    case HUNK_DATA   : if (!read_data_hunk ())
                         {
                         release_mem (hunk_start);
                         return (FALSE);
                         }
                       break;
    case HUNK_BSS    : if (!read_bss_hunk ())
                         {
                         release_mem (hunk_start);
                         return (FALSE);
                         }
                       break;
    case HUNK_END    : if (pass3)
                         close_output_file ();
                       return (TRUE);
    default: fprintf (stderr, "ERROR: Unknown hunk type encountered\n");
             release_mem (hunk_start);
             return (FALSE);
    }
  if (pass3)
    close_output_file ();
  current_hunk++;
  }
return (TRUE);
}

/*****************************************************************/

BOOL read_hunk_overlay ()

{
long table_size;

table_size = getlong ();
fseek (in, (table_size + 1) * 4L, SEEK_CUR);
f_offset += (table_size + 1) * 4L;
return (TRUE);
}

/*****************************************************************/

BOOL read_code_hunk ()

{
long hunk_size;
unsigned short *code_seg;
long type;
int i;
char filename_tmp [100];

if ((hunk_size = getlong ()) == 0)
  {
  if (getlong () == HUNK_END)
    return (TRUE);
  else
    return (FALSE);
  }

first_address = *(hunk_start + current_hunk);
last_address = first_address + hunk_size * 4;
*(hunk_offset + current_hunk) = f_offset;

if (!pass1)
  {
  /* Generate a unique filename */
  strcpy (filename_tmp, TMP_FILENAME);
  sprintf (filename_tmp + strlen (filename_tmp), "%lx", &current_address);
  sprintf (filename_tmp + strlen (filename_tmp), ".%d", current_hunk);
  if (!pass3)
    {
    if ((tmp_f = fopen (filename_tmp, "w")) == 0)
      {
      fprintf (stderr, "ERROR: Couldn't open temporary file\n");
      return (FALSE);
      }
    }
  else if (!disasm_quick)
    {
    if ((tmp_f = fopen (filename_tmp, "r")) == 0)
      {
      fprintf (stderr, "ERROR: Couldn't open temporary file\n");
      return (FALSE);
      }
    }
  }
else
  num_code_hunks++;

code_seg = get_mem (hunk_size * (4 + 4));
flags = (UBYTE*)(code_seg + hunk_size * 2);
for (i = 0; i < hunk_size; i++)
  *((long*)flags + i) = 0L;

if (fread (code_seg, 4, hunk_size, in) != hunk_size)
  {
  release_mem (code_seg);
  return (FALSE);
  }
f_offset += hunk_size * 4;

type = getlong ();
while (type != HUNK_END)
  {
  switch (type)
    { 
    case HUNK_RELOC32:
         read_reloc32_hunk (code_seg);
         type = getlong ();
         break;
    case HUNK_SYMBOL:
         read_symbol_hunk ();
         type = getlong ();
         break;
    case HUNK_DREL32:
    case HUNK_RELOC32SHORT:
         read_reloc16_hunk (code_seg);
         type = getlong ();
         break;
    default:
         fprintf (stderr, "ERROR: Hunk end missing\n");
         return (FALSE);
    }
  }

if (!pass1)
  {
  if (pass3 && !disasm_quick)
    fread (flags, hunk_size, 4, tmp_f);
  if (pass3)
    put ("                    CSEG\n\n");

#ifdef AMIGA
  if (disasm_as_lib && pass2 && !ROMTagFound)
    ROMTagFound = add_lib_labels (code_seg);
#endif

  disasm_code (code_seg, hunk_size * 4L);
  if (!pass3 && !disasm_quick)
    fwrite (flags, hunk_size, 4, tmp_f);
  }

release_mem (code_seg);
if (!pass1 && !disasm_quick)
  {
  fclose (tmp_f);
  tmp_f = NULL;
  if (pass3)
    remove (filename_tmp);
  }

if (pass3)
  {
  if (last_address != *(hunk_end + current_hunk))
    {
    first_address = current_address;
    last_address = *(hunk_end + current_hunk);
    disasm_bss ();
    }
  }
return (TRUE);
}

/*****************************************************************/

BOOL read_data_hunk ()

{
long hunk_size;
long type;
long i;
USHORT *data_seg;

hunk_size = getlong ();

first_address = *(hunk_start + current_hunk);
last_address = first_address + hunk_size * 4;
*(hunk_offset + current_hunk) = f_offset;

if (pass1)
  num_data_hunks++;

if (hunk_size != 0)
  {
  data_seg = get_mem (hunk_size * (4 + 4));
  flags = (UBYTE*)(data_seg + hunk_size * 2);
  for (i = 0; i < hunk_size; i++)
    *((long*)flags + i) = 0;
  
  if (fread (data_seg, 4, hunk_size, in) != hunk_size)
    {
    release_mem (data_seg);
    return (FALSE);
    }
  f_offset += hunk_size * 4;
  }

type = getlong ();
while (type != HUNK_END)
  {
  switch (type)
    {
    case HUNK_RELOC32:
         read_reloc32_hunk (data_seg);
         type = getlong ();
         break;
    case HUNK_SYMBOL:
         read_symbol_hunk ();
         type = getlong ();
         break;
    case HUNK_DREL32:
    case HUNK_RELOC32SHORT:
         read_reloc16_hunk (data_seg);
         type = getlong ();
         break;
    default:
         fprintf (stderr, "ERROR: Hunk end missing\n");
         return (FALSE);
    }
  }

if (pass3)
  {
  put ("                    DSEG\n\n");
  disasm_data ((UBYTE*)data_seg, hunk_size * 4);
  put ("\n");
  }

if (hunk_size != 0)
  release_mem (data_seg);

if (hunk_size * 4 < *(hunk_end + current_hunk) - *(hunk_start + current_hunk)
    && pass3)
  {
  /* The uninitialized data is part of the data segment.
     ==> There might be symbol information for the rest of the segment */
  first_address = current_address;
  last_address = *(hunk_end + current_hunk);
  disasm_bss ();
  }

return (TRUE);
}

/*****************************************************************/

BOOL read_bss_hunk ()

{
long hunk_size;
long type;

if ((hunk_size = getlong () * 4) == 0)
  {
  if (getlong () == HUNK_END)
    return (TRUE);
  else
    return (FALSE);
  }

first_address = *(hunk_start + current_hunk);
last_address = first_address + hunk_size;
*(hunk_offset + current_hunk) = f_offset;
current_address = first_address;

if (pass1)
  num_bss_hunks++;

if (pass3)
  {
  put ("                    DSEG\n\n");
  disasm_bss ();
  }

type = getlong ();
if (type == HUNK_END)
  return (TRUE);
else if (type == HUNK_SYMBOL)
  {
  read_symbol_hunk ();
  type = getlong ();
  if (type != HUNK_END)
    {
    fprintf (stderr, "ERROR: Hunk end missing\n");
    return (FALSE);
    }
  return (TRUE);
  }
fprintf (stderr, "ERROR: Hunk end missing\n");
return (FALSE);
}

/*****************************************************************/

BOOL read_symbol_hunk ()

{
long name_length;
char name [100];
ULONG *ptr;
int i;
ULONG reference;

while ((name_length = getlong ()) != 0)
  {
  ptr = (ULONG*)name;
  for (i = 0; i < name_length; i++)
    *ptr++ = getlong ();
  *ptr = 0;
  reference = *(hunk_start + current_hunk) + getlong (); 
  if ((reference >= *(hunk_start + current_hunk)) &&
       reference < *(hunk_end + current_hunk))
    enter_ref (reference, name, ACC_UNKNOWN);
  }
return (TRUE);
}

/*****************************************************************/

BOOL read_reloc32_hunk (USHORT *hunk)

{
long num_offsets;
long hunk_num;
long address;
long i;
long reference;
char label [100];

while ((num_offsets = getlong ()) != 0)
  {
  hunk_num = getlong ();      /* following is relocation info on hunk_num */
  /* gather information on labels defined within this hunk */
  for (i = 0; i < num_offsets; i++)
    {
    address = getlong ();     /* offset in current hunk */
    /* patch address, so we don't have to handle equal addresses in 
       different hunks */
    reference = 
         (*((ULONG*)(hunk + (address >> 1))) + *(hunk_start + hunk_num));

    *(flags + address) |= PERM_RELOC;
    *(flags + address + 1) |= PERM_RELOC;
    *(flags + address + 2) |= PERM_RELOC;
    *(flags + address + 3) |= PERM_RELOC;

    if (reference >= *(hunk_start + hunk_num) &&
        reference < *(hunk_end + hunk_num))
      {
      /* JMP or JSR opcode there ? */
      if ((*(hunk + (address >> 1) - 1) == 0x4ef9) || 
          (*(hunk + (address >> 1) - 1) == 0x4eb9))
        enter_ref (reference, 0L, ACC_CODE);
      else
        enter_ref (reference, 0L, ACC_UNKNOWN);
      *((ULONG*)(hunk + (address >> 1))) = reference;

      if (pass3 && !single_file && 
          ((long)reference < (long)first_address || reference >= last_address) &&
          !try_small)
        gen_xref (reference);
      }
    else if (!pass1)              /* symbol hunks have been read in */
      {
      /* reference relative to start of hunk */
      gen_label (label, *(hunk_start + hunk_num), TRUE);
      strcat (label, "+");
      format_ld (label + strlen (label), reference - *(hunk_start + hunk_num), TRUE);
      reference = ext_enter_ref (reference, hunk_num, label, ACC_UNKNOWN);
      /* The following must be explicitly entered, so we have something
         to refer to */
      enter_ref (*(hunk_start + hunk_num), 0L, ACC_UNKNOWN);
      *((ULONG*)(hunk + (address >> 1))) = reference;
      }

    if (address > 0 && pass1 && try_small &&
        *(hunk + (address >> 1) - 1) == 0x49f9)        /* LEA  $xxx.L,A4 */
      {
      if (a4_offset != -1 && a4_offset != reference && !warning_printed)
        {
        fprintf (stderr, "WARNING: A4 is probably not used for base register relative addressing\n");
        fprintf (stderr, "         Try disassembling in large mode\n");
        warning_printed = TRUE;
        }
      a4_offset = reference;
      }
    }
  }
return (TRUE);
}

/*****************************************************************/

BOOL read_reloc16_hunk (USHORT *hunk)

{
short num_offsets;
short hunk_num;
long address;
long i;
long reference;
char label [100];

while ((num_offsets = getword ()) != 0)
  {
  hunk_num = getword ();      /* following is relocation info on hunk_num */

#ifdef DEBUG
  printf ("Reading reloc16 for hunk %d. Num_offsets = %d\n", hunk_num, num_offsets);
#endif

  /* gather information on labels defined within this hunk */
  for (i = 0; i < num_offsets; i++)
    {
    address = getword ();     /* offset in current hunk */
    /* patch address, so we don't have to handle equal addresses in 
       different hunks */
    reference = 
         (*((ULONG*)(hunk + (address >> 1))) + *(hunk_start + hunk_num));

    *(flags + address) |= PERM_RELOC;
    *(flags + address + 1) |= PERM_RELOC;
    *(flags + address + 2) |= PERM_RELOC;
    *(flags + address + 3) |= PERM_RELOC;

    if (reference >= *(hunk_start + hunk_num) &&
        reference < *(hunk_end + hunk_num))
      {
      /* JMP or JSR opcode there ? */
      if ((*(hunk + (address >> 1) - 1) == 0x4ef9) || 
          (*(hunk + (address >> 1) - 1) == 0x4eb9))
        enter_ref (reference, 0L, ACC_CODE);
      else
        enter_ref (reference, 0L, ACC_UNKNOWN);
      *((ULONG*)(hunk + (address >> 1))) = reference;

      if (pass3 && !single_file && 
          ((long)reference < (long)first_address || reference >= last_address) &&
          !try_small)
        gen_xref (reference);
      }
    else if (!pass1)              /* symbol hunks have been read in */
      {
      /* reference relative to start of hunk */
      gen_label (label, *(hunk_start + hunk_num), TRUE);
      strcat (label, "+");
      format_ld (label + strlen (label), reference - *(hunk_start + hunk_num), TRUE);
      reference = ext_enter_ref (reference, hunk_num, label, ACC_UNKNOWN);
      /* The following must be explicitly entered, so we have something
         to refer to */
      enter_ref (*(hunk_start + hunk_num), 0L, ACC_UNKNOWN);
      *((ULONG*)(hunk + (address >> 1))) = reference;
      }

    if (address > 0 && pass1 && try_small &&
        *(hunk + (address >> 1) - 1) == 0x49f9)        /* LEA  $xxx.L,A4 */
      {
      if (a4_offset != -1 && a4_offset != reference && !warning_printed)
        {
        fprintf (stderr, "WARNING: A4 is probably not used for base register relative addressing\n");
        fprintf (stderr, "         Try disassembling in large mode\n");
        warning_printed = TRUE;
        }
      a4_offset = reference;
      }
    }
  }

if ((f_offset & 0x3) != NULL)
  getword ();                 /* To make it long aligned */
return (TRUE);
}
