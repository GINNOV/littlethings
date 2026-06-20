/*
 * uart.h
 *
 *  Created on: 22.09.2018
 *      Author: andre
 */

#ifndef INCLUDE_UART_H_
#define INCLUDE_UART_H_

// common
void uart_init();

// only bare metal
void uart_printChar(char c);
int uart_blockedGetChar();

// only OS

void uart_printf(const char* format, ...);
void uart_puts(char* str);
void uart_close();

#define uart_assert(cond)                                                                                              \
	if (!(cond))                                                                                                       \
	{                                                                                                                  \
		uart_printf("ASSERT failed at %s:%d %s\n", __FILE__, __LINE__, __func__);                                      \
		for (;;)                                                                                                       \
			;                                                                                                          \
	}

#endif /* INCLUDE_UART_H_ */
