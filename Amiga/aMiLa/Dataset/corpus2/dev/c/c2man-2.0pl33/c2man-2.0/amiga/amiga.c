/*
** $PROJECT:
**
** $VER: amiga.c 2.1 (22.01.95)
**
** by
**
** Stefan Ruppert , Windthorststraße 5 , 65439 Flörsheim , GERMANY
**
** (C) Copyright 1995
** All Rights Reserved !
**
** $HISTORY:
**
** 22.01.95 : 000.001 : initial
*/

#include "/c2man.h"

/* return Process ID.
 * The Amiga has no really process id , so return the address of TCB
*/

long getpid(void)
{
   return(((long) FindTask(NULL)));
}

