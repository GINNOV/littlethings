/*
**	XModuleGST.c
**
**	Copyright (C) 1994,95 by Bernardo Innocenti
**
**	This is a dummy file used to make the Global Symbol Table for XModule.
*/

#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/nodes.h>
#include <devices/audio.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>
#include <libraries/asl.h>
#include <libraries/commodities.h>
#include <libraries/gadtools.h>
#include <libraries/reqtools.h>
#include <libraries/iffparse.h>
#include <datatypes/soundclass.h>
#include <graphics/rpattr.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <utility/tagitem.h>
#include <rexx/storage.h>
#include <rexx/errors.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/alib_protos.h>
#include <clib/asl_protos.h>
#include <clib/commodities_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/keymap_protos.h>
#include <clib/icon_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/intuition_protos.h>
#include <clib/powerpacker_protos.h>
#include <clib/reqtools_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>

#include <pragmas/asl_pragmas.h>
#include <pragmas/commodities_pragmas.h>
#include <pragmas/datatypes_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/keymap_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/powerpacker_pragmas.h>
#include <pragmas/reqtools_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/wb_pragmas.h>

#include "PattEditClass.h"
#include "XModuleClass.h"

#include "XModule.h"
#include "Gui.h"
