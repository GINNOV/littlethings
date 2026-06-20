/*-------------------------------------------------------------------*/
/* Copyright (c) 1993 by SAS Institute Inc., Cary NC                 */
/* All Rights Reserved                                               */
/*                                                                   */
/* SUPPORT:    walker - Doug Walker                                  */
/*-------------------------------------------------------------------*/

#include <exec/ports.h>
#include <devices/timer.h>
#include <dos/dosextens.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>

#include "sprofpriv.h"

struct TimerPacket 
{
   struct timerequest tm_req;
   struct DosPacket   tm_pkt;
};

static struct TimerPacket *timerpkt;
static struct MsgPort *timerport;
static int ioout, deviceopen;

void GetTimerPkt(long repost, int wait)
{
   if(timerpkt != NULL && ioout)
   {
      if(wait || CheckIO((struct IORequest *)&timerpkt->tm_req))
      {
         /* If the IO request is already complete, the AbortIO */
         /* won't do anything, and the WaitIO will simply      */
         /* dequeue the request and return.                    */
         AbortIO((struct IORequest *)&timerpkt->tm_req);
         WaitIO((struct IORequest *)&timerpkt->tm_req);
         ioout = 0;
      }
   }
   if(repost) PostTimerReq(repost);
}

void _STDCloseTimer(void)
{
   if(ioout)
   {
      GetTimerPkt(0,1);
      ioout = 0;
   }
   if(timerpkt)
   {
      if(deviceopen)
      {
         CloseDevice((struct IORequest *)&(timerpkt->tm_req));
         deviceopen = 0;
      }
      DeleteExtIO((struct IORequest *)timerpkt);
      timerpkt = NULL;
   }
   if(timerport)
   {
      DeletePort(timerport);
      timerport = NULL;
   }
}

long OpenTimer(void)
{
   int error;

   if(timerport || timerpkt) return(0);

   if(!(timerport = CreatePort(NULL, NULL)))
      return(0);

   if ((timerpkt = (struct TimerPacket *)
      CreateExtIO(timerport, sizeof(struct TimerPacket)))== NULL)
   {
      return(0);
   }

   timerpkt->tm_req.tr_node.io_Message.mn_Node.ln_Name = 
      (char *)&(timerpkt->tm_pkt);
   timerpkt->tm_pkt.dp_Link = &(timerpkt->tm_req.tr_node.io_Message);
   timerpkt->tm_pkt.dp_Port = timerport;

   error = OpenDevice(TIMERNAME, UNIT_MICROHZ,
        	       (struct IORequest *)&(timerpkt->tm_req), 0);

   if(error)
   {
      _STDCloseTimer();
      return(0);
   }
   deviceopen = 1;

   return(1<<timerport->mp_SigBit);
}

void PostTimerReq(long time)  // time is in thousandths of a second
{
   if(time == 0) return;

   if (timerpkt != NULL && !ioout)
   {
      timerpkt->tm_req.tr_node.io_Command = TR_ADDREQUEST;
      timerpkt->tm_req.tr_time.tv_secs = time/1000;
      timerpkt->tm_req.tr_time.tv_micro = (time%1000)*1000;
      timerpkt->tm_pkt.dp_Type = ACTION_TIMER;

      SendIO((struct IORequest *)&timerpkt->tm_req);
      ioout = 1;
   }
}

