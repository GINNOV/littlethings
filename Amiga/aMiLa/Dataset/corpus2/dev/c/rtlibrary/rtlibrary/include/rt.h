/*
 * $Id: rt_h $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1994 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sat Dec 24 23:08:52 1994 too
 * Last modified: Wed Feb  1 00:14:56 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#ifndef RT_H
#define RT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct RT;
struct RTNode;

/*
 *	RT_Rem* flags
 */
#define RTRF_DATA	0x01	/* either data or node, must be present */
#define RTRF_NODE	0x02

#define RTRF_REMTO	0x04	/* either to or until, when needed */
#define RTRF_REMUNTIL	0x08

struct RT *	rt_Create(int size);
struct RTNode *	rt_Add(struct RT * rt,  void * func, void * data);
void		rt_Delete(struct RT * rt);

BOOL rt_RemData(struct RT * rt, void * data);
void rt_RemNode(struct RT * rt, struct RTNode * node);
void rt_RemSome(struct RT * rt, void * ptr, ULONG flags);

#ifndef unless
#define unless(x) if (!(x))
#endif

#endif /* RT_H */
