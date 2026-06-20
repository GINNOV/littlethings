/* XFD external slave for MMCMP format by Kyzer/CSG <kyzer@4u.net>
 * Based on code by Olivier Lapicque <olivierl@jps.net>
 * MMCMP format (C) Emmanuel Giasson
 */

#include <libraries/xfdmaster.h>
#include <proto/exec.h>
#include <exec/memory.h>
#include "SDI_compiler.h"

static char version[]="$VER: MMCMP 1.0 (12.08.2001) by <kyzer@4u.net>";

/* header format (little-endian):
 * 0       "ziRC"
 * 4       "ONia"
 * 8       header size.w (always 14)
 * 10      header version.w
 * 12      number of blocks.w
 * 14      unpacked file length.l
 * 18      offset to block offset table.l (usually 24)
 * 22      unknown.b
 * 23      unknown.b
 * 24      SIZEOF
 *
 * block offset table (little endian):
 * 0       offset to block[1].l
 * 4       ...
 * ...     offset to block[number of blocks].l
 *
 *
 * block format (little-endian):
 * 0       unpacked block length.l
 * 4       packed block length.l
 * 8       XOR checksum.l
 * 12      number of sub-blocks.w
 * 14      flags.w
 * 16      tt_entries.w
 * 18      num_bits.w
 * 20      SIZEOF
 *
 * sub-block format (little-endian):
 * 0       sub-block output offset in dest file.l
 * 4       sub-block length.l
 */

#define mmcmp_COMP	0x0001
#define mmcmp_DELTA	0x0002
#define mmcmp_16BIT	0x0004
#define mmcmp_STEREO	0x0100
#define mmcmp_ABS16	0x0200
#define mmcmp_ENDIAN	0x0400

#define EndGetI32(a)  ((((a)[3])<<24)|(((a)[2])<<16)|(((a)[1])<<8)|((a)[0]))
#define EndGetI16(a)  ((((a)[1])<<8)|((a)[0]))
#define GETLONG(x,n) EndGetI32(&x[n])
#define GETWORD(x,n) EndGetI16(&x[n])

#define ERROR(x)  { xbi->xfdbi_Error = XFDERR_##x ; return 0; }

const ULONG mmcmp_16bitcmds[16] = {
  0x0001, 0x0003, 0x0007, 0x000F, 0x001E, 0x003C, 0x0078, 0x00F0,
  0x01F0, 0x03F0, 0x07F0, 0x0FF0, 0x1FF0, 0x3FF0, 0x7FF0, 0xFFF0
};
const UBYTE mmcmp_16bitfetch[16] = {
  4, 4, 4, 4, 3, 2, 1, 0,
  0, 0, 0, 0, 0, 0, 0, 0
};
const ULONG mmcmp_8bitcmds[8] = {
  0x01, 0x03, 0x07, 0x0F, 0x1E, 0x3C, 0x78, 0xF8
};
const UBYTE mmcmp_8bitfetch[8] = {
  3, 3, 3, 3, 2, 1, 0, 0
};


struct bitbuf {
  ULONG buf;
  UBYTE *src, *end;
  int bits;
};

ULONG mmcmp_getbits(struct bitbuf *bb, int bits) {
  ULONG out;
  if (!bits) return 0;
  while (bb->bits < 24) {
    bb->buf |= ((bb->src < bb->end) ? *bb->src++ : 0) << bb->bits;
    bb->bits += 8;
  }
  out = bb->buf & ((1<<bits)-1);
  bb->buf >>= bits;
  bb->bits -= bits;
  return out;
}



ASM(BOOL) MMCMP_recog(REG(a0, UBYTE *buf), REG(d0, ULONG length)
  REG(a1, struct xfdRecogResult *rr)) {
  if (strncmp(buf, "ziRCONia", 8) == 0) {
    rr->xfdrr_MinTargetLen = rr->xfdrr_FinalTargetLen = GETLONG(buf, 14);
    return (BOOL) 1;
  }
  return (BOOL) 0;
}

