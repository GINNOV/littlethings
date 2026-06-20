
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_main.h
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

#ifndef FLOPPYFLUX_MAIN_H
#define FLOPPYFLUX_MAIN_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */


/*************************************************
 *
 * Assorted defines
 *
 */

#define EMAILADDR   "andrew.ab2000@bigfoot.com"
#define WWWURL      "http://www.homeusers.prestel.co.uk/ab2000"
#define YEAR        "1999"
#define SAFETY      30L       /* Sometimes used on allocations */
#define FFSTACKSIZE (1024*16) /* 16KB of stack space for FF */

/*************************************************
 *
 * Gadget and menu ids.
 *
 */

enum
{
  /* Main window gadgets */

  GID_DEVICE = 0xABCD, /* Note: We can't start from zero! */
  GID_READ,
  GID_WRITE,
  GID_LIST,
  GID_EDIT,
  GID_DELETE,
  GID_DELETEALL,
  GID_INFO,
  GID_RESCAN,
  GID_STATUS,
  GID_HIDE,
  GID_ABOUT,
  GID_SETTINGS,
  GID_QUIT,

  /* Edit image attr window gadgets */

  GIDIAT_NAME,
  GIDIAT_COMMENT,
  GIDIAT_ACCEPT,
  GIDIAT_CANCEL,

  /* Progress window gadgets */

  GIDPRO_GUAGE,
  GIDPRO_ABORT,

  /* Info window gadgets */

  GIDINF_TEXTBOX,
  GIDINF_CONTINUE,

  /* Settings window gadgets */

  GIDSET_COMPDISKIMGS,
  GIDSET_METHODLIST,
  GIDSET_XPKINFOBOX,
  GIDSET_XPKCOMPMODE,
  GIDSET_SAVE,
  GIDSET_USE,
  GIDSET_CANCEL

};

enum
{
  /* Main window menus */

  MID_INFO = 0xABCD,
  MID_SETTINGS,

  MID_HIDE,

  MID_ABOUT,
  MID_QUIT,

  MID_IMPORT,
  MID_EXPORT,

  MID_PACKSELECTED,
  MID_UNPACKSELECTED,

  MID_PACKALL,
  MID_UNPACKALL
};

/*************************************************
 *
 * Disk image dir cache defines.
 *
 */

#define IMAGEDIRNAME   "PROGDIR:DiskImages"
#define CACHEFILENAME  IMAGEDIRNAME ".cache"

/*************************************************
 *
 * FloppyFlux port defines.
 *
 */

#define FFPORTNAME "FloppyFlux_interface"

struct FFMsgPort
{
  struct MsgPort ffmp_MsgPort;
  UWORD          ffmp_Version;
  UWORD          ffmp_Revision;
};

#endif /* FLOPPYFLUX_MAIN_H */
