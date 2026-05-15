/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/contrib/managers/audio_mixer.h>
#include <ace/managers/memory.h>
#include <ace/managers/system.h>
#include <hardware/intbits.h>
#include <hardware/dmabits.h>
#include "mixer_control.h"

extern MXMixer mixer;
static ULONG s_ulBufferSize;
static void *s_pBuffer;

static void onChannelInterrupt(
	UNUSED_ARG REGARG(volatile tCustom *pCustom, "a0"),
	UNUSED_ARG REGARG(volatile void *pData, "a1")
) {
	MixerIRQHandler();
}

//---------------------------------------------------------------- ASM CALLBACKS

__attribute__((used))
void mixerEnableAudioDma(void) {
	systemSetDmaMask(DMAF_AUD3, 1);
}

__attribute__((used))
void mixerDisableAudioDma(void) {
	systemSetDmaMask(DMAF_AUD3, 0);
}

__attribute__((used))
void mixerEnableAudioInterrupts(void) {
	systemSetInt(INTB_AUD3, onChannelInterrupt, 0);
}

__attribute__((used))
void mixerDisableAudioInterrupts(void) {
	systemSetInt(INTB_AUD3, 0, 0);
}

//------------------------------------------------------------------- PUBLIC FNS

void audioMixerCreate(void) {
	s_ulBufferSize = MixerGetBufferSize();
	s_pBuffer = memAllocChip(s_ulBufferSize);

	MixerSetup(s_pBuffer, MIX_PAL);

	// Install interrupt handlers - equivalent of MixerInstallHandler()
	mixerEnableAudioInterrupts();
	mixer.mx_status = MIXER_RUNNING;
	mixer.mx_irq_bits = INTF_AUD3; // TODO: sync with config.mixer_output_channels

	MixerStart();
}

void audioMixerDestroy(void) {
	MixerStop();

	// Uninstall interrupt handlers - equivalent of MixerRemoveHandler()
	mixer.mx_status = MIXER_STOPPED;
	systemSetInt(INTB_AUD3, 0, 0);

	memFree(s_pBuffer, s_ulBufferSize);
}

void audioMixerPlaySfx(
	const tPtplayerSfx *pSfx, UBYTE ubMixerChannel, WORD wPriority, UBYTE isLoop
) {
	MixerPlayChannelSample(
		pSfx->pData, DMAF_AUD3 | (MIX_CH0 << ubMixerChannel),
		pSfx->uwWordLength * sizeof(UWORD), wPriority,
		isLoop ? MIX_FX_LOOP : MIX_FX_ONCE
	);
}

void audioMixerStopSfxOnChannel(UBYTE ubMixerChannel) {
	MixerStopFX(DMAF_AUD3 | (MIX_CH0 << ubMixerChannel));
}

UBYTE audioMixerIsPlaybackDone(void) {
	return mixer.mx_mixer_entries[0].mxe_channels[0].mch_status == 0;
}

void audioMixerSetVolume(UBYTE ubVolume) {
	MixerVolume(ubVolume);
}
