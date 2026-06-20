//////////////////////////////////////////////////////////////////////////////
// FrameIClass Class Example
// 6.2.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/frameiclass.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnNewSize(LPIntuiMessage imess);
    virtual ULONG WindowFlags();

    AFFrameIClass frame1;
    AFFrameIClass frame2;
    AFFrameIClass frame3;
    AFFrameIClass frame4;
    AFFrameIClass frame5;
    AFFrameIClass frame6;
    AFFrameIClass frame7;
    AFFrameIClass frame8;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnNewSize(LPIntuiMessage imess)
{
    frame1.RefreshImage();
    frame2.RefreshImage();
    frame3.RefreshImage();
    frame4.RefreshImage();
    frame5.RefreshImage();
    frame6.RefreshImage();
    frame7.RefreshImage();
    frame8.RefreshImage();
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

    win.Create(&theApp,&rect,"AFrame Frames Example");

    rect.SetRect(0,0,30,20);
    win.frame1.Create(&win,&rect,AFFrameIClass::recessedDown, AFFrameIClass::defaultFrame);

    rect.SetRect(32,0,64,20);
    win.frame2.Create(&win,&rect,AFFrameIClass::recessedDown, AFFrameIClass::buttonFrame);

    rect.SetRect(66,0,96,20);
    win.frame3.Create(&win,&rect,AFFrameIClass::recessedDown, AFFrameIClass::ridgeFrame);

    rect.SetRect(98,0,128,20);
    win.frame4.Create(&win,&rect,AFFrameIClass::recessedDown, AFFrameIClass::dropboxFrame);

    rect.SetRect(0,22,30,44);
    win.frame5.Create(&win,&rect,AFFrameIClass::recessedUp, AFFrameIClass::defaultFrame);

    rect.SetRect(32,22,64,44);
    win.frame6.Create(&win,&rect,AFFrameIClass::recessedUp, AFFrameIClass::buttonFrame);

    rect.SetRect(66,22,96,44);
    win.frame7.Create(&win,&rect,AFFrameIClass::recessedUp, AFFrameIClass::ridgeFrame);

    rect.SetRect(98,22,128,44);
    win.frame8.Create(&win,&rect,AFFrameIClass::recessedUp, AFFrameIClass::dropboxFrame);

    win.RefreshGadgets();

    theApp.RunApp();
}
