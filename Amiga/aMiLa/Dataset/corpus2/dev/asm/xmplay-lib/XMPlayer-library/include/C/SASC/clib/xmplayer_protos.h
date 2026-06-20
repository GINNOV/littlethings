#ifndef CLIB_XMPLAYER_PROTOS_H
#define CLIB_XMPLAYER_PROTOS_H
/*
**	$Filename: clib/xmplayer_protos.h $
**	$Release: 1.0a $
**	$Revision: 1.0a $
**
**	C prototypes for xmplayer.library
**
**	Library coded by CruST / Amnesty^.humbug.
**	Released by .humbug. 17.04.2001
**	
**	C includes&fd file by Igor/TCG
**
**	Library based on the PS3M source 
**	Copyright (c) Jarno Paananen a.k.a. Guru / S2 1994-96.
*/

#ifndef	EXEC_TYPES_H
#include <exec/types.h>
#endif	/* EXEC_TYPES_H */

#ifndef	LIBRARIES_XMPLAYER_H
#include <libraries/xmplayer.h>
#endif	/* LIBRARIES_XMPLAYER_H */

BOOL XMPl_Init(struct XMPlayerInfo *);
BOOL XMPl_Play(void);
void XMPl_StopPlay(void);
void XMPl_PausePlay(void);
void XMPl_ContPlay(void);
void XMPl_SetPos(LONG);
void XMPl_GetPos(struct XMPlayerPos *);
void XMPl_DeInit(void);

#endif /* CLIB_XMPLAYER_PROTOS_H */
