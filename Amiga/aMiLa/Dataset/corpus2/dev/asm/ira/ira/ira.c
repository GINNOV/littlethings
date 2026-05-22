/*
 * ira.c
 *
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : ira.c
 *      Purpose  : Contains most routines and main program
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2025 Frank Wille, (C)2014-2019 Nicolas Bastien
 */

#include <ctype.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ira.h"

#include "amiga_hunks.h"
#include "atari.h"
#include "config.h"
#include "constants.h"
#include "elf.h"
#include "init.h"
#include "ira_2.h"
#include "opcode.h"
#include "supp.h"

#ifdef AMIGAOS
const char *VERsion="$VER: IRA "VERSION"."REVISION" "__AMIGADATE__;
#endif

ira_t *ira;

int main(int argc, char **argv)
{
   ira = Start();

   Init(ira, argc, argv);
   GroupOpCodeByNibble(ira);
   SearchRomTag(ira);
   if (ira->params.pFlags & PREPROC)
   {
      DPass0(ira);
      CreateConfig(ira);
   }
   else
      if (ira->params.pFlags & CONFIG)
         CNFAreaToCodeArea(ira);
      else
         SectionToArea(ira);

   PrintAreas(&ira->codeArea);
   DPass1(ira);
   DPass2(ira);

   ExitPrg(NULL);
}

void FormatError(void)
{
   fprintf(stderr, "Usage  : IRA [Options] <Source> [Target]\n"
         "\n"
         "Source : Specifies the path of the source.\n"
         "Target : Specifies the path of the target.\n"
         "Options:\n"
         "        -M68xxx           xxx = 000,010,020,030,040,060,851,881,882:\n"
         "                          Specifies processor/coprocessor.\n"
         "        -BINARY           Treat source file as binary.\n"
         "        -A                Append address and data to every line.\n"
         "        -AW               Same as -A, but enforce 8-digit addresses.\n"
         "        -INFO             Print informations about the hunk's structure.\n"
         "        -OFFSET=<offs>    Specifies offset to relocate at.\n"
         "        -TEXT=<x>         x = 1: Method for searching text.\n"
         "        -KEEPZH           Hunks with zero length are recognized.\n"
         "        -KEEPBIN          Keep the file with the binary data.\n"
         "        -OLDSTYLE         Addressing modes are M68000 like.\n"
         "        -NEWSTYLE         Addressing modes are M68020 like.\n"
         "        -FIXLABELS        Prepend 'L' to potential illegal labels.\n"
         "        -LABEL=<style>    0=LAB_index/EXT_index, 1=LAB_addr/EXT_addr.\n"
         "        -RADIX=<n>        10 is default, 0 is hex for pos. dec for neg.\n"
         "        -ESCCODES         Use escape character '\\' in strings.\n"
         "        -COMPAT=<flags>   Various compatibility flags.\n"
         "        -SPLITFILE        Put each section in its own file.\n"
         "        -CONFIG           Loads config file.\n"
         "        -PREPROC          Finds data in code sections. Useful.\n"
         "        -ENTRY=<offs>     Where to begin scanning of code.\n"
         "        -BASEREG[=<x>[,<adr>[,<off>]]]\n"
         "                          Baserelative mode d16(Ax).\n"
         "                          x = 0-7 : Number of the address register.\n"
         "                          adr     : Base address.\n"
         "                          off     : Offset on base address.\n"
         "        -BASEABS          Baserel addr.mode as an absolute label.\n"
         "\n");
}

void ExitPrg(const char * errtext, ...)
{
   int exit_status;
   va_list arguments;

   if (errtext)
   {
      va_start(arguments, errtext);
      vfprintf(stderr, errtext, arguments);
      fprintf(stderr, "\n");
      va_end(arguments);
      exit_status = EXIT_FAILURE;
   }
   else
   {
      printf("\n");
      exit_status = EXIT_SUCCESS;
   }

   if (ira->files.sourceFile)
      fclose(ira->files.sourceFile);
   if (ira->files.binaryFile)
      fclose(ira->files.binaryFile);
   if (ira->files.targetFile)
      fclose(ira->files.targetFile);
   if (ira->files.labelFile)
      fclose(ira->files.labelFile);

   if (ira->filenames.labelName)
      delfile(ira->filenames.labelName);
   if (!(ira->params.pFlags & KEEP_BINARY) && ira->filenames.binaryName)
      delfile(ira->filenames.binaryName);

   exit(exit_status);
}

void PrintAreas(CodeArea_t *codeArea)
{
   unsigned long i;

   printf("codeAdrs: %lu   codeAdrMax: %lu\n", (unsigned long) codeArea->codeAdrs, (unsigned long) codeArea->codeAdrMax);

   for (i = 0; i < codeArea->codeAreas; i++)
      printf("CodeArea[%lu]: %08lx - %08lx\n", i, (unsigned long) codeArea->codeArea1[i], (unsigned long) codeArea->codeArea2[i]);

   printf("\n\n");
}

void WriteBaseDirective(FILE *f)
{
   ira->adrbuf[0] = 0;
   GetLabel(ira->baseReg.baseAddress, MODE_INVALID);
   fprintf(f, "\tBASEREG\t%s", ira->adrbuf);
   ira->adrbuf[0] = 0;
   if (ira->baseReg.baseOffset > 0)
      fprintf(f, "+%hd,A%hu\n", ira->baseReg.baseOffset, ira->params.baseReg);
   else
      if (ira->baseReg.baseOffset < 0)
         fprintf(f, "-%hd,A%hu\n", -ira->baseReg.baseOffset, ira->params.baseReg);
      else
         fprintf(f, ",A%hu\n", ira->params.baseReg);
}

void SplitCodeAreas(ira_t *ira)
{
   uint32_t i, j, ptr1;

   /* splitting code areas where sections begin or end */
   for (i = 0; i < ira->hunkCount; i++)
   {
      if (ira->hunksSize[i] == 0)
         continue;
      ptr1 = ira->hunksOffs[i] + ira->hunksSize[i];
      if (ptr1 <= ira->codeArea.codeArea2[ira->codeArea.codeAreas - 1])
      {
         for (j = 0; j < ira->codeArea.codeAreas; j++)
         {
            if (ptr1 < ira->codeArea.codeArea2[j])
            {
               if (ptr1 == ira->codeArea.codeArea1[j])
                  break;
               lmovmem(&ira->codeArea.codeArea1[j], &ira->codeArea.codeArea1[j + 1], ira->codeArea.codeAreas - j);
               lmovmem(&ira->codeArea.codeArea2[j], &ira->codeArea.codeArea2[j + 1], ira->codeArea.codeAreas - j);
               if (ptr1 < ira->codeArea.codeArea1[j])
                  ira->codeArea.codeArea1[j] = ira->codeArea.codeArea2[j] = ptr1;
               else
                  if (ptr1 > ira->codeArea.codeArea1[j])
                     ira->codeArea.codeArea2[j] = ira->codeArea.codeArea1[j + 1] = ptr1;
               ira->codeArea.codeAreas++;
               if (ira->codeArea.codeAreas == ira->codeArea.codeAreaMax)
               {
                  ira->codeArea.codeArea1 = GetNewVarBuffer(ira->codeArea.codeArea1, ira->codeArea.codeAreaMax);
                  ira->codeArea.codeArea2 = GetNewVarBuffer(ira->codeArea.codeArea2, ira->codeArea.codeAreaMax);
                  ira->codeArea.codeAreaMax *= 2;
               }
               break;
            }
         }
      }
      else
      {
         ira->codeArea.codeArea2[ira->codeArea.codeAreas] = ira->codeArea.codeArea1[ira->codeArea.codeAreas] = ptr1;
         ira->codeArea.codeAreas++;
         if (ira->codeArea.codeAreas == ira->codeArea.codeAreaMax)
         {
            ira->codeArea.codeArea1 = GetNewVarBuffer(ira->codeArea.codeArea1, ira->codeArea.codeAreaMax);
            ira->codeArea.codeArea2 = GetNewVarBuffer(ira->codeArea.codeArea2, ira->codeArea.codeAreaMax);
            ira->codeArea.codeAreaMax *= 2;
         }
      }
   }

   if (ira->codeArea.codeArea1[0] != ira->params.prgStart)
      InsertCodeArea(&ira->codeArea, ira->params.prgStart, ira->params.prgStart);
}

static int NoPtrsArea(uint32_t adr)
{
   uint32_t i;

   for (i = 0; i < ira->noPtr.noPtrCount; i++)
   {
      if (adr >= ira->noPtr.noPtrStart[i] && adr < ira->noPtr.noPtrEnd[i])
         return 1;
   }
   return 0;
}

static void CheckNoBase(uint32_t adr)
{
   if ((ira->params.pFlags & BASEREG2) && ira->noBase.noBaseIndex < ira->noBase.noBaseCount)
   {
      if (!ira->noBase.noBaseFlag)
      {
         if (adr >= ira->noBase.noBaseStart[ira->noBase.noBaseIndex])
         {
            ira->noBase.noBaseFlag = 1;
            if (ira->pass == 2)
               fprintf(ira->files.targetFile, "\tENDB\tA%hu\n", ira->params.baseReg);
         }
      }
      else
      {
         if (adr >= ira->noBase.noBaseEnd[ira->noBase.noBaseIndex])
         {
            ira->noBase.noBaseFlag = 0;
            if (ira->pass == 2)
               WriteBaseDirective(ira->files.targetFile);
            ira->noBase.noBaseIndex++;
         }
      }
   }
}

void InsertSymbol(char *name, uint32_t value)
{
   size_t len = strlen(name);
   unsigned i;
   char *p;

   for (i = 0; i < ira->symbols.symbolCount; i++)
      if (ira->symbols.symbolValue[i] == value)
         return;

   /* adapt for illegal local label names */
   i = 0;
   if ((ira->params.pFlags & FIXLABELS)) {
      if (isdigit((unsigned char)*name)) {
         len++;
         i = 1;
      }
      else if (*name == '.') {
         name++;
         i = 1;
      }
   }

   ira->symbols.symbolValue[ira->symbols.symbolCount] = value;
   ira->symbols.symbolName[ira->symbols.symbolCount++] = p = mycalloc(len + 1);
   if (i)
      *p++ = 'L';  /* prepend 'L' for potential illegal local label names */
   strcpy(p, name);

   if (ira->symbols.symbolCount == ira->symbols.symbolMax)
   {
      ira->symbols.symbolName = GetNewPtrBuffer(ira->symbols.symbolName, ira->symbols.symbolMax);
      ira->symbols.symbolValue = GetNewVarBuffer(ira->symbols.symbolValue, ira->symbols.symbolMax);
      ira->symbols.symbolMax *= 2;
   }
}

static uint32_t GetCodeAdr(uint32_t *ptr)
{
   if (ira->codeArea.codeAdrs)
   {
      *ptr = ira->codeArea.codeAdr[0];
      lmovmem(&ira->codeArea.codeAdr[1], &ira->codeArea.codeAdr[0], ira->codeArea.codeAdrs - 1);
      ira->codeArea.codeAdrs--;
      return (1);
   }
   return (0);
}

void InsertCodeAdr(ira_t *ira, uint32_t adr)
{
   uint32_t l = 0, m, r = ira->codeArea.codeAdrs, i;

   if (!(ira->params.pFlags & PREPROC))
      return;

   /* check if label points into an earlier processed code area */
   for (i = 0; i < ira->codeArea.codeAreas; i++)
   {
      if ((adr >= ira->codeArea.codeArea1[i]) && (adr < ira->codeArea.codeArea2[i]))
      {
         return;
      }
   }

   /* this case occurs pretty often */
   if (ira->codeArea.codeAdrs && (adr > ira->codeArea.codeAdr[ira->codeArea.codeAdrs - 1]))
   {
      ira->codeArea.codeAdr[ira->codeArea.codeAdrs++] = adr;
   }
   else
   {
      /* adr binary search */
      while (l < r)
      {
         m = (l + r) / 2;
         if (ira->codeArea.codeAdr[m] < adr)
            l = m + 1;
         else
            r = m;
      }
      if ((ira->codeArea.codeAdr[r] != adr) || (r == ira->codeArea.codeAdrs))
      {
         lmovmem(&ira->codeArea.codeAdr[r], &ira->codeArea.codeAdr[r + 1], ira->codeArea.codeAdrs - r);
         ira->codeArea.codeAdr[r] = adr;
         ira->codeArea.codeAdrs++;
      }
   }
   if (ira->codeArea.codeAdrs == ira->codeArea.codeAdrMax)
   {
      ira->codeArea.codeAdr = GetNewVarBuffer(ira->codeArea.codeAdr, ira->codeArea.codeAdrMax);
      ira->codeArea.codeAdrMax *= 2;
   }
}

void InsertCodeArea(CodeArea_t *codeArea, uint32_t adr1, uint32_t adr2)
{
   uint32_t i, j;

   if (codeArea->codeAreas == 0)
   {
      codeArea->codeArea1[0] = adr1;
      codeArea->codeArea2[0] = adr2;
      codeArea->codeAreas++;
   }
   else
   {
      i = 0;
      while (adr1 > codeArea->codeArea2[i] && i < codeArea->codeAreas)
         i++;
      if (adr1 == codeArea->codeArea2[i])
      {
         codeArea->codeArea2[i] = adr2;
         while (((i + 1) < codeArea->codeAreas) && (codeArea->codeArea2[i] >= codeArea->codeArea1[i + 1]))
         {
            codeArea->codeArea2[i] = codeArea->codeArea2[i + 1];
            lmovmem(&codeArea->codeArea1[i + 2], &codeArea->codeArea1[i + 1], codeArea->codeAreas - i - 1);
            lmovmem(&codeArea->codeArea2[i + 2], &codeArea->codeArea2[i + 1], codeArea->codeAreas - i - 1);
            codeArea->codeAreas--;
            i++;
         }
      }
      else
         if ((i != codeArea->codeAreas) && (adr2 >= codeArea->codeArea1[i]))
            codeArea->codeArea1[i] = adr1;
         else
         {
            lmovmem(&codeArea->codeArea1[i], &codeArea->codeArea1[i + 1], codeArea->codeAreas - i);
            lmovmem(&codeArea->codeArea2[i], &codeArea->codeArea2[i + 1], codeArea->codeAreas - i);
            codeArea->codeArea1[i] = adr1;
            codeArea->codeArea2[i] = adr2;
            codeArea->codeAreas++;
            if (codeArea->codeAreas == codeArea->codeAreaMax)
            {
               codeArea->codeArea1 = GetNewVarBuffer(codeArea->codeArea1, codeArea->codeAreaMax);
               codeArea->codeArea2 = GetNewVarBuffer(codeArea->codeArea2, codeArea->codeAreaMax);
               codeArea->codeAreaMax *= 2;
            }
         }
   }

   fprintf(stderr, "Areas: %4lu  \r", (unsigned long) codeArea->codeAreas);
   fflush(stderr);

   /* remove all labels that point within a earlier processed code area */
   for (j = 0; j < codeArea->codeAreas; j++)
   {
      for (i = 0; i < codeArea->codeAdrs;)
      {
         if ((codeArea->codeAdr[i] >= codeArea->codeArea1[j]) && (codeArea->codeAdr[i] < codeArea->codeArea2[j]))
         {
            lmovmem(&codeArea->codeAdr[i + 1], &codeArea->codeAdr[i], codeArea->codeAdrs - i - 1);
            codeArea->codeAdrs--;
         }
         else
            i++;
      }
   }
}

void SectionToArea(ira_t *ira)
{
   uint32_t i;

   if (!(ira->params.pFlags & PREPROC))
   {
      for (i = 0; i < ira->hunkCount; i++)
      {
         if (ira->hunksType[i] == HUNK_CODE)
         {
            if (i == 0)
            {
               InsertCodeArea(&ira->codeArea, ira->params.codeEntry, ira->hunksOffs[i] + ira->hunksSize[i]);
            }
            else
            {
               InsertCodeArea(&ira->codeArea, ira->hunksOffs[i], ira->hunksOffs[i] + ira->hunksSize[i]);
            }
         }
      }
   }

   /* need at least one code area for the following algorythm */
   if (ira->codeArea.codeAreas == 0)
      ira->codeArea.codeAreas = 1;
   SplitCodeAreas(ira);
}

