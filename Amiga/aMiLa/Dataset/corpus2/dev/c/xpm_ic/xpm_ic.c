/* ========================================================================== *
 * $Id$
 * -------------------------------------------------------------------------- *
 * Implementation of a XPM BOOPSI image class.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */


#include "methods.h"

#include <images/xpm.h>
#include <clib/xpm_protos.h>

#include <proto/intuition.h>


/* ========================================================================== */


static ULONG __saveds __asm
XpmClassDispatch (
    register __a0 Class   *cl,
    register __a2 Object  *obj,
    register __a1 Msg      msg)
{
    ULONG   retval = 1;

    switch (msg->MethodID)
    {
    case OM_NEW:
	retval = DoSuperMethodA (cl, obj, msg);
	if (retval != NULL)
	{
	    if (!XpmMethodNew (cl, (struct Image *)retval, (struct opSet *)msg))
	    {
		CoerceMethod (cl, (Object *)retval, OM_DISPOSE);
		retval = NULL;
	    }
	}
	break;
    case OM_DISPOSE:
	XpmMethodDispose (cl, obj, msg);
	retval = DoSuperMethodA (cl, obj, msg);
	break;
    case OM_SET:
	DoSuperMethodA (cl, obj, msg);
	XpmMethodSet (cl, (struct Image *)obj, (struct opSet *)msg);
	break;
    case OM_GET:
	if (!XpmMethodGet (cl, obj, (struct opGet *)msg))
	    retval = DoSuperMethodA (cl, obj, msg);
	break;
    case IM_DRAW:
    case IM_DRAWFRAME:
	XpmMethodDraw (cl, (struct Image *)obj, (struct impDraw *)msg);
	break;
    case IM_HITFRAME:
	retval = XpmMethodHitFrame (cl, (struct Image *)obj,
				    (struct impHitTest *)msg);
	break;
    case IM_ERASEFRAME:
	XpmMethodEraseFrame (cl, (struct Image *)obj, (struct impErase *)msg);
	break;
    default:
	retval = DoSuperMethodA (cl, obj, msg);
	break;
    }

    return retval;
}


/* ========================================================================== */


/****** xpm_ic/CreateXpmClass *************************************************
*
*   NAME
*       CreateXpmClass -- Create the XPM image class.
*
*   SYNOPSIS
*       xpm_class = CreateXpmClass()
*
*       Class *CreateXpmClass(VOID);
*
*   FUNCTION
*       This function is only available in the compiler linker library
*       xpm_ic.lib. It is not in the runtime linked version of the class,
*       xpm.image.
*
*       This function creates the XPM class and returns a pointer to it
*       that can be used in a call to NewObject(). An application using
*       this class will usually call this function in its initialization
*       and dispose of the class with DisposeXpmClass() just before exit.
*
*   INPUTS
*       Nothing.
*
*   RESULT
*       xpm_class - Pointer to the XPM image class or NULL if the class
*           could not be created.
*
*   SEE ALSO
*       DisposeXpmClass()
*
*******************************************************************************
*
*/
Class *
CreateXpmClass (VOID)
{
    Class  *cl;

    cl = MakeClass (NULL, "imageclass", NULL, sizeof (XpmClassData), 0);
    if (cl != NULL)
    {
	cl->cl_Dispatcher.h_SubEntry = NULL;
	cl->cl_Dispatcher.h_Entry = (HOOKFUNC)XpmClassDispatch;
	cl->cl_Dispatcher.h_Data = NULL;
    }

    return cl;
}


/****** xpm_ic/DisposeXpmClass ************************************************
*
*   NAME
*       DisposeXpmClass -- Dispose of the XPM image class.
*
*   SYNOPSIS
*       success = DisposeXpmClass(xpm_class)
*
*       BOOL DisposeXpmClass(Class *);
*
*   FUNCTION
*       This function is only available in the compiler linker library
*       xpm_ic.lib. It is not in the runtime linked version of the class,
*       xpm.image.
*
*       Frees up the XPM image class.
*
*   INPUTS
*       xpm_class - Pointer to the XPM image class.
*
*   RESULT
*       success - Whether or not the class was successfully disposed.
*
*   SEE ALSO
*       CreateXpmClass()
*
*******************************************************************************
*
*/
BOOL
DisposeXpmClass (
    Class  *cl)
{
    return FreeClass (cl);
}
