/* $VER: vda68k V1.4 (25.11.2009)
 *
 * Simple M68k file and memory disassembler.
 * Copyright (c) 2000-2009  Frank Wille
 *
 * vdappc is freeware and part of the portable and retargetable ANSI C
 * compiler vbcc, copyright (c) 1995-2009 by Volker Barthelmann.
 * vdappc may be freely redistributed as long as no modifications are
 * made and nothing is charged for it. Non-commercial usage is allowed
 * without any restrictions.
 * EVERY PRODUCT OR PROGRAM DERIVED DIRECTLY FROM MY SOURCE MAY NOT BE
 * SOLD COMMERCIALLY WITHOUT PERMISSION FROM THE AUTHOR.
 *
 *
 * v1.4  (25.11.2009) phx
 *       Optional start address and end address arguments.
 * v1.3  (05.10.2008) phx
 *       Improved support for LE and RISC architectures.
 * v1.1  (07.03.2001) phx
 *       Support for little-endian architectures.
 * v1.0  (26.06.2000) phx
 *       File created.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "m68k_disasm.h"

#define VERSION 1
#define REVISION 4

const char *_ver = "$VER: vda68k 1.4 (25.11.2009)\r\n";


int main(int argc,char *argv[])
{
  FILE *fh;
  m68k_word buf[12];
  m68k_word *p=NULL,*endp=NULL,*ip;
  unsigned long foff;
  long pos;
  struct DisasmPara_68k dp;
  char opcode[16];
  char operands[128];
  char iwordbuf[32];
  char tmpbuf[8];
  int n;
  char *s;

  if (argc<2 || argc>4 || !strncmp(argv[1],"-h",2) || argv[1][0]=='?') {
    printf("vda68k V%d.%d  (c)2000-2009 by Frank Wille\n"
           "M68k disassembler V%d.%d  (c)1999-2008 by Frank Wille\n"
           "Based on NetBSD disassembler  (c)1994 by Christian E. Hopps\n"
           "Build date: " __DATE__ ", " __TIME__ "\n\n"
           "Usage: %s [file name] [start address] [end address]\n"
           "Either file name or start address must be given, or both.\n",
           VERSION,REVISION,M68KDISASM_VER,M68KDISASM_REV,argv[0]);
    return 1;
  }

  /* initialize DisasmPara */
  memset(&dp,0,sizeof(struct DisasmPara_68k));
  dp.opcode = opcode;
  dp.operands = operands;
  dp.radix = 16;  /* we want hex! */
  iwordbuf[26] = '\0';

  /* parse arguments */
  n = 1;
  fh = fopen(argv[1],"rb");
  if (!isdigit((unsigned int)argv[1][0]) || fh!=NULL) {
    /* first argument is a file name */
    if (!fh) {
      fprintf(stderr,"%s: Can't open %s!\n",argv[0],argv[1]);
      return 10;
    }
    n++;
    dp.instr = buf;
  }
  if (n < argc) {
    sscanf(argv[n],"%i",(int *)&p);
    n++;
  }
  else if (!fh) {
    fprintf(stderr,"%s: File name or address expected!\n",argv[0]);
    return 10;
  }
  if (n < argc)
    sscanf(argv[n],"%i",(int *)&endp);
  if (fh) {
    if (foff = (unsigned long)p)
      fseek(fh,foff,SEEK_SET);
  }

  for (;;) {
    /* disassembler loop */
    if (fh)
      p = (m68k_word *)foff;
    if (endp!=NULL && p>=endp)
      break;

    if (fh) {
      pos = ftell(fh);
      memset(buf,0,sizeof(m68k_word)*8);
      if (fread(buf,sizeof(m68k_word),8,fh) < 1)
        break;  /* EOF */
      dp.iaddr = p;
      n = M68k_Disassemble(&dp) - dp.instr;
      fseek(fh,pos,SEEK_SET);
      if (fread(buf,sizeof(m68k_word),n,fh) != n)
        break;  /* read error */
    }
    else
      dp.instr = dp.iaddr = p;

    p = M68k_Disassemble(&dp);

    /* print up to 5 instruction words */
    for (n = 0; n<26; iwordbuf[n++]=' ');
    if ((n = (int)(p-dp.instr)) > 5)
      n = 5;
    ip = dp.instr;
    s = iwordbuf;
    while (n--) {
      sprintf(tmpbuf,"%02x%02x",*(unsigned char *)ip,
              *((unsigned char *)ip+1));
      ip++;
      strncpy(s,tmpbuf,4);
      s += 5;
    }

    printf("%08lx: %s%-7s %s\n",(unsigned long)dp.iaddr,iwordbuf,
           opcode,operands);
    if (fh)
      foff += (p - dp.instr) * sizeof(m68k_word);
  }

  /* cleanup */
  if (fh)
    fclose(fh);
  return 0;
}
