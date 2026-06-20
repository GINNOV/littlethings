/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998,1999 Olivier Debon
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
///////////////////////////////////////////////////////////////
//  Author : Olivier Debon  <odebon@club-internet.fr>
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#ifndef NOSOUND
#include <linux/soundcard.h>
#endif
#include "sound.h"

static char *rcsid = "$Id: sound.cc,v 1.11 1999/01/31 21:14:22 olivier Exp $";

#define PRINT 0

//////////// SOUND

Sound::Sound(long id) : Character(SoundType, id)
{
	samples = 0;
	stereo = 0;
	soundRate = 0;
	sampleSize = 1;
}

Sound::~Sound()
{
	if (samples) {
		delete samples;
	}
}

void
Sound::setSoundFlags(long f) {
	switch (GET_SOUND_RATE_CODE(f)) {
		case 0:
			soundRate = 5500;
			break;
		case 1:
			soundRate = 11000;
			break;
		case 2:
			soundRate = 22000;
			break;
		case 3:
			soundRate = 44000;
			break;
	}
	if (f & soundIs16bit) {
		sampleSize = 2;
	}
	if (f & soundIsStereo) {
		stereo = 1;
	}

#if PRINT
	printf("-----\nFlags = %2x\n", f);
	printf("Rate = %d kHz  ", soundRate);
	printf("SampleSize = %d byte(s) ", sampleSize);
	if (f & soundIsStereo) {
		printf("Stereo  ");
	} else {
		printf("Mono  ");
	}
	if (f & soundIsADPCMCompressed) {
		printf("ADPCM\n");
	} else {
		printf("Raw\n");
	}
#endif
}

char *
Sound::setNbSamples(long n) {
	long size;

	nbSamples = n;

	size = nbSamples * (stereo ? 2 : 1) * sampleSize;

	samples = new char[ size ];

	memset((char *)samples,0, size);

	return samples;
}

long
Sound::getRate() {
	return soundRate;
}

long
Sound::getChannel() {
	return stereo ? 2 : 1;
}

long
Sound::getNbSamples() {
	return nbSamples;
}

long
Sound::getSampleSize() {
	return sampleSize;
}

char *
Sound::getSamples() {
	return samples;
}

//////////// SOUND MIXER

long SoundMixer::dsp = -1;	// Init of descriptor
long SoundMixer::blockSize = 0;	// Driver sound buffer size
long SoundMixer::nbInst = 0;	// Nb SoundMixer instances
long SoundMixer::sampleSize = 0;
long SoundMixer::stereo = 0;
long SoundMixer::soundRate = 0;

SoundMixer::SoundMixer(char *device)
{
#ifndef NOSOUND
	int status;
	long fmt;

	list = 0;	// No sound to play

	if (nbInst++) {
		// Device is already open
		return;
	}

	dsp = open(device,O_WRONLY);
	if (dsp < 0) {
		perror("open dsp");
		return;
	}

	// Reset device
	status = ioctl(dsp, SNDCTL_DSP_RESET);

	// Set sample size
	fmt = AFMT_S16_LE;
	sampleSize = 2;
	status = ioctl(dsp, SNDCTL_DSP_SETFMT, &fmt);

	if (status) {
		fmt = AFMT_U8;
		sampleSize = 1;
		status = ioctl(dsp, SNDCTL_DSP_SETFMT, &fmt);
	}

	// Set stereo channel
	stereo = 1;
	status = ioctl(dsp, SNDCTL_DSP_STEREO, &stereo);

	if (status) {
		stereo = 0;
	}

	// Set sound rate in Hertz
	soundRate = 11000;
	status = ioctl(dsp, SNDCTL_DSP_SPEED, &soundRate);

	// Get device buffer size
	status = ioctl(dsp, SNDCTL_DSP_GETBLKSIZE, &blockSize);
	blockSize *= 2;

	buffer = (char *)malloc(blockSize);

#if PRINT
	int caps;

	ioctl(dsp,SNDCTL_DSP_GETCAPS, &caps);
	printf("Audio capabilities = %x\n", caps);
#endif /* PRINT */

#endif	/* NOSOUND */
}

SoundMixer::~SoundMixer()
{
	if (--nbInst == 0) {
		close(dsp);
		free(buffer);
	}
}

void
SoundMixer::stopSounds()
{
#ifndef NOSOUND
	SoundList *sl,*del;

	for(sl = list; sl; ) {
		del = sl;
		sl = sl->next;
		delete del;
	}
	list = 0;
#endif
}

