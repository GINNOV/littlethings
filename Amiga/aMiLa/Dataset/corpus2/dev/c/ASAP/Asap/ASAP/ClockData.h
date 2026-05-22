/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AClockData wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ClockData_H
#define ASAP_ClockData_H

extern "C"
{
 #include <Proto/Utility.h>
}

class AClockData : public ClockData
{
 public:
 inline ULONG CheckDate();
 inline ULONG Date2Amiga();
};
//----------------------------------------------------------------------------
ULONG AClockData::CheckDate ()
{
 return ::CheckDate(this);
}
//----------------------------------------------------------------------------
ULONG AClockData::Date2Amiga ()
{
 return ::Date2Amiga(this);
}

#endif
