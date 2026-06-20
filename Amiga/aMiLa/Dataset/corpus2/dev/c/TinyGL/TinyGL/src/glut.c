// TODO: placer les prototypes dans glut.c
    
#include <stdio.h>
//#include <lib/time.h>

#include <proto/timer.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>

#include <dos/dos.h>
 
#include <GL/glut.h>
#include <GL/gla.h>

#ifdef __SASC
#include <dos/dos.h>
#include <clib/exec_protos.h>
struct Library *TimerBase = NULL;
#else
#ifdef __MORPHOS__
struct Library *TimerBase = NULL;
#else
struct Device *TimerBase = NULL;
#endif
#endif
 
//#define __isMouseEvent(a) a >= EV_MOUSEEVENTS && a < EV_MOUSEEVENTS+6
//#define __isKeyEvent(a) a >= EV_KEYBOARDEVENTS && a < EV_KEYBOARDEVENTS+3

//#define SIGBREAKF_CTRL_C   (1<<12)

struct GfxBase *GfxBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct Library *CyberGfxBase = NULL;

typedef struct {
    int x, y, width, height, depth;
    struct Window *win;
    GLboolean redisplay;
    GLboolean reshape;
} glut_window_t;

// Ajouter un __glut_state : quoique, il y a un windowCreated
// ou __glut_initialized

//static glut_ave_t __glut_ave;
static int __glut_initX = 0, __glut_initY = 0;
static int __glut_initWidth = 320, __glut_initHeight = 256, __glut_initDepth = 8;
static int __glut_mouseX = 0, __glut_mouseY = 0;
static glut_window_t __glut_window;
static GLAContext __glut_ctx = NULL;
static int __glut_currWindow = 0;
//static int __glut_numWindows = 0;
static struct timeval __glut_initTime;
static GLboolean __glut_fullScreen = GL_FALSE;
static GLboolean __glut_windowCreated = GL_FALSE;
//static char* __glut_windowName;
static struct Screen *__glut_screen = NULL;
static struct timerequest __glut_timeRequest;
 
typedef void (*glut_displayFunc_t)(void);
typedef void (*glut_idleFunc_t)(void);
typedef void (*glut_keyboardFunc_t)(unsigned char key, int x, int y);
typedef void (*glut_reshapeFunc_t)(int width, int height);

static glut_displayFunc_t __glut_displayFunc = NULL;
static glut_idleFunc_t __glut_idleFunc = NULL;
static glut_keyboardFunc_t __glut_keyboardFunc = NULL;
static glut_reshapeFunc_t __glut_reshapeFunc = NULL;

static int ProcessMessages(struct Window *WinHandle);
    
// Auxiliary functions

void __setupWindow() {
    if (__glut_fullScreen) {
        __glut_window.width = __glut_initWidth = glutGet(GLUT_SCREEN_WIDTH);
        __glut_window.height = __glut_initHeight = glutGet(GLUT_SCREEN_HEIGHT);
        __glut_window.x = __glut_window.y = 0;
    }

    // Changer la position de la fenêtre


    //glAMakeCurrent(__glut_window.win, __glut_ctx);
    __glut_windowCreated = GL_TRUE;
}


// GLUT API Functions

void glutInit(int *argcp, char **argv) {
    int error;

GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 39L);
IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39L);

   
    CyberGfxBase = (struct Library *)OpenLibrary("cybergraphics.library", 41L);

    if (__glut_ctx != NULL) {
			return;
    }

    error = OpenDevice(TIMERNAME, UNIT_MICROHZ, (struct IORequest *) &__glut_timeRequest, 0);
#ifdef __SASC
		TimerBase = (struct Library *)__glut_timeRequest.tr_node.io_Device;
#else
#ifdef __MORPHOS__
		TimerBase = (struct Library *)__glut_timeRequest.tr_node.io_Device;
#else
		TimerBase = __glut_timeRequest.tr_node.io_Device;
#endif
#endif
    GetSysTime(&__glut_initTime);
    
  __glut_ctx = glACreateContext();
}
    
 
// TODO: Contrôler que ça ne sort pas de l'écran
void glutInitWindowPosition(int x, int y) {
    __glut_window.x = __glut_initX = x;
    __glut_window.y = __glut_initY = y;
}


