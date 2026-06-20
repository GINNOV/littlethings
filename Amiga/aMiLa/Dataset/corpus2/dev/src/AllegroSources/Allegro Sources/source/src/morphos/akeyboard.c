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
 *      Amiga OS keyboard driver.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"

#include <dos/dosextens.h>
#include <exec/execbase.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/keymap.h>
#include <string.h>

#include "akeymappings.h"
#include "amouse.h"

#define KB_MODIFIERS ( KB_SHIFT_FLAG | KB_CTRL_FLAG | KB_ALT_FLAG | KB_LWIN_FLAG | KB_RWIN_FLAG | KB_MENU_FLAG )
#define KB_LED_FLAGS ( KB_SCROLOCK_FLAG | KB_CAPSLOCK_FLAG )

/* Structures for keymap.library */

static BYTE gInputSignalBit = -1;		/* Signal used by wait_for_input() */
static int gSignalInput;				/* 1 for keyboard_handle_key() to signal gInputSignalBit */
static int gInitialised;				/* 1 if init_keyboard() has been called successfully */
static struct Process *gParentProcess;	/* Ptr to Amiga OS process of the main process */

/* Table used to convert Allegro format scancodes into key_shifts flag bits */

static unsigned short modifier_table[KEY_MAX - KEY_MODIFIERS] =
{
	KB_SHIFT_FLAG, KB_SHIFT_FLAG, KB_CTRL_FLAG, KB_CTRL_FLAG, KB_ALT_FLAG, KB_ALT_FLAG,
	KB_LWIN_FLAG, KB_RWIN_FLAG, KB_MENU_FLAG, KB_SCROLOCK_FLAG, KB_NUMLOCK_FLAG, KB_CAPSLOCK_FLAG
};

static int convert_key(const struct KeyMapping *aKeyMappings, int aNumKeyMappings, int aAmigaKey, int *aAllegroKey,
	int *aASCIIKey)
{
	int	Index, RetVal;

	/* Assume failure */

	RetVal = 0;

	/* Scan through the table of key mappings and see if there is an Allegro key */
	/* corresponding to the Amiga key passed in */

	for (Index = 0; Index < aNumKeyMappings; ++Index)
	{
		if (aKeyMappings[Index].km_AmigaKey == aAmigaKey)
		{
			RetVal = 1;

			/* Found it!  Get a copy of it and break out of the loop */

			*aAllegroKey = aKeyMappings[Index].km_AllegroKey;
			*aASCIIKey = aKeyMappings[Index].km_ASCIIKey;

			break;
		}
	}

	return(RetVal);
}

static void update_shifts(int allegro_key, int keypressed)
{
	int key_flag;

	/* If one of the shift, ctrl etc. keys has been pressed or released, handle it here */

	if (allegro_key >= KEY_MODIFIERS)
	{
		/* Convert the Allegro scancode into a bit representing the key pressed or released */

		key_flag = modifier_table[allegro_key - KEY_MODIFIERS];

		if (keypressed)
		{
			/* If the key was one of the shift, ctrl etc. keys then update its state in Allegro's */
			/* internal variable representing this */

			if (key_flag & KB_MODIFIERS)
			{
				_key_shifts |= key_flag;
			}

			/* Otherwise do some special handling for the LED keys that don't generate key up events */
			/* but have a toggled state */

			else if ((key_flag & KB_LED_FLAGS) && (key_led_flag))
			{
				_key_shifts ^= key_flag;
			}
		}
		else
		{
			/* If the key was one of the shift, ctrl etc. keys then update its state in Allegro's */
			/* internal variable representing this */

			if (key_flag & KB_MODIFIERS)
			{
				_key_shifts &= ~key_flag;
			}
		}
	}
}

