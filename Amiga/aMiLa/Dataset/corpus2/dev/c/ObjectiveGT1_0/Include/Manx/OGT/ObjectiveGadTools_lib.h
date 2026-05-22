#ifndef OGT_OBJECTIVEGADTOOLS_LIB_H
#define OGT_OBJECTIVEGADTOOLS_LIB_H 1
/*
** $Filename: OGT/ObjectiveGadTools_lib.h $
** $Release : 1.0                         $
** $Revision: 1.000                       $
** $Date    : 18/10/92                    $
**
**
** (C) Copyright 1991,1992 Davide Massarenti
**              All Rights Reserved
*/

#pragma amicall(ObjectiveGadToolsBase, 0x1e, OGT_OpenWindowTagList(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x24, OGT_CloseWindow(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x2a, OGT_GetMsgForWindow(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x30, OGT_GetMsgForWindowWithClass(a0,d0,d1))
#pragma amicall(ObjectiveGadToolsBase, 0x36, OGT_GetVisualInfoA(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x3c, OGT_FreeVisualInfo(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x42, OGT_RefreshWindow(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x48, OGT_GetWindowPtr(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x4e, OGT_GetMsg(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x54, OGT_ReplyMsg(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x5a, OGT_BuildObjects(d0,d1,a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x60, OGT_FontMeanSize(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x66, OGT_SizeTagList(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x6c, OGT_TagPosInArray(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x72, OGT_SetTagData(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x78, OGT_GetLastTagData(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x7e, OGT_GetMultiTagData(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x84, OGT_FilterTagData(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x8a, OGT_FindLastTagItem(d0,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x90, OGT_TagItemInArray(d0,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x96, OGT_InsertATagItem(a0,d0,d1))
#pragma amicall(ObjectiveGadToolsBase, 0x9c, OGT_InsertTagItemsA(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xa2, OGT_FindFirstMatch(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xa8, OGT_MapTags(a0,a1,d0))
#pragma amicall(ObjectiveGadToolsBase, 0xae, OGT_SignalTags(a0,a1,d0))
#pragma amicall(ObjectiveGadToolsBase, 0xb4, OGT_FilterRange(a0,d0,d1,d2))
#pragma amicall(ObjectiveGadToolsBase, 0xba, OGT_UpdateTagItemsA(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xc0, OGT_FreeTagItems(a0))
#pragma amicall(ObjectiveGadToolsBase, 0xc6, OGT_AllocateTagItems(d0))
#pragma amicall(ObjectiveGadToolsBase, 0xcc, OGT_CloneTagItems(a0))
#pragma amicall(ObjectiveGadToolsBase, 0xd2, OGT_ReduceTagItems(a0))
#pragma amicall(ObjectiveGadToolsBase, 0xd8, OGT_MergeTagItemsA(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xde, OGT_TackOnTagItemsA(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xe4, OGT_CloneAndMap(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xea, OGT_CloneAndFilter(a0,a1,d0))
#pragma amicall(ObjectiveGadToolsBase, 0xf0, OGT_CloneAndComplete(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0xf6, OGT_GetANode(a0,d0))
#pragma amicall(ObjectiveGadToolsBase, 0xfc, OGT_FindNodeInList(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x102, OGT_FindNodePos(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x108, OGT_SizeList(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x10e, OGT_MoveNodes(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x114, OGT_FreeMem(a1,d0,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x11a, OGT_AllocMem(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x120, OGT_FreeVec(a1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x126, OGT_AllocVec(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x12c, OGT_InitMem(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x132, OGT_CleanMem(a0))
#pragma amicall(ObjectiveGadToolsBase, 0x138, OGT_Fork(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x13e, OGT_DuplicateMsgPort(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x144, OGT_SignedScalerDiv(d0,d1,d2))
#pragma amicall(ObjectiveGadToolsBase, 0x14a, OGT_IsPointInsideBox(d0,d1,a0))
#pragma amicall(ObjectiveGadToolsBase, 0x150, OGT_BeginFramedDrawing(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x156, OGT_EndFramedDrawing(a0,a1))
#pragma amicall(ObjectiveGadToolsBase, 0x15c, OGT_DrawVectorImage(d0,d1,a0,a1))

#endif /* OGT_OBJECTIVEGADTOOLS_LIB_H */
