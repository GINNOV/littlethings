/* -----------------------------------------------------------
  $VER: calc.clip.c 1.01 (28.01.1999)

  clipboard support for calculator project

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
  ------------------------------------------------------------ */

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/clipboard.h>
#include <libraries/dosextens.h>
#include <libraries/dos.h>

#include "Calc.h"

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* used structs */

struct IOClipReq *ior;
struct cbbuf *buf;

/* whats on screen */
extern char buffer[100];

int ReadClip(char *string)
{
/* Open clipboard.device unit 0 */
if (ior=CBOpen(0L))
    { /* Look for FTXT in clipboard */
    if (CBQueryFTXT(ior))
        { /* Obtain a copy of the contents of each CHRS chunk */

        while (buf=CBReadCHRS(ior))
              { /* Process data */
              sprintf(buffer, "%s",buf->mem);
              // printf("read string, (%s)",buffer);
              /* Free buffer allocated by CBReadCHRS() */
              CBFreeBuf(buf);
              }

        CBReadDone(ior);
        } /* end if */

    else { printf("No FTXT in clipboard\n");
           return(-1);
         }

    CBClose(ior);
    }

else { printf("Error opening clipboard unit 0\n");
       return(-1);
     }

return(0); /* it all went swimingly */
} /* end ReadClip */



int WriteClip(char *string)
{ /* Write a string to the clipboard */

// printf("wrote string, (%s)",string);
/* Open clipboard.device unit 0 */
if (ior = CBOpen(0L))
    {
    if (!(CBWriteFTXT(ior,string)))
        {
        printf("Error writing to clipboard: io_Error = %ld\n",ior->io_Error);
        return(-1);
        }
    CBClose(ior);
    }

else
    { printf("Error opening clipboard.device\n");
      return(-1);
    }

return(0);
} /* end write clip */


struct IOClipReq *CBOpen(ULONG unit)
{
struct MsgPort *mp;
struct IOStdReq *ior;

if (mp = CreatePort(0L,0L))
    {
    if (ior=(struct IOStdReq *)CreateExtIO(mp,sizeof(struct IOClipReq)))
        {
        if (!(OpenDevice("clipboard.device",unit,ior,0L)))
            {
            return((struct IOClipReq *)ior);
            }
        DeleteExtIO(ior);
        }
    DeletePort(mp);
    }
return(NULL);

}


void CBClose(struct IOClipReq *ior)
{
struct MsgPort *mp;

mp = ior->io_Message.mn_ReplyPort;

CloseDevice((struct IOStdReq *)ior);
DeleteExtIO((struct IOStdReq *)ior);
DeletePort(mp);

}

int CBWriteFTXT(struct IOClipReq *ior,char *string)
{
ULONG length, slen;
BOOL odd;
int success;

slen = strlen(string);
odd = (slen & 1);               /* pad byte flag */

length = (odd) ? slen+1 : slen;

/* initial set-up for Offset, Error, and ClipID */

ior->io_Offset = 0;
ior->io_Error  = 0;
ior->io_ClipID = 0;


/* Create the IFF header information */

WriteLong(ior, (long *) "FORM");     /* "FORM"             */
length+=12L;                         /* + "[size]FTXTCHRS" */
WriteLong(ior, &length);             /* total length       */
WriteLong(ior, (long *) "FTXT");     /* "FTXT"             */
WriteLong(ior, (long *) "CHRS");     /* "CHRS"             */
WriteLong(ior, &slen);               /* string length      */

/* Write string */
ior->io_Data    = (STRPTR)string;
ior->io_Length  = slen;
ior->io_Command = CMD_WRITE;
DoIO( (struct IORequest *) ior);

/* Pad if needed */
if (odd)
    {
    ior->io_Data   = (STRPTR)"";
    ior->io_Length = 1L;
    DoIO( (struct IORequest *) ior);
    }

/* Tell the clipboard we are done writing */

ior->io_Command=CMD_UPDATE;
DoIO( (struct IORequest *) ior);

/* Check if io_Error was set by any of the preceding IO requests */
success = ior->io_Error ? FALSE : TRUE;

return(success);
}

WriteLong(ior, ldata)
struct IOClipReq *ior;
long *ldata;
{

ior->io_Data    = (STRPTR)ldata;
ior->io_Length  = 4L;
ior->io_Command = CMD_WRITE;
DoIO( (struct IORequest *) ior);

if (ior->io_Actual == 4)
    {
    return( ior->io_Error ? FALSE : TRUE);
    }

return(FALSE);

}


