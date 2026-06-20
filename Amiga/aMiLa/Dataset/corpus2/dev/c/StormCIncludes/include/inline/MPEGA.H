#ifndef _INLINE_MPEGA_H
#define _INLINE_MPEGA_H

#ifndef MPEGA_BASE_NAME
#define MPEGA_BASE_NAME MPEGABase
#endif

#define MPEGA_open(filename, ctrl) \
	((MPEGA_STREAM * (*)(char * __asm("a0"), MPEGA_CTRL * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 30))(filename, ctrl, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_close(mpds) \
	((void (*)(MPEGA_STREAM * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 36))(mpds, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_decode_frame(mpds, pcm) \
	((LONG (*)(MPEGA_STREAM * __asm("a0"), WORD * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 42))(mpds, pcm, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_seek(mpds, ms_time_position) \
	((LONG (*)(MPEGA_STREAM * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 48))(mpds, ms_time_position, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_time(mpds, ms_time_position) \
	((LONG (*)(MPEGA_STREAM * __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 54))(mpds, ms_time_position, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_find_sync(buffer, buffer_size) \
	((LONG (*)(BYTE * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 60))(buffer, buffer_size, (struct Library *) MPEGA_BASE_NAME)

#define MPEGA_scale(mpds, scale_percent) \
	((LONG (*)(MPEGA_STREAM * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MPEGA_BASE_NAME) - 66))(mpds, scale_percent, (struct Library *) MPEGA_BASE_NAME)

#endif /*  _INLINE_MPEGA_H  */
