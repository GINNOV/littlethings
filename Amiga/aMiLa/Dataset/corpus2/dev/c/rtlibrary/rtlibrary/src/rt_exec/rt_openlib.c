/*
 * $Id: rt_openlib.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Fri Jan  6 22:02:21 1995 too
 * Last modified: Wed Feb  1 01:45:17 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include <proto/exec.h>
#include <rt_exec.h>

void rt_CloseLib(struct Library * lib)
{
  CloseLibrary(lib);
}

struct RTNode * rt_OpenLib(struct RT * rt, void * libptr,
			   char * name, int version)
{
  unless (*(struct Library **)libptr = OpenLibrary(name, version))
    return NULL;

  return rt_Add(rt, rt_CloseLib, *(void **)libptr);
}
