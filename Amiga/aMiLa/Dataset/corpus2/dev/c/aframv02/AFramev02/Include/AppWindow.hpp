//////////////////////////////////////////////////////////////////////////////
// AppWindow.hpp
//
// Deryk B Robosson
// May 9, 1996
//
// May 19, 1996 DBR
// Added Window title support to Create functions
//////////////////////////////////////////////////////////////////////////////

#ifndef __APPWINDOW_HPP__
#define __APPWINDOW_HPP__

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
// AppWindow Class

class AFAppWindow : public AFWindow
{
public:
    AFAppWindow();
    ~AFAppWindow();

    virtual char *ObjectType() { return "AppWindow"; };

    virtual void Create(AFAmigaApp *theApp, AFRect *rect, ULONG id, LPMsgPort appmsgport, char *title);
    virtual void Create(AFAmigaApp *theApp, AFRect *rect, ULONG id, char *title);
    virtual void OnCloseWindow(LPIntuiMessage imess);

private:
    struct WorkbenchBase    *WorkbenchBase;
    struct IconBase         *IconBase;
    struct AppWindow        *aw;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __APPWINDOW_HPP__
