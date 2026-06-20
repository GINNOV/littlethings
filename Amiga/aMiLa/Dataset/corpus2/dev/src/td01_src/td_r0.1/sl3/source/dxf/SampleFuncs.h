/*
**      $VER: SampleFuncs.h 37.12 (29.6.97)
**
**      Demo functions for example.library
**
**      (C) Copyright 1996-97 Andreas R. Kleinert
**      All Rights Reserved.
*/

#include "compiler.h"

extern ULONG __saveds ASM EXF_TestRequest( register __d1 UBYTE *title_d1 GNUCREG(d1), register __d2 UBYTE *body GNUCREG(d2), register __d3 UBYTE *gadgets GNUCREG(d3));
