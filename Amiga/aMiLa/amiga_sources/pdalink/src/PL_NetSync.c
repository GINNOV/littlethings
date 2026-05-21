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
 * Handles the NetSync protocol.
 *
 * @author Chris Hodges <chrisly@platon42.de>
 */
 
#include "pdalink_glob.h"

/**
 * Sends a NetSync packet.
 *
 * @param socket        Connection socket
 * @param buffer        Buffer to be transmitted
 * @param length        Buffer length
 * @param type          Packet type
 * @return Number of bytes written, or -1: error
 */
__saveds __asm LONG PL_NetSyncWrite
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length,
  register __d1 UWORD type
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_NetSync_Header netsyncp;     // NetSync header
  LONG rlen = -1;
  KPRINTF(10, ("NetSyncWrite\n"));
  sock->lastError = PLERR_OKAY;

  /* Create transaction ID */
  if(!sock->initiator)
  {
    sock->transactionID++;
    if((sock->transactionID==0x00) || (sock->transactionID==0xFF)) // wrap around in time
      sock->transactionID=0x01;
  }

  /* create NetSync header */
  netsyncp.type     = 0x01;//type;
  netsyncp.transID  = sock->transactionID;
  netsyncp.dataSize = length;

#ifdef NETSYNCDEBUG
  Printf("NetSync A->P: type=%ld size=%ld tID=0x%02lx\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID);
#endif
  KPRINTF(10, ("NetSync A->P: type=%ld size=%ld tID=0x%02lx\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID));
  if(PL_RawWrite(socket, (UBYTE *) &netsyncp, sizeof(netsyncp)) == sizeof(netsyncp))
  {
#ifdef NETSYNCDEBUG
      Printf("NetSync data...\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID);
#endif
      KPRINTF(10, ("NetSync data...\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID));
      rlen = PL_RawWrite(socket, buffer, length);
      if(rlen != length)
      {
#ifdef NETSYNCDEBUG
          Printf("Write error %ld != %ld\n", rlen, length);
#endif
          KPRINTF(10, ("Write error %ld != %ld\n", rlen, length));
          return(-1);
      }
  }

  return(rlen);
}

/**
 * Reads a NetSync packet.
 *
 * @param socket        Connection socket
 * @param buffer        Buffer for reading
 * @param length        Buffer length
 * @return Bytes actually read, or -1: error
 */
__saveds __asm LONG PL_NetSyncRead
(
  register __a0 APTR socket,
  register __a1 APTR buffer,
  register __d0 LONG length
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_NetSync_Header netsyncp;
  LONG rlen;
  KPRINTF(10, ("NetSyncRead\n"));

  sock->lastError = PLERR_OKAY;

  /* Create transaction ID */
  if(sock->initiator)
  {
    sock->transactionID++;
    if(sock->transactionID==0xFF)
      sock->transactionID=0x01;
  }

  /* Receive data */
  do
  {
    rlen = PL_RawRead(socket, (UBYTE *) &netsyncp, sizeof(netsyncp));
    if(rlen != sizeof(netsyncp))
    {
      KPRINTF(10,("NetSync Read error %ld: type=%ld size=%ld tID=0x%02lx\n", rlen, netsyncp.type, netsyncp.dataSize, netsyncp.transID));
#ifdef NETSYNCDEBUG
      Printf("NetSync Read error %ld: type=%ld size=%ld tID=0x%02lx\n", rlen, netsyncp.type, netsyncp.dataSize, netsyncp.transID);
#endif
      sock->lastError = PLERR_BADPACKET;
      return(-1);
    }
    if((netsyncp.type == 0x90) && (netsyncp.transID == 0x01) && (netsyncp.dataSize == 0))
    {
        /* workaround for bug in USB protocol, sometimes losing the first header */
        KPRINTF(10, ("USB Magic 1 fix\n"));
        memcpy(buffer, &netsyncp, 6);
        buffer = ((UBYTE *) buffer) + 6;
        netsyncp.type = 1;
        netsyncp.transID = 0xFF;
        netsyncp.dataSize = 22-6;
    }
    if((netsyncp.type == 0x92) && (netsyncp.transID == 0x01) && (netsyncp.dataSize == 0))
    {
        /* workaround for bug in USB protocol, sometimes losing the first header */
        KPRINTF(10, ("USB Magic 2 fix\n"));
        memcpy(buffer, &netsyncp, 6);
        buffer = ((UBYTE *) buffer) + 6;
        netsyncp.type = 1;
        netsyncp.transID = sock->transactionID;
        netsyncp.dataSize = 50-6;
    }
#ifdef NETSYNCDEBUG
    Printf("NetSync A<-P: type=%ld size=%ld tID=0x%02lx\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID);
#endif
    KPRINTF(10, ("NetSync A<-P: type=%ld size=%ld tID=0x%02lx\n", netsyncp.type, netsyncp.dataSize, netsyncp.transID));

    if(netsyncp.dataSize > length)
    {
#ifdef NETSYNCDEBUG
      Printf("Buffer overflow (%ld > %ld)\n", netsyncp.dataSize, length);
#endif
      KPRINTF(10, ("Buffer overflow (%ld > %ld)\n", netsyncp.dataSize, length));
      sock->lastError = PLERR_BADPACKET;
      return(-1);
    }

    rlen = PL_RawRead(socket, buffer, netsyncp.dataSize);
    if(rlen != netsyncp.dataSize)
    {
#ifdef NETSYNCDEBUG
      Printf("NetSync Read error %ld/%ld\n", rlen, netsyncp.dataSize, netsyncp.transID);
#endif
      KPRINTF(10, ("NetSync Read error %ld/%ld\n", rlen, netsyncp.dataSize, netsyncp.transID));
      sock->lastError = PLERR_BADPACKET;
      return(-1);
    }
  } while(netsyncp.transID != sock->transactionID);

  return(rlen);                         // Packets received
}

/*
 * "Ritual Bytes"
 */
#if 0
static UBYTE ritual_resp1[] =
{
    0x90,				/* Command */
    0x01,				/* argc */
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x20,		/* Arg ID */
    0x00, 0x00, 0x00, 0x08,		/* Arg length */
    /* Arg data */
    0x00, 0x00, 0x00, 0x01,
    0x80, 0x00, 0x00, 0x00
};
#endif
/* First packet sent by NetSync daemon, when forwarding a NetSync
 * connection:
        01 ff 00 00 00 16
        90 01 00 00 00 00 00 00 00 20 00 00 00 08 00 00
        00 02 00 00 00 00
*/

static UBYTE ritual_stmt2[] =
{
    0x12,				/* Command */
    0x01,				/* argc */
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,

    0x00, 0x20,			/* Arg ID */
    0x00, 0x00, 0x00, 0x24,		/* Arg length */

	  /* Arg data */
    0xff, 0xff, 0xff, 0xff,
    0x3c, 0x00,			/* These are reversed in the response */
    0x3c, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0xc0, 0xa8, 0xa5, 0x1f,		/* 192.168.165.31 */
    0x04, 0x27, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

#if 0
static UBYTE ritual_resp2[] =
{
    0x92,				/* Command */
    0x01,				/* argc */
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x20,		/* Arg ID */
    0x00, 0x00, 0x00, 0x24,		/* Arg length */
    /* Arg data */
    0xff, 0xff, 0xff, 0xff,
    0x00, 0x3c,
    0x00, 0x3c,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x01,
    0xc0, 0xa8, 0x84, 0x3c,		/* 192.168.132.60
    				 * Presumably, this is the IP
    				 * address (or hostid) of the
    				 * sender.
    				 */
    0x04, 0x1c, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};
#endif

static UBYTE ritual_stmt3[] =
{
    0x13,				/* Command */
    0x01,				/* argc */
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,

    0x00, 0x20,			/* Arg ID */
    0x00, 0x00, 0x00, 0x20,		/* Arg length */

    /* Arg data
     * This is very similar to ritual statement/response 2.
     */
    0xff, 0xff, 0xff, 0xff,
    0x00, 0x3c,
    0x00, 0x3c,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

#if 0
static UBYTE ritual_resp3[] = {
	0x93,				/* Command */
	0x00,				/* argc? */
	0x00, 0x00, 0x00, 0x00,
	0x00, 0x00,
};
#endif

/**
 * Performs the NetSync server ritual.
 *
 * @param socket        Connection socket
 * @return success
 */
BOOL PL_NetSyncServerRitual(struct PL_Socket *socket)
{
    APTR tmpbuf;

    KPRINTF(10, ("NetSyncServerRitual\n"));
    tmpbuf = AllocVec(128, MEMF_CLEAR|MEMF_PUBLIC);
    if(!tmpbuf)
    {
        KPRINTF(10, ("NoMem\n"));
        return(FALSE);
    }
#ifdef NETSYNCDEBUG
    Printf("NetSync Server Ritual\n");
#endif

    socket->initiator = FALSE;
#if 0
    socket->transactionID = 0xff;
    if(PL_NetSyncRead(socket, tmpbuf, 128) < 0) /* initial packet */
    {
        KPRINTF(10, ("Ritual 1 failed\n"));
        FreeVec(tmpbuf);
        return(FALSE);
    }
#endif
    socket->transactionID = 0x01;
    if(PL_NetSyncWrite(socket, ritual_stmt2, sizeof(ritual_stmt2), PLPADP_DATA) < 0) /* ritual statement 2 */
    {
        KPRINTF(10, ("Ritual 2 failed\n"));
        FreeVec(tmpbuf);
        return(FALSE);
    }
    if(PL_NetSyncRead(socket, tmpbuf, 128) < 0) /* ritual response 2 */
    {
        KPRINTF(10, ("Ritual 3 failed\n"));
        FreeVec(tmpbuf);
        return(FALSE);
    }
    if(PL_NetSyncWrite(socket, ritual_stmt3, sizeof(ritual_stmt3), PLPADP_DATA) < 0) /* ritual statement 3 */
    {
        KPRINTF(10, ("Ritual 4 failed\n"));
        FreeVec(tmpbuf);
        return(FALSE);
    }
    if(PL_NetSyncRead(socket, tmpbuf, 128) < 0) /* ritual response 3 */
    {
        KPRINTF(10, ("Ritual 5 failed\n"));
        FreeVec(tmpbuf);
        return(FALSE);
    }
    KPRINTF(10, ("Ritual successful\n"));
    FreeVec(tmpbuf);
    return(TRUE);
}


