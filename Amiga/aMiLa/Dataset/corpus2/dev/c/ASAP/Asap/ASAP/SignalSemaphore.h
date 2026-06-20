/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ASignalSemaphore wrapper class                                            *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ASignalSemaphore_H
#define ASAP_ASignalSemaphore_H

extern "C"
{
 #include <EXEC/Semaphores.h>
 #include <Proto/EXEC.h>
}

class ASignalSemaphore : public SignalSemaphore
{
 public:
 inline void AddSemaphore();
 inline ULONG AttemptSemaphore();
 inline ULONG AttemptSemaphoreShared();
 inline static ASignalSemaphore * FindSemaphore(UBYTE * sigSem);
 inline void InitSemaphore();
 inline void ObtainSemaphore();
 inline void ObtainSemaphoreShared();
 inline ULONG Procure(SemaphoreMessage * bidMsg);
 inline void ReleaseSemaphore();
 inline void RemSemaphore();
 inline void Vacate(SemaphoreMessage * bidMsg);
};
//----------------------------------------------------------------------------
void ASignalSemaphore::AddSemaphore ()
{
 ::AddSemaphore(this);
}
//----------------------------------------------------------------------------
ULONG ASignalSemaphore::AttemptSemaphore ()
{
 return ::AttemptSemaphore(this);
}
//----------------------------------------------------------------------------
ULONG ASignalSemaphore::AttemptSemaphoreShared ()
{
 return ::AttemptSemaphoreShared(this);
}
//----------------------------------------------------------------------------
ASignalSemaphore * ASignalSemaphore::FindSemaphore (UBYTE * sigSem)
{
 return (ASignalSemaphore *) ::FindSemaphore(sigSem);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::InitSemaphore ()
{
 ::InitSemaphore(this);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::ObtainSemaphore ()
{
 ::ObtainSemaphore(this);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::ObtainSemaphoreShared ()
{
 ::ObtainSemaphoreShared(this);
}
//----------------------------------------------------------------------------
ULONG ASignalSemaphore::Procure (SemaphoreMessage * bidMsg)
{
 return ::Procure(this, bidMsg);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::ReleaseSemaphore ()
{
 ::ReleaseSemaphore(this);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::RemSemaphore ()
{
 ::RemSemaphore(this);
}
//----------------------------------------------------------------------------
void ASignalSemaphore::Vacate (SemaphoreMessage * bidMsg)
{
 ::Vacate(this, bidMsg);
}

#endif
