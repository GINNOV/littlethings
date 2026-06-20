/*
 * $Id: rt_allocmem.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Fri Jan  6 22:07:31 1995 too
 * Last modified: Wed Feb  1 01:45:34 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include <proto/exec.h>
#include <rt_exec.h>

void rt_FreeMem(void * ptr)
{
  FreeVec(ptr);
}

struct RTNode * rt_AllocMem(struct RT * rt, void * memptr,
			   ULONG size, ULONG flags)
{
  unless (*(void **)memptr = AllocVec(size, flags))
    return NULL;

  return rt_Add(rt, rt_FreeMem, *(void **)memptr);
}
