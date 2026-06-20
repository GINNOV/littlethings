/* This program loads a module, and plays it. Uses medplayer.library, and
   octaplayer.library if required. Could be used as a small replacement of
   (Octa)MEDPlayer. */

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
/* These two must be included in this order. */
#include "libproto.h"
#include "proplayer.h"

void main(argc,argv)
int argc;
char *argv[];
{
	struct MMD0 *sng;
	register struct Library *MEDPlayerBase = 0L,*OctaPlayerBase = 0L;
	if(argc < 2) {
		printf("Usage: example2 <song>\n");
		return;
	}
	MEDPlayerBase = OpenLibrary("medplayer.library",0);
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
	/* Now, test if it's 5 - 8 channel module */
	if(sng->song->flags & FLAG_8CHANNEL) {
		OctaPlayerBase = OpenLibrary("octaplayer.library",0);
		if(!OctaPlayerBase) {
			printf("Can't open octaplayer.library!\n");
			goto exit;
		}
		if(GetPlayer8()) {
			printf("Resource allocation failed.\n");
			goto exit;
		}
		PlayModule8(sng);
	} else {
		register long count,midi = 0;
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
}
