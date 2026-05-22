/* Mix: a simple SDL_mixer based test application
   Copyright (C) 2004 Angelo "Encelo" Theodorou

   In order to load music, just copy a file called music.ogg into 
   the directory where the program is located.
                                                                                
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
                                                                                
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
                                                                                
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

   NOTE:

   This program is part of "Mars, Land of No Mercy" SDL examples, 
   you can find others examples on http://mars.sourceforge.net
*/

#include <stdlib.h>
#include <SDL/SDL.h>
#include <SDL/SDL_mixer.h>

void handleKey(SDL_KeyboardEvent key);


Mix_Music *music;
Mix_Chunk *sample1, *sample2, *sample3;

int main(int argc, char **argv)
{
	SDL_Surface *screen;
	SDL_Event event;
	Uint8 *keys;
	int quit = 0;
	
	int frequency = 44100;
	Uint16 format = MIX_DEFAULT_FORMAT; /* It's the same of AUDIO_S16SYS */
	int channels = MIX_DEFAULT_CHANNELS; /* Stereo */
	int buffers = 2048;
	
	Uint8 left = 127;
	int volume = MIX_MAX_VOLUME;

	char *music_file, *sample1_file, *sample2_file, *sample3_file;
	
	/* Parsing shell parameters */
	if (argc == 1) {
		music_file = "music.ogg";
		sample1_file = "sample1.ogg";
		sample2_file = "sample2.ogg";
		sample3_file = "sample3.ogg";
	} 
	else if (argc == 5) {
		music_file = argv[1];
		sample1_file = argv[2];
		sample2_file = argv[3];
		sample3_file = argv[4];
	}
	else {
		printf("The correct syntax is: %s music sample1 sample2 sample3\n", argv[0]);
		exit(-1);
	}
	
	/* Initializing video and audio subsystems */
	if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO) < 0) {
		printf("SDL_Init error: %s\n", SDL_GetError());
		exit (-1);
	}
	
	/* Calling SDL_Quit at exit */
        atexit(SDL_Quit);

	/* Opening a window to catch user events */
	if ((screen = SDL_SetVideoMode(320, 240, 0, 0)) == NULL) {
		printf("SDL_SetVideoMode error: %s\n", SDL_GetError());
		exit (-1);
	}		
	
	/* Opening audio device */
	if (Mix_OpenAudio(frequency, format, channels, buffers) == -1) {
		printf("Mix_OpenAudio error: %s\n", Mix_GetError());
		exit(-1);
	}

	/* Set allocated channels number to 4, we don't need more */
	Mix_AllocateChannels(4);
	
	/* Analyzing system audio specifications */
	int numtimesopened;
	numtimesopened = Mix_QuerySpec(&frequency, &format, &channels);
	if (!numtimesopened)
		printf("Mix_QuerySpec error: %s\n", Mix_GetError());
	else {
		char *format_str="Unknown";
		switch (format) {
			case AUDIO_U8:
				format_str="U8";
				break;
			case AUDIO_S8:
				format_str="S8";
				break;
			case AUDIO_U16LSB:
				format_str="U16LSB";
				break;
			case AUDIO_S16LSB:
				format_str="S16LSB";
				break;
			case AUDIO_U16MSB:
				format_str="U16MSB";
				break;
			case AUDIO_S16MSB:
				format_str="S16MSB";
				break;
		}

	printf("The audio devices was opened %d times\n", numtimesopened);
	printf("System audio specifications:\n");
	printf("Frequency = %d\n", frequency);
	printf("Format = %s\n", format_str);
	printf("Channels = %d\n\n", channels);
	}
	
	/* Loading the music */
	if ((music = Mix_LoadMUS(music_file)) == NULL)
		printf("Error in music loading: %s\n", Mix_GetError());

	/* Loading audio samples */
	if ((sample1 = Mix_LoadWAV(sample1_file)) == NULL)
		printf("Error loading sample 1: %s\n", Mix_GetError());
	if ((sample2 = Mix_LoadWAV(sample2_file)) == NULL)
		printf("Error loading sample 2: %s\n", Mix_GetError());
	if ((sample3 = Mix_LoadWAV(sample3_file)) == NULL)
		printf("Error loading sample 3: %s\n", Mix_GetError());

	/* Registering central panning effect */
	Mix_SetPanning(MIX_CHANNEL_POST, 127, 127);

	/* User events handling cycle */
	while (!quit) {
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
			case SDL_QUIT:
				quit = 1;
				break;
			case SDL_KEYDOWN:
				handleKey(event.key);
				break;
			}
			/* Escape or Q key quits the program */
			if (event.key.keysym.sym == SDLK_ESCAPE || event.key.keysym.sym == SDLK_q) 
				quit = 1; 
		}
	
		keys = SDL_GetKeyState(NULL);

		/* Arrow up raises the volume */
		if (keys[SDLK_UP]) {
			if (volume < MIX_MAX_VOLUME) {
				volume += 4;
				Mix_Volume(-1, volume);
				Mix_VolumeMusic(volume);
				printf("Volume = %d\n", volume);
			}
		}

		/* Arrow down lowers the volume */
		if (keys[SDLK_DOWN]) {
			if (volume > 0) {
				volume -= 4;
				Mix_Volume(-1, volume);
				Mix_VolumeMusic(volume);
				printf("Volume = %d\n", volume);
			}
		}

		/* Left arrow moves the pan to the left */
		if (keys[SDLK_LEFT]) {
			if (left < 250) {
				left += 4;
				Mix_SetPanning(MIX_CHANNEL_POST, left, 254-left);
				printf("Panning = L:%d, R:%d\n", left, 254-left);
			}
		}

		/* Right arrow moves the pan to the right */
		if (keys[SDLK_RIGHT]) {
			if (left > 4) {
				left -= 4;
				Mix_SetPanning(MIX_CHANNEL_POST, left, 254-left);
				printf("Panning = L:%d, R:%d\n", left, 254-left);
			}
		}
	
		/* Let the CPU breath between two polls */
		SDL_Delay(50);
	}

	/* Freeing memory allocated for samples and music and closing the audio device */
	Mix_FreeChunk(sample3);
	Mix_FreeChunk(sample2);
	Mix_FreeChunk(sample1);
	Mix_FreeMusic(music);
	Mix_CloseAudio();
	SDL_Quit();

	return 0;	
}

