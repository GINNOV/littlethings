//////////////////////////////////////////////////////////////////////////////
// box.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/box.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFBox::~AFBox()
{
  DestroyObject();
}

void AFBox::Create(AFWindow* pwindow, AFRect *rect, ULONG id, UBYTE penColor, UBYTE Outline)
{
  // Create the gadget
  AFGadget::Create(pwindow,rect,id);

  // Set Pens
  m_penColor = penColor;

  // Build Images
  m_Box.NextImage=NULL;
  BuildImages(); 

  // Attach IntuiText Struct and Border Struct to gadget Struct
  m_pgadget->GadgetRender = &m_Box;
  m_pgadget->Flags = GFLG_GADGIMAGE|GFLG_GADGHNONE;
}

void AFBox::BuildImages()
{
  // Fill Done Image Struct
  m_Box.LeftEdge = m_Box.TopEdge = 0;
  m_Box.Width=m_pgadget->Width;
  m_Box.Height=m_pgadget->Height;
  m_Box.Depth=4;
  m_Box.ImageData=NULL;
  m_Box.PlanePick=NULL;
  m_Box.PlaneOnOff=m_penColor;
}

void AFBox::SetColor(UBYTE penColor)
{
  m_penColor=penColor;
  m_Box.PlaneOnOff=m_penColor;
  RefreshGList((LPGadget)m_pgadget,m_pwindow->m_pWindow,NULL,1);
}
