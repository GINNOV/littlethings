/*
 * Change history
 * $Log:	opcode_handler_mmu.c,v $
 * Revision 3.0  93/09/24  17:54:17  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.4  93/07/18  22:56:27  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.3  93/07/11  21:39:02  Martin_Apel
 * Bug fix: Changed PTEST function for 68030
 * 
 * Revision 2.2  93/07/08  22:29:17  Martin_Apel
 * 
 * Bug fix: Fixed PFLUSH bug. Mode and mask bits were confused
 * 
 * Revision 2.1  93/07/08  20:49:34  Martin_Apel
 * Bug fixes: Fixed various bugs regarding 68030 opcodes
 * 
 * Revision 2.0  93/07/01  11:54:31  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.3  93/07/01  11:42:59  Martin_Apel
 * 
 * Revision 1.2  93/06/19  12:11:49  Martin_Apel
 * Major mod.: Added full 68030/040 support
 * 
 * Revision 1.1  93/06/16  20:29:09  Martin_Apel
 * Initial revision
 * 
 */

#include <string.h>
#include "defs.h"

static char rcsid [] = "$Id: opcode_handler_mmu.c,v 3.0 93/09/24 17:54:17 Martin_Apel Exp $";

/**********************************************************************/

int pflush40 (struct opcode_entry *op)

{
if (pass3)
  {
  switch ((*code >> 3) & 0x3)
    {
    case 0: strcat (opcode, "N");  break;
    case 1:                        break;
    case 2: strcat (opcode, "AN"); break;
    case 3: strcat (opcode, "A");  break;
    }
  if ((*code & 0x10) == 0)
    indirect (src, (short)(REG_NUM (*code) + 8));
  }
return (1);
}

/**********************************************************************/

int ptest40 (struct opcode_entry *op)

{
if (pass3)
  {
  if (*code & 0x20)
    strcat (opcode, "R");
  else
    strcat (opcode, "W");
  indirect (src, (short)(REG_NUM (*code) + 8));
  }
return (1);
}

/**********************************************************************/

static BOOL eval_fc (char *to)

{
if ((*(code + 1) & 0x0018) == 0x0010)
  immed (to, (long)(*(code + 1) & 0x7));
else if ((*(code + 1) & 0x0018) == 0x0008)
  strcpy (to, reg_names [*(code + 1) & 0x7]);
else if ((*(code + 1) & 0x001f) == 0)
  strcpy (to, special_regs [SFC]);
else if ((*(code + 1) & 0x001f) == 0x0001)
  strcpy (to, special_regs [DFC]);
else return (FALSE);
return (TRUE);
}

/**********************************************************************/

int mmu30 (struct opcode_entry *op)

{
/* Test for PTEST instruction */
if (((*(code + 1) & 0xfc00) == 0x9c00) && ((*code & 0x003f) != 0))
  return ptest30 (op);
else if (!(*(code + 1) & 0x8000))
  {
  op = &(mmu_opcode_table [*(code + 1) >> 10]);
  if (pass3)
    strcpy (opcode, op->mnemonic);
  return ((*op->handler) (op));
  }
return (TRANSFER);
}

/**********************************************************************/

int ptest30 (struct opcode_entry *op)

{
if ((*code & 0x003f) == 0)         /* Check for illegal mode */
  return (TRANSFER);

strcpy (opcode, "PTESTWFC");
if (*(code + 1) & 0x0200)
  opcode [5] = 'R';
if (!eval_fc (dest))     
  return (TRANSFER);
if (*(code + 1) & 0x0100)
  {
  strcat (dest, ",");
  strcat (dest, reg_names [(*(code + 1) >> 5) & 0x7]);
  }
return (2 + decode_ea (MODE_NUM (*code), REG_NUM (*code),
                      dest, ACC_UNKNOWN, (short)2));
}

/**********************************************************************/

int pfl_or_ld (struct opcode_entry *op)

/* Tests for PLOAD instruction first. Otherwise it's a standard
   PFLUSH instruction */
{
if ((*(code + 1) & 0x00e0) != 0x0000)
  return (pflush30 (op));

if ((*code & 0x3f) == 0)
  return (TRANSFER);

strcpy (opcode, "PLOAD");
if (*(code + 1) & 0x0200)
  strcat (opcode, "R");
else
  strcat (opcode, "W");

if (!eval_fc (src))
  return (TRANSFER);
return (2 + decode_ea (MODE_NUM (*code), REG_NUM (*code),
                       dest, ACC_UNKNOWN, (short)2));
}

/**********************************************************************/

int pflush30 (struct opcode_entry *op)

{
switch (op->param)
  {
  case 1: /* PFLUSHA */
          if (*(code + 1) != 0x2400)
            return (TRANSFER);
          strcat (opcode, "A");
          return (2);
  case 4: /* PFLUSH FC,MASK */
          /* EA ignored !?! */
          if (!eval_fc (src))
            return (TRANSFER);
          immed (dest, (long)((*(code + 1) >> 5) & 0x7));
          return (2);

  case 6: /* PFLUSH FC,MASK,EA */
          if (!eval_fc (src))
            return (TRANSFER);
          strcat (src, ",");
          immed (src + strlen (src), (long)((*(code + 1) >> 5) & 0x7));
          return (2 + decode_ea (MODE_NUM (*code), REG_NUM (*code),
                                 dest, ACC_UNKNOWN, (short)2));
  }

return (TRANSFER);
}

/**********************************************************************/

int pmove30 (struct opcode_entry *op)

{
char *ea,
     *reg;

if ((*code & 0x003f) == 0)
  return (TRANSFER);

if ((*(code + 1) & 0xff) || ((*(code + 1) & 0x0010) && op->param == MMUSR))
  return (TRANSFER);

if (*(code + 1) & 0x0200)
  {
  ea = dest;
  reg = src;
  }
else
  {
  ea = src;
  reg = dest;
  }
if ((*(code + 1) & 0x0100))
  strcat (opcode, "FD");

strcpy (reg, special_regs [op->param]);
return (2 + decode_ea (MODE_NUM (*code), REG_NUM (*code),
                       ea, ACC_LONG, (short)2));
}
