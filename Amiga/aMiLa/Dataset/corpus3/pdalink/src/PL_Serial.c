/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Establishes a serial or USB connection to the PDA.
 *
 * @author Richard "Shred" Körber
 * @author Chris Hodges <chrisly@platon42.de>
 */ 
 
#include "pdalink_glob.h"

#include <devices/serial.h>
#include <devices/timer.h>



/*------------------------------------------------------**
** Name:        OpenPalmSerial                 protected
**
** Funktion:    Open a serial connection
**
** Parameter:   socket    Socket
**              device    Devicename
**              unit      Deviceunit
**              baud      Baudrate
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 13:40:02
*/
int OpenPalmSerial
(
  struct PL_Socket *sock,
  STRPTR device,
  ULONG  unit,
  ULONG  baud
)
{
  struct PL_Serial *ser;
  LONG err;

  err = PLERR_NOMEM;
  ser = (struct PL_Serial *)AllocVec(sizeof(struct PL_Serial),MEMF_PUBLIC|MEMF_CLEAR);
  if(ser)
  {
    if(ser->timerport = CreateMsgPort())          // Create timer message port
    {
      if(ser->timerio = (struct timerequest *)CreateIORequest(ser->timerport,sizeof(struct timerequest)))
      {
        err = PLERR_NORESOURCE;
        if(!OpenDevice("timer.device",UNIT_VBLANK,(struct IORequest *)ser->timerio,0L))
        {
          ser->timerbase = ser->timerio->tr_node.io_Device;
          err = PLERR_NOMEM;
          if(ser->serport = CreateMsgPort())      // create serial message port
          {
            if(ser->serio = (struct IOExtSer *)CreateIORequest(ser->serport,sizeof(struct IOExtSer)))
            {
              err = PLERR_NORESOURCE;
              ser->serio->io_SerFlags |= SERF_7WIRE;
//              ser->serio->io_SerFlags &= ~SERF_7WIRE;
              if(!OpenDevice(device,unit,(struct IORequest *)ser->serio,0L))
              {
                /* USB detection! */
                if(strstr(device, "usbpalm.device"))
                {
                    ser->isUSB = TRUE;
                }
                ser->serio->IOSer.io_Command = SDCMD_SETPARAMS;
                ser->serio->io_Baud          = baud;
                ser->serio->io_StopBits      = 1;
                ser->serio->io_ReadLen       = 8;
                ser->serio->io_WriteLen      = 8;
                ser->serio->io_SerFlags     |= SERF_RAD_BOOGIE|SERF_XDISABLED|SERF_7WIRE;
                ser->serio->io_ExtFlags      = 0;
                err = PLERR_SERIAL;
                if(  (!DoIO((struct IORequest *)ser->serio))
                   ||(ser->serio->IOSer.io_Error == SerErr_NoDSR))
                {
                  sock->serial = ser;
                  sock->lastError = PLERR_OKAY;
                  ser->currBaud = baud;
                  return(TRUE);
                }
                CloseDevice((struct IORequest *)ser->serio);
              }
              DeleteIORequest(ser->serio);
            }
            DeleteMsgPort(ser->serport);
          }
        }
        DeleteIORequest(ser->timerio);
      }
      DeleteMsgPort(ser->timerport);
    }
    FreeVec(ser);
  }
  sock->lastError = err;
  return(FALSE);
}
//<

/*------------------------------------------------------**
** Name:        ClosePalmSerial                protected
**
** Funktion:    Schließt die serielle Verbindung
**
** Parameter:   sock      Socket
//>
** Bemerkungen: Wird nur aufgerufen, wenn OpenPalmSerial()
**              _nicht_ fehlgeschlagen ist.
**
** Revision:    31. Mai 1998, 14:05:05
*/
void ClosePalmSerial
(
  struct PL_Socket *sock
)
{
  struct PL_Serial *ser = sock->serial;
  CloseDevice((struct IORequest *)ser->serio);
  DeleteIORequest(ser->serio);
  DeleteMsgPort(ser->serport);
  DeleteIORequest(ser->timerio);
  DeleteMsgPort(ser->timerport);
  FreeVec(ser);
}
//<

/*------------------------------------------------------**
** Name:        PL_RawSetRate                     public
**
** Funktion:    Stellt die Baudrate ein
**
** Parameter:   socket    Socket
**              baud      Baudrate
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     5. Juni 1998, 00:15:11
*/
__saveds __asm int PL_RawSetRate
(
  register __a0 APTR socket,
  register __d0 ULONG baud
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_Serial *ser = sock->serial;
  KPRINTF(10, ("RawSetRate\n"));
  sock->lastError = PLERR_OKAY;
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }

