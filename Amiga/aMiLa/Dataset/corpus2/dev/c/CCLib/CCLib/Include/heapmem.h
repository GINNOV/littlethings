#ifndef HEAPMEM_H
#define HEAPMEM_H 1

typedef long ALIGN;   /* forces long word alignment */

union header
{
struct
   {
   union header *ptr;
   unsigned long size;
   } s;
ALIGN x;
};

typedef union header HEADER;

typedef struct
{
void *ptr;
unsigned long size;
} LastFree;

#endif
