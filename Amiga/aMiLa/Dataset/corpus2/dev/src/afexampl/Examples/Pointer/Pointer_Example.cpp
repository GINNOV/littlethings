//////////////////////////////////////////////////////////////////////////////
// Pointer Example
// 5.19.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/pointer.hpp"
#include "aframe:include/reqtools.hpp"

static UWORD __chip Block_sdata[] =   // sample pointer data
{
    0x0000, 0x0000,		/* reserved, must be NULL */

    0x0000, 0x0100,
    0x0100, 0x0280,
    0x0380, 0x0440,
    0x0100, 0x0280,
    0x0100, 0x0ee0,
    0x0000, 0x2828,
    0x2008, 0x5834,
    0x783c, 0x8002,
    0x2008, 0x5834,
    0x0000, 0x2828,
    0x0100, 0x0ee0,
    0x0100, 0x0280,
    0x0380, 0x0440,
    0x0100, 0x0280,
    0x0000, 0x0100,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,
    0x0000, 0x0000,

    0x0000, 0x0000,		/* reserved, must be NULL */
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    virtual void OnCreate();

    AFPointer pointer;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnCreate()
{
    rt.EZRequest("Setting Pointer","Ok");
    pointer.SetPointer(this, Block_sdata, 32l, 16l, -8l, -7l);
}

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,100,100);

    win.Create(&theApp,&rect,"AFrame Pointer Example");

    theApp.RunApp();
}
