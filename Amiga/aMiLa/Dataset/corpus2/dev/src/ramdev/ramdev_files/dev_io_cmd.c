#define __USE_INLINE__ 1
#include "ramdev.h"

/***********************************************************************/

/* this function is used to tell which commands should be handled
   immediately (on the caller's schedule). */

BOOL is_immediate_command (UWORD command) {
	BOOL result;
	switch (command) {
		case NSCMD_DEVICEQUERY:
		case CMD_INVALID:
		case CMD_RESET:
		case CMD_STOP:
		case CMD_START:
		case CMD_FLUSH:
			result = TRUE;
			break;
		default:
			result = FALSE;
			break;
	}
	return(result);
}

/* this function is used to tell which commands can never be
   done "immediately" if using interrupts since they may have
   to wait for an interrupt forever!

   These commands are Read, Write and Format. */

BOOL is_never_immediate_command (UWORD command) {
	BOOL result;
	switch (command) {
		case CMD_READ:
		case CMD_WRITE:
		case CMD_FORMAT:
			result = TRUE;
			break;
		default:
			result = FALSE;
			break;
	}
	return(result);
}

/***********************************************************************/

/* terminate_io() sends the IO request back to the user.  It knows not to mark
   the device as inactive if this was an immediate request or if the
   request was started from the server task. */

void terminate_io (LONG error, struct IORequest *io, struct MyDev *md) {
	struct Unit * unit = io->io_Unit;

	if(INFO_LEVEL-160 >= 0)
		kprintf("%s/TermIO\n",MYDEVNAME);

	/* Check if this was not an immediate command */
	if (!is_immediate_command(io->io_Command))
	{
		Disable();

		/* we may need to turn the active bit off. */
		if(!(unit->unit_flags & UNITF_INTASK))
		{
			/* the task does not have more work to do */
			unit->unit_flags &= ~UNITF_ACTIVE;
		}

		Enable();
	}

	/* if the quick bit is still set then we don't need to reply
	   msg -- just return to the user. */
	if(!(io->io_Flags & IOF_QUICK))
		ReplyMsg((struct Message *)io);
}

/***********************************************************************/

void queue_io (struct IORequest *io, struct MyDev *md) {
	struct Unit * unit = io->io_Unit;

	if(INFO_LEVEL-250 >= 0)
		kprintf("%s/PutMsg: Port=%lx Message=%lx\n",MYDEVNAME,&unit->unit_MsgPort,(struct Message *)io);

	/* Required for safe unit flag manipulation; this should be replaced
	   by a Forbid() if no interrupts are involved */
	Disable();

	/* we need to queue the request.  mark us as needing
	   task attention.  Clear the quick flag */
	unit->unit_flags |= UNITF_INTASK;

	io->io_Flags &= ~IOF_QUICK; /* We did NOT complete this quickly */

	PutMsg(&unit->unit_MsgPort,(struct Message *)io);

	Enable();
}

/***********************************************************************/

LONG read_write (struct IOStdReq *io, struct MyDev *md) {
	struct MyDevUnit * mdu = (struct MyDevUnit *)io->io_Unit;
	LONG error;

	if(INFO_LEVEL-200 >= 0)
		kprintf("%s/RdWrt len %ld offset %ld data $%lx\n",MYDEVNAME,io->io_Length,io->io_Offset,io->io_Data);

	/* check operation for legality */

	if((((ULONG)io->io_Data) & 3) != 0) /* check if user's pointer is ODD */
	{
		if(INFO_LEVEL-10 >= 0)
			kprintf("%s/bad address\n",MYDEVNAME);

		error = IOERR_BADADDRESS;
		goto out;
	}

	if((io->io_Offset & (SECTOR-1)) != 0) /* Bad sector boundary or alignment? */
	{
		if(INFO_LEVEL-10 >= 0)
			kprintf("%s/bad address\n",MYDEVNAME);

		error = IOERR_BADADDRESS;
		goto out;
	}

	/* check for IO within disc range */

	if(io->io_Offset + io->io_Length < io->io_Offset) /* overflow... (important test) */
	{
		if(INFO_LEVEL-10 >= 0)
			kprintf("%s/bad length\n",MYDEVNAME);

		error = IOERR_BADLENGTH;
		goto out;
	}

	if(io->io_Offset + io->io_Length > RAMSIZE) /* Last byte is highest acceptable total */
	{
		if(INFO_LEVEL-10 >= 0)
			kprintf("%s/bad length\n",MYDEVNAME);

		error = IOERR_BADLENGTH;
		goto out;
	}

	if((io->io_Length & (SECTOR-1)) != 0) /* Even sector boundary? */
	{
		if(INFO_LEVEL-10 >= 0)
			kprintf("%s/bad length\n",MYDEVNAME);

		error = IOERR_BADLENGTH;
		goto out;
	}

	/* We've gotten this far, it must be a valid request. */

	if(INTRRUPT)
		Wait(mdu->mdu_SigMask); /* Wait for interrupt before proceeding */

	if(io->io_Length > 0)
	{
		if(io->io_Command == CMD_READ)
			CopyMemQuick(&mdu->mdu_RAM[io->io_Offset],io->io_Data,io->io_Length);
		else
			CopyMemQuick(io->io_Data,&mdu->mdu_RAM[io->io_Offset],io->io_Length);
	}

	/* Indicate we've moved all bytes */
	io->io_Actual = io->io_Length;

	error = OK;

 out:

	return(error);
}

