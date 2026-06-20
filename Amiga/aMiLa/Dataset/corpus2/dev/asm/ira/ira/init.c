/*
 * init.c
 *
 *  Created on: 24 december 2014
 *      Author   : Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : init.c
 *      Purpose  : IRA initialization subroutines
 *      Copyright: (C)2014-2016 Nicolas Bastien
 */

#include <ctype.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "ira.h"

#include "amiga_hunks.h"
#include "atari.h"
#include "binary.h"
#include "elf.h"
#include "init.h"
#include "ira_2.h"
#include "config.h"
#include "constants.h"
#include "supp.h"

ira_t *Start(void)
{
   ira_t *ira;
   int i;

   /* note: mycalloc doesn't return if allocation failed, so no need to check returned value */
   ira = (ira_t *) mycalloc(sizeof(ira_t));

   ira->params.cpuType = NOCPU;
   ira->params.baseReg = 4;
   ira->params.labelStyle = LABSTYLE_ORIG;
   ira->params.radix = 10;

   ira->reloc.relocMax = 1024;
   ira->symbols.symbolMax = 16;
   ira->codeArea.codeAreaMax = 16;
   ira->codeArea.cnfCodeAreaMax = 16;
   ira->codeArea.codeAdrMax = 16;
   ira->baseReg.baseSection = -1;
   ira->noBase.noBaseMax = 16;
   ira->noPtr.noPtrMax = 16;
   ira->text.textMax = 16;
   ira->jmp.jmpMax = 16;
   ira->label.labelMax = 1024;

   ira->pass = -1;
   ira->LabX_len = 400;
   ira->adrlen = 0;

   return ira;
}

