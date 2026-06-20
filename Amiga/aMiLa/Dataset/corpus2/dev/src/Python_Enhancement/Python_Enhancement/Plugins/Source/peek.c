
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

	/* Allocate definate values to the above. */
	peekaddress = 0;
	mybyte = 0;

	/* Ensure no typo' error can occur. */
	if (strlen(argv[1]) <= 0) (argv[1]) = "0";
	if (strlen(argv[1]) >= 9) (argv[1]) = "16777215";

	/* Get ASCII address from 'argv[1]'. */
	/* NOTE:- No need to allow for a NULL string length or odd */
	/* ASCII characters as 'atol()' takes care of it for me. :) */
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

	/* Use the RETURN CODE for BYTE value access for Python. */
	/* This is VERY controversial BUT it WORKS... :) */
	return(mybyte);
}
