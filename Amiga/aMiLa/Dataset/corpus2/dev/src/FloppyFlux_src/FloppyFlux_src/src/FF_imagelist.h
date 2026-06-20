
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_imagelist.h
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

#ifndef FLOPPYFLUX_IMAGELIST_H
#define FLOPPYFLUX_IMAGELIST_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */

struct ImageEntry
{
  struct Node IE_Node;
  UWORD       IE_Reserved; /* BOOL        IE_Packed; */
  ULONG       IE_Size;
  ULONG       IE_PackID;
  ULONG       IE_AZero;
  UBYTE       IE_ViewString[256];
  UBYTE       IE_Name[128];
  UBYTE       IE_Comment[128];
  UBYTE       IE_FullPath[256];
};

#endif /* FLOPPYFLUX_IMAGELIST_H */

