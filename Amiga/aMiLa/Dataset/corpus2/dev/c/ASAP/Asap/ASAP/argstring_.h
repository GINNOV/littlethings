/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * Aargstring wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_rgstring_H
#define ASAP_argstring_H

#include <New.h>

extern "C"
{
 #include <Proto/RexxSysLib.h>
}

class Aargstring
{
 public:
 inline static Aargstring * CreateArgstring(UBYTE * string, unsigned long length);
 inline void * operator new(size_t, UBYTE * string, unsigned long length);
 inline void DeleteArgstring();
 inline void operator delete(void *);
 inline ULONG LengthArgstring();
};
//----------------------------------------------------------------------------
Aargstring * Aargstring::CreateArgstring (UBYTE * string, unsigned long length)
{
 return (Aargstring *) ::CreateArgstring(string, length);
}
//----------------------------------------------------------------------------
void * Aargstring::operator new(size_t, UBYTE * string, unsigned long length)
{
 return Aargstring::CreateArgstring(string, length);
}
//----------------------------------------------------------------------------
void Aargstring::DeleteArgstring ()
{
 ::DeleteArgstring((UBYTE *) this);
}
//----------------------------------------------------------------------------
void Aargstring::operator delete (void *argstring)
{
 ((Aargstring *) argstring)->DeleteArgstring();
}
//----------------------------------------------------------------------------
ULONG Aargstring::LengthArgstring ()
{
 return ::LengthArgstring((UBYTE *) this);
}

#endif
