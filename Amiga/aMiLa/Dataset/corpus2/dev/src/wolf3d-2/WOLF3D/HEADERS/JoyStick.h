/* This file contains routines for allocating, reading, and deallocating
   a joystick port under Intuition.
 */
 
/* Note from the author: These routines are placed in the public domain. */


extern short AllocateJoystick(void);
extern short ReadJoystick(void);
extern void  DeallocateJoystick(void);

/* -----------------------  D E F I N E S  ----------------------- */

#define XJOYLFT 1
#define XJOYRGT 2
#define YJOYUP  4
#define YJOYDWN 8   
#define LBUTTON 16
#define RBUTTON 32

#define JOY_N  (YJOYUP)
#define JOY_NE (YJOYUP+XJOYRGT)
#define JOY_E  (XJOYRGT)
#define JOY_SE (XJOYRGT+YJOYDWN)
#define JOY_S  (YJOYDWN)
#define JOY_SW (YJOYDWN+XJOYLFT)
#define JOY_W  (XJOYLFT)
#define JOY_NW (XJOYLFT+YJOYUP)
#define JOY_CT 0

#define PORTNAME "MazeJoyStick"
#define UNIT 1  // 1 = regular joystick port, 0 = mouse/joystick port
