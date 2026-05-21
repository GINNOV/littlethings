/*
 *  AudioDriver_Arne.h
 *  MilkyPlay
 *
 *  Created by neoman on 14.05.20
 *
 */
#ifndef __AUDIODRIVER_ARNE_H__
#define __AUDIODRIVER_ARNE_H__

#include "AudioDriver_Amiga.h"

class AudioDriver_Arne : public AudioDriver_Amiga
{
protected:
	virtual mp_sint32   getChannels() const;

public:
						AudioDriver_Arne();
	virtual				~AudioDriver_Arne();

	virtual	mp_sint32	initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer);

	virtual	const char*	getDriverID();
	virtual	mp_sint32	getPreferredBufferSize() const;
};

class AudioDriver_Arne_DirectOut : public AudioDriver_Arne
{
private:
	mp_sword ** 		chanFetch;
	mp_sword ** 		chanRing;

protected:
	virtual mp_sint32   allocResources();
	virtual void        deallocResources();

	virtual void        initHardware();
	virtual void		setGlobalVolume(mp_ubyte volume);
	virtual void    	disableDMA();
	virtual void      	enableDMA();
	virtual void 		playAudioImpl();
	virtual void        bufferAudioImpl();

public:
	virtual	mp_sint32	initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer);

	virtual bool        isMultiChannel() const;
};

class AudioDriver_Arne_ResampleHW : public AudioDriver_Arne
{
private:
	bool				wasExterIRQEnabled;

	mp_ubyte            oldTimerALo;
	mp_ubyte            oldTimerAHi;
	mp_ubyte            oldTimerBLo;
	mp_ubyte            oldTimerBHi;

	mp_uword			newDMACON;

	mp_sbyte *          zeroSample;
	mp_uint32			channelLoopStart[8];
	mp_uint32			channelRepeatLength[8];
	mp_sint32           channelSamplePos[8];
	mp_sint32          	channelPeriod[8];

protected:
	virtual mp_sint32   allocResources();
	virtual void        deallocResources();

	virtual void        initHardware();
	virtual void        bufferAudioImpl();

	virtual void        disableDMA();
	virtual void      	disableIRQ();
	virtual void        enableIRQ();

public:
	virtual	mp_sint32	initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer);

	virtual void 		playAudio();
	virtual void     	bufferAudio();

	virtual bool        isMultiChannel() const;

    virtual void 		setChannelFrequency(ChannelMixer::TMixerChannel * chn);
    virtual void 		setChannelVolume(ChannelMixer::TMixerChannel * chn);
    virtual void 		playSample(ChannelMixer::TMixerChannel * chn);
    virtual void 		stopSample(ChannelMixer::TMixerChannel * chn);
	virtual void 		tickDone(ChannelMixer::TMixerChannel * chn);
};

#endif
