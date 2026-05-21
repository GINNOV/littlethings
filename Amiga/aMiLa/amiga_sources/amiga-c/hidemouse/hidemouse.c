/*
	Clears the mouse pointer for a window
*/

#include <proto/all.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>


#define windowWidth 240
#define windowHeight 160
#define windowLeft 20
#define windowTop 20

struct Window *myWindow;
void cleanExit(void);


static UWORD *cursor;

int main() {
   int hasEnded = FALSE;
   int counter = 0;
   struct IntuiMessage *msg;
   ULONG msgClass;

   // open window on the public workbench screen
   struct NewWindow winlayout = {
      windowLeft, windowTop,
      windowWidth, windowHeight,
      0,1,
      IDCMP_CLOSEWINDOW,
      WFLG_SIZEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET | WFLG_ACTIVATE,
      NULL, NULL,
      "Hide Mouse",
      NULL,NULL,
      0,0,
      600,400,
      WBENCHSCREEN
   };
   myWindow = OpenWindow(&winlayout);

   // set custom mouse pointer
   cursor = AllocMem(128, MEMF_CHIP | MEMF_CLEAR);
   if (cursor) SetPointer(myWindow, cursor, 1, 1, 0, 0);

   SetAPen(myWindow->RPort,1);
   Move(myWindow->RPort, 20, 40);
   Text(myWindow->RPort, "Look Ma!", 8);
   Move(myWindow->RPort, 20, 52);
   Text(myWindow->RPort, "No mouse pointer!", 17);
   Move(myWindow->RPort, 20, 70);
   Text(myWindow->RPort, "Deactivate this window", 22);
   Move(myWindow->RPort, 20, 82);
   Text(myWindow->RPort, "to restore it.", 14);


   while (hasEnded == FALSE) {

       // get message
       msg = GT_GetIMsg(myWindow->UserPort);

       if (msg){
       		msgClass = msg->Class;
       		GT_ReplyIMsg(msg);
       		if (msgClass == IDCMP_CLOSEWINDOW) hasEnded = TRUE;
       }

       counter++;
       Delay(1);
       if (counter>500) hasEnded = TRUE;
   }

	cleanExit();


   return(0);
}

void cleanExit(){
	if(cursor) {
		ClearPointer(myWindow);
		FreeMem(cursor, 128); cursor = 0;
	}
    CloseWindow(myWindow);
}

