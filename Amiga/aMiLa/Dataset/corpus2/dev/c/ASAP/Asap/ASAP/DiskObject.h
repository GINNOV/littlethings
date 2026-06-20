/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADiskObject wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DiskObject_H
#define ASAP_DiskObject_H

#include <New.h>

extern "C"
{
 #include <Proto/Icon.h>
}

class ADiskObject : public DiskObject
{
 public:
 inline void FreeDiskObject();
 inline void operator delete (void *);
 inline static ADiskObject * GetDefDiskObject(long type);
 inline void * operator new(size_t, long type);
 inline static ADiskObject * GetDiskObject(UBYTE * name);
 inline void * operator new(size_t, UBYTE * name, BOOL New = TRUE);
 inline static ADiskObject * GetDiskObjectNew(UBYTE * name);
 inline BOOL PutDefDiskObject();
};
//----------------------------------------------------------------------------
void ADiskObject::FreeDiskObject ()
{
 ::FreeDiskObject(this);
}
//----------------------------------------------------------------------------
void operator delete (void *)
{
}
//----------------------------------------------------------------------------
ADiskObject * ADiskObject::GetDefDiskObject (long type)
{
 return (ADiskObject *) ::GetDefDiskObject(type);
}
//----------------------------------------------------------------------------
void * ADiskObject::operator new(size_t, long type)
{
 return ADiskObject::GetDefDiskObject(type);
}
//----------------------------------------------------------------------------
ADiskObject * ADiskObject::GetDiskObject (UBYTE * name)
{
 return (ADiskObject *) ::GetDiskObject(name);
}
//----------------------------------------------------------------------------
void * ADiskObject::operator new(size_t, UBYTE * name, BOOL New)
{
 return New? ADiskObject::GetDiskObject(name) : ADiskObject::GetDiskObjectNew(name);
}
//----------------------------------------------------------------------------
ADiskObject * ADiskObject::GetDiskObjectNew (UBYTE * name)
{
 return (ADiskObject *) ::GetDiskObjectNew(name);
}
//----------------------------------------------------------------------------
BOOL ADiskObject::PutDefDiskObject ()
{
 return ::PutDefDiskObject(this);
}

#endif
