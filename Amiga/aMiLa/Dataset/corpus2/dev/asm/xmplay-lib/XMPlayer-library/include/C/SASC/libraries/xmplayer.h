#ifndef LIBRARIES_XMPLAYER_H
#define LIBRARIES_XMPLAYER_H
/*
**	$Filename: libraries/xmplayer.h $
**	$Release: 1.0a $
**	$Revision: 1.0a $
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

/*********************************************************************
XM MIX Types
*********************************************************************/

#define XM_MONO		0
#define XM_STEREO	1
#define XM_SURROUND	2
#define XM_REALSURR	3
#define XM_STEREO14	4

/*********************************************************************
XMPlayer Structure
*********************************************************************/

struct XMPlayerInfo
{
	APTR XMPl_Cont;
	LONG XMPl_Mixtype;
	LONG XMPl_Mixfreq;
	LONG XMPl_Vboost;
	APTR XMPl_PrName;
	LONG XMPl_PrPri;
};


/*********************************************************************
XMPlayerPos Structure
*********************************************************************/

struct XMPlayerPos
{
	LONG XMPl_ModPos;
	LONG XMPl_PattPos;
};


#endif /* LIBRARIES_XMPLAYER_H */
