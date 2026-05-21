/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2026 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_internal.h"

#if SDL_AUDIO_DRIVER_AMIGAOS4

#include "../SDL_audio_c.h"
#include "../SDL_sysaudio.h"
#include "SDL_os4audio.h"

#include "../../main/amigaos4/SDL_os4debug.h"

#include <proto/exec.h>

#define AHI_AUDIO_BUFFER_SIZE 4096

static bool
OS4_OpenAhiDevice(OS4AudioData * os4data)
{
    if (os4data->deviceOpen) {
        dprintf("Device already open\n");
    }

    os4data->deviceOpen = false;

    os4data->ahiReplyPort = (struct MsgPort *)IExec->AllocSysObjectTags(ASOT_PORT, TAG_DONE);

    if (os4data->ahiReplyPort) {

        /* create a iorequest for the device */
        os4data->ahiRequest[0] = (struct AHIRequest *)
            IExec->AllocSysObjectTags(
                ASOT_IOREQUEST,
                ASOIOR_ReplyPort, os4data->ahiReplyPort,
                ASOIOR_Size,      sizeof(struct AHIRequest),
                TAG_DONE);

        if (os4data->ahiRequest[0]) {

            if (!IExec->OpenDevice(AHINAME, 0, (struct IORequest *)os4data->ahiRequest[0], 0)) {

                dprintf("%s opened\n", AHINAME);

                /* Create a copy */
                os4data->ahiRequest[1] = (struct AHIRequest *)
                    IExec->AllocSysObjectTags(
                        ASOT_IOREQUEST,
                        ASOIOR_Duplicate, os4data->ahiRequest[0],
                        TAG_DONE);

                if (os4data->ahiRequest[1]) {

                    dprintf("IO requests created\n");

                    os4data->deviceOpen = true;
                    os4data->currentBuffer = 0;
                    os4data->link = NULL;
                } else {
                    dprintf("Failed to duplicate IO request\n");
                }
            } else {
                dprintf("Failed to open %s\n", AHINAME);
            }
        } else {
            dprintf("Failed to create IO request\n");
        }
    } else {
        dprintf("Failed to create reply port\n");
    }

    dprintf("deviceOpen = %d\n", os4data->deviceOpen);
    return os4data->deviceOpen;
}

static void
OS4_CloseAhiDevice(OS4AudioData * os4data)
{
    if (os4data->ahiRequest[0]) {
        if (os4data->link) {
            dprintf("Aborting I/O...\n");

            IExec->AbortIO((struct IORequest *)os4data->link);
            IExec->WaitIO((struct IORequest *)os4data->link);
        }

        dprintf("Closing device\n");
        IExec->CloseDevice((struct IORequest *)os4data->ahiRequest[0]);

        dprintf("Freeing I/O requests\n");
        IExec->FreeSysObject(ASOT_IOREQUEST, os4data->ahiRequest[0]);
        os4data->ahiRequest[0] = NULL;

        if (os4data->ahiRequest[1]) {
            IExec->FreeSysObject(ASOT_IOREQUEST, os4data->ahiRequest[1]);
            os4data->ahiRequest[1] = NULL;
        }
    }

    if (os4data->ahiReplyPort) {
        dprintf("Deleting message port\n");
        IExec->FreeSysObject(ASOT_PORT, os4data->ahiReplyPort);
        os4data->ahiReplyPort = NULL;
    }

    os4data->deviceOpen = false;

    dprintf("Device closed\n");
}

static bool
OS4_AudioAvailable(void)
{
    bool isAvailable = false;

    OS4AudioData *tempData = SDL_calloc(1, sizeof(OS4AudioData));

    if (!tempData) {
        dprintf("Failed to allocate temp data\n");
    } else {
        isAvailable = OS4_OpenAhiDevice(tempData);

        OS4_CloseAhiDevice(tempData);

        SDL_free(tempData);
    }

    dprintf("AHI is %savailable\n", isAvailable ? "" : "not ");
    return isAvailable;
}

static int
OS4_SwapBuffer(int current)
{
    return (1 - current);
}

static void
OS4_FillCaptureRequest(struct AHIRequest * request, void * buffer, int length, int frequency, int type)
{
    request->ahir_Std.io_Message.mn_Node.ln_Pri = 60;
    request->ahir_Std.io_Data    = buffer,
    request->ahir_Std.io_Length  = length;
    request->ahir_Std.io_Command = CMD_READ;
    request->ahir_Volume         = 0x10000;
    request->ahir_Position       = 0x8000;
    request->ahir_Link           = NULL;
    request->ahir_Frequency      = frequency;
    request->ahir_Type           = type;
}

