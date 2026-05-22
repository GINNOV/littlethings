/* SZDD-expand: a portable Microsoft COMPRESS.EXE file decruncher
 * Copyright (C) 2000 Stuart Caie <kyzer@4u.net>
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 *
 * Files in the SZDD file format are created with Microsoft's COMPRESS.EXE
 * program, and decompressed with Microsoft's EXPAND.EXE program. The file,
 * when compressed, usually has an underscore as the last character in its
 * filename, ie HELLO.EX_ or VBRUN666.DL_
 *
 * File header format:
 * 4 bytes : "SZDD" (0x53,0x5A,0x44,0x44) - magic ID
 * 4 bytes : 0x88,0xF0,0x27,0x33 - more magic ID
 * 1 byte  : compression mode - only 'A' (0x41) known
 * 1 byte  : the character missing from the end of the filename (0=unknown)
 * 4 bytes : A,B,C,D. unpacked size of file is (D<<24)|(C<<16)|(B<<8)|(A)
 * n bytes : the compressed data
 *
 * The compressed data format is basically LZSS
 * - one control byte, whose bits dictate the format of the next 8 elements,
 *   in the order of LSB to MSB:
 *   - if a bit is set, the next element is a single byte literal
 *   - otherwise, the next element is a repeat: two bytes, %AAAAAAAA %BBBBCCCC
 *     where offset = %BBBBAAAAAAAA and length is %CCCC + 3
 * - this repeats until enough data has been unpacked
 *
 * A 4096 byte wraparound buffer must be kept by the decruncher. A wraparound
 * pointer starts at 4096-16 and each outputted byte must be written at that
 * position and the pointer advanced by one. The offsets of the compressed
 * data refer to an absolute position in this buffer, which may be before the
 * current pointer, or after it. The buffer's initial state is that all
 * elements are the space character (0x20).
 *
 * Also, it seems that there can often be superfluous data at the end of a
 * file - I can only go by the uncompressed size, so I can only really test
 * running out of source data. Some files end in the middle of a run, so I
 * can't test if they exactly reach the endpoint and no more.
 *
 * This code was based on code found in a document describing the Windows Help
 * file format, written by M. Winterhoff <100326.2776@compuserve.com>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SZDD_OVERRUN  (144)    /* 8 matches, at maximum length */
#define SZDD_MINLEN   (14)     /* 4+4+2+4 = 14 byte header (and 0 data) */
#define SZDD_WNDSIZE  (4096)   /* LZ sliding window size (4k) */
#define SZDD_WNDMASK  (4095)

size_t filelen;
void *loadfile(char *name) {
  void *mem = NULL; FILE *fd;
  if ((fd = fopen(name, "rb"))) {
    if ((fseek(fd, 0, SEEK_END) == 0) && (filelen = ftell(fd))
    &&  (fseek(fd, 0, SEEK_SET) == 0) && (mem = malloc(filelen))) {
      if (fread(mem, 1, filelen, fd) < filelen) { free(mem); mem = NULL; }
    }
    fclose(fd);
  }
  return mem;
}

int savefile(char *name, void *mem, size_t length) {
  FILE *fd = fopen(name, "wb");
  int ok = fd && (fwrite(mem, 1, length, fd) == length);
  if (fd) fclose(fd);
  return ok;
}


int decrunch(unsigned char *src, unsigned char *dest, int inlen, int outlen) {
  unsigned char *rep, mask, bits;
  unsigned char *ends = src  + inlen;
  unsigned char *endd = dest + outlen;
  unsigned char *base = dest;
  int offset, length, clrlen, posn = SZDD_WNDSIZE-16;

  src += 14;
  while (src < ends) {
    bits = *src++;
    for (mask = 0x01; mask & 0xFF; mask <<= 1) {
      if (bits & mask) posn++, *dest++ = *src++;
      else {
        offset  = *src++; length = *src++;
        offset |= (length << 4) & 0xF00;
        length  = (length & 0x0F) + 3;

        /* translate absolute 4k buffer offset into real window offset */
        posn &= SZDD_WNDMASK; if (offset > posn) posn += SZDD_WNDSIZE;
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
  return 0;
}


void do_file(char *name) {
  unsigned char *in, *out;
  int outlen;

  if (!(in = (unsigned char *) loadfile(name))) {
    perror(name);
    return;
  }

  if (filelen >= SZDD_MINLEN) {
    if (in[0]=='S' || in[1]=='Z' || in[2]=='D' || in[3]=='D') {
      outlen = in[10] | (in[11]<<8) | (in[12]<<16) | (in[13]<<24);
      if ((out = (unsigned char *) malloc(outlen + SZDD_OVERRUN))) {
        if (decrunch(in, out, filelen, outlen)) {
          char *endc = name + strlen(name) - 1;
          if (in[9] && (*endc=='_')) *endc = in[9];
          if (savefile(name, (void *)out, outlen)) {
            printf("%s: saved as %d bytes\n", name, outlen);
          }
          else perror(name);
        }
        else printf("%s: not enough compressed data (file too short)\n", name);
        free((void *)out);
      }
      else printf("%s: not enough memory (%d bytes needed)\n", name, outlen);
    }
    else printf("%s: not an SZDD file\n", name);
  }
  else printf("%s: too short to be an SZDD file\n", name);
  free((void *)in);
}

int main(int argc, char *argv[]) {
  if (argc <= 1) {
    printf("Usage: %s <SZDD file(s)>\nFiles will be overwritten!\n", argv[0]);
    return 1;
  }
  argv++; while (*argv) do_file(*argv++);
  return 0;
}
