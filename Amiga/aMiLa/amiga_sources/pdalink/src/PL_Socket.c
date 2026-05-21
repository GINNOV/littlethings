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
 * Establishes a socket between client and PDA.
 *
 * @author Richard "Shred" Körber
 */ 

#include "strings.h"
#include "pdalink_glob.h"


#define DEFAULT_TIMEOUT       (10)        /* (sec) delay until serial timeouts */
#define DEFAULT_MAXRATE       (57600)     /* max baud rate the device supports */
#define ENVBUFFER_LENGTH      (2048)      /* size of env var buffer */

static const STRPTR plerrtable[] =
{
  "not enough memory",
  "a resource is allocated",
  "serial device error",
  "connection timeout",
  "data checksum error",
  "remote: not enough memory",
  "unexpected packet",
  "connection is not compatible",
  "serial cannot generate baud rate",
  "dos error",
  "PalmOS V2+ is required",
  "data buffer too large",
  "aborted"
};

static const STRPTR dlperrtable[] =
{
  "no error",
  "DLP: general system error",
  "DLP: out of memory",
  "DLP: invalid parameter",
  "record not found",
  "record not opened",
  "record already opened",
  "too many records opened",
  "record does already exist",
  "cannot open record",
  "record is deleted",
  "record is busy",
  "operation not supported",
  "record is read only",
  "not enough space for record",
  "limit exceeded",
  "hotsync cancelled",
  "DLP: bad arguments",
  "DLP: argument is missing",
  "DLP: bad argument size"
};


/*------------------------------------------------------**
** Name:        GetEnvVar                        private
**
** Funktion:    Get an env variable, as string
**
** Parameter:   name      Var name
** Ergebnis:    Variable Content (to be freed with FreeVec)
**              or NULL if not found (or no memory)
//>
** Bemerkungen:
**
** Revision:    26. Oktober 1999, 01:14:08
*/
static STRPTR GetEnvVar(STRPTR name)
{
  STRPTR space;
  LONG result;

  space = AllocVec(ENVBUFFER_LENGTH,MEMF_PUBLIC);
  if(space)
  {
    result = GetVar(name,space,ENVBUFFER_LENGTH,0);
    if(result<0) {
      FreeVec(space);
      return NULL;
    }
  }
  return(space);
}
//<
/*------------------------------------------------------**
** Name:        GetEnvVarLong                    private
**
** Funktion:    Get an env variable, as LONG
**
** Parameter:   name      Variable Name
**              var       LONG * to put the result to
** Ergebnis:    Success (0:failed, not 0:success)
//>
** Bemerkungen:
**
** Revision:    26. Oktober 1999, 01:14:08
*/
static int GetEnvVarLong(STRPTR name, LONG *var)
{
  STRPTR space;

  space = GetEnvVar(name);
  if(space)
  {
    if(-1 == StrToLong(space,var)) {
      return 0;
    }

    return -1;
  }
  else                                          // Failed
  {
    return 0;
  }
}
//<




