/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AColorMap wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ColorMap_H
#define ASAP_ColorMap_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class AColorMap : public ColorMap
{
 public:
 inline LONG AttachPalExtra(struct ViewPort * vp);
 inline LONG FindColor(unsigned long r, unsigned long g, unsigned long b, long maxcolor);
 inline void FreeColorMap();
 inline void operator delete(void *);
 inline static AColorMap * GetColorMap(long entries);
 inline void * operator new (size_t, long entries);
 inline void GetRGB32(unsigned long firstcolor, unsigned long ncolors, ULONG * table);
 inline ULONG GetRGB4(long entry);
 inline LONG ObtainBestPen(unsigned long r, unsigned long g, unsigned long b, unsigned long tag1Type,  ...);
 inline LONG ObtainBestPenA(unsigned long r, unsigned long g, unsigned long b, struct TagItem * tags);
 inline ULONG ObtainPen(unsigned long n, unsigned long r, unsigned long g, unsigned long b, long f);
 inline void ReleasePen(unsigned long n);
 inline void SetRGB32CM(unsigned long n, unsigned long r, unsigned long g, unsigned long b);
 inline void SetRGB4CM(long index, unsigned long red, unsigned long green, unsigned long blue);
 inline BOOL VideoControl(struct TagItem * tagarray);
 inline BOOL VideoControlTags(unsigned long tag1Type,  ...);
};
//----------------------------------------------------------------------------
LONG AColorMap::AttachPalExtra (ViewPort * vp)
{
 return ::AttachPalExtra(this, vp);
}
//----------------------------------------------------------------------------
LONG AColorMap::FindColor (unsigned long r, unsigned long g, unsigned long b, long maxcolor)
{
 return ::FindColor(this, r, g, b, maxcolor);
}
//----------------------------------------------------------------------------
void AColorMap::FreeColorMap ()
{
 ::FreeColorMap(this);
}
//----------------------------------------------------------------------------
void AColorMap::operator delete (void *colorMap)
{
 ((AColorMap *) colorMap)->FreeColorMap();
}
//----------------------------------------------------------------------------
AColorMap * AColorMap::GetColorMap (long entries)
{
 return (AColorMap *) ::GetColorMap(entries);
}
//----------------------------------------------------------------------------
void * AColorMap::operator new (size_t, long entries)
{
 return AColorMap::GetColorMap(entries);
}
//----------------------------------------------------------------------------
void AColorMap::GetRGB32 (unsigned long firstcolor, unsigned long ncolors, ULONG * table)
{
 ::GetRGB32(this, firstcolor, ncolors, table);
}
//----------------------------------------------------------------------------
ULONG AColorMap::GetRGB4 (long entry)
{
 return ::GetRGB4(this, entry);
}
//----------------------------------------------------------------------------
LONG AColorMap::ObtainBestPen (unsigned long r, unsigned long g, unsigned long b, unsigned long tag1Type,  ...)
{
 return AColorMap::ObtainBestPenA(r, g, b, (TagItem *) tag1Type);
}
//----------------------------------------------------------------------------
LONG AColorMap::ObtainBestPenA (unsigned long r, unsigned long g, unsigned long b, struct TagItem * tags)
{
 return ::ObtainBestPenA(this, r, g, b, tags);
}
//----------------------------------------------------------------------------
ULONG AColorMap::ObtainPen (unsigned long n, unsigned long r, unsigned long g, unsigned long b, long f)
{
 return ::ObtainPen(this, n, r, g, b, f);
}
//----------------------------------------------------------------------------
void AColorMap::ReleasePen (unsigned long n)
{
 ::ReleasePen(this, n);
}
//----------------------------------------------------------------------------
void AColorMap::SetRGB32CM (unsigned long n, unsigned long r, unsigned long g, unsigned long b)
{
 ::SetRGB32CM(this, n, r, g, b);
}
//----------------------------------------------------------------------------
void AColorMap::SetRGB4CM (long index, unsigned long red, unsigned long green, unsigned long blue)
{
 ::SetRGB4CM(this, index, red, green, blue);
}
//----------------------------------------------------------------------------
BOOL AColorMap::VideoControl (struct TagItem * tagarray)
{
 return ::VideoControl(this, tagarray);
}
//----------------------------------------------------------------------------
BOOL AColorMap::VideoControlTags (unsigned long tag1Type,  ...)
{
 return AColorMap::VideoControl((TagItem *) tag1Type);
}

#endif
