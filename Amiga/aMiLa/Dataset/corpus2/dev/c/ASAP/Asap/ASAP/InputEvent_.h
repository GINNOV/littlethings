/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AInputEvent wrapper class                                                 *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AInputEvent_H
#define ASAP_AInputEvent_H

#include <New.h>

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <Proto/Commodities.h>
 #include <Proto/Console.h>
 #include <Proto/Intuition.h>
 #include <Proto/Keymap.h>
}

class AInputEvent : public InputEvent
{
 public:
 inline void AddIEvents();
// inline AInputEvent * CDInputHandler(Library * consoleDevice);
 inline static void FreeIEvents();
 void operator delete(void *);
 inline void Intuition();
 inline static AInputEvent * InvertString(STRPTR str, KeyMap * km = 0);
 void * operator new(size_t, STRPTR str, KeyMap * km = 0);
 inline WORD MapRawKey(STRPTR buffer, long length, KeyMap * keyMap);
 inline BOOL MatchIX(IX * ix);
 inline LONG RawKeyConvert(STRPTR buffer, long length, KeyMap * keyMap);
};
//----------------------------------------------------------------------------
void AInputEvent::AddIEvents ()
{
 ::AddIEvents(this);
}
/*/----------------------------------------------------------------------------
InputEvent * AInputEvent::CDInputHandler (Library * consoleDevice)
{
 return ::CDInputHandler(this, consoleDevice);
}
*///----------------------------------------------------------------------------
void AInputEvent::FreeIEvents ()
{
 ::FreeIEvents(this);
}
//----------------------------------------------------------------------------
void AInputEvent::operator delete(void *ie)
{
 ((AInputEvent *) ie)->FreeIEvents();
}
//----------------------------------------------------------------------------
void AInputEvent::Intuition ()
{
 ::Intuition(this);
}
//----------------------------------------------------------------------------
AInputEvent * AInputEvent::InvertString (STRPTR str, KeyMap * km)
{
 return (AInputEvent *) ::InvertString(str, km);
}
//----------------------------------------------------------------------------
WORD AInputEvent::MapRawKey (STRPTR buffer, long length, KeyMap * keyMap)
{
 return ::MapRawKey(this, buffer, length, keyMap);
}
//----------------------------------------------------------------------------
BOOL AInputEvent::MatchIX (IX * ix)
{
 return ::MatchIX(this, ix);
}
//----------------------------------------------------------------------------
LONG AInputEvent::RawKeyConvert (STRPTR buffer, long length, KeyMap * keyMap)
{
 return ::RawKeyConvert(this, buffer, length, keyMap);
}

#endif