void DPass0(ira_t *ira)
{
   uint16_t dummy;
   uint16_t EndFlag;
   uint32_t ptr1, ptr2, i;

   ira->pass = 0;
   ptr2 = (ira->params.prgEnd - ira->params.prgStart) / 2;
   if (!(ira->params.pFlags & ROMTAGatZERO) && !(ira->params.pFlags & CONFIG))
      InsertCodeAdr(ira, ira->params.codeEntry);
   fprintf(stderr, "Pass 0: scanning for data in code\n");

   while (GetCodeAdr(&ptr1))
   {

      ira->prgCount = (ptr1 - ira->params.prgStart) / 2;

      /* Find out in which section we are */
      for (ira->modulcnt = 0; ira->modulcnt < ira->hunkCount; ira->modulcnt++)
         if ((ptr1 >= ira->hunksOffs[ira->modulcnt]) && (ptr1 < (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt])))
         {
            ira->codeArea.codeAreaEnd = (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - ira->params.prgStart) / 2;
            break;
         }

      /* Find the first relocation in this code area */
      for (ira->nextreloc = 0; ira->nextreloc < ira->relocount; ira->nextreloc++)
         if (ira->reloc.relocAdr[ira->nextreloc] >= ptr1)
            break;

      EndFlag = 0;
      while (EndFlag == 0)
      {
         if (ira->prgCount == ptr2)
         {
            InsertCodeArea(&ira->codeArea, ptr1, ira->prgCount * 2 + ira->params.prgStart);
            break;
         }
         else
            if (ira->prgCount > ptr2)
            {
               fprintf(stderr, "Watch out: prgcount*2(=%08lx) > (prgend-prgstart)(=%08lx)\n", (unsigned long) (ira->prgCount * 2), (unsigned long) (ira->params.prgEnd - ira->params.prgStart));
               break;
            }

         if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
         {
            ira->nextreloc++;
            ira->prgCount += 2;
            continue;
         }
         ira->pc = ira->prgCount;
         ira->seaow = be16(&ira->buffer[ira->prgCount++]);

         GetOpCode(ira, ira->seaow);
         if (instructions[ira->opCodeNumber].flags & OPF_ONE_MORE_WORD)
         {
            ira->extra = be16(&ira->buffer[ira->prgCount]);
            ira->ext_register = (ira->extra & REGISTER_EXTENSION_MASK) >> 12;
            if (P1WriteReloc(ira))
               continue;
         }

         DoSpecific(ira, 0);

         if ((instructions[ira->opCodeNumber].flags & OPF_APPEND_SIZE) && ira->extension == 3)
            ira->addressMode = MODE_INVALID;

         if (instructions[ira->opCodeNumber].sourceadr)
            if (DoAdress1(ira, instructions[ira->opCodeNumber].sourceadr))
               continue;

         if (instructions[ira->opCodeNumber].destadr)
         {
            if (instructions[ira->opCodeNumber].family == OPC_MOVE)
            {
               ira->addressMode = ((ira->seaow & ALT_MODE_MASK) >> 3) | ira->alt_register;
               if (ira->addressMode < EA_MODE_FIELD_MASK)
                  ira->addressMode = (ira->addressMode >> 3);
               else
                  ira->addressMode = 7 + ira->alt_register;
               ira->ea_register = ira->alt_register;
            }

            if (DoAdress1(ira, instructions[ira->opCodeNumber].destadr))
               continue;
            else
               if (instructions[ira->opCodeNumber].family == OPC_LEA || instructions[ira->opCodeNumber].family == OPC_MOVEAL)
                  if (ira->params.pFlags & BASEREG1)
                     if (ira->addressMode2 == 1 && ira->alt_register == ira->params.baseReg)
                        printf("BASEREG\t%08lX: A%hd\n", (unsigned long) (ira->pc * 2 + ira->params.prgStart), ira->params.baseReg);
         }

         /* Check for data in code */
         /**************************/

         if (ira->LabAdrFlag == 1)
         {
            if (instructions[ira->opCodeNumber].family == OPC_Bcc || instructions[ira->opCodeNumber].family == OPC_JSR || instructions[ira->opCodeNumber].family == OPC_DBcc || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_CALLM || instructions[ira->opCodeNumber].family == OPC_PBcc || instructions[ira->opCodeNumber].family == OPC_PDBcc)
               if ((ira->LabAdr < ptr1) || (ira->LabAdr > (ira->prgCount * 2 + ira->params.prgStart)))
                  InsertCodeAdr(ira, ira->LabAdr);
            ira->LabAdrFlag = 0;
         }

         /* note: first condition means "== BRA" */
         if (((instructions[ira->opCodeNumber].family == OPC_Bcc && (ira->seaow & 0xFF00) == 0x6000)) || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_RTS || instructions[ira->opCodeNumber].family == OPC_RTE || instructions[ira->opCodeNumber].family == OPC_RTR || instructions[ira->opCodeNumber].family == OPC_RTD || instructions[ira->opCodeNumber].family == OPC_RTM)
         {
            EndFlag = 1;
            for (i = 0; i < ira->codeArea.cnfCodeAreas; i++)
               if ((ira->codeArea.cnfCodeArea1[i] < (ira->prgCount * 2 + ira->params.prgStart)) && (ira->codeArea.cnfCodeArea2[i] > (ira->prgCount * 2 + ira->params.prgStart)))
               {
                  EndFlag = 0;
                  break;
               }
            if (EndFlag == 1)
               InsertCodeArea(&ira->codeArea, ptr1, ira->prgCount * 2 + ira->params.prgStart);
         }
      }

      /* Speeding up (takes out redundancies in code checking) */
      for (i = 0; i < ira->codeArea.cnfCodeAreas; i++)
         if (ira->codeArea.cnfCodeArea2[i] == (ira->prgCount * 2 + ira->params.prgStart))
            if (ira->codeArea.cnfCodeArea1[i] <= ptr1)
            {
               ira->codeArea.cnfCodeArea2[i] = ptr1;
               break;
            }
   }

   fprintf(stderr, "\n");

   /* Preparing sections to be area aligned */
   SectionToArea(ira);
}

/* Generate code for a complete jump-table with 'count' entries */
static void GenJmptab(uint8_t *buf, int size, uint32_t pc, int32_t base, int count)
{
   int32_t adr;

   for (; count > 0; count--, buf += size, pc += size)
   {
      WriteLabel2(pc);
      dtacat(itohex(pc, ira->adrlen));
      dtacat(": ");
      switch (size)
      {
         case 1:
            adr = base + *(int8_t *) buf;
            dtacat(itohex(*buf, 2));
            mnecat("DC.B");
            break;
         case 2:
            adr = base + (int16_t) be16(buf);
            dtacat(itohex(be16(buf), 4));
            mnecat("DC.W");
            break;
         case 4:
            adr = base + (int32_t) be32(buf);
            dtacat(itohex(be16(buf), 4));
            dtacat(itohex(be16(buf + 2), 4));
            mnecat("DC.L");
            break;
         default:
            ExitPrg("Illegal jmp table size %d.", size);
            break;
      }
      adrcat("(");
      GetLabel(adr, MODE_INVALID);
      adrcat(")-(");
      GetLabel(base, MODE_INVALID);
      adrcat(")");
      Output();
   }
}

