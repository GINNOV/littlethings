/* $VER: /include/pragmas/asyncio_pragmas.h 1.0 (4.5.97) */
#ifndef AsyncIOBase_PRAGMA_H
#define AsyncIOBase_PRAGMA_H

#pragma libcall AsyncIOBase OpenAsync 1e 10803
#pragma libcall AsyncIOBase OpenAsyncFromFH 24 10803
#pragma libcall AsyncIOBase CloseAsync 2a 801
#pragma libcall AsyncIOBase SeekAsync 30 10803
#pragma libcall AsyncIOBase ReadAsync 36 09803
#pragma libcall AsyncIOBase WriteAsync 3c 09803
#pragma libcall AsyncIOBase ReadCharAsync 42 801
#pragma libcall AsyncIOBase WriteCharAsync 48 0802
#pragma libcall AsyncIOBase ReadLineAsync 4e 09803
#pragma libcall AsyncIOBase WriteLineAsync 54 9802
#pragma libcall AsyncIOBase FGetsAsync 5a 09803
#pragma libcall AsyncIOBase FGetsLenAsync 60 a09804
#pragma libcall AsyncIOBase PeekAsync 66 09803

#endif
