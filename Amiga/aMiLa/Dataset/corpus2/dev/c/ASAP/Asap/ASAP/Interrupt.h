/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AInterrupt wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AInterrupt_H
#define ASAP_AInterrupt_H

extern "C"
{
 #include <EXEC/Interrupts.h>
 #include <Proto/EXEC.h>
}

class AInterrupt : public Interrupt
{
 public:
 inline void AddMemHandler();
 inline void Cause();
 inline static void Disable();
 inline static void Enable();
 inline void RemMemHandler();
 inline AInterrupt * SetIntVector(long intNumber);
 inline static AInterrupt * SetIntVector(long intNumber, Interrupt * interrupt);
};
//----------------------------------------------------------------------------
void AInterrupt::AddMemHandler ()
{
 ::AddMemHandler(this);
}
//----------------------------------------------------------------------------
void AInterrupt::Cause ()
{
 ::Cause(this);
}
//----------------------------------------------------------------------------
void AInterrupt::Disable ()
{
 ::Disable();
}
//----------------------------------------------------------------------------
void AInterrupt::Enable ()
{
 ::Enable();
}
//----------------------------------------------------------------------------
void AInterrupt::RemMemHandler ()
{
 ::RemMemHandler(this);
}
//----------------------------------------------------------------------------
AInterrupt * AInterrupt::SetIntVector (long intNumber)
{
 return (AInterrupt *) ::SetIntVector(intNumber, this);
}
//----------------------------------------------------------------------------
AInterrupt * AInterrupt::SetIntVector (long intNumber, Interrupt * interrupt)
{
 return (AInterrupt *) ::SetIntVector(intNumber, interrupt);
}

#endif
