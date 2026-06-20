/*
 * config.c
 *
 *  Created on: 3 may 2015
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : config.c
 *      Purpose  : Config file
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2024 Frank Wille, (C)2014-2019 Nicolas Bastien
 */

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ira.h"

#include "config.h"
#include "constants.h"
#include "ira_2.h"
#include "supp.h"

void CreateConfig(ira_t *ira)
{
   uint32_t i;
   FILE *configfile;
   uint32_t machine;
   uint32_t fpu;

   if ((configfile = fopen(ira->filenames.configName, "r")))
   {
      fclose(configfile);
      ExitPrg("Config file \"%s\" is already present! Remove it first.", ira->filenames.configName);
   }

   if (!(configfile = fopen(ira->filenames.configName, "w")))
      ExitPrg("Can't open config file \"%s\".", ira->filenames.configName);

   /* Specify processor with a default one : M68000 */
   machine = 68000;
   if (ira->params.cpuType & M010UP)
   {
      if (ira->params.cpuType & M68010)
         machine = 68010;
      if (ira->params.cpuType & M68020)
         machine = 68020;
      if (ira->params.cpuType & M68030)
         machine = 68030;
      if (ira->params.cpuType & M68040)
         machine = 68040;
      if (ira->params.cpuType & M68060)
         machine = 68060;
   }
   fprintf(configfile, "MACHINE %lu\n", (unsigned long) machine);

   /* Specify memory management coprocessor only if external (i.e M68851) */
   if (ira->params.cpuType & MMU_EXTERNAL)
      fprintf(configfile, "MACHINE 68851\n");

   /* Specify arithmetic coprocessor only if external (i.e M68881 or M68882) */
   if (ira->params.cpuType & FPU_EXTERNAL)
   {
      if (ira->params.cpuType & M68881)
         machine = 68881;
      if (ira->params.cpuType & M68882)
         machine = 68882;
      fprintf(configfile, "MACHINE %lu\n", (unsigned long) machine);
   }

   fprintf(configfile, "ENTRY $%08lX\n", (unsigned long) ira->params.codeEntry);
   fprintf(configfile, "OFFSET $%08lX\n", (unsigned long) ira->params.prgStart);

   if (ira->params.pFlags & BASEREG2)
   {
      fprintf(configfile, "BASEREG %u\n", (unsigned) ira->params.baseReg);
      fprintf(configfile, "BASEADR $%lX\n", (unsigned long) ira->baseReg.baseAddress);
      fprintf(configfile, "BASEOFF %hd\n", ira->baseReg.baseOffset);
   }

   for (i = 0; i < ira->symbols.symbolCount; i++)
      fprintf(configfile, "SYMBOL %s $%08lX\n", ira->symbols.symbolName[i], (unsigned long) ira->symbols.symbolValue[i]);

   for (i = 0; i < ira->codeArea.codeAreas; i++)
      fprintf(configfile, "CODE $%08X - $%08lX\n", ira->codeArea.codeArea1[i], (unsigned long) ira->codeArea.codeArea2[i]);

   fputs("END\n", configfile);

   fclose(configfile);
}

static FILE *open_config(ira_t *ira)
{
   FILE *configfile;

   if (!(configfile = fopen(ira->filenames.configName, "r")))
      if (ira->params.pFlags & PREPROC)
         printf("WARNING: Can't find config file \"%s\"\n", ira->filenames.configName);
      else
         ExitPrg("Can't open config file \"%s\".", ira->filenames.configName);
   return configfile;
}

void PreparseConfig(ira_t *ira)
{
   FILE *configfile;
   char cfg[256], *ptr1, *ptr2, *ptr3, *symbol, *equ_name, *label, c;
   int operand_size, line_number;
   uint32_t value;
   uint16_t i, j;

   if (configfile = open_config(ira))
   {
      line_number = 0;
      do
      {
         line_number++;
         if (!(fgets(cfg, 256, configfile)))
            break;

         if (!strnicmp(cfg, "OFFSET", 6))
         {
            if ((ptr1 = strchr(cfg, '$')))
               ira->params.prgStart = stch_l(ptr1 + 1);
            else
               ira->params.prgStart = atoi(&cfg[6]);
            if ((int32_t) ira->params.prgStart < 0L)
               ExitPrg("CONFIG ERROR: OFFSET must not be negative (at line %d).", line_number);
         }
      } while (strnicmp(cfg, "END", 3));

      fclose(configfile);
   }
}

