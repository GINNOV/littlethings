/*
 * opcode.c
 *
 *  Created on: 07 nov 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : opcode.c
 *      Purpose  : Functions about OpCode manipulation
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2015 Frank Wille, (C)2014-2016 Nicolas Bastien
 */

#include <stdint.h>
#include <stdio.h>

#include "ira.h"

#include "constants.h"
#include "opcode.h"
#include "supp.h"

static int FindOpCodeNumber(ira_t *ira, uint16_t seaow)
{
   int i, number;

   /* set the number of the opcode to the maximum (DC.W) as default. */
   number = OpCode_number - 1;

   /* Linear search by nibble */
   for (i = ira->opCodeByNibble[seaow >> 12].start; i < ira->opCodeByNibble[seaow >> 12].start + ira->opCodeByNibble[seaow >> 12].count; i++)
      if (((seaow & instructions[i].mask) == instructions[i].result) && (instructions[i].cpuType & ira->params.cpuType))
      {
         number = i;
         break;
      }

   return number;
}

void GroupOpCodeByNibble(ira_t *ira)
{
   int i;

   /* Let's fill an index to find opcodes grouped by their first nibble.
    * note: very important!!! instructions[] array MUST be sorted by opcode first nibble */
   for (i = 0; i < OpCode_number - 1; i++)
   {
      if (ira->opCodeByNibble[instructions[i].result >> 12].count == 0)
         ira->opCodeByNibble[instructions[i].result >> 12].start = i;
      ira->opCodeByNibble[instructions[i].result >> 12].count++;
   }
}

/*
 * note: seaow stands for "Single Effective Address Operation Word",
 * as defined in chapter "2.1 INSTRUCTION FORMAT" of MC68000PRM.
 */
void GetOpCode(ira_t *ira, uint16_t seaow)
{
   ira->opCodeNumber = FindOpCodeNumber(ira, seaow);

   /* split up the opcode */
   ira->alt_register = (seaow & ALT_REGISTER_MASK) >> 9;
   ira->rotate_shift_count = (seaow & ROTATE_SHIFT_COUNT_MASK) >> 9;
   if (!ira->rotate_shift_count)
      ira->rotate_shift_count = 8;
   ira->ea_register = (seaow & EA_REG_FIELD_MASK);

   /* Our addressMode is "Mode field" value when "Reg field" is a register number,
    * else it is "Reg field" + 7 (which is value of "Mode field", in that case).
    *
    * Why ?
    * See "Table 2-4. Effective Addressing Modes and Categories" of MC68000PRM.
    *
    * When "Mode field" is between 000 and 110, "Reg field" contains a register number.
    * When "Mode field" is 111, "Reg field" contains a value coding for an <ea> mode with no register number.
    *
    * There is 7 cases that code for a register number (from 000 to 110), they are 7th first cases (from 0 to 6).
    * Next cases are counted from 7 and because "Reg field" contains values from 000 to 100
    * (can be up to 111 but it doesn't happen), those values are simply incremented by 7 to keep on
    * counting after 7th first cases.
    *
    * see "first modes" comments in ira.h
    */
   ira->addressMode = (seaow & EFFECTIVE_ADDRESS_MASK);
   if ((ira->addressMode & EA_MODE_FIELD_MASK) != EA_REG_FIELD_IS_NOT_REG_NUMBER)
      ira->addressMode = (ira->addressMode >> 3);
   else
      ira->addressMode = 7 + ira->ea_register;

   if (instructions[ira->opCodeNumber].flags & OPF_OPERAND_SIZE)
      ira->extension = instructions[ira->opCodeNumber].flags & OPF_OPERAND_MASK;
   else
      ira->extension = (seaow & EXTENSION_SIZE_MASK) >> 6;
}
