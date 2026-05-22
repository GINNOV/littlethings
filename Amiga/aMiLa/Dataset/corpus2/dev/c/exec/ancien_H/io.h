/* IO.h - exec library function prototypes */
/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.  Duplication of this data by other than
**	licensed users is a violation of copyright law.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/
#ifndef	EXEC_IO_H
#define	EXEC_IO_H

// NOTE: The #defines are to reduce the lengths of system-generated names,
// due to the 31-character name limit on current Amiga C compilers.

#ifndef EXEC_PORTS_H
#include "exec/ports.h"
#endif !EXEC_PORTS_H

class Device;
class Unit;

const int IOB_QUICK	=	0;
const int IOF_QUICK =	(1<<IOB_QUICK);

#define CMD_INVALID	0
#define CMD_RESET	1
#define CMD_READ	2
#define CMD_WRITE	3
#define CMD_UPDATE	4
#define CMD_CLEAR	5
#define CMD_STOP	6
#define CMD_START	7
#define CMD_FLUSH	8

#define CMD_NONSTD	9

#define IORequest _IOR_
struct IORequest : public Message {
    Device  *io_Device;	    /* device node pointer  */
    Unit    *io_Unit;	    /* unit (driver private)*/
    UWORD   io_Command;		    /* device command */
    UBYTE   io_Flags;
    BYTE    io_Error;		    /* error or warning num */

   friend int OpenDevice(const TEXT *device_name,
		const int unit_number,
		const struct IORequest * iob,
		const int opt);
   friend void CloseDevice(const IORequest *r);

   friend IORequest * CheckIO( IORequest *io);
   friend int DoIO( IORequest *io);
   friend void SendIO( IORequest *io);
   friend void BeginIO( IORequest *io);
   friend int WaitIO( IORequest *io);

	IORequest() {
		io_Device = (Device *) -1;  // force Guru 3 if not open
		io_Unit = NULL;		io_Command = CMD_INVALID;
		io_Error = 0xff;
	}
	BOOL open(const TEXT *devname, int unit=0, int flags=0)
	{
		io_Error = OpenDevice(devname, unit, this, flags);
		return (io_Error == 0);
	}
 	void close() {CloseDevice(this); io_Device = (Device *) -1;}

	int error() { return io_Error; }
	void do_io(MsgPort *mp) {mn_ReplyPort = mp; io_Error = DoIO(this);}
	void start(MsgPort *mp) {mn_ReplyPort = mp; SendIO(this); }
	void begin(MsgPort *mp) {mn_ReplyPort = mp; BeginIO(this); }
	BOOL quick(MsgPort *mp)
	{ io_Flags |= IOF_QUICK;
	  mn_ReplyPort = mp;
	  BeginIO(this);
	  return io_Flags & IOF_QUICK;
	}
	IORequest *check() { return CheckIO(this); }
	void wait() { io_Error = WaitIO(this); }
};

#define IOStdReq _IORS_
struct IOStdReq : public IORequest {
//      Message io_Message;
//    Device  *io_Device;	    /* device node pointer  */
//    Unit    *io_Unit;	    /* unit (driver private)*/
//    UWORD   io_Command;		    /* device command */
//    UBYTE   io_Flags;
//    BYTE    io_Error;		    /* error or warning num */
    ULONG   io_Actual;		    /* actual number of bytes transferred */
    LONG    io_Length;		    /* requested number bytes transferred*/
    APTR    io_Data;		    /* points to data area */
    ULONG   io_Offset;		    /* offset for block ured devices */
/*  ULONG   io_Reserved1;
    ULONG   io_Reserved2;
*/

	// synchronous write

	int write(APTR data, int length = 0) // default length is strlen()
	{
	 io_Command = CMD_WRITE; io_Length = length; io_Data = data;
	 io_Flags = 0;
	 DoIO(this);
	 return io_Actual;
	}

	// synchronous read

	int read(APTR data, const int length = 1)
	{
	 io_Command = CMD_READ; io_Length = length; io_Data = data;
	 io_Flags = 0;
	 DoIO(this);
	 return io_Actual;	// *** CAUTION may indicate more data waiting
	}
};


#endif
