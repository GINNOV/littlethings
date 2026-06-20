#include "AudioDriver_Amiga.h"
#include "MasterMixer.h"

static mp_uint32
getVerticalBeamPosition() {
    struct vpos {
        mp_uint32 :13;
        mp_uint32 vpos:11;
        mp_uint32 hpos:8;
    };
    return ((struct vpos*) 0xdff004)->vpos;
}

static mp_sint32
playAudioService(register AudioDriver_Amiga * that __asm("a1"))
{
    that->playAudio();

    return 0;
}


AudioDriverInterface_Amiga::AudioDriverInterface_Amiga()
: AudioDriverBase()
{
}

AudioDriverInterface_Amiga::~AudioDriverInterface_Amiga()
{
}

void AudioDriverInterface_Amiga::bufferAudio()
{
}

AudioDriver_Amiga::AudioDriver_Amiga()
: AudioDriverInterface_Amiga()
, irqEnabled(false)
, irqAudioOld(NULL)
, allocated(false)
, statVerticalBlankMixMedian(0)
, statAudioBufferReset(0)
, statAudioBufferResetMedian(0)
, statRingBufferFull(0)
, statRingBufferFullMedian(0)
, statCountPerSecond(0)
{
}

AudioDriver_Amiga::~AudioDriver_Amiga()
{
}

mp_sint32
AudioDriver_Amiga::initDevice(mp_sint32 bufferSizeInWords, mp_uint32 mixFrequency, MasterMixer* mixer)
{
	mp_sint32 res = AudioDriverBase::initDevice(bufferSizeInWords, mixFrequency, mixer);
	if (res < 0)
		return res;

    //            _BB__BDBCBSDAAAA
    // DMACON 23f0 010001111110000
    dmaconOld = custom.dmaconr;

    // Create interrupt for playback
    irqPlayAudio = (struct Interrupt *) AllocMem(sizeof(struct Interrupt), MEMF_PUBLIC | MEMF_CLEAR);
    irqPlayAudio->is_Node.ln_Type = NT_INTERRUPT;
    irqPlayAudio->is_Node.ln_Pri = 127;
    irqPlayAudio->is_Node.ln_Name = (char *) "mt-saga-play-irq";
    irqPlayAudio->is_Data = this;
    irqPlayAudio->is_Code = (void(*)()) playAudioService;

    // Zero volume & disable audio DMA
    setGlobalVolume(0);
    disableDMA();
    disableIRQ();

    // Disable lowpass filter and reset ADKCON
    *((volatile mp_ubyte *) CIAAPRA) |= CIAF_LED;
    custom.adkcon = 0xff;

    mp_sint32 newBufferSize = alloc(bufferSizeInWords);

#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
    printf("Obtained mix frequency: %ld\n", mixFrequency);
    printf("Obtained buffer size: %ld\n", newBufferSize);
#endif

	return newBufferSize;
}

mp_sint32
AudioDriver_Amiga::alloc(mp_sint32 bufferSize)
{
    mp_sint32 ret;
    int i;

    nChannels = getChannels();

    dealloc();

    // Force buffer size of 2^n
    for (mp_uint32 i = 0; i < 16; i++) {
        if ((unsigned)(1 << i) >= (unsigned)bufferSize) {
            bufferSize = 1 << i;
            break;
        }
    }

    // Number of samples to fetch from Milky's ChannelMixer
    // ! Needs to be the same as the requested size
    fetchSize = bufferSize;

    // Number of samples in ring buffer we write into *and* read from at the same time
    ringSize = fetchSize << 2;

    // Number of samples processed via DMA for each audio block
    chunkSize = fetchSize >> 2;

    // Reset ring buffer indices
    idxRead = 0;
    idxWrite = ringSize >> 1;

    // Reset stat values
    statVerticalBlankMixMedian = 0;
    statAudioBufferReset = 0;
    statAudioBufferResetMedian = 0;
    statRingBufferFull = 0;
    statRingBufferFullMedian = 0;
    statCountPerSecond = 0;

    // Allocate driver-specific resources
    if((ret = allocResources()) < 0) {
        printf("%s: could not allocate driver resources (ret = %ld)\n", __PRETTY_FUNCTION__, ret);
        return ret;
    }
    allocated = true;

    // And init the hardware
    initHardware();

    return bufferSize * MP_NUMCHANNELS;
}

