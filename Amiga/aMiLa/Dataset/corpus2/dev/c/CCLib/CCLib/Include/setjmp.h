/*	setjmp.h	*/
/*  PMTG - created April 10th 1990 */
#ifndef SETJMP_H
#define SETJMP_H 1
/*
   The layout of jmp_buf variable after a call to setjump
   in this implementation is:
     Element	Contents
      0 	return address
      1 	D2
      2 	D3
      3 	D4
      4 	D5
      5 	D6
      6 	D7
      7 	A2
      8 	A3
      9 	A4
     10 	A5 - frame pointer
     11 	A6 - used as library base pointer
     12 	A7 - stack pointer

   NOTE: the setjmp and longjmp routines do not fully comply with ANSI C.
	 To do so would require saving the state of all local variables
	 (ok not to save register variables) at the time of the call to
	 setjmp and restore them when longjmp is called. This is left as an
	 exercise for the gentle reader...

*/
typedef unsigned long jmp_buf[13];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int return_code);

#endif

