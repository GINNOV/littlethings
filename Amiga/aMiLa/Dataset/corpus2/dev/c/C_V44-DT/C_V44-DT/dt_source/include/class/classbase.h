/*
**      $VER: classbase.h 44.1 (11.2.2006)
**
**      definition of ClassBase
**
**      (C) Copyright 1996-2006 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifndef CLASS_CLASSBASE_H
#define CLASS_CLASSBASE_H

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif /* DOS_DOS_H */

#include <intuition/classes.h>
#include <graphics/rastport.h>

struct ClassBase
{
 struct Library          cb_LibNode;
 APTR                    cb_SegList;
 Class			*cb_Class;

 struct ExecBase	*cb_SysBase;
 struct DosLibrary      *cb_DOSBase;
 struct IntuitionBase   *cb_IntuitionBase;
 struct GfxBase 	*cb_GfxBase;
 struct Library		*cb_UtilityBase;
 struct Library		*cb_IFFParseBase;
 struct Library		*cb_DataTypesBase;
 struct Library		*cb_SuperClassBase;

 struct SignalSemaphore  cb_DTSemaphore;
 ULONG                  *cb_Methods;
};

#endif /* CLASS_CLASSBASE_H */
