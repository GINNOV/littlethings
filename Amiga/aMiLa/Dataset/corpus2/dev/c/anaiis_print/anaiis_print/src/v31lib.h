/****************************************************************/
/* v31lib.h                                                     */
/****************************************************************/
/*                                                              */
/* Compatibility layer                                          */
/*                                                              */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 16-Oct-2009 Remove MFPrintf DOSBase reference                */
/* 21-Sep-2008 Semaphores                                       */
/* 13-Sep-2008 MFPrintf                                         */
/* 04-Mar-2008 CopyMem                                          */
/* 03-Mar-2008 rename v33 into v31                              */
/* 27-Jan-2008 utility                                          */
/* 04-Oct-2007 my own sprintf                                   */
/* 18-Jun-1993 first steps                                      */
/****************************************************************/


#define WB33_COMPATIBLE
#define WB33_BESTCODE

#include <exec/types.h>
#include <exec/memory.h>

#include <dos/dosextens.h>

#include <utility/tagitem.h>

#include "compiler.h"

#ifdef WB33_COMPATIBLE
#ifdef WB33_IO
APTR MCreateIORequest(struct MsgPort *port, ULONG size) ;
void MDeleteIORequest(APTR iorequest) ;
#define WB33_MEMORY
#endif

#ifdef WB33_MEMORY
APTR MAllocVec(ULONG byteSize, ULONG requirements) ;
void MFreeVec(APTR memoryBlock) ;
void MCopyMem(APTR source, APTR dest, ULONG size) ;
#endif
#ifdef WB33_PORTS
struct MsgPort* MCreateMsgPort(void) ;
void MDeleteMsgPort(struct MsgPort *port) ;
#endif

#ifdef WB33_TAGS
struct TagItem *MNextTagItem(struct TagItem **tagListPtr) ;
#endif
#ifdef WB33_SEMAPHORES
void ASM MInitSemaphore(A0 struct SignalSemaphore *sigSem) ;
void ASM MObtainSemaphore(A0 struct SignalSemaphore *sigSem) ;
void ASM MReleaseSemaphore(A0 struct SignalSemaphore *sigSem) ;
BOOL ASM MAttemptSemaphore(A0 struct SignalSemaphore *sigSem) ;
#endif

#include "v31lib.c.in"

#ifdef WB33_IO
#undef CreateIORequest
#undef DeleteIORequest
#define CreateIORequest MCreateIORequest
#define DeleteIORequest MDeleteIORequest
#endif

#ifdef WB33_PORTS
#undef CreateMsgPort
#undef DeleteMsgPort
#define CreateMsgPort MCreateMsgPort
#define DeleteMsgPort MDeleteMsgPort
#endif

#ifdef WB33_MEMORY
#undef AllocVec
#undef FreeVec
#undef CopyMem
#define AllocVec MAllocVec
#define FreeVec MFreeVec
#define CopyMem MCopyMem
#endif

#ifdef WB33_TAGS
#undef NextTagItem
#define NextTagItem MNextTagItem
#endif

#ifdef WB33_SEMAPHORES
#undef InitSemaphore
#undef ObtainSemaphore
#undef ReleaseSemaphore
#undef AttemptSemaphore
#define InitSemaphore MInitSemaphore
#define ObtainSemaphore MObtainSemaphore
#define ReleaseSemaphore MReleaseSemaphore
#define AttemptSemaphore MAttemptSemaphore
#endif

#endif

