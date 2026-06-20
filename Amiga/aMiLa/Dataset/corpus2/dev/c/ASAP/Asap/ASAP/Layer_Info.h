/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ALayer_Info wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ALayer_Info_H
#define ASAP_ALayer_Info_H

#include <New.h>

extern "C"
{
 #include <Proto/Layers.h>
}

class AHook;
class ALayer;

class ALayer_Info : public Layer_Info
{
 public:
 inline void DisposeLayerInfo();
 inline void operator delete (void *);
 inline LONG FattenLayerInfo();
 inline void InitLayers();
 inline AHook * InstallLayerInfoHook(Hook * hook);
 inline void LockLayerInfo();
 inline void LockLayers();
 inline static ALayer_Info * NewLayerInfo();
 inline void * operator new(size_t);
 inline void ThinLayerInfo();
 inline void UnlockLayerInfo();
 inline void UnlockLayers();
 inline ALayer * WhichLayer(long x, long y);
};
//----------------------------------------------------------------------------
void ALayer_Info::DisposeLayerInfo ()
{
 ::DisposeLayerInfo(this);
}
//----------------------------------------------------------------------------
void ALayer_Info::operator delete (void *li)
{
 ((ALayer_Info *) li)->DisposeLayerInfo();
}
//----------------------------------------------------------------------------
LONG ALayer_Info::FattenLayerInfo ()
{
 return ::FattenLayerInfo(this);
}
//----------------------------------------------------------------------------
void ALayer_Info::InitLayers ()
{
 ::InitLayers(this);
}
//----------------------------------------------------------------------------
AHook * ALayer_Info::InstallLayerInfoHook (Hook * hook)
{
 return (AHook *) ::InstallLayerInfoHook(this, hook);
}
//----------------------------------------------------------------------------
void ALayer_Info::LockLayerInfo ()
{
 ::LockLayerInfo(this);
}
//----------------------------------------------------------------------------
void ALayer_Info::LockLayers ()
{
 ::LockLayers(this);
}
//----------------------------------------------------------------------------
ALayer_Info * ALayer_Info::NewLayerInfo ()
{
 return (ALayer_Info *) ::NewLayerInfo();
}
//----------------------------------------------------------------------------
void * ALayer_Info::operator new (size_t)
{
 return ALayer_Info::NewLayerInfo();
}
//----------------------------------------------------------------------------
void ALayer_Info::ThinLayerInfo ()
{
 ::ThinLayerInfo(this);
}
//----------------------------------------------------------------------------
void ALayer_Info::UnlockLayerInfo ()
{
 ::UnlockLayerInfo(this);
}
//----------------------------------------------------------------------------
void ALayer_Info::UnlockLayers ()
{
 ::UnlockLayers(this);
}
//----------------------------------------------------------------------------
ALayer * ALayer_Info::WhichLayer (long x, long y)
{
 return (ALayer *) ::WhichLayer(this, x, y);
}

#endif
