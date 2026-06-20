//////////////////////////////////////////////////////////////////////////////
// ColorPick Example
// 5.20.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/colorpick.hpp"
#include "aframe:include/panel.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);
    virtual ULONG WindowFlags();

    AFColorPick cpick;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // ColorPick button
//    AFWindow::OnGadgetUp(imess);   // Need to call default function because
                                   // color pick is multi gadget control.
    // one could set pencolor here ;)
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
    AFRect rect(10,10,400,300);

    win.Create(&theApp,&rect,"AFrame ColorPick Example");

    rect.SetRect(10,10,110,110);
    win.cpick.Create(&win, &rect, (ULONG)100, AFColorPick::bevelUp, 16, 4, 1);

    win.RefreshGadgets();

    theApp.RunApp();
}
