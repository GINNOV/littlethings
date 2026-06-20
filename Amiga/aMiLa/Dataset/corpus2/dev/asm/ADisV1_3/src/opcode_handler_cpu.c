/*
 * Change history
 * $Log:	opcode_handler_cpu.c,v $
 * Revision 3.0  93/09/24  17:54:12  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.2  93/07/18  22:56:17  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.1  93/07/08  20:48:55  Martin_Apel
 * Minor mod.: Disabled internal error message in non-debugging version
 * 
 * Revision 2.0  93/07/01  11:54:21  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.14  93/07/01  11:41:49  Martin_Apel
 * Minor mod.: Now checks for zero upper byte on using CCR
 * 
 * Revision 1.13  93/06/16  20:28:56  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.12  93/06/06  13:47:17  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.11  93/06/03  20:28:42  Martin_Apel
 * Minor mod.: Additional linefeed generation for end instructions has been
 *             moved to format_line
 * 
 * Revision 1.10  93/05/27  20:47:51  Martin_Apel
 * Bug fix: Register list was misinterpreted for MOVEM / FMOVEM
 *          instructions.
 * 
 */

#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: opcode_handler_cpu.c,v 3.0 93/09/24 17:54:12 Martin_Apel Exp $";

/**********************************************************************/

int bit_reg (struct opcode_entry *op)

{
if (pass3)
  strcpy (src, reg_names [op->param]);

if (MODE_NUM (*code) == 0)         /* data register */
  {
  if (pass3)
    {
    strcat (opcode, ".L");
    strcpy (dest, reg_names [REG_NUM (*code)]);
    }
  return (1);
  }
else
  {
  if (pass3)
    strcat (opcode, ".B");
  return (decode_ea (MODE_NUM (*code), REG_NUM (*code), 
          dest, ACC_BYTE, (short)1) + 1);
  }
}

/**********************************************************************/

int bit_mem (struct opcode_entry *op)

{
if (pass3)
  {
  src [0] = '#';
  format_d (src + 1, (short)*(code + 1), FALSE);
  }

if (MODE_NUM (*code) == 0)         /* data register */
  {
  if (pass3)
    {
    strcat (opcode, ".L");
    strcpy (dest, reg_names [REG_NUM (*code)]);
    }
  return (2);
  }
else
  {
  if (pass3)
    strcat (opcode, ".B");
  return (decode_ea (MODE_NUM (*code), REG_NUM(*code), 
          dest, ACC_BYTE, (short)2) + 2);
  }
}

/**********************************************************************/

int move (struct opcode_entry *op)

{
short used;

used = decode_ea (MODE_NUM (*code), REG_NUM (*code), src, op->param, (short)1);
used += decode_ea ((short)((*code >> 6) & 0x7), 
                   (short)((*code >> 9) & 0x7), dest, op->param, (short)(used + 1));
return (1 + used);
}

/**********************************************************************/

int movem (struct opcode_entry *op)

{
char *reg_list;
int used;
BOOL incr_list;          /* Reglist starts with D0 in bit 0 */


if (op->param == MEM)
  {
  /* Transfer registers to memory */
  reg_list = src;
  used = decode_ea (MODE_NUM (*code), REG_NUM (*code), dest,
                    ACC_DATA, (short)2);
  }
else
  {
  reg_list = dest;
  used = decode_ea (MODE_NUM (*code), REG_NUM (*code), src,
                    ACC_DATA, (short)2);
  }

incr_list = (MODE_NUM (*code) != 4);         /* predecr mode */


if (pass3)
  {
  format_reg_list (reg_list, (unsigned short)(*(code + 1)), incr_list, (short)0);
  if (*reg_list == 0)
    {
    /* some compilers generate empty reg lists for movem instructions */
    *reg_list = ' ';
    *(reg_list + 1) = 0;
    }
  }

return (2 + used);
}

/**********************************************************************/

int srccr   (struct opcode_entry *op)

