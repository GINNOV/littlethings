/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AAppWindow wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AppWindow_H
#define ASAP_AppWindow_H

#include <New.h>

extern "C"
{
 #include <Proto/WB.h>
}

class AAppWindow : public AppWindow
{
 public:
 inline static AAppWindow * AddAppWindow(unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, Tag tag1,  ...);
 inline void * operator new(size_t, unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, Tag tag1,  ...);
 inline static AAppWindow * AddAppWindowA(unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, struct TagItem * taglist);
 inline void * operator new(size_t, unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, struct TagItem * taglist);
 inline BOOL RemoveAppWindow();
 inline void operator delete (void *);
};
//----------------------------------------------------------------------------
AAppWindow * AAppWindow::AddAppWindow (unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, Tag tag1,  ...)
{
 return AAppWindow::AddAppWindowA(id, userdata, window, msgport, (TagItem *) tag1);
}
//----------------------------------------------------------------------------
void * AAppWindow::operator new (size_t, unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, Tag tag1,  ...)
{
 return AAppWindow::AddAppWindowA(id, userdata, window, msgport, (TagItem *) tag1);
}
//----------------------------------------------------------------------------
AAppWindow * AAppWindow::AddAppWindowA (unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, struct TagItem * taglist)
{
 return (AAppWindow *) ::AddAppWindowA(id, userdata, window, msgport, taglist);
}
//----------------------------------------------------------------------------
void * AAppWindow::operator new (size_t, unsigned long id, unsigned long userdata, struct Window * window, struct MsgPort * msgport, struct TagItem * taglist)
{
 return AAppWindow::AddAppWindowA(id, userdata, window, msgport, taglist);
}
//----------------------------------------------------------------------------
BOOL AAppWindow::RemoveAppWindow ()
{
 return ::RemoveAppWindow(this);
}
//----------------------------------------------------------------------------
void AAppWindow::operator delete (void *appWindow)
{
 ((AAppWindow *) appWindow)->RemoveAppWindow();
}

#endif
