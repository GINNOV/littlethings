/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAmigaGuideMsg wrapper class                                              *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AAmigaGuideMsg_H
#define ASAP_AAmigaGuideMsg_H

extern "C"
{
 #include <Proto/AmigaGuide.h>
}

class AAmigaGuideMsg : public AmigaGuideMsg
{
 public:
 inline static AAmigaGuideMsg * GetAmigaGuideMsg(APTR cl);
 inline void ReplyAmigaGuideMsg();
};
//----------------------------------------------------------------------------
AAmigaGuideMsg * AAmigaGuideMsg::GetAmigaGuideMsg (APTR cl)
{
 return (AAmigaGuideMsg *) ::GetAmigaGuideMsg(cl);
}
//----------------------------------------------------------------------------
void AAmigaGuideMsg::ReplyAmigaGuideMsg ()
{
 ::ReplyAmigaGuideMsg(this);
}

#endif
