/*
 * ira_2.c
 *
 *      Author   : Tim Ruehsen, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : ira_2.c
 *      Purpose  : Contains some subroutines for IRA
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2024 Frank Wille, (C)2014-2019 Nicolas Bastien
 */

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ira.h"

#include "ira_2.h"
#include "amiga_hunks.h"
#include "constants.h"
#include "supp.h"

extern ira_t *ira;

uint32_t FileLength(uint8_t *name)
{
   int32_t len;
   FILE *file;
   if (name)
   {
      if (!(file = fopen(name, "rb")))
         ExitPrg("Can't open \"%s\".", name);
      if (fseek(file, 0, SEEK_END))
         ExitPrg("seek error (%s).", name);
      if ((len = ftell(file)) == -1L)
         ExitPrg("ftell error (%s).", name);
      fclose(file);
   }
   else
      printf("FileLength: Got no Name!\n");
   return ((uint32_t) len);
}

void *GetNewVarBuffer(void *p, uint32_t size)
{
   uint8_t *np = myalloc(size * sizeof(uint32_t) * 2);

   memcpy(np, p, size * sizeof(uint32_t));
   memset(np + size * sizeof(uint32_t), 0, size * sizeof(uint32_t));
   free(p);
   return (np);
}

void *GetNewPtrBuffer(void *p, uint32_t size)
{
   uint8_t *np = myalloc(size * sizeof(void *) * 2);

   memcpy(np, p, size * sizeof(void *));
   memset(np + size * sizeof(void *), 0, size * sizeof(void *));
   free(p);
   return (np);
}

void *GetNewStructBuffer(void *p, uint32_t size, uint32_t n)
{
   uint8_t *np = myalloc(n * size * 2);

   memcpy(np, p, n * size);
   memset(np + n * size, 0, n * size);
   free(p);
   return (np);
}

void InsertReloc(uint32_t adr, uint32_t value, int32_t offs, uint32_t mod)
/*
 adr     reloction address
 value   contents at that address (also an address)
 */
{
   uint32_t l = 0, m, r = ira->relocount;

   if (adr & 1)
      ExitPrg("Relocation at odd address $%lx not supported!", (unsigned long) adr);
   /* This case happens frequently. */
   if (ira->relocount && adr > ira->reloc.relocAdr[ira->relocount - 1])
   {
      ira->reloc.relocAdr[ira->relocount] = adr;
      ira->reloc.relocVal[ira->relocount] = value;
      ira->reloc.relocOff[ira->relocount] = offs;
      ira->reloc.relocMod[ira->relocount++] = mod;
   }
   else
   {
      /* binary search for adr */
      while (l < r)
      {
         m = (l + r) / 2;
         if (ira->reloc.relocAdr[m] < adr)
            l = m + 1;
         else
            r = m;
      }
      if (r == ira->relocount || ira->reloc.relocAdr[r] != adr)
      {
         lmovmem(&ira->reloc.relocAdr[r], &ira->reloc.relocAdr[r + 1], ira->relocount - r);
         lmovmem(&ira->reloc.relocOff[r], &ira->reloc.relocOff[r + 1], ira->relocount - r);
         lmovmem(&ira->reloc.relocVal[r], &ira->reloc.relocVal[r + 1], ira->relocount - r);
         lmovmem(&ira->reloc.relocMod[r], &ira->reloc.relocMod[r + 1], ira->relocount - r);
         ira->reloc.relocAdr[r] = adr;
         ira->reloc.relocOff[r] = offs;
         ira->reloc.relocVal[r] = value;
         ira->reloc.relocMod[r] = mod;
         ira->relocount++;
      }
   }
   if (ira->relocount == ira->reloc.relocMax)
   {
      ira->reloc.relocAdr = GetNewVarBuffer(ira->reloc.relocAdr, ira->reloc.relocMax);
      ira->reloc.relocVal = GetNewVarBuffer(ira->reloc.relocVal, ira->reloc.relocMax);
      ira->reloc.relocOff = GetNewVarBuffer(ira->reloc.relocOff, ira->reloc.relocMax);
      ira->reloc.relocMod = GetNewVarBuffer(ira->reloc.relocMod, ira->reloc.relocMax);
      ira->reloc.relocMax *= 2;
   }
}