void DPass2(ira_t *ira)
{
   uint16_t tflag, text, dummy;
   uint16_t longs_per_line, byte_count;
   int32_t dummy1;
   uint32_t dummy2;
   uint32_t i, j, k, l, m, r, rel, zero, alpha;
   uint8_t *buf, *tptr;
   uint32_t ptr1, ptr2, end, area;
   char *equate_name;

   ira->pass = 2;
   ira->LabelAdr2 = mycalloc(ira->label.labelMax * 4 + 4);

   if (ira->labcount)
   { /* Wenn ueberhaupt Labels vorhanden sind */
      fprintf(stderr, "Pass 2: correcting labels\n");
      if (!(ira->files.labelFile = fopen(ira->filenames.labelName, "rb")))
         ExitPrg("Can't open label file \"%s\" for reading.", ira->filenames.labelName);

      ira->labelbuf = mycalloc(ira->labc1 * sizeof(uint32_t));
      fread(ira->labelbuf, sizeof(uint32_t), ira->labc1, ira->files.labelFile);
      fclose(ira->files.labelFile);
      ira->files.labelFile = 0;
      delfile(ira->filenames.labelName);
      for (i = 0; i < ira->labcount; i++)
      {
         dummy1 = ira->LabelAdr2[i] = ira->label.labelAdr[i];
         if (dummy1 < (int32_t) ira->params.prgStart)
            ira->LabelAdr2[i] = ira->params.prgStart;
         /* Binaeres Suchen von dummy1 */
         l = 0;
         r = ira->labc1;
         while (l < r)
         {
            m = (l + r) / 2;
            if ((int32_t) ira->labelbuf[m] < dummy1)
               l = m + 1;
            else
               r = m;
         }
         if (ira->labelbuf[r] != dummy1 || r == ira->labc1)
         {
            if (r > 0)
               ira->LabelAdr2[i] = ira->labelbuf[r - 1];
            else
               ira->LabelAdr2[i] = ira->params.prgStart;
         }
      }
   } /* Ende der Labelbearbeitung */

   if (ira->params.textMethod)
   {
      fprintf(stderr, "Pass 2: searching for text\n");

      for (ira->modulcnt = 0; ira->modulcnt < ira->hunkCount; ira->modulcnt++)
      {
         /* BSS hunk --> there is no text */
         if (ira->hunksType[ira->modulcnt] == HUNK_BSS)
            continue;
         if (!ira->hunksSize[ira->modulcnt])
            continue;
         buf = ((uint8_t *) ira->buffer) + ira->hunksOffs[ira->modulcnt];

         for (rel = 0, i = 0; i < ira->hunksSize[ira->modulcnt] - 1; i++)
         {
            k = i;
            text = 1;
            alpha = 0;
            while (isprint(buf[k]) || isspace(buf[k]))
            {
               if (buf[k] > 127)
               {
                  text = 0;
                  break;
               }
               if (isalpha(buf[k]) && isalpha(buf[k + 1]))
                  alpha++;
               else
                  if (alpha < 4)
                     alpha = 0;
               k++;
            }

            /* there must be more than 4 letters concatenated */
            if (alpha < 4)
            {
               i = k;
               continue;
            }

            /* text should be null terminated */
            if (buf[k] != 0)
            {
               i = k;
               continue;
            }

            /* a text must have a minimum length */
            if ((k - i) <= 5)
            {
               i = k;
               continue;
            }

            /* relocations don't have to be in a text */
            while (ira->reloc.relocAdr[rel] <= (i + ira->hunksOffs[ira->modulcnt] - 4) && rel < ira->relocount)
               rel++;
            if (rel < ira->relocount)
            {
               if (ira->reloc.relocAdr[rel] <= (k + ira->hunksOffs[ira->modulcnt]))
               {
                  i = k;
                  continue;
               }
            }

            if (text)
            {

               /* RTS --> seems to be code */
               if (be16(&buf[k - 2]) == RTS_CODE)
               {
                  printf("TEXT\t%08lx:\n", (unsigned long) (ira->hunksOffs[ira->modulcnt] + i));
                  printf("\tDC.B\t");
                  for (tflag = 0, j = i; j <= k; j++)
                  {
                     if (isprint(buf[j]) && buf[j] != '\"')
                     {
                        if (tflag == 0)
                           printf("\"%c", buf[j]);
                        if (tflag == 1)
                           printf("%c", buf[j]);
                        if (tflag == 2)
                           printf(",\"%c", buf[j]);
                        tflag = 1;
                     }
                     else
                     {
                        if (tflag == 0)
                           printf("%d", (int) buf[j]);
                        if (tflag == 1)
                           printf("\",%d", (int) buf[j]);
                        if (tflag == 2)
                           printf(",%d", (int) buf[j]);
                        tflag = 2;
                     }
                  }
                  if (tflag == 1)
                     printf("\"\n");
                  if (tflag == 2)
                     printf("\n");
               }
            }
            i = k;
         }
      }
   }

   fprintf(stderr, "Pass 2: writing mnemonics\n");

   if (!(ira->files.targetFile = fopen(ira->filenames.targetName, "w")))
      ExitPrg("Can't open target file \"%s\" for writing.", ira->filenames.targetName);

   fprintf(ira->files.targetFile, IDSTRING2, VERSION, REVISION);

   /* Write EQU's */
   if (ira->XRefCount)
   {
      for (i = 0; i < ira->XRefCount; i++)
      {
         ira->adrbuf[0] = 0;
         if (!GetExtsymName(ira->XRefList[i])) {
            GetExtName(i);
            if (strlen(ira->adrbuf) < 8)
               adrcat("\t");
            fprintf(ira->files.targetFile, EQUATE_TEMPLATE, ira->adrbuf,
                    (unsigned long)ira->XRefList[i]);
         }
      }
      ira->adrbuf[0] = 0;
      fprintf(ira->files.targetFile, "\n");
   }

   /* Write renamed external addresses */
   WriteExtsyms(ira);

   /* Write custom EQU's (from config file) */
   WriteEquates(ira);

   /* Specify processor */
   dummy2 = 68000;
   if (ira->params.cpuType & M68010)
      dummy2 = 68010;
   if (ira->params.cpuType & M68020)
      dummy2 = 68020;
   if (ira->params.cpuType & M68030)
      dummy2 = 68030;
   if (ira->params.cpuType & M68040)
      dummy2 = 68040;
   if (ira->params.cpuType & M68060)
      dummy2 = 68060;
   if (dummy2 != 68000)
      fprintf(ira->files.targetFile, "\tMC%ld\n", (long) dummy2);
   if ((ira->params.cpuType & FPU_EXTERNAL) && !(ira->params.cpuType & FPU_INTERNAL))
      fprintf(ira->files.targetFile, "\tMC6888%c\n", (ira->params.cpuType & M68881)?'1':'2');
   if (dummy2 == 68020 && (ira->params.cpuType & MMU_EXTERNAL))
      fprintf(ira->files.targetFile, "\tMC68851\n");
   fprintf(ira->files.targetFile, "\n");

   if (ira->params.pFlags & BASEREG2)
      WriteBaseDirective(ira->files.targetFile);

   /* If split, write INCLUDE directives */
   if (ira->params.pFlags & SPLITFILE)
   {
      for (ira->modulcnt = 0; ira->modulcnt < ira->hunkCount; ira->modulcnt++)
      {
         if (!ira->hunksSize[ira->modulcnt])
            if (!(ira->params.pFlags & KEEP_ZEROHUNKS))
               continue;
         fprintf(ira->files.targetFile, "\tINCLUDE\t\"%s.S%s\"\n", ira->filenames.targetName, itoasc(ira->modulcnt));
      }
      fprintf(ira->files.targetFile, "\tEND\n");
      fclose(ira->files.targetFile);
      ira->files.targetFile = 0;
   }

   ira->prgCount = 0;
   ira->nextreloc = 0;
   ira->modulcnt = (uint32_t)-1;
   ira->noBase.noBaseIndex = 0;
   ira->noBase.noBaseFlag = 0;
   ira->text.textIndex = 0;
   ira->jmp.jmpIndex = 0;

   for (area = 0; area < ira->codeArea.codeAreas; area++)
   {

      while ((ira->modulcnt + 1 < ira->hunkCount) && (ira->hunksOffs[ira->modulcnt + 1] == ira->codeArea.codeArea1[area]))
      {
         ira->modulcnt++;
         if (ira->params.pFlags & SPLITFILE)
            SplitOutputFiles(&ira->files, &ira->filenames, ira->modulcnt);
         WriteSection(ira);
      }

      ira->dtabuf[0] = 0;
      ira->adrbuf[0] = 0;
      ira->mnebuf[0] = 0;

      /* HERE BEGINS THE CODE PART OF PASS 2 */
      /***************************************/

      ira->codeArea.codeAreaEnd = (ira->codeArea.codeArea2[area] - ira->params.prgStart) / 2;

      CheckPhase(-1); /* phase sync */

      while (ira->prgCount < ira->codeArea.codeAreaEnd)
      {
         CheckPhase(ira->prgCount * 2 + ira->params.prgStart);

         WriteBanner(ira->params.prgStart + ira->prgCount * 2);
         WriteLabel2(ira->params.prgStart + ira->prgCount * 2);
         WriteComment(ira->params.prgStart + ira->prgCount * 2);

         dtacat(itohex(ira->params.prgStart + ira->prgCount * 2, ira->adrlen));
         dtacat(": ");
         if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
         {
            mnecat("DC.L");
            dtacat(itohex(be16(&ira->buffer[ira->prgCount]), 4));
            dtacat(itohex(be16(&ira->buffer[ira->prgCount + 1]), 4));
            GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
            ira->nextreloc++;
            Output();
            ira->prgCount += 2;
            continue;
         }
         ira->pc = ira->prgCount;
         ira->seaow = be16(&ira->buffer[ira->prgCount++]);
         dtacat(itohex(ira->seaow, 4));

         GetOpCode(ira, ira->seaow);

         mnecat(instructions[ira->opCodeNumber].opcode);
         if (instructions[ira->opCodeNumber].flags & OPF_ONE_MORE_WORD)
         {
            ira->extra = be16(&ira->buffer[ira->prgCount]);
            ira->ext_register = (ira->extra & REGISTER_EXTENSION_MASK) >> 12;
            if (P2WriteReloc())
               continue;
         }

         if (instructions[ira->opCodeNumber].flags & OPF_APPEND_CC)
         {
            dummy = (ira->seaow & cc_MASK) >> 8;
            /* note: For Bcc, CC "T" (0000) and "F" (0001) don't exist. Bcc with 0000 is BRA and Bcc with 0001 is BSR.
             *       cpu_cc[] should contain 16 items (as CC is coded over 4 bits) but actually contains 18.
             *       Why ?
             *       Because, 17th and 18th items are "RA" and "SR".
             *       It is a trick to have BRA and BSR instead of BT and BF by adding 16 to CC got in dummy variable */
            if (instructions[ira->opCodeNumber].family == OPC_Bcc && dummy < 2)
               dummy += 16;
            mnecat(cpu_cc[dummy]);
         }

         if (instructions[ira->opCodeNumber].flags & OPF_APPEND_PCC)
         {
            if (instructions[ira->opCodeNumber].family == OPC_PBcc)
               dummy = ira->seaow;
            else
               dummy = ira->extra;
            mnecat(mmu_cc[dummy & Pcc_MASK]);
         }

         DoSpecific(ira, 2);

         if (instructions[ira->opCodeNumber].flags & OPF_APPEND_SIZE)
            if (ira->extension != 3)
               mnecat(extensions[ira->extension]);
            else
               ira->addressMode = MODE_INVALID;

         if (instructions[ira->opCodeNumber].sourceadr)
         {
            if (DoAdress2(instructions[ira->opCodeNumber].sourceadr))
               continue;

            if (instructions[ira->opCodeNumber].destadr)
               adrcat(",");
         }

         if (instructions[ira->opCodeNumber].destadr)
         {
            if (instructions[ira->opCodeNumber].family == OPC_MOVE)
            {
               ira->addressMode = ((ira->seaow & ALT_MODE_MASK) >> 3) | ira->alt_register;
               if (ira->addressMode < EA_MODE_FIELD_MASK)
                  ira->addressMode = (ira->addressMode >> 3);
               else
                  ira->addressMode = 7 + ira->alt_register;
               ira->ea_register = ira->alt_register;
            }

            if (DoAdress2(instructions[ira->opCodeNumber].destadr))
               continue;

            /* Third PACK and UNPK adjustment operand */
            if (instructions[ira->opCodeNumber].family == OPC_PACK_UNPACK)
            {
               adrcat(",#");
               equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));
               if (equate_name)
                  adrcat(equate_name);
               else
               {
                  adrcat("$");
                  adrcat(itohex(ira->extra, 4));
               }
            }
         }

         Output();
         CheckNoBase(ira->params.prgStart + ira->prgCount * 2);

         if (ira->prgCount > ira->codeArea.codeAreaEnd)
            fprintf(stderr, "P2 Watch out: prgCount*2(=%08lx) > (prgEnd-prgStart)(=%08lx)\n", (unsigned long) (ira->prgCount * 2), (unsigned long) (ira->params.prgEnd - ira->params.prgStart));
      }

      while ((ira->modulcnt + 1 < ira->hunkCount) && (ira->hunksOffs[ira->modulcnt + 1] == ira->codeArea.codeArea2[area]))
      {
         ira->modulcnt++;
         if (ira->params.pFlags & SPLITFILE)
            SplitOutputFiles(&ira->files, &ira->filenames, ira->modulcnt);
         WriteSection(ira);
      }

      /* HERE BEGINS THE DATA PART OF PASS 2 */
      /***************************************/

      ptr1 = ira->codeArea.codeArea2[area];
      if ((area + 1) < ira->codeArea.codeAreas)
         end = ira->codeArea.codeArea1[area + 1];
      else
         end = ira->params.prgEnd;

      while (ptr1 < end)
      {

         text = 0;

         buf = (uint8_t *) ira->buffer + ptr1 - ira->params.prgStart;

         WriteBanner(ptr1);
         /* write label and/or relocation */
         WriteLabel2(ptr1);
         WriteComment(ptr1);
         if (ira->reloc.relocAdr[ira->nextreloc] == ptr1)
         {
            mnecat("DC.L");
            GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
            dtacat(itohex(ptr1, ira->adrlen));
            dtacat(": ");
            dtacat(itohex(be32(buf), 8));

            ptr1 += 4;
            ptr2 = ptr1;
            ira->nextreloc++;

            Output();
            continue;
         }

         /* Check each possible size of equate (4, 2 and 1) */
         for (i = 4; i; i >>= 1)
            if ((equate_name = GetEquate(i, ptr1)))
            {
               mnecat("DC");
               mnecat(extensions[i >> 1]);
               adrcat(equate_name);
               /* In case of equate output, let's print raw data at the end of line */
               dtacat(itohex(ptr1, ira->adrlen));
               dtacat(": ");
               dtacat(itohex(i == 4 ? be32(buf) : i == 2 ? be16(buf) : (*buf), i << 1));

               ptr1 += i;
               ptr2 = ptr1;

               Output();
               break;
            }
         /* Previous loop ends if (i == 0) or if it was "broken".
          * If it was "broken", it means that an equate was found and
          * IRA has to go to next iteration of current loop */
         if (i)
            continue;

         /* sync with jump table */
         while (ira->jmp.jmpIndex < ira->jmp.jmpCount && ptr1 > ira->jmp.jmpTable[ira->jmp.jmpIndex].start)
            ira->jmp.jmpIndex++; /* we already warned in pass 1 about that */

         /* ptr2 will be upper bound */
         ptr2 = end;
         if (ira->nextreloc < ira->relocount && ira->reloc.relocAdr[ira->nextreloc] < ptr2)
            ptr2 = ira->reloc.relocAdr[ira->nextreloc];

         if (ira->jmp.jmpIndex < ira->jmp.jmpCount && ira->jmp.jmpTable[ira->jmp.jmpIndex].start == ptr1)
         {
            /* generate jump-table output */
            ptr2 = ira->jmp.jmpTable[ira->jmp.jmpIndex].end >= ptr2 ? ptr2 : ira->jmp.jmpTable[ira->jmp.jmpIndex].end;
            GenJmptab((uint8_t *) ira->buffer + (ptr1 - ira->params.prgStart), ira->jmp.jmpTable[ira->jmp.jmpIndex].size, ptr1, (int32_t) ira->jmp.jmpTable[ira->jmp.jmpIndex].base, (ptr2 - ptr1) / ira->jmp.jmpTable[ira->jmp.jmpIndex].size);
            ira->jmp.jmpIndex++;
            ptr1 = ptr2;
            continue;
         }

         if (ira->p2labind < ira->labcount && ira->LabelAdr2[ira->p2labind] < ptr2)
            ptr2 = ira->LabelAdr2[ira->p2labind];
         if (ira->jmp.jmpIndex < ira->jmp.jmpCount && ira->jmp.jmpTable[ira->jmp.jmpIndex].start < ptr2)
            ptr2 = ira->jmp.jmpTable[ira->jmp.jmpIndex].start; /* stop at next jump-table */

         /* sync with text table */
         while (ira->text.textIndex < ira->text.textCount && ptr1 >= ira->text.textEnd[ira->text.textIndex])
         {
            fprintf(stderr, "Watch out: TEXT $%08lx-$%08lx probably in code. Ignored.\n", (unsigned long) ira->text.textStart[ira->text.textIndex], (unsigned long) ira->text.textEnd[ira->text.textIndex]);
            ira->text.textIndex++;
         }
         /* check for user defined text block at ptr1 */
         if (ira->text.textIndex < ira->text.textCount && ptr1 >= ira->text.textStart[ira->text.textIndex])
         {
            if (ptr2 > ira->text.textEnd[ira->text.textIndex])
               ptr2 = ira->text.textEnd[ira->text.textIndex];
            text = 99;
            ira->text.textIndex++;
         }
         else
            if (ira->text.textIndex < ira->text.textCount && ptr1 < ira->text.textStart[ira->text.textIndex] && ptr2 > ira->text.textStart[ira->text.textIndex])
               ptr2 = ira->text.textStart[ira->text.textIndex];

         buf = (uint8_t *) ira->buffer + ptr1 - ira->params.prgStart;

         /* a text must have a minimum length */
         if (text == 0 && (ptr2 - ptr1) > 4)
         {
            /* I think a text shouldn't begin with a zero-byte */
            if (buf[0] != 0)
            {
               for (j = 0, zero = 0, text = 1; j < (ptr2 - ptr1); j++)
               {
                  /* First check for TEXT area */
                  if (ira->text.textIndex < ira->text.textCount && ptr1 + j >= ira->text.textStart[ira->text.textIndex])
                  {
                     if (ptr2 > ira->text.textEnd[ira->text.textIndex])
                        ptr2 = ira->text.textEnd[ira->text.textIndex];
                     text = 99;
                     j = ptr2 - ptr1;
                     zero = 0;
                     ira->text.textIndex++;
                     break;
                  }

                  if (buf[j] == 0)
                  {
                     if ((j + 1) < (ptr2 - ptr1))
                        if (buf[j + 1] == 0)
                        {
                           zero++;
                           if (zero > 4)
                           {
                              text = 0;
                              break;
                           }
                        }
                        else
                           if (text < 4)
                              text = 0;
                  }
                  else
                     if (!isprint(buf[j]) && !isspace(buf[j]) && buf[j] != 0x1b && buf[j] != 0x9b)
                     {
                        text = 0;
                        break;
                     }
                     else
                     {
                        text++;
                        zero = 0;
                     }
               }

               if (j == 0)
                  text = 0;
               else
                  if ((buf[j - 1] != 0) && (text < 6))
                     text = 0;
               if (text < 4)
                  text = 0;
               if (zero > 4)
                  text = 0;
            }
         }

         if (text)
         {
            /* write buffer to file */
            if (ira->params.pFlags & ADR_OUTPUT)
            {
               mnecat(";");
               mnecat(itohex(ptr1, ira->adrlen));
               Output();
            }

            if ((ptr2 - ptr1) > 10000)
               printf("ptr1=%08lx  ptr2=%08lx  end=%08lx\n", (unsigned long) ptr1, (unsigned long) ptr2, (unsigned long) ira->params.prgEnd);

            /* get buffer for string */
            tptr = mycalloc((ptr2 - ptr1) * 5 + 6);

            if (ira->params.pFlags & ADR_OUTPUT)
            {
               for (i = 0; i < ((ptr2 - ptr1 - 1) / 16 + 1); i++)
               {
                  strcpy(tptr, "\t;DC.B\t");
                  k = 7;
                  strcpy(&tptr[k++], "$");
                  strcpy(&tptr[k], itohex((uint32_t) buf[i * 16], 2));
                  k += 2;
                  for (j = i * 16 + 1; j < (ptr2 - ptr1) && j < ((i + 1) * 16);
                        j++)
                  {
                     strcpy(&tptr[k], ",$");
                     k += 2;
                     strcpy(&tptr[k], itohex((uint32_t) buf[j], 2));
                     k += 2;
                  }
                  tptr[k++] = '\n';
                  WriteTarget(tptr, k);
               }
            }

            /* create string */
            for (tflag = 0, j = 0, k = 0, l = 0; j < (ptr2 - ptr1); j++, l++)
            {
               if (j == 0 || l > 60 || (j > 0 && buf[j - 1] == 0 && buf[j] != 0) || (j > 0 && buf[j - 1] == 10 && buf[j] != 0 && buf[j] != 10))
               {
                  if (tflag)
                  {
                     if (tflag == 1)
                        tptr[k++] = '\"';
                     tptr[k++] = '\n';
                  }
                  strcpy(&tptr[k], "\tDC.B\t");
                  k += 6;
                  tflag = 0;
                  l = 0;
               }
               if (isprint(buf[j]))
               {
                  if (tflag == 0)
                     tptr[k++] = '\"';
                  if (tflag == 2)
                  {
                     tptr[k++] = ',';
                     tptr[k++] = '\"';
                  }
                  if (ira->params.pFlags & ESCCODES)
                  {
                     if (buf[j] == '\"' || buf[j] == '\'' || buf[j] == '\\')
                        tptr[k++] = '\\';
                  }
                  else
                  {
                     if (buf[j] == '\"')
                        tptr[k++] = '\"';
                  }
                  tptr[k++] = buf[j];
                  tflag = 1;
               }
               else
               {
                  if (tflag == 1)
                  {
                     tptr[k++] = '\"';
                     tptr[k++] = ',';
                  }
                  if (tflag == 2)
                     tptr[k++] = ',';
                  strcpy(&tptr[k], itoasc((uint32_t) buf[j]));
                  k += strlen(&tptr[k]);
                  tflag = 2;
               }
            }
            if (tflag == 1)
               tptr[k++] = '\"';
            tptr[k++] = '\n';

            /* write string */
            WriteTarget(tptr, k);

            /* free stringbuffer */
            free(tptr);
         }
         else
         { /* !text */
            /* First, let's check if there is any equate between ptr1 and ptr2
             * note: CheckEquate() returns equate's address or ptr2 */
            ptr2 = CheckEquate(ira, ptr1, ptr2);

            /* Align to next even address by starting with a byte DS or DC */
            if (((uintptr_t) buf) & 1)
            {
               if ((*buf) == 0)
               {
                  mnecat("DS.B");
                  adrcat("1");
               }
               else
               {
                  mnecat("DC.B");
                  adrcat("$");
                  adrcat(itohex(*buf, 2));
               }
               dtacat(itohex(ptr1, ira->adrlen));

               buf++;
               ptr1++;
               Output();
            }
            longs_per_line = 0;
            while ((ptr2 - ptr1) >= 4)
            {
               if (be32(buf) == 0)
               {
                  if (longs_per_line)
                     Output();
                  longs_per_line = 0;
                  dtacat(itohex(ptr1, ira->adrlen));
                  for (i = 0; (ptr2 - ptr1) >= sizeof(uint32_t) && be32(buf) == 0; ptr1 += sizeof(uint32_t), buf += sizeof(uint32_t))
                     i++;
                  mnecat("DS.L");
                  adrcat(itoasc(i));
                  Output();
               }
               else
               {
                  if (longs_per_line == 0)
                  {
                     mnecat("DC.L");
                     adrcat("$");
                     dtacat(itohex(ptr1, ira->adrlen));
                  }
                  else
                  {
                     adrcat(",$");
                  }
                  adrcat(itohex(be32(buf), 8));
                  longs_per_line++;
                  buf += 4;
                  ptr1 += 4;
                  if (longs_per_line == 4)
                  {
                     longs_per_line = 0;
                     Output();
                  }
               }
            }
            if (longs_per_line)
               Output();
            if ((ptr2 - ptr1) > 1)
            {
               if (be16(buf) == 0)
               {
                  mnecat("DS.W");
                  adrcat("1");
               }
               else
               {
                  mnecat("DC.W");
                  adrcat("$");
                  adrcat(itohex(be16(buf), 4));
               }
               dtacat(itohex(ptr1, ira->adrlen));
               buf += 2;
               ptr1 += 2;
               Output();
            }
            if (ptr2 - ptr1)
            {
               if ((*buf) == 0)
               {
                  mnecat("DS.B");
                  adrcat("1");
               }
               else
               {
                  mnecat("DC.B");
                  adrcat("$");
                  adrcat(itohex(*buf, 2));
               }
               dtacat(itohex(ptr1, ira->adrlen));
               buf++;
               ptr1++;
               Output();
            }
         }

         ptr1 = ptr2;
      }

      ira->prgCount = (end - ira->params.prgStart) / 2;
   }

   if (ira->params.pFlags & SPLITFILE)
   {
      fclose(ira->files.targetFile);
      ira->files.targetFile = NULL;
   }

   /* write last label */
   WriteLabel2(ira->params.prgStart + ira->prgCount * 2);

   if (ira->p2labind != ira->labcount)
      fprintf(stderr, "labcount=%ld  p2labind=%ld\n", (long) ira->labcount, (long) ira->p2labind);

   if (!(ira->params.pFlags & SPLITFILE))
      WriteTarget("\tEND\n", 5);

   fprintf(stderr, "100%%\n\n");
}

void CheckPhase(uint32_t adr)
{
   static uint32_t lc = 0;

   if (ira->labcount)
   {
      if (adr == -1)
         while (lc < ira->label.labelMax && ira->labelbuf[lc] < ira->prgCount * 2 + ira->params.prgStart)
            lc++;
      else
      {
         /* automatic phase sync */
         while (lc < ira->labc1 && adr > ira->labelbuf[lc])
            lc++;

         if (adr != ira->labelbuf[lc++])
            fprintf(stderr, "PHASE ERROR: adr=%08lx  %08lx %08lx %08lx\n", (unsigned long) adr, (unsigned long) ira->labelbuf[lc - 2], (unsigned long) ira->labelbuf[lc - 1], (unsigned long) ira->labelbuf[lc]);
         while (lc < ira->labc1 && ira->labelbuf[lc] == ira->labelbuf[lc - 1])
            lc++;
      }
   }

}

void WriteLabel2(uint32_t adr)
{
   uint32_t index;
   uint16_t flag;
   static uint32_t oldadr = 0;

   /* output of percent every 2 kb */
   if ((adr - oldadr) >= 2048)
   {
      fprintf(stderr, "%3d%%\r", (int) (((adr - ira->params.prgStart) * 100) / ira->params.prgLen));
      fflush(stderr);
      oldadr = adr;
   }

   /* write labels for current address */
   if (ira->LabelAdr2[ira->p2labind] < adr && ira->p2labind < ira->labcount)
      fprintf(stderr, "%lx adr=%lx This=%x\n", (unsigned long) ira->p2labind, (unsigned long) adr, (unsigned long) ira->LabelAdr2[ira->p2labind]);

   if (ira->LabelAdr2[ira->p2labind] == adr && ira->p2labind < ira->labcount)
   {
      flag = 1;
      index = ira->p2labind;
      while (ira->LabelAdr2[ira->p2labind] == adr && ira->p2labind < ira->labcount)
      {
         if (GetSymbol(ira->label.labelAdr[index]))
         {
            fprintf(ira->files.targetFile, "%s:\n", ira->adrbuf);
            ira->adrbuf[0] = 0;
         }
         else
            flag = 0;
         ira->p2labind++;
      }
      if (flag == 0) {
         switch (ira->params.labelStyle) {
            case LABSTYLE_ADDR:
               fprintf(ira->files.targetFile, "LAB_%lX:\n", (unsigned long) adr);
               break;
            default:
               fprintf(ira->files.targetFile, "LAB_%04lX:\n", (unsigned long) index);
               break;
         }
      }
   }
}

void WriteBanner(uint32_t adr)
{
   Comment_t *p;
   int hasBanner, i;

   for (p = ira->banners, hasBanner = 0; p; p = p->next )
      if(p->commentAdr == adr)
      {
         if (!hasBanner)
         {
            hasBanner = 1;
            fprintf(ira->files.targetFile, BANNER_TEMPLATE);
         }
         fprintf(ira->files.targetFile, COMMENT_TEMPLATE, p->commentText);
      }

   if (hasBanner)
      fprintf(ira->files.targetFile, BANNER_TEMPLATE);
}

void WriteComment(uint32_t adr)
{
   Comment_t *p;

   for (p = ira->comments; p; p = p->next)
      if (p->commentAdr == adr)
         fprintf(ira->files.targetFile, COMMENT_TEMPLATE, p->commentText);
}

void WriteEquates(ira_t *ira)
{
   Equate_t *p, *q;
   int bool;

   if (ira->equates)
   {
      fprintf(ira->files.targetFile, "; Custom equates (from config file)\n");
      for (p = ira->equates; p; p = p->next)
      {
         for (q = ira->equates, bool = 1; q != p && bool; q = q->next)
            if (strcmp(p->equateName, q->equateName) == 0)
               bool = 0;
         if (bool)
            fprintf(ira->files.targetFile, "%s\tEQU\t%s\n",
                    p->equateName, itoasc(p->equateValue));
      }
      fprintf(ira->files.targetFile, "\n");
   }
}

