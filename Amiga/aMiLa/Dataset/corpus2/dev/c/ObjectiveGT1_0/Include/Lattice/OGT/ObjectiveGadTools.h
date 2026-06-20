#ifndef  OGT_OBJECTIVEGADTOOLS_H
#define  OGT_OBJECTIVEGADTOOLS_H   1
/*
** $Filename: OGT/ObjectiveGadTools.h $
** $Release : 1.0                     $
** $Revision: 1.000                   $
** $Date    : 18/10/92                $
**
**
** (C) Copyright 1991,1992 Davide Massarenti
**              All Rights Reserved
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <exec/ports.h>
#include <exec/semaphores.h>
#include <exec/libraries.h>
#include <exec/io.h>
#include <exec/execbase.h>

#include <intuition/cghooks.h>
#include <intuition/sghooks.h>

#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>

#include <libraries/asl.h>

#include <proto/all.h>

#define OGT_LIB_NAME    "objectivegadtools.library"
#define OGT_LIB_VERSION (1)

#define   ASLREQ_OGT_CLASS   "aslreq_ogt"
#define   BUTTON_OGT_CLASS   "button_ogt"
#define    GROUP_OGT_CLASS    "group_ogt"
#define LISTVIEW_OGT_CLASS "listview_ogt"
#define     MENU_OGT_CLASS     "menu_ogt"
#define MULTIWAY_OGT_CLASS "multiway_ogt"
#define     PROP_OGT_CLASS     "prop_ogt"
#define SCROLLER_OGT_CLASS "scroller_ogt"
#define SHOWLIST_OGT_CLASS "showlist_ogt"
#define SHOWTEXT_OGT_CLASS "showtext_ogt"
#define   STRING_OGT_CLASS   "string_ogt"

struct OGT_ObjectSettings
{
   STRPTR          Class;
   struct TagItem *Settings;
   struct TagItem *PostSettings;
   ULONG           Parent;
   ULONG           Align;
};

struct OGT_ObjectLink
{
   ULONG           From;
   ULONG           To;
   struct TagItem *Map;
   Tag            *Filter;
};

#define OGT_NOOBJECT ((ULONG)-1)


/**********************************************************************************/
/*                                                                                */
/*                      ObjectiveGadTools common attributes                       */
/*                                                                                */
/**********************************************************************************/
#define OGT_Dummy                   (TAG_USER + 0x2F0000)

#define OGT_VisualInfo              (OGT_Dummy + 0x00)    /* APTR                                                                           */
#define OGT_LinkToAnchor            (OGT_Dummy + 0x01)    /* BOOL                         Default: TRUE                                     */
#define OGT_Parent                  (OGT_Dummy + 0x02)    /* Object *                                                                       */
#define OGT_AlignToObject           (OGT_Dummy + 0x03)    /* Object *                                                                       */
#define OGT_AppGadget               (OGT_Dummy + 0x04)    /* BOOL                         Default: FALSE                                    */


#define OGT_TextFont                (OGT_Dummy + 0x08)    /* struct TextFont *            Default: NULL                                     */
#define OGT_TextColor               (OGT_Dummy + 0x09)    /* SHORT                        Default: dri_Pens[ TEXTPEN ]                      */
#define OGT_TextPlacement           (OGT_Dummy + 0x0A)    /* SHORT                                                                          */
#define OGT_DrawFrame               (OGT_Dummy + 0x0B)    /* BOOL                                                                           */
#define OGT_ClickRepeat             (OGT_Dummy + 0x0C)    /* BOOL                         Default: FALSE                                    */
#define OGT_Activation              (OGT_Dummy + 0x0D)    /* ULONG                                                                          */

