#include "AudioDriver_Paula.h"
#include "MasterMixer.h"

#define AUDIO_REGBASE(CH)       (CUSTOM_REGBASE + 0x0a0 + ((CH & 0x3) << 4))
#define AUDIO_REG(CH, IDX)      (AUDIO_REGBASE(CH) + (IDX))

#define AUDIO_LOCHI(CH)         AUDIO_REG(CH, 0x00)
#define AUDIO_LOCLO(CH)         AUDIO_REG(CH, 0x02)
#define AUDIO_LENGTH(CH)        AUDIO_REG(CH, 0x04)
#define AUDIO_PERIOD(CH)        AUDIO_REG(CH, 0x06)
#define AUDIO_VOLUME(CH)        AUDIO_REG(CH, 0x08)

#define MAX_CHANNELS            4

AudioDriver_Paula::AudioDriver_Paula()
{
}

AudioDriver_Paula::~AudioDriver_Paula()
{
}

mp_sint32
AudioDriver_Paula::getChannels() const
{
    return MAX_CHANNELS;
}

const char*
AudioDriver_Paula::getDriverID()
{
    return "Commodore Paula Audio 4-ch";
}

mp_sint32
AudioDriver_Paula::getPreferredBufferSize() const
{
    return 8192;
}

mp_sint32
AudioDriver_Paula::initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer)
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
    printf("Hi baby, my name is Paula.\n");
    printf("Wanted buffer size: %ld\n", bufferSizeInWords);
    printf("Wanted mix frequency: %ld\n", mixFrequency);
#endif

    mixFrequency = 22050;

    return AudioDriver_Amiga::initDevice(bufferSizeInWords, mixFrequency, mixer);
}

// ---------------------------------------------------------------------------
// Mix
// ---------------------------------------------------------------------------

mp_sint32
AudioDriver_Paula_Mix::initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer)
{
#if DEBUG_DRIVER
    printf("Driver outputting in Mix mode\n");
#endif

    return AudioDriver_Paula::initDevice(bufferSizeInWords, mixFrequency, mixer);
}

mp_sint32
AudioDriver_Paula_Mix::allocResources()
{
    // Fetch buffer for 16-bit stereo
    samplesFetched = (mp_sword *) AllocMem(fetchSize * sizeof(mp_sword) * MP_NUMCHANNELS, MEMF_PUBLIC | MEMF_CLEAR);

    // Ring buffers for each side
    samplesLeft = (mp_sbyte *) AllocMem(ringSize * sizeof(mp_sbyte), MEMF_CHIP | MEMF_CLEAR);
    samplesRight = (mp_sbyte *) AllocMem(ringSize * sizeof(mp_sbyte), MEMF_CHIP | MEMF_CLEAR);

    return 0;
}

void
AudioDriver_Paula_Mix::deallocResources()
{
    FreeMem(samplesRight, ringSize * sizeof(mp_sbyte));
    FreeMem(samplesLeft, ringSize * sizeof(mp_sbyte));

    FreeMem(samplesFetched, fetchSize * sizeof(mp_sword) * MP_NUMCHANNELS);
}

void
AudioDriver_Paula_Mix::initHardware()
{
    mp_uword period = PAULA_CLK / this->mixFrequency;

    *((volatile mp_uint32 *) AUDIO_LOCHI(0)) = (mp_uint32) samplesLeft;
    *((volatile mp_uword *) AUDIO_LENGTH(0)) = chunkSize >> 1;
    *((volatile mp_uword *) AUDIO_PERIOD(0)) = period;

    *((volatile mp_uint32 *) AUDIO_LOCHI(1)) = (mp_uint32) samplesRight;
    *((volatile mp_uword *) AUDIO_LENGTH(1)) = chunkSize >> 1;
    *((volatile mp_uword *) AUDIO_PERIOD(1)) = period;
}

void
AudioDriver_Paula_Mix::setGlobalVolume(mp_ubyte volume)
{
    for(int i = 0; i < MAX_CHANNELS; i++) {
        *((volatile mp_uword *) AUDIO_VOLUME(i)) = volume;
    }
}

