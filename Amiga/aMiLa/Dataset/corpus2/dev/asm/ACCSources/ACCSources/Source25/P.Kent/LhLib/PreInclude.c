#define __NO_PRAGMAS 1

#include <libraries/dosextens.h>
#include <graphics/gfxmacros.h>
#include <libraries/arpbase.h>
#include <hardware/dmabits.h>
#include <hardware/custom.h>
#include <exec/execbase.h>
#include <devices/timer.h>
#include <hardware/cia.h>
#include <exec/memory.h>
#include <functions.h>
#include <fcntl.h>
#include <ctype.h>

#include "lhlib.h"

#define ToUpper(c)	(((c >= 224 && c <= 254) || (c >= 'a' && c <= 'z')) ? c - 32 : c)

struct NameLink
{
	struct NameLink	*Next;
	char		 Name[6 * DSIZE + FCHARS];
};

extern struct DosLibrary	*DOSBase;
extern struct ArpBase		*ArpBase;
extern struct ExecBase		*SysBase;
extern struct GfxBase		*GfxBase;
extern struct IntuitionBase	*IntuitionBase;
