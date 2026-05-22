/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ADateTime wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_DateTime_H
#define ASAP_DateTime_H

extern "C"
{
 #include <Proto/DOS.h>
}

class ADateTime : public DateTime
{
 public:
 inline LONG DateToStr();
 inline LONG StrToDate();
};
//----------------------------------------------------------------------------
LONG ADateTime::DateToStr ()
{
 return ::DateToStr(this);
}
//----------------------------------------------------------------------------
LONG ADateTime::StrToDate ()
{
 return ::StrToDate(this);
}

#endif
