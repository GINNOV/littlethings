#define __USE_INLINE__ 1
#include "ramdev.h"

/***********************************************************************/

/* here begin the device functions */

/***********************************************************************/

/* AbortIO() is a REQUEST to "hurry up" processing of an IORequest.
   If the IORequest was already complete, nothing happens (if an IORequest
   is quick or ln_Type=NT_REPLYMSG, the IORequest is complete).
   The message must be replied with ReplyMsg(), as normal. */

LONG libAbortIO (struct DeviceManagerInterface *Self,
	struct IORequest *which_io)
{
	struct MyDev *md = (struct MyDev *)Self->Data.LibBase;
	struct MyDevUnit * mdu = (struct MyDevUnit *)which_io->io_Unit;
	struct IORequest * io;
	LONG error = OK;

	/* Check if the request is still in the queue, waiting to be
	   processed; this *must* be done under Disable() conditions
	   because interrupt code can end up attaching I/O requests
	   to the unit port */
	Disable();

	for(io = (struct IORequest *)mdu->mdu_Unit.unit_MsgPort.mp_MsgList.lh_Head ;
	    io->io_Message.mn_Node.ln_Succ != NULL ;
	    io = (struct IORequest *)io->io_Message.mn_Node.ln_Succ)
	{
		if(io == which_io)
		{
			/* remove it from the queue and tag it as aborted */
			Remove((struct Node *)io);

			error = io->io_Error = IOERR_ABORTED;

			/* reply the message, as usual */
			ReplyMsg((struct Message *)io);
			break;
		}
	}

	Enable();

	return(error);
}

/***********************************************************************/

/* dev_begin_iO() starts all incoming io.  The IO is either queued up for the
   unit task or processed immediately.

   dev_begin_io() often is given the responsibility of making devices single
   threaded... so two tasks sending commands at the same time don't cause
   a problem.  Once this has been done, the command is dispatched via
   perform_io().

   There are many ways to do the threading.  This example uses the
   UNITF_ACTIVE flag.  Be sure this is good enough for your device before
   using!  Any method is ok.  If immediate access can not be obtained, the
   request is queued for later processing.

   Some IO requests do not need single threading, these can be performed
   immediately.

   IMPORTANT:
     The exec WaitIO() function uses the IORequest node type (ln_Type)
     as a flag.	If set to NT_MESSAGE, it assumes the request is
     still pending and will wait.  If set to NT_REPLYMSG, it assumes the
     request is finished.  It's the responsibility of the device driver
     to set the node type to NT_MESSAGE before returning to the user. */

void libBeginIO (struct DeviceManagerInterface *Self,
	struct IORequest *io)
{
	struct MyDev *md = (struct MyDev *)Self->Data.LibBase;

	if(INFO_LEVEL-1 >= 0)
	{
		volatile struct CIA * ciaa = (volatile struct CIA *)0xbfe001;

		ciaa->ciapra ^= CIAF_LED; /* Blink the power LED */
	}

	if(INFO_LEVEL-3 >= 0)
		kprintf("%s/BeginIO  -- $%lx\n",MYDEVNAME,io->io_Command);

	/* So WaitIO() is guaranteed to work */
	io->io_Message.mn_Node.ln_Type = NT_MESSAGE;

	/* Is this an immediate command? */
	if (is_immediate_command(io->io_Command))
	{
		perform_io((struct IOStdReq *)io,md);
	}
	else
	{
		/* Is this a command which can never be processed
		   immediately? */
		if((INTRRUPT) && is_never_immediate_command(io->io_Command))
		{
			queue_io(io,md);
		}
		else
		{
			struct Unit * unit = io->io_Unit;

			/* Needed for safely checking/changing the unit flags; this
			   should be replaced by a Forbid() if no interrupts are
			   involved */
			Disable();

			/* see if the unit is STOPPED.  If so, queue the msg. */
			if(unit->unit_flags & MDUF_STOPPED)
			{
				Enable();

				queue_io(io,md);
			}
			else
			{
				/* This is not an immediate command.  See if the device is
				   busy.  If the device is not, do the command on the
				   user schedule.  Else fire up the task.
				   This type of arbitration is not really needed for a ram
				   disk, but is essential for a device to reliably work
				   with shared hardware

				   REMEMBER: Never Wait() on the user's schedule in BeginIO()!
				   The only exception is when the user has indicated it is ok
				   by setting the "quick" bit.  Since this device copies from
				   ram that never needs to be waited for, this subtlely may not
				   be clear. */
				if(unit->unit_flags & UNITF_ACTIVE)
				{
					Enable();

					queue_io(io,md);
				}
				else
				{
					unit->unit_flags |= UNITF_ACTIVE;

					Enable();

					perform_io((struct IOStdReq *)io,md);

					Disable();

					/* Check if the task still has work to be done;
					   could be that we flagged the unit to be active
					   just at the time when the task was about to
					   pick up another request. In that case, the
					   task may have to wait for the next request
					   to arrive before it resumes processing the
					   queue. */
					if(unit->unit_flags & MDUF_WAKEUP)
					{
						/* Wake up the task so that it resumes processing
						   of the I/O request queue (if it's not doing
						   doing that already). */
						Signal(unit->unit_MsgPort.mp_SigTask,(1UL << unit->unit_MsgPort.mp_SigBit));
					}

					Enable();
				}
			}
		}
	}

	if(INFO_LEVEL-200 >= 0)
		kprintf("%s/BeginIO_End\n",MYDEVNAME);
}
