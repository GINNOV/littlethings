//////////////////////////////////////////////////////////////////////////////
// Tab Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/tab.hpp"
#include "aframe:include/reqtools.hpp"

TabLabel tablabels[] = {
	{ "First", -1, -1, -1, -1 },
	{ "Second",  -1, -1, -1, -1 },
	{ "Third",   -1, -1, -1, -1 },
    { "Fourth",   -1, -1, -1, -1 },
	NULL
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFTab tab;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Test tab gadget
    switch(tab.GetCurrentTab()) {
        case 0:
            rt.EZRequest("First","Ok");
            break;
        case 1:
            rt.EZRequest("Second","Ok");
            break;
        case 2:
             rt.EZRequest("Third","Ok");
            break;
        case 3:
            rt.EZRequest("Fourth","Ok");
            break;
        default:
            break;
    }
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

    win.Create(&theApp,&rect,"AFrame Tab Example");

    rect.SetRect(2,164,250,194);
    win.tab.Create(&win, &rect, tablabels, 100);

    win.RefreshGadgets();

    theApp.RunApp();
}