// TODO: S'assurer que la largeur soit multiple de 4 (ou 8 ?)
void glutInitWindowSize(int width, int height) {
    __glut_window.width = __glut_initWidth = width;
    __glut_window.height = __glut_initHeight = height;
}

                                                                                                            
// TODO : Codes d'erreur
// renseigner __glut_window.depth = GetBitMapAttr(window->BitMap, BMA_DEPTH);
// Il semble que si la fct s'exécute bien, elle retourne 1
int glutCreateWindow(char *name) {
    struct Screen *screen = NULL;
    unsigned long modeID = INVALID_ID;
    struct Screen   *WbScreen;
 
		// Workbench depth
		WbScreen = LockPubScreen("Workbench");
		if (WbScreen){
			if (CyberGfxBase){
				__glut_initDepth = GetCyberMapAttr(WbScreen->RastPort.BitMap, CYBRMATTR_DEPTH);
			}else{
				__glut_initDepth = GetBitMapAttr(WbScreen->RastPort.BitMap, BMA_DEPTH);
			}
			UnlockPubScreen(NULL, WbScreen);
		}

//printf("__glut_initDepth : %d\n", __glut_initDepth);
    if (__glut_initDepth < 8){
        __glut_initDepth = 8;
				__glut_fullScreen = GL_TRUE;
    }
											
		// Best ModeID
    if (CyberGfxBase){
				modeID = BestCModeIDTags(CYBRBIDTG_Depth, __glut_initDepth,
																CYBRBIDTG_NominalWidth, __glut_initWidth,
																CYBRBIDTG_NominalHeight, __glut_initHeight,
																TAG_DONE);
		}
   
    if (modeID == (unsigned long)INVALID_ID){
        modeID = BestModeID(
                BIDTAG_NominalWidth, __glut_initWidth,
                BIDTAG_NominalHeight, __glut_initHeight,
                BIDTAG_Depth, __glut_initDepth,
								BIDTAG_MonitorID, (ULONG)(GetVPModeID(&WbScreen->ViewPort) & MONITOR_ID_MASK),
								TAG_END);
    }

    if (modeID == (unsigned long)INVALID_ID){
        return 0;
	}
																										
 
		// Open the display
		if (__glut_fullScreen == GL_TRUE){
//printf("glut full screen\n");
        screen = OpenScreenTags(NULL,
                                     SA_Width, __glut_initWidth,
                                     SA_Height, __glut_initHeight,
                                     SA_Depth, __glut_initDepth,
                                     SA_Title, (ULONG)"TinyGL",
                                     SA_ShowTitle, FALSE,
                                     SA_Type, CUSTOMSCREEN,
                                     SA_SharePens, TRUE,
                                     SA_DisplayID, modeID,
                                     SA_Interleaved, TRUE,
												SA_FullPalette, __glut_initDepth == 8,
                                     TAG_DONE);
        if (screen == NULL){
            return 0;
        }
        
        __glut_screen = screen;
                                                        
        __glut_window.win = OpenWindowTags(NULL,
                        WA_Left, __glut_initX,
                        WA_Top, __glut_initY,
                        WA_Width, __glut_initWidth,
                        WA_Height, __glut_initHeight,
                        WA_CustomScreen, (ULONG)screen,
                        //WA_RMBTrap, TRUE,
												WA_CloseGadget, FALSE,
												WA_DepthGadget, FALSE,
												WA_Activate, TRUE,
                        WA_Title, (unsigned long)name,
                        WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_ACTIVEWINDOW| IDCMP_IDCMPUPDATE | IDCMP_CHANGEWINDOW | IDCMP_NEWSIZE | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS | IDCMP_VANILLAKEY | IDCMP_RAWKEY, // | IDCMP_INTUITICKS | IDCMP_NEWSIZE,
												WA_Flags, WFLG_SIZEGADGET | WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET, // | WFLG_REPORTMOUSE,
												TAG_DONE);

    }else{
        __glut_screen = WbScreen;
                                                    
        // TODO : changer initX et initY dans le cas de fenêtre sur Wb
        // voir si les flags et IDCMP sont ok
        __glut_window.win = OpenWindowTags(NULL,
                        WA_Left, __glut_initX,
                        WA_Top, __glut_initY,
                        WA_InnerWidth, __glut_initWidth,
                        WA_InnerHeight, __glut_initHeight,
                        WA_CustomScreen, (ULONG)WbScreen,
                        WA_SizeGadget, FALSE,
								WA_CloseGadget, TRUE,
                        WA_RMBTrap, TRUE,
                        //WA_CloseGadget, TRUE,
                        //WA_DepthGadget, TRUE,
								WA_Activate, TRUE,
                        WA_Title, (unsigned long)name,
                        WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_ACTIVEWINDOW| IDCMP_IDCMPUPDATE | IDCMP_CHANGEWINDOW | IDCMP_NEWSIZE | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS | IDCMP_VANILLAKEY | IDCMP_RAWKEY, // | IDCMP_INTUITICKS | IDCMP_NEWSIZE,
								WA_Flags, WFLG_SIZEGADGET | WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET, // | WFLG_REPORTMOUSE,
								TAG_DONE);
    }
   
    // TODO : __glut_window.depth ne doit pas servir ... vérifier et enlever
    __glut_window.depth = GetBitMapAttr(__glut_window.win->RPort->BitMap, BMA_DEPTH);
 
    glAMakeCurrent(__glut_window.win, __glut_ctx);
 
		__glut_window.redisplay = GL_TRUE;
    __glut_window.reshape = GL_TRUE;


    return 1;
}


