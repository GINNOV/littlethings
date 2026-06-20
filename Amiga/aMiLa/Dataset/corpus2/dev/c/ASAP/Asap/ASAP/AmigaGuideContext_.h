/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAmigaGuideContext wrapper class                                          *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AAmigaGuideContext_H
#define ASAP_AAmigaGuideContext_H

#include <New.h>

extern "C"
{
 #include <Proto/AmigaGuide.h>
}

class AAmigaGuideMsg;

class AAmigaGuideContext
{
 public:
 inline ULONG AmigaGuideSignal();
 inline void CloseAmigaGuide();
 inline void operator delete(void *);
 inline AAmigaGuideMsg * GetAmigaGuideMsg();
 inline static AAmigaGuideContext * OpenAmigaGuide(NewAmigaGuide * nag, Tag tag1,  ...);
 inline static AAmigaGuideContext * OpenAmigaGuideA(NewAmigaGuide * nag, TagItem * Parm1);
 inline void * operator new(size_t, NewAmigaGuide * nag, Tag tag1, bool Async = 0);
 inline static AAmigaGuideContext * OpenAmigaGuideAsync(NewAmigaGuide * nag, Tag tag1,  ...);
 inline static AAmigaGuideContext * OpenAmigaGuideAsyncA(NewAmigaGuide * nag, TagItem * attrs);
 inline void * operator new(size_t, NewAmigaGuide * nag, TagItem *attrs, bool Async = 0);
 inline LONG SendAmigaGuideCmd(STRPTR cmd, Tag tag1,  ...);
 inline LONG SendAmigaGuideCmdA(STRPTR cmd, TagItem * attrs);
 inline LONG SendAmigaGuideContext(Tag tag1,  ...);
 inline LONG SendAmigaGuideContextA(TagItem * attrs);
 inline LONG SetAmigaGuideAttrs(Tag tag1,  ...);
 inline LONG SetAmigaGuideAttrsA(TagItem * attrs);
 inline LONG SetAmigaGuideContext(unsigned long id, Tag tag1,  ...);
 inline LONG SetAmigaGuideContextA(unsigned long id, TagItem * attrs);
};
//----------------------------------------------------------------------------
ULONG AAmigaGuideContext::AmigaGuideSignal ()
{
 return ::AmigaGuideSignal(this);
}
//----------------------------------------------------------------------------
void AAmigaGuideContext::CloseAmigaGuide ()
{
 ::CloseAmigaGuide(this);
}
//----------------------------------------------------------------------------
void AAmigaGuideContext::operator delete (void *cl)
{
 ((AAmigaGuideContext *) cl)->CloseAmigaGuide();
}
//----------------------------------------------------------------------------
AAmigaGuideMsg * AAmigaGuideContext::GetAmigaGuideMsg ()
{
 return (AAmigaGuideMsg *) ::GetAmigaGuideMsg(this);
}
//----------------------------------------------------------------------------
AAmigaGuideContext * AAmigaGuideContext::OpenAmigaGuide (NewAmigaGuide * nag, Tag tag1,  ...)
{
 return (AAmigaGuideContext *) ::OpenAmigaGuideA(nag, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AAmigaGuideContext * AAmigaGuideContext::OpenAmigaGuideA (NewAmigaGuide * nag, TagItem * Parm1)
{
 return (AAmigaGuideContext *) ::OpenAmigaGuideA(nag, Parm1);
}
//----------------------------------------------------------------------------
void * AAmigaGuideContext::operator new(size_t, NewAmigaGuide * nag, Tag tag1, bool Async)
{
 return Async? AAmigaGuideContext::OpenAmigaGuideAsyncA(nag, (TagItem *) &tag1) : AAmigaGuideContext::OpenAmigaGuideA(nag, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AAmigaGuideContext * AAmigaGuideContext::OpenAmigaGuideAsync (NewAmigaGuide * nag, Tag tag1,  ...)
{
 return (AAmigaGuideContext *) ::OpenAmigaGuideAsyncA(nag, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AAmigaGuideContext * AAmigaGuideContext::OpenAmigaGuideAsyncA (NewAmigaGuide * nag, TagItem * attrs)
{
 return (AAmigaGuideContext *) ::OpenAmigaGuideAsyncA(nag, attrs);
}
//----------------------------------------------------------------------------
void * AAmigaGuideContext::operator new(size_t, NewAmigaGuide * nag, TagItem *attrs, bool Async)
{
 return Async? AAmigaGuideContext::OpenAmigaGuideAsyncA(nag, attrs) : AAmigaGuideContext::OpenAmigaGuideA(nag, attrs);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SendAmigaGuideCmd (STRPTR cmd, Tag tag1,  ...)
{
 return AAmigaGuideContext::SendAmigaGuideCmdA(cmd, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SendAmigaGuideCmdA (STRPTR cmd, TagItem * attrs)
{
 return ::SendAmigaGuideCmdA(this, cmd, attrs);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SendAmigaGuideContext (Tag tag1,  ...)
{
 return AAmigaGuideContext::SendAmigaGuideContextA((TagItem *) &tag1);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SendAmigaGuideContextA (TagItem * attrs)
{
 return ::SendAmigaGuideContextA(this, attrs);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SetAmigaGuideAttrs (Tag tag1,  ...)
{
 return AAmigaGuideContext::SetAmigaGuideAttrsA((TagItem *) &tag1);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SetAmigaGuideAttrsA (TagItem * attrs)
{
 return ::SetAmigaGuideAttrsA(this, attrs);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SetAmigaGuideContext (unsigned long id, Tag tag1,  ...)
{
 return AAmigaGuideContext::SetAmigaGuideContextA(id, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
LONG AAmigaGuideContext::SetAmigaGuideContextA (unsigned long id, TagItem * attrs)
{
 return ::SetAmigaGuideContextA(this, id, attrs);
}

#endif
