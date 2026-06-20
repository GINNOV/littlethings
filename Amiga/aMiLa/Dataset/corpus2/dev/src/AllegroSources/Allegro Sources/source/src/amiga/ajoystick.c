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
 *      Amiga OS joystick driver.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"
#include <proto/exec.h>
#include <proto/amigainput.h>
#include "agraphics.h"

/* Structures for AmigaInput.library, which is not opened by libauto */

struct Library *AIN_Base;
struct AIN_IFace *IAIN;

static int *gButtonOffsets;				/* Array of offsets for reading buttons on the joystick */
static int *gAxesOffsets;				/* Array of offsets for reading the axes in which the joystick can move */
static void *gContext;					/* AmigaInput instance to use for reading joystick */
static AIN_DeviceHandle *gDevice;		/* Handle to joystick being read from */
static AIN_DeviceID gDeviceSelected;	/* ID of joystick being read from */

static const char *gButtonName = "Button A";
#define BUTTON_NAME_LENGTH 9

static BOOL EnumDevicesCallback(AIN_Device *aDevice, void *aData)
{
	BOOL RetVal;

	(void) aData;
	
	/* Assume we are not interested in this device */
	
	RetVal = FALSE;

	/* Only do anything if we have not yet selected a joystick */

	if (gDeviceSelected == 0)
	{
		/* If this device is a joystick and it has buttons and axes then we will use it.  The check */
		/* for buttons and axes is to tell the differnce between a driver that has been detected with */
		/* no joystick attached, versus a driver that has been detected *with* a joystick attached */

		if ((aDevice->Type == AINDT_JOYSTICK) && (aDevice->NumButtons > 0) && (aDevice->NumAxes > 0))
		{
			/* Indicate that we have selected this device */

			RetVal = TRUE;
			gDeviceSelected = aDevice->DeviceID;
		}
	}

	return(RetVal);
}

