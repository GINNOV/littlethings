/*
 * measure_amiga.cpp
 *
 *  Created on: 22.06.2019
 *      Author: andre
 */

#include "config.h"

#include <malloc.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
extern "C"
{
#include <hardware/cia.h>
#include <hardware/custom.h>
#ifdef BUILD_FOR_AMIGADOS
#include <dos/dos.h>
#include <exec/exec.h>
#include <proto/cia.h>
#include <proto/dos.h>
#include <proto/exec.h>
#endif
}
#include "measure.h"

#include "multiplatform.h"

#ifndef BUILD_FOR_AMIGADOS

volatile struct Custom* const custom = (volatile struct Custom*)0xDFF000;
volatile struct CIA* const ciaa		 = (volatile struct CIA*)0xbfe001;

#else

volatile struct Custom* mycustom = (volatile struct Custom*)0xDFF000;
volatile struct CIA* myciaa		 = (volatile struct CIA*)0xbfe001;

#endif
// extern struct CIA ciaa, ciab;
// extern struct Custom custom;

uint16_t timerValueStart;
uint16_t timerValueEnd;
float elapsedTime;

static UWORD old_dmacon;

void printMemoryUsage()
{
#ifdef BUILD_FOR_AMIGADOS
	printf("Available Chip Mem %lu\n", AvailMem(MEMF_CHIP));
	printf("Available Fast Mem %lu\n", AvailMem(MEMF_FAST));
#else

	// Intersting to read but not really worth it... TODO sbrk analysis
#if 0
	struct mallinfo info = mallinfo();

	printf("Heap Information\n");
	printf(" arena    %lu\n", info.arena); /* total space allocated from system */
	printf(" ordblks  %lu\n", info.ordblks);
	printf(" smblks   %lu\n", info.smblks);
	printf(" hblks    %lu\n", info.hblks);
	printf(" hblkhd   %lu\n", info.hblkhd);
	printf(" usmblks  %lu\n", info.usmblks);
	printf(" fsmblks  %lu\n", info.fsmblks);
	printf(" uordblks %lu\n", info.uordblks); /* total allocated space */
	printf(" fordblks %lu\n", info.fordblks);
	printf(" keepcost %lu\n", info.keepcost);
#endif

#endif
}

void measure_start()
{
	// disable interrupts
#ifdef BUILD_FOR_AMIGADOS
	Disable();
#else
	// disable all interrupts
	custom->intena = 0x7FFF;
#endif

	// disable all DMA
	old_dmacon	 = custom->dmaconr | 0x8000;
	custom->dmacon = 0x7fff;

	ciaa->ciatahi = 0xff;
	ciaa->ciatalo = 0xff;
	ciaa->ciacra  = CIACRAF_START | CIACRAF_LOAD | CIACRAF_RUNMODE;

	// start timer
	uint8_t high = ciaa->ciatahi;
	uint8_t low  = ciaa->ciatalo;

	timerValueStart = ((uint16_t)high << 8) | ((uint16_t)low);
}

void measure_end()
{
	// stop timer
	uint8_t high = ciaa->ciatahi;
	uint8_t low  = ciaa->ciatalo;

	timerValueEnd = ((uint16_t)high << 8) | ((uint16_t)low);

	custom->dmacon = old_dmacon;
#ifdef BUILD_FOR_AMIGADOS
	Enable();
#else

#endif

	// CIAA is clocked with .715909 MHz
	// This means one tick is 1.39682557420007 µs

	// If timerValueEnd is 0xffff this means that a underflow has occured
	if (timerValueEnd != 0xffff)
		elapsedTime = (timerValueStart - timerValueEnd) * 1.39682557420007;
	else
		elapsedTime = -1;
}
