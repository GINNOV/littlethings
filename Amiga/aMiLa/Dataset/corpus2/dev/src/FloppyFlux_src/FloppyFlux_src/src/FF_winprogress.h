
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_winprogress.h
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

#ifndef FLOPPYFLUX_WINPROGRESS_H
#define FLOPPYFLUX_WINPROGRESS_H

/* Created: Wed/28/Apr/1999 */

/*************************************************
 *
 * Defines
 *
 */

struct ProgressHandle
{
  struct LayoutHandle *PH_Handle;
  struct Window *PH_Window;
  ULONG PH_TotalUnits;
};

#endif /* FLOPPYFLUX_WINPROGRESS_H */
