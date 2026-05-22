#ifndef POWERPC_PORTSPPC_H
#define POWERPC_PORTSPPC_H

/*
**  $VER: portsPPC.h 2.0 (15.03.98)
**  WarpOS Release 14.1
**
**  '(C) Copyright 1998 Haage & Partner Computer GmbH'
**       All Rights Reserved
*/


#ifndef EXEC_PORTS_H
#include <exec/ports.h>
#endif

#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif

#ifndef POWERPC_SEMAPHORESPPC_H
#include <powerpc/semaphoresPPC.h>
#endif

struct MsgPortPPC {
        struct MsgPort mp_Port;
        struct List mp_IntMsg;
        struct SignalSemaphorePPC mp_Semaphore;
};

#define NT_MSGPORTPPC 101

#endif
