/*
 * Copyright (c) 2020, neoman
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the <ORGANIZATION> nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "MixerProxy.h"
#include "Mixable.h"
#include "AudioDriverBase.h"
#include "ProxyProcessor.h"

#include <stdio.h>

MixerProxy::MixerProxy(mp_uint32 numChannels, ProxyProcessor * processor)
: numChannels(numChannels)
{
    buffers = new void* [numChannels];
    memset(buffers, 0, numChannels * sizeof(void *));

    if(processor)
        this->processor = processor;
    else
        this->processor = new ProxyProcessor;
}

MixerProxy::~MixerProxy()
{
    delete[] buffers;
}

MixerProxyMixDown::~MixerProxyMixDown()
{
    deleteBuffer<mp_sint32>(MixBuffer);
}

bool MixerProxyMixDown::lock(mp_uint32 bufferSize, mp_uint32 sampleShift)
{
    if(this->bufferSize != bufferSize) {
        deleteBuffer<mp_sint32>(MixBuffer);
        setBuffer<mp_sint32>(MixBuffer, new mp_sint32[bufferSize * MP_NUMCHANNELS]);
    }

    MixerProxy::lock(bufferSize, sampleShift);

    clearBuffer<mp_sint32>(MixBuffer, bufferSize * MP_NUMCHANNELS);

    return true;
}

void MixerProxyMixDown::unlock(Mixable * filterHook)
{
	mp_sint32 * bufferIn = getBuffer<mp_sint32>(MixBuffer);
    mp_sword * bufferOut = getBuffer<mp_sword>(MixDownBuffer);

	if (filterHook)
		filterHook->mix(this);

	const mp_sint32 sampleShift = this->sampleShift;
	const mp_sint32 lowerBound = -((128<<sampleShift)*256);
	const mp_sint32 upperBound = ((128<<sampleShift)*256)-1;
	const mp_sint32 bufferSize = this->bufferSize * MP_NUMCHANNELS;

	for (mp_sint32 i = 0; i < bufferSize; i++) {
		mp_sint32 b = *bufferIn++;

		if (b>upperBound) b = upperBound;
		else if (b<lowerBound) b = lowerBound;

		*bufferOut++ = b>>sampleShift;
	}
}

bool MixerProxyDirectOut::lock(mp_uint32 bufferSize, mp_uint32 sampleShift)
{
    MixerProxy::lock(bufferSize, sampleShift);

    for(int i = 0; i < numChannels; i++) {
        clearBuffer<mp_sword>(i, bufferSize * MP_NUMCHANNELS);
    }

    return true;
}

bool MixerProxyHardwareOut::lock(mp_uint32 bufferSize, mp_uint32 sampleShift)
{
    return true;
}
