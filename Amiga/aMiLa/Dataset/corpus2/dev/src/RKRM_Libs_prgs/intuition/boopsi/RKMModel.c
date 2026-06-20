;/* RKMModel.c - A simple custom modelclass subclass.
LC -cfist -b1 -y -v -j73 rkmmodel.c
quit ;*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <intuition/cghooks.h>
#include <intuition/icclass.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>

extern struct Library *IntuitionBase, *UtilityBase;

/*************************************************************************************************/
/****************  The attributes defined by this class  *****************************************/
/*************************************************************************************************/
#define RKMMOD_CurrVal  (TAG_USER + 1) /* This attribute is the current value of the model.*******/
                                       /**********************************************************/
#define RKMMOD_Up       (TAG_USER + 2) /* These two are fake attributes that rkmmodelclass *******/
#define RKMMOD_Down     (TAG_USER + 3) /* uses as pulse values to increment/decrement the  *******/
                                       /* rkmmodel's RKMMOD_CurrVal attribute.             *******/
                                       /**********************************************************/
#define RKMMOD_Limit    (TAG_USER + 4) /* This attribute contains the upper bound of the   *******/
                                       /* rkmmodel's RKMMOD_CurrVal.  The rkmmodel has a   *******/
                                       /* static lower bound of zero.                      *******/
/*************************************************************************************************/

#define DEFAULTVALLIMIT 100L /* If the programmer doesn't set               */
                             /* RKMMOD_Limit, it defaults to this.          */
struct RKMModData {
    ULONG currval;       /* The instance data for this class.               */
    ULONG vallimit;
};

/*************************************************************************************************/
/**************************      The functions in this module     ********************************/
/*************************************************************************************************/
void    geta4(void);                                                              /***************/
Class  *initRKMModClass(void);                                                    /***************/
BOOL    freeRKMModClass(Class *);                                                 /***************/
ULONG   dispatchRKMModel(Class *, Object *, Msg);                                 /***************/
void    NotifyCurrVal(Class *, Object *, struct opUpdate *, struct RKMModData *); /***************/
/*************************************************************************************************/

/*************************************************************************************************/
/********************************   Initialize the class    **************************************/
/*************************************************************************************************/
Class   *initRKMModClass(void)                /* Make the class and set     */
{                                             /* up the dispatcher's hook.  */
    Class *cl;
    extern ULONG HookEntry();  /*      <-------   defined in amiga.lib.     */

    if ( cl =  MakeClass( NULL,
                "modelclass", NULL,
                sizeof ( struct RKMModData ),
                0 ))
    {
        cl->cl_Dispatcher.h_Entry = HookEntry;           /* initialize the  */
        cl->cl_Dispatcher.h_SubEntry = dispatchRKMModel; /* cl_Dispatcher   */
                                                         /* Hook.           */
    }
    return ( cl );
}

/*************************************************************************************************/
/*********************************      Free the class     ***************************************/
/*************************************************************************************************/
BOOL freeRKMModClass( Class *cl )
{
    return (FreeClass(cl));
}