#ifdef SERDEBUG
    Printf("SER: Change baud to %ld\n",baud);
#endif

  if(ser->currBaud == baud) return(TRUE);         // has already been set
  ser->serio->IOSer.io_Command = SDCMD_SETPARAMS;
  ser->serio->io_Baud          = baud;
  if(  (!DoIO((struct IORequest *)ser->serio))
     ||(ser->serio->IOSer.io_Error == SerErr_NoDSR))
  {
    ser->currBaud = baud;
    Delay(10);                                    // take some time to settle
    return(TRUE);
  }

#ifdef SERDEBUG
  Printf("PL_RawSetRate Error %ld\n",ser->serio->IOSer.io_Error);
#endif
  sock->lastError = PLERR_SERIAL;
  return(FALSE);
}
//<

/*------------------------------------------------------**
** Name:        PL_RawRead                        public
**
** Funktion:    Liest Rohdaten vom Palm, wartet bis
**              genügend Daten vorhanden sind, oder bis
**              Timeout.
**
** Parameter:   socket    Socket
**              buffer    Datenpuffer
**              length    Länge des Puffers
** Ergebnis:    Gelesene Länge oder 0: Fehler
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 16:28:12
*/
__saveds __asm LONG PL_RawRead
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_Serial *ser  = sock->serial;
  ULONG waitmask =   (1L<<ser->serport->mp_SigBit)
                   | (sock->abortmask);
  ULONG signals;

#ifdef SERDEBUG
  UWORD i;
#endif
  KPRINTF(10, ("RawRead\n"));

  sock->lastError = PLERR_OKAY;

  ser->serio->IOSer.io_Command = CMD_READ;
  ser->serio->IOSer.io_Length  = length;
  ser->serio->IOSer.io_Data    = buffer;

  ser->timerio->tr_node.io_Command = TR_ADDREQUEST;
  ser->timerio->tr_time.tv_secs    = sock->timeout;
  ser->timerio->tr_time.tv_micro   = 0;

  if(sock->timeout)
  {
    SendIO((struct IORequest *)ser->timerio);     // start timer
    waitmask |= (1L<<ser->timerport->mp_SigBit);
  }
  SendIO((struct IORequest *)ser->serio);         // send command

  for(;;)
  {
    signals = Wait(waitmask);
    if(signals & sock->abortmask)
    {
      sock->lastError = PLERR_ABORTED;
      AbortIO((struct IORequest *)ser->serio);    // Abort serial command
      WaitIO((struct IORequest *)ser->serio);     // wait until abortion is acknowledged
      if(sock->timeout)
      {
        AbortIO((struct IORequest *)ser->timerio);  // stop timer
        WaitIO((struct IORequest *)ser->timerio);   // wait until timer is stopped
      }
      return 0;
    }

    if(CheckIO((struct IORequest *)ser->serio))   // request done?
    {
      WaitIO((struct IORequest *)ser->serio);     // Wait for request to arrive
      if(sock->timeout)
      {
        AbortIO((struct IORequest *)ser->timerio);  // abort timer
        WaitIO((struct IORequest *)ser->timerio);   // wait until timer is aborted
      }
#ifdef SERDEBUG
  for(i=0; i<length; i++)
    Printf("A<-P %02lx (%ld/%ld)\n",((UBYTE *)buffer)[i], i, length);
#endif
      if(ser->serio->IOSer.io_Error)              // Error?
      {
        if(ser->serio->IOSer.io_Error != SerErr_NoDSR)
        {
#ifdef SERDEBUG
  Printf("PL_RawRead Error %ld\n",ser->serio->IOSer.io_Error);
#endif
          sock->lastError = PLERR_SERIAL;
          return 0;                               // Nothing was read
        }
      }
      break;                                      // Leave loop
    }

    if(sock->timeout && CheckIO((struct IORequest *)ser->timerio)) // Timeout?
    {
      WaitIO((struct IORequest *)ser->timerio);   // wait until timer returns
      AbortIO((struct IORequest *)ser->serio);    // abort serial request
      WaitIO((struct IORequest *)ser->serio);     // wait until request is aborted
      sock->lastError = PLERR_TIMEOUT;            // Timeout
      return 0;                                   // failure (Timeout)
    }
  }

  return length;                                  // everything was read
}
//<

