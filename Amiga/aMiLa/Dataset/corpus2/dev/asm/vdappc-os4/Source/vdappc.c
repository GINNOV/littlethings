/* $VER: vdappc V1.2 (20.08.2000)
 *
 * Simple PowerPC file and memory disassembler.
 * Copyright (c) 1998-2000  Frank Wille
 *
 * vdappc is freeware and part of the portable and retargetable ANSI C
 * compiler vbcc, copyright (c) 1995-2000 by Volker Barthelmann.
 * vdappc may be freely redistributed as long as no modifications are
 * made and nothing is charged for it. Non-commercial usage is allowed
 * without any restrictions.
 * EVERY PRODUCT OR PROGRAM DERIVED DIRECTLY FROM MY SOURCE MAY NOT BE
 * SOLD COMMERCIALLY WITHOUT PERMISSION FROM THE AUTHOR.
 *
 *
 * v1.2  (20.08.2000) phx
 *       Displayed instruction word was wrong in file mode.
 * v1.1  (30.01.2000) phx
 *       Prints instruction word in hex.
 *       Version string update year 2000.
 *       Use new disassembler module V1.0.
 * v1.0  (23.05.1998) phx
 *       Seems to work. No known bugs.
 * v0.0  (16.05.1998) phx
 *       File created.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ppc_disasm.h"

#define VERSION 1
#define REVISION 2

const char *_ver = "$VER: vdappc 1.2 (20.08.2000)\r\n";


main(int argc,char *argv[])
{
  FILE *fh = NULL;
  ppc_word buf[1];
  ppc_word *p;
  unsigned long foff=0;
  struct DisasmPara_PPC dp;
  char opcode[10];
  char operands[24];

  if (argc!=2 || !strncmp(argv[1],"-h",2) || argv[1][0]=='?') {
    printf("vdappc V%d.%d  (c)1998-2000 by Frank Wille\n"
           "PowerPC disassembler V%d.%d  (c)1998-2000 by Frank Wille\n"
           "Build date: " __DATE__ ", " __TIME__ "\n\n"
           "Usage: %s file|address\n",
           VERSION,REVISION,PPCDISASM_VER,PPCDISASM_REV,argv[0]);
    exit(1);
  }

  /* initialize DisasmPara */
  dp.opcode = opcode;
  dp.operands = operands;

  if (isdigit((unsigned int)argv[1][0])) {
    sscanf(argv[1],"%i",(int *)&p);
  }
  else {
    /* open file */
    if (!(fh = fopen(argv[1],"r"))) {
      fprintf(stderr,"%s: Can't open %s!\n",argv[0],argv[1]);
      exit(10);
    }
    dp.instr = buf;
  }

  for (;;) {
    /* disassembler loop */
    if (fh) {
      if (fread(buf,1,sizeof(ppc_word),fh) != sizeof(ppc_word))
        break;  /* EOF */
      dp.iaddr = (ppc_word *)foff;
    }
    else
      dp.instr = dp.iaddr = p;
    PPC_Disassemble(&dp);
    printf("%08lx:  %08lx\t%s\t%s\n",fh?foff:(unsigned long)p,
           fh?buf[0]:*(unsigned long *)p,opcode,operands);
    if (fh)
      foff += sizeof(ppc_word);
    else
      p++;
  }

  /* cleanup */
  if (fh)
    fclose(fh);
  exit(0);
}
