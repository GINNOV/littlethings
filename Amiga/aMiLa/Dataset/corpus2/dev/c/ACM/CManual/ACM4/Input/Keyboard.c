/* Keyboard()                                                          */
/* Keyboard() is a handy, easy and fast but naughty function that hits */
/* the hardware of the Amiga. It checks the keyboard, and returns the  */
/* Raw Key Code. (See chapter (C) SYSTEM DEFAULT CONSOLE KEY MAPPING   */
/* for the full list of Raw Key Codes.)                                */
/*                                                                     */
/* Synopsis: value = Keyboard();                                       */
/* value:    (UBYTE) Raw Key Code. For example: If the user hits key   */
/*           "N", the function returns 36 (hexadecimal). When the user */
/*           releases the key, B6 is returned.                         */


#include <exec/types.h>
#include <hardware/cia.h>


#define CIAA 0xBFE001

struct CIA *cia = (struct CIA *) CIAA;


void main();
UBYTE Keyboard();


void main()
{
  int loop;
  
  for( loop = 0; loop < 100; loop++ )
    printf("Code: %2x\n", Keyboard() );
}


UBYTE Keyboard()
{
  UBYTE code;

  /* Get a copy of the SDR value and invert it: */
  code = cia->ciasdr ^ 0xFF;
  
  /* Shift all bits one step to the right, and put the bit that is */
  /* pushed out last: 76543210 -> 07654321                         */
  code = code & 0x01 ? (code>>1)+0x80 : code>>1;

  /* Return the Raw Key Code Value: */
  return( code );
}
