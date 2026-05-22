/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AVisualInfo wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_VisualInfo_H
#define ASAP_VisualInfo_H

#include <New.h>

extern "C"
{
 #include <Libraries/GadTools.h>
 #include <Proto/GadTools.h>
}

class AVisualInfo
{
 public:
 inline static AVisualInfo * GetVisualInfo(Screen *screen, Tag tag1, ...);
 inline void * operator new(size_t, Screen *screen, Tag tag1, ...);
 inline static AVisualInfo * GetVisualInfoA(Screen *screen, TagItem *taglist);
 inline void * operator new(size_t, Screen *screen, TagItem *taglist);
 inline void FreeVisualInfo();
 inline void operator delete(void *vi);
};
//-----------------------------------------------------------------------------
AVisualInfo * AVisualInfo::GetVisualInfo (Screen *screen, Tag tag1, ...)
{
 return GetVisualInfoA(screen, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
void * AVisualInfo::operator new (size_t, Screen *screen, Tag tag1, ...)
{
 return AVisualInfo::GetVisualInfoA(screen, (TagItem *) &tag1);
}
//-----------------------------------------------------------------------------
AVisualInfo * AVisualInfo::GetVisualInfoA (Screen *screen, TagItem *taglist)
{
 return (AVisualInfo *) ::GetVisualInfoA(screen, taglist);
}
//-----------------------------------------------------------------------------
void * AVisualInfo::operator new (size_t, Screen *screen, TagItem *taglist)
{
 return AVisualInfo::GetVisualInfoA(screen, taglist);
}
//-----------------------------------------------------------------------------
void AVisualInfo::FreeVisualInfo ()
{
 ::FreeVisualInfo(this);
}
//-----------------------------------------------------------------------------
void AVisualInfo::operator delete (void *vi)
{
 ((AVisualInfo *) vi)->FreeVisualInfo();
}

#endif