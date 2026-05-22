/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * Library wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_LIBRARY_H
#define ASAP_LIBRARY_H

#include <New.h>

extern "C"
{
 #include <Exec/Libraries.h>
 #include <Proto/EXEC.h>
}

class ALibrary : public Library
{
 public:
 inline void AddLibrary();
 inline void CloseLibrary();
 inline void operator delete (void *library);
 inline static ALibrary *MakeLibrary(APTR funcInit, unsigned long (*libInit)(), unsigned long dataSize, unsigned long segList);
 inline void * operator new (size_t, APTR funcInit, unsigned long (*libInit)(), unsigned long dataSize, unsigned long segList);
 inline static ALibrary *MakeLibrary(APTR funcInit, APTR structInit, unsigned long dataSize, unsigned long segList);
 inline void * operator new (size_t, APTR funcInit, APTR structInit, unsigned long dataSize, unsigned long segList);
 inline static ALibrary *OldOpenLibrary(UBYTE *libName);
 inline void * operator new (size_t, UBYTE *libName);
 inline static ALibrary *OpenLibrary( UBYTE *libName, unsigned long version);
 inline void * operator new (size_t, UBYTE *libName, unsigned long version);
 inline void RemLibrary();
 inline APTR SetFunction(long funcOffset, unsigned long (*newFunction)());
 inline void SumLibrary();
};
//-----------------------------------------------------------------------------
void ALibrary::AddLibrary ()
{
 ::AddLibrary(this);
}
//-----------------------------------------------------------------------------
void ALibrary::CloseLibrary ()
{
 ::CloseLibrary(this);
}
//-----------------------------------------------------------------------------
void ALibrary::operator delete (void *library)
{
 ((ALibrary *) library)->CloseLibrary();
}
//-----------------------------------------------------------------------------
ALibrary * ALibrary::MakeLibrary (APTR funcInit, unsigned long (*libInit)(), unsigned long dataSize, unsigned long segList)
{
 return (ALibrary *) ::MakeLibrary(funcInit, 0, libInit, dataSize, segList);
}
//-----------------------------------------------------------------------------
void * ALibrary::operator new (size_t, APTR funcInit, unsigned long (*libInit)(), unsigned long dataSize, unsigned long segList)
{
 return ALibrary::MakeLibrary(funcInit, libInit, dataSize, segList);
}
//-----------------------------------------------------------------------------
ALibrary * ALibrary::MakeLibrary (APTR funcInit, APTR structInit, unsigned long dataSize, unsigned long segList)
{
 return (ALibrary *) ::MakeLibrary(funcInit, structInit, 0, dataSize, segList);
}
//-----------------------------------------------------------------------------
void * ALibrary::operator new (size_t, APTR funcInit, APTR structInit, unsigned long dataSize, unsigned long segList)
{
 return ALibrary::MakeLibrary(funcInit, structInit, dataSize, segList);
}
//-----------------------------------------------------------------------------
ALibrary * ALibrary::OldOpenLibrary (UBYTE *libName)
{
 return (ALibrary *) ::OldOpenLibrary(libName);
}
//-----------------------------------------------------------------------------
void * operator new (size_t, UBYTE *libName)
{
 return ALibrary::OldOpenLibrary(libName);
}
//-----------------------------------------------------------------------------
ALibrary * ALibrary::OpenLibrary (UBYTE *libName, unsigned long version)
{
 return (ALibrary *) ::OpenLibrary(libName, version);
}
//-----------------------------------------------------------------------------
void * ALibrary::operator new (size_t, UBYTE *libName, unsigned long version)
{
 return ALibrary::OpenLibrary(libName, version);
}
//-----------------------------------------------------------------------------
void ALibrary::RemLibrary ()
{
 ::RemLibrary(this);
}
//-----------------------------------------------------------------------------
APTR ALibrary::SetFunction (long funcOffset, unsigned long (*newFunction)())
{
 return ::SetFunction(this, funcOffset, newFunction);
}
//-----------------------------------------------------------------------------
void ALibrary::SumLibrary ()
{
 ::SumLibrary(this);
}

#endif
