#include <proto/exec.h>

#define WINDOW_WIDTH 400
#define WINDOW_HEIGHT 300

//main.c
extern void init(void);
extern void quit(void);

//window.c
extern struct RastPort *windowContext;
extern int windowMarginTop;
extern int windowMarginLeft;
unsigned char openDisplay(void);
void closeDisplay(void);
SHORT waitUserAction();
struct EventInfo getUserEvent();

//ui.c
void createUI(void);
void drawRect(int x, int y, int w, int h, int color);
void drawText(char *text , int x, int y, int textColorPen);
void drawTextBox(char *text , int x, int y, int w, int h,int textColorPen);

//button.c
void createButton(long left, long top, long width, long height, char *text);
void drawButton(short index);
short getButtonAtPoint(long x, long y);
void activateButton(short index);
short deActivateButton();

struct EventInfo{
    int mouseButton;
    int mouseX;
    int mouseY;
    int exit;
};

enum {
	MOUSE_BUTTON_NONE,
	MOUSE_BUTTON_LEFT,
	MOUSE_BUTTON_RIGHT
};