/*------------------------------------------------------**
** Name:        PL_OpenSocket                     public
**
** Funktion:    Erzeugt einen neuen Socket
**
** Parameter:   taglist   Tagliste mit Parametern
** Ergebnis:    Socket
**
** Tags:        PLTAG_ErrorPtr
**              PLTAG_SerialDevice
**              PLTAG_SerialUnit
**              PLTAG_SerialMaxRate
**              PLTAG_SerialTimeout
**              PLTAG_AbortMask
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 13:40:02
*/
__saveds __asm APTR PL_OpenSocket
(
  register __a0 struct TagItem *taglist
)
{
  /* Very prominent baud rates, and candidates to be provided to the Palm */
  static ULONG rates[] = {115200,57600,38400,28800,19200,14400,9600,4800,2400,1200,0};

  struct PL_Socket *sock;         // Socket that has been created
  LONG   *error;                  // LONG * to place error codes into
  STRPTR device;                  // Device Name
  ULONG  unit;                    // Device Unit
  ULONG  maxrate;                 // Max Rate
  ULONG  *tstbaud;
  STRPTR defDevice;
  LONG   defUnit = 0;
  LONG   defMaxrate = DEFAULT_MAXRATE;
  KPRINTF(10, ("OpenSocket\n"));

  /* Read env variables, if available */
  defDevice = GetEnvVar("PDALINK_DEVICE");
  if(!defDevice) defDevice = "serial.device";
  if(!GetEnvVarLong("PDALINK_UNIT",&defUnit)) defUnit = 0;
  if(!GetEnvVarLong("PDALINK_RATE",&defMaxrate)) defMaxrate = DEFAULT_MAXRATE;


  error = (LONG *)GetTagData(PLTAG_ErrorPtr,NULL,taglist);

  if(error) *error = PLERR_OKAY;

  sock = (struct PL_Socket *)AllocVec(sizeof(struct PL_Socket),MEMF_PUBLIC|MEMF_CLEAR);
  if(sock)
  {
    sock->dlpbuffer = AllocMem(65536,MEMF_PUBLIC);
    if(sock->dlpbuffer)
    {
      sock->timeout   = GetTagData(PLTAG_SerialTimeout,DEFAULT_TIMEOUT,taglist);
      maxrate         = GetTagData(PLTAG_SerialMaxRate,defMaxrate,taglist);
      sock->abortmask = GetTagData(PLTAG_AbortMask,0L,taglist);
      sock->baudRate  = 9600;
      sock->initiator = FALSE;
      sock->transactionID = 0xFF;

      device = (STRPTR)GetTagData(PLTAG_SerialDevice,(ULONG)defDevice,taglist);
      unit   =         GetTagData(PLTAG_SerialUnit  ,defUnit         ,taglist);

      if(OpenPalmSerial(sock,device,unit,9600))           // This is the default baud rate
      {
        if(!sock->serial->isUSB)
        {
          /* Find out the maximum baud rate */
          for(tstbaud = rates; *tstbaud; tstbaud++)
          {
            if(*tstbaud > maxrate) continue;                // Higher than device's max rate?
            if(!PL_RawSetRate(sock,*tstbaud)) continue;     // Check if the device is able to generate that rate
            break;
          }
          if(*tstbaud)                                      // Found a rate
          {
            sock->maxRate = *tstbaud;
#ifdef APIDEBUG
            Printf("API OpenSocket: Device max rate is %ld\n",sock->maxRate);
#endif
            if(PL_RawSetRate(sock,9600))                    // For this time, go back to default rate to
            {                                               // establish the connection
              return(sock);                 /* <------- SUCCESS -------------- */
            }
          }
        } else {
          return(sock);
        }
        sock->lastError = PLERR_BADBAUD;
        ClosePalmSerial(sock);
      }
      if(error) *error = sock->lastError;
      FreeMem(sock->dlpbuffer,65536);
    }
    FreeVec(sock);
  }
  if(error && (*error==PLERR_OKAY)) *error = PLERR_NOMEM;

  return(NULL);                       /* <------- FAILURE -------------- */
}
//<

