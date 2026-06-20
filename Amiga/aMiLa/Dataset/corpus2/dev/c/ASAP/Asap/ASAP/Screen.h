/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AScreen wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AScreen_H
#define ASAP_AScreen_H

#include <New.h>

extern "C"
{
 #include <Proto/Intuition.h>
}

class AScreen : public Screen
{
 public:
 inline ULONG ChangeScreenBuffer(ScreenBuffer * sb);
 inline BOOL CloseScreen();
 inline void operator delete(void *screen);
 inline void DisplayBeep();
 inline static Screen * LockPubScreen(UBYTE * name);
 inline LONG MakeScreen();
 inline void MoveScreen(long dx, long dy);
 inline UBYTE * NextPubScreen(UBYTE * namebuf);
 inline static AScreen * OpenScreen(NewScreen * newscreen);
 inline void * operator new(size_t, NewScreen * newscreen);
 inline static AScreen * OpenScreenTagList(NewScreen * newscreen, TagItem * tagList);
 inline void * operator new(size_t, NewScreen * newscreen, TagItem * tagList);
 inline static AScreen * OpenScreenTags(NewScreen * newscreen, unsigned long tag1Type,  ...);
 inline void * operator new(size_t, NewScreen * newscreen, unsigned long tag1Type,  ...);
 inline UWORD PubScreenStatus(unsigned long statusFlags);
 inline void ScreenDepth(unsigned long flags, APTR reserved = 0);
 inline void ScreenPosition(unsigned long flags, long x1, long y1, long x2, long y2);
 inline void ScreenToBack();
 inline void ScreenToFront();
 inline void ShowTitle(long showIt = 1);
};
//----------------------------------------------------------------------------
ULONG AScreen::ChangeScreenBuffer (ScreenBuffer * sb)
{
 return ::ChangeScreenBuffer(this, sb);
}
//----------------------------------------------------------------------------
BOOL AScreen::CloseScreen ()
{
 return ::CloseScreen(this);
}
//----------------------------------------------------------------------------
void AScreen::DisplayBeep ()
{
 ::DisplayBeep(this);
}
//----------------------------------------------------------------------------
Screen * AScreen::LockPubScreen (UBYTE * name)
{
 return ::LockPubScreen(name);
}
//----------------------------------------------------------------------------
LONG AScreen::MakeScreen ()
{
 return ::MakeScreen(this);
}
//----------------------------------------------------------------------------
void AScreen::MoveScreen (long dx, long dy)
{
 ::MoveScreen(this, dx, dy);
}
//----------------------------------------------------------------------------
UBYTE * AScreen::NextPubScreen (UBYTE * namebuf)
{
 return ::NextPubScreen(this, namebuf);
}
//----------------------------------------------------------------------------
AScreen * AScreen::OpenScreen (NewScreen *newscreen)
{
 return (AScreen *) ::OpenScreen(newscreen);
}
//----------------------------------------------------------------------------
void * AScreen::operator new (size_t, NewScreen *newscreen)
{
 return AScreen::OpenScreen(newscreen);
}
//----------------------------------------------------------------------------
AScreen * AScreen::OpenScreenTagList (NewScreen * newscreen, TagItem * tagList)
{
 return (AScreen *) ::OpenScreenTagList(newscreen, tagList);
}
//----------------------------------------------------------------------------
void * AScreen::operator new (size_t, NewScreen * newscreen, TagItem * tagList)
{
 return AScreen::OpenScreenTagList(newscreen, tagList);
}
//----------------------------------------------------------------------------
AScreen * AScreen::OpenScreenTags (NewScreen * newscreen, unsigned long tag1Type,  ...)
{
 return (AScreen *) AScreen::OpenScreenTagList(newscreen, (TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void * AScreen::operator new (size_t, NewScreen * newscreen, unsigned long tag1Type, ...)
{
 return AScreen::OpenScreenTagList(newscreen, (TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
UWORD AScreen::PubScreenStatus (unsigned long statusFlags)
{
 return ::PubScreenStatus(this, statusFlags);
}
//----------------------------------------------------------------------------
void AScreen::ScreenDepth (unsigned long flags, APTR reserved)
{
 ::ScreenDepth(this, flags, reserved);
}
//----------------------------------------------------------------------------
void AScreen::ScreenPosition (unsigned long flags, long x1, long y1, long x2, long y2)
{
 ::ScreenPosition(this, flags, x1, y1, x2, y2);
}
//----------------------------------------------------------------------------
void AScreen::ScreenToBack ()
{
 ::ScreenToBack(this);
}
//----------------------------------------------------------------------------
void AScreen::ScreenToFront ()
{
 ::ScreenToFront(this);
}
//----------------------------------------------------------------------------
void AScreen::ShowTitle (long showIt)
{
 ::ShowTitle(this, showIt);
}

#endif