void
AudioDriver_Paula_Mix::disableDMA()
{
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_AUD0 | DMAF_AUD1;
}

void
AudioDriver_Paula_Mix::enableDMA()
{
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_SETCLR | DMAF_AUD0 | DMAF_AUD1;
}

void
AudioDriver_Paula_Mix::playAudioImpl()
{
    *((volatile mp_uint32 *) AUDIO_LOCHI(0)) = (mp_uint32) (samplesLeft + idxRead);
    *((volatile mp_uword *) AUDIO_LENGTH(0)) = chunkSize >> 1;

    *((volatile mp_uint32 *) AUDIO_LOCHI(1)) = (mp_uint32) (samplesRight + idxRead);
    *((volatile mp_uword *) AUDIO_LENGTH(1)) = chunkSize >> 1;
}

void
AudioDriver_Paula_Mix::bufferAudioImpl()
{
    mp_sword * f = samplesFetched;
    mp_sbyte
        * l = samplesLeft + idxWrite,
        * r = samplesRight + idxWrite;

    if (isMixerActive())
        mixer->mixerHandler(f);
    else
        memset(f, 0, fetchSize * sizeof(mp_sword) * MP_NUMCHANNELS);

    for(int i = 0; i < fetchSize; i++) {
        *(l++) = *(f++) >> 8;
        *(r++) = *(f++) >> 8;
    }
}

// ---------------------------------------------------------------------------
// DirectOut
// ---------------------------------------------------------------------------

mp_sint32
AudioDriver_Paula_DirectOut::initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer)
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
    printf("Driver outputting in DirectOut mode\n");
#endif

    return AudioDriver_Paula::initDevice(bufferSizeInWords, mixFrequency, mixer);
}

bool
AudioDriver_Paula_DirectOut::isMultiChannel() const
{
    return true;
}

mp_sint32
AudioDriver_Paula_DirectOut::allocResources()
{
    // Fetch buffers for each channel (16-bit stereo)
    chanFetch = (mp_sword **) AllocMem(nChannels * sizeof(mp_sword *), MEMF_PUBLIC | MEMF_CLEAR);
    for(int i = 0; i < nChannels; i++)
        chanFetch[i] = (mp_sword *) AllocMem(fetchSize * sizeof(mp_sword) * MP_NUMCHANNELS, MEMF_PUBLIC | MEMF_CLEAR);

    // Ring buffers for each channel
    chanRing = (mp_sbyte **) AllocMem(nChannels * sizeof(mp_sbyte *), MEMF_PUBLIC | MEMF_CLEAR);
    for(int i = 0; i < nChannels; i++)
        chanRing[i] = (mp_sbyte *) AllocMem(ringSize * sizeof(mp_sbyte), MEMF_CHIP | MEMF_CLEAR);

    mixerProxy = new MixerProxyDirectOut(nChannels);

    return 0;
}

void
AudioDriver_Paula_DirectOut::deallocResources()
{
    delete mixerProxy;

    for(int i = 0; i < nChannels; i++)
        FreeMem(chanRing[i], ringSize * sizeof(mp_sbyte));
    FreeMem(chanRing, nChannels * sizeof(mp_sbyte *));

    for(int i = 0; i < nChannels; i++)
        FreeMem(chanFetch[i], fetchSize * sizeof(mp_sword) * MP_NUMCHANNELS);
    FreeMem(chanFetch, nChannels * sizeof(mp_sword *));
}

void
AudioDriver_Paula_DirectOut::initHardware()
{
    mp_uword period = PAULA_CLK / this->mixFrequency;

    for(int i = 0; i < MAX_CHANNELS; i++) {
        *((volatile mp_uint32 *) AUDIO_LOCHI(i)) = (mp_uint32) chanRing[i];
        *((volatile mp_uword *) AUDIO_LENGTH(i)) = chunkSize >> 1;
        *((volatile mp_uword *) AUDIO_PERIOD(i)) = period;
    }
}

