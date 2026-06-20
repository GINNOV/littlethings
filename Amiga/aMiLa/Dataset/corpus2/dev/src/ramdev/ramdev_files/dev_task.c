#define __USE_INLINE__ 1
#include "ramdev.h"

void task_begin (struct MyDevUnit *mdu) {
	struct MyDev *md = mdu->mdu_Device;
	struct IORequest *io;

	if(INFO_LEVEL-35 >= 0)
		kprintf("%s/Task_Begin\n",MYDEVNAME);

	if(INTRRUPT)
	{
		BYTE sig_bit;

		/* Allocate a signal for "I/O Complete" interrupts */
		sig_bit = AllocSignal(-1);

		/* Convert bit number signal mask */
		mdu->mdu_SigMask = (1UL << sig_bit);

		/* Install the interrupt server */
		AddIntServer(INTB_PORTS,&mdu->mdu_InterruptServer);

		/* Enable interrupts on board */
		/*mdu->mdu_Base[INTCTRL2] |= (1<<INTENABLE);*/
	}

	/* Allocate a signal and make message port "live" */
	mdu->mdu_Unit.unit_MsgPort.mp_SigTask = FindTask(NULL);
	mdu->mdu_Unit.unit_MsgPort.mp_SigBit = AllocSignal(-1);
	mdu->mdu_Unit.unit_MsgPort.mp_Flags = PA_SIGNAL;

	if(INFO_LEVEL-40 >= 0)
		kprintf("%s/Signal=%ld, Unit=%lx Device=%lx Task=%lx\n",MYDEVNAME,mdu->mdu_Unit.unit_MsgPort.mp_SigBit,mdu,&mdu->mdu_Task);

	/* Automatic arbitration; this is broken by Wait() below */
	Disable();

	/* OK, kids, we are done with initialization.  We now can start the main loop
	   of the driver.  It goes like this.  Because we had the port marked
	   PA_IGNORE for a while (in init_unit()) we jump to the getmsg code on entry.
	   (The first message will probably be posted BEFORE our task gets a chance
	   to run)

	      wait for a message
	      lock the device
	      get a message.  If no message, unlock device and loop
	      dispatch the message
	      loop back to get a message */
	while(TRUE)
	{
		/* see if we are stopped or an immediate command is active */
		if(!(mdu->mdu_Unit.unit_flags & (MDUF_STOPPED|UNITF_ACTIVE)))
		{
			/* lock the device; we don't need to be woken up */
			mdu->mdu_Unit.unit_flags = (mdu->mdu_Unit.unit_flags | UNITF_ACTIVE) & ~MDUF_WAKEUP;

			Enable();

			while((io = (struct IORequest *)GetMsg(&mdu->mdu_Unit.unit_MsgPort)) != NULL)
			{
				if(INFO_LEVEL-1 >= 0)
					kprintf("%s/GotMsg\n",MYDEVNAME);

				perform_io((struct IOStdReq *)io,md);
			}

			Disable();
		}
		else
		{
			/* we want to be woken up when the caller currently using the
			   unit has done its job */
			mdu->mdu_Unit.unit_flags |= MDUF_WAKEUP;
		}

		mdu->mdu_Unit.unit_flags &= ~(UNITF_ACTIVE|UNITF_INTASK);

		if(INFO_LEVEL-75 >= 0)
			kprintf("%s/++Sleep\n",MYDEVNAME);

		Wait(1UL << mdu->mdu_Unit.unit_MsgPort.mp_SigBit);

		if(INFO_LEVEL-5 >= 0)
		{
			volatile struct CIA * ciaa = (volatile struct CIA *)0xbfe001;

			ciaa->ciapra ^= CIAF_LED; /* Blink the power LED */
		}

		if(INFO_LEVEL-75 >= 0)
			kprintf("%s/++Wakeup\n",MYDEVNAME);
	}
}

/***********************************************************************/

/* Here is a dummy interrupt handler, with some crucial components commented
   out.	If the IFD INTRRUPT is enabled, this code will cause the device to
   wait for a level two interrupt before it will process each request
   (pressing RETURN on the keyboard will do it).  This code is normally
   disabled, and must fake or omit certain operations since there  isn't
   really any hardware for this driver.	Similar code has been used
   successfully in other, "REAL" device drivers. */

ULONG interrupt (struct MyDevUnit *mdu) {
	struct MyDev * md = mdu->mdu_Device;
	ULONG was_my_interrupt = FALSE;

	/* Check if I'm interrupting; if not, return immediately */
	/*if(!(mdu->mdu_Base[INTCTRL1] & (1<<IAMPULLING)))*/
	/*	goto out;*/

	/* toggle controller's int2 bit */
	/*mdu->mdu_Base[INTACK] = 0;*/

	/* signal the task that an interrupt has occurred */
	Signal(mdu->mdu_Task,mdu->mdu_SigMask);

	/* now clear the zero condition code so that
	   the interrupt handler doesn't call the next
	   interrupt server. */
	/*was_my_interrupt = TRUE;*/

 out:

	return(was_my_interrupt);
}