void InsertLabel(int32_t adr)
{
   uint32_t l = 0, m, r = ira->labcount;

   if (ira->pass == 0)
      return;

   /* Happens frequently. */
   if (ira->labcount && (adr > (int32_t) ira->label.labelAdr[ira->labcount - 1]))
   {
      ira->label.labelAdr[ira->labcount++] = adr;
   }
   else
   {
      /* binary search of adr */
      while (l < r)
      {
         m = (l + r) / 2;
         if ((int32_t) ira->label.labelAdr[m] < adr)
            l = m + 1;
         else
            r = m;
      }
      if (ira->label.labelAdr[r] != adr || r == ira->labcount)
      {
         lmovmem(&ira->label.labelAdr[r], &ira->label.labelAdr[r + 1], ira->labcount - r);
         ira->label.labelAdr[r] = adr;
         ira->labcount++;
      }
   }
   if (ira->labcount == ira->label.labelMax)
   {
      ira->label.labelAdr = GetNewVarBuffer(ira->label.labelAdr, ira->label.labelMax);
      ira->label.labelMax *= 2;
   }
}

void InsertXref(uint32_t adr)
{
   uint32_t l = 0, m, r = ira->XRefCount;

   if (ira->pass == 0)
      return;

   /* binary search of adr */
   while (l < r)
   {
      m = (l + r) / 2;
      if (ira->XRefList[m] < adr)
         l = m + 1;
      else
         r = m;
   }
   if (ira->XRefList[r] != adr || r == ira->XRefCount)
   {
      lmovmem(&ira->XRefList[r], &ira->XRefList[r + 1], ira->XRefCount - r);
      ira->XRefList[r] = adr;
      ira->XRefCount++;
   }

   if (ira->XRefCount == ira->LabX_len)
   {
      ira->XRefList = GetNewVarBuffer(ira->XRefList, ira->LabX_len);
      ira->LabX_len *= 2;
   }
}

int GetSymbol(uint32_t adr)
{
   uint32_t i;

   for (i = 0; i < ira->symbols.symbolCount; i++)
      if (ira->symbols.symbolValue[i] == adr)
      {
         adrcat(ira->symbols.symbolName[i]);
         return (-1);
      }

   return (0);
}

static void CatLabelAddr(unsigned r2, unsigned r)
{
   char buf[20];

   switch (ira->params.labelStyle) {
      case LABSTYLE_ADDR:
         sprintf(buf, "LAB_%lX", (unsigned long)ira->LabelAdr2[r]);
         break;
      default:
         sprintf(buf, "LAB_%04X", r);
         break;
   }
   adrcat(buf);
}

char *SecstrtLabel(int i)
{
   static char buf[16];

   sprintf(buf, "SECSTRT_%d", i);
   return buf;
}

static void CatSecstrtLabel(ira_t *ira, int i)
{
   /* Do not attempt to use a symbol when section size [i] or the
      previous section's size is zero! */
   if (ira->hunksSize[i] != 0 && (!(ira->params.pFlags & KEEP_ZEROHUNKS)
       || i == 0 || ira->hunksSize[i-1] != 0)) {
      if (GetSymbol(ira->hunksOffs[i]))
         return;
   }
   /* SECSTRT_n otherwise */
   adrcat(SecstrtLabel(i));
}

