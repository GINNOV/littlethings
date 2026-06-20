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
 *      Amiga OS key mapping table.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#ifndef AKEYMAPPINGS_H
#define AKEYMAPPINGS_H

#include <devices/rawkeycodes.h>
#include <intuition/intuition.h>

/* Each keyboard character is represented by an instance of this structure */

struct KeyMapping
{
	int		km_AmigaKey;	/* Amiga keycode (usually just ASCII) */
	int		km_AllegroKey;	/* Allegro key onto which it maps */
	int		km_ASCIIKey;	/* ASCII key value */
};

/* Amiga raw keys that can be mapped onto corresponding Allegro keys */

static const struct KeyMapping gRawKeyMappings[] =
{
	{ CURSORLEFT, KEY_LEFT, 0 },
	{ CURSORRIGHT, KEY_RIGHT, 0 },
	{ CURSORUP, KEY_UP, 0 },
	{ CURSORDOWN, KEY_DOWN, 0 },

	{ RAWKEY_INSERT, KEY_INSERT, 0 },
	{ RAWKEY_PAGEUP, KEY_PGUP, 0 },
	{ RAWKEY_PAGEDOWN, KEY_PGDN, 0 },
	{ RAWKEY_F11, KEY_F11, 0 },
	{ RAWKEY_F1, KEY_F1, 0 },
	{ RAWKEY_F2, KEY_F2, 0 },
	{ RAWKEY_F3, KEY_F3, 0 },
	{ RAWKEY_F4, KEY_F4, 0 },
	{ RAWKEY_F5, KEY_F5, 0 },
	{ RAWKEY_F6, KEY_F6, 0 },
	{ RAWKEY_F7, KEY_F7, 0 },
	{ RAWKEY_F8, KEY_F8, 0 },
	{ RAWKEY_F9, KEY_F9, 0 },
	{ RAWKEY_F10, KEY_F10, 0 },
	{ RAWKEY_SCRLOCK, KEY_SCRLOCK, 0 },
	{ RAWKEY_LSHIFT, KEY_LSHIFT, 0 },
	{ RAWKEY_RSHIFT, KEY_RSHIFT, 0 },
	{ RAWKEY_CAPSLOCK, KEY_CAPSLOCK, 0},
	{ RAWKEY_LCONTROL, KEY_LCONTROL, 0 },
	{ RAWKEY_LALT, KEY_ALT, 0 },
	{ RAWKEY_RALT, KEY_ALTGR, 0 },
	{ RAWKEY_LAMIGA, KEY_LWIN, 0 },
	{ RAWKEY_RAMIGA, KEY_RWIN, 0 },
	{ RAWKEY_HELP, KEY_MENU, 0 },
	{ RAWKEY_PRTSCREEN, KEY_PRTSCR, 0 },
	{ RAWKEY_PAUSE, KEY_PAUSE, 0 },
	{ RAWKEY_F12, KEY_F12, 0 },
	{ RAWKEY_HOME, KEY_HOME, 0 },
	{ RAWKEY_END, KEY_END, 0 },
	{ RAWKEY_NUMLOCK, KEY_NUMLOCK, 0 }
};

/* Amiga vanilla keys that can be mapped onto corresponding Allegro keys */

static const struct KeyMapping gVanillaKeyMappings[] =
{
	/* ASCII characters and numbers */

	{ 'a', KEY_A, 'a' },
	{ 'b', KEY_B, 'b' },
	{ 'c', KEY_C, 'c' },
	{ 'd', KEY_D, 'd' },
	{ 'e', KEY_E, 'e' },
	{ 'f', KEY_F, 'f' },
	{ 'g', KEY_G, 'g' },
	{ 'h', KEY_H, 'h' },
	{ 'i', KEY_I, 'i' },
	{ 'j', KEY_J, 'j' },
	{ 'k', KEY_K, 'k' },
	{ 'l', KEY_L, 'l' },
	{ 'm', KEY_M, 'm' },
	{ 'n', KEY_N, 'n' },
	{ 'o', KEY_O, 'o' },
	{ 'p', KEY_P, 'p' },
	{ 'q', KEY_Q, 'q' },
	{ 'r', KEY_R, 'r' },
	{ 's', KEY_S, 's' },
	{ 't', KEY_T, 't' },
	{ 'u', KEY_U, 'u' },
	{ 'v', KEY_V, 'v' },
	{ 'w', KEY_W, 'w' },
	{ 'x', KEY_X, 'x' },
	{ 'y', KEY_Y, 'y' },
	{ 'z', KEY_Z, 'z' },
	{ '0', KEY_0, '0' },
	{ '1', KEY_1, '1' },
	{ '2', KEY_2, '2' },
	{ '3', KEY_3, '3' },
	{ '4', KEY_4, '4' },
	{ '5', KEY_5, '5' },
	{ '6', KEY_6, '6' },
	{ '7', KEY_7, '7' },
	{ '8', KEY_8, '8' },
	{ '9', KEY_9, '9' },

	/* Miscellaneous non alphanumeric keys */

	{ 39, KEY_QUOTE, '\'' },
	{ 42, KEY_ASTERISK, '*' },
	{ 43, KEY_PLUS_PAD, '+' },
	{ 44, KEY_COMMA, ',' },
	{ 45, KEY_MINUS_PAD, '-' },
	{ 46, KEY_STOP, '.'},
	{ 47, KEY_SLASH_PAD, '/' },
	{ 59, KEY_SEMICOLON, ';' },
	{ 61, KEY_EQUALS, '='},
	{ 91, KEY_OPENBRACE, '[' },
	{ 92, KEY_BACKSLASH, '\\'},
	{ 93, KEY_CLOSEBRACE, ']'},
	{ 96, KEY_TILDE, '`'},

	/* And now the non ASCII keys */

	{ 8, KEY_BACKSPACE, 8 },
	{ 9, KEY_TAB, '\t' },
	{ 13, KEY_ENTER, 13 },
	{ 27, KEY_ESC, 27 },
	{ 32, KEY_SPACE, 32 },
	{ 127, KEY_DEL, 127 }
};

#endif /* ! AKEYMAPPINGS_H */
