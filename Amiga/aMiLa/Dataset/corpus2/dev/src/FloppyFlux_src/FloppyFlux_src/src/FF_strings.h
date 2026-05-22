
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_strings.h
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

#ifndef FLOPPYFLUX_STRINGS_H
#define FLOPPYFLUX_STRINGS_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */

/* String IDs (SIDs) The order of these MUST
   reflect the array in FF_strings.c! */

enum /* These numbers MUST be parallel with the array in FF_strings.c */
{
  SID_DF0 = 0,
  SID_DF1,
  SID_DF2,
  SID_DF3,

  SID_NOFIBMEM,
  SID_NOOBJECT,
  SID_NOCACHEDIR,
  SID_NOCACHEFILE,
  SID_BADEXAMINE,

  SID_AMOUNT
};

#endif /* FLOPPYFLUX_STRINGS_H */
