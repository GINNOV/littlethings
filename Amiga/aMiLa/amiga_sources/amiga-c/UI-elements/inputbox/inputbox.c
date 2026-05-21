//
// Created by stef on 02/04/2020.
//

/* Example7                                                           */
/* This program will open a normal window which is connected to the   */
/* Workbench Screen. The window will use all System Gadgets, and will */
/* close first when the user has selected the System gadget Close     */
/* window. Inside the window we have put a String gadget.             */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* THE STRING GADGET's STRUCTURES: */

/* The coordinates for the box: */
SHORT my_points[]=
        {
                -7, -4, /* Start at position (-7, -4) */
                200, -4, /* Draw a line to the right to position (200,-4) */
                200, 11, /* Draw a line down to position (200,11) */
                -7, 11, /* Draw a line to the right to position (-7,11) */
                -7, -4  /* Finish of by drawing a line up to position (-7,-4) */
        };

/* The Border structure: */
struct Border my_border=
        {
                0, 0,        /* LeftEdge, TopEdge. */
                1,           /* FrontPen, colour register 1. */
                0,           /* BackPen, for the moment unused. */
                JAM1,        /* DrawMode, draw the lines with colour 1. */
                5,           /* Count, 5 pair of coordinates in the array. */
                my_points,   /* XY, pointer to the array with the coordinates. */
                NULL,        /* NextBorder, no other Border structures are connected. */
        };



/* The IntuiText structure: */
struct IntuiText my_text=
        {
                1,         /* FrontPen, colour register 1. */
                0,         /* BackPen, colour register 0. */
                JAM1,      /* DrawMode, draw the characters with colour 1, do not */
                /* change the background. */
                -53, 0,    /* LeftEdge, TopEdge. */
                NULL,      /* ITextFont, use default font. */
                "Text:",   /* IText, the text that will be printed. */
                NULL,      /* NextText, no other IntuiText structures. */
        };



UBYTE my_buffer[50]; /* 50 characters including the NULL-sign. */
UBYTE my_undo_buffer[50]; /* Must be at least as big as my_buffer. */



struct StringInfo my_string_info=
        {
                my_buffer,       /* Buffer, pointer to a null-terminated string. */
                my_undo_buffer,  /* UndoBuffer, pointer to a null-terminated string. */
                /* (Remember my_buffer is equal to &my_buffer[0]) */
                0,               /* BufferPos, initial position of the cursor. */
                50,              /* MaxChars, 50 characters + null-sign ('\0'). */
                0,               /* DispPos, first character in the string should be */
                /* first character in the display. */

                /* Intuition initializes and maintaines these variables: */

                0,               /* UndoPos */
                0,               /* NumChars */
                0,               /* DispCount */
                0, 0,            /* CLeft, CTop */
                NULL,            /* LayerPtr */
                NULL,            /* LongInt */
                NULL,            /* AltKeyMap */
        };


struct Gadget my_gadget=
        {
                NULL,          /* NextGadget, no more gadgets in the list. */
                68,            /* LeftEdge, 68 pixels out. */
                30,            /* TopEdge, 30 lines down. */
                198,           /* Width, 198 pixels wide. */
                8,             /* Height, 8 pixels lines heigh. */
                GADGHCOMP,     /* Flags, draw the select box in the complement */
                /* colours. Note: it actually only the cursor which */
                /* will be drawn in the complement colours (yellow). */
                /* If you set the flag GADGHNONE the cursor will not be */
                /* highlighted, and the user will therefore not be able */
                /* to see it. */
                GADGIMMEDIATE| /* Activation, our program will recieve a message when */
                RELVERIFY,     /* the user has selected this gadget, and when the user */
                /* has released it. */
                STRGADGET,     /* GadgetType, a String gadget. */
                (APTR) &my_border, /* GadgetRender, a pointer to our Border structure. */
                NULL,          /* SelectRender, NULL since we do not supply the gadget */
                /* with an alternative image. */
                &my_text,      /* GadgetText, a pointer to our IntuiText structure. */
                NULL,          /* MutualExclude, no mutual exclude. */
                (APTR) &my_string_info, /* SpecialInfo, a pointer to a StringInfo str. */
                0,             /* GadgetID, no id. */
                NULL           /* UserData, no user data connected to the gadget. */
        };



