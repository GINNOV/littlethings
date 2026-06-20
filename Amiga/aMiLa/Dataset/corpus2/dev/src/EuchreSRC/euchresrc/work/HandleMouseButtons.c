///
/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : HandleMouseButtons.c
 ** Created on       : Friday, 22-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.02
 **
 ** Purpose
 ** -------
 **   reads which card is selected by user and returns index # to that card
 **     in the Player.Myhand[] array
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 29-Aug-97   Rick Keller            added IDCMP_MENUPICK handling
 ** 22-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
///




#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

extern HandleMenuEvents(struct IntuiMessage *);

extern LONG Player0Card[5][2];


int HandleMouseButtons(void)
{
    extern struct Window *EuchreMain;
    struct IntuiMessage *msg;
    int i, picked;
    short done= FALSE;



    while (done == FALSE)
    {
        Wait(1L << EuchreMain->UserPort->mp_SigBit);

        while ((done == FALSE) && (NULL != (msg = (struct IntuiMessage *)GetMsg(EuchreMain->UserPort))))
        {
            switch (msg->Class)
            {
                case IDCMP_REFRESHWINDOW:
                     BeginRefresh(EuchreMain);
                     EndRefresh(EuchreMain, TRUE);
                     break;
                case IDCMP_MOUSEBUTTONS:

                     switch (msg->Code)
                     {
                         case SELECTUP:
                             for (i = 0; i < 5; i++)
                             {
                                if ((msg->MouseX >= Player0Card[i][0] &&  msg->MouseX <= (Player0Card[i][0] + 65))&& (msg->MouseY >=  Player0Card[i][1]) && msg->MouseY <= (Player0Card[i][1] + 98))
                                {
                                    done = TRUE;
                                    picked = i;
                                    break;
                                }
                             }
                             break;
                     } //switch MouseButtons
                     break;
                 case IDCMP_MENUPICK:
                     HandleMenuEvents(msg);
                     break;

            }//end switch
        }//end while
    } //end while
    return picked;
}//end HandleMouseButtons()


