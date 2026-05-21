#include "proto.h"
#include <intuition/intuition.h>



void createUI(){
    createButton(20,20,100,20,"Button 1");
    createButton(130,20,100,20,"Button 2");
}

void drawRect(int x, int y, int w, int h, int color){
	SetAPen(windowContext, color);
    RectFill(windowContext, x, y, x + w - 1, y + h - 1);
}

// writes a line of text at x,y position with a specific color
void drawText(char *text , int x, int y, int textColorPen){
    SetAPen(windowContext, textColorPen);
    SetDrMd(windowContext, JAM1);
    //SetBPen(windowContext, backGroundColorPen);
    Move(windowContext, x, y + windowContext->Font->tf_Baseline);
    Text(windowContext, text, strlen(text));
}

// writes a line of text with a specific color
// centered in a bounding box
void drawTextBox(char *text , int x, int y, int w, int h,int textColorPen){
    int left;
    int top;

    //TODO: apparently there's a textlength function?
    //http://amigadev.elowar.com/read/ADCD_2.1/Libraries_Manual_guide/node03DA.html
    top = y + (h+windowContext->Font->tf_Baseline)/2;
    left = x + (w-(windowContext->Font->tf_XSize*strlen(text)))/2;
    
    SetAPen(windowContext, textColorPen);
    SetDrMd(windowContext, JAM1);
    Move(windowContext, left, top);
    Text(windowContext, text, strlen(text));
}

