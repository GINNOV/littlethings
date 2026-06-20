#ifndef _INLINE_GETFILE_H
#define _INLINE_GETFILE_H

#ifndef GETFILE_BASE_NAME
#define GETFILE_BASE_NAME GetFileBase
#endif

#define GETFILE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) GETFILE_BASE_NAME) - 30))((struct Library *) GETFILE_BASE_NAME)

#endif /*  _INLINE_GETFILE_H  */