void GetLabel(int32_t address, uint16_t addressMode)
{
   uint32_t dummy = -1;
   uint32_t l = 0, m, r = ira->labcount, r2;

   if ((addressMode == 5 || addressMode == 6) && (address >= (int32_t) (ira->hunksOffs[ira->baseReg.baseSection] + ira->hunksSize[ira->baseReg.baseSection]) || address < (int32_t) ira->hunksOffs[ira->baseReg.baseSection]))
   {
      /* label outside of smalldata section always based on SECSTRT_n */
      CatSecstrtLabel(ira, ira->baseReg.baseSection);
      if (address > (int32_t) ira->hunksOffs[ira->baseReg.baseSection])
         adrcat("+");
      adrcat(itoasc(address - ira->hunksOffs[ira->baseReg.baseSection]));
      fprintf(stderr, "Base relative label not in section: %s\n", ira->adrbuf);
      return;
   }

   /* Search for an entry in LabelAdr */
   while (l < r)
   {
      m = (l + r) / 2;
      if ((int32_t) ira->label.labelAdr[m] < address)
         l = m + 1;
      else
         r = m;
   }
   if (ira->label.labelAdr[r] != address)
   {
      fprintf(stderr, "ADR=%08lx not found! (mode=%d) relocount=%ld nextreloc=%ld\n", (unsigned long) address, (int) addressMode, (long) ira->relocount, (long) ira->nextreloc);
      fprintf(stderr, "LabelAdr[l=%lu]=%08lx\n", l, (unsigned long) ira->label.labelAdr[l]);
      fprintf(stderr, "LabelAdr[m=%lu]=%08lx\n", m, (unsigned long) ira->label.labelAdr[m]);
      fprintf(stderr, "LabelAdr[r=%lu]=%08lx\n\n", r, (unsigned long) ira->label.labelAdr[r]);
      adrcat("LAB_");
      adrcat(itohex(address, 8));
      return;
   }

   /* to avoid several label at the same address */
   r2 = r;
   while (r && (ira->LabelAdr2[r] == ira->LabelAdr2[r - 1]))
      r--;

   /* Pass 2 */
   if (addressMode == 9999)
   {
      if (ira->LabelAdr2[r] == ira->hunksOffs[ira->reloc.relocMod[ira->nextreloc]])
      {
         CatSecstrtLabel(ira, ira->reloc.relocMod[ira->nextreloc]);
         if ((dummy = ira->reloc.relocOff[ira->nextreloc]))
         {
            if ((int32_t) ira->reloc.relocOff[ira->nextreloc] > 0)
               adrcat("+");
            adrcat(itoasc(ira->reloc.relocOff[ira->nextreloc]));
         }
         else
            if ((dummy = ira->label.labelAdr[r2] - ira->LabelAdr2[r]))
            {
               adrcat("+");
               adrcat(itoasc(dummy));
            }
      }
      else
      {
         if (!GetSymbol(ira->label.labelAdr[r2]))
         {
            CatLabelAddr(r2, r);
         }
         if ((dummy = ira->label.labelAdr[r2] - ira->LabelAdr2[r]))
         {
            adrcat("+");
            adrcat(itoasc(dummy));
         }
      }
   }
   else
   {
      int i;

      if (ira->LabelAdr2[r] == ira->hunksOffs[ira->modulcnt])
         i = ira->modulcnt;
      else
      {
         for (i = 0; i < ira->hunkCount; i++)
            if (ira->LabelAdr2[r] == ira->hunksOffs[i])
               break;
         if (i >= ira->hunkCount)
            i = -1;
      }
      if (i >= 0)
      {
         CatSecstrtLabel(ira, i);
         if (address > (int32_t) ira->hunksOffs[i])
         {
            adrcat("+");
            adrcat(itoasc(address - ira->hunksOffs[i]));
         }
         else
            if (address < (int32_t) ira->hunksOffs[i])
               adrcat(itoasc(address - ira->hunksOffs[i]));
      }
      else
      {
         if (!GetSymbol(ira->label.labelAdr[r2]))
         {
            CatLabelAddr(r2, r);
         }
         if ((dummy = ira->label.labelAdr[r2] - ira->LabelAdr2[r]))
         {
            adrcat("+");
            adrcat(itoasc(dummy));
         }
      }
   }
}