/* ---------------------------------------------- */
/* Audio driver exported functions implementation */
/* ---------------------------------------------- */
static void
OS4_CloseDevice(SDL_AudioDevice *_this)
{
    OS4AudioData *os4data = _this->hidden;

    dprintf("Called for device %p\n", _this);

    OS4_CloseAhiDevice(os4data);

    int i;
    for (i = 0; i < 2; i++) {
        if (os4data->audioBuffer[i]) {
            SDL_free(os4data->audioBuffer[i]);
            os4data->audioBuffer[i] = NULL;
        }
    }

    SDL_free(os4data);
}

static void
OS4_DetectDevices(SDL_AudioDevice **default_output, SDL_AudioDevice **default_capture)
{
    dprintf("Called\n");

    SDL_AudioSpec output, capture;

    output.freq = 44100;
    output.format = SDL_AUDIO_S16BE;
    output.channels = 2;

    capture.freq = output.freq;
    capture.format = output.format;
    capture.channels = 1;

    *default_output = SDL_AddAudioDevice(/*iscapture=*/false, "AHI default output device", &output, SDL_strdup("default"));
    *default_capture = SDL_AddAudioDevice(/*iscapture=*/true, "AHI default capture device", &capture, SDL_strdup("default"));

    dprintf("Default_output device %p, default_capture device %p\n", *default_output, *default_capture);
}

static bool
OS4_OpenDevice(SDL_AudioDevice *_this)
{
    OS4AudioData *os4data = NULL;

    dprintf("Called for device %p\n", _this);

    _this->hidden = (OS4AudioData *) SDL_malloc(sizeof(OS4AudioData));

    if (!_this->hidden) {
        dprintf("Failed to allocate private data\n");
        return SDL_OutOfMemory();
    }

    SDL_memset(_this->hidden, 0, sizeof(OS4AudioData));
    os4data = _this->hidden;

    switch (_this->spec.format & 0xFF) {
        case 8:
            dprintf("8-bits requested, use SDL_AUDIO_S8\n");
            _this->spec.format = SDL_AUDIO_S8;
            break;
        case 16:
            dprintf("16 bits requested, use SDL_AUDIO_S16BE\n");
            _this->spec.format = SDL_AUDIO_S16BE;
            break;
        case 32:
            dprintf("32 bits requested, use SDL_AUDIO_S32BE\n");
            _this->spec.format = SDL_AUDIO_S32BE;
            break;
        default:
            dprintf("%u bits requested, fallback to SDL_AUDIO_S16BE\n", _this->spec.format & 0xFF);
            _this->spec.format = SDL_AUDIO_S16BE;
            break;
    }

    /* AHI supports 1, 2 or 8 channels sound: 3-7 channels may be converted to 7.1 format */
    if (_this->spec.channels < 1 || _this->spec.channels > 8) {
        dprintf("%u channels requested, fallback to stereo", _this->spec.channels);
        _this->spec.channels = 2;
    } else if (_this->spec.channels > 2) {
        dprintf("%u channels requested, use 8 channel SDL_AUDIO_S32BE\n", _this->spec.channels);
        _this->spec.channels = 8;
        _this->spec.format = SDL_AUDIO_S32BE;
    }

    SDL_UpdatedAudioDeviceFormat(_this);

    os4data->audioBufferSize = AHI_AUDIO_BUFFER_SIZE;
    os4data->audioBuffer[0] = (Uint8 *) SDL_malloc(os4data->audioBufferSize);
    os4data->audioBuffer[1] = (Uint8 *) SDL_malloc(os4data->audioBufferSize);

    dprintf("SDL audio format = 0x%x\n", _this->spec.format);
    dprintf("Buffer size = %u bytes\n", os4data->audioBufferSize);
    dprintf("Channels = %u\n", _this->spec.channels);

    if (os4data->audioBuffer[0] == NULL || os4data->audioBuffer[1] == NULL) {
        OS4_CloseDevice(_this);
        dprintf("No memory for audio buffer\n");
        SDL_SetError("No memory for audio buffer");
        return false;
    }

    SDL_memset(os4data->audioBuffer[0], SDL_GetSilenceValueForFormat(_this->spec.format), os4data->audioBufferSize);
    SDL_memset(os4data->audioBuffer[1], SDL_GetSilenceValueForFormat(_this->spec.format), os4data->audioBufferSize);

    /* Decide AHI format */
    switch(_this->spec.format) {
        case SDL_AUDIO_S8:
            os4data->ahiType = (_this->spec.channels < 2) ? AHIST_M8S : AHIST_S8S;
            break;

        case SDL_AUDIO_S16BE:
            os4data->ahiType = (_this->spec.channels < 2) ? AHIST_M16S : AHIST_S16S;
            break;

        case SDL_AUDIO_S32BE:
            switch (_this->spec.channels) {
                case 1:
                    os4data->ahiType = AHIST_M32S;
                    break;
                case 2:
                    os4data->ahiType = AHIST_S32S;
                    break;
                case 8:
                    os4data->ahiType = AHIST_L7_1;
                    break;
                default:
                    dprintf("Unsupported channel count %u for 32-bit mode\n", _this->spec.channels);
                    os4data->ahiType = AHIST_M32S;
                    break;
            }
            break;

        default:
            dprintf("Unsupported audio format 0x%X requested\n", _this->spec.format);
            os4data->ahiType = (_this->spec.channels < 2) ? AHIST_M16S : AHIST_S16S;
            break;
    }

    dprintf("AHI format 0x%lX\n", os4data->ahiType);

    return true;
}

