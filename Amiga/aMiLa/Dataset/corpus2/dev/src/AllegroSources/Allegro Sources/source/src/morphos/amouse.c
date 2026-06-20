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
 *      Amiga OS mouse module.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"
#include <devices/input.h>
#include <intuition/intuition.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <string.h>
#include "agraphics.h"
#include "amouse.h"

/* States in which the hardware mouse pointer can be */

enum EHardwareMouseMode
{
	EHMM_Invisible,	/* Invisible */
	EHMM_Default,	/* Using default imagery */
	EHMM_Custom		/* Using custom imagery */
};

static int gInitialised;			/* 1 if mouse_init() has been called successfully */
static int gX;						/* Current X position */
static int gY;						/* Current Y position */
static int gZ;						/* Current wheel mouse value */
static int gMickeyX;				/* X value last time get_mickeys() was called */
static int gMickeyY;				/* Y value last time get_mickeys() was called */
static int gMinX;					/* Minimum X position allowed */
static int gMaxX;					/* Maximum X position allowed */
static int gMinY;					/* Minimum Y position allowed */
static int gMaxY;					/* Maximum Y position allowed */
static enum EHardwareMouseMode gHardwareMouseMode;	/* What the hardware mouse pointer should display */
static struct IOStdReq *gStdReq;	/* IORequest for sending mouse events to input.device */
static struct MsgPort *gMsgPort;	/* MsgPort to use with gStdReq */

/* Classic hardware style data for an invisible mouse pointer */

static unsigned short gMouseImage[] = { 0x0000, 0x0000 };

static unsigned int get_mouse_num_buttons();

static void clip_mouse(int aX, int aY)
{
	/* Ensure that the X and Y positions are within the allowed range area and, if so, save */
	/* them in Allegro's global variables that may be accessed by any Allegro program.  Also */
	/* save them in our own variables which are private */

	if ((aX >= gMinX) && (aX <= gMaxX))
	{
		gX = aX;
	}

	if ((aY >= gMinY) && (aY <= gMaxY))
	{
		gY = aY;
	}
}

static int set_mouse_xy_internal(int aX, int aY, int aMovePointer)
{
	int OldX, OldY, RetVal;
	struct IEPointerPixel PointerPixel;
	struct InputEvent InputEvent;
	struct Screen *Screen;

	/* Get the old X & Y positions so that we don't tell Intuition not to move the mouse */
	/* if it's not required */

	OldX = gX;
	OldY = gY;

	/* Validate the X & Y positions and save them */

	clip_mouse(aX, aY);

	/* If the position has changed, let Intuition know */

	if ((gX != OldX) || (gY != OldY))
	{
		RetVal = 1;

		/* If it has been requested to move the Amiga hardware mouse then send a request */
		/* to the input system */

		if (aMovePointer)
		{
			gStdReq->io_Command = IND_WRITEEVENT;
			gStdReq->io_Length = sizeof(InputEvent);
			gStdReq->io_Data = &InputEvent;

			InputEvent.ie_NextEvent = NULL;
			InputEvent.ie_Class = IECLASS_NEWPOINTERPOS;
			InputEvent.ie_SubClass = IESUBCLASS_PIXEL;
			InputEvent.ie_Code = 0;
			InputEvent.ie_Qualifier = 0;
			InputEvent.ie_EventAddress = &PointerPixel;

			/* Attempt to lock the current screen in preparation for sending the event.  If this */
			/* fails, don't worry handling any errors as its unlikely and isn't critical anyway */

			if ((Screen = LockPubScreen(NULL)) != NULL)
			{
				/* Now send the request */

				PointerPixel.iepp_Screen = Screen;
				PointerPixel.iepp_Position.X = (gMainWindow->LeftEdge + gMainWindow->BorderLeft + gX);
				PointerPixel.iepp_Position.Y = (gMainWindow->TopEdge + gMainWindow->BorderTop + gY);
				DoIO((struct IORequest *) gStdReq);

				/* And unlock the screen we just locked */

				UnlockPubScreen(NULL, Screen);
			}
		}

		/* And update the hardware mouse imagery */

		mouse_set_hardware_imagery(aX, aY);
	}
	else
	{
		RetVal = 0;
	}

	return(RetVal);
}

