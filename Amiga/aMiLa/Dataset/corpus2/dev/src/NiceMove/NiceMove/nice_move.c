/* nice_move
 *
 * Zeigt unterschiedliche Varianten der IDCMP_MOUSEMOVE-Abfrage
 * Shows different routines for MOUSEMOVE-event handling
 *
 * compile: LC -cisu -v -rr -O nice_move
 * link:    BLink FROM LIB:c.o,nice_move.o TO nice_move SC SD ND LIB LIB:lcr.lib
 */

#include <stdio.h>

#define MY_IDCMP (IDCMP_CLOSEWINDOW | IDCMP_MOUSEBUTTONS)


/***** Variablen, Datas *****/

struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;

struct TextAttr myfont = {"topaz.font", 8, 0x00,0x00};
struct Screen *screen = NULL;
struct NewScreen newscreen =
{
   0,0, 640,256, 4, 0,1,
   HIRES, CUSTOMSCREEN,
   &myfont, NULL, NULL, NULL
};

struct Window *window = NULL;
struct NewWindow newwindow =
{
   0,0, 640,256, -1,-1,
   NULL,                            /* IDCMP: wird sp‰ter init. */
   WFLG_SMART_REFRESH | WFLG_NOCAREREFRESH | WFLG_ACTIVATE | WFLG_RMBTRAP |
      WFLG_CLOSEGADGET,
   NULL, NULL, "Nice move", NULL, NULL,
   0,0, 0,0, CUSTOMSCREEN
};

struct RastPort *rp;
UWORD mode, depth = 4;

WORD x1 = -100,y1, ox,oy;


/***** Routinen *****/

int CXBRK(void) {return(0);}           /* disable Ctrl-C */
void chkabort(void) {}


void close_all(char *s, int err)
{
   if (window)          CloseWindow(window);
   if (screen)          CloseScreen(screen);

   if (GfxBase)         CloseLibrary((struct Library *)GfxBase);
   if (IntuitionBase)   CloseLibrary((struct Library *)IntuitionBase);

   if (s)
   {
      fputs(s, stdout);
      fputs("!\n", stdout);
   }

   exit(err);
}


void draw_line(WORD x1, WORD y1, WORD x2, WORD y2)
{
   Move(rp, x1,y1);
   Draw(rp, x2,y2);
}


void handle_mb(UWORD code, WORD mx, WORD my)
{
   switch (code)
   {
      case SELECTDOWN:
         ox = x1 = mx;
         oy = y1 = my;
         SetDrMd(rp, COMPLEMENT);
         WritePixel(rp, x1,y1);
         break;
      case SELECTUP:
         draw_line(x1,y1, ox,oy);
         SetDrMd(rp, JAM2);
         draw_line(x1,y1, mx,my);
         x1 = -100;
         break;
   } /* switch (code) */
}


void do_move(WORD mx, WORD my)
{
   char str[16];
   BYTE old_mode;

   sprintf(str, "X: %3d  Y: %3d", mx,my);
   old_mode = rp->DrawMode;
   SetDrMd(rp, JAM2);
   Move(rp, 10,20);
   Text(rp, str, 14);
   SetDrMd(rp, old_mode);

   if (x1 != -100)
   {
      draw_line(x1,y1, ox,oy);
      draw_line(x1,y1, mx,my);
      ox = mx;
      oy = my;
   }
}


void mainloop1(void)
/* normaler Loop, der bei jeder MOUSEMOVE-msg anpaﬂt
 * schnelle Reaktion, braucht viel CPU-Power,
 * bei depth=1 noch brauchbar, ab depth=2 l‰uft er nach, bei depth=4
 * absolut unbrauchbar
 *
 * quite the normal loop: on every MOUSEMOVE message the drawing routine is
 * called
 * fast reaction, needs a lot of CPU time
 * with depth=1 ok, depth=4 completely useless
 */
{
   struct IntuiMessage *msg;
   ULONG class;
   UWORD code;
   WORD mx,my;
   BOOL quit = FALSE;

   ModifyIDCMP(window, MY_IDCMP | IDCMP_MOUSEMOVE);
   ReportMouse1(window, TRUE);

   while (!quit)
   {
      WaitPort(window->UserPort);
      while (msg = (struct IntuiMessage *)GetMsg(window->UserPort))
      {
         class = msg->Class;
         code = msg->Code;
         mx = msg->MouseX;
         my = msg->MouseY;
         ReplyMsg((struct Message *)msg);

         switch (class)
         {
            case IDCMP_MOUSEMOVE:
               do_move(mx,my);
               break;
            case IDCMP_MOUSEBUTTONS:
               handle_mb(code, mx,my);
               break;
            case IDCMP_CLOSEWINDOW:
               quit = TRUE;
               break;
         } /* switch (class) */
      } /* while (GetMsg()) */
   } /* while (!quit) */
}


void mainloop2(void)
/* wie mainloop1, verwendet aber busy-loop (ARGH!!), Testzweck!!
 * minimalste Beschleunigung gegen¸ber mainloop1, also NICHT N÷TIG
 *
 * like mainloop1, but use a BUSY-LOOP (ARGH!!), just for tests,
 * no improvements towards mainloop1, hands off from this routine!
 */
{
   struct IntuiMessage *msg;
   ULONG class;
   UWORD code;
   WORD mx,my;
   BOOL quit = FALSE;

   ModifyIDCMP(window, MY_IDCMP | IDCMP_MOUSEMOVE);
   ReportMouse1(window, TRUE);

   while (!quit)
   {
      while (msg = (struct IntuiMessage *)GetMsg(window->UserPort))
      {
         class = msg->Class;
         code = msg->Code;
         mx = msg->MouseX;
         my = msg->MouseY;
         ReplyMsg((struct Message *)msg);

         switch (class)
         {
            case IDCMP_MOUSEMOVE:
               do_move(mx,my);
               break;
            case IDCMP_MOUSEBUTTONS:
               handle_mb(code, mx,my);
               break;
            case IDCMP_CLOSEWINDOW:
               quit = TRUE;
               break;
         } /* switch (class) */
      } /* while (GetMsg()) */
   } /* while (!quit) */
}


