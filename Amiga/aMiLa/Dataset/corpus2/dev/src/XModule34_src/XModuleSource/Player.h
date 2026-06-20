/*	Player.h
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Use 4 chars wide TABs to read this source
**
**	Definitions for the player interface.
*/

struct PlayerCmd
{
	struct Message	pcmd_Message;
	ULONG			pcmd_ID;
	APTR			pcmd_Data;
	LONG			pcmd_Err;
};


enum
{
	PCMD_SETUP = -1,
	PCMD_INIT,
	PCMD_PLAY,
};
