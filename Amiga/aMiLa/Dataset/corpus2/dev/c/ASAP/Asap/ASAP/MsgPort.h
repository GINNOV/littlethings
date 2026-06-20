/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMsgPort wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMsgPort_H
#define ASAP_AMsgPort_H

#include <New.h>

extern "C"
{
 #include <CLIB/ALIB_PROTOS.h>
 #include <Proto/EXEC.h>
 #include <Proto/GadTools.h>
}

class AMessage;
class AIntuiMessage;

class AMsgPort : public MsgPort
{
 public:
 inline void AddPort();
// inline static AMsgPort * CreateMsgPort();
// void * operator new(size_t);
 inline static AMsgPort * CreatePort(STRPTR name = 0, long pri = 0);
 void * operator new(size_t, STRPTR name = 0, long pri = 0);
// inline void DeleteMsgPort();
 inline void DeletePort();
 void operator delete(void *);
 inline AMsgPort * FindPort(UBYTE * name);
 inline AIntuiMessage * GT_GetIMsg();
 inline AMessage * GetMsg();
 inline void PutMsg(Message * message);
 inline void RemPort();
 inline AMessage * WaitPort();
};
//----------------------------------------------------------------------------
void AMsgPort::AddPort ()
{
 ::AddPort(this);
}
/*/----------------------------------------------------------------------------
AMsgPort * AMsgPort::CreateMsgPort ()
{
 return (AMsgPort *) ::CreateMsgPort();
}
//----------------------------------------------------------------------------
void * AMsgPort::operator new (size_t)
{
 return AMsgPort::CreateMsgPort();
}
*///----------------------------------------------------------------------------
AMsgPort * AMsgPort::CreatePort (STRPTR name, long pri)
{
 return (AMsgPort *) ::CreatePort(name, pri);
}
//----------------------------------------------------------------------------
void * AMsgPort::operator new (size_t, STRPTR name, long pri)
{
 return AMsgPort::CreatePort(name, pri);
}
/*/----------------------------------------------------------------------------
void AMsgPort::DeleteMsgPort ()
{
 ::DeleteMsgPort(this);
}
*///----------------------------------------------------------------------------
void AMsgPort::DeletePort ()
{
 ::DeletePort(this);
}
//----------------------------------------------------------------------------
void AMsgPort::operator delete (void *port)
{
 ((AMsgPort *) port)->DeletePort();
}
//----------------------------------------------------------------------------
AMsgPort * AMsgPort::FindPort (UBYTE * name)
{
 return (AMsgPort *) ::FindPort(name);
}
//----------------------------------------------------------------------------
AIntuiMessage * AMsgPort::GT_GetIMsg ()
{
 return (AIntuiMessage *) ::GT_GetIMsg(this);
}
//----------------------------------------------------------------------------
AMessage * AMsgPort::GetMsg ()
{
 return (AMessage *) ::GetMsg(this);
}
//----------------------------------------------------------------------------
void AMsgPort::PutMsg (Message * message)
{
 ::PutMsg(this, message);
}
//----------------------------------------------------------------------------
void AMsgPort::RemPort ()
{
 ::RemPort(this);
}
//----------------------------------------------------------------------------
AMessage * AMsgPort::WaitPort ()
{
 return (AMessage *) ::WaitPort(this);
}

#endif
