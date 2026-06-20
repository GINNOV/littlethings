#ifndef _CLASS_H
#define _CLASS_H

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/muimaster.h>
#include <proto/utility.h>
#include <proto/locale.h>
#include <proto/freedb.h>
#include <proto/intuition.h>
#include <mui/Textinput_mcc.h>
#include <mui/NList_mcc.h>
#include <mui/NListview_mcc.h>
#include <string.h>
#include <stdlib.h>
#include "base.h"
#include "msg.h"

/***********************************************************************/

#define SysBase         (libBase->sysBase)
#define DOSBase         (libBase->dosBase)
#define IntuitionBase   (libBase->intuitionBase)
#define UtilityBase     (libBase->utilityBase)
#define LocaleBase      (libBase->localeBase)
#define GfxBase         (libBase->gfxBase)
#define MUIMasterBase   (libBase->muiMasterBase)
#define FreeDBBase      (libBase->freeDBBase)

extern struct libBase *libBase;
extern STRPTR *strings;

/***********************************************************************/
/*
** Attributes
*/

#define MUIA_FreeDB_Config_Done FREEDB_TAG(70)

/***********************************************************************/
/*
** Methods
*/

#define FREEDB_TAG(n)   ((int)(0xfec90258+(n)))

#define MUIM_FreeDB_SitesList_ChangeActive  FREEDB_TAG(50) /* Private */
#define MUIM_FreeDB_SitesList_InsertSites   FREEDB_TAG(51) /* Private */
#define MUIM_FreeDB_SitesList_Add           FREEDB_TAG(52) /* Private */
#define MUIM_FreeDB_SitesList_GetActive     FREEDB_TAG(53)

#define MUIM_FreeDB_Config_HandleEvent      FREEDB_TAG(60) /* Private */
#define MUIM_FreeDB_Config_ChangeEdit       FREEDB_TAG(61) /* Private */
#define MUIM_FreeDB_Config_EditChange       FREEDB_TAG(62) /* Private */

#define MUIM_FreeDB_Config_Load             FREEDB_TAG(70)
#define MUIM_FreeDB_Config_Break            FREEDB_TAG(71)
#define MUIM_FreeDB_Config_Save             FREEDB_TAG(72)
#define MUIM_FreeDB_Config_GetSites         FREEDB_TAG(73)

/***********************************************************************/
/*
** Methods structures
*/

struct MUIP_SitesList_InsertSites
{
    ULONG                   MethodID;
    struct FREEDBS_Config   *opts;
};

struct MUIP_FreeDB_Config_Save
{
    ULONG   MethodID;
    STRPTR  name;
};

#define MUIV_FreeDB_Config_Save_Mode_Apply   ((STRPTR)(-1))
#define MUIV_FreeDB_Config_Save_Mode_Use     ((STRPTR)(-2))
#define MUIV_FreeDB_Config_Save_Mode_Save    ((STRPTR)(-3))

struct MUIP_FreeDB_Config_Load
{
    ULONG   MethodID;
    STRPTR  name;
};

#define MUIV_FreeDB_Config_Load_Env      (NULL)
#define MUIV_FreeDB_Config_Load_Envarc   ((STRPTR)(-1))

struct MUIP_FreeDB_Config_Remove
{
    ULONG   MethodID;
    Object  *parent;
};

/***********************************************************************/
/*
** Classes macros
*/

#define setsuper(cl,obj,tag,val) SetSuperAttrs(cl,obj,tag,val)

#define sitesListObject NewObject(libBase->sitesListClass->mcc_Class,NULL

/***********************************************************************/

#include "class_protos.h"

/***********************************************************************/

#endif /* _CLASS_H */
