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
#include <proto/intuition.h>
#include <proto/picasso96api.h>
#include "agraphics.h"

/* Lovely version structure.  Only Amiga makes it possible! */

static const struct Resident g_oROMTag __attribute__((used)) =
{
	RTC_MATCHWORD,
	(struct Resident *) &g_oROMTag,
	(struct Resident *) (&g_oROMTag + 1),
	RTF_AUTOINIT,
	0,
	NT_LIBRARY,
	0,
	"Allegro",
	/* Ensure HTML, al_get_sobj_version() and WA_Title in agraphics.c are changed too */
	"\0$VER: Allegro 1.1 (13.06.2009)\r\n",
	NULL
};

/* Driver info arrays used for by the system driver */

extern _DRIVER_INFO _gfx_driver_list[];
extern _DRIVER_INFO _digi_driver_list[];
extern _DRIVER_INFO _midi_driver_list[];
extern _DRIVER_INFO _keyboard_driver_list[];
extern _DRIVER_INFO _mouse_driver_list[];
extern _DRIVER_INFO _joystick_driver_list[];

unsigned int al_get_sobj_version()
{
	return((1 << 16) | 1);
}

static int system_init()
{
	int RetVal;
	struct Library *ElfBase;

	RetVal = 1;

	/* Allegro for OS4 now only works on OS 4.1 and above, thanks to a bug in elf.library that means */
	/* it screws up shared objects compiled with the 53.x SDK.  It would have been nice to continue to */
	/* support all versions of OS4 but I guess it was inevitable that this would happen, once more */
	/* advanced features began to be added to Allegro */

	if ((ElfBase = IExec->OpenLibrary("elf.library", 50)) != NULL)
	{
		if ((ElfBase->lib_Version >= 53) && (ElfBase->lib_Revision >= 2))
		{
			RetVal = 0;
		}

		IExec->CloseLibrary(ElfBase);
	}

	/* If the version of OS4 we are running on is too old, display an error and return failure */

	if (RetVal)
	{
		printf("OS version is too old.  Allegro requires at least OS 4.1 with elf.library version 53.2\n");
	}

	return(RetVal);
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

	if ((Screen = IIntuition->LockPubScreen(NULL)) != NULL)
	{
		RetVal = IP96->p96GetBitMapAttr(Screen->RastPort.BitMap, P96BMA_BITSPERPIXEL);
		IIntuition->UnlockPubScreen(NULL, Screen);
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
		IExec->InitSemaphore(RetVal);
	}

	return(RetVal);
}

static void destroy_mutex(void *aMutex)
{
	_AL_FREE(aMutex);
}

static void lock_mutex(void *aMutex)
{
	IExec->ObtainSemaphore((struct SignalSemaphore *) aMutex);
}

static void unlock_mutex(void *aMutex)
{
	IExec->ReleaseSemaphore((struct SignalSemaphore *) aMutex);
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
/*				create_mutex */ create_mutex,
/*			   destroy_mutex */ destroy_mutex,
/*				  lock_mutex */ lock_mutex,
/*				unlock_mutex */ unlock_mutex,
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
