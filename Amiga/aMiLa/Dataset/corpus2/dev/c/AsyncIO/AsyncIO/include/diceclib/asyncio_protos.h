/* $VER: clib/asyncio_protos.h 1.0 (9.9.95) */
#ifndef ASYNCIO_PROTOS_H
#define ASYNCIO_PROTOS_H 1
#include <pragmas/config.h>
#include <exec/types.h>
#include <clib/asyncio_protos.h>  /* Note this is in the Amiga directory */
#if __SUPPORTS_PRAGMAS__
#ifdef __DICE_INLINE
#ifdef ASIO_SHARED_LIB
extern struct Library *AsyncIOBase;
#include <pragmas/asyncio_pragmas.h>
#endif
#endif
#endif
#endif
