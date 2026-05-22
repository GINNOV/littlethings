/*****************************************************************************
 *
 * COPYRIGHT: Unless otherwise noted, all files are Copyright (c) 1992-1994
 * Commodore-Amiga, Inc. All rights reserved.
 *
 * DISCLAIMER: This software is provided "as is".  No representations or
 * warranties are made with respect to the accuracy, reliability,
 * performance, currentness, or operation of this software, and all use is at
 * your own risk. Neither Commodore nor the authors assume any responsibility
 * or liability whatsoever with respect to your use of this software.
 *
 *****************************************************************************
 * classbase.c
 * Class library initialization
 * Written by David N. Junod
 * modified for fillbar.image by Antonio Manuel Santos
 *
 */

#include <exec/types.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>

#include <clib/intuition_protos.h>

#include <pragmas/intuition_pragmas.h>

/*****************************************************************************/

#include "classbase.h"
#include "classdata.h"


/*****************************************************************************/

VOID CallCHook(void);

/*****************************************************************************/

BOOL __asm CreateClass (register __a6 struct ClassLib *cb)
{
    Class *cl;

    if (cl = MakeClass ("fillbar.image", IMAGECLASS, NULL, sizeof (struct objectData), 0))
    {
        cl->cl_Dispatcher.h_Entry    = (HOOKFUNC)CallCHook;
        cl->cl_Dispatcher.h_SubEntry = (HOOKFUNC)ClassDispatcher;
	cl->cl_Dispatcher.h_Data     = cb;
	cl->cl_UserData              = (ULONG) cb;
	AddClass (cl);
    }

    /* Set the class pointer */
    cb->cb_Library.cl_Class = cl;

    return (BOOL)(cl != NULL);
}


/*****************************************************************************/


BOOL __asm DestroyClass (register __a6 struct ClassLib *cb)
{
    BOOL result;

    if (result = FreeClass (cb->cb_Library.cl_Class))
	cb->cb_Library.cl_Class = NULL;

    return result;
}
