//////////////////////////////////////////////////////////////////////////////
// Tab.hpp
//
// Deryk B Robosson
// May 5, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __TAB_HPP__
#define __TAB_HPP__

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
#include <gadgets/tabs.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// Tab Class

class AFTab : public AFGadget
{
public:
    AFTab();
    ~AFTab();

    virtual char *ObjectType() { return "Tab"; };
    virtual void DestroyObject();

    virtual void Create(AFWindow* pwindow, AFRect *rect, TabLabel tlabels[], ULONG gadid);
    virtual void OnGadgetUp(LPIntuiMessage imess);
    virtual ULONG GetCurrentTab();

private:
    struct ClassLibrary *ClassLibrary;
    AFWindow* m_pwindow;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __TAB_HPP__
