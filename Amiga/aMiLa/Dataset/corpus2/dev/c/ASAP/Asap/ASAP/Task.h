/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ATask wrapper class                                                       *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ATask_H
#define ASAP_ATask_H

extern "C"
{
 #include <Proto/EXEC.h>
}

class ATask : public Task
{
 public:
 inline APTR AddTask(APTR initPC, APTR finalPC);
 inline static ATask * FindTask(UBYTE * name);
 inline static void Forbid();
 inline static void Permit();
 inline void RemTask();
 inline BYTE SetTaskPri(long priority);
 inline void Signal(unsigned long signalSet);
};
//----------------------------------------------------------------------------
APTR ATask::AddTask (APTR initPC, APTR finalPC)
{
 return ::AddTask(this, initPC, finalPC);
}
//----------------------------------------------------------------------------
ATask * ATask::FindTask (UBYTE * name)
{
 return (ATask *) ::FindTask(name);
}
//----------------------------------------------------------------------------
void ATask::Forbid ()
{
 ::Forbid();
}
//----------------------------------------------------------------------------
void ATask::Permit ()
{
 ::Permit();
}
//----------------------------------------------------------------------------
void ATask::RemTask ()
{
 ::RemTask(this);
}
//----------------------------------------------------------------------------
BYTE ATask::SetTaskPri (long priority)
{
 return ::SetTaskPri(this, priority);
}
//----------------------------------------------------------------------------
void ATask::Signal (unsigned long signalSet)
{
 ::Signal(this, signalSet);
}

#endif
