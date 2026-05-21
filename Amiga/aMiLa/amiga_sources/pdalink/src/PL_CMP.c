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
 * The Connection Management Protocol (CMP) is handled here.
 *
 * @author Richard "Shred" Körber
 */
 
#include "pdalink_glob.h"

/**
 * Aborts a CMP connection.
 *
 * @param socket    Connection socket
 * @param reason    Reason for the abortion
 * @return success (boolean)
 */
__saveds __asm int PL_CMPAbort
(
  register __a0 APTR socket,
  register __d0 UBYTE reason
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_CMP cmp = { PLCMP_WAKEUP,0,0,0,0 };
  KPRINTF(10, ("CMPAbort\n"));

  sock->lastError = PLERR_OKAY;
  cmp.flags = reason;
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }
  return(-1!=PL_PADPWrite(socket,&cmp,sizeof(struct PL_CMP),PLPADP_DATA));
}

/**
 * Initializes a CMP connection.
 * <p>
 * Note that the serial device is not set to the new rate here.
 *
 * @param socket    Connection socket
 * @param rate      Baud rate to be used
 * @return success (boolean)
 */
__saveds __asm int PL_CMPInit
(
  register __a0 APTR socket,
  register __d0 ULONG rate
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_CMP cmp = { PLCMP_INIT,0,0,0,0 };
  KPRINTF(10, ("CMPInit\n"));

  sock->lastError = PLERR_OKAY;
  cmp.baudrate = rate;
  if(rate!=9600) cmp.flags = PLCMPF_CHANGEBAUD;
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }
  return(-1!=PL_PADPWrite(socket,&cmp,sizeof(struct PL_CMP),PLPADP_DATA));
}

/**
 * Wakes up a CMP connection.
 * <p>
 * Note that the serial device is not set to the new rate here.
 *
 * @param socket    Connection socket
 * @param maxrate   Maximum rate to be used
 * @return success (boolean)
 */
__saveds __asm int PL_CMPWakeUp
(
  register __a0 APTR socket,
  register __d0 ULONG maxrate
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  struct PL_CMP cmp = { PLCMP_WAKEUP,0,PLCMPVER_1_0,0,0 };
  KPRINTF(10, ("CMPWakeUp\n"));

  sock->lastError = PLERR_OKAY;
  cmp.baudrate = maxrate;
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }
  return(-1!=PL_PADPWrite(socket,&cmp,sizeof(struct PL_CMP),PLPADP_WAKE));
}

/**
 * Reads from the socket.
 *
 * @param socket    Connection socket
 * @param cmp       CMP buffer
 * @return success (boolean)
 */
__saveds __asm int PL_CMPRead
(
  register __a0 APTR socket,
  register __d0 struct PL_CMP *cmp
)
{
  struct PL_Socket *sock = (struct PL_Socket *)socket;
  KPRINTF(10, ("CMPRead\n"));

  sock->lastError = PLERR_OKAY;
  if(sock->serial->isUSB)
  {
      return(TRUE);
  }
  return(-1!=PL_PADPRead(socket,cmp,sizeof(struct PL_CMP)));
}


