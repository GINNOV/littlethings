
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_configio.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Config file control routines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_CONFIGIO_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype void SetConfigDefaults( void );
Prototype void LoadConfig( void );
Prototype void SaveConfig( void );

/*************************************************
 *
 * Data protos
 *
 */

Prototype struct FFConfig FFC;

/*************************************************
 *
 * Data
 *
 */

struct FFConfig FFC;

/*************************************************
 *
 * Set the default settings for the configuration
 * file. This function is normally called when the
 * config file does not exist or is not valid.
 *
 */

void SetConfigDefaults( void )
{
  clrmem(&FFC, sizeof(struct FFConfig));

  CopyMem(FFCFG_ID, &FFC.FFC_ID, sizeof(FFCFG_ID));
  FFC.FFC_Version = FFCFG_VERSION;
  FFC.FFC_UseXPK  = FALSE;
  FFC.FFC_XPKMode = 100;
  CopyMem(FFCFG_DEFMETHOD, &FFC.FFC_XPKMethod, sizeof(FFCFG_DEFMETHOD));
}

/*************************************************
 *
 * Attempt to load and check the config file.
 *
 */

void LoadConfig( void )
{
  BPTR CfgHandle;
  BOOL CfgValid = FALSE;

  if (CfgHandle = Open(FFCFG_PATH, MODE_OLDFILE))
  {
    if (Read(CfgHandle, &FFC, sizeof(struct FFConfig)) == sizeof(struct FFConfig))
    {
      if (!memcmp(&FFC.FFC_ID, FFCFG_ID, sizeof(FFCFG_ID)))
      {
        CfgValid = TRUE;
      }
      else FFError("Invalid config file!", NULL);
    }
    else FFDOSError(NULL, NULL);

    Close(CfgHandle);
  }
  else if (IoErr() != ERROR_OBJECT_NOT_FOUND)
  {
    FFDOSError("Unable to access config file!", NULL);
  }

  if (!CfgValid)
  {
    SetConfigDefaults();

    PrintStatus("Using the default configuration settings", NULL);
  }
}

/*************************************************
 *
 * Attempt to save the config file.
 *
 */

void SaveConfig( void )
{
  BPTR CfgHandle;
  BPTR ValidWrite = FALSE;

  if (CfgHandle = Open(FFCFG_PATH, MODE_NEWFILE))
  {
    if (Write(CfgHandle, &FFC, sizeof(struct FFConfig)) == sizeof(struct FFConfig))
    {
      ValidWrite = TRUE;
    }
    else FFDOSError(NULL, NULL);

    Close(CfgHandle);
  }
  else FFDOSError(NULL, NULL);

  if (!ValidWrite)
  {
    if (!DeleteFile(FFCFG_PATH))  /* Delete config on error */
    {
      FFDOSError(NULL, NULL);
    }
  }
}

/*************************************************
 *
 * 
 *
 */
