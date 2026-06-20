///////////////////////////////////////////////////////////////////////////////
// iconbar.hpp
//
// Jeffry A Worth
// January 6, 1996
///////////////////////////////////////////////////////////////////////////////

#ifndef __ICONBAR_HPP__
  #define __ICONBAR_HPP__

  #define ICONBAR_SPACE	-1

  /////////////////////////////////////////////////////////////////////////////
  // INCLUDES

  #include "aframe:include/aframe.hpp"
  #include "aframe:include/panel.hpp"
  #include "aframe:include/iconbutton.hpp"

  /////////////////////////////////////////////////////////////////////////////
  // IconBar Class 

  class AFIconBar : public AFPanel
  {
	public:
		AFIconBar();

		virtual char *ObjectType() { return "IconBar"; };

		virtual void Create(AFWindow* pwindow, ULONG id, LPImage* imagelist, UWORD* idlist, char** help);
		virtual void OnPaint();

		LPImage* m_imagelist;
		UWORD* m_idlist;
		AFPtrDlist m_iconbuttons;
  };

///////////////////////////////////////////////////////////////////////////////
#endif // __ICONBAR_HPP__
