/*
 * $Id: rt_remsome.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sun Dec 25 01:01:58 1994 too
 * Last modified: Wed Feb  1 01:40:16 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include "rt_priv.h"

void rt_RemSome(struct RT * rt, void * ptr, ULONG flags)
{
  struct RTNode * node = rt->node;
  int dataflag = flags & RTRF_DATA;

  while (node->func) {
    if (ptr == ((dataflag)? node->data: node)) {
      if (flags & RTRF_REMTO) {
	((f_void)node->func)(node->data);
	node--;
      }
      rt->node = node; /* - 1 */;
      return;
    }
    ((f_void)node->func)(node->data);
    node--;
  }
  rt->node = &rt->endnode;
}