#define OGT_Right                   (OGT_Dummy + 0x10)    /* SHORT                                                                          */
#define OGT_Bottom                  (OGT_Dummy + 0x11)    /* SHORT                                                                          */
#define OGT_SetPosHandle            (OGT_Dummy + 0x12)    /* USHORT                       Default: OGT_X_Left          | OGT_Y_Top          */
#define OGT_SetPosReference         (OGT_Dummy + 0x13)    /* ULONG                        Default: OGT_X_Left          | OGT_Y_Top          */
#define OGT_SetDimReference         (OGT_Dummy + 0x14)    /* ULONG                        Default: OGT_X_Left_Relative | OGT_Y_Top_Relative */
#define OGT_ScaleLeft               (OGT_Dummy + 0x15)    /* UBYTE                        Default: OGT_Fixed                                */
#define OGT_ScaleTop                (OGT_Dummy + 0x16)    /* UBYTE                        Default: OGT_Fixed                                */
#define OGT_ScaleWidth              (OGT_Dummy + 0x17)    /* UBYTE                        Default: OGT_Fixed                                */
#define OGT_ScaleHeight             (OGT_Dummy + 0x18)    /* UBYTE                        Default: OGT_Fixed                                */
#define OGT_FontXscale              (OGT_Dummy + 0x19)    /* USHORT                       Default: 8                                        */
#define OGT_FontYscale              (OGT_Dummy + 0x1A)    /* USHORT                       Default: 8                                        */
#define OGT_DomainXscale            (OGT_Dummy + 0x1B)    /* USHORT                       Default: 100                                      */
#define OGT_DomainYscale            (OGT_Dummy + 0x1C)    /* USHORT                       Default: 100                                      */
#define OGT_ResetAspect             (OGT_Dummy + 0x1D)    /* void                                                                           */

#define OGT_DroppedIcon             (OGT_Dummy + 0x1E)    /* STRPTR                                                                         */

/**********************************************************************************/
/*                                                                                */
/* BUTTON_OGT_CLASS specific attributes                                           */
/*                                                                                */
/**********************************************************************************/
#define OGTBU_Labels                (OGT_Dummy + 0x20)    /* STRPTR *                                                                   */
#define OGTBU_ActiveLabel           (OGT_Dummy + 0x21)    /* SHORT                                                                      */
#define OGTBU_VectorImageDef        (OGT_Dummy + 0x22)    /* SHORT                                                                      */
#define OGTBU_VectorImage           (OGT_Dummy + 0x23)    /* struct OGT_VectorImage *                                                   */

/*
 * OGTBU_VectorImageDef tag data values:
 */
#define OGTBU_VectorImage_Radio       (0)
#define OGTBU_VectorImage_Check       (1)
#define OGTBU_VectorImage_Cycle       (2)
#define OGTBU_VectorImage_GetFile     (3)
#define OGTBU_VectorImage_ArrowUp     (4)
#define OGTBU_VectorImage_ArrowDown   (5)
#define OGTBU_VectorImage_ArrowLeft   (6)
#define OGTBU_VectorImage_ArrowRight  (7)

struct OGT_VectorImage
{
   struct OGT_VectorElement *LayoutNormal;    /* Could be NULL                             */
   struct OGT_VectorElement *LayoutSelected;  /* Could be NULL                             */
   struct OGT_VectorElement *LayoutHitTest;   /* Could be NULL                             */
   SHORT                     PosX;            /* A negative value means Central Position   */
   SHORT                     PosY;            /* A negative value means Central Position   */
   SHORT                     AspectX;         /* A negative value means a Fixed Size Image */
   SHORT                     AspectY;         /* A negative value means a Fixed Size Image */
   BOOL                      HasFrame;
   BOOL                      KeepAspect;
};


struct OGT_VectorElement
{
   SHORT X;
   SHORT Y;
   SHORT Action;
};

/* OGT_VectorElement.Action valid data (can be ORed together) */
#define OGTBU_Act_Move       (0x0000)  /* Move at position X/Y                                                         */
#define OGTBU_Act_Draw       (0x0001)  /* Draw a line from here to position X/Y                                        */

#define OGTBU_Act_StartFill  (0x0002)  /* Begin an area fill                                                           */
#define OGTBU_Act_EndFill    (0x0004)  /* End an area fill                                                             */

