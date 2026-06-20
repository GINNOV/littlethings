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
 *      List of system drivers for Amiga OS.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include "agraphics.h"

/* Driver info arrays used for by the system driver */

extern _DRIVER_INFO _gfx_driver_list[];
extern _DRIVER_INFO _digi_driver_list[];
extern _DRIVER_INFO _midi_driver_list[];
extern _DRIVER_INFO _keyboard_driver_list[];
extern _DRIVER_INFO _mouse_driver_list[];
extern _DRIVER_INFO _joystick_driver_list[];

static int system_init()
{
	return 0;
}

static void system_exit()
{
}

static _DRIVER_INFO *get_gfx_driver_list()
{
	return(_gfx_driver_list);
}

static _DRIVER_INFO *get_digi_driver_list()
{
	return(_digi_driver_list);
}

static _DRIVER_INFO *get_midi_driver_list()
{
	return(_midi_driver_list);
}

static _DRIVER_INFO *get_keyboard_driver_list()
{
	return(_keyboard_driver_list);
}

static _DRIVER_INFO *get_mouse_driver_list()
{
	return(_mouse_driver_list);
}

static _DRIVER_INFO *get_joystick_driver_list()
{
	return(_joystick_driver_list);
}

int system_desktop_color_depth()
{
	int RetVal;
	struct Screen *Screen;

	/* Lock the Workbench screen so that we can obtain its depth.  If this fails (extremely */
	/* unlikely) then just return that it is 16 bits deep, with is an emergency failsafe depth */

	if ((Screen = LockPubScreen((STRPTR)"Workbench")) != NULL || (Screen = LockPubScreen(NULL)) != NULL)
	{
		RetVal = GetBitMapAttr(Screen->RastPort.BitMap, BMA_DEPTH);
		UnlockPubScreen(NULL, Screen);
	}
	else
	{
		RetVal = 16;
	}

	return(RetVal);
}

static void *create_mutex()
{
	struct SignalSemaphore *RetVal;

	/* Allocate some memory for a signal semaphore and initialise it */

	if ((RetVal = _AL_MALLOC(sizeof(struct SignalSemaphore))) != NULL)
	{
		InitSemaphore(RetVal);
	}

	return(RetVal);
}

static void destroy_mutex(void *aMutex)
{
	_AL_FREE(aMutex);
}

static void lock_mutex(void *aMutex)
{
	ObtainSemaphore((struct SignalSemaphore *) aMutex);
}

static void unlock_mutex(void *aMutex)
{
	ReleaseSemaphore((struct SignalSemaphore *) aMutex);
}

/* the main system driver for running under Amiga OS */

SYSTEM_DRIVER system_amiga =
{
/*                        id */	SYSTEM_AMIGA,
/*                      name */	empty_string,
/*                      desc */	empty_string,
/*                ascii_name */	"amigasystem",
/*                      init */	system_init,
/*                      exit */	system_exit,
/*       get_executable_name */	NULL,
/*             find_resource */	NULL,
/*          set_window_title */	system_set_window_title,
/* set_close_button_callback */	system_set_close_button_callback,
/*                   message */	NULL,
/*                    assert */	NULL,
/*        save_console_state */	NULL,
/*     restore_console_state */	NULL,
/*             create_bitmap */	NULL,
/*            created_bitmap */	NULL,
/*         create_sub_bitmap */	NULL,
/*        created_sub_bitmap */	NULL,
/*            destroy_bitmap */	NULL,
/*     read_hardware_palette */	NULL,
/*         set_palette_range */	NULL,
/*                get_vtable */	NULL,
/*   set_display_switch_mode */	NULL,
/*       display_switch_lock */	NULL,
/*       desktop_color_depth */	system_desktop_color_depth,
/*    get_desktop_resolution */	NULL,
/*         get_gfx_safe_mode */	NULL,
/*           yield_timeslice */	NULL,
/*				create_mutex     */  create_mutex,
/*			   destroy_mutex    */  destroy_mutex,
/*				  lock_mutex     */  lock_mutex,
/*				unlock_mutex     */  unlock_mutex,
/*               gfx_drivers */	get_gfx_driver_list,
/*              digi_drivers */	get_digi_driver_list,
/*              midi_drivers */	get_midi_driver_list,
/*          keyboard_drivers */	get_keyboard_driver_list,
/*             mouse_drivers */	get_mouse_driver_list,
/*          joystick_drivers */	get_joystick_driver_list,
/*             timer_drivers */ NULL
};

/* List of available drivers */

_DRIVER_INFO _system_driver_list[] =
{
   {  SYSTEM_AMIGA, &system_amiga, TRUE  },
   {  0,            NULL,          0     }
};
