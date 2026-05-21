/*
 * measure_linux.cpp
 *
 *  Created on: 22.06.2019
 *      Author: andre
 */

#include "measure.h"
#include <stdlib.h>
#include <sys/time.h>

struct timeval tStart, tEnd;
float elapsedTime;

void printMemoryUsage()
{
}

void measure_start()
{
	// start timer
	gettimeofday(&tStart, NULL);
}

void measure_end()
{
	// stop timer
	gettimeofday(&tEnd, NULL);

	// compute and print the elapsed time in millisec
	elapsedTime = (tEnd.tv_sec - tStart.tv_sec) * 1000.0 * 1000.0; // sec to us
	elapsedTime += (tEnd.tv_usec - tStart.tv_usec);
}