void WriteExtsyms(ira_t *ira)
{
   Extsym_t *p;

   for (p = ira->extsyms; p; p = p->next)
      fprintf(ira->files.targetFile, EQUATE_TEMPLATE, p->extName,
              (unsigned long)p->extValue);
   fprintf(ira->files.targetFile, "\n");
}

void Output(void)
{
   int i;

   /* Here, the issue takes place */
   if ((ira->params.pFlags & ADR_OUTPUT) && ira->dtabuf[0])
   {
      i = 3 - strlen(ira->adrbuf) / 8;
      if (i <= 0)
         adrcat(" ");
      for (; i > 0; i--)
         adrcat("\t");
      fprintf(ira->files.targetFile, "\t%s\t%s;%s\n", ira->mnebuf, ira->adrbuf, ira->dtabuf);
   }
   else
      if (ira->adrbuf[0])
         fprintf(ira->files.targetFile, "\t%s\t%s\n", ira->mnebuf, ira->adrbuf);
      else
         if (ira->mnebuf[0])
            fprintf(ira->files.targetFile, "\t%s\n", ira->mnebuf);

   ira->dtabuf[0] = '\0';
   ira->adrbuf[0] = '\0';
   ira->mnebuf[0] = '\0';
}

int P2WriteReloc()
{
   if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
   {
      ira->dtabuf[0] = 0;
      ira->mnebuf[0] = 0;
      ira->adrbuf[0] = 0;
      mnecat("DC.W");
      adrcat("$");
      adrcat(itohex(ira->seaow, 4));
      dtacat(itohex(ira->pc * 2 + ira->params.prgStart, ira->adrlen));
      ira->prgCount = ira->pc + 1;
      Output();
      return (-1);
   }
   else
   {
      dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
      return (0);
   }
}

int NewAdrModes2(uint16_t mode, uint16_t reg)
/* AdrType :  6 --> Baseregister An */
/*           10 --> PC-relative     */
{
   uint16_t buf = be16(&ira->buffer[ira->prgCount]);
   uint16_t scale;
   uint16_t bdsize;
   uint16_t odsize;
   uint16_t iis;
   uint16_t is;
   uint16_t operand, square1, square2;
   int32_t adr;
   int getlab = 0;
   char *equate_name;

   if (P2WriteReloc())
      return (-1);

   if (ira->params.cpuType & (M68000 | M68010))
   {
      if (buf & 0x0700)
         return (MODE_INVALID);
      else
      {
         if (mode == 10)
         {
            adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int8_t) buf);
            if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
               return (MODE_INVALID);
            getlab = 1;
         }
         else
            if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
            {
               adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int8_t) buf;
               /*if (adr<(int32_t)(ira->moduloffs[ira->baseReg.baseSection]+ira->modultab[ira->baseReg.baseSection])
                && adr>=(int32_t)ira->moduloffs[ira->baseReg.baseSection])*/
               getlab = 1;
            }

         if (!getlab)
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            equate_name = GetEquate(1, PrgCount2Adr(ira->prgCount - 1) + 1);

         if (ira->params.pFlags & OLDSTYLE)
         {
            if (getlab)
               GetLabel(adr, mode);
            else
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int8_t) (buf & 0x00FF)));
            adrcat("(");
         }
         else
         {
            adrcat("(");
            if (getlab)
               GetLabel(adr, mode);
            else
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int8_t) (buf & 0x00FF)));
            adrcat(",");
         }

         if (mode == 6)
         {
            adrcat("A");
            adrcat(itohex(reg, 1));
         }
         else
            adrcat("PC");

         adrcat((buf & REGISTER_EXTENSION_TYPE) ? ",A" : ",D");
         adrcat(itohex((buf >> 12) & 7, 1));
         adrcat((buf & 0x0800) ? ".L" : ".W");
      }
   }
   else
   {
      scale = (buf & 0x0600) >> 9;
      if (buf & 0x0100)
      { /* MC68020 (& up) FULL FORMAT */
         bdsize = (buf & 0x0030) >> 4;
         odsize = (buf & 0x0003);
         iis = (buf & 0x0007);
         is = (buf & 0x0040) >> 6;
         operand = square1 = square2 = 0;

         if (mode == 10)
            reg = 0;
         if (buf & 8)
            return (MODE_INVALID);
         if (bdsize == 0)
            return (MODE_INVALID);
         if (is == 0 && iis == 4)
            return (MODE_INVALID);
         if (is == 1 && iis >= 4)
            return (MODE_INVALID);
         /*
          if (is==1 && (buf&0xfe00)) return(NOADRMODE);
          if (buf&0x0080 && reg!=0)  return(NOADRMODE);
          */
         if (bdsize > 1)
         {
            operand |= 1;
            square1 |= 1;
         }
         if (!(buf & 0x0080))
         {
            operand |= 2;
            square1 |= 2;
         }
         if ((buf & 0x0080) && mode == 10)
         {
            operand |= 2;
            square1 |= 2;
         }
         if (is == 0 || (buf & 0xF000))
         {
            operand |= 4;
            if (iis < 4)
               square1 |= 4;
         }
         if (odsize > 1)
            operand |= 8;
         if (iis != 0)
            square2 = square1;
         else
            square1 = 0;
         operand &= ~square1;
         if (!square1)
            operand |= 6;

         adrcat("(");
         if (square1)
            adrcat("[");
         if ((square1 | operand) & 1)
         { /* base displacement */
            if (bdsize == 2)
            {
               if (mode == 10 && !(buf & 0x0080))
               {
                  adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int16_t) be16(&ira->buffer[ira->prgCount]));
                  if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
                     return (MODE_INVALID);
#else
                     goto pc16out;
#endif
                  if (P2WriteReloc())
                     return (-1);
                  GetLabel(adr, mode);
               }
               else
               {
                  pc16out:
                  if (P2WriteReloc())
                     return (-1);
                  /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
                  equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));
                  if (equate_name)
                     adrcat(equate_name);
                  else
                     adrcat(itoasc((int16_t) be16(&ira->buffer[ira->prgCount - 1])));
               }
               adrcat(".W");
            }
            if (bdsize == 3)
            {
               if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
               {
                  GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
                  ira->nextreloc++;
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
               }
               else
               {
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                  if (mode == 10 && !(buf & 0x0080))
                  {
                     adr = ((ira->prgCount - 2) * 2 + ira->params.prgStart + (be16(&ira->buffer[ira->prgCount - 1]) << 16) + be16(&ira->buffer[ira->prgCount]));
                     if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
                        return (MODE_INVALID);
#else
                        goto pc32out;
#endif
                     if (P2WriteReloc())
                        return (-1);
                     GetLabel(adr, mode);
                  }
                  else
                  {
                     pc32out:
                     if (P2WriteReloc())
                        return (-1);
                     /* note: There is "ira->prgCount++" at dtacat() call few lines above and P2WriteReloc also does "ira->prgCount++" when succeed,
                      * so GetEquate needs PC-2 value */
                     equate_name = GetEquate(4, PrgCount2Adr(ira->prgCount - 2));
                     if (equate_name)
                        adrcat(equate_name);
                     else
                     {
                        adrcat("$");
                        adrcat(itohex(be16(&ira->buffer[ira->prgCount - 2]), 4));
                        adrcat(itohex(be16(&ira->buffer[ira->prgCount - 1]), 4));
                     }
                  }
               }
               adrcat(".L");
            }
            square1 &= ~1;
            operand &= ~1;
            if (square2 && !square1)
            {
               adrcat("]");
               square2 = 0;
            }
            if (square1 || operand)
               adrcat(",");
         }
         /* base register or (Z)PC */
         if ((square1 | operand) & 2)
         {
            if (buf & 0x0080)
               adrcat("Z");
            if (mode == 6)
            {
               adrcat("A");
               adrcat(itohex(reg, 1));
            }
            else
            {
               adrcat("PC");
            }
            square1 &= ~2;
            operand &= ~2;
            if (square2 && !square1)
            {
               adrcat("]");
               square2 = 0;
            }
            if (square1 || operand)
               adrcat(",");
         }
         /* index register */
         if ((square1 | operand) & 4)
         {
            if (is)
               adrcat("Z");
            adrcat((buf & REGISTER_EXTENSION_TYPE) ? "A" : "D");
            adrcat(itohex((buf >> 12) & 7, 1));
            if (buf & 0x0800)
               adrcat(".L");
            else
               adrcat(".W");
            if (scale)
            {
               adrcat("*");
               adrcat(itoasc(1 << scale));
            }
            square1 &= ~4;
            operand &= ~4;
            if (square2 && !square1)
            {
               adrcat("]");
               square2 = 0;
            }
            if (square1 || operand)
               adrcat(",");
         }
         /* outer displacement */
         if (operand & 8)
         {
            if (odsize == 2)
            {
               if (P2WriteReloc())
                  return (-1);
               /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
               equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int16_t) be16(&ira->buffer[ira->prgCount - 1])));
               adrcat(".W");
            }
            if (odsize == 3)
            {
               if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
               {
                  GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
                  ira->nextreloc++;
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
               }
               else
               {
                  dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                  if (P2WriteReloc())
                     return (-1);
                  /* note: There is "ira->prgCount++" at dtacat() call few lines above and P2WriteReloc also does "ira->prgCount++" when succeed,
                   * so GetEquate needs PC-2 value */
                  equate_name = GetEquate(4, PrgCount2Adr(ira->prgCount - 2));
                  if (equate_name)
                     adrcat(equate_name);
                  else
                  {
                     adr = (be16(&ira->buffer[ira->prgCount - 2]) << 16) + be16(&ira->buffer[ira->prgCount - 1]);
                     adrcat(itoasc(adr));
                  }
               }
               adrcat(".L");
            }
         }
      }
      else
      { /* MC68020 (& up) BRIEF FORMAT */
         if (mode == 10)
         {
            adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int8_t) buf);
            if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
               return (MODE_INVALID);
#else
               getlab = 0;
            else
#endif
            getlab = 1;
         }
         else
            if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
            {
               adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int8_t) buf;
               /*if (adr<(int32_t)(ira->moduloffs[ira->baseReg.baseSection]+ira->modultab[ira->baseReg.baseSection])
                && adr>=(int32_t)ira->moduloffs[ira->baseReg.baseSection])*/
               getlab = 1;
            }

         if (!getlab)
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            equate_name = GetEquate(1, PrgCount2Adr(ira->prgCount - 1) + 1);

         if (ira->params.pFlags & OLDSTYLE)
         {
            if (getlab)
               GetLabel(adr, mode);
            else
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int8_t) (buf & 0x00FF)));
            adrcat("(");
         }
         else
         {
            adrcat("(");
            if (getlab)
               GetLabel(adr, mode);
            else
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int8_t) (buf & 0x00FF)));
            adrcat(",");
         }
         if (mode == 6)
         {
            adrcat("A");
            adrcat(itohex(reg, 1));
         }
         else
            adrcat("PC");
         adrcat((buf & REGISTER_EXTENSION_TYPE) ? ",A" : ",D");
         adrcat(itohex((buf >> 12) & 7, 1));
         adrcat((buf & 0x0800) ? ".L" : ".W");
         if (scale)
         {
            adrcat("*");
            adrcat(itoasc(1 << scale));
         }
      }
   }
   adrcat(")");
   return (mode);
}

