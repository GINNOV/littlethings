
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_configio.h
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : 
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#ifndef FLOPPYFLUX_CONFIGIO_H
#define FLOPPYFLUX_CONFIGIO_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */

#define FFCFG_ID        "FFLXCFG"
#define FFCFG_VERSION   1
#define FFCFG_DEFMETHOD "FAST"
#define FFCFG_PATH      "PROGDIR:FloppyFlux.config"

struct FFConfig
{
  UBYTE FFC_ID[sizeof(FFCFG_ID)];    /* v1, FFLXCFG               */
  UBYTE FFC_Version;                 /* v1, FFCONFIG_VERSION      */ 
  BOOL  FFC_UseXPK;                  /* v1, TRUE or FALSE         */
  UWORD FFC_XPKMode;                 /* v1, 1 - 100               */
  UBYTE FFC_XPKMethod[6];            /* v1, NUKE, RAKE, FAST, etc */
};

/*************************************************
 *
 * Data protos
 *
 */

extern struct FFConfig FFC;

#endif /* FLOPPYFLUX_CONFIGIO_H */
