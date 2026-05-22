/*
** AMPlifier - plugin system
**
**  $VER: amplifierplugin.h
**
**  (C) Copyright 1999 Thorsten Hansen
*/

#ifndef __AMPLIFIERPLUGIN_H
#define __AMPLIFIERPLUGIN_H

#include <exec/types.h>
#include <utility/tagitem.h>


struct PluginCtrl
{
	APTR UserData;
};

struct RenderData
{
	ULONG Samplerate;
	ULONG Channels;
	WORD *waveform[2];
	WORD *spectrum[2];
};

#define PI_BaseTag					(TAG_USER + 0x100000)

#define PIA_Name						(PI_BaseTag + 1)
#define PIA_QuitTask					(PI_BaseTag + 2)
#define PIA_QuitMask					(PI_BaseTag + 3)
#define PIA_UserData					(PI_BaseTag + 4)
#define PIA_RenderHook				(PI_BaseTag + 5)
#define PIA_WaveformChannels		(PI_BaseTag + 6)
#define PIA_SpectrumChannels		(PI_BaseTag + 7)


#endif