/* Declare a pointer to a Window structure: */
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
        {
                50,            /* LeftEdge    x position of the window. */
                25,            /* TopEdge     y positio of the window. */
                320,           /* Width       320 pixels wide. */
                100,           /* Height      100 lines high. */
                0,             /* DetailPen   Text should be drawn with colour reg. 0 */
                1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
                CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
                /*             user has selected the Close window gad, */
                GADGETDOWN|    /*             or a gadget has been pressed on, or */
                GADGETUP,      /*             a gadge has been released. */
                SMART_REFRESH| /* Flags       Intuition should refresh the window. */
                WINDOWCLOSE|   /*             Close Gadget. */
                WINDOWDRAG|    /*             Drag gadget. */
                WINDOWDEPTH|   /*             Depth arrange Gadgets. */
                WINDOWSIZING|  /*             Sizing Gadget. */
                ACTIVATE,      /*             The window should be Active when opened. */
                &my_gadget,    /* FirstGadget A pointer to the String gadget. */
                NULL,          /* CheckMark   Use Intuition's default CheckMark. */
                "String Window",/* Title       Title of the window. */
                NULL,          /* Screen      Connected to the Workbench Screen. */
                NULL,          /* BitMap      No Custom BitMap. */
                320,           /* MinWidth    We will not allow the window to become */
                50,            /* MinHeight   smaller than 320 x 50, and not bigger */
                640,           /* MaxWidth    than 640 x 200. */
                200,           /* MaxHeight */
                WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
        };



main()
{
    /* Boolean variable used for the while loop: */
    BOOL close_me;

    /* Declare a variable in which we will store the IDCMP flag: */
    ULONG class;

    /* Declare a pointer to an IntuiMessage structure: */
    struct IntuiMessage *my_message;



    /* Put some text into the my_buffer string: */
    strcpy( my_buffer, "Some text" );



    /* Before we can use Intuition we need to open the Intuition Library: */
    IntuitionBase = (struct IntuitionBase *)
            OpenLibrary( "intuition.library", 0 );

    if( IntuitionBase == NULL )
        exit(); /* Could NOT open the Intuition Library! */



    /* We will now try to open the window: */
    my_window = (struct Window *) OpenWindow( &my_new_window );

    /* Have we opened the window succesfully? */
    if(my_window == NULL)
    {
        /* Could NOT open the Window! */

        /* Close the Intuition Library since we have opened it: */
        CloseLibrary( IntuitionBase );

        exit();
    }



    /* We have opened the window, and everything seems to be OK. */



    close_me = FALSE;

    /* Stay in the while loop until the user has selected the Close window */
    /* gadget: */
    while( close_me == FALSE )
    {
        /* Wait until we have recieved a message: */
        Wait( 1 << my_window->UserPort->mp_SigBit );

        /* Collect the message: */
        my_message = (struct IntuiMessage *) GetMsg( my_window->UserPort );

        /* Have we collected the message sucessfully? */
        if(my_message)
        {
            /* After we have collected the message we can read it, and save any */
            /* important values which we maybe want to check later: */
            class = my_message->Class;      /* Save the IDCMP flag. */

            /* After we have read it we reply as fast as possible: */
            /* REMEMBER! Do never try to read a message after you have replied! */
            /* Some other process has maybe changed it. */
            ReplyMsg( my_message );

            /* Check which IDCMP flag was sent: */
            switch( class )
            {
                case CLOSEWINDOW:  /* The user selected the Close window gadget! */
                    close_me=TRUE;
                    break;

                case GADGETDOWN:   /* The user has selected the String gadget: */
                    /* (Clicked inside the select box) */
                    printf("String gadget selected.\n");
                    break;

                case GADGETUP:     /* The user has released the String gadget: */
                    /* (Pressed ENTER or RETURN) */
                    printf("String gadget released.\n");
                    break;
            }
        }
    }



    /* Print out the final string: */
    printf("String: %s\n", my_string_info.Buffer);



    /* We should always close the windows we have opened before we leave: */
    CloseWindow( my_window );



    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    /* THE END */
}