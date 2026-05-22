/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADosList wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ADosList_H
#define ASAP_ADosList_H

extern "C"
{
 #include <Proto/DOS.h>
}

class ADosList : public DosList
{
 public:
 inline LONG AddDosEntry();
 inline static ADosList * AttemptLockDosList(unsigned long flags);
 inline ADosList * FindDosEntry(STRPTR name, unsigned long flags);
 inline void FreeDosEntry();
 inline static ADosList * LockDosList(unsigned long flags);
 inline static ADosList * MakeDosEntry(STRPTR name, long type);
 inline ADosList * NextDosEntry(unsigned long flags);
 inline BOOL RemDosEntry();
 inline static void UnLockDosList(unsigned long flags);
};
//----------------------------------------------------------------------------
LONG ADosList::AddDosEntry ()
{
 return ::AddDosEntry(this);
}
//----------------------------------------------------------------------------
ADosList * ADosList::AttemptLockDosList (unsigned long flags)
{
 return (ADosList *) ::AttemptLockDosList(flags);
}
//----------------------------------------------------------------------------
ADosList * ADosList::FindDosEntry (STRPTR name, unsigned long flags)
{
 return (ADosList *) ::FindDosEntry(this, name, flags);
}
//----------------------------------------------------------------------------
void ADosList::FreeDosEntry ()
{
 ::FreeDosEntry(this);
}
//----------------------------------------------------------------------------
ADosList * ADosList::LockDosList (unsigned long flags)
{
 return (ADosList *) ::LockDosList(flags);
}
//----------------------------------------------------------------------------
ADosList * ADosList::MakeDosEntry (STRPTR name, long type)
{
 return (ADosList *) ::MakeDosEntry(name, type);
}
//----------------------------------------------------------------------------
ADosList * ADosList::NextDosEntry (unsigned long flags)
{
 return (ADosList *) ::NextDosEntry(this, flags);
}
//----------------------------------------------------------------------------
BOOL ADosList::RemDosEntry ()
{
 return ::RemDosEntry(this);
}
//----------------------------------------------------------------------------
void ADosList::UnLockDosList (unsigned long flags)
{
 ::UnLockDosList(flags);
}

#endif