void mainloop3(void)
/* wie 1, im while (GetMsg())-Loop wird aber bei MOUSEMOVE nur ein Flag
 * gesetzt, daﬂ auﬂerhalb des Loops den Aufruf Routine veranlaﬂt
 * schnelle Reaktion, kein Nachlaufen, ab depth=3 minimales Nachlaufen
 *
 * like 1, but during the while (GetMsg())-loop the MOUSEMOVE-event just
 * sets a single flag (fast operation). At the end of the loop the flag
 * invokes the drawing
 * fast reaction, from depth=3 the line runs after the pointer a very little
 * bit
 */
{
   struct IntuiMessage *msg;
   ULONG class;
   UWORD code;
   WORD mx,my;
   BOOL quit = FALSE, moved;

   ModifyIDCMP(window, MY_IDCMP | IDCMP_MOUSEMOVE);
   ReportMouse1(window, TRUE);

   while (!quit)
   {
      WaitPort(window->UserPort);
      while (msg = (struct IntuiMessage *)GetMsg(window->UserPort))
      {
         class = msg->Class;
         code = msg->Code;
         mx = msg->MouseX;
         my = msg->MouseY;
         ReplyMsg((struct Message *)msg);

         switch (class)
         {
            case IDCMP_MOUSEMOVE:
               moved = TRUE;
               break;
            case IDCMP_MOUSEBUTTONS:
               handle_mb(code, mx,my);
               break;
            case IDCMP_CLOSEWINDOW:
               quit = TRUE;
               break;
         } /* switch (class) */
      } /* while (GetMsg()) */
      if (moved)
      {
         do_move(mx,my);         /* benutzt letzte Koordinaten */
         moved = FALSE;
      }
   } /* while (!quit) */
}


void mainloop4(void)
/* bei jedem INTUITICK wird angepaﬂt, MOUSEMOVE wird NICHT abgefragt
 * reagiert langsam, aber ohne Nachlaufen (Linie bleibt bis zum n‰chsten
 * INTUITICK allerdings stehen, minimales Nachlaufen)
 *
 * no MOUSEMOVE, on every INTUITICKS the line is updated, if the pointer
 * position has changed.
 * slow reaction, but for some cases fast enough
 */
{
   struct IntuiMessage *msg;
   ULONG class;
   UWORD code;
   WORD mx=0,my=0, oldx,oldy;
   BOOL quit = FALSE;

   ModifyIDCMP(window, MY_IDCMP | IDCMP_INTUITICKS);

   while (!quit)
   {
      WaitPort(window->UserPort);
      while (msg = (struct IntuiMessage *)GetMsg(window->UserPort))
      {
         class = msg->Class;
         code = msg->Code;
         oldx = mx;
         oldy = my;
         mx = msg->MouseX;
         my = msg->MouseY;
         ReplyMsg((struct Message *)msg);

         switch (class)
         {
            case IDCMP_INTUITICKS:
               if ((mx != oldx) || (my != oldy))
                  do_move(mx,my);
               break;
            case IDCMP_MOUSEBUTTONS:
               handle_mb(code, mx,my);
               break;
            case IDCMP_CLOSEWINDOW:
               quit = TRUE;
               break;
         } /* switch (class) */
      } /* while (GetMsg()) */
   } /* while (!quit) */
}


void open_all(void)
{
   if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 33)))
      close_all("No intuition.library", 20);
   if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 33)))
      close_all("No graphics.library", 20);

   newscreen.Depth = depth;
   if (!(screen = OpenScreen(&newscreen)))
      close_all("Can`t open screen", 20);
   newwindow.Screen = screen;
   if (!(window = OpenWindow(&newwindow)))
      close_all("Can`t open window", 20);

   if (IntuitionBase->LibNode.lib_Version >= 36) /* bei OS 2.0 MOUSEMOVE- */
      SetMouseQueue(window, 500);   /* Queue-K¸rzung (nahezu) verhindern */

   rp = window->RPort;                    /* init. RastPort */
   SetAPen(rp, 1);
   SetDrMd(rp, JAM2);
}


void usage(void)
{
   puts("Usage: nice_move mode [depth]");
   puts("  mode = 1: normaler Loop");
   puts("       = 2: wie 1, aber busy-loop (ARGH!!), kein WaitPort()");
   puts("       = 3: wie 1, aber erst auﬂerhalb der while (GetMsg())-Schleife wird");
   puts("            die Routine aufgerufen, im Loop wird nur ein Flag gesetzt");
   puts("       = 4: kein MOUSEMOVE, sondern INTUITICKS");
   puts("  depth: Screen depth (1 - 4), default is 4");

   exit(5);
}


void main(int argc, char *argv[])
{
   if ((argc < 2) || (argc > 3))
      usage();

   mode = *argv[1] - '0';
   if ((mode < 1) || (mode > 4))
      usage();
   if (argc == 3)                   /* depth angegeben? */
   {
      depth = *argv[2] - '0';
      if ((depth < 1) || (depth > 4))
         depth = 4;
   }

   open_all();

   switch (mode)
   {
      case 1:
         mainloop1();
         break;
      case 2:
         mainloop2();
         break;
      case 3:
         mainloop3();
         break;
      case 4:
         mainloop4();
         break;
   }

   close_all(NULL, 0);
}

