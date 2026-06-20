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

#pragma libcall ObjectiveGadToolsBase OGT_OpenWindowTagList 1e 9802
#pragma libcall ObjectiveGadToolsBase OGT_CloseWindow 24 9802
#pragma libcall ObjectiveGadToolsBase OGT_GetMsgForWindow 2a 801
#pragma libcall ObjectiveGadToolsBase OGT_GetMsgForWindowWithClass 30 10803
#pragma libcall ObjectiveGadToolsBase OGT_GetVisualInfoA 36 9802
#pragma libcall ObjectiveGadToolsBase OGT_FreeVisualInfo 3c 801
#pragma libcall ObjectiveGadToolsBase OGT_RefreshWindow 42 801
#pragma libcall ObjectiveGadToolsBase OGT_GetWindowPtr 48 801
#pragma libcall ObjectiveGadToolsBase OGT_GetMsg 4e 801
#pragma libcall ObjectiveGadToolsBase OGT_ReplyMsg 54 801
#pragma libcall ObjectiveGadToolsBase OGT_BuildObjects 5a 981004
#pragma libcall ObjectiveGadToolsBase OGT_FontMeanSize 60 9802
#pragma libcall ObjectiveGadToolsBase OGT_SizeTagList 66 801
#pragma libcall ObjectiveGadToolsBase OGT_TagPosInArray 6c 9802
#pragma libcall ObjectiveGadToolsBase OGT_SetTagData 72 81003
#pragma libcall ObjectiveGadToolsBase OGT_GetLastTagData 78 81003
#pragma libcall ObjectiveGadToolsBase OGT_GetMultiTagData 7e 81003
#pragma libcall ObjectiveGadToolsBase OGT_FilterTagData 84 81003
#pragma libcall ObjectiveGadToolsBase OGT_FindLastTagItem 8a 8002
#pragma libcall ObjectiveGadToolsBase OGT_TagItemInArray 90 8002
#pragma libcall ObjectiveGadToolsBase OGT_InsertATagItem 96 10803
#pragma libcall ObjectiveGadToolsBase OGT_InsertTagItemsA 9c 9802
#pragma libcall ObjectiveGadToolsBase OGT_FindFirstMatch a2 9802
#pragma libcall ObjectiveGadToolsBase OGT_MapTags a8 9803
#pragma libcall ObjectiveGadToolsBase OGT_SignalTags ae 9803
#pragma libcall ObjectiveGadToolsBase OGT_FilterRange b4 210804
#pragma libcall ObjectiveGadToolsBase OGT_UpdateTagItemsA ba 9802
#pragma libcall ObjectiveGadToolsBase OGT_FreeTagItems c0 801
#pragma libcall ObjectiveGadToolsBase OGT_AllocateTagItems c6 1
#pragma libcall ObjectiveGadToolsBase OGT_CloneTagItems cc 801
#pragma libcall ObjectiveGadToolsBase OGT_ReduceTagItems d2 801
#pragma libcall ObjectiveGadToolsBase OGT_MergeTagItemsA d8 9802
#pragma libcall ObjectiveGadToolsBase OGT_TackOnTagItemsA de 9802
#pragma libcall ObjectiveGadToolsBase OGT_CloneAndMap e4 9802
#pragma libcall ObjectiveGadToolsBase OGT_CloneAndFilter ea 9803
#pragma libcall ObjectiveGadToolsBase OGT_CloneAndComplete f0 9802
#pragma libcall ObjectiveGadToolsBase OGT_GetANode f6 802
#pragma libcall ObjectiveGadToolsBase OGT_FindNodeInList fc 9802
#pragma libcall ObjectiveGadToolsBase OGT_FindNodePos 102 9802
#pragma libcall ObjectiveGadToolsBase OGT_SizeList 108 801
#pragma libcall ObjectiveGadToolsBase OGT_MoveNodes 10e 9802
#pragma libcall ObjectiveGadToolsBase OGT_FreeMem 114 80903
#pragma libcall ObjectiveGadToolsBase OGT_AllocMem 11a 81003
#pragma libcall ObjectiveGadToolsBase OGT_FreeVec 120 8902
#pragma libcall ObjectiveGadToolsBase OGT_AllocVec 126 81003
#pragma libcall ObjectiveGadToolsBase OGT_InitMem 12c 81003
#pragma libcall ObjectiveGadToolsBase OGT_CleanMem 132 801
#pragma libcall ObjectiveGadToolsBase OGT_Fork 138 9802
#pragma libcall ObjectiveGadToolsBase OGT_DuplicateMsgPort 13e 9802
#pragma libcall ObjectiveGadToolsBase OGT_SignedScalerDiv 144 21003
#pragma libcall ObjectiveGadToolsBase OGT_IsPointInsideBox 14a 81003
#pragma libcall ObjectiveGadToolsBase OGT_BeginFramedDrawing 150 9802
#pragma libcall ObjectiveGadToolsBase OGT_EndFramedDrawing 156 9802
#pragma libcall ObjectiveGadToolsBase OGT_DrawVectorImage 15c 981004

#endif /* OGT_OBJECTIVEGADTOOLS_LIB_H */
