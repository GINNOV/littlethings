//////////////////////////////////////////////////////////////////////////////
// DataType.hpp
//
// Deryk Robosson
// March 9, 1996
//////////////////////////////////////////////////////////////////////////////

#ifndef __DATATYPE_HPP__
#define __DATATYPE_HPP__

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include "aframe:include/aframe.hpp"
#include "aframe:include/string.hpp"
#include "aframe:include/rect.hpp"
#include "aframe:include/window.hpp"
#include "aframe:include/screen.hpp"
#include <exec/memory.h>
#include <exec/libraries.h>
#include <devices/clipboard.h>
#include <graphics/gfx.h>
#include <graphics/displayinfo.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/pictureclass.h>
#include <datatypes/soundclass.h>
#include <datatypes/textclass.h>
#include <datatypes/animationclass.h>
#include <libraries/iffparse.h>

#include <clib/alib_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/datatypes_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/icon_pragmas.h>

#include <proto/datatypes.h>

///////////////////////////////////////////////////////////////////////////////
// Definitions
extern struct IconBase      *IconBase;
extern struct Library       *DataTypesBase;
extern struct Library       *IFFParseBase;

typedef struct
{
    AFString description;   // Description of datatype
    AFString name;          // Name of datatype
    AFString type;          // Type
    AFString group;         // Group
    AFString id;            // ID
    AFString author;        // Author       // this and below not yet implemented
    AFString annotation;    // Annotation
    AFString copyright;     // Copyright
    AFString version;       // version
} DTINFO;

typedef struct
{
    struct dtPrint  dtp;
    LPMsgPort       mp;
    union printerIO *pio;
} DTPRINT;

typedef struct
{
    Object              *o;
    AFWindow            *dtWindow;  // keep a pointer to the window of the object
    struct DataType     *dtn;
    struct DTSpecialInfo *dtsi;
    struct FrameInfo    fri;
    struct dtFrameBox   dtf;
    struct dtWrite      dtw;
    struct dtDraw       dtDraw;
    struct dtGeneral    dtg;
    struct dtGoto       dtGoto;
    struct dtSelect     dts;
    struct dtTrigger    dtt;
    struct DTMethod     dtm;
    struct gpLayout     gpl;
    struct GadgetInfo   ginfo;
    AFRect              rect;
    DTPRINT             dtPrint;
    DTINFO              dtInfo;
    BOOL                dtAdded;  // keep track off object addition & removal
} GD;

//////////////////////////////////////////////////////////////////////////////
// DataType Class

class AFDataType : public AFObject
{
public:
    AFDataType();
    ~AFDataType();

    virtual void DestroyObject();
    virtual char *ObjectType() { return "DataType"; };

    BOOL IsDataType(char *file);
    BOOL DTInfo();
    BOOL DTInfo(char *file);
    BOOL SaveObject(ULONG stype, char *file_name, ULONG mode);
    BOOL PrintObject(AFWindow *window);
    BOOL AbortPrint();
    BOOL PrintComplete();
    BOOL LoadClipBoard(LONG unit);
    ULONG InterrogateClipBoard(LONG unit);
    ULONG AddObject(AFWindow *window, AFRect *rect, UWORD id);
    LONG RemoveObject();
    AFRect FrameObject(AFWindow *window);
    AFRect FrameObject(AFScreen *screen);
    AFRect FrameObject();

    AFDataType operator=(AFDataType dtype);

    GD  m_dtGlobal;
};

//////////////////////////////////////////////////////////////////////////////
#endif // __DATATYPE_HPP__
