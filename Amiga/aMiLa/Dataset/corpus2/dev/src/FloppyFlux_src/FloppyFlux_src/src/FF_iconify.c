
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_iconify.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Sunday 20-Jun-99 17:35:02
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : GUI iconify control routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_ICONIFY_C

/* Created: Sun/20/Jun/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype BOOL HideGUI( void );
Prototype Prototype BOOL ShowGUI( void );
Prototype struct DiskObject *AI_GetDiskObject( void );
Prototype void AI_FreeDiskObject( void );

Prototype BOOL AI_Show( void );
Prototype void AI_Hide( void );

/*************************************************
 *
 * Data protos
 *
 */

/* Use this variable to determine the state
   of FloppyFlux's GUI. It's global, so all
   modules can access it.  */

Prototype BOOL Iconified;
BOOL Iconified = FALSE;

struct AppIcon *FFAppIcon;
ULONG IconLastSel = 0;

/*************************************************
 *
 * Hide the FF GUI. This is called when FF is
 * going into iconification state.
 *
 */

BOOL HideGUI( void )
{
  BOOL result = FALSE;

  if (AI_Show())
  {
    IconLastSel = LT_GetAttributes(MainWindowHandle, GID_LIST,
                    TAG_DONE);

    CloseMainWindow();
    result = TRUE;
  }
  return Iconified = result;
}

/*************************************************
 *
 * Show the FF GUI. This is called when FF is
 * coming out of iconification state.
 *
 */

BOOL ShowGUI( void )
{
  if (OpenMainWindow())
  {
    AI_Hide();
    AttachImageList();

    LT_SetAttributes(MainWindowHandle, GID_LIST,
      GTLV_Selected,    IconLastSel,
      GTLV_MakeVisible, IconLastSel,
      TAG_DONE);

    PrintStatus("Welcome back to FloppyFlux!", NULL);

    Iconified = FALSE;
  }
  else Iconified = TRUE;

  if (Iconified)
  {
    return FALSE;
  }
  else
  {
    return TRUE;
  }
}

/*************************************************
 *
 * Access the AppIcon that FF is going to use for
 * iconification.
 *
 */

struct DiskObject *DiskObj = NULL;

struct DiskObject *AI_GetDiskObject( void )
{
  UBYTE PrgNameBuf[256];

  BOOL success = FALSE;

  /* Locate FloppyFluxes' program name */

  if (WBStartupMsg)
  {
    UBYTE *WBName = WBStartupMsg->sm_ArgList->wa_Name;

    if (WBName)
    {
      strcpy((UBYTE *) &PrgNameBuf, WBName);
      success = TRUE;
    }
  }
  else
  {
    if (GetProgramName((UBYTE *) &PrgNameBuf, 256L))
    {
      success = TRUE;
    }
    else FFDOSError("Failed to get program's name!", NULL);
  }

  /* Load FloppyFluxes' icon and convert it to an AppIcon */

  if (success)
  {
    if (DiskObj = GetDiskObjectNew( (UBYTE *) &PrgNameBuf ))
    {
      DiskObj->do_Magic = NULL;
      DiskObj->do_Version = NULL;
      DiskObj->do_Gadget.NextGadget = NULL;
      DiskObj->do_Gadget.LeftEdge = NULL;
      DiskObj->do_Gadget.TopEdge = NULL;
      DiskObj->do_Gadget.Activation = NULL;
      DiskObj->do_Gadget.GadgetType = NULL;
      ((struct Image *)DiskObj->do_Gadget.GadgetRender)->LeftEdge = NULL;
      ((struct Image *)DiskObj->do_Gadget.GadgetRender)->TopEdge = NULL;
      ((struct Image *)DiskObj->do_Gadget.GadgetRender)->PlaneOnOff = 0;
      ((struct Image *)DiskObj->do_Gadget.GadgetRender)->NextImage = NULL;
      DiskObj->do_Gadget.GadgetText = NULL;
      DiskObj->do_Gadget.MutualExclude = NULL;
      DiskObj->do_Gadget.SpecialInfo = NULL;
      DiskObj->do_Gadget.GadgetID = NULL;
      DiskObj->do_Gadget.UserData = NULL;
      DiskObj->do_Type = NULL;
      DiskObj->do_DefaultTool = NULL;
      DiskObj->do_ToolTypes = NULL;
      DiskObj->do_CurrentX = NO_ICON_POSITION;
      DiskObj->do_CurrentY = NO_ICON_POSITION;
      DiskObj->do_DrawerData = NULL;
      DiskObj->do_ToolWindow = NULL;
      DiskObj->do_StackSize = NULL;
    }
    else FFError("Call to GetDiskObjectNew() failed!", NULL);
  }
  else FFError("Cannot locate program name!", NULL);

  if (!DiskObj)
  {
    FFError("Failed to get AppIcon object!", NULL);
  }

  return DiskObj;
}

/*************************************************
 *
 * Free the AppIcon that FF is using for
 * iconification.
 *
 */

void AI_FreeDiskObject( void )
{
  if (DiskObj) FreeDiskObject(DiskObj); DiskObj = NULL;
}

/*************************************************
 *
 * Show FF's AppIcon.
 *
 */

BOOL AI_Show( void )
{
  BOOL success = FALSE;

  struct DiskObject *DskO = AI_GetDiskObject();

  if (DskO)
  {
    FFAppIcon = AddAppIcon(0, 0, "FloppyFlux is sleeping", WBMP, NULL, DskO, NULL);

    if (FFAppIcon)
    {
      success = TRUE;
    }
  }
  else
  {
    FFError("Failed to create AppIcon!", NULL);
  }

  return success;
}

/*************************************************
 *
 * Hide FF's AppIcon.
 *
 */

void AI_Hide( void )
{
  if (WBMP)
  {
    FlushMsgPort( WBMP );
  }

  if (FFAppIcon)
  {
    RemoveAppIcon( FFAppIcon );
    FFAppIcon = NULL;
  }

  AI_FreeDiskObject();
}

/*************************************************
 *
 *
 *
 */
