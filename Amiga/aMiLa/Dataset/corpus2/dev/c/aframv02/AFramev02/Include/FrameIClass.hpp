//////////////////////////////////////////////////////////////////////////////
// FrameIClass.hpp
//
// Deryk B Robosson
// June 2, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __FRAMEICLASS_HPP__
#define __FRAMEICLASS_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/window.hpp"
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/classes.h>
#include <intuition/icclass.h>
#include <clib/intuition_protos.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// FrameIClass Class

class AFFrameIClass : public AFObject
{
	public:
		AFFrameIClass();
		~AFFrameIClass();

        enum recessed { recessedUp, recessedDown };
        enum frametype { defaultFrame, buttonFrame, ridgeFrame, dropboxFrame };

		virtual void DestroyObject();
		virtual char *ObjectType() { return "FrameIClass"; };

        BOOL Create(AFWindow *window, AFRect *rect, int recessed, int frametype);
        void RemoveObject();
        void RefreshImage();

    private:
        AFWindow        *m_pwindow; // where we belong
        AFRect          m_Rect;     // what our size/coords are
        struct Image    *m_Frame;   // Image for the frame
        BOOL            m_Added;    // wheather or not we are attached to above window ;)
};

//////////////////////////////////////////////////////////////////////////////
#endif // __FRAMEICLASS_HPP__