/*************************************************************************************************/
/********************************     The class Dispatcher     ***********************************/
/*************************************************************************************************/
ULONG dispatchRKMModel(Class *cl, Object *o, Msg msg)
{
    struct RKMModData *mmd;
    APTR retval = NULL;  /* A generic return value used by this class's methods.  The            */
                         /* meaning of this field depends on the method.  For example,           */
                         /* OM_GET uses this a a boolean return value, while OM_NEW              */
                         /* uses it as a pointer to the new object.                              */
    geta4();    /* SAS/C and Manx function - makes sure A4 contains global data pointer.         */

    switch (msg->MethodID)
    {
        case OM_NEW:     /* Pass message onto superclass first so it can set aside the memory    */
                         /* for the object and take care of superclass instance data.            */
            if (retval = (APTR)DoSuperMethodA(cl, o, msg))
            {            /************************************************************************/
                         /* For the OM_NEW method, the object pointer passed to the dispatcher   */
                         /* does not point to an object (how could it? The object doesn't exist  */
                         /* yet.)  DoSuperMethodA() returns a pointer to a newly created         */
                         /* object. INST_DATA() is a macro defined in <intuition/classes.h>      */
                         /* that returns a pointer to the object's instance data that is local   */
                         /* to this class. For example, the instance data local to this class    */
                         /* is the RKMModData structure defined above.                           */
                         /************************************************************************/
                mmd = INST_DATA(cl, retval);
                mmd->currval = GetTagData(RKMMOD_CurrVal, 0L, /* initialize object's attributes. */
                                          ((struct opSet *)msg)->ops_AttrList);
                mmd->vallimit = GetTagData(RKMMOD_Limit, DEFAULTVALLIMIT,
                                           ((struct opSet *)msg)->ops_AttrList);
            }
            break;
        case OM_SET:
        case OM_UPDATE:
            mmd = INST_DATA(cl, o);
            DoSuperMethodA(cl, o, msg);   /* Let the superclasses set their attributes first.    */
            {
                struct TagItem *tstate, *ti;    /* grab some temp variables off of the stack.    */

                ti = ((struct opSet *)msg)->ops_AttrList;
                tstate = ti;

                        /* Step through all of the attribute/value pairs in the list.  Use the   */
                        /* utility.library tag functions to do this so they can properly process */
                        /* special tag IDs like TAG_SKIP, TAG_IGNORE, etc.                       */

                while (ti = NextTagItem(&tstate))    /* Step through all of the attribute/value  */
                {                 /* pairs in the list. Use the utility.library tag functions    */
                                  /* to do this so they can properly process special tag IDs     */
                                  /* like TAG_SKIP, TAG_IGNORE, etc.                             */
                    switch (ti->ti_Tag)
                    {
                        case RKMMOD_CurrVal:
                            if ((ti->ti_Data) > mmd->vallimit) ti->ti_Data =
                                    mmd->vallimit;
                            mmd->currval = ti->ti_Data;
                            NotifyCurrVal(cl, o, msg, mmd);
                            retval = (APTR)1L;  /* Changing RKMMOD_CurrVal can cause a visual    */
                            break;              /* change to gadgets in the rkmmodel's broadcast */
                                                /* list.  The rkmmodel has to tell the applica-  */
                                                /* tion by returning a value besides zero.       */
                        case RKMMOD_Up:
                            mmd->currval++;

                                 /* Make sure the current value is not greater than value limit. */
                            if ((mmd->currval) > mmd->vallimit) mmd->currval = mmd->vallimit;
                            NotifyCurrVal(cl, o, msg, mmd);
                            retval = (APTR)1L;  /* Changing RKMMOD_Up can cause a visual         */
                            break;              /* change to gadgets in the rkmmodel's broadcast */
                                                /* list.  The rkmmodel has to tell the applica-  */
                                                /* tion by returning a value besides zero.       */
                        case RKMMOD_Down:
                            mmd->currval--;
                                    /* Make sure currval didn't go negative. */
                            if ((LONG)(mmd->currval) == -1L)
                                mmd->currval = 0L;
                            NotifyCurrVal(cl, o, msg, mmd);
                            retval = (APTR)1L;  /* Changing RKMMOD_Down can cause a visual       */
                            break;              /* change to gadgets in the rkmmodel's broadcast */
                                                /* list.  The rkmmodel has to tell the applica-  */
                                                /* tion by returning a value besides zero.       */
                        case RKMMOD_Limit:
                            mmd->vallimit = ti->ti_Data; /* Set the limit.  Note that this does  */
                            break;                       /* not do bounds checking on the        */
                                                         /* current RKMModData.currval value.    */
                    }
                }
            }
            break;
        case OM_GET:                     /* The only attribute that is "gettable" in this        */
            mmd = INST_DATA(cl, o);      /* class or its superclasses is RKMMOD_CurrVal.         */
            if ((((struct opGet *)msg)->opg_AttrID) == RKMMOD_CurrVal)
            {
                *(((struct opGet *)msg)->opg_Storage) = mmd->currval;
                retval = (Object *)TRUE;
            }
            else retval = (APTR)DoSuperMethodA(cl, o, msg);
            break;
        default:       /* rkmmodelclass does not recognize the methodID, so let the superclass's */
                       /* dispatcher take a look at it.                                          */
            retval = (APTR)DoSuperMethodA(cl, o, msg);
            break;
    }
    return((ULONG)retval);
}



void NotifyCurrVal(Class *cl, Object *o, struct opUpdate *msg, struct RKMModData *mmd)
{
    struct TagItem tt[2];

    tt[0].ti_Tag = RKMMOD_CurrVal; /* make a tag list.  */
    tt[0].ti_Data = mmd->currval;
    tt[1].ti_Tag = TAG_DONE;
                                /* If the RKMMOD_CurrVal changes, we want everyone to know about */
    DoSuperMethod(cl, o,        /* it. Theoretically, the class is supposed to send itself a     */
             OM_NOTIFY,         /* OM_NOTIFY message. Because this class lets its superclass     */
             tt,                /* handle the OM_NOTIFY message, it skips the middleman and      */
             msg->opu_GInfo,    /* sends the OM_NOTIFY directly to its superclass.               */

             ((msg->MethodID == OM_UPDATE) ? (msg->opu_Flags) : 0L)); /* If this is an OM_UPDATE */
                                /* method, make sure the part the OM_UPDATE message adds to the  */
                                /* OM_SET message gets added.  That lets the dispatcher handle   */
}                               /* OM_UPDATE and OM_SET in the same case.                        */
