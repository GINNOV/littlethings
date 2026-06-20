#ifndef WAVEFORMS_H
#define WAVEFORMS_H

/* Force use of new variable names to help prevent errors */
#define INTUI_V36_NAMES_ONLY
#define ASL_V38_NAMES_ONLY

#define DB(x) ;

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>

#include <graphics/gfxmacros.h>
#include <graphics/gfx.h>
#include <graphics/rastport.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/cghooks.h>
#include <intuition/screens.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/alib_protos.h>
#include <clib/macros.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include <utility/tagitem.h>
#include <utility/hooks.h>


#define LIBRARY_VER           40L


#define XTAG( expr, tagid ) ((Tag)((expr)?(tagid):(TAG_IGNORE)))

/* Subclass specific tags - start just after the image.class specific tags for now. */

#define WFI_Dummy       (IA_Dummy + 0x21)

#define WFI_WaveShape   (WFI_Dummy + 1)
      /* the phase value for a square wave */

#define WFI_WaveType    (WFI_Dummy + 2)
      /* the type of waveform - see below */

#define WFI_Outline     (WFI_Dummy + 3)
      /* how to draw the waveform, solid or dotted */

#define WFI_BoxFrame    (WFI_Dummy + 4)
      /* whether we want a frame around the graphic or NOT */

#define WFI_WavePen     (WFI_Dummy + 5)
      /* draw the waveform using this */

#define WFI_ZeroPen     (WFI_Dummy + 6)
      /* draw for dotted wave only, same as BGPen for no zero line */

#define WFI_OsciPen     (WFI_Dummy + 7)
      /* the 'oscilloscope' screen background */


#define  WF_SINE_WAVE         0
#define  WF_TRIANGULAR_WAVE   1
#define  WF_RAMPUP_WAVE       2
#define  WF_RAMPDOWN_WAVE     3
#define  WF_SQUARE_WAVE       4
#define  WF_ALL_IMAGES        5


/*    These define the way the wave is drawn.  There are two different types: solid
 *    means Move() pixel by pixel along the zero line and draw a vertical line for every
 *    amplitude value.  Dotted means using WritePixel along the wave outline.
 */
#define  WF_SOLID_DISPLAY     0
#define  WF_DOTTED_DISPLAY    1


#endif /* WAVEFORMS_H */



