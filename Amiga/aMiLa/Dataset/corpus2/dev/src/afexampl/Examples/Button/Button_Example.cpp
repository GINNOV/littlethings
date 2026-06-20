//////////////////////////////////////////////////////////////////////////////
// Button Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/reqtools.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFButton button;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Test button
    rt.EZRequest("Test button selected","Ok");
    rt.FileRequest();
    printf("File Selected: %s\n",rt.filename);
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

    win.Create(&theApp,&rect,"AFrame Button Example");

    rect.SetRect(10,10,50,50);
    win.button.Create("Button",&win,&rect,100);

    win.RefreshGadgets();

    theApp.RunApp();
}
