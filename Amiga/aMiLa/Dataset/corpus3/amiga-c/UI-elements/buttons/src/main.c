#include "proto.h"

/*
2021 by Steffest
Compiled with SAS/C 6.5
*/

/*
    a more abstract approach to creating a button-driven UI    
*/

BOOL done = FALSE;
SHORT hasevent;

void main(void){
    struct EventInfo event;
    short UiElementIndex;
    init();

    while(!done){
        hasevent = waitUserAction();
        if (hasevent){
            event = getUserEvent();
            if (event.exit){done=TRUE;}
            if (event.mouseButton == -1){
                UiElementIndex = getButtonAtPoint(event.mouseX,event.mouseY);
                if (UiElementIndex == deActivateButton()){
                    // button was clicked
                    if (UiElementIndex == 1){
                        done=TRUE;
                    }
                };
            }
            if (event.mouseButton == 1){
              UiElementIndex = getButtonAtPoint(event.mouseX,event.mouseY);
              if (UiElementIndex>=0){
                  activateButton(UiElementIndex);
              }
            }
        }
    }

    quit();
}

void init(void){
    openDisplay();
    createUI();
}

void quit(void){
    closeDisplay();
}