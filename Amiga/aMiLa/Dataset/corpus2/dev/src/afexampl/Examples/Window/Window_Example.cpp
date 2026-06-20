//////////////////////////////////////////////////////////////////////////////
// Window Example
// 5.18.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    ControlWindow();
    virtual void OnCreate();
    virtual void OnCloseWindow(LPIntuiMessage imess);
    virtual void OnNewSize(LPIntuiMessage imess);
    virtual ULONG WindowFlags();
    virtual ULONG WindowIDCMP();

    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

ControlWindow::ControlWindow()
{
    rt.EZRequest("AFWindow::AFWindow","Ok");
}

void ControlWindow::OnCloseWindow(LPIntuiMessage imess)
{
    rt.EZRequest("AFWindow::OnCloseWindow","Ok");
    AFWindow::DestroyWindow();
}

void ControlWindow::OnCreate()
{
    rt.EZRequest("AFWindow::OnCreate","Ok");
}

void ControlWindow::OnNewSize(LPIntuiMessage imess)
{
    rt.EZRequest("AFWindow::OnNewSize","Ok");
}

ULONG ControlWindow::WindowFlags()
{
    return (AFWindow::WindowFlags() | WFLG_GIMMEZEROZERO);
}

ULONG ControlWindow::WindowIDCMP()
{
	return (AFWindow::WindowIDCMP() | IDCMP_IDCMPUPDATE);
}

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,100,100);

    win.Create(&theApp,&rect,"AFrame Window Example");

    theApp.RunApp();
}
