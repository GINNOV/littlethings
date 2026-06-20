/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AVSprite wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AVSprite_H
#define ASAP_AVSprite_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class AVSprite : public VSprite
{
 public:
 inline void AddVSprite(RastPort * rp);
 inline static void InitGels(VSprite * head, VSprite * tail, GelsInfo * gelsInfo);
 inline void InitMasks();
 inline void RemVSprite();
};
//----------------------------------------------------------------------------
void AVSprite::AddVSprite (RastPort * rp)
{
 ::AddVSprite(this, rp);
}
//----------------------------------------------------------------------------
void AVSprite::InitGels (VSprite * head, VSprite * tail, GelsInfo * gelsInfo)
{
 ::InitGels(head, tail, gelsInfo);
}
//----------------------------------------------------------------------------
void AVSprite::InitMasks ()
{
 ::InitMasks(this);
}
//----------------------------------------------------------------------------
void AVSprite::RemVSprite ()
{
 ::RemVSprite(this);
}

#endif