{
/* Only possible from ANDI, ORI, EORI */
if (pass3)
  {
  strcpy (opcode, opcode_table [*code >> 6].mnemonic);
  strcpy (dest, special_regs [(*code & 0x0040) ? SR : CCR]);
  /* Check for zero upper byte, if reg == CCR */
  if (!(*code & 0x0040) && (*(code + 1) & 0xff00))
    return (TRANSFER);    
  immed (src, (long)(*(code + 1) & 0xffff));
  }
return (2);
}

/**********************************************************************/

int special (struct opcode_entry *op)

{
/* move usp,     10dxxx
   trap,         00xxxx
   unlk,         011xxx
   link.w        010xxx

   reset,        110000
   nop,          110001
   stop,         110010
   rte,          110011
   rtd,          110100
   rts,          110101
   trapv         110110
   rtr,          110111

   movec,        11101d
*/

char *ptr;
int used = 1;

if ((*code & 0x38) == 0x30)
  {
  switch (*code & 0xf)
    {
    case 0: ptr = "RESET";
            break;
    case 1: ptr = "NOP";
            break;
    case 2: ptr = "STOP";
            if (pass3)
              immed (src, (long)*(code + 1));
            used = 2;
            break;
    case 3: ptr = "RTE";
            end_instr = TRUE;
            break;
    case 4: if (!mc68020)
              return (TRANSFER);
            ptr = "RTD";
            end_instr = TRUE;
            if (pass3)
              {
              src [0] = '#';
              format_d (src + 1, (short)*(code + 1), FALSE);
              }
            used = 2;
            break;
    case 5: ptr = "RTS";
            end_instr = TRUE;
            break;
    case 6: ptr = "TRAPV";
            break;
    case 7: if (!mc68020)
              return (TRANSFER);
            ptr = "RTR";
            end_instr = TRUE;
            break;
    }
  if (pass3)
    strcpy (opcode, ptr);
  return (used);
  }
else if ((*code & 0x3e) == 0x3a)          /* MOVEC */
  {
  short reg_offset;

  if (!mc68020)
    return (TRANSFER);
  switch (*(code + 1) & 0xfff)
    {
    case 0x000: ptr = special_regs [SFC];
                break;
    case 0x001: ptr = special_regs [DFC];
                break;
    case 0x002: ptr = special_regs [CACR];
                break;
    case 0x003: if (mc68040)
                  ptr = special_regs [TC];
                else
                  return (TRANSFER);
                break;
    case 0x004: if (mc68040)
                  ptr = special_regs [ITT0];
                else
                  return (TRANSFER);
                break;
    case 0x005: if (mc68040)
                  ptr = special_regs [ITT1];
                else
                  return (TRANSFER);
                break;
    case 0x006: if (mc68040)
                  ptr = special_regs [DTT0];
                else
                  return (TRANSFER);
                break;
    case 0x007: if (mc68040)
                  ptr = special_regs [DTT1];
                else
                  return (TRANSFER);
                break;
    case 0x800: ptr = special_regs [USP];
                break;
    case 0x801: ptr = special_regs [VBR];
                break;
    case 0x802: ptr = special_regs [CAAR];
                break;
    case 0x803: ptr = special_regs [MSP];
                break;
    case 0x804: ptr = special_regs [ISP];
                break;
    case 0x805: if (mc68040)
                  ptr = special_regs [MMUSR];
                else
                  return (TRANSFER);
                break;
    case 0x806: if (mc68040)
                  ptr = special_regs [URP];
                else
                  return (TRANSFER);
                break;
    case 0x807: if (mc68040)
                  ptr = special_regs [SRP];
                else
                  return (TRANSFER);
                break;
    default : return (TRANSFER);
    }

  reg_offset = (*(code + 1) & 0x8000) ? 8 : 0;
  if (pass3)
    {
    strcpy (opcode, "MOVEC.L");
    if (*code & 0x1)
      {
      /* from general register to control register */
      strcpy (dest, ptr);
      strcpy (src, reg_names [((*(code + 1) >> 12) & 0x7) + reg_offset]);
      }
    else
      {
      strcpy (src, ptr);
      strcpy (dest, reg_names [((*(code + 1) >> 12) & 0x7) + reg_offset]);
      }
    }
  return (2);
  }
else if ((*code & 0x30) == 0)
  {
  /* TRAP */
  if (pass3)
    {
    strcpy (opcode, "TRAP");
    src [0] = '#';
    format_d (src + 1, (short)(*code & 0xf), FALSE);
    }
  return (1);
  }
else if ((*code & 0x38) == 0x10)
  {
  /* LINK */
  if (pass3)
    {
    strcpy (opcode, "LINK");
    strcpy (src, reg_names [(*code & 0x7) + 8]);
    dest [0] = '#';
    format_d (dest + 1, (short)*(code + 1), TRUE);
    }
  return (2);
  }
else if ((*code & 0x38) == 0x18)
  {
  /* UNLK */
  if (pass3)
    {
    strcpy (opcode, "UNLK");
    strcpy (src, reg_names [(*code & 0x7) + 8]);
    }
  return (1);
  }
else if ((*code & 0x38) == 0x20)
  {
  if (pass3)
    {
    strcpy (opcode, "MOVE.L");
    strcpy (dest, special_regs [USP]);
    strcpy (src, reg_names [(*code & 0x7) + 8]);
    }
  return (1);
  }
else if ((*code & 0x38) == 0x28)
  {
  if (pass3)
    {
    strcpy (opcode, "MOVE");
    strcpy (src, special_regs [USP]);
    strcpy (dest, reg_names [(*code & 0x7) + 8]);
    }
  return (1);
  }
return (TRANSFER);
}