void
AudioDriver_Amiga::dealloc()
{
    if(!allocated)
        return;
    allocated = false;

    deallocResources();
}

mp_sint32
AudioDriver_Amiga::closeDevice()
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
#endif
    setGlobalVolume(0);
    disableDMA();
    disableIRQ();

    custom.dmacon = DMAF_SETCLR | dmaconOld;

    dealloc();

    FreeMem(irqPlayAudio, sizeof(struct Interrupt));

	return MP_OK;
}

void
AudioDriver_Amiga::playAudio()
{
    playAudioImpl();

    idxRead += chunkSize;
    if(idxRead >= ringSize)
        idxRead = 0;

    statAudioBufferReset++;

    custom.intreq = INTF_AUD0;
}

void
AudioDriver_Amiga::bufferAudio()
{
    int i, j;

    statCountPerSecond++;
    if(statCountPerSecond == REFRESHRATE) {
        statCountPerSecond = 0;

        statAudioBufferResetMedian = (statAudioBufferResetMedian + statAudioBufferReset) >> 1;
        statAudioBufferReset = 0;

        statRingBufferFullMedian = (statRingBufferFullMedian + statRingBufferFull) >> 1;
        statRingBufferFull = 0;
    }

    // Fetch only if we would not write into the block to read
    mp_sint32 idxDist;
    if(idxRead <= idxWrite)
        idxDist = idxWrite - idxRead;
    else
        idxDist = (ringSize - idxRead) + idxWrite;

    if(idxDist >= fetchSize) {
        mp_uint32 vpos = getVerticalBeamPosition();

        bufferAudioImpl();

        idxWrite += fetchSize;
        if(idxWrite >= ringSize)
            idxWrite = 0;

        mp_uint32 mix = (((getVerticalBeamPosition() - vpos) * 1000000) / SCANLINES) / 10000;
        statVerticalBlankMixMedian = (statVerticalBlankMixMedian + mix) >> 1;
    } else {
        statRingBufferFull++;
    }
}

void
AudioDriver_Amiga::disableIRQ()
{
    custom.intena = INTF_AUD0;

    if(irqEnabled) {
        SetIntVector(INTB_AUD0, irqAudioOld);
        irqAudioOld = NULL;
        irqEnabled = false;
    }
}

void
AudioDriver_Amiga::enableIRQ()
{
    if(!irqEnabled) {
        irqAudioOld = SetIntVector(INTB_AUD0, irqPlayAudio);
        irqEnabled = true;
    }

    custom.intena = INTF_SETCLR | INTF_AUD0;
}

mp_sint32
AudioDriver_Amiga::start()
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
#endif
    setGlobalVolume(MAX_VOLUME);
    enableDMA();
    enableIRQ();

	return MP_OK;
}

mp_sint32
AudioDriver_Amiga::stop()
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
#endif
    setGlobalVolume(0);
    disableDMA();
    disableIRQ();

    return MP_OK;
}

mp_sint32
AudioDriver_Amiga::pause()
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
#endif
    disableDMA();

    return MP_OK;
}

mp_sint32
AudioDriver_Amiga::resume()
{
#if DEBUG_DRIVER
    printf("%s\n", __PRETTY_FUNCTION__);
#endif
    enableDMA();

    return MP_OK;
}

mp_sint32
AudioDriver_Amiga::getStatValue(mp_uint32 key)
{
    switch(key) {
    case 0:
        return statVerticalBlankMixMedian;
    case 1:
        return statAudioBufferResetMedian;
    case 2:
        return statRingBufferFullMedian;
    }

    return 0;
}
