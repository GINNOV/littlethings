/*
 * uart.c
 *
 *  Created on: 22.09.2018
 *      Author: andre
 */

#include <errno.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <graphics/display.h>
#include <hardware/blit.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>

#include "multiplatform.h"
#include "uart.h"

#define BAUD 19200

void uart_init()
{
	custom->serper = (3546895 / BAUD) - 1;
}

#define SERDATR_TBE (1 << 13)

void uart_printChar(char c)
{
	while ((custom->serdatr & SERDATR_TBE) == 0)
		;

	custom->serdat = ((uint16_t)c) | 0x100;
}

int uart_blockedGetChar()
{
	while ((custom->intreqr & INTF_RBF) == 0)
		;

	int ret = custom->serdatr & 0xff;

	custom->intreq = INTF_RBF;

	return ret;
}

void uart_printf(const char* format, ...)
{
	char buffer[128];
	va_list args;
	va_start(args, format);
	int num = vsprintf(buffer, format, args);

	// I usually use only \n at end. But this is not enough.
	buffer[num]		= '\r';
	buffer[num + 1] = '\0';

	char* str = buffer;
	while (*str)
	{
		uart_printChar(*str);

		str++;
	}

	va_end(args);
}

void uart_close()
{
}
