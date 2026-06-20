//////////////////////////////////////////////////////////////////////////////
// colorpick.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __COLORPICK_HPP__
#define __COLORPICK_HPP__

  //////////////////////////////////////////////////////////////////////////////
  // INCLUDES
  #include "aframe:include/panel.hpp"
  #include "aframe:include/box.hpp"
  #include "aframe:include/ptrdlist.hpp"

  //////////////////////////////////////////////////////////////////////////////
  // Definitions

  //////////////////////////////////////////////////////////////////////////////
  // Color Pick Class

  class AFColorPick : public AFPanel
  {
	public:
		AFColorPick();
		~AFColorPick();

        enum bevel { bevelDown, bevelUp, bevelNone };

		virtual void DestroyObject();
		virtual char *ObjectType() { return "ColorPick"; };
		virtual void OnGadgetUp(LPIntuiMessage imess);

		virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id, bevel beveltype,
						int numColors, int numColumns, UBYTE Color);

		UBYTE m_Color;

	private:
		AFPtrDlist m_boxes;
  };

  class AFCPBox : public AFBox
  {
	public:
		AFCPBox();
		~AFCPBox();

		virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id, UBYTE penColor,
							UBYTE Outline, AFColorPick *colorpick);
		virtual void OnGadgetUp(LPIntuiMessage imess);

		AFColorPick *m_pcolorpick;
  };

//////////////////////////////////////////////////////////////////////////////
#endif // __COLORPICK_HPP__