int DoAdress2(uint16_t adrs)
/* This is for PASS 2 */
{
   uint16_t i;
   uint16_t mode = ira->addressMode;
   uint16_t dummy1;
   uint16_t buf = be16(&ira->buffer[ira->prgCount]);
   uint16_t reg, creg;
   int32_t adr;
   char *equate_name;

   if (mode != MODE_INVALID)
   {
      if (adrs & MODE_ALT_REGISTER)
         reg = ira->alt_register;
      else
         if (adrs & MODE_EXT_REGISTER)
            reg = ira->ext_register;
         else
            reg = ira->ea_register;

      if (adrs & MODE_IN_LOWER_BYTE)
         mode = adrs & MODE_IN_LOWER_BYTE_MASK;
      else
         if (((adrs & EA_MASK) == adrs) && !(adrs & (EA_SELECTOR_BIT >> mode)))
            mode = MODE_INVALID;
   }

   /* process addressing mode */
   switch (mode)
   {
      case MODE_DREG_DIRECT:
         adrcat("D");
         adrcat(itohex(reg, 1));
         break;

      case MODE_AREG_DIRECT:
         /* Byte access on address register is not possible */
         /* ira->extension is 0 for LEA (because odd addresses are allowed) */
         if (ira->extension || instructions[ira->opCodeNumber].family == OPC_LEA)
         {
            adrcat("A");
            adrcat(itohex(reg, 1));
         }
         else
            mode = MODE_INVALID;
         break;

      case MODE_AREG_INDIRECT:
         adrcat("(A");
         adrcat(itohex(reg, 1));
         adrcat(")");
         break;

      case MODE_AREG_INDIRECT_POST:
         adrcat("(A");
         adrcat(itohex(reg, 1));
         adrcat(")+");
         break;

      case MODE_AREG_INDIRECT_PRE:
         adrcat("-(A");
         adrcat(itohex(reg, 1));
         adrcat(")");
         break;

      case MODE_AREG_INDIRECT_D16:
         if (P2WriteReloc())
            return (-1);
         dummy1 = 0;
         if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
         {
            adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int16_t) buf;
            dummy1 = 1;
         }
         if (dummy1)
         {
            if (!ira->params.baseAbs && !(ira->params.pFlags & OLDSTYLE))
               adrcat("(");
            GetLabel(adr, mode);
            if (!ira->params.baseAbs)
            {
               if (ira->params.pFlags & OLDSTYLE)
                  adrcat("(A");
               else
                  adrcat(",A");
               adrcat(itohex(reg, 1));
               adrcat(")");
            }
         }
         else
         {
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));

            if (ira->params.pFlags & OLDSTYLE)
            {
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int16_t) buf));
               adrcat("(A");
            }
            else
            {
               adrcat("(");
               if (equate_name)
                  adrcat(equate_name);
               else
                  adrcat(itoasc((int16_t) buf));
               adrcat(",A");
            }
            adrcat(itohex(reg, 1));
            adrcat(")");
         }
         break;

      case MODE_AREG_INDIRECT_INDEX:
      case MODE_PC_INDIRECT_INDEX:
         if ((mode = NewAdrModes2(mode, reg)) == (uint16_t)-1)
            return (-1);
         break;

      case MODE_ABSOLUTE_16:
         adr = (int16_t) buf;
         /* Reject odd address */
         if ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR || instructions[ira->opCodeNumber].family == OPC_ROTATE_SHIFT_MEMORY))
            mode = MODE_INVALID;
         else
         {
            if (P2WriteReloc())
               return (-1);
            /* PEA for stack arguments in C code */
            if (instructions[ira->opCodeNumber].family == OPC_PEA || (ira->params.sourceType == M68K_BINARY && NoPtrsArea(ira->prgCount * 2 + ira->params.prgStart)))
               adrcat(itoasc(adr));
            else
            {
               if (ira->params.sourceType == M68K_BINARY && (adr >= ira->params.prgStart && adr <= ira->params.prgEnd))
                  GetLabel(adr, mode);
               else
                  GetXref(adr);
            }
            adrcat(".W");
         }
         break;

      case MODE_ABSOLUTE_32:
         adr = ((buf << 16) + be16(&ira->buffer[ira->prgCount + 1]));
         /* Reject odd address */
         if ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR || instructions[ira->opCodeNumber].family == OPC_ROTATE_SHIFT_MEMORY))
            mode = MODE_INVALID;
         else
         {
            if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart + 2))
               mode = MODE_INVALID;
            else if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
            {
               GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
               ira->nextreloc++;
            }
            else
            {
               /* PEA for stack arguments in C code */
               if (instructions[ira->opCodeNumber].family == OPC_PEA || (ira->params.sourceType == M68K_BINARY && NoPtrsArea(ira->prgCount * 2 + ira->params.prgStart)))
               {
                  adrcat("$");
                  adrcat(itohex(adr, 8));
               }
               else
               {
                  if (ira->params.sourceType == M68K_BINARY && (adr >= ira->params.prgStart && adr <= ira->params.prgEnd))
                     GetLabel(adr, mode);
                  else
                     GetXref(adr);
               }
            }
            dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
            dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
         }
         break;

      case MODE_PC_RELATIVE:
         adr = (ira->prgCount * 2 + ira->params.prgStart + (int16_t) buf);
         if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR))) {
#if PCLABELSONLY
            mode = MODE_INVALID;
#else
            if (P2WriteReloc())
               return (-1);
            if (ira->params.pFlags & OLDSTYLE)
            {
               adrcat(itoasc((int16_t) buf));
               adrcat("(PC)");
            }
            else
            {
               adrcat("(");
               adrcat(itoasc((int16_t) buf));
               adrcat(",PC)");
            }
#endif
         }
         else
         {
            if (P2WriteReloc())
               return (-1);
            if (ira->params.pFlags & OLDSTYLE)
            {
               GetLabel(adr, mode);
               adrcat("(PC)");
            }
            else
            {
               adrcat("(");
               GetLabel(adr, mode);
               adrcat(",PC)");
            }
         }
         break;

      case MODE_IMMEDIATE:
         if (adrs == instructions[ira->opCodeNumber].sourceadr || instructions[ira->opCodeNumber].family == OPC_BITOP)
         {
            if (ira->extension != 3)
            {
               if (ira->extension == 0)
               {
                  /* immediate data can have MSB different from 0 only if MSB is 0xff and LSB has most significant bit set.
                   * it means that immediate's MSB is only allowed to be LSB sign extended. */
                  if ((buf & 0xff00) != 0 && (buf & 0xff80) != 0xff80)
                     mode = MODE_INVALID;
                  else
                     /* BUT !
                      * that sign extension over MSB is only allowed with COMPAT flag 'i' */
                     if ((buf & 0xff80) == 0xff80 && !ira->params.immedByte)
                        mode = MODE_INVALID;
                     else
                     {
                        if (P2WriteReloc())
                           return (-1);
                        adrcat("#");
                        /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
                        equate_name = GetEquate(1, PrgCount2Adr(ira->prgCount - 1) + 1);
                        if (equate_name)
                           adrcat(equate_name);
                        else
                        {
                           adrcat("$");
                           adrcat(itohex(buf & 0xFFFF, 2));
                        }
                     }
               }
               else
                  if (ira->extension == 1)
                  {
                     if (P2WriteReloc())
                        return (-1);
                     adrcat("#");
                     /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
                     equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));
                     if (equate_name)
                        adrcat(equate_name);
                     else
                     {
                        adrcat("$");
                        adrcat(itohex(buf, 4));
                     }
                  }
                  else
                     if (ira->extension == 2)
                     {
                        if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart + 2))
                           mode = MODE_INVALID;
                        else
                        {
                           if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
                           {
                              adrcat("#");
                              GetLabel(ira->reloc.relocVal[ira->nextreloc], 9999);
                              ira->nextreloc++;
                           }
                           else
                           {
                              adrcat("#");
                              equate_name = GetEquate(4, PrgCount2Adr(ira->prgCount));
                              if (equate_name)
                                 adrcat(equate_name);
                              else
                              {
                                 adrcat("$");
                                 adrcat(itohex(buf, 4));
                                 adrcat(itohex(be16(&ira->buffer[ira->prgCount + 1]), 4));
                              }
                           }
                           dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                           dtacat(itohex(be16(&ira->buffer[ira->prgCount++]), 4));
                        }
                     }
            }
            else
               mode = MODE_INVALID;
         }
         else
         {
            /* <ea> #data (aka IMMEDIATE) for destination operand has a special meaning (except for BTST)
             * for EORI, ANDI and ORI, it means CCR or SR, according to SEAOW extension size bits (7 & 6)
             * .B for CCR and .W for SR (.L is invalid) */
            if (ira->extension == 0)
               adrcat("CCR");
            if (ira->extension == 1)
               adrcat("SR");
            if (ira->extension == 2)
               mode = MODE_INVALID; /* d=immediate long */
         }
         break;

      case MODE_CCR:
         adrcat("CCR");
         break;

      case MODE_SR:
         adrcat("SR");
         break;

      case MODE_USP:
         adrcat("USP");
         break;

      case MODE_MOVEM:
         if ((dummy1 = ira->extra))
         {
            i = 0;
            if ((instructions[ira->opCodeNumber].family == OPC_MOVEM) && !(ira->seaow & 0x0018))
            {
               while (dummy1)
               {
                  if (dummy1 & 0x8000)
                  {
                     if (i < 8)
                        adrcat("D");
                     else
                        adrcat("A");
                     adrcat(itohex(i & 7, 1));
                     if ((dummy1 & 0x4000) && (i & 7) < 7)
                     {
                        adrcat("-");
                        while ((dummy1 & 0x4000) && (i & 7) < 7)
                        {
                           dummy1 <<= 1;
                           i++;
                        }
                        if (i < 8)
                           adrcat("D");
                        else
                           adrcat("A");
                        adrcat(itohex(i & 7, 1));
                     }
                     if ((uint16_t) (dummy1 << 1))
                        adrcat("/");
                  }
                  i++;
                  dummy1 <<= 1;
               }
            }
            else
            {
               while (dummy1 || i < 16)
               {
                  if (dummy1 & 0x0001)
                  {
                     if (i < 8)
                        adrcat("D");
                     else
                        adrcat("A");
                     adrcat(itohex(i & 7, 1));
                     if ((dummy1 & 0x0002) && (i & 7) < 7)
                     {
                        adrcat("-");
                        while ((dummy1 & 0x0002) && (i & 7) < 7)
                        {
                           dummy1 >>= 1;
                           i++;
                        }
                        if (i < 8)
                           adrcat("D");
                        else
                           adrcat("A");
                        adrcat(itohex(i & 7, 1));
                     }
                     if (dummy1 >> 1)
                        adrcat("/");
                  }
                  i++;
                  dummy1 >>= 1;
               }
            }
         }
         else
         {
            adrcat("#0"); /* no register */
         }
         break;

      case MODE_ADDQ_SUBQ:
         adrcat("#");
         equate_name = GetEquate(0, PrgCount2Adr(ira->prgCount - 1));
         if (equate_name)
            adrcat(equate_name);
         else
         {
            if (!reg)
               reg = 8;
            adrcat(itohex(reg, 1));
         }
         break;

      case MODE_BKPT:
         adrcat("#");
         adrcat(itohex(reg, 1));
         break;

      case MODE_DBcc:
      case MODE_PDBcc:
         adr = (ira->prgCount * 2 + ira->params.prgStart + (int16_t) buf);
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1) || !buf)
            mode = MODE_INVALID;
         else
         {
            if (P2WriteReloc())
               return (-1);
            GetLabel(adr, mode);
         }
         break;

      case MODE_TRAP:
         adrcat("#");
         adrcat(itoasc(ira->seaow & 0xF));
         break;

      case MODE_MOVEQ:
         adrcat("#");
         equate_name = GetEquate(1, PrgCount2Adr(ira->prgCount - 1) + 1);
         if (equate_name)
            adrcat(equate_name);
         else
            adrcat(itoasc((int8_t) (ira->seaow & 0x00ff)));
         break;

      case MODE_Bcc:
         if ((ira->seaow & 0x00ff) == 0x00ff)
            if (ira->params.cpuType & M020UP)
            {
               ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
               if (ira->displace != 0 && ira->displace != 2)
               {
                  ira->displace += ira->prgCount * 2;
                  if (P2WriteReloc())
                     return (-1);
                  if (P2WriteReloc())
                     return (-1);
                  mnecat(".L");
               }
               else
                  mode = MODE_INVALID;
            }
            else
               mode = MODE_INVALID;
         else
            if ((ira->seaow & 0x00ff) == 0x0000)
            {
               if (buf)
               {
                  mnecat(".W");
                  ira->displace = (ira->prgCount * 2 + (int16_t) (buf));
                  if (P2WriteReloc())
                     return (-1);
               }
               else
                  mode = MODE_INVALID;
            }
            else
            {
               mnecat(".S");
               ira->displace = (ira->prgCount * 2 + (int8_t) (ira->seaow & 0x00ff));
            }

         adr = ira->params.prgStart + ira->displace;
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1))
            mode = MODE_INVALID;
         else
            GetLabel(adr, mode);
         break;

      case MODE_SP_DISPLACE_W: /* LINK , RTD */
         /* Here may be the odd stack pointer compatibility flag */
         if (buf & 1)
            mode = MODE_INVALID;
         else
         {
            if (P2WriteReloc())
               return (-1);
            adrcat("#");
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            equate_name = GetEquate(2, PrgCount2Adr(ira->prgCount - 1));
            if (equate_name)
               adrcat(equate_name);
            else
               adrcat(itoasc((int16_t) buf));
         }
         break;

      case MODE_BIT_MANIPULATION:
         mnecat(&bitop[ira->extension][0]);
         if (!ira->extension) /* BTST */
            if (ira->seaow & 0x0100)
               instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED;
            else
               instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND;
         else
            /* BCHG, BCLR, BSET */
            instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
         if (ira->seaow & 0x0100)
         {
            adrcat("D");
            adrcat(itohex(reg, 1));
         }
         else
         {
            if (P2WriteReloc())
               return (-1);
            adrcat("#");
            if (ira->seaow & 0x0038)
            {
               if (buf & (ira->params.bitRange ? 0xfff0 : 0xfff8))
                  mode = MODE_INVALID;
            }
            else
            {
               if (buf & 0xffe0)
                  mode = MODE_INVALID;
            }
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            equate_name = GetEquate(1, PrgCount2Adr(ira->prgCount - 1) + 1);
            if (equate_name)
               adrcat(equate_name);
            else
               adrcat(itoasc(buf));
         }
         ira->extension = 0; /* Set extension to BYTE (undefined before) */
         break;

      case MODE_BITFIELD:
         /* specific behaviour according to bitfield's identifier */
         switch ((ira->seaow & BITFIELD_IDENTIFIER_MASK) >> 8)
         {
            case BITFIELD_IDENTIFIER_CHG:
            case BITFIELD_IDENTIFIER_CLR:
            case BITFIELD_IDENTIFIER_SET:
            case BITFIELD_IDENTIFIER_INS:
               if (DoAdress2(D_DIR|A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32))
                  return (-1);
               break;

            case BITFIELD_IDENTIFIER_EXTS:
            case BITFIELD_IDENTIFIER_EXTU:
            case BITFIELD_IDENTIFIER_FFO:
            case BITFIELD_IDENTIFIER_TST:
               if (DoAdress2(D_DIR|A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND))
                  return (-1);
               break;
         }

         adrcat("{");
         reg = (ira->extra & 0x07c0) >> 6;
         if (ira->extra & 0x0800)
         {
            if (reg > 7)
               mode = MODE_INVALID;
            adrcat("D");
         }
         adrcat(itoasc(reg));
         adrcat(":");
         reg = (ira->extra & 0x001f);
         if (ira->extra & BITFIELD_DATA_WIDTH_BIT)
         {
            if (reg > 7)
               mode = MODE_INVALID;
            adrcat("D");
         }
         else
            if (reg == 0)
               reg = 32;
         adrcat(itoasc(reg));
         adrcat("}");
         break;

      case MODE_RTM:
         if (ira->seaow & 0x0008)
            adrcat("A");
         else
            adrcat("D");
         adrcat(itoasc(ira->ea_register));
         break;

      case MODE_CAS2:
         buf = be16(&ira->buffer[ira->prgCount]);
         if (P2WriteReloc())
            return (-1);
         ira->extension = (ira->seaow & ALT_EXTENSION_SIZE_MASK) >> 9;
         if (ira->extension == 0 || ira->extension == 1)
            mode = MODE_INVALID;
         else
            mnecat(extensions[--ira->extension]);
         if ((buf & 0x0e38) || (ira->extra & 0x0e38))
            mode = MODE_INVALID;
         else
         {
            adrcat("D");
            adrcat(itoasc(ira->extra & 7));
            adrcat(":");
            adrcat("D");
            adrcat(itoasc(buf & 7));
            adrcat(",");
            adrcat("D");
            adrcat(itoasc((ira->extra & 0x01c0) >> 6));
            adrcat(":");
            adrcat("D");
            adrcat(itoasc((buf & 0x01c0) >> 6));
            adrcat(",");
            adrcat((ira->extra & REGISTER_EXTENSION_TYPE) ? "(A" : "(D");
            adrcat(itoasc((ira->extra & REGISTER_EXTENSION_MASK) >> 12));
            adrcat("):");
            adrcat((buf & REGISTER_EXTENSION_TYPE) ? "(A" : "(D");
            adrcat(itoasc((buf & REGISTER_EXTENSION_MASK) >> 12));
            adrcat(")");
         }
         break;

      case MODE_CAS:
         ira->extension = (ira->seaow & ALT_EXTENSION_SIZE_MASK) >> 9;
         if (ira->extension == 0)
            mode = MODE_INVALID;
         else
            mnecat(extensions[--ira->extension]);
         if (ira->extra & CAS_EXTENSION_MASK)
            mode = MODE_INVALID;
         else
         {
            adrcat("D");
            adrcat(itoasc(ira->extra & CAS_EXTENSION_DC));
            adrcat(",");
            adrcat("D");
            adrcat(itoasc((ira->extra & CAS_EXTENSION_DU) >> 6));
         }
         break;

      case MODE_MUL_DIV_LONG:
         if (ira->extra & 0x83f8)
            mode = MODE_INVALID;
         else
         {
            if (ira->extra & 0x0800)
               mnecat("S");
            else
               mnecat("U");
            reg = (ira->extra & REGISTER_EXTENSION_MASK) >> 12;
            creg = ira->extra & 0x0007; /* Dr/Dh */
            if (instructions[ira->opCodeNumber].family == OPC_DIVL)
            {
               if (!(ira->extra & 0x0400) && reg != creg)
                  mnecat("L");
               adrcat("D");
               adrcat(itoasc(creg));
               if ((ira->extra & 0x0400) || (!(ira->extra & 0x0400) && reg != creg))
               {
                  adrcat(":D");
                  adrcat(itoasc(reg));
               }
            }
            else
            { /* MUL?.L */
               if (ira->extra & 0x0400)
               {
                  adrcat("D");
                  adrcat(itoasc(creg));
                  adrcat(":");
               }
               adrcat("D");
               adrcat(itoasc(reg));
            }
            mnecat(".L");
         }
         break;

      case MODE_SP_DISPLACE_L: /* LINK.L */
         ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
         /* Here may be the odd stack pointer compatibility flag */
         if (ira->displace & 1)
            mode = MODE_INVALID;
         else
         {
            if (P2WriteReloc())
               return (-1);
            if (P2WriteReloc())
               return (-1);
            adrcat("#");
            /* note: P2WriteReloc does "ira->prgCount++" when succeed, so GetEquate needs previous PC value */
            /* note2: P2WriteReloc executed twice */
            equate_name = GetEquate(4, PrgCount2Adr(ira->prgCount - 2));
            if (equate_name)
               adrcat(equate_name);
            else
               adrcat(itoasc(ira->displace));
         }
         break;

      case MODE_CACHE_REG:
         adrcat(caches[(ira->seaow & CACHE_REGISTER) >> 6]);
         break;

      case MODE_MOVEC:
         if (P2WriteReloc())
            return (-1);
         reg = (buf & REGISTER_EXTENSION_MASK) >> 12;
         creg = buf & MOVEC_CONTROL_REGISTER_MASK;
         if (creg & ILLEGAL_CONTROL_REGISTER)
            mode = MODE_INVALID;
         else
         {
            if (ira->seaow & MOVEC_DIRECTION_BIT)
            {
               adrcat((buf & REGISTER_EXTENSION_TYPE) ? "A" : "D");
               adrcat(itoasc(reg));
               adrcat(",");
            }
            if (creg & MOVEC_CR_HIGHER_RANGE_BIT)
               creg = (creg & ~MOVEC_CR_HIGHER_RANGE_BIT) + 9;
            if (ira->params.cpuType & ControlRegisters[creg].cpuflag)
               adrcat(ControlRegisters[creg].name);
            else
               mode = MODE_INVALID;
            if (!(ira->seaow & MOVEC_DIRECTION_BIT))
            {
               adrcat((buf & REGISTER_EXTENSION_TYPE) ? ",A" : ",D");
               adrcat(itoasc(reg));
            }
         }
         break;

      case MODE_MOVES:
         if (ira->extra & MOVES_EXTENSION_MASK)
            mode = MODE_INVALID;
         else
         {
            adrcat((ira->extra & REGISTER_EXTENSION_TYPE) ? "A" : "D");
            adrcat(itoasc(ira->ext_register));
         }
         break;

      case MODE_ROTATE_SHIFT:
         if (ira->seaow & IMMEDIATE_OR_REGISTER_BIT)
         {
            adrcat("D");
            adrcat(itohex(ira->alt_register, 1));
         }
         else
         {
            adrcat("#");
            equate_name = GetEquate(0, PrgCount2Adr(ira->prgCount - 1));
            if (equate_name)
               adrcat(equate_name);
            else
               adrcat(itohex(ira->rotate_shift_count, 1));
         }
         break;

      case MODE_PBcc:
         if (ira->seaow & PBcc_SIZE_BIT)
         {
            ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
            if (ira->displace != 0 && ira->displace != 2)
            {
               ira->displace += ira->prgCount * 2;
               if (P2WriteReloc())
                  return (-1);
               if (P2WriteReloc())
                  return (-1);
            }
            else
               mode = MODE_INVALID;
         }
         else
         {
            ira->displace = (ira->prgCount * 2 + (int16_t) (buf));
            if (P2WriteReloc())
               return (-1);
         }

         adr = ira->params.prgStart + ira->displace;
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1))
            mode = MODE_INVALID;
         else
            GetLabel(adr, mode);
         break;

      case MODE_FC:
      case MODE_FC_MASK:
         dummy1 = (ira->extra & PMMU_FC_MASK);
         if (dummy1 & PMMU_FC_SPEC_IMMED)
         {
            dummy1 &= PMMU_FC_SPEC_IMMED_MASK;
            /* bit 4 of FC field must be cleared if CPU is 68030 */
            if (dummy1 > 7 && (ira->params.cpuType & M68030))
               mode = MODE_INVALID;
            else
            {
               adrcat("#");
               adrcat(itoasc(dummy1));
            }
         }
         else
            if (dummy1 & PMMU_FC_SPEC_DREG)
            {
               adrcat("D");
               adrcat(itoasc(dummy1 & PMMU_FC_SPEC_DREG_MASK));
            }
            else
               /* To get SFC or DFC */
               adrcat(ControlRegisters[dummy1].name);

         if (mode == MODE_FC_MASK)
         {
            adrcat(",#");
            dummy1 = (ira->extra & ((ira->params.cpuType & M68030)?PFLUSH_MASK030_MASK:PFLUSH_MASK851_MASK)) >> 5;
            adrcat(itoasc(dummy1));
         }

         break;

      case MODE_PVALID:
         switch (ira->extra & PLOAD_or_PVALID_or_PFLUSH_MODE_MASK)
         {
            case PVALID_VAL_PSEUDO_MODE:
               adrcat("VAL");
               break;
            case PVALID_An_PSEUDO_MODE:
               adrcat("A");
               adrcat(itoasc(ira->extra & PVALID_AREG_MASK));
               break;
         }
         break;

      case MODE_PREG_TT:
         adrcat("TT");
         adrcat(((ira->extra & PMMU_PREG_MASK) == PMMU_PREG_TT0) ? "0" : "1");
         break;

      case MODE_PREG1:
         adrcat(pmmu_reg1[(ira->extra & PMMU_PREG_MASK) >> 10]);
         break;

      case MODE_PREG2:
         dummy1 = (ira->extra & PMMU_PREG_MASK);
         adrcat(pmmu_reg2[dummy1 >> 10]);
         if (dummy1 == PMMU_PREG_BAD || dummy1 == PMMU_PREG_BAC)
            adrcat(itoasc((ira->extra & PMOVE851_PREG_NUM_MASK) >> 2));
         break;

      case MODE_PTEST:
         if (DoAdress2(A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32))
            return (-1);

         /* Let's add last operands: ,#<level>[,An] */
         dummy1 = (ira->extra & PTEST_LEVEL_MASK) >> 10;
         adrcat(",#");
         adrcat(itoasc(dummy1));

         /* Register field
          * Specifies an address register for the instruction. When the A field
          * contains 0, this field must contain 0. */
         if ((ira->extra & PTEST_A_BIT_MASK))
         {
            adrcat(",A");
            adrcat(itoasc((ira->extra & PTEST_REG_MASK) >> 5));
         }
         else
            if (ira->extra & PTEST_REG_MASK)
               mode = MODE_INVALID;
         break;
   }

   if (ira->prgCount > ira->codeArea.codeAreaEnd)
      mode = MODE_INVALID;
   if (mode == MODE_INVALID)
   {
      ira->adrbuf[0] = 0;
      ira->mnebuf[0] = 0;
      ira->dtabuf[0] = 0;
      mnecat("DC.W");
      adrcat("$");
      adrcat(itohex(ira->seaow, 4));
      dtacat(itohex(ira->pc * 2 + ira->params.prgStart, ira->adrlen));
      ira->prgCount = ira->pc + 1;
      Output();
      return (-1);
   }

   return (0);
}