void GetExtName(uint32_t index)
{
   register uint32_t xref;
   uint32_t l = 0, m, r = x_adr_number;

   xref = ira->XRefList[index];
   if ((ira->params.sourceType&SOURCE_FAMILY_MASK) == SOURCE_FAMILY_AMIGA
       && xref >= 0xDC0000 && xref <= 0xDCFFFF)
      xref &= 0xDC00FC;

   /* binary search for entry */
   while (l < r)
   {
      m = (l + r) / 2;
      if (x_adrs[m].adr < xref)
         l = m + 1;
      else
         r = m;
   }
       
   if (x_adrs[r].adr != xref ||
       (x_adrs[r].system != 0 &&
        (ira->params.sourceType&SOURCE_FAMILY_MASK) != x_adrs[r].system))
   {
      char buf[16];

      adrcat("EXT_");
      switch (ira->params.labelStyle) {
         case LABSTYLE_ADDR:
            sprintf(buf, "%lX", (unsigned long)xref);
            adrcat(buf);
            break;
         default:
            adrcat(itohex(index, 4));
            break;
      }
   }
   else
      adrcat(&x_adrs[r].name[0]);
}

int GetExtsymName(uint32_t adr)
{
   Extsym_t *sym = ira->extsyms;

   while (sym) {
      if (sym->extValue == adr) {
         adrcat(sym->extName);
         return 1;
      }
      sym = sym->next;
   }
   return 0;
}

void GetXref(uint32_t adr)
{
   uint32_t l = 0, m, r = ira->XRefCount;

   /* search entry in XRefListe */
   while (l < r)
   {
      m = (l + r) / 2;
      if (ira->XRefList[m] < adr)
         l = m + 1;
      else
         r = m;
   }
   if (ira->XRefList[r] != adr)
   {
      fprintf(stderr, "XRef ADR=%08lx not found!\n", (unsigned long) adr);
      adrcat("EXT_");
      adrcat(itohex(adr, 8));
   }
   else if (!GetExtsymName(adr))
      GetExtName(r);
}

char *GetEquate(int size, uint32_t adr)
{
   Equate_t *equ = ira->equates;
   char *equate_name = NULL;

   while (equ && !equate_name)
   {
      if (equ->size == size && equ->equateAdr == adr)
         equate_name = equ->equateName;
      equ = equ->next;
   }

   return equate_name;
}

uint32_t CheckEquate(ira_t *ira, uint32_t start, uint32_t end)
{
   Equate_t *equ;
   uint32_t result = end;

   for (equ = ira->equates; equ; equ = equ->next)
      if (start<= equ->equateAdr && equ->equateAdr < end)
      {
         result = equ->equateAdr;
         break;
      }

   return result;
}

static void CreateSymbol(const char * name, uint32_t symptr, uint32_t refptr, uint32_t module, uint32_t number)
{
   char symbol[32];

   strcpy(symbol, name);
   if (number)
      strcat(symbol, itoasc(number));
   InsertSymbol(symbol, symptr);
   if (symptr >= ira->hunksOffs[ira->modulcnt] &&
       symptr < (ira->hunksOffs[ira->modulcnt] + ira->hunksSize[ira->modulcnt]))
   {
      InsertReloc(refptr + ira->params.prgStart, symptr, 0L, module);
      InsertLabel(symptr);
   }
}