void
AudioDriver_Paula_DirectOut::setGlobalVolume(mp_ubyte volume)
{
    for(int i = 0; i < MAX_CHANNELS; i++) {
        *((volatile mp_uword *) AUDIO_VOLUME(i)) = volume;
    }
}

void
AudioDriver_Paula_DirectOut::disableDMA()
{
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_AUDIO;
}

void
AudioDriver_Paula_DirectOut::enableDMA()
{
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_SETCLR | DMAF_AUDIO;
}

void
AudioDriver_Paula_DirectOut::playAudioImpl()
{
    for(int i = 0; i < MAX_CHANNELS; i++) {
        *((volatile mp_uint32 *) AUDIO_LOCHI(i)) = (mp_uint32) (chanRing[i] + idxRead);
        *((volatile mp_uword *) AUDIO_LENGTH(i)) = chunkSize >> 1;
    }
}

void
AudioDriver_Paula_DirectOut::bufferAudioImpl()
{
    if (isMixerActive()) {
        for(int i = 0; i < MAX_CHANNELS; i++)
            mixerProxy->setBuffer<mp_sword>(i, chanFetch[i]);
        mixer->mixerHandler(NULL, mixerProxy);

        for(int i = 0; i < MAX_CHANNELS; i++) {
            mp_sword * s = chanFetch[i];
            mp_sbyte * d = chanRing[i] + idxWrite;
            int l = -1;

            for(int j = 0; j < fetchSize; j++) {
                *(d++) = *(s++) >> 8;
                s++;
            }
        }
    } else {
        for(int i = 0; i < MAX_CHANNELS; i++)
            memset(chanRing[i] + idxWrite, 0, fetchSize * sizeof(mp_sbyte));
    }
}

// ---------------------------------------------------------------------------
// ResampleHW
// ---------------------------------------------------------------------------

mp_sint32
AudioDriver_Paula_ResampleHW::initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer)
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
    printf("Driver outputting in ResampleHW mode\n");
#endif

    return AudioDriver_Paula::initDevice(bufferSizeInWords, mixFrequency, mixer);
}

bool
AudioDriver_Paula_ResampleHW::isMultiChannel() const
{
    return true;
}

mp_sint32
AudioDriver_Paula_ResampleHW::allocResources()
{
    mixerProxy = new MixerProxyHardwareOut(nChannels, this);
    zeroSample = (mp_sbyte *) AllocMem(16, MEMF_CHIP | MEMF_CLEAR);

    return 0;
}

void
AudioDriver_Paula_ResampleHW::deallocResources()
{
    FreeMem(zeroSample, 16);
    delete mixerProxy;
}

void
AudioDriver_Paula_ResampleHW::initHardware()
{
    newDMACON = 0;

    for(int i = 0; i < MAX_CHANNELS; i++) {
        channelLoopStart[i] = 0;
        channelRepeatLength[i] = 1;
        channelSamplePos[i] = 0;
        channelPeriod[i] = 1;
    }
}

void
AudioDriver_Paula_ResampleHW::bufferAudioImpl()
{
    if(isMixerActive()) {
        mixer->mixerHandler(NULL, mixerProxy);
    }
}

void
AudioDriver_Paula_ResampleHW::bufferAudio()
{
}

void
AudioDriver_Paula_ResampleHW::disableIRQ()
{
    if(!irqEnabled)
        return;

    if(!wasExterIRQEnabled)
        custom.intena = INTF_EXTER;
    RemIntServer(INTB_EXTER, irqPlayAudio);

    // Restore CIA registers
    ciab.ciatalo = oldTimerALo;
    ciab.ciatahi = oldTimerAHi;
    ciab.ciatblo = oldTimerBLo;
    ciab.ciatbhi = oldTimerBHi;

    // Disable CIA interrupts
    ciab.ciaicr = CIAICRF_IR | CIAICRF_FLG | CIAICRF_SP | CIAICRF_ALRM | CIAICRF_TB | CIAICRF_TA;

    irqEnabled = false;
}

