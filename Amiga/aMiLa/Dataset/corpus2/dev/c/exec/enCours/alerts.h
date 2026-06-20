/* Alerts.h - exec library function prototypes */

/*
** Copyright (C) 1986, by MTS Associates, Jacksonville FL
** All rights reserved.  Duplication of this data by other than
** licensed users is a violation of copyright law.
**
** Function prototypes for the exec.library of Amiga EXEC
**
** Portions (C) 1986 by Commodore-Amiga, Inc.
**
** Updated: 11/17/86, TFH
*/

#ifndef EXEC_ALERTS_H
#define EXEC_ALERTS_H

#define SF_ALERTWACK (1<<1)   /* in ExecBase.SysFlag */


/*********************************************************************
*
*  Format of the alert error number:
*
*    +-+-------------+----------------+--------------------------------+  
*    |D|  SubSysId   |  General Error |    SubSystem Specific Error    |
*    +-+-------------+----------------+--------------------------------+
*
*          D:  DeadEnd alert
*        SubSysId:  indicates ROM subsystem number.
*   General Error:  roughly indicates what the error was
*  Specific Error:  indicates more detail
**********************************************************************/

/*********************************************************************
*
*  General Dead-End Alerts
*
*  For example: timer.device can't open math.library
*
*     ALERT(AN_TimerDev|AG_OpenLib|AO_MathLib)
*
*********************************************************************/

/*------ alert types */
#define AT_DeadEnd   0x80000000
#define AT_Recovery  0x00000000

/*------ general purpose alert codes */
#define AG_NoMemory  0x00010000
#define AG_MakeLib   0x00020000
#define AG_OpenLib   0x00030000
#define AG_OpenDev   0x00040000
#define AG_OpenRes   0x00050000
#define AG_IOError   0x00060000

/*------ alert objects: */
#define AO_ExecLib   0x00008001
#define AO_GraphicsLib  0x00008002
#define AO_LayersLib 0x00008003
#define AO_Intuition 0x00008004
#define AO_MathLib   0x00008005
#define AO_CListLib  0x00008006
#define AO_DOSLib 0x00008007
#define AO_RAMLib 0x00008008
#define AO_IconLib   0x00008009
#define AO_AudioDev  0x00008010
#define AO_ConsoleDev   0x00008011
#define AO_GamePortDev  0x00008012
#define AO_KeyboardDev  0x00008013
#define AO_TrackDiskDev 0x00008014
#define AO_TimerDev  0x00008015
#define AO_CIARsrc   0x00008020
#define AO_DiskRsrc  0x00008021
#define AO_MiscRsrc  0x00008022
#define AO_BootStrap    0x00008030
#define AO_Workbench    0x00008031


/*********************************************************************
*
*   Specific Dead-End Alerts:
*
*********************************************************************/

/*------ exec.library */
#define AN_ExecLib   0x01000000
#define AN_ExcptVect 0x81000001  /* 68000 exception vector checksum */
#define AN_BaseChkSum   0x81000002  /* execbase checksum */
#define AN_LibChkSum 0x81000003  /* library checksum failure */
#define AN_LibMem 0x81000004  /* no memory to make library */
#define AN_MemCorrupt   0x81000005  /* corrupted memory list */
#define AN_IntrMem   0x81000006  /* no memory for interrupt servers */

/*------ graphics.library */
#define AN_GraphicsLib  0x02000000
#define AN_CopDisplay   0x82010001  /* copper display list, no memory */
#define AN_CopInstr  0x82010002  /* copper instruction list, no memory */
#define AN_CopListOver  0x82000003  /* copper list overload */
#define AN_CopIListOver 0x82000004  /* copper intermediate list overload */
#define AN_CopListHead  0x82010005  /* copper list head, no memory */
#define AN_LongFrame 0x82010006  /* long frame, no memory */
#define AN_ShortFrame   0x82010007  /* short frame, no memory */
#define AN_FloodFill 0x82010008  /* flood fill, no memory */
#define AN_TextTmpRas   0x02010009  /* text, no memory for TmpRas */
#define AN_BltBitMap 0x8201000A  /* BltBitMap, no memory */

