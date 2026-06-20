#ifndef _CLASS_H
#define _CLASS_H

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/muimaster.h>
#include <proto/utility.h>
#include <proto/locale.h>
#include <proto/freedb.h>
#include <proto/intuition.h>
#include <mui/muiundoc.h>
#include <mui/SpeedBar_mcc.h>
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
#define DataTypesBase   (libBase->dataTypesBase)

extern struct libBase *libBase;

extern STRPTR *strings;
extern STRPTR cyclerStrings[];

/***********************************************************************/

#define FREEDB_TAG(n)   ((int)(0xfec90258+(n)))

/***********************************************************************/

#define MUIM_FreeDB_Bar_Set                 FREEDB_TAG(0)  /* Private */
#define MUIM_FreeDB_Bar_Notify              FREEDB_TAG(1)  /* Private */
#define MUIM_FreeDB_Bar_Disable             FREEDB_TAG(2)  /* Private */

struct MUIP_FreeDB_Bar_Notify
{
    ULONG   MethodID;
    ULONG   button;
    ULONG   trigAttr;
    ULONG   trigVal;
    APTR    destObj;
    ULONG   followParams;
    /* ... */
};

struct MUIP_FreeDB_Bar_Set
{
    ULONG   MethodID;
    ULONG   button;
    ULONG   tag;
    ULONG   value;
    ULONG   remember;
};

#define setbar(obj,button,tag,value) DoMethod((Object *)(obj),MUIM_FreeDB_Bar_Set,(ULONG)(button),(Tag)(tag),(ULONG)(value),FALSE)
#define setbarrem(obj,button,tag,value) DoMethod((Object *)(obj),MUIM_FreeDB_Bar_Set,(ULONG)(button),(Tag)(tag),(ULONG)(value),TRUE)


struct MUIP_FreeDB_Bar_Disable
{
    ULONG   MethodID;
    ULONG   restore;
};

#define MUIA_FreeDB_Bar_Buttons             FREEDB_TAG(0)  /* Private */
#define MUIA_FreeDB_Bar_ImagesDrawer        FREEDB_TAG(1)  /* Private */
#define MUIA_FreeDB_Bar_Active              FREEDB_TAG(2)  /* Private */
#define MUIA_FreeDB_Bar_Spacer              FREEDB_TAG(3)  /* Private */
#define MUIA_FreeDB_Bar_ViewMode            FREEDB_TAG(4)  /* Private */
#define MUIA_FreeDB_Bar_Sunny               FREEDB_TAG(5)  /* Private */
#define MUIA_FreeDB_Bar_Borderless          FREEDB_TAG(6)  /* Private */
#define MUIA_FreeDB_Bar_Raising             FREEDB_TAG(7)  /* Private */
#define MUIA_FreeDB_Bar_Small               FREEDB_TAG(8)  /* Private */
#define MUIA_FreeDB_Bar_NoBrushes           FREEDB_TAG(9)  /* Private */
#define MUIA_FreeDB_Bar_AllUnabled          FREEDB_TAG(10) /* Private */

/***********************************************************************/
/*
** DiscInfo
*/

#define MUIM_FreeDB_DiscInfo_Setup          FREEDB_TAG(15)  /* Private */
#define MUIM_FreeDB_DiscInfo_SetContents    FREEDB_TAG(16)  /* Private */

struct MUIP_FreeDB_DiscInfo_Setup
{
    ULONG   MethodID;
    Object  *parent;
};

struct MUIP_FreeDB_DiscInfo_SetContents
{
    ULONG                   MethodID;
    struct FREEDBS_DiscInfo *di;
    struct FREEDBS_TOC      *toc;
    ULONG                   flags;
};

enum
{
    MUIV_FreeDB_DiscInfo_SetContents_Flags_Clear      = 1,
    MUIV_FreeDB_DiscInfo_SetContents_Flags_ClearList  = 2,
};

#define MUIA_FreeDB_DiscInfo_ActiveTitle    FREEDB_TAG(15)  /* Private */
#define MUIA_FreeDB_DiscInfo_DoubleClick    FREEDB_TAG(16)  /* Private */

struct title
{
    struct FREEDBS_DiscInfo *di;
    struct FREEDBS_TOC      *toc;
    int                     track;
    char                    time[16];
    char                    type[16];
    char                    trackS[16];
};

#define MUIV_FreeDB_Titles_Format   "P=\33r BAR,BAR,BAR,BAR,"
#define MUIV_FreeDB_Titles_NAFormat "P=\33r BAR,BAR,BAR,COL=4"
#define MUIV_FreeDB_Titles_NDFormat "P=\33r BAR,BAR,COL=4"

/***********************************************************************/
/*
** Matches
*/

#define MUIV_FreeDB_Matches_Format  "BAR,BAR,BAR,"

/***********************************************************************/
/*
** Edit
*/

#define MUIM_FreeDB_Edit_Setup              FREEDB_TAG(20) /* Private */
#define MUIM_FreeDB_Edit_InfoToGadgets      FREEDB_TAG(21) /* Private */
#define MUIM_FreeDB_Edit_GadgetsToInfo      FREEDB_TAG(22) /* Private */
#define MUIM_FreeDB_Edit_Submit             FREEDB_TAG(23) /* Private */

/*
** Methods structures
*/

struct MUIP_FreeDB_Edit_Setup
{
    ULONG   MethodID;
    Object  *disc;
};

/***********************************************************************/
/*
** Disc
*/

#define MUIM_FreeDB_Disc_HandleEvent        FREEDB_TAG(30) /* Private */
#define MUIM_FreeDB_Disc_SetStatus          FREEDB_TAG(31) /* Private */
#define MUIM_FreeDB_Disc_SetError           FREEDB_TAG(32) /* Private */
#define MUIM_FreeDB_Disc_Submit             FREEDB_TAG(33) /* Private */
#define MUIM_FreeDB_Disc_Edit               FREEDB_TAG(34) /* Private */

