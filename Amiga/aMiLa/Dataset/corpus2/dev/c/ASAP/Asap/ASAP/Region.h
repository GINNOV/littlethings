/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARegion wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ARegion_H
#define ASAP_ARegion_H

#include <New.h>

extern "C"
{
 #include <Proto/Graphics.h>
}

class ARegion : public Region
{
 public:
 inline void AndRectRegion(Rectangle * rectangle);
 inline BOOL AndRegionRegion(Region * destRegion);
 inline BOOL ClearRectRegion(Rectangle * rectangle);
 inline void ClearRegion();
 inline void DisposeRegion();
 inline void operator delete(void *);
 inline static ARegion * NewRegion();
 inline void * operator new(size_t);
 inline BOOL OrRectRegion(Rectangle * rectangle);
 inline BOOL OrRegionRegion(Region * destRegion);
 inline BOOL XorRectRegion(Rectangle * rectangle);
 inline BOOL XorRegionRegion(Region * destRegion);
};
//----------------------------------------------------------------------------
void ARegion::AndRectRegion (Rectangle * rectangle)
{
 ::AndRectRegion(this, rectangle);
}
//----------------------------------------------------------------------------
BOOL ARegion::AndRegionRegion (Region * destRegion)
{
 return ::AndRegionRegion(this, destRegion);
}
//----------------------------------------------------------------------------
BOOL ARegion::ClearRectRegion (Rectangle * rectangle)
{
 return ::ClearRectRegion(this, rectangle);
}
//----------------------------------------------------------------------------
void ARegion::ClearRegion ()
{
 ::ClearRegion(this);
}
//----------------------------------------------------------------------------
void ARegion::DisposeRegion ()
{
 ::DisposeRegion(this);
}
//----------------------------------------------------------------------------
void ARegion::operator delete (void *region)
{
 ((ARegion *) region)->DisposeRegion();
}
//----------------------------------------------------------------------------
ARegion * ARegion::NewRegion ()
{
 return (ARegion *) ::NewRegion();
}
//----------------------------------------------------------------------------
void * ARegion::operator new (size_t)
{
 return (ARegion *) ::NewRegion();
}
//----------------------------------------------------------------------------
BOOL ARegion::OrRectRegion (Rectangle * rectangle)
{
 return ::OrRectRegion(this, rectangle);
}
//----------------------------------------------------------------------------
BOOL ARegion::OrRegionRegion (Region * destRegion)
{
 return ::OrRegionRegion(this, destRegion);
}
//----------------------------------------------------------------------------
BOOL ARegion::XorRectRegion (Rectangle * rectangle)
{
 return ::XorRectRegion(this, rectangle);
}
//----------------------------------------------------------------------------
BOOL ARegion::XorRegionRegion (Region * destRegion)
{
 return ::XorRegionRegion(this, destRegion);
}

#endif
