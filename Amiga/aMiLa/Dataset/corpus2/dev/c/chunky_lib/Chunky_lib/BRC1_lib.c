/*
 * BRC1 library
 * Byte Run Compression (type 1) system
 * Originally based on various BRC sources and extra functions added by
 * Andrew "Oondy" King.
 *
 * (c) 1998 Rosande Limited, all rights reserved
 */

/*	control bytes:
 *	 [0..127]   : followed by n+1 bytes of data.
 *	 [-1..-127] : followed by byte to be repeated (-n)+1 times.
 *	 -128       : NOOP.
 */

//#define debugthis
 
#include <exec/memory.h>
#include <clib/exec_protos.h>
#ifdef debugthis
#include <stdio.h>
#endif

#include "BRC1.h"

static unsigned long PutSize;
static char buf[256];

//------------------------------------------------------- Private functions
static char *BRCPutDump(char *Destination, int Number)
{
  int i;

  PutByte(Number-1);
  for(i = 0; i < Number; i++) PutByte(buf[i]);
  return(Destination);
}

static char *BRCPutRun(char *Destination, int Number, int Count)
{
  PutByte(-(Number-1));
  PutByte(Count);
  return(Destination);
}

unsigned long BRC_PackBytes(char *pSource, char *pDest, long rowSize)
{
  char *source, *dest;
  char c,lastc = '\0';
  unsigned short mode = DUMP;
  short nbuf = 0, rstart = 0;

  source = pSource;
  dest = pDest;
  if(!source) return(NULL);

  PutSize = 0;
  buf[0] = lastc = c = (*source++);
  nbuf = 1; rowSize--;

  for(; rowSize; --rowSize)
  {
    buf[nbuf++] = c = (*source++);
    switch(mode)
    {
      case DUMP: 
      {
        if(nbuf>MAXDAT)
        {
          OutDump(nbuf-1);
          buf[0] = c;
          nbuf = 1;
          rstart = 0;
          break;
        }
        if(c == lastc)
        {
          if(nbuf-rstart >= MINRUN)
          {
            if(rstart > 0) OutDump(rstart);
            mode = RUN;
          }
          else if(rstart == 0)
          {
            mode = RUN;
          }
        }
        else
        {
          rstart = nbuf-1;
        }
        break;
      }
      case RUN:
      {
        if((c != lastc) || (nbuf-rstart > MAXRUN))
        {
          OutRun(nbuf-1-rstart,lastc);
          buf[0] = c;
          nbuf = 1; rstart = 0;
          mode = DUMP;
        }
        break;
      }
    }
    lastc = c;
  }
  
  switch(mode)
  {
    case DUMP: OutDump(nbuf); break;
    case RUN: OutRun(nbuf-rstart,lastc); break;
  }
//  *pSource = source;
//  *pDest = dest;
  return(PutSize);
}

unsigned short BRC_UnpackBytes(char *pSource, char *pDest, long srcBytes0, long dstBytes0)
{
  register char *source = pSource;
  register char *dest   = pDest;
  register short n;
  register long srcBytes = srcBytes0;
  register long dstBytes = dstBytes0;
  unsigned short error = TRUE;
  short minus128 = -128;
  register char c;
  
  while(dstBytes > 0)
  {
    if((srcBytes -= 1) < 0) goto ErrorExit;
    n = *source++;
    
    if(n >= 0)
    {
      n += 1;
      if((srcBytes -= n) < 0) goto ErrorExit;
      if((dstBytes -= n) < 0) goto ErrorExit;
      do
      {
        UPutByte(*source++);
      } while(--n > 0);
    }
    else if(n != minus128)
    {
      n = -n + 1;
      if((srcBytes -= 1) < 0) goto ErrorExit;
      if((dstBytes -= n) < 0) goto ErrorExit;
      c = *source++;
      do
      {
        UPutByte(c);
      } while(--n > 0);
    }
  }
  error = FALSE;

  ErrorExit:

#ifdef debugthis
  if(error)
  {
    printf("unpackrow exit: srcBytes=%ld->%ld dstBytes=%ld->%ld n=%ld error=%ld\n", srcBytes0, srcBytes, dstBytes0, dstBytes, n, error);
  }
#endif
  return(error);
}

//------------------------------------------------------- Public  functions
void BRC_FreeBuffer(struct BRC1Header *Buffer)
{
  if(Buffer)
  {
    if(Buffer->br_Buffer) FreeVec(Buffer->br_Buffer);
    FreeVec(Buffer);
  }
}

struct BRC1Header *BRC_Compress(void *Buffer, unsigned long BufferSize)
{
  struct BRC1Header *Result = NULL;
  void *WorkBuffer = NULL, *ResultBuffer = NULL;
  unsigned short Okay = FALSE;
  unsigned long PackedBytes;
  
  if(Buffer && BufferSize)
  {
    // Allocate the header
    if(Result = AllocVec(sizeof(struct BRC1Header), MEMF_CLEAR))
    {
      // Allocate a work buffer
      if(WorkBuffer = AllocVec(BufferSize, MEMF_CLEAR))
      {
        // Okay, compress the buffer
        PackedBytes = BRC_PackBytes(Buffer, WorkBuffer, BufferSize);
        if(PackedBytes)
        {
          // Woohoo - copy the work buffer to the buffer we're returning
          if(ResultBuffer = AllocVec(PackedBytes, MEMF_CLEAR))
          {
            CopyMem(WorkBuffer, ResultBuffer, PackedBytes);
            // Set up the result
            Result->br_Identification = HEAD_BRC1;
            Result->br_UnpackedSize   = BufferSize;
            Result->br_PackedSize     = PackedBytes;
            Result->br_Buffer         = ResultBuffer;
            Okay = TRUE;
          }
        }
      }
    }
  }
  
  if(!Okay)
  {
    if(ResultBuffer) FreeVec(ResultBuffer);
    if(Result)       FreeVec(Result);
    Result = NULL;
  }
  if(WorkBuffer)   FreeVec(WorkBuffer);
  return(Result);
}

void *BRC_Uncompress(struct BRC1Header *Buffer)
{
  void *UnBuffer = NULL;
  unsigned short Okay = FALSE;
  
  if(Buffer->br_Identification == HEAD_BRC1)
  {
    // Okay, let's unpack it
    if(UnBuffer = AllocVec(Buffer->br_UnpackedSize, MEMF_CLEAR))
    {
      if(!(BRC_UnpackBytes(Buffer->br_Buffer, UnBuffer, Buffer->br_PackedSize, Buffer->br_UnpackedSize)))
      {
        // Tada
        Okay = TRUE;
      }
    }
  }
  
  if(!Okay)
  {
    if(UnBuffer) FreeVec(UnBuffer);
    UnBuffer = NULL;
  }
  return(UnBuffer);
}