void Init(ira_t *ira, int argc, char **argv)
{
   int nextarg = 1;
   uint32_t i;
   uint16_t addrstyle = CPU_ADDR_STYLE;

   /* If argc lesser than 2: IRA is missing some arguments */
   if (argc < 2)
   {
#ifdef AMIGAOS
      /* argc equals 0 means "launched from Workbench" on AmigaOS. */
      if (argc == 0)
         fprintf(stderr, "IRA launching from Workbench is not yet supported\n\n");
#endif
      FormatError();
      ExitPrg("");
   }

   fprintf(stderr, IDSTRING1, VERSION, REVISION);

   /* Get everything we can from command line */
   ReadOptions(ira, argc, argv, &nextarg, &addrstyle);

   /* Let's check CPU and FPUs */
   CheckCPU(ira);

   /* All options are now handled, let's go to source and target file's name stuff. */

   /* Is there anymore argument that would contain the source file name ? */
   if (nextarg >= argc)
      ExitPrg("No source specified!");

   /* note: mystrdup() uses myalloc() which doesn't return if allocation failed, so no need to check returned value */
   ira->filenames.sourceName = mystrdup(argv[nextarg++]);

   /* Let's check if source file is readable. */
   if (!(ira->files.sourceFile = fopen(ira->filenames.sourceName, "rb")))
      ExitPrg("Can't open source file \"%s\".", ira->filenames.sourceName);

   /* If target is specified (in next argument), so be it */
   if (nextarg < argc)
      ira->filenames.targetName = mystrdup(argv[nextarg]);
   /* Else, let's build it with source's name with ASM extension. */
   else
      ira->filenames.targetName = ExtendFileName(ira->filenames.sourceName, ASM_EXT);

   /* Let's build other names from source name with appropriate extensions */
   ira->filenames.configName = ExtendFileName(ira->filenames.sourceName, CONFIG_EXT);
   ira->filenames.binaryName = ExtendFileName(ira->filenames.sourceName, BIN_EXT);
   ira->filenames.labelName = ExtendFileName(ira->filenames.sourceName, LABEL_EXT);

   /* Preparse config file, for options we need early (like OFFSET) */
   if (ira->params.pFlags & CONFIG)
      PreparseConfig(ira);

   /* By default, CPU will choose the addressing style (old style for 68000/010, new style for others).
    * If a style is explicitly asked, it will be used ignoring CPU. */
   if ((addrstyle == CPU_ADDR_STYLE && (ira->params.cpuType & (M68000 | M68010))) || addrstyle == OLD_ADDR_STYLE)
      ira->params.pFlags |= OLDSTYLE;

   /* If source type wasn't forced to binary, let's find out the file type. */
   if (!ira->params.sourceType)
      ira->params.sourceType = AutoScan(ira);

   /* If source type IS binary, of course, there won't be more than one Reloc */
   if (ira->params.sourceType == M68K_BINARY)
      ira->reloc.relocMax = 1;

   /* Let's try to get some memory */
   ira->label.labelAdr = mycalloc(ira->label.labelMax * 4);
   ira->reloc.relocAdr = mycalloc(ira->reloc.relocMax * 4);
   /* note: mycalloc() doesn't return if allocation failed, so no need to check returned value */
   ira->reloc.relocAdr[0] = 1; /* If no Reloc found */
   ira->reloc.relocOff = mycalloc(ira->reloc.relocMax * 4);
   ira->reloc.relocVal = mycalloc(ira->reloc.relocMax * 4);
   ira->reloc.relocMod = mycalloc(ira->reloc.relocMax * 4);
   ira->symbols.symbolName = mycalloc(ira->symbols.symbolMax * sizeof(char *));
   ira->symbols.symbolValue = mycalloc(ira->symbols.symbolMax * sizeof(uint32_t));
   ira->codeArea.codeArea1 = mycalloc(ira->codeArea.codeAreaMax * sizeof(uint32_t));
   ira->codeArea.codeArea2 = mycalloc(ira->codeArea.codeAreaMax * sizeof(uint32_t));
   ira->codeArea.cnfCodeArea1 = mycalloc(ira->codeArea.cnfCodeAreaMax * sizeof(uint32_t));
   ira->codeArea.cnfCodeArea2 = mycalloc(ira->codeArea.cnfCodeAreaMax * sizeof(uint32_t));
   ira->codeArea.codeAdr = mycalloc(ira->codeArea.codeAdrMax * sizeof(uint32_t));
   ira->noBase.noBaseStart = mycalloc(ira->noBase.noBaseMax * sizeof(uint32_t));
   ira->noBase.noBaseEnd = mycalloc(ira->noBase.noBaseMax * sizeof(uint32_t));
   ira->noPtr.noPtrStart = mycalloc(ira->noPtr.noPtrMax * sizeof(uint32_t));
   ira->noPtr.noPtrEnd = mycalloc(ira->noPtr.noPtrMax * sizeof(uint32_t));
   ira->text.textStart = mycalloc(ira->text.textMax * sizeof(uint32_t));
   ira->text.textEnd = mycalloc(ira->text.textMax * sizeof(uint32_t));
   ira->jmp.jmpTable = mycalloc(ira->jmp.jmpMax * sizeof(JMPTab_t));

   /* Source file read according to its chosen or detected type */
   switch(ira->params.sourceType & SOURCE_FAMILY_MASK)
   {
      case SOURCE_FAMILY_AMIGA:
         /* Let's try to open binary file */
         if ((ira->files.binaryFile = fopen(ira->filenames.binaryName, "wb")))
            if (ira->params.sourceType == AMIGA_HUNK_EXECUTABLE)
               ReadAmigaHunkExecutable(ira);
            else
               ReadAmigaHunkObject(ira);
         else
            ExitPrg("Can't open binary file \"%s\" for writing.", ira->filenames.binaryName);
         break;
      case SOURCE_FAMILY_ATARI:
         /* Let's try to open binary file */
         if ((ira->files.binaryFile = fopen(ira->filenames.binaryName, "wb")))
            ReadAtariExecutable(ira);
         else
            ExitPrg("Can't open binary file \"%s\" for writing.", ira->filenames.binaryName);
         break;
      case SOURCE_FAMILY_ELF:
         ReadElfExecutable(ira);
         ExitPrg("Elf's executable files not yet supported.");
         break;
      case SOURCE_FAMILY_NONE:
      default:
         Read68kBinary(ira);
         break;
   }

   /* Initial reading is done, let's close files to open them again differently, later */
   if (ira->files.sourceFile)
      fclose(ira->files.sourceFile);
   if (ira->files.binaryFile)
      fclose(ira->files.binaryFile);
   ira->files.binaryFile = ira->files.sourceFile = NULL;

   /* A binary file has been created, containing everything, its size is the program size */
   ira->params.prgLen = FileLength(ira->filenames.binaryName);

   /* Open binary file */
   if (!(ira->files.binaryFile = fopen(ira->filenames.binaryName, "rb")))
      ExitPrg("Can't open binary file \"%s\" for reading.", ira->filenames.binaryName);

   /* Open labels file */
   if (!(ira->files.labelFile = fopen(ira->filenames.labelName, "wb")))
      ExitPrg("Can't open label file \"%s\" for writing.", ira->filenames.labelName);

   /* note: mycalloc() doesn't return if allocation failed, so no need to check returned value */
   ira->LabelNum = mycalloc(ira->hunkCount * sizeof(uint32_t));
   ira->XRefList = mycalloc(ira->LabX_len * sizeof(uint32_t));
   ira->buffer = mycalloc(ira->params.prgLen + 4);

   /* Has binary file the expected size ? */
   if ((fread(ira->buffer, 1, ira->params.prgLen, ira->files.binaryFile)) != ira->params.prgLen)
      ExitPrg("Can't read all data (binary file has not expected size).");

   /* Something obvious about program's end */
   ira->params.prgEnd = ira->params.prgStart + ira->params.prgLen;

   /* Now dealing with config file */
   if (ira->params.pFlags & CONFIG)
      ReadConfig(ira);

   /* Computing maximum length of a string containing the current address (between 1 and 8 because m68ks are 32bits wide) */
   if (ira->adrlen == 0)
      for (ira->adrlen = 1;
           (1 << (ira->adrlen*4)) < ira->params.prgEnd && ira->adrlen < 8;
           ira->adrlen++);

   /* Reject code entry if too high, but override code entry to start of program if too low */
   if (ira->params.codeEntry >= ira->params.prgEnd)
      ExitPrg("ERROR: Entry(=$%08lX) is out of range!", (unsigned long) ira->params.codeEntry);
   if (ira->params.codeEntry < ira->params.prgStart)
      ira->params.codeEntry = ira->params.prgStart;

   if (ira->params.pFlags & BASEREG2)
   {
      /* Same as code entry with base address */
      if (ira->baseReg.baseAddress >= ira->params.prgEnd)
         ExitPrg("ERROR: BASEADR(=$%08lX) is out of range!", (unsigned long) ira->baseReg.baseAddress);
      if (ira->baseReg.baseAddress < ira->params.prgStart)
         ira->baseReg.baseAddress = ira->params.prgStart;

      InsertLabel(ira->baseReg.baseAddress);
      for (ira->baseReg.baseSection = 0; ira->baseReg.baseSection < ira->hunkCount; ira->baseReg.baseSection++)
         if (ira->baseReg.baseAddress >= ira->hunksOffs[ira->baseReg.baseSection] && ira->baseReg.baseAddress < ira->hunksOffs[ira->baseReg.baseSection] + ira->hunksSize[ira->baseReg.baseSection])
            break;
   }

   printf("SOURCE : \"%s\"\n", ira->filenames.sourceName);
   printf("TARGET : \"%s\"\n", ira->filenames.targetName);
   if (ira->params.pFlags & KEEP_BINARY)
      printf("BINARY : \"%s\"\n", ira->filenames.binaryName);
   if (ira->params.pFlags & CONFIG)
      printf("CONFIG : \"%s\"\n", ira->filenames.configName);
   for (i = 0; i < cpuname_number; i++)
      if (ira->params.cpuType & (1 << i))
         printf("MACHINE: %s\n", cpuname[i]);
   printf("OFFSET : $%08lX\n", (unsigned long) ira->params.prgStart);
}

