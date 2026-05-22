/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ACxObj wrapper class                                                      *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_CxObj_H
#define ASAP_CxObj_H

#include <New.h>

extern "C"
{
 #include <Proto/Commodities.h>
}

class ACxObj
{
 public:
 inline static ACxObj * HotKey( STRPTR description, MsgPort *port, long id);
 inline LONG ActivateCxObj(long Activate = true );
 inline void AttachCxObj( CxObj *headObj);
 inline void ClearCxObjError();
 inline static ACxObj *CreateCxObj( unsigned long type, long arg1, long arg2 );
 inline void * operator new (size_t, unsigned long type, long arg1, long arg2);
 inline static ACxObj *CxBroker( struct NewBroker *nb, LONG *error );
 inline void * operator new (size_t, NewBroker *nb, LONG *error);
 inline LONG CxObjError();
 inline ULONG CxObjType();
 inline void DeleteCxObj();
 inline void operator delete (void *co);
 inline static void DeleteCxObjAll(CxObj *co);
 inline void EnqueueCxObj( CxObj *headObj);
 inline void InsertCxObj( CxObj *headObj, CxObj *pred = 0);
 inline void RemoveCxObj();
 inline LONG SetCxObjPri(long pri);
 inline void SetFilter(STRPTR text);
 inline void SetFilterIX(IX *ix);
 inline void SetTranslate(InputEvent *events);
};
//-----------------------------------------------------------------------------
ACxObj * ACxObj::HotKey (STRPTR description, MsgPort *port, long id )
{
 return (ACxObj *) ::HotKey(description, port, id);
}
//-----------------------------------------------------------------------------
LONG ACxObj::ActivateCxObj (long Activate)
{
 return ::ActivateCxObj((LONG *) this, Activate);
}
//-----------------------------------------------------------------------------
void ACxObj::AttachCxObj (CxObj *headObj)
{
 ::AttachCxObj(headObj, (CxObj *) this);
}
//-----------------------------------------------------------------------------
void ACxObj::ClearCxObjError ()
{
 ::ClearCxObjError((CxObj *) this);
}
//-----------------------------------------------------------------------------
ACxObj * ACxObj::CreateCxObj (unsigned long type, long arg1, long arg2)
{
 return (ACxObj *) ::CreateCxObj(type, arg1, arg2);
}
//-----------------------------------------------------------------------------
void * ACxObj::operator new (size_t, unsigned long type, long arg1, long arg2)
{
 return ACxObj::CreateCxObj(type, arg1, arg2);
}
//-----------------------------------------------------------------------------
ACxObj * ACxObj::CxBroker (NewBroker *nb, LONG *error)
{
 return (ACxObj *) ::CxBroker(nb, error);
}
//-----------------------------------------------------------------------------
void * ACxObj::operator new (size_t, NewBroker *nb, LONG *error)
{
 return ACxObj::CxBroker(nb, error);
}
//-----------------------------------------------------------------------------
LONG ACxObj::CxObjError ()
{
 return ::CxObjError((CxObj *) this);
}
//-----------------------------------------------------------------------------
ULONG ACxObj::CxObjType ()
{
 return ::CxObjType((CxObj *) this);
}
//-----------------------------------------------------------------------------
void ACxObj::DeleteCxObj ()
{
 ::DeleteCxObj((CxObj *) this);
}
//-----------------------------------------------------------------------------
void ACxObj::operator delete (void *co)
{
 ((ACxObj *) co)->DeleteCxObj();
}
//-----------------------------------------------------------------------------
void ACxObj::DeleteCxObjAll (CxObj *co)
{
 ::DeleteCxObjAll((CxObj *) co);
}
//-----------------------------------------------------------------------------
void ACxObj::EnqueueCxObj (CxObj *headObj)
{
 ::EnqueueCxObj((CxObj *) headObj, (CxObj *) this);
}
//-----------------------------------------------------------------------------
void ACxObj::InsertCxObj (CxObj *headObj, CxObj *pred)
{
 ::InsertCxObj(headObj, (CxObj *) this, pred);
}
//-----------------------------------------------------------------------------
void ACxObj::RemoveCxObj ()
{
 ::RemoveCxObj((CxObj *) this);
}
//-----------------------------------------------------------------------------
LONG ACxObj::SetCxObjPri (long pri)
{
 return ::SetCxObjPri((CxObj *) this, pri);
}
//-----------------------------------------------------------------------------
void ACxObj::SetFilter (STRPTR text)
{
 ::SetFilter((CxObj *) this, text);
}
//-----------------------------------------------------------------------------
void ACxObj::SetFilterIX (IX *ix)
{
 ::SetFilterIX((CxObj *) this, ix);
}
//-----------------------------------------------------------------------------
void ACxObj::SetTranslate (InputEvent *events)
{
 ::SetTranslate((CxObj *) this, events);
}

#endif
