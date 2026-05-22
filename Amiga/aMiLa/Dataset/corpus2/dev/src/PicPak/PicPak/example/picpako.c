/***********************************************************
*                                                          *
* picpako.c                                                *
*                                                          *
* this file is used to create picpak.o                     *
*                                                          *
* created by mark carter 24.10.94                          *
*                                                          *
***********************************************************/


#include <graphics/gfxmacros.h>
#include <intuition/intuitionbase.h>
#include <exec/interrupts.h> /* define Interrupt() and List functions */
#include <exec/memory.h>  /* defines MEMF_CLEAR etc. */
#include <hardware/intbits.h> /* defines INTB_VERTB */
#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#include "/picpak/picpak.h"
#include "/picpak/picpak.c"



