/* Programmheader

	Name:		GetCRC
	Author:		SDI
	Distribution:	PD/GPL
	Description:	calculates checksums
	Compileropts:	-
	Linkeropts:	-gsi

This whole program is under the GPL license as stated below. This is enforced
by the inclusion of md4sum. But all program parts exception the md4sum part
can be used in other software without any restrictions (called Public Domain)
as well as the whole program with md4sum part removed.
All the algorithms also can be calculated step by step without loading or even
knowing the complete file at once. It is left to you modify the functions in
case you need this. All of them are build of 3 parts
  Init
  Work
  Result
Seperate Init and Result part and call Work for each of the data blocks :-)

 1.0   31.10.98 : first version
 1.1   01.11.98 : added PCompress CRC
 1.2   20.12.98 : better, more optimized routines
 1.3   07.02.99 : xadmaster CRC calculation changed
 1.4   09.02.99 : added Brik and tables
 1.5   10.02.99 : added Donald Kindred's CRC
 1.6   20.02.99 : added old Zoom CRC, WORD and LONG sums
 1.7   05.07.99 : added bzip2
 1.8   20.07.99 : found table generation for bzip2
 1.9   04.01.00 : added bzip2 inverted crc
 1.10  11.04.00 : added more Archiver names
 1.11  22.11.00 : added LightFileSystem
 1.12  30.11.00 : some little changes
 1.13  04.12.00 : fixed LightFileSystem checksum
 1.14  27.12.00 : added md5sum, removed xad-stuff, ReadArgs,
	made portable
 1.15  19.04.01 : added the Motorola/Intel methods, added EOR
 1.16  10.09.01 : added type argument
 1.17  30.09.02 : added md4sum, added const to arguments
 1.18  30.12.02 : changed directcall method to use symbolic names,
	added SHA1
 1.19  16.02.03 : added BSD and SYSV checksums as well as chksum CRC
*/

const char * version = "$VER: GetCRC 1.19 (16.02.2003) (PD/GPL) by Dirk Stöcker <stoecker@epost.de>";

/* This utility is a collection of checksum calculation routines for different
  utilities. For some checksums it includes different ways to compute the
  checksum.
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef signed long     int32;
typedef unsigned long  uint32;
typedef signed short    int16;
typedef unsigned short uint16;
typedef signed char     int8;
typedef unsigned char  uint8;

/* CRC32_1, CRC32_2 and CRC32_3 use same table */
uint32 DoCRC32_1 (const uint8 *, int32);
uint32 DoCRC32_2 (const uint8 *, int32);
uint32 DoCRC32_3 (const uint8 *, int32);
uint32 DoCRC32_4 (const uint8 *, int32);
uint32 DoCRC32_5 (const uint8 *, int32);
uint32 DoCRC32_6 (const uint8 *, int32);
uint32 DoCRC32_7 (const uint8 *, int32);
uint16 DoCRC16_1 (const uint8 *, int32);
uint16 DoCRC16_2 (const uint8 *, int32);
uint16 DoCRC16_3 (const uint8 *, int32);
uint16 DoCRC16_4 (const uint8 *, int32);
uint32 DoCHS32_1M(const uint8 *, int32);
uint32 DoCHS32_1I(const uint8 *, int32);
uint32 DoCHS32_2 (const uint8 *, int32);
uint16 DoCHS16_1 (const uint8 *, int32);
uint16 DoCHS16_2 (const uint8 *, int32);
uint16 DoCHS16_3 (const uint8 *, int32);
uint32 DoSumUB   (const uint8 *, int32);
uint32 DoSumUWM  (const uint8 *, int32);
uint32 DoSumUWI  (const uint8 *, int32);
uint32 DoSumLM   (const uint8 *, int32);
uint32 DoSumLI   (const uint8 *, int32);
uint32 DoSumSB   (const int8 *, int32);
uint32 DoSumSWM  (const uint8 *, int32);
uint32 DoSumSWI  (const uint8 *, int32);
uint8  DoEORB    (const uint8 *, int32);
uint16 DoEORWM   (const uint8 *, int32);
uint16 DoEORWI   (const uint8 *, int32);
uint32 DoEORLM   (const uint8 *, int32);
uint32 DoEORLI   (const uint8 *, int32);
void   md5sum    (const uint8 *, int32, uint8 md5sum[16]);
void   mdfour    (const uint8 *, int32, uint8 md4sum[16]);
void   sha1      (const uint8 *, int32, uint8 sha1[20]);

static void printall(uint8 *mem, uint32 size)
{
  uint8 res[20];
  uint32 i;

  printf("Size              :   %08ld\n----------------------------\n", size);
  printf("CRC-16 1          :       %04X  PCompress2, Arc, DMS, ProPack, LhA, Zoo, Shrink\n", DoCRC16_1(mem, size));
  printf("CRC-16 2          :       %04X  CCITT, XModem, LU\n", DoCRC16_2(mem, size));
  printf("CRC-16 3          :       %04X  Donald Kindred's CRC\n", DoCRC16_3(mem, size));
  printf("CRC-16 4          :       %04X  old Zoom, CompDisk\n", DoCRC16_4(mem, size));
  printf("CRC-32 1          :   %08lX  Olaf Barthel's CRC, PCompress, Zoom 5, LhPak\n", DoCRC32_1(mem, size));
  printf("CRC-32 2          :   %08lX  Zip, GZip, LZX, RAR, Arj\n", DoCRC32_2(mem, size));
  printf("CRC-32 3          :   %08lX  Brik (Binary mode), Ace\n", DoCRC32_3(mem, size));
  printf("CRC-32 4          :   %08lX  GPatch (old)\n", DoCRC32_4(mem, size));
  printf("CRC-32 5          :   %08lX  BZip2\n", DoCRC32_5(mem, size));
  printf("CRC-32 6          :   %08lX  BZip2 inverted\n", DoCRC32_6(mem, size));
  printf("CRC-32 7          : %10lu  chksum utility (decimal)\n", DoCRC32_7(mem, size));
  printf("CHS-16 1          :       %04X  PowerPacker Passwords\n", DoCHS16_1(mem, size));
  printf("CHS-16 2          :      %5u  BSD sum (decimal)\n", DoCHS16_2(mem, size));
  printf("CHS-16 3          :      %5u  SYSV sum (decimal)\n", DoCHS16_3(mem, size));
  printf("CHS-32 1M (WRAP)  :   %08lX  Olaf Barthel's CRC, Bootblock of FFS\n", DoCHS32_1M(mem, size));
  printf("CHS-32 1I         :   %08lX\n", DoCHS32_1I(mem, size));
  printf("CHS-32 2          :   %08lX  LightFileSystem\n", DoCHS32_2(mem, size));

  /* EOR methods */
  printf("EOR Byte          :         %02X\n", DoEORB(mem, size));
  printf("EOR Word (M/I)    :       %04X/    %04X", DoEORWM(mem, size), DoEORWI(mem, size));
  if(size & 1)
    printf(" (+%02X)", mem[size-1]);
  printf("\n");
  printf("EOR Long (M/I)    :   %08lX/%08lX", DoEORLM(mem, size), DoEORLI(mem, size));
  if(size & 3)
  {
    printf(" (+");
    for(i = size & ~3; i < size; ++i)
      printf("%02X", mem[i]);
    printf(")");
  }
  printf("\n");

  /* int8 Sum Methods */
  printf("Sum Byte Signed   :   %08lX\n", DoSumSB(mem, size));
  printf("Sum Byte Unsigned :   %08lX\n", DoSumUB(mem, size));

  printf("Sum Word Si (M/I) :   %08lX/%08lX", DoSumSWM(mem, size), DoSumSWI(mem, size));
  if(size & 1)
    printf(" (+%02X)", mem[size-1]);
  printf("\n");

  printf("Sum Word Un (M/I) :   %08lX/%08lX", DoSumUWM(mem, size), DoSumUWI(mem, size));
  if(size & 1)
    printf(" (+%02X)", mem[size-1]);
  printf("\n");
  
  printf("Sum Long (M/I)    :   %08lX/%08lX", DoSumLM(mem, size), DoSumLI(mem, size));
  if(size & 3)
  {
    printf(" (+");
    for(i = size & ~3; i < size; ++i)
      printf("%02X", mem[i]);
    printf(")");
  }
  printf("\n");

  /* and other methods */
  printf("MD4               : ");
  mdfour(mem, size, res);
  for(i = 0; i < 16; ++i)
    printf("%02X", res[i]);
  printf("\n");

  printf("MD5               : ");
  md5sum(mem, size, res);
  for(i = 0; i < 16; ++i)
    printf("%02X", res[i]);
  printf("\n");

  printf("SHA1              : ");
  sha1(mem, size, res);
  for(i = 0; i < 20; ++i)
    printf("%02X", res[i]);
  printf("\n");
}

static int mystrcasecmp(char *a, char *b)
{
  int i;
  while(!(i = tolower(*a) - tolower(*b)) && (*a++))
    ++b;
  return i;
}