static void
OS4_ThreadInit(SDL_AudioDevice *_this)
{
    OS4AudioData *os4data = _this->hidden;

    dprintf("Called for device %p\n", _this);

    /* Signal must be opened in the task which is using it (player) */
    if (!OS4_OpenAhiDevice(os4data)) {
        // FIXME: this is bad. We have failed and SDL core doesn't know about that.
        dprintf("Failed to open AHI\n");
    }

    /* This will cause a lot of problems.. and should be removed.

    One possibility: create a configuration GUI or ENV variable that allows
    user to select priority, if there is no silver bullet value */
    IExec->SetTaskPri(IExec->FindTask(NULL), 5);
}

static void
OS4_ThreadDeinit(SDL_AudioDevice *_this)
{
    dprintf("Called for device %p\n", _this);
}

static bool
OS4_WaitDevice(SDL_AudioDevice *_this)
{
    /* Dummy - OS4_PlayDevice handles the waiting */
    //dprintf("Called\n");
    return true;
}

#define SDL_FC  2
#define SDL_LFE 3
#define SDL_BL  4
#define SDL_BR  5
#define SDL_SL  6
#define SDL_SR  7

#define AHI_BL  2
#define AHI_BR  3
#define AHI_SL  4
#define AHI_SR  5
#define AHI_FC  6
#define AHI_LFE 7

static void
OS4_RemapSurround(Sint32* buffer, int samples)
{
    int i;
    for (i = 0; i < samples; i++) {
        Sint32 bl, br, sl, sr, fc, lfe;

        bl = buffer[SDL_BL];
        br = buffer[SDL_BR];
        sl = buffer[SDL_SL];
        sr = buffer[SDL_SR];
        fc = buffer[SDL_FC];
        lfe = buffer[SDL_LFE];

        buffer[AHI_BL] = bl;
        buffer[AHI_BR] = br;
        buffer[AHI_SL] = sl;
        buffer[AHI_SR] = sr;
        buffer[AHI_FC] = fc;
        buffer[AHI_LFE] = lfe;

        buffer += 8;
    }
}

static bool
OS4_PlayDevice(SDL_AudioDevice *_this, const Uint8 *buffer, int buflen)
{
    struct AHIRequest  *ahiRequest;
    SDL_AudioSpec      *spec    = &_this->spec;
    OS4AudioData       *os4data = _this->hidden;
    int                 current = os4data->currentBuffer;

    //dprintf("Called\n");

    if (!os4data->deviceOpen) {
        dprintf("Device is not open\n");
        return false;
    }

    ahiRequest = os4data->ahiRequest[current];

    ahiRequest->ahir_Std.io_Message.mn_Node.ln_Pri = 60;
    ahiRequest->ahir_Std.io_Data    = os4data->audioBuffer[current];
    ahiRequest->ahir_Std.io_Length  = os4data->audioBufferSize;
    ahiRequest->ahir_Std.io_Offset  = 0;
    ahiRequest->ahir_Std.io_Command = CMD_WRITE;
    ahiRequest->ahir_Volume         = 0x10000;
    ahiRequest->ahir_Position       = 0x8000;
    ahiRequest->ahir_Link           = os4data->link;
    ahiRequest->ahir_Frequency      = spec->freq;
    ahiRequest->ahir_Type           = os4data->ahiType;

    /* Let SDL handle possible conversions between formats, channels etc., but
       because order of 7.1 channels is different (AHI <-> SDL), remap it here */

    if (spec->channels == 8) {
        OS4_RemapSurround((Sint32 *)os4data->audioBuffer[current], os4data->audioBufferSize/sizeof(Sint32)/8 /* TODO: FIXME */);
    }

    IExec->SendIO((struct IORequest *)ahiRequest);

    if (os4data->link) {
        IExec->WaitIO((struct IORequest *)os4data->link);
    }

    os4data->link = ahiRequest;
    os4data->currentBuffer = OS4_SwapBuffer(current);

    return true;
}

