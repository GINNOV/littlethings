/*
 * $Id: rt_remitem.c $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sun Dec 25 00:18:50 1994 too
 * Last modified: Sun Dec 25 01:01:42 1994 too
 *
 * HISTORY 
 * $Log: $
 */

#include "rt_priv.h"

BOOL rt_RemData(struct RT * rt, void * data)
{
  struct RTNode * node = rt->node;
  size_t * i;

  while (node->func) {
    if (data == node->data) {
      size_t * j = (size_t *)(rt->node + 1);
  
      ((f_void)node->func)(node->data);

      for (i = (size_t *)node; i < j; i++)
	i[0] = i[sizeof (struct RTNode) / sizeof (size_t)];

      rt->node--;
      return TRUE;
    }
    node--;
  }
  return FALSE;
}