int main(int argc, char **argv)
{
  FILE *fh;

  if(argc < 2 || argc > 3)
  {
    printf("%s\n%s <filename> [crc type]\n", version+6, argv[0]);
    return 10;
  }

  if((fh = fopen(argv[1], "rb")))
  {
    uint32 size;

    if(!fseek(fh,0,SEEK_END) && (size = ftell(fh)) != EOF && !fseek(fh,0,SEEK_SET))
    {
      uint8 *mem;
      if((mem = (uint8 *) malloc(size+3)))
      {
        if(fread(mem, size, 1, fh) == 1)
        {
          mem[size] = mem[size+1] = mem[size+2] = 0; /* clear 3 additional bytes */
          if(argc == 3)
          {
            uint8 res[20];
            int i;

            if(!mystrcasecmp("CRC16-1", argv[2]))
              printf("%04X", DoCRC16_1(mem, size));
            else if(!mystrcasecmp("CRC16-2", argv[2]))
              printf("%04X", DoCRC16_2(mem, size));
            else if(!mystrcasecmp("CRC16-1", argv[2]))
              printf("%04X", DoCRC16_3(mem, size));
            else if(!mystrcasecmp("CRC16-4", argv[2]))
              printf("%04X", DoCRC16_4(mem, size));
            else if(!mystrcasecmp("CRC32-1", argv[2]))
              printf("%08lX", DoCRC32_1(mem, size));
            else if(!mystrcasecmp("CRC32-2", argv[2]))
	      printf("%08lX", DoCRC32_2(mem, size));
            else if(!mystrcasecmp("CRC32-3", argv[2]))
              printf("%08lX", DoCRC32_3(mem, size));
            else if(!mystrcasecmp("CRC32-4", argv[2]))
              printf("%08lX", DoCRC32_4(mem, size));
            else if(!mystrcasecmp("CRC32-5", argv[2]))
              printf("%08lX", DoCRC32_5(mem, size));
            else if(!mystrcasecmp("CRC32-6", argv[2]))
              printf("%08lX", DoCRC32_6(mem, size));
            else if(!mystrcasecmp("CRC32-7", argv[2]))
              printf("%lu", DoCRC32_7(mem, size));
            else if(!mystrcasecmp("CHS16-1", argv[2]))
              printf("%04X", DoCHS16_1(mem, size));
            else if(!mystrcasecmp("CHS16-2", argv[2]))
              printf("%u", DoCHS16_2(mem, size));
            else if(!mystrcasecmp("CHS16-3", argv[2]))
              printf("%u", DoCHS16_3(mem, size));
            else if(!mystrcasecmp("CHS32-1M", argv[2]))
              printf("%08lX", DoCHS32_1M(mem, size));
            else if(!mystrcasecmp("CHS32-1I", argv[2]))
              printf("%08lX", DoCHS32_1I(mem, size));
            else if(!mystrcasecmp("CHS32-2", argv[2]))
              printf("%08lX", DoCHS32_2(mem, size));
            else if(!mystrcasecmp("EOR-Byte", argv[2]))
              printf("%02X", DoEORB(mem, size));
/* how to handle additional bytes ?
            else if(!mystrcasecmp("EOR-WordM", argv[2]))
              printf("%04X", DoEORWM(mem, size));
            else if(!mystrcasecmp("EOR-WordI", argv[2]))
              printf("%04X", DoEORWI(mem, size));
            else if(!mystrcasecmp("EOR-LongM", argv[2]))
              printf("%08X", DoEORLM(mem, size));
            else if(!mystrcasecmp("EOR-LONGI", argv[2]))
              printf("%08X", DoEORLI(mem, size));
*/
            else if(!mystrcasecmp("Sum-Byte", argv[2]))
              printf("%02lX", DoSumSB(mem, size));
            else if(!mystrcasecmp("Sum-ByteU", argv[2]))
              printf("%02lX", DoSumUB(mem, size));
/* how to handle additional bytes ?
            else if(!mystrcasecmp("Sum-WordM", argv[2]))
              printf("%04X", DoSumSWM(mem, size));
            else if(!mystrcasecmp("Sum-WordI", argv[2]))
              printf("%04X", DoSumSWI(mem, size));
            else if(!mystrcasecmp("Sum-WordUM", argv[2]))
              printf("%04X", DoSumUWM(mem, size));
            else if(!mystrcasecmp("Sum-WordUI", argv[2]))
              printf("%04X", DoSumUWI(mem, size));
            else if(!mystrcasecmp("Sum-LongM", argv[2]))
              printf("%08X", DoSumLM(mem, size));
            else if(!mystrcasecmp("Sum-LongI", argv[2]))
              printf("%08X", DoSumLI(mem, size));
*/
            else if(!mystrcasecmp("MD4", argv[2]))
            {
              mdfour(mem, size, res);
              for(i = 0; i < 16; ++i)
                printf("%02X", res[i]);
            }
            else if(!mystrcasecmp("MD5", argv[2]))
            {
              md5sum(mem, size, res);
              for(i = 0; i < 16; ++i)
                printf("%02X", res[i]);
            }
            else if(!mystrcasecmp("SHA1", argv[2]))
            {
              sha1(mem, size, res);
              for(i = 0; i < 20; ++i)
                printf("%02X", res[i]);
            }
            else
            {
              printf("%s\n%s <filename> [crc type]\n", version+6, argv[0]);
              printf("CRC16-1, CRC16-2, CRC16-3, CRC16-4,\n"
                     "CRC32-1, CRC32-2, CRC32-3, CRC32-4, CRC32-5, CRC32-6, CRC32-7,\n"
                     "CHS16-1, CHS16-2, CHS16-3, CHS32-1M, CHS32-1I, CHS32-2,\n"
                     "EOR-Byte, Sum-Byte, Sum-ByteU,\n"
                     "MD4, MD5, SHA1");
            }
            printf("\n");
          }
          else
            printall(mem, size);
        }
        else
          printf("Could not read file.\n");
        free(mem);
      }
      else
        printf("Could not allocate memory.\n");
    }
    else
      printf("Could not get file size.\n");
    fclose(fh);
  }
  else
    printf("Could not open file.\n");
  return 0;
}

/****************************************************************************/
/*                        the CRC table creators                            */
/****************************************************************************/

void MakeCRC16(uint16 * buf, uint16 ID)
{
  uint16 i, j, k;

  for(i = 0; i < 256; ++i)
  {
    k = i;

    for(j = 0; j < 8; ++j)
    {
      if(k & 1)
        k = (k >> 1) ^ ID;
      else
        k >>= 1;
    }
    buf[i] = k;
  }
}

void MakeCRC16R(uint16 * buf, uint16 ID)
{
  uint16 i, j, k;

  for(i = 0; i < 256; ++i)
  {
    k = i << 8;

    for(j = 0; j < 8; ++j)
    {
      if(k & 0x8000)
        k = (k << 1) ^ ID;
      else
        k <<= 1;
    }
    buf[i] = k;
  }
}

void MakeCRC32(uint32 * buf, uint32 ID)
{
  uint32 i, j, k;

  for(i = 0; i < 256; ++i)
  {
    k = i;

    for(j = 0; j < 8; ++j)
    {
      if(k & 1)
        k = (k >> 1) ^ ID;
      else
        k >>= 1;
    }
    buf[i] = k;
  }
}

void MakeCRC32R(uint32 * buf, uint32 ID)
{
  uint32 i, j, k;

  for(i = 0; i < 256; ++i)
  {
    k = i << 24;

    for(j = 0; j < 8; ++j)
    {
      if(k & 0x80000000)
        k = (k << 1) ^ ID;
      else
        k <<= 1;
    }
    buf[i] = k;
  }
}

/****************************************************************************/
/*                            the CRC methods                               */
/****************************************************************************/

/* PCompress LH data */
uint32 DoCRC32_1(const uint8 * Mem, int32 Size)
{
  uint32 CRC = 0;
  uint32 buf[256];

  MakeCRC32(buf, 0xEDB88320);

  while(Size--)
    CRC = buf[(CRC ^ *(Mem++)) & 0xFF] ^ (CRC >> 8);

  return CRC;
}

/* GZip, Zip, LZX */
uint32 DoCRC32_2(const uint8 * Mem, int32 Size)
{
  uint32 CRC = ~0;
  uint32 buf[256];

  MakeCRC32(buf, 0xEDB88320);

  while(Size--)
    CRC = buf[(CRC ^ *(Mem++)) & 0xFF] ^ (CRC >> 8);

  return ~CRC;
}

/* Brik Binary */
uint32 DoCRC32_3(const uint8 * Mem, int32 Size)
{
  uint32 CRC = ~0;
  uint32 buf[256];

  MakeCRC32(buf, 0xEDB88320);

  while(Size--)
    CRC = buf[(CRC ^ *(Mem++)) & 0xFF] ^ (CRC >> 8);

  return CRC;
}

/* GPatch */
uint32 DoCRC32_4(const uint8 * Mem, int32 Size)
{
  uint32 CRC = 0, highbit, newbit;
  uint8 l, int8var;

  while(Size--)
  {
    int8var = *(Mem++);

    for(l=1; l<=8; l++)
    {
      highbit = CRC & 0x80000000;
      CRC <<= 1;
      newbit = (int8var & 0x80)>>7;
      int8var <<= 1;
      CRC |= newbit;
      if(highbit)
        CRC^=0x04c11db7;
    }
  }

  for(l=1; l<=33; l++)
  {
    highbit = CRC & 0x80000000;
    CRC <<= 1;
    if(highbit)
      CRC^=0x04c11db7;
  }

  return CRC;
}

/* BZip2 */
uint32 DoCRC32_5(const uint8 * Mem, int32 Size)
{
  uint32 CRC = ~0;
  uint32 buf[256];

  MakeCRC32R(buf, 0x04C11DB7);

  while(Size--)
    CRC = buf[(CRC >> 24) ^ *(Mem++)] ^ (CRC << 8);

  return ~CRC;
}

/* BZip2 inverted */
uint32 DoCRC32_6(const uint8 * Mem, int32 Size)
{
  uint32 CRC = ~0;
  uint32 buf[256];

  MakeCRC32R(buf, 0x04C11DB7);

  while(Size--)
    CRC = buf[(CRC >> 24) ^ *(Mem++)] ^ (CRC << 8);

  return CRC;
}

