/*
 * Change history:
 * $Log:	opcode_handler_fpu.c,v $
 * Revision 3.0  93/09/24  17:54:15  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:56:24  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:54:27  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.7  93/06/16  20:29:03  Martin_Apel
 * Minor mod.: Removed #ifdef FPU_VERSION and #ifdef MACHINE68020
 * Minor mod.: Added variables for 68030 / 040 support
 * 
 * Revision 1.6  93/06/06  13:47:37  Martin_Apel
 * Minor mod.: Replaced first_pass and read_symbols by pass1, pass2, pass3
 * 
 * Revision 1.5  93/05/27  20:48:41  Martin_Apel
 * Bug fix: Register list was misinterpreted for MOVEM / FMOVEM
 *          instructions.
 * 
 */

#include <exec/types.h>
#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: opcode_handler_fpu.c,v 3.0 93/09/24 17:54:15 Martin_Apel Exp $";

int fpu (struct opcode_entry *op)

{
int used;
char *reg_list,
     *ea;
register char *tmp;
int num_regs;

if ((*(code + 1) & 0xfc00) == 0x5c00)
  {
  /* FMOVECR */
  if (pass3)
    {
    strcpy (opcode, "FMOVECR.X");
    immed (src, (long)(*(code + 1) & 0x7f));
    strcpy (dest, reg_names [17 + ((*(code + 1) >> 7) & 0x7)]);
    }
  return (2);
  }
else
  {
  switch (*(code + 1) >> 13)
    {
    case 0:
    case 2: if ((*(code + 1) & 0x0040) && !mc68040)
              return (TRANSFER);
            op = &(fpu_opcode_table [*(code + 1) & 0x7f]);
            return ((*op->handler) (op));

    case 3: /* FMOVE from FPx */
            if (pass3)
              {
              strcpy (opcode, "FMOVE");
              strcat (opcode, xfer_size [(*(code + 1) >> 10) & 0x7]);
              strcpy (src, reg_names [17 + ((*(code + 1) >> 7) & 0x7)]);
              }
            used = decode_ea (MODE_NUM (*code), REG_NUM (*code), dest, 
                              sizes [(*(code + 1) >> 10) & 0x7], (short)2);
            if ((*(code + 1) & 0x1c00) == 0x0c00)
              {
              /* Packed decimal real with static k-factor */
              if (pass3)
                {
                tmp = dest + strlen (dest);
                *tmp++ = '{';
                tmp = immed (tmp, (long)(*(code + 1) & 0x7f));
                *tmp++ = '}';
                *tmp = 0;
                  /* Same as:
                     sprintf (dest + strlen (dest), "{#$%x}", 
                              *(code + 1) & 0x7f);
                  */
                }
              }
            else if ((*(code + 1) & 0x1c00) == 0x1c00)
              {
              /* Packed decimal real with dynamic k-factor */
              if (pass3)
                {
                tmp = dest + strlen (dest);
                *tmp++ = '{';
                strcpy (tmp, reg_names [(*(code + 1) >> 4) & 0x7]);
                while (*(++tmp) != 0);
                *tmp++ = '}';
                *tmp = 0;
                /* Same as:
                   sprintf (dest + strlen (dest), "{%s}", 
                            reg_names [(*(code + 1) >> 4) & 0x7]);
                */
                }
              }
            return (2 + used);

    case 4: 
    case 5: /* FMOVE cntrl regs */
            num_regs = 0;
            if (pass3)
              strcpy (opcode, "FMOVE");
            if (*(code + 1) & 0x2000)
              {
              ea = dest;
              reg_list = src;
              }
            else
              {
              ea = src;
              reg_list = dest;
              }
            used = decode_ea (MODE_NUM (*code), REG_NUM (*code), ea, 
                              (short)(ACC_DATA | ACC_LONG), (short)2);
            if (pass3)
              {
              if (*(code + 1) & 0x1000)
                {
                strcpy (reg_list, "FPCR");
                num_regs++;
                }
              if (*(code + 1) & 0x0800)
                {
                if (num_regs != 0)
                  strcat (reg_list, "/");
                strcat (reg_list, "FPSR");
                num_regs++;
                }
              if (*(code + 1) & 0x0400)
                {
                if (num_regs != 0)
                  strcat (reg_list, "/");
                strcat (reg_list, "FPIAR");
                num_regs++;
                }
              if (num_regs > 1)
                strcat (opcode, "M");          /* for FMOVEM */
              }
            return (2 + used);

    case 6:
    case 7: /* FMOVEM */
            if (MODE_NUM (*code) < 2)
              return (TRANSFER);
            if (pass3)
              strcpy (opcode, "FMOVEM.X");
            if (*(code + 1) & 0x2000)        /* to mem */
              {
              if (MODE_NUM (*code) == 3 || (*code & 0x3f) >= 0x3a)
                return (TRANSFER);
              reg_list = src;
              ea = dest;
              }
            else                             /* from mem */
              {
              if (MODE_NUM (*code) == 4 || (*code & 0x3f) == 0x3a)
                return (TRANSFER);
              reg_list = dest;
              ea = src;
              }
            if (pass3)
              {
              if (*(code + 1) & 0x0800)
                {
                /* Dynamic register list in data register */
                strcpy (reg_list, reg_names [(*(code + 1) >> 4) & 0x7]);
                }
              else
                {
                /* Test for predecrement mode */
                if (MODE_NUM (*code) == 4)
                  format_reg_list (reg_list, (unsigned short)(*(code + 1) & 0xff),
                                   TRUE, (short) 17);
                else
                  format_reg_list (reg_list, (unsigned short)(*(code + 1) << 8),
                                   FALSE, (short) 17);
                }
              }
            return (decode_ea (MODE_NUM (*code), REG_NUM (*code), ea,
                               ACC_DATA, (short)2) + 2);
    }
  }
return (TRANSFER);
}


