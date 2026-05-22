
/*
 *  LISTS.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef LISTS_H
#define LISTS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

extern void *GetHead(void *);
extern void *GetTail(void *);
extern void *GetSucc(void *);
extern void *GetPred(void *);

#endif

