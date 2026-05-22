/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : Config.c
 ** Created on       : Tuesday, 09-Jun-98
 ** Created by       : Rick Keller
 ** Current revision : V 1.05
 **
 ** Purpose
 ** -------
 **   handle all configuration details
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 18-Oct-98   Rick Keller            added screen mode preference
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 12-Aug-98   Rick Keller            finished settings editor
 ** 11-Aug-98   Rick Keller            began integrating Settings Editor
 ** 09-Jun-98   Rick Keller            added BadConfig error msg, began integration into prog
 ** 09-Jun-98   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/


#include <exec/types.h>
#include <stdio.h>
#include <string.h>
#include <intuition/intuition.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdlib.h>

#include "settings.h"
#include "gamesetup.h"

#define MAX 20

extern struct Window *EuchreMain;
extern int OpensettingsWindow( void );

void BadConfig(BYTE *error);

int ReadConfig( void )
{
    extern short Speed;
    extern short Loner;
    extern BOOL End;
    extern short pstyle[3];
    extern ULONG EuchreScreenMode;


    FILE *config = NULL;
    BYTE *setting = "REALBADSTUFFHERECOWBOYS";
    BYTE *errormsg = "MOREREALBADSTUFF";
    BYTE *tempscreenmode;
    BOOL configerror = FALSE;
    if ((config = fopen("Euchre.config","r")) == NULL)
    {
        OpensettingsWindow();
        config = fopen("Euchre.config","r");
    }

    if (config)
    {
        //read in setting for ScreenMode
        tempscreenmode = fgets(setting, MAX, config);
        EuchreScreenMode = strtoul(setting, &tempscreenmode, 0);
        if (EuchreScreenMode == 0)
        {
            errormsg = "Euchre! Screen Mode";
            BadConfig(errormsg);
            configerror = TRUE;
        }

        //read in setting for playing styles:
        //player 1

        if (strcmp(fgets(setting, MAX, config),"MODERATE\n") == 0)
        {
            pstyle[PLAYER_1] = MODERATE;
        }

        else if (strcmp(setting, "CONSERVATIVE\n") == 0)
        {
            pstyle[PLAYER_1] = CONSERVATIVE;
        }

        else if (strcmp(setting, "RISKY\n") == 0)
        {
            pstyle[PLAYER_1] = RISKY;
        }

        else
        {
            errormsg = "Player1Style";
            BadConfig(errormsg);
            configerror = TRUE;
        }

    //player2
        if (strcmp(fgets(setting, MAX, config),"MODERATE\n") == 0)
        {
            pstyle[PLAYER_2] = MODERATE;
        }

        else if (strcmp(setting, "CONSERVATIVE\n") == 0)
        {
            pstyle[PLAYER_2] = CONSERVATIVE;
        }

        else if (strcmp(setting, "RISKY\n") == 0)
        {
            pstyle[PLAYER_2] = RISKY;
        }

        else

        {
            errormsg = "Player2Style";
            BadConfig(errormsg);
            configerror = TRUE;
        }

    //player3
        if (strcmp(fgets(setting, MAX, config),"MODERATE\n") == 0)
        {
            pstyle[PLAYER_3] = MODERATE;
        }

        else if (strcmp(setting, "CONSERVATIVE\n") == 0)
        {
            pstyle[PLAYER_3] = CONSERVATIVE;
        }

        else if (strcmp(setting, "RISKY\n") == 0)
        {
            pstyle[PLAYER_3] = RISKY;
        }

        else
        {
            errormsg = "Player3Style";
            BadConfig(errormsg);
            configerror = TRUE;
        }

    //read in setting for loner value

        if (strcmp(fgets(setting, MAX, config),"THREE\n") == 0)
        {

            Loner = THREE_POINT;

        }

        else if (strcmp(setting, "FOUR\n") == 0)
        {
            Loner = FOUR_POINT;

        }


        else
        {
            errormsg = "LonerVal";
            BadConfig(errormsg);
            configerror = TRUE;
        }
    //now check setting for end early
        if (strcmp(fgets(setting,MAX, config),"ENDEARLY\n") == 0)
        {

            End = TRUE;

        }

        else if (strcmp(setting, "NOEARLY\n") == 0)
        {
            End = FALSE;

        }

        else
        {
            errormsg = "EndEarly";
            BadConfig(errormsg);
            configerror = TRUE;
        }



    //now check setting for play speed
        if (strcmp(fgets(setting,MAX, config),"SLOW\n") == 0)
        {
            Speed = SLOW_SPEED;

        }

        else if (strcmp(setting, "NORMAL\n") == 0)
        {
            Speed = NORMAL_SPEED;

        }

        else if (strcmp(setting, "FAST\n") == 0)
        {
            Speed = FAST_SPEED;

        }
        else if (strcmp(setting, "RIDICULOUS\n") == 0)
        {
            Speed = RIDICULOUS_SPEED;

        }
        else
        {
            errormsg = "PlaySpeed";
            BadConfig(errormsg);
            configerror = TRUE;
        }
        if (config)
            fclose(config);
    }

    if (configerror == TRUE)
        OpensettingsWindow();

    return 0;
}

void BadConfig(BYTE *error)
{
    struct EasyStruct ConfigError =
    {
        sizeof(struct EasyStruct),
        0,
        "Error",
        "There was an error in the configuration for %s.\n",
        "Ok",
    };

    EasyRequest(EuchreMain, &ConfigError, NULL, error);
}


