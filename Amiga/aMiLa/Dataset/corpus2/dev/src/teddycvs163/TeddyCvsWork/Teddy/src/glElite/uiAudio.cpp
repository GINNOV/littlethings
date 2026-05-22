
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
	tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\file
	\ingroup g_testing_environment
	\author  Timo Suoranta
	\brief	 This file contains UserInterface Audio management
	\date	 2001
*/


#include "config.h"
#include "SysSupport/Messages.h"
#include "ui.h"
#include <cstdio>


#if defined( WIN32 )
extern "C" {
#include "arch/win32/native_midi.h"
}
#endif

#if defined (HAVE_LIB_SDL_MIXER)

# include "SDL_mixer.h"
# if defined( _MSC_VER)
#  if defined( _DEBUG )
#   pragma comment (lib, "SDLD_mixer.lib")
#  else
#   pragma comment (lib, "SDL_mixer.lib")
#  endif
# endif

static Mix_Chunk *pulse;
static Mix_Chunk *hyper;
static Mix_Chunk *explode;

#else
# include <cstdio>
static void *pulse;
static void *hyper;
static void *explode;
#endif


namespace Application {


void UI::initAudio(){
	init_msg( "UI::initAudio..." );
#	if defined( WIN32 )
	if( isEnabled(ENABLE_AUDIO) == true ){
		native_midi_init();
		init_msg( "native_midi_loadsong..." );
//		NativeMidiSong *music = native_midi_loadsong ( "audio/vangels2-bladerunner.mid" );
		NativeMidiSong *music = native_midi_loadsong ( "audio/adblue.mid" );
		native_midi_start( music );
	}
#	endif

#	ifdef HAVE_LIB_SDL_MIXER
//	signal( SIGINT,  exit );
//	signal( SIGTERM, exit );

	/* Open the audio device */
	if( Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 2048) < 0 ){
		error_msg( MSG_HEAD "Couldn't open audio: %s", SDL_GetError() );
		return;
	}else{
//		Mix_QuerySpec( &audio_rate, &audio_format, &audio_channels );
/*		printf(
			"Opened audio at %d Hz %d bit %s\n",
			audio_rate,
			(audio_format&0xFF),
			(audio_channels > 1) ? "stereo" : "mono"
		);*/
	}

	init_msg( "wav..." );
	pulse   = Mix_LoadWAV( "audio/pulse.wav"   );
	hyper   = Mix_LoadWAV( "audio/hyper.wav"   );
	explode = Mix_LoadWAV( "audio/explode.wav" );
	if( pulse == NULL ){
		warn_msg( "Could not load audio/pulse.wav" );
	}
	if( hyper == NULL ){
		warn_msg( "Could not load audio/hyper.wav" );
	}
	if( explode == NULL ){
		warn_msg( "Could not load audio/explode.wav" );
	}
	//printf( "WAV LOAD DONE\n" );
#	else
	warn_msg( "SDL_mixer was not available when built - Audio disabled" );
#	endif
}


void UI::playPulse  (){ playWav( pulse   ); }									  
void UI::playHyper  (){ playWav( hyper   ); }
void UI::playExplode(){ playWav( explode ); }


void UI::playWav( void *chunk ){
#	ifdef HAVE_LIB_SDL_MIXER
	if( isEnabled(ENABLE_AUDIO) ){
		Mix_PlayChannel( -1, (Mix_Chunk*)chunk, 0 );
		//printf( "audio!!\n" );
	}else{
		//printf( "disabled audio!!\n" );
	}
#	endif
}


};	//	namespace Application

