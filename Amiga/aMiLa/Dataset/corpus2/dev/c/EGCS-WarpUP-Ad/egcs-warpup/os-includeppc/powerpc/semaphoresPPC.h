#ifndef POWERPC_SEMAPHORESPPC_H
#define POWERPC_SEMAPHORESPPC_H

/*
**  $VER: semaphoresPPC.h 2.0 (15.03.98)
**  WarpOS Release 14.1
**
**  '(C) Copyright 1998 Haage & Partner Computer GmbH'
**       All Rights Reserved
*/


#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif

/* SignalSemaphorePPC structure used by PPC semaphore functions */

struct SignalSemaphorePPC {
        struct SignalSemaphore ssppc_SS;
        APTR ssppc_reserved;
};

/* return value from InitSemaphore and AddSemaphore */

#define SSPPC_SUCCESS      -1
#define SSPPC_NOMEM        0

/* return values of AttemptSemaphore */

#define ATTEMPT_SUCCESS   -1
#define ATTEMPT_FAILURE   0

#endif