#define OGTBU_Act_X_Right    (0x0008)  /* X is Right Edge relative                                                     */
#define OGTBU_Act_Y_Bottom   (0x0010)  /* Y is Bottom Edge relative                                                    */
#define OGTBU_Act_X_Center   (0x0020)  /* X is relative to central position                                            */
#define OGTBU_Act_Y_Center   (0x0040)  /* Y is relative to central position                                            */
#define OGTBU_Act_X_Scale    (0x0080)  /* if X > 0, then next X elements are scaled: realX = X * ImageWidth  / X_scale */
#define OGTBU_Act_Y_Scale    (0x0100)  /* if Y > 0, then next Y elements are scaled: realY = Y * ImageHeight / Y_scale */
#define OGTBU_Act_Shadow     (0x0200)  /* Draw with dri_Pens[ SHADOWPEN ]                                              */
#define OGTBU_Act_Shine      (0x0400)  /* Draw with dri_Pens[ SHINEPEN  ]                                              */
#define OGTBU_Act_Fill       (0x0800)  /* Draw with dri_Pens[ FILLPEN   ]                                              */
#define OGTBU_Act_Color      (0x1000)  /* X holds the color to use with next elements                                  */
#define OGTBU_Act_Last       (0x2000)  /* Last element                                                                 */


/**********************************************************************************/
/*                                                                                */
/* MULTIWAY_OGT_CLASS specific attributes                                         */
/*                                                                                */
/**********************************************************************************/
#define OGTMW_Labels                (OGT_Dummy + 0x28)    /* STRPTR *                                                                   */
#define OGTMW_ActiveLabel           (OGT_Dummy + 0x29)    /* SHORT                                                                      */
#define OGTMW_ActiveMask            (OGT_Dummy + 0x2A)    /* ULONG                                                                      */


/**********************************************************************************/
/*                                                                                */
/* SCROLLER_OGT_CLASS specific attributes                                         */
/*                                                                                */
/**********************************************************************************/
#define OGTSR_ArrowSize             (OGT_Dummy + 0x2C)    /* USHORT                       Default: 16                                   */


/**********************************************************************************/
/*                                                                                */
/* SHOWLIST_OGT_CLASS specific attributes                                         */
/*                                                                                */
/**********************************************************************************/
#define OGTSL_Labels                (OGT_Dummy + 0x30)    /* STRPTR *                                                                   */
#define OGTSL_ListOfLabels          (OGT_Dummy + 0x31)    /* struct MinList *                                                           */
#define OGTSL_FileToLoadByFH        (OGT_Dummy + 0x32)    /* BPTR                                                                       */
#define OGTSL_FileToLoadByName      (OGT_Dummy + 0x33)    /* STRPTR                                                                     */
#define OGTSL_FontOfLabels          (OGT_Dummy + 0x34)    /* struct TextFont *                                                          */

#define OGTSL_HoriPos               (OGT_Dummy + 0x35)    /* LONG                                                                       */
#define OGTSL_HoriTotal             (OGT_Dummy + 0x36)    /* LONG                                                                       */
#define OGTSL_HoriVisible           (OGT_Dummy + 0x37)    /* LONG                                                                       */
#define OGTSL_VertPos               (OGT_Dummy + 0x38)    /* LONG                                                                       */
#define OGTSL_VertTotal             (OGT_Dummy + 0x39)    /* LONG                                                                       */
#define OGTSL_VertVisible           (OGT_Dummy + 0x3A)    /* LONG                                                                       */

#define OGTSL_UseNumPad             (OGT_Dummy + 0x3B)    /* BOOL                         Default: FALSE                                */
#define OGTSL_Freedom               (OGT_Dummy + 0x3C)    /* ULONG                        Default: FREEVERT | FREEHORIZ                 */
#define OGTSL_Spacing               (OGT_Dummy + 0x3D)    /* ULONG                        Default: 0                                    */

#define OGTSL_TranslateLabel        (OGT_Dummy + 0x3E)    /* struct Hook *                                                              */
#define OGTSL_ExtraRendering        (OGT_Dummy + 0x3F)    /* struct Hook *                                                              */

#define OGTSL_InsertLabelBefore     (OGT_Dummy + 0x40)    /* STRPTR or struct Node *                                                    */
#define OGTSL_ChangeLabel           (OGT_Dummy + 0x41)    /* STRPTR or struct Node *                                                    */
#define OGTSL_DeleteLabel           (OGT_Dummy + 0x42)    /* STRPTR or struct Node *                                                    */
#define OGTSL_InsertLabelAfter      (OGT_Dummy + 0x43)    /* STRPTR or struct Node *                                                    */
#define OGTSL_WorkLabelPos          (OGT_Dummy + 0x44)    /* LONG                                                                       */
#define OGTSL_LockList              (OGT_Dummy + 0x45)    /* BOOL                                                                       */


