/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIntuiText wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AIntuiText_H
#define ASAP_AIntuiText_H

extern "C"
{
 #include <Proto/Intuition.h>
}

class AIntuiText : public IntuiText
{
 public:
 inline LONG IntuiTextLength();
};
//----------------------------------------------------------------------------
LONG AIntuiText::IntuiTextLength ()
{
 return ::IntuiTextLength(this);
}

#endif
