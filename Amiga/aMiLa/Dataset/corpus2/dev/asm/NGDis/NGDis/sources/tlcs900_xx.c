//
//
//

#include <stdio.h>
#include <string.h>
#include "tlcs900d.h"

int decode_xx( struct tlcs900d *dd ) {
    unsigned char *b = dd->buffer + dd->pos;
    int len = 0;
    int cc = getcc(b);
    int R = getR(b);
    enum opcodes op = INVALID;
    int d = dd->base + dd->pos;

    *dd->ops = '\0';
    dd->opt = OPT_1_0_0;

    //
    // Only few opcodes left..
    //   LD R,#             0+zzz+R:#   %0zzz0RRR:#
    //                                  %00100RRR
    //                                  %00110RRR
    //                                  %01000RRR
    //   PUSH R             28+s+R      %001s1RRR
    //   POP R              48+s+R      %010s1RRR
    //   JR [cc,]$+2+d8     60+cc:d8    %0110cccc:d8
    //   JRL [cc,]$+3+d16   70+cc:d16   %0111cccc:d16
    //

  switch (*b & 0xf8) {
  case 0x20:  // LD R,#8
    op = LD;
    dd->opt = OPT_1_1_0;
    sprintf(dd->ops,"%s,%03Xh",R8_names[R],get8u(b+1) );
    len = 1+1;
    break;
  case 0x30:  // LD R,#16
    op = LD;
    dd->opt = OPT_1_2_0;
    sprintf(dd->ops,"%s,%05Xh",R16_names[R],get16u(b+1) );
    len = 1+2;
    break;
  case 0x40:  // LD R,#32
    op = LD;
    dd->opt = OPT_1_4_0;
    sprintf(dd->ops,"%s,%09Xh",R32_names[R],get32u(b+1) );
    len = 1+4;
    break;
  case 0x28:  // PUSH R (word)
    op = PUSH;
    sprintf(dd->ops,"%s",R16_names[R] );
    len = 1;
    break;
  case 0x38:  // PUSH R (long)
    op = PUSH;
    sprintf(dd->ops,"%s",R32_names[R] );
    len = 1;
    break;
  case 0x48:  // POP R (word)
    op = POP;
    sprintf(dd->ops,"%s",R16_names[R] );
    len = 1;
    break;
  case 0x58:  // POP R (long)
    op = POP;
    sprintf(dd->ops,"%s",R32_names[R] );
    len = 1;
    break;
  default:
    if ((*b & 0x70) == 0x70) {
      //   JRL [cc,]$+3+d16   70+cc:d16   %0111cccc:d16
      d = d + get16(b+1) + 3;
      op = JRL; 
      len = 1+2;
      dd->opt = OPT_1_2_0;
    } else if ((*b & 0x60) == 0x60) {
      //   JR [cc,]$+2+d8     60+cc:d8    %0110cccc:d8
      d = d + get8(b+1) + 2;
      op = JR;
      len = 1+1;
      dd->opt = OPT_1_1_0;
    } else {
      // unknown instruction..
      op = INVALID;
      break;
    }

    // do JR or JRL..

    if (cc != 0x08) {
      sprintf(dd->ops,"%s,%07Xh",cc_names[cc],d);
    } else {
      sprintf(dd->ops,"%07Xh",d);
    }
    break;
  }

  dd->opf = opcode_names[op];
  return len;
}