struct ogmsl_Node
{
   struct Node ogmsl_Data;
   SHORT       ogmsl_Flags;
};

#define ogmsl_Flags_Modified         (0x0001)
#define ogmsl_Flags_ReverseColors    (0x0002)
#define ogmsl_Flags_UsePriAsColor    (0x0004)


struct ogmsl_Translate
{
   struct ogmsl_Node *ogmsl_Node;
   STRPTR             ogmsl_Text;
   LONG               ogmsl_TextLength;
};

struct ogmsl_ExtraRendering
{
   struct MinList    *ogmsl_Nodes;
   struct ogmsl_Node *ogmsl_FirstNode;
   struct RastPort   *ogmsl_RPort;
   struct IBox        ogmsl_Domain;
   ULONG              ogmsl_TextScrollLeft;
   ULONG              ogmsl_TextScrollTop;
   ULONG              ogmsl_TextSpacing;
   BOOL               ogmsl_AfterText;
};


/********************************************************************************/
/*                                                                              */
/* ASLREQ_OGT_CLASS specific attributes                                         */
/*                                                                              */
/********************************************************************************/
#define OGTAR_Type                  (OGT_Dummy + 0x50)    /* ASL_FileRequest or ASL_FontRequest                             ONLY OM_NEW */
#define OGTAR_ShowSelected          (OGT_Dummy + 0x51)    /* BOOL                                                           ONLY OM_NEW */
#define OGTAR_FullFileName          (OGT_Dummy + 0x52)    /* STRPTR                                                                     */
#define OGTAR_FontData              (OGT_Dummy + 0x53)    /* struct TextAttr *                                                          */
#define OGTAR_FilesSelected         (OGT_Dummy + 0x54)    /* STRPTR *                                                       ONLY OM_GET */


/********************************************************************************/
/*                                                                              */
/* SHOWTEXT_OGT_CLASS specific attributes                                       */
/*                                                                              */
/********************************************************************************/
#define OGTST_Number                (OGT_Dummy + 0x60)    /* LONG                                    Default: 0                         */
#define OGTST_Label                 (OGT_Dummy + 0x61)    /* STRPTR                                                                     */
#define OGTST_Labels                (OGT_Dummy + 0x62)    /* STRPTR *                                                                   */
#define OGTST_Format                (OGT_Dummy + 0x63)    /* STRPTR                                                                     */
#define OGTST_Arguments             (OGT_Dummy + 0x64)    /* void **                                                                    */
#define OGTST_Placement             (OGT_Dummy + 0x65)    /* same as OGT_SetPosHandle                Default: OGT_X_Center|OGT_Y_Center */


/********************************************************************************/
/*                                                                              */
/* MENU_OGT_CLASS specific attributes                                           */
/*                                                                              */
/********************************************************************************/
#define OGTMN_Menu                  (OGT_Dummy + 0x70)    /* STRPTR                                                                     */
#define OGTMN_Item                  (OGT_Dummy + 0x71)    /* STRPTR                                                                     */
#define OGTMN_SubItem               (OGT_Dummy + 0x72)    /* STRPTR                                                                     */
#define OGTMN_ImageItem             (OGT_Dummy + 0x73)    /* struct Image *                                                             */
#define OGTMN_ImageSubItem          (OGT_Dummy + 0x74)    /* struct Image *                                                             */
#define OGTMN_BarLabel              (OGT_Dummy + 0x75)    /* void                                                                       */
#define OGTMN_NewName               (OGT_Dummy + 0x76)    /* STRPTR                                                                     */
#define OGTMN_NewImage              (OGT_Dummy + 0x77)    /* struct Image *                                                             */
#define OGTMN_ShortCut              (OGT_Dummy + 0x78)    /* SHORT                                                                      */
#define OGTMN_MutualExclude         (OGT_Dummy + 0x79)    /* ULONG                                                                      */
#define OGTMN_Hook                  (OGT_Dummy + 0x7A)    /* struct Hook *                                                              */
#define OGTMN_ClearMenus            (OGT_Dummy + 0x7B)    /* BOOL                                                                       */
#define OGTMN_MenuStrip             (OGT_Dummy + 0x7C)    /* struct Menu *                                                  ONLY OM_GET */


