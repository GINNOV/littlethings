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
 * The Desktop Link Protocol (DLP) is handled here.
 *
 * @author Richard "Shred" Körber
 */

#include <string.h>
#include "pdalink_glob.h"


/*------------------------------------------------------**
** Name:        PL_DLPInit                        public
**
** Funktion:    Startet eine DLP-Übertragung
**
** Parameter:   socket    Socket für die Übertragung
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm void PL_DLPInit
(
  register __a0 APTR socket
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPInit\n"));
  sock->dlpoffset = 0;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPWriteByte                   public
**
** Funktion:    Fügt ein Byte zum Paket hinzu
**
** Parameter:   socket    Socket für die Übertragung
**              byte      Hinzuzufügendes Byte
** Ergebnis:    length    Aktuelle DLP-Paketlänge
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPWriteByte
(
  register __a0 APTR socket,
  register __d0 BYTE bdata
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPWriteByte\n"));

  *(sock->dlpbuffer+(sock->dlpoffset++)+6) = bdata;
  return sock->dlpoffset;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPWriteWord                   public
**
** Funktion:    Fügt ein Word zum Paket hinzu
**
** Parameter:   socket    Socket für die Übertragung
**              word      Hinzuzufügendes Word
** Ergebnis:    length    Aktuelle DLP-Paketlänge
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPWriteWord
(
  register __a0 APTR socket,
  register __d0 WORD wdata
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPWriteWord\n"));

  *((WORD *)(sock->dlpbuffer+sock->dlpoffset+6)) = wdata;
  sock->dlpoffset += 2;
  return sock->dlpoffset;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPWriteLong                   public
**
** Funktion:    Fügt ein Long zum Paket hinzu
**
** Parameter:   socket    Socket für die Übertragung
**              long      Hinzuzufügendes Long
** Ergebnis:    length    Aktuelle DLP-Paketlänge
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPWriteLong
(
  register __a0 APTR socket,
  register __d0 LONG ldata
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPWriteLong\n"));
  *((LONG *)(sock->dlpbuffer+sock->dlpoffset+6)) = ldata;
  sock->dlpoffset += 4;
  return sock->dlpoffset;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPWrite                       public
**
** Funktion:    Fügt Daten zum Paket hinzu
**
** Parameter:   socket    Socket für die Übertragung
**              packet    Paket
**              length    Länge des Pakets
** Ergebnis:    length    Aktuelle DLP-Paketlänge
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPWrite
(
  register __a0 APTR socket,
  register __a1 APTR packet,
  register __d0 LONG length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPWrite\n"));

  CopyMem(packet,sock->dlpbuffer+sock->dlpoffset+6,length);
  sock->dlpoffset += length;
  return sock->dlpoffset;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPTstWrite                    public
**
** Funktion:    Prüft, ob genug Platz für das Datum
**
** Parameter:   socket    Socket für die Übertragung
**              length    Länge des Pakets
** Ergebnis:    success   TRUE: paßt
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPTstWrite
(
  register __a0 APTR socket,
  register __d0 LONG length
)
{
  KPRINTF(10, ("DLPTstWrite\n"));
  return(((struct PL_Socket *)socket)->dlpoffset+6+length <= 0xFFFF);
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPSend                        public
**
** Funktion:    Sendet das DLP-Paket ab
**
** Parameter:   socket    Socket für die Übertragung
**              cmd       Kommando-Code
**              arg       Argument
** Ergebnis:    length    Länge des Antwortpakets
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:36:41
*/
__saveds __asm LONG PL_DLPSend
(
  register __a0 APTR socket,
  register __d0 UBYTE cmd,
  register __d1 UBYTE arg
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  UBYTE *buf = sock->dlpbuffer;
  LONG msglen = sock->dlpoffset;
  LONG pktlen;
  WORD errcode;
  KPRINTF(10, ("DLPSend\n"));

  sock->lastError = PLERR_OKAY;

  /* collect packet data */
  buf[0] = cmd;
  if(msglen!=0 && arg)
  {
    buf[1] = 1;
    buf[2] = arg|0x80;
    buf[3] = 0;
    buf[4] = msglen>>8;
    buf[5] = msglen&0xFF;
    pktlen = msglen+6;
  }
  else
  {
    buf[1] = 0;
    pktlen = 2;
  }

  /* send DLP packet */
  if(PL_Write(socket,buf,pktlen) != pktlen)
  {
    return -1;
  }

  /* Wait for reply */
  pktlen = PL_Read(socket,buf,65536);
  if(pktlen==-1) return -1;

  /* DLP error occured? */
  errcode = buf[2]<<8 | buf[3];
  if(errcode)
  {
    sock->lastError = errcode;
    return -1;
  }

  /* Got right packet? */
  if(buf[0] != (cmd|0x80))
  {
    sock->lastError = PLERR_BADPACKET;
    return -1;
  }

  /* Collect answer */
  sock->dlpoffset = 0;                          // Read from the beginning
  if(!buf[1])                                   // No answer expected
  {
    sock->readoffset = 0;
    return 0;
  }

  if((buf[4]&0xC0) == 0xC0)                     // Long
  {
    pktlen = ((((((buf[6]<<8) | buf[7])<<8) | buf[8])<<8) | buf[9]);
    sock->readoffset = 10;
  }
  else if((buf[4]&0xC0) == 0x80)                // Short
  {
    pktlen = (buf[6]<<8) | buf[7];
    sock->readoffset = 8;
  }
  else                                          // Tiny
  {
    pktlen = buf[5];
    sock->readoffset = 6;
  }

  return pktlen;
}
//<
/*------------------------------------------------------**
** Name:        PL_DLPRead                        public
**
** Funktion:    Liest Daten aus dem Paket
**
** Parameter:   socket    Socket für die Übertragung
**              buffer    Pufferspeicher (NULL:Skip)
**              length    Länge des Puffers
** Ergebnis:    momentan stets = length
//>
** Bemerkungen:
**
** Revision:    11. Juni 1998, 23:53:33
*/
__saveds __asm LONG PL_DLPRead
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("DLPRead\n"));

  if(buffer)
    CopyMem(sock->dlpbuffer+sock->readoffset+sock->dlpoffset , buffer, length);
  sock->dlpoffset += length;
  return length;
}
//<





