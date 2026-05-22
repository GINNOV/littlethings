//////////////////////////////////////////////////////////////////////////////
// panel.hpp
//
// Jeffry  Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __PANEL_HPP__
#define __PANEL_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <string.h>
#include "aframe:include/string.hpp"
#include "aframe:include/gadget.hpp"
#include "aframe:include/border.hpp"

//////////////////////////////////////////////////////////////////////////////
// Panel Class

class AFPanel : public AFGadget
{
  public:
	AFPanel();
  	~AFPanel();

	enum bevel { bevelDown, bevelUp, bevelNone };

  	virtual void DestroyObject();
  	virtual char *ObjectType() { return "Panel"; };
  	virtual void SetText(char* text);
  	virtual void Create(char *text, AFWindow* pwindow, AFRect *rect, ULONG id,
		bevel beveltype);
	virtual void GetDisplayRect(AFRect *rect);

  	struct IntuiText m_IntuiText;
  	struct Border m_gborder,m_gborder2;
  	AFString m_text;
	AFBorder border;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __PANEL_HPP__
