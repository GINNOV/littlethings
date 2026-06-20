//////////////////////////////////////////////////////////////////////////////
// AppIcon.cpp

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/appicon.hpp"

#include <workbench/startup.h>
#include <workbench/workbench.h>

extern struct Image About_image;

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnAppIcon(LPAppMessage amess);

    AFAppIcon appicon;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnAppIcon(LPAppMessage amess)
{
    struct WBArg    *argptr;
    int i;

    argptr = amess->am_ArgList;

    for(i=0;i<amess->am_NumArgs;i++) {
        printf("Items: %s\n",argptr->wa_Name);
        argptr++;
    }
}

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,410,310);

    win.Create(&theApp,&rect,"AFrame AppIcon Example");

    win.appicon.Create(&theApp, &About_image, NULL, 1, (char*)"AFrame AppIcon");
    win.rt.EZRequest("Drop a file(s) on me","Ok");

    theApp.RunApp();
}