/**********************************************************************/

int off_illegal  (struct opcode_entry *op)
/* The official illegal instruction */
{
return (1);
}

/**********************************************************************/

int illegal  (struct opcode_entry *op)

{
src [0] = 0;
dest [0] = 0;
detected_illegal = TRUE;
return (1);
}

/**********************************************************************/

int immediate (struct opcode_entry *op)

{
short used = 2;

if (pass2 && op->param == ACC_LONG)
  used = 3;
else
  {
  src [0] = '#';
  switch (op->param)
    {
    case ACC_BYTE:
      format_d (src + 1, (short)(*(code + 1) & 0xff), FALSE);
      break;
    case ACC_WORD:
      format_d (src + 1, (short)*(code + 1), FALSE);
      break;
    case ACC_LONG:
      format_ld (src + 1, ((long)*(code + 1) << 16) + (long)*(code + 2), FALSE);
      used = 3;
      break;
    }
  }
return (decode_ea (MODE_NUM(*code), REG_NUM(*code), dest, op->param, 
                   used) + used);
}

/**********************************************************************/

int ori_b (struct opcode_entry *op)

{
/* Special routine which checks for ORI.B #0,D0 and flags it as
   illegal. This will prevent many unfortunate disassemblies, which
   were meant as data */

if (*((ULONG*)code) == 0L)
  {
  detected_illegal = TRUE;
  return (1);
  }
src [0] = '#';
format_d (src + 1, (short)(*(code + 1) & 0xff), FALSE);
return (decode_ea (MODE_NUM(*code), REG_NUM(*code), dest, op->param, (short)2) + 2);
}

/**********************************************************************/

int single_op (struct opcode_entry *op)

{
return (decode_ea (MODE_NUM(*code), REG_NUM(*code), src, op->param,
                   (short)1) + 1);
}

/**********************************************************************/

int end_single_op (struct opcode_entry *op)
/* A single operand instruction ending an instruction sequence, i.e.
   JMP or RTM */
{
int size;

end_instr = TRUE;
size = decode_ea (MODE_NUM(*code), REG_NUM(*code), src, op->param,
                   (short)1) + 1;
return (size);
}

/**********************************************************************/

int quick (struct opcode_entry *op)

{
if (pass3)
  {
  src [0] = '#';
  format_d (src + 1, (short)op->param, TRUE);
  }
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), dest, 
                   (UWORD)(ACC_DATA | (1 << ((*code >> 6) & 0x3))),
                   (short)1) + 1);
