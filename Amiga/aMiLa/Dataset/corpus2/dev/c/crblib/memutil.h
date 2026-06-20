#ifndef _MEMUTIL_H
#define _MEMUTIL_H

#include "inc.h"

/** the "Fast" routines take as 'len' the Number of ULONGS, NOT the number
      of bytes **/

#define MEMF_ANY 0
#define MEMF_FAST MEMF_ANY
#define MEMF_CHIP MEMF_ANY
#define MEMF_CLEAR 1

extern void * AllocMem(size_t size,int MemFlags);
extern void FreeMem(void * mem,int trash);
extern void MemClear(void *P,size_t len);
extern void MemClearFast(void *P,size_t len);

extern void MemCpy(void *To,void *Fm,size_t len);
extern void MemCpyFast(void *To,void *fm,size_t len);

#define MemClearMacro(a,b) MemClear(a,b)
#define MemCpyMacro(a,b,c) MemCpy(a,b,c)
#define MemClearMacroFast(a,b) MemClearFast(a,b)
#define MemCpyMacroFast(a,b,c) MemCpyFast(a,b,c)

#endif /* _MEMUTIL_H */
