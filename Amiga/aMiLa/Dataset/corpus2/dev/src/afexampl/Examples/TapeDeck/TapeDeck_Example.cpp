//////////////////////////////////////////////////////////////////////////////
// TapeDeck Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/tapedeck.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFTapeDeck td;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  switch(((struct Gadget*)imess->IAddress)->GadgetID) {
    case 100:
        switch(td.GetCurrentButton()) {
            case BUT_PLAY:
                rt.EZRequest("Play","Ok");
                break;
            case BUT_STOP:
                rt.EZRequest("Stop","Ok");
                break;
            case BUT_FORWARD:
                rt.EZRequest("Forward","Ok");
                break;
            case BUT_REWIND:
                rt.EZRequest("Rewind","Ok");
                break;
            case BUT_PAUSE:
                rt.EZRequest("Pause","Ok");
                break;
            default:
                break;
        }
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
    AFRect rect(10,10,200,200);

    win.Create(&theApp,&rect,"AFrame TapeDeck Example");

    rect.SetRect(2,132,50,162);
    win.td.Create(&win,&rect,100l);

    win.RefreshGadgets();

    theApp.RunApp();
}
