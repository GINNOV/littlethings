/*
 *  This file is part of ixemul.library for the Amiga.
 *  Copyright (C) 1991, 1992  Markus M. Wild
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _PACKETS_H
#define _PACKETS_H

#ifdef __pos__

#define CTOBPTR(ptr) ((long)ptr)
#define BTOCPTR(ptr) ((void *)ptr)
#define HANDLER_NIL(fp) (!(fp)->f_fh->fh_DosDev)

#else

#define PutPacket(port,pack) PutMsg((port), (struct Message *)(pack))

#define GetPacket(port) ((struct StandardPacket *)GetMsg(port))

/***************************************************************************/

#define LastResult(f) ((f)->f_sp.sp_Pkt.dp_Res1)
#define LastError(f) ((f)->f_sp.sp_Pkt.dp_Res2)

#define SelLastResult(f) ((f)->f_select_sp.sp_Pkt.dp_Res1)
#define SelLastError(f) ((f)->f_select_sp.sp_Pkt.dp_Res2)

/***************************************************************************/

#define SendPacket0(fp,port,act) \
  ((fp)->f_sp.sp_Pkt.dp_Port = (port), (fp)->f_sp.sp_Pkt.dp_Type = (act), \
  PutPacket((fp)->f_fh->fh_Type, &(fp)->f_sp))

#define SendPacket1(fp,port,act,arg1) \
  ((fp)->f_sp.sp_Pkt.dp_Port = (port), (fp)->f_sp.sp_Pkt.dp_Type = (act), \
  (fp)->f_sp.sp_Pkt.dp_Arg1 = (arg1), \
  PutPacket((fp)->f_fh->fh_Type, &(fp)->f_sp))

#define SelSendPacket1(fp,port,act,arg1) \
  ((fp)->f_select_sp.sp_Pkt.dp_Port = (port), (fp)->f_select_sp.sp_Pkt.dp_Type = (act), \
  (fp)->f_select_sp.sp_Pkt.dp_Arg1 = (arg1), \
  PutPacket((fp)->f_fh->fh_Type, &(fp)->f_select_sp))

#define SendPacket2(fp,port,act,arg1,arg2) \
  ((fp)->f_sp.sp_Pkt.dp_Port = (port), (fp)->f_sp.sp_Pkt.dp_Type = (act), \
  (fp)->f_sp.sp_Pkt.dp_Arg1 = (arg1), (fp)->f_sp.sp_Pkt.dp_Arg2 = (arg2), \
  PutPacket((fp)->f_fh->fh_Type, &(fp)->f_sp))

#define SendPacket3(fp,port,act,arg1,arg2,arg3) \
  ((fp)->f_sp.sp_Pkt.dp_Port = (port), (fp)->f_sp.sp_Pkt.dp_Type = (act), \
  (fp)->f_sp.sp_Pkt.dp_Arg1 = (arg1), (fp)->f_sp.sp_Pkt.dp_Arg2 = (arg2), \
  (fp)->f_sp.sp_Pkt.dp_Arg3 = (arg3), \
  PutPacket((fp)->f_fh->fh_Type, &((fp)->f_sp)))

#define SendPacket4(fp,port,act,arg1,arg2,arg3,arg4) \
  ((fp)->f_sp.sp_Pkt.dp_Port = (port), (fp)->f_sp.sp_Pkt.dp_Type = (act), \
  (fp)->f_sp.sp_Pkt.dp_Arg1 = (arg1), (fp)->f_sp.sp_Pkt.dp_Arg2 = (arg2), \
  (fp)->f_sp.sp_Pkt.dp_Arg3 = (arg3), (fp)->f_sp.sp_Pkt.dp_Arg4 = (arg4), \
  PutPacket((fp)->f_fh->fh_Type, &(fp)->f_sp))

/***************************************************************************/

#define HANDLER_NIL(fp) (!(fp)->f_fh->fh_Type)

#define CTOBPTR(ptr) (((long)(ptr)) >> 2)
#define BTOCPTR(ptr) ((void *)((ptr) << 2))

#endif

/* this version only works for word-aligned data as you get it from alloca()! */
#define LONG_ALIGN(ptr) ((void *)((((long)(ptr))&3)?((long)ptr)+2:(long)ptr))

#endif /* _PACKETS_H */
