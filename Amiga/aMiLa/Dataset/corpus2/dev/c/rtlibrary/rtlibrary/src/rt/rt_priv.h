/*
 * $Id: rt_priv.h $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sun Dec 25 00:16:45 1994 too
 * Last modified: Mon Jan 30 01:10:04 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#include <rt.h>

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif


struct RTNode {
  void * func;
  void * data;
};

struct RT {
#ifdef DEBUG
  int maxitems;
#endif  
  struct RTNode * node;
  struct RTNode endnode;
};

typedef LONG size_t;
typedef void (* f_void)(void *);

#ifndef BOOL
#define BOOL short
#endif

#ifndef unless
#define unless(x)	if(!(x))     
#endif
     
/* eof */
