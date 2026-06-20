/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AKeyMap wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AKeyMap_H
#define ASAP_AKeyMap_H

extern "C"
{
 #include <Proto/Keymap.h>
}

class AKeyMap : public KeyMap
{
 public:
 inline static AKeyMap * AskKeyMapDefault();
 inline void SetKeyMapDefault();
};
//----------------------------------------------------------------------------
AKeyMap * AKeyMap::AskKeyMapDefault ()
{
 return (AKeyMap *) ::AskKeyMapDefault();
}
//----------------------------------------------------------------------------
void AKeyMap::SetKeyMapDefault ()
{
 ::SetKeyMapDefault(this);
}

#endif
