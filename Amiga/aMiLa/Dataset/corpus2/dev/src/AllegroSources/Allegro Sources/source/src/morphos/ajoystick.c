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
 *      Amiga joystick driver.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"

#include <libraries/sensors_hid.h>
#include <proto/exec.h>
#include <proto/sensors.h>

#include "agraphics.h"

static int joystick_init()
{
	static const size_t sensortags[] = { SENSORS_Class, SensorClass_HID, TAG_DONE };
	APTR sensorlist = ObtainSensorsList(sensortags);
	APTR sensor = NULL;
	int rc = -1;

	while ((sensor = NextSensor(sensor, sensorlist, NULL)))
	{
		JOYSTICK_INFO *Joystick;
	}

	ReleaseSensorsList(sensorlist, NULL);

	return rc;
}

static void joystick_exit()
{
	JOYSTICK_INFO *Joystick = &joy[0];
}

static int joystick_poll()
{
	JOYSTICK_AXIS_INFO *Axis;
	JOYSTICK_INFO *Joystick = &joy[0];

	return 0;
}

static JOYSTICK_DRIVER joystick_amiga =
{
/*             id */ JOYSTICK_AMIGA,
/*           name */ empty_string,
/*           desc */ empty_string,
/*     ascii_name */ "Amiga joystick interface",
/*           init */ joystick_init,
/*           exit */ joystick_exit,
/*           poll */ joystick_poll,
/*      save_data */ NULL,
/*      load_data */ NULL,
/* calibrate_name */ NULL,
/*      calibrate */ NULL
};

/* List of available drivers */

_DRIVER_INFO _joystick_driver_list[] =
{
	{  JOYSTICK_AMIGA,  &joystick_amiga,  TRUE  },
	{  0,               0,                0     }
};
