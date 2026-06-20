/* joy.c                                                             */
/* Written in September 1993 by George F. McBay (gfm@gnu.ai.mit.edu) */
/* This code is 100% Public Domain.                                  */
#include <exec/types.h>
#include <hardware/custom.h>
#include <hardware/cia.h>
#include <stdlib.h>
#include <stdio.h>

#define UP     1        /* Define values for possible joystick events */
#define DOWN   2
#define LEFT   4
#define RIGHT  8
#define FIRE1 16
#define FIRE2 32

#define POTGOR *(UWORD *)0xDFF016     
struct CIA *cia = (struct CIA *) 0xBFE001;

void main(int argc, char *argv[]);
UBYTE ReadJoystick(UWORD joynum);

void main(int argc, char *argv[])
{
 UBYTE joyval;
 UWORD count = 0, maxcount, joynum;
	
	if(argc == 0)
		exit(0); /* Must be run from a Shell */

	if(argc != 3) {
		printf("Usage: %s [joyport] [number of events to process]\n", argv[0]);
	  	exit(0);
	}

	if((atoi(argv[1]) != 0) && (atoi(argv[1]) != 1)) {
		printf("Error: The joyport parameter must be equal to 0 or 1.\n");
		exit(0);
	}

	joynum = atoi(argv[1]);
	maxcount = atoi(argv[2]);
		
	do { 
	      joyval = ReadJoystick(joynum); /* Example program reads joyport number 1, the */
        	                             /* function can also read joyport 0 */

	      if(joyval & UP)
	        printf("Up ");

	      if(joyval & DOWN)
	        printf("Down ");

	      if(joyval & LEFT)
	        printf("Left ");
	
	      if(joyval & RIGHT)
	        printf("Right ");

	      if(joyval  & FIRE1)
	        printf("(Fire-1) ");

	      if(joyval & FIRE2)
		printf("(Fire-2) ");

	      if(joyval != 0) {
		printf("\n");
		count++;
	      }

	}	while(count <  maxcount); /* Get 'maxcount' Joystick Events */
      
 }

UBYTE ReadJoystick(UWORD joynum)
{
 extern struct Custom far custom;
 UBYTE ret = 0;
 UWORD joy;
    
	  if(joynum == 0)                /* JoyPort 0? */
		  joy = custom.joy0dat;  /* If so, use joyport 0 */
	  else
	          joy = custom.joy1dat;  /* Otherwise, default to joyport 1 */

	  ret += (joy >> 1 ^ joy) & 0x0100 ? UP : 0;  
	  ret += (joy >> 1 ^ joy) & 0x0001 ? DOWN : 0;

	  ret += joy & 0x0200 ? LEFT : 0;
	  ret += joy & 0x0002 ? RIGHT : 0;
	
	  if(joynum == 0) {
		ret += !(cia->ciapra & 0x0040) ? FIRE1 : 0;  /* Read FireButtons */
		ret += !(POTGOR & 0x0400) ? FIRE2 : 0;          /* on joyport 0     */
	  }
	  else {
		  ret += !(cia->ciapra & 0x0080) ? FIRE1 : 0; /* Read FireButtons */
		  ret += !(POTGOR & 0x4000) ? FIRE2 : 0;         /* on joyport 1     */
	  }

	  return(ret);
}

