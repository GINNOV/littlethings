#include <proto/all.h>
#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/dos.h>
#include <stdlib.h>

#define screenWidth 320
#define screenHeight 200
#define screenLeft 0
#define screenTop 0

int main() {
   struct Window *myWindow;
   int hasEnded = FALSE;
   struct IntuiMessage *msg;
   ULONG msgClass;

   // open window on the public workbench screen
   struct NewWindow winlayout = {
      screenLeft, screenTop,
      screenWidth, screenHeight,
      0,1,
      IDCMP_CLOSEWINDOW,
      WFLG_SIZEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE,
      NULL, NULL,
      "It's me!",
      NULL,NULL,
      0,0,
      600,400,
      WBENCHSCREEN
   };
   myWindow = OpenWindow(&winlayout);

   Move(myWindow->RPort, 40, 40);
   Text(myWindow->RPort, "Hello!", 6);

   while (hasEnded == FALSE) {
       // wait for and event
       Wait(1L << myWindow->UserPort->mp_SigBit);

       // get message
       msg = GT_GetIMsg(myWindow->UserPort);

       // get class of message;
       msgClass = msg->Class;

       // handle message (close it);
       GT_ReplyIMsg(msg);

       if (msgClass == IDCMP_CLOSEWINDOW) {
           CloseWindow(myWindow);
           hasEnded = TRUE;
       }
   }
   return(0);
}