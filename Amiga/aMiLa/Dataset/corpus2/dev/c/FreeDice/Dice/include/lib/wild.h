
/*
 *  LIB/WILD.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef _LIB_WILD_H
#define _LIB_WILD_H

extern void *_ParseWild(const char *, short)
extern int _CompWild(const char *, void *, void *);
extern void _FreeWild(void *);

#endif