void
SoundMixer::startSound(Sound *sound)
{
	SoundList *sl;

	if (sound) {
		// Add sound in list
		sl = new SoundList;
		sl->rate = sound->getRate();
		sl->stereo = (sound->getChannel() == 2);
		sl->sampleSize = sound->getSampleSize();
		sl->current = sound->getSamples();
		sl->remaining = sound->getSampleSize()*sound->getNbSamples()*sound->getChannel();
		sl->next = list;
		list = sl;
	}
}

long
SoundMixer::playSounds()
{
#ifndef NOSOUND
	audio_buf_info	 bufInfo;
	long		 nbBytes, n;
	SoundList	*sl,*prev;
	int		 status;

	// Init failed
	if (dsp < 0) return 0;

	// No sound to play
	if (list == 0) return 0;

	// Get free DMA buffer space
	status = ioctl(dsp, SNDCTL_DSP_GETOSPACE, &bufInfo);

	// Free space is not large enough to output data without blocking
	// But there are still sounds to play. We must wait.
	if (bufInfo.bytes < blockSize) return 1;

	nbBytes = 0;

	// Fill buffer with silence.
	memset((void*)buffer, 0, blockSize);

	prev = 0;
	sl = list;
	while(sl) {

		// Ask sound to fill the buffer
		// according to device capabilities
		n = fillSoundBuffer(sl, buffer, blockSize);

		// Remember the largest written size
		if (n > nbBytes) {
			nbBytes = n;
		}

		// No more samples for this sound
		if (sl->remaining == 0) {
			// Remove sound from list
			if (prev) {
				prev->next = sl->next;
				delete sl;
				sl = prev->next;
			} else {
				list = sl->next;
				delete sl;
				sl = list;
			}
		} else {
			sl = sl->next;
		}
	}

	if (nbBytes) {
		// At last ! Play It !
		write(dsp,buffer,nbBytes);
		status = ioctl(dsp, SNDCTL_DSP_POST);
	}

	return nbBytes;
#else
	return 0;
#endif
}

long
SoundMixer::fillSoundBuffer(SoundList *sl, char *buffer, long bufferSize)
{
	long sampleLeft, sampleRight;
	long skipOut, skipOutInit;
	long skipIn, skipInInit;
	long freqRatio;
	long totalOut = 0;

	freqRatio = sl->rate / soundRate;
	if (freqRatio) {
		skipOutInit = freqRatio - 1;
		skipInInit = 0;
	}

	freqRatio = soundRate / sl->rate;
	if (freqRatio) {
		skipInInit = freqRatio - 1;
		skipOutInit = 0;
	}

	skipOut = skipOutInit;
	skipIn = skipInInit;
	while (bufferSize && sl->remaining) {
		if (skipIn-- == 0) {
			// Get sampleLeft
			if (sl->sampleSize == 2) {
				sampleLeft = (long)(*(short *)(sl->current));
				if (sampleSize == 1) {
					sampleLeft = (sampleLeft >> 8) &0xff;
				}
			} else {
				sampleLeft = (long)*(sl->current);
				if (sampleSize == 2) {
					sampleLeft <<= 8;
				}
			}
			sl->current += sl->sampleSize;
			sl->remaining -= sl->sampleSize;

			if (sl->stereo) {
				// Get sampleRight
				if (sl->sampleSize == 2) {
					sampleRight = (long)(*(short *)(sl->current));
					if (sampleSize == 1) {
						sampleRight = (sampleRight >> 8) &0xff;
					}
				} else {
					sampleRight = (long)*(sl->current);
					if (sampleSize == 2) {
						sampleRight <<= 8;
					}
				}
				sl->current += sl->sampleSize;
				sl->remaining -= sl->sampleSize;

			} else {
				sampleRight = sampleLeft;
			}
			
			skipIn = skipInInit;
		}

		if (skipOut-- == 0) {
			// Output
			if (stereo) {
				if (sampleSize == 2) {
					*((short *)buffer) += sampleLeft/2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
					*((short *)buffer) += sampleRight/2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
				} else {
					*((char *)buffer) += sampleLeft/2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
					*((char *)buffer) += sampleRight/2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
				}
				totalOut += 2*sampleSize;
			} else {
				if (sampleSize == 2) {
					*((short *)buffer) += (sampleLeft+sampleRight)>>2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
				} else {
					*((char *)buffer) += (sampleLeft+sampleRight)>>2;
					bufferSize -= sampleSize;
					buffer += sampleSize;
				}
				totalOut += sampleSize;
			}

			skipOut = skipOutInit;
		}
	}

	return totalOut;
}
