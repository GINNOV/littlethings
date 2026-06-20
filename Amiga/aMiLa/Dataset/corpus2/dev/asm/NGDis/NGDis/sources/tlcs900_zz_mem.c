///////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//
//
// Author:
//  (c) 2001 Jouni Korhonen
//
// Version:
//  v0.2 21-Nov-2001 - JiK
//
///////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include "tlcs900d.h"


int decode_zz_mem( struct tlcs900d *dd ) {
  unsigned char *b = dd->buffer + dd->pos;
  char m[MEM_LEN];
  unsigned char c;
  int len;
  int mem;
  int zz;
  int n;
  int R;
  enum opcodes op = INVALID;
  char **Regs;

  //

  dd->opt = OPT_1_n_1;

  //
  // Following many opcodes:
  //  LD<W> (#16),(mem)   80+zz+mem:19:#16  +

  // regs

  //  LD   R,(mem)        80+zz+mem:20+R  +
  //  ADD  R,(mem)        80+zz+mem:80+R  +
  //  ADC  R,(mem)        80+zz+mem:90+R  +
  //  SUB  R,(mem)        80+zz+mem:a0+R  +
  //  SBC  R,(mem)        80+zz+mem:b0+R  +
  //  CP   R,(mem)        80+zz+mem:f0+R  +
  //  MUL  RR,(mem)       80+zz+mem:40+R  +
  //  MULS RR,(mem)       80+zz+mem:48+R  +
  //  DIV  RR,(mem)       80+zz+mem:50+R  +
  //  DIVS RR,(mem)       80+zz+mem:58+R  +
  //  AND  R,(mem)        80+zz+mem:c0+R  +
  //  OR   R,(mem)        80+zz+mem:e0+R  +
  //  XOR  R,(mem)        80+zz+mem:d0+R  +

  //  EX (mem),R          80+zz+mem:30+R  +
  //  ADD (mem),R         80+zz+mem:88+R  +
  //  ADC (mem),R         80+zz+mem:98+R  +
  //  SUB (mem),R         80+zz+mem:a8+R  +
  //  SBC (mem),R         80+zz+mem:b8+R  +
  //  CP (mem),R          80+zz+mem:f8+R  +
  //  AND (mem),R         80+zz+mem:c8+R  +
  //  OR (mem),R          80+zz+mem:e8+R  +
  //  XOR (mem),R         80+zz+mem:d8+R  +

  // inc/dec 1-8

  //  INC<W> #3,(mem)     80+zz+mem:60+#3 +
  //  DEC<W> #3,(mem)     80+zz+mem:68+#3 +

  // 8 or 16 bits..

  //  ADD<W> (mem),#			80+zz+mem:38:#  +
  //  ADC<W> (mem),#      80+zz+mem:39:#  +
  //  SUB<W> (mem),#      80+zz+mem:3a:#  +
  //  SBC<W> (mem),#      80+zz+mem:3b:#  +
  //  CP<W> (mem),#       80+zz+mem:3f:#  +
  //  AND<W> (mem),#      80+zz+mem:3c:#  +
  //  OR<W> (mem),#     	80+zz+mem:3e:#  +
  //  XOR<W> (mem),#      80+zz+mem:3d:#  +

  // 'Fixed' codes..

  //  PUSH<W> (mem)       80+zz+mem:04    +
  //  RLC<W> (mem)        80+zz+mem:78    +
  //  RRC<W> (mem)        80+zz+mem:79    + 
  //  RL<W> (mem)         80+zz+mem:7a    +
  //  RR<W> (mem)         80+zz+mem:7b    +
  //  SLA<W> (mem)        80+zz+mem:7c    +
  //  SRA<W> (mem)        80+zz+mem:7d    +
  //  SLL<W> (mem)        80+zz+mem:7e    +
  //  SRL<W> (mem)        80+zz+mem:7f    +
  //  RLD [A],(mem)       80+mem:06       +
  //  RRD [A],(mem)       80+mem:07       +
  //

  zz  = getzz(b);
  mem = getmem(b);  

  //

  if ((len = retmem(b,m,mem)) == 0) {
    return 0;
  }

  R = getR(b+len);
  n = get3(b+len); 
  c = b[len++];

  switch (zz) {
  case 0:
    Regs = R8_names;
    break;
  case 1:
    Regs = R16_names;
    break;
  case 2:
    Regs = R32_names;
    break;
  }

  //

  if (c == 0x04 || c == 0x06 || c == 0x07 || c == 0x19 ||
      c >= 0x78 && c < 0x80  || c >= 0x38 && c < 0x40)  {

    switch (c) {
    case 0x38:  // ADD<W> (mem),#
      op = ADD;
      goto w_mem_nro;
    case 0x39:  // ADC<W> (mem),#
      op = ADC;
      goto w_mem_nro;
    case 0x3a:  // SUB<W> (mem),#
      op = SUB;
      goto w_mem_nro;
    case 0x3b:  // SBC<W> (mem),#
      op = SBC;
      goto w_mem_nro;
    case 0x3c:  // AND<W> (mem),# 
      op = AND;
      goto w_mem_nro;
    case 0x3d:  // XOR<W> (mem),#
      op = XOR;
      goto w_mem_nro;
    case 0x3e:  // OR<W> (mem),#
      op = OR;
      goto w_mem_nro;
    case 0x3f:  // CP<W> (mem),#
      op = CP;
w_mem_nro:
      if (zz == 0) {
        sprintf(dd->ops,"%s,%03Xh",m,get8u(b+len));
        len++;
        dd->opt = OPT_1_n_1_1;
      } else if (zz == 1) {
        op++;
        sprintf(dd->ops,"%s,%05Xh",m,get16u(b+len));
        len += 2;
        dd->opt = OPT_1_n_1_2;
      } else {
        // Got this far but this is not a valid instruction..
        return 0;
      }
      break;

    case 0x19:  // LD<W> (#16),(mem)
      dd->opt = OPT_1_n_1_2;
      op = zz == 0 ? LD : LDW;
      sprintf(dd->ops,"(%04Xh),%s",get16u(b+len),m);
      len += 2;
      break;

    case 0x06:  // RLD [A],(mem)
      op = RLD;
    case 0x07:  // RRD [A],(mem)
      if (op == INVALID) { op = RRD; }
      sprintf(dd->ops,"[A],%s",m);
      break;

    case 0x04:  // PUSH<W> (mem)
      op = PUSHW;
      goto w_mem;
    case 0x78:  // RLC<W> (mem)
      op = RLC;
      goto w_mem;
    case 0x79:  // RRC<W> (mem)
      op = RRC;
      goto w_mem;
    case 0x7a:  // RL<W> (mem)
      op = RL;
      goto w_mem;
    case 0x7b:  // RR<W> (mem)
      op = RR;
      goto w_mem;
    case 0x7c:  // SLA<W> (mem)
      op = SLA;
      goto w_mem;
    case 0x7d:  // SRA<W> (mem)
      op = SRA;
      goto w_mem;
    case 0x7e:  // SLL<W> (mem) 
      op = SLL;
      goto w_mem;
    case 0x7f:  // SRL<W> (mem)
      op = SRL;
w_mem:
      if (zz > 0) { op++; }
      sprintf(dd->ops,"%s",m);
      break;
    default:
      return 0;
    }
  } else {
    switch ( c & 0xf8 ) {
    case 0x60:  // INC<W> (mem)
      op = zz == 0 ? INC : INCW;
    case 0x68:  // DEC<W> (mem)
      if (op == INVALID) { op = zz == 0 ? DEC : DECW; }
      if (n == 0) { n = 8; }
      sprintf(dd->ops,"%d,%s",n,m);
      break;

    case 0x20:  // LD R,(mem)
      op = LD;
      goto r_mem;
    case 0x80:  // ADD R,(mem)
      op = ADD;
      goto r_mem;
    case 0x90:  // ADC R,(mem)
      op = ADC;
      goto r_mem;
    case 0xa0:  // SUB R,(mem)
      op = SUB;
      goto r_mem;
    case 0xb0:  // SBC R,(mem)
      op = SBC;
      goto r_mem;
    case 0xf0:  // CP R,(mem)
      op = CP;
      goto r_mem;
    case 0x40:  // MUL RR,(mem)
      op = MUL;
      goto r_mem;
    case 0x48:  // MULS RR,(mem)
      op = MULS;
      goto r_mem;
    case 0x50:  // DIV RR,(mem)
      op = DIV;
      goto r_mem;
    case 0x58:  // DIVS RR,(mem)
      op = DIVS;
      goto r_mem;
    case 0xc0:  // AND R,(mem)
      op = AND;
      goto r_mem;
    case 0xe0:  // OR R,(mem)
      op = OR;
      goto r_mem;
    case 0xd0:  // XOR R,(mem)
      op = XOR;
r_mem:
      sprintf(dd->ops,"%s,%s",Regs[R],m);
      break;

    case 0x30:  // EX (mem),R
      op = EX;
      goto mem_r;
    case 0x88:  // ADD (mem),R
      op = ADD;
      goto mem_r;
    case 0x98:  // ADC (mem),R
      op = ADC;
      goto mem_r;
    case 0xa8:  // SUB (mem),R
      op = SUB;
      goto mem_r;
    case 0xb8:  // SBC (mem),R
      op = SBC;
      goto mem_r;
    case 0xf8:  // CP (mem),R
      op = CP;
      goto mem_r;
    case 0xc8:  // AND (mem),R
      op = AND;
      goto mem_r;
    case 0xe8:  // OR (mem),R
      op = OR;
      goto mem_r;
    case 0xd8:  // XOR (mem),R
      op = XOR;
mem_r:
      sprintf(dd->ops,"%s,%s",m,Regs[R]);
      break;
    default:
      return 0;
    }
  }

  //

  dd->opf = opcode_names[op];
  return len;
}







