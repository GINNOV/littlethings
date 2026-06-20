/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ALayer wrapper class                                                      *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ALayer_H
#define ASAP_ALayer_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
 #include <Proto/Layers.h>
}

class AHook;

class ALayer : public Layer
{
 public:
 inline LONG BeginUpdate();
 inline static ALayer * CreateBehindHookLayer(Layer_Info *, BitMap * bm, long x0, long y0, long x1, long y1, long flags, Hook * hook, BitMap * bm2 = 0);
 inline static ALayer * CreateBehindLayer(Layer_Info *, BitMap * bm, long x0, long y0, long x1, long y1, long flags = LAYERSMART, BitMap * bm2 = 0);
 inline static ALayer * CreateUpfrontHookLayer(Layer_Info *, BitMap * bm, long x0, long y0, long x1, long y1, long flags, Hook * hook, BitMap * bm2 = 0);
 inline static ALayer * CreateUpfrontLayer(Layer_Info *, BitMap * bm, long x0, long y0, long x1, long y1, long flags = LAYERSMART, BitMap * bm2 = 0);
 inline void * operator new(size_t, Layer_Info *, BitMap * bm, long x0, long y0, long x1, long y1, BOOL Upfront, long flags = LAYERSMART, BitMap * bm2 = 0, Hook * hook = 0);
 inline LONG DeleteLayer(LONG dummy = 0);
 inline void EndUpdate(unsigned long flag);
 inline Region * InstallClipRegion(Region * region);
 inline AHook * InstallLayerHook(Hook * hook);
 inline void LockLayerRom();
 inline LONG MoveLayerInFrontOf(Layer * other_layer);
 inline LONG MoveSizeLayer(long dx, long dy, long dw, long dh);
 inline void SortLayerCR(long dx, long dy);
 inline void UnlockLayer();
};
//----------------------------------------------------------------------------
LONG ALayer::BeginUpdate ()
{
 return ::BeginUpdate(this);
}
//----------------------------------------------------------------------------
ALayer * ALayer::CreateBehindHookLayer (Layer_Info *li, BitMap * bm, long x0, long y0, long x1, long y1, long flags, Hook * hook, BitMap * bm2)
{
 return (ALayer *) ::CreateBehindHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2);
}
//----------------------------------------------------------------------------
ALayer * ALayer::CreateBehindLayer (Layer_Info *li, BitMap * bm, long x0, long y0, long x1, long y1, long flags, BitMap * bm2)
{
 return (ALayer *) ::CreateBehindLayer(li, bm, x0, y0, x1, y1, flags, bm2);
}
//----------------------------------------------------------------------------
ALayer * ALayer::CreateUpfrontHookLayer (Layer_Info *li, BitMap * bm, long x0, long y0, long x1, long y1, long flags, Hook * hook, BitMap * bm2)
{
 return (ALayer *) ::CreateUpfrontHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2);
}
//----------------------------------------------------------------------------
ALayer * ALayer::CreateUpfrontLayer (Layer_Info *li, BitMap * bm, long x0, long y0, long x1, long y1, long flags, BitMap * bm2)
{
 return (ALayer *) ::CreateUpfrontLayer(li, bm, x0, y0, x1, y1, flags, bm2);
}
//----------------------------------------------------------------------------
void * ALayer::operator new(size_t, Layer_Info *li, BitMap * bm, long x0, long y0, long x1, long y1, BOOL Upfront, long flags, BitMap * bm2, Hook * hook)
{
 return (ALayer *) Upfront? hook? ::CreateUpfrontHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) : ::CreateUpfrontLayer(li, bm, x0, y0, x1, y1, flags, bm2)
                          : hook? ::CreateBehindHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2) : ::CreateBehindLayer(li, bm, x0, y0, x1, y1, flags, bm2);
}
//----------------------------------------------------------------------------
LONG ALayer::DeleteLayer(LONG dummy)
{
 return ::DeleteLayer(dummy, this);
}
//----------------------------------------------------------------------------
void operator delete (void *layer)
{
 ((ALayer *) layer)->DeleteLayer();
}
//----------------------------------------------------------------------------
void ALayer::EndUpdate (unsigned long flag)
{
 ::EndUpdate(this, flag);
}
//----------------------------------------------------------------------------
Region * ALayer::InstallClipRegion (Region * region)
{
 return ::InstallClipRegion(this, region);
}
//----------------------------------------------------------------------------
AHook * ALayer::InstallLayerHook (Hook * hook)
{
 return (AHook *) ::InstallLayerHook(this, hook);
}
//----------------------------------------------------------------------------
void ALayer::LockLayerRom ()
{
 ::LockLayerRom(this);
}
//----------------------------------------------------------------------------
LONG ALayer::MoveLayerInFrontOf (Layer * other_layer)
{
 return ::MoveLayerInFrontOf(this, other_layer);
}
//----------------------------------------------------------------------------
LONG ALayer::MoveSizeLayer (long dx, long dy, long dw, long dh)
{
 return ::MoveSizeLayer(this, dx, dy, dw, dh);
}
//----------------------------------------------------------------------------
void ALayer::SortLayerCR (long dx, long dy)
{
 ::SortLayerCR(this, dx, dy);
}
//----------------------------------------------------------------------------
void ALayer::UnlockLayer ()
{
 ::UnlockLayer(this);
}

#endif