#define MUIM_FreeDB_Disc_GetDisc            FREEDB_TAG(40)
#define MUIM_FreeDB_Disc_GetMatch           FREEDB_TAG(41)
#define MUIM_FreeDB_Disc_Break              FREEDB_TAG(42)
#define MUIM_FreeDB_Disc_Save               FREEDB_TAG(43)
#define MUIM_FreeDB_Disc_ObtainInfo         FREEDB_TAG(44)
#define MUIM_FreeDB_Disc_ReleaseInfo        FREEDB_TAG(45)
#define MUIM_FreeDB_Disc_Setup              FREEDB_TAG(46)
#define MUIM_FreeDB_Disc_Remove             FREEDB_TAG(47)
#define MUIM_FreeDB_Disc_Play               FREEDB_TAG(48)

struct MUIP_FreeDB_Disc_GetDisc
{
    ULONG               MethodID;
    struct FREEDBS_TOC  *toc;
    ULONG               flags;
};

enum
{
    MUIV_FreeDB_Disc_GetDisc_Flags_ForceLocal  = 1,
    MUIV_FreeDB_Disc_GetDisc_Flags_ForceRemote = 2,
};

struct MUIP_FreeDB_Disc_SetError
{
    ULONG   MethodID;
    ULONG   err;
};

struct MUIP_FreeDB_Disc_SetStatus
{
    ULONG   MethodID;
    ULONG   string;
    ULONG   mode;
};

enum
{
    MUIV_FreeDB_Disc_SetStatus_Mode_Status,
    MUIV_FreeDB_Disc_SetStatus_Mode_Error,
    MUIV_FreeDB_Disc_SetStatus_Mode_String,
};

struct MUIP_FreeDB_Disc_ObtainInfo
{
    ULONG                   MethodID;
    struct FREEDBS_DiscInfo **di;
    struct FREEDBS_TOC      **toc;
};

enum
{
    MUIV_FreeDB_Disc_ObtainInfo_Res_DiscInfo  = 1,
    MUIV_FreeDB_Disc_ObtainInfo_Res_TOC       = 2,
};

struct MUIP_FreeDB_Disc_ReleaseInfo
{
    ULONG   MethodID;
    ULONG   update;
};

struct MUIP_FreeDB_Disc_Remove
{
    ULONG   MethodID;
    Object  *parent;
};

struct MUIP_FreeDB_Disc_Play
{
    ULONG   MethodID;
    int     track;
};

enum
{
    MUIV_FreeDB_Disc_Play_Active = -1,
};

#define MUIA_FreeDB_Disc_Status             FREEDB_TAG(30)  /* Private */

#define MUIA_FreeDB_Disc_UseSpace           FREEDB_TAG(40)
#define MUIA_FreeDB_Disc_Disc               FREEDB_TAG(41)
#define MUIA_FreeDB_Disc_ActiveTitle        FREEDB_TAG(42)
#define MUIA_FreeDB_Disc_DoubleClick        FREEDB_TAG(43)

enum
{
    MUIV_FreeDB_Disc_Status_None,
    MUIV_FreeDB_Disc_Status_LookingUp,
    MUIV_FreeDB_Disc_Status_RemoteLookingUp,
    MUIV_FreeDB_Disc_Status_LocalFound,
    MUIV_FreeDB_Disc_Status_RemoteFound,
    MUIV_FreeDB_Disc_Status_MultiMatches,
    MUIV_FreeDB_Disc_Status_LookingUpMatch,
    MUIV_FreeDB_Disc_Status_RemoteLookingUpMatch,
    MUIV_FreeDB_Disc_Status_Submitting,
    MUIV_FreeDB_Disc_Status_Submitted,
    MUIV_FreeDB_Disc_Status_SubmitError,
};

#define FREEDBV_ImagesDir   "ENVARC:FreeDB/Images"

/***********************************************************************/

struct SBButton
{
    STRPTR  file;
    ULONG   text;
    ULONG   help;
    UWORD   flags;
    ULONG   exclude;
};

#define SBENTRY(file,text,help,flags,exclude)   {(STRPTR)(file),(ULONG)(text),(ULONG)(help),(UWORD)(flags),(ULONG)(exclude)}
#define SBSPACER                                SBENTRY(MUIV_SpeedBar_Spacer,0,0,0,0)
#define SBEND                                   SBENTRY(MUIV_SpeedBar_End,0,0,0,0)

enum
{
    MUIV_Button_Flags_Disabled =  1,
    MUIV_Button_Flags_Hide     =  2,
    MUIV_Button_Flags_Toggle   =  4,
    MUIV_Button_Flags_Selected =  8,
    MUIV_Button_Flags_Space    = 16,
};

enum
{
    BGET,
    BSAVE,
    BSTOP,
    DUMMY1,
    BDISC,
    BMATCHES,
    BEDIT
};

/***********************************************************************/
/*
** Classes macros
*/

#define setsuper(cl,obj,tag,val) SetSuperAttrs(cl,obj,tag,val)

#define multiMatchesListObject  NewObject(libBase->multiMatchesList->mcc_Class,NULL
#define titlesListObject        NewObject(libBase->titlesList->mcc_Class,NULL
#define barObject               NewObject(libBase->bar->mcc_Class,NULL
#define discInfoObject          NewObject(libBase->discInfo->mcc_Class,NULL
#define editObject              NewObject(libBase->edit->mcc_Class,NULL

/***********************************************************************/

#include "class_protos.h"

/***********************************************************************/

#endif /* _CLASS_H */
