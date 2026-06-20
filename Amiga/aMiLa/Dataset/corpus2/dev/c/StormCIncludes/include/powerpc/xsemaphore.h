#ifndef POWERPC_XSEMAPHORE_H
#define POWERPC_XSEMAPHORE_H

/*
**  $VER: xsemaphore.h 1.0 (04.10.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef POWERPC_SEMAPHORESPPC_H
#include <powerpc/semaphoresPPC.h>
#endif


struct XSemaphore
{
	/* private */
    ULONG *bid68k;
    ULONG *bidPPC;
    struct SignalSemaphore    *sema68k;
    struct SignalSemaphorePPC *semaPPC;
    ULONG pads[8];  /* for future extensions */
};


#ifdef __cplusplus
extern "C" {
#endif

BOOL InitXSemaphore(struct XSemaphore *);
void FreeXSemaphore(struct XSemaphore *);

void ObtainXSemaphore(struct XSemaphore *);
void ReleaseXSemaphore(struct XSemaphore *);

#ifdef __cplusplus
}
#endif


#endif /* POWERPC_XSEMAPHORE_H */