/*------------------------------------------------------**
** Name:        DLP_OpenConduit                   public
**
** Funktion:    Startet die Verbindung
**
** Parameter:   socket    Socket für die Übertragung
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_OpenConduit
(
  register __a0 APTR socket
)
{
  KPRINTF(10, ("DLPOpenConduit\n"));
  PL_DLPInit(socket);
  return(PL_DLPSend(socket,0x2E,0x00) != -1);
}
//<
/*------------------------------------------------------**
** Name:        DLP_EndOfSync                     public
**
** Funktion:    Beendet die Verbindung
**
** Parameter:   socket    Socket für die Übertragung
**              status    Status-Code
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_EndOfSync
(
  register __a0 APTR socket,
  register __d0 UWORD status
)
{
  KPRINTF(10, ("DLPEndOfSync\n"));
  PL_DLPInit(socket);
  PL_DLPWriteWord(socket,(WORD)status);
  return(PL_DLPSend(socket,0x2F,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_SetSysTime                    public
**
** Funktion:    Setzt die Systemzeit des Palm
**
** Parameter:   socket    Socket für die Übertragung
**              time      Time-Struct
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_SetSysTime
(
  register __a0 APTR socket,
  register __a1 struct DLP_SysTime *time
)
{
  KPRINTF(10, ("DLPSetSysTime\n"));
  PL_DLPInit(socket);
  PL_DLPWrite(socket,time,sizeof(struct DLP_SysTime));
  return(PL_DLPSend(socket,0x14,0x20) != -1);
}
//<
/*------------------------------------------------------**
** Name:        DLP_GetSysTime                    public
**
** Funktion:    Liest die Systemzeit des Palm
**
** Parameter:   socket    Socket für die Übertragung
**              time      Time-Struct
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_GetSysTime
(
  register __a0 APTR socket,
  register __a1 struct DLP_SysTime *time
)
{
  KPRINTF(10, ("DLPGetSysTime\n"));
  PL_DLPInit(socket);
  if(PL_DLPSend(socket,0x13,0x20) == -1) return(FALSE);
  PL_DLPRead(socket,time,sizeof(struct DLP_SysTime));
  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_GetStorageInfo                public
**
** Funktion:    Liest Infos über den Palm-Speicher
**
** Parameter:   socket    Socket für die Übertragung
**              cardno    Karten-Nummer
**              info      Platz für Informationen darüber
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_GetStorageInfo
(
  register __a0 APTR socket,
  register __d0 UBYTE cardno,
  register __a1 struct DLP_StorageInfo *info
)
{
  struct DLP_SIResult
  {
    UBYTE number;
    UBYTE more;
    UBYTE pad;
    UBYTE count;
    UBYTE totalSize;
    UBYTE cardNo;
    UWORD cardVersion;
    struct DLP_SysTime date;
    ULONG ROMSize;
    ULONG RAMSize;
    ULONG RAMFree;
    UBYTE cardNameSize;
    UBYTE cardManufSize;
    UBYTE NameManufBuffer[256];
  }
  sres;
  KPRINTF(10, ("DLPGetStorageInfo\n"));

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)cardno);
  PL_DLPWriteByte(socket,0);

  if(PL_DLPSend(socket,0x15,0x20) == -1) return(FALSE);

  PL_DLPRead(socket,&sres,sizeof(struct DLP_SIResult));
  info->more        = (sres.count>1 || sres.more);
  info->cardNo      = sres.cardNo;
  info->cardVersion = sres.cardVersion;
  info->date        = sres.date;
  info->ROMSize     = sres.ROMSize;
  info->RAMSize     = sres.RAMSize;
  info->RAMFree     = sres.RAMFree;
  CopyMem(sres.NameManufBuffer, info->name, sres.cardNameSize);
  info->name[sres.cardNameSize] = '\0';
  CopyMem(sres.NameManufBuffer+sres.cardNameSize,info->manuf,sres.cardManufSize);
  info->manuf[sres.cardManufSize] = '\0';

  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_GetSysInfo                    public
**
** Funktion:    Liest Infos über das System
**
** Parameter:   socket    Socket für die Übertragung
**              info      Speicher für SysInfo
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_GetSysInfo
(
  register __a0 APTR socket,
  register __a1 struct DLP_SysInfo *info
)
{
  UBYTE len;
  KPRINTF(10, ("DLPGetSysInfo\n"));

  PL_DLPInit(socket);
  if(PL_DLPSend(socket,0x12,0x20) == -1) return(FALSE);

  PL_DLPRead(socket,&info->romVer,4);   // ULONG        (0)   romVer
  PL_DLPRead(socket,&info->locale,4);   // ULONG        (4)   locale
  PL_DLPRead(socket,NULL,1);            // UBYTE        (8)   pad
  PL_DLPRead(socket,&len,1);            // UBYTE        (9)   NameLen
  PL_DLPRead(socket,info->name,len);    // UBYTE[128]   (10)  Name
  info->name[len] = '\0';

  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_GetDBInfo                     public
**
** Funktion:    Liest Infos über die Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              cardno    Karten-Nummer
**              flags     Flags
**              start     Erste Eintrags-Nummer
**              info      Speicher für DBInfo
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_GetDBInfo
(
  register __a0 APTR socket,
  register __d0 UBYTE cardno,
  register __d1 UBYTE flags,
  register __d2 UWORD start,
  register __a1 struct DLP_DBInfo *info
)
{
  KPRINTF(10, ("DLPGetDBInfo\n"));
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)flags);
  PL_DLPWriteByte(socket,(BYTE)cardno);
  PL_DLPWriteWord(socket,(WORD)start);

  if(PL_DLPSend(socket,0x16,0x20) == -1) return(FALSE);

  PL_DLPRead(socket,NULL                ,2);
  PL_DLPRead(socket,&info->more         ,1);
  PL_DLPRead(socket,NULL                ,2);
  PL_DLPRead(socket,&info->excludes     ,1);
  PL_DLPRead(socket,&info->flags        ,2);
  PL_DLPRead(socket,&info->type         ,4);
  PL_DLPRead(socket,&info->creator      ,4);
  PL_DLPRead(socket,&info->version      ,2);
  PL_DLPRead(socket,&info->modnum       ,4);
  PL_DLPRead(socket,&info->createDate   ,sizeof(struct DLP_SysTime));
  PL_DLPRead(socket,&info->modifyDate   ,sizeof(struct DLP_SysTime));
  PL_DLPRead(socket,&info->backupDate   ,sizeof(struct DLP_SysTime));
  PL_DLPRead(socket,&info->index        ,2);
  PL_DLPRead(socket,&info->name         ,32);
  info->name[32] = '\0';

  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_OpenDB                        public
**
** Funktion:    Öffnet eine Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              cardno    Karten-Nummer
**              mode      Modus
**              name      Name
** Ergebnis:    handle    DB-Handle oder -1:Error
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm LONG DLP_OpenDB
(
  register __a0 APTR socket,
  register __d0 UBYTE cardno,
  register __d1 UBYTE mode,
  register __a1 STRPTR name
)
{
  UBYTE handle;
  KPRINTF(10, ("DLPOpenDB\n"));

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)cardno);
  PL_DLPWriteByte(socket,(BYTE)mode);
  PL_DLPWrite(socket,name,strlen(name)+1);

  if(PL_DLPSend(socket,0x17,0x20) == -1) return(-1);

  PL_DLPRead(socket,&handle,1);
  return(handle);
}
//<

/*------------------------------------------------------**
** Name:        DLP_DeleteDB                      public
**
** Funktion:    Löscht eine Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              cardno    Karten-Nummer
**              name      Name
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_DeleteDB
(
  register __a0 APTR socket,
  register __d0 UBYTE cardno,
  register __a1 STRPTR name
)
{
  KPRINTF(10, ("DLPDeleteDB\n"));
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)cardno);
  PL_DLPWriteByte(socket,0);
  PL_DLPWrite(socket,name,strlen(name)+1);
  return(PL_DLPSend(socket,0x1A,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_CreateDB                      public
**
** Funktion:    Erstellt eine Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              cardno    Karten-Nummer
**              creator   Erzeuger-ID
**              type      Typ-ID
**              flags     Flags
**              version   Versionsnr.
**              name      Name
** Ergebnis:    handle    DB-Handle oder -1:Error
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 00:28:28
*/
__saveds __asm LONG DLP_CreateDB
(
  register __a0 APTR socket,
  register __d0 UBYTE cardno,
  register __d1 ULONG creator,
  register __d2 ULONG type,
  register __d3 UWORD flags,
  register __d4 UWORD version,
  register __a1 STRPTR name
)
{
  UBYTE handle;
  KPRINTF(10, ("DLPCreateDB\n"));

  PL_DLPInit(socket);
  PL_DLPWriteLong(socket,(LONG)creator);
  PL_DLPWriteLong(socket,(LONG)type);
  PL_DLPWriteByte(socket,(BYTE)cardno);
  PL_DLPWriteByte(socket,0);
  PL_DLPWriteWord(socket,(WORD)flags);
  PL_DLPWriteWord(socket,(WORD)version);
  PL_DLPWrite(socket,name,strlen(name)+1);
  if(PL_DLPSend(socket,0x18,0x20) == -1) return(-1);
  PL_DLPRead(socket,&handle,1);
  return(handle);
}
//<