void
AudioDriver_Paula_ResampleHW::enableIRQ()
{
    if(irqEnabled)
        return;

    // Save regs
    oldTimerALo = ciab.ciatalo;
    oldTimerAHi = ciab.ciatahi;
    oldTimerBLo = ciab.ciatblo;
    oldTimerBHi = ciab.ciatbhi;

    // Disable CIA interrupts
    ciab.ciaicr = CIAICRF_IR | CIAICRF_FLG | CIAICRF_SP | CIAICRF_ALRM | CIAICRF_TB | CIAICRF_TA;

    // Reset Timer A
    ciab.ciacra = CIACRAF_LOAD | CIACRAF_START;
    ciab.ciatalo = (1773447/125)&0xff;
    ciab.ciatahi = (1773447/125)>>8;

    // Reset Timer B
    ciab.ciacrb = CIACRBF_LOAD;
    ciab.ciatblo = 576&0xff;
    ciab.ciatbhi = 576>>8;

    // Enable CIA interrupt
    ciab.ciaicr = CIAICRF_SETCLR | CIAICRF_TA | CIAICRF_TB;

    // Read current EXTER IRQ state
    wasExterIRQEnabled = (custom.intenar & INTF_EXTER) ? true : false;

    // Enable channel playback interrupt
    AddIntServer(INTB_EXTER, irqPlayAudio);
    if(!wasExterIRQEnabled)
        custom.intena = INTF_SETCLR | INTF_EXTER;
    irqEnabled = true;
}

void
AudioDriver_Paula_ResampleHW::disableDMA()
{
    custom.dmacon = DMAF_AUDIO;
}

void
AudioDriver_Paula_ResampleHW::playAudio()
{
    // Read ICR (which clears the reg!)
    UBYTE icr = ciab.ciaicr;

    // If Timer-A has been fired
    if(icr & CIAICRF_TA) {
        bufferAudioImpl();
    }

    // If Timer-B has been fired
    if(icr & CIAICRF_TB) {
        if(newDMACON) {
            //
            // First round
            //

            // Enable one-shot timer to set repeat
            ciab.ciacrb = CIACRBF_LOAD | CIACRBF_RUNMODE | CIACRBF_START;

            // Enable DMA channels
            custom.dmacon = DMAF_SETCLR | newDMACON;
            newDMACON = 0;
        } else {
            //
            // Second round
            //

            // Set sample pointers and lengths
            *((volatile mp_uint32 *) AUDIO_LOCHI(0)) = channelLoopStart[0];
            *((volatile mp_uword *) AUDIO_LENGTH(0)) = channelRepeatLength[0];
            *((volatile mp_uint32 *) AUDIO_LOCHI(1)) = channelLoopStart[1];
            *((volatile mp_uword *) AUDIO_LENGTH(1)) = channelRepeatLength[1];
            *((volatile mp_uint32 *) AUDIO_LOCHI(2)) = channelLoopStart[2];
            *((volatile mp_uword *) AUDIO_LENGTH(2)) = channelRepeatLength[2];
            *((volatile mp_uint32 *) AUDIO_LOCHI(3)) = channelLoopStart[3];
            *((volatile mp_uword *) AUDIO_LENGTH(3)) = channelRepeatLength[3];
        }
    }
}

void
AudioDriver_Paula_ResampleHW::setChannelFrequency(ChannelMixer::TMixerChannel * chn)
{
    //printf("ch %ld per = %ld\n", chn->index, chn->period);

    *((volatile mp_uword *) AUDIO_PERIOD(chn->index)) = chn->period >> 10;
    channelPeriod[chn->index] = chn->period >> 10;
}

void
AudioDriver_Paula_ResampleHW::setChannelVolume(ChannelMixer::TMixerChannel * chn)
{
    mp_sint32 vol = 0;

    switch (chn->index & 3) {
        case 0:
        case 3:
            vol = chn->finalvoll;
            break;
        case 1:
        case 2:
            vol = chn->finalvolr;
            break;
    }

    *((volatile mp_uword *) AUDIO_VOLUME(chn->index)) = ((vol >> 21) + 6) >> 3;
}

