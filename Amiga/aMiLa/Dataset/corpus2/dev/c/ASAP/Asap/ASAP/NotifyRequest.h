/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ANotifyRequest wrapper class                                              *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ANotifyRequest_H
#define ASAP_ANotifyRequest_H

extern "C"
{
 #include <Proto/DOS.h>
}

class ANotifyRequest : public NotifyRequest
{
 public:
 inline void EndNotify();
 inline BOOL StartNotify();
};
//----------------------------------------------------------------------------
void ANotifyRequest::EndNotify ()
{
 ::EndNotify(this);
}
//----------------------------------------------------------------------------
BOOL ANotifyRequest::StartNotify ()
{
 return ::StartNotify(this);
}

#endif
