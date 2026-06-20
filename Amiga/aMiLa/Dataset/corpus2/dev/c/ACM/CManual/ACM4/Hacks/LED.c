/* LED                                                               */
/* This fantastic useful program does what all true hackers have     */
/* dreamt of. Enjoy your Amiga's fantastic ability to flash one LED! */


#include <exec/types.h>
#include <hardware/cia.h>


/* The address of the CIAA chip: */
#define CIAA 0xBFE001

/* Declare a pointer to the CIA (8520) chip: */
struct CIA *cia = (struct CIA *) CIAA;

void _main();

/* NOTE! Since we have declared our main() function as _main(), */
/* no Consol window will be opened if it is run from the        */
/* Workbench. The disadvantage is that we must NEVER use the    */
/* printf() or similar console functions. It would crash the    */
/* system.                                                      */

void _main()
{
  int loop;
  
  for( loop = 0; loop < 40000; loop++ )
  {
    /* We change the second bit in the ciapra register. If the bit is */
    /* unset (0) the LED is on, if the bit is set (1) the LED is off. */
    if( loop % 1000 == 0 )
      cia->ciapra ^= CIAF_LED;
  }
}
