/*
**      lineread.c - functions to read lines from sockets effectively
**
**      Copyright © 1994 AmiTCP/IP Group,
**                       Network Solutions Development Inc.
**                       All rights reserved.
**
**      Modified by Alfonso Ranieri
**
*/

/***************************************************************************/

#include "freedb.h"
#include "proc.h"

/***************************************************************************/

int ASM
lineRead(REG(a0) struct lineRead *lr)
{
    register struct Library *SocketBase = lr->socketBase;
    register int            i;

    if (lr->bufPtr==lr->howLong)
        if (lr->selected)
        {
            if (lr->lineCompleted)
                lr->startp = lr->bufPtr = 0;

            if ((i = recv(lr->sock,lr->buffer+lr->bufPtr,lr->bufferSize-lr->bufPtr,0))<=0)
            {
                /*
                 * here if end-of-file or on error. set Howlong == Bufpointer
                 * so if non-blocking I/O is in use next call will go to READ()
                 */
                lr->howLong = lr->bufPtr;
                lr->line = NULL;
                return i;
            }
            else lr->howLong = lr->bufPtr + i;
        }
        else
        {
            /* Inform user that next call may block (unless select()ed) */
            lr->selected = TRUE;
            return 0;
        }
    else /* Bufpointer has not reached Howlong yet. */
    {
        lr->buffer[lr->bufPtr] = lr->saved;
        lr->startp = lr->bufPtr;
    }

    /*
    * Scan read string for next newline.
    */
    while (lr->bufPtr<lr->howLong)
        if (lr->buffer[lr->bufPtr++]=='\n')
              goto Skip;

    /*
    * Here if Bufpointer == Howlong.
    */
    if (lr->type!=LRV_Type_NotReq)
    {
        lr->selected = TRUE;

        if (lr->bufPtr==lr->bufferSize)
        {
            /*
            * Here if Bufpointer reaches end-of-buffer.
            */
            if (lr->startp==0)
            {
                /* (buffer too short for whole string) */
                lr->lineCompleted = TRUE;
                lr->line = lr->buffer;
                lr->buffer[lr->bufPtr] = '\0';
                return -1;
            }
            /*
            * Copy partial string to start-of-buffer and make control ready for
            * filling rest of buffer when next call to lineRead() is made
            * (perhaps after select()).
            */
            for (i = 0; i<lr->bufferSize-lr->startp; i++)
                lr->buffer[i] = lr->buffer[lr->startp+i];
            lr->howLong -= lr->startp;
            lr->bufPtr = lr->howLong;
            lr->startp = 0;
        }

        lr->lineCompleted = FALSE;
        return 0;
    }

Skip:
    lr->lineCompleted = TRUE;
    if (lr->type==LRV_Type_ReqNul) lr->buffer[lr->bufPtr-1] = '\0';
    lr->saved = lr->buffer[lr->bufPtr];
    lr->buffer[lr->bufPtr] = '\0';
    lr->selected = FALSE;
    lr->line = lr->buffer+lr->startp;

    return (lr->bufPtr-lr->startp);
}

/***************************************************************************/

void ASM
initLineRead(REG(a0) struct lineRead *lr,
             REG(a1) struct Library *socketBase,
             REG(d0) int fd,
             REG(d1) int type,
             REG(d2) int bufferSize)
{
    lr->socketBase = socketBase;
    lr->sock       = fd;
    lr->type       = type;
    lr->bufPtr     = lr->howLong = 0;
    lr->selected   = lr->lineCompleted = TRUE;
    lr->bufferSize = bufferSize;
}

/***************************************************************************/
/*
struct lineRead * ASM
allocLineRead(REG(d0) int type,REG(d1) int bufferSize)
{
    register struct lineRead *lr;

    if (lr = allocArbitratePooled(sizeof(struct lineRead)+bufferSize+1))
    {
        lr->socketBase = NULL;
        lr->sock       = -1;
        lr->type       = type;
        lr->bufPtr     = lr->howLong = 0;
        lr->selected   = lr->lineCompleted = TRUE;
        lr->bufferSize = bufferSize;
    }

    return lr;
}

/***************************************************************************/

void ASM
freeLineRead(REG(a0) struct lineRead *lr)
{
    freeArbitratePooled(lr,sizeof(struct lineRead)+lr->bufferSize+1);
}

/***************************************************************************/
*/
