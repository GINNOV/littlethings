#ifndef _INLINE_PALETTE_H
#define _INLINE_PALETTE_H

#ifndef PALETTE_BASE_NAME
#define PALETTE_BASE_NAME PaletteBase
#endif

#define PALETTE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) PALETTE_BASE_NAME) - 30))((struct Library *) PALETTE_BASE_NAME)

#endif /*  _INLINE_PALETTE_H  */