uint32 DoCRC32_7(const uint8 * Mem, int32 Size)
{
  uint32 CRC = 0,origsize=Size;
  uint32 buf[256];

  MakeCRC32R(buf, 0x04C11DB7);

  while(Size--)
    CRC = buf[(CRC >> 24) ^ *(Mem++)] ^ (CRC << 8);

  while(origsize)
  {
    CRC = buf[(CRC >> 24) ^ (origsize&0xFF)] ^ (CRC << 8);
    origsize >>= 8;
  }

  return (~CRC);
}

/* PCompress2, Arc, DMS */
uint16 DoCRC16_1(const uint8 * Mem, int32 Size)
{
  uint16 CRC = 0;
  uint16 buf[256];
  
  MakeCRC16(buf, 0xA001);

  while(Size--)
    CRC = buf[(CRC ^ *(Mem++)) & 0xFF] ^ (CRC >> 8);

  return CRC;
}

uint16 DoCRC16_2(const uint8 * Mem, int32 Size)
{
  uint16 CRC = 0;
  uint16 buf[256];
  
  MakeCRC16R(buf, 0x1021);

  while(Size--)
    CRC = buf[((CRC>>8) ^ *(Mem++)) & 0xFF] ^ (CRC<<8);

  return CRC;
}

/* Donald Kindred's CRC */
uint16 DoCRC16_3(const uint8 * Mem, int32 Size)
{
  uint16 CRC = 0;
  uint16 c;

  while(Size--)
  {
    c = CRC;
    CRC <<= 1;
    CRC = (uint8) (CRC + *(Mem++)) + (CRC & 0xFF00);
    if(c & 0x8000)
      CRC ^= 0xA097;
  }
  return CRC;
}

uint16 DoCRC16_4(const uint8 * Mem, int32 Size)
{
  uint16 CRC = 0;
  uint16 buf[256];
  
  MakeCRC16R(buf, 0x1021);

  while(Size--)
    CRC = buf[((CRC>>8) & 0xFF)] ^ ((CRC << 8) ^ *(Mem++));

  return CRC;
}

/****************************************************************************/
/*                         the checksum methods                             */
/****************************************************************************/

/* Olaf Barthel's WRAP checksum (Motorolla format) */
uint32 DoCHS32_1M(const uint8 * Mem, int32 Size)
{
  uint32 WRAP = 0, oldWRAP, i;

  Size >>= 2;

  while(Size--)
  {
    i = *(Mem++) << 24; i |= *(Mem++) << 16; i |= *(Mem++) << 8; i |= *(Mem++);
    oldWRAP = WRAP;
    WRAP += i;
    if(WRAP < oldWRAP)
      ++WRAP;
  }
  return ~WRAP;
}

/* and the same in Intel format */
uint32 DoCHS32_1I(const uint8 * Mem, int32 Size)
{
  uint32 WRAP = 0, oldWRAP, i;

  Size >>= 2;

  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8; i |= *(Mem++) << 16; i |= *(Mem++) << 24;
    oldWRAP = WRAP;
    WRAP += i;
    if(WRAP < oldWRAP)
      ++WRAP;
  }
  return ~WRAP;
}

/* LightFileSystem */
uint32 DoCHS32_2(const uint8 * Mem, int32 Size)
{
  uint32 CRC = 0, i, s;
  while(Size)
  {
    s = 0;
    i = Size > 0x1600 ? 0x1600 : Size; /* calculated in 0x1600 blocks */
    Size -= i;

    do
    {
      s += *(Mem++);
      s = ((s << (i&7)) | (s >> (32-(i&7)))); /* L-rotate sum i times */
    } while(--i);
    CRC += s;
  }
  return CRC;
}

/* Powerpacker password check */
uint16 DoCHS16_1(const uint8 * Mem, int32 Size)
{
  uint16 CRC = 0, i, k;

  while(Size--)
  {
    i = *(Mem++);
    k = i % 16;
    CRC = i + ((CRC >> k) | (CRC << (16-k))); /* R-rotate CRC i times */
  }
  return CRC;
}

uint16 DoCHS16_2(const uint8 * Mem, int32 Size)
{
  uint16 sum = 0;

  while(Size--)
  {
    if(sum&1)
      sum = (sum >> 1) + 0x8000;
    else
      sum >>= 1;
    sum += *(Mem++);
  }
  return sum;
}

uint16 DoCHS16_3(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;

  while(Size--)
    sum += *(Mem++);
  return ((uint16) (sum%0xFFFF));
}

/****************************************************************************/
/*                            the easy eors                                 */
/****************************************************************************/

uint8 DoEORB(const uint8 * Mem, int32 Size)
{
  uint8 eor = 0;
  
  while(Size--)
    eor ^= *(Mem++);
  return eor;
}

uint16 DoEORWM(const uint8 * Mem, int32 Size)
{
  uint16 eor = 0, i;

  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++) << 8; i |= *(Mem++);
    eor ^= i;
  }
  return eor;
}

uint16 DoEORWI(const uint8 * Mem, int32 Size)
{
  uint16 eor = 0, i;

  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8;
    eor ^= i;
  }
  return eor;
}

uint32 DoEORLM(const uint8 * Mem, int32 Size)
{
  uint32 eor = 0, i;

  Size >>= 2;
  
  while(Size--)
  {
    i = *(Mem++) << 24; i |= *(Mem++) << 16; i |= *(Mem++) << 8; i |= *(Mem++);
    eor ^= i;
  }
  return eor;
}

uint32 DoEORLI(const uint8 * Mem, int32 Size)
{
  uint32 eor = 0, i;

  Size >>= 2;

  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8; i |= *(Mem++) << 16; i |= *(Mem++) << 24;
    eor ^= i;
  }
  return eor;
}

/****************************************************************************/
/*                            the easy sums                                 */
/****************************************************************************/

uint32 DoSumSB(const int8 * Mem, int32 Size)
{
  uint32 sum = 0;
  
  while(Size--)
    sum += *(Mem++);
  return sum;
}

uint32 DoSumSWM(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint16 i;
  
  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++) << 8; i |= *(Mem++);
    sum += (int16) i;
  }
  return sum;
}

uint32 DoSumSWI(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint16 i;
  
  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8;
    sum += (int16) i;
  }
  return sum;
}

uint32 DoSumUB(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  
  while(Size--)
    sum += *(Mem++);
  return sum;
}

uint32 DoSumUWM(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint16 i;
  
  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++) << 8; i |= *(Mem++);
    sum += i;
  }
  return sum;
}

uint32 DoSumUWI(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint16 i;
  
  Size >>= 1;
  
  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8;
    sum += i;
  }
  return sum;
}

uint32 DoSumLM(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint32 i;

  Size >>= 2;

  while(Size--)
  {
    i = *(Mem++) << 24; i |= *(Mem++) << 16; i |= *(Mem++) << 8; i |= *(Mem++);
    sum += i;
  }
  return sum;
}

uint32 DoSumLI(const uint8 * Mem, int32 Size)
{
  uint32 sum = 0;
  uint32 i;

  Size >>= 2;

  while(Size--)
  {
    i = *(Mem++); i |= *(Mem++) << 8; i |= *(Mem++) << 16; i |= *(Mem++) << 24;
    sum += i;
  }
  return sum;
}

/****************************************************************************/
/*                            tables for CRC's                              */
/****************************************************************************/