/*------------------------------------------------------**
** Name:        PL_Accept                         public
**
** Funktion:    Akzeptiere eine Verbindung vom Palm
**
** Parameter:   socket    Socket zum Palm
**              timeout   Timeout
** Ergebnis:    success
**
//>
** Bemerkungen:
**
** Revision:     7. Juni 1998, 22:45:35
*/
__saveds __asm int PL_Accept
(
  register __a0 APTR socket,
  register __d0 ULONG timeout
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_CMP cmp;
  ULONG trycnt;
  ULONG tstbaud;
  KPRINTF(10, ("Accept\n"));

  sock->lastError = PLERR_OKAY;             // No errors so far
  if(sock->serial->isUSB)
  {
      PL_NetSyncServerRitual(sock);
      return(TRUE);
  }
  trycnt = (timeout / DEFAULT_TIMEOUT)+1;   // How many retries to fill out the timeout?

  /* Wait for CMP packet */
#ifdef APIDEBUG
  Printf("API Accept: Waiting for CMP Packet\n");
#endif
  for(;;)
  {
    if(PL_CMPRead(socket,&cmp)) break;      // Success!
    if(sock->lastError == PLERR_TIMEOUT)    // Timeout?
    {
      trycnt--;
      if(trycnt>0) continue;                // give it another try...
    }
    return(FALSE);                          // Error occured
  }

  sock->version = cmp.version;              // Remember the version

  sock->lastError = PLERR_OKAY;             // Clear timeouts that may have occured

  /* Check version */
  if((cmp.version & 0xFF00) != 0x0100)      // V1.0 oder V2.0 ?
  {
    PL_CMPAbort(socket,0x80);               // Comm not compatible
    sock->lastError = PLERR_NOTCOMPATIBLE;
    return(FALSE);
  }

  tstbaud = min(cmp.baudrate,sock->maxRate);  // The smaller baud rate is the right one

#ifdef APIDEBUG
  Printf("API Accept: Sending Init (Rate %ld)\n",tstbaud);
#endif
  if(!PL_CMPInit(socket,tstbaud))       // arrange this baud rate with the Palm device
  {
    return(FALSE);                      // Failed? Then we have no chance to connect!
  }                                     // (Should not happen, 9600 should always be available)

  if(!PL_RawFlush(socket))              // Flushing meadow... :-)
  {
    return(FALSE);
  }

  Delay(30);                            // Amiga devices seem to need some time to
                                        // settle to the new rate. Wait a short moment,
                                        // so we can receive the next packet with the
                                        // proper baud rate. The value is experimental,
                                        // but showed best results so far...

#ifdef APIDEBUG
  Printf("API Accept: Changing to new baud rate %ld\n",tstbaud);
#endif
  if(!PL_RawSetRate(socket,tstbaud))    // now we change to the new baud rate ourselves
  {
    return(FALSE);                      // Failed? No chance to establish a contact. :-((
  }

  if(!PL_RawFlush(socket))              // Flushing again...
  {
    return(FALSE);
  }

  sock->baudRate = tstbaud;                 // put baud rate into socket
  sock->initiator = FALSE;                  // we didn't initiate this connection

#ifdef APIDEBUG
  Printf("API Accept: *done*\n");
#endif

  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        PL_Connect                        public
**
** Funktion:    Erzeuge eine Verbindung zum Palm
**
** Parameter:   socket    Socket zum Palm
**              timeout   Timeout
** Ergebnis:    success
**
//>
** Bemerkungen:
**
** Revision:     8. Juni 1998, 00:10:28
*/
__saveds __asm int PL_Connect
(
  register __a0 APTR socket
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_CMP cmp;
  KPRINTF(10, ("Connect\n"));

  sock->lastError = PLERR_OKAY;             // No errors so far
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }
  /* Wake up remote */
  if(!PL_CMPWakeUp(socket,sock->maxRate))   // Try a wakeup
  {
    return(FALSE);                          // didn't succeed, remote still sleeping :)
  }

  /* Accept suggested baud rate */
  if(!PL_CMPRead(socket,&cmp))              // Read answer
  {
    return(FALSE);                          // failed...
  }
  sock->version = cmp.version;              // Remember version
  switch(cmp.type)
  {
    case 2:                                 // Init type?
      if(cmp.flags&PLCMPF_CHANGEBAUD)       // Baud rate to be changed?
      {
        if(!PL_RawSetRate(socket,cmp.baudrate))
        {
          sock->lastError = PLERR_BADBAUD;  // Doh! Amiga does not support the suggested
          return(FALSE);                    // baud rate. No connection possible! :-(
        }
        sock->baudRate = cmp.baudrate;
        Delay(50);                          // Palm needs a little time to settle
                                            // to the new baud rate
      }
      break;

    case 3:                                 // Abort ?
      sock->lastError = PLERR_NOTCOMPATIBLE;
      return(FALSE);
      break;

    default:                                // Something else?
#ifdef DEBUGOUT
  Printf("DEBUG: File %s Line %ld: Bad Packet\n",__FILE__,__LINE__);
#endif
      sock->lastError = PLERR_BADPACKET;
      return(FALSE);
  }

  sock->initiator = TRUE;                   // This time we initiated the connection
  return(TRUE);                             // Okay, we are done now...
}
//<

/*------------------------------------------------------**
** Name:        PL_LastError                      public
**
** Funktion:    Liefert den letzten Fehlercode zurück
**
** Parameter:   socket    Socket zum Schließen
** Ergebnis:    error     Fehlercode
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 14:09:56
*/
__saveds __asm LONG PL_LastError
(
  register __a0 APTR socket
)
{
  KPRINTF(10, ("LastError\n"));
  return(((struct PL_Socket *)socket)->lastError);
}
//<

