
/****************************************************************************
 *
 *  alloca() implementation for SAS/C
 *
 *  Copyright: PUBLIC DOMAIN
 *  Written by Stefan Proels <proels@fmi.uni-passau.de>
 *
 */

#include <stddef.h>
#include <stdlib.h>
#include <exec/types.h>
#include <exec/memory.h>
/*#include <clib/alib_protos.h>*/
#include <constructor.h>

APTR __stdargs LibCreatePool(unsigned long, unsigned long, unsigned long);
void __stdargs LibDeletePool(APTR);
void __stdargs LibFreePooled(APTR, APTR, unsigned long);
APTR __stdargs LibAllocPooled(APTR, unsigned long);

#ifndef __SASC
#error Wrong compiler (SAS/C required)
#endif

#ifdef _PROFILE
#error This file must NOT be compiled with PROFILE enabled
#endif


/*
 * each alloca()ted block is preceded by this header
 */
struct block
  {
    struct block *down;
    ULONG size;
    ULONG level;
    /* alloca()ted memory below */
  };

static APTR pool = NULL;
static struct block *top = NULL;
ULONG __alloca_SP = 0;


/*
 * SAS/C autoinitialization function
 */
PROFILE_CONSTRUCTOR(Sprof)
{
  if (pool = LibCreatePool(MEMF_ANY, 4096, 2048))
    return 0;
  return -1;
}

/*
 * SAS/C autotermination function
 */
PROFILE_DESTRUCTOR(Sprof)
{
  if (pool)
    LibDeletePool(pool);
}


/*
 * called whenever a function is entered
 */
void __asm _PROLOG(register __a0 char *dummy)
{
  __alloca_SP++;
}

/*
 * called on return from a function
 */
void __asm _EPILOG(register __a0 char *dummy)
{
  struct block *mem;

  for (mem = top; mem && mem->level >= __alloca_SP; mem = top)
    {
      top = mem->down;
      LibFreePooled(pool, mem, mem->size);
    }
  --__alloca_SP;
}


/*
 * that's what the whole thing is all about -- alloca()te memory
 */
void *alloca(size_t size)
{
  struct block *mem;

  if (size <= 0)  /* garbage collection -- not required */
    return NULL;

  size += sizeof(struct block);
  if (!(mem = (struct block *)LibAllocPooled(pool, (ULONG)size)))
    {
      /* do whatever you want here */
      abort();
    }
  mem->down = top;
  mem->size = size;
  mem->level = __alloca_SP;
  top = mem;
  return ++mem;
}

