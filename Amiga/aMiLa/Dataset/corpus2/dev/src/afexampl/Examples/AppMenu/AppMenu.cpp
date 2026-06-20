//////////////////////////////////////////////////////////////////////////////
// AppMenu.cpp
//
// Deryk Robosson
// May 9, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/AppMenu.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFAppMenu::AFAppMenu()
    :WorkbenchBase(NULL),
    IconBase(NULL)
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

AFAppMenu::~AFAppMenu()
{
    if(am) {
        RemoveAppMenuItem(am);
        am=NULL;
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

BOOL AFAppMenu::AddItem(AFWindow *window, UBYTE* name, ULONG menuid, LPMsgPort appmsgport)
{
    m_menuid=menuid;
    m_itemname=name;
    m_pwindow=window;

    if(am = (struct AppMenuItem*)AddAppMenuItem(m_menuid, (ULONG)0, m_itemname, appmsgport, NULL))
        return TRUE;
    else return FALSE;
}

void AFAppMenu::RemoveItem()
{
    RemoveAppMenuItem(am);
    am=NULL;
}
