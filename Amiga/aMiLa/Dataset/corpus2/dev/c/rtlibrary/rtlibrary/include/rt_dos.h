/*
 * $Id: rt_dos.h $
 *
 * Author: Tomi Ollila <Tomi.Ollila@hut.fi>
 *
 * 	Copyright (c) 1995 Tomi Ollila
 * 	    All rights reserved
 *
 * Created: Mon Jan 30 01:47:51 1995 too
 * Last modified: Wed Feb  1 02:29:34 1995 too
 *
 * HISTORY 
 * $Log: $
 */

#ifndef RT_DOS_H
#define RT_DOS_H

#ifndef RT_H
#include <rt.h>
#endif

struct RTNode * rt_Open(struct RT * rt, BPTR * file, char * name, int mode);

#endif /* RT_DOS_H */
