/*
**    GetModeInfo
**
**        © 1996 by Timo C. Nentwig
**        All Rights Reserved !
**
**        Tcn@oxygen.in-berlin.de
**
*/

/// #include

#include <dos/dos.h>
#include <dos/rdargs.h>

#include <exec/memory.h>
#include <exec/types.h>

#include <graphics/displayinfo.h>

#include <libraries/asl.h>

#include <proto/asl.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>

#include <pragmas/asl_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/graphics_pragmas.h>

#include <tcn/macros.h>

///
/// #define

#define PRG_TITLE       "GetModeInfo"
#define PRG_AUTHOR      "Timo C. Nentwig"
#define PRG_EMAIL       "Tcn@oxygen.in-berlin.de"
#define PRG_YEAR        "1995-1996"
#define PRG_VERSION     "2.0"

///

struct Settings
{

    struct
    {

        BOOL    Dimension;
        BOOL    Monitor;
        BOOL    Display;

    } Info;

} Set;

