#include "proto.h"

static struct Button {
    unsigned char index;
    long left;
    long top;
    long width;
    long height;
    short active;
    char *text;
};

static short buttonCount = 0;
static struct Button buttons[10];
static short activeButton = -1;
static short highLightPen = 2;
static short shadowPen = 1;
static short fillPen = 3;

void createButton(long left, long top, long width, long height, char *text){
    buttons[buttonCount].left = left + windowMarginLeft;
    buttons[buttonCount].top = top + windowMarginTop;
    buttons[buttonCount].width = width;
    buttons[buttonCount].height = height;
    buttons[buttonCount].active = 0;
    buttons[buttonCount].text = text;

    drawButton(buttonCount);
    buttonCount++;
}

void drawButton(short index){
    struct Button b = buttons[index];
    if (b.active){
        drawRect(b.left,b.top,b.width,b.height,shadowPen);
        drawRect(b.left+1,b.top+1,b.width-1,b.height-1,highLightPen);
        drawRect(b.left+1,b.top+1,b.width-2,b.height-2,highLightPen);
        drawTextBox(b.text,b.left,b.top+1,b.width,b.height+1,shadowPen);
    }else{
        drawRect(b.left,b.top,b.width,b.height,highLightPen);
        drawRect(b.left+1,b.top+1,b.width-1,b.height-1,shadowPen);
        drawRect(b.left+1,b.top+1,b.width-2,b.height-2,fillPen);
        drawTextBox(b.text,b.left,b.top,b.width,b.height,shadowPen);
    }

}

short getButtonAtPoint(long x, long y){
    short i;
    for (i = 0;i<buttonCount;i++){
        struct Button b = buttons[i];
		if (x>b.left && x<b.left+b.width && y>b.top && y<b.top+b.height){
            return i;
        }
	}
    return -1;
}

void activateButton(short index){
    activeButton = index;
    buttons[index].active = 1;
    drawButton(index);
}

short deActivateButton(){
    short prevActiveButton = activeButton;
    if (activeButton>=0){
         buttons[activeButton].active = 0;
        drawButton(activeButton);
    }
    activeButton = -1;
    return prevActiveButton;
}