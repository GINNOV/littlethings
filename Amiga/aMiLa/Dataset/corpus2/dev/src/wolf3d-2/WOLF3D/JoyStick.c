#include <exec/io.h>
#include <devices/gameport.h>
#include <devices/inputevent.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include "JoyStick.h"

/* This file contains routines for allocating, reading, and deallocating
   a joystick port under Intuition.
 */
 
/* Note from the author: These routines are placed in the public domain. */

/*-------------------------------------------------------*
 * NAME: AllocateJoystick                                *
 *                                                       *
 * AUTHOR: Terence Russell (August 9,1993)               *
 *                                                       *
 * DESC: Attempts to allocate a gameport device for use  *
 *       as a joystick port. Will return 1 if successful *
 *       and 0 if it failed. If a port is successfully   *
 *       allocated, then you MUST call DeallocateJoystick*
 *       once your program is finished. Do NOT call the  *
 *       deallocation routine if the port was not        *
 *       allocated.                                      *
 *-------------------------------------------------------*/
 
short AllocateJoystick(void);

/*-------------------------------------------------------*
 * NAME: ReadJoystick                                    *
 *                                                       *
 * AUTHOR: Terence Russell (August 9,1993)               *
 *                                                       *
 * DESC: This routine essentially reads the gameport     *
 *       which was allocated with the AllocateJoystick() *
 *       routine.                                        *
 *       It returns a 16 bit word which indicates the    *
 *       state of the joystick. Currently only the lower *
 *       6 bits are used.                                *
 *                                                       *
 *       Joystick positions are given in -1,0 & 1 X,Y    *
 *       coordinates.                                    *
 *                                                       *
 *       The first 2 bits represent the X values:        *
 *           left = X = -1 -> gives a bit value of 01    *
 *         center = X =  0 -> gives a bit value of 00    *
 *          right = X =  1 -> gives a bit value of 10    *
 *                                                       *
 *       The next 2 bits represent the Y values:         *
 *             up = Y = -1 -> gives a bit value of 01    *
 *         center = Y =  0 -> gives a bit value of 00    *
 *           down = Y =  1 -> gives a bit value of 10    *
 *                                                       *
 *       The 5th bit is the up/down state of the FIRE    *
 *       button. 0 = down, 1 = up.                       *
 *                                                       *
 *       The 6th bit is the up/down state of a second    *
 *       FIRE button. (For those of you with real two    *
 *       button joysticks.                               *
 *-------------------------------------------------------*/ 
 
short ReadJoystick(void);


/*-------------------------------------------------------*
 * NAME: DeallocateJoystick                              *
 *                                                       *
 * AUTHOR: Terence Russell (August 9,1993)               *
 *                                                       *
 * DESC: This routine deallocates a joystick gameport.   *
 *       Do NOT call this routine if a gameport was not  *
 *       previously allocated!                           *
 *-------------------------------------------------------*/

void  DeallocateJoystick(void);


struct MsgPort    *JoyStikMP;
struct IOStdReq   *JoyStikIO;

struct InputEvent JoyStikEV;
struct GamePortTrigger JoyStikTR;

