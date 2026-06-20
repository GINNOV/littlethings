/*
 * amiga_hunks.c
 *
 *  Created on: 1 may 2015
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : amiga_hunks.c
 *      Purpose  : Functions about Amiga's executable files format: Hunk
 *      Copyright: (C)2015-2016 Nicolas Bastien
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "ira.h"
#include "amiga_hunks.h"
#include "constants.h"
#include "ira_2.h"
#include "supp.h"

void ReadAmigaHunkObject(ira_t *ira)
{
   uint32_t hunk, length, i;
   uint32_t dummy;

   fseek(ira->files.sourceFile, 4, SEEK_SET);
   ReadSymbol(ira->files.sourceFile, 0, 0, ira->symbolName);
   if (ira->params.pFlags & SHOW_RELOCINFO)
      printf("  Unit    : %s\n", ira->symbolName);

   while ((hunk = readbe32(ira->files.sourceFile)))
   { /* Type of hunk (Code,Data,...) */

      /* Bits 30 and 31 specify memory type for the hunk.
       * 00: any/public memory (fast preferred)
       * 01: chip memory
       * 10: fast memory
       * 11: next longword contains flags for a AllocMem() call */
      if ((hunk >> 30) == 3)
         /* AllocMem() flags */
         length = readbe32(ira->files.sourceFile);
      hunk &= 0x0000FFFF;

      switch (hunk)
      {
         case HUNK_CODE:
         case HUNK_DATA:
         case HUNK_BSS:
            length = readbe32(ira->files.sourceFile);
            ira->hunkCount++; /* number of hunks + 1 */
            ira->hunksSize = myrealloc(ira->hunksSize, ira->hunkCount * sizeof(uint32_t));
            ira->hunksSize[ira->hunkCount - 1] = length;
            if (hunk != HUNK_BSS) /* only with code and data */
               fseek(ira->files.sourceFile, length * 4, SEEK_CUR); /* skip length */
            break;
         case HUNK_DREL32:
         case HUNK_DREL16:
         case HUNK_DREL8:
         case HUNK_RELOC32:
         case HUNK_RELOC16:
         case HUNK_RELOC8:
         case HUNK_RELRELOC32:
            do
            {
               /* Read number of relocations */
               length = readbe32(ira->files.sourceFile);
               if (length)
                  fseek(ira->files.sourceFile, (length + 1) * 4, SEEK_CUR);
            } while (length);
            break;
         case HUNK_END:
            break;
         case HUNK_NAME:
            length = readbe32(ira->files.sourceFile);
            fseek(ira->files.sourceFile, length * 4, SEEK_CUR);
            break;
         case HUNK_DEBUG:
            length = readbe32(ira->files.sourceFile);
            fseek(ira->files.sourceFile, length * 4, SEEK_CUR);
            break;
         case HUNK_SYMBOL:
            do
            {
               length = readbe32(ira->files.sourceFile);
               if (length)
                  fseek(ira->files.sourceFile, (length + 1) * 4, SEEK_CUR);
            } while (length);
            break;
         case HUNK_EXT:
            do
            {
               uint8_t type;

               length = readbe32(ira->files.sourceFile);
               type = length >> 24;
               dummy = length;
               length &= 0x00FFFFFF;
               if (dummy)
               {
                  switch (type)
                  {
                     case EXT_SYMB:
                     case EXT_DEF:
                     case EXT_ABS:
                     case EXT_RES:
                     case EXT_COMMON:
                        fseek(ira->files.sourceFile, (length + 1) * 4, SEEK_CUR);
                        if (type == 130)
                        {
                           length = readbe32(ira->files.sourceFile);
                           fseek(ira->files.sourceFile, length * 4, SEEK_CUR);
                        }
                        break;
                     case EXT_REF32:
                     case EXT_RELREF32:
                     case EXT_REF16:
                     case EXT_REF8:
                     case EXT_DEXT32:
                     case EXT_DEXT16:
                     case EXT_DEXT8:
                        fseek(ira->files.sourceFile, length * 4, SEEK_CUR);
                        length = readbe32(ira->files.sourceFile);
                        fseek(ira->files.sourceFile, length * 4, SEEK_CUR);
                        break;
                     case EXT_RELCOMMON:
                     case EXT_ABSREF16:
                     case EXT_ABSREF8:
                        ExitPrg("HUNK_EXT sub-type=%d not supported yet.", (int) type);
                        break;
                     case EXT_RELREF26:
                        ExitPrg("Extended HUNK_EXT sub-type=%d not supported yet.", (int) type);
                        break;
                     default:
                        ExitPrg("Unknown HUNK_EXT sub-type=%d !", (int) type);
                        break;
                  }
               }
            } while (dummy);
            break;
         case HUNK_PPC_CODE:
         case HUNK_RELRELOC26:
            ExitPrg("Extended Hunk...:%08lx not supported yet.", (unsigned long) hunk);
            break;
         case HUNK_UNIT:
         case HUNK_LIB:
         case HUNK_INDEX:
         default:
            ExitPrg("Hunk...:%08lx not supported.", (unsigned long) hunk);
            break;

      } /* End - Switch() */

   } /* Read next hunk and relocate. */

   if (ira->params.pFlags & SHOW_RELOCINFO)
      printf("  Hunks : %d\n", (int) ira->hunkCount);

   /* Get memory according to the number of hunks found in object file */
   ira->hunksMemoryType = mycalloc(ira->hunkCount * sizeof(uint16_t));
   ira->hunksMemoryAttrs = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksType = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksOffs = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksContent = mycalloc(ira->hunkCount * sizeof(uint32_t *));

   fseek(ira->files.sourceFile, 4L, SEEK_SET);
   ReadSymbol(ira->files.sourceFile, 0, 0, ira->symbolName);

   ira->firstHunk = 0;
   ira->lastHunk = ira->hunkCount - 1;

   ExamineHunks(ira, 0);
}

