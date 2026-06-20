#ifndef LIBRARIES_DEPTHMENU_H
#define LIBRARIES_DEPTHMENU_H

/*
**  $VER: depthmenu.h v3 (18.11.2002)
**
**  DepthMenu modules interface definition
**
**  (C) Copyright 2001-2002 Arkadiusz [Yak] Wahlig
**      All Rights Reserved.
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif


/* usefull in module's hook entry prototypes */

#if !defined REG && !defined ASM
#ifdef __GNUC__
#define REG(reg, arg) register arg __asm__(#reg)
#define ASM
#else
#define REG(reg, arg) register __##reg arg
#define ASM __asm
#endif /* __GNUC__ */
#endif /* REG and ASM */

/* this struct defines the module */

struct DM_Module
{
 ULONG MatchWord;               /* word to match on (DM_MATCHWORD)      */
 struct DM_Module *MatchTag;    /* pointer to the above                 */

 UBYTE APIVersion;              /* minimal required API version         */
 BYTE Priority;                 /* module priority                      */
 STRPTR IDString;               /* module identification string         */
 struct TagItem *TagList;       /* tags, see below                      */

 BPTR SegList;                  /* module seglist, filled by DepthMenu  */
 STRPTR ModulePath;             /* module filepath, filled by DepthMenu */
};


/* place it in DM_Module->MatchWord field */

#define DM_MATCHWORD            (0x4AFCBE93)


/* place it in DM_Module->APIVersion field */

#define DM_APIVERSION           3


#define DM_Dummy                (TAG_USER+2000)

/* tags which can be used in DM_Module->TagList field */

/*      ti_Tag:                                    ti_Data: */
/*      -----------------------                    ----------------------- */

/* defining hooks */
#define DM_Hook_Setup           (DM_Dummy+100)  /* struct Hook *              */
#define DM_Hook_Cleanup         (DM_Dummy+101)  /* struct Hook *              */
#define DM_Hook_WindowAttrs     (DM_Dummy+102)  /* struct Hook *              */
#define DM_Hook_ScreenAttrs     (DM_Dummy+103)  /* struct Hook *              */
#define DM_Hook_WindowItems     (DM_Dummy+104)  /* struct Hook *              */
#define DM_Hook_ScreenItems     (DM_Dummy+105)  /* struct Hook *              */
#define DM_Hook_WindowSelected  (DM_Dummy+106)  /* struct Hook *              */
#define DM_Hook_ScreenSelected  (DM_Dummy+107)  /* struct Hook *              */
#define DM_Hook_ItemsHandler    (DM_Dummy+108)  /* (V3) struct Hook *         */

/* obtaining library bases */
#define DM_Get_DepthMenuBase    (DM_Dummy+200)  /* struct DepthMenuBase **    */
#define DM_Get_SysBase          (DM_Dummy+201)  /* struct ExecBase **         */
#define DM_Get_DOSBase          (DM_Dummy+202)  /* struct DosLibrary **       */
#define DM_Get_CxBase           (DM_Dummy+203)  /* struct Library **          */
#define DM_Get_IntuitionBase    (DM_Dummy+205)  /* struct IntuitionBase **    */
#define DM_Get_LayersBase       (DM_Dummy+206)  /* struct Library **          */
#define DM_Get_UtilityBase      (DM_Dummy+207)  /* struct Library **          */
#define DM_Get_IconBase         (DM_Dummy+208)  /* struct Library **          */
#define DM_Get_LocaleBase       (DM_Dummy+209)  /* struct Library **          */

/* other module tags */
#define DM_Get_Language         (DM_Dummy+300)  /* STRPTR *                   */

/* DM_CreateItemsNewMenuA() tags */
#define DM_RootItemLabel        (DM_Dummy+400)  /* (V3) STRPTR                */


/* values returned by depthmenu.library/DM_AddModule() */

#define DM_ERROR_NOT_A_MODULE       1  /* function argument is not a module        */
#define DM_ERROR_BAD_API_VERSION    2  /* APIVersion does not match                */
#define DM_ERROR_SETUP_FAILED       3  /* DM_Hook_Setup hook returned FALSE        */
#define DM_ERROR_ALREADY_EXISTS     4  /* (V3) module already exists on list       */
#define DM_ERROR_OUT_OF_MEMORY      5  /* (V3) there is not enough momory          */


/* values returned by depthmenu.library/DM_RemModule() */

#define DM_ERROR_CLEANUP_FAILED     1  /* (V3) DM_Hook_Cleanup hook returned FALSE */
#define DM_ERROR_DOESNT_EXISTS      4  /* module doesn't exist on list             */


/* DM_Hook_ScreenAttrs and DM_Hook_WindowAttrs hooks message */

struct DM_AttrsMessage
{
 struct Process *Process;  /* [G.] object owner (if avaiable)                         */
 STRPTR ProcessName;       /* [G.] object owner's name (if avaiable)                  */

 BOOL Remove;              /* [S.] set to TRUE if you want to remove object from menu */

 STRPTR TitleHead;         /* [S.] use it if you want to add something before title   */
 STRPTR Title;             /* [S.] use it if you want to replace the window title     */
 STRPTR TitleTail;         /* [S.] use it if you want to add something after title    */
};


/* DM_Hook_ScreenItems and DM_Hook_WindowItems hooks message */

struct DM_ItemsMessage
{
 struct Process *Process;  /* [G.] object owner (if avaiable)                        */
 STRPTR ProcessName;       /* [G.] object owner's name (if avaiable)                 */

 APTR Items;               /* [.S] pointer returned by DM_CreateItemsNewMenuA()      */
 BOOL Reusable;            /* [.S] (V3) if TRUE, then Items won't be freed after use */
};


/* DM_Hook_ScreenSelected and DM_Hook_WindowSelected hooks message */
/* (currently only usable for DM_Hook_WindowSelected)              */

struct DM_SelectedMessage
{
 struct Process *Process;  /* [G.] object owner (if avaiable)                        */
 STRPTR ProcessName;       /* [G.] object owner's name (if avaiable)                 */
};


/* DM_Hook_ItemsHandler hook message */

struct DM_ItemsHandlerMessage
{
 APTR UserData;
};


/* depthmenu.library base */

struct DepthMenuBase
{
 struct Library Library;

 struct MinList *Modules;    /* (V3) all modules list (see below for nodes)    */
 UWORD DynamicModulesCnt;    /* (V3) number of dynamic modules currently added */
};


/* DepthMenuBase->Modules list nodes */

struct DM_ModuleNode
{
 struct Node Node;

 struct DM_Module *Module;   /* module pointer */
};


/* image titles are also supported */

#ifndef IM_TITLE
#define IM_TITLE           (NM_TITLE|MENU_IMAGE)
#endif

#endif /* LIBRARIES_DEPTHMENU_H */
