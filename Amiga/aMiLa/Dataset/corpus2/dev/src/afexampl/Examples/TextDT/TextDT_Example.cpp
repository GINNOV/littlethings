//////////////////////////////////////////////////////////////////////////////
// AudioDT Example
// 6.16.96 Deryk Robosson
// The TextDT supports word selection as well as up/down scrolling w/mouse =)

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/textdt.hpp"

#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <utility/tagitem.h>
#include <proto/utility.h>
#include <clib/utility_protos.h>
#include <pragmas/utility_pragmas.h>

//////////////////////////////////////////////////////////////////////////////
// DisplayWindow Class Definition

class DisplayWindow : public AFWindow
{
    virtual void OnCloseWindow(LPIntuiMessage imess);
    virtual void OnGadgetUp(LPIntuiMessage imess);
    virtual void OnIDCMPUpdate(LPIntuiMessage imess);
    virtual void DestroyWindow();
    virtual ULONG WindowFlags();
    virtual ULONG WindowIDCMP();
};

void DisplayWindow::OnCloseWindow(LPIntuiMessage imess) // time to leave!! ;)
{
    DisplayWindow::DestroyWindow();
}

void DisplayWindow::DestroyWindow()
{
    AFWindow::DestroyWindow();
    delete this;
}
ULONG DisplayWindow::WindowFlags()
{
    return (AFWindow::WindowFlags() | WFLG_GIMMEZEROZERO);
}

ULONG DisplayWindow::WindowIDCMP()  // We need the IDCMP_IDCMPUPDATE for the TextDT Class
{                                   // if we are to recieve messages for it =)
    return (AFWindow::WindowIDCMP() | IDCMP_IDCMPUPDATE | IDCMP_GADGETDOWN);
}

void DisplayWindow::OnGadgetUp(LPIntuiMessage imess)
{
    switch(((struct Gadget*)imess->IAddress)->GadgetID) {

    case 100:   // TextDT Object
//        ::RefreshGadgets(m_pWindow->FirstGadget,m_pWindow,(struct Requester*)NULL);
        // Do whatever else here 8)
        break;
    default:
        break;
    }
}

void DisplayWindow::OnIDCMPUpdate(LPIntuiMessage imess)
{
    AFReqTools rt;
    char *buffer;
    struct TagItem  *attrs;
    struct TagItem  *tag;

    attrs=(struct TagItem*)imess->IAddress;

    if(tag=FindTagItem(DTA_Busy, attrs)) { // Check for busy attribute
        if(tag->ti_Data)
            SetWindowPointer(m_pWindow,WA_BusyPointer,TRUE,WA_PointerDelay,TRUE,TAG_DONE);
        else
            SetWindowPointer(m_pWindow,WA_Pointer,NULL,TAG_DONE);
    }
/*    if(tag=FindTagItem(TDTA_WordSelect, attrs)) { // Check for a word selected
        if(tag->ti_Data) {
            sprintf(buffer,"%s",tag->ti_Data);
            rt.EZRequest(buffer,"Ok");
        }
    }*/
    if(tag=FindTagItem(DTA_Sync,attrs)) // Check for a resync request
        ::RefreshGadgets(m_pWindow->FirstGadget,m_pWindow,(struct Requester*)NULL);
}

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFButton    load;
    AFReqTools  rt;
    AFTextDT    text;
    DisplayWindow *display;
};

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Implementation routines

void ControlWindow::OnGadgetUp(LPIntuiMessage imess)
{
  AFRect rect;

  switch(((struct Gadget*)imess->IAddress)->GadgetID) {

  case 100:     // Load button
    if(!(rt.FileRequest())) {
        rt.EZRequest("No dir/filename was entered","Ok");
        break;
    }
    if(!(text.LoadText((char*)rt.GetFileName(),(struct Screen*)NULL))) {
        rt.EZRequest("Load File Failed","Ok");
        break;
    }
    display=new DisplayWindow;  // Create a new displaywindow
    text.m_dtGlobal.dtWindow=display;   // Set the TextDT window equal to our new window
    rect.SetRect(0,0,640,440);          // Set our new window size and position
    display->Create(m_papp,&rect);      // Create new window
    display->SetWindowTitles((UBYTE*)rt.GetFileName(),(UBYTE*)NULL);    // Set window title same as filename
    rect.SetRect(0,0,640,440);          // Set size and position of TextDT
    text.AddObject(display,&rect, 100); // Add object to our new window  with the gadid of 100, 
                                        // we could use this in a OnGadgetUp/Down for our new displaywindow
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

    win.Create(&theApp,&rect,"AFrame TextDT Example");

    rect.SetRect(10,10,50,50);
    win.load.Create("Load",&win,&rect,100);

    win.RefreshGadgets();

    theApp.RunApp();
}
