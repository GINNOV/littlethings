#ifndef	__LIBRARY_H__
#define	__LIBRARY_H__

#ifndef	DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef	EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#define HAVE_USER_INIT 0

#if defined(__PPC__)
#define __TEXTSEGMENT__ __attribute__((section(".text")))
#endif

#if !defined(__MORPHOS__)
#define ADDTAIL AddTail
#define REMOVE  Remove
#define NEWLIST NewList
#endif

#if defined(__SASC)
#  define MASM __asm
#  define MREG(reg,type) register __##reg type
#elif defined(__GNUC__)
#  define MASM
#  define MREG(reg,type) type __asm(#reg)
#elif defined(__VBCC__)
#  define MASM
#  define MREG(reg,type) __reg(#reg) type
#elif defined(__MAXON__) | defined(__STORM__)
#  define MASM
#  define MREG(reg,type) register __##reg type
#else
#  error Unknown compiler, SAS/C, GCC, VBCC, MaxonC and StormC supported
#endif

#if defined(__PPC__)
#define VREG(reg,type) type
#else
#define VREG(reg,type) MREG(reg,type)
#endif

struct TaskNode
{
	struct MinNode Node;
	struct Task *Task;
};

struct MyLibrary
{
	struct Library    Library;
	UWORD             UserInitDone;
	struct MyLibrary *Parent;
	BPTR              SegList;

	union
	{
		struct MinList TaskList;
		struct TaskNode TaskNode;
	} TaskContext;

	#if HAVE_USER_INIT
	struct SignalSemaphore Semaphore;
	#endif
};

#if HAVE_USER_INIT
BOOL UserLibOpen(struct MyLibrary *base);
VOID UserLibClose(struct MyLibrary *base);
#endif

#endif /* __LIBRARY_H__ */
