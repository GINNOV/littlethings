/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AWindow wrapper class                                                     *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AWindow_H
#define ASAP_AWindow_H

#include <new.h>

extern "C"
{
 #include <proto/DataTypes.h>
 #include <proto/GadTools.h>
 #include <proto/Intuition.h>
}

class AViewPort;

class AWindow : public Window
{
 public:
 inline void ActivateWindow();
 inline LONG AddDTObject(Requester * req, Object * o, long pos = -1);
 inline UWORD AddGList(Gadget * gadget, unsigned long position, long numGad, Requester * requester);
 inline UWORD AddGadget(Gadget * gadget, unsigned long position);
 inline BOOL AutoRequest(IntuiText * body, IntuiText * posText, IntuiText * negText, unsigned long pFlag, unsigned long nFlag, unsigned long width, unsigned long height);
 inline void BeginRefresh();
 inline AWindow * BuildEasyRequest(EasyStruct * easyStruct, unsigned long idcmp = 0, APTR arg1 = TAG_DONE, ...);
 inline AWindow * BuildEasyRequestArgs(EasyStruct * easyStruct, unsigned long idcmp, APTR args);
 inline AWindow * BuildSysRequest(IntuiText * body, IntuiText * posText, IntuiText * negText, unsigned long flags, unsigned long width, unsigned long height);
 inline void ChangeWindowBox(long left, long top, long width, long height);
 inline BOOL ClearDMRequest();
 inline void ClearMenuStrip();
 inline void ClearPointer();
 inline void CloseWindow();
 inline void operator delete(void *);
 inline LONG EasyRequest(EasyStruct * easyStruct, ULONG * idcmpPtr, APTR arg1 = TAG_DONE, ...);
 inline LONG EasyRequestArgs(EasyStruct * easyStruct, ULONG * idcmpPtr, APTR args);
 inline void EndRefresh(long complete);
 inline void FreeSysRequest();
 inline void GT_BeginRefresh();
 inline void GT_EndRefresh(long complete = 1);
 inline void GT_RefreshWindow(Requester * req);
 inline void HelpControl(unsigned long flags);
 inline void LendMenus(Window * towindow);
 inline BOOL ModifyIDCMP(unsigned long flags);
 inline void MoveWindow(long dx, long dy);
 inline void MoveWindowInFrontOf(Window * behindWindow);
 inline void OffMenu(unsigned long menuNumber);
 inline void OnMenu(unsigned long menuNumber);
 inline static AWindow * OpenWindow(NewWindow *);
 inline void * operator new(size_t, NewWindow *);
 inline static AWindow * OpenWindowTagList(NewWindow *, TagItem * tagList);
 inline void * operator new(size_t, NewWindow *, TagItem * tagList);
 inline static AWindow * OpenWindowTags(NewWindow *, unsigned long tag1Type,  ...);
 inline void * operator new(size_t, NewWindow *, unsigned long tag1Type,  ...);
 inline void RefreshWindowFrame();
 inline LONG RemoveDTObject(Object * o);
 inline UWORD RemoveGList(Gadget * gadget, long numGad);
 inline UWORD RemoveGadget(Gadget * gadget);
 inline void ReportMouse(long flag);
 inline BOOL ResetMenuStrip(Menu * menu);
 inline void ScrollWindowRaster(long dx, long dy, long xMin, long yMin, long xMax, long yMax);
 inline BOOL SetDMRequest(Requester * requester);
 inline BOOL SetMenuStrip(Menu * menu);
 inline LONG SetMouseQueue(unsigned long queueLength);
 inline void SetPointer(UWORD * pointer, long height, long width, long xOffset, long yOffset);
 inline void SetWindowPointer(unsigned long tag1,  ...);
 inline void SetWindowPointerA(TagItem * taglist);
 inline void SetWindowTitles(UBYTE * windowTitle, UBYTE * screenTitle);
 inline void SizeWindow(long dx, long dy);
 inline LONG SysReqHandler(ULONG * idcmpPtr, long waitInput);
 inline AViewPort * ViewPortAddress();
 inline BOOL WindowLimits(long widthMin, long heightMin, unsigned long widthMax, unsigned long heightMax);
 inline void WindowToBack();
 inline void WindowToFront();
 inline void ZipWindow();
};
//----------------------------------------------------------------------------
void AWindow::ActivateWindow ()
{
 ::ActivateWindow(this);
}
//----------------------------------------------------------------------------
LONG AWindow::AddDTObject (Requester * req, Object * o, long pos)
{
 return ::AddDTObject(this, req, o, pos);
}
//----------------------------------------------------------------------------
UWORD AWindow::AddGList (Gadget * gadget, unsigned long position, long numGad, Requester * requester)
{
 return ::AddGList(this, gadget, position, numGad, requester);
}
//----------------------------------------------------------------------------
UWORD AWindow::AddGadget (Gadget * gadget, unsigned long position)
{
 return ::AddGadget(this, gadget, position);
}
//----------------------------------------------------------------------------
BOOL AWindow::AutoRequest (IntuiText * body, IntuiText * posText, IntuiText * negText, unsigned long pFlag, unsigned long nFlag, unsigned long width, unsigned long height)
{
 return ::AutoRequest(this, body, posText, negText, pFlag, nFlag, width, height);
}
//----------------------------------------------------------------------------
void AWindow::BeginRefresh ()
{
 ::BeginRefresh(this);
}
//----------------------------------------------------------------------------
AWindow * AWindow::BuildEasyRequest (EasyStruct * easyStruct, unsigned long idcmp, APTR arg1, ...)
{
 return AWindow::BuildEasyRequestArgs(easyStruct, idcmp, (APTR) &arg1);
}
//----------------------------------------------------------------------------
AWindow * AWindow::BuildEasyRequestArgs (EasyStruct * easyStruct, unsigned long idcmp, APTR args)
{
 return (AWindow *) ::BuildEasyRequestArgs(this, easyStruct, idcmp, args);
}
//----------------------------------------------------------------------------
AWindow * AWindow::BuildSysRequest (IntuiText * body, IntuiText * posText, IntuiText * negText, unsigned long flags, unsigned long width, unsigned long height)
{
 return (AWindow *) ::BuildSysRequest(this, body, posText, negText, flags, width, height);
}
//----------------------------------------------------------------------------
void AWindow::ChangeWindowBox (long left, long top, long width, long height)
{
 ::ChangeWindowBox(this, left, top, width, height);
}
//----------------------------------------------------------------------------
BOOL AWindow::ClearDMRequest ()
{
 return ::ClearDMRequest(this);
}
//----------------------------------------------------------------------------
void AWindow::ClearMenuStrip ()
{
 ::ClearMenuStrip(this);
}
//----------------------------------------------------------------------------
void AWindow::ClearPointer ()
{
 ::ClearPointer(this);
}
//----------------------------------------------------------------------------
void AWindow::CloseWindow ()
{
 ::CloseWindow(this);
}
//----------------------------------------------------------------------------
void AWindow::operator delete (void *win)
{
 ((AWindow *) win)->CloseWindow();
}
//----------------------------------------------------------------------------
LONG AWindow::EasyRequest (EasyStruct * easyStruct, ULONG * idcmpPtr, APTR arg1, ...)
{
 return ::EasyRequest(this, easyStruct, idcmpPtr, (APTR) &arg1);
}
//----------------------------------------------------------------------------
LONG AWindow::EasyRequestArgs (EasyStruct * easyStruct, ULONG * idcmpPtr, APTR args)
{
 return ::EasyRequestArgs(this, easyStruct, idcmpPtr, args);
}
//----------------------------------------------------------------------------
void AWindow::EndRefresh (long complete)
{
 ::EndRefresh(this, complete);
}
//----------------------------------------------------------------------------
void AWindow::FreeSysRequest ()
{
 ::FreeSysRequest(this);
}
//----------------------------------------------------------------------------
void AWindow::GT_BeginRefresh ()
{
 ::GT_BeginRefresh(this);
}
//----------------------------------------------------------------------------
void AWindow::GT_EndRefresh (long complete)
{
 ::GT_EndRefresh(this, complete);
}
//----------------------------------------------------------------------------
void AWindow::GT_RefreshWindow (Requester * req)
{
 ::GT_RefreshWindow(this, req);
}
//----------------------------------------------------------------------------
void AWindow::HelpControl (unsigned long flags)
{
 ::HelpControl(this, flags);
}
//----------------------------------------------------------------------------
void AWindow::LendMenus (Window * towindow)
{
 ::LendMenus(this, towindow);
}
//----------------------------------------------------------------------------
BOOL AWindow::ModifyIDCMP (unsigned long flags)
{
 return ::ModifyIDCMP(this, flags);
}
//----------------------------------------------------------------------------
void AWindow::MoveWindow (long dx, long dy)
{
 ::MoveWindow(this, dx, dy);
}
//----------------------------------------------------------------------------
void AWindow::MoveWindowInFrontOf (Window * behindWindow)
{
 ::MoveWindowInFrontOf(this, behindWindow);
}
//----------------------------------------------------------------------------
void AWindow::OffMenu (unsigned long menuNumber)
{
 ::OffMenu(this, menuNumber);
}
//----------------------------------------------------------------------------
void AWindow::OnMenu (unsigned long menuNumber)
{
 ::OnMenu(this, menuNumber);
}
//----------------------------------------------------------------------------
AWindow * AWindow::OpenWindow (NewWindow *newWindow)
{
 return (AWindow *) ::OpenWindow(newWindow);
}
//----------------------------------------------------------------------------
void * AWindow::operator new(size_t, NewWindow *newWindow)
{
 return AWindow::OpenWindow(newWindow);
}
//----------------------------------------------------------------------------
AWindow * AWindow::OpenWindowTagList (NewWindow *newWindow, TagItem * tagList)
{
 return (AWindow *) ::OpenWindowTagList(newWindow, tagList);
}
//----------------------------------------------------------------------------
void * AWindow::operator new(size_t, NewWindow *newWindow, TagItem *tagList)
{
 return AWindow::OpenWindowTagList(newWindow, tagList);
}
//----------------------------------------------------------------------------
AWindow * AWindow::OpenWindowTags (NewWindow *newWindow, unsigned long tag1Type,  ...)
{
 return (AWindow *) ::OpenWindowTagList(newWindow, (TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void * AWindow::operator new(size_t, NewWindow *newWindow, unsigned long tag1Type,  ...)
{
 return AWindow::OpenWindowTagList(newWindow, (TagItem *) &tag1Type);
}
//----------------------------------------------------------------------------
void AWindow::RefreshWindowFrame ()
{
 ::RefreshWindowFrame(this);
}
//----------------------------------------------------------------------------
LONG AWindow::RemoveDTObject (Object * o)
{
 return ::RemoveDTObject(this, o);
}
//----------------------------------------------------------------------------
UWORD AWindow::RemoveGList (Gadget * gadget, long numGad)
{
 return ::RemoveGList(this, gadget, numGad);
}
//----------------------------------------------------------------------------
UWORD AWindow::RemoveGadget (Gadget * gadget)
{
 return ::RemoveGadget(this, gadget);
}
//----------------------------------------------------------------------------
void AWindow::ReportMouse (long flag)
{
 ::ReportMouse(flag, this);
}
//----------------------------------------------------------------------------
BOOL AWindow::ResetMenuStrip (Menu * menu)
{
 return ::ResetMenuStrip(this, menu);
}
//----------------------------------------------------------------------------
void AWindow::ScrollWindowRaster (long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
 ::ScrollWindowRaster(this, dx, dy, xMin, yMin, xMax, yMax);
}
//----------------------------------------------------------------------------
BOOL AWindow::SetDMRequest (Requester * requester)
{
 return ::SetDMRequest(this, requester);
}
//----------------------------------------------------------------------------
BOOL AWindow::SetMenuStrip (Menu * menu)
{
 return ::SetMenuStrip(this, menu);
}
//----------------------------------------------------------------------------
LONG AWindow::SetMouseQueue (unsigned long queueLength)
{
 return ::SetMouseQueue(this, queueLength);
}
//----------------------------------------------------------------------------
void AWindow::SetPointer (UWORD * pointer, long height, long width, long xOffset, long yOffset)
{
 ::SetPointer(this, pointer, height, width, xOffset, yOffset);
}
//----------------------------------------------------------------------------
void AWindow::SetWindowPointer (unsigned long tag1,  ...)
{
 SetWindowPointerA((TagItem *) &tag1);
}
//----------------------------------------------------------------------------
void AWindow::SetWindowPointerA (TagItem * taglist)
{
 ::SetWindowPointerA(this, taglist);
}
//----------------------------------------------------------------------------
void AWindow::SetWindowTitles (UBYTE * windowTitle, UBYTE * screenTitle)
{
 ::SetWindowTitles(this, windowTitle, screenTitle);
}
//----------------------------------------------------------------------------
void AWindow::SizeWindow (long dx, long dy)
{
 ::SizeWindow(this, dx, dy);
}
//----------------------------------------------------------------------------
LONG AWindow::SysReqHandler (ULONG * idcmpPtr, long waitInput)
{
 return ::SysReqHandler(this, idcmpPtr, waitInput);
}
//----------------------------------------------------------------------------
AViewPort * AWindow::ViewPortAddress ()
{
 return (AViewPort *) ::ViewPortAddress(this);
}
//----------------------------------------------------------------------------
BOOL AWindow::WindowLimits (long widthMin, long heightMin, unsigned long widthMax, unsigned long heightMax)
{
 return ::WindowLimits(this, widthMin, heightMin, widthMax, heightMax);
}
//----------------------------------------------------------------------------
void AWindow::WindowToBack ()
{
 ::WindowToBack(this);
}
//----------------------------------------------------------------------------
void AWindow::WindowToFront ()
{
 ::WindowToFront(this);
}
//----------------------------------------------------------------------------
void AWindow::ZipWindow ()
{
 ::ZipWindow(this);
}

#endif