void ReadAmigaHunkExecutable(ira_t *ira)
{
   int i;

   /* Seek after HUNK_HEADER's magic (0x000003F3), the 4th byte. */
   fseek(ira->files.sourceFile, 4L, SEEK_SET);

   /* Skip (unused) resident library name */
   while (ReadSymbol(ira->files.sourceFile, 0, 0, ira->symbolName))
      printf("  Unexpected resident library name in HUNK_HEADER : %s\n", ira->symbolName);

   /* Read number of hunks */
   ira->hunkCount = readbe32(ira->files.sourceFile);

   if (ira->params.pFlags & SHOW_RELOCINFO)
      printf("  Hunks : %d\n", (int) ira->hunkCount);

   /* Read first and last hunk numbers */
   ira->firstHunk = readbe32(ira->files.sourceFile);
   ira->lastHunk = readbe32(ira->files.sourceFile);

   /* Only resident libraries can have a first hunk not equal to 0 */
   if (ira->firstHunk)
      ExitPrg("Can't handle first hunk not equal to 0 (resident libraries not supported).");

   /* Get memory according to the number of hunks found in header */
   ira->hunksMemoryType = mycalloc(ira->hunkCount * sizeof(uint16_t));
   ira->hunksMemoryAttrs = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksSize = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksType = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksOffs = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->hunksContent = mycalloc(ira->hunkCount * sizeof(uint32_t *));

   /* Read hunk table to get hunk lengths */
   for (i = 0; i <= (ira->lastHunk - ira->firstHunk); i++)
   {
      /* Raw longword with bits 30 and 31 containing memory type */
      ira->hunksSize[i] = readbe32(ira->files.sourceFile);

      /* Bits 30 and 31 specify memory type for the hunk.
       * 00: any/public memory (fast preferred)
       * 01: chip memory
       * 10: fast memory
       * 11: next longword contains flags for a AllocMem() call (extension) */
      ira->hunksMemoryType[i] = (ira->hunksSize[i] >> 30) & 3; /* PUBLIC,CHIP,FAST,EXTENSION */
      if (ira->hunksMemoryType[i] == 3)
         /* AllocMem() flags */
         ira->hunksMemoryAttrs[i] = readbe32(ira->files.sourceFile);
      else
         ira->hunksMemoryAttrs[i] = 0;
   }

   ExamineHunks(ira, 1);
}