static int joystick_init()
{
	char *Name;
	int Index, Result, RetVal;
	JOYSTICK_INFO *Joystick;

	/* Assume failure */

	RetVal = -1;

	/* Open AmigaInput.library, so we can get input from the joystick(s) */

	if ((AIN_Base = IExec->OpenLibrary("AmigaInput.library", 52)) != NULL)
	{
		if ((IAIN = (struct AIN_IFace *) IExec->GetInterface(AIN_Base, "main", 1, NULL)) != NULL)
		{
			if ((gContext = IAIN->AIN_CreateContext(1, NULL)) != NULL)
			{
				if (IAIN->AIN_EnumDevices(gContext, EnumDevicesCallback, NULL))
				{
					if (gDeviceSelected != 0)
					{
						if ((gDevice = IAIN->AIN_ObtainDevice(gContext, gDeviceSelected)) != NULL)
						{
							if (IAIN->AIN_Query(gContext, gDeviceSelected, AINQ_NUMBUTTONS, (ULONG) NULL, &Result, sizeof(Result)))
							{
								Joystick = &joy[0];
								Joystick->num_buttons = (Result < MAX_JOYSTICK_BUTTONS) ? Result : MAX_JOYSTICK_BUTTONS;

								for (Index = 0; Index < Joystick->num_buttons; ++Index)
								{
									Joystick->button[Index].name = NULL;
								}

								if ((gButtonOffsets = _AL_MALLOC(Joystick->num_buttons * sizeof(int))) != NULL)
								{
									for (Index = 0; Index < Joystick->num_buttons; ++Index)
									{
										if (IAIN->AIN_Query(gContext, gDeviceSelected, AINQ_BUTTON_OFFSET, Index, &gButtonOffsets[Index], sizeof(int)))
										{
											if ((Joystick->button[Index].name = Name = _AL_MALLOC(BUTTON_NAME_LENGTH)) != NULL)
											{
												strcpy(Name, gButtonName);
												Name[7] += Index;
											}
											else
											{
												break;
											}
										}
										else
										{
											break;
										}
									}

									/* If all buttons were initialised successfully, query information about the axis */

									if (Index == Joystick->num_buttons)
									{
										if (IAIN->AIN_Query(gContext, gDeviceSelected, AINQ_NUMAXES, (ULONG) NULL, &Result, sizeof(Result)))
										{
											Joystick->num_sticks = (Result < MAX_JOYSTICK_AXIS) ? Result : MAX_JOYSTICK_AXIS;

											if ((gAxesOffsets = _AL_MALLOC(Joystick->num_sticks * sizeof(int))) != NULL)
											{
												for (Index = 0; Index < Joystick->num_sticks; ++Index)
												{
													if (!(IAIN->AIN_Query(gContext, gDeviceSelected, AINQ_AXIS_OFFSET, Index, &gAxesOffsets[Index], sizeof(int))))
													{
														break;
													}
												}

												if (Index == Joystick->num_sticks)
												{
													RetVal = 0;
													num_joysticks = 1;
													Joystick->flags = JOYFLAG_DIGITAL;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	// TODO: CAW - How is this working + error checking
	return(RetVal);
}

static void joystick_exit()
{
	int Index;
	JOYSTICK_INFO *Joystick;

	/* Iterate through the detected buttons and free the names of any that were allocated */

	Joystick = &joy[0];

	for (Index = 0; Index < Joystick->num_buttons; ++Index)
	{
		_AL_FREE((char *) Joystick->button[Index].name);
	}

	/* And set the number of buttons back to 0 in case the routine is re-entered */

	Joystick->num_buttons = 0;

	/* Free whatever resources were allocated */

	if (gAxesOffsets)
	{
		_AL_FREE(gAxesOffsets);
		gAxesOffsets = NULL;
	}

	if (gButtonOffsets)
	{
		_AL_FREE(gButtonOffsets);
		gButtonOffsets = NULL;
	}

	if (gDevice)
	{
		IAIN->AIN_ReleaseDevice(gContext, gDevice);
		gDevice = NULL;
	}

	if (gContext)
	{
		IAIN->AIN_DeleteContext(gContext);
		gContext = NULL;
	}

	if (IAIN)
	{
		IExec->DropInterface((struct Interface *) IAIN);
		IAIN = NULL;
	}

	/* Close the AmigaInput library, if it has been opened */

	if (AIN_Base)
	{
		IExec->CloseLibrary(AIN_Base);
		AIN_Base = NULL;
	}
}

static int joystick_poll()
{
	int Index, *Data;
	void *DataPtr;
	JOYSTICK_AXIS_INFO *Axis;
	JOYSTICK_INFO *Joystick;

	/* Only do anything if AmigaInput initialised successfully */

	if (num_joysticks > 0)
	{
		/* Ask AmigaInput for the current state of the joystick buttons and axes */

		if (IAIN->AIN_ReadDevice(gContext, gDevice, &DataPtr))
		{
			Data = DataPtr;
			Joystick = &joy[0];

			/* Iterate the buttons and copy their state into Allegro's joystick structure */

			for (Index = 0; Index < Joystick->num_buttons; ++Index)
			{
				Joystick->button[Index].b = Data[gButtonOffsets[Index]];
			}

			/* Iterate the axes and copy their state into Allegro's joystick structure, */
			/* converting them from an analogue representation of the digital axis to a */
			/* "real" 1 or 0 representation */

			for (Index = 0; Index < Joystick->num_sticks; ++Index)
			{
				Axis = &Joystick->stick[0].axis[Index];
				Axis->d1 = (Data[gAxesOffsets[Index]] < 0);
				Axis->d2 = (Data[gAxesOffsets[Index]] > 0);
			}
		}
	}

	return(0);
}

static JOYSTICK_DRIVER joystick_amiga =
{
/*             id */ JOYSTICK_AMIGA,
/*           name */ empty_string,
/*           desc */ empty_string,
/*     ascii_name */ "Amiga Digital USB joystick",
/*           init */ joystick_init,
/*           exit */ joystick_exit,
/*           poll */ joystick_poll,
/*      save_data */ NULL,
/*      load_data */ NULL,
/* calibrate_name */ NULL,
/*      calibtate */ NULL
};

/* List of available drivers */

_DRIVER_INFO _joystick_driver_list[] =
{
	{  JOYSTICK_AMIGA,  &joystick_amiga,  TRUE  },
	{  0,               0,                0     }
};
