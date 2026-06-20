//////////////////////////////////////////////////////////////////////////////
// MsgPrompt Example
// 5.19.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/msgprompt.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow
{
public:
    AFMsgPrompt mp;
    AFReqTools rt;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFAmigaApp theApp;
    ControlWindow win;
    AFRect rect(10,10,100,100);

    win.Create(&theApp,&rect,"AFrame MsgPrompt Example");

    win.mp.Prompt(&win,"The is a simple prompt","MsgPrompt Example",NULL);

    theApp.RunApp();
}
