/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACardHandle wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_CardHandle_H
#define ASAP_CardHandle_H

extern "C"
{
 #include <Proto/CardRes.h>
}

class AResident;

class ACardHandle : public CardHandle
{
 public:
 inline BOOL BeginCardAccess();
 inline ULONG CardAccessSpeed(unsigned long nanoseconds);
 inline ULONG CardChangeCount();
 inline BOOL CardForceChange();
 inline ULONG CardInterface();
 inline UBYTE CardMiscControl(unsigned long control_bits);
 inline LONG CardProgramVoltage(unsigned long voltage);
 inline BOOL CardResetCard();
 inline BOOL CardResetRemove(unsigned long flag);
 inline BOOL CopyTuple(UBYTE * buffer, unsigned long tuplecode, unsigned long size);
 inline ULONG DeviceTuple(UBYTE * tuple_data, DeviceTData * storage);
 inline BOOL EndCardAccess();
 inline CardMemoryMap * GetCardMap();
 inline AResident * IfAmigaXIP();
 inline ACardHandle * OwnCard();
 inline UBYTE ReadCardStatus();
 inline void ReleaseCard(unsigned long flags);
};
//----------------------------------------------------------------------------
BOOL ACardHandle::BeginCardAccess ()
{
 return ::BeginCardAccess(this);
}
//----------------------------------------------------------------------------
ULONG ACardHandle::CardAccessSpeed (unsigned long nanoseconds)
{
 return ::CardAccessSpeed(this, nanoseconds);
}
//----------------------------------------------------------------------------
ULONG ACardHandle::CardChangeCount ()
{
 return ::CardChangeCount();
}
//----------------------------------------------------------------------------
BOOL ACardHandle::CardForceChange ()
{
 return ::CardForceChange();
}
//----------------------------------------------------------------------------
ULONG ACardHandle::CardInterface ()
{
 return ::CardInterface();
}
//----------------------------------------------------------------------------
UBYTE ACardHandle::CardMiscControl (unsigned long control_bits)
{
 return ::CardMiscControl(this, control_bits);
}
//----------------------------------------------------------------------------
LONG ACardHandle::CardProgramVoltage (unsigned long voltage)
{
 return ::CardProgramVoltage(this, voltage);
}
//----------------------------------------------------------------------------
BOOL ACardHandle::CardResetCard ()
{
 return ::CardResetCard(this);
}
//----------------------------------------------------------------------------
BOOL ACardHandle::CardResetRemove (unsigned long flag)
{
 return ::CardResetRemove(this, flag);
}
//----------------------------------------------------------------------------
BOOL ACardHandle::CopyTuple (UBYTE * buffer, unsigned long tuplecode, unsigned long size)
{
 return ::CopyTuple(this, buffer, tuplecode, size);
}
//----------------------------------------------------------------------------
ULONG ACardHandle::DeviceTuple (UBYTE * tuple_data, DeviceTData * storage)
{
 return ::DeviceTuple(tuple_data, storage);
}
//----------------------------------------------------------------------------
BOOL ACardHandle::EndCardAccess ()
{
 return ::EndCardAccess(this);
}
//----------------------------------------------------------------------------
CardMemoryMap * ACardHandle::GetCardMap ()
{
 return ::GetCardMap();
}
//----------------------------------------------------------------------------
AResident * ACardHandle::IfAmigaXIP ()
{
 return (AResident *) ::IfAmigaXIP(this);
}
//----------------------------------------------------------------------------
ACardHandle * ACardHandle::OwnCard ()
{
 return (ACardHandle *) ::OwnCard(this);
}
//----------------------------------------------------------------------------
UBYTE ACardHandle::ReadCardStatus ()
{
 return ::ReadCardStatus();
}
//----------------------------------------------------------------------------
void ACardHandle::ReleaseCard (unsigned long flags)
{
 ::ReleaseCard(this, flags);
}

#endif