/*------------------------------------------------------**
** Name:        PL_GetBaudRate                    public
**
** Funktion:    Liefert die Baudrate zum Palm
**
** Parameter:   socket    Socket zum Schließen
** Ergebnis:    baud      Baudrate zum Palm
//>
** Bemerkungen:
**
** Revision:     7. Januar 2000, 00:17:17
*/
__saveds __asm ULONG PL_GetBaudRate
(
  register __a0 APTR socket
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("GetBaudRate\n"));
  return sock->baudRate;
}
//<

/*------------------------------------------------------**
** Name:        PL_Read                           public
**
** Funktion:    Liest Daten vom Palm
**
** Parameter:   socket    Socket zum Palm
**              buffer    Datenpuffer
**              size      Größe des Puffers
** Ergebnis:    length    Tatsächliche Paketgröße
**
//>
** Bemerkungen:
**
** Revision:     8. Juni 1998, 00:10:28
*/
__saveds __asm LONG PL_Read
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG size
)
{
  KPRINTF(10, ("Read\n"));
  if(((struct PL_Socket *) socket)->serial->isUSB)
  {
    return PL_NetSyncRead(socket, buffer, size);
  } else {
    return PL_PADPRead(socket,buffer,size);
  }
}
//<

/*------------------------------------------------------**
** Name:        PL_Write                          public
**
** Funktion:    Schreibt Daten zum Palm
**
** Parameter:   socket    Socket zum Palm
**              buffer    Datenpuffer
**              size      Größe des Puffers
** Ergebnis:    length    Tatsächliche Paketgröße
**
//>
** Bemerkungen:
**
** Revision:     8. Juni 1998, 00:10:28
*/
__saveds __asm LONG PL_Write
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG size
)
{
  KPRINTF(10, ("Write\n"));
  if(((struct PL_Socket *) socket)->serial->isUSB)
  {
    return PL_NetSyncWrite(socket, buffer, size, PLPADP_DATA);
  } else {
    return PL_PADPWrite(socket,buffer,size,PLPADP_DATA);
  }
}
//<

/*------------------------------------------------------**
** Name:        PL_Tickle                         public
**
** Funktion:    Verhindert einen Timeout
**
** Parameter:   socket    Socket zum Palm
** Ergebnis:    success
**
//>
** Bemerkungen:
**
** Revision:     8. Juni 1998, 00:26:57
*/
__saveds __asm LONG PL_Tickle
(
  register __a0 APTR socket
)
{
  UWORD dummy;
  KPRINTF(10, ("Tickle\n"));
  if(((struct PL_Socket *) socket)->serial->isUSB)
  {
    return(0);
  } else {
    return PL_PADPWrite(socket,&dummy,0,PLPADP_TICKLE);
  }
}
//<

/*------------------------------------------------------**
** Name:        PL_CloseSocket                    public
**
** Funktion:    Schließt einen Socket
**
** Parameter:   socket    Socket zum Schließen
** Ergebnis:
//>
** Bemerkungen: Wird nur aufgerufen, wenn PL_OpenSocket()
**              _nicht_ fehlschlug.
**
** Revision:    31. Mai 1998, 14:07:41
*/
__saveds __asm void PL_CloseSocket
(
  register __a0 APTR socket
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("CloseSocket\n"));
  FreeMem(sock->dlpbuffer,65536);
  ClosePalmSerial(sock);                // Close connection
  FreeVec(sock);                        // Free socket
}
//<

/*------------------------------------------------------**
** Name:        PL_Explain                        public
**
** Funktion:    Erklärt eine Fehlermeldung
**
** Parameter:   error     Fehlercode
**              buffer    Puffer für String
**              length    Länge des Puffers (inkl. 0-Term)
** Ergebnis:
//>
** Bemerkungen:
**
** Revision:    10. September 1998, 01:24:21
*/
__saveds __asm void PL_Explain
(
  register __a0 LONG error,
  register __a1 STRPTR buffer,
  register __d0 ULONG length
)
{
  LONG negerr;
  KPRINTF(10, ("Explain\n"));

  if(error < 0)
  {
    negerr = (-error)-1;
    if(negerr < sizeof(plerrtable))
    {
      stccpy(buffer,plerrtable[negerr],length);
      return;
    }
  }

  if(error < sizeof(dlperrtable))
  {
    stccpy(buffer,dlperrtable[error],length);
    return;
  }

  Fault(error,"",buffer,length);
}
//<



/********************************************************************/
