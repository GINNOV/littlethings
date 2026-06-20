/*
**  waveforms_lib.c
**
**  Contains the raiseClass() and dropClass() routines for
**  the waveforms.image
**
**  Since this image class will be made into a shared library later,
**  these routines will be renamed to UserLibInit() and UserLibCleanup().
**
**  © Copyright 2000 stranded UFO productions. All Rights Reserved.
**  Written by Paul Juhasz.
**
*/

#include "waveforms.h"
#include "waveforms_rev.h"
#include "waveforms_protos.h"

#undef  SysBase
#undef  GfxBase
#undef  IntuitionBase
#undef  UtilityBase

#define SysBase                  cb->cb_SysBase
#define GfxBase                  cb->cb_GfxBase
#define IntuitionBase            cb->cb_IntuitionBase
#define UtilityBase              cb->cb_UtilityBase

#ifdef DOUBLEMATH
#define MathIeeeDoubBasBase      cb->cb_MathIeeeDoubBasBase
#define MathIeeeDoubTransBase    cb->cb_MathIeeeDoubTransBase
#endif /* DOUBLEMATH */


/****** waveforms.image/--datasheet-- ***********************************************
*
*    NAME
*       waveforms.image--Audio Waveforms display images.                 (V0)
*
*    SUPERCLASS
*       imageclass
*
*    DESCRIPTION
*       The waveforms.image class provides a selectable waveform image display.
*
*    METHODS
*       OM_NEW--Create the waveforms.  Passed to superclass, then OM_SET.
*
*       OM_SET--Set object attributes.  Passed to superclass first.
*
*       OM_GET--Get object attributes.  Passed to superclass first.
*
*       OM_UPDATE--Set object notification attributes.  Passed to superclass
*           first.
*
*       IM_DRAW--Renders the images.  Overrides the superclass.
*
*       All other methods are passed to the superclass, including OM_DISPOSE.
*
*    ATTRIBUTES
*
*       SYSIA_DrawInfo (struct DrawInfo *) -- Contains important pen                 IS
*           information.  This is required if IA_BGPen and IA_FGPen are
*           not specified.
*
*       IA_Pens -- pointer to UWORD pens[]                                           IS
*
*       IA_FGPen (LONG) -- Pen to use to draw the hilite box outline or BLOCKPEN.    IS
*
*       IA_BGPen (LONG) -- Pen to use to draw the shadow box outline or DETAILPEN.   IS
*
*       IA_Width (WORD) -- Width of the image - def 64 pixels.                       IS
*
*       IA_Height (WORD) -- Height of the image - def 64 pixels.                     IS
*
*
*    Private Tags:
*
*       WFI_WaveType (LONG) -- Which of the 5 types of waveforms is used.            ISG
*
*              WF_SINE_WAVE         0
*              WF_TRIANGULAR_WAVE   1
*              WF_RAMPUP_WAVE       2
*              WF_RAMPDOWN_WAVE     3
*              WF_SQUARE_WAVE       4
*
*       WFI_WaveShape (LONG) -- Pulse width for square wave only. Values can be      ISG
*                                             from -98 to +98.
*
*       WFI_Outline (LONG) -- Draw the wave either as WF_SOLID_DISPLAY               ISG
*                                                  or as WF_DOTTED_DISPLAY
*
*       WFI_BoxFrame (LONG) -- Draw a box frame around the graphic or none           IS
*                                   the graphic will be adjusted to fit inside
*
*       WFI_OsciPen (WORD) -- Pen to use to draw the 'oscilloscope screen'           ISG
*                                   background.  If -1 is specified then
*                                   BARBLOCKPEN is used.
*
*       WFI_WavePen (WORD) -- Pen to use to draw the wave.  If -1 is                 IS
*                                   specified then BARDETAILPEN is used.
*
*       WFI_ZeroPen (WORD) -- Draw the zero line using this colour.  The             ISG
*                                   zero line is only drawn when the option
*                                   WF_DOTTED_DISPLAY is selected.  Defaults
*                                   to WF_OsciPen for 'invisible' line or to
*                                   BARTRIMPEN if -1 is specified.
*
*
*******************************************************************************
*
*  P. Juhasz
*
*/


UBYTE *verstring=VERSTRING;



/*______________________________________________________________________________________
 |                                                                                      |
 |    Create a new waveform.image public class                                          |
 |______________________________________________________________________________________*/

BOOL __saveds __asm raiseClass( REGISTER __a0 struct WFIBase *cb )
{
   Class            *cl = NULL;

   SysBase = (*((VOID **)4));
   if (( SysBase )->lib_Version >= LIBRARY_VER ) {
      if ( IntuitionBase = OpenLibrary( "intuition.library", LIBRARY_VER )) {
         if ( GfxBase = OpenLibrary( "graphics.library", LIBRARY_VER )) {
            if ( UtilityBase = OpenLibrary( "utility.library", LIBRARY_VER )) {

#ifdef DOUBLEMATH
               if ( MathIeeeDoubBasBase = OpenLibrary( "mathieeedoubbas.library", LIBRARY_VER )) {
                  if ( MathIeeeDoubTransBase = OpenLibrary( "mathieeedoubtrans.library", LIBRARY_VER )) {
#endif /* DOUBLEMATH */

                     if ( cl = MakeClass( "waveformiclass", IMAGECLASS, NULL,
                                          sizeof( struct waveformData ), 0 )) {
                        cl->cl_Dispatcher.h_SubEntry  = NULL;
                        cl->cl_Dispatcher.h_Entry     = ( HOOKFUNC )dispatchWFI;
                        cl->cl_Dispatcher.h_Data      = (VOID *)cb;
                        cl->cl_UserData               = getreg( REG_A4 );
                        AddClass((struct IClass *)cl );
                     }
#ifdef DOUBLEMATH
                  }
               }
#endif /* DOUBLEMATH */
            }
         }
      }
   }
   cb->cb_Lib.cl_Class = cl;
   return((BOOL)( cl != NULL ));
}


VOID __saveds __asm dropClass( REGISTER __a0 struct WFIBase *cb )
{
   Class            *cl = cb->cb_Lib.cl_Class;

   if ( cl ) {
      RemoveClass((struct IClass *)cl );
      if ( FreeClass( cl ))         cb->cb_Lib.cl_Class = NULL;
   }
   if ( SysBase ) {

#ifdef DOUBLEMATH
      CloseLibrary((struct Library *)MathIeeeDoubTransBase );
      CloseLibrary((struct Library *)MathIeeeDoubBasBase );
#endif /* DOUBLEMATH */

      CloseLibrary((struct Library *)UtilityBase );
      CloseLibrary((struct Library *)GfxBase );
      CloseLibrary((struct Library *)IntuitionBase );
      SysBase = NULL;
   }
}



