/************************************************************************/
/*                                                                      */
/*                            Compiler: DICE                            */
/*                                                                      */
/*                            Compilerusage:                            */
/*                                                                      */
/*               DCC -oExample1 Example1.c Font.c Font1.c               */
/*                                                                      */
/************************************************************************/


#include <intuition/intuition.h>

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;

extern struct TextFont Ruby12Font;
extern struct TextFont Garnet9Font;

struct Window *win;
struct RastPort *rp;
struct IntuiMessage *mes;

struct TextAttr attr_Ruby12,attr_Garnet9;

struct NewWindow nwin =
  {
    30,15,265,52,0,1,CLOSEWINDOW,ACTIVATE|WINDOWCLOSE|RMBTRAP,
    NULL,NULL,"<- Click to close",NULL,NULL,0,0,0,0,WBENCHSCREEN
  };

struct IntuiText text1 =
  {
    1,0,JAM1,20,17,&attr_Ruby12,"This is an exampletext.",NULL
  };

struct IntuiText text2 =
  {
    1,0,JAM1,20,35,&attr_Garnet9,"Output with PrintIText().",&text1
  };

ULONG mesclass;

dummy()
  {
    _waitwbmsg();
  }

_main()
  {
    win=(struct Window *)OpenWindow(&nwin);

    rp=win->RPort;

    FontInit_Ruby12();
    SetFont(rp,&Ruby12Font);
    AddFont(&Ruby12Font);
    AskFont(rp,&attr_Ruby12);

    FontInit_Garnet9();
    SetFont(rp,&Garnet9Font);
    AddFont(&Garnet9Font);
    AskFont(rp,&attr_Garnet9);

    PrintIText(rp,&text2,0,0);

    for(;;)
      {
        if(mes=(struct IntuiMessage *)GetMsg(win->UserPort))
          {
            mesclass=mes->Class;
            ReplyMsg(mes);
            if(mesclass==CLOSEWINDOW)
              {
                close_all();
                exit(0);
              }
          }
      }
  }

close_all()
  {
    RemFont(&Ruby12Font);
    RemFont(&Garnet9Font);
    CloseWindow(win);
  }

