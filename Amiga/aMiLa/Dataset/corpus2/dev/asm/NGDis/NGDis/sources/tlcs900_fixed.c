/*
 *
 *
 *
 */

#include <stdio.h>
#include <string.h>
#include "tlcs900d.h"

/*
 *
 *
 *
 */

int decode_fixed( struct tlcs900d *dd ) {
  unsigned char *b = dd->buffer + dd->pos;
  int len = 1;
  enum opcodes op;
  int d;

  *dd->ops = '\0';
  dd->opt = OPT_1_0_0;
  op = INVALID;

  switch (*b) {
  case 0x08: // LD (#8),#8
    op = LD;
    sprintf(dd->ops,"(%02Xh),%03Xh",get8u(b+1),get8u(b+2) );
    len = 1+2;
    dd->opt = OPT_1_1_1;
    break;
  case 0x0a: // LDW (#8),#16
    op = LDW;
    sprintf(dd->ops,"(%02Xh),%05Xh",get8u(b+1),get16u(b+2) );
    len = 1+3;
    dd->opt = OPT_1_1_2;
    break;
  case 0x09: // PUSH #8
    op = PUSH;
    sprintf(dd->ops,"%03Xh",get8u(b+1) );
    len = 1+1;
    dd->opt = OPT_1_1_0;
    break;
  case 0x0b: // PUSHW #16
    op = PUSHW;
    sprintf(dd->ops,"%05Xh",get16u(b+1) );
    len = 1+2;
    dd->opt = OPT_1_2_0;
    break;
  case 0x18: // PUSH F
    op = PUSH;
    sprintf(dd->ops,"F");
    break;
  case 0x14: // PUSH A
    op = PUSH;
    sprintf(dd->ops,"A");
    break;
  case 0x19: // POP F
    op = POP;
    sprintf(dd->ops,"F");
    break;
  case 0x15: // POP A
    op = POP;
    sprintf(dd->ops,"A");
    break;
  case 0x16: // EX F,F'
    op = EX;
    sprintf(dd->ops,"F,F'");
    break;
  case 0x10: // RCF
    op = RCF;
    break;
  case 0x11: // SCF
    op = SCF;
    break;
  case 0x12: // CCF
    op = CCF;
    break;
  case 0x13: // ZCF
    op = ZCF;
    break;
  case 0x00: // NOP
    op = NOP;
    break;
  case 0x06: // EI [#3] / DI
    if (b[1] == 0x07) {
      op = DI;
    } else {
      op = EI;
      sprintf(dd->ops,"%d",b[1] & 0x07);
    }
    len = 1+1;
    dd->opt = OPT_1_1_0;
    break;
  case 0x02: // PUSH SR
    op = PUSH;
    sprintf(dd->ops,"SR");
    break;
  case 0x03: // POP SR
    op = POP;
    sprintf(dd->ops,"SR");
    break;
  case 0x05: // HALT
    op = HALT;
    break;
  case 0x0c: // INCF
    op = INCF;
    break;
  case 0x0d: // DECF
    op = DECF;
    break;
  case 0x1a: // JP #16
    op = JP;
    sprintf(dd->ops,"%05Xh",get16u(b+1));
    len = 1+2;
    dd->opt = OPT_1_2_0;
    break;
  case 0x1b: // JP #24
    op = JP;
    sprintf(dd->ops,"%07Xh",get24u(b+1));
    len = 1+3;
    dd->opt = OPT_1_3_0;
    break;
  case 0x1c: // CALL #16
    op = CALL;
    sprintf(dd->ops,"%05Xh",get16u(b+1));
    len = 1+2;
    dd->opt = OPT_1_2_0;
    break;
  case 0x1d: // CALL #24
    op = CALL;
    sprintf(dd->ops,"%07Xh",get24u(b+1));
    len = 1+3;
    dd->opt = OPT_1_3_0;
    break;
  case 0x1e: // CALR d16 !!!!
    op = CALR;
    d = dd->base + dd->pos + 3 + get16(b+1);
    sprintf(dd->ops,"%07Xh",d);   // relative to the address..
    len = 1+2;
    dd->opt = OPT_1_2_0;
    break;
  case 0x0e: // RET
    op = RET;
    break;
  case 0x0f: // RETD d16
    op = RETD;
    sprintf(dd->ops,"%05Xh",get16(b+1));
    len = 1+2;
    dd->opt = OPT_1_2_0;
    break;
  case 0x07: // RETI
    op = RETI;
    break;
  case 0xf7: // LDX (#8),#8
    op = LDX;
    sprintf(dd->ops,"(%02Xh),%03Xh",get8u(b+2),get8u(b+4));
    len = 1+5;
    dd->opt = OPT_1_1_1_1_1_1;
    break;
  case 0xf8: // SWI [#3];
  case 0xf9: case 0xfa: case 0xfb:
  case 0xfc: case 0xfd: case 0xfe: case 0xff:
    op = SWI;
    sprintf(dd->ops,"%d",*b & 0x07);
    break;
  case 0x17: // LDF #3
    op = LDF;
    sprintf(dd->ops,"%d",get8u(b+1) & 0x07);
    len = 1+1;
    dd->opt = OPT_1_1_0;
    break;
  default:
    len = 0;
    break;
  }

  dd->opf = opcode_names[op];
  return len;

}
