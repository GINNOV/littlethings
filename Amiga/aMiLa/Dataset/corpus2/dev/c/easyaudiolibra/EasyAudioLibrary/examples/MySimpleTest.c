/* ------------------------------------------------------------------ */
/* $VER: Lib-Test.c 39.01 (12.12.1999)                                */
/*                                                                    */
/* Demo program for easyaudio.library                                 */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */
      
#include <exec/types.h>
#include <exec/memory.h>

#include <dos/dos.h> /* for Delay() */

#include <proto/exec.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <easyaudio/easyaudio.h>
#include <proto/easyaudio.h>


int main(long argc, char **argv)
{
char text[40];
int frequency;
int duration;
int result;


 EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
    printf("\nEasyaudio.library opening failed\n");
    exit(20);
   }

 else /* opened correctly */
  {
   printf("Library opening WORKED\n");

   /* call the requestor function */
   result = EA_Request("Test Message",
                       "It works! (wow)",
                       "OK|Cancel");
   
   if (result ==0)
       printf("Cancel pressed\n");

   else if (result ==1)
            printf("Ok pressed\n");


   /* call the speech function */
   strcpy(text,"Hello World"); /* some text to speek */

   if (EA_Speech(text) ==1)
       printf("Ough shit, the speech broke !\n");
   else /* it worked */
       printf("i can speak\n");


   Delay(2 * 50); /* 2 second wait, so speeking finshes */

   printf("frequency\t");
   scanf("%d",&frequency);
   printf("duration\t");
   scanf("%d",&duration);

   /* call the beep function */
   if (EA_Beep(frequency,duration) ==1)
       printf("Ough shit, the beep broke !\n");
   else /* it worked */
       printf("i can beep\n");


   CloseLibrary((APTR) EasyaudioBase);

   exit(0);
  }

} /* end test program */

