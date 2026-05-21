/*
 *  AudioDriver_Paula.h
 *  MilkyPlay
 *
 *  Created by neoman on 14.05.20
 *
 */
#ifndef __AUDIODRIVER_PAULA_H__
#define __AUDIODRIVER_PAULA_H__

#include "AudioDriver_Amiga.h"

class AudioDriver_Paula : public AudioDriver_Amiga
{
protected:
	virtual mp_sint32   getChannels() const;

public:
						AudioDriver_Paula();
	virtual				~AudioDriver_Paula();

	virtual	mp_sint32	initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer);

	virtual	const char*	getDriverID();
	virtual	mp_sint32	getPreferredBufferSize() const;
};

class AudioDriver_Paula_Mix : public AudioDriver_Paula
{
private:
	mp_sword * 			samplesFetched;

	mp_sbyte * 			samplesLeft;
	mp_sbyte * 			samplesRight;

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
};

class AudioDriver_Paula_DirectOut : public AudioDriver_Paula
{
private:
	mp_sword ** 		chanFetch;
	mp_sbyte ** 		chanRing;

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

class AudioDriver_Paula_ResampleHW : public AudioDriver_Paula
{
private:
	bool				wasExterIRQEnabled;

	mp_ubyte            oldTimerALo;
	mp_ubyte            oldTimerAHi;
	mp_ubyte            oldTimerBLo;
	mp_ubyte            oldTimerBHi;

	mp_uword			newDMACON;

	mp_sbyte *          zeroSample;
	mp_uint32			channelLoopStart[4];
	mp_uword			channelRepeatLength[4];
	mp_sint32           channelSamplePos[4];
	mp_sint32          	channelPeriod[4];

protected:
	virtual mp_sint32   allocResources();
	virtual void        deallocResources();

	virtual void        initHardware();
	virtual void        bufferAudioImpl();

	virtual void    	disableDMA();
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
