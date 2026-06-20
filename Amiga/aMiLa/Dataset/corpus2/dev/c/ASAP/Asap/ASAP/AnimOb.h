/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAnimOb wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AnimOb_H
#define ASAP_AnimOb_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AAnimOb : public AnimOb
{
 public:
 inline void AddAnimOb(AnimOb ** anKey, RastPort * rp);
 inline static void Animate(AnimOb **, RastPort * rp);
 inline void FreeGBuffers(RastPort * rp, long flag);
 inline BOOL GetGBuffers(RastPort * rp, long flag);
 inline void InitGMasks();
};
//----------------------------------------------------------------------------
void AAnimOb::AddAnimOb (AnimOb ** anKey, RastPort * rp)
{
 ::AddAnimOb(this, anKey, rp);
}
//----------------------------------------------------------------------------
void AAnimOb::Animate (AnimOb **animObs, RastPort * rp)
{
 ::Animate(animObs, rp);
}
//----------------------------------------------------------------------------
void AAnimOb::FreeGBuffers (RastPort * rp, long flag)
{
 ::FreeGBuffers(this, rp, flag);
}
//----------------------------------------------------------------------------
BOOL AAnimOb::GetGBuffers (RastPort * rp, long flag)
{
 return ::GetGBuffers(this, rp, flag);
}
//----------------------------------------------------------------------------
void AAnimOb::InitGMasks ()
{
 ::InitGMasks(this);
}

#endif