/*------ layers.library */
#define AN_LayersLib 0x03000000

/*------ intuition.library */
#define AN_Intuition 0x04000000
#define AN_GadgetType   0x84000001  /* unknown gadet type */
#define AN_BadGadget 0x04000001  /* Recovery form of AN_GadgetType */
#define AN_CreatePort   0x84010002  /* create port, no memory */
#define AN_ItemAlloc 0x84010003  /* item plane alloc, no memory */
#define AN_SubAlloc  0x84010004  /* sub alloc, no memory */
#define AN_PlaneAlloc   0x84010005  /* plane alloc, no memory */
#define AN_ItemBoxTop   0x84000006  /* item box top < RelZero */
#define AN_OpenScreen   0x84010007  /* open screen, no memory */
#define AN_OpenScrnRast 0x84010008  /* open screen, raster alloc, no memory */
#define AN_SysScrnType  0x84000009  /* open sys screen, unknown type */
#define AN_AddSWGadget  0x8401000A  /* add SW gadgets, no memory */
#define AN_OpenWindow   0x8401000B  /* open window, no memory */
#define  AN_BadState 0x8400000C  /* Bad State Return entering Intuition */
#define  AN_BadMessage  0x8400000D  /* Bad Message received by IDCMP */
#define  AN_WeirdEcho   0x8400000E  /* Weird echo causing incomprehension */
#define  AN_NoConsole   0x8400000F  /* couldn't open the Console Device */


/*------ math.library */
#define AN_MathLib   0x05000000

/*------ clist.library */
#define AN_CListLib  0x06000000

/*------ dos.library */
#define AN_DOSLib 0x07000000
#define AN_StartMem  0x07010001  /* no memory at startup */
#define AN_EndTask   0x07000002  /* EndTask didn't */
#define AN_QPktFail  0x07000003  /* Qpkt failure */
#define AN_AsyncPkt  0x07000004  /* Unexpected packet received */
#define AN_FreeVec   0x07000005  /* Freevec failed */
#define AN_DiskBlkSeq   0x07000006  /* Disk block sequence error */
#define AN_BitMap 0x07000007  /* Bitmap corrupt */
#define AN_KeyFree   0x07000008  /* Key already free */
#define AN_BadChkSum 0x07000009  /* Invalid checksum */
#define AN_DiskError 0x0700000A  /* Disk Error */
#define AN_KeyRange  0x0700000B  /* Key out of range */
#define AN_BadOverlay   0x0700000C  /* Bad overlay */

/*------ ramlib.library */
#define AN_RAMLib 0x08000000

/*------ ramlib.library */
#define AN_IconLib   0x09000000

/*------ audio.device */
#define AN_AudioDev  0x10000000

/*------ console.device */
#define AN_ConsoleDev   0x11000000

/*------ gameport.device */
#define AN_GamePortDev  0x12000000

/*------ keyboard.device */
#define AN_KeyboardDev  0x13000000

/*------ trackdisk.device */
#define AN_TrackDiskDev 0x14000000
#define AN_TDCalibSeek  0x14000001  /* calibrate: seek error */
#define AN_TDDelay   0x14000002  /* delay: error on timer wait */

/*------ timer.device */
#define AN_TimerDev  0x15000000
#define AN_TMBadReq  0x15000001  /* bad request */

/*------ cia.resource */
#define AN_CIARsrc   0x20000000

/*------ disk.resource */
#define AN_DiskRsrc  0x21000000
#define AN_DRHasDisk 0x21000001  /* get unit: already has disk */
#define AN_DRIntNoAct   0x21000002  /* interrupt: no active unit */

/*------ misc.resource */
#define AN_MiscRsrc  0x22000000

/*------ bootstrap */
#define AN_BootStrap    0x30000000
#define AN_BootError 0x30000001  /* boot code returned an error */

/*------ Workbench */
#define AN_Workbench 0x31000000

void Alert(const LONGBITS alertnum, const APTR whoknows=NULL);

#endif !EXEC_ALERTS_H
