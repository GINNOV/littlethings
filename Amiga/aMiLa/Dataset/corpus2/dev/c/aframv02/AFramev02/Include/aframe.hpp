//////////////////////////////////////////////////////////////////////////////
// aframe.h
// 
// Jeffry A Worth
// Deryk B Robosson
// December 16, 1995
//////////////////////////////////////////////////////////////////////////////

#ifndef __AFRAME_HPP__
#define __AFRAME_HPP__

#define __VERSION__ 1
#define __REVISION__ 1

//////////////////////////////////////////////////////////////////////////////
// INCLUDES
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/dos.h>

#include <intuition/intuition.h>
#include <devices/serial.h>
#include <libraries/dos.h>
#include <exec/types.h>
#include <stdio.h>

#include <clib/layers_protos.h>

#include "aframe:include/object.hpp"

//////////////////////////////////////////////////////////////////////////////
// AFrame Standard Window features

#define STD_WINDOW_IDCMP IDCMP_GADGETUP+IDCMP_CLOSEWINDOW+IDCMP_NEWSIZE+IDCMP_IDCMPUPDATE
#define STD_WINDOW_FLAGS WFLG_SIZEGADGET+WFLG_DRAGBAR+WFLG_DEPTHGADGET+WFLG_CLOSEGADGET+WFLG_ACTIVATE+WFLG_NEWLOOKMENUS+WFLG_GIMMEZEROZERO

//////////////////////////////////////////////////////////////////////////////
// HANDLES

typedef struct IntuiMessage * LPIntuiMessage;
typedef struct AppMessage *LPAppMessage;    // May 13, 1996 Deryk
typedef struct Message * LPMessage;
typedef struct Window * LPWindow;
typedef struct RastPort * LPRastPort;
typedef struct Gadget * LPGadget;
typedef struct ExtGadget * LPExtGadget;
typedef struct Image  * LPImage;
typedef struct Screen * LPScreen;
typedef struct Region * LPRegion;
typedef struct Border * LPBorder;

typedef struct Rectangle Rectangle;

typedef struct MsgPort *LPMsgPort;
typedef struct IORequest *LPIORequest;
typedef struct IOStdReq *LPIOStdReq;    // January 1, 1996 Deryk
typedef struct IOExtSer *LPIOExtSer;
typedef struct Library *LPLibrary;      // January 10, 1996 Deryk
typedef struct IOAudio *LPAudio;        // March 2, 1996 Deryk
typedef struct Message *LPMessage;      // March 2, 1996 Deryk

typedef struct TextExtent TEXTEXTENT;
typedef TEXTEXTENT *PTEXTEXTENT;
typedef struct TextAttr TEXTATTR;
typedef TEXTATTR *PTEXTATTR;

//////////////////////////////////////////////////////////////////////////////
#endif // __AFRAME_HPP__
