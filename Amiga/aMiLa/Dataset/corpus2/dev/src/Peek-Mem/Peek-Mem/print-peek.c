/* Peeking memory addresses one byte at a time. */
/* Limited to 16MB boundary ONLY, for idea testing. */
/* This is the standard A1200 version using Dice-C and VBCC compilers. */
/* (C)2006, B.Walker, G0LCU. To be used in conjunction with Python V1.4. */

/* This is written in childishly simple C coding so that it can be easily */
/* understood by anyone interested in programming in C. */
/* It is in theory ANSI C compliant... */

/* Standard include(s). */
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

/* Get the ASCII address from Python VIA this 'argv[1]'. Whatever appears */
/* in 'argv[1]' does not matter as the code below will compensate for any */
/* typo' errors. */
int main(int argc, char *argv[])

{
	/* Set up types required. */
	long int peekaddress;
	unsigned char mybyte;

	/* Ensure definate values for the above. */
	peekaddress = 0;
	mybyte = 0;

	/* Ensure no NULL typo' error or overflow error can occur. */
	/* Limit to 24 Bit address space for testing. */
	if (strlen(argv[1]) <= 0) (argv[1]) = "0";
	if (strlen(argv[1]) >= 9) (argv[1]) = "16777215";

	/* Get ASCII address from 'argv[1]'. */
	peekaddress = atol(argv[1]);

	/* Correct for number of arguments error, MUST be 2. */
	/* If not equal to 2 then set 'peekaddress' to ZERO. */
	if (argc <= 1) peekaddress = 0;
	if (argc >= 3) peekaddress = 0;

	/* Limit memory access to 16MB boundary for A1200 use!. */
	/* DO NOT allow negative numbers!. Address 0 is technically an */
	/* ENFORCER hit for high end AMIGAs so treat it as such. */
	if (peekaddress <= 0) peekaddress = 0;
	if (peekaddress >= 16777215) peekaddress = 16777215;

	/* Obtain a single BYTE character ONLY from the memory address. */
	mybyte = *(unsigned char *)peekaddress;

	/* Print values to the screen. */
	/* This can be used from the command line as 'peek x<RETURN>' */
	/* where x is from 0 to 16777215. NOTE, for my purposes it was */
	/* added purely for debugging purposes... :) */
	/* 'x' can be anything at all see comments the above... */
	printf("\nThe address in decimal is %ld.", peekaddress);
	printf("\nThe address in hexadecimal is 0x%lX.\n", peekaddress);
	printf("\nThe byte at that address in decimal is %u.", mybyte);
	printf("\nThe byte at that address in hexadecimal is %X.\n\n", mybyte);

	/* Use the RETURN CODE for BYTE value access for Python. */
	/* This is VERY controversial BUT it WORKS... :) */
	return(mybyte);
}
