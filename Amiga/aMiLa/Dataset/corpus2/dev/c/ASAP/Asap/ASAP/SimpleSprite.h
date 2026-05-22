/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ASimpleSprite wrapper class                                               *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_SimpleSprite_H
#define ASAP_SimpleSprite_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class ASimpleSprite : public SimpleSprite
{
 public:
 inline WORD GetSprite(/* SimpleSprite *sprite, */long number = -1);
 inline void FreeSprite();
};
//-----------------------------------------------------------------------------
WORD ASimpleSprite::GetSprite (long number)
{
 return ::GetSprite(this, number);
}
//-----------------------------------------------------------------------------
void ASimpleSprite::FreeSprite ()
{
 ::FreeSprite(num);
}

#endif
