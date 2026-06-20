#include <stdio.h>
#include <math.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/GfxBase.h>
#include <hardware/custom.h>
#include "jiff.h"
#include <hardware/custom.h>
#include <graphics/copper.h>
#include <graphics/gfxmacros.h>

#ifdef	__SASC
#include <proto/exec.h>
#include <proto/timer.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#endif

#ifdef	AZTEC_C
#include <functions.h>
#endif
