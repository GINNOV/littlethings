/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ANVData wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ANVData_H
#define ASAP_ANVData_H

#include <New.h>

extern "C"
{
 #include <Proto/Nonvolatile.h>
}

class ANVData
{
 public:
 inline static BOOL DeleteNV(STRPTR appName, STRPTR itemName, long killRequesters = 1);
 inline void FreeNVData();
 inline void operator delete(void *);
 inline static ANVData * GetCopyNV(STRPTR appName, STRPTR itemName, long killRequesters = 1);
 inline void * operator new(size_t, STRPTR appName, STRPTR itemName, long killRequesters = 1);
 inline static BOOL SetNVProtection(STRPTR appName, STRPTR itemName, long mask = NVEF_DELETE, long killRequesters = 1);
 inline UWORD StoreNV(STRPTR appName, STRPTR itemName, unsigned long length, long killRequesters = 1);
};
//----------------------------------------------------------------------------
BOOL ANVData::DeleteNV (STRPTR appName, STRPTR itemName, long killRequesters)
{
 return ::DeleteNV(appName, itemName, killRequesters);
}
//----------------------------------------------------------------------------
void ANVData::FreeNVData ()
{
 ::FreeNVData((APTR) this);
}
//----------------------------------------------------------------------------
void ANVData::operator delete (void *data)
{
 ((ANVData *) data)->FreeNVData();
}
//----------------------------------------------------------------------------
ANVData * ANVData::GetCopyNV (STRPTR appName, STRPTR itemName, long killRequesters)
{
 return (ANVData *) ::GetCopyNV(appName, itemName, killRequesters);
}
//----------------------------------------------------------------------------
void * ANVData::operator new (size_t, STRPTR appName, STRPTR itemName, long killRequesters)
{
 return ANVData::GetCopyNV(appName, itemName, killRequesters);
}
//----------------------------------------------------------------------------
BOOL ANVData::SetNVProtection (STRPTR appName, STRPTR itemName, long mask, long killRequesters)
{
 return ::SetNVProtection(appName, itemName, mask, killRequesters);
}
//----------------------------------------------------------------------------
UWORD ANVData::StoreNV (STRPTR appName, STRPTR itemName, unsigned long length, long killRequesters)
{
 return ::StoreNV(appName, itemName, (APTR) this, length, killRequesters);
}

#endif
