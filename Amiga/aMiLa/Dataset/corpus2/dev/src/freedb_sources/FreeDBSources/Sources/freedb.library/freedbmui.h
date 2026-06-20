
#include <proto/muimaster.h>
#include <proto/intuition.h>
#include <mui/freedb_mcc.h>
#include <libraries/gadtools.h>
#include "freedb.h"

/***********************************************************************/

struct appMsg
{
    struct Message  link;
    STRPTR          device;
    UWORD           unit;
    UBYTE           lun;
    STRPTR          prg;
    STRPTR          ver;
    ULONG           flags;
};

enum
{
    AMFGLS_DeviceName    =  1,
    AMFGLS_UseSpace      =  2,
    AMFGLS_NoRequester   =  4,
    AMFGLS_GetDisc       =  8,
    AMFGLS_GetDiscLocal  = 16,
    AMFGLS_GetDiscRemote = 32,
};

/***********************************************************************/

#define FREE_TAG(n) ((int)(0xfec902bc+(n)))

/* FreeDBApp methods */
#define MUIM_FreeDB_App_Setup   FREE_TAG(0)
#define MUIM_FreeDB_App_About   FREE_TAG(1)
#define MUIM_FreeDB_App_Config  FREE_TAG(2)

struct MUIP_FreeDB_App_Setup
{
    ULONG   MethodID;
    Object  *disc;
    Object  *window;
};

#define MUIA_FreeDB_App_Changed FREE_TAG(0)

#define FreeDBAppObject NewObject(rexxLibBase->appClass->mcc_Class,NULL

#define MTITLE(t)   {NM_TITLE,(STRPTR)(t),0,0,0,NULL}
#define MITEM(t)    {NM_ITEM,(STRPTR)(t),0,0,0,(APTR)(t)}
#define MBAR        {NM_ITEM,(STRPTR)NM_BARLABEL,0,0,0,NULL}
#define MEND        {NM_END,NULL,0,0,0,NULL}

/***********************************************************************/

ULONG DoSuperMethodA(struct IClass *,APTR,APTR);
ULONG DoSuperMethod(struct IClass *,APTR ,ULONG,...);
ULONG DoMethodA(APTR,APTR);
ULONG DoMethod(APTR,unsigned long MethodID,...);
ULONG CoerceMethodA(APTR,APTR,APTR);
ULONG CoerceMethod(APTR,APTR,long MethodID,...);
ULONG SetSuperAttrs(APTR,APTR,ULONG,...);

/* appclass.c */
BOOL ASM initAppClass ( void );

/* freedb.c */
void request ( Object *app , Object *win , char *format , ...);
APTR SAVEDS ASM FreeDBCreateAppA ( REG (a0 )struct TagItem *attrs );

/* freedbproc.c */
void SAVEDS FreeDB ( void );

/***********************************************************************/
