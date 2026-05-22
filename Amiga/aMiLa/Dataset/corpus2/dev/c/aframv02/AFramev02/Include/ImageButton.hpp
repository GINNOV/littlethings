//////////////////////////////////////////////////////////////////////////////
// ImageButton.hpp
//
// Jeffry A Worth
// Deryk B Robosson
// December 4, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFIMAGEBUTTON_HPP__
#define __AFIMAGEBUTTON_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/gadget.hpp"
#include "aframe:include/rastport.hpp"

//////////////////////////////////////////////////////////////////////////////
// IButton Class

class AFImageButton : public AFGadget
{
public:
  AFImageButton();
  ~AFImageButton();

  virtual void DestroyObject();
  virtual char *ObjectType() { return "AFImageButton"; };

  virtual void Create(AFWindow* pwindow, AFRect* rect, ULONG id, LPImage image, LPImage select);
  virtual void Create(AFWindow* pwindow, AFRect* rect, ULONG id, LPImage image, LPImage select, LPImage disabled);
  virtual void SizeToFit();

	// December 19,1995 Jeffry A Worth
private:
  LPImage m_pRender;
  LPImage m_pSelect;
  LPImage m_pDisabled;
	// End Additions
};

//////////////////////////////////////////////////////////////////////////////
#endif // __AFIMAGEBUTTON_HPP__