void ExamineHunks(ira_t *ira, int exe)
{
   char hunkName[STDNAMELENGTH];
   uint8_t type;
   uint32_t i, dummy, offset, offs, value;
   uint32_t relocnt, relocnt1;
   uint16_t nextHunk = 0, out_of_range = 0, BUF16[1];
   uint32_t BUF32[1], hunkLen = 0, hunk, relomod;
   uint32_t OVL_Size, OVL_Level, OVL_Data[8];

   hunkName[0] = 0;

   for (offs = ira->params.prgStart, i = 0; i < ira->hunkCount; i++)
   {
      /* calculate offsets for relocation */
      ira->hunksSize[i] *= 4;
      ira->hunksOffs[i] = offs;
      offs += ira->hunksSize[i];

      /* get memory for hunks */
      ira->hunksContent[i] = mycalloc(ira->hunksSize[i]);
   }

   /* read hunks and relocate */
   for (i = 0; i < ira->hunkCount;)
   {
      /* Hunk type (Code,Data,...) */
      if ((fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile)) != 1)
         break;
      BUF32[0] = be32(BUF32);
      hunk = BUF32[0] & 0x0000ffff;

      switch (hunk)
      {
         case HUNK_CODE:
         case HUNK_DATA:
         case HUNK_BSS:
            i += nextHunk;
            nextHunk = 1;

            if (BUF32[0] & 0xc0000000)
            {
               ira->hunksMemoryType[i] = (BUF32[0] >> 30) & 3;
               if (ira->hunksMemoryType[i] == 3)
                  ira->hunksMemoryAttrs[i] = readbe32(ira->files.sourceFile);
            }

            ira->hunksType[i] = hunk;
            fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile); /* length of hunk */
            hunkLen = be32(BUF32);

            /* optional overlay hunks */
            if (i > ira->lastHunk)
            {
               printf("i > LastHunk\n");
               /* calculate relocation offset */
               ira->hunksSize[i] = hunkLen * 4;
               ira->hunksOffs[i] = offs;
               offs += ira->hunksSize[i];
               /* allocate memory for hunk */
               ira->hunksContent[i] = mycalloc(ira->hunksSize[i]);
            }

            if (hunk != HUNK_BSS) /* for code and data only */
               fread(ira->hunksContent[i], sizeof(uint32_t), hunkLen, ira->files.sourceFile); /* longwords in memory */

            if (ira->params.pFlags & SHOW_RELOCINFO)
            {
               printf("\n    Module %d : %s ,%-8s", (int) i, modname[ira->hunksType[i] - HUNK_CODE], memtypename[ira->hunksMemoryType[i]]);
               if (ira->hunksMemoryType[i] == 3)
                  printf("($%lx)", (unsigned long) ira->hunksMemoryAttrs[i]);
               if (hunkName[0])
               {
                  printf(" ,Name='%s'", hunkName);
                  hunkName[0] = 0;
               }
               if (ira->hunksType[i] == HUNK_BSS)
                  printf(" ,%ld Bytes.\n", (long) ira->hunksSize[i]);
               else
               {
                  printf(" ,%ld Bytes", (long) (hunkLen * 4));
                  if (ira->hunksSize[i] - hunkLen * 4)
                     printf(" (+ %ld BSS).\n", (long) (ira->hunksSize[i] - hunkLen * 4));
                  else
                     printf(".\n");
               }
            }
            break;
         case HUNK_DREL16:
         case HUNK_DREL8:
         case HUNK_RELOC16:
         case HUNK_RELOC8:
            relocnt1 = 0;
            do
            {
               /* read number of relocations */
               if ((fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile)) != 1)
                  break;
               relocnt1 = be32(BUF32);
               relocnt1 += relocnt;
               if (relocnt)
                  fseek(ira->files.sourceFile, (relocnt + 1) * sizeof(uint32_t), SEEK_CUR);
            } while (relocnt);
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("      Hunk_(D)Reloc16/8: %ld entries\n", (long) relocnt1);
            break;
         case HUNK_DREL32: /* V37+ */
         case HUNK_RELOC32SHORT: /* V39+ */
         case HUNK_RELRELOC32: /* V39+ */
            if (ira->params.pFlags & SHOW_RELOCINFO)
            {
               if (hunk == HUNK_DREL32)
                  printf("      Hunk_DRel32: ");
               if (hunk == HUNK_RELOC32SHORT)
                  printf("      Hunk_Reloc32Short: ");
               if (hunk == HUNK_RELRELOC32)
                  printf("      Hunk_RelReloc32: ");
            }
            if (!exe && hunk == HUNK_RELRELOC32) goto obj_relreloc32;
            relocnt1 = 0;
            do
            {
               /* read number of relocations */
               if ((fread(BUF16, sizeof(uint16_t), 1, ira->files.sourceFile)) != 1)
                  break;
               if (!(relocnt = be16(BUF16)))
               {
                  /* alignment check: take fread() from above into account*/
                  if ((relocnt1+1) & 1)
                     fread(BUF16, sizeof(uint16_t), 1, ira->files.sourceFile);
                  break;
               }
               relocnt1 += relocnt;

               /* read referenced hunk */
               if ((fread(BUF16, sizeof(uint16_t), 1, ira->files.sourceFile)) != 1)
                  break;
               relomod = be16(BUF16);
               if (relomod > ira->lastHunk)
                  ExitPrg("Relocation: Bad Hunk (%ld).", (long) relomod);

               /* execute relocation */
               ira->RelocNumber = relocnt;
               ira->DRelocBuffer = mycalloc(ira->RelocNumber * sizeof(uint16_t));
               fread(ira->DRelocBuffer, sizeof(uint16_t), ira->RelocNumber, ira->files.sourceFile);
               while (relocnt--)
               {
                  offset = be16(&ira->DRelocBuffer[relocnt]);
                  if (offset > (ira->hunksSize[i] - 4))
                     ExitPrg("Relocation: Bad offset ((offset=%ld) > %ld).", (long) (ira->hunksSize[i] - 4));

                  if (hunk == HUNK_RELRELOC32)
                  {
                     int32_t pc = ira->hunksOffs[i] + offset;
                     int32_t add = be32((uint8_t *) ira->hunksContent[i] + offset);

                     wbe32((uint8_t *)ira->hunksContent[i] + offset,
                           (int32_t)ira->hunksOffs[relomod] - pc + add);
                  }
                  else
                  {
                     dummy = be32((uint8_t *) ira->hunksContent[i] + offset);
                     if ((int32_t) dummy < 0L || dummy >= ira->hunksSize[relomod])
                        out_of_range = 1;
                     dummy += (int32_t) ira->hunksOffs[relomod];
                     wbe32((uint8_t *) ira->hunksContent[i] + offset, dummy);
                     if (out_of_range)
                     { /* hunk-spanning lables */
                        InsertReloc(ira->hunksOffs[i] + offset, ira->hunksOffs[relomod], dummy - ira->hunksOffs[relomod], relomod);
                        InsertLabel(ira->hunksOffs[relomod]);
                        out_of_range = 0;
                     }
                     else
                     {
                        InsertReloc(ira->hunksOffs[i] + offset, dummy, 0L, relomod);
                        InsertLabel(dummy);
                     }
                  }
               }
               free(ira->DRelocBuffer);
               ira->DRelocBuffer = 0;
            } while (1);
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("%ld entries\n", (long) relocnt1);
            break;
         case HUNK_RELOC32:
            if (ira->params.pFlags & SHOW_RELOCINFO)
            {
               if (hunk == HUNK_RELOC32)
                  printf("      Hunk_Reloc32: ");
            }
         obj_relreloc32:
            relocnt1 = 0;
            do
            {
               /* read number of relocations */
               if ((fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile)) != 1)
                  break;
               relocnt = be32(BUF32);
               if (!relocnt)
                  break;
               relocnt1 += relocnt;

               /* read referenced hunk */
               if ((fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile)) != 1)
                  break;
               relomod = be32(BUF32);
               if (relomod > ira->lastHunk)
                  ExitPrg("Relocation: Bad Hunk (%d).", (int) relomod);

               /* execute relocation */
               ira->RelocNumber = relocnt;
               ira->RelocBuffer = mycalloc(ira->RelocNumber * 4);
               fread(ira->RelocBuffer, sizeof(uint32_t), ira->RelocNumber, ira->files.sourceFile);
               while (relocnt--)
               {
                  offset = be32(&ira->RelocBuffer[relocnt]);
                  if ((int32_t) offset < 0 || offset > (ira->hunksSize[i] - 4))
                     ExitPrg("Relocation: Bad offset (0 <= (offset=%ld) <= %ld).", (long) offset, (long) (ira->hunksSize[i] - 4));

                  if (hunk == HUNK_RELRELOC32)
                  {
                     int32_t pc = ira->hunksOffs[i] + offset;
                     int32_t add = be32((uint8_t *) ira->hunksContent[i] + offset);

                     wbe32((uint8_t *)ira->hunksContent[i] + offset,
                           (int32_t)ira->hunksOffs[relomod] - pc + add);
                  }
                  else
                  {
                     dummy = be32((uint8_t *) ira->hunksContent[i] + offset);
                     if ((int32_t) dummy < 0L || dummy >= ira->hunksSize[relomod])
                        out_of_range = 1;
                     dummy += (int32_t) ira->hunksOffs[relomod];
                     wbe32((uint8_t *) ira->hunksContent[i] + offset, dummy);
   
                     if (out_of_range)
                     { /* hunk-spanning labels */
                        InsertReloc(ira->hunksOffs[i] + offset, ira->hunksOffs[relomod], dummy - ira->hunksOffs[relomod], relomod);
                        InsertLabel(ira->hunksOffs[relomod]);
                        out_of_range = 0;
                     }
                     else
                     {
                        InsertReloc(ira->hunksOffs[i] + offset, dummy, 0L, relomod);
                        InsertLabel(dummy);
                     }
                  }
               }
               free(ira->RelocBuffer);
               ira->RelocBuffer = 0;
            } while (1);
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("%ld entries\n", (long) relocnt1);
            break;
         case HUNK_OVERLAY:
            fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
            OVL_Size = be32(BUF32);
            fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
            OVL_Level = be32(BUF32);
            fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
            fseek(ira->files.sourceFile, -(int)sizeof(uint32_t), SEEK_CUR);
            if (be32(BUF32) == 0)
            {
               OVL_Level -= 2;
               OVL_Size = (OVL_Size - OVL_Level + 1) / 8;
               fseek(ira->files.sourceFile, (OVL_Level + 1) * 4, SEEK_CUR);
            }
            else
               OVL_Size = OVL_Size / 8;
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("\n    Hunk_Overlay: %ld Level, %ld Entries\n", (long) OVL_Level, (long) OVL_Size);
            while (OVL_Size--)
            {
               fread(&OVL_Data, sizeof(uint32_t), 8, ira->files.sourceFile);
               if (ira->params.pFlags & SHOW_RELOCINFO)
               {
                  printf("      SeekOffset: $%08lx\n", (unsigned long) be32(&OVL_Data[0]));
                  printf("      Dummy1    : %ld\n", (long) be32(&OVL_Data[1]));
                  printf("      Dummy2    : %ld\n", (long) be32(&OVL_Data[2]));
                  printf("      Level     : %ld\n", (long) be32(&OVL_Data[3]));
                  printf("      Ordinate  : %ld\n", (long) be32(&OVL_Data[4]));
                  printf("      FirstHunk : %ld\n", (long) be32(&OVL_Data[5]));
                  printf("      SymbolHunk: %ld\n", (long) be32(&OVL_Data[6]));
                  printf("      SymbolOffX: %08lx\n\n", (long) be32(&OVL_Data[7]));
               }
            }
            break;
         case HUNK_END:
         case HUNK_BREAK:
            i += nextHunk;
            nextHunk = 0;
            break;
         case HUNK_NAME:
            ReadSymbol(ira->files.sourceFile, 0, 0, ira->symbolName);
            strcpy(hunkName, ira->symbolName);
            break;
         case HUNK_DEBUG:
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("      hunk_debug (skipped).\n");
            fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
            fseek(ira->files.sourceFile, be32(BUF32) * sizeof(uint32_t), SEEK_CUR);
            break;
         case HUNK_SYMBOL:
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("      hunk_symbol:\n");
            while ((dummy = ReadSymbol(ira->files.sourceFile, &value, 0, ira->symbolName)))
               if (value > ira->hunksSize[i])
                  fprintf(stderr, "Symbol %s value $%08lx not in section limits.\n", ira->symbolName, (unsigned long) value);
               else
               {
                  value += (ira->hunksOffs[i]);
                  if (ira->params.pFlags & SHOW_RELOCINFO)
                     printf("        %s = %08lx\n", ira->symbolName, (unsigned long) value);
                  InsertSymbol(ira->symbolName, value);
                  InsertLabel(value);
               }
            break;
         case HUNK_EXT:
            if (ira->params.pFlags & SHOW_RELOCINFO)
               printf("      hunk_ext:\n");
            do
            {
               dummy = ReadSymbol(ira->files.sourceFile, &value, &type, ira->symbolName);
               if (dummy)
               {
                  switch (type)
                  {
                     uint32_t ref;
                  case EXT_SYMB:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_symb:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s = %08lx\n", ira->symbolName, (unsigned long) value);
                     break;
                  case EXT_DEF:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_def:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s = %08lx\n", ira->symbolName, (unsigned long) value);
                     break;
                  case EXT_ABS:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_abs:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s = %08lx\n", ira->symbolName, (unsigned long) value);
                     break;
                  case EXT_RES:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_res:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s = %08lx\n", ira->symbolName, (unsigned long) value);
                     break;
                  case EXT_COMMON:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_common:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, Size=%ld\n", ira->symbolName, (long) value);
                     fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                     fseek(ira->files.sourceFile, be32(BUF32) * sizeof(uint32_t), SEEK_CUR);
                     break;
                  case EXT_REF32:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_ref32:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_RELREF32:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_relref32:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_REF16:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_ref16:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_REF8:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_ref8:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_DEXT32:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_dext32:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_DEXT16:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_dext16:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_DEXT8:
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("        ext_dext8:\n");
                     if (ira->params.pFlags & SHOW_RELOCINFO)
                        printf("          %s, %ld reference(s)\n", ira->symbolName, (long) value);
                     while (value--)
                     {
                        fread(BUF32, sizeof(uint32_t), 1, ira->files.sourceFile);
                        ref = be32(BUF32);
                        if (ira->params.pFlags & SHOW_RELOCINFO)
                           printf("          %08lx\n", (unsigned long) ref);
                     }
                     break;
                  case EXT_RELCOMMON:
                  case EXT_ABSREF16:
                  case EXT_ABSREF8:
                     ExitPrg("HUNK_EXT sub-type=%d not supported yet.", (int) type);
                     break;
                  case EXT_RELREF26:
                     ExitPrg("Extended HUNK_EXT sub-type=%d not supported yet.", (int) type);
                     break;
                  default:
                     ExitPrg("Unknown HUNK_EXT sub-type=%d !", (int) type);
                     break;
                  }
               }
            } while (dummy);
            break;
         case HUNK_PPC_CODE:
         case HUNK_RELRELOC26:
            ExitPrg("Extended Hunk...:%08lx not supported yet.", (unsigned long) hunk);
            break;
         case HUNK_UNIT:
         case HUNK_LIB:
         case HUNK_INDEX:
         default:
            ExitPrg("Hunk...:%08lx not supported.", (unsigned long) hunk);
            break;

      } /* End of switch() */

   } /* read next hunk */
   printf("\n");

   /* write data to file and release memory */
   for (i = 0; i < ira->hunkCount; i++)
   {
      fwrite(ira->hunksContent[i], 1, ira->hunksSize[i], ira->files.binaryFile);
      free(ira->hunksContent[i]);
   }
   free(ira->hunksContent);
   ira->hunksContent = 0;
}

