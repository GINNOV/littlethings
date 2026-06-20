/*
 * Change history
 * $Log:	util.c,v $
 * Revision 3.0  93/09/24  17:54:29  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.3  93/07/18  22:56:58  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.2  93/07/10  13:02:35  Martin_Apel
 * Major mod.: Added full jump table support. Seems to work quite well
 * 
 * Revision 2.1  93/07/08  22:29:31  Martin_Apel
 * 
 * Minor mod.: Displacements below 4 used with pc indirect indexed are
 *             not entered into the symbol table anymore
 * 
 * Revision 2.0  93/07/01  11:54:56  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.17  93/07/01  11:45:00  Martin_Apel
 * Minor mod.: Removed $-sign from labels
 * Minor mod.: Prepared for tabs instead of spaces
 * 
 * Revision 1.16  93/06/16  20:31:31  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * 
 * Revision 1.15  93/06/04  11:56:35  Martin_Apel
 * New feature: Added -ln option for generation of ascending label numbers
 * 
 * Revision 1.14  93/06/03  20:30:17  Martin_Apel
 * Minor mod.: Additional linefeed generation for end instructions has been
 *             moved to format_line
 * New feature: Added -a switch to generate comments for file offsets
 * 
 * Revision 1.13  93/05/27  20:50:48  Martin_Apel
 * Bug fix: Register list was misinterpreted for MOVEM / FMOVEM
 *          instructions.
 * 
 */

#include <exec/types.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "defs.h"
#include "string_recog.h"

static char rcsid [] =  "$Id: util.c,v 3.0 93/09/24 17:54:29 Martin_Apel Exp $";

/**********************************************************************/
/*      A few routines doing string handling such as formatting       */
/*        a hex value, formatting the register list for MOVEM         */
/*              instructions, different address modes...              */
/*        sprintf would have been much easier but sloooow !!!         */
/**********************************************************************/

PRIVATE char hex_chars [] = "0123456789ABCDEF";

/**************************************************************************/

char *format_d (char *where, short val, BOOL sign)

{
char stack [10],
     *sp;
register ULONG my_val;

if (val < 0 && sign)
  {
  my_val = ((ULONG) -val) & 0xffff;
  *where++ = '-';
  }
else
  my_val = (ULONG) val & 0xffff;

sp = stack;
while (my_val != 0)
  {
  *sp++ = my_val & 0xf;          /* MOD 16 */
  my_val = my_val >> 4;          /* DIV 16 */
  }

*where++ = '$';
if (sp == stack)
  /* value is zero */
  *where++ = '0';
else
  {
  do
    *where++ = hex_chars [*(--sp)];
  while (sp != stack);
  }
*where = 0;
return (where);
}

/**************************************************************************/

char *format_ld  (char *where, long val, BOOL sign)

{
char stack [15],
     *sp;
register ULONG my_val;

if (val < 0 && sign)
  {
  my_val = (ULONG) -val;
  *where++ = '-';
  }
else
  my_val = (ULONG) val;

sp = stack;
while (my_val != 0)
  {
  *sp++ = my_val & 0xf;          /* MOD 16 */
  my_val = my_val >> 4;          /* DIV 16 */
  }


*where++ = '$';
if (sp == stack)
  /* value is zero */
  *where++ = '0';
else
  {
  do
    *where++ = hex_chars [*(--sp)];
  while (sp != stack);
  }
*where = 0;
return (where);
}

/**************************************************************************/

char *format_ld_no_dollars  (char *where, long val, BOOL sign)

/* The same as format_ld but without the dollar sign */

{
char stack [15],
     *sp;
register ULONG my_val;

if (val < 0 && sign)
  {
  my_val = (ULONG) -val;
  *where++ = '-';
  }
else
  my_val = (ULONG) val;

sp = stack;
while (my_val != 0)
  {
  *sp++ = my_val & 0xf;          /* MOD 16 */
  my_val = my_val >> 4;          /* DIV 16 */
  }


if (sp == stack)
  /* value is zero */
  *where++ = '0';
else
  {
  do
    *where++ = hex_chars [*(--sp)];
  while (sp != stack);
  }
*where = 0;
return (where);
}

/**************************************************************************/

void format_reg_list (char *where, unsigned short list, BOOL incr_list,
                      short reglist_offset)

