/*
 * megadrive.c
 *
 *  Created on: 21 sept 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : megadrive.c
 *      Purpose  : Functions about Megadrive (Genesis) roms
 *      Copyright: (C)2015-2016 Nicolas Bastien
 */

#include <stdio.h>
#include <stdint.h>

#include "megadrive.h"

int BelongToPreviousCycle(int tocheck)
{
   int start, cur, checked;

   checked = 0;

   if (tocheck < SMD_BUFFER_SIZE)
      for (start = 0; !checked && start < tocheck; start++)
         if (start == tocheck)
            checked = 1;
         else
         {
            cur = NEXT_IN_CYCLE(start);
            while (!checked && cur != start)
               if (cur == tocheck)
                  checked = 1;
               else
                  cur = NEXT_IN_CYCLE(cur);
         }

   return checked;
}

void SMD16kBufferInsituTransposition(uint8_t *smd16kbuffer)
{
   int start, cur;
   char tmp, prev;

   for (start = 1; start < SMD_BUFFER_SIZE; start += 2)
      if (!BelongToPreviousCycle(start))
      {
         prev = smd16kbuffer[start];
         cur = NEXT_IN_CYCLE(start);
         while (cur != start)
         {
            tmp = smd16kbuffer[cur];
            smd16kbuffer[cur] = prev;
            prev = tmp;
            cur = NEXT_IN_CYCLE(cur);
         }
         smd16kbuffer[start] = prev;
      }
}
