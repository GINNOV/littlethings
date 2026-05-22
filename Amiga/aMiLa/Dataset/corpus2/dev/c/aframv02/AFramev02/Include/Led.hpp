//////////////////////////////////////////////////////////////////////////////
// Led.hpp
//
// Deryk B Robosson
// April 26, 1996
//
// 5.23.96 DBR
// SetDigits(int pair, int number)
//////////////////////////////////////////////////////////////////////////////

#ifndef __LED_HPP__
#define __LED_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/window.hpp"
#include <dos/dos.h>
#include <exec/types.h>
#include <exec/libraries.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/classes.h>
#include <intuition/icclass.h>
#include <intuition/intuitionbase.h>
#include <images/led.h>
#include <stdlib.h>
#include <stdio.h>

#include <clib/macros.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions
typedef struct
{
    BOOL Added;             // Gadget added to window TRUE/FALSE
    BOOL Colon;             // Colon on/off default=TRUE
    BOOL Negative;          // Negative on/off default=FALSE
    BOOL Signed;            // Signed on/off default=TRUE
    LONG FGPen;             // Foreground Pen
    LONG BGPen;             // Background Pen
    LONG NumPairs;          // Number of digit pairs default=1
    AFWindow *Window;       // Window to which gadget has been added
    struct Image *Image;    // Image Struct
    AFRect rect;            // Image size and position
    WORD DigitPairs[8];     // DigitPairs array
} LED;

//////////////////////////////////////////////////////////////////////////////
// Led Class

class AFLed : public AFObject
{
	public:
		AFLed();
		~AFLed();

		virtual void DestroyObject();
		virtual char *ObjectType() { return "Led"; };

        BOOL Create(AFWindow *window, AFRect *rect);
        void RefreshImage();
        void RemoveObject();
        void SetDigits(int pair, int number);

        LED m_Global;

    private:
        struct ClassLibrary *LedLibrary;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __LED_HPP__