void ReadOptions(ira_t *ira, int argc, char **argv, int *nextarg, uint16_t *addrstyle)
{
   char *odata, option, *data;

   while ((odata = argopt(argc, argv, nextarg, &option)))
   {
      switch (toupper(option))
      {
         case 'A':
            ira->params.pFlags |= ADR_OUTPUT;
            if (!stricmp(odata, "W"))
               ira->adrlen = 8;
            else if (odata[0])
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'B':
            if (!(stricmp(odata, "INARY")))
               ira->params.sourceType = M68K_BINARY;
            else
               if (!(stricmp(odata, "ASEABS")))
                  ira->params.baseAbs = 1;
               else
                  if (!(stricmp(odata, "ASEREG")))
                     ira->params.pFlags |= BASEREG1;
                  else
                     if (!(strnicmp(odata, "ASEREG=", 7)))
                     {
                        ira->params.baseReg = odata[7] - '0';
                        if ((data = strchr(odata, ',')))
                        {
                           ira->baseReg.baseAddress = parseAddress(&data[1]);
                           ira->params.pFlags |= BASEREG2;
                           if ((data = strchr(&data[1], ',')))
                           {
                              int32_t off;
                              off = stcd_l(&data[1]);
                              ira->baseReg.baseOffset = (int16_t) off;
                           }
                           else
                              ira->baseReg.baseOffset = 0;
                        }
                        else
                           ira->params.pFlags |= BASEREG1;
                        if (ira->params.baseReg > 7)
                           ExitPrg("Register cannot be greater than 7.");
                     }
                     else
                        ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'C':
            if (!(stricmp(odata, "ONFIG")))
               ira->params.pFlags |= CONFIG;
            else
               if (!(strnicmp(odata, "OMPAT=", 6)))
               {
                  char c, *p = odata + 6;

                  while ((c = *p++))
                  {
                     switch (tolower((unsigned) c))
                     {
                        case 'b':
                           ira->params.bitRange = 1;
                           break;
                        case 'i':
                           ira->params.immedByte = 1;
                           break;
                        default:
                           ExitPrg("Illegal COMPAT flag '%c'", c);
                           break;
                     }
                  }
               }
               else
                  ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'E':
            if (!strnicmp(odata, "NTRY=", 5))
            {
               ira->params.codeEntry = parseAddress(&odata[5]);
               if ((int32_t) (ira->params.codeEntry) < 0L)
                  ExitPrg("-ENTRY=%s: ENTRY must not be negative!", &odata[5]);
            }
            else
               if (!(stricmp(odata, "SCCODES")))
                  ira->params.pFlags |= ESCCODES;
               else
                  ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'F':
            if (!stricmp(odata, "IXLABELS"))
                  ira->params.pFlags |= FIXLABELS;
               else
                  ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'I':
            if (!(stricmp(odata, "NFO")))
               ira->params.pFlags |= SHOW_RELOCINFO;
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'K':
            if (!(stricmp(odata, "EEPZH")))
               ira->params.pFlags |= KEEP_ZEROHUNKS;
            else
               if (!(stricmp(odata, "EEPBIN")))
                  ira->params.pFlags |= KEEP_BINARY;
               else
                  ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'L':
            if (!strnicmp(odata, "ABEL=", 5))
               ira->params.labelStyle = atoi(&odata[5]);
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;
           
         case 'N':
            if (!(stricmp(odata, "EWSTYLE")))
               if (*addrstyle == OLD_ADDR_STYLE)
                  ExitPrg("-NEWSTYLE cannot be use with -OLDSTYLE");
               else
                  *addrstyle = NEW_ADDR_STYLE;
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'M':
            if (!strncmp(odata, "680", 3))
               /* Processor stuff */
               if (ira->params.cpuType & M680x0)
                  ExitPrg("Processor already defined.");
               else
                  if (!strcmp(&odata[2], "000"))
                     ira->params.cpuType |= M68000;
                  else
                     if (!strcmp(&odata[2], "010"))
                        ira->params.cpuType |= M68010;
                     else
                        if (!strcmp(&odata[2], "020"))
                           ira->params.cpuType |= M68020;
                        else
                           if (!strcmp(&odata[2], "030"))
                              ira->params.cpuType |= M68030;
                           else
                              if (!strcmp(&odata[2], "040"))
                                 ira->params.cpuType |= M68040;
                              else
                                 if (!strcmp(&odata[2], "060"))
                                    ira->params.cpuType |= M68060;
                                 else
                                    ExitPrg("Unknown processor Motorola %c%s", option, odata);
            else
               /* MMU stuff */
               if (!strcmp(odata, "68851"))
                  ira->params.cpuType |= M68851;
               else
                  if (!strncmp(odata, "6888", 4))
                     /* FPU stuff */
                     if (ira->params.cpuType & FPU_EXTERNAL)
                        ExitPrg("Arithmetic coprocessor already defined.");
                     else
                        if (!strcmp(odata, "68881"))
                           ira->params.cpuType |= M68881;
                        else
                           if (!strcmp(odata, "68882"))
                              ira->params.cpuType |= M68882;
                           else
                              ExitPrg("Unknown arithmetic coprocessor Motorola %c%s", option, odata);
                  else
                     ExitPrg("Unknown Motorola %c%s", option, odata);
            break;

         case 'O':
            if (!stricmp(odata, "LDSTYLE"))
               if (*addrstyle == NEW_ADDR_STYLE)
                  ExitPrg("-OLDSTYLE cannot be use with -NEWSTYLE");
               else
                  *addrstyle = OLD_ADDR_STYLE;
            else
               if (!strnicmp(odata, "FFSET=", 6))
               {
                  ira->params.prgStart = parseAddress(&odata[6]);
                  if ((int32_t) ira->params.prgStart < 0L)
                     ExitPrg("-OFFSET=%s: OFFSET must not be negative!", &odata[6]);
               }
               else
                  ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'P':
            if (!(stricmp(odata, "REPROC")))
               ira->params.pFlags |= PREPROC;
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'R':
            if (!strnicmp(odata, "ADIX=", 5))
               ira->params.radix = atoi(&odata[5]);
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'S':
            if (!(stricmp(odata, "PLITFILE")))
               ira->params.pFlags |= SPLITFILE;
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         case 'T':
            if (!(stricmp(odata, "EXT=1")))
               ira->params.textMethod = 1;
            else
               ExitPrg("Unknown option -%c%s", option, odata);
            break;

         default:
            ExitPrg("Unknown option -%c%s", option, odata);
            break;
      }
   }
}

