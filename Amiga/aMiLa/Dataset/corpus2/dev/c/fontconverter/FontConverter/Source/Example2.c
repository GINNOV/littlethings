/************************************************************************/
/*                                                                      */
/*                            Compiler: DICE                            */
/*                                                                      */
/*                            Compilerusage:                            */
/*                                                                      */
/*               DCC -oExample2 Example2.c Font.c Font1.c               */
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

struct NewWindow nwin =
  {
    30,15,220,55,0,1,CLOSEWINDOW,ACTIVATE|WINDOWCLOSE|RMBTRAP,
    NULL,NULL,"<- Click to close",NULL,NULL,0,0,0,0,WBENCHSCREEN
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

    SetAPen(rp,1);

    FontInit_Ruby12();
    FontInit_Garnet9();

    SetFont ( rp,&Ruby12Font );
    Move(rp,20,27);
    Text(rp,"This is an example.",19);

    SetFont ( rp,&Garnet9Font );
    Move(rp,20,45);
    Text(rp,"Output with Text().",19);

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
    CloseWindow(win);
  }

