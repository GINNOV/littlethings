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

	{ 71, KEY_INSERT, 0 },
	{ 72, KEY_PGUP, 0 },
	{ 73, KEY_PGDN, 0 },
	{ 75, KEY_F11, 0 },
	{ 80, KEY_F1, 0 },
	{ 81, KEY_F2, 0 },
	{ 82, KEY_F3, 0 },
	{ 83, KEY_F4, 0 },
	{ 84, KEY_F5, 0 },
	{ 85, KEY_F6, 0 },
	{ 86, KEY_F7, 0 },
	{ 87, KEY_F8, 0 },
	{ 88, KEY_F9, 0 },
	{ 89, KEY_F10, 0 },
	{ 95, KEY_SCRLOCK, 0 },
	{ 96, KEY_LSHIFT, 0 },
	{ 97, KEY_RSHIFT, 0 },
	{ 98, KEY_CAPSLOCK, 0},
	{ 99, KEY_LCONTROL, 0 },
	{ 100, KEY_ALT, 0 },
	{ 101, KEY_ALTGR, 0 },
	{ 102, KEY_LWIN, 0 },
	{ 103, KEY_RWIN, 0 },
	{ 107, KEY_MENU, 0 },
	{ 109, KEY_PRTSCR, 0 },
	{ 110, KEY_PAUSE, 0 },
	{ 111, KEY_F12, 0 },
	{ 112, KEY_HOME, 0 },
	{ 113, KEY_END, 0 },
	{ 121, KEY_NUMLOCK, 0 }
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
