#ifndef GUARD_OF_CURSOR_H
#define GUARD_OF_CURSOR_H

#include <ace/types.h>
#include <ace/utils/extview.h>

/**
 * Creates cursor on supplied view.
 * @param pView        Parent view.
 * @param fubSpriteIdx Index of sprite to be used. Must not be disabled
 *                     by cop*DisableSprites().
 * @param szPath       Path to 2bpp interleaved bitmap used as cursor.
 *                     Bitmap has to have two unused lines on top & bottom
 *                     of cursor image.
 * @param uwRawCopPos  If copperlist is in raw mode, specify position
 *                     for 2 MOVEs. Should be as close to 0,0 as possible.
 * @todo Passing hotspot coord as params.
 * @todo Support for 4bpp sprites.
 */
void cursorCreate(
	tView *pView,
	FUBYTE fubSpriteIdx,
	char *szPath,
	UWORD uwRawCopPos
);

/**
 * Frees stuff allocated by copCreate().
 * This function doesn't remove created copBlock as it will be destroyed along
 * with copperlist.
 */
void cursorDestroy(void);

/**
 * Updates cursor position.
 */
void cursorUpdate(void);

#endif // GUARD_OF_GAMESTATES_GAME_CURSOR_H
