//////////////////////////////////////////////////////////////////////////////
// panel.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/panel.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFPanel::AFPanel()
{
}

AFPanel::~AFPanel()
{
  DestroyObject();
}

void AFPanel::DestroyObject()
{
  AFGadget::DestroyObject();
}

void
AFPanel::SetText(char* text)
{
	m_text=text;
	m_IntuiText.IText = (UBYTE*)m_text.data();
	EraseGadget();
	DrawGadget();
}

void AFPanel::Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id, bevel beveltype)
{
  WORD w,h;

  // Create the gadget
  AFGadget::Create(pwindow,rect,id);

  // Create the border to be used
  border.SetBorder(*rect,2,1);

  // Create string for the text
  m_text = text;

/*  if(beveltype!=bevelNone) {
	// Fill in coordinates to draw border
  	w=rect->Width()-1;
  	h=rect->Height()-1;
  	m_xyshine[0]=m_xyshine[2]=m_xyshine[3]=m_xyshine[5]=0;
  	m_xyshine[1]=h;
  	m_xyshine[4]=w;

  	m_xyshadow[0]=1;
  	m_xyshadow[1]=m_xyshadow[3]=h;
  	m_xyshadow[2]=m_xyshadow[4]=w;
  	m_xyshadow[5]=0;

  	// Fill in Border Structure
  	m_gborder.LeftEdge = m_gborder2.LeftEdge = 0;
  	m_gborder.TopEdge = m_gborder2.TopEdge = 0;
  	if(beveltype) {
    	m_gborder.FrontPen = 2;
    	m_gborder2.FrontPen = 1;
  	} else {
    	m_gborder.FrontPen = 1;
    	m_gborder2.FrontPen = 2;
  	}
  	m_gborder.BackPen = m_gborder2.BackPen = 0;
  	m_gborder.DrawMode = m_gborder2.DrawMode = JAM1;
  	m_gborder.Count = m_gborder2.Count = 3;
  	m_gborder.XY = m_xyshine;
  	m_gborder2.XY = m_xyshadow; 
  	m_gborder.NextBorder = &m_gborder2;
  	m_gborder2.NextBorder = NULL;
  }*/

  // Fill IntuiText Structure
  m_IntuiText.FrontPen = 1;
  m_IntuiText.DrawMode = JAM1;
  m_IntuiText.LeftEdge = 5;
  m_IntuiText.TopEdge = 5;
  m_IntuiText.ITextFont = NULL;
  m_IntuiText.IText = (UBYTE*)m_text.data();
  m_IntuiText.NextText = NULL;

  // Attach IntuiText Struct and Border Struct to gadget Struct
  m_pgadget->GadgetText = &m_IntuiText;

  if(beveltype!=bevelNone)
	m_pgadget->GadgetRender = border.border(); //&m_gborder;
  else
    m_pgadget->GadgetRender = NULL;

  m_pgadget->Flags = GFLG_GADGHNONE;
}

void
AFPanel::GetDisplayRect(AFRect* rect)
{
	rect->SetRect(m_pgadget->LeftEdge+1,m_pgadget->TopEdge+1,
			m_pgadget->LeftEdge+m_pgadget->Width-2,m_pgadget->TopEdge+m_pgadget->Height-2);
}