void mouse_handle_buttons(int aCode)
{
	int Button, ButtonBit;

	/* This function may get called before mouse_init() has been called.  In this case, just */
	/* return without doing anything */

	if (gInitialised)
	{
		/* And out the bit representing the up/down state */

		Button = (aCode & ~IECODE_UP_PREFIX);

		/* Map the Intuition mouse code onto the Allegro mouse code */

		if (Button == IECODE_LBUTTON)
		{
			Button = 1;
		}
		else if (Button == IECODE_RBUTTON)
		{
			Button = 2;
		}
		else if (Button == IECODE_MBUTTON)
		{
			Button = 3;
		}
		else
		{
			Button = -1;
		}

		/* If a matching Allegro mouse code was found, send an event to the comouse thread */

		if (Button != -1)
		{
			/* Update the bits representing the mouse buttons directly, so determne which bit matches */
			/* the button that has just been pressed or released */

			ButtonBit = (1 << (Button - 1));

			/* And set or clear that bit, depending on whether the mouse button was just pressed or */
			/* released */

			if (!(aCode & IECODE_UP_PREFIX))
			{
				_mouse_b |= ButtonBit;
			}
			else
			{
				_mouse_b &= ~ButtonBit;
			}

			/* Now get Allegro to process the input */

			_handle_mouse_input();
		}
	}
}

void mouse_handle_move(int aX, int aY)
{
	int X, Y, OldX, OldY;

	/* This function may get called before mouse_init() has been called.  In this case, just */
	/* return without doing anything */

	if (gInitialised)
	{
		/* Get the old X & Y positions for use in calculating mouse mickeys */

		OldX = gX;
		OldY = gY;

		/* Calculate the current X & Y position of the mouse, taking into account the size of the */
		/* top and bottom borders, which the Allegro program isn't interested in */

		X = (aX - gMainWindow->BorderLeft);
		Y = (aY - gMainWindow->BorderTop);

		/* Set the new X & Y positions and if they are valid, send an event to the mouse thread */

		if (set_mouse_xy_internal(X, Y, 0))
		{
			/* Moving the mouse also resets the mouse wheel position */

			gZ = 0;

			/* Update the variables representing the mouse position directly */

			_mouse_x = gX;
			_mouse_y = gY;
			_mouse_z = gZ;

			/* Now get Allegro to process the input */

			_handle_mouse_input();
		}
	}
}

void mouse_handle_wheel(int aZ)
{
	/* This function may get called before mouse_init() has been called.  In this case, just */
	/* return without doing anything */

	if (gInitialised)
	{
		/* Update the mouse wheel value and send an event to the comouse thread */

		gZ += aZ;

		/* Update the variables representing the mouse position directly */

		_mouse_x = gX;
		_mouse_y = gY;
		_mouse_z = gZ;

		/* Now get Allegro to process the input */

		_handle_mouse_input();
	}
}

void mouse_set_hardware_imagery(int aX, int aY)
{
	/* If we are using a hardware mouse, check to see if it is within the Allegro window and */
	/* if so, assign the custom imagery to it.  Otherwise set it back to its default */

	if (gHardwareMouseMode != EHMM_Default)
	{
		if ((aX >= 0) && (aY >= 0) && (aX < gMainWindow->Width) && (aY < gMainWindow->Height))
		{
			SetPointer(gMainWindow, gMouseImage, 0, 0, 0, 0);
		}
		else
		{
			ClearPointer(gMainWindow);
		}
	}
}

