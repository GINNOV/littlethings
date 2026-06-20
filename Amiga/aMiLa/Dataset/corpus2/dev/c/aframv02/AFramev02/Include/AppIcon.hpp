//////////////////////////////////////////////////////////////////////////////
// AppIcon.hpp
//
// Deryk B Robosson
// May 8, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __APPICON_HPP__
#define __APPICON_HPP__

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
// AppIcon Class

class AFAppIcon : public AFObject
{
public:
    AFAppIcon();
    ~AFAppIcon();

    virtual char *ObjectType() { return "AppIcon"; };

    virtual void Create(LPImage render, LPImage select, int id, char *appname, LPMsgPort msgport);
    virtual void Create(AFAmigaApp *theApp, LPImage render, LPImage select, int id, char *iconname);

private:
    struct WorkbenchBase    *WorkbenchBase;
    struct IconBase         *IconBase;
    struct AppIcon          *ai;
    struct DiskObject       *dob;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __APPICON_HPP__