/* Handles the SDL_KeyboardEvent structure to reply to keyboard input */
void handleKey(SDL_KeyboardEvent key)
{
	switch(key.keysym.sym) {
	/* C key resets the panning to the centre */
	case SDLK_c:
		Mix_SetPanning(MIX_CHANNEL_POST, 127, 127);
		printf("Panning = Central\n");
		break;
	/* F key alternatively fades in and out the music */	
	case SDLK_f:
		if (Mix_PlayingMusic())
			Mix_FadeOutMusic(3000);
		else
			Mix_FadeInMusic(music, -1, 3000);
		break;
	/* M key plays and stops the music */
	case SDLK_m:
		if (Mix_PlayingMusic())
			Mix_HaltMusic();
		else
			Mix_PlayMusic(music, -1);
		break;
	/* P key pauses and resumes the music */
	case SDLK_p:
		if (Mix_PausedMusic())
			Mix_ResumeMusic();
		else
			Mix_PauseMusic();
		break;
	/* 1 key (both keyboard and keypad) plays the 1st sample mixed with the rest */
	case SDLK_1:
	case SDLK_KP1:
		Mix_PlayChannel(1, sample1, 0);
		break;
	/* 2 key (both keyboard and keypad) plays the 2nd sample mixed with the rest */
	case SDLK_2:
	case SDLK_KP2:
		Mix_PlayChannel(2, sample2, 0);
		break;
	/* 3 key (both keyboard and keypad) plays the 3rd sample mixed with the rest */
	case SDLK_3:
	case SDLK_KP3:
		Mix_PlayChannel(3, sample3, 0);
		break;
	}
}