static Uint8 *
OS4_GetDeviceBuf(SDL_AudioDevice *_this, int *buffer_size)
{
    //dprintf("Called for device %p\n", _this);

    if (buffer_size) {
        OS4AudioData *os4data = _this->hidden;

        *buffer_size = os4data->audioBufferSize;
    }

    return _this->hidden->audioBuffer[_this->hidden->currentBuffer];
}

static bool
OS4_WaitRecordingDevice(SDL_AudioDevice *device)
{
    dprintf("Called for device %p\n", device);
    return true;
}

#ifndef MIN
#define MIN(a, b) (a) < (b) ? (a) : (b)
#endif

#define RESTART_CAPTURE_THRESHOLD 500

static int
OS4_RecordDevice(SDL_AudioDevice *_this, void * buffer, int buflen)
{
    struct AHIRequest  *request;
    SDL_AudioSpec      *spec    = &_this->spec;
    OS4AudioData       *os4data = _this->hidden;
    Uint32 now;
    size_t copyLen;
    void *completedBuffer;
    int current;

    //dprintf("Called for device %p, buffer %p, buflen %d, spec %p\n", _this, buffer, buflen, spec);

    if (!os4data->deviceOpen) {
        dprintf("Device is not open\n");
        return 0;
    }

    now = SDL_GetTicks();
    current = os4data->currentBuffer;
    request = os4data->ahiRequest[0];

    if (os4data->lastCaptureTicks == 0 || (now - os4data->lastCaptureTicks) > RESTART_CAPTURE_THRESHOLD) {
        if (os4data->link) {
            IExec->WaitIO((struct IORequest *)os4data->link);
        }

        /* Assume that we have to (re)start recording */
        OS4_FillCaptureRequest(
            request,
            os4data->audioBuffer[current],
            os4data->audioBufferSize,
            spec->freq,
            os4data->ahiType);

        request->ahir_Std.io_Offset = 0;

        dprintf("Start recording\n");

        IExec->DoIO((struct IORequest *)request);
        os4data->link = NULL;

        current = OS4_SwapBuffer(current);
    } else {
        /* Wait for the previous request completion */
        if (os4data->link) {
            IExec->WaitIO((struct IORequest *)os4data->link);
        }
    }

    OS4_FillCaptureRequest(
        request,
        os4data->audioBuffer[current],
        os4data->audioBufferSize,
        spec->freq,
        os4data->ahiType);

    IExec->SendIO((struct IORequest *)request);
    os4data->link = request;

    current = OS4_SwapBuffer(current);

    completedBuffer = os4data->audioBuffer[current];

    copyLen = MIN(buflen, os4data->audioBufferSize);

    SDL_memcpy(buffer, completedBuffer, copyLen);

    os4data->lastCaptureTicks = now;
    os4data->currentBuffer = current;

    //dprintf("%d bytes copied\n", copyLen);

    return copyLen;
}

static void
OS4_FlushRecording(SDL_AudioDevice *this)
{
    dprintf("Called\n");
}

static void
OS4_FreeDeviceHandle(SDL_AudioDevice *device)
{
    dprintf("Called\n");
}

static void
OS4_DeinitializeStart(void)
{
    dprintf("Called\n");
}

static void
OS4_Deinitialize(void)
{
    dprintf("Called\n");
}

/* ------------------------------------------ */
/* Audio driver init functions implementation */
/* ------------------------------------------ */
static bool
OS4_Init(SDL_AudioDriverImpl * impl)
{
    if (!OS4_AudioAvailable()) {
        SDL_SetError("Failed to open AHI device");
        return false;
    }

    impl->DetectDevices = OS4_DetectDevices;
    impl->OpenDevice = OS4_OpenDevice;
    impl->ThreadInit = OS4_ThreadInit;
    impl->ThreadDeinit = OS4_ThreadDeinit;
    impl->WaitDevice = OS4_WaitDevice;
    impl->PlayDevice = OS4_PlayDevice;
    impl->GetDeviceBuf = OS4_GetDeviceBuf;
    impl->WaitRecordingDevice = OS4_WaitRecordingDevice;
    impl->RecordDevice = OS4_RecordDevice;
    impl->FlushRecording = OS4_FlushRecording;
    impl->CloseDevice = OS4_CloseDevice;
    impl->FreeDeviceHandle = OS4_FreeDeviceHandle;
    impl->DeinitializeStart = OS4_DeinitializeStart;
    impl->Deinitialize = OS4_Deinitialize;

    impl->ProvidesOwnCallbackThread = false;
    impl->HasRecordingSupport = true;
    impl->OnlyHasDefaultPlaybackDevice = true;
    impl->OnlyHasDefaultRecordingDevice = true;

    return true;
}

AudioBootStrap AMIGAOS4AUDIO_bootstrap = {
    "amigaos4", "AmigaOS 4 AHI audio", OS4_Init, false
};
#endif