short AllocateJoystick(void)
{
    char controllerType = 0;
    
    if( JoyStikMP = CreatePort(PORTNAME,0) )
    {
        if(JoyStikIO = (struct IOStdReq *)CreateExtIO(JoyStikMP,sizeof(*JoyStikIO)) )
        {     
            if(! OpenDevice("gameport.device",UNIT,(struct IORequest *)JoyStikIO,0) )
            {
                /* Now check controller type and ask if we can use it. */

                Forbid();
                
                JoyStikIO->io_Command = GPD_ASKCTYPE;
                JoyStikIO->io_Length  = 1;
                JoyStikIO->io_Flags   = IOF_QUICK;
                JoyStikIO->io_Data    = (APTR)&controllerType;
                DoIO((struct IORequest *)JoyStikIO);
                
                if(controllerType == GPCT_NOCONTROLLER)
                {
                    controllerType = GPCT_ABSJOYSTICK;
                    
                    JoyStikIO->io_Command = GPD_SETCTYPE;
                    JoyStikIO->io_Length  = 1;
                    JoyStikIO->io_Data    = (APTR)&controllerType;
                    DoIO((struct IORequest *)JoyStikIO);
                    
                    Permit();
                    
                    JoyStikIO->io_Command = CMD_CLEAR; // flush the buffer
                    JoyStikIO->io_Length  = 0;
                    JoyStikIO->io_Flags   = IOF_QUICK;
                    JoyStikIO->io_Data    = NULL;
                    DoIO((struct IORequest *)JoyStikIO);

                    JoyStikTR.gpt_Keys = GPTF_DOWNKEYS | GPTF_UPKEYS;
                    JoyStikTR.gpt_XDelta = 1;
                    JoyStikTR.gpt_YDelta = 1;
                    JoyStikIO->io_Command = GPD_SETTRIGGER;
                    JoyStikIO->io_Length  = sizeof(struct GamePortTrigger);
                    JoyStikIO->io_Data    = (APTR)&JoyStikTR;
                    DoIO((struct IORequest *)JoyStikIO);
                    
                    return (TRUE);
                };
                
                Permit();
                CloseDevice((struct IORequest *)JoyStikIO);// There should be no other IO requests pending.
            };
            
            DeleteExtIO((struct IORequest *)JoyStikIO);
        };

        DeletePort(JoyStikMP);
    };
    
    return (FALSE);
}

short ReadJoystick(void)
{
    static short RequestSwitch = FALSE, result = 0;
    register short temp;
    
    if(! RequestSwitch) // No request has yet been sent.
    {
        JoyStikIO->io_Command = GPD_READEVENT;
        JoyStikIO->io_Length  = sizeof( struct InputEvent);
        JoyStikIO->io_Data    = (APTR)&JoyStikEV;
        JoyStikIO->io_Flags   = 0;
        SendIO((struct IORequest *)JoyStikIO);// Asynchronous
        RequestSwitch = TRUE;
    };
    
    if( GetMsg(JoyStikMP) )
    {
        RequestSwitch = FALSE;
            
        switch(JoyStikEV.ie_Code)
        {
            case IECODE_LBUTTON:
                result |= LBUTTON;
                break;
                    
            case (IECODE_LBUTTON | IECODE_UP_PREFIX):
                result &= (!LBUTTON);
                break;
                
            case IECODE_RBUTTON:
                result |= RBUTTON;
                break;
                    
            case (IECODE_RBUTTON | IECODE_UP_PREFIX):
                result &= (!RBUTTON);
                break;
        };

        result &= (LBUTTON+RBUTTON);
        
        temp = JoyStikEV.ie_X;
        if(temp == -1) result |= XJOYLFT;
        else if(temp) result |= XJOYRGT;
        

        temp = JoyStikEV.ie_Y;
        if(temp == -1) result |= YJOYUP;
        else if(temp) result |= YJOYDWN;
    };
    
    return(result);
}

void DeallocateJoystick(void)
{
    char controllerType = GPCT_NOCONTROLLER;

    /* First toast any remaining asynchronous messages. */
    if(! CheckIO((struct IORequest *)JoyStikIO) )
    {
        AbortIO((struct IORequest *)JoyStikIO);
        WaitIO((struct IORequest *)JoyStikIO);
    };

    /* Tell the device we are no longer using it. */
    JoyStikIO->io_Command = GPD_SETCTYPE;
    JoyStikIO->io_Length  = 1;
    JoyStikIO->io_Flags   = IOF_QUICK;
    JoyStikIO->io_Data    = (APTR)&controllerType;
    DoIO((struct IORequest *)JoyStikIO);

    CloseDevice((struct IORequest *)JoyStikIO);
    DeleteExtIO((struct IORequest *)JoyStikIO);
    DeletePort(JoyStikMP);
}
