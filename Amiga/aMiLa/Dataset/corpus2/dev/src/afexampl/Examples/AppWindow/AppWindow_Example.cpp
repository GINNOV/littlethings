//////////////////////////////////////////////////////////////////////////////
// AppWindow Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/appwindow.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include <workbench/startup.h>
#include <workbench/workbench.h>

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFAppWindow
{
public:
    ControlWindow();
    virtual void OnAppWindow(LPAppMessage amess);

    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

ControlWindow::ControlWindow()
{
    rt.EZRequest("Drop a file(s) on me","Ok");
}

void ControlWindow::OnAppWindow(LPAppMessage amess)
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
    AFRect rect(10,10,100,100);

    win.Create(&theApp,&rect,1l);
    win.SetWindowTitles((UBYTE*)"AFrame Window Example",(UBYTE*)NULL);

    theApp.RunApp();
}
