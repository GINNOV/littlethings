/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADTObject wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DTObject_H
#define ASAP_DTObject_H

#include <New.h>

extern "C"
{
 #include <Proto/DataTypes.H>
}

class ADTObject : public _Object
{
 public:
 inline void DisposeDTObject();
 inline void operator delete(void *o);
 inline ULONG DoAsyncLayout(gpLayout *gpl);
 inline ULONG DoDTMethod(Window *win/*, Requester *req*/, unsigned long data = TAG_DONE, ...);
 inline ULONG DoDTMethod(Window *win, Requester *req, unsigned long data = TAG_DONE, ...);
 inline ULONG DoDTMethodA(Window *win/*, Requester *req*/, Msg msg);
 inline ULONG DoDTMethodA(Window *win, Requester *req, Msg msg);
 inline ULONG GetDTAttrsA(TagItem *attrs);
 inline ULONG GetDTAttrs(Tag Tag1, ...);
 inline ULONG *GetDTMethods();
 inline static STRPTR GetDTString(unsigned long id);
 inline DTMethods * GetDTTriggerMethods();
 inline static ADTObject *NewDTObjectA( const char * name, TagItem *attrs);
 inline void * operator new(size_t, const char * name, TagItem *attrs);
 inline static ADTObject *NewDTObject(const char *name, Tag Tag1 = TAG_DONE, ...);
 inline void * operator new(size_t, const char *name, Tag Tag1 = TAG_DONE, ...);
 inline ULONG PrintDTObject(Window *win/*, Requester *req*/, unsigned long data = TAG_DONE, ...);
 inline ULONG PrintDTObject(Window *win, Requester *req, unsigned long data = TAG_DONE, ...);
 inline ULONG PrintDTObjectA(Window *win/*, Requester *req*/, dtPrint *msg);
 inline ULONG PrintDTObjectA(Window *win, Requester *req, dtPrint *msg);
 inline void RefreshDTObjectA(Window *win/*, Requester *req*/, TagItem *attrs);
 inline void RefreshDTObjects(Window *win/*, Requester *req*/, Tag Tag1 = TAG_DONE, ...);
 inline ULONG SetDTAttrsA(Window *win/*, Requester *req*/, TagItem *attrs);
 inline ULONG SetDTAttrsA(Window *win, Requester *req, TagItem *attrs);
 inline ULONG SetDTAttrs(Window *win/*, Requester *req*/, Tag Tag1, ...);
 inline ULONG SetDTAttrs(Window *win, Requester *req, Tag Tag1, ...);
};
//-----------------------------------------------------------------------------
void ADTObject::DisposeDTObject()
{
 ::DisposeDTObject((Object *) this);
}
//-----------------------------------------------------------------------------
void ADTObject::operator delete (void *o)
{
 ((ADTObject *) o)->DisposeDTObject();
}
//-----------------------------------------------------------------------------
ULONG ADTObject::DoAsyncLayout (gpLayout *gpl )
{
 return ::DoAsyncLayout((Object *) this, gpl);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::DoDTMethod (Window *win/*, Requester *req*/, unsigned long data, ...)
{
 return ::DoDTMethodA((Object *) this, win, NULL, (Msg) &data);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::DoDTMethod (Window *win, Requester *req, unsigned long data, ...)
{
 return ::DoDTMethodA((Object *) this, win, req, (Msg) &data);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::DoDTMethodA (Window *win/*, Requester *req*/, Msg msg)
{
 return ::DoDTMethodA((Object *) this, win, NULL, msg);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::DoDTMethodA (Window *win, Requester *req, Msg msg)
{
 return ::DoDTMethodA((Object *) this, win, req, msg);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::GetDTAttrsA (TagItem *attrs)
{
 return ::GetDTAttrsA((Object *) this, attrs);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::GetDTAttrs (Tag Tag1, ...)
{
 return ::GetDTAttrsA((Object *) this, (TagItem *) &Tag1);
}
//-----------------------------------------------------------------------------
ULONG * ADTObject::GetDTMethods ()
{
 return ::GetDTMethods((Object *) this);
}
//-----------------------------------------------------------------------------
STRPTR ADTObject::GetDTString (unsigned long id)
{
 return ::GetDTString(id);
}
//-----------------------------------------------------------------------------
DTMethods * ADTObject::GetDTTriggerMethods ()
{
 return ::GetDTTriggerMethods((Object *) this);
}
//-----------------------------------------------------------------------------
ADTObject * ADTObject::NewDTObjectA (const char * name, TagItem *attrs)
{
 return (ADTObject *) ::NewDTObjectA((APTR) name, attrs);
}
//-----------------------------------------------------------------------------
void * ADTObject::operator new (size_t, const char * name, TagItem *attrs)
{
 return ADTObject::NewDTObjectA(name, attrs);
}
//-----------------------------------------------------------------------------
ADTObject * ADTObject::NewDTObject (const char *name, Tag Tag1, ...)
{
 return NewDTObjectA(name, (TagItem *) &Tag1);
}
//-----------------------------------------------------------------------------
void * ADTObject::operator new (size_t, const char *name, Tag Tag1, ...)
{
 return ADTObject::NewDTObjectA(name, (TagItem *) &Tag1);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::PrintDTObject (Window *win/*, Requester *req*/, unsigned long data, ... )
{
 return PrintDTObjectA(win, NULL, (dtPrint *) &data);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::PrintDTObject (Window *win, Requester *req, unsigned long data, ...)
{
 return ::PrintDTObjectA((Object *) this, win, req, (dtPrint *) &data);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::PrintDTObjectA (Window *win/*, Requester *req*/, dtPrint *msg)
{
 return PrintDTObjectA(win, NULL, msg);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::PrintDTObjectA (Window *win, Requester *req, dtPrint *msg)
{
 return ::PrintDTObjectA((Object *) this, win, req, msg);
}
//-----------------------------------------------------------------------------
void ADTObject::RefreshDTObjectA (Window *win/*, Requester *req*/, TagItem *attrs)
{
 ::RefreshDTObjectA((Object *) this, win, NULL, attrs);
}
//-----------------------------------------------------------------------------
void ADTObject::RefreshDTObjects (Window *win/*, Requester *req*/, Tag Tag1, ...)
{
 RefreshDTObjectA(win, (TagItem *) &Tag1);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::SetDTAttrsA (Window *win/*, Requester *req*/, TagItem *attrs)
{
 return ::SetDTAttrsA((Object *) this, win, NULL, attrs);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::SetDTAttrsA (Window *win, Requester *req, TagItem *attrs)
{
 return ::SetDTAttrsA((Object *) this, win, req, attrs);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::SetDTAttrs (Window *win/*, Requester *req*/, Tag Tag1, ...)
{
 return SetDTAttrsA(win, (TagItem *) &Tag1);
}
//-----------------------------------------------------------------------------
ULONG ADTObject::SetDTAttrs (Window *win, Requester *req, Tag Tag1, ...)
{
 return SetDTAttrsA(win, req, (TagItem *) &Tag1);
}

#endif