/* ((*code >> 6) & 0x3) is the size encoding in the quick instructions.
   It has to be performed, otherwise it would be possible to generate
   instructions, that do e.g. byte accesses do address registers */
}

/**********************************************************************/

int branch (struct opcode_entry *op)

{
long offset;
short used;
unsigned long ref;

if ((*code & 0xff) == 0)
  {
  /* word displacement */
  offset = (short)*(code + 1) ;
  used = 2;
  }
else if ((*code & 0xff) == 0xff)
  {
  /* long displacement */
  if (!mc68020)
    return (TRANSFER);
  offset = (*(code + 1) << 16) + *(code + 2);
  used = 3;
  }
else
  {
  /* byte displacement */
  offset = (char)(*code & 0xff);
  used = 1;
  }

if (offset & 0x1)
  /* branch to an odd address */
  return (TRANSFER);

ref = current_address + 2 + offset;
if (ref < first_address || ref > last_address)
  return (TRANSFER);

if (pass3)
  {
  if (gen_label (src, ref, TRUE) == NO_ACCESS && !disasm_quick)
    {
#ifdef DEBUG
    fprintf (stderr, "INTERNAL ERROR: branch: Non-existant label reference during second pass\n");
    fprintf (stderr, "         Current address is: %lx\n", current_address);
#endif
    }
  if (used == 1)
    strcat (opcode, ".S");
  else
    strcat (opcode, ".L");
  }
else
  {
  enter_ref (ref, 0L, ACC_CODE);
  if ((*code & 0xff00) == 0x6000)
    {
    /* unconditional branch */
    end_instr = TRUE;
    }
  }
return (used);
}

/**********************************************************************/

int dual_op (struct opcode_entry *op)

{
if (*code & 0x100)
  {
  /* Data register is source */
  if (pass3)
    strcpy (src, reg_names [op->param]);
  return (decode_ea (MODE_NUM (*code), REG_NUM (*code), dest, 
                     (UWORD)(ACC_DATA | (1 << ((*code >> 6) & 0x3))),
                     (short)1) + 1);
  }
else
  {
  /* Data register is destination */
  if (pass3)
    strcpy (dest, reg_names [op->param]);
  return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, 
                     (UWORD)(ACC_DATA | (1 << ((*code >> 6) & 0x3))),
                     (short)1) + 1);
  }
}

/**********************************************************************/

int dbranch (struct opcode_entry *op)

{
unsigned long ref;

if (*(code + 1) & 0x1)
  /* branch to an odd address */
  return (TRANSFER);

if (pass3)
  strcpy (src, reg_names [*code & 7]);
ref = current_address + 2 + (short)(*(code + 1));
if (ref < first_address || ref > last_address)
  return (TRANSFER);
if (pass3)
  {
  if (gen_label (dest, ref, TRUE) == NO_ACCESS && !disasm_quick)
    {
#ifdef DEBUG
    fprintf (stderr, "INTERNAL ERROR: dbranch: Non-existant label reference during second pass\n");
    fprintf (stderr, "         Current address is: %lx\n", current_address);
#endif
    }
  }
else
  enter_ref (ref, 0L, ACC_CODE);

return (2);
}

/**********************************************************************/

int shiftreg (struct opcode_entry *op)

{
opcode [1] = 'S';
opcode [2] = 0;
switch ((*code >> 3) & 0x3)
  {
  case 0:  /* Arithmetic shift */
           opcode [0] = 'A';
           break;
  case 1:  /* Logical shift */
           opcode [0] = 'L';
           break;
  case 2:  /* Rotate with extend */
           if (pass3)
             strcpy (opcode, "ROX");
           break;
  case 3:  /* Rotate */
           opcode [0] = 'R';
           opcode [1] = 'O';
           break;
  }
if (pass3)
  {
  strcat (opcode, op->mnemonic);

  if (*code & 0x20)
    {
    /* shift count is in register */
    strcpy (src, reg_names [op->param & 0x7]);
    /* This is because param gives a shift count of 8, if this bitfield is 0 */
    }
  else
    {
    /* shift count specified as immediate */
    src [0] = '#';
    format_d (src + 1, (short)op->param, FALSE);
    }

  strcpy (dest, reg_names [REG_NUM (*code)]);
  }
return (1);
}

