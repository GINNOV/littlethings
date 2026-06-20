/*
** This is a replacement for the amiga.lib kprintf for PowerPC.
** It uses the WarpUp SPrintF function to do debug output
** to the serial connector (or Sushi, if it's installed).
*/

#include "sysinc.h"
#include <stdarg.h>
#include <stdio.h>

#ifdef __VBCC__
#pragma amiga-align
#endif

#include <proto/exec.h>

#ifdef __STORM__
#include <clib/powerpc_protos.h>
#else
#if defined (__STORMGCC__) || (defined (__VBCC__) && defined (__PPC__))
#include <clib/powerpc_protos.h>
#else
	#ifndef __VBCC__
	#include <powerpc/powerpc_protos.h>
	#endif
#endif
#endif


#ifdef __VBCC__
#pragma default-align
#endif

int kprintf(char *format, ...)
{
#ifndef NDEBUG
	char msg[1024];
	va_list marker;

	va_start(marker, format);
	vsprintf(msg, format, marker);
	va_end(marker);

	#ifndef __STORM__
	#ifndef __STORMGCC__
	#ifdef __PPC__
	SPrintF(msg, 0);
	#endif
	#endif
	#endif
#endif
	return 1;   /* fake something... */

}
