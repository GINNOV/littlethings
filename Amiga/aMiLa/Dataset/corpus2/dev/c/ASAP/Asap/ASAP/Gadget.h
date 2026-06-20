/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AGadget wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_Gadget_H
#define ASAP_Gadget_H

extern "C"
{
 #include <Proto/GadTools.h>
 #include <Proto/Intuition.h>
}

class ARastPort;

class AGadget : public Gadget
{
 public:
 inline BOOL ActivateGadget(Window * window, Requester * requester);
 inline static AGadget * CreateContext(Gadget **glistptr);
 inline static AGadget * CreateGadget(unsigned long kind, Gadget * gad, NewGadget * ng, Tag tag1,  ...);
 inline static AGadget * CreateGadgetA(unsigned long kind, Gadget * gad, NewGadget * ng, TagItem * taglist);
 inline ULONG DoGadgetMethod(Window * win, Requester * req, unsigned long MethodID,  ...);
 inline ULONG DoGadgetMethodA(Window * win, Requester * req, Msg message);
 inline static void FreeGadgets(Gadget *glistptr);
 inline LONG GT_GetGadgetAttrs(Window * win, Requester * req, Tag tag1,  ...);
 inline LONG GT_GetGadgetAttrsA(Window * win, Requester * req, TagItem * taglist);
 inline void GT_SetGadgetAttrs(Window * win, Requester * req, Tag tag1,  ...);
 inline void GT_SetGadgetAttrsA(Window * win, Requester * req, TagItem * taglist);
 inline void GadgetMouse(GadgetInfo * gInfo, WORD * mousePoint);
 inline void ModifyProp(Window * window, Requester * requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody);
 inline void NewModifyProp(Window * window, Requester * requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody, long numGad);
 inline void OffGadget(Window * window, Requester * requester);
 inline void OnGadget(Window * window, Requester * requester);
 inline void RefreshGList(Window * window, Requester * requester, long numGad);
 inline void RefreshGadgets(Window * window, Requester * requester);
 inline ULONG SetGadgetAttrs(Window * window, Requester * requester, unsigned long tag1,  ...);
 inline ULONG SetGadgetAttrsA(Window * window, Requester * requester, TagItem * tagList);
};
//----------------------------------------------------------------------------
BOOL AGadget::ActivateGadget (Window * window, Requester * requester)
{
 return ::ActivateGadget(this, window, requester);
}
//----------------------------------------------------------------------------
AGadget * AGadget::CreateContext (Gadget **glistptr)
{
 glistptr = 0; return (AGadget *) ::CreateContext(glistptr);
}
//----------------------------------------------------------------------------
AGadget * AGadget::CreateGadget (unsigned long kind, Gadget * gad, NewGadget * ng, Tag tag1,  ...)
{
 return AGadget::CreateGadgetA(kind, gad, ng, (TagItem *) &tag1);
}
//----------------------------------------------------------------------------
AGadget * AGadget::CreateGadgetA (unsigned long kind, Gadget * gad, NewGadget * ng, TagItem * taglist)
{
 return (AGadget *) ::CreateGadgetA(kind, gad, ng, taglist);
}
//----------------------------------------------------------------------------
ULONG AGadget::DoGadgetMethod (Window * win, Requester * req, unsigned long MethodID,  ...)
{
 return ::DoGadgetMethod(this, win, req, MethodID);
}
//----------------------------------------------------------------------------
ULONG AGadget::DoGadgetMethodA (Window * win, Requester * req, Msg message)
{
 return ::DoGadgetMethodA(this, win, req, message);
}
//----------------------------------------------------------------------------
void AGadget::FreeGadgets (Gadget *glistptr)
{
 ::FreeGadgets(glistptr);
}
//----------------------------------------------------------------------------
LONG AGadget::GT_GetGadgetAttrs (Window * win, Requester * req, Tag tag1,  ...)
{
 return ::GT_GetGadgetAttrs(this, win, req, tag1);
}
//----------------------------------------------------------------------------
LONG AGadget::GT_GetGadgetAttrsA (Window * win, Requester * req, TagItem * taglist)
{
 return ::GT_GetGadgetAttrsA(this, win, req, taglist);
}
//----------------------------------------------------------------------------
void AGadget::GT_SetGadgetAttrs (Window * win, Requester * req, Tag tag1,  ...)
{
 ::GT_SetGadgetAttrs(this, win, req, tag1);
}
//----------------------------------------------------------------------------
void AGadget::GT_SetGadgetAttrsA (Window * win, Requester * req, TagItem * taglist)
{
 ::GT_SetGadgetAttrsA(this, win, req, taglist);
}
//----------------------------------------------------------------------------
void AGadget::GadgetMouse (GadgetInfo * gInfo, WORD * mousePoint)
{
 ::GadgetMouse(this, gInfo, mousePoint);
}
//----------------------------------------------------------------------------
void AGadget::ModifyProp (Window * window, Requester * requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody)
{
 ::ModifyProp(this, window, requester, flags, horizPot, vertPot, horizBody, vertBody);
}
//----------------------------------------------------------------------------
void AGadget::NewModifyProp (Window * window, Requester * requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody, long numGad)
{
 ::NewModifyProp(this, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad);
}
//----------------------------------------------------------------------------
void AGadget::OffGadget (Window * window, Requester * requester)
{
 ::OffGadget(this, window, requester);
}
//----------------------------------------------------------------------------
void AGadget::OnGadget (Window * window, Requester * requester)
{
 ::OnGadget(this, window, requester);
}
//----------------------------------------------------------------------------
void AGadget::RefreshGList (Window * window, Requester * requester, long numGad)
{
 ::RefreshGList(this, window, requester, numGad);
}
//----------------------------------------------------------------------------
void AGadget::RefreshGadgets (Window * window, Requester * requester)
{
 ::RefreshGadgets(this, window, requester);
}
//----------------------------------------------------------------------------
ULONG AGadget::SetGadgetAttrs (Window * window, Requester * requester, unsigned long tag1,  ...)
{
 return ::SetGadgetAttrs(this, window, requester, tag1);
}
//----------------------------------------------------------------------------
ULONG AGadget::SetGadgetAttrsA (Window * window, Requester * requester, TagItem * tagList)
{
 return ::SetGadgetAttrsA(this, window, requester, tagList);
}

#endif