/***********************************************************************/

/* PerformIO actually dispatches an io request.	It might be called from
   the task, or directly from BeginIO (thus on the callers's schedule) */

static const uint16 cmd_list[] = {
	NSCMD_DEVICEQUERY,
	CMD_UPDATE,
	CMD_CLEAR,
	CMD_RESET,
	CMD_ADDCHANGEINT,
	CMD_REMCHANGEINT,
	CMD_REMOVE,
	CMD_SEEK,
	CMD_MOTOR,
	CMD_CHANGENUM,
	CMD_CHANGESTATE,
	CMD_PROTSTATUS,
	CMD_GETDRIVETYPE,
	CMD_GETNUMTRACKS,
	CMD_READ,
	CMD_WRITE,
	CMD_FORMAT,
	CMD_STOP,
	CMD_START,
	CMD_FLUSH,
	0
};

void perform_io (struct IOStdReq *io, struct MyDev *md) {
	struct Unit * unit = io->io_Unit;
	struct IORequest * ior;
	LONG error = OK;

	if(INFO_LEVEL-150 >= 0)
		kprintf("%s/PerformIO -- $%lx\n",MYDEVNAME,io->io_Command);

	switch(io->io_Command)
	{
		case NSCMD_DEVICEQUERY:
			if (io->io_Length < sizeof(struct NSDeviceQueryResult)) {
				error = IOERR_BADLENGTH;
			} else {
				struct NSDeviceQueryResult *dq;
				dq = (struct NSDeviceQueryResult *)io->io_Data;
				dq->DevQueryFormat = 0;
				io->io_Actual = dq->SizeAvailable = sizeof(struct NSDeviceQueryResult);
				dq->DeviceType = NSDEVTYPE_TRACKDISK;
				dq->DeviceSubType = 0;
				dq->SupportedCommands = (uint16 *)cmd_list;
			}
			break;

		/* Update and Clear are internal buffering commands.  Update forces all
		   io out to its final resting spot, and does not return until this is
		   totally done.  Since this is automatic in a ramdisk, we simply return "Ok".

		   Clear invalidates all internal buffers.  Since this device
		   has no internal buffers, these commands do not apply. */

		case CMD_UPDATE:
		case CMD_CLEAR:
		case CMD_RESET:			/* Do nothing (nothing reasonable to do) */
		case CMD_ADDCHANGEINT:	/* Do nothing */
		case CMD_REMCHANGEINT:	/* Do nothing */
		case CMD_REMOVE:		/* Do nothing */
		case CMD_SEEK:			/* Do nothing */
		case CMD_MOTOR:			/* Do nothing */ 
		case CMD_CHANGENUM:		/* Return zero (changecount =0) */
		case CMD_CHANGESTATE:	/* Zero indicates disk inserted */
		case CMD_PROTSTATUS:	/* Zero indicates unprotected */

			io->io_Actual = 0;
			break;

		case CMD_GETDRIVETYPE:

			/* make it look like 3.5" (90mm) drive */
			io->io_Actual = DRIVE3_5;
			break;

		case CMD_GETNUMTRACKS:

			/* Number of tracks */
			io->io_Actual = RAMSIZE / BYTESPERTRACK;
			break;

		case CMD_READ:
		case CMD_WRITE:
		case CMD_FORMAT:

			error = read_write(io,md);
			break;

		case CMD_STOP:

			/* the Stop command stop all future io requests from being
			   processed until a Start command is received.	The Stop
			   command is NOT stackable: e.g. no matter how many stops
			   have been issued, it only takes one Start to restart
			   processing. */
			Disable();

			unit->unit_flags |= MDUF_STOPPED;

			Enable();

			break;

		case CMD_START:

			if(INFO_LEVEL-30 >= 0)
				kprintf("%s/Start: called\n",MYDEVNAME);

			Disable();

			if(unit->unit_flags & MDUF_STOPPED)
			{
				unit->unit_flags &= ~MDUF_STOPPED;

				Signal(unit->unit_MsgPort.mp_SigTask,(1UL << unit->unit_MsgPort.mp_SigBit));
			}

			Enable();

			break;

		case CMD_FLUSH:

			/* Flush pulls all I/O requests off the queue and sends them back.
			   We must be careful not to destroy work in progress, and also
			   that we do not let some io requests slip by. */

			if(INFO_LEVEL-30 >= 0)
				kprintf("%s/Flush: called\n",MYDEVNAME);

			Disable();

			/* Steal messages from task's port */
			while((ior = (struct IORequest *)GetMsg(&unit->unit_MsgPort)) != NULL)
			{
				ior->io_Error = IOERR_ABORTED;
				ReplyMsg((struct Message *)ior);
			}

			Enable();

			break;

		default:

			error = IOERR_NOCMD;
			break;
	}

	terminate_io(error,(struct IORequest *)io,md);
}
