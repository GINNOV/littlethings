/* This program loads a module, and plays it. Uses medplayer.library,
   octaplayer.library and octamixplayer.library, if required. Could be
   used as a small simple replacement of OctaMEDPlayer. */

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <stdio.h>
/* These two must be included in this order. */
#include "libproto.h"
#include "proplayer.h"

void main(int argc,char *argv[])
{
	struct MMD0 *sng;
	struct Library *MEDPlayerBase = NULL,*OctaPlayerBase = NULL,
		*OctaMixPlayerBase = NULL;
	LONG play_routine;
	if(argc < 2) {
		printf("Usage: example2 <song>\n");
		return;
	}
	/* Assume 4-ch mode (medplayer.library)
	   We use V7 to obtain RequiredPlayRoutine */
	MEDPlayerBase = OpenLibrary("medplayer.library",7);
	if(!MEDPlayerBase) {
		printf("Can't open medplayer.library!\n");
		return;
	}
	printf("Loading...\n");
	sng = LoadModule(argv[1]);
	if(!sng) {
		printf("Load error (DOS error #%d).\n",IoErr());
		goto exit;
	}
	/* Test which play routine is required... */
	play_routine = RequiredPlayRoutine(sng);
	if(play_routine > 2) {
		printf("Requires an unknown playing routine!\n");
		goto exit;
	}
	switch(play_routine) {
	case 1:	// octaplayer.library...
		OctaPlayerBase = OpenLibrary("octaplayer.library",0);
		if(!OctaPlayerBase) {
			printf("Can't open octaplayer.library!\n");
			goto exit;
		}
		break;
	case 2: // octamixplayer.library
		OctaMixPlayerBase = OpenLibrary("octamixplayer.library",0);
		if(!OctaMixPlayerBase) {
			printf("Can't open octamixplayer.library!\n");
			goto exit;
		}
	}
	// Then allocate the player and play...
	switch(play_routine) {
	case 0:	// 4-channel
		{
			long count,midi = 0;
	/* Check if it's a MIDI song. We check the MIDI channel of
	each instrument. */
		   	for(count = 0; count < 63; count++)
				if(sng->song->sample[count].midich) midi = 1;
			if(GetPlayer(midi)) {
				printf("Resource allocation failed.\n");
				goto exit;
			}
			PlayModule(sng);
		}
		break;
	case 1: // 5-8-channel
		if(GetPlayer8()) {
			printf("Resource allocation failed.\n");
			goto exit;
		}
		PlayModule8(sng);
		break;
	case 2: // mixing
		if(GetPlayerM()) {
			printf("Resource allocation failed.\n");
			goto exit;
		}
		PlayModuleM(sng);
	}
	printf("Press Ctrl-C to quit.\n");
	Wait(SIGBREAKF_CTRL_C);
exit:
	FreePlayer();
	UnLoadModule(sng);
	CloseLibrary(MEDPlayerBase);
	if(OctaPlayerBase) {
		FreePlayer8();
		CloseLibrary(OctaPlayerBase);
	}
	if(OctaMixPlayerBase) {
		FreePlayerM();
		CloseLibrary(OctaMixPlayerBase);
	}
}
