#ifndef _SGE_H
#define _SGE_H

#include <sgedefines.h>
#include <SDL.h>
#include <SDL_image.h>
#include <SDL_mixer.h>
#include <SDL_audio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#if !defined(MORPHOS) && !defined(__amigaos4__)
	#include <unistd.h>
#endif
#include <fcntl.h>
#include <time.h>
#include <math.h>

#define sgeLock(surface) do {\
		if (SDL_MUSTLOCK(surface)) SDL_LockSurface(surface);\
	} while (0)

#define sgeUnlock(surface) do {\
		if (SDL_MUSTLOCK(surface)) SDL_UnlockSurface(surface);\
	} while (0)

#define sgeBailOut(format, args...) do {\
		fprintf(stderr,(format),args); \
		exit(-1); \
	} while (0)

#define sgeFlip() SDL_Flip(screen)

#define sgeMalloc(target,type,amount) do {\
		(target)=(type *)malloc((amount+1)*sizeof(type));\
		if ((target)==NULL) {\
			sgeBailOut("could not allocate %d bytes of ram\n", (int)((amount)*sizeof(type)));\
		}\
		memset(target,0,((amount)*sizeof(type)));\
	} while (0)

#define sgeRealloc(target,type,amount) do {\
		(target)=realloc((target),sizeof(type)*(amount+1));\
		if (target==NULL) {\
			sgeBailOut("could not allocate %d bytes of ram\n", (int)((amount)*sizeof(type)));\
		}\
	} while (0)

#define sgeNew(target,type) sgeMalloc(target,type,1);

#define sgeFree(target) do {\
		free(target);\
		target=NULL;\
	} while(0)

#define sgeRandom(from, range) (from + (int) ((float)(range+1) * (rand() / (RAND_MAX + (float)from))))
#define sgeRandomFloat(from, range) (float) ((float)from + ((float)(range+1) * (rand() / (RAND_MAX + (float)from))))

#if SDL_BYTEORDER == SDL_LIL_ENDIAN
#define sgeByteSwap16(val)    (val)
#define sgeByteSwap32(val)    (val)
#else
#define sgeByteSwap16(val)    SDL_Swap16(val)
#define sgeByteSwap32(val)    SDL_Swap32(val)
#endif

#if defined(MORPHOS) || defined(__amigaos4__)

#define sgeRound(val) (int)((val*100+50)/100)
#else
#define sgeRound(val) round(val)
#endif

#ifndef MAX
#define MAX(x, y) ((x) > (y) ? (x) : (y))
#endif
#ifndef MIN
#define MIN(x, y) ((x) < (y) ? (x) : (y))
#endif

#define MINMAX(value, lower, upper) MIN(MAX((value), (lower)), (upper))

#include <sgeinit.h>
#include <sgegp2x.h>
#include <sgemisc.h>
#include <sgelist.h>
#include <sgearray.h>
#include <sgescreen.h>
#include <sgecontrol.h>
#include <sgegfx.h>
#include <sgeresource.h>
#include <sgeevent.h>
#include <sgesound.h>
#include <sgespriteimage.h>
#include <sgesprite.h>
#include <sgespritegroup.h>
#include <sgestage.h>
#include <sgegamestate.h>
#include <sgefont.h>
#include <sgepathfinder.h>
#include <sgeparticles.h>

#endif