int CBQueryFTXT(struct IOClipReq *ior)
{
ULONG cbuff[4];

/* initial set-up for Offset, Error, and ClipID */

ior->io_Offset = 0;
ior->io_Error  = 0;
ior->io_ClipID = 0;

/* Look for "FORM[size]FTXT" */

ior->io_Command = CMD_READ;
ior->io_Data    = (STRPTR)cbuff;
ior->io_Length  = 12;

DoIO( (struct IORequest *) ior);


/* Check to see if we have at least 12 bytes */

if (ior->io_Actual == 12L)
    {
    /* Check to see if it starts with "FORM" */
    if (cbuff[0] == ID_FORM)
        {
        /* Check to see if its "FTXT" */
        if (cbuff[2] == ID_FTXT)
            return(TRUE);
        }

    /* It's not "FORM[size]FTXT", so tell clipboard we are done */
    }

CBReadDone(ior);

return(FALSE);
}


struct cbbuf *CBReadCHRS(struct IOClipReq *ior)
{
ULONG chunk,size;
struct cbbuf *buf;
int looking;

/* Find next CHRS chunk */

looking = TRUE;
buf = NULL;

while (looking)
      {
      looking = FALSE;

      if (ReadLong(ior,&chunk))
          {
          /* Is CHRS chunk ? */
          if (chunk == ID_CHRS)
              {
              /* Get size of chunk, and copy data */
              if (ReadLong(ior,&size))
                  {
                  if (size)
                      buf=FillCBData(ior,size);
                  }
              }

            /* If not, skip to next chunk */
          else
              {
              if (ReadLong(ior,&size))
                  {
                   looking = TRUE;
                   if (size & 1)
                       size++;    /* if odd size, add pad byte */

                    ior->io_Offset += size;
                  }
              }
          }
      }

if (buf == NULL)
    CBReadDone(ior);        /* tell clipboard we are done */

return(buf);
}


ReadLong(ior, ldata)
struct IOClipReq *ior;
ULONG *ldata;
{
ior->io_Command = CMD_READ;
ior->io_Data    = (STRPTR)ldata;
ior->io_Length  = 4L;

DoIO( (struct IORequest *) ior);

if (ior->io_Actual == 4)
    {
    return( ior->io_Error ? FALSE : TRUE);
    }

return(FALSE);
}


struct cbbuf *FillCBData(struct IOClipReq *ior,ULONG size)
{
register UBYTE *to,*from;
register ULONG x,count;

ULONG length;
struct cbbuf *buf,*success;

success = NULL;

if (buf = AllocMem(sizeof(struct cbbuf),MEMF_PUBLIC))
    {

    length = size;
    if (size & 1)
        length++;            /* if odd size, read 1 more */

    if (buf->mem = AllocMem(length+1L,MEMF_PUBLIC))
        {
        buf->size = length+1L;

        ior->io_Command = CMD_READ;
        ior->io_Data    = (STRPTR)buf->mem;
        ior->io_Length  = length;

        to = buf->mem;
        count = 0L;

        if (!(DoIO( (struct IOStdReq *) ior)))
            {
            if (ior->io_Actual == length)
                {
                success = buf;      /* everything succeeded */

                /* strip NULL bytes */
                for (x=0, from=buf->mem ;x<size;x++)
                     {
                     if (*from)
                         {
                         *to = *from;
                         to++;
                         count++;
                         }

                     from++;
                     }
                *to=0x0;            /* Null terminate buffer */
                buf->count = count; /* cache count of chars in buf */
                }
            }

        if (!(success))
            FreeMem(buf->mem,buf->size);
        }
    if (!(success))
        FreeMem(buf,sizeof(struct cbbuf));
    }

return(success);
}

void CBReadDone(struct IOClipReq *ior)
{
char buffer[256];

ior->io_Command = CMD_READ;
ior->io_Data    = (STRPTR)buffer;
ior->io_Length  = 254;


/* falls through immediately if io_Actual == 0 */

while (ior->io_Actual)
      {
      if (DoIO( (struct IORequest *) ior))
          break;
      }
}


void CBFreeBuf(struct cbbuf *buf)
{
FreeMem(buf->mem, buf->size);
FreeMem(buf, sizeof(struct cbbuf));
}


