/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS specific threading system for use by Amiga only code.
 *      The code in thread.c is for the use of Allegro itself.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include <proto/dos.h>
#include <proto/exec.h>
#include <string.h>
#include "athread.h"

// TODO: CAW - Figure out why this stuff is required for downward compatibility and comment it
struct Library *DOSBase;
struct DOSIFace *IDOS;

#define OPEN_LIBRARY(LibraryName, LibraryBase, Interface, InterfaceType, Version) \
	if ((LibraryBase = IExec->OpenLibrary(LibraryName, Version)) != NULL) \
	{ \
		Interface = (InterfaceType *) IExec->GetInterface(LibraryBase, "main", 1, NULL ); \
	} \
	\
	if (!(Interface)) \
	{ \
		if (IDOS) \
		{ \
			IDOS->Printf("Error: Unable to open library %s version %d or above\n", LibraryName, Version); \
		} \
	}

static LONG thread_func(STRPTR aArgs, LONG aArgsLength)
{
	struct AmiThread *AmiThread;
	struct Process *Process;

	(void) aArgs;
	(void) aArgsLength;

	/* Get a ptr to the AmiThread structure for use throughout this routine and the user threadfunc */

	Process = (struct Process *) IExec->FindTask(NULL);
	AmiThread = (struct AmiThread *) Process->pr_Task.tc_UserData;

	/* Set our thread to a very high task priority so that it responds immediately */

	IExec->SetTaskPri((struct Task *) &AmiThread->at_ThreadProcess->pr_Task, 15);

	/* Allocate a signal bit that can be used to shut down the thread */

	if ((AmiThread->at_ThreadSignalBit = IExec->AllocSignal(-1)) != -1)
	{
		/* Create a message port and IO request for use by timer.device */

		if ((AmiThread->at_TimerMsgPort = IExec->CreateMsgPort()) != NULL)
		{
			if ((AmiThread->at_TimeRequest = (struct TimeRequest *) IExec->CreateIORequest(AmiThread->at_TimerMsgPort,
				sizeof(struct TimeRequest))) != NULL)
			{
				/* Open timer.device for use */

				if ((AmiThread->at_TimerDevice = IExec->OpenDevice(TIMERNAME, 0, &AmiThread->at_TimeRequest->Request, 0)) == 0)
				{
					/* Call the user's initialisation function so that it can allocated any */
					/* required resources */

					AmiThread->at_StartedOk = AmiThread->at_InitFunc(AmiThread);

					/* Continue the thread only if the user's initialisation function completed successfully */

					if (AmiThread->at_StartedOk)
					{
						/* Signal that we started successfully */

						IExec->Signal(&AmiThread->at_ParentProcess->pr_Task, (1 << AmiThread->at_ParentSignalBit));

						/* Call the user threadfunc, which will handle input and return when it is complete */

						AmiThread->at_UserFunc(AmiThread);

						/* Abort any leftover timer requests and close the timer.device */

						IExec->AbortIO(&AmiThread->at_TimeRequest->Request);
						IExec->CloseDevice(&AmiThread->at_TimeRequest->Request);
					}
				}
			}
		}
	}

	/* Either initialisation of the required resources has failed or the thread is shutting down. */
	/* Either way, free whatever resources have been allocated */

	if (AmiThread->at_TimeRequest)
	{
		IExec->DeleteIORequest(&AmiThread->at_TimeRequest->Request);
		AmiThread->at_TimeRequest = NULL;
	}

	if (AmiThread->at_TimerMsgPort)
	{
		IExec->DeleteMsgPort(AmiThread->at_TimerMsgPort);
		AmiThread->at_TimerMsgPort = NULL;
	}

	if (AmiThread->at_ThreadSignalBit != -1)
	{
		IExec->FreeSignal(AmiThread->at_ThreadSignalBit);
		AmiThread->at_ThreadSignalBit = -1;
	}

	/* Depending on whether the thread was successfully initialised, this code will serve to */
	/* either signal to the main thread that startup failed, or that shutdown is complete */

	IExec->Signal(&AmiThread->at_ParentProcess->pr_Task, (1 << AmiThread->at_ParentSignalBit));

	return(0);
}

int amithread_create(struct AmiThread *aAmiThread, int (*aInitFunc)(struct AmiThread *aAmiThread),
	void (*aUserFunc)(struct AmiThread *aAmiThread), void *aUserData)
{
	int RetVal;
	BPTR OutputHandle;

	/* Assume failure */

	RetVal = 0;
	OutputHandle = 0;

	/* Reset all fields of the AmiThread structure and save the pointer to the client data */
	/* for use by the thread */

	aAmiThread->at_ParentSignalBit = aAmiThread->at_ThreadSignalBit = aAmiThread->at_AltParentSignalBit = -1;
	aAmiThread->at_InitFunc = aInitFunc;
	aAmiThread->at_UserData = aUserData;
	aAmiThread->at_UserFunc = aUserFunc;

	/* Save a ptr to this process so the thread can signal us */

	aAmiThread->at_ParentProcess = (struct Process *) IExec->FindTask(NULL);

	/* Allocate a signal bit that the thread can use for signalling the main process */

	if ((aAmiThread->at_ParentSignalBit = IExec->AllocSignal(-1)) != -1)
	{
		// TODO: CAW
		if (!(IDOS))
		{
			OPEN_LIBRARY("dos.library", DOSBase, IDOS, struct DOSIFace, 52);
		}

		/* Create the thread and wait for it to signal that it has completed its startup procedure */

		if ((OutputHandle = IDOS->Open("CONSOLE:", MODE_NEWFILE)) != 0)
		{
			aAmiThread->at_ThreadProcess = IDOS->CreateNewProcTags(NP_Entry, thread_func, NP_UserData, aAmiThread,
				NP_Output, OutputHandle, NP_Name, "Allegro Helper Thread", TAG_DONE);

			if (aAmiThread->at_ThreadProcess)
			{
				IExec->Wait(1 << aAmiThread->at_ParentSignalBit);

				/* And signal success or failure */

				RetVal = aAmiThread->at_StartedOk;
			}
		}

		/* If the thread could not be created or it could not be initialised, clean up after ourselves */

		if (!(RetVal))
		{
			IExec->FreeSignal(aAmiThread->at_ParentSignalBit);
			aAmiThread->at_ParentSignalBit = -1;
		}
	}

	return(RetVal);
}

