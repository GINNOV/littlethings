//////////////////////////////////////////////////////////////////////////////
// gadget.cpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/slider.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFSlider::AFSlider()
{
  m_iMax = m_iCount = m_iPos = 0;
}

AFSlider::~AFSlider()
{
  DestroyObject();
}

void AFSlider::FillGadgetStruct(LPGadget psgadget)
{
  psgadget->Flags = NULL;
  psgadget->Activation = GACT_RELVERIFY|GACT_IMMEDIATE;
  psgadget->GadgetType = GTYP_PROPGADGET;
  psgadget->GadgetRender = (APTR)&m_image;
  psgadget->SelectRender = NULL;
  psgadget->GadgetText = NULL;
  psgadget->MutualExclude = NULL;
  psgadget->SpecialInfo = (APTR)&m_propinfo;
  return;
}

void AFSlider::Create(AFWindow* pwindow, AFRect *rect, ULONG id, UWORD iFlags)
{
  Create(pwindow,rect,id,iFlags,1,1,1);
}

void AFSlider::Create(AFWindow* pwindow, AFRect *rect, ULONG id, UWORD iFlags, int iMax, int iCount, int iPos)
{
  double size;

  // Store Information
  m_iMax=iMax;
  m_iCount=iCount;
  m_iPos=iPos;

  // Setup the PropInfo Structure
  size = m_iCount;
  size*=(0xffff/m_iMax);
  m_propinfo.Flags = iFlags | PROPNEWLOOK | AUTOKNOB;
  m_propinfo.HorizBody = MAXBODY; // FIXED TO VERTICLE FOR THE TIME BEING !!!!!!!!!!!!!!!!
  m_propinfo.VertBody = size;

  // Create the gadget
  AFGadget::Create(pwindow,rect,id);
}

int AFSlider::SetMax(int iMax)
{
  return iMax;
}

int AFSlider::SetCount(int iCount)
{
  return iCount;
}

int AFSlider::SetPos(int iPos)
{
  return iPos;
}

int AFSlider::CurrentPos()
{
  double pos;

  pos = m_propinfo.VertPot+2*(0xFFFF/m_iMax);
  pos /= 0xFFFF;
  if(m_iMax>m_iCount)
    return pos*(m_iMax-m_iCount)+1;
  return 0;
}
