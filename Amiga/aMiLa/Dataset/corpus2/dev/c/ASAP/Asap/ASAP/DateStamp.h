/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADateStamp wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DateStamp_H
#define ASAP_DateStamp_H

extern "C"
{
 #include <Proto/DOS.h>
}

class ADateStamp : public DateStamp
{
 public:
 inline LONG CompareDates(struct DateStamp * date2);
 inline ADateStamp * DateStamp();
};
//----------------------------------------------------------------------------
LONG ADateStamp::CompareDates (struct DateStamp * date2)
{
 return ::CompareDates(this, date2);
}
//----------------------------------------------------------------------------
ADateStamp * ADateStamp::DateStamp ()
{
 return (ADateStamp *) ::DateStamp(this);
}

#endif