{
register int i;
register long mylist;                 /* list in order a7-a0/d7-d0 */
short last_set;
BOOL regs_used;

if (!incr_list)
  {
  mylist = 0;
  for (i = 0; i < 16; i++)
    {
    if (list & (1 << i))
      mylist |= 1 << (15 - i);
    }
  }
else
  mylist = list;

last_set = -1;
regs_used = FALSE;
for (i = 0; i < 17; i++)
  {
  if ((mylist & (1 << i)) && last_set == -1)
    {
    if (regs_used)
      strcat (where, "/");
    strcat (where, reg_names [i + reglist_offset]);
    last_set = i;
    regs_used = TRUE;
    }
  else if (!(mylist & (1 << i)))
    {
    if (last_set == i - 1)
      last_set = -1;
    else if (last_set != -1)
      {
      strcat (where, "-");
      strcat (where, reg_names [i - 1 + reglist_offset]);
      last_set = -1;
      }
    }
  if (i == 7 && (mylist & 0x180) == 0x180)
    {
    if (last_set != 7) 
      /* d7 and a0 both used and still in a list */
      {
      strcat (where, "-");
      strcat (where, reg_names [7 + reglist_offset]);
      }
    last_set = -1;
    }      
  }
}

/**************************************************************************/

char *immed (char *to, long val)

{
/* e.g. #$17 */

*to++ = '#';
return (format_ld (to, val, FALSE));
}

/**************************************************************************/

void pre_dec (char *to, short reg_num)

{
/* e.g. -(A1) */

PRIVATE char *template = "-(  )";

strcpy (to, template);
strcpy (to + 2, reg_names [reg_num]);
*(to + 4) = ')';
}

/**************************************************************************/

void post_inc (char *to, short reg_num)

{
/* e.g. (A2)+ */

PRIVATE char *template = "(  )+";

strcpy (to, template);
strcpy (to + 1, reg_names [reg_num]);
*(to + 3) = ')';
}

/**************************************************************************/

void indirect (char *to, short reg_num)

{
/* e.g. (A1) */

*to++ = '(';
*to++ = *(reg_names [reg_num]);
*to++ = *(reg_names [reg_num] + 1);
*to++ = ')';
*to = 0;
}

/**************************************************************************/

void disp_an (char *to, short reg_num, short disp)

{
/* e.g. 4(A0) */

to = format_d (to, disp, TRUE);
*to++ = '(';
*to++ = *(reg_names [reg_num]);
*to++ = *(reg_names [reg_num] + 1);
*to++ = ')';
*to = 0;
}

/**************************************************************************/

void disp_an_indexed (char *to, short an, char disp, short index_reg, 
                      short scale, short size)

{
/* e.g. 4(A0,D0.W*4) */

PRIVATE char *template = "(  ,  .W* )";

if (an == PC && !((*code & 0xffc0) == 0x4ec0))
  {
  /* Don't generate label for JMP instruction */
  gen_label (to, current_address + 2 + disp, TRUE);
  while (*(++to));
  }
else
  to = format_d (to, (short)disp, TRUE);
strcpy (to, template);
strcpy (to + 1, reg_names [an]);
*(to + 3) = ',';
strcpy (to + 4, reg_names [index_reg]);
*(to + 6) = '.';
if (size == ACC_LONG)
  *(to + 7) = 'L';
if (scale == 1)
  {
  *(to + 8) = ')';
  *(to + 9) = 0;
  }
else
  *(to + 9) = scale + '0';
}

/**************************************************************************/

int full_extension (char *to, UWORD *extension, short mode, short reg)