/**********************************************************************************/
/*                                                                                */
/* LISTVIEW_OGT_CLASS specific attributes                                         */
/*                                                                                */
/**********************************************************************************/
#define OGTLV_ActiveLabel           (OGT_Dummy + 0x80)    /* LONG                                                                       */
#define OGTLV_Labels                (OGT_Dummy + 0x81)    /* STRPTR *                                                                   */
#define OGTLV_ListOfLabels          (OGT_Dummy + 0x82)    /* struct MinList *                                                           */
#define OGTLV_FontOfLabels          (OGT_Dummy + 0x83)    /* struct TextFont *                                                          */

#define OGTLV_ReadOnly              (OGT_Dummy + 0x84)    /* ULONG                        Default: FALSE                                */
#define OGTLV_ShowSelected          (OGT_Dummy + 0x85)    /* ULONG                        Default: FALSE                                */

#define OGTLV_Top                   (OGT_Dummy + 0x86)    /* LONG                                                                       */
#define OGTLV_Spacing               (OGT_Dummy + 0x87)    /* ULONG                        Default: 0                                    */
#define OGTLV_ScrollWidth           (OGT_Dummy + 0x88)    /* ULONG                        Default: 16                                   */
#define OGTLV_ShowHeight            (OGT_Dummy + 0x89)    /* ULONG                        Default: font->tf_YSize + 6                   */

#define OGTLV_FollowSelected        (OGT_Dummy + 0x8A)    /* BOOL                         Default: TRUE                                 */
#define OGTLV_ToggleSelect          (OGT_Dummy + 0x8B)    /* BOOL                                                                       */

#define OGTLV_InsertLabelBefore     (OGT_Dummy + 0x8C)    /* STRPTR                                                                     */
#define OGTLV_ChangeLabel           (OGT_Dummy + 0x8D)    /* STRPTR                                                                     */
#define OGTLV_DeleteLabel           (OGT_Dummy + 0x8E)    /* STRPTR                                                                     */
#define OGTLV_InsertLabelAfter      (OGT_Dummy + 0x8F)    /* STRPTR                                                                     */
#define OGTLV_WorkLabelPos          (OGT_Dummy + 0x90)    /* LONG                                                                       */
#define OGTLV_LockList              (OGT_Dummy + 0x91)    /* BOOL                                                                       */



/* Tags passed through IDCMP_IDCMPUPDATE & OM_NOTIFY */
#define OGT_ID                      (OGT_Dummy + 0x800)  /* UWORD                        */
#define OGT_Object                  (OGT_Dummy + 0x801)  /* Object *                     */
#define OGT_MouseX                  (OGT_Dummy + 0x802)  /* SHORT                        */
#define OGT_MouseY                  (OGT_Dummy + 0x803)  /* SHORT                        */
#define OGT_GadgetDown              (OGT_Dummy + 0x804)  /* BOOL                         */
#define OGT_GadgetUp                (OGT_Dummy + 0x805)  /* BOOL                         */
#define OGT_GadgetMove              (OGT_Dummy + 0x806)  /* BOOL                         */
#define OGT_GadgetRepeat            (OGT_Dummy + 0x807)  /* BOOL                         */
#define OGT_MenuUp                  (OGT_Dummy + 0x808)  /* ULONG                        */
#define OGT_MenuItemUp              (OGT_Dummy + 0x809)  /* ULONG                        */
#define OGT_MenuItemSubUp           (OGT_Dummy + 0x80A)  /* ULONG                        */
#define OGT_AskedHelp               (OGT_Dummy + 0x80B)  /* BOOL                         */

#define OGTSL_HitX                  (OGT_Dummy + 0x810)  /* LONG                         */
#define OGTSL_HitY                  (OGT_Dummy + 0x811)  /* LONG                         */
#define OGTSL_HitLabelFromList      (OGT_Dummy + 0x812)  /* struct ogmsl_Node *          */
#define OGTSL_HitLabelNumFromList   (OGT_Dummy + 0x813)  /* LONG                         */


