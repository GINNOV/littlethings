/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AObject wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Object_H
#define ASAP_Object_H

#include <New.h>

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <Proto/Intuition.H>
}

class AObject : public _Object
{
 public:
 inline static AObject * NextObject(APTR objectPtrPtr);
 inline void DisposeObject();
 inline void operator delete(void *object);
 inline ULONG GetAttr(unsigned long attrID, ULONG *storagePtr);
 inline ULONG SetAttrs(unsigned long tag1, ...);
 inline ULONG SetAttrsA(TagItem *tagList);
 inline ULONG CallHook(Hook *hookPtr, unsigned long arg1 = 0, ...);
 inline ULONG CallHookA(Hook *hookPtr, APTR message);
 inline ULONG DoMethod(unsigned long MethodID, ...);
 inline ULONG DoMethodA(Msg message);
 inline ULONG DoSuperMethod(IClass *cl, unsigned long MethodID, ...);
 inline ULONG DoSuperMethodA(IClass *cl, Msg message);
 inline ULONG CoerceMethod(IClass *cl, unsigned long MethodID, ...);
 inline ULONG CoerceMethodA(IClass *cl, Msg message);
 inline static AObject * NewObject(/* IClass *classPtr,*/ const char  *classID, unsigned long tag1, ... );
 inline void * operator new(size_t, /* IClass *classPtr,*/ const char *classID, unsigned long tag1, ... );
 inline static AObject * NewObject( IClass *classPtr/*, UBYTE *classID*/, unsigned long tag1, ...);
 inline void * operator new(size_t, IClass *classPtr/*, UBYTE *classID*/, unsigned long tag1, ... );
 inline static AObject * NewObjectA(/* IClass *classPtr,*/ const char *classID, TagItem *tagList);
 inline void * operator new(size_t, /* IClass *classPtr,*/ const char *classID, TagItem *tagList);
 inline static AObject * NewObjectA( IClass *classPtr/*, UBYTE *classID*/, TagItem *tagList );
 inline void * operator new(size_t, IClass *classPtr/*, UBYTE *classID*/, TagItem *tagList);
 inline ULONG SetSuperAttrs(IClass *cl, unsigned long Tag1, ... );
};
//-----------------------------------------------------------------------------
AObject * AObject::NextObject (APTR objectPtrPtr)
{
 return (AObject *) ::NextObject(objectPtrPtr);
}
//-----------------------------------------------------------------------------
void AObject::DisposeObject ()
{
 ::DisposeObject((Object *) this);
}
//-----------------------------------------------------------------------------
void AObject::operator delete (void *object)
{
 ((AObject *) object)->DisposeObject();
}
//-----------------------------------------------------------------------------
ULONG AObject::GetAttr (unsigned long attrID, ULONG *storagePtr)
{
 return ::GetAttr(attrID, (APTR) (Object *) this, storagePtr);
}
//-----------------------------------------------------------------------------
ULONG AObject::SetAttrs (unsigned long tag1, ...)
{
 return SetAttrsA((TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
ULONG AObject::SetAttrsA (TagItem *tagList)
{
 return ::SetAttrsA((Object *) this, tagList);
}
//-----------------------------------------------------------------------------
ULONG AObject::CallHook (Hook *hookPtr, unsigned long arg1, ...)
{
 return CallHookA(hookPtr, arg1? &arg1 : NULL);
}
//-----------------------------------------------------------------------------
ULONG AObject::CallHookA (Hook *hookPtr, APTR message)
{
 return ::CallHookA(hookPtr, (Object *) this, message);
}
//-----------------------------------------------------------------------------
ULONG AObject::DoMethod (unsigned long MethodID, ...)
{
 return DoMethodA((Msg) &MethodID);
}
//-----------------------------------------------------------------------------
ULONG AObject::DoMethodA (Msg message)
{
 return ::DoMethodA((Object *) this, message);
}
//-----------------------------------------------------------------------------
ULONG AObject::DoSuperMethod (IClass *cl, unsigned long MethodID, ...)
{
 return DoSuperMethodA(cl, (Msg) &MethodID);
}
//-----------------------------------------------------------------------------
ULONG AObject::DoSuperMethodA (IClass *cl, Msg message)
{
 return ::DoSuperMethodA(cl, (Object *) this, message);
}
//-----------------------------------------------------------------------------
ULONG AObject::CoerceMethod (IClass *cl, unsigned long MethodID, ...)
{
 return CoerceMethodA(cl, (Msg) &MethodID);
}
//-----------------------------------------------------------------------------
ULONG AObject::CoerceMethodA (IClass *cl, Msg message)
{
 return ::CoerceMethodA(cl, (Object *) this, message);
}
//-----------------------------------------------------------------------------
AObject * AObject::NewObject (const char *classID, unsigned long tag1, ...)
{
 return AObject::NewObjectA(classID, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
void * AObject::operator new (size_t, const char *classID, unsigned long tag1, ...)
{
 return AObject::NewObjectA(classID, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
AObject * AObject::NewObject (IClass *classPtr/*, UBYTE *classID*/, unsigned long tag1, ...)
{
 return AObject::NewObjectA(classPtr, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
void * AObject::operator new (size_t, IClass *classPtr/*, UBYTE *classID*/, unsigned long tag1, ...)
{
 return AObject::NewObjectA(classPtr, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
AObject * AObject::NewObjectA (const char *classID, TagItem *tagList)
{
 return (AObject *) ::NewObjectA(NULL, (UBYTE *) classID, tagList);
}
//-----------------------------------------------------------------------------
void * AObject::operator new (size_t, const char *classID, TagItem *tagList)
{
 return AObject::NewObjectA(classID, tagList);
}
//-----------------------------------------------------------------------------
AObject * AObject::NewObjectA (IClass *classPtr/*, UBYTE *classID*/, TagItem *tagList )
{
 return (AObject *) ::NewObjectA(classPtr, NULL, tagList);
}
//-----------------------------------------------------------------------------
void * AObject::operator new (size_t, IClass *classPtr/*, UBYTE *classID*/, TagItem *tagList)
{
 return AObject::NewObjectA(classPtr, tagList);
}
//-----------------------------------------------------------------------------
ULONG AObject::SetSuperAttrs (IClass *cl, unsigned long Tag1, ...)
{
 return DoSuperMethod(cl, OM_SET, (TagItem *) &Tag1, 0);
}

#endif
