/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 ****************************************************************************
 *
 * Absolute_Joystick.c
 *
 * Gameport device absolute joystick example
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <exec/exec.h>
#include <dos/dos.h>
#include <devices/gameport.h>
#include <devices/inputevent.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define JOY_X_DELTA (1)
#define JOY_Y_DELTA (1)
#define TIMEOUT_SECONDS (10)

extern struct ExecBase *SysBase;

/*-----------------------------------------------------------------------
** Routine to print out some information for the user.
*/
VOID printInstructions(VOID)
{
printf("\n >>> gameport.device Absolute Joystick Demo <<<\n\n");

if (SysBase->VBlankFrequency==60)
    printf(" Running on NTSC system (60 Hz).\n");
else if (SysBase->VBlankFrequency==50)
    printf(" Running on PAL system (50 Hz).\n");

printf( " Attach joystick to rear connector (A3000) and (A1000).\n"
        " Attach joystick to right connector (A2000).\n"
        " Attach joystick to left connector (A500).\n"
	" Then move joystick and click its button(s).\n\n"
	" To exit program press and release fire button 3 consecutive times. \n"
	" The program also exits if no activity occurs for 1 minute.\n\n");
}


/*-----------------------------------------------------------------------
** print out information on the event received.
*/
BOOL check_move(struct InputEvent *game_event)
{
WORD xmove, ymove;
BOOL timeout=FALSE;

xmove = game_event->ie_X;
ymove = game_event->ie_Y;

if (xmove == 1)
    {
    if (ymove == 1) printf("RIGHT DOWN\n");
    else if (ymove == 0) printf("RIGHT\n");
    else if (ymove ==-1) printf("RIGHT UP\n");
    else printf("UNKNOWN Y\n");
    }
else if (xmove ==-1)
    {
    if (ymove == 1) printf("LEFT DOWN\n");
    else if (ymove == 0) printf("LEFT\n");
    else if (ymove ==-1) printf("LEFT UP\n");
    else printf("UNKNOWN Y\n");
    }
else if (xmove == 0)
    {
    if (ymove == 1) printf("DOWN\n");
    /* Note that 0,0 can be a timeout, or a direction release. */
    else if (ymove == 0)
	{
	if (game_event->ie_TimeStamp.tv_secs >=
			(UWORD)(SysBase->VBlankFrequency) * TIMEOUT_SECONDS)
            {
            /* Under 1.3 (V34) and earlier versions of the Amiga OS, the   */
            /* ie_TimeStamp.tvsecs field used in the if() statement above  */
            /* is not correctly filled in.  Therefore, this program cannot */
            /* tell the difference between a release event and a timeout   */
            /* under 1.3 (release events will be reported as timeouts)     */
	    printf("TIMEOUT\n");
	    timeout=TRUE;
	    }
	else printf("RELEASE\n");
	}
    else if (ymove ==-1) printf("UP\n");
    else printf("UNKNOWN Y\n");
    }
else
    {
    printf("UNKNOWN X ");
    if (ymove == 1) printf("unknown action\n");
    else if (ymove == 0) printf("unknown action\n");
    else if (ymove ==-1) printf("unknown action\n");
    else printf("UNKNOWN Y\n");
    }

return(timeout);

}

/*-----------------------------------------------------------------------
** send a request to the gameport to read an event.
*/
VOID send_read_request( struct InputEvent *game_event,
			struct IOStdReq *game_io_msg)
{
game_io_msg->io_Command = GPD_READEVENT;
game_io_msg->io_Flags	= 0;
game_io_msg->io_Data	= (APTR)game_event;
game_io_msg->io_Length	= sizeof(struct InputEvent);
SendIO(game_io_msg);  /* Asynchronous - message will return later */
}

/*-----------------------------------------------------------------------
** simple loop to process gameport events.
*/
VOID processEvents( struct IOStdReq *game_io_msg,
		    struct MsgPort  *game_msg_port)
{
BOOL timeout;
SHORT timeouts;
SHORT button_count;
BOOL  not_finished;
struct InputEvent game_event;	/* where input event will be stored */

/* From now on, just read input events into the event buffer,
** one at a time.  READEVENT waits for the preset conditions.
*/
timeouts = 0;
button_count = 0;
not_finished = TRUE;

while ((timeouts < 6) && (not_finished))
    {
    /* Send the read request */
    send_read_request(&game_event,game_io_msg);

    /* Wait for joystick action */
    Wait(1L << game_msg_port->mp_SigBit);
    while (NULL != GetMsg(game_msg_port))
	{
	timeout=FALSE;
	switch(game_event.ie_Code)
	    {
	    case IECODE_LBUTTON:
		printf(" FIRE BUTTON PRESSED \n");
		break;

	    case (IECODE_LBUTTON | IECODE_UP_PREFIX):
		printf(" FIRE BUTTON RELEASED \n");
		if (3 == ++button_count)
		    not_finished = FALSE;
		break;

	    case IECODE_RBUTTON:
		printf(" ALT BUTTON PRESSED \n");
		button_count = 0;
		break;

	    case (IECODE_RBUTTON | IECODE_UP_PREFIX):
		printf(" ALT BUTTON RELEASED \n");
		button_count = 0;
		break;

	    case IECODE_NOBUTTON:
		/* Check for change in position */
		timeout = check_move(&game_event);
		button_count = 0;
		break;

	    default:
		break;
	    }

	if (timeout)
	    timeouts++;
	else
	    timeouts=0;
	}
    }
}

