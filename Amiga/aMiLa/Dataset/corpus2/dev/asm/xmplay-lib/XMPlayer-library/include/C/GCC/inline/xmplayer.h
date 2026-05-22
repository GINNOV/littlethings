/* Automatically generated header! Do not edit! */

#ifndef _INLINE_XMPLAYER_H
#define _INLINE_XMPLAYER_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef XMPLAYER_BASE_NAME
#define XMPLAYER_BASE_NAME XMPlayerBase
#endif /* !XMPLAYER_BASE_NAME */

#define XMPl_ContPlay() \
	LP0NR(0x36, XMPl_ContPlay, \
	, XMPLAYER_BASE_NAME)

#define XMPl_DeInit() \
	LP0NR(0x48, XMPl_DeInit, \
	, XMPLAYER_BASE_NAME)

#define XMPl_GetPos(XMPlayerPos_) \
	LP1NR(0x42, XMPl_GetPos, struct XMPlayerPos *, XMPlayerPos_, a0, \
	, XMPLAYER_BASE_NAME)

#define XMPl_Init(XMPlayerInfo_) \
	LP1(0x1e, BOOL, XMPl_Init, struct XMPlayerInfo *, XMPlayerInfo_, a0, \
	, XMPLAYER_BASE_NAME)

#define XMPl_PausePlay() \
	LP0NR(0x30, XMPl_PausePlay, \
	, XMPLAYER_BASE_NAME)

#define XMPl_Play() \
	LP0(0x24, BOOL, XMPl_Play, \
	, XMPLAYER_BASE_NAME)

#define XMPl_SetPos(NewPosition) \
	LP1NR(0x3c, XMPl_SetPos, LONG, NewPosition, d0, \
	, XMPLAYER_BASE_NAME)

#define XMPl_StopPlay() \
	LP0NR(0x2a, XMPl_StopPlay, \
	, XMPLAYER_BASE_NAME)

#endif /* !_INLINE_XMPLAYER_H */
