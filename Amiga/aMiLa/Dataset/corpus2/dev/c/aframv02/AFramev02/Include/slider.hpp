//////////////////////////////////////////////////////////////////////////////
// slider.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __SLIDER_HPP__
#define __SLIDER_HPP__

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/gadget.hpp"

//////////////////////////////////////////////////////////////////////////////
// Slider Class

class AFSlider : public AFGadget
{
public:
  AFSlider();
  ~AFSlider();

  virtual char *ObjectType() { return "Slider"; };
  virtual void FillGadgetStruct(LPGadget psgadget);

  virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id, UWORD iFlags);
  virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id, UWORD iFlags,
		int iMax, int iCount, int iPos);

  virtual int SetMax(int iMax);
  virtual int SetCount(int iCount);
  virtual int SetPos(int iPos);
  virtual int CurrentPos();

  struct PropInfo m_propinfo;
  struct Image m_image;
  int m_iMax,m_iCount,m_iPos;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __SLIDER_HPP__