/*-----------------------------------------------------------------------
** allocate the controller if it is available.
** you allocate the controller by setting its type to something
** other than GPCT_NOCONTROLLER.  Before you allocate the thing
** you need to check if anyone else is using it (it is free if
** it is set to GPCT_NOCONTROLLER).
*/
BOOL set_controller_type(BYTE type, struct IOStdReq *game_io_msg)
{
BOOL success = FALSE;
BYTE controller_type = 0;

/* begin critical section
** we need to be sure that between the time we check that the controller
** is available and the time we allocate it, no one else steals it.
*/
Forbid();

game_io_msg->io_Command = GPD_ASKCTYPE;	   /* inquire current status */
game_io_msg->io_Flags	= IOF_QUICK;
game_io_msg->io_Data	= (APTR)&controller_type; /* put answer in here */
game_io_msg->io_Length	= 1;
DoIO(game_io_msg);

/* No one is using this device unit, let's claim it */
if (controller_type == GPCT_NOCONTROLLER)
    {
    game_io_msg->io_Command = GPD_SETCTYPE;
    game_io_msg->io_Flags   = IOF_QUICK;
    game_io_msg->io_Data    = (APTR)&type;
    game_io_msg->io_Length  = 1;
    DoIO( game_io_msg);
    success = TRUE;
    }

Permit(); /* critical section end */
return(success);
}

/*-----------------------------------------------------------------------
** tell the gameport when to trigger.
*/
VOID set_trigger_conditions(struct GamePortTrigger *gpt,
			    struct IOStdReq *game_io_msg)
{
/* trigger on all joystick key transitions */
gpt->gpt_Keys	= GPTF_UPKEYS | GPTF_DOWNKEYS;
gpt->gpt_XDelta = JOY_X_DELTA;
gpt->gpt_YDelta = JOY_Y_DELTA;
/* timeout trigger every TIMEOUT_SECONDS second(s) */
gpt->gpt_Timeout = (UWORD)(SysBase->VBlankFrequency) * TIMEOUT_SECONDS;

game_io_msg->io_Command = GPD_SETTRIGGER;
game_io_msg->io_Flags	= IOF_QUICK;
game_io_msg->io_Data	= (APTR)gpt;
game_io_msg->io_Length	= (LONG)sizeof(struct GamePortTrigger);
DoIO(game_io_msg);
}

/*-----------------------------------------------------------------------
** clear the buffer.  do this before you begin to be sure you
** start in a known state.
*/
VOID flush_buffer(struct IOStdReq *game_io_msg)
{
game_io_msg->io_Command = CMD_CLEAR;
game_io_msg->io_Flags	= IOF_QUICK;
game_io_msg->io_Data	= NULL;
game_io_msg->io_Length	= 0;
DoIO(game_io_msg);
}

/*-----------------------------------------------------------------------
** free the unit by setting its type back to GPCT_NOCONTROLLER.
*/
VOID free_gp_unit(struct IOStdReq *game_io_msg)
{
BYTE type = GPCT_NOCONTROLLER;

game_io_msg->io_Command = GPD_SETCTYPE;
game_io_msg->io_Flags	= IOF_QUICK;
game_io_msg->io_Data	= (APTR)&type;
game_io_msg->io_Length	= 1;
DoIO(game_io_msg);
}

/*-----------------------------------------------------------------------
** allocate everything and go.	On failure, free any resources that
** have been allocated.	 this program fails quietly--no error messages.
*/
VOID main(int argc,char **argv)
{
struct GamePortTrigger	 joytrigger;
struct IOStdReq		*game_io_msg;
struct MsgPort		*game_msg_port;

/* Create port for gameport device communications */
if (game_msg_port = CreatePort("RKM_game_port",0))
    {
    /* Create message block for device IO */
    if (game_io_msg = (struct IOStdReq *)
                      CreateExtIO(game_msg_port,sizeof(*game_io_msg)))
	{
	game_io_msg->io_Message.mn_Node.ln_Type = NT_UNKNOWN;

	/* Open the right/back (unit 1, number 2) gameport.device unit */
	if (!OpenDevice("gameport.device",1,game_io_msg,0))
	    {
	    /* Set controller type to joystick */
	    if (set_controller_type(GPCT_ABSJOYSTICK,game_io_msg))
		{
		/* Specify the trigger conditions */
		set_trigger_conditions(&joytrigger,game_io_msg);

		printInstructions();

		/* Clear device buffer to start from a known state.
		** There might still be events left
		*/
		flush_buffer(game_io_msg);

		processEvents(game_io_msg,game_msg_port);

		/* Free gameport unit so other applications can use it ! */
		free_gp_unit(game_io_msg);
		}
	    CloseDevice(game_io_msg);
	    }
	DeleteExtIO(game_io_msg);
	}
    DeletePort(game_msg_port);
    }
}


