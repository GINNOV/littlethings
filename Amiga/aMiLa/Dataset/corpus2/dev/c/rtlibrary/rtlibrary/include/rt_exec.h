/*
 * $Id: rt_exec.h $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1995 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Sun Jan 29 23:26:10 1995 too
 * Last modified: Wed Feb  1 02:29:28 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#ifndef RT_EXEC_H
#define RT_EXEC_H

#ifndef RT_H
#include <rt.h>
#endif

struct RTNode *	rt_OpenLib(struct RT * rt, void * libptr,
			   char * name, int version);
struct RTNode *	rt_AllocMem(struct RT * rt, void * memptr,
			    ULONG size, ULONG flags);

#endif /* RT_EXEC_H */
