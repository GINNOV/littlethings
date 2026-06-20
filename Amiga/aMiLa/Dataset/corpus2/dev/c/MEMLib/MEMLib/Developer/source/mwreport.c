/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1989 The Software Distillery.                    *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          The Software Distillery                              *
* |  . |//           235 Trillingham Lane                                 *
* ======             Cary, NC 27513                                       *
*                    BBS:(919)-471-6436                                   *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "mempriv.h"

extern struct MWGlobal mwg;

void MWReport(char *title, long level)
{
   struct MWAlc *mwa;

   if(!(mwg.flags & MWF_ACTIVE)) return;

   MWCheck();

   if(mwg.flags & MWF_NOLOG) return;

   if(level == MWR_NONE) return;


   MWPrintf("%s\n********** CURRENT MEMORY USAGE SUMMARY\n",MW_NEWLINE);
   if(title) MWPrintf("%s\n", title);

   MWPrintf("\nCurrent chip usage = %ld bytes in %ld allocations\n",
            mwg.sum[MWT_CHIP], mwg.num[MWT_CHIP]);

   MWPrintf("Current fast usage = %ld bytes in %ld allocations\n",
            mwg.sum[MWT_FAST], mwg.num[MWT_FAST]);

   MWPrintf("Peak chip usage = %ld bytes; Peak fast usage = %ld bytes\n\n",
      mwg.max[MWT_CHIP], mwg.max[MWT_FAST]);

   if(level == MWR_SUM) return;

   MWPrintf("********** CURRENT MEMORY USAGE DETAIL\n\n");

   if(mwg.first)
   {
      for(mwa=mwg.first; mwa; mwa=mwa->next)
         MWPrintAlc(mwa);
   }
   else
      MWPrintf("No memory currently allocated\n");

   MWPrintf("\n**********\n\n");
}
