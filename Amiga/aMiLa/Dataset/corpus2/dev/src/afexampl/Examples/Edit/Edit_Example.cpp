//////////////////////////////////////////////////////////////////////////////
// Edit Example
// 5.19.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/edit.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFEdit      name;
    AFEdit      address;
    AFEdit      phone;
    AFReqTools  rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Name button
    rt.EZRequest(name.m_text,"Ok");
    break;
  case 101:     // Address button
    rt.EZRequest(address.m_text,"Ok");
    break;
  case 102:     // Phone button
    rt.EZRequest(phone.m_text,"Ok");
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
    AFRastPort rp(&win);
    AFRect rect(10,10,410,310);

    win.Create(&theApp,&rect,"AFrame Edit Example");

    rp.TextOut(10,2,"Name",4);
    rect.SetRect(50,2,100,20);
    win.name.Create("Name",&win,&rect,100,20);

    rp.TextOut(10,22,"Address",7);
    rect.SetRect(50,22,100,42);
    win.address.Create("Address",&win,&rect,101,20);

    rp.TextOut(10,44,"Phone",5);
    rect.SetRect(50,44,100,64);
    win.phone.Create("Phone",&win,&rect,102,20);

    win.RefreshGadgets();

    theApp.RunApp();
}
