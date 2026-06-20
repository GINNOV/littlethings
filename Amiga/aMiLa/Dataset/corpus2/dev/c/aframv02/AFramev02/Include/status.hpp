//////////////////////////////////////////////////////////////////////////////
// status.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __STATUS_HPP__
#define __STATUS_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include <string.h>
#include "aframe:include/gadget.hpp"

//////////////////////////////////////////////////////////////////////////////
// Status Bar Class

class AFStatus : public AFGadget
{
public:
  AFStatus();
  ~AFStatus();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "Status"; };

  virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id, UBYTE penDone, UBYTE penToGo);
  virtual void SetStatus(int percent);
  virtual void BuildImages();

  struct IntuiText m_IntuiText;
  struct Image m_Done,m_ToGo;
  char *m_text;
  int m_percent;
  UBYTE m_penDone,m_penToGo;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __STATUS_HPP__
