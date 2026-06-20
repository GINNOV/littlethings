/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AHook wrapper class                                                       *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Hook_H
#define ASAP_Hook_H

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <Proto/Utility.h>
}

class AHook : public Hook
{
 public:
 inline ULONG CallHook(Object * obj, Tag arg1 = 0, ...);
 inline ULONG CallHookA(Object * obj, APTR message);
 inline ULONG CallHookPkt(APTR object, APTR paramPacket);
};
//----------------------------------------------------------------------------
ULONG AHook::CallHook (Object * obj, Tag arg1, ...)
{
 return ::CallHookA(this, obj, (APTR) &arg1);
}
//----------------------------------------------------------------------------
ULONG AHook::CallHookA (Object * obj, APTR message)
{
 return ::CallHookA(this, obj, message);
}
//----------------------------------------------------------------------------
ULONG AHook::CallHookPkt (APTR object, APTR paramPacket)
{
 return ::CallHookPkt(this, object, paramPacket);
}

#endif
