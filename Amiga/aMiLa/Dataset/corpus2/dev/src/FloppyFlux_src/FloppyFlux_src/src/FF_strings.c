
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_strings.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Assorted strings for FloppyFlux
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_STRINGS_C

/* Created: Wed/28/Apr/1999 */

#include <FF_include.h>

/*************************************************
 *
 * Function protos
 *
 */

Prototype UBYTE *GetFFStr( ULONG SID );

/*************************************************
 *
 * Data protos
 *
 */

Prototype UBYTE *Strings[];

/*************************************************
 *
 * Lookup and return a FloppyFlux string.
 * 
 */

UBYTE *EmptyStr = "";

UBYTE *GetFFStr( ULONG SID )
{
  if ( SID >= SID_AMOUNT )
  {
    return EmptyStr;
  }
  else
  {
    return Strings[SID];
  }
}

/*************************************************
 *
 * Strings, one day all FF strings will end up in
 * this array :) Use GetFFStr() to look'em up.
 *
 */

UBYTE *Strings[] = 
{
  /* SID_DF0 */ "DF0:",
  /* SID_DF1 */ "DF1:",
  /* SID_DF2 */ "DF2:",
  /* SID_DF3 */ "DF3:",

  /* SID_NOFIBMEM    */ "Failed to allocate FileInfoBlock!",
  /* SID_NOOBJECT    */ "Failed to locate object!",
  /* SID_NOCACHEDIR  */ "Failed to locate cache drawer!",
  /* SID_NOCACHEFILE */ "Failed to locate cache file!",
  /* SID_BADEXAMINE  */ "Failed to examine an object!"

};

/*************************************************
 *
 * 
 *
 */