/* table for MakeCRC32R(buf, 0x04C11DB7);

uint32 table[256] = {
  0x00000000,0x04C11DB7,0x09823B6E,0x0D4326D9,0x130476DC,0x17C56B6B,0x1A864DB2,
  0x1E475005,0x2608EDB8,0x22C9F00F,0x2F8AD6D6,0x2B4BCB61,0x350C9B64,0x31CD86D3,
  0x3C8EA00A,0x384FBDBD,0x4C11DB70,0x48D0C6C7,0x4593E01E,0x4152FDA9,0x5F15ADAC,
  0x5BD4B01B,0x569796C2,0x52568B75,0x6A1936C8,0x6ED82B7F,0x639B0DA6,0x675A1011,
  0x791D4014,0x7DDC5DA3,0x709F7B7A,0x745E66CD,0x9823B6E0,0x9CE2AB57,0x91A18D8E,
  0x95609039,0x8B27C03C,0x8FE6DD8B,0x82A5FB52,0x8664E6E5,0xBE2B5B58,0xBAEA46EF,
  0xB7A96036,0xB3687D81,0xAD2F2D84,0xA9EE3033,0xA4AD16EA,0xA06C0B5D,0xD4326D90,
  0xD0F37027,0xDDB056FE,0xD9714B49,0xC7361B4C,0xC3F706FB,0xCEB42022,0xCA753D95,
  0xF23A8028,0xF6FB9D9F,0xFBB8BB46,0xFF79A6F1,0xE13EF6F4,0xE5FFEB43,0xE8BCCD9A,
  0xEC7DD02D,0x34867077,0x30476DC0,0x3D044B19,0x39C556AE,0x278206AB,0x23431B1C,
  0x2E003DC5,0x2AC12072,0x128E9DCF,0x164F8078,0x1B0CA6A1,0x1FCDBB16,0x018AEB13,
  0x054BF6A4,0x0808D07D,0x0CC9CDCA,0x7897AB07,0x7C56B6B0,0x71159069,0x75D48DDE,
  0x6B93DDDB,0x6F52C06C,0x6211E6B5,0x66D0FB02,0x5E9F46BF,0x5A5E5B08,0x571D7DD1,
  0x53DC6066,0x4D9B3063,0x495A2DD4,0x44190B0D,0x40D816BA,0xACA5C697,0xA864DB20,
  0xA527FDF9,0xA1E6E04E,0xBFA1B04B,0xBB60ADFC,0xB6238B25,0xB2E29692,0x8AAD2B2F,
  0x8E6C3698,0x832F1041,0x87EE0DF6,0x99A95DF3,0x9D684044,0x902B669D,0x94EA7B2A,
  0xE0B41DE7,0xE4750050,0xE9362689,0xEDF73B3E,0xF3B06B3B,0xF771768C,0xFA325055,
  0xFEF34DE2,0xC6BCF05F,0xC27DEDE8,0xCF3ECB31,0xCBFFD686,0xD5B88683,0xD1799B34,
  0xDC3ABDED,0xD8FBA05A,0x690CE0EE,0x6DCDFD59,0x608EDB80,0x644FC637,0x7A089632,
  0x7EC98B85,0x738AAD5C,0x774BB0EB,0x4F040D56,0x4BC510E1,0x46863638,0x42472B8F,
  0x5C007B8A,0x58C1663D,0x558240E4,0x51435D53,0x251D3B9E,0x21DC2629,0x2C9F00F0,
  0x285E1D47,0x36194D42,0x32D850F5,0x3F9B762C,0x3B5A6B9B,0x0315D626,0x07D4CB91,
  0x0A97ED48,0x0E56F0FF,0x1011A0FA,0x14D0BD4D,0x19939B94,0x1D528623,0xF12F560E,
  0xF5EE4BB9,0xF8AD6D60,0xFC6C70D7,0xE22B20D2,0xE6EA3D65,0xEBA91BBC,0xEF68060B,
  0xD727BBB6,0xD3E6A601,0xDEA580D8,0xDA649D6F,0xC423CD6A,0xC0E2D0DD,0xCDA1F604,
  0xC960EBB3,0xBD3E8D7E,0xB9FF90C9,0xB4BCB610,0xB07DABA7,0xAE3AFBA2,0xAAFBE615,
  0xA7B8C0CC,0xA379DD7B,0x9B3660C6,0x9FF77D71,0x92B45BA8,0x9675461F,0x8832161A,
  0x8CF30BAD,0x81B02D74,0x857130C3,0x5D8A9099,0x594B8D2E,0x5408ABF7,0x50C9B640,
  0x4E8EE645,0x4A4FFBF2,0x470CDD2B,0x43CDC09C,0x7B827D21,0x7F436096,0x7200464F,
  0x76C15BF8,0x68860BFD,0x6C47164A,0x61043093,0x65C52D24,0x119B4BE9,0x155A565E,
  0x18197087,0x1CD86D30,0x029F3D35,0x065E2082,0x0B1D065B,0x0FDC1BEC,0x3793A651,
  0x3352BBE6,0x3E119D3F,0x3AD08088,0x2497D08D,0x2056CD3A,0x2D15EBE3,0x29D4F654,
  0xC5A92679,0xC1683BCE,0xCC2B1D17,0xC8EA00A0,0xD6AD50A5,0xD26C4D12,0xDF2F6BCB,
  0xDBEE767C,0xE3A1CBC1,0xE760D676,0xEA23F0AF,0xEEE2ED18,0xF0A5BD1D,0xF464A0AA,
  0xF9278673,0xFDE69BC4,0x89B8FD09,0x8D79E0BE,0x803AC667,0x84FBDBD0,0x9ABC8BD5,
  0x9E7D9662,0x933EB0BB,0x97FFAD0C,0xAFB010B1,0xAB710D06,0xA6322BDF,0xA2F33668,
  0xBCB4666D,0xB8757BDA,0xB5365D03,0xB1F740B4,
};
*/

/* table for MakeCRC32(buf, 0xEDB88320);

uint32 table[256] = {
  0x00000000,0x77073096,0xEE0E612C,0x990951BA,0x076DC419,0x706AF48F,0xE963A535,
  0x9E6495A3,0x0EDB8832,0x79DCB8A4,0xE0D5E91E,0x97D2D988,0x09B64C2B,0x7EB17CBD,
  0xE7B82D07,0x90BF1D91,0x1DB71064,0x6AB020F2,0xF3B97148,0x84BE41DE,0x1ADAD47D,
  0x6DDDE4EB,0xF4D4B551,0x83D385C7,0x136C9856,0x646BA8C0,0xFD62F97A,0x8A65C9EC,
  0x14015C4F,0x63066CD9,0xFA0F3D63,0x8D080DF5,0x3B6E20C8,0x4C69105E,0xD56041E4,
  0xA2677172,0x3C03E4D1,0x4B04D447,0xD20D85FD,0xA50AB56B,0x35B5A8FA,0x42B2986C,
  0xDBBBC9D6,0xACBCF940,0x32D86CE3,0x45DF5C75,0xDCD60DCF,0xABD13D59,0x26D930AC,
  0x51DE003A,0xC8D75180,0xBFD06116,0x21B4F4B5,0x56B3C423,0xCFBA9599,0xB8BDA50F,
  0x2802B89E,0x5F058808,0xC60CD9B2,0xB10BE924,0x2F6F7C87,0x58684C11,0xC1611DAB,
  0xB6662D3D,0x76DC4190,0x01DB7106,0x98D220BC,0xEFD5102A,0x71B18589,0x06B6B51F,
  0x9FBFE4A5,0xE8B8D433,0x7807C9A2,0x0F00F934,0x9609A88E,0xE10E9818,0x7F6A0DBB,
  0x086D3D2D,0x91646C97,0xE6635C01,0x6B6B51F4,0x1C6C6162,0x856530D8,0xF262004E,
  0x6C0695ED,0x1B01A57B,0x8208F4C1,0xF50FC457,0x65B0D9C6,0x12B7E950,0x8BBEB8EA,
  0xFCB9887C,0x62DD1DDF,0x15DA2D49,0x8CD37CF3,0xFBD44C65,0x4DB26158,0x3AB551CE,
  0xA3BC0074,0xD4BB30E2,0x4ADFA541,0x3DD895D7,0xA4D1C46D,0xD3D6F4FB,0x4369E96A,
  0x346ED9FC,0xAD678846,0xDA60B8D0,0x44042D73,0x33031DE5,0xAA0A4C5F,0xDD0D7CC9,
  0x5005713C,0x270241AA,0xBE0B1010,0xC90C2086,0x5768B525,0x206F85B3,0xB966D409,
  0xCE61E49F,0x5EDEF90E,0x29D9C998,0xB0D09822,0xC7D7A8B4,0x59B33D17,0x2EB40D81,
  0xB7BD5C3B,0xC0BA6CAD,0xEDB88320,0x9ABFB3B6,0x03B6E20C,0x74B1D29A,0xEAD54739,
  0x9DD277AF,0x04DB2615,0x73DC1683,0xE3630B12,0x94643B84,0x0D6D6A3E,0x7A6A5AA8,
  0xE40ECF0B,0x9309FF9D,0x0A00AE27,0x7D079EB1,0xF00F9344,0x8708A3D2,0x1E01F268,
  0x6906C2FE,0xF762575D,0x806567CB,0x196C3671,0x6E6B06E7,0xFED41B76,0x89D32BE0,
  0x10DA7A5A,0x67DD4ACC,0xF9B9DF6F,0x8EBEEFF9,0x17B7BE43,0x60B08ED5,0xD6D6A3E8,
  0xA1D1937E,0x38D8C2C4,0x4FDFF252,0xD1BB67F1,0xA6BC5767,0x3FB506DD,0x48B2364B,
  0xD80D2BDA,0xAF0A1B4C,0x36034AF6,0x41047A60,0xDF60EFC3,0xA867DF55,0x316E8EEF,
  0x4669BE79,0xCB61B38C,0xBC66831A,0x256FD2A0,0x5268E236,0xCC0C7795,0xBB0B4703,
  0x220216B9,0x5505262F,0xC5BA3BBE,0xB2BD0B28,0x2BB45A92,0x5CB36A04,0xC2D7FFA7,
  0xB5D0CF31,0x2CD99E8B,0x5BDEAE1D,0x9B64C2B0,0xEC63F226,0x756AA39C,0x026D930A,
  0x9C0906A9,0xEB0E363F,0x72076785,0x05005713,0x95BF4A82,0xE2B87A14,0x7BB12BAE,
  0x0CB61B38,0x92D28E9B,0xE5D5BE0D,0x7CDCEFB7,0x0BDBDF21,0x86D3D2D4,0xF1D4E242,
  0x68DDB3F8,0x1FDA836E,0x81BE16CD,0xF6B9265B,0x6FB077E1,0x18B74777,0x88085AE6,
  0xFF0F6A70,0x66063BCA,0x11010B5C,0x8F659EFF,0xF862AE69,0x616BFFD3,0x166CCF45,
  0xA00AE278,0xD70DD2EE,0x4E048354,0x3903B3C2,0xA7672661,0xD06016F7,0x4969474D,
  0x3E6E77DB,0xAED16A4A,0xD9D65ADC,0x40DF0B66,0x37D83BF0,0xA9BCAE53,0xDEBB9EC5,
  0x47B2CF7F,0x30B5FFE9,0xBDBDF21C,0xCABAC28A,0x53B39330,0x24B4A3A6,0xBAD03605,
  0xCDD70693,0x54DE5729,0x23D967BF,0xB3667A2E,0xC4614AB8,0x5D681B02,0x2A6F2B94,
  0xB40BBE37,0xC30C8EA1,0x5A05DF1B,0x2D02EF8D
};
*/

