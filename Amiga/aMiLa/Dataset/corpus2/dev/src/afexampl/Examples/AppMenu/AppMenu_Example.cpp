//////////////////////////////////////////////////////////////////////////////
// AppMenu Example
// 5.18.95 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/appmenu.hpp"
#include "aframe:include/reqtools.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnAppMenu(LPAppMessage amess);

    virtual ULONG WindowFlags();

    AFAppMenu   appmenu;

};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnAppMenu(LPAppMessage amess)
{
    AFReqTools rt;

    if(amess->am_ID == 1)
        rt.EZRequest("AFrame v.02\n\n©1995,1996 Synthetic Input\nJeffry Worth\nDeryk Robosson","Ok");
}

ULONG ControlWindow::WindowFlags()
{
    return (AFWindow::WindowFlags() | WFLG_GIMMEZEROZERO);
}

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,100,30);

    win.Create(&theApp,&rect,"AFrame AppMenu Example");

    win.appmenu.AddItem(&win, (UBYTE*)"About AFrame", (ULONG)1, theApp.appmsgport);

    win.RefreshGadgets();

    theApp.RunApp();
}
