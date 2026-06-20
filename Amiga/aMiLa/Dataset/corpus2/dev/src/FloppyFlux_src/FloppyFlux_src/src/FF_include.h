
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_include.h
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Global defines
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#ifndef FLOPPYFLUX_INCLUDE_H
#define FLOPPYFLUX_INCLUDE_H

/* Created: Wed/28/Apr/1999 */

#define DEFXPKCHUNKSIZE (1024*128)

#define Prototype extern
#define Local static

#include "FloppyFlux_rev.h"

#include <ainc:system.h> /* Special pre-compiled header */

extern struct ExecBase *SysBase;
extern struct DosLibrary *DOSBase;
extern struct Library *GadToolsBase;
extern struct Library *IntuitionBase;
extern struct Library *UtilityBase;
extern struct Library *AslBase;
extern struct Library *WorkbenchBase;
extern struct Library *IconBase;

#include <clib/alib_protos.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/asl_protos.h>
#include <clib/wb_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/icon_pragmas.h>

#include <proto/xpkmaster.h>
#include <xpk/xpk.h>

/* ANSI */

#include <stdio.h>
#include <string.h>

/* FloppyFlux header files */

#ifndef FLOPPYFLUX_CONFIGIO_H
#include <FF_configio.h>
#endif /* FLOPPYFLUX_CONFIGIO_H */

#ifndef FLOPPYFLUX_IMAGELIST_H
#include <FF_imagelist.h>
#endif /* FLOPPYFLUX_IMAGELIST_H */

#ifndef FLOPPYFLUX_ROUTINES_H
#include <FF_routines.h>
#endif /* FLOPPYFLUX_ROUTINES_H */

#ifndef FLOPPYFLUX_DISKIO_H
#include <FF_diskio.h>
#endif /* FLOPPYFLUX_DISKIO_H */

#ifndef FLOPPYFLUX_WINPROGRESS_H
#include <FF_winprogress.h>
#endif /* FLOPPYFLUX_WINPROGRESS_H */

#ifndef FLOPPYFLUX_WININFO_H
#include <FF_wininfo.h>
#endif /* FLOPPYFLUX_WININFO_H */

#ifndef FLOPPYFLUX_MAIN_H
#include <FF_main.h>
#endif /* FLOPPYFLUX_MAIN_H */

#ifndef FLOPPYFLUX_WINSETTINGS_H
#include <FF_winsettings.h>
#endif /* FLOPPYFLUX_WINSETTINGS_H */

#ifndef FLOPPYFLUX_STRINGS_H
#include <FF_strings.h>
#endif /* FLOPPYFLUX_STRINGS_H */

#ifndef FLOPPYFLUX_WINMAIN_H
#include <FF_winmain.h>
#endif /* FLOPPYFLUX_WINMAIN_H */

#ifndef FLOPPYFLUX_CONFIGIO_H
#include <FF_configio.h>
#endif /* FLOPPYFLUX_CONFIGIO_H */

#ifndef FLOPPYFLUX_WINGETSTR_H
#include <FF_wingetstr.h>
#endif /* FLOPPYFLUX_WINGETSTR_H */

#ifndef FLOPPYFLUX_IMAGECACHE_H
#include <FF_imagecache.h>
#endif /* FLOPPYFLUX_IMAGECACHE_H */

#ifndef FLOPPYFLUX_ICONIFY_H
#include <FF_iconify.h>
#endif /* FLOPPYFLUX_ICONIFY_H */

#ifndef FLOPPYFLUX_WB_H
#include <FF_wb.h>
#endif /* FLOPPYFLUX_WB_H */

/* Notes: It's important that we include this last, so that the compiler can
          resolve all structures that are seen in the protos. */

#include <FF_protos.h>

#include <GTLayout_support.h>

#endif /* FLOPPYFLUX_INCLUDE_H */
