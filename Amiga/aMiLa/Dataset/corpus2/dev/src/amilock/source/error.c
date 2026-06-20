#include <exec/types.h>
#include <exec/PORTS.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>
#include <intuition/intuition.h>
#include <proto/all.h>
#include <string.h>
#include <stdlib.h>

#include "headers/error_proto.h"

char GMsg[100] = "this is the global message";

struct TextAttr  TOPAZ180  = {(STRPTR)"topaz.font",TOPAZ_EIGHTY,0,0};
struct IntuiText Neg = {3,0,JAM2,0,0,&TOPAZ180,"NO!!",NULL};
struct IntuiText Pos = {3,0,JAM2,0,0,&TOPAZ180,"YES!",NULL};
struct IntuiText Act = {3,0,JAM2,0,0,&TOPAZ180,GMsg,NULL};

BOOL Error(a)
char *a;
{
	strcpy(GMsg,a);
	if (AutoRequest(NULL,&Act,&Pos,&Neg,IDCMP_GADGETUP,IDCMP_GADGETUP,150,100))
		return TRUE;
	else return FALSE;
}