/* table for MakeCRC16(buf, 0xA001);

uint16 table[256] = {
  0x0000,0xC0C1,0xC181,0x0140,0xC301,0x03C0,0x0280,0xC241,0xC601,0x06C0,
  0x0780,0xC741,0x0500,0xC5C1,0xC481,0x0440,0xCC01,0x0CC0,0x0D80,0xCD41,
  0x0F00,0xCFC1,0xCE81,0x0E40,0x0A00,0xCAC1,0xCB81,0x0B40,0xC901,0x09C0,
  0x0880,0xC841,0xD801,0x18C0,0x1980,0xD941,0x1B00,0xDBC1,0xDA81,0x1A40,
  0x1E00,0xDEC1,0xDF81,0x1F40,0xDD01,0x1DC0,0x1C80,0xDC41,0x1400,0xD4C1,
  0xD581,0x1540,0xD701,0x17C0,0x1680,0xD641,0xD201,0x12C0,0x1380,0xD341,
  0x1100,0xD1C1,0xD081,0x1040,0xF001,0x30C0,0x3180,0xF141,0x3300,0xF3C1,
  0xF281,0x3240,0x3600,0xF6C1,0xF781,0x3740,0xF501,0x35C0,0x3480,0xF441,
  0x3C00,0xFCC1,0xFD81,0x3D40,0xFF01,0x3FC0,0x3E80,0xFE41,0xFA01,0x3AC0,
  0x3B80,0xFB41,0x3900,0xF9C1,0xF881,0x3840,0x2800,0xE8C1,0xE981,0x2940,
  0xEB01,0x2BC0,0x2A80,0xEA41,0xEE01,0x2EC0,0x2F80,0xEF41,0x2D00,0xEDC1,
  0xEC81,0x2C40,0xE401,0x24C0,0x2580,0xE541,0x2700,0xE7C1,0xE681,0x2640,
  0x2200,0xE2C1,0xE381,0x2340,0xE101,0x21C0,0x2080,0xE041,0xA001,0x60C0,
  0x6180,0xA141,0x6300,0xA3C1,0xA281,0x6240,0x6600,0xA6C1,0xA781,0x6740,
  0xA501,0x65C0,0x6480,0xA441,0x6C00,0xACC1,0xAD81,0x6D40,0xAF01,0x6FC0,
  0x6E80,0xAE41,0xAA01,0x6AC0,0x6B80,0xAB41,0x6900,0xA9C1,0xA881,0x6840,
  0x7800,0xB8C1,0xB981,0x7940,0xBB01,0x7BC0,0x7A80,0xBA41,0xBE01,0x7EC0,
  0x7F80,0xBF41,0x7D00,0xBDC1,0xBC81,0x7C40,0xB401,0x74C0,0x7580,0xB541,
  0x7700,0xB7C1,0xB681,0x7640,0x7200,0xB2C1,0xB381,0x7340,0xB101,0x71C0,
  0x7080,0xB041,0x5000,0x90C1,0x9181,0x5140,0x9301,0x53C0,0x5280,0x9241,
  0x9601,0x56C0,0x5780,0x9741,0x5500,0x95C1,0x9481,0x5440,0x9C01,0x5CC0,
  0x5D80,0x9D41,0x5F00,0x9FC1,0x9E81,0x5E40,0x5A00,0x9AC1,0x9B81,0x5B40,
  0x9901,0x59C0,0x5880,0x9841,0x8801,0x48C0,0x4980,0x8941,0x4B00,0x8BC1,
  0x8A81,0x4A40,0x4E00,0x8EC1,0x8F81,0x4F40,0x8D01,0x4DC0,0x4C80,0x8C41,
  0x4400,0x84C1,0x8581,0x4540,0x8701,0x47C0,0x4680,0x8641,0x8201,0x42C0,
  0x4380,0x8341,0x4100,0x81C1,0x8081,0x4040
};
*/

/* table for MakeCRC16R(buf, 0x1021);

uint16 table[256] = {
  0x0000,0x1021,0x2042,0x3063,0x4084,0x50A5,0x60C6,0x70E7,0x8108,0x9129,
  0xA14A,0xB16B,0xC18C,0xD1AD,0xE1CE,0xF1EF,0x1231,0x0210,0x3273,0x2252,
  0x52B5,0x4294,0x72F7,0x62D6,0x9339,0x8318,0xB37B,0xA35A,0xD3BD,0xC39C,
  0xF3FF,0xE3DE,0x2462,0x3443,0x0420,0x1401,0x64E6,0x74C7,0x44A4,0x5485,
  0xA56A,0xB54B,0x8528,0x9509,0xE5EE,0xF5CF,0xC5AC,0xD58D,0x3653,0x2672,
  0x1611,0x0630,0x76D7,0x66F6,0x5695,0x46B4,0xB75B,0xA77A,0x9719,0x8738,
  0xF7DF,0xE7FE,0xD79D,0xC7BC,0x48C4,0x58E5,0x6886,0x78A7,0x0840,0x1861,
  0x2802,0x3823,0xC9CC,0xD9ED,0xE98E,0xF9AF,0x8948,0x9969,0xA90A,0xB92B,
  0x5AF5,0x4AD4,0x7AB7,0x6A96,0x1A71,0x0A50,0x3A33,0x2A12,0xDBFD,0xCBDC,
  0xFBBF,0xEB9E,0x9B79,0x8B58,0xBB3B,0xAB1A,0x6CA6,0x7C87,0x4CE4,0x5CC5,
  0x2C22,0x3C03,0x0C60,0x1C41,0xEDAE,0xFD8F,0xCDEC,0xDDCD,0xAD2A,0xBD0B,
  0x8D68,0x9D49,0x7E97,0x6EB6,0x5ED5,0x4EF4,0x3E13,0x2E32,0x1E51,0x0E70,
  0xFF9F,0xEFBE,0xDFDD,0xCFFC,0xBF1B,0xAF3A,0x9F59,0x8F78,0x9188,0x81A9,
  0xB1CA,0xA1EB,0xD10C,0xC12D,0xF14E,0xE16F,0x1080,0x00A1,0x30C2,0x20E3,
  0x5004,0x4025,0x7046,0x6067,0x83B9,0x9398,0xA3FB,0xB3DA,0xC33D,0xD31C,
  0xE37F,0xF35E,0x02B1,0x1290,0x22F3,0x32D2,0x4235,0x5214,0x6277,0x7256,
  0xB5EA,0xA5CB,0x95A8,0x8589,0xF56E,0xE54F,0xD52C,0xC50D,0x34E2,0x24C3,
  0x14A0,0x0481,0x7466,0x6447,0x5424,0x4405,0xA7DB,0xB7FA,0x8799,0x97B8,
  0xE75F,0xF77E,0xC71D,0xD73C,0x26D3,0x36F2,0x0691,0x16B0,0x6657,0x7676,
  0x4615,0x5634,0xD94C,0xC96D,0xF90E,0xE92F,0x99C8,0x89E9,0xB98A,0xA9AB,
  0x5844,0x4865,0x7806,0x6827,0x18C0,0x08E1,0x3882,0x28A3,0xCB7D,0xDB5C,
  0xEB3F,0xFB1E,0x8BF9,0x9BD8,0xABBB,0xBB9A,0x4A75,0x5A54,0x6A37,0x7A16,
  0x0AF1,0x1AD0,0x2AB3,0x3A92,0xFD2E,0xED0F,0xDD6C,0xCD4D,0xBDAA,0xAD8B,
  0x9DE8,0x8DC9,0x7C26,0x6C07,0x5C64,0x4C45,0x3CA2,0x2C83,0x1CE0,0x0CC1,
  0xEF1F,0xFF3E,0xCF5D,0xDF7C,0xAF9B,0xBFBA,0x8FD9,0x9FF8,0x6E17,0x7E36,
  0x4E55,0x5E74,0x2E93,0x3EB2,0x0ED1,0x1EF0
};
*/

/****************************************************************************/
/*                          now the md5 stuff                               */
/****************************************************************************/

struct md5context {
  uint32 state[4];
  uint32 count[2];
  uint8 buffer[64];
};

static void MD5Init(struct md5context *p)
{
  /* Load magic initialization constants. */
  p->state[0] = 0x67452301;
  p->state[1] = 0xefcdab89;
  p->state[2] = 0x98badcfe;
  p->state[3] = 0x10325476;

  /* Nothing counted, so count=0 */
  p->count[0] = 0;
  p->count[1] = 0;
}

#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21

/* Encodes input (uint32) into output (uint8). Assumes len is a multiple of 4. */
static void md5_encode(uint8 *output, const uint32 *input, uint32 len)
{
  uint32 i, j;

  for(i = 0, j = 0; j < len; i++, j += 4)
  {
    output[j]     = (uint8)  (input[i] & 0xff);
    output[j + 1] = (uint8) ((input[i] >> 8) & 0xff);
    output[j + 2] = (uint8) ((input[i] >> 16) & 0xff);
    output[j + 3] = (uint8) ((input[i] >> 24) & 0xff);
  }
}

/* Decodes input (uint8) into output (uint32). Assumes len is a multiple of 4. */
static void md5_decode(uint32 *output, const uint8 *input, uint32 len)
{
  uint32 i, j;

  for(i = 0, j = 0; j < len; i++, j += 4)
    output[i] = ((uint32)input[j]) | (((uint32)input[j + 1]) << 8)
    | (((uint32)input[j + 2]) << 16) | (((uint32)input[j + 3]) << 24);
}

static uint32 md5_rotateleft(uint32 x, uint32 n)	{ return (x << n) | (x >> (32 - n)); }

/* F, G, H and I are basic MD5 functions. */
static uint32 MD5_F(uint32 x, uint32 y, uint32 z)	{ return (x & y) | (~x & z); }
static uint32 MD5_G(uint32 x, uint32 y, uint32 z)	{ return (x & z) | (y & ~z); }
static uint32 MD5_H(uint32 x, uint32 y, uint32 z)	{ return x ^ y ^ z; }
static uint32 MD5_I(uint32 x, uint32 y, uint32 z)	{ return y ^ (x | ~z); }

