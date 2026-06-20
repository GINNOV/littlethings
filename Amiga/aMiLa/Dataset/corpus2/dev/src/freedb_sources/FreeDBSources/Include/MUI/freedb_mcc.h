#ifndef FREEDB_MCC_H
#define FREEDB_MCC_H

/*
** FreeDB mccs
**
** (C) 2001-2002 Alfonso Ranieri <alforan@tin.it>
** All Rights Reserved
**
*/

#ifndef LIBRARIES_MUI_H
#include <libraries/mui.h>
#endif

/***********************************************************************
** Class Tree

** !  +--Window                (main class for all windows)
** !  !  \--FreeDBAbout        (FreeDB About window of MUI preferences)
** !  +--Area                  (base class for all GUI elements)
** !     +--Group              (groups other GUI elements)
** !        +--FreeDBDisc      (FreeDB main group)
** !        +--FreeDBConfig    (FreeDB configuration group)

***********************************************************************/


#define MUIC_FreeDBAbout                    "FreeDBAbout.mcc"
#define MUIC_FreeDBConfig                   "FreeDBConfig.mcc"
#define MUIC_FreeDBDisc                     "FreeDBDisc.mcc"

#define FreeDBAboutObject                   MUI_NewObject(MUIC_FreeDBAbout
#define FreeDBConfigObject                  MUI_NewObject(MUIC_FreeDBConfig
#define FreeDBDiscObject                    MUI_NewObject(MUIC_FreeDBDisc

/***********************************************************************/

#define FREEDB_TAG(n) ((int)(0xfec90258+(n)))

/***********************************************************************/
/*
** FreeDBAbout.mcc
*/

/* No Method and attribute defined */

/***********************************************************************/
/*
** FreeDBConfig.mcc
*/

/*  Attributes */
#define MUIA_FreeDB_Config_Done             FREEDB_TAG(70) /* BOOL [...N] */

/* Methods */
#define MUIM_FreeDB_Config_Load             FREEDB_TAG(70)
#define MUIM_FreeDB_Config_Break            FREEDB_TAG(71)
#define MUIM_FreeDB_Config_Save             FREEDB_TAG(72)
#define MUIM_FreeDB_Config_GetSites         FREEDB_TAG(73)

/* Methods structures */
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

#define MUIV_FreeDB_Config_Load_Env         (NULL)
#define MUIV_FreeDB_Config_Load_Envarc      ((STRPTR)(-1))

/***********************************************************************/
/*
** FreeDBDisc.mcc
*/

/* Attributes */
#define MUIA_FreeDB_Disc_UseSpace           FREEDB_TAG(40) /* BOOL [I...] */
#define MUIA_FreeDB_Disc_Disc               FREEDB_TAG(41) /* BOOL [..GN] */
#define MUIA_FreeDB_Disc_ActiveTitle        FREEDB_TAG(42) /* LONG [.SGN] */
#define MUIA_FreeDB_Disc_DoubleClick        FREEDB_TAG(43) /* BOOL [...N] */

/* Methods */
#define MUIM_FreeDB_Disc_GetDisc            FREEDB_TAG(40)
#define MUIM_FreeDB_Disc_GetMatch           FREEDB_TAG(41)
#define MUIM_FreeDB_Disc_Break              FREEDB_TAG(42)
#define MUIM_FreeDB_Disc_Save               FREEDB_TAG(43)
#define MUIM_FreeDB_Disc_ObtainInfo         FREEDB_TAG(44)
#define MUIM_FreeDB_Disc_ReleaseInfo        FREEDB_TAG(45)
#define MUIM_FreeDB_Disc_Setup              FREEDB_TAG(46)
#define MUIM_FreeDB_Disc_Remove             FREEDB_TAG(47)
#define MUIM_FreeDB_Disc_Play               FREEDB_TAG(48)

/* Methods structures */

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

/***********************************************************************/

#endif /* FREEDB_MCC_H */
