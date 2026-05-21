#include <proto/intuition.h>
#include <proto/dos.h>
#include <intuition/screens.h>

#define SCREENWIDTH 320
#define SCREENHEIGHT 200

#define PLANES 5 // 32 colors

#define LORES 0

int main() {
    struct NewScreen screenProperties = {
         0,0,SCREENWIDTH,SCREENHEIGHT,PLANES,
         DETAILPEN, BLOCKPEN,
         LORES,
         CUSTOMSCREEN | CUSTOMBITMAP,
         NULL,
         "My Screen",
         NULL,
         NULL
     };
     struct Screen *myScreen;
     myScreen = OpenScreen(&screenProperties);
     ShowTitle(myScreen, FALSE);
     Delay(100);
     DisplayBeep(myScreen);
     Delay(10);
     if (myScreen) CloseScreen(myScreen);
     return(0);
   }