/*------------------------------------------------------**
** Name:        PL_RawWrite                       public
**
** Funktion:    Sendet Rohdaten zum Palm
**
** Parameter:   socket    Socket
**              buffer    Datenpuffer
**              length    Länge des Puffers
** Ergebnis:    Geschriebene Länge oder 0: Fehler
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 16:35:59
*/
__saveds __asm LONG PL_RawWrite
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_Serial *ser  = sock->serial;
  ULONG waitmask =   (1L<<ser->serport->mp_SigBit)
                   | (sock->abortmask);
  ULONG signals;

#ifdef SERDEBUG
  UWORD i;
#endif
  KPRINTF(10, ("RawWrite\n"));

  sock->lastError = PLERR_OKAY;

  ser->serio->IOSer.io_Command = CMD_WRITE;
  ser->serio->IOSer.io_Length  = length;
  ser->serio->IOSer.io_Data    = buffer;

  ser->timerio->tr_node.io_Command = TR_ADDREQUEST;
  ser->timerio->tr_time.tv_secs    = sock->timeout;
  ser->timerio->tr_time.tv_micro   = 0;

  if(sock->timeout) {
    SendIO((struct IORequest *)ser->timerio);       // Start timer
    waitmask |= (1L<<ser->timerport->mp_SigBit);
  }
  SendIO((struct IORequest *)ser->serio);         // Start request

  for(;;)
  {
    signals = Wait(waitmask);

    if(signals & sock->abortmask)
    {
      sock->lastError = PLERR_ABORTED;
      AbortIO((struct IORequest *)ser->serio);    // stop serial request
      WaitIO((struct IORequest *)ser->serio);     // wait until stopped
      if(sock->timeout) {
        AbortIO((struct IORequest *)ser->timerio);  // stop timer
        WaitIO((struct IORequest *)ser->timerio);   // wait until timer is stopped
      }
      return 0;
    }

    if(CheckIO((struct IORequest *)ser->serio))   // request finished?
    {
      WaitIO((struct IORequest *)ser->serio);     // wait for the request to return
      if(sock->timeout) {
        AbortIO((struct IORequest *)ser->timerio);  // stop timer
        WaitIO((struct IORequest *)ser->timerio);   // wait until timer is stopped
      }
#ifdef SERDEBUG
  for(i=0; i<length; i++)
    Printf("A->P %02lx\n",((UBYTE *)buffer)[i]);
#endif
      if(ser->serio->IOSer.io_Error)              // Error?
      {
        if(ser->serio->IOSer.io_Error != SerErr_NoDSR)
        {
#ifdef SERDEBUG
  Printf("PL_RawWrite Error %ld\n",ser->serio->IOSer.io_Error);
#endif
          sock->lastError = PLERR_SERIAL;
          return 0;                               // Nothing was read
        }
      }
      break;                                      // break loop
    }

    if(sock->timeout && CheckIO((struct IORequest *)ser->timerio)) // Timeout?
    {
      WaitIO((struct IORequest *)ser->timerio);   // wait for the timer to return
      AbortIO((struct IORequest *)ser->serio);    // stop serial request
      WaitIO((struct IORequest *)ser->serio);     // wait for request to return
      sock->lastError = PLERR_TIMEOUT;            // timeout
      return 0;                                   // failure (Timeout)
    }
  }

  return length;                                  // Everything was read
}
//<

/*------------------------------------------------------**
** Name:        PL_RawFlush                       public
**
** Funktion:    Leert den Sende- und Empfangspuffer
**
** Parameter:   socket    Socket
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. September 1998, 11:20:26
*/
__saveds __asm int PL_RawFlush
(
  register __a0 APTR socket
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_Serial *ser  = sock->serial;
  KPRINTF(10, ("RawFlush\n"));

  sock->lastError = PLERR_OKAY;

  ser->serio->IOSer.io_Command = CMD_FLUSH;
  DoIO((struct IORequest *)ser->serio);           // Put command

  if(ser->serio->IOSer.io_Error)              // Error?
  {
    if(ser->serio->IOSer.io_Error != SerErr_NoDSR)
    {
#ifdef SERDEBUG
  Printf("PL_RawFlush Error %ld\n",ser->serio->IOSer.io_Error);
#endif
      sock->lastError = PLERR_SERIAL;
      return FALSE;
    }
  }

  return TRUE;
}
//<


/********************************************************************/
