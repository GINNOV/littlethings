//////////////////////////////////////////////////////////////////////////////
// AppIcon.cpp
//
// Deryk Robosson
// May 8, 1996
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/AppIcon.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFAppIcon::AFAppIcon()
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

AFAppIcon::~AFAppIcon()
{
    if(ai)
        RemoveAppIcon(ai);
    if(dob)
        FreeDiskObject(dob);
    if(WorkbenchBase)
        CloseLibrary((struct Library*)WorkbenchBase);
    if(IconBase)
        CloseLibrary((struct Library*)IconBase);
}

void AFAppIcon::Create(LPImage render, LPImage select, int id, char *appname, LPMsgPort appmsgport)
{
    if(dob=GetDiskObject(NULL)) {
        dob->do_Gadget.Width = render->Width;
        dob->do_Gadget.Height = render->Height;
        dob->do_Gadget.GadgetRender = render;
        if(select == NULL)
            dob->do_Gadget.SelectRender = NULL;
        else dob->do_Gadget.SelectRender = select;
    } else printf("failed to getdiskobject\n");

    if(!(ai = (struct AppIcon*)AddAppIcon((ULONG)id, (ULONG)0, (UBYTE*)appname, appmsgport, NULL, dob, NULL)))
        printf("AppIcon Failed!\n");

}

void AFAppIcon::Create(AFAmigaApp *theapp, LPImage render, LPImage select, int id, char *iconname)
{
    Create(render, select, id, iconname, theapp->appmsgport);
}
