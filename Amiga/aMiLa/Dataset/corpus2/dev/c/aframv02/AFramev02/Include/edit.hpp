//////////////////////////////////////////////////////////////////////////////
// edit.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __EDIT_HPP__
#define __EDIT_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/gadget.hpp"

//////////////////////////////////////////////////////////////////////////////
// Edit Class

class AFEdit : public AFGadget
{
public:
  AFEdit();
  ~AFEdit();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "Edit"; };

  virtual void Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id, int maxlen);
  virtual void FillGadgetStruct(LPExtGadget psgadget);

  virtual void SetText(int i);
  virtual void SetText(char *text);

  struct StringInfo m_si;
  char *m_pbuffer,*m_pundobuffer;
  struct IntuiText m_IntuiText;
  struct Border m_gborder,m_gborder2;
  struct Border m_sborder,m_sborder2;
  char *m_text;
  WORD m_xyshine[6];
  WORD m_xyshadow[6];
  int m_maxlen;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __EDIT_HPP__
