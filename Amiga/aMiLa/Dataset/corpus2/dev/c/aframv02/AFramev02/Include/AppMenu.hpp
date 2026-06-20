//////////////////////////////////////////////////////////////////////////////
// AppMenu.hpp
//
// Deryk B Robosson
// May 9, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __APPMENU_HPP__
#define __APPMENU_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/object.hpp"
#include "aframe:include/window.hpp"
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <clib/icon_protos.h>
#include <clib/wb_protos.h>

//////////////////////////////////////////////////////////////////////////////
// Definitions

//////////////////////////////////////////////////////////////////////////////
// AppMenu Class

class AFAppMenu : public AFObject
{
public:
    AFAppMenu();
    ~AFAppMenu();

    virtual char *ObjectType() { return "AppMenu"; };

    virtual BOOL AddItem(AFWindow *window, UBYTE* name, ULONG menuid, LPMsgPort appmsgport);
    virtual void RemoveItem();

private:
    struct WorkbenchBase    *WorkbenchBase;
    struct IconBase         *IconBase;
    struct AppMenuItem      *am;
    struct AppMessage       *amsg;
    struct WBArg            *argptr;

    AFWindow                *m_pwindow;
    ULONG                   m_menuid;
    UBYTE                   *m_itemname;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __APPMENU_HPP__
