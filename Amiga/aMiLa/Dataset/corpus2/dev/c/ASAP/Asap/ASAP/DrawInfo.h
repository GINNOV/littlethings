/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADrawInfo wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ADrawInfo_H
#define ASAP_ADrawInfo_H

extern "C"
{
 #include <Proto/Intuition.h>
}

class ADrawInfo : public DrawInfo
{
 public:
 inline void FreeScreenDrawInfo(Screen * screen);
 inline static ADrawInfo * GetScreenDrawInfo(Screen * screen);
};
//----------------------------------------------------------------------------
void ADrawInfo::FreeScreenDrawInfo (Screen * screen)
{
 ::FreeScreenDrawInfo(screen, this);
}
//----------------------------------------------------------------------------
ADrawInfo * ADrawInfo::GetScreenDrawInfo (Screen * screen)
{
 return (ADrawInfo *) ::GetScreenDrawInfo(screen);
}

#endif
