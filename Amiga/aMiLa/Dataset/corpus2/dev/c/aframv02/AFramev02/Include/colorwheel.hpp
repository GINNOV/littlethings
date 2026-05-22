//////////////////////////////////////////////////////////////////////////////
// colorwheel.hpp
//
// Jeffry A Worth
// January 29, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __COLORWHEEL_HPP__
  #define __COLORWHEEL_HPP__

  //////////////////////////////////////////////////////////////////////////////
  // INCLUDES
  #include <proto/exec.h>
  #include <proto/colorwheel.h>
  #include <intuition/gadgetclass.h>

  #include "aframe:include/gadget.hpp"

  extern struct Library* ColorWheelBase;

  //////////////////////////////////////////////////////////////////////////////
  // ColorWheel Class

  class AFColorWheel : public AFGadget
  {
	public:
		AFColorWheel();
		~AFColorWheel();

		virtual void DestroyObject();
		virtual char *ObjectType() { return "ColorWheel"; };
		BOOL BeginPaint() { return FALSE; }; // N/A - BOOPSI Gadgets
		void EndPaint() { return; };   // N/A - BOOPSI Gadgets

		virtual void Create(AFWindow* pwindow, AFRect *rect, ULONG id);
};

//////////////////////////////////////////////////////////////////////////////
#endif // __COLORWHEEL_HPP__
