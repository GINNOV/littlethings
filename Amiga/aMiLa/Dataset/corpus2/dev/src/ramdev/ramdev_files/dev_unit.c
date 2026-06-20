#define __USE_INLINE__ 1
#include "ramdev.h"

LONG InitUnit (ULONG unit_number, struct MyDev *md) {
	struct MyDevUnit *mdu;
	LONG error;

	if(INFO_LEVEL-30 >= 0)
		kprintf("%s/InitUnit: called\n",MYDEVNAME);

	/* allocate unit memory */
	mdu = AllocMem(sizeof(*mdu), MEMF_SHARED|MEMF_CLEAR);
	if(mdu == NULL)
	{
		error = IOERR_OPENFAIL;
		goto out;
	}

	if(INFO_LEVEL-30 >= 0)
		kprintf("%s/InitUnit, unit= %lx, task=%lx\n",MYDEVNAME,mdu,&mdu->mdu_Task);

	/* IMPORTANT: Mark offset zero as ASCII "BAD " */
	strcpy(mdu->mdu_RAM,"BAD ");

	/* Initialize unit number and device pointer */
	mdu->mdu_UnitNum = unit_number;
	mdu->mdu_Device = md;

	/* start up the unit task.  We do a trick here --
	   we set his message port to PA_IGNORE until the
	   new task has a change to set it up.
	   We cannot go to sleep here: it would be very nasty
	   if someone else tried to open the unit
	   (exec's OpenDevice has done a Forbid() for us --
	   we depend on this to become single threaded). */

	mdu->mdu_Unit.unit_MsgPort.mp_Flags = PA_IGNORE;
	mdu->mdu_Unit.unit_MsgPort.mp_SigTask = NULL;

	/* initialize the unit's message port's list */
	NewList(&mdu->mdu_Unit.unit_MsgPort.mp_MsgList);

	if(INTRRUPT)
	{
		/* Pass unit addr to interrupt server */
		mdu->mdu_InterruptServer.is_Node.ln_Pri		= 4; /* Int priority 4 */
		mdu->mdu_InterruptServer.is_Node.ln_Name	= md->md_Device.dd_Library.lib_Node.ln_Name;
		mdu->mdu_InterruptServer.is_Data			= mdu;
		mdu->mdu_InterruptServer.is_Code			= (VOID (*)())interrupt;
	}

	if(INFO_LEVEL-30 >= 0)
		kprintf("%s/About to add task\n",MYDEVNAME);

	/* Startup the task */
	mdu->mdu_Task = CreateTaskTags(MYDEVNAME, MYPROCPRI, (APTR)task_begin, MYPROCSTACKSIZE,
		AT_Param1,	mdu,
		TAG_END);
	if (mdu->mdu_Task == NULL)
	{
		FreeMem(mdu,sizeof(*mdu));

		error = IOERR_OPENFAIL;
		goto out;
	}

	/* mark us as ready to go */
	md->md_Units[unit_number] = mdu;

	/* Success */
	error = OK;

	if(INFO_LEVEL-30 >= 0)
		kprintf("%s/InitUnit: ok\n",MYDEVNAME);

 out:

	return(error);
}

void ExpungeUnit (struct MyDevUnit * mdu,struct MyDev * md) {
	ULONG unit_number = mdu->mdu_UnitNum;

	if(INFO_LEVEL-10 >= 0)
		kprintf("%s/ExpungeUnit: called\n",MYDEVNAME);

	/* If you can expunge your unit, and each unit has it's own interrupts,
	   you must remember to remove its interrupt server */
	if(INTRRUPT)
		RemIntServer(INTB_PORTS,&mdu->mdu_InterruptServer);

	/* get rid of the unit's task.  We know this is safe
	   because the unit has an open count of zero, so it
	   is 'guaranteed' not in use. */
	DeleteTask(mdu->mdu_Task);

	/* free the unit structure. */
	FreeMem(mdu,sizeof(*mdu));

	/* clear out the unit vector in the device */
	md->md_Units[unit_number] = NULL;
}
