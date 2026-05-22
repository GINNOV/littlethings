/*
**      $VER: SampleFuncs.c 37.12 (29.6.97)
**
**      Demo functions for example.library
**
**      (C) Copyright 1996-97 Andreas R. Kleinert
**      All Rights Reserved.
*/

#define __USE_SYSBASE        // perhaps only recognized by SAS/C

#include <exec/types.h>
#include <exec/memory.h>

#ifdef __MAXON__
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#else
#include <proto/exec.h>
#include <proto/intuition.h>
#include <intuition/intuition.h>
#endif

#include "compiler.h"

 /* Please note, that &ExampleBase always resides in register __a6 as well,
    but if we don't need it, we need not reference it here.

    Also note, that registers a0, a1, d0, d1 always are scratch registers,
    so you usually should only *pass* parameters there, but make a copy
    directly after entering the function. To avoid problems of kind
    "implementation defined behaviour", you should make a copy of A6 too,
    when it is actually used.

    In this example case, scratch register saving would not have been necessary
    (since there are no other function calls inbetween), but we did it nevertheless.
  */

ULONG __saveds ASM EXF_TestRequest( register __d1 UBYTE *title_d1 GNUCREG(d1), register __d2 UBYTE *body GNUCREG(d2), register __d3 UBYTE *gadgets GNUCREG(d3))
{
 UBYTE *title = title_d1;

 struct EasyStruct __aligned estr;

 estr.es_StructSize   = sizeof(struct EasyStruct);
 estr.es_Flags        = NULL;
 estr.es_Title        = title;
 estr.es_TextFormat   = body;
 estr.es_GadgetFormat = gadgets;

 return( (ULONG) EasyRequestArgs(NULL, &estr, NULL, NULL));
}
