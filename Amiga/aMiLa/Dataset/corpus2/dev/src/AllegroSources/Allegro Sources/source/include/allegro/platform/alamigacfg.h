/*         ______   ___    ___ 
 *        /\  _  \ /\_ \  /\_ \ 
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___ 
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS specific configuration #defines that determine how the
 *      Allegro library is built.
 *
 *      By René W. Olsen and Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#ifndef ALAMIGACFG_H
#define ALAMIGACFG_H

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

/* This is missing from newlib but is required by Allegro, so we will #define it here */

#define O_BINARY 0x10000

#define ALLEGRO_PLATFORM_STR	"amiga"
#define ALLEGRO_BIG_ENDIAN		1
#define ALLEGRO_MULTITHREADED   1
#define ALLEGRO_HAVE_STDINT_H	1
#define ALLEGRO_HAVE_MKSTEMP	1

#define ALLEGRO_EXTRA_HEADER     "allegro/platform/alamiga.h"

#endif /* ! ALAMIGACFG_H */
