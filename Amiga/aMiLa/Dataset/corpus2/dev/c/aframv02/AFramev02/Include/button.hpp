//////////////////////////////////////////////////////////////////////////////
// button.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __BUTTON_HPP__
#define __BUTTON_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/gadget.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
// Button Class

class AFButton : public AFGadget
{
public:
  AFButton();
  ~AFButton();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "Button"; };

  virtual void Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id);

  struct IntuiText m_IntuiText;
  struct Border m_gborder,m_gborder2;
  struct Border m_sborder,m_sborder2;
  AFString m_text;
  WORD m_xyshine[6];
  WORD m_xyshadow[6];

  AFRect m_rect;

  virtual void FillGadgetStruct(LPExtGadget psgadget);
  virtual void SetText(char* text);
};

//////////////////////////////////////////////////////////////////////////////
#endif // __BUTTON_HPP__
