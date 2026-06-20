//////////////////////////////////////////////////////////////////////////////
// Button Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/imagebutton.hpp"
#include "aframe:include/reqtools.hpp"
#include "resources/brushes_select.res"
#include "resources/brushes_render.res"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFImageButton button;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Test button
    rt.EZRequest("ImageButton selected!","Ok");
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

    win.Create(&theApp,&rect,"AFrame ImageButton Example");

    rect.SetRect(10,10,50,50);
    win.button.Create(&win,&rect,100, &about_render_image, &about_select_image);

    win.RefreshGadgets();

    theApp.RunApp();
}