void glutSwapBuffers(void) {
    glASwapBuffers(__glut_window.win);
}


void glutFullScreen(void) {
    __glut_fullScreen = GL_TRUE;
		//__setupWindow();
}


void glutSetWindow(int win) {
    __glut_currWindow = win;
}


int glutGetWindow(void) {
    return __glut_currWindow;
}


void glutDestroyWindow(int win) {
	
    glADestroyContext(__glut_ctx);
    CloseWindow(__glut_window.win);
    __glut_window.win = NULL;
    __glut_windowCreated = GL_FALSE;

		// Close the screen only if it's a private one
		if (__glut_fullScreen == GL_TRUE){
			CloseScreen(__glut_screen);
			__glut_screen = NULL;
		}
}


// Afficher la fenêtre si
//          __glut_displayFunc();
//          __glut_window.redisplay = GL_FALSE;
// TODO: passer les coordonnées du pointeur souris à keyboard()
void glutMainLoop(void) {
    struct Window *WinHandle = NULL;
    int done = 0;
    ULONG signals;
   
		if (__glut_windowCreated == GL_FALSE) {
        __setupWindow();
    }

    if ((__glut_window.reshape) && (__glut_reshapeFunc != NULL)){
        __glut_reshapeFunc(__glut_window.width, __glut_window.height);
        __glut_window.reshape = GL_FALSE;
    }
                                    

    // Récupération du handle de fenêtre et boucle des messages
   
    WinHandle = __glut_window.win;
 
        //WaitPort(MyWindow->UserPort);
        //MyWinMsg = (struct IntuiMessage *) GetMsg(MyWindow->UserPort);
 
        while (done == 0){
                        
            signals = SetSignal(0L, 0L);
            if (signals & (1L << WinHandle->UserPort->mp_SigBit)){
                    done = ProcessMessages(WinHandle);
            }
 

            // Comme pour keyboardFunc, vérifier aussi que displayFunc n'est pas NULL
            // Idem pour reshapeFunc

            if ((__glut_window.redisplay) && (__glut_displayFunc != NULL)){
                __glut_displayFunc();
                __glut_window.redisplay = GL_FALSE;
            }
            if ((__glut_window.reshape) && (__glut_reshapeFunc != NULL)){
								__glut_reshapeFunc(__glut_window.width, __glut_window.height);
								__glut_window.reshape = GL_FALSE;
            }
        
            // A chaque tour de boucle on exécute la fonction idle
            if (__glut_idleFunc != NULL) {
                __glut_idleFunc();
            }

        } // ici, done = 1, on sort de la boucle

    
    // Fermeture
    glutDestroyWindow(0);
                                        
    if (CyberGfxBase){
        CloseLibrary(CyberGfxBase);
    }

if (GfxBase){
	CloseLibrary((struct Library *)GfxBase);
}
if (IntuitionBase){
	CloseLibrary((struct Library *)IntuitionBase);
}
    
    CloseDevice((struct IORequest *) &__glut_timeRequest);
}


void glutPostRedisplay(void) {
    __glut_window.redisplay = GL_TRUE;
}


void glutDisplayFunc(void (*func)(void)) {
    __glut_displayFunc = func;
}


