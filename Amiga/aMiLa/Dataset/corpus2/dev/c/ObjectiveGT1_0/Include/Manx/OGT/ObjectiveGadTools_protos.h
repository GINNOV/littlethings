#ifndef OGT_OBJECTIVEGADTOOLS_PROTOS_H
#define OGT_OBJECTIVEGADTOOLS_PROTOS_H
/*
** $Filename: OGT/ObjectiveGadTools_protos.h $
** $Release : 1.0                            $
** $Revision: 1.000                          $
** $Date    : 18/10/92                       $
**
**
** (C) Copyright 1991,1992 Davide Massarenti
**              All Rights Reserved
*/

#ifndef OGT_OBJECTIVEGADTOOLS_H
#include <OGT/ObjectiveGadTools.h>
#endif

/**********************************************************************************/
/*                                                                                */
/*                                  General                                       */
/*                                                                                */
/**********************************************************************************/
struct Window *OGT_OpenWindowTagList( struct MsgPort *port, struct TagItems *tags );
struct Window *OGT_OpenWindowTags   ( struct MsgPort *port,                  ...  );
void           OGT_CloseWindow      ( struct MsgPort *port, struct Window   *win  );

struct IntuiMessage *OGT_GetMsgForWindow         ( struct Window *win                                   );
struct IntuiMessage *OGT_GetMsgForWindowWithClass( struct Window *win, LONG class, LONG qualifiers_mask );

APTR                 OGT_GetVisualInfoA( struct MsgPort *port, struct TagItem *tags );
APTR                 OGT_GetVisualInfo ( struct MsgPort *port,                 ...  );
void                 OGT_FreeVisualInfo( APTR vinfo                                 );
BOOL                 OGT_RefreshWindow ( APTR vinfo                                 );
struct Window       *OGT_GetWindowPtr  ( APTR vinfo                                 );
struct IntuiMessage *OGT_GetMsg        ( APTR vinfo                                 );
void                 OGT_ReplyMsg      ( struct IntuiMessage *msg                   );

BOOL OGT_BuildObjects( APTR vinfo, struct OGT_ObjectSettings *objectsarray, struct OGT_ObjectLink *linksarray, Object ***storage );

void OGT_FontMeanSize( struct TextFont *font, struct TextExtent *buffer );


/**********************************************************************************/
/*                                                                                */
/*                             TAGs Handling                                      */
/*                                                                                */
/**********************************************************************************/
ULONG           OGT_SizeTagList     (                          struct TagItem *list  );
ULONG           OGT_TagPosInArray   ( Tag  tag ,               Tag            *array );
void            OGT_SetTagData      ( Tag  tag , ULONG  data , struct TagItem *list  );
ULONG           OGT_GetLastTagData  ( Tag  tag , ULONG  data , struct TagItem *list  );
void            OGT_GetMultiTagData ( Tag *tags, ULONG *datas, struct TagItem *list  );
void            OGT_FilterTagData   ( Tag  tag , ULONG  data , struct TagItem *list  );
struct TagItem *OGT_FindLastTagItem ( Tag  tag ,               struct TagItem *list  );
struct TagItem *OGT_TagItemInArray  ( Tag  tag ,               struct TagItem *array );

void            OGT_InsertATagItem  ( struct TagItem *array, Tag tag, ULONG  data     );
void            OGT_InsertTagItemsA ( struct TagItem *array, struct TagItem *newitems );
void            OGT_InsertTagItems  ( struct TagItem *array,                 ...      );

struct TagItem *OGT_FindFirstMatch  ( struct TagItem  *tagList, Tag            *tagMatch                                        );
LONG            OGT_MapTags         ( struct TagItem  *taglist, struct TagItem *maplist   ,                   LONG  includemiss );
ULONG           OGT_SignalTags      ( struct TagItem  *list   , struct TagItem *maskarray , BOOL  usedata                       );
void            OGT_FilterRange     ( struct TagItem  *list   , ULONG           lowerbound, ULONG upperbound, LONG  includemiss );
void            OGT_UpdateTagItemsA ( struct TagItem  *list   , struct TagItem *updates                                         );
void            OGT_UpdateTagItems  ( struct TagItem  *list   ,                 ...                                             );