#define OGT_Reserved1               (OGT_Dummy + 0x840)
#define OGT_Reserved2               (OGT_Dummy + 0x841)
#define OGT_Reserved3               (OGT_Dummy + 0x842)
#define OGT_Reserved4               (OGT_Dummy + 0x843)
#define OGT_Reserved5               (OGT_Dummy + 0x844)
#define OGT_Reserved6               (OGT_Dummy + 0x845)
#define OGT_Reserved7               (OGT_Dummy + 0x846)
#define OGT_Reserved8               (OGT_Dummy + 0x847)
#define OGT_Reserved9               (OGT_Dummy + 0x848)
#define OGT_Reserved10              (OGT_Dummy + 0x849)
#define OGT_Reserved11              (OGT_Dummy + 0x84A)
#define OGT_Reserved12              (OGT_Dummy + 0x84B)
#define OGT_Reserved13              (OGT_Dummy + 0x84C)
#define OGT_Reserved14              (OGT_Dummy + 0x84D)
#define OGT_Reserved15              (OGT_Dummy + 0x84E)
#define OGT_Reserved16              (OGT_Dummy + 0x84F)


/* Flags for OGT_TextPlacement */
#define OGT_Text_IN                 (0)
#define OGT_Text_IN_LEFTMOST        (1)
#define OGT_Text_IN_RIGHTMOST       (2)
#define OGT_Text_LEFT               (3)
#define OGT_Text_RIGHT              (4)
#define OGT_Text_ABOVE              (5)
#define OGT_Text_BELOW              (6)
#define OGT_Text_HIDE               (7)


/* Flags for OGT_Activation */
#define OGT_Act_ToggleType          (0x0001)
#define OGT_Act_ReportGadgetDown    (0x0002)
#define OGT_Act_ReportGadgetUp      (0x0004)
#define OGT_Act_ReportGadgetMove    (0x0008)
#define OGT_Act_ReportGadgetRepeat  (0x0010)


/* Flags for OGT_SetPosHandle, OGT_SetPosReference & OGT_SetDimReference */
#define OGT_X_Left                  (0x0000)
#define OGT_X_Center                (0x0001)
#define OGT_X_Right                 (0x0002)
#define OGT_X_Pos_Mask              (0x0003)

#define OGT_Y_Top                   (0x0000)
#define OGT_Y_Center                (0x0004)
#define OGT_Y_Bottom                (0x0008)
#define OGT_Y_Pos_Mask              (0x000C)


/* Flags for OGT_SetPosReference & OGT_SetDimReference */
#define OGT_X_Mode_Free             (0x0000)
#define OGT_X_Mode_Align            (0x0010)
#define OGT_X_Mode_Center           (0x0020) /* Only for OGT_SetPosReference */
#define OGT_X_Mode_In_Border        (0x0030)
#define OGT_X_Mode_Mask             (0x0030)

#define OGT_Y_Mode_Free             (0x0000)
#define OGT_Y_Mode_Align            (0x0040)
#define OGT_Y_Mode_Center           (0x0080) /* Only for OGT_SetPosReference */
#define OGT_Y_Mode_In_Border        (0x00C0)
#define OGT_Y_Mode_Mask             (0x00C0)


/* Flags for OGT_SetDimReference */
#define OGT_X_Dim_Fixed             (0x0000)
#define OGT_X_Dim_Relative          (0x0100)
#define OGT_X_Dim_AsCoord           (0x0200)
#define OGT_X_Dim_Mask              (0x0300)

#define OGT_Y_Dim_Fixed             (0x0000)
#define OGT_Y_Dim_Relative          (0x0400)
#define OGT_Y_Dim_AsCoord           (0x0800)
#define OGT_Y_Dim_Mask              (0x0C00)


/* Flags for OGT_ScaleXXXX */
#define OGT_Fixed                   (0x00)
#define OGT_FontRelative            (0x01)
#define OGT_DomainRelative          (0x02)


/**********************************************************************************/
/*                                                                                */
/*                        ObjectiveGadTools common methods                        */
/*                                                                                */
/**********************************************************************************/
#define OGM_DUMMY                   (OGT_Dummy + 0x10000)
#define OGM_ERASE                   (OGM_DUMMY + 0x00) /* erase the gadget image                                       */
#define OGM_GETREALBOX              (OGM_DUMMY + 0x01) /* get the absolute position of gadget                          */
#define OGM_ADDTARGET               (OGM_DUMMY + 0x02) /* adds    a target for OM_NOTIFY                               */
#define OGM_REMTARGET               (OGM_DUMMY + 0x03) /* removes a target for OM_NOTIFY                               */

