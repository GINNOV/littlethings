#include <sge.h>

int sgeDefaultSampleRate=44100;

void sgeSetDefaultSampleRate(int rate) {
	sgeDefaultSampleRate=rate;
}

int sgeGetDefaultSampleRate() {
	return sgeDefaultSampleRate;
}

int sgeGlobalVolume=MIX_MAX_VOLUME;

void sgeSetVolume(int volume) {
	sgeGlobalVolume=volume;
	Mix_Volume(-1, volume);
}

int sgeGetVolume() {
	return sgeGlobalVolume;
}

SGESOUND *sgeSoundNew(SGEFILE *f, const char *name) {
	SGESOUND *ret;
	sgeNew(ret, SGESOUND);
	ret->data=sgeReadSound(f, name);
	ret->playing=0;
	ret->channel=-1;
	return ret;
}

void sgeSoundDestroy(SGESOUND *m) {
	if (m->playing) {
		Mix_HaltChannel(m->channel);
	}
	Mix_FreeChunk(m->data);
	sgeFree(m);
}

void sgeSoundPlay(SGESOUND *m, int loop, int fadeinms) {
	if (m->playing) return;

	if (fadeinms==0) {
		m->channel=Mix_PlayChannel(-1, m->data, loop);
	} else {
		m->channel=Mix_FadeInChannel(-1, m->data, loop, fadeinms);
	}
	m->playing=1;
}

void sgeSoundStop(SGESOUND *m, int fadeoutms) {
	if (!m->playing) return;

	if (fadeoutms==0) {
		Mix_HaltChannel(m->channel);
	} else {
		Mix_FadeOutChannel(m->channel, fadeoutms);
	}
	m->channel=-1;
	m->playing=0;
}

int sgeSoundIsPlaying(SGESOUND *m) {
	if (m->channel<0) return 0;
	return Mix_Playing(m->channel);
}