void keyboard_handle_key(struct IntuiMessage *aIntuiMessage)
{
	TEXT Buffer[20];
	int AllegroKey, ASCIIKey, KeyCode, Ok, Size;
	const struct KeyMapping *KeyMappings;
	struct InputEvent InputEvent;

	/* This function may get called before init_keyboard() has been called.  In this case, */
	/* just return without doing anything */

	switch (aIntuiMessage->Code)
	{
		case RAWKEY_NM_WHEEL_UP:
			mouse_handle_wheel(1);
			return;

		case RAWKEY_NM_WHEEL_DOWN:
			mouse_handle_wheel(-1);
			return;
	}

	if (gInitialised)
	{
		/* Determine the keycode by discarding the key up/down bit */

		KeyCode = (aIntuiMessage->Code & ~IECODE_UP_PREFIX);

		/* Map the raw keycode onto a vanilla keycode */

		InputEvent.ie_Class = IECLASS_RAWKEY;
		InputEvent.ie_SubClass = 0;
		InputEvent.ie_Code = KeyCode;
		InputEvent.ie_Qualifier = 0;
		InputEvent.ie_EventAddress = (APTR) *((ULONG *) aIntuiMessage->IAddress);

		/* Perform the actual mapping and decide whether to scan the raw key or vanilla key mapping */
		/* arrays, depending on the result */

		if (MapRawKey(&InputEvent, Buffer, sizeof(Buffer), 0) == 1)
		{
			KeyCode = Buffer[0];
			KeyMappings = gVanillaKeyMappings;
			Size = (sizeof(gVanillaKeyMappings) / sizeof(struct KeyMapping));
		}
		else
		{
			KeyMappings = gRawKeyMappings;
			Size = (sizeof(gRawKeyMappings) / sizeof(struct KeyMapping));
		}

		/* See if there is an Allegro key matching the Amiga key passed in */

		if (convert_key(KeyMappings, Size, KeyCode, &AllegroKey, &ASCIIKey))
		{
			/* We have a recognised key.  Depending on whether it is a key down or */
			/* a key up it needs to be treated differently */

			Ok = 1;

			if (!(aIntuiMessage->Code & IECODE_UP_PREFIX))
			{
				/* Update the state of the shift, ctrl etc. keys */

				update_shifts(AllegroKey, 1);

				/* Do some special handling for the ALT key, for which Allegro wants us to return 0 */

				if (_key_shifts & KB_ALT_FLAG)
				{
					ASCIIKey = 0;
				}

				/* Otherwise if the key pressed was a letter, see if it needs to be converted to a */
				/* special control combination or upper case */

				else if ((AllegroKey >= KEY_A) && (AllegroKey <= KEY_Z))
				{
					/* If the control key is pressed then we must return the position of the letter */
					/* in the alphabet rather than its ASCII code */

					if (_key_shifts & KB_CTRL_FLAG)
					{
						ASCIIKey = (ASCIIKey - 'a' + 1);
					}
					else
					{
						/* If shift was pressed then convert it to upper case */

						if (_key_shifts & KB_SHIFT_FLAG)
						{
							ASCIIKey -= 0x20;
						}

						/* Then if caps lock was pressed then toggle its state.  This is PC style and */
						/* Amiga OS does not normally do this, but some games might depend on it */

						if (_key_shifts & KB_CAPSLOCK_FLAG)
						{
							ASCIIKey ^= 0x20;
						}
					}
				}

				/* This is a key down event.  Only send it if it is not a repeat as key */
				/* repeats are handled internally by Allegro */

				if (!(aIntuiMessage->Qualifier & IEQUALIFIER_REPEAT))
				{
					_handle_key_press(ASCIIKey, AllegroKey);
				}
			}
			else
			{
				update_shifts(AllegroKey, 0);
				_handle_key_release(AllegroKey);
			}

			/* If this is a keydown event and the main thread is waiting for a signal that */
			/* a key has been pressed, send that signal now */

			if (!(aIntuiMessage->Code & IECODE_UP_PREFIX))
			{
				/* This is a key up event.  Only send it if it is not a repeat as key */
				/* repeats are handled internally by Allegro */

				if (!(aIntuiMessage->Qualifier & IEQUALIFIER_REPEAT))
				{
					/* If the wait_for_key() routine has requested notification, clear the */
					/* notification flag and wait signal the notification */

					if (gSignalInput)
					{
						gSignalInput = 0;
						Signal(&gParentProcess->pr_Task, (1 << gInputSignalBit));
					}
				}
			}
		}
	}
}

static int init_keyboard()
{
	int	RetVal;

	/* Assume failure */

	RetVal = 1;

	/* Allocate a signal bit that can be used to indicate that a key has been pressed */

	if ((gInputSignalBit = AllocSignal(-1)) != -1)
	{
		/* Save a ptr to this process so the input thread can signal us */

		gParentProcess = (struct Process *)SysBase->ThisTask;
		gInitialised = 1;
		RetVal = 0;
	}

	return(RetVal);
}

static void exit_keyboard()
{
	/* Free whatever resources were allocated */

	FreeSignal(gInputSignalBit);
	gInputSignalBit = -1;
}

static void wait_for_input()
{
	/* Request that the input handler signal that a key has been pressed and wait for that keypress */

	gSignalInput = 1;
	Wait(1 << gInputSignalBit);
}

KEYBOARD_DRIVER keyboard_amiga =
{
/*                      id */ KEYBOARD_AMIGA,
/*                    name */ empty_string,
/*                    desc */ empty_string,
/*              ascii_name */ "amigakeyboard",
/*			    autorepeat */ FALSE,
/*                    init */ init_keyboard,
/*                    exit */ exit_keyboard,
/*                    poll */ NULL,
/*                set_leds */ NULL,
/*                set_rate */ NULL,
/*          wait_for_input */ wait_for_input,
/*  stop_waiting_for_input */ NULL,
/*       scancode_to_ascii */ NULL,
/*        scancode_to_name */ NULL
};

/* List of available drivers */

_DRIVER_INFO _keyboard_driver_list[] =
{
	{  KEYBOARD_AMIGA, &keyboard_amiga, TRUE },
	{  0,              NULL,            0    }
};