void ReadConfig(ira_t *ira)
{
   FILE *configfile;
   uint32_t area1, area2, base;
   char cfg[256], *ptr1, *ptr2, *ptr3, *symbol, *equ_name, *label, c;
   int operand_size, line_number;
   uint32_t value;
   uint16_t i, j;
   uint32_t machine;

   if (configfile = open_config(ira))
   {
      line_number = 0;
      do
      {
         line_number++;

         /* Try to read at most 255 bytes from next line */
         if (!(fgets(cfg, 256, configfile)))
            /* If fail, let's get out ! */
            break;

         /* Simply ignore empty line */
         if (cfg[0] == '\n')
            /* And let's go to the next line */
            continue;

         /* Ignore line starting by comments symbol
          * note: FULL LINE has to be ignored !
          *       otherwise string starting at 255th byte will be considered as the next line in the next loop */
         if (cfg[0] == ';')
         {
            ptr1 = GetFullLine(cfg, configfile);
            /* Don't forget to free allocated memory (yes, it seams silly to get and free immediatly...) */
            if (ptr1 != cfg)
               free(ptr1);

            /* And let's go to the next line */
            continue;
         }

         if (!strnicmp(cfg, "CODE", 4))
         {
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            area2 = area1;
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1)
            {
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: %08lx out of range (at line %d).", (unsigned long) area1, line_number);
               if (ptr2)
               {
                  if (area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                     ExitPrg("CONFIG ERROR: %08lx out of range (%08lx-%08lx) (at line %d).", (unsigned long) area2, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
                  if (area1 > area2)
                  {
                     ExitPrg("CONFIG ERROR: %08lx > %08lx (at line %d).", (unsigned long) area1, (unsigned long) area2, line_number);
                  }
                  else
                     InsertCNFArea(ira, area1, area2);
                  if (area1 < area2)
                     InsertCodeAdr(ira, area1);
               }
               else
                  if (area1 < ira->params.prgEnd)
                     InsertCodeAdr(ira, area1);
            }
         }
         else if (!strnicmp(cfg, "PTRS", 4))
         {
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            area2 = area1 + 4;
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1)
            {
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: PTRS %08lx out of range (at line %d).", (unsigned long) area1, line_number);
               if (ptr2)
               {
                  if (area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                     ExitPrg("CONFIG ERROR: PRTS %08lx out of range (%08lx-%08lx) (at line %d).", (unsigned long) area2, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
                  if (area1 > area2)
                     ExitPrg("CONFIG ERROR: PTRS %08lx > %08lx (at line %d).", (unsigned long) area1, (unsigned long) area2, line_number);
               }
               for (; (area1 + 3) < area2; area1 += 4)
               {
                  for (i = 0; i < ira->hunkCount; i++)
                  {
                     if (area1 >= ira->hunksOffs[i] && (area2 + 3) < (ira->hunksOffs[i] + ira->hunksSize[i]))
                     {
                        value = be32((uint8_t *) ira->buffer + (area1 - ira->params.prgStart));
                        InsertReloc(area1, value, 0, i);
                        InsertLabel(value);
                        break;
                     }
                  }
               }
            }
            else
               ExitPrg("CONFIG ERROR: PTRS address missing (at line %d).", line_number);
         }
         else if (!strnicmp(cfg, "NOPTRS", 4))
         {
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            area2 = area1 + 4;
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1)
            {
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: NOPTRS %08lx out of range (at line %d).", (unsigned long) area1, line_number);
               if (ptr2)
               {
                  if (area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                     ExitPrg("CONFIG ERROR: NOPRTS %08lx out of range (%08lx-%08lx) (at line %d).", (unsigned long) area2, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
                  if (area1 > area2)
                     ExitPrg("CONFIG ERROR: NOPTRS %08lx > %08lx (at line %d).", (unsigned long) area1, (unsigned long) area2, line_number);
               }
               InsertNoPointersArea(ira, area1, area2);
            }
            else
               ExitPrg("CONFIG ERROR: PTRS address missing (at line %d).", line_number);
         }
         else if (!strnicmp(cfg, "NBAS", 4))
         {
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1 && ptr2)
            {
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: NBAS %08lx out of range (at line %d).", (unsigned long) area1, line_number);
               if (area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: NBAS %08lx out of range (%08lx-%08lx) (at line %d).", (unsigned long) area2, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
               if (area1 > area2)
                  ExitPrg("CONFIG ERROR: NBAS %08lx > %08lx (at line %d).", (unsigned long) area1, (unsigned long) area2, line_number);
               InsertNoBaseArea(ira, area1, area2);
            }
            else
               ExitPrg("CONFIG ERROR: NBAS address missing (at line %d).", line_number);
         }
         else if (!strnicmp(cfg, "TEXT", 4))
         {
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1 && ptr2)
            {
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: TEXT %08lx out of range (at line %d).", (unsigned long) area1, line_number);
               if (area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: TEXT %08lx out of range (%08lx-%08lx) (at line %d).", (unsigned long) area2, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
               if (area1 > area2)
                  ExitPrg("CONFIG ERROR: TEXT %08lx > %08lx (at line %d).", (unsigned long) area1, (unsigned long) area2, line_number);
               InsertTextArea(ira, area1, area2);
            }
            else
               ExitPrg("CONFIG ERROR: TEXT address missing (at line %d).", line_number);
         }
         else if (!strnicmp(cfg, "JMPB", 4) || !strnicmp(cfg, "JMPW", 4) || !strnicmp(cfg, "JMPL", 4))
         {
            ptr3 = 0;
            if ((ptr1 = strchr(cfg, '$')))
               area1 = stch_l(ptr1 + 1);
            if (ptr1 && (ptr2 = strchr(ptr1 + 1, '$')))
               area2 = stch_l(ptr2 + 1);
            if (ptr1 && ptr2 && (ptr3 = strchr(ptr2 + 1, '$')))
               base = stch_l(ptr3 + 1);
            if (ptr1 && ptr2)
            {
               if (!ptr3)
                  base = area1;
               if (area1 < ira->params.prgStart || area1 > ira->params.prgEnd || area2 < ira->params.prgStart || area2 > ira->params.prgEnd)
                  ExitPrg("CONFIG ERROR: %.4s %08lx-%08lx out of range (at line %d).", cfg, (unsigned long) area1, (unsigned long) area2, line_number);
               if (area1 > area2)
                  ExitPrg("CONFIG ERROR: %.4s %08lx > %08lx (at line %d).", cfg, (unsigned long) area1, (unsigned long) area2, line_number);
               switch (toupper((unsigned) cfg[3]))
               {
                  case 'B':
                     operand_size = 1;
                     break;
                  case 'W':
                     operand_size = 2;
                     break;
                  case 'L':
                     operand_size = 4;
                     break;
                  default:
                     ExitPrg("CONFIG ERROR: %.4s! (at line %d).", cfg, line_number);
                     break;
               }
               InsertJmpTabArea(ira, operand_size, area1, area2, base);
            }
            else
               ExitPrg("CONFIG ERROR: %.4s address missing (at line %d).", cfg, line_number);
         }
         else if (!strnicmp(cfg, "SYMBOL", 6))
         {
            /* Go to the first parameter */
            for (i = 6; isspace(cfg[i]); i++)
               ;

            /* The string symbol begins here and ends at word's end */
            for (symbol = &cfg[i]; isgraph(cfg[i]); i++)
               ;

            /* If symbol's name is empty */
            if (symbol == &cfg[i])
               ExitPrg("CONFIG ERROR: no symbol specified in SYMBOL directive ! (at line %d)", line_number);

            /* If configuration line ends after symbol's name
             * note: Need to check that HERE before overwriting cfg[i] by a null character */
            if (!cfg[i])
               ExitPrg("CONFIG ERROR: no address specified in SYMBOL directive ! (at line %d)", line_number);

            /* Don't forget to give an end to string symbol (which is, actually, inside string cfg) */
            cfg[i++] = '\0';

            /* Go to the second parameter */
            while (isspace(cfg[i]))
               i++;

            value = GetAddress(&cfg[i], line_number);

            if (value < ira->params.prgStart || value >= ira->params.prgEnd)
               ExitPrg("CONFIG ERROR: %s=%lu but must be within [%lu,%lu[ (at line %d).", cfg, (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
            InsertSymbol(symbol, value);
         }
         else if (!strnicmp(cfg, "MACHINE", 7))
         {
            machine = atoi(&cfg[7]);
            /* CPU (reset CPU choice every time, last to speak is right) */
            if (machine >= 68000 && machine <= 68060)
               ira->params.cpuType &= ~M680x0;
            if (machine == 68000)
               ira->params.cpuType |= M68000;
            if (machine == 68010)
               ira->params.cpuType |= M68010;
            if (machine == 68020)
               ira->params.cpuType |= M68020;
            if (machine == 68030)
               ira->params.cpuType |= M68030;
            if (machine == 68040)
               ira->params.cpuType |= M68040;
            if (machine == 68060)
               ira->params.cpuType |= M68060;

            /* MMU */
            if (machine == 68851)
               ira->params.cpuType |= M68851;

            /* FPU (reset FPU choice every time, last to speak is right) */
            if (machine >= 68881 && machine <= 68882)
               ira->params.cpuType &= ~FPU_EXTERNAL;
            if (machine == 68881)
               ira->params.cpuType |= M68881;
            if (machine == 68882)
               ira->params.cpuType |= M68882;

            if (ira->params.cpuType == 0)
               ExitPrg("CONFIG ERROR: unknown processor \"%s\" (at line %d).", cfg, line_number);
         }
         else if (!strnicmp(cfg, "OFFSET", 6))
         {
            /* parsed during PreparseConfig() */
         }
         else if (!strnicmp(cfg, "ENTRY", 5))
         {
            if ((ptr1 = strchr(cfg, '$')))
               ira->params.codeEntry = stch_l(ptr1 + 1);
            else
               ira->params.codeEntry = atoi(&cfg[5]);
         }
         else if (!strnicmp(cfg, "BASEREG", 7))
         {
            if ((ptr1 = strchr(&cfg[7], 'a')))
               ira->params.baseReg = atoi(ptr1 + 1);
            else
               if ((ptr1 = strchr(&cfg[7], 'A')))
                  ira->params.baseReg = atoi(ptr1 + 1);
               else
                  ira->params.baseReg = atoi(&cfg[7]);
            if (ira->params.baseReg > 7)
               ExitPrg("CONFIG ERROR: unknown address register \"%s\" (at line %d).", cfg, line_number);
            if (!(ira->params.pFlags & BASEREG2))
               ira->params.pFlags |= BASEREG1;
         }
         else if (!strnicmp(cfg, "BASEADR", 7))
         {
            if ((ptr1 = strchr(cfg, '$')))
               ira->baseReg.baseAddress = stch_l(ptr1 + 1);
            else
               ira->baseReg.baseAddress = atoi(&cfg[7]);
            ira->params.pFlags &= (~BASEREG1);
            ira->params.pFlags |= BASEREG2;
         }
         else if (!strnicmp(cfg, "BASEOFF", 7))
         {
            int32_t off;

            if ((ptr1 = strchr(cfg, '$')))
            {
               off = stch_l(ptr1 + 1);
               ira->baseReg.baseOffset = (int16_t) off;
            }
            else
               ira->baseReg.baseOffset = (int16_t) atoi(&cfg[7]);
         }
         else if (!strnicmp(cfg, "COMMENT", 7))
         {
            /* Get address */
            if ((ptr1 = strchr(cfg, '$')))
               value = stch_l(ptr1 + 1);
            else
               value = atoi(&cfg[7]);

            /* Is this address good ? */
            if (value < ira->params.prgStart || value >= ira->params.prgEnd)
               if (ptr1 && *ptr1 == '$')
                  ExitPrg("CONFIG ERROR: address $%lx must be within [$%lx,$%lx[ (at line %d).", (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
               else
                  ExitPrg("CONFIG ERROR: address %lu must be within [%lu,%lu[ (at line %d).", (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);

            /* Go to the second param */
            i = 7;
            while (isspace(cfg[i]))  /* skip whitespace between COMMENT and address */
               i++;
            while (isgraph(cfg[i]))  /* skip address */
               i++;
            if (isspace(cfg[i]))     /* only skip a single whitespace char to preserve formatting */
               i++;

            /* A comment can be greater than 255 bytes */
            ptr1 = GetFullLine(cfg, configfile);
            InsertComment(ira, value, &ptr1[i]);

            /* Don't forget to free allocated memory */
            if (ptr1 != cfg)
               free(ptr1);
         }
         else if (!strnicmp(cfg, "BANNER", 6))
         {
           /* Get address */
           if ((ptr1 = strchr(cfg, '$')))
             value = stch_l(ptr1 + 1);
           else
             value = atoi(&cfg[6]);

           /* Is this address good ? */
           if (value < ira->params.prgStart || value >= ira->params.prgEnd)
              if (ptr1 && *ptr1 == '$')
                 ExitPrg("CONFIG ERROR: address $%lx must be within [$%lx,$%lx[ (at line %d).", (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
              else
                 ExitPrg("CONFIG ERROR: address %lu must be within [%lu,%lu[ (at line %d).", (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);

           /* Go to the second param */
           i = 6;
           while (isspace(cfg[i]))  /* skip whitespace between BANNER and address */
             i++;
           while (isgraph(cfg[i]))  /* skip address */
             i++;
           if (isspace(cfg[i]))     /* only skip a single whitespace char to preserve formatting */
             i++;

           /* A banner can be greater than 255 bytes */
           ptr1 = GetFullLine(cfg, configfile);
           InsertBanner(ira, value, &ptr1[i]);

           /* Don't forget to free allocated memory */
           if (ptr1 != cfg)
             free(ptr1);
         }
         else if (!strnicmp(cfg, "EQU", 3))
         {
            /* EQU directive have undefined number of arguments: line can be greater than 255 bytes */
            ptr1 = GetFullLine(cfg, configfile);

            /* Go to the first parameter */
            for (i = 3; isspace(ptr1[i]); i++)
               ;

            /* The string equ_name begins here and ends at word's end */
            for (equ_name = &ptr1[i]; isgraph(ptr1[i]); i++)
               ;

            /* If EQU's name is empty */
            if (equ_name == &ptr1[i])
               ExitPrg("CONFIG ERROR: no name specified in EQU directive ! (at line %d)", line_number);

            /* If configuration line ends after EQU's name
             * note: Need to check that HERE before overwriting cfg[i] by a null character */
            if (!ptr1[i])
               ExitPrg("CONFIG ERROR: there must be at least one address in EQU directive ! (at line %d)", line_number);

            /* Don't forget to give an end to string equ_name (which is, actually, inside string cfg) */
            ptr1[i++] = '\0';

            /* If EQU's name is reserved by IRA
             * note: CheckEquateName does not return on error */
            CheckEquateName(equ_name, line_number);

            while (ptr1[i])
            {
               /* Go to the next parameter */
               while (isspace(ptr1[i]))
                  i++;

               /* If end of string not reached, here is the next parameter */
               if (ptr1[i])
               {
                  value = GetAddress(&ptr1[i], line_number);
                  /* keep hypothetical '$' for error message */
                  c = ptr1[i];

                  /* Go to the operand size or to next space */
                  while (ptr1[i] != '.' && !isspace(ptr1[i]))
                     i++;

                  if (isspace(ptr1[i++]))
                     ExitPrg("CONFIG ERROR: operand size is missing in EQU directive's address ! (at line %d)", line_number);

                  switch (toupper((int) ptr1[i]))
                  {
                     case 'Q':
                        operand_size = 0;
                        break;
                     case 'B':
                        operand_size = 1;
                        break;
                     case 'W':
                        operand_size = 2;
                        break;
                     case 'L':
                        operand_size = 4;
                        break;
                     default:
                        ExitPrg("CONFIG ERROR: '%c' unknown operand size in EQU directive's address ! (at line %d)", ptr1[i], line_number);
                        break;
                  }

                  if (value < ira->params.prgStart || value + operand_size > ira->params.prgEnd)
                     /* Here comes the hypothetical '$' */
                     if (c == '$')
                        ExitPrg("CONFIG ERROR: address $%x.%c for EQU \"%s\" must be within [$%lx,$%lx[ (at line %d)", value, ptr1[i], equ_name, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd - operand_size, line_number);
                     else
                        ExitPrg("CONFIG ERROR: address %d.%c for EQU \"%s\" must be within [%lu,%lu[ (at line %d)", value, ptr1[i], equ_name, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd - operand_size, line_number);

                  InsertEquate(ira, equ_name, value, operand_size);
                  i++;
               }
            }

            /* Don't forget to free allocated memory */
            if (ptr1 != cfg)
               free(ptr1);
         }
         else if (!strnicmp(cfg, "EXTSYM", 6))
         {
            /* Go to the first parameter */
            for (i = 6; isspace(cfg[i]); i++)
               ;

            /* The string symbol begins here and ends at word's end */
            for (symbol = &cfg[i]; isgraph(cfg[i]); i++)
               ;

            /* If symbol's name is empty */
            if (symbol == &cfg[i])
               ExitPrg("CONFIG ERROR: no symbol specified in EXTSYM directive ! (at line %d)", line_number);

            /* If configuration line ends after symbol's name
             * note: Need to check that HERE before overwriting cfg[i] by a null character */
            if (!cfg[i])
               ExitPrg("CONFIG ERROR: no address specified in EXTSYM directive ! (at line %d)", line_number);

            /* Don't forget to give an end to string symbol (which is, actually, inside string cfg) */
            cfg[i++] = '\0';

            /* If EXTSYM's name is reserved by IRA
             * note: CheckEquateName does not return on error */
            CheckEquateName(symbol, line_number);

            /* Go to the second parameter */
            while (isspace(cfg[i]))
               i++;

            value = GetAddress(&cfg[i], line_number);

#if 0 /* @@@ */
            if (value >= ira->params.prgStart && value < ira->params.prgEnd)
               ExitPrg("CONFIG ERROR: %s=%lu but must not be within [%lu,%lu[ (at line %d).", cfg, (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
#endif
            InsertExtsym(ira, symbol, value);
         }
         else if (!strnicmp(cfg, "LABEL", 5))
         {
            /* Go to the first parameter */
            for (i = 5; isspace(cfg[i]); i++)
               ;

            /* The string label begins here and ends at word's end */
            for (label = &cfg[i]; isgraph(cfg[i]); i++)
               ;

            /* If label's name is empty */
            if (label == &cfg[i])
               ExitPrg("CONFIG ERROR: no label specified in LABEL directive ! (at line %d)", line_number);

            /* If configuration line ends after label's name
             * note: Need to check that HERE before overwriting cfg[i] by a null character */
            if (!cfg[i])
               ExitPrg("CONFIG ERROR: no address specified in LABEL directive ! (at line %d)", line_number);

            /* Don't forget to give an end to string label (which is, actually, inside string cfg) */
            cfg[i++] = '\0';

            /* Go to the second parameter */
            while (isspace(cfg[i]))
               i++;

            value = GetAddress(&cfg[i], line_number);

            if (value < ira->params.prgStart || value >= ira->params.prgEnd)
               ExitPrg("CONFIG ERROR: %s=%lu but must be within [%lu,%lu[ (at line %d).", cfg, (unsigned long) value, (unsigned long) ira->params.prgStart, (unsigned long) ira->params.prgEnd, line_number);
            InsertSymbol(label, value);
            InsertLabel(value);
         }
         else if (strnicmp(cfg, "END", 3))
            ExitPrg("CONFIG ERROR: Unknown directive:%s (at line %d).", cfg, line_number);
      } while (strnicmp(cfg, "END", 3));

      fclose(configfile);
   }
}

void CheckEquateName(char *name, uint16_t line_number)
{
   int i;
   /* Let's check if equate name is not a reserved name */

   /* Check AllocMem flags */
   if (!strncmp(name, "MEMF_", 5))
      ExitPrg("ERROR: for EQU \"%s\", names starting with \"MEMF_\" are reserved for AllocMem() purpose (at line %d).", name, line_number);

   /* Check absolute Amiga's addresses */
   for(i = 0; i < x_adr_number; i++)
      if (!strcmp(name, x_adrs[i].name))
         ExitPrg("ERROR: for EQU \"%s\", it is an IRA reserved name (at line %d).", name, line_number);
}

void CNFAreaToCodeArea(ira_t *ira)
{
   uint32_t i;

   for (i = 0; i < ira->codeArea.cnfCodeAreas; i++)
      InsertCodeArea(&ira->codeArea, ira->codeArea.cnfCodeArea1[i], ira->codeArea.cnfCodeArea2[i]);

   /* need at least one code area for the following algorythm */
   if (ira->codeArea.codeAreas == 0)
      ira->codeArea.codeAreas = 1;
   SplitCodeAreas(ira);
}

void InsertBanner(ira_t *ira, uint32_t adr, char *banner)
{
   Comment_t *p;

   /* note: mycalloc doesn't return if allocation failed, so no need to check returned value */
   p = mycalloc(sizeof(Comment_t));

   /* If last banner exists, the new one will be its next */
   if (ira->lastBanner)
      ira->lastBanner->next = p;
   /* Else here we have our first banner */
   else
      ira->banners= p;

   /* Whatever happened, the new one is the new last one */
   ira->lastBanner = p;

   p->commentAdr = adr;
   p->commentText = mystrdup(banner);
   /* note: thanks to mycalloc(), p->next is already set to NULL */
}

void InsertComment(ira_t *ira, uint32_t adr, char *comment)
{
   Comment_t *p;

   /* note: mycalloc doesn't return if allocation failed, so no need to check returned value */
   p = mycalloc(sizeof(Comment_t));

   /* If last comment exists, the new one will be its next */
   if (ira->lastComment)
      ira->lastComment->next = p;
   /* Else here we have our first comment */
   else
      ira->comments = p;

   /* Whatever happened, the new one is the new last one */
   ira->lastComment = p;

   p->commentAdr = adr;
   p->commentText = mystrdup(comment);
   /* note: thanks to mycalloc(), p->next is already set to NULL */
}

void InsertEquate(ira_t *ira, char *name, uint32_t adr, int size)
{
   int8_t *data;
   int32_t value;
   int i;
   Equate_t *p, *e;

   /* note: mycalloc doesn't return if allocation failed, so no need to check returned value */
   p = mycalloc(sizeof(Equate_t));

   /* note: ira->buffer is uint16_t pointer but is loaded by fread(ira->buffer, 1,...).
    * Because it keeps big endianness, it is possible to cast ira->buffer to (int8_t *) and simply read
    * data as big endian without taking care about anything (nor endianness neither memory alignment). */
   data = (int8_t *) ira->buffer + adr - ira->params.prgStart;
   switch (size)
   {
      case 0:  /* .Q */
         /* Specific case for ADDQ, SUBQ, ASL, ASR, LSL, LSR, ROL, ROR, ROXL and ROXR
          * where value is stored in bits 11,10 and 9 of instruction word */
         value = (int16_t) be16(data);
         value = (value & ROTATE_SHIFT_COUNT_MASK) >> 9;
         /* When "count" is equal to 000, it means 1000
          * (because adding 0 or shifting by 0 is meaningless) */
         if (value == 0)
            value = 8;
         break;
      case 1:  /* .B */
         value = *data;
         break;
      case 2:  /* .W */
         value = (int16_t) be16(data);
         break;
      case 4:  /* .L */
         value = be32(data);
         break;
      default:
         ExitPrg("ERROR: InsertEquate() unknown size %d (must be 0, 1, 2 or 4).", size);
         break;
   }

   /* Let's check if other similar equates have the same value (otherwise, it can't work at all) */
   for (e = ira->equates; e; e = e->next)
      if (!strcmp(name, e->equateName))
         if (value != e->equateValue)
            ExitPrg("ERROR: for EQU \"%s\", addresses $%x.%c (%d) and $%x.%c (%d) does not have the same value.", name, e->equateAdr, e->size==4?'L':e->size==2?'W':size==1?'B':'Q', e->equateValue, adr, size==4?'L':size==2?'W':size==1?'B':'Q', value);

   /* If last equate exists, the new one will be its next */
   if (ira->lastEquate)
      ira->lastEquate->next = p;
   /* Else here we have our first equate */
   else
      ira->equates = p;

   /* Whatever happened, the new one is the new last one */
   ira->lastEquate = p;

   p->equateAdr = adr;
   p->equateValue = value;
   p->size = size;
   p->equateName = mystrdup(name);
   /* note: thanks to mycalloc(), p->next is already set to NULL */
}

void InsertExtsym(ira_t *ira, char *name, uint32_t val)
{
   Extsym_t *p;

   p = mycalloc(sizeof(Extsym_t));

   if (ira->lastExtsym)
      ira->lastExtsym->next = p;
   else
      ira->extsyms = p;
   ira->lastExtsym = p;

   p->extValue = val;
   p->extName = mystrdup(name);
}

void InsertCNFArea(ira_t *ira, uint32_t adr1, uint32_t adr2)
{
   uint32_t i;

   if (ira->codeArea.cnfCodeAreas == 0)
   {
      ira->codeArea.cnfCodeArea1[0] = adr1;
      ira->codeArea.cnfCodeArea2[0] = adr2;
      ira->codeArea.cnfCodeAreas++;
   }
   else
   {
      i = 0;
      while (adr1 > ira->codeArea.cnfCodeArea2[i] && i < ira->codeArea.cnfCodeAreas)
         i++;
      if (adr1 == ira->codeArea.cnfCodeArea2[i])
      {
         ira->codeArea.cnfCodeArea2[i] = adr2;
         while (((i + 1) < ira->codeArea.cnfCodeAreas) && (ira->codeArea.cnfCodeArea2[i] >= ira->codeArea.cnfCodeArea1[i + 1]))
         {
            ira->codeArea.cnfCodeArea2[i] = ira->codeArea.cnfCodeArea2[i + 1];
            lmovmem(&ira->codeArea.cnfCodeArea1[i + 2], &ira->codeArea.cnfCodeArea1[i + 1], ira->codeArea.cnfCodeAreas - i - 1);
            lmovmem(&ira->codeArea.cnfCodeArea2[i + 2], &ira->codeArea.cnfCodeArea2[i + 1], ira->codeArea.cnfCodeAreas - i - 1);
            ira->codeArea.cnfCodeAreas--;
            i++;
         }
      }
      else
         if ((i != ira->codeArea.cnfCodeAreas) && (adr2 >= ira->codeArea.cnfCodeArea1[i]))
            ira->codeArea.cnfCodeArea1[i] = adr1;
         else
         {
            lmovmem(&ira->codeArea.cnfCodeArea1[i], &ira->codeArea.cnfCodeArea1[i + 1], ira->codeArea.cnfCodeAreas - i);
            lmovmem(&ira->codeArea.cnfCodeArea2[i], &ira->codeArea.cnfCodeArea2[i + 1], ira->codeArea.cnfCodeAreas - i);
            ira->codeArea.cnfCodeArea1[i] = adr1;
            ira->codeArea.cnfCodeArea2[i] = adr2;
            ira->codeArea.cnfCodeAreas++;
            if (ira->codeArea.cnfCodeAreas == ira->codeArea.cnfCodeAreaMax)
            {
               ira->codeArea.cnfCodeArea1 = GetNewVarBuffer(ira->codeArea.cnfCodeArea1, ira->codeArea.cnfCodeAreaMax);
               ira->codeArea.cnfCodeArea2 = GetNewVarBuffer(ira->codeArea.cnfCodeArea2, ira->codeArea.cnfCodeAreaMax);
               ira->codeArea.cnfCodeAreaMax *= 2;
            }
         }
   }
}

void InsertNoPointersArea(ira_t *ira, uint32_t adr1, uint32_t adr2)
{
   uint32_t i;

   if (ira->noPtr.noPtrCount >= ira->noPtr.noPtrMax)
   {
      ira->noPtr.noPtrStart = GetNewVarBuffer(ira->noPtr.noPtrStart, ira->noPtr.noPtrMax);
      ira->noPtr.noPtrEnd = GetNewVarBuffer(ira->noPtr.noPtrEnd, ira->noPtr.noPtrMax);
      ira->noPtr.noPtrMax *= 2;
   }
   for (i = 0; i < ira->noPtr.noPtrCount; i++)
   {
      if (adr1 < ira->noPtr.noPtrStart[i])
         break;
   }
   if (i < ira->noPtr.noPtrCount)
   {
      lmovmem(&ira->noPtr.noPtrStart[i], &ira->noPtr.noPtrStart[i + 1], ira->noPtr.noPtrCount - i);
      lmovmem(&ira->noPtr.noPtrEnd[i], &ira->noPtr.noPtrEnd[i + 1], ira->noPtr.noPtrCount - i);
   }
   ira->noPtr.noPtrStart[i] = adr1;
   ira->noPtr.noPtrEnd[i] = adr2;
   ira->noPtr.noPtrCount++;
}

void InsertNoBaseArea(ira_t *ira, uint32_t adr1, uint32_t adr2)
{
   uint32_t i;

   if (ira->noBase.noBaseCount >= ira->noBase.noBaseMax)
   {
      ira->noBase.noBaseStart = GetNewVarBuffer(ira->noBase.noBaseStart, ira->noBase.noBaseMax);
      ira->noBase.noBaseEnd = GetNewVarBuffer(ira->noBase.noBaseEnd, ira->noBase.noBaseMax);
      ira->noBase.noBaseMax *= 2;
   }
   for (i = 0; i < ira->noBase.noBaseCount; i++)
   {
      if (adr1 < ira->noBase.noBaseStart[i])
         break;
   }
   if (i < ira->noBase.noBaseCount)
   {
      lmovmem(&ira->noBase.noBaseStart[i], &ira->noBase.noBaseStart[i + 1], ira->noBase.noBaseCount - i);
      lmovmem(&ira->noBase.noBaseEnd[i], &ira->noBase.noBaseEnd[i + 1], ira->noBase.noBaseCount - i);
   }
   ira->noBase.noBaseStart[i] = adr1;
   ira->noBase.noBaseEnd[i] = adr2;
   ira->noBase.noBaseCount++;
}

void InsertTextArea(ira_t *ira, uint32_t adr1, uint32_t adr2)
{
   uint32_t i;

   if (ira->text.textCount >= ira->text.textMax)
   {
      ira->text.textStart = GetNewVarBuffer(ira->text.textStart, ira->text.textMax);
      ira->text.textEnd = GetNewVarBuffer(ira->text.textEnd, ira->text.textMax);
      ira->text.textMax *= 2;
   }
   for (i = 0; i < ira->text.textCount; i++)
   {
      if (adr1 < ira->text.textStart[i])
         break;
   }
   if (i < ira->text.textCount)
   {
      lmovmem(&ira->text.textStart[i], &ira->text.textStart[i + 1], ira->text.textCount - i);
      lmovmem(&ira->text.textEnd[i], &ira->text.textEnd[i + 1], ira->text.textCount - i);
   }
   ira->text.textStart[i] = adr1;
   ira->text.textEnd[i] = adr2;
   ira->text.textCount++;
}

void InsertJmpTabArea(ira_t *ira, int size, uint32_t adr1, uint32_t adr2, uint32_t base)
{
   uint32_t i;

   if (ira->jmp.jmpCount >= ira->jmp.jmpMax)
   {
      ira->jmp.jmpTable = GetNewStructBuffer(ira->jmp.jmpTable, sizeof(JMPTab_t), ira->jmp.jmpMax);
      ira->jmp.jmpMax *= 2;
   }
   for (i = 0; i < ira->jmp.jmpCount; i++)
   {
      if (adr1 < ira->jmp.jmpTable[i].start)
         break;
   }
   if (i < ira->jmp.jmpCount)
      memmove(&ira->jmp.jmpTable[i + 1], &ira->jmp.jmpTable[i], sizeof(JMPTab_t) * (ira->jmp.jmpCount - i));
   ira->jmp.jmpTable[i].size = size;
   ira->jmp.jmpTable[i].start = adr1;
   ira->jmp.jmpTable[i].end = adr2;
   ira->jmp.jmpTable[i].base = base;
   ira->jmp.jmpCount++;
}

char *GetFullLine(char *cfg, FILE *configfile)
{
   char *p, *q;
   int i;

   /* Note : the comment can be very long and the whole line can be longer than 255 bytes */
   /* Let's call fgets() again and again until a real end of line is reached */
   for (p = cfg, i = 2; strlen(cfg) == 255 && cfg[254] != '\n'; i++)
   {
      if (p == cfg)
      {
         p = myalloc(i*256);
         strcpy(p, cfg);
      }
      else
         p = myrealloc(p, i*256);

      /* Note: fgets() can return NULL !
       * If the last line of config file has a length of 255 bytes and do not ends by a newline,
       * cfg will remain the same while nothing has been read -> infinite loop until out of memory */
      if (fgets(cfg, 256, configfile))
         strcat(p, cfg);
      else
         cfg[0] = '\0';
   }

   /* Remove trailing newline, if exists */
   if ((q = strchr(p, '\n')))
      *q = '\0';

   return p;
}

uint32_t GetAddress(char *adr, uint16_t line_number)
{
   uint32_t value;

   /* If configuration line ends without expected address */
   if (!adr[0])
      ExitPrg("CONFIG ERROR: no address specified ! (at line %d)", line_number);

   if (adr[0] == '$')
      if (isxdigit(adr[1]))
         value = stch_l(&adr[1]);
      else
         ExitPrg("CONFIG ERROR: \"%s\" is not a valid hexadecimal address ! (at line %d)", adr, line_number);
   else
      if (isdigit(adr[0]))
         value = atoi(adr);
      else
         ExitPrg("CONFIG ERROR: \"%s\" is not a valid decimal address ! (at line %d)", adr, line_number);

   return value;
}
