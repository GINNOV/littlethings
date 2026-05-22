//
//
//

#include <stdio.h>
#include <string.h>
#include "tlcs900d.h"

//
//
//

int decode_B0_mem( struct tlcs900d * dd ) {
  char m[OPS_LEN];
  enum opcodes op = INVALID;
  unsigned char *b = dd->buffer + dd->pos;
  int len = 1;
  int n;
  int zz;
  int R;

  *dd->ops = '\0';
  dd->opt = OPT_1_n_1;

  //
  // Following opcodes:
  //   LD (mem),R         B0+mem:40+zz+R  +
  //   LD<W> (mem),#      B0+mem:00+z:#   +
  //   LD<W> (mem),(#16)  B0+mem:14+z:#16 +
  //   POP<W> (mem)       B0+mem:04+z     +
  //   LDA R,mem          B0+mem:20+s+R   +
  //   LDAR R,$+4+d16     F3:13:d16:20+s+R    +
  //   LDCF #3,(mem)      B0+mem:98+#3    +
  //   LDCF A,(mem)       B0+mem:2B       +
  //   STCF #3,(mem)      B0+mem:A0+#3    +
  //   STCF A,(mem)       B0+mem:2C       +
  //   ANDCF #3,(mem)     B0+mem:80+#3    +
  //   ANDCF A,(mem)      B0+mem:28       +
  //   ORCF #3,(mem)      B0+mem:88+#3    +
  //   ORCF A,(mem)       B0+mem:29       +
  //   XORCF #3,(mem)     B0+mem:90+#3    +
  //   XORCF A,(mem)      B0+mem:2A       +
  //   BIT #3,(mem)       B0+mem:C8+#3    +
  //   RES #3,(mem)       B0+mem:B0+#3    +
  //   SET #3,(mem)       B0+mem:B8+#3    +
  //   CHG #3,(mem)       B0+mem:C0+#3    +
  //   TSET #3,(mem)      B0+mem:A8+#3    +
  //   JP [cc,]mem        B0+mem:D0+cc    +
  //   CALL [cc,]mem      B0+mem:E0+cc    +
  //   RET cc             B0:F0+cc        +
  //

  if (*b == 0xf3 && b[1] == 0x13) {  // LDAR..
    int32_t d16 = get16(b+2) + 4 + dd->base + dd->pos;

    dd->opf = opcode_names[LDAR];

    if (b[4] & 0x20) {
        sprintf(dd->ops,"%s,%09Xh",R32_names[ getR(b+4) ],d16);
    } else {
        sprintf(dd->ops,"%s,%09Xh",R16_names[ getR(b+4) ],d16);
    }
    dd->opt = OPT_2_1_2;
    return 5;
  }
  if (*b == 0xb0 && b[1] >= 0xf0) {  // RET cc..
    dd->opf = opcode_names[RET];
    strcpy(dd->ops,cc_names[getcc(b+1)]);
    dd->opt = OPT_1_1_0;
    return 2; 
  }

 // Another huge switch based on the nth byte..

  n = retmem(b,m,getmem(b));
  if (n == 0) { return 0; }

  switch (b[n]) {
  case 0xe0: case 0xe1: case 0xe2: case 0xe3:
  case 0xe4: case 0xe5: case 0xe6: case 0xe7:
  case 0xe8: case 0xe9: case 0xea: case 0xeb:
  case 0xec: case 0xed: case 0xee: case 0xef:
    dd->opf = opcode_names[CALL];
    if (getcc(b+n) != 8) {
      sprintf(dd->ops,"%s,%s",cc_names[getcc(b+n)],m);
    } else {
      strcpy(dd->ops,m);
    }
    dd->opt = OPT_1_n_1;
    return n+1;
  case 0xd0: case 0xd1: case 0xd2: case 0xd3:
  case 0xd4: case 0xd5: case 0xd6: case 0xd7:
  case 0xd8: case 0xd9: case 0xda: case 0xdb:
  case 0xdc: case 0xdd: case 0xde: case 0xdf:
    dd->opf = opcode_names[JP];
    if (getcc(b+n) != 8) {
      sprintf(dd->ops,"%s,%s",cc_names[getcc(b+n)],m);
    } else {
      strcpy(dd->ops,m);
    }
    dd->opt = OPT_1_n_1;
    return n+1;
  case 0x28:  // ANDCF A,(mem)
    dd->opf = opcode_names[ANDCF];
    sprintf(dd->ops,"A,%s",m);      
    return n+1;
  case 0x29:  // ORCF A,(mem)
    dd->opf = opcode_names[ORCF];
    sprintf(dd->ops,"A,%s",m);      
    return n+1;
  case 0x2a:  // XORCF A,(mem)
    dd->opf = opcode_names[XORCF];
    sprintf(dd->ops,"A,%s",m);      
    return n+1;
  case 0x2b:  // LDCF A,(mem)
    dd->opf = opcode_names[LDCF];
    sprintf(dd->ops,"A,%s",m);      
    return n+1;
  case 0x2c:  // STCF A,(mem)
    dd->opf = opcode_names[STCF];
    sprintf(dd->ops,"A,%s",m);      
    return n+1;
  case 0x00:  // LD (mem),#8
    dd->opf = opcode_names[LD];
    sprintf(dd->ops,"%s,%03Xh",m,get8u(b+n+1));      
    dd->opt = OPT_1_n_1_1;
    return n+2;
  case 0x02:  // LDW (mem),#16
    dd->opf = opcode_names[LDW];
    sprintf(dd->ops,"%s,%05Xh",m,get16u(b+n+1));      
    dd->opt = OPT_1_n_1_2;
    return n+3;
  case 0x04:  // POP (mem)
    dd->opf = opcode_names[POP];
    strcpy(dd->ops,m);
    return n+1;
  case 0x06:  // POPW (mem)
    dd->opf = opcode_names[POPW];
    strcpy(dd->ops,m);
    return n+1;
  case 0x14:  // LD (mem),(#16)
    dd->opf = opcode_names[LD];
    sprintf(dd->ops,"%s,(%04Xh)",m,get16u(b+n+1) );      
    return n+3;
  case 0x16:  // LDW (mem),(#16)
    dd->opf = opcode_names[LDW];
    sprintf(dd->ops,"%s,(%04Xh)",m,get16u(b+n+1) );      
    dd->opt = OPT_1_n_2;
    return n+3;
  default:
    break;
  }

  //
  //
  //

  zz = getzz(b+n);
  R = getR(b+n);

  switch (b[n] & 0xf8) {
  case 0x40:  // LD (mem),R
    op = LD;
    sprintf(dd->ops,"%s,%s",m,R8_names[R]);
    len = n+1;
    break;
  case 0x50:  // LD (mem),R
    op = LD;
    sprintf(dd->ops,"%s,%s",m,R16_names[R]);
    len = n+1;
    break;
  case 0x60:  // LD (mem),R
    op = LD;
    sprintf(dd->ops,"%s,%s",m,R32_names[R]);
    len = n+1;
    break;
  case 0x20:
    op = LDA; // LDA R,(mem)
    sprintf(dd->ops,"%s,%s",R16_names[R],m);
    len = n+1;
    break;
  case 0x30:
    op = LDA; // LDA R,(mem)
    sprintf(dd->ops,"%s,%s",R32_names[R],m);
    len = n+1;
    break;
  case 0x98:  // LDCF #3,(mem)
    op = LDCF;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xa0:  // STCF #3,(mem)
    op = STCF;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0x80:  // ANDCF #3,(mem)
    op = ANDCF;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0x88:
    op = ORCF;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0x90:
    op = XORCF;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xc8:
    op = BIT;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xb0:
    op = RES;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xb8:
    op = SET;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xc0:
    op = CHG;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  case 0xa8:
    op = TSET;
    sprintf(dd->ops,"%d,%s",R,m);  // R is now #3
    len = n+1;
    break;
  default:  // INVALID
    len = 0;
    op = INVALID;
    break;
  }

  //

  dd->opf = opcode_names[op];
  return len;
}

