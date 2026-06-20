//
//
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "tlcs900d.h"


int decode_zz_r( struct tlcs900d *dd ) {
  unsigned char *b = dd->buffer + dd->pos;
  unsigned char c;
  char **regs;
  char **Regs;
  int zz = getzz(b);
  int r = getr(b);
  int len = 1;
  enum opcodes op = INVALID;
  int base;

  switch (zz) {
  case 0x00:
    Regs = R8_names;
    break;
  case 0x01:
    Regs = R16_names;
    break;
  case 0x02:
    Regs = R32_names;
    break;
  case 0x03:
  default:
    return 0;
  }

  //

  regs = getregs( r, zz );

  if (r < 0) {
    r = b[len++];
    dd->opt = OPT_1_1_1;
  }

  //
  // Following many opcodes:
  //   LD r,#     C8+zz+r:03:#    * 0x03-0x10
  //   PUSH r     C8+zz+r:04      *
  //   POP r      C8+zz+r:05      *
  //   CPL r      C8+zz+r:06      *
  //   NEG r      C8+0z+r:07      *
  //   MUL rr,#   C8+zz+r:08:#    *
  //   MULS rr,#  C8+zz+r:09:#    *
  //   DIV rr,#   C8+zz+r:0A:#    *
  //   DIVS rr,#  C8+zz+r:0B:#    *
  //   LINK r,d16 C8+10+r:0C:d16  *
  //   UNLK r     C8+10+r:0D      *
  //   BS1F A,r   C8+01+r:0E      *
  //   BS1B A,r   C8+01+r:0F      *
  //   DAA r      C8+00+r:10      *

  //   EXTZ r     C8+zz+r:12      * 0x12-0x14
  //   EXTS r     C8+zz+r:13      *
  //   PAA r      C8+zz+r:14      *

  //   MIRR r     C8+01+r:16      * 0x16

  //   MULA rr    C8+01+r:19      * 0x19

  //   DJNZ [r,]$+3/4+d8  C8+zz+r:1C:d8 * 0x1c

  //   ANDCF #4,r C8+zz+r:20:#4   * 0x20-0x24
  //   ORCF #4,r  C8+zz+r:21:#4   *
  //   XORCF #4,r C8+zz+r:22:#4   *
  //   LDCF #4,r  C8+zz+r:23:#4   *
  //   STCF #4,r  C8+zz+r:24:#4   *

  //   ANDCF A,r  C8+zz+r:28      * 0x28-0x2c
  //   ORCF A,r   C8+zz+r:29      *
  //   XORCF A,r  C8+zz+r:2A      *
  //   LDCF A,r   C8+zz+r:2B      *
  //   STCF A,r   C8+zz+r:2C      *
  //   LDC cr,r   C8+zz+r:2E      *
  //   LDC r,cr   C8+zz+r:2F      *

  //   RES #4,r   C8+zz+r:30:#4   * 0x30-0x34
  //   SET #4,r   C8+zz+r:31:#4   *
  //   CHG #4,r   C8+zz+r:32:#4   *
  //   BIT #4,r   C8+zz+r:33:#4   *
  //   TSET #4,r  C8+zz+r:34:#4   *

  //   MINC1 #,r  C8+01+r:38:#-1  * 0x38-0x3a
  //   MINC2 #,r  C8+01+r:39:#-2  *
  //   MINC4 #,r  C8+01+r:3A:#-4  *

  //   MDEC1 #,r  C8+01+r:3C:#-1  * 0x3c-0x3e
  //   MDEC2 #,r  C8+01+r:3D:#-2  *
  //   MDEC4 #,r  C8+01+r:3E:#-4  *

  //   ADD r,#    C8+zz+r:C8:#    * 0xc8-0xcf
  //   ADC r,#    C8+zz+r:C9:#    *
  //   SUB r,#    C8+zz+r:CA:#    *
  //   SBC r,#    C8+zz+r:CB:#    *
  //   AND r,#    C8+zz+r:CC:#    *
  //   XOR r,#    C8+zz+r:CD:#    *
  //   OR r,#     C8+zz+r:CE:#    *
  //   CP r,#     C8+zz+r:CF:#    *

  //   RLC #4,r   C8+zz+r:E8:#4   * 0xe8-0xef
  //   RRC #4,r   C8+zz+r:E9:#4   *
  //   RL #4,r    C8+zz+r:EA:#4   *
  //   RR #4,r    C8+zz+r:EB:#4   *
  //   SLA #4,r   C8+zz+r:EC:#4   *
  //   SRA #4,r   C8+zz+r:ED:#4   *
  //   SLL #4,r   C8+zz+r:EE:#4   *
  //   SRL #4,r   C8+zz+r:EF:#4   *

  //   RLC A,r    C8+zz+r:F8      * 0xf8-0xff
  //   RRC A,r    C8+zz+r:F9      *
  //   RL A,r     C8+zz+r:FA      *
  //   RR A,r     C8+zz+r:FB      *
  //   SLA A,r    C8+zz+r:FC      *
  //   SRA A,r    C8+zz+r:FD      *
  //   SLL A,r    C8+zz+r:FE      *
  //   SRL A,r    C8+zz+r:FF      *

  // groups or 8s or 16s

  //   MUL RR,r   C8+zz+r:40+R    * 0x40-0xc7
  //   MULS RR,r  C8+zz+r:48+R    *
  //   DIV RR,r   C8+zz+r:50+R    *
  //   DIVS RR,r  C8+zz+r:58+R    *
  //   INC #3,r   C8+zz+r:60+#3   *
  //   DEC #3,r   C8+zz+r:68+#3   *
  //   SCC cc,r   C8+zz+r:70+cc   *
  //   ADD R,r    C8+zz+r:80+R    *
  //   LD R,r     C8+zz+r:88+R    *
  //   ADC R,r    C8+zz+r:90+R    *
  //   LD r,R     C8+zz+r:98+R    *
  //   SUB R,r    C8+zz+r:A0+R    *
  //   LD r,#3    C8+zz+r:A8+#3   *
  //   SBC R,r    C8+zz+r:B0+R    *
  //   EX R,r     C8+zz+r:B8+R    *
  //   AND R,r    C8+zz+r:C0+R    *

  //   XOR R,r    C8+zz+r:D0+R    * 0xd0-0xe7
  //   CP r,#3    C8+zz+r:D8+#3   *
  //   OR R,r     C8+zz+r:E0+R    *

  //   CP R,r     C8+zz+r:F0+R    * 0xf0-0xf7
  //   

  c = b[len++];

  if (c >= 0x40 && c < 0xc8 || c >= 0xd0 && c < 0xe8 || c >= 0xf0 && c < 0xf8) {
    // xx+R , xx+#3 , 70+cc 

    switch (c & 0xf8) {
    case 0x40:  // MUL RR,r
      op = MUL;
      goto zz_R;
    case 0x48:  // MULS RR,r
      op = MULS;
      goto zz_R;
    case 0x50:  // DIV RR,r
      op = DIV;
      goto zz_R;
    case 0x58:  // DIVS RR,r
      op = DIVS;
      goto zz_R;
    case 0x80:  // ADD R,r
      op = ADD;
      goto zz_R;
    case 0x88:  // LD R,r
      op = LD;
      goto zz_R;
    case 0x90:  // ADC R,r
      op = ADC;
      goto zz_R;
    case 0xa0:  // SUB R,r
      op = SUB;
      goto zz_R;
    case 0xb0:  // SBC R,r
      op = SBC;
      goto zz_R;
    case 0xb8:  // EX R,r
      op = EX;
      goto zz_R;
    case 0xc0:  // AND R,r
      op = AND;
      goto zz_R;
    case 0xd0:  // XOR R,r
      op = XOR;
      goto zz_R;
    case 0xe0:  // OR R,r
      op = OR;
      goto zz_R;
    case 0xf0:  // CP R,r
      op = CP;
zz_R:
      sprintf(dd->ops,"%s,%s",Regs[c & 0x07],regs[r]);
      dd->opt = OPT_1_n_1;
      break;

    case 0x98:  // LD r,R
      op = LD;
      sprintf(dd->ops,"%s,%s",regs[r],Regs[c & 0x07]);
      dd->opt = OPT_1_n_1;
      break;

    case 0x60:  // INC #3,r
      op = INC;
    case 0x68:  // DEC #3,r
      if (op == INVALID) { op = DEC; }
      if ((c &= 0x07) == 0) { c = 8; }
      sprintf(dd->ops,"%d,%s",c,regs[r]);
      dd->opt = OPT_1_1_0;
      break;

    case 0xa8:  // LD r,#3
      op = LD;
    case 0xd8:  // CP r,#3
      if (op == INVALID) { op = CP; }
      sprintf(dd->ops,"%s,%03Xh",regs[r],c & 0x07);
      dd->opt = OPT_1_1_0;
      break;

    case 0x70:  // SCC cc,r
    case 0x78: 
      op = SCC;
      sprintf(dd->ops,"%s,%s",cc_names[c & 0x0f],regs[r]);
      dd->opt = OPT_1_n_1;
      break;

    default:
      // unknow opcode..
      return 0;
    }
  } else {
    switch (c) {
    case 0x03:  // LD r,#
      op = LD;
      goto r_num;
    case 0x08:  // MUL rr,#
      op = MUL;
      goto r_num;
    case 0x09:  // MULS rr,#
      op = MULS;
      goto r_num;
    case 0x0a:  // DIV rr,#
      op = DIV;
      goto r_num;
    case 0x0b:  // DIVS rr,#
      op = DIVS;
      goto r_num;
    case 0xc8:  // ADD r,#
      op = ADD;
      goto r_num;
    case 0xc9:  // ADC r,#
      op = ADC;
      goto r_num;
    case 0xca:  // SUB r,#
      op = SUB;
      goto r_num;
    case 0xcb:  // SBC r,#
      op = SBC;
      goto r_num;
    case 0xcc:  // AND r,#
      op = AND;
      goto r_num;
    case 0xcd:  // XOR r,#
      op = XOR;
      goto r_num;
    case 0xce:  // OR r,#
      op = OR;
      goto r_num;
    case 0xcf:  // CP r,#
      op = CP;
r_num:
      if (zz == 0) {
        sprintf(dd->ops,"%s,%03Xh",regs[r],get8u(b+len));
        len++;
        dd->opt = OPT_1_n_1_1;
      } else if (zz == 1) {
        sprintf(dd->ops,"%s,%05Xh",regs[r],get16u(b+len));
        len += 2;
        dd->opt = OPT_1_n_1_2;
      } else if (zz == 2) {
        sprintf(dd->ops,"%s,%09Xh",regs[r],get32u(b+len));
        len += 4;
        dd->opt = OPT_1_n_1_4;
      } else {
        // Hmmm not a valid instruction..
        return 0;
        assert(zz < 3);
      }
      break;

    case 0x20:  // ANDCF #4,r
      op = ANDCF;
      goto num_r;
    case 0x21:  // ORCF #4,r
      op = ORCF;
      goto num_r;
    case 0x22:  // XORCF #4,r
      op = XORCF;
      goto num_r;
    case 0x23:  // LDCF #4,r
      op = LDCF;
      goto num_r;
    case 0x24:  // STCF #4,r
      op = STCF;
      goto num_r;
    case 0x30:  // RES #4,r
      op = RES;
      goto num_r;
    case 0x31:  // SET #4,r
      op = SET;
      goto num_r;
    case 0x32:  // CHG #4,r
      op = CHG;
      goto num_r;
    case 0x33:  // BIT #4,r
      op = BIT;
      goto num_r;
    case 0x34:  // TSET #4,r
      op = TSET;
      goto num_r;
    case 0xe8:  // RLC #4,r
      op = RLC;
      goto num_r;
    case 0xe9:  // RRC #4,r
      op = RRC;
      goto num_r;
    case 0xea:  // RL #4,r
      op = RL;
      goto num_r;
    case 0xeb:  // RR #4,r
      op = RR;
      goto num_r;
    case 0xec:  // SLA #4,r
      op = SLA;
      goto num_r;
    case 0xed:  // SRA #4,r
      op = SRA;
      goto num_r;
    case 0xee:  // SLL #4,r
      op = SLL;
      goto num_r;
    case 0xef:  // SRL #4,r
      op = SRL;
num_r:
      sprintf(dd->ops,"%03Xh,%s", b[len++] & 0x0f, regs[r]);
      dd->opt = OPT_1_n_1;
      break;

    case 0x04:  // PUSH r
      op = PUSH;
      goto just_r;
    case 0x05:  // POP r
      op = POP;
      goto just_r;
    case 0x06:  // CPL r
      op = CPL;
      goto just_r;
    case 0x07:  // NEG r
      op = NEG;
      goto just_r;
    case 0x0d:  // UNLK r
      op = UNLK;
      goto just_r;
    case 0x10:  // DAA r
      op = DAA;
      goto just_r;
    case 0x12:  // EXTZ r
      op = EXTZ;
      goto just_r;
    case 0x13:  // EXTS r
      op = EXTS;
      goto just_r;
    case 0x14:  // PAA r
      op = PAA;
      goto just_r;
    case 0x16:  // MIRR r
      op = MIRR;
      goto just_r;
    case 0x19:  // MULA rr
      op = MULA;
just_r:
      sprintf(dd->ops,"%s",regs[r]);
      dd->opt = OPT_1_n_1;
      break;

    case 0x1c:  // DJNZ [r],$+3/4+d8
      base = dd->base + dd->pos + get8(b+len);
      op = DJNZ;
      dd->opt = OPT_1_n_1_1;

      if (len > 2) {
        // using extended r code..
        base += 4;
      } else {
        base += 3;
      }
      if (r == 2 && zz == 0) {  // i.e. r == B
        sprintf(dd->ops,"%07Xh",base);
      } else {
        sprintf(dd->ops,"%s,%07Xh",regs[r],base);
      }
      len++;
      break;

    case 0x0e:  // BS1F A,r
      op = BS1F;
      goto a_r;
    case 0x0f:  // BS1B A,r
      op = BS1B;
      goto a_r;
    case 0x28:  // ANDCF A,r
      op = ANDCF;
      goto a_r;
    case 0x29:  // ORCF A,r
      op = ORCF;
      goto a_r;
    case 0x2a:  // XORCF A,r
      op = XORCF;
      goto a_r;
    case 0x2b:  // LDCF A,r
      op = LDCF;
      goto a_r;
    case 0x2c:  // STCF A,r
      op = STCF;
      goto a_r;
    case 0xf8:  // RLC A,r
      op = RLC;
      goto a_r;
    case 0xf9:  // RRC A,r
      op = RRC;
      goto a_r;
    case 0xfa:  // RL A,r
      op = RL;
      goto a_r;
    case 0xfb:  // RR A,r
      op = RR;
      goto a_r;
    case 0xfc:  // SLA A,r
      op = SLA;
      goto a_r;
    case 0xfd:  // SRA A,r
      op = SRA;
      goto a_r;
    case 0xfe:  // SLL A,r
      op = SLL;
      goto a_r;
    case 0xff:  // SRL A,r
      op = SRL;
a_r:
      sprintf(dd->ops,"A,%s",regs[r]);
      dd->opt = OPT_1_n_1;
      break;

    case 0x2e:  // LDC cr,r
      dd->opt = OPT_1_n_1_1;
      op = LDC;
      sprintf(dd->ops,"%s,%s",cr_names[b[len++]],regs[r]);
      break;
    case 0x2f:  // LDC r,cr
      dd->opt = OPT_1_n_1_1;
      op = LDC;
      sprintf(dd->ops,"%s,%s",regs[r],cr_names[b[len++]]);
      break;

    case 0x0c:  // LINK r,d16
      op = LINK;
      sprintf(dd->ops,"%s,%05Xh",regs[r],get16(&b[len]) );
      len += 2;
      dd->opt = OPT_1_n_1_2;
      break;
      
    case 0x38:    // MINC1 #,r
      op = MINC1;
      goto minc_mdec;
    case 0x39:    // MINC2 #,r
      op = MINC2;
      goto minc_mdec;
    case 0x3a:    // MINC4 #,r
      op = MINC4;
      goto minc_mdec;
    case 0x3c:    // MDEC1 #,r
      op = MDEC1;
      goto minc_mdec;
    case 0x3d:    // MDEC2 #,r
      op = MDEC2;
      goto minc_mdec;
    case 0x3e:    // MDEC4 #,r
      op = MDEC4;
minc_mdec:
      sprintf(dd->ops,"%05Xh,%s",get16u(b+len),regs[r]);
      len += 2;
      dd->opt = OPT_1_n_1_1;
      break;

    default:
      // unknown opcode..
      return 0;
    }
  }

  dd->opf = opcode_names[op];
  return len;
}

