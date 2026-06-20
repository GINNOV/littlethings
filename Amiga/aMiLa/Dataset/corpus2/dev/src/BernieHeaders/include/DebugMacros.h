#ifndef DEBUGMACROS_H
#define DEBUGMACROS_H
/*
**	$Id: DebugMacros.h,v 1.2 1999/02/07 14:41:01 bernie Exp $
**
**	Copyright (C) 1995,96,97,98,99 Bernardo Innocenti <bernardo.innocenti@usa.net>
**	All rights reserved.
**
**	Use 4 chars wide TABs to read this file
**
**	Some handy debug macros which are automatically excluded when the
**	_DEBUG preprocessor symbol isn't defined. To make debug executables,
**	you must link with debug.lib or any module containing the kprintf()
**	function.
**
**	Here is a short description of the macros defined below:
**
**	ILLEGAL
**		Output an inline "ILLEGAL" 68K opcode, which will
**		be interpreted as a breakpoint by most debuggers.
**
**	DBPRINTF
**		Output a formatted string to the debug console. This
**		macro uses the debug.lib kprintf() function by default.
**
**	ASSERT(x)
**		Do nothing if the expression <x> evalutates to a
**		non-zero value, output a debug message otherwise.
**
**	ASSERT_VALID_PTR(x)
**		Checks if the expression <x> points to a valid
**		memory location, and outputs a debug message
**		otherwise. A NULL pointer is considered VALID.
**
**	ASSERT_VALID_PTR_OR_NULL(x)
**		Checks if the expression <x> points to a valid
**		memory location, and outputs a debug message
**		otherwise. A NULL pointer is considered INVALID.
**
**	DB(x)
**		Compile the expression <x> when making a debug
**		executable, otherwise omit it.
**
**	DB1(x)
**		DB verbosity level 1. Compile the expression <x> when the
**		preprocessor symbol DEBUG is defined to a number greater or
**		equal to 1.
**
**	DB2(x)
**		DB verbosity level 2. Compile the expression <x> when the
**		preprocessor symbol _DEBUG is defined to a number greater or
**		equal to 2.
*/

#if (defined(_DEBUG) && (_DEBUG != 0)) || (defined(DEBUG) && (DEBUG != 0))

	/* Needed for TypeOfMem() */
	#ifndef  PROTO_EXEC_H
	#include <proto/exec.h>
	#endif /* PROTO_EXEC_H */

	#if defined(__SASC)

		extern void __builtin_emit (int);
		// #define ILLEGAL __builtin_emit(0x4AFC)
		#define ILLEGAL 0
		STDARGS extern void kprintf (const char *, ...);

	#elif defined(__GNUC__)

		/* Currently, there is no kprintf() in libamiga.a */
		#define kprintf printf

		/* GCC doesn't accept asm statements in the middle of an
		 * expression such as `a ? b : asm("something")'.
		 */
		#define ILLEGAL illegal()
		static __inline__ int illegal(void) { asm ("illegal"); return 0; }
		extern void STDARGS FORMATCALL(printf,1,2) kprintf (const char *, ...);

	#else
		#error Please add compiler specific definitions for your compiler
	#endif


	/* common definitions for ASSERT and DB macros */

	#define DBPRINTF kprintf

	#define ASSERT(x) ( (x) ? 0 :									\
		( DBPRINTF ("\x07%s, %ld: assertion failed: " #x "\n",		\
		__FILE__, __LINE__) , ILLEGAL ) );

	#define ASSERT_VALID_PTR_OR_NULL(x) ( ((((APTR)(x)) == NULL) ||	\
		(((LONG)(x) > 1024) &&	TypeOfMem ((APTR)(x)))) ? 0 :		\
		( DBPRINTF ("\x07%s, %ld: bad pointer: " #x " = $%lx\n",	\
		__FILE__, __LINE__, (APTR)(x)) , ILLEGAL ) );

	#define ASSERT_VALID_PTR(x) ( (((LONG)(x) > 1024) &&			\
		TypeOfMem ((APTR)(x))) ? 0 :								\
		( DBPRINTF ("\x07%s, %ld: bad pointer: " #x " = $%lx\n",	\
		__FILE__, __LINE__, (APTR)(x)) , ILLEGAL ) );

	/* Obsolete definitions */
	#define ASSERT_VALID	ASSERT_VALID_PTR_OR_NULL
	#define ASSERT_VALIDNO0	ASSERT_VALID_PTR

	#define DB(x) x
	#define DB1(x) x

	#if (_DEBUG >= 2) || (DEBUG >= 2)
		#define DB2(x) x
	#else
		#define DB2(x)
	#endif

	#if (_DEBUG >= 3) || (DEBUG >= 3)
		#define DB3(x) x
	#else
		#define DB3(x)
	#endif
#else
	#define ASSERT_VALID_PTR(x)
	#define ASSERT_VALID_PTR_OR_NULL(x)
	#define ASSERT_VALID(x)
	#define ASSERT_VALIDNO0(x)
	#define ASSERT(x)
	#define DB(x)
	#define DB1(x)
	#define DB2(x)
	#define DB3(x)
#endif /* DEBUG */

#endif /* !DEBUGMACROS_H */
