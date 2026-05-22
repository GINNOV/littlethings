/* Joystick()                                                          */
/* Joystick() is a handy, easy and fast but naughty function that hits */
/* the hardware of the Amiga. It looks at either port 1 or port 2, and */
/* returns a bitfield containing the position of the stick and the     */
/* present state of the button.                                        */
/*                                                                     */
/* Synopsis: value = Joystick( port );                                 */
/* value:    (UBYTE) If the fire button is pressed, the first bit is   */
/*           set. If the stick is moved to the right, the second bit   */
/*           is set, and if the stick is moved to the left, the third  */
/*           bit is set. The fourth bit is set if the stick is moved   */
/*           down, and the fifth bit is set if the stick is moved up.  */
/* port:     (UBYTE) Set the flag PORT1 if you want to check the first */
/*           (mouse) port, or set the flag PORT2 if you want to check  */
/*           the second (joystick) port.                               */


#include <exec/types.h>
#include <hardware/custom.h>
#include <hardware/cia.h>


#define CIAAPRA 0xBFE001 

#define FIRE   1
#define RIGHT  2
#define LEFT   4
#define DOWN   8
#define UP    16

#define PORT1 1
#define PORT2 2


extern struct Custom far custom;
struct CIA *cia = (struct CIA *) CIAAPRA;


void main();
UBYTE Joystick();


void main()
{
  int timer = 0;
  UBYTE value = 0;
  UBYTE old_value = 0;
  
  
  while( timer < 30 )
  {
    old_value = value;

    value = Joystick( PORT2 );
    
    if( value != old_value )
    {
      timer++;

      if( value & FIRE )
        printf("FIRE ");
      if( value & RIGHT )
        printf("RIGHT ");
      if( value & LEFT )
        printf("LEFT ");
      if( value & DOWN )
        printf("DOWN ");
      if( value & UP )
        printf("UP ");
      printf("\n");
    }
  }
}



UBYTE Joystick( port )
UBYTE port;
{
  UBYTE data = 0;
  UWORD joy;
  
  if( port == PORT1 )
  {
    /* PORT 1 ("MOUSE PORT") */
    joy = custom.joy0dat;
    data += !( cia->ciapra & 0x0040 ) ? FIRE : 0;
  }
  else
  {
    /* PORT 2 ("JOYSTICK PORT") */
    joy = custom.joy1dat;
    data += !( cia->ciapra & 0x0080 ) ? FIRE : 0;
  }

  data += joy & 0x0002 ? RIGHT : 0;
  data += joy & 0x0200 ? LEFT : 0;
  data += (joy >> 1 ^ joy) & 0x0001 ? DOWN : 0;
  data += (joy >> 1 ^ joy) & 0x0100 ? UP : 0;

  return( data );
}

