/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AIntuiMessage wrapper class                                               *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AIntuiMessage_H
#define ASAP_AIntuiMessage_H

extern "C"
{
 #include <Proto/GadTools.h>
}

class AIntuiMessage : public IntuiMessage
{
 public:
 inline AIntuiMessage * GT_FilterIMsg();
 inline AIntuiMessage * GT_PostFilterIMsg();
 inline void GT_ReplyIMsg();
 inline void ReplyMsg();
};
//----------------------------------------------------------------------------
AIntuiMessage * AIntuiMessage::GT_FilterIMsg ()
{
 return (AIntuiMessage *) ::GT_FilterIMsg(this);
}
//----------------------------------------------------------------------------
AIntuiMessage * AIntuiMessage::GT_PostFilterIMsg ()
{
 return (AIntuiMessage *) ::GT_PostFilterIMsg(this);
}
//----------------------------------------------------------------------------
void AIntuiMessage::GT_ReplyIMsg ()
{
 ::GT_ReplyIMsg(this);
}
//----------------------------------------------------------------------------
void AIntuiMessage::ReplyMsg ()
{
 ::ReplyMsg((Message *) this);
}

#endif
