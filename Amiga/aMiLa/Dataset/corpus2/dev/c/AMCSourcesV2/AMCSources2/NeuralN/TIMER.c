/*
*-----------------------------------------------------------------------------
*	file:	timer.c
*	desc:	time a program in secs
*	by:	patrick ko
*	date:	18 jan 92
*-----------------------------------------------------------------------------
*/

#include <stdio.h>
#include <time.h>

static time_t	last;
static time_t	this;
static time_t	temp;

void timer_restart( )
{
	time( &last );
}

long int timer_stop( )
{
	time( &this );
	temp = this - last;
	last = this;

	return ((long int)temp);
}
