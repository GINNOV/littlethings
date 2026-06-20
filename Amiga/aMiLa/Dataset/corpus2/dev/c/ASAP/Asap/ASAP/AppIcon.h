/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAppIcon wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AppIcon_H
#define ASAP_AppIcon_H

#include <New.h>

extern "C"
{
 #include <Proto/WB.h>
}

class AAppIcon : public AppIcon
{
 public:
 inline static AAppIcon * AddAppIcon(unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, Tag tag1, ...);
 inline void * operator new (size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, Tag tag1, ...);
 inline static AAppIcon * AddAppIconA(unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, TagItem * taglist);
 inline void * operator new (size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, TagItem * taglist);
 inline BOOL RemoveAppIcon();
 inline void operator delete (void *);
};
//----------------------------------------------------------------------------
AAppIcon * AAppIcon::AddAppIcon (unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, Tag tag1, ...)
{
 return AAppIcon::AddAppIconA(id, userdata, text, msgport, lock, diskobj, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
void * AAppIcon::operator new (size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, Tag tag1, ...)
{
 return AAppIcon::AddAppIconA(id, userdata, text, msgport, lock, diskobj, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AAppIcon * AAppIcon::AddAppIconA (unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, TagItem * taglist)
{
 return (AAppIcon *) ::AddAppIconA(id, userdata, text, msgport, lock, diskobj, taglist);
}
//----------------------------------------------------------------------------
void * AAppIcon::operator new (size_t, unsigned long id, unsigned long userdata, UBYTE * text, MsgPort * msgport, FileLock * lock, DiskObject * diskobj, TagItem * taglist)
{
 return AAppIcon::AddAppIconA(id, userdata, text, msgport, lock, diskobj, taglist);
}
//----------------------------------------------------------------------------
BOOL AAppIcon::RemoveAppIcon ()
{
 return ::RemoveAppIcon(this);
}
//----------------------------------------------------------------------------
void AAppIcon::operator delete (void *appIcon)
{
 ((AAppIcon *) appIcon)->RemoveAppIcon();
}

#endif
