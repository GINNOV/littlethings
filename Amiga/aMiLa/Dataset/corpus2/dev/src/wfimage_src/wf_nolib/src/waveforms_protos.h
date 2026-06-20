#ifndef  WAVEFORMS_PROTOS_H
#define  WAVEFORMS_PROTOS_H
/*
**  waveforms_protos.c
**
**  Contains the dispatchWFI() routine for the hook in
**  the waveforms.image shared library.
**
**  © Copyright 1999-2001 stranded UFO productions. All Rights Reserved.
**  Written by Paul Juhasz.
**
*/

#include "waveformsbase.h"

#include <clib/exec_protos.h>
#include <pragmas/exec_pragmas.h>


LONG __asm dispatchWFI( REGISTER __a0 Class *cl, REGISTER __a2 struct Image *im,
                           REGISTER __a1 ULONG *msg );

#endif /* WAVEFORMS_PROTOS_H */


