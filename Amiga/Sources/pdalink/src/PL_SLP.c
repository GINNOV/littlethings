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
 * Handles the Serial Link Protocol (SLP).
 *
 * @author Richard "Shred" Körber
 */ 

#include "pdalink_glob.h"


/*------------------------------------------------------**
** Name:        CRC16                            private
**
** Funktion:    Calculate CRC16 checksum
**
** Parameter:   buf       Start des Buffers
**              len       Länge des Buffers
**              crc       CRC aus vorigem Bufferabschnitt,
**                        0 beim ersten mal
** Ergebnis:    CRC-Prüfsumme
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 22:01:39
*/
static UWORD CRC16(UBYTE *buf, UWORD len, UWORD crc)
{
  register UWORD i;

  while(len--)
  {
    crc ^= (UWORD)(*buf++ << 8);
    for(i=0; i<8; i++)
    {
      if(crc & 0x8000)
        crc = (crc<<1) ^ 0x1021;
      else
        crc = crc<<1;
    }
  }
  return(crc);
}
//<

/*------------------------------------------------------**
** Name:        PL_SLPWrite                       public
**
** Funktion:    Verschickt ein SLP-Paket
**
** Parameter:   socket    Socket für die Übertragung
**              buffer    zu übertragener Puffer
**              length    Länge des Puffers
**              header    SLP-Header
**              PADP      Optional: PADP-Header
** Ergebnis:    length    Verschickte Daten oder
**                        -1: Fehler
//>
** Bemerkungen:
**
** Revision:    31. Mai 1998, 21:14:30
*/
__saveds __asm LONG PL_SLPWrite
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length,
  register __a2 struct PL_SLP_Header *header,
  register __a3 struct PL_PADP_Header *padp
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  UWORD i;
  UBYTE hdrsum;
  UWORD checksum;
  KPRINTF(10, ("SLPWrite\n"));

  sock->lastError = PLERR_OKAY;
  if(sock->serial->isUSB)
  {
      return(-1);
  }

  /* Create signature */
  header->signature[0] = 0xBE;
  header->signature[1] = 0xEF;
  header->signature[2] = 0xED;
  header->dataSize     = (padp ? length+sizeof(struct PL_PADP_Header) : length) ;

  /* Calculate header checksum */
  for(hdrsum = i = 0; i<(sizeof(struct PL_SLP_Header)-1); i++)
  {
    hdrsum += ((UBYTE *)header)[i];
  }
  header->checksum = hdrsum;

  /* Calculate data checksum */
  checksum = CRC16((UBYTE *)header,sizeof(struct PL_SLP_Header),0);
  if(padp) checksum = CRC16((UBYTE *)padp,sizeof(struct PL_PADP_Header),checksum);
  checksum = CRC16((UBYTE *)buffer,length,checksum);

  /* Send packet, and we are done */
  if(PL_RawWrite(socket,(UBYTE *)header,sizeof(struct PL_SLP_Header)))
  {
    if(!padp || PL_RawWrite(socket,padp,sizeof(struct PL_PADP_Header)))
    {
      if(PL_RawWrite(socket,buffer,length))
      {
        if(PL_RawWrite(socket,(UBYTE *)&checksum,2))
        {
#ifdef SLPDEBUG
  Printf("SLP A->P: dest=%ld src=%ld type=%ld dataSize=%ld transID=0x%02lx sum=0x%02lx\n",header->destSocket,header->srcSocket,header->pckType,header->dataSize,header->transID,header->checksum);
#endif
          return(length);                 // Success
        }
      }
    }
  }
  return(-1);                           // Failure
}
//<

/*------------------------------------------------------**
** Name:        PL_SLPRead                        public
**
** Funktion:    Holt ein SLP-Paket
**
** Parameter:   socket    Socket für die Übertragung
**              buffer    Empfangspuffer
**              length    Länge des Empfangsbuffer
**              header    SLP-Header-Puffer
**              padp      Optional: PADP-Header
** Ergebnis:    length    Länge des empfangenen Puffers
**                        (ohne SLP-Header), -1: Fehler
//>
** Bemerkungen:
**
** Revision:     1. Juni 1998, 16:01:46
*/
__saveds __asm LONG PL_SLPRead
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length,
  register __a2 struct PL_SLP_Header *header,
  register __a3 struct PL_PADP_Header *padp
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  UBYTE  read;                          // Reading into this variable
  UBYTE  hdrsum;
  UWORD  i;
  UWORD  readChecksum;
  UWORD  checksum;
  KPRINTF(10, ("SLPRead\n"));

  sock->lastError = PLERR_OKAY;         // No error occured yet
  if(sock->serial->isUSB)
  {
      return(-1);
  }

  /* State machine: wait for header */
  if(PL_RawRead(socket,&read,1))
  {
    for(;;)
    {
      /* wait for 0xBEEFED */
      if(read==0xBE)
      {
        header->signature[0] = read;
        if(!PL_RawRead(socket,&read,1)) return(-1);   // <--- Failed ---
        if(read!=0xEF) continue;
        header->signature[1] = read;
        if(!PL_RawRead(socket,&read,1)) return(-1);   // <--- Failed ---
        if(read!=0xED) continue;
        header->signature[2] = read;
      }
      else
      {
        if(!PL_RawRead(socket,&read,1)) return(-1);   // <--- Failed ---
        continue;
      }

      /* Looks promising, read rest of the header */
      if(!PL_RawRead(socket,&header->destSocket,7)) return(-1); // <--- Failed ---

      /* Check sum okay? */
      for(hdrsum = i = 0; i<(sizeof(struct PL_SLP_Header)-1); i++)
      {
        hdrsum += ((UBYTE *)header)[i];
      }

      /* LOOP packet ? */
      if(header->pckType == PLSLPTYPE_LOOP)           // is ignored
      {
        for(i=0; i<(header->dataSize+2); i++)
        {
          if(!PL_RawRead(socket,&read,1)) return(-1); // <--- Failure ---
        }
        continue;                                     // Wait for next packet
      }

      if(header->checksum == hdrsum) break;           // Found a good header
    }
  }

  /* Fetch rest of data */
  if(padp)
  {
    length = min(header->dataSize - sizeof(struct PL_PADP_Header), length);
    if(!PL_RawRead(socket,padp,sizeof(struct PL_PADP_Header))) return(-1);
    if(!PL_RawRead(socket,buffer,length)) return(-1);   // Read error
  }
  else
  {
    length = min(header->dataSize,length);
    if(!PL_RawRead(socket,buffer,length)) return(-1);   // read error
  }

  /* Read CRC16 */
  if(!PL_RawRead(socket,(UBYTE *)&readChecksum,2)) return(-1); // read error

  /* Compare data checksum */
  checksum = CRC16((UBYTE *)header,sizeof(struct PL_SLP_Header),0);
  if(padp) checksum = CRC16((UBYTE *)padp,sizeof(struct PL_PADP_Header),checksum);
  checksum = CRC16((UBYTE *)buffer,length,checksum);
  if(checksum!=readChecksum)
  {
    sock->lastError = PLERR_CHECKSUM;
    return(-1);                                       // bad checksum
  }

#ifdef SLPDEBUG
  Printf("SLP A<-P: dest=%ld src=%ld type=%ld dataSize=%ld transID=0x%02lx sum=0x%02lx\n",header->destSocket,header->srcSocket,header->pckType,header->dataSize,header->transID,header->checksum);
#endif

  return(length);                                     // Packet received
}
//<


/********************************************************************/
