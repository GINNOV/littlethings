//////////////////////////////////////////////////////////////////////////////
// AudioDT Example
// 6.16.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/amigaapp.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/reqtools.hpp"
#include "aframe:include/audiodt.hpp"

//////////////////////////////////////////////////////////////////////////////
// ControlWindow Class Definition

class ControlWindow : public AFWindow

{
public:
    virtual void OnGadgetUp(LPIntuiMessage imess);

    AFButton    load;
    AFButton    play;
    AFReqTools  rt;
    AFAudioDT   audio;
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
    if(!(audio.LoadSample((char*)rt.GetFileName()))) {
        rt.EZRequest("Load File Failed","Ok");
        break;
    }
    rect.SetRect(94,10,134,50);
    audio.AddObject(this,&rect,200);
    break;
  case 101: // Play Button
    if(!(audio.PlaySample()))
        rt.EZRequest("Play Failed/No Sample Loaded","Ok");
    break;
  case 200: // Added DataType Gadget (see line 48)
    rt.EZRequest("Audio DataType!","Ok");
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

    win.Create(&theApp,&rect,"AFrame AudioDT Example");

    rect.SetRect(10,10,50,50);
    win.load.Create("Load",&win,&rect,100);

    rect.SetRect(52,10,92,50);
    win.play.Create("Play",&win,&rect,101);

    win.RefreshGadgets();

    theApp.RunApp();
}
