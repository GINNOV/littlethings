#ifndef _INLINE_CHUNKYPPC_H
#define _INLINE_CHUNKYPPC_H

#ifndef CHUNKYPPC_BASE_NAME
#define CHUNKYPPC_BASE_NAME ChunkyPPCBase
#endif

#define ChunkyInit68k(ms, srcformat) \
	((int (*)(struct Mode_Screen * __asm("a0"), int __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CHUNKYPPC_BASE_NAME) - 198))(ms, srcformat, (struct Library *) CHUNKYPPC_BASE_NAME)

#define OpenGraphics(title, ms, override) \
	((struct Mode_Screen * (*)(char * __asm("a0"), struct Mode_Screen * __asm("a1"), int __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CHUNKYPPC_BASE_NAME) - 204))(title, ms, override, (struct Library *) CHUNKYPPC_BASE_NAME)

#define CloseGraphics(ms, shutdownlibs) \
	((void (*)(struct Mode_Screen * __asm("a0"), int __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CHUNKYPPC_BASE_NAME) - 210))(ms, shutdownlibs, (struct Library *) CHUNKYPPC_BASE_NAME)

#define LoadColors(ms, table) \
	((void (*)(struct Mode_Screen * __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CHUNKYPPC_BASE_NAME) - 216))(ms, table, (struct Library *) CHUNKYPPC_BASE_NAME)

#define DoubleBuffer(ms) \
	((void (*)(struct Mode_Screen * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CHUNKYPPC_BASE_NAME) - 222))(ms, (struct Library *) CHUNKYPPC_BASE_NAME)

#endif /*  _INLINE_CHUNKYPPC_H  */