/*------------------------------------------------------**
** Name:        DLP_CloseDB                       public
**
** Funktion:    Schließt eine Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DB-Handle
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_CloseDB
(
  register __a0 APTR socket,
  register __d0 LONG handle
)
{
  KPRINTF(10, ("DLPCloseDB\n"));
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  return(PL_DLPSend(socket,0x19,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_CloseAllDB                    public
**
** Funktion:    Schließt alle Datenbanken
**
** Parameter:   socket    Socket für die Übertragung
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_CloseAllDB
(
  register __a0 APTR socket
)
{
  KPRINTF(10, ("DLPCloseAllDB\n"));
  PL_DLPInit(socket);
  return(PL_DLPSend(socket,0x19,0x21) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ResetSystem                   public
**
** Funktion:    Setzt den Palm zurück
**
** Parameter:   socket    Socket für die Übertragung
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:     9. Juni 1998, 22:06:58
*/
__saveds __asm int DLP_ResetSystem
(
  register __a0 APTR socket
)
{
  KPRINTF(10, ("DLPResetSystem\n"));
  PL_DLPInit(socket);
  return(PL_DLPSend(socket,0x29,0x00) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_AddSyncLogEntry
**
** Funktion:    Eintrag in die Sync-Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              entry     Eintrag
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 22:27:34
*/
__saveds __asm int DLP_AddSyncLogEntry
(
  register __a0 APTR socket,
  register __a1 STRPTR entry
)
{
  KPRINTF(10, ("DLPAddSyncLogEntry\n"));
  PL_DLPInit(socket);
  PL_DLPWrite(socket,entry,strlen(entry)+1);
  return(PL_DLPSend(socket,0x2A,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_CountDBEntries
**
** Funktion:    Ermittelt die Anzahl der Einträge
**
** Parameter:   socket    Socket für die Übertragung
**              handle    Handle
** Ergebnis:    entries
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 22:36:34
*/
__saveds __asm LONG DLP_CountDBEntries
(
  register __a0 APTR socket,
  register __d0 LONG handle
)
{
  UWORD entr;
  KPRINTF(10, ("DLPCountDBEntries\n"));

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  if(PL_DLPSend(socket,0x2B,0x20) == -1) return(-1);
  PL_DLPRead(socket,&entr,sizeof(UWORD));
  return((LONG)entr);
}
//<

/*------------------------------------------------------**
** Name:        DLP_MoveCategory
**
** Funktion:    Verschiebt eine Kategorie
**
** Parameter:   socket    Socket für die Übertragung
**              handle    Handle
**              oldcat    alte Kategorie
**              newcat    neue Kategorie
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 22:42:34
*/
__saveds __asm int DLP_MoveCategory
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UBYTE oldcat,
  register __d2 UBYTE newcat
)
{
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(BYTE)oldcat);
  PL_DLPWriteByte(socket,(BYTE)newcat);
  PL_DLPWriteByte(socket,0);
  return(PL_DLPSend(socket,0x2C,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_SetUserInfo
**
** Funktion:    Schreibt eine Userinfo
**
** Parameter:   socket    Socket für die Übertragung
**              user      Userinfo
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 22:47:04
*/
__saveds __asm int DLP_SetUserInfo
(
  register __a0 APTR socket,
  register __a1 struct DLP_UserInfo *user
)
{
  PL_DLPInit(socket);
  PL_DLPWriteLong(socket,(LONG)user->userID);
  PL_DLPWriteLong(socket,(LONG)user->viewerID);
  PL_DLPWriteLong(socket,(LONG)user->lastSyncPC);
  PL_DLPWrite(socket,&user->successfulSync,sizeof(struct DLP_SysTime));
  PL_DLPWriteByte(socket,(BYTE)0xFF);
  PL_DLPWriteByte(socket,strlen(user->userName)+1);
  PL_DLPWrite(socket,user->userName,strlen(user->userName)+1);
  return(PL_DLPSend(socket,0x11,0x20) != -1);
}
//<
/*------------------------------------------------------**
** Name:        DLP_GetUserInfo
**
** Funktion:    Liest eine Userinfo
**
** Parameter:   socket    Socket für die Übertragung
**              user      Userinfo
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 22:47:04
*/
__saveds __asm int DLP_GetUserInfo
(
  register __a0 APTR socket,
  register __a1 struct DLP_UserInfo *user
)
{
  UBYTE userlen;
  UBYTE pwlen;

  PL_DLPInit(socket);
  if(PL_DLPSend(socket,0x10,0x00) == -1) return(FALSE);
  PL_DLPRead(socket,&user->userID,4);
  PL_DLPRead(socket,&user->viewerID,4);
  PL_DLPRead(socket,&user->lastSyncPC,4);
  PL_DLPRead(socket,&user->successfulSync,sizeof(struct DLP_SysTime));
  PL_DLPRead(socket,&user->lastSync,sizeof(struct DLP_SysTime));
  PL_DLPRead(socket,&userlen,1);
  PL_DLPRead(socket,&pwlen,1);
  PL_DLPRead(socket,user->userName,userlen);
  user->userName[userlen] = '\0';
  PL_DLPRead(socket,user->password,pwlen);
  user->password[pwlen] = '\0';
  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_SetNetSyncInfo
**
** Funktion:    Schreibt eine NetSyncInfo
**
** Parameter:   socket    Socket für die Übertragung
**              netsync   NetSync-Info
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 23:42:44
*/
__saveds __asm int DLP_SetNetSyncInfo
(
  register __a0 APTR socket,
  register __a1 struct DLP_NetSyncInfo *netsync
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  if(sock->version < 0x0101)
  {
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)0x80|0x40|0x20|0x10);  // Change all Settings
  PL_DLPWriteByte(socket,netsync->lanSync);
  PL_DLPWriteLong(socket,0);
  PL_DLPWriteLong(socket,0);
  PL_DLPWriteLong(socket,0);
  PL_DLPWriteLong(socket,0);
  PL_DLPWriteWord(socket,strlen(netsync->hostName)+1);
  PL_DLPWriteWord(socket,strlen(netsync->hostAddress)+1);
  PL_DLPWriteWord(socket,strlen(netsync->hostSubnetMask)+1);
  PL_DLPWrite(socket,netsync->hostName,strlen(netsync->hostName)+1);
  PL_DLPWrite(socket,netsync->hostAddress,strlen(netsync->hostAddress)+1);
  PL_DLPWrite(socket,netsync->hostSubnetMask,strlen(netsync->hostSubnetMask)+1);

  return(PL_DLPSend(socket,0x37,0x20) != -1);
}
//<
/*------------------------------------------------------**
** Name:        DLP_GetNetSyncInfo
**
** Funktion:    Liest eine NetSyncInfo
**
** Parameter:   socket    Socket für die Übertragung
**              netsync   NetSync-Info
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 23:22:47
*/
__saveds __asm int DLP_GetNetSyncInfo
(
  register __a0 APTR socket,
  register __a1 struct DLP_NetSyncInfo *netsync
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  UWORD hnamelen;
  UWORD haddresslen;
  UWORD submasklen;

  if(sock->version < 0x0101)
  {
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  if(PL_DLPSend(socket,0x36,0x20) == -1) return(FALSE);
  PL_DLPRead(socket,&netsync->lanSync,1);
  PL_DLPRead(socket,NULL,17);
  PL_DLPRead(socket,&hnamelen,2);
  PL_DLPRead(socket,&haddresslen,2);
  PL_DLPRead(socket,&submasklen,2);
  PL_DLPRead(socket,netsync->hostName,hnamelen);
  netsync->hostName[hnamelen] = '\0';
  PL_DLPRead(socket,netsync->hostAddress,haddresslen);
  netsync->hostAddress[haddresslen] = '\0';
  PL_DLPRead(socket,netsync->hostSubnetMask,submasklen);
  netsync->hostSubnetMask[submasklen] = '\0';
  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ResetLastSyncPC
**
** Funktion:    Liest eine NetSyncInfo
**
** Parameter:   socket    Socket für die Übertragung
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 23:22:47
*/
__saveds __asm int DLP_ResetLastSyncPC
(
  register __a0 APTR socket
)
{
  struct DLP_UserInfo user;

  if(!DLP_GetUserInfo(socket,&user)) return(FALSE);
  user.lastSyncPC = 0;
  return(DLP_SetUserInfo(socket,&user));
}
//<

/*------------------------------------------------------**
** Name:        DLP_ResetDBIndex
**
** Funktion:    Liest eine NetSyncInfo
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    12. Juni 1998, 23:22:47
*/
__saveds __asm int DLP_ResetDBIndex
(
  register __a0 APTR socket,
  register __d0 LONG handle
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  sock->dlprecord = 0;
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  return(PL_DLPSend(socket,0x30,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_GetRecordIDList
**
** Funktion:    Liest eine Liste von Records-IDs
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              sort      Sortieren?
**              start     Start-ID
**              max       Platz in Structure
**              ids       Table für IDs
**              count     Zählvariable
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:22:59
*/
__saveds __asm LONG DLP_GetRecordIDList
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 BOOL sort,
  register __d2 UWORD start,
  register __d3 UWORD max,
  register __a1 ULONG *ids
)
{
  LONG retnum;
  UWORD num;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(sort ? 0x80 : 0x00));
  PL_DLPWriteWord(socket,start);
  PL_DLPWriteWord(socket,max);
  if(PL_DLPSend(socket,0x31,0x20) == -1) return(-1);
  PL_DLPRead(socket,&num,2);
  retnum = num;
  while(num--) PL_DLPRead(socket,ids++,4);
  return(retnum);
}
//<

/*------------------------------------------------------**
** Name:        DLP_WriteRecord
**
** Funktion:    Schreibt einen Record
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              flags     Flags
**              id        Record-ID
**              catid     Kategorie-ID
**              buffer    Pufferdaten
**              length    Länge des Puffers
**              newid     rückgelieferte ID
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:34:13
*/
__saveds __asm int DLP_WriteRecord
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UBYTE flags,
  register __d2 ULONG id,
  register __d3 UBYTE catid,
  register __a1 APTR buffer,
  register __d4 UWORD length,
  register __a2 ULONG *newid
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0);
  PL_DLPWriteLong(socket,(LONG)id);
  PL_DLPWriteByte(socket,(BYTE)flags);
  PL_DLPWriteByte(socket,(BYTE)catid);
  if(!PL_DLPTstWrite(socket,length))
  {
    sock->lastError = PLERR_TOOLARGE;
    return(FALSE);
  }
  PL_DLPWrite(socket,buffer,length);

  if((reply=PL_DLPSend(socket,0x21,0x20)) == -1) return(FALSE);

  if(newid)
  {
    if(reply==4)
      PL_DLPRead(socket,newid,4);
    else
      *newid = 0;
  }

  return(TRUE);
}
//<

/*------------------------------------------------------**
** Name:        DLP_DeleteRecord
**
** Funktion:    Löscht einen Record
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              all       Alle Records
**              id        Record-ID
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:43:18
*/
__saveds __asm int DLP_DeleteRecord
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 BOOL all,
  register __d2 ULONG id
)
{
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(all ? 0x80 : 0x00));
  PL_DLPWriteLong(socket,(LONG)id);
  return(PL_DLPSend(socket,0x22,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_DeleteCategory
**
** Funktion:    Löscht eine Kategorie
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              category  Kategorie-Code
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:43:18
*/
__saveds __asm int DLP_DeleteCategory
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UBYTE category
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  if(sock->version < 0x0101)
  {
    /*TODO: write PalmOS 1 emulation code */
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x40);
  PL_DLPWriteLong(socket,((LONG)category) & 0xFF);
  return(PL_DLPSend(socket,0x22,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadResourceByType
**
** Funktion:    Liest eine Resource nach Typ
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              type      Typ-ID
**              id        Kategorie-ID
**              buffer    Zielpuffer
**              index
**              size
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:52:51
*/
__saveds __asm LONG DLP_ReadResourceByType
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 ULONG type,
  register __d2 UWORD id,
  register __a1 APTR buffer,
  register __a2 UWORD *index,
  register __a3 UWORD *size
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x40);
  PL_DLPWriteLong(socket,(LONG)type);
  PL_DLPWriteWord(socket,(WORD)id);
  PL_DLPWriteWord(socket,0);
  PL_DLPWriteWord(socket,(buffer ? 0xFFFF : 0));
  if((reply=PL_DLPSend(socket,0x23,0x21)) == -1) return(-1);
  PL_DLPRead(socket,NULL,6);
  PL_DLPRead(socket,index,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,buffer,reply-10);
  return(reply-10);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadResourceByIndex
**
** Funktion:    Liest eine Resource nach Index
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              index     Index
**              buffer    Zielpuffer
**              type      Typ
**              id
**              size
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 00:52:51
*/
__saveds __asm LONG DLP_ReadResourceByIndex
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UWORD index,
  register __a1 APTR buffer,
  register __a2 ULONG *type,
  register __a3 UWORD *id,
  register __d2 UWORD *size
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteWord(socket,(WORD)index);
  PL_DLPWriteWord(socket,0);
  PL_DLPWriteWord(socket,(buffer ? 0xFFFF : 0));
  if((reply=PL_DLPSend(socket,0x23,0x20)) == -1) return(-1);
  PL_DLPRead(socket,type,4);
  PL_DLPRead(socket,id,2);
  PL_DLPRead(socket,NULL,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,buffer,reply-10);
  return(reply-10);
}
//<

/*------------------------------------------------------**
** Name:        DLP_WriteResource
**
** Funktion:    Schreibt eine Resource
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              type      Typ
**              id
**              buffer    Datenbuffer
**              length    Länge des Pakets
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 17:58:49
*/
__saveds __asm int DLP_WriteResource
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 ULONG type,
  register __d2 UWORD id,
  register __a1 APTR buffer,
  register __d3 UWORD length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteLong(socket,(LONG)type);
  PL_DLPWriteWord(socket,id);
  PL_DLPWriteWord(socket,length);
  if(!PL_DLPTstWrite(socket,length))
  {
    sock->lastError = PLERR_TOOLARGE;
    return(FALSE);
  }
  PL_DLPWrite(socket,buffer,length);
  return(PL_DLPSend(socket,0x24,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_DeleteResource
**
** Funktion:    Löscht eine Resource
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              all       Alle Resourcen
**              restype   Resource-Typ
**              resid     Resource-ID
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 18:34:17
*/
__saveds __asm int DLP_DeleteResource
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 BOOL all,
  register __d2 ULONG restype,
  register __d3 UWORD resid
)
{
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(all ? 0x80 : 0x00));
  PL_DLPWriteLong(socket,(LONG)restype);
  PL_DLPWriteWord(socket,(WORD)resid);
  return(PL_DLPSend(socket,0x25,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadAppBlock
**
** Funktion:    Liest einen AppBlock (?)
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              offset    Offset
**              buffer    Zielpuffer
**              length    Puffergröße
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 18:44:41
*/
__saveds __asm LONG DLP_ReadAppBlock
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UWORD offset,
  register __a1 APTR buffer,
  register __d2 UWORD length
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteWord(socket,(WORD)offset);
  PL_DLPWriteWord(socket,(WORD)length);
  if((reply=PL_DLPSend(socket,0x1B,0x20)) == -1) return(-1);
  if(buffer)
  {
    PL_DLPRead(socket,NULL,2);
    PL_DLPRead(socket,buffer,reply-2);
  }
  return(reply-2);
}
//<
/*------------------------------------------------------**
** Name:        DLP_WriteAppBlock
**
** Funktion:    Schreibt einen AppBlock
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              buffer    Datenbuffer
**              length    Länge des Pakets
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 17:58:49
*/
__saveds __asm int DLP_WriteAppBlock
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __a1 APTR buffer,
  register __d1 UWORD length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteWord(socket,(WORD)length);
  if(!PL_DLPTstWrite(socket,length))
  {
    sock->lastError = PLERR_TOOLARGE;
    return(FALSE);
  }
  PL_DLPWrite(socket,buffer,length);
  return(PL_DLPSend(socket,0x1C,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadSortBlock
**
** Funktion:    Liest einen SortBlock (?)
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              offset    Offset
**              buffer    Zielpuffer
**              length    Puffergröße
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 18:44:41
*/
__saveds __asm LONG DLP_ReadSortBlock
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UWORD offset,
  register __a1 APTR buffer,
  register __d2 UWORD length
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteWord(socket,(WORD)offset);
  PL_DLPWriteWord(socket,(WORD)length);
  if((reply=PL_DLPSend(socket,0x1D,0x20)) == -1) return(-1);
  if(buffer)
  {
    PL_DLPRead(socket,NULL,2);
    PL_DLPRead(socket,buffer,reply-2);
  }
  return(reply-2);
}
//<
/*------------------------------------------------------**
** Name:        DLP_WriteSortBlock
**
** Funktion:    Schreibt einen SortBlock
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              buffer    Datenbuffer
**              length    Länge des Pakets
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 19:09:25
*/
__saveds __asm int DLP_WriteSortBlock
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __a1 APTR buffer,
  register __d1 UWORD length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0x00);
  PL_DLPWriteWord(socket,(WORD)length);
  if(!PL_DLPTstWrite(socket,length))
  {
    sock->lastError = PLERR_TOOLARGE;
    return(FALSE);
  }
  PL_DLPWrite(socket,buffer,length);
  return(PL_DLPSend(socket,0x1E,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_CleanUpDatabase
**
** Funktion:    Säubert die Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 19:11:45
*/
__saveds __asm int DLP_CleanUpDatabase
(
  register __a0 APTR socket,
  register __d0 LONG handle
)
{
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  return(PL_DLPSend(socket,0x26,0x20) != -1);
}
//<
/*------------------------------------------------------**
** Name:        DLP_ResetSyncFlags
**
** Funktion:    Säubert die Datenbank
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 19:11:45
*/
__saveds __asm int DLP_ResetSyncFlags
(
  register __a0 APTR socket,
  register __d0 LONG handle
)
{
  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  return(PL_DLPSend(socket,0x27,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadNextCatRecord
**
** Funktion:    Liest den nächsten Record der Kategorie
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              cat       Kategorie
**              buffer    Zielpuffer
**              id        Platz für Record-ID
**              index     Platz für Record-Index
**              size      Platz für Record-Size
**              attr      Platz für Record-Attribut
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 19:26:14
*/
__saveds __asm LONG DLP_ReadNextCatRecord
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UBYTE cat,
  register __a1 APTR buffer,
  register __a2 ULONG *id,
  register __a3 UWORD *index,
  register __d2 UWORD *size,
  register __d3 UBYTE *attr
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  LONG reply;

  if(sock->version < 0x0101)
  {
    /*TODO: write PalmOS 1 emulation code */
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(BYTE)cat);
  if((reply=PL_DLPSend(socket,0x32,0x20)) == -1) return(-1);
  PL_DLPRead(socket,id,4);
  PL_DLPRead(socket,index,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,attr,1);
  if(buffer)
  {
    PL_DLPRead(socket,NULL,1);
    PL_DLPRead(socket,buffer,reply-10);
  }
  return(reply-10);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadAppPreference
**
** Funktion:    Liest die Prefs einer App
**
** Parameter:   socket    Socket für die Übertragung
**              creator   Erzeuger-ID
**              id        ID
**              backup    ??
**              maxsize   Maximale Größe
**              buffer    Zielpuffer
**              size      Platz für Größe
**              version   Platz für Version
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 20:36:57
*/
__saveds __asm LONG DLP_ReadAppPreference
(
  register __a0 APTR socket,
  register __d0 ULONG creator,
  register __d1 UWORD id,
  register __d2 BOOL backup,
  register __d3 UWORD maxsize,
  register __a1 APTR buffer,
  register __a2 UWORD *size,
  register __a3 UWORD *version
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  UWORD stotal, sreturn;

  if(sock->version < 0x0101)
  {
    /*TODO: write PalmOS 1 emulation code */
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteLong(socket,(LONG)creator);
  PL_DLPWriteWord(socket,(WORD)id);
  PL_DLPWriteWord(socket,(buffer ? maxsize : 0));
  PL_DLPWriteByte(socket,(backup ? 0x80 : 0x00));
  PL_DLPWriteByte(socket,0);
  if(PL_DLPSend(socket,0x34,0x20) == -1) return(-1);
  PL_DLPRead(socket,version,2);
  PL_DLPRead(socket,&stotal,2);
  PL_DLPRead(socket,&sreturn,2);
  if(buffer)
  {
    PL_DLPRead(socket,buffer,sreturn);
    *size = sreturn;
  }
  else
  {
    *size = stotal;
  }
  return(sreturn);
}
//<
/*------------------------------------------------------**
** Name:        DLP_WriteAppPreference
**
** Funktion:    Schreibt die Prefs einer App
**
** Parameter:   socket    Socket für die Übertragung
**              creator   Erzeuger-ID
**              id        ID
**              backup    ??
**              version   Versionsnr.
**              buffer    Zielpuffer
**              size      Größe
** Ergebnis:    success
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 20:36:57
*/
__saveds __asm int DLP_WriteAppPreference
(
  register __a0 APTR socket,
  register __d0 ULONG creator,
  register __d1 UWORD id,
  register __d2 BOOL backup,
  register __d3 UWORD version,
  register __a1 APTR buffer,
  register __d4 UWORD length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;

  if(sock->version < 0x0101)
  {
    /*TODO: write PalmOS 1 emulation code */
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteLong(socket,(LONG)creator);
  PL_DLPWriteWord(socket,(WORD)id);
  PL_DLPWriteWord(socket,(WORD)version);
  PL_DLPWriteWord(socket,(WORD)length);
  PL_DLPWriteByte(socket,(backup ? 0x80 : 0x00));
  PL_DLPWriteByte(socket,0);
  if(!PL_DLPTstWrite(socket,length))
  {
    sock->lastError = PLERR_TOOLARGE;
    return(FALSE);
  }
  PL_DLPWrite(socket,buffer,length);
  return(PL_DLPSend(socket,0x35,0x20) != -1);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadNextModifiedCatRecord
**
** Funktion:    Liest den nächsten modifizierten Record der Kategorie
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              cat       Kategorie
**              buffer    Zielpuffer
**              id        Platz für Record-ID
**              index     Platz für Record-Index
**              size      Platz für Record-Size
**              attr      Platz für Record-Attribut
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 20:56:03
*/
__saveds __asm LONG DLP_ReadNextModifiedCatRecord
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UBYTE cat,
  register __a1 APTR buffer,
  register __a2 ULONG *id,
  register __a3 UWORD *index,
  register __d2 UWORD *size,
  register __d3 UBYTE *attr
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  LONG reply;

  if(sock->version < 0x0101)
  {
    /*TODO: write PalmOS 1 emulation code */
    sock->lastError = PLERR_OS2REQUIRED;
    return(FALSE);
  }

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,(BYTE)cat);
  if((reply=PL_DLPSend(socket,0x33,0x20)) == -1) return(-1);
  PL_DLPRead(socket,id,4);
  PL_DLPRead(socket,index,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,attr,1);
  if(buffer)
  {
    PL_DLPRead(socket,NULL,1);
    PL_DLPRead(socket,buffer,reply-10);
  }
  return(reply-10);
}
//<

/*------------------------------------------------------**
** Name:        DLP_ReadRecordByID
**
** Funktion:    Liest einen Eintrag per ID
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              id        Record-ID
**              buffer    Zielpuffer
**              index     Platz für Record-Index
**              size      Platz für Record-Size
**              attr      Platz für Record-Attribut
**              cat       Platz für Kategoriecode
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 20:56:03
*/
__saveds __asm LONG DLP_ReadRecordByID
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 ULONG id,
  register __a1 APTR buffer,
  register __a2 UWORD *index,
  register __a3 UWORD *size,
  register __d2 UBYTE *attr,
  register __d3 UBYTE *cat
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0);
  PL_DLPWriteLong(socket,4);
  PL_DLPWriteWord(socket,0);
  PL_DLPWriteWord(socket,(buffer ? 0xFFFF : 0));
  if((reply=PL_DLPSend(socket,0x20,0x20)) == -1) return(-1);
  PL_DLPRead(socket,NULL,4);
  PL_DLPRead(socket,index,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,attr,1);
  PL_DLPRead(socket,cat,1);
  if(buffer)
  {
    PL_DLPRead(socket,buffer,reply-10);
  }
  return(reply-10);
}
//<
/*------------------------------------------------------**
** Name:        DLP_ReadRecordByIndex
**
** Funktion:    Liest einen Eintrag per Index
**
** Parameter:   socket    Socket für die Übertragung
**              handle    DBHandle
**              index     Record-Index
**              buffer    Zielpuffer
**              size      Platz für Record-Size
**              attr      Platz für Record-Attribut
**              cat       Platz für Kategoriecode
**              id        Platz für Record-ID
** Ergebnis:    length    Datenpaket
//>
** Bemerkungen:
**
** Revision:    13. Juni 1998, 20:56:03
*/
__saveds __asm LONG DLP_ReadRecordByIndex
(
  register __a0 APTR socket,
  register __d0 LONG handle,
  register __d1 UWORD index,
  register __a1 APTR buffer,
  register __a2 ULONG *id,
  register __a3 UWORD *size,
  register __d2 UBYTE *attr,
  register __d3 UBYTE *cat
)
{
  LONG reply;

  PL_DLPInit(socket);
  PL_DLPWriteByte(socket,(BYTE)handle);
  PL_DLPWriteByte(socket,0);
  PL_DLPWriteWord(socket,(WORD)index);
  PL_DLPWriteWord(socket,0);
  PL_DLPWriteWord(socket,(buffer ? 0xFFFF : 0));
  if((reply=PL_DLPSend(socket,0x20,0x21)) == -1) return(-1);
  PL_DLPRead(socket,id,4);
  PL_DLPRead(socket,NULL,2);
  PL_DLPRead(socket,size,2);
  PL_DLPRead(socket,attr,1);
  PL_DLPRead(socket,cat,1);
  if(buffer)
  {
    PL_DLPRead(socket,buffer,reply-10);
  }
  return(reply-10);
}
//<

/*------------------------------------------------------**
** Name:        DLP_UnpackCategoryAppInfo
**
** Funktion:    Entpackt eine Category AppInfo-Struktur
**
** Parameter:   cai       Platz für CategoryAppInfo
**              record    Zeiger auf Record
**              length    Länge des Records
** Ergebnis:    length    Länge des Category AppInfos
//>
** Bemerkungen:
**
** Revision:     2. März 1999, 23:45:04
*/
__saveds __asm LONG DLP_UnpackCategoryAppInfo
(
  register __a0 struct PL_CategoryAppInfo *cai,
  register __a1 APTR record,
  register __d0 LONG length
)
{
  if(length < sizeof(struct PL_CategoryAppInfo))
    return 0;                                     // Zu kurz

  CopyMem(record,cai,sizeof(struct PL_CategoryAppInfo));
  return sizeof(struct PL_CategoryAppInfo);
}
//<
/*------------------------------------------------------**
** Name:        DLP_PackCategoryAppInfo
**
** Funktion:    Packt eine Category AppInfo-Struktur
**
** Parameter:   cai       Zeiger auf CategoryAppInfo
**              record    Zeiger auf Record, oder NULL,
**                        um die Größe herauszufinden
**              length    Länge des Records
** Ergebnis:    length    Länge des Category AppInfos
//>
** Bemerkungen:
**
** Revision:     2. März 1999, 23:45:04
*/
__saveds __asm LONG DLP_PackCategoryAppInfo
(
  register __a0 struct PL_CategoryAppInfo *cai,
  register __a1 APTR record,
  register __d0 LONG length
)
{
  if(!record)
    return sizeof(struct PL_CategoryAppInfo);
  if(length < sizeof(struct PL_CategoryAppInfo))
    return 0;                                     // Too short

  CopyMem(cai,record,sizeof(struct PL_CategoryAppInfo));
  return sizeof(struct PL_CategoryAppInfo);
}
//<




/********************************************************************/
