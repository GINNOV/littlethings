/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AViewPort wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AViewPort_H
#define ASAP_AViewPort_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AViewPort : public ViewPort
{
 public:
 inline LONG ChangeExtSprite(ExtSprite * oldsprite, ExtSprite * newsprite, unsigned long tag1Type,  ...);
 inline LONG ChangeExtSpriteA(ExtSprite * oldsprite, ExtSprite * newsprite, TagItem * tags);
 inline void ChangeSprite(SimpleSprite * sprite, PLANEPTR newData);
 inline void ChangeVPBitMap(BitMap * bm, DBufInfo * db);
 inline ULONG CoerceMode(unsigned long monitorid, unsigned long flags);
 inline void FreeVPortCopLists();
 inline LONG GetVPModeID();
 inline void InitVPort();
 inline void LoadRGB32(ULONG * table);
 inline void LoadRGB4(UWORD * colors, long count);
 inline ULONG MakeVPort(View * view);
 inline void MoveSprite(SimpleSprite * sprite, long x, long y);
 inline void ScrollVPort();
 inline void SetRGB32(unsigned long n, unsigned long r, unsigned long g, unsigned long b);
 inline void SetRGB4(long index, unsigned long red, unsigned long green, unsigned long blue);
 inline void WaitBOVP();
};
//----------------------------------------------------------------------------
LONG AViewPort::ChangeExtSprite (ExtSprite * oldsprite, ExtSprite * newsprite, unsigned long tag1Type,  ...)
{
 return AViewPort::ChangeExtSpriteA(oldsprite, newsprite, (TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
LONG AViewPort::ChangeExtSpriteA (ExtSprite * oldsprite, ExtSprite * newsprite, TagItem * tags)
{
 return ::ChangeExtSpriteA(this, oldsprite, newsprite, tags);
}
//----------------------------------------------------------------------------
void AViewPort::ChangeSprite (SimpleSprite * sprite, PLANEPTR newData)
{
 ::ChangeSprite(this, sprite, newData);
}
//----------------------------------------------------------------------------
void AViewPort::ChangeVPBitMap (BitMap * bm, DBufInfo * db)
{
 ::ChangeVPBitMap(this, bm, db);
}
//----------------------------------------------------------------------------
ULONG AViewPort::CoerceMode (unsigned long monitorid, unsigned long flags)
{
 return ::CoerceMode(this, monitorid, flags);
}
//----------------------------------------------------------------------------
void AViewPort::FreeVPortCopLists ()
{
 ::FreeVPortCopLists(this);
}
//----------------------------------------------------------------------------
LONG AViewPort::GetVPModeID ()
{
 return ::GetVPModeID(this);
}
//----------------------------------------------------------------------------
void AViewPort::InitVPort ()
{
 ::InitVPort(this);
}
//----------------------------------------------------------------------------
void AViewPort::LoadRGB32 (ULONG * table)
{
 ::LoadRGB32(this, table);
}
//----------------------------------------------------------------------------
void AViewPort::LoadRGB4 (UWORD * colors, long count)
{
 ::LoadRGB4(this, colors, count);
}
//----------------------------------------------------------------------------
ULONG AViewPort::MakeVPort (View * view)
{
 return ::MakeVPort(view, this);
}
//----------------------------------------------------------------------------
void AViewPort::MoveSprite (SimpleSprite * sprite, long x, long y)
{
 ::MoveSprite(this, sprite, x, y);
}
//----------------------------------------------------------------------------
void AViewPort::ScrollVPort ()
{
 ::ScrollVPort(this);
}
//----------------------------------------------------------------------------
void AViewPort::SetRGB32 (unsigned long n, unsigned long r, unsigned long g, unsigned long b)
{
 ::SetRGB32(this, n, r, g, b);
}
//----------------------------------------------------------------------------
void AViewPort::SetRGB4 (long index, unsigned long red, unsigned long green, unsigned long blue)
{
 ::SetRGB4(this, index, red, green, blue);
}
//----------------------------------------------------------------------------
void AViewPort::WaitBOVP ()
{
 ::WaitBOVP(this);
}

#endif