/* FF, GG, HH, and II transformations for MD4_ROUNDs 1, 2, 3, and 4.
   Rotation is separate from addition to prevent recomputation. */
static void MD5_FF(uint32* a, uint32 b, uint32 c, uint32 d, uint32 x, uint32 s, uint32 ac)
{
  *a += MD5_F(b, c, d) + x + ac;
  *a = md5_rotateleft(*a, s) + b;
}

static void MD5_GG(uint32* a, uint32 b, uint32 c, uint32 d, uint32 x, uint32 s, uint32 ac)
{
  *a += MD5_G(b, c, d) + x + ac;
  *a = md5_rotateleft(*a, s) + b;
}

static void MD5_HH(uint32* a, uint32 b, uint32 c, uint32 d, uint32 x, uint32 s, uint32 ac)
{
  *a += MD5_H(b, c, d) + x + ac;
  *a = md5_rotateleft(*a, s) + b;
}

static void MD5_II(uint32* a, uint32 b, uint32 c, uint32 d, uint32 x, uint32 s, uint32 ac)
{
  *a += MD5_I(b, c, d) + x + ac;
  *a = md5_rotateleft(*a, s) + b;
}

/* MD5 basic transformation. Transforms state based on block. */
static void transform(struct md5context *p, const uint8 block[64])
{
  uint32 a = p->state[0], b = p->state[1], c = p->state[2], d = p->state[3], x[16];

  md5_decode(x, block, 64);

  /* MD4_ROUND 1 */
  MD5_FF(&a, b, c, d, x[ 0], S11, 0xd76aa478); /*  1 */
  MD5_FF(&d, a, b, c, x[ 1], S12, 0xe8c7b756); /*  2 */
  MD5_FF(&c, d, a, b, x[ 2], S13, 0x242070db); /*  3 */
  MD5_FF(&b, c, d, a, x[ 3], S14, 0xc1bdceee); /*  4 */
  MD5_FF(&a, b, c, d, x[ 4], S11, 0xf57c0faf); /*  5 */
  MD5_FF(&d, a, b, c, x[ 5], S12, 0x4787c62a); /*  6 */
  MD5_FF(&c, d, a, b, x[ 6], S13, 0xa8304613); /*  7 */
  MD5_FF(&b, c, d, a, x[ 7], S14, 0xfd469501); /*  8 */
  MD5_FF(&a, b, c, d, x[ 8], S11, 0x698098d8); /*  9 */
  MD5_FF(&d, a, b, c, x[ 9], S12, 0x8b44f7af); /* 10 */
  MD5_FF(&c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
  MD5_FF(&b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
  MD5_FF(&a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
  MD5_FF(&d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
  MD5_FF(&c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
  MD5_FF(&b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

  /* MD4_ROUND 2 */
  MD5_GG(&a, b, c, d, x[ 1], S21, 0xf61e2562); /* 17 */
  MD5_GG(&d, a, b, c, x[ 6], S22, 0xc040b340); /* 18 */
  MD5_GG(&c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
  MD5_GG(&b, c, d, a, x[ 0], S24, 0xe9b6c7aa); /* 20 */
  MD5_GG(&a, b, c, d, x[ 5], S21, 0xd62f105d); /* 21 */
  MD5_GG(&d, a, b, c, x[10], S22,  0x2441453); /* 22 */
  MD5_GG(&c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
  MD5_GG(&b, c, d, a, x[ 4], S24, 0xe7d3fbc8); /* 24 */
  MD5_GG(&a, b, c, d, x[ 9], S21, 0x21e1cde6); /* 25 */
  MD5_GG(&d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
  MD5_GG(&c, d, a, b, x[ 3], S23, 0xf4d50d87); /* 27 */
  MD5_GG(&b, c, d, a, x[ 8], S24, 0x455a14ed); /* 28 */
  MD5_GG(&a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
  MD5_GG(&d, a, b, c, x[ 2], S22, 0xfcefa3f8); /* 30 */
  MD5_GG(&c, d, a, b, x[ 7], S23, 0x676f02d9); /* 31 */
  MD5_GG(&b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */

  /* MD4_ROUND 3 */
  MD5_HH(&a, b, c, d, x[ 5], S31, 0xfffa3942); /* 33 */
  MD5_HH(&d, a, b, c, x[ 8], S32, 0x8771f681); /* 34 */
  MD5_HH(&c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
  MD5_HH(&b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
  MD5_HH(&a, b, c, d, x[ 1], S31, 0xa4beea44); /* 37 */
  MD5_HH(&d, a, b, c, x[ 4], S32, 0x4bdecfa9); /* 38 */
  MD5_HH(&c, d, a, b, x[ 7], S33, 0xf6bb4b60); /* 39 */
  MD5_HH(&b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
  MD5_HH(&a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
  MD5_HH(&d, a, b, c, x[ 0], S32, 0xeaa127fa); /* 42 */
  MD5_HH(&c, d, a, b, x[ 3], S33, 0xd4ef3085); /* 43 */
  MD5_HH(&b, c, d, a, x[ 6], S34,  0x4881d05); /* 44 */
  MD5_HH(&a, b, c, d, x[ 9], S31, 0xd9d4d039); /* 45 */
  MD5_HH(&d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
  MD5_HH(&c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
  MD5_HH(&b, c, d, a, x[ 2], S34, 0xc4ac5665); /* 48 */

  /* MD4_ROUND 4 */
  MD5_II(&a, b, c, d, x[ 0], S41, 0xf4292244); /* 49 */
  MD5_II(&d, a, b, c, x[ 7], S42, 0x432aff97); /* 50 */
  MD5_II(&c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
  MD5_II(&b, c, d, a, x[ 5], S44, 0xfc93a039); /* 52 */
  MD5_II(&a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
  MD5_II(&d, a, b, c, x[ 3], S42, 0x8f0ccc92); /* 54 */
  MD5_II(&c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
  MD5_II(&b, c, d, a, x[ 1], S44, 0x85845dd1); /* 56 */
  MD5_II(&a, b, c, d, x[ 8], S41, 0x6fa87e4f); /* 57 */
  MD5_II(&d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
  MD5_II(&c, d, a, b, x[ 6], S43, 0xa3014314); /* 59 */
  MD5_II(&b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
  MD5_II(&a, b, c, d, x[ 4], S41, 0xf7537e82); /* 61 */
  MD5_II(&d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
  MD5_II(&c, d, a, b, x[ 2], S43, 0x2ad7d2bb); /* 63 */
  MD5_II(&b, c, d, a, x[ 9], S44, 0xeb86d391); /* 64 */

  p->state[0] += a;
  p->state[1] += b;
  p->state[2] += c;
  p->state[3] += d;

  /* Zeroize sensitive information. */
  memset((uint8 *) x, 0, sizeof(x));
}

static void MD5Update(struct md5context *p, const uint8 *input, uint32 input_length)
{
  uint32 input_index, buffer_index;
  uint32 buffer_space;                /* how much space is left in buffer */

  /* Compute number of int8s mod 64 */
  buffer_index = (uint32)((p->count[0] >> 3) & 0x3F);

  /* Update number of bits */
  if((p->count[0] += ((uint32)input_length << 3))<((uint32)input_length << 3))
    p->count[1]++;

  p->count[1] += ((uint32)input_length >> 29);

  buffer_space = 64 - buffer_index;  /* how much space is left in buffer */

  /* Transform as many times as possible. */
  if(input_length >= buffer_space) /* ie. we have enough to fill the buffer */
  {
    /* fill the rest of the buffer and transform */
    memcpy(p->buffer + buffer_index, input, buffer_space);
    transform(p, p->buffer);

    /* now, transform each 64-int8 piece of the input, bypassing the buffer */
    for(input_index = buffer_space; input_index + 63 < input_length; input_index += 64)
      transform(p, input + input_index);

    buffer_index = 0; /* so we can buffer remaining */
  }
  else
    input_index = 0; /* so we can buffer the whole input */

  /* and here we do the buffering: */
  memcpy(p->buffer + buffer_index, input + input_index, input_length - input_index);
}

static void MD5Final(unsigned char digest[16], struct md5context *p)
{
  static const uint8 PADDING[64]={
    0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  uint32 index, padLen;
  uint8 bits[8];

  /* Save number of bits */
  md5_encode(bits, p->count, 8);

  /* Pad out to 56 mod 64. */
  index = (uint32) ((p->count[0] >> 3) & 0x3f);
  padLen = (index < 56) ? (56 - index) : (120 - index);
  MD5Update(p, PADDING, padLen);

  /* Append length (before padding) */
  MD5Update(p, bits, 8);

  /* Store state in digest */
  md5_encode(digest, p->state, 16);

  /* Zeroize sensitive information */
  memset(p->buffer, 0, sizeof(p->buffer));
}

void md5sum(const uint8 *Mem, int32 Size, uint8 md5sum[16])
{
  struct md5context m;

  MD5Init(&m);
  MD5Update(&m, Mem, Size);
  MD5Final(md5sum, &m);
}

/****************************************************************************/
/*                          now the md4 stuff                               */
/*                                                                          */
/*                                                                          */
/*	mdfour.c                                                            */
/*                                                                          */
/*	An implementation of MD4 designed for use in the samba SMB          */
/*	authentication protocol                                             */
/*                                                                          */
/*	Copyright (C) 1997-1998 Andrew Tridgell                             */
/*      Modified and shortened by SDI 2002                                  */
/*                                                                          */
/*	This program is free software; you can redistribute it and/or       */
/*	modify it under the terms of the GNU General Public License         */
/*	as published by the Free Software Foundation; either version 2      */
/*	of the License, or (at your option) any later version.              */
/*                                                                          */
/*	This program is distributed in the hope that it will be useful,     */
/*	but WITHOUT ANY WARRANTY; without even the implied warranty of      */
/*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                */
/*                                                                          */
/*	See the GNU General Public License for more details.                */
/*                                                                          */
/*	You should have received a copy of the GNU General Public License   */
/*	along with this program; if not, write to:                          */
/*                                                                          */
/*		Free Software Foundation, Inc.                              */
/*		59 Temple Place - Suite 330                                 */
/*		Boston, MA  02111-1307, USA                                 */
/*                                                                          */
/****************************************************************************/

struct mdfour {
  uint32 A;
  uint32 B;
  uint32 C;
  uint32 D;
  uint32 totalN;
};

#define MD4_F(X,Y,Z) (((X)&(Y)) | ((~(X))&(Z)))
#define MD4_G(X,Y,Z) (((X)&(Y)) | ((X)&(Z)) | ((Y)&(Z)))
#define MD4_H(X,Y,Z) ((X)^(Y)^(Z))

#ifdef LARGE_INT32
  #define lshift(x,s) ((((x)<<(s))&0xFFFFFFFF) | (((x)>>(32-(s)))&0xFFFFFFFF))
#else
  #define lshift(x,s) (((x)<<(s)) | ((x)>>(32-(s))))
#endif

#define MD4_ROUND1(a,b,c,d,k,s) a = lshift(a + MD4_F(b,c,d) + X[k], s)
#define MD4_ROUND2(a,b,c,d,k,s) a = lshift(a + MD4_G(b,c,d) + X[k] + 0x5A827999,s)
#define MD4_ROUND3(a,b,c,d,k,s) a = lshift(a + MD4_H(b,c,d) + X[k] + 0x6ED9EBA1,s)

/* this applies md4 to 64 byte chunks */
static void mdfour64(struct mdfour *m, const uint32 * X)
{
  uint32 A, B, C, D;

  A = m->A;
  B = m->B;
  C = m->C;
  D = m->D;

  MD4_ROUND1(A, B, C, D, 0, 3);
  MD4_ROUND1(D, A, B, C, 1, 7);
  MD4_ROUND1(C, D, A, B, 2, 11);
  MD4_ROUND1(B, C, D, A, 3, 19);
  MD4_ROUND1(A, B, C, D, 4, 3);
  MD4_ROUND1(D, A, B, C, 5, 7);
  MD4_ROUND1(C, D, A, B, 6, 11);
  MD4_ROUND1(B, C, D, A, 7, 19);
  MD4_ROUND1(A, B, C, D, 8, 3);
  MD4_ROUND1(D, A, B, C, 9, 7);
  MD4_ROUND1(C, D, A, B, 10, 11);
  MD4_ROUND1(B, C, D, A, 11, 19);
  MD4_ROUND1(A, B, C, D, 12, 3);
  MD4_ROUND1(D, A, B, C, 13, 7);
  MD4_ROUND1(C, D, A, B, 14, 11);
  MD4_ROUND1(B, C, D, A, 15, 19);

  MD4_ROUND2(A, B, C, D, 0, 3);
  MD4_ROUND2(D, A, B, C, 4, 5);
  MD4_ROUND2(C, D, A, B, 8, 9);
  MD4_ROUND2(B, C, D, A, 12, 13);
  MD4_ROUND2(A, B, C, D, 1, 3);
  MD4_ROUND2(D, A, B, C, 5, 5);
  MD4_ROUND2(C, D, A, B, 9, 9);
  MD4_ROUND2(B, C, D, A, 13, 13);
  MD4_ROUND2(A, B, C, D, 2, 3);
  MD4_ROUND2(D, A, B, C, 6, 5);
  MD4_ROUND2(C, D, A, B, 10, 9);
  MD4_ROUND2(B, C, D, A, 14, 13);
  MD4_ROUND2(A, B, C, D, 3, 3);
  MD4_ROUND2(D, A, B, C, 7, 5);
  MD4_ROUND2(C, D, A, B, 11, 9);
  MD4_ROUND2(B, C, D, A, 15, 13);

  MD4_ROUND3(A, B, C, D, 0, 3);
  MD4_ROUND3(D, A, B, C, 8, 9);
  MD4_ROUND3(C, D, A, B, 4, 11);
  MD4_ROUND3(B, C, D, A, 12, 15);
  MD4_ROUND3(A, B, C, D, 2, 3);
  MD4_ROUND3(D, A, B, C, 10, 9);
  MD4_ROUND3(C, D, A, B, 6, 11);
  MD4_ROUND3(B, C, D, A, 14, 15);
  MD4_ROUND3(A, B, C, D, 1, 3);
  MD4_ROUND3(D, A, B, C, 9, 9);
  MD4_ROUND3(C, D, A, B, 5, 11);
  MD4_ROUND3(B, C, D, A, 13, 15);
  MD4_ROUND3(A, B, C, D, 3, 3);
  MD4_ROUND3(D, A, B, C, 11, 9);
  MD4_ROUND3(C, D, A, B, 7, 11);
  MD4_ROUND3(B, C, D, A, 15, 15);

  m->A += A;
  m->B += B;
  m->C += C;
  m->D += D;

#ifdef LARGE_INT32
  m->A &= 0xFFFFFFFF;
  m->B &= 0xFFFFFFFF;
  m->C &= 0xFFFFFFFF;
  m->D &= 0xFFFFFFFF;
#endif
}

static void copy64(uint32 *M, const uint8 *in)
{
  int32 i;

  for(i = 0; i < 16; i++)
  {
    M[i] = (in[i * 4 + 3] << 24) | (in[i * 4 + 2] << 16)
    | (in[i * 4 + 1] << 8) | (in[i * 4 + 0] << 0);
  }
}

static void copy4(uint8 *out, uint32 x)
{
  out[0] = x & 0xFF;
  out[1] = (x >> 8) & 0xFF;
  out[2] = (x >> 16) & 0xFF;
  out[3] = (x >> 24) & 0xFF;
}

static void mdfour_begin(struct mdfour *md)
{
  md->A = 0x67452301;
  md->B = 0xefcdab89;
  md->C = 0x98badcfe;
  md->D = 0x10325476;
  md->totalN = 0;
}

static void mdfour_tail(struct mdfour *m, const uint8 *in, uint32 n)
{
  uint8  buf[128];
  uint32 M[16];
  uint32 b;

  m->totalN += n;

  b = m->totalN * 8;

  memset(buf, 0, 128);
  if(n)
    memcpy(buf, in, n);
  buf[n] = 0x80;

  if(n <= 55)
  {
    copy4(buf + 56, b);
    copy64(M, buf);
    mdfour64(m, M);
  }
  else
  {
    copy4(buf + 120, b);
    copy64(M, buf);
    mdfour64(m, M);
    copy64(M, buf + 64);
    mdfour64(m, M);
  }
}

static void mdfour_update(struct mdfour *m, const uint8 *in, uint32 n)
{
  uint32 M[16];

  if(!n)
    mdfour_tail(m, in, n);

  while(n >= 64)
  {
    copy64(M, in);
    mdfour64(m, M);
    in += 64;
    n -= 64;
    m->totalN += 64;
  }
  mdfour_tail(m, in, n);
}

static void mdfour_result(struct mdfour *md, uint8 *out)
{
  copy4(out, md->A);
  copy4(out + 4, md->B);
  copy4(out + 8, md->C);
  copy4(out + 12, md->D);
}

void mdfour(const uint8 *Mem, int32 Size, uint8 md4sum[16])
{
  struct mdfour md;

  mdfour_begin(&md);
  mdfour_update(&md, Mem, Size);
  mdfour_result(&md, md4sum);
}

/*  SHA1 stuff, derived from RFC3174, programmers error handling removed,
 *  assuming that programmers know how to call the 3 functions
 *
 *  Description:
 *      This file implements the Secure Hashing Algorithm 1 as
 *      defined in FIPS PUB 180-1 published April 17, 1995.
 *
 *      The SHA-1, produces a 160-bit message digest for a given
 *      data stream.  It should take about 2**n steps to find a
 *      message with the same digest as a given message and
 *      2**(n/2) to find any two messages with the same digest,
 *      when n is the digest size in bits.  Therefore, this
 *      algorithm can serve as a means of providing a
 *      "fingerprint" for a message.
 *
 *  Caveats:
 *      SHA-1 is designed to work with messages less than 2^64 bits
 *      long.  Although SHA-1 allows a message digest to be generated
 *      for messages of any number of bits less than 2^64, this
 *      implementation only works with messages with a length that is
 *      a multiple of the size of an 8-bit character.
 */

#define SHA1HashSize 20

/* This structure will hold context information for the SHA-1
 * hashing operation */
struct SHA1Context
{
  uint32 Intermediate_Hash[SHA1HashSize/4]; /* Message Digest       */

  uint32 Length_Low;            /* Message length in bits           */
  uint32 Length_High;           /* Message length in bits           */

                                /* Index into message block array   */
  int16 Message_Block_Index;
  uint8 Message_Block[64];      /* 512-bit message blocks           */
};

/* Define the SHA1 circular left shift macro */
#define SHA1CircularShift(bits,word) \
                (((word) << (bits)) | ((word) >> (32-(bits))))

/*
 *  SHA1ProcessMessageBlock
 *
 *  Description:
 *      This function will process the next 512 bits of the message
 *      stored in the Message_Block array.
 *
 *  Comments:
 *      Many of the variable names in this code, especially the
 *      single character names, were used because those were the
 *      names used in the publication.
 *
 *
 */
static void SHA1ProcessMessageBlock(struct SHA1Context *context)
{
  const uint32 K[4] = {/* Constants defined in SHA-1   */
    0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6};
  int         t;                 /* Loop counter                */
  uint32      temp;              /* Temporary word value        */
  uint32      W[80];             /* Word sequence               */
  uint32      A, B, C, D, E;     /* Word buffers                */

  /* Initialize the first 16 words in the array W */
  for(t = 0; t < 16; t++)
  {
    W[t] = context->Message_Block[t * 4] << 24;
    W[t] |= context->Message_Block[t * 4 + 1] << 16;
    W[t] |= context->Message_Block[t * 4 + 2] << 8;
    W[t] |= context->Message_Block[t * 4 + 3];
  }

  for(t = 16; t < 80; t++)
  {
    W[t] = SHA1CircularShift(1,W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16]);
  }

  A = context->Intermediate_Hash[0];
  B = context->Intermediate_Hash[1];
  C = context->Intermediate_Hash[2];
  D = context->Intermediate_Hash[3];
  E = context->Intermediate_Hash[4];

  for(t = 0; t < 20; t++)
  {
    temp =  SHA1CircularShift(5,A) +
    ((B & C) | ((~B) & D)) + E + W[t] + K[0];
    E = D;
    D = C;
    C = SHA1CircularShift(30,B);
    B = A;
    A = temp;
  }

  for(t = 20; t < 40; t++)
  {
    temp = SHA1CircularShift(5,A) + (B ^ C ^ D) + E + W[t] + K[1];
    E = D;
    D = C;
    C = SHA1CircularShift(30,B);
    B = A;
    A = temp;
  }

  for(t = 40; t < 60; t++)
  {
    temp = SHA1CircularShift(5,A) +
    ((B & C) | (B & D) | (C & D)) + E + W[t] + K[2];
    E = D;
    D = C;
    C = SHA1CircularShift(30,B);
    B = A;
    A = temp;
  }

  for(t = 60; t < 80; t++)
  {
    temp = SHA1CircularShift(5,A) + (B ^ C ^ D) + E + W[t] + K[3];
    E = D;
    D = C;
    C = SHA1CircularShift(30,B);
    B = A;
    A = temp;
  }

  context->Intermediate_Hash[0] += A;
  context->Intermediate_Hash[1] += B;
  context->Intermediate_Hash[2] += C;
  context->Intermediate_Hash[3] += D;
  context->Intermediate_Hash[4] += E;
  context->Message_Block_Index = 0;
}

/*
 *  SHA1PadMessage
 *
 *  Description:
 *      According to the standard, the message must be padded to an even
 *      512 bits.  The first padding bit must be a '1'.  The last 64
 *      bits represent the length of the original message.  All bits in
 *      between should be 0.  This function will pad the message
 *      according to those rules by filling the Message_Block array
 *      accordingly.  It will also call the ProcessMessageBlock function
 *      provided appropriately.  When it returns, it can be assumed that
 *      the message digest has been computed.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to pad
 *      ProcessMessageBlock: [in]
 *          The appropriate SHA*ProcessMessageBlock function
 *
 */
static void SHA1PadMessage(struct SHA1Context *context)
{
  /*
   *  Check to see if the current message block is too small to hold
   *  the initial padding bits and length.  If so, we will pad the
   *  block, process it, and then continue padding into a second
   *  block.
   */
  if(context->Message_Block_Index > 55)
  {
    context->Message_Block[context->Message_Block_Index++] = 0x80;
    while(context->Message_Block_Index < 64)
    {
      context->Message_Block[context->Message_Block_Index++] = 0;
    }

    SHA1ProcessMessageBlock(context);

    while(context->Message_Block_Index < 56)
    {
      context->Message_Block[context->Message_Block_Index++] = 0;
    }
  }
  else
  {
    context->Message_Block[context->Message_Block_Index++] = 0x80;
    while(context->Message_Block_Index < 56)
    {
      context->Message_Block[context->Message_Block_Index++] = 0;
    }
  }

  /*
   *  Store the message length as the last 8 octets
   */
  context->Message_Block[56] = context->Length_High >> 24;
  context->Message_Block[57] = context->Length_High >> 16;
  context->Message_Block[58] = context->Length_High >> 8;
  context->Message_Block[59] = context->Length_High;
  context->Message_Block[60] = context->Length_Low >> 24;
  context->Message_Block[61] = context->Length_Low >> 16;
  context->Message_Block[62] = context->Length_Low >> 8;
  context->Message_Block[63] = context->Length_Low;

  SHA1ProcessMessageBlock(context);
}

/*
 *  SHA1Reset
 *
 *  Description:
 *      This function will initialize the SHA1Context in preparation
 *      for computing a new SHA1 message digest.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to reset.
 *
 */
static void SHA1Reset(struct SHA1Context *context)
{
  context->Length_Low             = 0;
  context->Length_High            = 0;
  context->Message_Block_Index    = 0;

  context->Intermediate_Hash[0]   = 0x67452301;
  context->Intermediate_Hash[1]   = 0xEFCDAB89;
  context->Intermediate_Hash[2]   = 0x98BADCFE;
  context->Intermediate_Hash[3]   = 0x10325476;
  context->Intermediate_Hash[4]   = 0xC3D2E1F0;
}

/*
 *  SHA1Result
 *
 *  Description:
 *      This function will return the 160-bit message digest into the
 *      Message_Digest array  provided by the caller.
 *      NOTE: The first octet of hash is stored in the 0th element,
 *            the last octet of hash in the 19th element.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to use to calculate the SHA-1 hash.
 *      Message_Digest: [out]
 *          Where the digest is returned.
 */
static void SHA1Result(struct SHA1Context *context,
uint8 Message_Digest[SHA1HashSize])
{
  int i;

  SHA1PadMessage(context);
  for(i=0; i < 64; ++i)
  {
    /* message may be sensitive, clear it out */
    context->Message_Block[i] = 0;
  }
  context->Length_Low = 0;    /* and clear length */
  context->Length_High = 0;

  for(i = 0; i < SHA1HashSize; ++i)
  {
    Message_Digest[i] = context->Intermediate_Hash[i>>2]
    >> 8 * (3 - (i & 0x03));
  }
}

/*
 *  SHA1Input
 *
 *  Description:
 *      This function accepts an array of octets as the next portion
 *      of the message.
 *
 *  Parameters:
 *      context: [in/out]
 *          The SHA context to update
 *      message_array: [in]
 *          An array of characters representing the next portion of
 *          the message.
 *      length: [in]
 *          The length of the message in message_array
 *
 *  Returns:
 *      0 in case of error
 */
static int SHA1Input(struct SHA1Context *context,
const uint8 *message_array, uint32 length)
{
  while(length--)
  {
    context->Message_Block[context->Message_Block_Index++] =
    (*message_array & 0xFF);

    context->Length_Low += 8;
    if(!context->Length_Low)
    {
      context->Length_High++;
      if(!context->Length_High)
        return 0; /* Message is too long */
    }
    if(context->Message_Block_Index == 64)
      SHA1ProcessMessageBlock(context);
    message_array++;
  }
  return 1;
}

void sha1(const uint8 *Mem, int32 Size, uint8 sha1[20])
{
  struct SHA1Context sha;

  SHA1Reset(&sha);
  /* If total size can get greater than 64Bit, check result code! */
  SHA1Input(&sha, Mem, Size);
  SHA1Result(&sha, sha1);
}

/****************************************************************************/
/*                      now some obsoleted stuff                            */
/****************************************************************************/

/* original Amiga version
uint32 DoCHS32_1(const uint32 *Mem, int32 Size)
{
  uint32 WRAP = 0, oldWRAP;

  Size >>= 2;

  while(Size--)
  {
    oldWRAP = WRAP;
    WRAP += *(Mem++);
    if(WRAP < oldWRAP)
      ++WRAP;
  }
  return ~WRAP;
}
*/

/* other, less efficent method
void MakeCRC32(uint32 *buf, uint32 ID)
{
  uint32 i, j, k, l;
  
  for(i = 0; i < 256; ++i)
  {
    k = 2*i;
    for(j = l = 0; j < 8; ++j)
    {
      k >>= 1;
      l = ((k ^ l) & 1) ? (l >> 1) ^ ID : l >> 1;
    }
    buf[i] = l;
  }
}
*/

/* other, less efficent method
void MakeCRC16R(uint16 *buf, uint16 ID)
{
  uint16 i, j, k, l;

  for(i = 0; i < 256; ++i)
  {
    l = i << 8;
    k = 0;

    for(j = 0; j < 8; ++j)
    {
      if((k ^ l) & 0x8000)
        k = (k << 1) ^ ID;
      else
        k <<= 1;
      l <<= 1;
    }
    buf[i] = k;
  }
}
*/

/* inline method
uint16 DoCRC16_1(const uint8 *Mem, int32 Size)
{
  uint16 CRC = 0;
  uint32 i;
  uint8 c;

  while(Size--)
  {
    c = *(Mem++);
    for(i=0; i < 8; i++)
    {
      if((CRC ^ c) & 1)
        CRC = (CRC>>1) ^ 0xA001;
      else
        CRC >>= 1;
      c>>=1;
    }
  }

  return CRC;
}
*/

/* inline method
uint16 DoCRC16_2(const uint8 *Mem, int32 Size)
{
  uint16 CRC = 0;
  uint32 i;
  uint16 c;

  while(Size--)
  {
    c = *(Mem++) << 8;
    for(i=0; i < 8; i++)
    {
      if((CRC ^ c) & 0x8000)
        CRC = (CRC<<1) ^ 0x1021;
      else
        CRC <<= 1;
      c<<=1;
    }
  }

  return CRC;
}
*/