/* generates labels out of a relative jump-table */
static void GenJmptabLabels(uint8_t *buf, int size, int32_t base, int count)
{
   int32_t adr;

   InsertLabel((int32_t) base);
   for (; count > 0; count--, buf += size)
   {
      switch (size)
      {
         case 1:
            adr = base + *(int8_t *) buf;
            break;
         case 2:
            adr = base + (int16_t) be16(buf);
            break;
         case 4:
            adr = base + (int32_t) be32(buf);
            break;
         default:
            ExitPrg("Illegal jmp table size %d.", size);
            break;
      }
      InsertLabel(adr);
   }
}

/* 1. Pass : find out possible addresses for labels */
void DPass1(ira_t *ira)
{
   int badreloc = 0;
   uint16_t dummy;
   uint32_t i, area, end;

   ira->pass = 1;
   ira->prgCount = 0;
   ira->nextreloc = 0;
   ira->modulcnt = (uint32_t)-1;
   ira->noBase.noBaseIndex = 0;
   ira->noBase.noBaseFlag = 0;
   ira->jmp.jmpIndex = 0;

   for (area = 0; area < ira->codeArea.codeAreas; area++)
   {

      while ((ira->modulcnt + 1 < ira->hunkCount) && (ira->hunksOffs[ira->modulcnt + 1] == ira->codeArea.codeArea1[area]))
         ira->modulcnt++;

      /* HERE BEGINS THE CODE PART OF PASS 1 */
      /***************************************/

      ira->codeArea.codeAreaEnd = (ira->codeArea.codeArea2[area] - ira->params.prgStart) / 2;

      while (ira->prgCount < ira->codeArea.codeAreaEnd)
      {
         if (ira->nextreloc < ira->relocount && ira->reloc.relocAdr[ira->nextreloc] < (ira->prgCount * 2 + ira->params.prgStart))
            fprintf(stderr, "Watch out: prgcounter(%08lx) > nextreloc(%08lx)\n", (unsigned long) (ira->prgCount * 2 + ira->params.prgStart), (unsigned long) ira->reloc.relocAdr[ira->nextreloc]);

         CheckNoBase(ira->params.prgStart + ira->prgCount * 2);
         WriteLabel1(ira->params.prgStart + ira->prgCount * 2);

         if (ira->nextreloc < ira->relocount && ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
         {
            ira->nextreloc++;
            ira->prgCount += 2;
            continue;
         }
         ira->pc = ira->prgCount;
         ira->seaow = be16(&ira->buffer[ira->prgCount++]);

         GetOpCode(ira, ira->seaow);
         if (instructions[ira->opCodeNumber].flags & OPF_ONE_MORE_WORD)
         {
            ira->extra = be16(&ira->buffer[ira->prgCount]);
            ira->ext_register = (ira->extra & REGISTER_EXTENSION_MASK) >> 12;
            if (P1WriteReloc(ira))
               continue;
         }

         DoSpecific(ira, 1);

         if ((instructions[ira->opCodeNumber].flags & OPF_APPEND_SIZE) && ira->extension == 3)
            ira->addressMode = MODE_INVALID;

         if (instructions[ira->opCodeNumber].sourceadr)
            if (DoAdress1(ira, instructions[ira->opCodeNumber].sourceadr))
               continue;

         if (instructions[ira->opCodeNumber].destadr)
         {
            if (instructions[ira->opCodeNumber].family == OPC_MOVE)
            {
               ira->addressMode = ((ira->seaow & ALT_MODE_MASK) >> 3) | ira->alt_register;
               if (ira->addressMode < EA_MODE_FIELD_MASK)
                  ira->addressMode = (ira->addressMode >> 3);
               else
                  ira->addressMode = 7 + ira->alt_register;
               ira->ea_register = ira->alt_register;
            }

            if (DoAdress1(ira, instructions[ira->opCodeNumber].destadr))
               continue;
            else
               if (instructions[ira->opCodeNumber].family == OPC_LEA || instructions[ira->opCodeNumber].family == OPC_MOVEAL)
                  if (ira->params.pFlags & BASEREG1)
                     if (ira->addressMode2 == 1 && ira->alt_register == ira->params.baseReg)
                        printf("BASEREG\t%08lX: A%hd\n", (unsigned long) (ira->pc * 2 + ira->params.prgStart), ira->params.baseReg);
         }

         if (ira->prgCount > ira->codeArea.codeAreaEnd)
            fprintf(stderr, "P1 Watch out: prgCount*2(=%08lx) > (prgEnd-prgStart)(=%08lx)\n", (unsigned long) (ira->prgCount * 2), (unsigned long) (ira->params.prgEnd - ira->params.prgStart));

      }

      while ((ira->modulcnt + 1 < ira->hunkCount) && (ira->hunksOffs[ira->modulcnt + 1] == ira->codeArea.codeArea2[area]))
         ira->modulcnt++;

      /* HERE BEGINS THE DATA PART OF PASS 1 */
      /***************************************/

      if ((area + 1) < ira->codeArea.codeAreas)
         end = ira->codeArea.codeArea1[area + 1];
      else
         end = ira->params.prgEnd;

      while (ira->jmp.jmpIndex < ira->jmp.jmpCount && ira->codeArea.codeArea2[area] > ira->jmp.jmpTable[ira->jmp.jmpIndex].start)
      {
         fprintf(stderr, "P1 Watch out: ira->jmp.jmpTable $%08lx-$%08lx skipped.\n", (unsigned long) ira->jmp.jmpTable[ira->jmp.jmpIndex].start, (unsigned long) ira->jmp.jmpTable[ira->jmp.jmpIndex].end);
         ira->jmp.jmpIndex++;
      }

      for (i = ira->codeArea.codeArea2[area]; i < end; i++)
      {
         WriteLabel1(i);
         if (ira->nextreloc < ira->relocount && ira->reloc.relocAdr[ira->nextreloc] == i)
         {
            ira->nextreloc++;
            i += 3;
         }
         else
            if (ira->jmp.jmpIndex < ira->jmp.jmpCount && ira->jmp.jmpTable[ira->jmp.jmpIndex].start == i)
            {
               uint32_t len = (
                     ira->jmp.jmpTable[ira->jmp.jmpIndex].end >= end ? end : ira->jmp.jmpTable[ira->jmp.jmpIndex].end) - i;
               GenJmptabLabels((uint8_t *) ira->buffer + (i - ira->params.prgStart), ira->jmp.jmpTable[ira->jmp.jmpIndex].size, (int32_t) ira->jmp.jmpTable[ira->jmp.jmpIndex].base, len / ira->jmp.jmpTable[ira->jmp.jmpIndex].size);
               ira->jmp.jmpIndex++;
               i += len - 1;
            }
            else
               if (ira->jmp.jmpIndex < ira->jmp.jmpCount && ira->jmp.jmpTable[ira->jmp.jmpIndex].start < i)
                  ira->jmp.jmpIndex++;
      }
      ira->prgCount = (end - ira->params.prgStart) / 2;
      while (ira->nextreloc < ira->relocount && ira->reloc.relocAdr[ira->nextreloc] < (ira->prgCount * 2 + ira->params.prgStart))
      {
         if (!badreloc)
         {
            fprintf(stderr, "P1 Missed bad reloc addr $%08lx!\n", (unsigned long) ira->reloc.relocAdr[ira->nextreloc]);
            badreloc = 1;
         }
         ira->nextreloc++;
      }
   }

   fprintf(stderr, "Pass 1: 100%%\n");
   if (ira->relocount != ira->nextreloc)
      fprintf(stderr, "relocount=%lu nextreloc=%lu\n", (unsigned long) ira->relocount, (unsigned long) ira->nextreloc);
   fclose(ira->files.labelFile);
   ira->files.labelFile = 0;
}

void WriteLabel1(uint32_t adr)
{
   static uint16_t linecount = 200;
   /* emit percentage */
   if (linecount++ >= 200)
   {
      fprintf(stderr, "Pass 1: %3d%%\r", (int) (((adr - ira->params.prgStart) * 100) / ira->params.prgLen));
      fflush(stderr);
      linecount = 0;
   }

   if ((fwrite(&adr, sizeof(uint32_t), 1, ira->files.labelFile) != 1))
      ExitPrg("Write error !");
   ira->labc1++;
}

int P1WriteReloc(ira_t *ira)
{
   if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
   {
      ira->prgCount = ira->pc + 1;
      return (-1);
   }
   else
   {
      ira->prgCount++;
      return (0);
   }
}

static uint16_t NewAdrModes1(uint16_t mode, uint16_t reg)
/* AddrType :  6 --> Baseregister An */
/*            10 --> PC-relative     */
{
   uint16_t buf = be16(&ira->buffer[ira->prgCount]);
   uint16_t bdsize;
   uint16_t odsize;
   uint16_t iis;
   uint16_t is;
   uint16_t operand, square1, square2;
   int32_t adr;

   if (P1WriteReloc(ira))
      return ((uint16_t) 0xffff);

   if (ira->params.cpuType & (M68000 | M68010))
   {
      if (buf & 0x0700)
         return (MODE_INVALID);
      else
      {
         if (mode == 10)
         {
            adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int8_t) buf);
            if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
               return (MODE_INVALID);
            InsertLabel(adr);
            /*
             ira->LabAdr=adr;
             ira->LabAdrFlag=1;
             */
         }
         else
            if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
            {
               adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int8_t) buf;
               /*if (adr<(int32_t)(ira->moduloffs[ira->baseReg.baseSection]+ira->modultab[ira->baseReg.baseSection])
                && adr>=(int32_t)ira->moduloffs[ira->baseReg.baseSection]) {*/
               InsertLabel(adr);
               /*	ira->LabAdr=adr;
                ira->LabAdrFlag=1;
                }*/
            }
      }
   }
   else
   {
      if (buf & 0x0100)
      { /* MC68020 (& up) FULL FORMAT */
         bdsize = (buf & 0x0030) >> 4;
         odsize = (buf & 0x0003);
         iis = (buf & 0x0007);
         is = (buf & 0x0040) >> 6;
         operand = square1 = square2 = 0;

         if (mode == 10)
            reg = 0;
         if (buf & 8)
            return (MODE_INVALID);
         if (bdsize == 0)
            return (MODE_INVALID);
         if (is == 0 && iis == 4)
            return (MODE_INVALID);
         if (is == 1 && iis >= 4)
            return (MODE_INVALID);
         /*
          if (is==1 && (buf&0xfe00)) return(NOADRMODE);
          if (buf&0x0080 && reg!=0)  return(NOADRMODE);
          */
         if (bdsize > 1)
         {
            operand |= 1;
            square1 |= 1;
         }
         if (!(buf & 0x0080))
         {
            operand |= 2;
            square1 |= 2;
         }
         if ((buf & 0x0080) && mode == 10)
         {
            operand |= 2;
            square1 |= 2;
         }
         if (is == 0 || (buf & 0xF000))
         {
            operand |= 4;
            if (iis < 4)
               square1 |= 4;
         }
         if (odsize > 1)
            operand |= 8;
         if (iis != 0)
            square2 = square1;
         else
            square1 = 0;
         operand &= ~square1;

         if ((square1 | operand) & 1)
         {
            if (bdsize == 2)
            {
               if (mode == 10 && !(buf & 0x0080))
               {
                  adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int16_t) be16(&ira->buffer[ira->prgCount]));
                  if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
                     return (MODE_INVALID);
#else
                     goto mode10W;
#endif
                  if (P1WriteReloc(ira))
                     return ((uint16_t) 0xffff);
                  InsertLabel(adr);
               }
               else
               {
                  mode10W:
                  if (P1WriteReloc(ira))
                     return ((uint16_t) 0xffff);
               }
            }
            if (bdsize == 3)
            {
               if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
               {
                  ira->nextreloc++;
                  ira->prgCount += 2;
               }
               else
               {
                  ira->prgCount++;
                  if (mode == 10 && !(buf & 0x0080))
                  {
                     adr = ((ira->prgCount - 2) * 2 + ira->params.prgStart + (be16(&ira->buffer[ira->prgCount - 1]) << 16) + be16(&ira->buffer[ira->prgCount]));
                     if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
                        return (MODE_INVALID);
#else
                        goto mode10L;
#endif
                     if (P1WriteReloc(ira))
                        return ((uint16_t) 0xffff);
                     InsertLabel(adr);
                  }
                  else
                  {
                     mode10L:
                     if (P1WriteReloc(ira))
                        return ((uint16_t) 0xffff);
                  }
               }
            }
            /*
             square1&=~1;
             operand&=~1;
             if (square2 && !square1) {square2=0;}
             */
         }
         /*
          if ((square1|operand)&2) {
          square1&=~2;
          operand&=~2;
          if (square2 && !square1) {square2=0;}
          }
          if ((square1|operand)&4) {
          square1&=~4;
          operand&=~4;
          if (square2 && !square1) {square2=0;}
          }
          */
         if (operand & 8)
         {
            if (odsize == 2)
            {
               if (P1WriteReloc(ira))
                  return ((uint16_t) 0xffff);
            }
            if (odsize == 3)
            {
               if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
               {
                  ira->nextreloc++;
                  ira->prgCount += 2;
               }
               else
               {
                  ira->prgCount++;
                  if (P1WriteReloc(ira))
                     return ((uint16_t) 0xffff);
               }
            }
         }
      }
      else
      { /* MC68020 (& up) BRIEF FORMAT */
         if (mode == 10)
         {
            adr = ((ira->prgCount - 1) * 2 + ira->params.prgStart + (int8_t) buf);
            if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR)))
#if PCLABELSONLY
               return (MODE_INVALID);
#else
               return (mode);
#endif
            InsertLabel(adr);
            /*
             ira->LabAdr=adr;
             ira->LabAdrFlag=1;
             */
         }
         else
            if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
            {
               adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int8_t) buf;
               /*if (adr<(int32_t)(ira->moduloffs[ira->baseReg.baseSection]+ira->modultab[ira->baseReg.baseSection])
                && adr>=(int32_t)ira->moduloffs[ira->baseReg.baseSection]) {*/
               InsertLabel(adr);
               /*	ira->LabAdr=adr;
                ira->LabAdrFlag=1;
                }*/
            }
      }
   }
   return (mode);
}

