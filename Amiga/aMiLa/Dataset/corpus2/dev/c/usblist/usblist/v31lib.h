/****************************************************************/
/* Exec remplacement routines                                   */
/****************************************************************/
/* 2008, Gilles Pelletier some code to work on 3.1 and lower    */
/****************************************************************/

#ifndef SysBase
extern struct Library *SysBase ;
#endif

#include <stdlib.h>
#include <string.h>

#include <clib/alib_protos.h>

/* Some code to work even on KS 1.1 */

APTR MAllocVec(ULONG byteSize, ULONG requirements) ;
void MFreeVec(APTR memoryBlock) ;
struct MsgPort* MCreateMsgPort(void) ;
void MCopyMem(APTR source, APTR dest, ULONG size) ;
void MDeleteMsgPort(struct MsgPort *port) ;
APTR MCreateIORequest(struct MsgPort *port, ULONG size) ;
void MDeleteIORequest(APTR iorequest) ;


APTR MCreateIORequest(struct MsgPort *port, unsigned long size) 
{
  if (SysBase->lib_Version >= 36)
  {
    return CreateIORequest(port, size) ;
  }
  else
  {
    struct IORequest *io ;

    if (size < sizeof(struct Message)) size = sizeof(struct Message) ;

    io = (struct IORequest*) MAllocVec(size, MEMF_PUBLIC|MEMF_CLEAR) ;
    if (io != NULL)
    {
      io->io_Message.mn_Node.ln_Type = NT_MESSAGE ;
      io->io_Message.mn_ReplyPort    = port ;
      io->io_Message.mn_Length       = size ;
    }
    return io ;
  }
}

void MDeleteIORequest(APTR iorequest) 
{
  if (SysBase->lib_Version >= 36)
  {
    DeleteIORequest(iorequest) ;
  }
  else
  {
    MFreeVec(iorequest) ;
  }
}

struct MsgPort* MCreateMsgPort(void)
{
  if (SysBase->lib_Version >= 36)
  {
    return CreateMsgPort() ;
  }
  else
  {
    BYTE signal ;
    struct MsgPort *port ;

    signal = AllocSignal(-1) ;
    if (signal == -1)
    {
      return NULL ;
    }

    port = AllocMem( sizeof(struct MsgPort),
                     MEMF_PUBLIC|MEMF_CLEAR ) ;
    if (port == NULL)
    {
      FreeSignal(signal) ;
      return NULL ;
    }

    port->mp_Node.ln_Name = NULL ;
    port->mp_Node.ln_Pri  = 0 ;
    port->mp_Node.ln_Type = NT_MSGPORT ;
    port->mp_Flags        = PA_SIGNAL ;
    port->mp_SigBit       = signal ;
    port->mp_SigTask      = FindTask(NULL) ;
    NewList(&(port->mp_MsgList)) ;
    return port ;
  }
}

void MDeleteMsgPort(struct MsgPort *port)
{
  if (SysBase->lib_Version >= 36)
  {
    DeleteMsgPort(port) ;
  }
  else
  {
    port->mp_Node.ln_Type = 0xff ;
    port->mp_MsgList.lh_Head = (struct Node*)-1 ;
    FreeSignal(port->mp_SigBit) ;
    FreeMem(port, sizeof(struct MsgPort)) ;
  }
}

APTR MAllocVec( unsigned long byteSize, unsigned long requirements )
{
  if (SysBase->lib_Version >= 36)
  {
    return AllocVec(byteSize, requirements) ;
  }
  else
  {
    unsigned long *data = NULL ;

    byteSize += sizeof(unsigned long) ;
    data = (unsigned long *)AllocMem(byteSize, requirements) ;
  
    *data = byteSize ;
    data++ ;
    return data ;
  }
}

void MFreeVec( APTR memoryBlock )
{
  if (SysBase->lib_Version >= 36)
  {
    FreeVec(memoryBlock) ;
  }
  else
  {
    unsigned long byteSize ;
    unsigned long *data ;

    data = (unsigned long*)memoryBlock ;
    data-- ;
    byteSize = *data ;
    FreeMem(data, byteSize) ;
  }
}

void MCopyMem(APTR source, APTR dest, ULONG size)
{
  if (SysBase->lib_Version >= 33)
  {
    CopyMem(source, dest, size) ;
  }
  else
  {
#if 0
    register UBYTE *src = (UBYTE *)source ;
    register UBYTE *dst = (UBYTE *)dest ;
    while (size > 0)
    {
      *dst++ = *src++ ;
      size -- ;
    }
#else
    memcpy(dest, source, size) ;
#endif
  }
}

/* Now, the crazy thing, undef all routines we wan't to make */
/* compatible with all versions of OS                        */
#undef AllocVec
#undef FreeVec
#undef CopyMem
#undef CreateMsgPort
#undef DeleteMsgPort
#undef CreateIORequest
#undef DeleteIORequest

#define AllocVec MAllocVec
#define FreeVec MFreeVec
#define CopyMem MCopyMem
#define CreateMsgPort MCreateMsgPort
#define DeleteMsgPort MDeleteMsgPort
#define CreateIORequest MCreateIORequest
#define DeleteIORequest MDeleteIORequest

/* That's all */
