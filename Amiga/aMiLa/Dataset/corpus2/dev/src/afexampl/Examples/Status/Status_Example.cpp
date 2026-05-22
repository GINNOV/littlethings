//////////////////////////////////////////////////////////////////////////////
// Status Class Example
// 5.19.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/status.hpp"
#include "aframe:include/reqtools.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    ControlWindow();
    virtual void OnGadgetUp(LPIntuiMessage imess);
    virtual ULONG WindowFlags();

    AFStatus    status;
    AFButton    up;
    AFButton    down;

    short       value;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

ControlWindow::ControlWindow()
    :value(0)
{
}

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
    AFReqTools  rt;

    switch(((struct Gadget*)imess->IAddress)->GadgetID) {
    case 99:
        rt.EZRequest("Status Gadget Selected","Ok");
        break;
    case 100:
        if(++value>100)
            value=0;
        status.SetStatus(value);
        break;
    case 101:
        if(--value<0)
            value=100;
        status.SetStatus(value);
        break;
    default:
        AFWindow::OnGadgetUp(imess);
        break;
    }
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
    AFRect rect(10,10,310,110);

    win.Create(&theApp,&rect,"AFrame Status Example");

    rect.SetRect(0,0,98,30);
    win.status.Create(&win,&rect,99,3,2);

    rect.SetRect(100,0,150,30);
    win.up.Create("Increase",&win,&rect,100);

    rect.SetRect(152,0,202,30);
    win.down.Create("Decrease",&win,&rect,101);

    win.RefreshGadgets();

    theApp.RunApp();
}
