/*
 * syscalls.c
 *
 *  Created on: 22.09.2018
 *      Author: andre
 */

#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#include "uart.h"

_READ_WRITE_RETURN_TYPE write(int f, const void* b, size_t s)
{
	size_t todo;
	char* ptr = (char*)b;

	for (todo = 0; todo < s; todo++)
		uart_printChar(*ptr++);
	return s;
}

void _exit(int rc)
{
	uart_printf("exitcode %d\n", rc);

	for (;;)
		;
} /* _exit () */

int close(int file)
{
	errno = EBADF;

	return -1; /* Always fails */
}

int fstat(int file, struct stat* st)
{
	st->st_mode = S_IFCHR;
	return 0;

} /* _fstat () */

int isatty(int file)
{
	return 1;

} /* _isatty () */

off_t lseek(int __fildes, off_t __offset, int __whence)
{
	return 0;

} /* _lseek () */

_READ_WRITE_RETURN_TYPE read(int __fd, void* __buf, size_t __nbyte)
{
	return 0; /* EOF */

} /* _read () */

void* sbrk(ptrdiff_t nbytes)
{
	/* Symbol defined by linker map */
	extern int _end; /* start of free memory (as symbol) */

	/* Value set by crt0.S */
	extern int stack_start; /* end of free memory */

	/* The statically held previous end of the heap, with its initialization. */
	static int* heap_ptr = (void*)&_end; /* Previous end */

	// uart_printf("sbrk %d %x %x %x\n", nbytes, (int)heap_ptr, (int)&stack_start, &_end);

	if ((heap_ptr + nbytes) < &stack_start)
	{
		void* base = heap_ptr;
		heap_ptr += nbytes;
		// uart_printf("sbrk accepted!\n");
		return base;
	}
	else
	{
		errno = ENOMEM;
		// uart_printf("sbrk failed!\n");
		return (void*)-1;
	}
} /* _sbrk () */

int getpid()
{
	return 1; /* Success */

} /* _getpid () */

int kill(int pid, int sig)
{
	errno = EINVAL;
	return -1; /* Always fails */

} /* _kill () */

int open(const char* name, int flags, int mode)
{
	errno = ENOSYS;
	return -1; /* Always fails */

} /* _open () */
