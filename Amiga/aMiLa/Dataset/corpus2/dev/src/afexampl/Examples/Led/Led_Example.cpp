//////////////////////////////////////////////////////////////////////////////
// Led Class Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/led.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    ControlWindow();
    virtual void OnGadgetUp(LPIntuiMessage imess);
    virtual void OnNewSize(LPIntuiMessage imess);
    virtual ULONG WindowFlags();

    AFLed       led;
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
    switch(((struct Gadget*)imess->IAddress)->GadgetID) {
    case 100:
        if(++value>99)
            value=0;
        led.m_Global.DigitPairs[0]=value; //set value for digit pairs
        led.Create(led.m_Global.Window, &led.m_Global.rect);
        break;
    case 101:
        if(--value<0)
            value=99;
        led.m_Global.DigitPairs[0]=value; //set value for digit pairs
        led.Create(led.m_Global.Window, &led.m_Global.rect);
        break;
    default:
        AFWindow::OnGadgetUp(imess);
        break;
    }
}

void ControlWindow::OnNewSize(LPIntuiMessage imess)
{
    led.RefreshImage();
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
    AFRect rect(10,10,410,310);

    win.Create(&theApp,&rect,"AFrame Led Example");

    rect.SetRect(0,0,100,100);
    win.led.Create(&win,&rect);

    rect.SetRect(100,0,150,30);
    win.up.Create("Increase",&win,&rect,100);

    rect.SetRect(152,0,202,30);
    win.down.Create("Decrease",&win,&rect,101);

    win.RefreshGadgets();

    theApp.RunApp();
}
