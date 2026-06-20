/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ARexxMsg wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_ARexxMsg_H
#define ASAP_ARexxMsg_H

#include <New.h>

extern "C"
{
 #include <Proto/RexxSysLib.h>
}

class ARexxMsg : public RexxMsg
{
 public:
 inline void ClearRexxMsg(unsigned long count);
 inline static ARexxMsg * CreateRexxMsg(MsgPort * port, UBYTE * extension, UBYTE * host);
 inline void * operator new(size_t, MsgPort * port, UBYTE * extension, UBYTE * host);
 inline void DeleteRexxMsg();
 inline void operator delete(void *);
 inline BOOL FillRexxMsg(unsigned long count, unsigned long mask);
 inline BOOL IsRexxMsg();
};
//----------------------------------------------------------------------------
void ARexxMsg::ClearRexxMsg (unsigned long count)
{
 ::ClearRexxMsg(this, count);
}
//----------------------------------------------------------------------------
ARexxMsg * ARexxMsg::CreateRexxMsg (MsgPort * port, UBYTE * extension, UBYTE * host)
{
 return (ARexxMsg *) ::CreateRexxMsg(port, extension, host);
}
//----------------------------------------------------------------------------
void * ARexxMsg::operator new (size_t, MsgPort * port, UBYTE * extension, UBYTE * host)
{
 return ARexxMsg::CreateRexxMsg(port, extension, host);
}
//----------------------------------------------------------------------------
void ARexxMsg::DeleteRexxMsg ()
{
 ::DeleteRexxMsg(this);
}
//----------------------------------------------------------------------------
void ARexxMsg::operator delete (void *rexxmsg)
{
 ((ARexxMsg *) rexxmsg)->DeleteRexxMsg();
}
//----------------------------------------------------------------------------
BOOL ARexxMsg::FillRexxMsg (unsigned long count, unsigned long mask)
{
 return ::FillRexxMsg(this, count, mask);
}
//----------------------------------------------------------------------------
BOOL ARexxMsg::IsRexxMsg ()
{
 return ::IsRexxMsg(this);
}

#endif
