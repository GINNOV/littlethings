/* Mouse()                                                               */
/* Mouse() is a handy, easy and fast but naughty function that hits the  */
/* hardware of the Amiga. It looks at either port 1 or port 2, and       */
/* returns the (x and y) delta movement of the mouse, as well as a       */
/* bitfield containing the present state of the three buttons. (A normal */
/* Amiga mouse has only two buttons (left and right), but it is possible */
/* to connect a mouse with three buttons, so why shouldn't we support    */
/* it?)                                                                  */
/*                                                                       */
/* Synopsis: buttons = Mouse( port, dx, dy );                            */
/* buttons:  (UBYTE) If the left mouse button was pressed, bit one is    */
/*           set. If the middle mouse button was pressed the second      */
/*           bit is set, and if the right mouse button was pressed the   */
/*           third bit is set.                                           */
/* port:     (UBYTE) Set the flag PORT1 if you want to check the first   */
/*           (mouse) port, or set the flag PORT2 if you want to check    */
/*           the second (joystick) port.                                 */
/* dx:       (BYTE *) Pointer to a variable that will be initialized     */
/*           with the horizontal delta movement of the mouse.            */
/* dy:       (BYTE *) Pointer to a variable that will be initialized     */
/*           with the vertical delta movement of the mouse.              */


#include <exec/types.h>
#include <hardware/custom.h>
#include <hardware/cia.h>


#define CIAAPRA 0xBFE001

#define LEFT_BUTTON   1
#define MIDDLE_BUTTON 2
#define RIGHT_BUTTON  4

#define PORT1 1
#define PORT2 2


extern struct Custom far custom;
struct CIA *cia = (struct CIA *) CIAAPRA;


void main();
UBYTE Mouse();


void main()
{
  int timer = 0;
  UBYTE value = 0, old_value = 0;
  BYTE dx=0, dy=0;
  
  while( timer < 30 )
  {
    old_value = value;

    value = Mouse( PORT1, &dx, &dy );

    printf( "(%4d :%4d)  ", dx, dy );
    
    if( value != old_value )
    {
      timer++;

      if( value & LEFT_BUTTON )
        printf("LEFT ");
      if( value & MIDDLE_BUTTON )
        printf("MIDDLE ");
      if( value & RIGHT_BUTTON )
        printf("RIGHT ");
    }
    printf("\n");
  }
}



UBYTE Mouse( port, delta_x, delta_y )
UBYTE port;
BYTE *delta_x, *delta_y;
{
  UBYTE data = 0;
  UWORD joy, pot;
  static BYTE x=0, y=0, old_x=0, old_y=0;


  custom.potgo = 0xFF00;
  pot = custom.potinp;

  if( port == PORT1 )
  {
    /* PORT 1 ("MOUSE PORT") */
    joy = custom.joy0dat;
    data += !( cia->ciapra & 0x0040 ) ? LEFT_BUTTON : 0;
    data += !( pot & 0x0100 ) ? MIDDLE_BUTTON : 0;
    data += !( pot & 0x0400 ) ? RIGHT_BUTTON : 0;
  }
  else
  {
    /* PORT 2 ("JOYSTICK PORT") */ 
    joy = custom.joy1dat;
    data += !( cia->ciapra & 0x0080 ) ? LEFT_BUTTON : 0;
    data += !( pot & 0x1000 ) ? MIDDLE_BUTTON : 0;
    data += !( pot & 0x4000 ) ? RIGHT_BUTTON : 0;
  }

  old_x = x;
  x = joy & 0x00FF;
  *delta_x = x - old_x;

  old_y = y;
  y = joy >> 8;
  *delta_y = y - old_y;

  return( data );
}
