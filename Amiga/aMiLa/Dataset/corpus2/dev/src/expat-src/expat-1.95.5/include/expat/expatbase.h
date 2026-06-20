/*
**      $VER: expatbase.h 1.0 (1/8/01)
**
**      definition of ExpatBase
**
*/

#ifndef EXPAT_EXPATBASE_H
#define EXPAT_EXPATBASE_H

#ifdef   __MAXON__
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#else
#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */
#endif

#include <dos/dos.h>

struct ExpatBase
{
  struct Library         exb_LibNode;
  BPTR             exb_SegList;
  struct ExecBase       *exb_SysBase;
  struct IntuitionBase  *exb_IntuitionBase;
  struct GfxBase        *exb_GfxBase;
};

#endif /* EXPAT_EXPATBASE_H */
