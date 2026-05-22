/*
 * $Id: rt_Open.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Mon Jan 30 01:41:18 1995 too
 * Last modified: Mon Jan 30 01:53:23 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include <proto/dos.h>
#include <rt_dos.h>


/* sizeof(BPTR) == sizeof(void *) */
void rt_Close(BPTR file)
{
  Close(file);
}

struct RTNode * rt_Open(struct RT * rt, BPTR * file, char * name, int mode)
{
  unless (*file = Open(name, mode))
    return NULL;

  return rt_Add(rt, (void *)rt_Close, (void *)*file);
}

