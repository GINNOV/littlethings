/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAppMenuItem wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AppMenuItem_H
#define ASAP_AppMenuItem_H

#include <New.h>

extern "C"
{
 #include <Proto/WB.h>
}

class AAppMenuItem : public AppMenuItem
{
 public:
 inline static AAppMenuItem * AddAppMenuItem(unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, Tag tag1,  ...);
 inline void * operator new(size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, Tag tag1,  ...);
 inline static AAppMenuItem * AddAppMenuItemA(unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, TagItem * taglist);
 inline void * operator new(size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, TagItem * taglist);
 inline BOOL RemoveAppMenuItem();
 inline void operator delete(void *);
};
//----------------------------------------------------------------------------
AAppMenuItem * AAppMenuItem::AddAppMenuItem (unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, Tag tag1,  ...)
{
 return AAppMenuItem::AddAppMenuItemA(id, userdata, text, msgport, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
void * AAppMenuItem::operator new(size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, Tag tag1,  ...)
{
 return AAppMenuItem::AddAppMenuItemA(id, userdata, text, msgport, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AAppMenuItem * AAppMenuItem::AddAppMenuItemA (unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, TagItem * taglist)
{
 return (AAppMenuItem *) ::AddAppMenuItemA(id, userdata, text, msgport, taglist);
}
//----------------------------------------------------------------------------
void * AAppMenuItem::operator new(size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, TagItem * taglist)
{
 return AAppMenuItem::AddAppMenuItemA(id, userdata, text, msgport, taglist);
}
//----------------------------------------------------------------------------
BOOL AAppMenuItem::RemoveAppMenuItem ()
{
 return ::RemoveAppMenuItem(this);
}
//----------------------------------------------------------------------------
void AAppMenuItem::operator delete (void *appMenuItem)
{
 ((AAppMenuItem *) appMenuItem)->RemoveAppMenuItem();
}

#endif