int std_fpu (struct opcode_entry *op)

{
if (pass3)
  {
  strcpy (opcode, op->mnemonic);
  strcpy (dest, reg_names [17 + ((*(code + 1) >> 7) & 0x7)]);
  }
if (*(code + 1) & 0x4000)          /* R/M - Bit */
  {
  if (pass3)
    strcat (opcode, xfer_size [(*(code + 1) >> 10) & 0x7]);
  return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, 
                     sizes [(*(code + 1) >> 10) & 0x7], (short)2) + 2);
  }
else if (pass3)
  {
  strcat (opcode, xfer_size [2]);       /* ".X" */
  strcpy (src, reg_names [17 + ((*(code + 1) >> 10) & 0x7)]);
  }

if ((src [2] == dest [2]) && (op->param == SNG_ALL))      /* single operand */
  dest [0] = 0;
return (2);
}


int fsincos (struct opcode_entry *op)

{
if (pass3)
  {
  strcpy (opcode, op->mnemonic);
  strcpy (dest, reg_names [17 + op->param]);
  strcat (dest, ":");
  strcat (dest, reg_names [17 + ((*(code + 1) >> 7) & 0x7)]);
  }
if (*(code + 1) & 0x4000)          /* R/M-Bit */
  {
  if (pass3)
    strcat (opcode, xfer_size [(*(code + 1) >> 10) & 0x7]);
  return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, 
                     sizes [(*(code + 1) >> 10) & 0x7], (short)2) + 2);  
  }
else
  {
  if (pass3)
    {
    strcat (opcode, xfer_size [2]);       /* ".X" */
    strcpy (src, reg_names [17 + ((*(code + 1) >> 10) & 0x7)]);
    }
  return (2);
  }
}


int fscc (struct opcode_entry *op)

{
if ((*(code + 1) & 0xffe0) != 0)
  return (TRANSFER);

if (pass3)
  strcat (opcode, fpu_conditions [*(code + 1)]);
return (decode_ea (MODE_NUM (*code), REG_NUM (*code), src, ACC_BYTE, (short)2)
          + 2);
}


int fbranch (struct opcode_entry *op)

{
long offset;
unsigned long ref;

if (pass3)
  strcat (opcode, fpu_conditions [*code & 0x1f]);
if (op->param & ACC_WORD)
  offset = (short)*(code + 1);
else
  offset = (*(code + 1) << 16) + *(code + 2);

if (offset == 0 && pass3)
  strcpy (opcode, "FNOP");
else if (offset != 0)
  {
  ref = current_address + 2 + offset;
  if (ref < first_address || ref > last_address)
    return (TRANSFER);
  if (pass3)
    gen_label (src, ref, TRUE);
  else
    enter_ref (ref, 0L, ACC_CODE);
  }
return (2 + ((op->param & ACC_WORD) ? 0 : 1));
}


int fdbranch (struct opcode_entry *op)

{
unsigned long ref;

if ((*(code + 1) & 0xffe0) != 0)
  return (TRANSFER);
if ((*code & 0x0038) != 0x8)
  return (TRANSFER);
if (pass3)
  {
  strcat (opcode, fpu_conditions [*(code + 1)]);
  strcpy (src, reg_names [*code & 0x7]);
  }
ref = current_address + 4 + (short)*(code + 2);
if (ref < first_address || ref > last_address)
  return (TRANSFER);
if (pass3)
  gen_label (dest, ref, TRUE);
else
  enter_ref (ref, 0L, ACC_CODE);
return (3);
}


int ftrapcc (struct opcode_entry *op)

{
if ((*(code + 1) & 0xffe0) != 0)
  return (TRANSFER);
if (pass3)
  strcat (opcode, fpu_conditions [*(code + 1)]);
if ((*code & 0x7) == 2)
  {
  if (pass3)
    immed (src, (long)*(code + 2));
  return (3);
  }
if ((*code & 0x7) == 3)
  {
  if (pass3)
    immed (src, (*(code + 2) << 16) + *(code + 3));
  return (4);
  }

return (2);
}
