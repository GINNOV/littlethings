/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACxMsg wrapper class                                                      *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_CxMsg_H
#define ASAP_CxMsg_H

#include <New.h>

extern "C"
{
 #include <Proto/Commodities.h>
}

class ACxMsg
{
 public:
 inline APTR CxMsgData();
 inline LONG CxMsgID();
 inline ULONG CxMsgType();
 inline void DisposeCxMsg();
 inline void DivertCxMsg(CxObj *headObj, CxObj *returnObj );
 inline void RouteCxMsg(CxObj *co );
};

//-----------------------------------------------------------------------------
APTR ACxMsg::CxMsgData ()
{
 return ::CxMsgData((CxMsg *)  this);
}
//-----------------------------------------------------------------------------
LONG ACxMsg::CxMsgID ()
{
 return ::CxMsgID((CxMsg *)  this);
}
//-----------------------------------------------------------------------------
ULONG ACxMsg::CxMsgType ()
{
 return ::CxMsgType((CxMsg *)  this);
}
//-----------------------------------------------------------------------------
void ACxMsg::DisposeCxMsg ()
{
 ::DisposeCxMsg((CxMsg *)  this);
}
//-----------------------------------------------------------------------------
void ACxMsg::DivertCxMsg (CxObj *headObj, CxObj *returnObj)
{
 ::DivertCxMsg ((CxMsg *) this, headObj, returnObj);
}
//-----------------------------------------------------------------------------
void ACxMsg::RouteCxMsg(CxObj *co )
{
 ::RouteCxMsg((CxMsg *) this, co);
}

#endif
