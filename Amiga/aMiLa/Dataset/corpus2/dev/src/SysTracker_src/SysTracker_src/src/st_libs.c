/***************************************************************************/
/* st_libs.c - Amiga shared library handling.                              */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/
/* Data and defines */
/***************************************************************************/

struct Library *IntuitionBase = NULL;
struct Library *UtilityBase = NULL;
struct Library *WorkbenchBase = NULL;
struct Library *DiskFontBase = NULL;
struct Library *GfxBase = NULL;

#define MIN_OS_VER 39L

struct GetLibs GetLibsData[] =
{
  { "intuition.library", MIN_OS_VER, &IntuitionBase, GL_ABSOLUTE },
  { "utility.library",   MIN_OS_VER, &UtilityBase,   GL_ABSOLUTE },
  { "workbench.library", MIN_OS_VER, &WorkbenchBase, GL_ABSOLUTE },
  { "diskfont.library",  MIN_OS_VER, &DiskFontBase,  GL_ABSOLUTE },
  { "graphics.library",  MIN_OS_VER, &GfxBase,       GL_ABSOLUTE },
  { NULL,                0,          NULL,           0           }, 
};

/***************************************************************************/

GPROTO BOOL LIBS_Init( void )
{
  /*********************************************************************
   *
   * LIBS_Init()
   *
   * Open all of the system libraries that SysTracker requires.
   *
   *********************************************************************
   *
   */

  register struct GetLibs *GLD = GetLibsData;
  register BOOL OLFailure = FALSE;

  if (!GUI_InitMUI()) return FALSE;

  while(GLD->gl_Name)
  {
    if (!(*GLD->gl_LibBasePtr =
      OpenLibrary(GLD->gl_Name, (LONG) GLD->gl_Version)))
    {
      if (GLD->gl_Mode == GL_ABSOLUTE) OLFailure = TRUE;
    }
    GLD++;
  }

  if (OLFailure)
  {
    if (IntuitionBase)
    {
      UBYTE TmpStr[128];
      register UBYTE *ErrStr = MEM_AllocVec(1024);    

      if (ErrStr)
      {
        strcpy(ErrStr, STR_Get(SID_CANNOT_OPEN_FOLLOWING_LIBS));

        GLD = GetLibsData;

        while(GLD->gl_Name)
        {
          if ((*GLD->gl_LibBasePtr == NULL) &&
              (GLD->gl_Mode == GL_ABSOLUTE))
          {
            sprintf(TmpStr, STR_Get(SID_LIB_VERSION_FMT),
              GLD->gl_Name, GLD->gl_Version);
            strcat(ErrStr, TmpStr);
          }           
          GLD++;
        }
        M_PrgError(ErrStr, NULL);
        MEM_FreeVec(ErrStr);
      } 
    }
    return FALSE;
  } 
  return TRUE;
}

GPROTO void LIBS_Free( void )
{
  /*********************************************************************
   *
   * LIBS_Free()
   *
   * Close all system libraries opened by LIBS_Init().
   *
   *********************************************************************
   *
   */

  register struct GetLibs *GLD = GetLibsData;

  while(GLD->gl_Name)
  {
    if (*GLD->gl_LibBasePtr)
    {
      CloseLibrary(*GLD->gl_LibBasePtr); *GLD->gl_LibBasePtr = NULL;
    }
    GLD++;
  }
  GUI_EndMUI();
}


