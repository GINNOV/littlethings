/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : ShowWinLose.c
 ** Created on       : Thursday, 04-Sep-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.02
 **
 ** Purpose
 ** -------
 **   shows win/loss image to player
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 04-Jun-98   Rick Keller            moved image data to header for clarity
 ** 04-Sep-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

#include "GameOutcome.h"

extern struct Window *EuchreMain;
extern LONG width, height;

void ShowWinLose(short winner)
{

    extern short Speed;

    LONG myX, myY;

    myX = (width/2) - 172;
    myY = (height/2) - 63;

    if (winner == 0)
    {
        DrawImage(EuchreMain->RPort, &youwin, myX, myY);
        Delay((LONG)(10*Speed));
        EraseImage(EuchreMain->RPort, &youwin, myX, myY);
    }

    else
    {
        DrawImage(EuchreMain->RPort, &youlose, myX, myY);
        Delay((LONG)(10*Speed));
        EraseImage(EuchreMain->RPort, &youlose, myX, myY);
    }
}
