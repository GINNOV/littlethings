
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_winsettings.h
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

#ifndef FLOPPYFLUX_WINSETTINGS_H
#define FLOPPYFLUX_WINSETTINGS_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */

struct PackerListNode
{
  struct Node PLN_Node;       /* ln_Name field contains the method name */
  UWORD       PLN_Pad;        /* LONG Alignment */
  ULONG       PLN_NodeNumber; /* Number of this node (Used for internal ref, etc.) */

  UBYTE       PLN_ViewString[256];
  UBYTE       PLN_Method[6];
  UBYTE       PLN_Name[24];
  UBYTE       PLN_LongName[32];
  UBYTE       PLN_Description[80];
};

#define PLN_Size sizeof(struct PackerListNode) /* Easy allocs! */

#endif /* FLOPPYFLUX_WINSETTINGS_H */
