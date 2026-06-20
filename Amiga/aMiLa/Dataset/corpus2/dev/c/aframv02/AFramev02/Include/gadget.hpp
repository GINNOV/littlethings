//////////////////////////////////////////////////////////////////////////////
// gadget.hpp
//
// Jeffry A Worth
// November 10, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __GADGET_HPP__
  #define __GADGET_HPP__

  //////////////////////////////////////////////////////////////////////////////
  // INCLUDES
  #include "aframe:include/aframe.hpp"
  #include "aframe:include/window.hpp"
  #include "aframe:include/rect.hpp"
  #include "aframe:include/string.hpp"

  //////////////////////////////////////////////////////////////////////////////
  // Definitions

  #define AFGADGET_OWNERSTRUCT 0x80000000

  //////////////////////////////////////////////////////////////////////////////
  // Gadget Class

  class AFGadget : public AFObject
  {
	public:
		AFGadget();
		~AFGadget();

		virtual void DestroyObject();
		virtual char *ObjectType() { return "Gadget"; };

		virtual void Create(AFWindow* pwindow, AFRect *rect,ULONG id);
		virtual void Create(AFWindow* pwindow, LPExtGadget psgadget);
		virtual void FillGadgetStruct(LPExtGadget psgadget);
		virtual void AddGadget();
		virtual void RemoveGadget();
        virtual ULONG GadgetID();

		// Events
		virtual void OnGadgetDown(LPIntuiMessage) { return; };
		virtual void OnGadgetUp(LPIntuiMessage) { return; };
		virtual void OnPaint() { return; };

		LPExtGadget m_pgadget;
		AFWindow *m_pwindow;
		ULONG m_flags;

		virtual BOOL BeginPaint();
		virtual void EndPaint();
		virtual void GetDisplayRect(AFRect* rect);
		virtual void EraseGadget();
		virtual void DrawGadget();
		
		AFString m_statusText;

	private:
		LPRegion m_newregion,m_oldregion;

  };

//////////////////////////////////////////////////////////////////////////////
#endif // __GADGET_HPP__