{
/* Who did come up with these complicated addressing modes ? */
/* Does anybody ever use them ? */

short base_disp_size,
      outer_disp_size;
char index_reg [10],
     base_reg [10],
     base_disp [80],
     outer_disp [15],
     tmp_string [10];
short scale;
int next_extension_word = 1;
int type;

/* check for validity of extension word */
if ((*extension & 0x0008) || !(*extension & 0x0030) || 
    (*extension & 0x0007) == 0x0004 ||
    ((*extension & 0x0007) >= 4 && (*extension & 0x0040)))
  {
  detected_illegal = TRUE;
  return (0);
  }

base_disp_size = (*extension & 0x0030) >> 4;
outer_disp_size = (*extension & 0x0003);


/* generate string for index register */
strcpy (index_reg, reg_names [*extension >> 12]);
if (*extension & 0x0800)
  strcat (index_reg, ".L");
else
  strcat (index_reg, ".W");
scale = 1 << ((*extension & 0x0600) >> 9);
if (scale != 1)
  {
  sprintf (tmp_string, "*%d", scale);
  strcat (index_reg, tmp_string);
  }

/* generate string for base register */
if (mode == 7)
  {
  /* PC memory indirect */
  strcpy (base_reg, reg_names [PC]);
  }
else
  strcpy (base_reg, reg_names [reg + 8]);

/* generate string for base displacement */
switch (base_disp_size)
  {
  case 1: /* Null displacement */
    strcpy (base_disp, "0");
    break;
  case 2: /* Word displacement */
    if (mode == 7)                      /* PC relative */
      {
      if (pass2)
        enter_ref (current_address + 2 + *(extension + next_extension_word++),
                   NULL, ACC_UNKNOWN);
      else
        gen_label (base_disp, 
                   current_address + 2 + *(extension + next_extension_word++),
                   TRUE);
      }
    else
      format_d (base_disp, *(extension + next_extension_word++), TRUE);
    break;
  case 3: /* Long displacement */
    if (mode == 7)                      /* PC relative */
      {
      if (pass2)
        enter_ref (current_address + 2 + 
                   (*(extension + next_extension_word) << 16) +
                    *(extension + next_extension_word + 1),
                   NULL, ACC_UNKNOWN);
      else
        gen_label (base_disp, 
                   current_address + 2 + 
                   (*(extension + next_extension_word) << 16) +
                    *(extension + next_extension_word + 1),
                   TRUE);
      }
    else
      format_ld (base_disp, (*(extension + next_extension_word) << 16) +
                 *(extension + next_extension_word + 1), TRUE);
    next_extension_word += 2;
    break;
  }

/* generate string for outer displacement */
switch (outer_disp_size)
  {
  case 1: /* Null displacement */
    strcpy (outer_disp, "0");
    break;
  case 2: /* Word displacement */
    format_d (outer_disp, *(extension + next_extension_word++), TRUE);
    break;
  case 3: /* Long displacement */
    format_ld (outer_disp, (*(extension + next_extension_word) << 16) +
               *(extension + next_extension_word + 1), TRUE);
    next_extension_word += 2;
    break;
  }

type = ((*extension & 0x00c0) >> 3) | (*extension & 0x0007);
switch (type)
  {
  case 0x00: sprintf (to, "%s(%s,%s)", base_disp, base_reg, index_reg); break;
  case 0x01:
  case 0x02:
  case 0x03: sprintf (to, "([%s,%s,%s],%s)", base_disp, base_reg, 
                      index_reg, outer_disp); break;
  case 0x05:
  case 0x06:
  case 0x07: sprintf (to, "([%s,%s],%s,%s)", base_disp, base_reg, 
                   index_reg, outer_disp); break;
  case 0x08: sprintf (to, "%s(%s)", base_disp, base_reg); break;
  case 0x09:
  case 0x0a:
  case 0x0b: sprintf (to, "([%s,%s],%s)", base_disp, base_reg, outer_disp); break;

  /* base register suppressed */
  case 0x10: sprintf (to, "%s(%s)", base_disp, index_reg); break;
  case 0x11:
  case 0x12:
  case 0x13: sprintf (to, "([%s,%s],%s)", base_disp, index_reg, 
                      outer_disp); break;
  case 0x15:
  case 0x16:
  case 0x17: sprintf (to, "([%s],%s,%s)", base_disp, index_reg, 
                      outer_disp); break;
  case 0x18: sprintf (to, "%s", base_disp); break;
  case 0x19:
  case 0x1a:
  case 0x1b: sprintf (to, "([%s],%s)", base_disp, outer_disp); break;

  default: fprintf (stderr, "INTERNAL ERROR: full_extension: illegal addressing mode\n");
           fprintf (stderr, "    Current address is: %lx\n", current_address);
  }

return (next_extension_word);
}

/**************************************************************************/

void format_line_spaces (BOOL labeled, BOOL commented)

{
register char *tmp;
register char blank = ' ';

gen_label (instruction, current_address, labeled);
for (tmp = instruction; *tmp != 0; tmp++);
if (tmp != instruction)
  /* a label has been generated */
  *tmp++ = ' ';
while (tmp - instruction < OPCODE_COL)
  *tmp++ = blank;
strcpy (tmp, opcode);

if (!(src [0] == 0 && dest [0] == 0))
  {
  while (*(++tmp));          /* scan to end of string */
  while (tmp - instruction < PARAM_COL)
    *tmp++ = blank;
  if (dest [0] == 0)
    strcpy (tmp, src);
  else if (src [0] == 0)
    strcpy (tmp, dest);
  else
    {
    strcpy (tmp, src);
    while (*(++tmp));         /* scan to end of string */
    *tmp++ = ',';
    strcpy (tmp, dest);
    }
  }

if (add_file_offset && commented)
  {
  while (*(++tmp));         /* scan to end of string */
  while (tmp - instruction < COMMENT_COL)
    *tmp++ = blank;
  *tmp++ = ';';
  *tmp++ = blank;
  format_ld (tmp, current_address - first_address + 
             *(hunk_offset + current_hunk), FALSE);
  }

strcat (tmp, "\n");
if (end_instr)
  strcat (tmp, "\n");
}

