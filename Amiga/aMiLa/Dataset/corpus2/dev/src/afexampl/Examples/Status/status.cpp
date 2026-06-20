//////////////////////////////////////////////////////////////////////////////
// status.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/status.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFStatus::AFStatus()
{
  m_text=NULL;
  m_percent=0;
}

AFStatus::~AFStatus()
{
  DestroyObject();
}

void AFStatus::DestroyObject()
{
  AFGadget::DestroyObject();
  if(m_text) {
    delete m_text;
    m_text=NULL;
  }
}

void AFStatus::Create(AFWindow* pwindow, AFRect *rect, ULONG id, UBYTE penDone, UBYTE penToGo)
{
  AFRastPort rp(pwindow);
  char string[10];

  // Create the gadget
  AFGadget::Create(pwindow,rect,id);

  // Create string for the text
  sprintf(string,"%d%%",m_percent);
  m_text = new char[strlen(string)+1];
  strcpy(m_text,string);

  // Set Pens
  m_penDone = penDone;
  m_penToGo = penToGo;

  // Build Images
  m_Done.NextImage=&m_ToGo;
  m_ToGo.NextImage=NULL;
  BuildImages(); 

  // Fill IntuiText Structure
  m_IntuiText.FrontPen = 1;
  m_IntuiText.DrawMode = JAM1;
  m_IntuiText.LeftEdge = 5;
  m_IntuiText.TopEdge = 5;
  m_IntuiText.ITextFont = NULL;
  m_IntuiText.LeftEdge = (m_pgadget->Width-rp.TextLength(m_text,strlen(m_text)))/2;
  m_IntuiText.IText = (UBYTE*)m_text;
  m_IntuiText.NextText = NULL;

  // Attach IntuiText Struct and Border Struct to gadget Struct
  m_pgadget->GadgetText = &m_IntuiText;
  m_pgadget->GadgetRender = &m_Done;
  m_pgadget->Flags = GFLG_GADGIMAGE|GFLG_GADGHNONE;
}

void AFStatus::BuildImages()
{
  // Fill Done Image Struct
  m_Done.LeftEdge = m_Done.TopEdge = 0;
  m_Done.Width=m_percent*m_pgadget->Width/100;
  m_Done.Height=m_pgadget->Height;
  m_Done.Depth=4;
  m_Done.ImageData=NULL;
  m_Done.PlanePick=NULL;
  m_Done.PlaneOnOff=m_penDone;

  // Fill ToGo Image Struct
  m_ToGo.TopEdge = 0;
  m_ToGo.LeftEdge=m_percent*m_pgadget->Width/100;
  m_ToGo.Width=m_pgadget->Width-m_ToGo.LeftEdge;
  m_ToGo.Height=m_pgadget->Height;
  m_ToGo.Depth=4;
  m_ToGo.ImageData=NULL;
  m_ToGo.PlanePick=NULL;
  m_ToGo.PlaneOnOff=m_penToGo;
}

void AFStatus::SetStatus(int percent)
{
  AFRastPort rp(m_pwindow);
  char string[10];
  
  // Rebuild Images
  m_percent=percent;
  BuildImages();

  // Build Text String
  m_IntuiText.IText = NULL;
  if(m_text) delete m_text;
  sprintf(string,"%d%%",m_percent);
  m_text = new char[strlen(string)+1];
  strcpy(m_text,string);
  m_IntuiText.LeftEdge = (m_pgadget->Width-rp.TextLength(m_text,strlen(m_text)))/2;
  m_IntuiText.IText = (UBYTE*)m_text;

  // Update the gadget
  RefreshGList((struct Gadget*)m_pgadget, m_pwindow->m_pWindow, (struct Requester*)NULL, 1);
}
