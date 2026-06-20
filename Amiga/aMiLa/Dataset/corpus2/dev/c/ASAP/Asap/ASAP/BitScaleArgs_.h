/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ABitScaleArgs wrapper class                                               *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_BitScaleArgs_H
#define ASAP_BitScaleArgs_H

extern "C"
{
 #include <Graphics/Scale.h>
 #include <Proto/Graphics.h>
}

class ABitScaleArgs : public BitScaleArgs
{
 public:
 inline void BitMapScale();
};
//----------------------------------------------------------------------------
void ABitScaleArgs::BitMapScale ()
{
 ::BitMapScale(this);
}

#endif
