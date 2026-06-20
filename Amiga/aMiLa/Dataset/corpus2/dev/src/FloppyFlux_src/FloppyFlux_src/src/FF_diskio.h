
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_diskio.h
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

#ifndef FLOPPYFLUX_DISKIO_H
#define FLOPPYFLUX_DISKIO_H

/* Created: Wed/28/Apr/1999 */


/*************************************************
 *
 * Defines
 *
 */

/* All Amiga DD trackdisks have 160 tracks (80 upper/80 lower), each
   track contains 11 sectors, each sector is 512 (TD_SECTOR) bytes long. */

#define STDIMAGESIZE (TD_SECTOR * 11) * 160

enum /* Used by PromptForDisk() */
{
  PROMPTMODE_READ = 0, PROMPTMODE_WRITE
};

#endif /* FLOPPYFLUX_DISKIO_H */