static int mouse_init()
{
	int	RetVal;

	/* Assume failure */

	RetVal = 0;

	/* Create a message port and IO request for use by input.device */

	gMsgPort = CreateMsgPort();

		if ((gStdReq = (struct IOStdReq *) CreateIORequest(gMsgPort, sizeof(struct IOStdReq))) != NULL)
		{
			/* Open timer.device for use */

			if (OpenDevice("input.device", 0, (struct IORequest *) gStdReq, 0) == 0)
			{
				gInitialised = 1;
				RetVal = get_mouse_num_buttons();

				/* Just display the standard imagery with the hardware mouse pointer */

				gHardwareMouseMode = EHMM_Default;
			}
			else
			{
				DeleteIORequest((struct IORequest *) gStdReq);
				DeleteMsgPort(gMsgPort);
			}
		}
		else
		{
			DeleteMsgPort(gMsgPort);
		}

	return(RetVal);
}

static void mouse_exit()
{
	CloseDevice((struct IORequest *) gStdReq);
	DeleteIORequest((struct IORequest *) gStdReq);
	DeleteMsgPort(gMsgPort);
}

static void mouse_enable_hardware_cursor(int aMode)
{
	/* Only actually enable or disable the mouse pointer if the main window is open */

	if (gMainWindow)
	{
		/* Depending on whether or not Allegro wishes to enable the hardware mouse pointer, */
		/* either show it (with ClearPointer()) or hide it by giving it an empty sprite to display */

		if (aMode)
		{
			ClearPointer(gMainWindow);
		}
		else
		{
			SetPointer(gMainWindow, gMouseImage, 0, 0, 0, 0);
		}
	}

	/* And indicate what type of imagery is used for the hardware mouse pointer */

	if (aMode)
	{
		gHardwareMouseMode = EHMM_Default;
	}
	else
	{
		gHardwareMouseMode = EHMM_Invisible;
	}
}

static unsigned int get_mouse_num_buttons()
{
	/* I can't find any way of querying the number of buttons present, so just assume there */
	/* three and hope for the best :-( */

	return(3);
}

static int set_mouse_xy(int aX, int aY)
{
	int	RetVal;

	/* Call the internal version of set_mouse_xy(), telling it to move the mouse pointer */
	/* as well as update the position.  If the new X & Y positions are valid, send an */
	/* event to the comouse thread */

	if ((RetVal = set_mouse_xy_internal(aX, aY, 1)) != 0)
	{
		/* Moving the mouse also resets the mouse wheel position and the mouse mickeys */

		gZ = 0;
		gMickeyX = gX;
		gMickeyY = gY;

		/* Update the variables representing the mouse position directly */

		_mouse_x = gX;
		_mouse_y = gY;
		_mouse_z = gZ;

		/* Now get Allegro to process the input */

		_handle_mouse_input();
	}

	return(RetVal);
}

static int mouse_set_mouse_range(int aMinX, int aMinY, int aMaxX, int aMaxY)
{
	gMinX = aMinX;
	gMinY = aMinY;
	gMaxX = aMaxX;
	gMaxY = aMaxY;

	return(1);
}

static void get_mickeys(int *aMickeyX, int *aMickeyY)
{
	/* Calculate the X and Y mickeys as being the delta of the mouse's current position and */
	/* the position the last time this function was called */

	*aMickeyX = (gX - gMickeyX);
	*aMickeyY = (gY - gMickeyY);

	/* Reset the X and Y mickeys for the next time this function is called */

	gMickeyX = gX;
	gMickeyY = gY;
}

static MOUSE_DRIVER mouse_amiga =
{
/*                     id */ MOUSE_AMIGA,
/*                   name */ empty_string,
/*                   desc */ empty_string,
/*             ascii_name */ "amigamouse",
/*                   init */ mouse_init,
/*                   exit */ mouse_exit,
/*                   poll */ NULL,
/*             timer_poll */ NULL,
/*               position */ (void (*)(int, int)) set_mouse_xy,
/*              set_range */ (void (*)(int, int, int, int)) mouse_set_mouse_range,
/*              set_speed */ NULL,
/*            get_mickeys */ get_mickeys,
/*           analyse_data */ NULL,
/* enable_hardware_cursor */ mouse_enable_hardware_cursor,
/*   select_system_cursor */ NULL
};

/* List of available drivers */

_DRIVER_INFO _mouse_driver_list[] =
{
	{  MOUSE_AMIGA, &mouse_amiga, TRUE  },
	{  0,           NULL,         0     }
};