void glutReshapeFunc(void (*func)(int width, int height)) {
    __glut_reshapeFunc = func;
}


void glutIdleFunc(void (*func)(void)) {
    __glut_idleFunc = func;
}


void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y)) {
    __glut_keyboardFunc = func;
}

int glutGet(GLenum state) {
    struct timeval thetime;

    switch (state) {
    case GLUT_WINDOW_X :
        return __glut_window.x;
    case GLUT_WINDOW_Y :
        return __glut_window.y;
    case GLUT_WINDOW_WIDTH :
        return __glut_window.width;
    case GLUT_WINDOW_HEIGHT :
        return __glut_window.height;
    case GLUT_WINDOW_DEPTH_SIZE :
        return __glut_window.depth;
    case GLUT_WINDOW_PARENT :
        return 0;
    case GLUT_WINDOW_NUM_CHILDREN :
        return 0;
    case GLUT_SCREEN_WIDTH :
        return __glut_window.win->WScreen->Width;
    case GLUT_SCREEN_HEIGHT :
        return __glut_window.win->WScreen->Height;
    case GLUT_SCREEN_WIDTH_MM :
        return 0;
    case GLUT_SCREEN_HEIGHT_MM :
        return 0;
    case GLUT_INIT_WINDOW_X :
        return __glut_initX;
    case GLUT_INIT_WINDOW_Y :
        return __glut_initY;
    case GLUT_INIT_WINDOW_WIDTH :
        return __glut_initWidth;
    case GLUT_INIT_WINDOW_HEIGHT :
        return __glut_initHeight;
    case GLUT_ELAPSED_TIME :
        GetSysTime(&thetime);
        SubTime(&thetime, &__glut_initTime); /* Now thetime contains the elapsed time */
        return (int)((thetime.tv_secs*1000) + (thetime.tv_micro / 1000));
    }

    return -1;
}

/// Not implemented
void glutInitDisplayMode(unsigned int mode) {}

 
static int ProcessMessages(struct Window *WinHandle){
    int done = 0;
    ULONG portsig, waitsigs;
    struct IntuiMessage *imsg = NULL;

            portsig = 1L << WinHandle->UserPort->mp_SigBit;

      waitsigs = Wait(portsig | SIGBREAKF_CTRL_C);
      if (waitsigs & portsig){
        while (imsg = (struct IntuiMessage *)GetMsg(WinHandle->UserPort)){

          switch (imsg->Class){
            case IDCMP_CLOSEWINDOW:
              done = 1;
              break;
            case IDCMP_IDCMPUPDATE:
							//printf("IDCMPUPDATE\n");
              break;
            case IDCMP_VANILLAKEY:
							// TODO: passer les coordonnées à la place de (0,0)
							//printf("Code VANILLAKEY = %d\n", imsg->Code);
              if (imsg->Code == 27){
									done = 1;
              }else{
									if (__glut_keyboardFunc){
											__glut_keyboardFunc(imsg->Code, 0, 0);
									}
              }
              break;
            case IDCMP_NEWSIZE:
                            //printf("NEWSIZE\n");
              break;
            case IDCMP_MOUSEMOVE:
                            //__glut_mouseX = ave_event.msg->EVD_X;
                            //__glut_mouseY = ave_event.msg->EVD_Y;
                            //printf("MOUSEMOVE\n");
              break;
            case IDCMP_CHANGEWINDOW:
                            //printf("CHANGEWINDOW\n");
              break;
            case IDCMP_REFRESHWINDOW:
                            //printf("REFRESHWINDOW\n");
              break;
            case IDCMP_ACTIVEWINDOW:
                            //printf("ACTIVEWINDOW\n");
              break;
						case IDCMP_MOUSEBUTTONS:
                            //case IECODE_LBUTTON:

                            break;
            case IDCMP_RAWKEY:
                            // Code 45 : escape
                            //printf("RAWKEY\n");
                            //printf("Code RAWKEY = %d\n", imsg->Code);
                            if (__glut_keyboardFunc != NULL) {
                                __glut_keyboardFunc(imsg->Code, 0, 0);
                            }
              break;
                        //default:
                            //printf("IDCMP_default\n");
          }
                    ReplyMsg((struct Message *)imsg);
        }
      }
      if (waitsigs & SIGBREAKF_CTRL_C){
        done = 1;
      }
                                            
    return done;
}
    
 
