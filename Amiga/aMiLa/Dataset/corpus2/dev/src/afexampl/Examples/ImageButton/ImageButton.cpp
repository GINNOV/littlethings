//////////////////////////////////////////////////////////////////////////////
// IButton.cpp
//
// Deryk B Robosson
// Jeffry A Worth
// December 4, 1995
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "AFrame:include/ImageButton.hpp"

//////////////////////////////////////////////////////////////////////////////
//

AFImageButton::AFImageButton()
{
  //Do nothing as default constructor;
}

AFImageButton::~AFImageButton()
{
  DestroyObject();
}

void AFImageButton::DestroyObject()
{
  AFGadget::DestroyObject();
}

void AFImageButton::Create(AFWindow* pwindow, AFRect* rect, ULONG id, LPImage image, LPImage select)
{
  Create(pwindow, rect, id, image, select, NULL);
}

void AFImageButton::Create(AFWindow* pwindow, AFRect* rect, ULONG id, LPImage image, LPImage select, LPImage disabled)
{
  AFRastPort rp(pwindow);

  // Store the imagery imformation
  m_pRender = image;
  m_pSelect = select;
  m_pDisabled = disabled;

  // Create the gadget
  AFGadget::Create(pwindow,rect,id);

  // Attach ImageStruct to Gadget Struct
  m_pgadget->Activation = GACT_RELVERIFY | GACT_IMMEDIATE;
  m_pgadget->GadgetType = GTYP_BOOLGADGET;
  m_pgadget->GadgetRender = m_pRender;

  if(select == NULL) {
    m_pgadget->SelectRender = NULL;
    m_pgadget->Flags = GFLG_GADGHIMAGE | GFLG_GADGIMAGE;
  } else {
      m_pgadget->SelectRender = m_pSelect;
      m_pgadget->Flags = GFLG_GADGHIMAGE | GFLG_GADGIMAGE;
  }

  m_pgadget->GadgetText = NULL;
  m_pgadget->MutualExclude = NULL;
  m_pgadget->SpecialInfo = NULL;
}

// December 19, 1995 - Jeffry A Worth
void AFImageButton::SizeToFit()
{
  m_pgadget->Width = m_pRender->Width;
  m_pgadget->Height = m_pRender->Height;
}
