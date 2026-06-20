//////////////////////////////////////////////////////////////////////////////
// AppWindow.cpp
//
// Deryk Robosson
// May 9, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/AppWindow.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFAppWindow::AFAppWindow()
    :WorkbenchBase(NULL),
    IconBase(NULL),
    aw(NULL)
{
    if(!WorkbenchBase) {
        if(!(WorkbenchBase=(struct WorkbenchBase*)OpenLibrary((UBYTE*)"workbench.library",(ULONG)36)))
            printf("failed to open workbench.library\n");
    }

    if(!IconBase) {
        if(!(IconBase=(struct IconBase*)OpenLibrary((UBYTE*)"icon.library",(ULONG)36)))
            printf("failed to open icon.library\n");
    }
}

AFAppWindow::~AFAppWindow()
{
    if(aw) {
        RemoveAppWindow(aw);
        aw=NULL;
    }

    if(WorkbenchBase) {
        CloseLibrary((struct Library*)WorkbenchBase);
        WorkbenchBase=NULL;
    }
    if(IconBase) {
        CloseLibrary((struct Library*)IconBase);
        IconBase=NULL;
    }
}

void AFAppWindow::Create(AFAmigaApp *theapp, AFRect *rect, ULONG id, LPMsgPort appmsgport)
{
    AFWindow::Create(theapp, rect);

    if(!(aw = (struct AppWindow*)AddAppWindow((ULONG)id, (ULONG)0, m_pWindow, appmsgport, NULL)))
        printf("AppWindow Failed!\n");
}

void AFAppWindow::Create(AFAmigaApp *theapp, AFRect *rect, ULONG id)
{
    Create(theapp, rect, id, theapp->appmsgport);
}

void AFAppWindow::OnCloseWindow(LPIntuiMessage imess)
{
    if(aw) {
        RemoveAppWindow(aw);
        aw=NULL;
    }
    AFWindow::DestroyWindow();
}
