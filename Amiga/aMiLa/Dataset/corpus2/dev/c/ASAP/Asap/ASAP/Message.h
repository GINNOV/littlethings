/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMessage wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMessage_H
#define ASAP_AMessage_H

extern "C"
{
 #include <EXEC/Ports.h>
 #include <Proto/EXEC.h>
}

class AMessage : public Message
{
 public:
 inline void ReplyMsg();
};
//----------------------------------------------------------------------------
void AMessage::ReplyMsg ()
{
 ::ReplyMsg(this);
}

#endif