/**************************************************************************/

int gen_label (char *where_to, ULONG ref, BOOL anyway)

/* returns the access type for the reference, if none is found returns
   NO_ACCESS */
{
char *label;
UWORD access;

if (find_reference (ref, &label, &access))
  {
  if (label != 0)
    strcpy (where_to, label);
  else
    {
    *where_to++ = 'L';
    format_ld_no_dollars (where_to, ref, FALSE);
    }
  return ((int)access);
  }
else if (anyway)
  {
  *where_to++ = 'L';
  format_ld_no_dollars (where_to, ref, FALSE);
  }
else
  *where_to = 0;
return (NO_ACCESS);
}

/**************************************************************************/

BOOL is_string (char *maybe_string, ULONG max_len)

{
register unsigned char *tmp;
char *last_char;

/* Strings must not cross label boundaries */
last_char = maybe_string + max_len;
tmp = (unsigned char*) maybe_string;
while (*tmp != 0 && IS_VALID (*tmp))
  tmp++;
if (*tmp == 0 && tmp < (unsigned char*)last_char &&
    (char*)tmp != maybe_string)    /* Don't let single 0 characters be */
                                   /* disassembled as strings */
  return (TRUE);
return (FALSE);
}

/**************************************************************************/

void put (char *string)

{
#ifdef DEBUG
if (out == NULL)
  {
  fprintf (stderr, "INTERNAL ERROR: put: Attempt to write to closed file\n");
  ExitADis ();
  }
#endif

if (fputs (string, out) == EOF)
  {
  fprintf (stderr, "\nError writing output file\n");
  ExitADis ();
  }
}

/**************************************************************************/

void mark_entry_illegal (int entry)

{
struct opcode_entry *op;

op = &(opcode_table [entry]);
op->handler = illegal;
op->mnemonic = "ILLEGAL";
op->modes = op->submodes = 0xff;
}

/**************************************************************************/

char *cpstr (char *dest, char *src, int max_len)

/* returns NULL, if the whole string fitted into max_len characters.
   Otherwise a pointer is to the first character in "src" is passed,
   which didn't fit in */
{
register char *from,
              *to;
register BOOL last_was_printable;
int chars_used = 0;

last_was_printable = FALSE;

for (from = src, to = dest; *from != 0 && chars_used < max_len; from++)
  {
  if (IS_PRINTABLE (((UBYTE)*from)))
    {
    if (!last_was_printable)
      {
      *to++ = '"';
      last_was_printable = TRUE;
      chars_used++;
      }
    *to++ = *from;
    chars_used++;
    }
  else 
    {
    if (last_was_printable)
      {
      *to++ = '"';
      *to++ = ',';
      chars_used += 2;
      last_was_printable = FALSE;
      }
    to = format_d (to, (short)((UBYTE)*from), FALSE);
    chars_used = strlen (dest) + 1;
    *to++ = ',';
    }
  }
if (chars_used < max_len)
  {
  if (last_was_printable)
    {
    *to++ = '"';
    *to++ = ',';
    }
  *to++ = '0';
  *to = 0;
  return (NULL);
  }
else
  {
  if (last_was_printable)
    *to++ = '"';
  else 
    to--;
  *to = 0;
  return (from);
  }
}

/**************************************************************************/

void gen_xref (ULONG address)

{
register char *tmp;
register char blank = ' ';

tmp = instruction;
while (tmp - instruction < OPCODE_COL)
  *tmp++ = blank;
strcpy (tmp, "XREF");
while (*(++tmp));          /* scan to end of string */

while (tmp - instruction < PARAM_COL)
  *tmp++ = blank;

gen_label (tmp, address, TRUE);
strcat (tmp, "\n");
put (instruction);
}

/**************************************************************************/

void assign_label_names (void)

/**********************************************************************/
/*   Assigns each label an ascending number instead of its address    */
/**********************************************************************/
{
long label_count = 1;
char label_name [20];
UWORD access;
char *old_name;

current_address = 0L;
label_name [0] = 'L';

while ((current_address = next_reference (current_address, total_size, &access))
                != total_size)
  {
  find_reference (current_address, &old_name, &access);
  if (old_name == NULL)
    {
    format_ld_no_dollars (label_name + 1, label_count++, FALSE);
    enter_ref (current_address, label_name, access);
    }
  }

current_address = 0L;
}
