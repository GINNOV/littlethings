/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AEClockVal wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_EClockVal_H
#define ASAP_EClockVal_H

extern "C"
{
 #include <Proto/LowLevel.h>
 #include <Proto/Timer.h>
}

class AEClockVal : public EClockVal
{
 public:
 inline ULONG ElapsedTime();
 inline ULONG ReadEClock();
};
//----------------------------------------------------------------------------
ULONG AEClockVal::ElapsedTime ()
{
 return ::ElapsedTime(this);
}
//----------------------------------------------------------------------------
ULONG AEClockVal::ReadEClock ()
{
 return ::ReadEClock(this);
}

#endif
