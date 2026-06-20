/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_XPKMASTER_H
#define _PPCINLINE_XPKMASTER_H

#ifndef __PPCINLINE_MACROS_H
#include <powerup/ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef XPKMASTER_BASE_NAME
#define XPKMASTER_BASE_NAME XpkBase
#endif /* !XPKMASTER_BASE_NAME */

#define XpkClose(xbuf) \
	LP1(0x4e, LONG, XpkClose, XFH  *, xbuf, a0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkExamine(fib, tags) \
	LP2(0x24, LONG, XpkExamine, XFIB *, fib, a0, TAGS *, tags, a1, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkOpen(xbuf, tags) \
	LP2(0x36, LONG, XpkOpen, XFH **, xbuf, a0, TAGS  *, tags, a1, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkPack(tags) \
	LP1(0x2a, LONG, XpkPack, TAGS *, tags, a0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkQuery(tags) \
	LP1(0x54, LONG, XpkQuery, TAGS *, tags, a0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkRead(xbuf, buf, len) \
	LP3(0x3c, LONG, XpkRead, XFH  *, xbuf, a0, UBYTE *, buf, a1, LONG, len, d0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkSeek(xbuf, len, mode) \
	LP3(0x48, LONG, XpkSeek, XFH  *, xbuf, a0, LONG, len, d0, LONG, mode, d1, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkUnpack(tags) \
	LP1(0x30, LONG, XpkUnpack, TAGS *, tags, a0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define XpkWrite(xbuf, buf, len) \
	LP3(0x42, LONG, XpkWrite, XFH  *, xbuf, a0, UBYTE *, buf, a1, LONG, len, d0, \
	, XPKMASTER_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* !_PPCINLINE_XPKMASTER_H */
