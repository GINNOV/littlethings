#ifndef _INLINE_GLYPH_H
#define _INLINE_GLYPH_H

#ifndef GLYPH_BASE_NAME
#define GLYPH_BASE_NAME GlyphBase
#endif

#define GLYPH_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) GLYPH_BASE_NAME) - 30))((struct Library *) GLYPH_BASE_NAME)

#endif /*  _INLINE_GLYPH_H  */
