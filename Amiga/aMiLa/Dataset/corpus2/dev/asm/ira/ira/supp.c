/*
 * supp.c
 *
 *      Author   : Tim Ruehsen, Crisi, Frank Wille, Nicolas Bastien
 *      Project  : IRA  -  680x0 Interactive ReAssembler
 *      Part     : supp.c
 *      Purpose  : Extended functions
 *      Copyright: (C)1993-1995 Tim Ruehsen
 *                 (C)2009-2023 Frank Wille, (C)2014-2016 Nicolas Bastien
 */

#include <ctype.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "ira.h"

extern ira_t *ira;

void *myalloc(size_t sz)
{
   void *p = NULL;

   if (sz && (p = malloc(sz)) == NULL)
      ExitPrg("Out of memory (allocating %u bytes)!", (unsigned) sz);
   return p;
}

void *mycalloc(size_t sz)
{
   void *p = myalloc(sz);

   memset(p, 0, sz);
   return p;
}

void *myrealloc(void *p, size_t sz)
{
   void *q;

   if ((q = realloc(p, sz)) == NULL)
      ExitPrg("Out of memory (reallocating %u bytes)!", (unsigned) sz);
   return q;
}

char *itoasc(int32_t integer)
{
   static char buf[16];
   int r = ira->params.radix;

   if (r == 0)
      r = (integer < 0) ? 10 : 16;

   switch (r) {
      case 16:
         if (integer<=-10 || integer>=10) {
            sprintf(buf, "$%lX", (unsigned long) integer);
            break;
         }
      default:
         sprintf(buf, "%ld", (long) integer);
         break;
   }
   return buf;
}

char *itohex(uint32_t integer, uint8_t len)
{
   static char buf[16];
   static char fmtbuf[] = "%04.4lx";

   fmtbuf[2] = len + '0';
   fmtbuf[4] = len + '0';
   sprintf(buf, fmtbuf, integer);
   return buf;
}

void mnecat(const char *buf)
{
   static unsigned long cnt;
   char *dst;
   unsigned char c;

   dst = &ira->mnebuf[ira->mnebuf[0] ? cnt : 0];

   do
   {
      c = *buf++;
      *dst++ = c;
   } while (c);

   cnt = dst - &ira->mnebuf[0] - 1;
}

void dtacat(const char *buf)
{
   static unsigned long cnt;
   char *dst;
   unsigned char c;

   dst = &ira->dtabuf[ira->dtabuf[0] ? cnt : 0];

   do
   {
      c = *buf++;
      *dst++ = c;
   } while (c);

   cnt = dst - &ira->dtabuf[0] - 1;
}

void adrcat(const char *buf)
{
   static unsigned long cnt;
   char *dst;
   unsigned char c;

   dst = &ira->adrbuf[ira->adrbuf[0] ? cnt : 0];

   do
   {
      c = *buf++;
      *dst++ = c;
   } while (c);

   cnt = dst - &ira->adrbuf[0] - 1;
}

char *argopt(int argc, char **argv, int *nextarg, char *option)
{
   char *odata, *p;

   odata = NULL;

   if (argc > *nextarg)
   {
      p = argv[*nextarg];

      if (*p == '-')
      {
         *nextarg += 1;
         p++;

         *option = *p;
         odata = p + 1;
      }
   }

   return odata;
}

int stricmp(const char *str1, const char *str2)
{
   const unsigned char *us1 = (const unsigned char *) str1,
         *us2 = (const unsigned char *) str2;

   while (tolower(*us1) == tolower(*us2++))
      if (*us1++ == '\0')
         return 0;
   return (tolower(*us1) - tolower(*--us2));
}

int strnicmp(const char *str1, const char *str2, size_t n)
{
   if (str1 == NULL || str2 == NULL)
      return 0;

   if (n)
   {
      const unsigned char *us1 = (const unsigned char *) str1,
            *us2 = (const unsigned char *) str2;

      do
      {
         if (tolower(*us1) != tolower(*us2++))
            return tolower(*us1) - tolower(*--us2);
         if (*us1++ == '\0')
            break;
      } while (--n != 0);
   }

   return 0;
}

int stccpy(char *p, const char *q, size_t n)
{
   char *t = p;

   while ((*p++ = *q++) && --n > 0)
      ;
   p[-1] = '\0';

   return p - t;
}

int32_t stcd_base(const char *p, int base)
{
   int32_t result;
   char *p2;

   result = 0;
   if (p)
      if (*p == '+' || *p == '-' || (base == 10 ? isdigit((unsigned char) *p) : isxdigit((unsigned char) *p)))
         result = (int32_t) strtol(p, &p2, base);

   return result;
}

int32_t stcd_l(const char *p)
{
   return stcd_base(p, 10);
}

int32_t stch_l(const char *p)
{
   return stcd_base(p, 16);
}

int32_t parseAddress(const char *p)
{
   if (p[0] == '$')
      return stch_l(p + 1);
   else if (p[0] == '0' && tolower((unsigned char)p[1]) == 'x')
      return stch_l(p + 2);
   else
      return stcd_l(p);
}

char *strupr(char *p)
{
   char *ret = p;

   while (*p)
   {
      if (islower(*p))
         *p = toupper(*p);
      p++;
   }

   return ret;
}

char *mystrdup(char *p)
{
   char *s = myalloc(strlen(p) + 1);
   strcpy(s, p);

   return s;
}

void delfile(const char *path)
{
   FILE *f;

   if ((f = fopen(path, "rb")))
   {
      fclose(f);
      remove(path);
   }
}

uint16_t be16(void *buf)
{
   uint8_t *p = buf;

   return (((uint16_t) p[0]) << 8) | (uint16_t) p[1];
}

uint32_t be32(void *buf)
{
   uint8_t *p = buf;

   return (((uint32_t) p[0]) << 24) | (((uint32_t) p[1]) << 16) | (((uint32_t) p[2]) << 8) | (uint32_t) p[3];
}

void wbe32(void *buf, uint32_t v)
{
   uint8_t *p = buf;

   *p++ = (uint8_t) (v >> 24);
   *p++ = (uint8_t) (v >> 16);
   *p++ = (uint8_t) (v >> 8);
   *p = (uint8_t) v;
}

uint32_t readbe32(FILE *f)
{
   uint32_t d;

   if (fread(&d, sizeof(uint32_t), 1, f) == 1)
      return be32(&d);
   return 0;
}
