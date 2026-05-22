/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAnchorPath wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AnchorPath_H
#define ASAP_AnchorPath_H

extern "C"
{
 #include <Proto/DOS.h>
}

class AAnchorPath : public AnchorPath
{
 public:
 inline void MatchEnd();
 inline LONG MatchFirst(STRPTR pat);
 inline LONG MatchNext();
};
//----------------------------------------------------------------------------
void AAnchorPath::MatchEnd ()
{
 ::MatchEnd(this);
}
//----------------------------------------------------------------------------
LONG AAnchorPath::MatchFirst (STRPTR pat)
{
 return ::MatchFirst(pat, this);
}
//----------------------------------------------------------------------------
LONG AAnchorPath::MatchNext ()
{
 return ::MatchNext(this);
}

#endif
