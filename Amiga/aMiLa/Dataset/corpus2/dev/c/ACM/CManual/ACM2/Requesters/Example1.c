/* Example1                                                            */
/* This example opens a Simple requester by calling the function       */
/* AutoRequest. It displays a message "This is a very simple           */
/* requester!", and has one gadget connected to it (on the right side) */
/* with the text "OK".                                                 */



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
  "This is a very simple requester!", /* IText, the text . */
  NULL,    /* NextText, no more IntuiText structures link. */
};

/* The OK text: */
struct IntuiText my_ok_text=
{
  0,       /* FrontPen, colour 0 (blue). */
  0,       /* BackPen, not used since JAM1. */
  JAM1,    /* DrawMode, do not change the background. */
  6,       /* LedtEdge, 6 pixels out. */
  3,       /* TopEdge, 3 lines down. */
  NULL,    /* ITextFont, default font. */
  "OK",    /* IText, the text that will be printed. */
  NULL,    /* NextText, no more IntuiText structures link. */
};



main()
{
  /* Before we can use Intuition we need to open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  AutoRequest(NULL, &my_body_text, NULL, &my_ok_text, NULL, NULL, 320, 72);

  /***********************************************************************/
  /* NULL,              no pointer to a window structure.                */
  /* &my_body_text,     pointer to a IntuiText str. cont. the body text  */
  /* NULL,              no gadget on the right side.                     */
  /* &my_ok_text,       pointer to a IntuiText str. cont. the neg. text  */
  /* NULL,              no gadget on the right side.                     */
  /* NULL,              IDCMP flags which will satisfy the negative gad. */
  /* 320,               Width, 320 pixels wide.                          */
  /* 72,                Height, 72 lines high.                           */
  /*                                                                     */
  /* Intuition will automatically set the IDCMP flag RELVERIFY for both  */
  /* of the gadgets, so we do not need to set any IDCMP flags if we do   */
  /* not want to.                                                        */
  /*                                                                     */
  /* The requester will look like this:                                  */
  /*                                                                     */
  /* ---------------------------------------                             */
  /* | System Request ================[*][*]                             */
  /* ---------------------------------------                             */
  /* | This is a very simple requester! |  |                             */
  /* |                                  |  |                             */
  /* |                                  |  |                             */
  /* |                           ------ |  |                             */
  /* |                           | OK | |  |                             */
  /* |                           ------ |  |                             */
  /* ------------------------------------[*]                             */
  /*                                                                     */
  /***********************************************************************/



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}
