/*
 * $Id: rt.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sat Dec 24 23:56:19 1994 too
 * Last modified: Mon Jan 30 01:40:37 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include <proto/exec.h>
#include "rt_priv.h"

struct RT * rt_Create(int size)
{
  int asize = sizeof (struct RT) + size * sizeof (struct RTNode);

  struct RT * rt = (struct RT *)AllocMem(asize, 0);
  rt->node = &rt->endnode;
  rt->endnode.func = 0;
  rt->endnode.data = (void *)asize;

  return rt;
}

struct RTNode * rt_Add(struct RT * rt,  void * func, void * data)
{
  rt->node++;
  
  rt->node->func = func;
  rt->node->data = data;

  return rt->node;
}

void rt_Delete(struct RT * rt)
{
  struct RTNode * node = rt->node;

  while (node->func) {
    ((f_void)node->func)(node->data);
    node--;
  }
  FreeMem(rt, (int)rt->endnode.data);
}
