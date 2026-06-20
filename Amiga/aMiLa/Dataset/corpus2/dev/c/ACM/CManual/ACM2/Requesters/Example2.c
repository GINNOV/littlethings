/* Example2                                                             */
/* This example opens a Simple requester by calling the function        */
/* AutoRequest. It displays a message "Do you really want to quit?",    */
/* and allows the user to choose between "Yes" and "No". The program    */
/* will continue to open the requester until the user has chosen "Yes". */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* The body text for the requester: */
struct IntuiText my_body_text=
{
  0,       /* FrontPen, colour 0 (blue). */
  0,       /* BackPen, not used since JAM1. */
  JAM1,    /* DrawMode, do not change the background. */
  15,      /* LedtEdge, 15 pixels out. */
  5,       /* TopEdge, 5 lines down. */
  NULL,    /* ITextFont, default font. */
  "Do you really want to quit?", /* IText, the text that will be printed. */
  NULL,    /* NextText, no more IntuiText structures link. */
};

/* The positive text: */
/* (Printed inside the left gadget) */
struct IntuiText my_positive_text=
{
  0,       /* FrontPen, colour 0 (blue). */
  0,       /* BackPen, not used since JAM1. */
  JAM1,    /* DrawMode, do not change the background. */
  6,       /* LedtEdge, 6 pixels out. */
  3,       /* TopEdge, 3 lines down. */
  NULL,    /* ITextFont, default font. */
  "Yes",   /* IText, the text that will be printed. */
  NULL,    /* NextText, no more IntuiText structures link. */
};

/* The negative text: */
/* (Printed inside the right gadget) */
struct IntuiText my_negative_text=
{
  0,       /* FrontPen, colour 0 (blue). */
  0,       /* BackPen, not used since JAM1. */
  JAM1,    /* DrawMode, do not change the background. */
  6,       /* LedtEdge, 6 pixels out. */
  3,       /* TopEdge, 3 lines down. */
  NULL,    /* ITextFont, default font. */
  "No",    /* IText, the text that will be printed. */
  NULL,    /* NextText, no more IntuiText structures link. */
};



main()
{
  /* Before we can use Intuition we need to open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  while( !AutoRequest( NULL, &my_body_text, &my_positive_text,
                       &my_negative_text, NULL, NULL, 320, 72) );

  /***********************************************************************/
  /* NULL,              no pointer to a window structure.                */
  /* &my_body_text,     pointer to a IntuiText str. cont. the body text  */
  /* &my_positive_text, pointer to a IntuiText str. cont. the pos. text  */
  /* &my_negative_text, pointer to a IntuiText str. cont. the neg. text  */
  /* NULL,              IDCMP flags which will satisfy the positive gad. */
  /* NULL,              IDCMP flags which will satisfy the negative gad. */
  /* 320,               Width, 320 pixels wide.                          */
  /* 72,                Height, 72 lines high.                           */
  /*                                                                     */
  /* Intuition will automatically set the IDCMP flag RELVERIFY for both  */
  /* of the gadgets, so we do not need to set any IDCMP flags if we do   */
  /* not want to.                                                        */
  /*                                                                     */
  /* while( !AutoRequest(...) );                                         */
  /* Since AutoRequest returns TRUE ("Yes") or FALSE ("No") we neggate   */
  /* it (!), and can then use the statement in a while loop. As long as  */
  /* the user selects the "No" gadget AutoRequest returns FALSE which    */
  /* is changed into TRUE, and we stay in the while loop. When the user, */
  /* on the other hand, selects the "Yes" gadget AutoRequest() returns   */
  /* TRUE, changed into FALSE, and we leave the while loop.              */
  /*                                                                     */
  /* The requester will look like this:                                  */
  /*                                                                     */
  /* ---------------------------------------                             */
  /* | System Request ================[*][*]                             */
  /* ---------------------------------------                             */
  /* | Do you really want to quit?      |  |                             */
  /* |                                  |  |                             */
  /* |                                  |  |                             */
  /* | -------                   ------ |  |                             */
  /* | | Yes |                   | No | |  |                             */
  /* | -------                   ------ |  |                             */
  /* ------------------------------------[*]                             */
  /*                                                                     */
  /***********************************************************************/



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}
