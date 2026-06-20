/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ATextFont wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ATextFont_H
#define ASAP_ATextFont_H

#include <New.h>

extern "C"
{
 #include <Proto/DiskFont.h>
 #include <Proto/Graphics.h>
}

class ATextFont : public TextFont
{
 public:
 inline void AddFont();
 inline void CloseFont();
 inline void operator delete(void *textFont);
 inline ULONG ExtendFont(TagItem * fontTags);
 inline ULONG ExtendFontTags(unsigned long tag1Type,  ...);
 inline void FontExtent(struct TextExtent * fontExtent);
 inline static ATextFont * OpenDiskFont(TextAttr * textAttr);
 inline void * operator new(size_t, TextAttr * textAttr, BOOL disk = 0);
 inline static ATextFont * OpenFont(TextAttr * textAttr);
 inline void RemFont();
 inline void StripFont();
};
//----------------------------------------------------------------------------
void ATextFont::AddFont ()
{
 ::AddFont(this);
}
//----------------------------------------------------------------------------
void ATextFont::CloseFont ()
{
 ::CloseFont(this);
}
//----------------------------------------------------------------------------
void ATextFont::operator delete (void *textfont)
{
 ((ATextFont *) textfont)->CloseFont();
}
//----------------------------------------------------------------------------
ULONG ATextFont::ExtendFont (TagItem * fontTags)
{
 return ::ExtendFont(this, fontTags);
}
//----------------------------------------------------------------------------
ULONG ATextFont::ExtendFontTags (unsigned long tag1Type,  ...)
{
 return ATextFont::ExtendFont((TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void ATextFont::FontExtent (struct TextExtent * fontExtent)
{
 ::FontExtent(this, fontExtent);
}
//----------------------------------------------------------------------------
ATextFont * ATextFont::OpenDiskFont (TextAttr * textAttr)
{
 return (ATextFont *) ::OpenDiskFont(textAttr);
}
//----------------------------------------------------------------------------
void * ATextFont::operator new(size_t, TextAttr * textAttr, BOOL disk)
{
 return disk? ATextFont::OpenDiskFont(textAttr) : ATextFont::OpenFont(textAttr);
}
//----------------------------------------------------------------------------
ATextFont * ATextFont::OpenFont (TextAttr * textAttr)
{
 return (ATextFont *) ::OpenFont(textAttr);
}
//----------------------------------------------------------------------------
void ATextFont::RemFont ()
{
 ::RemFont(this);
}
//----------------------------------------------------------------------------
void ATextFont::StripFont ()
{
 ::StripFont(this);
}

#endif
