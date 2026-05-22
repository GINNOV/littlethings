/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: mice.c,v 1.2.1.3 1994/12/09 05:29:56 jason Exp $

$Log: mice.c,v $
 * Revision 1.2.1.3  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.2  1994/11/16  06:25:25  jason
 * check for NOT_EXTERN
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:17  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

struct MsgPort *GameMP;
struct IOStdReq *GameIO;
struct InputEvent *GameEV;
struct IntuiMessage *GameMS;
BYTE GameEventBuffer[sizeof(struct InputEvent)];

struct GamePortTrigger GameTR=
	{
	GPTF_DOWNKEYS|GPTF_UPKEYS,		/* transition trigger */
	300,							/* seconds * 60Hz (time per auto event) */
	1,1								/* delta mouse trigger */
	};


/******************************************************************************
long	start_gameport(void)

	returns TRUE if successful

******************************************************************************/
/*PROTOTYPE*/
long start_gameport(void)
	{
	GameEV=(struct InputEvent *)GameEventBuffer;

	if((GameMP=CreatePort("RKM_game_port",0)))
/* 	if((GameMP=CreatePort(NULL,0))) */
		{
		if(GameIO=(struct IOStdReq *)CreateExtIO(GameMP,sizeof(struct IOStdReq)))
/* 		if(GameIO=(struct IOStdReq *)CreateStdIO(GameMP)) */
			{
			if(!OpenDevice("gameport.device",1,(struct IORequest *)GameIO,0))
				{
				if(set_controller_type((BYTE)GPCT_MOUSE))
					{
					set_trigger_conditions();

					flush_buffer();

					printf("gameport started\n");
					return TRUE;
					}
				else
					GL_error("can't set game port");

				CloseDevice((struct IORequest *)GameIO);
				}
			else
				GL_error("can't open game port");

			DeleteExtIO((struct IORequest *)GameIO);
			}
		else
			GL_error("can't create game IO");

		DeletePort(GameMP);
		}
	else
		GL_error("can't create game port");

	return FALSE;
	}


/******************************************************************************
void	stop_gameport(void)

******************************************************************************/
/*PROTOTYPE*/
void stop_gameport(void)
	{
	printf("stop gameport\n");

	free_gameport();

	if(!(CheckIO((struct IORequest *)GameIO)))
		AbortIO((struct IORequest *)GameIO);	/* ask device to abort request, if pending */

	WaitIO((struct IORequest *)GameIO);			/* wait for abort, then clean up */
	CloseDevice((struct IORequest *)GameIO);
	DeleteExtIO((struct IORequest *)GameIO);
	DeletePort(GameMP);

	printf(" stopped\n");
	}


/******************************************************************************
void	send_read_request(void)

******************************************************************************/
/*PROTOTYPE*/
void send_read_request(void)
	{
	GameIO->io_Command=GPD_READEVENT;
	GameIO->io_Flags=0;
	GameIO->io_Length=sizeof(struct InputEvent);
	GameIO->io_Data=(APTR)&GameEventBuffer;
	SendIO((struct IORequest *)GameIO);
	}


/******************************************************************************
void	set_trigger_conditions(void)

******************************************************************************/
/*PROTOTYPE*/
void set_trigger_conditions(void)
	{
	GameIO->io_Command=GPD_SETTRIGGER;
	GameIO->io_Flags=IOF_QUICK;
	GameIO->io_Data=(APTR)&GameTR;
	GameIO->io_Length=sizeof(struct GamePortTrigger);
	DoIO((struct IORequest *)GameIO);
	}


/******************************************************************************
long	set_controller_type(BYTE type)

******************************************************************************/
/*PROTOTYPE*/
long set_controller_type(BYTE type)
	{
	long success=FALSE;
	BYTE controller_type=0;

	Forbid();								/* start critical section */

	GameIO->io_Command=GPD_ASKCTYPE;		/* inquire current status */
	GameIO->io_Length=1;
	GameIO->io_Flags=IOF_QUICK;
	GameIO->io_Data=(APTR)&controller_type;	/* put answer here */
	DoIO((struct IORequest *)GameIO);

	if(controller_type==GPCT_NOCONTROLLER)	/* if not in use */
		{
		GameIO->io_Command=GPD_SETCTYPE;
		GameIO->io_Length=1;
		GameIO->io_Flags=IOF_QUICK;
		GameIO->io_Data=(APTR)&type;
		DoIO((struct IORequest *)GameIO);

		success=TRUE;
		}

	Permit();								/* end critcal section */

	return success;
	}


/******************************************************************************
void	free_gameport(void)

******************************************************************************/
/*PROTOTYPE*/
void free_gameport(void)
	{
	BYTE type=GPCT_NOCONTROLLER;

	GameIO->io_Command=GPD_SETCTYPE;
	GameIO->io_Flags=IOF_QUICK;
	GameIO->io_Length=1;
	GameIO->io_Data=(APTR)&type;
	DoIO((struct IORequest *)GameIO);
	}


/******************************************************************************
void	flush_buffer(void)

******************************************************************************/
/*PROTOTYPE*/
void flush_buffer(void)
	{
	GameIO->io_Command=CMD_CLEAR;
	GameIO->io_Flags=IOF_QUICK;
	GameIO->io_Data=NULL;
	GameIO->io_Length=0;
	DoIO((struct IORequest *)GameIO);
	}


/******************************************************************************
long	gameport_event(long *device,short *state,short *dx,short *dy)

	only affected values are changed

	returns code (FALSE if no message)

******************************************************************************/
/*PROTOTYPE*/
long gameport_event(long *device,short *state,short *dx,short *dy)
	{
	long code;

	*device=NULL;
	*state=0;
	*dx=0;
	*dy=0;

	GameMS=(struct IntuiMessage *)GetMsg(GameMP);		/* try first without asking */

	if(GameMS==NULL)
		{
		send_read_request();							/* send request */

		GameMS=(struct IntuiMessage *)GetMsg(GameMP);	/* try again */

		if(GameMS==NULL)								/* still no message */
			{
/* 			printf("gameport_event() no message\n"); */
			return FALSE;								/* give up for now */
			}
		}

	code=GameEV->ie_Code;
	switch(code)
		{
		case IECODE_LBUTTON:
			printf("gameport_event() left down\n");
			*device=BPAD1;
			*state=TRUE;
			break;
		case IECODE_LBUTTON+IECODE_UP_PREFIX:
			printf("gameport_event() left up\n");
			*device=BPAD1;
			*state=FALSE;
			break;
		case IECODE_MBUTTON:
			printf("gameport_event() middle down\n");
			*device=BPAD2;
			*state=TRUE;
			break;
		case IECODE_MBUTTON+IECODE_UP_PREFIX:
			printf("gameport_event() middle up\n");
			*device=BPAD2;
			*state=FALSE;
			break;
		case IECODE_RBUTTON:
			printf("gameport_event() right down\n");
			*device=BPAD3;
			*state=TRUE;
			break;
		case IECODE_RBUTTON+IECODE_UP_PREFIX:
			printf("gameport_event() right up\n");
			*device=BPAD3;
			*state=FALSE;
			break;
		case IECODE_NOBUTTON:
/* 			printf("gameport_event() no button\n"); */
			break;
		default:
			printf("gameport_event() default\n");
			return FALSE;
			break;
		}

	*dx=  GameEV->ie_X;
	*dy= -GameEV->ie_Y;

/* 	printf("gameport_event() code=%d %2d,%2d\n",code,GameEV->ie_X,GameEV->ie_Y); */

/* 	ReplyMsg((struct Message *)GameMS); */

	return code;
	}
