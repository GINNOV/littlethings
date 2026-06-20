/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIClass wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_IClass_H
#define ASAP_IClass_H

#include <New.h>

extern "C"
{
 #include <Proto/Intuition.h>
}

class AIClass : public IClass
{
 public:
 inline void AddClass();
 inline BOOL FreeClass();
 inline void operator delete(void *classPtr);
 inline static AIClass * MakeClass(const char *classID, const char *superClassID/*, IClass *superClassPtr*/, unsigned long instanceSize, unsigned long flags = 0);
 inline void * operator new(size_t, const char *classID, const char *superClassID, unsigned long instanceSize, unsigned long flags = 0);
 inline static AIClass * MakeClass(const char *classID/*, UBYTE *superClassID*/, IClass *superClassPtr, unsigned long instanceSize, unsigned long flags = 0);
 inline void * operator new(size_t, const char *classID, IClass *superClassPtr, unsigned long instanceSize, unsigned long flags = 0);
 inline void RemoveClass();
};
//-----------------------------------------------------------------------------
void AIClass::AddClass ()
{
 ::AddClass(this);
}
//-----------------------------------------------------------------------------
BOOL AIClass::FreeClass ()
{
 return ::FreeClass(this);
}
//-----------------------------------------------------------------------------
void AIClass::operator delete (void *classPtr)
{
 ((AIClass *) classPtr)->FreeClass();
}
//-----------------------------------------------------------------------------
AIClass * AIClass::MakeClass (const char *classID, const char *superClassID, unsigned long instanceSize, unsigned long flags)
{
 return (AIClass *) ::MakeClass((UBYTE *) classID, (UBYTE *) superClassID, NULL, instanceSize, flags);
}
//-----------------------------------------------------------------------------
void * AIClass::operator new (size_t, const char *classID, const char *superClassID, unsigned long instanceSize, unsigned long flags)
{
 return AIClass::MakeClass(classID, superClassID, instanceSize, flags);
}
//-----------------------------------------------------------------------------
AIClass * AIClass::MakeClass (const char *classID, IClass *superClassPtr, unsigned long instanceSize, unsigned long flags)
{
 return (AIClass *) ::MakeClass((UBYTE *) classID, NULL, superClassPtr, instanceSize, flags);
}
//-----------------------------------------------------------------------------
void * AIClass::operator new (size_t, const char *classID, IClass *superClassPtr, unsigned long instanceSize, unsigned long flags)
{
 return AIClass::MakeClass(classID, superClassPtr, instanceSize, flags);
}
//-----------------------------------------------------------------------------
void AIClass::RemoveClass ()
{
 ::RemoveClass(this);
}

#endif