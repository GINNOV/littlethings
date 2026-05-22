#ifndef _INCLUDE_PRAGMAS_XMPLAYER_PRAGMAS_H
#define _INCLUDE_PRAGMAS_XMPLAYER_PRAGMAS_H

#ifndef CLIB_XMPLAYER_PROTOS_H
#include <clib/xmplayer_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(XMPlayerBase,0x01E,XMPl_Init(a0))
#pragma amicall(XMPlayerBase,0x024,XMPl_Play())
#pragma amicall(XMPlayerBase,0x02A,XMPl_StopPlay())
#pragma amicall(XMPlayerBase,0x030,XMPl_PausePlay())
#pragma amicall(XMPlayerBase,0x036,XMPl_ContPlay())
#pragma amicall(XMPlayerBase,0x03C,XMPl_SetPos(d0))
#pragma amicall(XMPlayerBase,0x042,XMPl_GetPos(a0))
#pragma amicall(XMPlayerBase,0x048,XMPl_DeInit())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall XMPlayerBase XMPl_Init            01E 801
#pragma  libcall XMPlayerBase XMPl_Play            024 00
#pragma  libcall XMPlayerBase XMPl_StopPlay        02A 00
#pragma  libcall XMPlayerBase XMPl_PausePlay       030 00
#pragma  libcall XMPlayerBase XMPl_ContPlay        036 00
#pragma  libcall XMPlayerBase XMPl_SetPos          03C 001
#pragma  libcall XMPlayerBase XMPl_GetPos          042 801
#pragma  libcall XMPlayerBase XMPl_DeInit          048 00
#endif

#endif	/*  _INCLUDE_PRAGMAS_XMPLAYER_PRAGMAS_H  */