/* This is for PASS 1 */
int DoAdress1(ira_t *ira, uint16_t adrs)
{
   uint16_t mode = ira->addressMode;
   uint16_t dummy1;
   uint16_t buf = be16(&ira->buffer[ira->prgCount]);
   uint16_t reg, creg;
   int32_t adr;

   if (mode != MODE_INVALID)
   {
      if (adrs & MODE_ALT_REGISTER)
         reg = ira->alt_register;
      else
         if (adrs & MODE_EXT_REGISTER)
            reg = ira->ext_register;
         else
            reg = ira->ea_register;

      if (adrs & MODE_IN_LOWER_BYTE)
         ira->addressMode2 = mode = adrs & MODE_IN_LOWER_BYTE_MASK;
      else
         if ((adrs & 0x0fff) == adrs)
            if (!(adrs & (0x0800 >> mode)))
               ira->addressMode2 = mode = MODE_INVALID;
   }

   /* process addressing mode */
   switch (mode)
   {
      case MODE_AREG_DIRECT:
         /* Byte access on address register is not possible */
         /* ira->extension is 0 for LEA (because odd addresses are allowed) */
         if (ira->extension || instructions[ira->opCodeNumber].family == OPC_LEA)
         {
         }
         else
            mode = MODE_INVALID;
         break;

      case MODE_AREG_INDIRECT_D16:
         if (P1WriteReloc(ira))
            return (-1);
         if ((ira->params.pFlags & BASEREG2) && !ira->noBase.noBaseFlag && reg == ira->params.baseReg)
         {
            adr = (int32_t) ira->baseReg.baseAddress + ira->baseReg.baseOffset + (int16_t) buf;
            if (1/*adr<(int32_t)(ira->moduloffs[ira->baseReg.baseSection]+ira->modultab[ira->baseReg.baseSection])
             && adr>=(int32_t)ira->moduloffs[ira->baseReg.baseSection]*/)
            {
               InsertLabel(adr);
               ira->LabAdr = adr;
               ira->LabAdrFlag = 1;
            }
         }
         break;

      case MODE_AREG_INDIRECT_INDEX:
      case MODE_PC_INDIRECT_INDEX:
         if ((mode = NewAdrModes1(mode, reg)) == (uint16_t) 0xffff)
            return (-1);
         break;

      case MODE_ABSOLUTE_16:
         adr = (uint32_t) ((int16_t) buf);
         /* Reject odd address */
         if ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR || instructions[ira->opCodeNumber].family == OPC_ROTATE_SHIFT_MEMORY))
            mode = MODE_INVALID;
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
            /* PEA for stack arguments in C code */
            if (instructions[ira->opCodeNumber].family != OPC_PEA && (ira->params.sourceType != M68K_BINARY || !NoPtrsArea(ira->prgCount * 2 + ira->params.prgStart)))
            {
               if (ira->params.sourceType == M68K_BINARY && (adr >= ira->params.prgStart && adr <= ira->params.prgEnd))
               {
                  InsertLabel(adr);
                  ira->LabAdr = adr;
                  ira->LabAdrFlag = 1;
               }
               else
                  InsertXref(adr);
            }
         }
         break;

      case MODE_ABSOLUTE_32:
         adr = (uint32_t) ((buf << 16) + be16(&ira->buffer[ira->prgCount + 1]));
         /* Reject odd address */
         if ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR || instructions[ira->opCodeNumber].family == OPC_ROTATE_SHIFT_MEMORY))
            mode = MODE_INVALID;
         else
         {
            if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart + 2))
               mode = MODE_INVALID;
            else if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
            {
               ira->LabAdr = adr;
               ira->LabAdrFlag = 1;
               ira->nextreloc++;
            }
            else
            {

               /* PEA for stack arguments in C code */
               if (instructions[ira->opCodeNumber].family != OPC_PEA && (ira->params.sourceType != M68K_BINARY || !NoPtrsArea(ira->prgCount * 2 + ira->params.prgStart)))
               {
                  if (ira->params.sourceType == M68K_BINARY && (adr >= ira->params.prgStart && adr <= ira->params.prgEnd))
                  {
                     InsertLabel(adr);
                     ira->LabAdr = adr;
                     ira->LabAdrFlag = 1;
                  }
                  else
                     InsertXref(adr);
               }
            }
            ira->prgCount += 2;
         }
         break;

      case MODE_PC_RELATIVE:
         adr = (ira->prgCount * 2 + ira->params.prgStart + (int16_t) buf);
         if (adr >= (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]) || adr < (int32_t) (ira->hunksOffs[ira->modulcnt] - 8) || ((adr & 1) && (ira->extension || instructions[ira->opCodeNumber].family == OPC_JMP || instructions[ira->opCodeNumber].family == OPC_JSR))) {
#if PCLABELSONLY
            mode = MODE_INVALID;
#else
            if (P1WriteReloc(ira))
               return (-1);
#endif
         }
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
            InsertLabel(adr);
            ira->LabAdr = adr;
            ira->LabAdrFlag = 1;
         }
         break;

      case MODE_IMMEDIATE:
         if (adrs == instructions[ira->opCodeNumber].sourceadr || instructions[ira->opCodeNumber].family == OPC_BITOP)
         {
            if (ira->extension != 3)
            {
               if (ira->extension == 0)
               {
                  /* immediate data can have MSB different from 0 only if MSB is 0xff and LSB has most significant bit set.
                   * it means that immediate's MSB is only allowed to be LSB sign extended. */
                  if ((buf & 0xff00) != 0 && (buf & 0xff80) != 0xff80)
                     mode = MODE_INVALID;
                  else
                     /* BUT !
                      * that sign extension over MSB is only allowed with COMPAT flag 'i' */
                     if ((buf & 0xff80) == 0xff80 && !ira->params.immedByte)
                        mode = MODE_INVALID;
                     else
                        if (P1WriteReloc(ira))
                           return (-1);
               }
               else
                  if (ira->extension == 1)
                  {
                     if (P1WriteReloc(ira))
                        return (-1);
                  }
                  else
                     if (ira->extension == 2)
                     {
                        if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart + 2))
                           mode = MODE_INVALID;
                        else
                        {
                           if (ira->reloc.relocAdr[ira->nextreloc] == (ira->prgCount * 2 + ira->params.prgStart))
                           {
                              ira->nextreloc++;
                           }
                           ira->prgCount += 2;
                        }
                     }
            }
            else
               mode = MODE_INVALID;
         }
         else
            /* <ea> #data (aka IMMEDIATE) for destination operand has a special meaning (except for BTST)
             * for EORI, ANDI and ORI, it means CCR or SR, according to SEAOW extension size bits (7 & 6)
             * .B for CCR and .W for SR (.L is invalid) */
            if (ira->extension == 2)
               mode = MODE_INVALID; /* d=immediate long */
         break;

      case MODE_DBcc:
      case MODE_PDBcc:
         adr = (ira->prgCount * 2 + ira->params.prgStart + (int16_t) buf);
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1) || !buf)
            mode = MODE_INVALID;
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
            InsertLabel(adr);
            ira->LabAdr = adr;
            ira->LabAdrFlag = 1;
         }
         break;

      case MODE_Bcc:
         if ((ira->seaow & 0x00ff) == 0x00ff)
         {
            if (ira->params.cpuType & M020UP)
            {
               ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
               if (ira->displace != 0 && ira->displace != 2)
               {
                  ira->displace += ira->prgCount * 2;
                  if (P1WriteReloc(ira))
                     return (-1);
                  if (P1WriteReloc(ira))
                     return (-1);
               }
               else
                  mode = MODE_INVALID;
            }
            else
               mode = MODE_INVALID;
         }
         else
            if ((ira->seaow & 0x00ff) == 0x0000)
            {
               if (buf)
               {
                  ira->displace = (ira->prgCount * 2 + (int16_t) (buf));
                  if (P1WriteReloc(ira))
                     return (-1);
               }
               else
                  mode = MODE_INVALID;
            }
            else
            {
               ira->displace = (ira->prgCount * 2 + (int8_t) (ira->seaow & 0x00ff));
            }
         adr = ira->params.prgStart + ira->displace;
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1))
            mode = MODE_INVALID;
         else
         {
            InsertLabel(adr);
            ira->LabAdr = adr;
            ira->LabAdrFlag = 1;
         }
         break;

      case MODE_SP_DISPLACE_W:
         if (buf & 1)
            mode = MODE_INVALID;
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
         }
         break;

      case MODE_BIT_MANIPULATION:
         if (!ira->extension)
            instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED; /* BTST */
         else
            instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32; /* sonstige B... */

         if (!ira->extension) /* BTST */
            if (ira->seaow & 0x0100)
               instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND|IMMED;
            else
               instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND;
         else
            /* BCHG, BCLR, BSET */
            instructions[ira->opCodeNumber].destadr = D_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
         if (ira->seaow & 0x0100)
         {
         }
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
            if (ira->seaow & 0x0038)
            {
               if (buf & (ira->params.bitRange ? 0xFFF0 : 0xFFF8))
                  mode = MODE_INVALID;
            }
            else
            {
               if (buf & 0xFFE0)
                  mode = MODE_INVALID;
            }
         }
         ira->extension = 0; /* Set extension to BYTE (undefined before) */
         break;

      case MODE_BITFIELD:
         /* specific behaviour according to bitfield's identifier */
         switch ((ira->seaow & BITFIELD_IDENTIFIER_MASK) >> 8)
         {
            case BITFIELD_IDENTIFIER_CHG:
            case BITFIELD_IDENTIFIER_CLR:
            case BITFIELD_IDENTIFIER_SET:
            case BITFIELD_IDENTIFIER_INS:
               if (DoAdress1(ira, D_DIR|A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32))
                  return (-1);
               break;

            case BITFIELD_IDENTIFIER_EXTS:
            case BITFIELD_IDENTIFIER_EXTU:
            case BITFIELD_IDENTIFIER_FFO:
            case BITFIELD_IDENTIFIER_TST:
               if (DoAdress1(ira, D_DIR|A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32|PC_REL|PC_IND))
                  return (-1);
               break;
         }

         reg = (ira->extra & 0x07c0) >> 6;
         if (ira->extra & 0x0800)
         {
            if (reg > 7)
               mode = MODE_INVALID;
         }
         reg = (ira->extra & 0x001F);
         if (ira->extra & BITFIELD_DATA_WIDTH_BIT)
         {
            if (reg > 7)
               mode = MODE_INVALID;
         }
         break;

      case MODE_CAS2:
         buf = be16(&ira->buffer[ira->prgCount]);
         if (P1WriteReloc(ira))
            return (-1);
         ira->extension = (ira->seaow & ALT_EXTENSION_SIZE_MASK) >> 9;
         if (ira->extension == 0 || ira->extension == 1)
            mode = MODE_INVALID;
         else
            --ira->extension;
         if ((buf & 0x0e38) || (ira->extra & 0x0e38))
            mode = MODE_INVALID;
         break;

      case MODE_CAS:
         ira->extension = (ira->seaow & ALT_EXTENSION_SIZE_MASK) >> 9;
         if (ira->extension == 0)
            mode = MODE_INVALID;
         else
            --ira->extension;
         if (ira->extra & CAS_EXTENSION_MASK)
            mode = MODE_INVALID;
         break;

      case MODE_MUL_DIV_LONG:
         if (ira->extra & 0x83f8)
            mode = MODE_INVALID;
         break;

      case MODE_SP_DISPLACE_L:
         ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
         if (ira->displace & 1)
            mode = MODE_INVALID;
         else
         {
            if (P1WriteReloc(ira))
               return (-1);
            if (P1WriteReloc(ira))
               return (-1);
         }
         break;

      case MODE_MOVEC:
         if (P1WriteReloc(ira))
            return (-1);
         reg = (buf & REGISTER_EXTENSION_MASK) >> 12;
         creg = buf & MOVEC_CONTROL_REGISTER_MASK;
         if (creg & ILLEGAL_CONTROL_REGISTER)
            mode = MODE_INVALID;
         else
         {
            if (creg & MOVEC_CR_HIGHER_RANGE_BIT)
               creg = (creg & ~MOVEC_CR_HIGHER_RANGE_BIT) + 9;
            if (ira->params.cpuType & ControlRegisters[creg].cpuflag)
            {
            }
            else
               mode = MODE_INVALID;
         }
         break;

      case MODE_MOVES:
         if (ira->extra & MOVES_EXTENSION_MASK)
            mode = MODE_INVALID;
         break;

      case MODE_PBcc:
         if (ira->seaow & PBcc_SIZE_BIT)
         {
            ira->displace = (buf << 16) | be16(&ira->buffer[ira->prgCount + 1]);
            if (ira->displace != 0 && ira->displace != 2)
            {
               ira->displace += ira->prgCount * 2;
               if (P2WriteReloc())
                  return (-1);
               if (P2WriteReloc())
                  return (-1);
            }
            else
               mode = MODE_INVALID;
         }
         else
         {
            ira->displace = (ira->prgCount * 2 + (int16_t) (buf));
            if (P2WriteReloc())
               return (-1);
         }

         adr = ira->params.prgStart + ira->displace;
         if (adr > (int32_t) (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt] - 2) || adr < (int32_t) ira->hunksOffs[ira->modulcnt] || (adr & 1))
            mode = MODE_INVALID;
         else
         {
            InsertLabel(adr);
            ira->LabAdr = adr;
            ira->LabAdrFlag = 1;
         }
         break;

      case MODE_FC:
      case MODE_FC_MASK:
         dummy1 = (ira->extra & PMMU_FC_MASK);
         if (dummy1 & PMMU_FC_SPEC_IMMED)
         {
            dummy1 &= PMMU_FC_SPEC_IMMED_MASK;
            /* bit 4 of FC field must be cleared if CPU is 68030 */
            if (dummy1 > 7 && (ira->params.cpuType & M68030))
               mode = MODE_INVALID;
         }

         break;

      case MODE_PVALID:
         break;

      case MODE_PREG1:
         break;

      case MODE_PREG2:
         break;

      case MODE_PTEST:
         if (DoAdress1(ira, A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32))
            return (-1);

        dummy1 = (ira->extra & PTEST_LEVEL_MASK) >> 10;

        /* Register field
          * Specifies an address register for the instruction. When the A field
          * contains 0, this field must contain 0. */
         if (((ira->extra & PTEST_A_BIT_MASK) == 0) && (ira->extra & PTEST_REG_MASK))
            mode = MODE_INVALID;
         break;
   }

   if (ira->prgCount > ira->codeArea.codeAreaEnd)
      mode = MODE_INVALID;
   if (mode == MODE_INVALID)
   {
      ira->prgCount = ira->pc + 1;
      return (-1);
   }
   return (0);
}

int AutoScan(ira_t *ira)
{
   uint32_t magic;
   int result;

   /* Note: When calling Autoscan(), sourceFile is already opened. */

   /* Read "magic" at the beginning of source file */
   magic = readbe32(ira->files.sourceFile);

   switch (magic)
   {
      case HUNK_HEADER:
         result = AMIGA_HUNK_EXECUTABLE;
         break;
      case HUNK_UNIT:
         result = AMIGA_HUNK_OBJECT;
         break;
      case ELF_MAGIC:
         result = ELF_EXECUTABLE;
         break;
      default:
         /* No 32 bits magic recognized, let's try 16 bits magic (i.e Atari) */
         magic >>= 16;
         switch (magic)
         {
            case ATARI_MAGIC:
               result = ATARI_EXECUTABLE;
               break;
            default:
               /* Hello coder from the future (Nicolas Bastien talking) :-)
                * If you want to check for 8 bits magic, do it right here and don't forget M68K_BINARY by default */

               /* No known magic, it must be a binary file */
               result = M68K_BINARY;
               break;
         }
         break;
   }

   if (ira->params.pFlags & SHOW_RELOCINFO)
      printf("\n%s (%s)....:\n", SOURCE_FILE_DESCR(result), ira->filenames.sourceName);

   return result;
}

void SplitOutputFiles(Files_t *files, Filenames_t *filenames, uint32_t count)
{
   if (files->targetFile)
      fclose(files->targetFile);

   strcpy(filenames->tsName, filenames->targetName);
   strcat(filenames->tsName, ".S");
   strcat(filenames->tsName, itoasc(count));
   if (!(files->targetFile = fopen(filenames->tsName, "w")))
      ExitPrg("Can't open split target file \"%s\" for writing.", filenames->tsName);
}

void WriteSection(ira_t *ira)
{
   int section_start_label;

   if ((ira->hunksSize[ira->modulcnt] != 0) || (ira->params.pFlags & KEEP_ZEROHUNKS))
   {
      fprintf(ira->files.targetFile, "\n\n\t");
      if (ira->params.sourceType == M68K_BINARY && ira->modulcnt == 0)
         fprintf(ira->files.targetFile, "ORG\t$%lx", (unsigned long) ira->params.prgStart);
      else
      {
         fprintf(ira->files.targetFile, "SECTION S_%ld,%s", (long) ira->modulcnt, modname[ira->hunksType[ira->modulcnt] - HUNK_CODE]);
         if (ira->hunksMemoryType[ira->modulcnt] == 3)
            fprintf(ira->files.targetFile, ",$%lx", (unsigned long) ira->hunksMemoryAttrs[ira->modulcnt]);
         else
            if (ira->hunksMemoryType[ira->modulcnt])
               fprintf(ira->files.targetFile, ",%s", memtypename[ira->hunksMemoryType[ira->modulcnt]]);
      }
      fprintf(ira->files.targetFile, "\n\n");

      section_start_label = 1;

      while (ira->LabelAdr2[ira->p2labind] == ira->hunksOffs[ira->modulcnt]
             && ira->p2labind < ira->labcount)
      {
         if (GetSymbol(ira->label.labelAdr[ira->p2labind]))
         {
            /* Do not attempt to use a symbol when this section size or the
               previous section's size is zero! */
            if (ira->hunksSize[ira->modulcnt] != 0 &&
                (!(ira->params.pFlags & KEEP_ZEROHUNKS) ||
                 ira->modulcnt == 0 || ira->hunksSize[ira->modulcnt-1] != 0)) {
               fprintf(ira->files.targetFile, "%s:\n", ira->adrbuf);
               ira->adrbuf[0] = 0;
               section_start_label = 0;
            }
         }
         ira->p2labind++;
      }

      if (section_start_label)
         fprintf(ira->files.targetFile, "%s:\n", SecstrtLabel(ira->modulcnt));
   }
}

