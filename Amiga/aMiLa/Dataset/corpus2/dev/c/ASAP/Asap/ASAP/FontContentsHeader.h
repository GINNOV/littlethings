/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AFontContentsHeader wrapper class                                         *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_FontContentsHeader_H
#define ASAP_FontContentsHeader_H

#include <New.h>

extern "C"
{
 #include <Proto/DiskFont.h>
}

class AFontContentsHeader : public FontContentsHeader
{
 public:
 inline void DisposeFontContents();
 inline void operator delete(void *);
 inline static AFontContentsHeader * NewFontContents(BPTR fontsLock, STRPTR fontName);
 inline void * operator new(size_t, BPTR fontsLock, STRPTR fontName);
};
//----------------------------------------------------------------------------
void AFontContentsHeader::DisposeFontContents ()
{
 ::DisposeFontContents(this);
}
//----------------------------------------------------------------------------
void AFontContentsHeader::operator delete(void *fontContentsHeader)
{
 ((AFontContentsHeader *) fontContentsHeader)->DisposeFontContents();
}
//----------------------------------------------------------------------------
AFontContentsHeader * AFontContentsHeader::NewFontContents (BPTR fontsLock, STRPTR fontName)
{
 return (AFontContentsHeader *) ::NewFontContents(fontsLock, fontName);
}
//----------------------------------------------------------------------------
void * AFontContentsHeader::operator new (size_t, BPTR fontsLock, STRPTR fontName)
{
 return AFontContentsHeader::NewFontContents(fontsLock, fontName);
}

#endif
