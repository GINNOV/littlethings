/* Example1                                                          */
/* This example displays an Alert message at the top of the display:   */
/*                                                                     */
/*  -----------------------------------------------------------------  */
/*  |                                                               |  */
/*  |  DANGER! Stupid user behind the keyboard!                     |  */
/*  |                                                               |  */
/*  |  Press Left Button to Retry   Press Right Button to Abort     |  */
/*  |                                                               |  */
/*  -----------------------------------------------------------------  */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



main()
{
  /* The string which will be printed out: */
  char message[106];

  /* In this variable will we store what DisplayAlert() returned: */
  BOOL result;



  /* Before we can use Intuition we need to open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* We will now fill the message array with our requirements: */
  
  /* Put the first string into the array. Remember to give space for 3 */
  /* characters in the beginning. We will there store the x (2 bytes)  */
  /* and y (1 byte) position of the text:                              */

  strcpy( message, "   DANGER! Stupid user behind the keyboard!");


  /* Put the second string into the array. Remember to give space for  */
  /* 5 (!) characters/bytes. We will there store the NULL sign which   */
  /* finish of the first string, the TRUE sign which tells Intuition   */
  /* that another string will come, and three bytes used to position   */
  /* the text:                                                         */

  strcat( message,
          "     Press Left Button to Retry   Press Right Button to Abort");
    

  message[0]=0;       /* X position of the first string */
  message[1]=32;      /*               - " -            */
  message[2]=16;      /* Y             - " -            */

  message[43]='\0';   /* NULL sign which finish of the first string. */
  message[44]=TRUE;   /* Continuation byte set to TRUE (new string). */
  
  message[45]=0;      /* X position of the second string. */
  message[46]=32;     /*               - " -              */
  message[47]=32;     /* Y             - " -              */

  message[104]='\0';  /* NULL sign which finish of the second string. */
  message[105]=FALSE; /* Continuation byte set to FALSE (last string). */



  /* We will now display the Alert message: */
  result = DisplayAlert( RECOVERY_ALERT, message, 48 );
  
  /*******************************************************************/
  /* RECOVERY_ALERT: The system will survive after this message have */
  /*                 been displayed.                                 */
  /* message:        Pointer to the string which contains the text   */
  /*                 we want to display + information about where we */
  /*                 want to display it (x/y position) etc.          */
  /* 48:             The height of the Alert box. (48 lines high)    */
  /*******************************************************************/
  
  
  
  if(result)
  {
    /* result is equal to TRUE, left button was pressed: */
    printf("RETRY: Left button was pressed\n");
  }
  else
  {
    /* result is equal to FALSE, right button was pressed: */
    printf("ABORT: Right button was pressed\n");
  }



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}
