/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_MPEGA_H
#define _PPCINLINE_MPEGA_H

#ifndef __PPCINLINE_MACROS_H
#include <powerup/ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef MPEGA_BASE_NAME
#define MPEGA_BASE_NAME MPEGABase
#endif /* !MPEGA_BASE_NAME */

#define MPEGA_open(stream_name, ctrl) \
	LP2(0x1e, MPEGA_STREAM *, MPEGA_open, char *, stream_name, a0, MPEGA_CTRL *, ctrl, a1, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_close(mpds) \
	LP1NR(0x24, MPEGA_close, MPEGA_STREAM *, mpds, a0, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_decode_frame(mpds, pcm) \
	LP2(0x2a, LONG, MPEGA_decode_frame, MPEGA_STREAM *, mpds, a0, WORD **, pcm, a1, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_seek(mpds, ms_time_position) \
	LP2(0x30, LONG, MPEGA_seek, MPEGA_STREAM *, mpds, a0, ULONG, ms_time_position, d0, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_time(mpds, ms_time_position) \
	LP2(0x36, LONG, MPEGA_time, MPEGA_STREAM *, mpds, a0, ULONG *, ms_time_position, a1, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_find_sync(buffer, buffersize) \
	LP2(0x3c, LONG, MPEGA_find_sync, BYTE *, buffer, a0, LONG, buffersize, d0, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define MPEGA_scale(mpds, scale_percent) \
	LP2(0x42, LONG, MPEGA_scale, MPEGA_STREAM *, mpds, a0, LONG, scale_percent, d0, \
	, MPEGA_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* !_PPCINLINE_MPEGA_H */
