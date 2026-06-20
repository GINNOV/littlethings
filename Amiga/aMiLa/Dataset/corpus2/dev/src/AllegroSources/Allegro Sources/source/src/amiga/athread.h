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

#ifndef AMITHREAD_H
#define AMITHREAD_H

struct AmiThread
{
	struct Process		*at_ThreadProcess;		/* Ptr to Amiga OS process of the thread */
	struct Process		*at_ParentProcess;		/* Ptr to Amiga OS process of the thread's parent */
	struct Process		*at_AltParentProcess;	/* Ptr to Amiga OS process of the alternate thread */
												/* that can send messages to the thread */
	void				*at_UserData;			/* Client specified data to be passed to the thread */
	int					at_Message;				/* Message being sent via at_ThreadSignalBit */
	int					at_StartedOk;			/* 1 if thread started successfully */
	BYTE				at_ThreadSignalBit;		/* Main -> thread signalling */
	BYTE				at_ParentSignalBit;		/* Thread -> main signalling */
	BYTE				at_AltParentSignalBit;	/* Alternate thread -> main signalling */
	BYTE				at_TimerDevice;			/* Instance of timer.device to use for timer events */
	struct MsgPort		*at_TimerMsgPort;		/* MsgPort to wait for timer events on */
	struct TimeRequest	*at_TimeRequest;		/* IORequest to use for timer events */
	int					(*at_InitFunc)(struct AmiThread *aAmiThread);	/* User thread initialisation function */
	void				(*at_UserFunc)(struct AmiThread *aAmiThread);	/* User thread function */
};

int	amithread_create(struct AmiThread *aAmiThread, int (*aInitFunc)(struct AmiThread *aAmiThread),
	void (*aUserFunc)(struct AmiThread *aAmiThread), void *aUserData);

void amithread_destroy(struct AmiThread *aAmiThread);

int amithread_add_sender(struct AmiThread *aAmiThread);

void amithread_remove_sender(struct AmiThread *aAmiThread);

void amithread_request_timeout(struct AmiThread *aAmiThread, unsigned int aTimeout);

void amithread_send_message(struct AmiThread *aAmiThread, int aMessage);

void amithread_reply_message(struct AmiThread *aAmiThread);

#endif /* ! AMITHREAD_H */