/**********************************************************************/


int op_w      (struct opcode_entry *op)

{
if (pass3)
  strcpy (dest, reg_names [op->param]);
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, ACC_WORD, 
                   (short) 1) + 1);
}

/**********************************************************************/

int op_l      (struct opcode_entry *op)

{
if (pass3)
  strcpy (dest, reg_names [op->param]);
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, ACC_LONG, 
                   (short) 1) + 1);
}

/**********************************************************************/

int restrict (struct opcode_entry *op)

{
/* For opcodes such as ADDX, SUBX, ABCD, SBCD, PACK, UNPK with only 
   -(Ax) and Dn addressing allowed */
char *tmp;

if (pass3)
  {
  if (*code & 0x8)
    {
    /* -(Ax) addressing */
    pre_dec (src, (short)(REG_NUM (*code) + 8));
    pre_dec (dest, (short)(((*code >> 9) & 0x7) + 8));
    }
  else
    {
    /* Dn addressing */
    strcpy (src, reg_names [REG_NUM (*code)]);
    strcpy (dest, reg_names [((*code >> 9) & 0x7)]);
    }
  }

if (op->param == NO_ADJ)
  return (1);
else
  {
  if (pass3)
    {
    tmp = dest + strlen (dest);
    *tmp++ = ',';
    immed (tmp, (long)*(code + 1));
    }
  return (2);
  }
}

/**********************************************************************/

int muldivl (struct opcode_entry *op)

{
register short dr, dq;

opcode [3] = (*(code + 1) & 0x800) ? 'S' : 'U';
dr = *(code + 1) & 0x7;
dq = (*(code + 1) >> 12) & 0x7;
if (pass3)
  {
  if (*(code + 1) & 0x400)
    {
    /* 64-bit operation */
    strcpy (dest, reg_names [dr]);
    strcat (dest, ":");
    strcat (dest, reg_names [dq]);
    }
  else
    {
    if (dr != dq)
      {
      strcat (opcode, "L");
      strcpy (dest, reg_names [dr]);
      strcat (dest, ":");
      strcat (dest, reg_names [dq]);
      }
    else
      strcpy (dest, reg_names [dq]);
    }
  strcat (opcode, ".L");
  }
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, ACC_LONG,
                   (short)2) + 2);
}

/**********************************************************************/
    
int bf_op   (struct opcode_entry *op)

{
int used;
short offset, width;
register char *ptr_ea, *ptr_dn;

offset = (*(code + 1) >> 6) & 0x1f;
width = *(code + 1) & 0x1f;

switch (op->param)
  {
  case SINGLEOP: ptr_ea = src;
                 break;
  case DATADEST: ptr_ea = src;
                 ptr_dn = dest;
                 break;
  case DATASRC : ptr_ea = dest;
                 ptr_dn = src;
                 break;
  }

if (pass3)
  {
  if (op->param != SINGLEOP)
    strcpy (ptr_dn, reg_names [(*(code + 1) >> 12) & 0x7]);
  }

used = decode_ea (MODE_NUM (*code), REG_NUM (*code), ptr_ea, ACC_DATA,
                  (short)2);

if (pass3)
  strcat (ptr_ea, "{");

if (*(code + 1) & 0x800)
  {
  /* Offset specified in register */
  if (offset > 7)
    return (TRANSFER);
  if (pass3)
    strcat (ptr_ea, reg_names [offset]);
  }
else if (pass3)
  {
  /* Offset specified as immediate */
  format_d (ptr_ea + strlen (ptr_ea), offset, FALSE);
  }

if (pass3)
  strcat (ptr_ea, ":");

if (*(code + 1) & 0x20)
  {
  /* Width specified in register */
  if (width > 7)
    return (TRANSFER);
  if (pass3)
    strcat (ptr_ea, reg_names [width]);
  }
else if (pass3)
  {
  /* Width specified as immediate */
  format_d (ptr_ea + strlen (ptr_ea), width, FALSE);
  }

if (pass3)
  strcat (ptr_ea, "}");

return (2 + used);
}

