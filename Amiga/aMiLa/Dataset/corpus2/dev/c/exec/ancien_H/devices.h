/* Devices.h - exec library function prototypes */
/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.  Duplication of this data by other than
**	licensed users is a violation of copyright law.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/
#ifndef	EXEC_DEVICES_H
#define	EXEC_DEVICES_H

#ifndef EXEC_LIBRARIES_H
#include "exec/libraries.h"
#endif !EXEC_LIBRARIES_H

#ifndef EXEC_PORTS_H
#include "exec/ports.h"
#endif !EXEC_PORTS_H


/****** Device ******************************************************/

struct Device : public Library { 
//    Library dd_Library;

	friend void AddDevice ( Device *d);
	friend void CloseDevice( IORequest *io);
	friend int RemDevice(struct Device *d);
};


/****** Unit ********************************************************/

struct Unit : public MsgPort {
//    MsgPort *unit_MsgPort;		/* queue for unprocessed messages */
    UBYTE   unit_flags;
    UBYTE   unit_pad;
    UWORD   unit_OpenCnt;		/* number of active opens */
};


const UNITF_ACTIVE =	(1<<0);
const UNITF_INTASK =	(1<<1);

#endif