#define OGM_RESERVED1               (OGM_DUMMY + 0x10)
#define OGM_RESERVED2               (OGM_DUMMY + 0x11)
#define OGM_RESERVED3               (OGM_DUMMY + 0x12)
#define OGM_RESERVED4               (OGM_DUMMY + 0x13)
#define OGM_RESERVED5               (OGM_DUMMY + 0x14)
#define OGM_RESERVED6               (OGM_DUMMY + 0x15)
#define OGM_RESERVED7               (OGM_DUMMY + 0x16)
#define OGM_RESERVED8               (OGM_DUMMY + 0x17)
#define OGM_RESERVED9               (OGM_DUMMY + 0x18)
#define OGM_RESERVED10              (OGM_DUMMY + 0x19)
#define OGM_RESERVED11              (OGM_DUMMY + 0x1A)
#define OGM_RESERVED12              (OGM_DUMMY + 0x1B)
#define OGM_RESERVED13              (OGM_DUMMY + 0x1C)
#define OGM_RESERVED14              (OGM_DUMMY + 0x1D)
#define OGM_RESERVED15              (OGM_DUMMY + 0x1E)
#define OGM_RESERVED16              (OGM_DUMMY + 0x1F)


/**********************************************************************************/
/*                                                                                */
/*                 Parameter "Messages" passed to class methods                   */
/*                                                                                */
/**********************************************************************************/

/* OGM_ERASE */
struct ogmErase
{
   ULONG              MethodID;
   struct GadgetInfo *ogm_GInfo;
   BOOL               ogm_BroadCast;
};


/* OGM_GETREALBOX */
struct ogmGetRealBox
{
   ULONG              MethodID;
   struct GadgetInfo *ogm_GInfo;
   struct IBox       *ogm_Frame;
   ULONG              ogm_Flags;
};

/* Flags for ogmGetRealBox.ogm_Flags */
#define GRB_F_ABSOLUTE     (0x0000)
#define GRB_F_RELATIVE     (0x0001)


/* OGM_ADDTARGET */
struct ogmAddTarget
{
   ULONG           MethodID;
   Object         *ogm_Target;
   struct TagItem *ogm_Map;
   Tag            *ogm_Filter;
};


/* OGM_REMTARGET */
struct ogmRemTarget
{
   ULONG   MethodID;
   Object *ogm_Target;
};


/**********************************************************************************/
/*                                                                                */
/*                          VisualInfo Attributes                                 */
/*                                                                                */
/**********************************************************************************/
#define OVI_Dummy                   (OGT_Dummy - 0x1000)

#define OVI_GimmeZeroZero           (OVI_Dummy + 0x00)
#define OVI_AdaptWidthToFont        (OVI_Dummy + 0x01)
#define OVI_AdaptHeightToFont       (OVI_Dummy + 0x02)


/**********************************************************************************/
/*                                                                                */
/*                               TAGs handling                                    */
/*                                                                                */
/**********************************************************************************/
struct TagItemMulti
{
   Tag   OriginalTag;
   Tag   MappedTag;
   ULONG Value;
};


/**********************************************************************************/
/*                                                                                */
/*                             Memory handling                                    */
/*                                                                                */
/**********************************************************************************/
struct OGT_PooledMemHeader
{
   struct SignalSemaphore AccessSem;   /* READ-ONLY */
   struct MinList         List;        /* READ-ONLY */
   ULONG                  Size;        /* READ-ONLY */
   ULONG                  Attributes;  /* READ-ONLY */
};

#ifndef OGT_OBJECTIVEGADTOOLSBASE_H
#include <OGT/ObjectiveGadToolsBase.h>
#endif

extern struct ObjectiveGadToolsBase *ObjectiveGadToolsBase;

#ifndef OGT_OBJECTIVEGADTOOLS_PROTOS_H
#include <OGT/ObjectiveGadTools_protos.h>
#endif

#ifndef OGT_OBJECTIVEGADTOOLS_LIB_H
#include <OGT/ObjectiveGadTools_lib.h>
#endif

#endif /* OGT_OBJECTIVEGADTOOLS_H */
