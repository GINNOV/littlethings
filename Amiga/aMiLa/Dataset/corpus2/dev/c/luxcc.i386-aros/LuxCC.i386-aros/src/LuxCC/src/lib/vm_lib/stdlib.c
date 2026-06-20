// Copyright (C) 2002 Michael Ringgaard. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of the project nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//

#include <stddef.h>

//
// Binary search
//
void *bsearch(const void *key, const void *base, size_t num, size_t width, int (*compare)(const void *, const void *)) {
  char *lo = (char *) base;
  char *hi = (char *) base + (num - 1) * width;
  char *mid;
  unsigned int half;
  int result;

  while (lo <= hi) {
    if (half = num / 2) {
      mid = lo + (num & 1 ? half : (half - 1)) * width;
      if (!(result = (*compare)(key,mid))) {
        return mid;
      } else if (result < 0) {
        hi = mid - width;
        num = num & 1 ? half : half - 1;
      } else {
        lo = mid + width;
        num = half;
      }
    } else if (num) {
      return ((*compare)(key, lo) ? NULL : lo);
    } else {
      break;
    }
  }

  return NULL;
}

//
// Quick sort
//
#define CUTOFF 8

static void shortsort(char *lo, char *hi, unsigned width, int (*comp)(const void *, const void *));
static void swap(char *p, char *q, unsigned int width);

void qsort(void *base, size_t num, size_t width, int (*comp)(const void *, const void *))
{
  char *lo, *hi;
  char *mid;
  char *l, *h;
  unsigned size;
  char *lostk[30], *histk[30];
  int stkptr;

  if (num < 2 || width == 0) return;
  stkptr = 0;

  lo = base;
  hi = (char *) base + width * (num - 1);

recurse:
  size = (hi - lo) / width + 1;

  if (size <= CUTOFF) {
    shortsort(lo, hi, width, comp);
  } else {
    mid = lo + (size / 2) * width;
    swap(mid, lo, width);

    l = lo;
    h = hi + width;

    for (;;) {
      do { l += width; } while (l <= hi && comp(l, lo) <= 0);
      do { h -= width; } while (h > lo && comp(h, lo) >= 0);
      if (h < l) break;
      swap(l, h, width);
    }

    swap(lo, h, width);

    if (h - 1 - lo >= hi - l) {
      if (lo + width < h) {
        lostk[stkptr] = lo;
        histk[stkptr] = h - width;
        ++stkptr;
      }

      if (l < hi) {
        lo = l;
        goto recurse;
      }
    } else {
      if (l < hi) {
        lostk[stkptr] = l;
        histk[stkptr] = hi;
        ++stkptr;
      }

      if (lo + width < h) {
        hi = h - width;
        goto recurse;
      }
    }
  }

  --stkptr;
  if (stkptr >= 0) {
    lo = lostk[stkptr];
    hi = histk[stkptr];
    goto recurse;
  }
}

static void shortsort(char *lo, char *hi, unsigned width, int (*comp)(const void *, const void *)) {
  char *p, *max;

  while (hi > lo) {
    max = lo;
    for (p = lo + width; p <= hi; p += width) if (comp(p, max) > 0) max = p;
    swap(max, hi, width);
    hi -= width;
  }
}

static void swap(char *a, char *b, unsigned width) {
  char tmp;

  if (a != b) {
    while (width--) {
      tmp = *a;
      *a++ = *b;
      *b++ = tmp;
    }
  }
}


void *calloc(size_t nelem, size_t size)
{
    void *p;
    unsigned nb;

    if (nelem==0 || size==0)
        return NULL;

    nb = nelem*size;
    if ((p=malloc(nb)) != NULL)
        memset(p, 0, nb);

    return p;
}

char *getenv(const char *name)
{
    return NULL;
}

/* stdio.c */
#if 0
long simple_strtol(const char *, char **, unsigned int);
unsigned long simple_strtoul(const char *, char **, unsigned int);
unsigned long long simple_strtoull(const char *,char **, unsigned int);
long long simple_strtoll(const char *cp, char **, unsigned int);

long strtol(const char *nptr, char **endptr, int base)
{
    return simple_strtol(nptr, endptr, base);
}

unsigned long strtoul(const char *nptr, char **endptr, int base)
{
    return simple_strtoul(nptr, endptr, base);
}

long long strtoll(const char *nptr, char **endptr, int base)
{
    return simple_strtoll(nptr, endptr, base);
}

unsigned long long strtoull(const char *nptr, char **endptr, int base)
{
    return simple_strtoull(nptr, endptr, base);
}
#endif

int atoi(const char *s)
{
    int n;
    n=0;
    while (*s != 0 && (*s >= '0' && *s <= '9')) {
        n=n*10+(*s - '0');
        s++;
    }
    return n;
}
