//////////////////////////////////////////////////////////////////////////////
// TapeDeck.hpp
//
// Deryk B Robosson
// April 29, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __TAPEDECK_HPP__
#define __TAPEDECK_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/gadget.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/window.hpp"
#include <intuition/classes.h>
#include <intuition/gadgetclass.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>
#include <gadgets/tapedeck.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// TapeDeck Class

class AFTapeDeck : public AFGadget
{
public:
	AFTapeDeck();
	~AFTapeDeck();

    virtual char *ObjectType() { return "TapeDeck"; };
    virtual void DestroyObject();

    virtual void Create(AFWindow *window, AFRect *rect, ULONG gadid);
    ULONG GetCurrentButton();

private:
    struct ClassLibrary *ClassLibrary;
    AFWindow* m_pwindow;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __TAPEDECK_HPP__