/**********************************************************************/

int moveq (struct opcode_entry *op)

{
char val;

if (pass3)
  {
  src [0] = '#';
  /* Get the sign right */
  val = *code & 0xff;
  format_d (src + 1, (short)val, TRUE);
  strcpy (dest, reg_names [op->param]);
  }
return (1);
}

/**********************************************************************/

int scc (struct opcode_entry *op)

{
if (pass3)
  strcat (opcode, conditions [(*code >> 8) & 0xf]);
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, ACC_BYTE, (short)1)
        + 1);
}

/**********************************************************************/

int exg  (struct opcode_entry *op)

{
short rx = (*code >> REG2_SHIFT) & 0x7;

if (((*code >> 3) & 0x1f) == 0x8)
  {
  /* exchange two data registers */
  if (pass3)
    {
    strcpy (src, reg_names [rx]);
    strcpy (dest, reg_names [*code & 0x7]);
    }
  }
else if (((*code >> 3) & 0x1f) == 0x9)
  {
  /* exchange two address registers */
  if (pass3)
    {
    strcpy (src, reg_names [rx + 8]);
    strcpy (dest, reg_names [(*code & 0x7) + 8]);
    }
  }
else if (((*code >> 3) & 0x1f) == 0x11)
  {
  /* exchange an address and a data register */
  if (pass3)
    {
    strcpy (src, reg_names [rx]);
    strcpy (dest, reg_names [(*code & 0x7) + 8]);
    }
  }
else
  return (TRANSFER);
return (1);
}

/**********************************************************************/

int trapcc (struct opcode_entry *op)

{
if (pass3)
  strcat (opcode, conditions [(*code >> 8) & 0xf]);
if ((*code & 0x7) == 2)
  {
  if (pass3)
    immed (src, (long)*(code + 1));
  return (2);
  }
if ((*code & 0x7) == 3)
  {
  if (pass3)
    immed (src, (*(code + 1) << 16) + *(code + 2));
  return (3);
  }

return (1);
}

/**********************************************************************/

int chkcmp2 (struct opcode_entry *op)

{
if (pass3)
  {
  if (*(code + 1) & 0x800)
    {
    /* CHK2 */
    opcode [1] = 'H';
    opcode [2] = 'K';
    }
  else
    {
    /* CMP2 */
    opcode [1] = 'M';
    opcode [2] = 'P';
    }
  if (pass3)
    strcpy (dest, reg_names [*(code + 1) >> 12]);
  }
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, op->param, (short)2)
        + 2);
}

/**********************************************************************/

int cas  (struct opcode_entry *op)

{
if (pass3)
  {
  strcpy (src, reg_names [*(code + 1) & 0x7]);
  strcat (src, ",");
  strcat (src, reg_names [(*(code + 1) >> 6) & 0x7]);
  }
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), dest, op->param, 
                   (short)2) + 2);
}

/**********************************************************************/

int cas2 (struct opcode_entry *op)

{
if (pass3)
  {
  sprintf (src, "%s:%s,%s:%s", reg_names [*(code + 1) & 0x7],
                               reg_names [*(code + 2) & 0x7],
                               reg_names [(*(code + 1) >> 6) & 0x7],
                               reg_names [(*(code + 2) >> 6) & 0x7]);

  sprintf (dest, "(%s):(%s)",  reg_names [*(code + 1) >> 12],
                               reg_names [*(code + 2) >> 12]);
  }
return (3);
}

/**********************************************************************/

int moves (struct opcode_entry *op)

{
char *reg, *ea;

if (*(code + 1) & 0x800)
  {
  reg = src;
  ea = dest;
  }
else
  {
  reg = dest;
  ea = src;
  }

if (pass3)
  strcpy (reg, reg_names [(*(code + 1) >> 12) & 0xf]);
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), ea, op->param, 
                   (short)2) + 2);
}

/**********************************************************************/

