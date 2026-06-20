/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ABob wrapper class                                                        *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Bob_H
#define ASAP_Bob_H

extern "C"
{
 #include <Proto/Graphics.h>
}

class ABob : public Bob
{
 public:
 inline void AddBob(struct RastPort * rp);
 inline void RemIBob(struct RastPort * rp, struct ViewPort * vp);
};
//----------------------------------------------------------------------------
void ABob::AddBob (struct RastPort * rp)
{
 ::AddBob(this, rp);
}
//----------------------------------------------------------------------------
void ABob::RemIBob (struct RastPort * rp, struct ViewPort * vp)
{
 ::RemIBob(this, rp, vp);
}

#endif
