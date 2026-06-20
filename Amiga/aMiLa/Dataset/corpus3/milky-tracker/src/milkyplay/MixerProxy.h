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

#ifndef __MIXER_PROXY_H__
#define __MIXER_PROXY_H__

#include "MilkyPlayTypes.h"

#include <string.h>

#define MAX_DIRECTOUT_CHANNELS 16

//
// Intermediate structure as glue between the mixer and the driver
// This one can be quite interdisciplinary.
//

struct Mixable;
class ProxyProcessor;

class MixerProxy
{
public:
	enum ProcessingType {
		MixDown,
		DirectOut,
		HardwareOut
	};

protected:
	ProxyProcessor * 	processor;
	mp_uint32 			numChannels;
	void **				buffers;
	mp_uint32 			bufferSize;
	mp_uint32 			sampleShift;

public:
	template <class SampleType>
	void setBuffer(mp_uint32 idx, SampleType * buffer) {
		buffers[idx] = buffer;
	}

	template <class SampleType>
	void deleteBuffer(mp_uint32 idx) {
		delete[] reinterpret_cast<SampleType *>(buffers[idx]);
	}

	template <class SampleType>
	void clearBuffer(mp_uint32 idx, mp_uint32 clearSize) {
		memset(getBuffer<SampleType>(idx), 0, clearSize * sizeof(SampleType));
	}

	template <class SampleType>
	void advanceBuffer(mp_uint32 idx, mp_uint32 offset) {
		reinterpret_cast<SampleType **>(buffers)[idx] += offset;
	}

	template <class SampleType>
	SampleType * getBuffer(mp_uint32 idx) const {
		return (SampleType *) buffers[idx];
	}

	virtual bool lock(mp_uint32 bufferSize, mp_uint32 sampleShift) {
		this->bufferSize = bufferSize;
		this->sampleShift = sampleShift;

		return true;
	}

	virtual void 			unlock(Mixable * filterHook) { }
	virtual ProcessingType 	getProcessingType() const = 0;
	virtual mp_uint32       getNumChannels() const { return numChannels; }

	ProxyProcessor *     	getProcessor() { return processor; }
	mp_uint32 				getBufferSize() const { return bufferSize; }
	mp_uint32 				getSampleShift() const { return sampleShift; }

	MixerProxy(mp_uint32 numChannels, ProxyProcessor * processor);
	virtual ~MixerProxy();
};

class MixerProxyMixDown : public MixerProxy
{
public:
	enum {
		MixBuffer = 0,
		MixDownBuffer = 1
	};

	virtual bool 			lock(mp_uint32 bufferSize, mp_uint32 sampleShift);
	virtual void 			unlock(Mixable * filterHook);
	virtual ProcessingType	getProcessingType() const { return MixDown; }

	MixerProxyMixDown(mp_uint32 numChannels = 2, ProxyProcessor * processor = 0) : MixerProxy(numChannels, processor) {}
	virtual ~MixerProxyMixDown();
};

class MixerProxyDirectOut : public MixerProxy
{
public:
	virtual bool 			lock(mp_uint32 bufferSize, mp_uint32 sampleShift);
	virtual ProcessingType	getProcessingType() const { return DirectOut; }

	MixerProxyDirectOut(mp_uint32 numChannels, ProxyProcessor * processor = 0) : MixerProxy(numChannels, processor) {}
	virtual ~MixerProxyDirectOut() {}
};

class MixerProxyHardwareOut : public MixerProxy
{
public:
	virtual bool 			lock(mp_uint32 bufferSize, mp_uint32 sampleShift);
	virtual ProcessingType	getProcessingType() const { return HardwareOut; }

	MixerProxyHardwareOut(mp_uint32 numChannels, ProxyProcessor * processor = 0) : MixerProxy(numChannels, processor) {}
	virtual ~MixerProxyHardwareOut() {}
};

#endif