void amithread_destroy(struct AmiThread *aAmiThread)
{
	/* Signal to the threat to shutdown and wait for it to signal that it has done so */

	amithread_send_message(aAmiThread, 0);

	/* And free the signal bit */

	IExec->FreeSignal(aAmiThread->at_ParentSignalBit);
	aAmiThread->at_ParentSignalBit = -1;
}

int amithread_add_sender(struct AmiThread *aAmiThread)
{
	ASSERT(aAmiThread->at_AltParentProcess == NULL);

	/* Allocate a signal bit that the thread can use for signalling the alternate process */

	aAmiThread->at_AltParentSignalBit = IExec->AllocSignal(-1);
	aAmiThread->at_AltParentProcess = (struct Process *) IExec->FindTask(NULL);

	return(aAmiThread->at_AltParentSignalBit != -1);
}

void amithread_remove_sender(struct AmiThread *aAmiThread)
{
	if (aAmiThread->at_AltParentSignalBit != -1)
	{
		IExec->FreeSignal(aAmiThread->at_AltParentSignalBit);
		aAmiThread->at_AltParentSignalBit = -1;
	}
}

void amithread_request_timeout(struct AmiThread *aAmiThread, unsigned int aTimeout)
{
	aAmiThread->at_TimeRequest->Request.io_Command = TR_ADDREQUEST;
	aAmiThread->at_TimeRequest->Time.Seconds = (aTimeout / 1000000);
	aAmiThread->at_TimeRequest->Time.Microseconds = (aTimeout % 1000000);
	IExec->SendIO(&aAmiThread->at_TimeRequest->Request);
}

void amithread_send_message(struct AmiThread *aAmiThread, int aMessage)
{
	BYTE OldParentSignalBit;
	struct Process *OldParentProcess;

	/* See if we are being called from a thread other than the one that created the thread to which the */
	/* message is to be sent.  This is unpleasent but unfortunately this does sometimes happen so it */
	/* needs to be handled */

	if (aAmiThread->at_ParentProcess != (struct Process *) IExec->FindTask(NULL))
	{
		/* Save the details of the main process */

		OldParentProcess = aAmiThread->at_ParentProcess;
		OldParentSignalBit = aAmiThread->at_ParentSignalBit;

		/* If the calling thread is internal code from another thread then it will have setup */
		/* itself as a caller in advance and the process ptr and signal bit will be allocated */

		if (aAmiThread->at_AltParentProcess)
		{
			/* Make the alternate process the main one */

			aAmiThread->at_ParentProcess = aAmiThread->at_AltParentProcess;
			aAmiThread->at_ParentSignalBit = aAmiThread->at_AltParentSignalBit;

			/* Send the message with the newly setup process and signal bit, and wait for a reponse */

			amithread_send_message(aAmiThread, aMessage);
		}

		/* Otherwise its third party code starting threads when it shouldn't really be.  Handle this */
		/* by allocating a signal and using that temporarily. This is not such as good situation as */
		/* this can fail and amithread_send_message() can *not* fail so there is not much we can do in */
		/* this situation */
		
		else
		{
			/* Make the current process the main one */

			aAmiThread->at_ParentProcess = (struct Process *) IExec->FindTask(NULL);
			aAmiThread->at_ParentSignalBit = IExec->AllocSignal(-1);

			// TODO:CAW - What if this fails?  Can this be cached to reduce the likelyhood of this?
			if (aAmiThread->at_ParentSignalBit != -1)
			{
				/* Send the message with the newly setup process and signal bit, and wait for a reponse */

				amithread_send_message(aAmiThread, aMessage);

				/* And free the temporary signal bit */

				IExec->FreeSignal(aAmiThread->at_ParentSignalBit);
			}
		}

		/* And restore the main process's details */

		aAmiThread->at_ParentProcess = OldParentProcess;
		aAmiThread->at_ParentSignalBit = OldParentSignalBit;
	}
	else
	{
		/* Save the message to be sent, send it and wait for a response */

		aAmiThread->at_Message = aMessage;
		IExec->Signal(&aAmiThread->at_ThreadProcess->pr_Task, (1 << aAmiThread->at_ThreadSignalBit));
		IExec->Wait(1 << aAmiThread->at_ParentSignalBit);
	}
}

void amithread_reply_message(struct AmiThread *aAmiThread)
{
	IExec->Signal(&aAmiThread->at_ParentProcess->pr_Task, (1 << aAmiThread->at_ParentSignalBit));
}
