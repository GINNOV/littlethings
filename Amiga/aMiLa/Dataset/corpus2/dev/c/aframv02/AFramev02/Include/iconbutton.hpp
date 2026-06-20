//////////////////////////////////////////////////////////////////////////////
// iconbutton.hpp
//
// Jeffry A Worth
// January 6, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __ICONBUTTON_HPP__
#define __ICONBUTTON_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES

#include "aframe:include/window.hpp"
#include "aframe:include/button.hpp"
#include "aframe:include/rect.hpp"

class AFIconButton : public AFButton
{
  public:
	AFIconButton();

	virtual char *ObjectType() { return "IconButton"; };

	virtual void Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id, LPImage pimage);
	virtual void OnGadgetDown(LPIntuiMessage imess) { OnPaint(); };
	virtual void OnGadgetUp(LPIntuiMessage imess) { OnPaint(); };
	virtual void OnPaint(); 
	virtual void FillGadgetStruct(LPExtGadget psgadget);

	LPImage m_image;
};

#endif // __ICONBUTTON_HPP__
