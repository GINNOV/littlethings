//////////////////////////////////////////////////////////////////////////////
// GSlider.hpp
//
// Deryk B Robosson
// June 2, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __GSLIDER_HPP__
#define __GSLIDER_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/gadget.hpp"
#include <intuition/classes.h>
#include <intuition/gadgetclass.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>
#include <gadgets/gradientslider.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// GSlider Class

class AFGSlider : public AFGadget
{
public:
    AFGSlider();
    ~AFGSlider();

    virtual char *ObjectType() { return "GSlider"; };
    virtual void DestroyObject();

    virtual void Create(AFWindow* window, AFRect *rect, UWORD pens[], ULONG id, ULONG verthoriz);
    virtual ULONG CurrentPos();

private:
    struct ClassLibrary *ClassLibrary;
    AFWindow* m_pwindow;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __GSLIDER_HPP__
