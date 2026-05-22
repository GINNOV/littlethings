/*
 * gdb-m68k-stub.h
 *
 *  Created on: 23.12.2018
 *      Author: andre
 */

#ifndef INCLUDE_GDB_M68K_STUB_H_
#define INCLUDE_GDB_M68K_STUB_H_

// Debugging Stub
typedef void (*ExceptionHook)(int); /* pointer to function with int parm */
typedef void (*Function)();			/* pointer to a function */

void stub_putDebugChar(char c);
int stub_getDebugChar();
void breakpoint();
void exceptionHandler(int, void*);						 /* assign an exception handler */
extern ExceptionHook exceptionHook asm("exceptionHook"); /* hook variable for errors/exceptions */
void set_debug_traps();

#endif /* INCLUDE_GDB_M68K_STUB_H_ */
