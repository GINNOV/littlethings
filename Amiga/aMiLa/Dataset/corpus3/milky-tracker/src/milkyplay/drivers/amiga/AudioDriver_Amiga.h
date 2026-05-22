/*
 *  AudioDriver_Amiga.h
 *  MilkyPlay
 *
 *  Created by neoman on 14.05.20
 *
 */
#ifndef __AUDIODRIVER_AMIGA_H__
#define __AUDIODRIVER_AMIGA_H__

#include "AudioDriverBase.h"
#include "MixerProxy.h"
#include "ProxyProcessor.h"

#include <exec/exec.h>
#include <clib/exec_protos.h>

#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>
#include <hardware/cia.h>

#include <stdio.h>
#include <string.h>

#define DEBUG_DRIVER            0

#define CIAAPRA                 0xbfe001

#define CUSTOM_REGBASE          0xdff000
#define CUSTOM_DMACON           (CUSTOM_REGBASE + 0x096)
#define CUSTOM_INTENA           (CUSTOM_REGBASE + 0x09a)

#define MAX_VOLUME              0x40

#define PAULA_CLK           	3546895
#define SCANLINES               312
#define REFRESHRATE				50

extern volatile struct Custom custom;
extern volatile struct CIA ciaa, ciab;

class AudioDriverInterface_Amiga : public AudioDriverBase
{
protected:
	AudioDriverInterface_Amiga();
	virtual ~AudioDriverInterface_Amiga();
public:
	virtual void bufferAudio();
};

class AudioDriver_Amiga : public AudioDriverInterface_Amiga, public ProxyProcessor
{
protected:
	enum OutputMode {
		Mix,
		DirectOut,
		ResampleHW
	};

	MixerProxy * 		mixerProxy;

	bool                allocated;
	bool                irqEnabled;

	mp_uint32           nChannels;

	mp_sint32   		idxRead, idxWrite;
	mp_uint32           chunkSize, ringSize, fetchSize;
	mp_uword    		intenaOld, dmaconOld;

	mp_sint32           statVerticalBlankMixMedian;
	mp_sint32           statAudioBufferReset, statAudioBufferResetMedian;
	mp_sint32           statRingBufferFull, statRingBufferFullMedian;
	mp_sint32           statCountPerSecond;

	struct Interrupt *	irqPlayAudio;
	struct Interrupt *	irqAudioOld;

	virtual mp_sint32	alloc(mp_sint32 bufferSize);
	virtual void 		dealloc();

	virtual void      	disableIRQ();
	virtual void        enableIRQ();

						AudioDriver_Amiga();
	virtual				~AudioDriver_Amiga();

	virtual mp_sint32   allocResources() = 0;
	virtual void        initHardware() = 0;
	virtual void   		deallocResources() = 0;

	virtual void        bufferAudioImpl() = 0;
	virtual void 		playAudioImpl() { }

	virtual void		setGlobalVolume(mp_ubyte volume) { }

	virtual void    	disableDMA() { }
	virtual void      	enableDMA() { }

	virtual	mp_sint32	initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer);
	virtual	mp_sint32	closeDevice();

	virtual	mp_sint32	start();
	virtual	mp_sint32	stop();

	virtual	mp_sint32	pause();
	virtual	mp_sint32	resume();

	virtual	const char*	getDriverID() = 0;
	virtual	mp_sint32	getPreferredBufferSize() const = 0;

	virtual mp_sint32   getStatValue(mp_uint32 key);

public:
	virtual void 		playAudio();
	virtual void 		bufferAudio();

	virtual bool        isMultiChannel() const { return false; }
};

#endif
