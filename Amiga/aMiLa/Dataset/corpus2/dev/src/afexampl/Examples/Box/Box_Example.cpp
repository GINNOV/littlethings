//////////////////////////////////////////////////////////////////////////////
// Box Example
// 5.19.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/box.hpp"
#include "aframe:include/reqtools.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFBox       box;
    AFReqTools  rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Box button
    rt.EZRequest("Box was selected!","Ok");
    break;
  default:
    AFWindow::OnGadgetUp(imess);
    break;
  }
}

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,410,310);

    win.Create(&theApp,&rect,"AFrame Box Example");

    rect.SetRect(10,10,50,50);
    win.box.Create(&win,&rect,100,3,BOX_SOLID);

    win.RefreshGadgets();

    theApp.RunApp();
}