/*
 * ReadSymbol will return the size of the string written into ira->standardName
 *
 * If val and type are null : just get the symbol name (resident libraries list from HUNK_HEADER)
 * If val is not null and type is null : get the symbol name and its value (HUNK_SYMBOL)
 * If val and type are not null : get the HUNK_EXT symbol name, its value and its type (HUNK_EXT)
 */
uint32_t ReadSymbol(FILE *file, uint32_t *val, uint8_t *type, uint8_t *name)
{
   uint32_t BUF32[1];
   uint32_t length;
   uint32_t nameSize = 0;

   /* Let's read the number of long words */
   if ((fread(BUF32, sizeof(uint32_t), 1, file)) != 1)
      ExitPrg("ReadSymbol error (can not read size of symbol's name).");

   /* Let's get the long word value, big-endian way, as length.
    * If it is greater than 0, we can do something,
    * otherwise, let's default value (which is 0) be returned */
   if ((length = be32(BUF32)))
   {
      /* If asked for a HUNK_EXT type */
      if (type)
      {
         /* Symbol data units in HUNK_EXT are defined as follows:
          * 1 byte : symbol type
          * 3 byte : length of the symbol's name (in longwords) */

         /* Let's split length as described */
         *type = (length >> 24);
         length &= 0x00FFFFFF;
      }

      /* As far as length is a number of long words, let's multiply it by 4 to have a number of bytes. */
      length *= 4;

      /* Obvious check in order not to read (and then to write) a string longer than ira->standardName */
      if (length >= STDNAMELENGTH)
         nameSize = STDNAMELENGTH - 1;
      else
         nameSize = length;

      /* Let's get symbol's name */
      if ((fread(name, 1, nameSize, file)) != nameSize)
         ExitPrg("ReadSymbol error (symbol's name has not the expected size).");

      /* String terminator (follow me if you want to live) */
      name[nameSize] = 0;

      /* If length was too big, the symbol's name has been truncated.
       * But we still need to seek at the end of the string containing the symbol's name. */
      if (length > nameSize)
         fseek(file, length - nameSize, SEEK_CUR);

      /* If asked for a HUNK_SYMBOL or HUNK_EXT value */
      if (val)
      {
         if ((fread(BUF32, sizeof(uint32_t), 1, file)) != 1)
            ExitPrg("ReadSymbol error (fail to read symbol's value).");
         *val = be32(BUF32);
      }
   }

   /* And, finally, returns the size of the string written into ira->symbolName */
   return (nameSize);
}
