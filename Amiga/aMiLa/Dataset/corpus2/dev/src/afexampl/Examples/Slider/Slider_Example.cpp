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
#include "aframe:include/slider.hpp"

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
    AFSlider    slider;
    AFButton    up;
    AFButton    down;

    ULONG       value;
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
    case 100:   // up gadget
        if(++value>99)
            value=0;
        led.SetDigits(0,value);
        slider.SetPos(value);
        break;
    case 101:   // down gadget
        if(--value<0)
            value=99;
        led.SetDigits(0,value);
        slider.SetPos(value);
        break;
    case 102:   // slider gadget
        led.SetDigits(0,(value=slider.CurrentPos());
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
    win.led.Create(&win,&rect,99);

    rect.SetRect(100,0,150,30);
    win.up.Create("Increase",&win,&rect,100);

    rect.SetRect(152,0,202,30);
    win.down.Create("Decrease",&win,&rect,101);

    rect.SetRect(204,0,234,100);
    win.slider.Create(&win,&rect,(ULONG)102,(UWORD)NULL,100,99,1);


    win.RefreshGadgets();

    theApp.RunApp();
}
