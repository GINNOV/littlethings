/*
 * $Id: rt_remnode.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sun Dec 25 00:16:01 1994 too
 * Last modified: Sun Dec 25 00:22:21 1994 too
 *
 * HISTORY 
 * $Log: $
 */

#include "rt_priv.h"

void rt_RemNode(struct RT * rt, struct RTNode * node)
{
  size_t *i, *j = (size_t *)(rt->node + 1);

  ((f_void)node->func)(node->data);

  for (i = (size_t *)node; i < j; i++)
    i[0] = i[sizeof (struct RTNode) / sizeof (size_t)];

  rt->node--;
}
