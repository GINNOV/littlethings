/* XFD external slave for SZDD format by Kyzer/CSG <kyzer@4u.net>
 * This is no longer supported -- see the assembler XFD slave,
 * or the portable C szddexpand.c (or the Linux mscompress package)
 */

#include <libraries/xfdmaster.h>
#include <proto/exec.h>
#include <exec/memory.h>
#include "SDI_compiler.h"

#define SZDD_OVERRUN  (144)    /* 8 matches, at maximum length */
#define SZDD_MINLEN   (14)     /* 4+4+2+4 = 14 byte header (and 0 data) */
#define SZDD_WNDSIZE  (4096)   /* LZ sliding window size (4k) */

static char version[]="$VER: SZDD 1.3 (29.06.2000) by <kyzer@4u.net>";


ASM(BOOL) SZDD_recog(REG(a0, STRPTR buf), REG(d0, ULONG length)
  REG(a1, struct xfdRecogResult *rr)) {
  if (buf[0]=='S' && buf[1]=='Z' && buf[2] =='D' && buf[3]=='D') {
    rr->xfdrr_MinTargetLen = SZDD_OVERRUN + (
      rr->xfdrr_FinalTargetLen =
      buf[10] | (buf[11]<<8) | (buf[12]<<16) | (buf[13]<<24)
    );
    return (BOOL) 1;
  }
  return (BOOL) 0;
}

ASM(BOOL) SZDD_decrunch(REG(a0, struct xfdBufferInfo * xbi),
  REG(a6, struct xfdMasterBase *xfdMasterBase)) {

  struct ExecBase *SysBase = xfdMasterBase->xfdm_ExecBase;

  UBYTE *rep, mask, bits;
  int offset, length, clrlen;

  UBYTE *src  = (UBYTE *) xbi->xfdbi_SourceBuffer + 14;
  UBYTE *dest = (UBYTE *) xbi->xfdbi_UserTargetBuf;
  UBYTE *ends = src  + xbi->xfdbi_SourceBufLen;
  UBYTE *endd = dest + xbi->xfdbi_TargetBufSaveLen;
  UBYTE *base = dest;
  int posn = SZDD_WNDSIZE-16;

  while (src < ends) {
    bits = *src++;
    for (mask = 0x01; mask & 0xFF; mask <<= 1) {
      if (bits & mask) posn++, *dest++ = *src++;
      else {
        offset  = *src++; length = *src++;
        offset |= (length << 4) & 0xF00;
        length  = (length & 0x0F) + 3;

        /* translate absolute 4k buffer offset into real window offset */
        posn &= SZDD_WNDSIZE-1; if (offset > posn) posn += SZDD_WNDSIZE;
        rep = dest - posn + offset;
        posn += length;

        /* if repeat starts before actual data, write spaces */
        while (rep < base && length-- > 0) rep++, *dest++ = ' ';

        /* copy out repeat */
        while (length-- > 0) *dest++ = *rep++;
      }

    }

    /* at worst, we could overrun dest by (15+3)*8 = 144 bytes */
    if (dest >= endd) return 1;
  }

  /* bad exit - run out of src */
  xbi->xfdbi_Error = XFDERR_CORRUPTEDDATA;
  return 0;
}

struct xfdSlave FirstSlave = {
  NULL, XFDS_VERSION, 39, "(SZDD) Microsoft Data Cruncher",
  XFDPFF_DATA|XFDPFF_RECOGLEN|XFDPFF_USERTARGET,
  0, (BOOL (*)()) SZDD_recog, (BOOL (*)()) SZDD_decrunch,
  NULL, NULL, 0, 0, SZDD_MINLEN
};
