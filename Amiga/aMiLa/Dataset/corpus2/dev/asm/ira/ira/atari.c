/*
 * atari.c
 *
 *  Created on: 31 may 2024
 *      Author   : Frank Wille
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : atari.c
 *      Purpose  : Functions about Atari's executable files format
 *      Copyright: (C)2024 Frank Wille
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ira.h"
#include "ira_2.h"
#include "supp.h"
#include "amiga_hunks.h"  /* @@@FIXME: just for HUNK_CODE/DATA/BSS ? */
#include "atari.h"

static int CheckSzbX(dri_symbol_t *sym)
{
  return be16(&sym->type)==STYP_XFLAGS && be32(&sym->value)==0x87654321;
}

static size_t SymNameLen(const char *p,size_t maxlen)
{
  size_t len = 0;

  while (maxlen-- && *p!='\0')
    len++;
  return len;
}

static int GetSymBase(ira_t *ira,dri_symbol_t *symtab,int n)
{
  uint32_t value;
  uint16_t type;
  int i;

  for (i=0; i<n; i++) {
    type = be16(symtab[i].type);
    value = be32(symtab[i].value);
    if (type!=STYP_XFLAGS && value!=0x87654321) {
      if (((type & STYP_DATA) && value>ira->hunksSize[1]) ||
          ((type & STYP_BSS) && value>ira->hunksSize[2]))
        return 1;  /* symbol value cannot be a normal section-offset */
    }
    if ((type&STYP_LONGNAME) == STYP_LONGNAME)
      i++;
  }
  return 0;  /* symbol table might have normal section-based offsets */
}

