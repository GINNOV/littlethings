/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADBufInfo wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DBufInfo_H
#define ASAP_DBufInfo_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class ADBufInfo : public DBufInfo
{
 public:
 inline static ADBufInfo * AllocDBufInfo(ViewPort * vp);
 inline void * operator new(size_t, ViewPort * vp);
 inline void FreeDBufInfo();
 inline void operator delete(void *);
};
//----------------------------------------------------------------------------
ADBufInfo * ADBufInfo::AllocDBufInfo (ViewPort * vp)
{
 return (ADBufInfo *) ::AllocDBufInfo(vp);
}
//----------------------------------------------------------------------------
void * ADBufInfo::operator new (size_t, ViewPort * vp)
{
 return ADBufInfo::AllocDBufInfo(vp);
}
//----------------------------------------------------------------------------
void ADBufInfo::FreeDBufInfo ()
{
 ::FreeDBufInfo(this);
}
//----------------------------------------------------------------------------
void ADBufInfo::operator delete (void *dbi)
{
 ((ADBufInfo *) dbi)->FreeDBufInfo();
}

#endif