ASM(BOOL) MMCMP_decrunch(REG(a0, struct xfdBufferInfo * xbi),
  REG(a6, struct xfdMasterBase *xfdMasterBase)) {

  UBYTE *src  = (UBYTE *) xbi->xfdbi_SourceBuffer;
  UBYTE *dest = (UBYTE *) xbi->xfdbi_UserTargetBuf;
  UBYTE *ends = &src[xbi->xfdbi_SourceBufLen];
  UBYTE *endd = &dest[xbi->xfdbi_TargetBufSaveLen];
  UBYTE *inpos, *block, *outp, *endp, *ptable;

  int flags, blk, subblk, num_bits, fetch;
  int num_subblocks, num_blocks = GETWORD(src, 12);
  ULONG x, oldx, y, new_bits;

  struct bitbuf bb;

  for (blk = 0; blk < num_blocks; blk++) {
    /* get block pointer from block offset table */
    block = &src[GETLONG(src, 24 + (blk*4))];
    if ((block + 20) > ends) ERROR(CORRUPTEDDATA);

    num_subblocks = GETWORD(block, 12);
    flags = GETWORD(block, 14);

    /* point inpos at the start of actual block data
     * (after the block and subblock headers)
     */
    inpos = &block[20 + (8 * num_subblocks)];
    if (inpos > ends) ERROR(CORRUPTEDDATA);

    if (flags & mmcmp_COMP) {
      num_bits = GETWORD(block, 18);
      if (num_bits >= ((flags & mmcmp_16BIT) ? 16 : 8)) ERROR(CORRUPTEDDATA);

      /* initialise oldx for delta values */
      oldx = 0;

      /* initialise bit buffer */
      bb.bits = bb.buf = 0;
      bb.src  = &inpos[GETWORD(block, 16)];
      bb.end  = &inpos[GETLONG(block, 4)];

      /* initialise 8-bit lookup table */
      ptable = inpos;
    }

    /* decrunch each sub-block */
    for (subblk = 0; subblk < num_subblocks; subblk++) {

      /* each sub-block defines an offset in the decrunched file where
       * it should decrunch to, and how long its decrunched length is
       */
      outp = &dest[GETLONG(block, 20 + (subblk*8))];
      endp = &outp[GETLONG(block, 24 + (subblk*8))];

      if (endp > endd) ERROR(CORRUPTEDDATA);

      if (flags & mmcmp_COMP) {
        if (flags & mmcmp_16BIT) {
          /* 16-bit compression */
          while (outp < endp) {
            x = 0x10000;
            y = mmcmp_getbits(&bb, num_bits+1);
            if (y >= mmcmp_16bitcmds[num_bits]) {
              fetch = mmcmp_16bitfetch[num_bits];
              new_bits = ((y - mmcmp_16bitcmds[num_bits]) << fetch)
                       | mmcmp_getbits(&bb, fetch);
              if (new_bits != num_bits) {
                num_bits = new_bits & 0x0F;
              }
              else {
                if ((y = mmcmp_getbits(&bb, 4)) == 0x0F) {
                  if (mmcmp_getbits(&bb, 1) != 0) break;
                  x = 0xFFFF;
                }
                else {
                  x = 0xFFF0 + y;
                }
              }
            }
            else {
              x = y;
            }

            if (x < 0x10000) {
              x = (x & 1) ? (0xFFFFFFFF - (x >> 1)) : (x >> 1);
              if (flags & mmcmp_DELTA) {
                x += oldx;
                oldx = x;
              }
              else if (!(flags & mmcmp_ABS16)) {
                x ^= 0x8000;
              }
              /* output 16-bit word, little-endian format */
              *outp++ = (x)      & 0xFF;
              *outp++ = (x >> 8) & 0xFF;
            }
          }
        }
        else {
          /* 8-bit compression */
          while (outp < endp) {
            x = 0x100;
            y = mmcmp_getbits(&bb, num_bits+1);
            if (y >= mmcmp_8bitcmds[num_bits]) {
              fetch = mmcmp_8bitfetch[num_bits];
              new_bits = ((y - mmcmp_8bitcmds[num_bits]) << fetch)
                       | mmcmp_getbits(&bb, fetch);
              if (new_bits != num_bits) {
                num_bits = new_bits & 0x07;
              }
              else {
                if ((y = mmcmp_getbits(&bb, 3)) == 0x07) {
                  if (mmcmp_getbits(&bb, 1) == 0) x = 0xFF; else break;
                }
                else {
                  x = 0xF8 + y;
                }
              }
            }
            else {
              x = y;
            }

            if (x < 0x100) {
              x = ptable[x];
              if (flags & mmcmp_DELTA) {
                x += oldx;
                oldx = x;
              }
              /* output 8-bit byte */
              *outp++ = x & 0xFF;
            }

          }
        }
      }
      else {
        /* block is not compressed */
        if ((inpos + (endp-outp)) > ends) ERROR(CORRUPTEDDATA);
        memcpy(outp, inpos, (endp-outp));
        inpos += (endp-outp);
      }
    }
  }

  /* good exit */
  return 1;
}

struct xfdSlave FirstSlave = {
  NULL, XFDS_VERSION, 39, "(MMCMP) Data Cruncher",
  XFDPFF_DATA|XFDPFF_RECOGLEN|XFDPFF_USERTARGET,
  0, (BOOL (*)()) MMCMP_recog, (BOOL (*)()) MMCMP_decrunch,
  NULL, NULL, 0, 0, 44
};