void CheckCPU(ira_t *ira)
{
   /* If no processor have been specified on command line :
    * let's choose our plain old M68000 */
   if (!(ira->params.cpuType & M680x0))
      ira->params.cpuType |= M68000;

   /* MMU check :
    * only M68020 can have M68851
    * M68030, M68040 and M68060 already have an internal MMU
    * note : M68010 might have, in theory, by simulating its interface in software (but IRA won't care)
    * (http://en.wikipedia.org/wiki/Motorola_68851) */

   /* FPU check :
    * only M68020 and M68030 can have M68881 or M68882
    * M68040 and M68060 already have an internal FPU
    * note : 68881 and 68882 are functionally the same, they only differ by their inner structure and performances
    * (http://en.wikipedia.org/wiki/Motorola_68881) */

   /* If MMU selected and CPU is not 68020 */
   if ((ira->params.cpuType & M68851) && !(ira->params.cpuType & M68020))
      if (ira->params.cpuType & MMU_INTERNAL)
         ExitPrg("There is already a MMU in M68030, M68040 and M68060.");
      else
         ExitPrg("Only M68020 can have M68851.");
   else
      /* If FPU selected and CPU is neither 68020 nor 68030 */
      if ((ira->params.cpuType & FPU_EXTERNAL) && !(ira->params.cpuType & (M68020 | M68030)))
         if (ira->params.cpuType & FPU_INTERNAL)
            ExitPrg("There is already a FPU in M68040 and M68060.");
         else
            ExitPrg("Only M68020 and M68030 can have M68881 or M68882.");
}

char *ExtendFileName(char *filename, char *extension)
{
   size_t len = strlen(filename);
   char *p = filename + len - 1;

   while (p > filename && *p != '/' && *p != '\\' && *p != ':') {
      if (*p == '.') {
         len = p - filename;
         break;
      }
      p--;
   }

   p = myalloc(len + strlen(extension) + 1);
   memcpy(p, filename, len);
   strcpy(p + len, extension);

   return p;
}
