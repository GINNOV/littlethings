/*
  $Id: debugstub.c,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
   
  $Log: debugstub.c,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 07:59:31  wegge
  Initial revision

  */

#include "debugstub.h"

__asm("
	.globl	_KPrintF

_KPrintF:
	lea	sp@(4),a1    | DataStream
	movel	a1@+,a0      | Format
	movel	a2,sp@-      
	lea	KPutChar,a2  | PutChProc
	movel	a6,sp@-
	movel	4:W,a6
	jsr	a6@(-522:W)  | RawDoFmt(Format, DataStream, PutChProc)
	movel	sp@+,a6
	movel	sp@+,a2
	rts

KPutChar:
	movel	a6,sp@-
	movel	4:W,a6
	jsr	a6@(-516:W) | exec/RawPutChr()
	movel	sp@+,a6
	rts

");