int movesrccr (struct opcode_entry *op)

{
char *ea;

if (pass3)
  {
  switch (op->param)
    {
    case FROM_CCR: strcpy (src, special_regs [CCR]);
                   ea = dest;
                   break;
    case TO_CCR  : strcpy (dest, special_regs [CCR]);
                   ea = src;
                   break;
    case FROM_SR : strcpy (src, special_regs [SR]);
                   ea = dest;
                   break;
    case TO_SR   : strcpy (dest, special_regs [SR]);
                   ea = src;
                   break;
    }
  }
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), ea, ACC_WORD, (short)1)
        + 1);
}

/**********************************************************************/

int cmpm (struct opcode_entry *op)

{
if (pass3)
  {
  post_inc (src, (short)(*code & 0xf));
  post_inc (dest, (short)((*code >> 9) & 0xf));
  }
return (1);
}

/**********************************************************************/

int movep (struct opcode_entry *op)

{
char *dn, *an;

if (pass3)
  {
  if (*code & 0x40)
    strcat (opcode, ".L");
  else
    strcat (opcode, ".W");
  }
if (*code & 0x80)
  {
  /* Transfer to memory */
  an = dest;
  dn = src;
  }
else
  {
  /* Transfer from memory */
  an = src;
  dn =dest;
  }

if (pass3)
  {
  strcpy (dn, reg_names [(*code >> 9) & 0x7]);
  disp_an (an, (short)((*code & 0x7) + 8), *(code + 1));
  }
return (2);
}

/**********************************************************************/

int bkpt (struct opcode_entry *op)

{
if (pass3)
  {
  src [0] = '#';
  format_d (src + 1, (short)(*code & 0x7), FALSE);
  }
return (1);
}

/**********************************************************************/

int link_l (struct opcode_entry *op)

{
if (pass3)
  {
  dest [0] = '#';
  format_ld (dest + 1, ((long)*(code + 1) << 16) + (long)*(code + 2), FALSE);
  strcpy (src, reg_names [REG_NUM (*code) + 8]);
  }
return (3);
}

/**********************************************************************/

int move16 (struct opcode_entry *op)

{
char *tmp;

if ((*code & 0x20) &&
    ((*(code + 1) & 0x8fff) == 0x8000))
  {  /* post increment mode for src and dest */
  if (pass3)
    {
    post_inc (src, (short)((*code & 0x7) + 8));
    post_inc (dest, (short)(((*(code + 1) >> 12) & 0x7) + 8));
    }
  return (2);
  }
else if ((*code & 0x20) == 0)
  {
  if (pass3)
    {
    if (*code & 0x8)    
      {
      tmp = dest;
      decode_ea ((short)7, (short)1, src, (short)(ACC_LONG | ACC_DATA), (short)1);
      }
    else
      {
      tmp = src;
      decode_ea ((short)7, (short)1, dest, (short)(ACC_LONG | ACC_DATA), (short)1);
      }
    if (*code & 0x10)
      indirect (tmp, (short)((*code & 0x7) + 8));
    else
      post_inc (tmp, (short)((*code & 0x7) + 8));
    }
  return (3);
  }
return (TRANSFER);
}

/**********************************************************************/

int cache (struct opcode_entry *op)

{
if (pass3)
  {
  if (*code & 0x20)
    strcpy (opcode, "CPUSH");
  else
    strcpy (opcode, "CINV");
  switch ((*code >> 3) & 0x3)
    {
    case 1: strcat (opcode, "L"); break;
    case 2: strcat (opcode, "P"); break;
    case 3: strcat (opcode, "A"); break;
    }

  switch (op->param)          /* which cache to modify */
    {
    case 0: strcpy (src, "NC"); break;
    case 1: strcpy (src, "DC"); break;
    case 2: strcpy (src, "IC"); break;
    case 3: strcpy (src, "BC"); break;
    }

  if (((*code >> 3) & 0x3) != 0x3)      /* not all --> page or line */
    indirect (dest, (short)(REG_NUM (*code) + 8));
  }
return (1);
}
