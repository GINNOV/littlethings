// Lines.c, a trivial example of using ASAP

// Adaptation of the SAS sample "lines.c"



//extern "C"

//{
#include <stdlib.h>
//}

#include <ASAP/Window.h>
#include <ASAP/RastPort.h>
#include <ASAP/MsgPort.h>
#include <ASAP/IntuiMessage.h>

void DrawLines (ARastPort& , int, int);

void main(void)
{
 typedef ULONG MessageClass;

 NewWindow The_NewWindow =
 {
  100,100, 300,200,
  2,1,                    /* detail, block pens */
  IDCMP_CLOSEWINDOW | IDCMP_NEWSIZE | IDCMP_INTUITICKS,          /* IDCMP flags */
  WINDOWDRAG | WINDOWCLOSE | GIMMEZEROZERO/* | WINDOWSIZING*/,   /* Window flags */
  NULL,                   /* Pointer to first gadget */
  NULL,                   /* Pointer to checkmark */
  (unsigned char *) "ASAP Lines",          /* title */
  NULL,                   /* screen pointer */
  NULL,                   /* bitmap pointer */
  50,50,640,400,          /* window not sized */
  WBENCHSCREEN            /* type of screen */
 };

 AWindow *pThe_Window = new (&The_NewWindow) AWindow;

 if (pThe_Window)
 {
  ARastPort& The_RastPort = *(ARastPort *) pThe_Window->RPort;                  /* Get the raster port pointer */

  The_RastPort.SetDrMd(JAM1);               /* Draw with foreground pen */

  int xlim = pThe_Window->Width,
      ylim = pThe_Window->Height;

  MessageClass This_MessageClass = NULL;

  do
  {
   static
   AMsgPort& The_MsgPort = * (AMsgPort *) pThe_Window->UserPort;

   The_MsgPort.WaitPort();

   static
   AIntuiMessage *pThis_IntuiMessage;

   do
   {
    pThis_IntuiMessage = (AIntuiMessage *) The_MsgPort.GetMsg();

    if (pThis_IntuiMessage)
    {
     This_MessageClass = pThis_IntuiMessage->Class;

     pThis_IntuiMessage->ReplyMsg();

     switch (This_MessageClass)
     {
      case IDCMP_NEWSIZE: xlim = pThe_Window->Width; ylim = pThe_Window->Height; break;
      case IDCMP_INTUITICKS: DrawLines(The_RastPort, xlim, ylim);
     }
    }
   } while (pThis_IntuiMessage);
  } while (This_MessageClass != IDCMP_CLOSEWINDOW);

  delete pThe_Window;
 }
}

void DrawLines (ARastPort& The_RastPort, int xlim, int ylim)
{
 register short i;
 register int k;

 static
 int iColour = rand() % 256;

 static
 long j = 10;

 static
 int x[2] = { rand() % xlim + 1, rand() % xlim + 1 },
     y[2] = { rand() % ylim + 1, rand() % ylim + 1 },
     xd[2] = { rand() % 10 + 1, rand() % 10 + 1  },
     yd[2] = { rand() % 10 + 1, rand() % 10 + 1  },
     ox[2][16],oy[2][16];

 The_RastPort.SetAPen(0);
 The_RastPort.Move(ox[0][j & 15],oy[0][j & 15]);
 The_RastPort.Draw(ox[1][j & 15],oy[1][j & 15]);

 The_RastPort.SetAPen(iColour);
 The_RastPort.Move(x[0], y[0]);
 The_RastPort.Draw(x[1], y[1]);

 if((rand() & 127) < 2)
 {
  if( ++ iColour > 255) iColour = 1;

  The_RastPort.SetAPen(iColour);
 }

 for (i = 0; i < 2; ++ i)
 {
  ox[i][j] = x[i];
  oy[i][j] = y[i];
  x[i] += xd[i];
  y[i] += yd[i];

  if (x[i] < 2) { x[i] = 2; xd[i] = -xd[i]; }
  else if (x[i] > xlim)
  {
   x[i] = xlim;
   xd[i] = -xd[i];
  }

  if (y[i] < 2) { y[i] = 2; yd[i] = -yd[i]; }
  else if (y[i] > ylim) { y[i] = ylim; yd[i] = -yd[i]; }

  if (((rand() >> 5) & 127) < 2)
  {
   if (xd[i] < 1) k = 1; xd[i] = (rand() >> 5) & 7;

   if(k == 1) xd[i] = -xd[i]; k = 0;
  }

  if(((rand() >> 5) & 255) < 50)
  {
   if(yd[i] < 1) k = 1; yd[i] = (rand() >> 5) & 7;

   if(k == 1) yd[i] = -yd[i];
   k = 0;
  }
 }

 j = ++ j % 16; // + 10;
}


