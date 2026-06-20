//
//
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "tlcs900d.h"


int decode_zz_R( struct tlcs900d *dd ) {
  unsigned char *b = dd->buffer + dd->pos;
  char *a;
  int zz = getzz(b);
  int R = getR(b);
  int w = *b & 0x07;
  int len = 1;
  enum opcodes op = INVALID;

  switch (zz) {
  case 0x00:
    a = "A";
    break;
  case 0x01:
    a = "WA";
    break;
  case 0x02:
  case 0x03:
  default:
    // Not a valid instruction..
    return 0;
  }

  //
  // Following many opcodes:
  //   LDI<W>  [(XDE+),(XhL+)]    83+zz:10
  //   LDI<W>  (XIX+),(XIY+)      85+zz:10
  //   LDIR<W> [(XDE+),(XhL+)]    83+zz:11
  //   LDIR<W> (XIX+),(XIY+)      85+zz:11
  //   LDD<W>  [(XDE-),(XhL-)]    83+zz:12
  //   LDD<W>  (XIX-),(XIY-)      85+zz:12
  //   LDDR<W> [(XDE-),(XhL-)]    83+zz:13
  //   LDDR<W> (XIX-),(XIY-)      85+zz:13

  //   CPI     [A/WA,(R+)]        80+zz+R:14
  //   CPIR    [A/WA,(R+)]        80+zz+R:15
  //   CPD     [A/WA,(R-)]        80+zz+R:16
  //   CPDR    [A/WA,(R-)]        80+zz+R:17
  //
  // Here the zz is actually 0z because none
  // of these instructions use longword size.
  //
  //

  switch (b[len++]) {
  case 0x10:  // LDI
    op = LDI;
  case 0x11:  // LDIR
    if (op == INVALID) { op = LDIR; }
    if (zz == 1) { op++; }
    if (w == 5) {
      strcpy(dd->ops,"(XIX+),(XIY+)");
    } else {
      strcpy(dd->ops,"[(XDE+),(XhL+)]");
    }
    break;

  case 0x12:  // LDD
    op = LDD;
  case 0x13:  // LDDR
    if (op == INVALID) { op = LDDR; }
    if (zz == 1) { op++; }
    if (w == 5) {
      strcpy(dd->ops,"(XIX-),(XIY-)");
    } else {
      strcpy(dd->ops,"[(XDE-),(XhL-)]");
    }
    break;

  case 0x14:  // CPI [A/WA,(R+)]
    op = CPI;
  case 0x15:  // CPIR [A/WA,(R+)]
    if (op == INVALID) { op = CPIR; }
    sprintf(dd->ops,"%s,(%s+)",a,R32_names[R]);
    break;

  case 0x16:  // CPD [A/WA,(R-)]
    op = CPD;
  case 0x17:  // CPDR [A/WA,(R-)]
    if (op == INVALID) { op = CPDR; }
    sprintf(dd->ops,"%s,(%s-)",a,R32_names[R]);
    break;

  default:
    // ...
    return 0;
  }


  dd->opf = opcode_names[op];
  dd->opt = OPT_1_1_0;
  return len;
}







