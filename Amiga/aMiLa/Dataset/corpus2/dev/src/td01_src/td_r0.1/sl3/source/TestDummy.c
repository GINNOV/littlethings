/*
**      $VER: TextExampleLib.c 37.30 (7.3.98)
**
**      Demo program for example.library
**
**      (C) Copyright 1996-98 Andreas R. Kleinert
**      All Rights Reserved.
*/

#include <exec/types.h>
#include <exec/memory.h>

#include <x3/x3.h>

#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <pragma/x3_lib.h>
#else
#include <proto/exec.h>
#include <proto/x3.h>
#endif

#include <stdio.h>
#include <stdlib.h>

struct x3Base *x3Base=NULL;

void main(long argc, char **argv)
{
 x3Base = (APTR) OpenLibrary("dummy1.library", 0);
 if(x3Base)
  {
	printf("impl S %ld L %ld\n",tdo3XSave(0,NULL,NULL),tdo3XLoad(0,NULL,NULL,NULL));
	CloseLibrary((APTR)x3Base);
    exit(0);
  }

 printf("\nLibrary opening failed\n");

 exit(20);
}