void SearchRomTag(ira_t *ira)
{
   uint8_t name[80];
   uint32_t number = 0;
   uint32_t ptr, refptr, functable, module = 0;
   uint8_t *rtname;
   int32_t i, j, k, l;
   uint8_t flags, Type;
   uint16_t relative;
   static const char * FuncName[] = {"OPEN", "CLOSE", "EXPUNGE", "RESERVED", "BEGINIO", "ABORTIO"};

   for (i = 0; i < (int32_t) (ira->params.prgEnd - ira->params.prgStart - 24) / 2; i++)
   {
      relative = 0;
      if (be16(&ira->buffer[i]) == ILLEGAL_CODE)
      {
         i++;
         ptr = be32(&ira->buffer[i]);

         /* OK. RomTag structure found */
         if ((ptr - ira->params.prgStart) == (i - 1) * 2)
         {
            for (l = 0; l <= ira->lastHunk; l++)
            {
               if (ira->hunksSize[l])
               {
                  if (i * 2 >= ira->hunksOffs[l] && i * 2 < ira->hunksOffs[l] + ira->hunksSize[l])
                  {
                     module = l;
                     break;
                  }
               }
            }
            if (i == 1)
               ira->params.pFlags |= ROMTAGatZERO;

            CreateSymbol("ROMTAG", ptr, i * 2, module, number);
            i += 2;
            CreateSymbol("ENDSKIP", be32(&ira->buffer[i]), i * 2, module, number);
            i += 2;
            flags = (uint8_t) (be16(&ira->buffer[i++]) >> 8);
            Type = (uint8_t) (be16(&ira->buffer[i++]) >> 8);
            ptr = be32(&ira->buffer[i]);
            rtname = ((uint8_t *)ira->buffer) + (ptr - ira->params.prgStart);
            stccpy(name, rtname, 16);
            strupr(name);
            for (k = 0; k < 16; k++)
               if (!isalnum(name[k]))
                  name[k] = 0;
            if (Type == NT_LIBRARY)
            {
               strcat(name, "LIBNAME");
               CreateSymbol(name, ptr, i * 2, module, 0);
            }
            else
               if (Type == NT_DEVICE)
               {
                  strcat(name, "DEVNAME");
                  CreateSymbol(name, ptr, i * 2, module, 0);
               }
               else
                  if (Type == NT_RESOURCE)
                  {
                     strcat(name, "RESNAME");
                     CreateSymbol(name, ptr, i * 2, module, 0);
                  }
                  else
                  {
                     strcat(name, "NAME");
                     CreateSymbol(name, ptr, i * 2, module, number);
                  }
            i += 2;
            CreateSymbol("IDSTRING", be32(&ira->buffer[i]), i * 2, module, number);
            i += 2;
            ptr = be32(&ira->buffer[i]);
            CreateSymbol("INIT", ptr, i * 2, module, number);
            i += 2;
            /* if RTF_AUTOINIT is set, INIT points to a special structure. */
            if (flags & 0x80)
            {
               j = (ptr - ira->params.prgStart) / 2;
               ptr = be32(&ira->buffer[j + 6]);
               if (ptr)
               {
                  CreateSymbol("INITFUNCTION", ptr, (j + 6) * 2, module, number);
                  InsertCodeAdr(ira, ptr);
               }
               ptr = be32(&ira->buffer[j + 4]);
               if (ptr)
               {
                  CreateSymbol("DATATABLE", ptr, (j + 4) * 2, module, number);
               }
               functable = be32(&ira->buffer[j + 2]);
               if (functable)
               {
                  CreateSymbol("FUNCTABLE", functable, (j + 2) * 2, module, number);
                  j = (functable - ira->params.prgStart) / 2;
                  if (ira->buffer[j] == 0xFFFF)
                     relative = 1;

                  k = j + relative;
                  l = 0;
                  if (Type == NT_DEVICE)
                     l = 6;
                  if (Type == NT_LIBRARY)
                     l = 4;
                  ptr = 0;
                  while (ptr != 0xFFFFFFFF)
                  {
                     if (relative == 1)
                     {
                        if (ira->buffer[k] == 0xFFFF)
                           ptr = 0xFFFFFFFF;
                        else
                           ptr = functable + (int16_t) be16(&ira->buffer[k]);
                     }
                     else
                     {
                        ptr = be32(&ira->buffer[j + (k - j) * 2]);
                        refptr = j * 2 + (k - j) * 4;
                     }
                     k++;
                     if (ptr && (ptr != 0xFFFFFFFF))
                     {
                        if (k - j > l)
                        {
                           strcpy(name, "LIBFUNC");
                           if (number)
                              strcat(name, itoasc(number));
                           strcat(name, "_");
                           strcat(name, itoasc(k - j - l - 1));
                        }
                        else
                        {
                           strcpy(name, FuncName[k - j - 1 - relative]);
                           if (number)
                              strcat(name, itoasc(number));
                        }
                        if (relative == 0)
                           InsertReloc(refptr + ira->params.prgStart, ptr, 0L, module);
                        InsertSymbol(name, ptr);
                        InsertCodeAdr(ira, ptr);
                        InsertLabel(ptr);
                     }
                  }
               }
            }
            else
            {
               InsertCodeAdr(ira, ptr);
            }
            number++;
         }
      }
   }
}

void WriteTarget(void *ptr, uint32_t len)
{
   if ((fwrite(ptr, 1, len, ira->files.targetFile)) != len)
      ExitPrg("Write Error !");
}
