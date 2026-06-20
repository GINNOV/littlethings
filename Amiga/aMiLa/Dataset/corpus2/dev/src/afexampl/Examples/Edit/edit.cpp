//////////////////////////////////////////////////////////////////////////////
// edit.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/edit.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFEdit::AFEdit()
{
  m_text=NULL;
}

AFEdit::~AFEdit()
{
  DestroyObject();
}

void AFEdit::DestroyObject()
{

  AFGadget::DestroyObject();
  
  if(m_text) {
    delete m_text;
    m_text=NULL;
  }
  if(m_pbuffer) {
    delete m_pbuffer;
    m_pbuffer=NULL;
  }
  if(m_pundobuffer) {
    delete m_pundobuffer;
    m_pundobuffer=NULL;
  }
}

void AFEdit::Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id, int maxlen)
{
  AFRect grect;
  WORD w,h;

  // Setup the rect for the actual strgadget
  grect.SetRect(rect->TopLeft()->m_x+2,rect->TopLeft()->m_y+2,
                rect->BottomRight()->m_x-2,rect->BottomRight()->m_y-2);

  m_maxlen = maxlen;

  // Create buffers for the edit control
  m_pbuffer = new char[m_maxlen+1];
  m_pundobuffer = new char[m_maxlen+1];
  m_pbuffer[0]=m_pundobuffer[0]=NULL;
  
  AFGadget::Create(pwindow,&grect,id);

  // Create string for the text
  m_text = new char[strlen(text)+1];
  strcpy(m_text,text);

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
  m_gborder.FrontPen = 2;
  m_gborder2.FrontPen = 1;
  m_gborder.BackPen = m_gborder2.BackPen = 0;
  m_gborder.DrawMode = m_gborder2.DrawMode = JAM1;
  m_gborder.Count = m_gborder2.Count = 3;
  m_gborder.XY = m_xyshine;
  m_gborder2.XY = m_xyshadow; 
  m_gborder.NextBorder = &m_gborder2;
  m_gborder2.NextBorder = NULL;

  m_sborder.LeftEdge = m_sborder2.LeftEdge = -2;
  m_sborder.TopEdge = m_sborder2.TopEdge = -2;
  m_sborder.FrontPen = 1;
  m_sborder2.FrontPen = 2;
  m_sborder.BackPen = m_sborder2.BackPen = 0;
  m_sborder.DrawMode = m_sborder2.DrawMode = JAM1;
  m_sborder.Count = m_sborder2.Count = 3;
  m_sborder.XY = m_xyshine;
  m_sborder2.XY = m_xyshadow; 
  m_sborder.NextBorder = &m_sborder2;
  m_sborder2.NextBorder = NULL;

  // Fill IntuiText Structure
  m_IntuiText.FrontPen = 1;
  m_IntuiText.DrawMode = JAM1;
  m_IntuiText.LeftEdge = 5;
  m_IntuiText.TopEdge = 5;
  m_IntuiText.ITextFont = NULL;
  m_IntuiText.IText = (UBYTE*)m_text;
  m_IntuiText.NextText = NULL;

  // Attach IntuiText Struct and Border Struct to gadget Struct
  //m_pgadget->GadgetText = &m_IntuiText;
  m_pgadget->GadgetRender = &m_sborder;
  m_pgadget->SelectRender = &m_gborder;
}

void AFEdit::FillGadgetStruct(LPExtGadget psgadget)
{
  AFGadget::FillGadgetStruct(psgadget);

  psgadget->GadgetType = GTYP_STRGADGET;
  psgadget->Activation = GACT_RELVERIFY;
  psgadget->Flags = GFLG_TABCYCLE;
  psgadget->SpecialInfo=&m_si;

  m_si.Buffer=(UBYTE*)m_pbuffer;
  m_si.UndoBuffer=(UBYTE*)m_pundobuffer;
  m_si.MaxChars=25;
  m_si.BufferPos=0;
  m_si.DispPos=0;
}

void AFEdit::SetText(int i)
{
  char text[25];

  sprintf(text,"%d",i);
  SetText(text);
}

void AFEdit::SetText(char *text)
{
  strncpy(m_pbuffer,text,m_maxlen);
  RefreshGList((LPGadget)m_pgadget,m_pwindow->m_pWindow,NULL,1);
}