void ReadAtariExecutable(ira_t *ira)
{
  static const char *secnames[] = { "text","data","bss","equate" };
  atari_header_t hdr;
  uint32_t prglen;
  char *prgptr;
  int i,nsyms;

  /* read the header */
  fseek(ira->files.sourceFile,0,SEEK_SET);
  if (fread(&hdr,sizeof(hdr),1,ira->files.sourceFile) != 1)
    ExitPrg("Bad TOS Header!");

  /* we have always three sections: text, data, bss */
  ira->hunkCount = 3;
  ira->hunksMemoryType = mycalloc(3*sizeof(uint16_t));
  ira->hunksMemoryAttrs = mycalloc(3*sizeof(uint32_t));
  ira->hunksSize = mycalloc(3*sizeof(uint32_t));
  ira->hunksType = mycalloc(3*sizeof(uint32_t));
  ira->hunksOffs = mycalloc(3*sizeof(uint32_t));
  ira->firstHunk = 0;
  ira->lastHunk = 2;

  /* set section sizes, types and offsets */
  ira->hunksSize[0] = be32(hdr.ph_tlen);
  ira->hunksOffs[0] = ira->params.prgStart;
  ira->hunksType[0] = HUNK_CODE;
  ira->hunksSize[1] = be32(hdr.ph_dlen);
  ira->hunksOffs[1] = ira->hunksOffs[0] + ira->hunksSize[0];
  ira->hunksType[1] = HUNK_DATA;
  ira->hunksSize[2] = be32(hdr.ph_blen);
  ira->hunksOffs[2] = ira->hunksOffs[1] + ira->hunksSize[1];
  ira->hunksType[2] = HUNK_BSS;

  /* read text and data */
  prglen = ira->hunksSize[0] + ira->hunksSize[1] + ira->hunksSize[2];
  prgptr = mycalloc(prglen);
  fread(prgptr,ira->hunksSize[0]+ira->hunksSize[1],1,ira->files.sourceFile);

  if (ira->params.pFlags & SHOW_RELOCINFO)
    printf("\n  text: %ld bytes.\n  data: %ld bytes.\n  bss : %ld bytes.\n",
           ira->hunksSize[0],ira->hunksSize[1],ira->hunksSize[2]);

  /* read symbols, when present */
  if ((nsyms = be32(hdr.ph_slen)/sizeof(dri_symbol_t)) != 0) {
    dri_symbol_t *symtab = mycalloc(nsyms*sizeof(dri_symbol_t));
    int szbx,textbased;

    if (fread(symtab,sizeof(dri_symbol_t),nsyms,ira->files.sourceFile) != nsyms)
      ExitPrg("Symbol table corrupt!");
    i = szbx = !memcmp(symtab[0].name,"SozobonX",DRI_NAMELEN) &&
               CheckSzbX(&symtab[0]);
    textbased = GetSymBase(ira,&symtab[i],nsyms-i);
    if (ira->params.pFlags & SHOW_RELOCINFO)
      printf("\n  %d symbols present%s.\n",nsyms,textbased?" (textbased)":"");

    while (i < nsyms) {
      char *p;
      int len,type;
      uint32_t value;

      /* first determine symbol name length */
      if (szbx) {
        int n = i + 1;

        len = 0;
        while (n<nsyms && CheckSzbX(&symtab[n])) {
          len += DRI_NAMELEN;
          n++;
        }
        len += SymNameLen(symtab[n-1].name,DRI_NAMELEN);
      }
      else {
        if (i+1<nsyms &&
            (be16(symtab[i].type) & STYP_LONGNAME) == STYP_LONGNAME)
          len = DRI_NAMELEN +
                SymNameLen(symtab[i+1].name,sizeof(dri_symbol_t));
        else
          len = SymNameLen(symtab[i].name,DRI_NAMELEN);
      }
      if (len >= STDNAMELENGTH)
        ExitPrg("Too large name in symbol table!");

      type = be16(symtab[i].type);
      value = be32(symtab[i].value);
      p = ira->symbolName;

      if (szbx) {
        while (i+1<nsyms && CheckSzbX(&symtab[i+1])) {
          memcpy(p,symtab[i].name,DRI_NAMELEN);
          p += DRI_NAMELEN;
          len -= DRI_NAMELEN;
          i++;
        }
      }
      else {
        if (i+1<nsyms && (type&STYP_LONGNAME)==STYP_LONGNAME) {
          memcpy(p,symtab[i].name,DRI_NAMELEN);
          p += DRI_NAMELEN;
          len -= DRI_NAMELEN;
          i++;
        }
      }
      strncpy(p,symtab[i++].name,len);
      p[len] = '\0';

      if ((type & (STYP_DEFINED|STYP_EXTERNAL)) == STYP_DEFINED) {
        int sec;

        switch (type &
                (STYP_TEXT|STYP_DATA|STYP_BSS|STYP_REGISTER|STYP_EQUATED)) {
          case STYP_TEXT:
            sec = 0;
            break;
          case STYP_DATA:
            sec = 1;
            break;
          case STYP_BSS:
            sec = 2;
            break;
          case STYP_EQUATED:
            sec = 3;  /* @@@ import as equate? */
            break;
          default:
            sec = -1;
            break;
        }
        if (sec >= 0) {
          if (sec < 3) {
            /* define new symbol */
            if (!textbased)
              value += ira->hunksOffs[sec];
            InsertSymbol(ira->symbolName,value);
            InsertLabel(value);
          }
          /* @@@ else: equates? */
          if (ira->params.pFlags & SHOW_RELOCINFO)
            printf("    %-8s$%08lx %s\n",secnames[sec],value,ira->symbolName);
        }
        else {
          /* unsupported symbol type */
          if (ira->params.pFlags & SHOW_RELOCINFO)
            printf("    IGNORED $%08lx %s\n",value,ira->symbolName);
        }
      }
    }
    free(symtab);
  }

  if (be16(hdr.ph_absflag) == 0) {
    uint32_t offset;

    if (fread(&offset,sizeof(uint32_t),1,ira->files.sourceFile) != 1)
      ExitPrg("Relocation table expected. File corrupt.");
    offset = be32(&offset);

    if (offset != 0) {
      /* read relocations */
      uint8_t delta;
      uint32_t addend;

      i = 0;
      do {
        if (offset > prglen-4)
          ExitPrg("Relocation: Bad offset (0 <= (offset=%u) <= %u).",
                  (unsigned)offset,(unsigned)prglen);
        i++;
        addend = be32(prgptr+offset);
        InsertReloc(offset,addend,0,0);
        InsertLabel(addend);

        do {
          if (fread(&delta,sizeof(uint8_t),1,ira->files.sourceFile) != 1)
            ExitPrg("Unexpected end of relocation table.");
          offset += delta==1 ? 254 : delta;
        } while (delta == 1);
      } while (delta);

      if (ira->params.pFlags & SHOW_RELOCINFO)
        printf("\n  Relocation table: %d entries.\n",i);
    }
  }
  putchar('\n');

  /* write data to binary file and release memory */
  fwrite(prgptr,1,prglen,ira->files.binaryFile);
  free(prgptr);
}