void DoSpecific(ira_t *ira, int pass_number)
{
   uint16_t dummy;

   switch (instructions[ira->opCodeNumber].family)
   {
      case OPC_CMPI:
         if (ira->params.cpuType & M020UP)
            instructions[ira->opCodeNumber].destadr |= PC_REL|PC_IND;
         break;

      case OPC_TST:
         if (ira->params.cpuType & M020UP)
            instructions[ira->opCodeNumber].sourceadr |= A_DIR|PC_REL|PC_IND|IMMED;
         break;

      case OPC_BITFIELD:
         /* if no Dn is expected, ext register must be cleared */
         if ((!(((ira->seaow & 0x0700) >> 8) & 1)) && (ira->extra & 0xf000))
            ira->addressMode = MODE_INVALID;
         else
         {
            /* get bitfield's identifier */
            dummy = (ira->seaow & BITFIELD_IDENTIFIER_MASK) >> 8;
            if (pass_number == 2)
               mnecat(bitfield[dummy]);

            /* specific behaviour according to bitfield's identifier */
            switch (dummy)
            {
               case BITFIELD_IDENTIFIER_CHG:
               case BITFIELD_IDENTIFIER_CLR:
               case BITFIELD_IDENTIFIER_SET:
               case BITFIELD_IDENTIFIER_TST:
                  instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE|MODE_BITFIELD;
                  instructions[ira->opCodeNumber].destadr = MODE_NONE;
                  break;

               case BITFIELD_IDENTIFIER_INS:
                  instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE|MODE_EXT_REGISTER|MODE_DREG_DIRECT;
                  instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE|MODE_BITFIELD;
                  break;

               case BITFIELD_IDENTIFIER_EXTS:
               case BITFIELD_IDENTIFIER_EXTU:
               case BITFIELD_IDENTIFIER_FFO:
                  instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE|MODE_BITFIELD;
                  instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE|MODE_EXT_REGISTER|MODE_DREG_DIRECT;
                  break;
            }
         }
         break;

      case OPC_C2:
         if (ira->extra & 0x07ff)
            ira->addressMode = MODE_INVALID;
         else
         {
            if (pass_number == 2)
            {
               if (ira->extra & 0x0800)
                  mnecat("HK2");
               else
                  mnecat("MP2");
            }
            instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_EXT_REGISTER | ((ira->extra & REGISTER_EXTENSION_TYPE) ? MODE_AREG_DIRECT : MODE_DREG_DIRECT);
         }
         ira->extension = (ira->seaow & ALT_EXTENSION_SIZE_MASK) >> 9;
         break;

      case OPC_MOVES:
         if (ira->extra & DIRECTION_EXTENSION_MASK)
         {
            instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_MOVES;
            instructions[ira->opCodeNumber].destadr = A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
         }
         else
         {
            instructions[ira->opCodeNumber].sourceadr = A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
            instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_MOVES;
         }
         break;

      case OPC_PMMU:
         switch (ira->extra & PMMU_MASK)
         {
            case PMMU_PMOVE_030_TT:
               if (ira->params.cpuType & M68030)
                  if ((ira->extra & PMOVE030_TT_EXTENSION_MASK) == PMOVE030_TT_EXTENSION)
                  {
                     if (pass_number == 2)
                        mnecat("MOVE");

                     /* P-Register field-Specifies the transparent translation register.
                      * 010 - Transparent Translation Register 0
                      * 011 - Transparent Translation Register 1 */
                     dummy = (ira->extra & PMMU_PREG_MASK);
                     if (dummy == PMMU_PREG_TT0 || dummy == PMMU_PREG_TT1)
                     {
                        if (ira->extra & PMMU_RW_BIT_MASK)
                        {
                           /* register to memory */

                           /* PMOVEFD only from memory to register */
                           if (ira->extra & PMMU_FD_BIT_MASK)
                              ira->addressMode = MODE_INVALID;
                           else
                           {
                              instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PREG_TT;
                              instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                           }
                        }
                        else
                        {
                           /* memory to register */

                           /* PMOVEFD mode */
                           if (pass_number == 2 && (ira->extra & PMMU_FD_BIT_MASK))
                              mnecat("FD");

                           instructions[ira->opCodeNumber].sourceadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                           instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PREG_TT;
                        }
                     }
                     else
                        /* Invalid MMU register */
                        ira->addressMode = MODE_INVALID;
                  }
                  else
                     /* Invalid extension word */
                     ira->addressMode = MODE_INVALID;
               else
                  /* Invalid CPU type */
                  ira->addressMode = MODE_INVALID;
               break;

            case PMMU_PLOAD_or_PVALID_or_PFLUSH:
               dummy = (ira->extra & PLOAD_or_PVALID_or_PFLUSH_MODE_MASK);

               switch (dummy)
               {
                  case PLOAD_PSEUDO_MODE:
                     if ((ira->extra & PLOAD_EXTENSION_MASK) == PLOAD_EXTENSION)
                     {
                        if (pass_number == 2)
                        {
                           mnecat("LOAD");
                           mnecat((ira->extra & PMMU_RW_BIT_MASK)?"R":"W");
                        }
                        instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC;
                        instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                     }
                     else
                        ira->addressMode = MODE_INVALID;
                     break;

                  case PVALID_VAL_PSEUDO_MODE:
                  case PVALID_An_PSEUDO_MODE:
                     if (ira->params.cpuType & M68851)
                     {
                        if (pass_number == 2)
                           mnecat("VALID");
                        instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PVALID;
                        instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                     }
                     else
                        ira->addressMode = MODE_INVALID;
                     break;

                  case PFLUSH_MODE_ALL:
                  case PFLUSH_MODE_FC_ONLY:
                  case PFLUSH_MODE_FC_SHARE:
                  case PFLUSH_MODE_FC_EA:
                  case PFLUSH_MODE_FC_EA_SHARE:
                     /* Static part of extension word has, at least, to match expected value.
                      * note: 68851 and 68030 have not the same value to be matched.
                      * note: PFLUSH(A/S) and PFLUSHR have not, too. */
                     if ((ira->extra & ((ira->params.cpuType & M68030)?PFLUSH030_EXTENSION_MASK:PFLUSH851_EXTENSION_MASK)) == PFLUSH_EXTENSION)
                        switch (dummy)
                        {
                           case PFLUSH_MODE_ALL:
                              /* 68030: When mode is 001, mask must be 000 and FC field must be 00000.
                               * 68851: If mode = 001 (flush all entries), mask must be 0000 and function code must be 00000 */
                              if ((ira->extra & ((ira->params.cpuType & M68030)?PFLUSH_MASK030_MASK:PFLUSH_MASK851_MASK | PMMU_FC_MASK)) != PFLUSH_EXPECTED_FOR_MODE_ALL)
                                 ira->addressMode = MODE_INVALID;
                              else
                              {
                                 instructions[ira->opCodeNumber].sourceadr = MODE_NONE;
                                 instructions[ira->opCodeNumber].destadr = MODE_NONE;
                                 if (pass_number == 2)
                                    mnecat("FLUSHA");
                              }
                              break;

                           case PFLUSH_MODE_FC_ONLY:
                              instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC_MASK;
                              instructions[ira->opCodeNumber].destadr = MODE_NONE;
                              if (pass_number == 2)
                                 mnecat("FLUSH");
                              break;

                           case PFLUSH_MODE_FC_SHARE:
                              if (ira->params.cpuType & M68851)
                              {
                                 instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC_MASK;
                                 instructions[ira->opCodeNumber].destadr = MODE_NONE;
                                 if (pass_number == 2)
                                    mnecat("FLUSHS");
                              }
                              else
                                 ira->addressMode = MODE_INVALID;
                              break;

                           case PFLUSH_MODE_FC_EA:
                              instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC_MASK;
                              instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                              if (pass_number == 2)
                                 mnecat("FLUSH");
                              break;

                           case PFLUSH_MODE_FC_EA_SHARE:
                              if (ira->params.cpuType & M68851)
                              {
                                 instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC_MASK;
                                 instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                                 if (pass_number == 2)
                                    mnecat("FLUSHS");
                              }
                              else
                                 ira->addressMode = MODE_INVALID;
                              break;
                        }
                     else
                        ira->addressMode = MODE_INVALID;
                     break;
               }
               break;

            case PMMU_PMOVE_851_or_030_format1:
               /* PMOVE 68851 */
               if (ira->params.cpuType & M68851)
                  if ((ira->extra & PMOVE851_format1_EXTENSION_MASK) == PMOVE851_format1_EXTENSION)
                  {
                     if (pass_number == 2)
                        mnecat("MOVE");

                     if (ira->extra & PMMU_RW_BIT_MASK)
                     {
                        /* register to memory */
                        instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PREG1;

                        /* PMOVE from CRP, SRP, DRP not allowed with modes Dn and An */
                        dummy = (ira->extra & PMMU_PREG_MASK);
                        if (dummy == PMMU_PREG_CRP || dummy == PMMU_PREG_SRP || dummy == PMMU_PREG_DRP)
                           instructions[ira->opCodeNumber].destadr = A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                        else
                           instructions[ira->opCodeNumber].destadr = D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                     }
                     else
                     {
                        /* memory to register */

                        /* PMOVE to CRP, SRP, DRP not allowed with modes Dn and An */
                        dummy = (ira->extra & PMMU_PREG_MASK);
                        if (dummy == PMMU_PREG_CRP || dummy == PMMU_PREG_SRP || dummy == PMMU_PREG_DRP)
                           instructions[ira->opCodeNumber].sourceadr = A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED|PC_REL|PC_IND;
                        else
                           instructions[ira->opCodeNumber].sourceadr = D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED|PC_REL|PC_IND;

                        instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PREG1;
                     }
                  }
                  else
                     /* Extra word invalid */
                     ira->addressMode = MODE_INVALID;
               else
                  /* PMOVE 030 */
                  if (ira->params.cpuType & M68030)
                     if ((ira->extra & PMOVE030_format1_EXTENSION_MASK) == PMOVE030_format1_EXTENSION)
                     {
                        if (pass_number == 2)
                           mnecat("MOVE");

                        /* Register field - Specifies the MC68030 register.
                         * 000 - Translation Control Register
                         * 010 - Supervisor Root Pointer
                         * 011 - CPU Root Pointer */
                        dummy = (ira->extra & PMMU_PREG_MASK);
                        if (dummy == PMMU_PREG_TC || dummy == PMMU_PREG_SRP || dummy == PMMU_PREG_CRP)
                        {
                           if (ira->extra & PMMU_RW_BIT_MASK)
                           {
                              /* register to memory */

                              /* PMOVEFD only from memory to register */
                              if (ira->extra & PMMU_FD_BIT_MASK)
                                 ira->addressMode = MODE_INVALID;
                              else
                              {
                                 instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PREG1;
                                 instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                              }
                           }
                           else
                           {
                              /* memory to register */

                              /* PMOVEFD mode */
                              if (pass_number == 2 && (ira->extra & PMMU_FD_BIT_MASK))
                                 mnecat("FD");

                              instructions[ira->opCodeNumber].sourceadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                              instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PREG1;
                           }
                        }
                        else
                           /* Invalid MMU register */
                           ira->addressMode = MODE_INVALID;
                     }
                     else
                        /* Invalid extension word */
                        ira->addressMode = MODE_INVALID;
                  else
                     /* Invalid CPU type */
                     ira->addressMode = MODE_INVALID;
               break;

            case PMMU_PMOVE_851_or_030_format2:
               /* PMOVE 68851 */
               if (ira->params.cpuType & M68851)
                  if ((ira->extra & PMOVE851_format2_EXTENSION_MASK) == PMOVE851_format2_EXTENSION)
                  {
                     if (pass_number == 2)
                        mnecat("MOVE");

                     /* P-Register field - Specifies the type of MC68851 register.
                      * 000 - PMMU Status Register
                      * 001 - PMMU Cache Status Register
                      * 100 - Breakpoint Acknowledge Data
                      * 101 - Breakpoint Acknowledge Control */
                     dummy = (ira->extra & PMMU_PREG_MASK);
                     if (dummy == PMMU_PREG_PSR || dummy == PMMU_PREG_PCSR || dummy == PMMU_PREG_BAD || dummy == PMMU_PREG_BAC)
                     {
                        if ((dummy == PMMU_PREG_PSR || dummy == PMMU_PREG_PCSR) && ((ira->extra & PMOVE851_PREG_NUM_MASK) != 0))
                           /* Invalid P-Register number (must be 0 for PSR and PCSR) */
                           ira->addressMode= MODE_INVALID;
                        else
                           if (ira->extra & PMMU_RW_BIT_MASK)
                           {
                              /* register to memory */
                              instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PREG2;
                              instructions[ira->opCodeNumber].destadr = D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                           }
                           else
                           {
                              /* memory to register */


                              /* PMOVE from PCSR only */
                              if (dummy == PMMU_PREG_PCSR)
                                 ira->addressMode = MODE_INVALID;
                              else
                              {
                                 instructions[ira->opCodeNumber].sourceadr = D_DIR|A_DIR|A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED|PC_REL|PC_IND;
                                 instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PREG2;
                              }
                           }
                     }
                     else
                        /* Invalid MMU register */
                        ira->addressMode = MODE_INVALID;
                  }
                  else
                     /* Extra word invalid */
                     ira->addressMode = MODE_INVALID;
               else
                  /* PMOVE 030 */
                  if (ira->params.cpuType & M68030)
                     if ((ira->extra & PMOVE030_format2_EXTENSION_MASK) == PMOVE030_format2_EXTENSION)
                     {
                        if (pass_number == 2)
                           mnecat("MOVE");

                        /* Register field - Specifies the MC68030 register.
                         * 000 - MMU Status Register / PSR */
                        if ((ira->extra & PMMU_PREG_MASK) == PMMU_PREG_PSR)
                        {
                           if (ira->extra & PMMU_RW_BIT_MASK)
                           {
                              /* register to memory */

                              instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_PREG2;
                              instructions[ira->opCodeNumber].destadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                           }
                           else
                           {
                              /* memory to register */

                              instructions[ira->opCodeNumber].sourceadr = A_IND|A_IND_D16|A_IND_IDX|ABS16|ABS32;
                              instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PREG2;
                           }
                        }
                        else
                           /* Invalid MMU register */
                           ira->addressMode = MODE_INVALID;
                     }
                     else
                        /* Invalid extension word */
                        ira->addressMode = MODE_INVALID;
                  else
                     /* Invalid CPU type */
                     ira->addressMode = MODE_INVALID;
               break;

            case PMMU_PTEST:
               if ((ira->extra & PTEST_EXTENSION_MASK) == PTEST_EXTENSION)
               {
                  if (pass_number == 2)
                  {
                     mnecat("TEST");
                     mnecat((ira->extra & PMMU_RW_BIT_MASK)?"R":"W");
                  }

                  instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_FC;
                  instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_PTEST;
               }
               else
                  /* Invalid extension word */
                  ira->addressMode = MODE_INVALID;
               break;

            case PMMU_PFLUSHR:
               if (ira->extra == PFLUSHR_EXTENSION)
               {
                  instructions[ira->opCodeNumber].sourceadr = MODE_NONE;
                  instructions[ira->opCodeNumber].destadr = A_IND|A_IND_POST|A_IND_PRE|A_IND_D16|A_IND_IDX|ABS16|ABS32|IMMED|PC_REL|PC_IND;
                  if (pass_number == 2)
                     mnecat("FLUSHR");
               }
               else
                  ira->addressMode = MODE_INVALID;
               break;
         }
         break;

      case OPC_PFLUSH040:
         switch (ira->seaow & PFLUSH040_OPMODE_MASK)
         {
            case PFLUSH040_OPMODE_PAGE_NOT_GLOBAL:
               instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_AREG_INDIRECT;
               if (pass_number == 2)
                  mnecat("N");
               break;
            case PFLUSH040_OPMODE_PAGE:
               instructions[ira->opCodeNumber].destadr = MODE_IN_LOWER_BYTE | MODE_AREG_INDIRECT;
               break;
            case PFLUSH040_OPMODE_ALL_NOT_GLOBAL:
               instructions[ira->opCodeNumber].destadr = MODE_NONE;
               if (pass_number == 2)
                  mnecat("AN");
               break;
            case PFLUSH040_OPMODE_ALL:
               instructions[ira->opCodeNumber].destadr = MODE_NONE;
               if (pass_number == 2)
                  mnecat("A");
               break;
         }
         break;

      case OPC_PTEST040:
         if (pass_number == 2)
            mnecat((ira->seaow & PTEST040_RW_BIT_MASK)?"R":"W");
         break;

      case OPC_PBcc:
         ira->extension = (ira->seaow & PBcc_SIZE_BIT) ? 2 : 1;
         break;

      case OPC_PDBcc:
      case OPC_PScc:
         if ((ira->extra & ~Pcc_MASK))
            ira->addressMode = MODE_INVALID;
         break;

      case OPC_PTRAPcc:
         switch (ira->seaow & PTRAPcc_OPMODE_MASK)
         {
            case PTRAPcc_OPMODE_WORD:
               /* Force .W #$xxxx */
               ira->extension = 1;
               if (pass_number == 2)
                  mnecat(extensions[ira->extension]);
               instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_IMMEDIATE;
               break;

            case PTRAPcc_OPMODE_LONG:
               /* Force .L #$xxxxxxxx */
               ira->extension = 2;
               if (pass_number == 2)
                  mnecat(extensions[ira->extension]);
               instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_IMMEDIATE;
               break;

            case PTRAPcc_OPMODE_NONE:
               instructions[ira->opCodeNumber].sourceadr = MODE_NONE;
               break;

            default:
               ira->addressMode = MODE_INVALID;
               break;
         }
         break;

      case OPC_CACHE_SCOPE:
         switch (ira->seaow & CACHE_SCOPE_MASK)
         {
            case CACHE_SCOPE_LINE:
               if (pass_number == 2)
                  mnecat("L");
               break;

            case CACHE_SCOPE_PAGE:
               if (pass_number == 2)
                  mnecat("P");
               break;

            default:
               ira->addressMode = MODE_INVALID;
               break;
         }
         break;

      case OPC_PLPA:
         if (pass_number == 2)
            if (ira->seaow & PLPA_RW_BIT)
               mnecat("R");
            else
               mnecat("W");
         break;

      case OPC_MOVE16:
         if ((ira->extra & ~REGISTER_EXTENSION_MASK) != MOVE16_EXTENSION)
            ira->addressMode = MODE_INVALID;
         break;

      case OPC_LPSTOP:
         if (ira->extra != LPSTOP_EXTENSION)
            ira->addressMode = MODE_INVALID;
         break;
   }

   /* DoAdress{0,1,2}() is able to compute addressMode = MODE_INVALID and then handle it correctly.
    * DoSpecific() can also compute it but as DoAdress{0,1,2}() isn't called if {source,dest}adr == MODE_NONE...
    * so DoSpecific() has to explicitely compute sourceadr = MODE_IN_LOWER_BYTE | MODE_INVALID in order to let DoAdress{0,1,2}() handle this invalid mode. */
   if (ira->addressMode == MODE_INVALID)
      instructions[ira->opCodeNumber].sourceadr = MODE_IN_LOWER_BYTE | MODE_INVALID;
}
