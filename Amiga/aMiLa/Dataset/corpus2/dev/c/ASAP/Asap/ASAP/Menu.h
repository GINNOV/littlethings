/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMenu wrapper class                                                       *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMenu_H
#define ASAP_AMenu_H

#include <New.h>

extern "C"
{
 #include <Proto/GadTools.h>
 #include <Proto/Intuition.h>
}

class AMenuItem;

class AMenu : public Menu
{
 public:
 inline static AMenu * CreateMenus(NewMenu * newMenu, Tag tag1,  ...);
 inline void * operator new(size_t, NewMenu * newMenu, Tag tag1, ...);
 inline static AMenu * CreateMenusA(NewMenu * newMenu, TagItem * taglist);
 inline void * operator new(size_t, NewMenu * newMenu, TagItem * taglist);
 inline void FreeMenus();
 inline void operator delete(void *);
 inline AMenuItem * ItemAddress(unsigned long menuNumber);
 inline BOOL LayoutMenus(APTR vi, Tag tag1,  ...);
 inline BOOL LayoutMenusA(APTR vi, TagItem * taglist);
};
//----------------------------------------------------------------------------
AMenu * AMenu::CreateMenus (NewMenu * newMenu, Tag tag1,  ...)
{
 return CreateMenusA(newMenu, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
void * AMenu::operator new(size_t, NewMenu * newMenu, Tag tag1, ...)
{
 return AMenu::CreateMenusA(newMenu, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AMenu * AMenu::CreateMenusA (NewMenu * newMenu, TagItem * taglist)
{
 return (AMenu *) ::CreateMenusA(newMenu, taglist);
}
//----------------------------------------------------------------------------
void * AMenu::operator new (size_t, NewMenu * newMenu, TagItem * taglist)
{
 return AMenu::CreateMenusA(newMenu, taglist);
}
//----------------------------------------------------------------------------
void AMenu::FreeMenus ()
{
 ::FreeMenus(this);
}
//----------------------------------------------------------------------------
void AMenu::operator delete (void *menu)
{
 ((AMenu *) menu)->FreeMenus();
}
//----------------------------------------------------------------------------
AMenuItem * AMenu::ItemAddress (unsigned long menuNumber)
{
 return (AMenuItem *) ::ItemAddress(this, menuNumber);
}
//----------------------------------------------------------------------------
BOOL AMenu::LayoutMenus (APTR vi, Tag tag1,  ...)
{
 return LayoutMenusA(vi, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
BOOL AMenu::LayoutMenusA (APTR vi, TagItem * taglist)
{
 return ::LayoutMenusA(this, vi, taglist);
}

#endif