void            OGT_FreeTagItems    (                         struct TagItem      *list                );
struct TagItem *OGT_AllocateTagItems( ULONG            size                                            );
struct TagItem *OGT_CloneTagItems   (                         struct TagItem      *list                );
struct TagItem *OGT_ReduceTagItems  (                         struct TagItem      *list                );
struct TagItem *OGT_MergeTagItemsA  ( struct TagItem  *listA, struct TagItem      *listB               );
struct TagItem *OGT_MergeTagItems   ( struct TagItem  *list ,                      ...                 );
struct TagItem *OGT_TackOnTagItemsA ( struct TagItem **listA, struct TagItem      *listB               );
struct TagItem *OGT_TackOnTagItems  ( struct TagItem **list ,                      ...                 );
struct TagItem *OGT_CloneAndMap     ( struct TagItem  *list , struct TagItem      *map                 );
struct TagItem *OGT_CloneAndFilter  ( struct TagItem  *list , Tag                 *array  , LONG logic );
struct TagItem *OGT_CloneAndComplete( struct TagItem  *list , struct TagItemMulti *convert             );


/**********************************************************************************/
/*                                                                                */
/*                             LISTs Handling                                     */
/*                                                                                */
/**********************************************************************************/
struct MinNode *OGT_GetANode      ( struct MinList *list, LONG            which );
BOOL            OGT_FindNodeInList( struct MinList *list, struct MinNode *node  );
LONG            OGT_FindNodePos   ( struct MinList *list, struct MinNode *node  );
ULONG           OGT_SizeList      ( struct MinList *list                        );
void            OGT_MoveNodes     ( struct MinList *from, struct MinList *to    );


/**********************************************************************************/
/*                                                                                */
/*                            Memory Handling                                     */
/*                                                                                */
/**********************************************************************************/
void OGT_FreeMem ( APTR  block, ULONG size, struct OGT_PooledMemHeader *info );
APTR OGT_AllocMem( ULONG size , ULONG attr, struct OGT_PooledMemHeader *info );
void OGT_FreeVec ( APTR  block,             struct OGT_PooledMemHeader *info );
APTR OGT_AllocVec( ULONG size , ULONG attr, struct OGT_PooledMemHeader *info );
void OGT_InitMem ( ULONG size , ULONG attr, struct OGT_PooledMemHeader *info );
void OGT_CleanMem(                          struct OGT_PooledMemHeader *info );


/**********************************************************************************/
/*                                                                                */
/*                            Process Handling                                    */
/*                                                                                */
/**********************************************************************************/
struct Process *OGT_Fork( SHORT (*code)(), void *data );

void OGT_DuplicateMsgPort( struct MsgPort *old, struct MsgPort *new );


/**********************************************************************************/
/*                                                                                */
/*                               Miscellaneous                                    */
/*                                                                                */
/**********************************************************************************/
WORD OGT_SignedScalerDiv   ( SHORT factor, USHORT numerator, USHORT denominator);
BOOL OGT_IsPointInsideBox  ( SHORT x, SHORT y,    struct IBox *box             );
APTR OGT_BeginFramedDrawing( struct RastPort *rp, struct IBox *box             );
void OGT_EndFramedDrawing  ( struct RastPort *rp, APTR ret                     );

void OGT_DrawVectorImage( struct RastPort *rp, USHORT *pens, struct IBox *box, struct OGT_VectorElement *image );

BOOL OpenOGT ( void );
void CloseOGT( void );

#endif /* OGT_OBJECTIVEGADTOOLS_PROTOS_H */
