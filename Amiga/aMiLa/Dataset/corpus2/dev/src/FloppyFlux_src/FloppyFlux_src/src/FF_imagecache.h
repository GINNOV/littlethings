
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_imagecache.h
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Tuesday 01-Jun-99 23:06:18
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : 
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#ifndef FLOPPYFLUX_IMAGECACHE_H
#define FLOPPYFLUX_IMAGECACHE_H

/* Created: Tue/1/Jun/1999 */

#define CACHEFHBUFSIZE (1024*32)

#define CACHEHDR_ID  "FFLXCACH" /* Magic ID */
#define CACHEHDR_VER 1          /* Cache file format version */

struct CacheHeader
{
  UBYTE CHDR_ID[8];
  ULONG CHDR_Length;
  UWORD CHDR_FmtVer;
  UWORD CHDR_Flags;
  ULONG CHDR_Amount;
};

/* Note: All tags are aligned on a 32 bit boundary */

struct CacheTag
{
  UWORD CTAG_TagID;      /* The datablock tag id */
  UWORD CTAG_Flags;      /* Currently always 0 */
  ULONG CTAG_Length;     /* Length of data the tag represents */
  ULONG CTAG_CheckSum;   /* Currently always 0 */
};

enum 
{
  TAGID_DUMMY = 'AB',  /* My initials :) */
  TAGID_NAMES,
  TAGID_COMMENTS,
  TAGID_LENGTHS,
  TAGID_ENDTAG,        /* No more tags follow */
  TAGID_OBSOLETE,      /* PACKSTAT */
  TAGID_PACKIDS
};


/*
 * A QUICK CACHE TAG SPEC
 * ~~~~~~~~~~~~~~~~~~~~~~
 * The cache file contains a series of tags. Each tag represents a block of
 * data. The actual format of the data block (aka chunk) is determined by
 * the tag ID. Tags are similar to IFF chunks. Listed below are the current
 * tag IDs supported.
 *
 * TAGID_NAMES
 *  
 *   This chunk contains a list of disk image filenames.  The amount of 
 *   filenames is determined by the CHDR_Amount field in the CacheHeader.
 *
 * TAGID_COMMENTS
 *
 *   This chunk contains a list of disk image comments.  The amount of 
 *   comments is determined by the CHDR_Amount field in the CacheHeader.
 *
 * TAGID_LENGTHS
 *
 *   The first ULONG of this chunk stores the amount of ULONGs that follows
 *   it. Each of these ULONGs contains the disk image lengths.           
 *
 * TAGID_ENDTAG
 *
 *   When you encounter this tag, you'll know that no more tags follow.
 *
 * TAGID_PACKIDS 
 *
 *   The first ULONG of this chunk stores the amount of ULONGs that follow
 *   it. Each of these ULONGs contains the XPK method IDs (eg: RAKE) else
 *   a 0 or a -1. The 0 means that the entry is not packed and a -1 means
 *   that the pack status of this entry is undetermined.
 *   
 * NOTES
 * ~~~~~
 * All of the entries in the data blocks are parallel.
 *
 * STRING FORMAT
 * ~~~~~~~~~~~~~
 * All strings are encoded one after the other like this...
 *
 * At offset 0, is a UBYTE that indicates the length of the
 *  string that follows (this value includes the NULL).
 *
 * At offset 1 follows the NULL-terminated string.
 *
 */

#endif /* FLOPPYFLUX_IMAGECACHE_H */