void
AudioDriver_Paula_ResampleHW::playSample(ChannelMixer::TMixerChannel * chn)
{
    ciab.ciacrb = CIACRBF_LOAD;

    // Stop running sample
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_AUD0 << chn->index;

    // Get sample position
    mp_sint32 smppos = (chn->flags & 131072) ? chn->smppos : channelSamplePos[chn->index];

    /*printf("ch %ld play = $%08lx smppos = $%08lx, $%08lx, $%08lx, loopend = $%08lx\n",
        chn->index, chn->sample, chn->smppos, smppos, hwChannelPos[chn->index], chn->loopend);*/

    // When end of sample is reached, either loop or stop
    if(smppos >= chn->loopend) {
        if ((chn->flags & 3) == 0) {
            // No loop
            stopSample(chn);
            return;
        } else {
            smppos = ((smppos - chn->loopstart) % (chn->loopend - chn->loopstart)) + chn->loopstart;
        }
    }

    // Set sample
    *((volatile mp_uint32 *) AUDIO_LOCHI(chn->index)) = (mp_uint32) (chn->sample + smppos);
    *((volatile mp_uword *) AUDIO_LENGTH(chn->index)) = (mp_uword) (((chn->loopend - smppos) >> 1) & 0xffff);
    channelSamplePos[chn->index] = smppos;

    setChannelFrequency(chn);
    setChannelVolume(chn);

    if ((chn->flags & 3) == 0) {
        channelLoopStart[chn->index] = (mp_uint32) zeroSample;
        channelRepeatLength[chn->index] = 1;
    } else {
        channelLoopStart[chn->index] = (mp_uint32) (chn->sample + chn->loopstart);
        channelRepeatLength[chn->index] = (mp_uword) (((chn->loopend - chn->loopstart) >> 1) & 0xffff);
    }

    // And mark DMA channel as to be played
    newDMACON |= DMAF_AUD0 << chn->index;

    //
    // After processing plays and stops, this continues in tickDone
    // to enable the interrupt which enables the DMA
    //
}

void
AudioDriver_Paula_ResampleHW::stopSample(ChannelMixer::TMixerChannel * chn)
{
    //printf("ch %ld stop = %ld\n", chn->index, chn->sample);

    // Stop running sample
    *((volatile mp_uword *) CUSTOM_DMACON) = DMAF_AUD0 << chn->index;

    channelSamplePos[chn->index] = 0;
    channelLoopStart[chn->index] = 0;
    channelRepeatLength[chn->index] = 1;
    channelPeriod[chn->index] = 1;

    //
    // See playSample what happens next!
    //
}

void
AudioDriver_Paula_ResampleHW::tickDone(ChannelMixer::TMixerChannel * chn)
{
    int i;

    // Handle one-shot
    for(i = 0; i < MAX_CHANNELS; i++) {
        if((chn->flags & 3) == 0 && chn->flags & 8192 && channelSamplePos[i] >= chn->loopend) {
            chn->flags &= ~8192;
            chn->flags |= 1;
            chn->loopend = chn->loopendcopy;

            channelLoopStart[i] = (mp_uint32) chn->sample;
            channelRepeatLength[i] = (mp_uword) (((chn->loopend - chn->loopstart) >> 1) & 0xffff);
            channelSamplePos[i] = ((channelSamplePos[i] - chn->loopstart) % (chn->loopend - chn->loopstart)) + chn->loopstart;

            newDMACON |= DMAF_AUD0 << i;
        }

        chn++;
    }

    // If there are new samples playing on a channel, let irqEnableChannels enable the DMA for us
    if(newDMACON) {
        // Enable one-shot timer to set repeat
        ciab.ciacrb = CIACRBF_LOAD | CIACRBF_RUNMODE | CIACRBF_START;
    }

    for(i = 0; i < MAX_CHANNELS; i++) {
        // Period is bound to Paula/Video clock !
        channelSamplePos[i] += (PAULA_CLK / REFRESHRATE) / channelPeriod[i];
    }
}
