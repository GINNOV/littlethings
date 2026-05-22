/* dump full information about SZDD compressed file (only useful to
 * implementors like me ;)  (C) 2000 Stuart Caie <kyzer@4u.net>
 */

#include <stdlib.h>
#include <stdio.h>

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

void printinfo(unsigned char *src, int length) {
  int mask, bits, off, len, posn = 4096-16, inlen = 0, outlen = 0, outsize;

  if (src[0]!='S' || src[1]!='Z' || src[2]!='D' || src[3]!='D') return;
  printf("header: SZDD %02x %02x %02x %02x %02x %02x\n", (int)src[4],
    (int)src[5], (int)src[6], (int)src[7], (int)src[8], (int)src[9]);


  outsize = src[10] | (src[11]<<8) | (src[12]<<16) | (src[13]<<24);
  printf("insize = %d, outsize = %d\ninplen:outlen:posn\n", length, outsize);
  src += 14;

  while (inlen < length) {
    printf("%06d:%06d:%04d control $%x\n", inlen++, outlen, posn, *src);
    bits = *src++;
    for (mask = 0x01; mask & 0xFF; mask <<= 1) {
      if (bits & mask) {
        printf("%06d:%06d:%04d literal $%x '%c'\n",
          inlen++,outlen++,posn++,(int)*src,*src); src++;
      }
      else {
        off  = *src++; len = *src++;
        off |= (len << 4) & 0xF00;
        len  = (len & 0x0F) + 3;
        printf("%06d:%06d:%04d repeat %d,%d\n",inlen,outlen,posn,off,len);
        inlen+=2; outlen+=len; posn+=len;
      }
      posn &= 4095;
    }
  }
}

void do_file(char *filename) {
  void *mem = loadfile(filename);
  if (mem) {
    printf("filename : '%s'\n", filename);
    printinfo((unsigned char *) mem, filelen);
    free(mem);
  }
}

int main(int argc, char *argv[]) {
  char *name;
  if (argc <= 1) {
    printf("Usage: %s <SZDD file(s)>\n", argv[0]);
    return 1;
  }
  argv++; while (*argv) do_file(*argv++);
}
