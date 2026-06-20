#ifndef  WAVEFORMSBASE_H
#define  WAVEFORMSBASE_H

#include <exec/types.h>
#include <exec/libraries.h>
#include <graphics/gfxbase.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <dos.h>


//#define DOUBLEMATH   1


#ifdef DOUBLEMATH
#include <mieeedoub.h>
#define PI      3.14159265358979323846       /*  Floating point constants */
#define PID2    1.57079632679489661923       /*  PI/2  */
#define PID4    0.78539816339744830962       /*  PI/4  */
#define I_PI    0.31830988618379067154       /*  1/PI  */
#define I_PID2  0.63661977236758134308       /*  1/(PI/2)  */
#endif /* DOUBLEMATH */


struct waveformData
{
   struct DrawInfo     *wf_DrawInfo;
   LONG                 wf_WaveShape;
   LONG                 wf_WaveType;
   LONG                 wf_Outline;
   LONG                 wf_BoxFrame;         /* whether to frame the graphic or NOT */
   WORD                 wf_ShadowPen;        /* used for box outline shadow */
   WORD                 wf_HiLitePen;        /*    ...same for highlighting */
   WORD                 wf_WavePen;
   WORD                 wf_ZeroPen;
   WORD                 wf_OsciPen;          /* see user tags below */
   WORD                 wf_Pad;
};


struct WFIBase
{
   struct ClassLibrary  cb_Lib;              /* Node (14) -> Library (34) -> ClassLib (40) */
   struct Library      *cb_SysBase;
   struct Library      *cb_GfxBase;
   struct Library      *cb_IntuitionBase;
   struct Library      *cb_UtilityBase;

#ifdef DOUBLEMATH
   struct Library      *cb_MathIeeeDoubBasBase;
   struct Library      *cb_MathIeeeDoubTransBase;
#endif /* DOUBLEMATH */

   ULONG                cb_SegList;
};


BOOL __saveds __asm raiseClass( REGISTER __a0 struct WFIBase *cb );
VOID __saveds __asm dropClass( REGISTER __a0 struct WFIBase *cb );


#endif /* WAVEFORMSBASE_H */


