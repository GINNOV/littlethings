// Exec/semaphores.h
//
// (C) 1986, MTS Associates
//
#ifndef EXEC_SEMAPHORES_H
#define EXEC_SEMAPHORES_H
#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif !EXEC_NODES_H
#ifndef EXEC_LISTS_H
#include "exec/lists.h"
#endif !EXEC_LISTS_H
#ifndef EXEC_PORTS_H
#include "exec/ports.h"
#endif !EXEC_PORTS_H
#ifndef EXEC_TASKS_H
#include "exec/tasks.h"
#endif !EXEC_TASKS_H

struct Semaphore : public MsgPort {
    WORD   sm_Bids;
};

#define sm_LockMsg      mp_SigTask
struct SemaphoreRequest : public MinNode {
//    MinNode sr_Link;
    Task *sr_Waiter;
};

struct SignalSemaphore : public Node {
    SHORT   ss_NestCount;
    MinList ss_WaitQueue;
    SemaphoreRequest ss_MultipleLink;
    Task    *ss_Owner;
    SHORT   ss_QueueCount;
};

void AddSemaphore(const  SignalSemaphore *s);
BOOL AttemptSemaphore( SignalSemaphore *s);
SignalSemaphore * FindSemaphore(const TEXT *t);
void InitSemaphore( SignalSemaphore *s);
void ObtainSemaphore( SignalSemaphore *s);
void ObtainSemaphoreList( SignalSemaphore *s);
void ReleaseSemaphore( SignalSemaphore *s);
void ReleaseSemaphoreList( SignalSemaphore *s);
void RemSemaphore( SignalSemaphore *s);

BOOL Procure( Semaphore *s,  Message *bidmsg);
void Vacate( Semaphore *s);

#endif
