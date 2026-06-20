/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMenuItem wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMenuItem_H
#define ASAP_AMenuItem_H

extern "C"
{
 #include <Proto/GadTools.h>
}

class AMenuItem : public MenuItem
{
 public:
 inline static BOOL LayoutMenuItems(MenuItem *firstitem, APTR vi, Tag tag1,  ...);
 inline static BOOL LayoutMenuItemsA(MenuItem *firstitem, APTR vi, TagItem * taglist);
};
//----------------------------------------------------------------------------
BOOL AMenuItem::LayoutMenuItems (MenuItem *firstitem, APTR vi, Tag tag1,  ...)
{
 return ::LayoutMenuItemsA(firstitem, vi, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
BOOL AMenuItem::LayoutMenuItemsA (MenuItem *firstitem, APTR vi, TagItem * taglist)
{
 return ::LayoutMenuItemsA(firstitem, vi, taglist);
}

#endif
