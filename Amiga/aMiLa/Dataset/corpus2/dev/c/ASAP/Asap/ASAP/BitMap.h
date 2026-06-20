/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ABitMap wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ABitMap_H
#define ASAP_ABitMap_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class ABitMap : public BitMap
{
 public:
 inline static ABitMap * AllocBitMap(unsigned long sizex, unsigned long sizey, unsigned long depth, unsigned long flags, BitMap * friend_bitmap);
 inline void * operator new(size_t, unsigned long sizex, unsigned long sizey, unsigned long depth, unsigned long flags, BitMap * friend_bitmap);
 inline LONG BltBitMap(long xSrc, long ySrc, BitMap * destBitMap, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, unsigned long mask, PLANEPTR tempA);
 inline void BltBitMapRastPort(long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm);
 inline void BltMaskBitMapRastPort(long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, PLANEPTR bltMask);
 inline void FreeBitMap();
 inline void operator delete(void *);
 inline ULONG GetBitMapAttr(unsigned long attrnum);
 inline void InitBitMap(long depth, long width, long height);
};
//----------------------------------------------------------------------------
ABitMap * ABitMap::AllocBitMap (unsigned long sizex, unsigned long sizey, unsigned long depth, unsigned long flags, BitMap * friend_bitmap)
{
 return (ABitMap *) ::AllocBitMap(sizex, sizey, depth, flags, friend_bitmap);
}
//----------------------------------------------------------------------------
void * ABitMap::operator new(size_t, unsigned long sizex, unsigned long sizey, unsigned long depth, unsigned long flags, BitMap * friend_bitmap)
{
 return ABitMap::AllocBitMap(sizex, sizey, depth, flags, friend_bitmap);
}
//----------------------------------------------------------------------------
LONG ABitMap::BltBitMap (long xSrc, long ySrc, BitMap * destBitMap, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, unsigned long mask, PLANEPTR tempA)
{
 return ::BltBitMap(this, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA);
}
//----------------------------------------------------------------------------
void ABitMap::BltBitMapRastPort (long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm)
{
 ::BltBitMapRastPort(this, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm);
}
//----------------------------------------------------------------------------
void ABitMap::BltMaskBitMapRastPort (long xSrc, long ySrc, RastPort * destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, PLANEPTR bltMask)
{
 ::BltMaskBitMapRastPort(this, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask);
}
//----------------------------------------------------------------------------
void ABitMap::FreeBitMap ()
{
 ::FreeBitMap(this);
}
//----------------------------------------------------------------------------
void ABitMap::operator delete(void *bm)
{
 ((ABitMap *) bm)->FreeBitMap();
}
//----------------------------------------------------------------------------
ULONG ABitMap::GetBitMapAttr (unsigned long attrnum)
{
 return ::GetBitMapAttr(this, attrnum);
}
//----------------------------------------------------------------------------
void ABitMap::InitBitMap (long depth, long width, long height)
{
 ::InitBitMap(this, depth, width, height);
}

#endif
