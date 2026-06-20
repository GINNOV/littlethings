/*
**      $VER: classbase.h 43.21 (18.3.2008)
**
**      definition of ClassBase
**
**      (C) Copyright 1996-2008 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifndef CLASS_CLASSBASE_H
#define CLASS_CLASSBASE_H

#include <intuition/classes.h>

#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <exec/semaphores.h>
#include <exec/execbase.h>
#include <exec/alerts.h>
#include <exec/libraries.h>
#include <exec/interrupts.h>
#include <exec/resident.h>
#include <dos/dos.h>

struct ClassBase
{
 struct Library          cb_LibNode;
 APTR                    cb_SegList;
 Class                  *cb_Class;

 struct ExecBase        *cb_SysBase;
 struct DosLibrary      *cb_DOSBase;
 struct IntuitionBase   *cb_IntuitionBase;
 struct GfxBase         *cb_GfxBase;
 struct Library         *cb_UtilityBase;
 struct Library         *cb_IFFParseBase;
 struct Library         *cb_DataTypesBase;
 struct Library         *cb_SuperClassBase;
};

#endif /* CLASS_CLASSBASE_H */
